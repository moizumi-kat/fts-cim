# -*- coding: utf-8 -*-
"""現行ファイルの実データ（CSV）を取り込む。

    python load_csv.py <CSVの入ったフォルダ>
    python load_csv.py <フォルダ> AJUGFP AJUKFP     ← 表を指定することもできる

Dropbox「CIM更新／新プロジェクト／データ」にある CSV をそのまま読めます。
  ・1行目が英名の見出し行になっているもの（ASOSMP.CSV など）  → 見出しで対応づけ
  ・見出しの無いもの（AJUGFP.csv など）                        → レコードの並び順で対応づけ
文字コードは cp932／UTF-8（BOM付き）のどちらでも読みます。

**現物サンプル（run.py --seed）とは別物です。** こちらは本物のデータです。
"""
import csv, io, os, re, sys, unicodedata
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cim.db import connect, Q
from cim.schema_gen import TABLES

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

# ファイル名が表名と違うもの（中身は同じ）
BESSOU = {}          # 2026-11-11 JURITUFP の読み替えは不要になった
                     # （表名を正しい JURITUFP に直したため）

def _han(s):
    """全角の数字などを半角にそろえる（承認図２ と 承認図2 を同じに扱う）。"""
    return unicodedata.normalize('NFKC', s or '')

def _midashi(tbl, head):
    """CSVの見出し1つを、現行の列名に対応づける。

    いただいたCSVは出どころによって見出しの書きかたが違います。
      ・英名そのまま            SEIBAN, JUCYUK_1
      ・繰返しの _ が1つ少ない  GENDO_1   → 定義体は GENDO__1（5文字を_で6文字に詰める）
      ・日本語の項目名          出力順位, グループ開始01
    どれでも読めるようにします。
    """
    cols = [c[0] for c in TABLES[tbl]['cols']]
    up = head.strip().strip('"').upper()
    if up in cols: return up
    # 繰返し：STEM_N → 英名を _ で6文字に詰めてから _N
    m = re.match(r'^(.*?)_+(\d+)$', up)
    if m:
        cand = m.group(1).ljust(6, '_') + '_' + str(int(m.group(2)))
        if cand in cols: return cand
    # 日本語の項目名（末尾に 01 などの回数が付くことがある）
    ja = {}
    for name, ty, j, pic in TABLES[tbl]['cols']:
        if j: ja.setdefault(_han(j), name)
    h = _han(head.strip().strip('"'))
    if h in ja: return ja[h]
    m = re.match(r'^(.*?)(\d{1,2})$', h)
    if m:
        cand = '%s(%d)' % (m.group(1), int(m.group(2)))
        if cand in ja: return ja[cand]
    return None

# CSV に紛れ込む制御文字（0x00-0x1F・0x7F）
_SEIGYO = {c: None for c in list(range(0x20)) + [0x7F]}
_otoshita = 0

def _soji(v):
    """値から制御文字を落とす。

       ■ なぜ要るか（2026-11-20 実測）
         いただいた CSV の一部に、文字でないバイトが混じっている。
           ABUHMP.PARTNA  '\x00\x1e  VCB 7.2KV400A8KA (M,ﾋｷﾀﾞｼ)PW'  34件
           AHATMP.YOBI    予備欄に生のバイト                        25件
         中身（30バイト）は定義どおりで、**先頭の2バイトが余分**なだけ。
         そのまま入れると SQL Server で「切り捨て」エラーになるので落とす。
         落とした数は最後に件数で出す（黙って直さない）。
    """
    global _otoshita
    t = v.translate(_SEIGYO)
    if t != v:
        _otoshita += 1
    return t

def _open(path):
    raw = open(path, 'rb').read()
    for enc in ('utf-8-sig', 'cp932', 'utf-8'):
        try:
            return io.StringIO(raw.decode(enc)), enc
        except UnicodeDecodeError:
            pass
    return io.StringIO(raw.decode('cp932', 'replace')), 'cp932(置換)'

