# -*- coding: utf-8 -*-
"""A10040PO（鑑）第2項目群の 修正・変更・取消・複写 が現行どおりかを確かめる。

     python3 点検/chk_a10040po3.py
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

def tsukuru(ku, kagami=None, achk=None, wkk=None, func='E000'):
    tmp = tempfile.mkdtemp()
    con = sqlite3.connect(os.path.join(tmp, 't.db')); con.row_factory = sqlite3.Row
    for sql in db.ddl('sqlite'):
        con.execute(sql)
    con.execute("INSERT INTO [ASOSMP] (BSYOCD,TANCD,BSYNAM,TANNAM)"
                " VALUES ('10','20','仙台支店','山田')")
    con.execute("INSERT INTO [ANAMMP] (NAMKBN,NAMCD,RYAKU) VALUES ('00','A','官')")
    con.execute("INSERT INTO [ANAMMP] (NAMKBN,NAMCD,RYAKU) VALUES ('02','1','定価')")
    con.execute("INSERT INTO [ATORMP] (TORICD,TORNAR) VALUES ('T0001','古川電気')")
    con.execute("INSERT INTO [ASIYMP] (SIYOCD,SIYONA) VALUES ('01','標準仕様')")
    if kagami:
        h = ','.join(kagami); v = ','.join('?' * len(kagami))
        con.execute("INSERT INTO [AJBGFP] (%s) VALUES (%s)" % (h, v),
                    tuple(kagami.values()) if isinstance(kagami, dict) else None)
    if achk:
        con.execute("INSERT INTO [ACHKFP] (MITUNO,TENKFK,TENKFM) VALUES (?,'0','0')", (achk,))
    for r in (wkk or []):
        con.execute("INSERT INTO [AWKKFP] (MITUNO,MITKOB,SEIBAN) VALUES (?,?,?)", r)
    p = a10040po.A10040PO(con=con, sousa=Sousa(func), db=db,
                          kyou=datetime.datetime(2026, 11, 17, 9, 0))
    p.端末ＩＤ = 'WS01'
    p.初期処理Ｒ(); p.link = Linkage(); p.SAVE_GROUP = 'GRPA02'
    p.gs('処理区', ku)
    return con, p

def kagami_ireru(con, mituno, **kw):
    k = dict(MITUNO=mituno, UPDCNT=3, BKENNO='B0000001', KNMEIK='ケンメイ',
             KENME1='件名いち', KAKKBN='1', IRAICD='T0001', SIYOU1='01',
             SIYOU2='99', SESYCD='T0001', SEKECD='T0001', KENGCD='T0001',
             KETDEN='T0001', CRTBSY='10', CRTKKR='20',
             SEDICD='A', FASTNK=20260401, LASTNK=20260630,
             KAKRIT_1=1, KAKRIT_2=2, KAKRIT_3=3, KAKRIT_4=4,
             MITGAK_1=1234567, MITRIT=85, SASKIN_1=7654321,
             DELFLG='0', GAIKBN='')
    k.update(kw)
    con.execute("INSERT INTO [AJBGFP] (%s) VALUES (%s)"
                % (','.join(k), ','.join('?' * len(k))), tuple(k.values()))

print('■ 修正（1362行）見積なんばが空')
con, p = tsukuru(2)
p.gs('見積なんば', ''); p.修正第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))
miru('GRPA02 に留まる', p.SAVE_GROUP == 'GRPA02', p.SAVE_GROUP)

print()
print('■ 修正 ― 鑑ファイルに無い（1555行）')
con, p = tsukuru(2)
p.gs('見積なんば', '610A9999'); p.修正第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))

print()
print('■ 修正 ― ほかの人が使用中（チェックＦに札がある・1546行）')
con, p = tsukuru(2); kagami_ireru(con, '610A0001')
con.execute("INSERT INTO [ACHKFP] (MITUNO,TENKFK,TENKFM) VALUES ('610A0001','0','0')")
p.gs('見積なんば', '610A0001'); p.修正第２項目群()
miru('ERR-FLG が 5', p.ERR_FLG == 5, str(p.ERR_FLG))
miru('GRPA02 に留まる', p.SAVE_GROUP == 'GRPA02', p.SAVE_GROUP)

print()
print('■ 修正 ― 消された見積は使えない（DELFLG="1"・1528行）')
con, p = tsukuru(2); kagami_ireru(con, '610A0001', DELFLG='1')
p.gs('見積なんば', '610A0001'); p.修正第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))

print()
print('■ 修正 ― 正常。鑑の中身が画面に出る（3572行）')
con, p = tsukuru(2); kagami_ireru(con, '610A0001')
p.gs('見積なんば', '610A0001'); p.修正第２項目群()
miru('誤りなし', p.ERR_FLG == 0, str(p.ERR_FLG))
miru('SAVE-GROUP が GRPA03', p.SAVE_GROUP == 'GRPA03', p.SAVE_GROUP)
miru('担当者ＣＤが入る', p.g('担当者ＣＤ') == '1020', repr(p.g('担当者ＣＤ')))
miru('作成部所名が入る', p.g('作成部所名').startswith('仙台支店'))
miru('件名１が入る', p.g('件名１').startswith('件名いち'))
miru('価格区分名（名称マスタ区分"02"）', p.g('価格区分名').startswith('定価'),
     repr(p.g('価格区分名')[:4]))
miru('依頼先名（取引先マスタ）', p.g('依頼先名').startswith('古川電気'))
miru('仕様名（仕様マスタ）', p.g('仕様名').startswith('標準仕様'))
miru('仕様名２は無いので空白（3667行）', p.g('仕様名２').strip() == '',
     repr(p.g('仕様名２')[:4]))
miru('掛率4つが 1/2/3/4', [p.数(n) for n in
     ('掛率配電盤','掛率制御盤','掛率分電盤','掛率その他')] == [1,2,3,4])
miru('見積総額（MITGAK_1）', p.数('見積総額') == 1234567, p.g('見積総額'))
miru('差引合計金額（SASKIN_1）', p.数('差引合計金額') == 7654321, p.g('差引合計金額'))
miru('修正は 変更回数＝UPDCNT のまま（3592行）', p.数('変更回数') == 3, p.g('変更回数'))
miru('チェックＦに札が立つ', db.q1(con, "SELECT * FROM [ACHKFP] WHERE MITUNO='610A0001'") is not None)
miru('ＶＬＤ２に1件積まれる（バック開始処理２）', len(p.VLD2.tamatta) == 1)

print()
print('■ 変更（1381行）変更回数が1つ増える（3588行）')
con, p = tsukuru(3); kagami_ireru(con, '610A0001')
p.gs('見積なんば', '610A0001'); p.変更第２項目群()
miru('誤りなし', p.ERR_FLG == 0, str(p.ERR_FLG))
miru('変更回数が 3→4', p.数('変更回数') == 4, p.g('変更回数'))

print()
print('■ 変更 ― 外注区分が入っていると使えない（1580行・修正との違い）')
con, p = tsukuru(3); kagami_ireru(con, '610A0001', GAIKBN='1')
p.gs('見積なんば', '610A0001'); p.変更第２項目群()
miru('変更は ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))
con, p = tsukuru(2); kagami_ireru(con, '610A0001', GAIKBN='1')
p.gs('見積なんば', '610A0001'); p.修正第２項目群()
miru('修正は 外注区分を見ないので通る', p.ERR_FLG == 0, str(p.ERR_FLG))

print()
print('■ 取消（1400行）')
con, p = tsukuru(4); kagami_ireru(con, '610A0001')
p.gs('見積なんば', '610A0001'); p.取消第２項目群()
miru('第7項目群（確認）へ進む', p.SAVE_GROUP == 'GRPA07', p.SAVE_GROUP)
miru('ERR-FLG が 3（確認メッセージ）', p.ERR_FLG == 3, str(p.ERR_FLG))

print()
print('■ 取消 ― 製番が付いていたら消せない（1418行）')
con, p = tsukuru(4, wkk=[('610A0001', 1, 'S12345')]); kagami_ireru(con, '610A0001')
p.gs('見積なんば', '610A0001'); p.取消第２項目群()
miru('ERR-FLG が 10', p.ERR_FLG == 10, str(p.ERR_FLG))
con, p = tsukuru(4, wkk=[('610A0001', 1, '')]); kagami_ireru(con, '610A0001')
p.gs('見積なんば', '610A0001'); p.取消第２項目群()
miru('製番が無ければ 3 のまま', p.ERR_FLG == 3, str(p.ERR_FLG))

print()
print('■ 複写１（1428行）')
con, p = tsukuru(5, func='E000')
kagami_ireru(con, '510Z0001')
con.execute("INSERT INTO [AHATMP] (HATKBN,HATUCD,RENBAN,RKAGEN,RJOGEN)"
            " VALUES ('01','610A  ',7,0,9999)")
con.execute("INSERT INTO [AHATMP] (HATKBN,HATUCD,RENBAN,RKAGEN,RJOGEN)"
            " VALUES ('00','610A  ',41,0,9999)")
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.gs('複写元見積ナンバ', '510Z0001')
p.複写物新第２項目群()
miru('誤りなし', p.ERR_FLG == 0, str(p.ERR_FLG))
miru('新しい見積なんばが発番される', p.g('見積なんば') == '610A0008', repr(p.g('見積なんば')))
miru('物件ナンバーも発番される（複写物新だけ）', p.g('物件ナンバー') == '610A0042',
     repr(p.g('物件ナンバー')))
miru('複写は 変更回数ゼロ（3586行）', p.数('変更回数') == 0, p.g('変更回数'))
miru('複写元の件名が引き継がれる', p.g('件名１').startswith('件名いち'))
miru('ＶＬＤ２の見積ＮＯは**複写元**（4137行）',
     p.VLD2.tamatta and p.VLD2.tamatta[-1][32:40].decode('cp932') == '510Z0001',
     p.VLD2.tamatta[-1][32:48].decode('cp932') if p.VLD2.tamatta else '')
miru('ＶＬＤ２の複写先は新しい番号',
     p.VLD2.tamatta and p.VLD2.tamatta[-1][40:48].decode('cp932') == '610A0008')

print()
print('■ 複写元が外注（GAIKBN="1"）なら使えない（1691行）')
con, p = tsukuru(5); kagami_ireru(con, '510Z0001', GAIKBN='1')
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.gs('複写元見積ナンバ', '510Z0001')
p.複写物新第２項目群()
miru('ERR-FLG が 2', p.ERR_FLG == 2, str(p.ERR_FLG))

print()
print('■ 複写２（1480行）物件ナンバーは発番しない')
con, p = tsukuru(6); kagami_ireru(con, '510Z0001')
con.execute("INSERT INTO [AHATMP] (HATKBN,HATUCD,RENBAN,RKAGEN,RJOGEN)"
            " VALUES ('01','610A  ',7,0,9999)")
p.gs('担当者ＣＤ', '1020'); p.gs('施主大分類ＣＤ', 'A')
p.gs('複写元見積ナンバ', '510Z0001')
p.複写物新第２項目群.__self__.複写物修第２項目群()
miru('見積なんばは発番される', p.g('見積なんば') == '610A0008', repr(p.g('見積なんば')))
miru('物件ナンバーは複写元のまま（発番しない）',
     p.g('物件ナンバー').startswith('B0000001'), repr(p.g('物件ナンバー')))

print()
print('=' * 60)
print('■ %d件 合いませんでした。' % warui if warui
      else '■ 第2項目群は、すべて現行どおりに動きました。')
print('=' * 60)
sys.exit(1 if warui else 0)
