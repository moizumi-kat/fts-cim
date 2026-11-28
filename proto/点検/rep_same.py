# -*- coding: utf-8 -*-
"""レプリケーション対象の表が、村上様よりお送りいただいた定義体（DDL）と
   一字一句同じになっているかを確かめる。

   使いかた:  python 点検/rep_same.py  [定義体の .sql が入ったフォルダ]
              フォルダを省くと ..\03_定義体 を見ます（zip の同梱分）。
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from cim.schema_gen import TABLES

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

re_tbl = re.compile(r'CREATE\s+TABLE\s+\[dbo\]\.\[([^\]]+)\]\s*\(', re.I)
re_col = re.compile(r'^\s*\[([^\]]+)\]\s*\[([A-Za-z]+)\]\s*(\(([^)]*)\))?\s*(NOT\s+NULL|NULL)?', re.I)
re_pk  = re.compile(r'PRIMARY\s+KEY', re.I)
re_df  = re.compile(r'ALTER\s+TABLE\s+\[dbo\]\.\[([^\]]+)\]\s+ADD\s+DEFAULT\s+\((.*?)\)\s+FOR\s+\[([^\]]+)\]', re.I | re.S)

def read(path):
    txt = open(path, 'rb').read().decode('cp932', 'replace')
    m = re_tbl.search(txt)
    if not m: return None
    name, cols, pk, in_pk = m.group(1), [], [], False
    for line in txt[m.end():].splitlines():
        s = line.strip()
        if re_pk.search(s): in_pk = True; continue
        if in_pk:
            if s.startswith(')'): in_pk = False; continue
            k = re.match(r'^\[([^\]]+)\]', s)
            if k: pk.append(k.group(1))
            continue
        if s.upper().startswith('CONSTRAINT'): continue
        if s.startswith(')') or s.upper().startswith('GO'): break
        c = re_col.match(s)
        if c:
            arg = (c.group(4) or '').replace(' ', '')
            cols.append((c.group(1), c.group(2).lower() + ('(%s)' % arg if arg else ''),
                         not (c.group(5) and c.group(5).upper() == 'NULL')))
    df = {d.group(3): d.group(2).strip() for d in re_df.finditer(txt) if d.group(1) == name}
    return name, cols, pk, df

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if len(sys.argv) > 1:
    src = sys.argv[1]
else:
    # zip を展開した場所によって位置が変わるので、ありそうな所を順に探す
    src = ''
    for cand in ('03_定義体', os.path.join('..', '03_定義体'),
                 os.path.join(HERE, '03_定義体'),
                 os.path.join(HERE, '..', '03_定義体')):
        if os.path.isdir(cand): src = cand; break
if not src or not os.path.isdir(src):
    print('定義体（.sql）のフォルダが見つかりませんでした。')
    print('zip を展開したフォルダの中の「03_定義体」を指定してください。')
    print('  例) py -3.13 点検\\rep_same.py  "D:\\受領\\FTS-CIM IT部門お渡し一式\\03_定義体"')
    sys.exit(2)
book = {}
for fn in sorted(os.listdir(src)):
    if fn.lower().endswith('.sql'):
        r = read(os.path.join(src, fn))
        if r: book[r[0]] = r[1:]

ok = ng = 0
for t in sorted(TABLES):
    if TABLES[t]['src'] != 'rep': continue
    if t not in book:
        print('  %-10s 定義体が見あたりません' % t); ng += 1; continue
    cols, pk, df = book[t]
    mine  = [(c[0], c[1], c[0] in set(TABLES[t]['notnull'])) for c in TABLES[t]['cols']]
    bad = []
    if mine != cols:             bad.append('列（名前・型・NOT NULL）')
    if TABLES[t]['pk'] != pk:    bad.append('主キー')
    if TABLES[t]['default'] != df: bad.append('既定値')
    if bad:
        ng += 1
        print('  %-10s 違う: %s' % (t, '／'.join(bad)))
        for a, b in zip(mine, cols):
            if a != b: print('      こちら %s ／ 定義体 %s' % (a, b)); break
    else:
        ok += 1
        print('  %-10s 一致（%d列・主キー %s）' % (t, len(cols), ','.join(pk) or 'なし'))

print('\nレプリケーション対象 %d 表： 一致 %d ／ 違い %d' % (ok + ng, ok, ng))
sys.exit(1 if ng else 0)
