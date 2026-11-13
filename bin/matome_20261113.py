# -*- coding: utf-8 -*-
"""村上様ご回答（2026-11-13）と、こちらの探し直しを突き合わせて整理する。

     python3 bin/matome_20261113.py work_tarinai3.json work_caset.json \
                                    work_murakami_20261113.json
"""
import sys, json

TARINAI, CASETJ, KAITO = sys.argv[1], sys.argv[2], sys.argv[3]
d = json.load(open(TARINAI, encoding='utf-8'))
cs = json.load(open(CASETJ, encoding='utf-8'))
ka = json.load(open(KAITO, encoding='utf-8'))
SIYO = set(cs['caset']) | set(cs['dps'])

# こちらの探し直しで片付いたもの（2026-11-13）
KATAZUITA = {
    'A16100KB': 'A1_見積サブシステム.zip にあった（CASET仕様書.zip しか見ていなかった）',
    'A16110KB': '同上',
    'A16120KP': '同上',
    'D40130KP': 'CASET仕様書.zip の D4013KP.pdf が綴り落ち。'
                'D4のプログラム一覧表で「出荷実績一覧表 D40130KP 画面・帳表 D40130P1」と確認',
    'JCVEBCC':  'ASP V29 マニュアル ikou_asp/4_14.html に'
                '「標準コード変換サブルーチン JCVEBCC（英数漢字変換）」',
    'XSBSSI':   'ASP V29 マニュアルに記載あり（システム状態参照サブルーチン）',
}
TSUKURANAI = ('仕様書は無いのでこの部分は作成しなくて良い', '対象外')

kumi = (('１．末尾 KB／KP／KO', d['kb_kp_ko']),
        ('２．末尾 O', d['owari_o']),
        ('３．そのほか', d['hoka']))
wake = {'作らない': [], '片付いた': [], 'まだ見つからない': []}
for na, mono in kumi:
    for x in sorted(x for x in mono if x not in SIYO):
        k = ' '.join(ka.get(x, []))
        if any(t in k for t in TSUKURANAI):
            wake['作らない'].append((x, na, k))
        elif x in KATAZUITA:
            wake['片付いた'].append((x, na, KATAZUITA[x]))
        else:
            wake['まだ見つからない'].append((x, na, k))

for k in ('作らない', '片付いた', 'まだ見つからない'):
    print('■ %s  %d本' % (k, len(wake[k])))
    for x, na, me in wake[k]:
        print('   %-10s [%s] %s' % (x, na, me[:78]))
    print()
print('合計 %d本' % sum(len(v) for v in wake.values()))
