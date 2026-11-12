# -*- coding: utf-8 -*-
"""A10040PO（鑑）の第2項目群「新規」が、現行どおりに動くかを確かめる。
   担当者・施主大分類の確認から、見積番号・物件番号の発番まで。

     python3 点検/chk_a10040po2.py
"""
import sys, pathlib, datetime, sqlite3, tempfile, os
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim import db
from cim.cobol import vld, fairu, a10040po
from cim.cobol.a10010po import Linkage

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)


class Sousa(vld.Kioku):
    def __init__(self, func='E000'):
        super().__init__(); self.func = func


def tsukuru(func='E000', kyou=None, hatuban=None):
    """仮のデータベースと鑑を1組つくる。"""
    tmp = tempfile.mkdtemp()
    con = sqlite3.connect(os.path.join(tmp, 't.db'))
    con.row_factory = sqlite3.Row
    for sql in db.ddl('sqlite'):
        con.execute(sql)
    # 組織マスタ（部所10・担当20 → 仙台支店／山田）
    con.execute("INSERT INTO [ASOSMP] (BSYOCD, TANCD, BSYNAM, TANNAM)"
                " VALUES ('10','20','仙台支店','山田')")
    # 名称マスタ（区分00・コードA → 官公庁）
    con.execute("INSERT INTO [ANAMMP] (NAMKBN, NAMCD, RYAKU)"
                " VALUES ('00','A','官公庁')")
    if hatuban:
        for h in hatuban:
            con.execute("INSERT INTO [AHATMP] (HATKBN, HATUCD, RENBAN,"
                        " RKAGEN, RJOGEN) VALUES (?,?,?,?,?)", h)
    p = a10040po.A10040PO(con=con, sousa=Sousa(func), db=db,
                          kyou=kyou or datetime.datetime(2026, 11, 12, 9, 30))
    p.端末ＩＤ = 'WS01'
    p.初期処理Ｒ(); p.インターフェースＲ()
    p.link = Linkage()
    p.SAVE_GROUP = 'GRPA02'
    p.gs('処理区', p.新規)
    return con, p


print('■ 画面初期設定（4079行）新規のときの決まり文句')
con, p = tsukuru()
p.画面初期設定()
miru('納入期日', p.g('納入期日').startswith('御打ち合わせの上'), repr(p.g('納入期日')[:8]))
miru('受渡場所', p.g('受渡場所').startswith('車上渡し'))
miru('支払条件', p.g('支払条件').startswith('従来通り'))
miru('荷造及び運賃', p.g('荷造及び運賃').startswith('含入'))
miru('見積有効期限', p.g('見積有効期限').startswith('６０日'))
miru('掛率4つが1', all(p.数(n) == 1 for n in
                      ('掛率配電盤', '掛率制御盤', '掛率分電盤', '掛率その他')),
     p.g('掛率配電盤'))

print()
print('■ 担当者ＣＤが空白（1263行）')
con, p = tsukuru()
p.gs('担当者ＣＤ', ''); p.新規第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))
miru('担当者ＣＤが赤', p.画面['担当者ＣＤ'].zokusei['EDIT-COLOR'] == 'R')
miru('GRPA02 に留まる', p.SAVE_GROUP == 'GRPA02', p.SAVE_GROUP)

print()
print('■ 担当者ＣＤが組織マスタに無い（1280行）')
con, p = tsukuru()
p.gs('担当者ＣＤ', '9999'); p.gs('施主大分類ＣＤ', 'A'); p.新規第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))
miru('GRPA02 に留まる', p.SAVE_GROUP == 'GRPA02', p.SAVE_GROUP)

print()
print('■ 担当者ＣＤは4桁＝部所2桁＋担当2桁（1272行）')
con, p = tsukuru()
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.担当者コード判定()
miru('作成部所名が入る', p.g('作成部所名').startswith('仙台支店'), repr(p.g('作成部所名')[:6]))
miru('担当者名が入る', p.g('担当者名').startswith('山田'), repr(p.g('担当者名')[:4]))
miru('誤りなし', p.ERR_FLG == 0, str(p.ERR_FLG))

print()
print('■ 施主大分類が名称マスタに無い（1341行）')
con, p = tsukuru()
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'Z'); p.新規第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))
miru('施主大分類ＣＤが赤', p.画面['施主大分類ＣＤ'].zokusei['EDIT-COLOR'] == 'R')

print()
print('■ 発番 ― その年のレコードがある（3380行）連番を1つ進める')
#   年26・支店10・施主A → 発番キー "6" + "10" + "A" + "  "
con, p = tsukuru(hatuban=[('01', '610A  ', 7, 0, 9999),
                          ('00', '610A  ', 41, 0, 9999)])
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.新規第２項目群()
miru('誤りなし', p.ERR_FLG == 0, str(p.ERR_FLG))
miru('見積なんば＝年1＋支店2＋施主1＋連番4', p.g('見積なんば') == '610A0008',
     repr(p.g('見積なんば')))
