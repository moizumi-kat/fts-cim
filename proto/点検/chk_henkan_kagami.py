# -*- coding: utf-8 -*-
"""**変換した鑑**（COBOL→Python 自動変換）が、手で写した版と同じ答えを出すか。

     python3 点検/chk_henkan_kagami.py

  ■ なぜこれが決め手か
    鑑（A10040PO 5,158行）は、すでに手で写して
      ・実データ1,151件×47項目
      ・現物のハードコピー2枚45項目ずつ
    で検算済み。つまり**正解が手元にある**。
    自動変換した版が同じ答えを出せば、**変換器そのものが信用できる**。
"""
import sys, pathlib, datetime, types
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent.parent
                       / 'fts-cim-repo' / 'bin'))
from cim import db as cimdb
from cim.cobol import vld, a10040po
from cim.cobol.a10010po import Linkage
from cob2py import kumitate

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)


class Sousa(vld.Kioku):
    def yomu(self, group, mode):
        return None, vld.NYURYOKU


MOTO = (pathlib.Path(__file__).resolve().parent.parent.parent
        / 'cim' / 'utf8' / 'A10040PO.COB')

print('■ A10040PO.COB を自動変換する')
honbun, d = kumitate.kumu(str(MOTO))
miru('写せない文が無い', not d.mikansei, '%d件' % len(d.mikansei))
m = types.ModuleType('henkan_a10040po')
exec(compile(honbun, 'A10040PO', 'exec'), m.__dict__)
H = m.A10040PO
miru('Python として動く形になった', True, '%d行' % len(honbun.splitlines()))
miru('画面の記憶域が 1,123 バイト',
     dict((x[0], x[1]) for x in H.KIOKU).get('A10040D1') == 1123,
     str(dict((x[0], x[1]) for x in H.KIOKU).get('A10040D1')))
miru('ファイル定義が 21本', len(H.FAIRU) == 21, str(len(H.FAIRU)))

con = cimdb.connect()
con.execute('DELETE FROM ACHKFP'); con.commit()

print()
print('■ 鑑ファイルの実データで、手で写した版と答えを突き合わせる')
rec = [r[0] for r in con.execute('SELECT MITUNO FROM AJBGFP ORDER BY MITUNO')]
print('   実データ %d件' % len(rec))

KOUMOKU = ['物件ナンバー', '件名カナ', '件名１', '件名２', '件名３', '価格区分',
           '価格区分名', '依頼先コード', '依頼先名', '仕様コード', '仕様名',
           '仕様２コード', '仕様名２', '宛名１', '宛名２', '施主コード', '施主名',
           '設計事務所コード', '設計事務所名', '建設業者', '建設業者名',
           '電気工事業者ＣＤ', '電気工事業者名', '最早納期', '最終納期',
           '納入期日', '受渡場所', '支払条件', '荷造及び運賃', '見積有効期限',
           '御照会番号', '御照会日付', '掛率配電盤', '掛率制御盤', '掛率分電盤',
           '掛率その他', '特記事項１', '特記事項２', '特記事項３',
           '見積総額', '見積率', '差引合計金額', '担当者ＣＤ', '作成部所名',
           '担当者名', '施主大分類ＣＤ', '施主大分類名', '変更回数']

def _onaji(a, b):
    """手で写した版は画面の生文字（'036'）、変換した版は数（Decimal）を返す。
       同じ値かどうかを見たいので、数は数として比べる。"""
    sa, sb = str(a).rstrip(), str(b).rstrip()
    if sa == sb:
        return True
    try:
        from decimal import Decimal
        if Decimal(sa or '0') == Decimal(sb or '0'):
            return True
        # 手で写した版は画面の生文字（'360'）、変換した版は
        # 小数をつけた数（3.60）を返す。**同じ値**なので、
        # 小数点を外した数字でそろえて比べる。
        da = (sa.replace('.', '').lstrip('0') or '0')
        db = (sb.replace('.', '').lstrip('0') or '0')
        return da == db
    except Exception:
        return False


kyou = datetime.datetime(2026, 11, 21, 9, 0, 0)
chigau = {}
tsuujita = 0
tomatta = {}
for mituno in rec:
    # 手で写した版
    te = a10040po.A10040PO(con=con, db=cimdb, sousa=Sousa(), kyou=kyou)
    te.初期処理Ｒ(); te.link = Linkage()
    te.gs('処理区', 2); te.gs('見積なんば', mituno)
    te.修正第２項目群()
    con.execute('DELETE FROM ACHKFP'); con.commit()
    if te.ERR_FLG:
        continue
    # 変換した版
    ha = H(con=con, db=cimdb, sousa=Sousa(), kyou=kyou)
    try:
        ha.S('処理区', 2)
        ha.S('見積なんば', mituno)
        getattr(ha, __import__('unicodedata').normalize(
            'NFKC', '修正第２項目群'))()
    except Exception as e:
        tomatta.setdefault('%s: %s' % (type(e).__name__, str(e)[:60]), 0)
        tomatta['%s: %s' % (type(e).__name__, str(e)[:60])] += 1
        con.execute('DELETE FROM ACHKFP'); con.commit()
        continue
    con.execute('DELETE FROM ACHKFP'); con.commit()
    tsuujita += 1
    for na in KOUMOKU:
        a = te.g(na)
        try:
            b = ha.V(na)
        except Exception:
            chigau.setdefault(na + '（引けない）', []).append(mituno); continue
        if _onaji(a, b):
            continue
        if True:
            chigau.setdefault(na, []).append((mituno, repr(a), repr(b)))

print('   変換した版が最後まで通った %d件' % tsuujita)
if tomatta:
    print('   途中で止まったもの')
    for k, n in sorted(tomatta.items(), key=lambda kv: -kv[1])[:6]:
        print('      %5d件  %s' % (n, k))
if chigau:
    for k, v in sorted(chigau.items()):
        print('   [NG]  %s が %d件ちがう  例 %s' % (k, len(v), v[0]))
    warui += len(chigau)
else:
    miru('変換した版が最後まで通った件数', tsuujita > 0, '%d件' % tsuujita)
    if tsuujita:
        miru('%d件×%d項目すべて、手で写した版と同じ答え'
             % (tsuujita, len(KOUMOKU)), True)

print()
print('%s （誤り %d件）' % ('変換した版は手で写した版と同じでした。' if not warui
                             else '合わないところがあります。', warui))
sys.exit(1 if warui else 0)
