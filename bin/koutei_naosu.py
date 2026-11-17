# -*- coding: utf-8 -*-
"""koutei405.json の「ソースが有るか（have）」を、いまの資料で付け直す。

     python3 bin/koutei_naosu.py <koutei405.json> <ソース置き場> <work_caset.json>

  ■ なぜ要るか（2026-11-17 に気づいた）
     koutei405.json は 2026-11-04 に作ったもので、**走査を直す前**の判定が
     そのまま残っていた。実際には手元に無いプログラム（D20010PO・SEMICH01 など）
     が have:true になっており、「作れない工程」の数を小さく見誤った。
     判定の材料（ソース一式・CASET仕様書）が増えたら、必ず付け直すこと。
"""
import sys, json, re, pathlib

KOUTEI, SRC, CASETJ = sys.argv[1], pathlib.Path(sys.argv[2]), sys.argv[3]

PID = re.compile(r'^\s*PROGRAM-ID\.\s*([A-Z0-9#@$\-]+)\s*\.', re.M | re.I)
ARU = {p.stem.upper() for p in SRC.glob('*.CL')}
for p in SRC.glob('*.COB'):
    ARU.add(p.stem.upper())
    m = PID.search(p.read_text('utf-8', 'replace'))
    if m:
        ARU.add(m.group(1).upper())          # 実行形式名でも引けるように

cs = json.load(open(CASETJ, encoding='utf-8'))
SIYO = set(cs['caset']) | set(cs['dps']) | {
    'A16100KB', 'A16110KB', 'A16120KP', 'D40130KP'}   # 別zip・綴り落ち分
MANUAL = {'JCVEBCC', 'XSBSSI'}                        # マニュアルのサブルーチン
TSUKURANAI = {'D40135KP', 'D40900KB', 'D40910KB',
              'M11020KO', 'M11030KP', 'M10500KB'}     # 作らない（村上様ご回答）
CL_GO = {'WAIT', 'END', 'START', 'STATUS', 'STS'}     # ＣＬの語。プログラムではない

d = json.load(open(KOUTEI, encoding='utf-8'))
kawatta = 0
for k in d:
    for c in k.get('callinfo', []):
        n = c['n'].upper()
        if n in ARU:
            atarashii, moto = True, 'source'
        elif n in SIYO:
            atarashii, moto = True, 'caset'
        elif n in MANUAL:
            atarashii, moto = True, 'manual'
        elif n in TSUKURANAI:
            atarashii, moto = True, 'tsukuranai'
        elif n in CL_GO:
            atarashii, moto = True, 'cl'
        else:
            atarashii, moto = False, ''
        if c.get('have') != atarashii or c.get('moto') != moto:
            kawatta += 1
        c['have'], c['moto'] = atarashii, moto
    k['srcok'] = all(c['have'] for c in k.get('callinfo', []))

json.dump(d, open(KOUTEI, 'w'), ensure_ascii=False)
tomaru = [k for k in d if not k['srcok']]
print('■ 付け直した判定 %d件' % kawatta)
print('■ 作れない工程 %d / %d' % (len(tomaru), len(d)))
import collections
c = collections.Counter(k.get('o1') or 0 for k in tomaru)
print('   大分類ごと:', '／'.join('%d系 %d工程' % (a, b) for a, b in sorted(c.items())))