miru('物件ナンバーも同じ組み立て', p.g('物件ナンバー') == '610A0042',
     repr(p.g('物件ナンバー')))
# 施主大分類名は画面で**2バイト＝全角1文字**（.SMD と画面の並びで確認）。
# ANAMMP.RYAKU は nchar(5) なので、MOVE で1文字に切り詰められるのが現行どおり。
miru('施主大分類名は先頭1文字だけ入る（画面が2バイト）',
     p.g('施主大分類名') == '官', repr(p.g('施主大分類名')))
miru('作成部所名・担当者名が入る',
     p.g('作成部所名').startswith('仙台支店') and p.g('担当者名').startswith('山田'))
miru('SAVE-GROUP が GRPA03', p.SAVE_GROUP == 'GRPA03', p.SAVE_GROUP)
r = db.q1(con, "SELECT RENBAN FROM [AHATMP] WHERE HATKBN='01' AND HATUCD='610A  '")
miru('発番ファイルの連番が8に更新されている', int(r['RENBAN']) == 8, str(r['RENBAN']))
r = db.q1(con, "SELECT * FROM [ACHKFP] WHERE MITUNO='610A0008'")
miru('チェックＦに札が立つ（3166行）', r is not None)
miru('札の転記フラグは "0"', r and r['TENKFK'] == '0' and r['TENKFM'] == '0')

print()
print('■ 発番 ― 連番が上限に達している（3428行）')
con, p = tsukuru(hatuban=[('01', '610A  ', 9999, 0, 9999)])
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.新規第２項目群()
miru('見積なんばが空になる', p.g('見積なんば').strip() == '', repr(p.g('見積なんば')))
miru('ERR-FLG が 7（1317行）', p.ERR_FLG == 7, str(p.ERR_FLG))
miru('取引を取り消す（TR-CNL-FLG=1）', p.TR_CNL_FLG == 1, str(p.TR_CNL_FLG))
miru('GRPA02 に留まる', p.SAVE_GROUP == 'GRPA02', p.SAVE_GROUP)

print()
print('■ 発番 ― 今年のレコードが無く、前の年にはある（3382・3407行）')
#   年26 → 前年25 のキー "5" + "10" + "A"
con, p = tsukuru(hatuban=[('01', '510A  ', 123, 0, 9999),
                          ('00', '510A  ', 456, 0, 9999)])
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.新規第２項目群()
miru('今年のレコードが作られる', p.g('見積なんば') == '610A0001', repr(p.g('見積なんば')))
r = db.q1(con, "SELECT * FROM [AHATMP] WHERE HATKBN='01' AND HATUCD='610A  '")
miru('下限0・連番1・上限9999で作る（3862行）',
     r and int(r['RKAGEN']) == 0 and int(r['RENBAN']) == 1 and int(r['RJOGEN']) == 9999,
     str(dict(r)) if r else 'なし')
miru('年は戻してある（WK-NEN=26）', p.WK_NEN == 26, str(p.WK_NEN))

print()
print('■ 発番 ― 今年も前の年も無い（3398行）')
con, p = tsukuru(hatuban=[])
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.新規第２項目群()
miru('見積なんばは空', p.g('見積なんば').strip() == '', repr(p.g('見積なんば')))
miru('ERR-FLG が 7', p.ERR_FLG == 7, str(p.ERR_FLG))
miru('年は戻してある（WK-NEN=26）', p.WK_NEN == 26, str(p.WK_NEN))

print()
print('■ ＰＦ５で第1項目群へ戻る（765行）')
con, p = tsukuru(func='F005')
p.gs('担当者ＣＤ', '1020'); p.gs('件名１', 'あああ')
p.GRPA02_RTN()
miru('SAVE-GROUP が GRPA01', p.SAVE_GROUP == 'GRPA01', p.SAVE_GROUP)
miru('第2群が消えている', p.g('担当者ＣＤ').strip() == '', repr(p.g('担当者ＣＤ')))
miru('第3群も消えている', p.g('件名１').strip() == '', repr(p.g('件名１')[:6]))

print()
print('■ まだ写していない処理区は、黙って素通りしない')
con, p = tsukuru()
p.gs('処理区', p.修正)
try:
    p.GRPA02_RTN(); ok = False
except a10040po.未実装 as e:
    ok = '修正第２項目群' in str(e)
miru('修正を呼ぶと 未実装 を投げる', ok)

print()
print('=' * 60)
if warui:
    print('■ %d件 合いませんでした。' % warui)
else:
    print('■ 第2項目群「新規」は、すべて現行どおりに動きました。')
print('=' * 60)
sys.exit(1 if warui else 0)