def load(con, tbl, path):
    cols = [c[0] for c in TABLES[tbl]['cols']]
    fh, enc = _open(path)
    rd = csv.reader(fh)
    try:
        head = next(rd)
    except StopIteration:
        return 0, enc, '空'
    tsuita = [_midashi(tbl, h) for h in head]
    if sum(1 for x in tsuita if x) >= max(1, len(head) // 2):
        use = tsuita                                     # 見出しあり
        wakaranai = [h for h, x in zip(head, tsuita) if not x]
        how = '見出し行で対応づけ'
        if wakaranai:
            how += '（%d 列は対応づけできず飛ばしました: %s）' % (
                len(wakaranai), ' '.join(w.strip().strip('"') for w in wakaranai[:4]))
    else:
        use = cols[:len(head)]                           # 見出しなし＝並び順
        fh.seek(0); rd = csv.reader(fh)
        how = 'レコードの並び順で対応づけ'
    # NOT NULL の列は、空のときは入れずに既定値にまかせる（現行の定義体どおり）。
    # ただし既定値が無い列は、入れないと INSERT が落ちる。現行（COBOL）は
    # 空のときは**文字なら空白・数なら0**なので、そのとおりに入れる。
    #   例 ABUHMP.SKBNCD は CSV で "  "（空白2つ）＝ NOT NULL・既定値なし。
    #      これを飛ばすと「NOT NULL constraint failed」で1表まるごと取り込めない。
    nn = set(TABLES[tbl].get('notnull') or [])
    dflt = set((TABLES[tbl].get('default') or {}).keys())
    kata = {c[0]: str(c[1]) for c in TABLES[tbl]['cols']}

    def _kara(c):
        """空のときに入れる値。None＝入れない（既定値にまかせる）。"""
        if c not in nn:
            return None, True          # NULL を入れてよい
        if c in dflt:
            return None, False         # 既定値にまかせる（列ごと入れない）
        return ('' if kata.get(c, '').startswith(('char', 'nchar', 'varchar',
                                                  'nvarchar')) else 0), True
    n = 0
    con.execute('DELETE FROM %s' % tbl)
    for row in rd:
        d = {}
        for c, v in zip(use, row):
            if not c: continue
            v = _soji(v).strip()
            if v == '':
                atai, ireru = _kara(c)
                if not ireru: continue
                d[c] = atai
            else:
                d[c] = v
        if not d: continue
        con.execute('INSERT INTO %s(%s) VALUES(%s)'
                    % (tbl, ','.join(Q(k) for k in d), ','.join('?' * len(d))),
                    tuple(d.values()))
        n += 1
    con.commit()
    return n, enc, how

def main():
    if len(sys.argv) < 2:
        print(__doc__); return 2
    src = sys.argv[1]
    want = [t.upper() for t in sys.argv[2:]]
    if not os.path.isdir(src):
        print('フォルダがありません: %s' % src); return 2
    found = {}
    for f in sorted(os.listdir(src)):
        stem, ext = os.path.splitext(f)
        if ext.lower() != '.csv': continue
        t = BESSOU.get(stem.upper(), stem.upper())
        if t in TABLES and (not want or t in want):
            found[t] = os.path.join(src, f)
    if not found:
        print('取り込める CSV がありませんでした（表名と同じ名前の .csv を探します）。')
        return 1
    con = connect()
    try:
        for t, p in sorted(found.items()):
            try:
                n, enc, how = load(con, t, p)
                print('  %-10s %7d 件  (%s／%s)' % (t, n, enc, how))
            except Exception as e:
                print('  %-10s 取り込めませんでした: %s' % (t, e))
    finally:
        con.close()
    print('\n%d 表を取り込みました。' % len(found))
    if _otoshita:
        print('※ 文字でないバイト（制御文字）が入っていた値が %d 件あり、'
              'そこだけ落としました。' % _otoshita)
    print('このあと  python batch.py juhen2cf  で当月受注率ファイルを作れます。')
    return 0

if __name__ == '__main__':
    sys.exit(main())
