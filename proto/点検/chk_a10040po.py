# -*- coding: utf-8 -*-
"""A10040PO（鑑処理）の第1項目群が、現行どおりに動くかを確かめる。

     python3 点検/chk_a10040po.py
"""
import sys, pathlib, datetime
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim.cobol import vld, a10040po
from cim.cobol.a10010po import Linkage

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)


class Sousa(vld.Kioku):
    """試験用の端末役。押したキーと、打ち込む値を仕込む。"""

    def __init__(self, func='E000', ireru=None):
        super().__init__()
        self.func = func
        self.ireru = ireru or {}

    def yomu(self, group, mode):
        # 打ち込まれた値を、いまの画面に上書きして返す
        return None, vld.NYURYOKU


def ugokasu(func, shoriku, iku='', kubun='', keyid=''):
    """鑑を1回動かす。戻ってきたリンケージを返す。"""
    s = Sousa(func)
    p = a10040po.A10040PO(sousa=s, kyou=datetime.datetime(2026, 11, 12, 9, 30, 0))
    link = Linkage()
    link.詰める('行き画面', iku)
    link.詰める('鑑画面処理区分', kubun)
    link.詰める('キーＩＤ', keyid)
    p.実行(link)
    # 処理区は画面から入る。ここでは直に入れてから動かす必要があるので、
    # 入力の直後に差し替える仕掛けにする
    return p, link


print('■ 初期処理Ｒ（567行）')
s = Sousa('F010')
p = a10040po.A10040PO(sousa=s, kyou=datetime.datetime(2026, 11, 12, 9, 30, 0))
link = Linkage()
p.初期処理Ｒ()
miru('END-FLG が "INT"', p.END_FLG == 'INT', p.END_FLG)
miru('西暦は20（年26は90未満）', p.WK_SEIREKI == 20, str(p.WK_SEIREKI))
miru('11月なので年度は26のまま', p.WK_NEN == 26, str(p.WK_NEN))

p2 = a10040po.A10040PO(sousa=s, kyou=datetime.datetime(2026, 3, 20, 0, 0, 0))
p2.初期処理Ｒ()
miru('3月20日は前の年度＝25（3月21日より前）', p2.WK_NEN == 25, str(p2.WK_NEN))
p3 = a10040po.A10040PO(sousa=s, kyou=datetime.datetime(2026, 3, 21, 0, 0, 0))
p3.初期処理Ｒ()
miru('3月21日は当年度＝26', p3.WK_NEN == 26, str(p3.WK_NEN))
p4 = a10040po.A10040PO(sousa=s, kyou=datetime.datetime(2000, 1, 5, 0, 0, 0))
p4.初期処理Ｒ()
miru('年00の1月は99になる（594行 FTH指示）', p4.WK_NEN == 99, str(p4.WK_NEN))
p5 = a10040po.A10040PO(sousa=s, kyou=datetime.datetime(1995, 5, 1, 0, 0, 0))
p5.初期処理Ｒ()
miru('年95は西暦19', p5.WK_SEIREKI == 19, str(p5.WK_SEIREKI))

print()
print('■ インターフェースＲ（606行）')
p = a10040po.A10040PO(sousa=Sousa('F010'))
link = Linkage()
p.初期処理Ｒ(); p.インターフェースＲ()
miru('行き画面が空白・区分もキーも空白 → GRPA01', p.SAVE_GROUP == 'GRPA01', p.SAVE_GROUP)
miru('総額計算フラグは未計算', p.総額計算フラグ == p.未計算)

p = a10040po.A10040PO(sousa=Sousa('F010'))
p.link = Linkage(); p.link.詰める('行き画面', 'GRPA01')
p.初期処理Ｒ(); p.インターフェースＲ()
miru('行き画面 GRPA01 → GRPA01', p.SAVE_GROUP == 'GRPA01', p.SAVE_GROUP)

p = a10040po.A10040PO(sousa=Sousa('F010'))
p.link = Linkage(); p.link.詰める('行き画面', 'GRPZ99')
p.初期処理Ｒ()
try:
    p.インターフェースＲ(); ok, soe = False, '例外が出ませんでした'
except a10040po.StopRun as e:
    ok, soe = e.hyoji == '鑑画面死亡', e.hyoji
miru('知らない行き画面 → STOP RUN「鑑画面死亡」（628行）', ok, soe)

print()
print('■ 第1項目群（657行）ＰＦ１０で終了')
p = a10040po.A10040PO(sousa=Sousa('F010'))
link = Linkage()
p.実行(link)
miru('戻り画面が空白', link.戻り画面.strip() == '', repr(link.戻り画面))
miru('キーＩＤが "F010"', link.キーＩＤ == 'F010', repr(link.キーＩＤ))
miru('鑑処理区分は渡さない（730行は受渡鑑処理区分を呼ばない）',
     link.鑑画面処理区分.strip() == '', repr(link.鑑画面処理区分))

