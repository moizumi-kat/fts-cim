# -*- coding: utf-8 -*-
"""A10040PO（鑑）を**実データ**で検算する。

     python3 点検/chk_a10040po_jitsu.py

  ■ なぜ実データで見るのか（CLAUDE.md 1-1「裏取り」）
    移植が「現行どおり」かは、作った試験値では確かめられない。
    村上様からいただいた現物（鑑ファイル1,151件・各マスタ）を流して、
    画面に出る値が**現物のとおり**になるかを1件ずつ突き合わせる。

  ■ 使う現物（load_csv.py で取り込んだもの）
    AJBGFP 1,151件（鑑）／AHATMP 1,848件（発番）／ASOSMP 545／ANAMMP 357
    ATORMP 7,579／ASIYMP 143／ABUHMP 4,994／ATYUMP 1,569／ASUNMP 923
    AKAKMP 1／ABANMP 6／CCALMP 12,418／CSHKMP 12
    AWKGFP・AWKKFP・AWKMFP・ACHKFP・ARMIJP は空（村上様「空でかまいません」）。

  ■ 突き合わせの土台（2026-11-20 受領の「実際の見積画面のハードコピー」）
    移植中の A10040D1 そのものの画面が2件。桁・並び・表示の形の正解として使う。
"""
import sys, pathlib, datetime
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim import db as cimdb
from cim.cobol import vld, fairu, a10040po
from cim.cobol.a10010po import Linkage

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)


class Sousa(vld.Kioku):
    def __init__(self, func='E000'):
        super().__init__()
        self.func = func
    def yomu(self, group, mode):
        return None, vld.NYURYOKU


con = cimdb.connect()
con.row_factory = __import__('sqlite3').Row if 'sqlite3' in str(type(con)) else con.row_factory

def hiku(sql, *a):
    return list(con.execute(sql, a))

def tsukuru():
    p = a10040po.A10040PO(con=con, db=cimdb, sousa=Sousa('E000'),
                          kyou=datetime.datetime(2026, 11, 20, 9, 0, 0))
    p.初期処理Ｒ()
    p.link = Linkage()
    return p

def s(v):
    return ('' if v is None else str(v)).strip()


# チェックＦ＝「いま誰かが開いている」札。鑑を1,151件ぶん開くとその数だけ
# 札が立つので、始める前と終わったあとに落とす（現行の運用でも落ちる）。
con.execute('DELETE FROM ACHKFP')
con.commit()


# ================================================================
print('■ 取り込んだ現物の件数')
# 2026-11-24 に **実データ492本（SFL.zip）** が届き、件数が増えた。
# 固定の件数で見ると「増えたこと」を誤りと数えてしまうので、
# **中身があること**を見る（下の突き合わせが本番の検算）。
for t in ('AJBGFP', 'AHATMP', 'ASOSMP', 'ANAMMP', 'ATORMP', 'ASIYMP',
          'ABUHMP', 'ATYUMP', 'ASUNMP', 'CCALMP'):
    j = hiku('SELECT COUNT(*) FROM %s' % t)[0][0]
    miru('%s に現物がある' % t, j > 0, '%d件' % j)
# ワークと札は空でよい（村上様）。履歴（ARMIJP）は .SFL から入ったので中身がある。
for t in ('AWKGFP', 'AWKKFP', 'AWKMFP', 'ACHKFP'):
    j = hiku('SELECT COUNT(*) FROM %s' % t)[0][0]
    miru('%s は空（村上様の指示どおり）' % t, j == 0, '%d件' % j)

# ================================================================
print()
print('■ 発番（3374-3520行）を現物で裏取り')
# 発番ファイルの作り
kbn = [r[0].strip() for r in hiku('SELECT DISTINCT HATKBN FROM AHATMP ORDER BY 1')]
miru('HATKBN に 01（見積）と 00（物件）が在る', '01' in kbn and '00' in kbn, ' '.join(kbn))
n01 = hiku("SELECT COUNT(*) FROM AHATMP WHERE RTRIM(HATKBN)='01'")[0][0]
n00 = hiku("SELECT COUNT(*) FROM AHATMP WHERE RTRIM(HATKBN)='00'")[0][0]
miru('見積と物件が同数（1:1で立っている）', n01 == n00 and n01 > 0, '%d／%d' % (n01, n00))

