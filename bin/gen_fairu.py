# -*- coding: utf-8 -*-
"""COBOL の FILE-CONTROL から、ファイルの定義（表名・キー）を起こす。

     python3 bin/gen_fairu.py <プログラム.COB> <schema_gen.py> <出力.py>

  ■ 根拠
     SELECT 鑑ファイル ASSIGN TO DA-01-VI-AJBGFL1
            ORGANIZATION IS INDEXED
            RECORD KEY   IS AJBG-MITUNO
            ACCESS MODE  IS DYNAMIC
            FILE STATUS  IS AJBG-STSCD
     ＝ 索引（キー）はここに書いてある。XFDLIB は要らない。
     論理名 AWKGFL1 → 物理表は schema_gen の ronri（論理ファイル名）から引く。
     キーの項目名 AWKG-MITUNO の「-」より後ろが表の列名（実測）。
"""
import sys, re, pathlib, importlib.util

COB, SCHEMA, OUT = sys.argv[1], sys.argv[2], sys.argv[3]

spec = importlib.util.spec_from_file_location('sg', SCHEMA)
sg = importlib.util.module_from_spec(spec); spec.loader.exec_module(sg)
RONRI = {}
for t, v in sg.TABLES.items():
    for r in v.get('ronri', []):
        RONRI.setdefault(r.upper(), t)

hon = []
for ln in pathlib.Path(COB).read_text('utf-8', errors='replace').splitlines():
    ln = ln.rstrip('\r\n')
    if ln and ln[0] not in ('*', '/', 'D', 'd'):
        hon.append(ln[1:67])
zen = '\n'.join(hon)
tejun = zen.find('FILE-CONTROL')
data = zen.find('DATA', tejun)
naka = zen[tejun:data if data > 0 else len(zen)]

# キーが集団項目のもの。内訳は現物で確かめたものだけを書く。
SHUDAN = {
    ('ASUNMP', 'SUNPO'): (['WIDTH', 'HIGH', 'DEPTH'],
                          'A10040PO.COB 4478-4480行（注記）に '
                          'MOVE AWKM-DW/DH/DD TO ASUN-WIDTH/HIGH/DEPTH とあり、'
                          'ASUN-SUNPO は MOVE HIGH-VALUE で丸ごと埋められている'
                          '（4348行）＝巾・高さ・奥行をまとめた集団項目'),
}

R_SEL = re.compile(r'SELECT\s+(\S+)\s+ASSIGN\s+TO\s+(\S+)(.*?)(?=SELECT\s|\Z)', re.S)
R_KEY = re.compile(r'RECORD\s+KEY\s+IS\s+(.*?)(?=ACCESS|FILE\s+STATUS|ORGANIZATION|\Z)', re.S)
R_ORG = re.compile(r'ORGANIZATION\s+IS\s+(\w+)', re.I)
R_STS = re.compile(r'FILE\s+STATUS\s+IS\s+(\S+)')

b = ['# -*- coding: utf-8 -*-',
     '"""%s が使うファイルの定義。bin/gen_fairu.py が自動生成。**手で直さない。**' % pathlib.Path(COB).stem,
     '',
     '   FILE-CONTROL をそのまま写したもの。',
     '   FAIRU の1件 = 論理名: (COBOLの名前, 物理表, [キーの列], 状態項目)',
     '"""', '', 'FAIRU = {']
kazu, fumei = 0, []
for m in R_SEL.finditer(naka):
    na, asg, ato = m.group(1), m.group(2), m.group(3)
    org = R_ORG.search(ato)
    if not org or org.group(1).upper() != 'INDEXED':
        continue                                   # 画面・ＶＬＤは別扱い
    ronri = asg.upper().split('-')[-1]
    hyo = RONRI.get(ronri)
    mk = R_KEY.search(ato)
    kagi = []
    if mk:
        for x in re.findall(r'[\w-]+', mk.group(1)):
            if '-' in x:
                kagi.append(x.split('-', 1)[1])
    sts = R_STS.search(ato)
    if hyo is None:
        fumei.append(ronri); continue
    hashira = {c[0] for c in sg.TABLES[hyo]['cols']}
    # 集団項目のキーは内訳に展開する
    hirogeta, konkyo = [], []
    for k in kagi:
        if k in hashira:
            hirogeta.append(k)
        elif (hyo, k) in SHUDAN:
            uchi, ne = SHUDAN[(hyo, k)]
            hirogeta += uchi
            konkyo.append('%s は集団項目 → %s（%s）' % (k, '＋'.join(uchi), ne))
        else:
            hirogeta.append(k)
    kagi = hirogeta
    nai = [k for k in kagi if k not in hashira]
    if nai:
        fumei.append('%s（キー %s が表 %s に無い）' % (ronri, '／'.join(nai), hyo))
        continue
    for ne in konkyo:
        b.append('    # %s' % ne)
    b.append('    %-10r: (%-16r, %-9r, %r, %r),'
             % (ronri, na, hyo, kagi, sts.group(1).rstrip('.') if sts else ''))
    kazu += 1
b.append('}')
pathlib.Path(OUT).write_text('\n'.join(b) + '\n', encoding='utf-8')
print('%s → %s  索引ファイル %d本' % (pathlib.Path(COB).name, OUT, kazu))
if fumei:
    print('   物理表に辿れなかったもの %d件: %s' % (len(fumei), '／'.join(fumei)))
