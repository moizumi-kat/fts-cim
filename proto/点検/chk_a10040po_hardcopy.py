# -*- coding: utf-8 -*-
"""「実際の見積画面のハードコピー」（2026-11-20 村上様より）と、移植した鑑を
   1項目ずつ突き合わせる。

     python3 点検/chk_a10040po_hardcopy.py

  ■ なぜこれが効くのか
    いただいた紙は **移植中の A10040D1 そのもの**で、しかも実案件2件。
    「現行がこう出した」という**人の手が入っていない正解**なので、
    移植が現行どおりかを外から確かめられる（CLAUDE.md 1-1 裏取り）。

  ■ 何を確かめるか
    ① マスタ引き … 画面の名前は、実マスタ（ASOSMP/ANAMMP/ATORMP/ASIYMP）から
       引いた値と紙が一致するか。**ここは移植が実際に引いて出す。**
    ② 表示の形 … 納期 24.12.20／掛率 3.80／見積総額 1,354,000 のように、
       画面がもつデータ（241220・380・000001354000）と紙の見た目はちがう。
       .SMD の編集どおりに組み立てて紙と合うか。
    ③ 見積ナンバーの作り … 41130558 ＝ 年4＋支店11＋施主3＋連番0558。

  ■ 鑑ファイルの扱い
    この2件は、いただいた実データ（2025-2026年ぶん）には入っていない年のもの。
    紙から読み取った値で**その場だけ**鑑ファイルへ入れ、見終わったら戻す
    （ROLLBACK するので実データは汚さない）。
"""
import sys, pathlib, datetime
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cim import db as cimdb
from cim.cobol import vld, a10040po
from cim.cobol.a10010po import Linkage

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)


class Sousa(vld.Kioku):
    def __init__(self): super().__init__()
    def yomu(self, group, mode): return None, vld.NYURYOKU


# ── 紙から読み取った鑑の中身 ────────────────────────────
# （画面に出ている項目だけ。出ていない項目は現行の初期値のまま）
KAMI = [
 dict(
  MITUNO='41130558', BKENNO='41130459', UPDCNT=0,
  CRTBSY='11', CRTKKR='19', SEDICD='3',
  KNMEIK='ﾐｻﾄ', KENME1='美郷町第二庁舎事務室空調設備改修工事',
  KENME2='', KENME3='　' * 17 + '御用品',
  KAKKBN='2', IRAICD='22461', SIYOU1='01', SIYOU2='R3',
  ATENA1='', ATENA2='',
  SESYCD='01218', SEKECD='01218', KENGCD='09999', KETDEN='22461',
  FASTNK=20241220, LASTNK=20241220,
  NONUHI='御打ち合わせの上', UKEWAB='車上渡し', SIHARI='従来通り',
  NIDUUN='含入', MITKGN='６０日', SKAINO='', SKAIHI=0,
  KAKRIT_1='3.80', KAKRIT_2='3.80', KAKRIT_3='3.80', KAKRIT_4='1.00',
  TOKKI1='【社内用】４１１３－０５５６', TOKKI2='', TOKKI3='',
  MITGAK_1=1354000, MITRIT=68, SASKIN_1=1354000, DELFLG='0', GAIKBN='',
 ),
 dict(
  MITUNO='41130651', BKENNO='41130445', UPDCNT=0,
  CRTBSY='11', CRTKKR='24', SEDICD='3',
  KNMEIK='ｱｷﾀｱﾄﾘｵﾝ', KENME1='【秋田アトリオンビル空調改修】',
  KENME2='動力盤更新工事', KENME3='（一部改修変更分）＜社内用＞御用品',
  KAKKBN='2', IRAICD='38101', SIYOU1='01', SIYOU2='R3',
  ATENA1='', ATENA2='',
  SESYCD='', SEKECD='', KENGCD='', KETDEN='',
  FASTNK=0, LASTNK=0,
  NONUHI='御打ち合わせの上', UKEWAB='車上渡し', SIHARI='従来通り',
  NIDUUN='含入', MITKGN='６０日', SKAINO='', SKAIHI=0,
  KAKRIT_1='4.10', KAKRIT_2='4.10', KAKRIT_3='4.10', KAKRIT_4='1.40',
  TOKKI1='＜社内用＞', TOKKI2='', TOKKI3='',
  MITGAK_1=56024000, MITRIT=799, SASKIN_1=56024000, DELFLG='0', GAIKBN='',
 ),
]

