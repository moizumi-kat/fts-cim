# -*- coding: utf-8 -*-
"""「見当たらない」とした本を、**手元の資料を全部横断して**引き直す。

     python3 bin/sagashinaosu.py <work_tarinai*.json> <work_caset.json> <資料の置き場 …>

  ■ なぜ要るか（2026-11-13）
     村上様の調査結果で、ほとんどが「提供済、再度確認願います」だった。
     実際、A16100KB 等は **A1_見積サブシステム.zip** にあり、
     こちらが CASET仕様書.zip しか見ていなかった見落としだった。
     以後は**資料を1か所ずつ見ない。全部まとめて引く。**
"""
import sys, json, pathlib, zipfile, os, collections

TARINAI, CASETJ = sys.argv[1], sys.argv[2]
MOTO = [pathlib.Path(x) for x in sys.argv[3:]]

MOCHI = collections.defaultdict(list)      # 名前（大文字） → どこにあるか


def ireru(na, doko):
    MOCHI[os.path.splitext(na)[0].upper()].append(doko)


for m in MOTO:
    if not m.exists():
        print('（%s は無い）' % m); continue
    if m.is_dir():
        for p in m.rglob('*'):
            if p.is_file():
                ireru(p.name, str(p))
    for p in ([m] if m.suffix.lower() == '.zip'
              else (m.rglob('*.zip') if m.is_dir() else [])):
        try:
            z = zipfile.ZipFile(p)
        except Exception:
            continue
        for x in z.namelist():
            try: nm = x.encode('cp437').decode('cp932')
            except Exception: nm = x
            if nm.endswith('/'):
                continue
            ireru(os.path.basename(nm), '%s!%s' % (p.name, nm))

d = json.load(open(TARINAI, encoding='utf-8'))
cs = json.load(open(CASETJ, encoding='utf-8'))
SIYO = set(cs['caset']) | set(cs['dps'])

print('■ 手元の資料にある名前 %d（重複を除く）' % len(MOCHI))
print()
kumi = (('１．末尾 KB／KP／KO', d['kb_kp_ko']),
        ('２．末尾 O', d['owari_o']),
        ('３．そのほか', d['hoka']))
mitsuketa, nokori = [], []
for na, mono in kumi:
    nokoru = [x for x in mono if x not in SIYO]
    print('── %s  %d本（仕様書で埋まる分を除く）' % (na, len(nokoru)))
    for x in sorted(nokoru):
        doko = MOCHI.get(x, [])
        if doko:
            mitsuketa.append(x)
            print('   %-10s **あった**  %s' % (x, doko[0][:70]))
        else:
            nokori.append(x)
            print('   %-10s 無い' % x)
    print()
print('■ 見つかった %d本 ／ まだ無い %d本' % (len(mitsuketa), len(nokori)))
if nokori:
    for i in range(0, len(nokori), 6):
        print('    ' + '  '.join('%-10s' % x for x in sorted(nokori)[i:i+6]))