# 発番コードの形＝年1＋支店2＋施主1（＋空白2）
# 見積（01）と物件（00）だけ。ほかの発番区分（02/03/11…）は別の採番で桁も違う。
warui_katachi = [r[0] for r in hiku(
    """SELECT HATUCD FROM AHATMP
       WHERE RTRIM(HATKBN) IN ('01','00') AND LENGTH(RTRIM(HATUCD))<>4""")]
miru('見積・物件の HATUCD は有効4桁（＝年1＋支店2＋施主1）', not warui_katachi,
     '%d件 例 %r' % (len(warui_katachi), warui_katachi[:3]))

p = tsukuru()
p.WK_NEN = 26
p.gs('担当者ＣＤ', '1119')
p.gs('施主大分類ＣＤ', '3')
p.発番区分 = p.見積
f = p.発番キー設定Ｒ()
miru('発番用ワークは 6桁', len(p.発番用ワーク()) == 6, repr(p.発番用ワーク()))
miru('発番用ワーク＝年1＋支店2＋施主1＋空白2', p.発番用ワーク() == '6113  ',
     repr(p.発番用ワーク()))
miru('見積のキーは HATKBN="01"', f['HATKBN'] == '01', repr(f['HATKBN']))
miru('HATUCD は定義どおり char(06) に収まる', len(f['HATUCD']) == 6, repr(f['HATUCD']))
p.発番区分 = p.物件
miru('物件のキーは HATKBN="00"', p.発番キー設定Ｒ()['HATKBN'] == '00')

# 発番編集Ｒ ＝ HATUCD の先頭4桁＋連番4桁
p.発番区分 = p.見積
p.発番キー設定Ｒ()
p.ファイル['AHATML1']['RENBAN'] = 558
p.発番編集Ｒ()
miru('発番編集Ｒ：6113＋0558 → 61130558', p.g('見積なんば') == '61130558',
     repr(p.g('見積なんば')))

# ここが本番。現物の鑑 1,151件すべてで
#   見積ＮＯ ＝ 年1 ＋ 作成部所2 ＋ 施主大分類1 ＋ 連番4
# が成り立つか。成り立てば 発番編集Ｒ の作りは現行と同じ。
# **数字だけの見積ＮＯ**がこの形になる。実データ12,955件のうち122件は
# `6YD30044` のように英字を含み、この形では**ない**（古い付番と思われる）。
# 発番編集Ｒ が作るのは数字だけの形なので、そちらで検算する。
chigau = []
eiji = 0
for r in hiku('SELECT MITUNO, CRTBSY, SEDICD FROM AJBGFP'):
    m, bsy, sedi = s(r[0]), s(r[1]), s(r[2])
    if not m.isdigit():
        eiji += 1
        continue
    if len(m) != 8 or m[1:3] != bsy.zfill(2) or m[3:4] != sedi:
        chigau.append((m, bsy, sedi))
miru('数字だけの見積ＮＯは「年1＋支店2＋施主1＋連番4」', not chigau,
     '%d件ちがう 例 %r（英字を含む見積ＮＯ %d件は対象外）'
     % (len(chigau), chigau[:3], eiji))

# 発番ファイルの連番で、実際にその番号が作れるか（現物の最大番号と突き合わせ）
tameshi = 0
for r in hiku("""SELECT RTRIM(HATUCD) AS U, RENBAN FROM AHATMP
                 WHERE RTRIM(HATKBN)='01' AND RENBAN>0 ORDER BY U LIMIT 200"""):
    u, ren = s(r[0]), int(r[1] or 0)
    p.WK_NEN_KUBUN, p.WK_SITEN_KUBUN, p.WK_SESHU_KUBUN = u[0], u[1:3], u[3]
    p.ファイル['AHATML1']['RENBAN'] = ren
    p.発番編集Ｒ()
    if p.g('見積なんば') != '%s%04d' % (u, ren):
        chigau.append((u, ren, p.g('見積なんば')))
    tameshi += 1
miru('発番ファイル %d件から番号を組み立てられる' % tameshi, not chigau,
     '%r' % chigau[:3])

