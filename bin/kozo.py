# -*- coding: utf-8 -*-
"""COBOLの骨組みを出す（PROCEDURE DIVISION の段落と、その中の PERFORM 先）。

     python3 bin/kozo.py <ソース.COB> [段落名]

  桁は README 2.45 のとおり：標識欄＝line[0]、本文＝line[1:67]。
"""
import sys, re, pathlib, collections

p = pathlib.Path(sys.argv[1])
MITAI = sys.argv[2] if len(sys.argv) > 2 else None

gyo = []                                   # (原文の行番号, 本文)
for i, ln in enumerate(p.read_text('utf-8', errors='replace').splitlines(), 1):
    ln = ln.rstrip('\r\n')
    if not ln or ln[0] in ('*', '/', 'D', 'd'):
        continue
    b = ln[1:67]
    if b.strip():
        gyo.append((i, b))

R_DIV  = re.compile(r'^\s{0,6}(\w[\w-]*)\s+DIVISION\s*\.', re.I)
R_SECT = re.compile(r'^\s{0,6}([^\s.]+)\s+SECTION\s*\.', re.I)
R_PARA = re.compile(r'^\s{0,6}([^\s.]+)\s*\.\s*$')
R_PERF = re.compile(r'\bPERFORM\s+([^\s.]+)', re.I)
R_GOTO = re.compile(r'\bGO\s+TO\s+([^\s.]+)', re.I)

# PROCEDURE DIVISION の開始
tejun = 0
for k, (i, b) in enumerate(gyo):
    m = R_DIV.match(b)
    if m and m.group(1).upper() == 'PROCEDURE':
        tejun = k
        break

if MITAI:
    naka, dasu = False, []
    for i, b in gyo[tejun:]:
        m = R_PARA.match(b) or R_SECT.match(b)
        if m:
            if naka:
                break
            naka = (m.group(1).upper() == MITAI.upper())
        if naka:
            dasu.append('%5d  %s' % (i, b.rstrip()))
    print('\n'.join(dasu) if dasu else '段落 %s が見つかりません' % MITAI)
    sys.exit(0)

# 段落ごとに 行数／PERFORM先／GO TO先
ima, naka = None, collections.OrderedDict()
for i, b in gyo[tejun:]:
    m = R_SECT.match(b)
    if m:
        ima = m.group(1).upper() + '（SECTION）'
        naka[ima] = {'kara': i, 'gyo': 0, 'perf': [], 'goto': []}
        continue
    m = R_PARA.match(b)
    if m:
        ima = m.group(1).upper()
        naka[ima] = {'kara': i, 'gyo': 0, 'perf': [], 'goto': []}
        continue
    if ima:
        naka[ima]['gyo'] += 1
        naka[ima]['perf'] += [x.upper() for x in R_PERF.findall(b)]
        naka[ima]['goto'] += [x.upper() for x in R_GOTO.findall(b)]

print('%s  手続き部 %d段落' % (p.name, len(naka)))
print('%-28s %5s %5s  %s' % ('段落', '開始', '行数', 'PERFORM／GO TO 先'))
for k, v in naka.items():
    saki = []
    for x in dict.fromkeys(v['perf']):
        saki.append(x)
    for x in dict.fromkeys(v['goto']):
        if x not in saki:
            saki.append('→' + x)
    print('%-28s %5d %5d  %s' % (k[:28], v['kara'], v['gyo'],
                                 '／'.join(saki[:6]) + ('…' if len(saki) > 6 else '')))
