# -*- coding: utf-8 -*-
"""cim/schema_gen.py を起こす（405工程が使う表すべて）。

  出どころは2つだけ。どちらも村上様からいただいた現物で、推測はしない。
    1) レプリケーション対象 … 定義体（DDL）を**一字一句そのまま**
    2) それ以外            … レコードリストから変換仕様書どおりに起こす
  日本語の項目名は、どちらの場合もレコードリストから引いて見出し用に添える。

  検算（必ず通すこと）
    既存32表（村上様へお渡し済み・レビュー済み）を1列もずれずに再現できること。
      レプリケーション 22表／変換 10表 → bin/chk_schema.py

  使い方
    python3 gen_schema_all.py <レコードリスト置き場> <定義体置き場> \
                              work_tables.json 出力先.py
"""
import sys, json, pprint, pathlib, collections
sys.path.insert(0, str(pathlib.Path(__file__).parent))
import recdef, repdef, oginai, fd_hirou

RECDIR, DEFDIR, TBLJSON, OUT = sys.argv[1:5]
SRCDIR = sys.argv[5] if len(sys.argv) > 5 else 'cim/utf8'

rec = recdef.yomu(RECDIR)
rep = repdef.yomu(DEFDIR)
tbl = json.load(open(TBLJSON))

MOKUHYO = tbl['hyo']                 # 作る表の一覧
HANTEI  = tbl.get('hantei', {})      # 仕分けの判定

# 名前のゆれ（仕分け提案書「⑤ ファイル名の訂正」）。
# レコードリストは台帳の名前で持っているので、正しい名前でも引けるようにする。
for _a, _b in (tbl.get('naoshi') or {}).items():
    if _a in rec and _b not in rec:
        rec[_b] = rec[_a]

TABLES, warn, nashi = {}, collections.defaultdict(list), []

# レコードリストにも定義体にも無い表を、現行ソースの根拠で補う（bin/oginai.py）
oginai.oginau(rec, rep, SRCDIR)

for t in MOKUHYO:
    r = rec.get(t)
    jp = {}
    if r:
        cols, w = recdef.hashira(r['items'], t)
        jp = {c[0]: c[2] for c in cols}
        if w:
            warn[t] += w
    if t in rep:                                   # ① 定義体のまま
        d = rep[t]
        TABLES[t] = {
            'src': 'rep',
            'lib': (r or {}).get('lib', ''),
            'nm':  (r or {}).get('nm', ''),
            'ronri': sorted(set((r or {}).get('ronri', []))),
            'cols': [(c[0], c[1], jp.get(c[0], ''), '') for c in d['cols']],
            'notnull': d['notnull'], 'pk': d['pk'], 'default': d['default'],
        }
    elif r:                                        # ② 変換仕様書どおり
        TABLES[t] = {
            'src': {'source': 'source'}.get(r.get('_moto'),
                                            'utsushi' if r.get('_moto') else 'conv'),
            'lib': r['lib'], 'nm': r['nm'],
            'ronri': sorted(set(r.get('ronri', []))),
            'cols': cols,
            'notnull': [], 'pk': [], 'default': {},
        }
        if r.get('_konkyo'):
            TABLES[t]['konkyo'] = r['_konkyo']
            TABLES[t]['moto'] = r.get('_moto')
    else:
        nashi.append(t)
    if t in TABLES:
        TABLES[t]['hantei'] = HANTEI.get(t, '仕分けに無し')

atama = '''# -*- coding: utf-8 -*-
"""現行システムのファイル定義そのもの。bin/gen_schema_all.py が自動生成。
   **手で直さないこと。** 直すなら生成器のほうを直して、作り直す。

  テーブル名 ＝ 現行の物理ファイル名（論理ファイル名は ronri に保持）
  列名      ＝ 現行の COBOL 英名（英大文字）

  src='rep'     … データベースサーバへ**レプリケーションしている**ファイル。
  src='utsushi' … 定義が無く、CL の CNVFILE/SETPF/OVRF/OVRSF が示す**写し元と同じ並び**と
                  みなしたもの（**推定**。根拠は konkyo、写し元は moto）。
  src='source'  … 定義が無く、プログラムが FD の下に直接書いているレコードから起こしたもの。
              村上様よりいただいた定義体（DDL）を一字一句そのまま使う。
              CAD・営業支援システム等の周辺ソフトが同じ定義を見ているため、
              ここは絶対に変えない。
  src='conv'… レプリケーションしていないファイル。
              「COBOLファイル定義からSQL Serverテーブル定義への
                フィールド名変換仕様書」に従って PIC から生成。
              繰返し（OCCURS）は英名を _ で6文字に詰めて _1, _2 … と
              水平展開する。並びは現行のバイト位置のまま（集団項目ごと）。

  hantei … 「FTS-CIM ファイル・テーブル仕分け提案書（第2版）」村上様ご確認済
            の判定。残す／作らない（ワーク・一時が主）／要確認。
            試作環境では**現行の処理をそのまま写すため全部作る**が、
            新システムに残すのは「残す」だけ。

  cols の並び ＝ (列名, 型, 現行の日本語項目名, 現行のPIC)
                 日本語名は画面の見出し用で、列名には使わない。
'''
kazu = collections.Counter(v['src'] for v in TABLES.values())
h = collections.Counter(v['hantei'] for v in TABLES.values())
atama += ('\n   %d表 %d列（定義体のまま %d表 ／ 変換仕様書から %d表'
          ' ／ 現行ソースの根拠で補った %d表）\n') % (
    len(TABLES), sum(len(v['cols']) for v in TABLES.values()),
    kazu['rep'], kazu['conv'], kazu['utsushi'] + kazu['source'])
for k, v in h.most_common():
    atama += '     %-12s %3d表\n' % (k, v)
atama += '"""\n'

body = 'TABLES = ' + pprint.pformat(TABLES, width=100, sort_dicts=True) + '\n'
pathlib.Path(OUT).write_text(atama + body, encoding='utf-8')

print('■ 書き出し %s' % OUT)
print('   %d表 %d列' % (len(TABLES), sum(len(v['cols']) for v in TABLES.values())))
print('   定義体のまま %d表 ／ 変換仕様書から %d表 ／ 現行ソースの根拠で補った %d表'
      % (kazu['rep'], kazu['conv'], kazu['utsushi'] + kazu['source']))
for _t in sorted(t for t, v in TABLES.items() if v['src'] in ('utsushi', 'source')):
    print('     %-9s %s' % (_t, TABLES[_t]['konkyo']))
for k, v in h.most_common():
    print('     %-12s %3d表' % (k, v))
print()
print('■ 定義が見当たらず作れなかった %d表' % len(nashi))
for t in nashi:
    print('     %-10s %s' % (t, HANTEI.get(t, '仕分けに無し')))
print()
print('■ レコードリストの直し・読めなかった PIC %d表' % len(warn))
for t, w in sorted(warn.items()):
    for x in w:
        print('     %-10s %s' % (t, x))
