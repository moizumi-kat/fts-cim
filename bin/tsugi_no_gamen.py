# -*- coding: utf-8 -*-
"""これから作る工程で、どの画面定義（XMDLIB）が要るかを数える。

     python3 bin/tsugi_no_gamen.py <koutei405.json> <ソース置き場> <受領済み画面の置き場> [工程数]
"""
import sys, json, re, pathlib, collections

KOUTEI, SRC, MOCHI = sys.argv[1], pathlib.Path(sys.argv[2]), pathlib.Path(sys.argv[3])
N = int(sys.argv[4]) if len(sys.argv) > 4 else 10

aru = {p.stem.upper() for p in MOCHI.glob('*.SMD')}
R_COPY = re.compile(r'\bCOPY\s+([\w-]+)\s+OF\s+(XMDLIB)', re.I)

def honbun(p):
    out = []
    for ln in p.read_text('utf-8', errors='replace').splitlines():
        ln = ln.rstrip('\r\n')
        if ln and ln[0] not in ('*', '/', 'D', 'd'):
            out.append(ln[1:67])
    return '\n'.join(out)

d = json.load(open(KOUTEI, encoding='utf-8'))
d.sort(key=lambda x: (x.get('o1') or 0, x.get('o2') or 0))

print('■ 工程順に、要る画面定義')
iru, sumi = [], []
for k in d[:N]:
    pgms = [c['src'] for c in k.get('callinfo', []) if c.get('have')]
    gamen = set()
    nai_src = [c['n'] for c in k.get('callinfo', []) if not c.get('have')]
    for pg in pgms:
        p = SRC / (pg + '.COB')
        if not p.exists():
            continue
        for m, _lib in R_COPY.findall(honbun(p)):
            gamen.add(m.upper())
    motteru = sorted(g for g in gamen if g in aru)
    tarinai = sorted(g for g in gamen if g not in aru)
    iru += tarinai
    sumi += motteru
    print('   %2d-%-2d %-22s 画面 %d本（受領済 %d／**未入手 %d**）%s'
          % (k.get('o1') or 0, k.get('o2') or 0, k['nm'][:22],
             len(gamen), len(motteru), len(tarinai),
             ('  ソース無し %d本' % len(nai_src)) if nai_src else ''))
    if tarinai:
        print('        未入手: %s' % '／'.join(tarinai))
print()
print('■ この%d工程で未入手の画面定義 %d本（重複を除く）' % (N, len(set(iru))))
for i, x in enumerate(sorted(set(iru))):
    if i % 8 == 0: print('   ', end='')
    print('%-10s' % x, end='\n' if i % 8 == 7 else '')
print()
