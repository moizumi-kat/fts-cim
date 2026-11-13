# -*- coding: utf-8 -*-
"""更新用ＶＬＤ（バック開始処理）が、コピー原文と現行どおりかを確かめる。

     python3 点検/chk_vld_msg.py
"""
import sys, pathlib, datetime
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim.cobol import vld, vld_msg, vld_rec, a10040po
from cim.cobol.a10010po import Linkage

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)

class Sousa(vld.Kioku):
    func = 'E000'

print('■ コピー原文どおりの桁（A1VLD001／A1VLD002）')
miru('ＶＬＤ１は41バイト', vld_rec.NAGASA1 == 41, str(vld_rec.NAGASA1))
miru('ＶＬＤ２は49バイト', vld_rec.NAGASA2 == 49, str(vld_rec.NAGASA2))
d1 = {t[0]: t for t in vld_rec.REC1}
d2 = {t[0]: t for t in vld_rec.REC2}
miru('見積ＮＯ１は8桁・32バイト目から', d1['見積ＮＯ１'][3:5] == (8, 32), str(d1['見積ＮＯ１']))
miru('処理ＩＤ１は1桁・40バイト目', d1['処理ＩＤ１'][3:5] == (1, 40), str(d1['処理ＩＤ１']))
miru('データ長1=9 と中身が合う（見積ＮＯ8＋処理ＩＤ1）',
     d1['見積ＮＯ１'][3] + d1['処理ＩＤ１'][3] == 9)
miru('データ長2=17 と中身が合う（8＋8＋1）',
     d2['見積ＮＯ２'][3] + d2['複写先見積ＮＯ２'][3] + d2['処理ＩＤ２'][3] == 17)

def tsukuru(ku, ＶＬＤ一=1, ＶＬＤ二=2):
    p = a10040po.A10040PO(sousa=Sousa(), kyou=datetime.datetime(2026, 11, 13, 9, 0))
    p.初期処理Ｒ()
    p.link = Linkage()
    p.link.詰める('ＶＬＤ一', ＶＬＤ一)
    p.link.詰める('ＶＬＤ二', ＶＬＤ二)
    p.gs('処理区', ku)
    p.作業見積ＮＯ = '610A0008'
    p.作業複写元見積ＮＯ = '510Z0001'
    return p

print()
print('■ バック開始処理１（4095行）')
for ku, na, shori in ((1, '新規', '1'), (2, '修正', '2'), (3, '変更', '3'),
                      (4, '取消', '4'), (5, '複写１', '5'), (6, '複写２', '6')):
    p = tsukuru(ku)
    m = p.バック開始処理１()
    miru('%s → 処理ＩＤ１ "%s"' % (na, shori), m['処理ＩＤ１'] == shori, m['処理ＩＤ１'])
p = tsukuru(8)
m = p.バック開始処理１()
miru('概算新規 → 処理ＩＤ１は空白（4117行）', m['処理ＩＤ１'] == ' ', repr(m['処理ＩＤ１']))
p = tsukuru(1)
m = p.バック開始処理１()
miru('見積ＮＯ１が入る', m['見積ＮＯ１'] == '610A0008', repr(m['見積ＮＯ１']))
miru('処理種別は "WT"', m['処理種別１'] == 'WT', repr(m['処理種別１']))
miru('データ長は 0009', m['データ長１'] == '0009', repr(m['データ長１']))
miru('優先順位は 9', m['優先順位１'] == '9', repr(m['優先順位１']))
miru('論理宛先名にＶＬＤ一が入る', m['論理宛先名１'] == '001', repr(m['論理宛先名１']))
miru('レコードは41バイト', len(m.rec()) == 41, str(len(m.rec())))
miru('ＶＬＤ１に1件積まれた', len(p.VLD1.tamatta) == 1, str(len(p.VLD1.tamatta)))

print()
print('■ バック開始処理２（4133行）')
p = tsukuru(1)
m = p.バック開始処理２()
miru('新規は 見積ＮＯ２＝作業見積ＮＯ', m['見積ＮＯ２'] == '610A0008', repr(m['見積ＮＯ２']))
miru('新規は 複写先が空白', m['複写先見積ＮＯ２'].strip() == '', repr(m['複写先見積ＮＯ２']))
p = tsukuru(5)
m = p.バック開始処理２()
miru('複写１は 見積ＮＯ２＝複写**元**（4137行）',
     m['見積ＮＯ２'] == '510Z0001', repr(m['見積ＮＯ２']))
miru('複写１は 複写先＝作業見積ＮＯ',
     m['複写先見積ＮＯ２'] == '610A0008', repr(m['複写先見積ＮＯ２']))
p = tsukuru(8)
m = p.バック開始処理２()
miru('概算新規は 処理ＩＤ２を入れない（4160行 CONTINUE）',
     m['処理ＩＤ２'] == ' ', repr(m['処理ＩＤ２']))
p = tsukuru(7)
m = p.バック開始処理２()
miru('そのほかは 処理ＩＤ２ "7"（4165行）', m['処理ＩＤ２'] == '7', repr(m['処理ＩＤ２']))
miru('データ長は 0017', m['データ長２'] == '0017', repr(m['データ長２']))
miru('レコードは49バイト', len(m.rec()) == 49, str(len(m.rec())))

print()
print('■ バック開始処理３（4181行）')
p = tsukuru(5)
m = p.バック開始処理３()
miru('処理区にかかわらず 処理ＩＤ２ は "7"', m['処理ＩＤ２'] == '7', repr(m['処理ＩＤ２']))
miru('複写でも 見積ＮＯ２＝作業見積ＮＯ', m['見積ＮＯ２'] == '610A0008', repr(m['見積ＮＯ２']))
miru('複写先は空白', m['複写先見積ＮＯ２'].strip() == '')

print()
print('=' * 60)
print('■ %d件 合いませんでした。' % warui if warui
      else '■ ＶＬＤは、コピー原文と現行どおりでした。')
print('=' * 60)
sys.exit(1 if warui else 0)