# ================================================================
print()
print('■ 修正第２項目群（1362行）→ 全項目群出力Ｒ（3572行）を現物1,151件で')
# 鑑ファイルの列 → 画面の項目（全項目群出力Ｒ の写し先）
UTSUSHI = [
    ('BKENNO', '物件ナンバー'), ('KNMEIK', '件名カナ'),
    ('KENME1', '件名１'), ('KENME2', '件名２'), ('KENME3', '件名３'),
    ('KAKKBN', '価格区分'), ('IRAICD', '依頼先コード'),
    ('SIYOU1', '仕様コード'), ('SIYOU2', '仕様２コード'),
    ('ATENA1', '宛名１'), ('ATENA2', '宛名２'),
    ('SESYCD', '施主コード'), ('SEKECD', '設計事務所コード'),
    ('KENGCD', '建設業者'), ('KETDEN', '電気工事業者ＣＤ'),
    ('FASTNK', '最早納期'), ('LASTNK', '最終納期'),
    ('NONUHI', '納入期日'), ('UKEWAB', '受渡場所'), ('SIHARI', '支払条件'),
    ('NIDUUN', '荷造及び運賃'), ('MITKGN', '見積有効期限'),
    ('SKAINO', '御照会番号'), ('SKAIHI', '御照会日付'),
    ('KAKRIT_1', '掛率配電盤'), ('KAKRIT_2', '掛率制御盤'),
    ('KAKRIT_3', '掛率分電盤'), ('KAKRIT_4', '掛率その他'),
    ('TOKKI1', '特記事項１'), ('TOKKI2', '特記事項２'), ('TOKKI3', '特記事項３'),
    ('MITGAK_1', '見積総額'), ('MITRIT', '見積率'), ('SASKIN_1', '差引合計金額'),
    ('UPDCNT', '変更回数'),
]

def matomo(kata, naga, db_atai, shou=0):
    """鑑ファイルの値を COBOL の MOVE にかけたら画面はこうなる、という値。

       ■ ここを作り直した理由（2026-11-20 実測）
         はじめは「鑑ファイルの値とそのまま同じか」で見ていたが、
         それだと**現行の正しいふるまいまで誤りに見えてしまう**。
           ・施主大分類名は画面が **2バイト**。'官庁関係' は '官' に切れる。
             ハードコピーでも「3 地」と**全角1文字**しか出ていない＝切れるのが正。
           ・最早納期は画面が **6桁**。20250929 は下6桁 '250929' になる。
             ハードコピーでも「24.12.20」＝年の上2桁は画面に無い＝切れるのが正。
         COBOL の MOVE は **英数は左詰めで右が切れ、数字は右詰めで左が切れる**。
         その規則をここで**別に書き起こして**から比べる（移植側の関数は使わない
         ＝同じ理屈を2度書かないと検算にならないため）。
    """
    # **英数は先頭の空白を落とさない**（2026-11-24 実測で判明）。
    #   COBOL の MOVE は左詰めで、先頭の全角空白もそのまま写る。
    #   ここで strip() していたため、`　×17＋御用品` のような値で
    #   「移植が正しいのに誤りに見える」ことが 9,796件あった。
    #   数字は左の0や空白を落として比べるので従来どおり strip する。
    d = s(db_atai) if kata == '9' else ('' if db_atai is None
                                       else str(db_atai)).rstrip()
    if kata == '9':
        # 画面が小数の桁を持つ項目（掛率は小数2桁）は、桁を上げてから入る。
        #   表の 3.6 は画面で '360'（表示 3.60）。上げずに比べると合わない。
        if shou:
            from decimal import Decimal as _D
            try:
                d = str(int(_D(d or '0').scaleb(shou)))
            except Exception:
                pass
        d = ''.join(c for c in d if c.isdigit()) or '0'
        return (d[-naga:] if len(d) > naga else d).lstrip('0') or '0'
    b = d.encode('cp932', 'replace')[:naga]
    try:
        b.decode('cp932')
    except UnicodeDecodeError:
        b = b[:-1]
    return b.decode('cp932').rstrip()


def onaji(kata, naga, hako, db_atai, shou=0):
    g = hako
    if kata == '9':
        g = g.strip().lstrip('0') or '0'
    else:
        g = g.rstrip()
    return g == matomo(kata, naga, db_atai, shou)

