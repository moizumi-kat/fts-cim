# -*- coding: utf-8 -*-
"""画面定義(.SMD) の読み取りを4つのやりかたで検算する。1つでも外れたら落とす。

  ① 画面に収まるか      行 0-23 ／ 桁 1-80 ／ 桁+長さ-1 <= 80
  ② レコードの並び      入力項目は「5バイトの制御部＋データ」の繰返し。
                        前の項目の終わり＋5 が次の項目の位置になるはず
  ③ 手書きの領域と一致  A10080PO.COB だけが画面編集領域を手書きしている。
                        そこと位置・長さ・並びが合うか（15項目）
  ④ プログラムが使う名前 6本のプログラムが COPY で取り込んだ名前を書いているなら、
                        それが .SMD の中に在るか
"""
import sys, re, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).parent))
from smd_parse import yomu

GAMEN = ['A10040D1', 'A10050D1', 'A10060D1', 'A10070D1', 'A10080D1', 'A10090D1']
NG = []


def miru(ok, midashi, kuwashiku=''):
    print('   [%s] %s%s' % ('OK' if ok else 'NG', midashi,
                            '' if ok else '  ← ' + kuwashiku))
    if not ok:
        NG.append(midashi)


smddir = pathlib.Path(sys.argv[1])
cobdir = pathlib.Path(sys.argv[2])

print('================================================================')
print('■ 画面定義（.SMD）の読み取り検算')
print('================================================================')
print()

zen = {}
for g in GAMEN:
    nm, ko, size = yomu(smddir / (g + '.SMD'))
    zen[g] = ko
    ari = [k for k in ko if k.get('gyo') is not None]
    nyuryoku = sorted([k for k in ari if k.get('k6') or k.get('k7')],
                      key=lambda k: k['k6'])
    print('■ %s  %d バイト ／ 項目 %d（行桁あり %d ／ 入力 %d）'
          % (nm, size, len(ko), len(ari), len(nyuryoku)))
    miru(nm == g, 'ファイル先頭の画面名が %s' % g, '読めたのは %r' % nm)

    # ① 画面に収まるか
    warui = [k for k in ari if not (0 <= k['gyo'] <= 23 and 1 <= k['keta'] <= 80
                                    and k['keta'] + k['naga'] - 1 <= 80)]
    miru(not warui, '全項目が 24行×80桁 に収まる',
         '／'.join('%s(行%d 桁%d 長%d)' % (k['nm'], k['gyo'], k['keta'], k['naga'])
                   for k in warui[:4]))

    # ② レコードの並び（5バイトの制御部）
    chigau = []
    for i in range(1, len(nyuryoku)):
        mae, ato = nyuryoku[i - 1], nyuryoku[i]
        hazu = mae['k6'] + mae['naga2'] + 5
        if ato['k6'] != hazu:
            chigau.append('%s→%s(%d のはずが %d)' % (mae['nm'], ato['nm'], hazu, ato['k6']))
    miru(not chigau, '入力項目が「5バイト制御部＋データ」で並ぶ（%d項目）' % len(nyuryoku),
         '／'.join(chigau[:4]))
    miru(not nyuryoku or nyuryoku[0]['k6'] == 5, '先頭の入力項目がレコード位置5から',
         '位置 %d' % (nyuryoku[0]['k6'] if nyuryoku else -1))

    # 通し番号が 1,2,3… と続くか
    ban = [k['k7'] for k in nyuryoku]
    miru(ban == list(range(1, len(ban) + 1)), '入力項目の通し番号が 1 から連番',
         '%s' % ban[:10])
    print()

# ③ A10080PO の手書き領域と突き合わせ
print('■ A10080PO.COB の手書き「画面編集領域」と突き合わせ')
t = (cobdir / 'A10080PO.COB').read_text('utf-8', 'replace')
PIC = re.compile(r'^\s*05\s+(\S+)\s+PIC\s+(S?)([9XNA])\((\d+)\)', re.I)
naka, te = False, []
for ln in t.splitlines():
    if ln.lstrip().startswith('*'):
        continue
    if re.match(r'^\s*01\s+DSP-AREA', ln):
        naka = True; continue
    if naka and re.match(r'^\s*01\s+\S', ln):
        break
    if not naka:
        continue
    m = PIC.match(ln)
    if m:
        kind, n = m.group(3).upper(), int(m.group(4))
        te.append((m.group(1).rstrip('.'), kind, n, n * 2 if kind == 'N' else n))
ichi, data = 0, []
for nm2, kind, n, baito in te:
    if nm2.upper() == 'FILLER':
        ichi += baito; continue
    data.append((nm2, kind, n, baito, ichi)); ichi += baito
ny = sorted([k for k in zen['A10080D1'] if k.get('k6') or k.get('k7')],
            key=lambda k: k['k6'])
miru(len(ny) == len(data), '項目の数が同じ（%d）' % len(data),
     '.SMD %d ／ 手書き %d' % (len(ny), len(data)))
awanai = []
for a, b in zip(ny, data):
    if a['k6'] != b[4] or a['naga2'] != b[3]:
        awanai.append('%s(位置%d 長%d) ↔ %s(位置%d 長%d)'
                      % (a['nm'], a['k6'], a['naga2'], b[0], b[4], b[3]))
miru(not awanai, '位置と長さが全部一致（%d項目）' % len(data), '／'.join(awanai[:3]))
print()

# ④ プログラムが書いている画面項目名が .SMD にあるか
print('■ プログラムが書いている画面項目名が .SMD にあるか')
NA = re.compile(r'\b([FRSEIC]\d{3,5})\s+OF\s+(A100\d0D1)\b')
mi = 0
for p in sorted(cobdir.glob('A100[4-9]0PO.COB')):
    src = p.read_text('utf-8', 'replace')
    tsukau = set(NA.findall(src))
    for nm2, g in tsukau:
        aru = any(k['nm'] == nm2 for k in zen.get(g, []))
        if not aru:
            miru(False, '%s が書く %s OF %s' % (p.name, nm2, g), '.SMD に無い')
        mi += 1
miru(True, '「項目名 OF 画面名」の形で書かれているもの %d 件を確認' % mi)

print()
print('================================================================')
if NG:
    print('■ 外れた項目 %d 件' % len(NG))
    for x in NG:
        print('   ' + x)
    sys.exit(1)
print('■ すべて通りました。画面定義の読み取りは正しいと判断します。')
print('================================================================')