# 紙に出ている「見た目」。移植が出す表示とそのまま比べる。
MIME = [
 {'処理区': '2',
  '担当者ＣＤ': '1119', '作成部所名': '北日本支店', '担当者名': '高橋　諒',
  '複写元見積ナンバ': '', '施主大分類ＣＤ': '3', '施主大分類名': '地',
  '見積なんば': '41130558', '変更回数': '', '物件ナンバー': '41130459',
  '件名カナ': 'ﾐｻﾄ', '件名１': '美郷町第二庁舎事務室空調設備改修工事',
  '価格区分': '2', '価格区分名': '工業会',
  '依頼先コード': '22461', '依頼先名': '㈱日仙電機',
  '仕様コード': '01', '仕様名': '公共建築',
  '仕様２コード': 'R3', '仕様名２': 'Ｒ３',
  '施主コード': '01218', '施主名': '秋田県自治',
  '設計事務所コード': '01218', '設計事務所名': '秋田県自治',
  '建設業者': '09999', '建設業者名': '建築工事無',
  '電気工事業者ＣＤ': '22461', '電気工事業者名': '㈱日仙電機',
  '最早納期': '24.12.20', '最終納期': '24.12.20',
  '納入期日': '御打ち合わせの上', '受渡場所': '車上渡し',
  '支払条件': '従来通り', '荷造及び運賃': '含入', '見積有効期限': '６０日',
  '御照会番号': '', '御照会日付': '',
  '掛率配電盤': '3.80', '掛率制御盤': '3.80',
  '掛率分電盤': '3.80', '掛率その他': '1.00',
  '特記事項１': '【社内用】４１１３－０５５６',
  '見積総額': '1,354,000', '見積率': '068', '差引合計金額': '1,354,000'},
 {'処理区': '2',
  '担当者ＣＤ': '1124', '作成部所名': '北日本支店', '担当者名': '中須賀　拓真',
  '複写元見積ナンバ': '', '施主大分類ＣＤ': '3', '施主大分類名': '地',
  '見積なんば': '41130651', '変更回数': '', '物件ナンバー': '41130445',
  '件名カナ': 'ｱｷﾀｱﾄﾘｵﾝ', '件名１': '【秋田アトリオンビル空調改修】',
  '価格区分': '2', '価格区分名': '工業会',
  '依頼先コード': '38101', '依頼先名': 'ユアテック',
  '仕様コード': '01', '仕様名': '公共建築',
  '仕様２コード': 'R3', '仕様名２': 'Ｒ３',
  '施主コード': '', '施主名': '',
  '設計事務所コード': '', '設計事務所名': '',
  '建設業者': '', '建設業者名': '',
  '電気工事業者ＣＤ': '', '電気工事業者名': '',
  '最早納期': '', '最終納期': '',
  '納入期日': '御打ち合わせの上', '受渡場所': '車上渡し',
  '支払条件': '従来通り', '荷造及び運賃': '含入', '見積有効期限': '６０日',
  '御照会番号': '', '御照会日付': '',
  '掛率配電盤': '4.10', '掛率制御盤': '4.10',
  '掛率分電盤': '4.10', '掛率その他': '1.40',
  '特記事項１': '＜社内用＞',
  '見積総額': '56,024,000', '見積率': '799', '差引合計金額': '56,024,000'},
]

con = cimdb.connect()

# チェックＦ＝「いま誰かが開いている」札。前の点検の札が残っていると
# 現行どおり「ほかの人が使用中（ERR_FLG=5）」で弾かれるので、先に片づける。
con.execute('DELETE FROM ACHKFP')
con.commit()

print('■ ハードコピー2件を鑑ファイルへ（終わったら戻す）')
ireta = []
try:
    for k in KAMI:
        con.execute('DELETE FROM AJBGFP WHERE MITUNO=?', (k['MITUNO'],))
        con.execute('INSERT INTO AJBGFP(%s) VALUES(%s)'
                    % (','.join('[%s]' % c for c in k), ','.join('?' * len(k))),
                    tuple(k.values()))
        ireta.append(k['MITUNO'])
    con.commit()
    miru('2件入れた', len(ireta) == 2)

    for kami, mime in zip(KAMI, MIME):
        print()
        print('■ 見積No %s （紙のとおりに出るか）' % kami['MITUNO'])
        p = a10040po.A10040PO(con=con, db=cimdb, sousa=Sousa(),
                              kyou=datetime.datetime(2026, 11, 20, 9, 0, 0))
        p.初期処理Ｒ()
        p.link = Linkage()
        p.gs('処理区', 2)                       # 修正
        p.gs('見積なんば', kami['MITUNO'])
        p.修正第２項目群()
        if p.ERR_FLG:
            miru('修正で画面まで通る', False, 'ERR_FLG=%s' % p.ERR_FLG)
            continue
        chigau = []
        for na, beki in sorted(mime.items()):
            de = p.画面.hyouji(na).strip()
            if de != beki.strip():
                chigau.append('%s 紙=%r 移植=%r' % (na, beki, de))
        miru('紙の %d 項目すべて一致' % len(mime), not chigau)
        for c in chigau:
            print('        ', c)
        warui_mae = warui
        # 見積ナンバーの作り（年1＋支店2＋施主1＋連番4）
        m = kami['MITUNO']
        miru('見積No = 年%s＋支店%s＋施主%s＋連番%s'
             % (m[0], m[1:3], m[3], m[4:]),
             m[1:3] == kami['CRTBSY'] and m[3] == kami['SEDICD'])
        # システム日付（画面の右上）
        miru('システム日付が 26.11.20', p.画面.hyouji('システム日付') == '26.11.20',
             repr(p.画面.hyouji('システム日付')))
finally:
    for m in ireta:
        con.execute('DELETE FROM AJBGFP WHERE MITUNO=?', (m,))
    con.execute('DELETE FROM ACHKFP')
    con.commit()
    print()
    print('   （入れた2件は消して、実データを元に戻しました）')

print()
print('%s （誤り %d件）' % ('紙のとおりでした。' if not warui
                             else '紙と合わないところがあります。', warui))
sys.exit(1 if warui else 0)
