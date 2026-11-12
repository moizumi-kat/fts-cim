# -*- coding: utf-8 -*-
"""COBOL の索引ファイルのふるまい（READ／WRITE／REWRITE／DELETE／START／READ NEXT）
   が、現行どおりかを確かめる。

     python3 点検/chk_fairu.py
"""
import sys, pathlib, sqlite3, tempfile, os
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim import db, schema_gen
from cim.cobol import fairu
from cim.cobol.fairu_a10040po import FAIRU

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)

print('■ A10040PO が使う索引ファイル %d本' % len(FAIRU))
miru('18本ある', len(FAIRU) == 18, '%d' % len(FAIRU))

# 表とキーが本当に在るか
nai = []
for ronri, (na, hyo, kagi, _sts) in FAIRU.items():
    if hyo not in schema_gen.TABLES:
        nai.append('%s→表%s' % (ronri, hyo)); continue
    h = {c[0] for c in schema_gen.TABLES[hyo]['cols']}
    for k in kagi:
        if k not in h:
            nai.append('%s のキー %s' % (ronri, k))
miru('表もキーもすべて実在', not nai, '／'.join(nai[:3]))

# 仮のデータベースを作って、実際に動かす
tmp = tempfile.mkdtemp()
con = sqlite3.connect(os.path.join(tmp, 't.db'))
con.row_factory = sqlite3.Row
for sql in db.ddl('sqlite'):
    con.execute(sql)

print()
print('■ ワーク鑑（AWKGFP・キー MITUNO）で入出力を一通り')
f = fairu.Fairu(con, 'AWKGFP', ['MITUNO'], 'AWKGFL1', db=db)

miru('無いものを READ → "23"', f.yomu('A0000001') == fairu.NASHI, f.status)
miru('WRITE → "00"', f.kaku({'MITUNO': 'A0000001', 'KENME1': '一件目'}) == fairu.SEIJOU)
miru('同じキーをもう一度 WRITE → "22"',
     f.kaku({'MITUNO': 'A0000001', 'KENME1': 'ニ重'}) == fairu.JYUUFUKU)
miru('READ → "00"', f.yomu('A0000001') == fairu.SEIJOU)
miru('読んだ値が合っている', f['KENME1'] == '一件目', repr(f['KENME1']))
f['KENME1'] = '直した'
miru('REWRITE → "00"', f.kakinaosu() == fairu.SEIJOU)
f.yomu('A0000001')
miru('書き直しが効いている', f['KENME1'] == '直した', repr(f['KENME1']))
miru('無いものを REWRITE → "23"',
     f.kakinaosu({'MITUNO': 'Z9999999', 'KENME1': 'x'}) == fairu.NASHI)
miru('DELETE → "00"', f.kesu('A0000001') == fairu.SEIJOU)
miru('消したあと READ → "23"', f.yomu('A0000001') == fairu.NASHI)
miru('無いものを DELETE → "23"', f.kesu('A0000001') == fairu.NASHI)

print()
print('■ ワーク項目（AWKKFP・キー MITUNO＋MITKOB）で START と READ NEXT')
g = fairu.Fairu(con, 'AWKKFP', ['MITUNO', 'MITKOB'], 'AWKKFL1', db=db)
for no, kou in (('B0000001', 1), ('B0000001', 2), ('B0000001', 10),
                ('B0000002', 1)):
    g.kaku({'MITUNO': no, 'MITKOB': kou})
miru('START KEY >= (B0000001, 2) → "00"', g.hajime('B0000001', 2) == fairu.SEIJOU)
yonda = []
while g.tsugi() == fairu.SEIJOU:
    yonda.append((g['MITUNO'], g['MITKOB']))
miru('その位置から順に読める',
     yonda == [('B0000001', 2), ('B0000001', 10), ('B0000002', 1)],
     str(yonda))
miru('最後は "10"（AT END）', g.status == fairu.OWARI, g.status)
miru('キーの2つめも正しく比べている（2 の次が 10）',
     [k for _n, k in yonda if _n == 'B0000001'] == [2, 10])
miru('START で届かない位置 → "23"', g.hajime('Z9999999', 1) == fairu.NASHI)

con.close()
print()
print('=' * 60)
if warui:
    print('■ %d件 合いませんでした。' % warui)
else:
    print('■ すべて現行のふるまいどおりでした。')
print('=' * 60)
sys.exit(1 if warui else 0)