_G = __import__('cim.cobol.gamen_a10040d1', fromlist=['KOUMOKU', 'HENSYUU'])
_K = _G.KOUMOKU
kata = {k[1]: k[7] for k in _K}
naga = {k[1]: k[5] for k in _K}          # データ長（画面がもつバイト数）
shou = {k[1]: (getattr(_G, 'HENSYUU', {}).get(k[1]) or (0, 0, '', 0))[3]
        for k in _K}                      # 小数の桁（定義体の編集から）

rec = hiku('SELECT * FROM AJBGFP ORDER BY MITUNO')
print('   鑑ファイル %d件を1件ずつ流す' % len(rec))
machigai = {}
tsuujita = 0
akai = 0
for r in rec:
    d = dict(r)
    p = tsukuru()
    p.gs('処理区', 2)                       # 修正
    p.gs('見積なんば', s(d['MITUNO']))
    p.修正第２項目群()
    if p.ERR_FLG:                            # DELFLG="1" 等は現行どおり弾かれる
        akai += 1
        continue
    tsuujita += 1
    for col, na in UTSUSHI:
        if not onaji(kata[na], naga[na], p.g(na), d[col], shou[na]):
            machigai.setdefault('%s→%s' % (col, na), []).append(
                (s(d['MITUNO']), repr(p.g(na)), repr(d[col])))
    # 担当者・施主大分類・各マスタの名前
    def kuraberu(moto, na, atai):
        if atai is None:
            return
        if not onaji(kata[na], naga[na], p.g(na), atai, shou[na]):
            machigai.setdefault('%s→%s' % (moto, na), []).append(
                (s(d['MITUNO']), repr(p.g(na)), repr(atai)))

    o = hiku('SELECT BSYNAM,TANNAM FROM ASOSMP WHERE RTRIM(BSYOCD)=? AND RTRIM(TANCD)=?',
             s(d['CRTBSY']), s(d['CRTKKR']))
    if o:
        kuraberu('ASOSMP', '作成部所名', o[0][0])
        kuraberu('ASOSMP', '担当者名', o[0][1])
    kuraberu('AJBGFP', '担当者ＣＤ',
             '%s%s' % (s(d['CRTBSY']).zfill(2), s(d['CRTKKR']).zfill(2)))
    kuraberu('AJBGFP', '施主大分類ＣＤ', d['SEDICD'])
    n = hiku("SELECT RYAKU FROM ANAMMP WHERE RTRIM(NAMKBN)='00' AND RTRIM(NAMCD)=?",
             s(d['SEDICD']))
    if n:
        kuraberu('ANAMMP', '施主大分類名', n[0][0])
    k = hiku("SELECT RYAKU FROM ANAMMP WHERE RTRIM(NAMKBN)='02' AND RTRIM(NAMCD)=?",
             s(d['KAKKBN']))
    if k:
        kuraberu('ANAMMP', '価格区分名', k[0][0])
    for col, na in (('IRAICD', '依頼先名'), ('SESYCD', '施主名'),
                    ('SEKECD', '設計事務所名'), ('KENGCD', '建設業者名'),
                    ('KETDEN', '電気工事業者名')):
        t = hiku('SELECT TORNAR FROM ATORMP WHERE RTRIM(TORICD)=?', s(d[col]))
        if t:
            kuraberu('ATORMP', na, t[0][0])
    for col, na in (('SIYOU1', '仕様名'), ('SIYOU2', '仕様名２')):
        y = hiku('SELECT SIYONA FROM ASIYMP WHERE RTRIM(SIYOCD)=?', s(d[col]))
        if y:
            kuraberu('ASIYMP', na, y[0][0])

miru('修正で画面まで通った件数', tsuujita > 0, '%d件（弾かれた %d件）' % (tsuujita, akai))
if machigai:
    for k, v in sorted(machigai.items()):
        print('   [NG]  %s が %d件ちがう  例 %s' % (k, len(v), v[0]))
    warui += len(machigai)
else:
    miru('%d件×%d項目すべて現物と一致' % (tsuujita, len(UTSUSHI) + 12), True)

con.execute('DELETE FROM ACHKFP')
con.commit()

print()
print('%s （誤り %d件）' % ('すべて現物どおりでした。' if not warui
                             else '現物と合わないところがあります。', warui))
sys.exit(1 if warui else 0)
