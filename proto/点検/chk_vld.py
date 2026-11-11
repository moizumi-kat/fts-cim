# -*- coding: utf-8 -*-
"""画面（ＶＬＤ）の実行時部品が、現行のふるまいどおりかを確かめる。

     python3 点検/chk_vld.py
"""
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim.cobol import vld, gamen_a10040d1 as teigi

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)

print('■ 画面 %s' % teigi.GAMEN)
g = vld.Gamen(teigi, vld.Kioku())

miru('項目数が55', len(g.ko) == 55, '%d' % len(g.ko))
miru('レコード長が1,123バイト', g.nagasa == 1123, '%d' % g.nagasa)

print()
print('■ 並びが重ならず、すき間なく繋がっているか（制御部5＋データ）')
tsugi, kasanari, suki = 0, 0, 0
for k in sorted(g.ko, key=lambda k: k.ichi):
    s = k.ichi - 5
    if s < tsugi:
        kasanari += 1
    elif s > tsugi:
        suki += 1
    tsugi = k.ichi + k.naga2
miru('重なりなし', kasanari == 0, '%d件' % kasanari)
miru('すき間は0（先頭の制御部を含めて連続）', suki == 0, '%d件' % suki)
miru('最後の項目で1,123に届く', tsugi == 1123, '%d' % tsugi)

print()
print('■ 制御項目初期化Ｒ')
g['処理区'].zokusei['EDIT-STATUS'] = 'X'
g.seigyo_shokika()
miru('EDIT-STATUS が " " に戻る', g['処理区'].zokusei['EDIT-STATUS'] == ' ')
miru('EDIT-OPTION が "M"', g['処理区'].zokusei['EDIT-OPTION'] == 'M')
miru('EDIT-COLOR が "M"', g['処理区'].zokusei['EDIT-COLOR'] == 'M')

print()
print('■ MOVE のふるまい（数字は右詰めゼロ／英数は左詰め空白）')
g.ireru('見積総額', 1234)
miru('数字 12桁に右詰めゼロ', g.atai('見積総額') == '000000001234', repr(g.atai('見積総額')))
g.ireru('件名１', 'テスト件名')
# PIC X(40) は40バイト。全角5文字＝10バイト＋空白30バイト
miru('英数 40バイトに左詰め空白', g['件名１'].data == 'テスト件名'.encode('cp932') + b' ' * 30,
     '%dバイト' % len(g['件名１'].data))

print()
print('■ 第ｎ項目群消去Ｒ')
g.ireru('担当者ＣＤ', 'A123')
g.ireru('変更回数', 7)
g.gun_shoukyo(2)
miru('第2群の英数が空白に', g.atai('担当者ＣＤ') == '    ')
miru('第2群の数字がゼロに', g.atai('変更回数') == '00')
miru('第3群は触らない', g['件名１'].data.startswith('テスト件名'.encode('cp932')))

print()
print('■ 項目群の中身（第ｎ項目群消去Ｒ から取った）')
# 第3群は 件名カナ〜見積率 の40項目（COBOL 3217-3257行を数えた）
for n, kazu in ((1, 1), (2, 9), (3, 40), (4, 1)):
    aru = len(g.gun_no_ko('GRPA%02d' % n))
    miru('第%d群は%d項目' % (n, kazu), aru == kazu, '%d' % aru)

print()
print('■ レコードの組み立てと取り出し（往復して元に戻るか）')
b = g.rec()
miru('レコードが1,123バイト', len(b) == 1123, '%d' % len(b))
mae = {k.na: (k.data, dict(k.zokusei)) for k in g.ko}
g2 = vld.Gamen(teigi, vld.Kioku())
g2.rec_ireru(b)
chigai = [k.na for k in g2.ko
          if (k.data, k.zokusei) != mae[k.na]]
miru('往復して全55項目が一致', not chigai, '／'.join(chigai[:4]))

print()
print('■ 画面出力Ｒ・画面入力Ｒ')
k = vld.Kioku()
g3 = vld.Gamen(teigi, k)
miru('画面出力Ｒ が "00"', g3.kaku('GRPALL') == vld.SEIJOU)
miru('GRPALL で書かれた', k.kaita and k.kaita[-1][0] == 'GRPALL')
k.yomaseru.append(b)
miru('画面入力Ｒ が "04"（入力あり）', g3.yomu('GRPA02', ' ') == vld.NYURYOKU)
miru('読んだ値が入っている', g3['件名１'].data.startswith('テスト件名'.encode('cp932')))

print()
print('=' * 60)
if warui:
    print('■ %d件 合いませんでした。' % warui)
else:
    print('■ すべて現行のふるまいどおりでした。')
print('=' * 60)
sys.exit(1 if warui else 0)