print()
print('■ 第1項目群 処理区ごとの分かれ（664行）')
for ku, na, modori, keyid, kubun in (
        (8, '概算新規', 'GRPF01', 'E000', '8'),
        (9, '概算修正', 'GRPF01', 'E000', '9')):
    p = a10040po.A10040PO(sousa=Sousa('E000'))
    link = Linkage()
    p.初期処理Ｒ(); p.インターフェースＲ()
    p.gs('処理区', ku); p.link = link
    p.GRPA01_RTN() if False else None
    try:
        p.主処理Ｒ()
    except a10040po.ExitProgram:
        pass
    miru('%s(%d) → 戻り画面 %s' % (na, ku, modori),
         link.戻り画面.strip() == modori, repr(link.戻り画面))
    miru('%s → キーＩＤ %s' % (na, keyid), link.キーＩＤ == keyid, repr(link.キーＩＤ))
    miru('%s → 鑑画面処理区分 %s' % (na, kubun),
         link.鑑画面処理区分 == kubun, repr(link.鑑画面処理区分))
    miru('%s → 処理区はゼロに戻る（1109行）' % na,
         p.数('処理区') == 0, repr(p.g('処理区')))

print()
print('■ 第1項目群 新規〜複写２は画面に残る（665-672行）')
for ku, na in ((1, '新規'), (2, '修正'), (3, '変更'), (4, '取消'),
               (5, '複写１'), (6, '複写２')):
    p = a10040po.A10040PO(sousa=Sousa('E000'))
    link = Linkage()
    p.初期処理Ｒ(); p.インターフェースＲ(); p.link = link
    p.gs('処理区', ku)
    p.GRPA01_RTN()
    miru('%s(%d) → SAVE-GROUP が GRPA02' % (na, ku),
         p.SAVE_GROUP == 'GRPA02', p.SAVE_GROUP)

print()
print('■ 第1項目群 処理区が正しくないとき（677行）')
p = a10040po.A10040PO(sousa=Sousa('E000'))
link = Linkage()
p.初期処理Ｒ(); p.インターフェースＲ(); p.link = link
p.gs('処理区', 7)
p.GRPA01_RTN()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))
miru('処理区が赤（EDIT-COLOR = R）',
     p.画面['処理区'].zokusei['EDIT-COLOR'] == 'R')
miru('処理区にカーソル（EDIT-CURSOR = C）',
     p.画面['処理区'].zokusei['EDIT-CURSOR'] == 'C')
miru('GRPA01 に留まる', p.SAVE_GROUP == 'GRPA01', p.SAVE_GROUP)

print()
print('■ ＰＦ案内（3271行）')
p = a10040po.A10040PO(sousa=Sousa('E000'))
p.初期処理Ｒ(); p.SAVE_GROUP = 'GRPA01'; p.メッセージＲ()
miru('第1群は「ＰＦ１０：終了」', p.g('ＰＦエリア').startswith('ＰＦ１０：終了'),
     repr(p.g('ＰＦエリア')[:10]))
p.SAVE_GROUP = 'GRPA03'; p.メッセージＲ()
miru('第3群は「ＰＦ５：前項目」', p.g('ＰＦエリア').startswith('ＰＦ５：前項目'),
     repr(p.g('ＰＦエリア')[:10]))

print()
print('■ 入力強調処理Ｒ（3299行）')
p = a10040po.A10040PO(sousa=Sousa('E000'))
p.初期処理Ｒ(); p.SAVE_GROUP = 'GRPA02'
p.gs('処理区', 1); p.入力強調処理Ｒ()
miru('新規は 複写元・見積なんば・物件ナンバーが入力不可',
     all(p.画面[n].zokusei['EDIT-STATUS'] == 'X'
         for n in ('複写元見積ナンバ', '見積なんば', '物件ナンバー')))
p.画面.seigyo_shokika(); p.gs('処理区', 2); p.入力強調処理Ｒ()
miru('修正は 担当者ＣＤ・複写元・施主大分類・物件ナンバーが入力不可',
     all(p.画面[n].zokusei['EDIT-STATUS'] == 'X'
         for n in ('担当者ＣＤ', '複写元見積ナンバ', '施主大分類ＣＤ', '物件ナンバー')))
p.画面.seigyo_shokika(); p.SAVE_GROUP = 'GRPA03'
p.gs('処理区', 2); p.gs('最終納期', 0); p.入力強調処理Ｒ()
miru('第3群・最終納期がゼロなら入力できる（3324行）',
     p.画面['最終納期'].zokusei['EDIT-STATUS'] == ' ')
p.gs('最終納期', 20261231); p.入力強調処理Ｒ()
miru('第3群・最終納期が入っていれば入力不可',
     p.画面['最終納期'].zokusei['EDIT-STATUS'] == 'X')

print()
print('■ まだ写していない段落は、黙って素通りしない')
p = a10040po.A10040PO(sousa=Sousa('E000'))
p.初期処理Ｒ(); p.link = Linkage(); p.SAVE_GROUP = 'GRPA03'
try:
    p.主処理Ｒ(); ok = False
except a10040po.未実装 as e:
    ok = 'GRPA03' in str(e)
miru('まだの GRPA03 を呼ぶと 未実装 を投げる', ok)

print()
print('=' * 60)
if warui:
    print('■ %d件 合いませんでした。' % warui)
else:
    print('■ 第1項目群は、すべて現行どおりに動きました。')
print('=' * 60)
sys.exit(1 if warui else 0)
