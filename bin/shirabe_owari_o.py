# -*- coding: utf-8 -*-
"""「呼ばれているのに、ソースが見当たらない」末尾Oのプログラムを数え直す。

     python3 bin/shirabe_owari_o.py <COBOL/CLソース置き場>

  ■ 2026-11-11 に見つけた数えまちがい
     work_tarinai.json の owari_o は 223件 だったが、SBMJOB の `PGM-xxx` から
     **`PGM-` を外さずに**名前を拾っていたため、同じ1本が
     「BANKIN9O」と「PGM-BANKIN9O」の2件に数えられていた（35組）。
     正味は 188本。
"""
import sys, re, pathlib, collections

U = pathlib.Path(sys.argv[1])
src = {f.stem.upper(): f for f in list(U.glob('*.CL')) + list(U.glob('*.COB'))}
kind = {n: f.suffix.upper().lstrip('.') for n, f in src.items()}
txt = {n: f.read_text('utf-8', 'replace') for n, f in src.items()}

PID      = re.compile(r'^\s*PROGRAM-ID\.\s*([A-Z0-9#@$\-]+)\s*\.', re.M | re.I)
CL_CALL  = re.compile(r'\bCALL\s+([A-Z0-9#@$]+)')
BARE     = re.compile(r'^\s+([A-Z0-9#@$]{4,8})(?=[\s,]|$)', re.M)
SBM      = re.compile(r'PGM-([A-Z0-9#@$]+)')          # PGM- は外して名前だけ取る
COB_CALL = re.compile(r'CALL\s+["\']([A-Z0-9#@$\-]+)["\']')

# 実行形式名 → ソース名（PROGRAM-ID を読む。末尾の文字では読み替えない）
jikkou = {n: n for n in src}
for n in src:
    if kind[n] == 'COB':
        m = PID.search(txt[n])
        if m:
            jikkou[m.group(1).upper()] = n

yobimoto = collections.defaultdict(set)
kata = collections.defaultdict(set)
for n in src:
    t = txt[n]
    if kind[n] == 'CL':
        mitsuke = [('CALL', x) for x in CL_CALL.findall(t)] \
                + [('SBMJOB', x) for x in SBM.findall(t)] \
                + [('名前のみ', x) for x in BARE.findall(t)]
    else:
        mitsuke = [('CALL', x) for x in COB_CALL.findall(t)] \
                + [('CALL', x) for x in CL_CALL.findall(t)] \
                + [('SBMJOB', x) for x in SBM.findall(t)]
    for k, x in mitsuke:
        x = x.upper()
        if x not in jikkou:
            yobimoto[x].add(n)
            kata[x].add(k)

nai = sorted(x for x in yobimoto if x.endswith('O'))
print('■ 呼ばれているのに、ソースが見当たらない「末尾O」  %d本' % len(nai))
print('   （PGM- を外して数え直した正味。旧 owari_o 223件は重複35組を含んでいた）')
print()

# 末尾Sに読み替えたソースが本当に無いかを念のため確かめる
for x in nai:
    for ji in 'SPKBCMXO':
        kouho = x[:-1] + ji
        if kouho in src:
            print('   ⚠ %s は %s.%s があるので、見当たらない扱いは誤り' % (x, kouho, kind[kouho]))

# 名前の系統でまとめる（先頭の英字部分）
kei = collections.defaultdict(list)
for x in nai:
    m = re.match(r'^([A-Z]+)', x)
    kei[m.group(1) if m else '?'].append(x)

print('■ 名前の系統ごと（%d系統）' % len(kei))
for k in sorted(kei, key=lambda k: (-len(kei[k]), k)):
    mono = kei[k]
    moto = sorted({m for x in mono for m in yobimoto[x]})
    print('   %-10s %3d本   呼び元 %d本: %s'
          % (k, len(mono), len(moto), '／'.join(moto[:6]) + ('…' if len(moto) > 6 else '')))
    for i in range(0, len(mono), 6):
        print('        ' + '  '.join('%-10s' % y for y in mono[i:i + 6]))
