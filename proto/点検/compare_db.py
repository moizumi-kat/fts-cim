# -*- coding: utf-8 -*-
"""現行システムの処理結果と、この試作の処理結果を**全項目**つき合わせる。

    python 点検/compare_db.py <正解CSVの入ったフォルダ> [表名 ...]

正解CSV＝現行システムで同じ入力を処理したあとのファイルの中身。
表名と同じ名前の .csv を探します（AJUGFP.csv／JURITUFP.CSV など）。
見出し行があれば見出しで、無ければレコードの並び順で対応づけます。

比べかた
  ・主キーでレコードを対応づけ、**列を1つずつ**比べます。
  ・char／nchar は後ろの空白を無視します（現行は固定長、SQL Server も同じ）。
  ・数値は値として比べます（0 と 0.0 と "0" は同じ）。
  ・作成日・作成時間・更新日・更新時間・端末ＩＤは、実行のたびに変わるので
    既定では比べません。比べたいときは --with-time を付けてください。

  ちがいが1件でもあれば終了コード 1 で終わります。
"""
import csv, io, os, re, sys
from decimal import Decimal, InvalidOperation

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from cim.db import connect, q
from cim.schema_gen import TABLES
from load_csv import BESSOU, _midashi      # 見出しの対応づけは取り込みと同じものを使う

# 実行のたびに変わる項目（既定では比べない）
JIKOKU = ('CRTDAY', 'CRTDAT', 'CRTTIM', 'UPDDAY', 'UPDTIM', 'WSID', 'CRTWS')

def norm(v, ty):
    """比べられる形にそろえる。"""
    if v is None: return ''
    s = str(v).strip()
    if s == '': return ''
    if re.match(r'^(decimal|numeric)', ty or ''):
        try:
            d = Decimal(s)
            # 40000 を 4E+4 と出さないよう、整数は整数のまま
            return d.quantize(Decimal(1)) if d == d.to_integral_value() else d.normalize()
        except InvalidOperation: return s
    return s

def read_csv(tbl, path, cols):
    raw = open(path, 'rb').read()
    for enc in ('utf-8-sig', 'cp932', 'utf-8'):
        try: txt = raw.decode(enc); break
        except UnicodeDecodeError: txt = None
    if txt is None: txt = raw.decode('cp932', 'replace')
    rd = csv.reader(io.StringIO(txt))
    try: head = next(rd)
    except StopIteration: return []
    tsuita = [_midashi(tbl, h) for h in head]
    if sum(1 for x in tsuita if x) >= max(1, len(head) // 2):
        use = tsuita
    else:
        use = cols[:len(head)]
        rd = csv.reader(io.StringIO(txt))
    out = []
    for row in rd:
        d = {}
        for c, v in zip(use, row):
            if c: d[c] = v.strip()
        if d: out.append(d)
    return out

def compare(con, tbl, path, with_time):
    t = TABLES[tbl]
    cols = [c[0] for c in t['cols']]
    ty = {c[0]: c[1] for c in t['cols']}
    pk = t['pk'] or cols[:1]
    mine = q(con, 'SELECT * FROM %s' % tbl)
    seikai = read_csv(tbl, path, cols)
    look = [c for c in cols if with_time or c.upper() not in JIKOKU]

    def keyof(r): return tuple(norm(r.get(k), ty.get(k)) for k in pk)
    m = {keyof(r): r for r in mine}
    s = {keyof(r): r for r in seikai}
    sagai = []
    for k in sorted(set(s) - set(m)):
        sagai.append(('こちらに無い', k, '', '', ''))
    for k in sorted(set(m) - set(s)):
        sagai.append(('正解に無い', k, '', '', ''))
    for k in sorted(set(m) & set(s)):
        for c in look:
            a, b = norm(m[k].get(c), ty.get(c)), norm(s[k].get(c), ty.get(c))
            if a != b:
                sagai.append(('値がちがう', k, c, a, b))
    return len(mine), len(seikai), sagai, pk

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    with_time = '--with-time' in sys.argv
    if not args:
        print(__doc__); return 2
    src, want = args[0], [a.upper() for a in args[1:]]
    if not os.path.isdir(src):
        print('フォルダがありません: %s' % src); return 2
    found = {}
    for f in sorted(os.listdir(src)):
        stem, extn = os.path.splitext(f)
        t = BESSOU.get(stem.upper(), stem.upper())
        if extn.lower() == '.csv' and t in TABLES:
            if not want or t in want:
                found[t] = os.path.join(src, f)
    if not found:
        print('比べられる CSV がありませんでした。'); return 1
    print('■ 現行システムの処理結果との突き合わせ（%s）'
          % ('全項目' if with_time else '日時・端末ＩＤを除く全項目'))
    con = connect()
    zen = 0
    try:
        for tbl, path in sorted(found.items()):
            n1, n2, sagai, pk = compare(con, tbl, path, with_time)
            zen += len(sagai)
            print('  %-10s 件数 %6d ／ 正解 %6d   %s'
                  % (tbl, n1, n2, '一致' if not sagai else 'ちがい %d 件' % len(sagai)))
            for kind, k, c, a, b in sagai[:10]:
                key = '／'.join('%s=%s' % (p, v) for p, v in zip(pk, k))
                if c: print('     %-10s %-8s こちら %-18s 正解 %s' % (key, c, a, b))
                else: print('     %-10s %s' % (key, kind))
            if len(sagai) > 10:
                print('     …ほか %d 件' % (len(sagai) - 10))
    finally:
        con.close()
    print()
    if zen:
        print('ちがいが %d 件ありました。' % zen); return 1
    print('すべての項目が一致しました。')
    return 0

if __name__ == '__main__':
    sys.exit(main())
