# -*- coding: utf-8 -*-
"""現物の紙と、このプロトタイプが**現行ロジックで計算した**数字を突き合わせる。

   数字の出どころを3つに分けて見ます。
     [読]  現行ファイルの値をそのまま出す項目
     [算]  現行COBOLのロジックで計算する項目（cim/cobol/ の移植）
     [外]  別のファイルから引く項目。元データが無ければ計算できない
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cim.db import connect
from cim import repo

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

NG, SKIP = [], []

def _n(v):
    """数どうしを、型の違いに左右されずに比べられる形にする。

    SQL Server は numeric の列を Decimal、SQLite は float で返します。
    Decimal('115.1') と float の 115.1 は、そのまま == すると**違う**と出ます
    （float の 115.1 はぴったり 115.1 ではないため）。文字にしてから
    Decimal に直し、10進の値どうしで比べます。
    """
    from decimal import Decimal, InvalidOperation
    if isinstance(v, (tuple, list)): return tuple(_n(x) for x in v)
    if isinstance(v, bool) or not isinstance(v, (int, float, Decimal)): return v
    try: return Decimal(str(v)).normalize()
    except InvalidOperation: return v

def _show(v):
    """画面に出す形。Decimal('120.0') は 120.0 と出す。"""
    from decimal import Decimal
    if isinstance(v, (tuple, list)):
        return '(%s)' % ', '.join(_show(x) for x in v)
    return str(v) if not isinstance(v, Decimal) else format(v, 'f')

def eq(name, got, want, kind='[算]'):
    ok = (_n(got) == _n(want))
    if not ok: NG.append('%s %s：計算 %s ／ 現物 %s' % (kind, name, got, want))
    print('%-4s %-30s %-14s %s' % (kind, name, _show(got),
                                   'OK' if ok else '← 現物は %s' % _show(want)))

def skip(name, why):
    SKIP.append('%s：%s' % (name, why))
    print('%-4s %-30s %-14s %s' % ('[外]', name, '-', why))

con = connect()
print('■ 営業日報（26年9月30日現在）  ※ NPJYU5CS.COB の移植で計算')
d = repo.nippou(con)
GENBUTSU = {  # 現物の紙の値： 受目標, 受注実績, 達成率, 受注率, 当受注, 出図実績, 売上実績
 '北日本支店': (36000,19725,54.7,113.6,12905,15240,7500),
 '仙台支店':   (58000, 3670, 6.3,140.3,  230,38531,29324),
 '郡山支店':   (46000, 3570, 7.7, 94.8,    0, 4267,22389),
 '東京支店':  (240000,12344, 5.1,107.4,  880,40998,46697),
 '横浜営業所': (30000, 1025, 3.4,  0.0,  280,38516,    0),
 '関西支店':   (87000,51100,58.7,105.2,50600,34071,24873),
 'システム事業部':(28000,1175,4.1,111.5,   0, 1175,  979),
 '名古屋営業所':(25000, 450, 1.8,  0.0,  450, 6455, 1914),
 '東北営業部　計':(140000,26965,19.2,116.9,13135,58038,59213),
 '東京営業部　計':(410000,66094,16.1,105.3,52210,121215,74463),
 '　総合計　': (550000,93059,16.9,107.6,65345,179253,133676),
}
rows = [r for g in d['groups'] for r in (g['rows'] + ([g['total']] if g['total'] else []))]
if d['grand']: rows.append(d['grand'])
ritsu_arari = any(r.get('ritsu') for r in rows)
# 現物の紙の見出しも、画面に出た名前も、前後の空白を落としてから突き合わせます。
# （SQL Server は nchar を空白で埋めて返すため、そのままでは一致しません）
GEN = {k.strip(): v for k, v in GENBUTSU.items()}
NOKORI = set(GEN)                       # まだ画面に出ていない、紙にある行
for r in rows:
    nm = (r['nm'] or '').strip()
    w = GEN.get(nm)
    if not w:
        # 紙に無い行が画面に出た場合も、黙って飛ばさずに知らせる
        print('%-4s %-30s %-14s %s' % ('[!]', nm, '-', '現物の紙に無い行です'))
        NG.append('[!] %s：現物の紙に無い行が画面に出ました' % nm)
        continue
    NOKORI.discard(nm)
    eq('%s 受注目標額' % nm, r['mokuhyo'], w[0], '[読]')
    eq('%s 受注実績額' % nm, r['jutyu'],   w[1], '[読]')
    eq('%s 出図実績額' % nm, r['syutsuzu'],w[5], '[読]')
    eq('%s 売上実績額' % nm, r['uriage'],  w[6], '[読]')
    eq('%s 達成率' % nm,     r['tassei'],  w[2], '[算]')
    eq('%s 当日受注' % nm,   r['tou_jutyu'],w[4],'[算]')
    if ritsu_arari:
        eq('%s 受注率' % nm, r['ritsu'], w[3], '[外]')
    else:
        skip('%s 受注率' % nm,
             '現物サンプルに標準原価が無いため。実データなら計算されます')
for nm in sorted(NOKORI):       # 紙にあるのに画面に出なかった行＝取りこぼし
    print('%-4s %-30s %-14s %s' % ('[算]', '%s の行' % nm, 'なし', '← 現物の紙にはあります'))
    NG.append('[算] %s：現物の紙にある行が、画面に出ませんでした' % nm)
eq('生産実績額', d['seisan'], 156691, '[読]')
eq('現在日付', d['asof'], '26年9月30日現在', '[算]')

print('\n■ テーブルが現行のレコード定義どおりか')
from cim.schema_gen import TABLES
for t in ('NIPSYOFP','JURITUFP','KRIRIKFP','URIZSYFP','AJUGFP','AJUKFP',
          'AGEGFP','AGEKFP','KETUTESF','CJISFP','ASOSMP','ATORMP','KENTOUSF'):
    eq('%s がある' % t, t in TABLES, True)
col = lambda t: [c[0] for c in TABLES[t]['cols']]
# 列名は現行の COBOL 英名（村上様ご指示・2026-10-16）
eq('NIPSYOFP に EGJMOK（受注目標額）', 'EGJMOK' in col('NIPSYOFP'), True)
eq('JURITUFP に HYOGEN（標準原価）',   'HYOGEN' in col('JURITUFP'), True)
eq('AJUGFP に SEIBAN（製番）',         'SEIBAN' in col('AJUGFP'),   True)
# レプリケーション対象は、お送りいただいた定義体のままか
eq('AJUGFP はレプリ対象の定義そのまま', TABLES['AJUGFP']['src'], 'rep')
eq('AJUGFP の主キー',                  TABLES['AJUGFP']['pk'], ['SEIBAN'])
eq('ASOSMP の主キー',                  TABLES['ASOSMP']['pk'], ['BSYOCD', 'TANCD'])
# 型・桁も定義体どおりか
ty = lambda t, c: dict((x[0], x[1]) for x in TABLES[t]['cols'])[c]
eq('AJUGFP.SEIBAN',   ty('AJUGFP','SEIBAN'),   'char(6)')
eq('AJUGFP.KENMEI',   ty('AJUGFP','KENMEI'),   'nchar(20)')
eq('AJUGFP.JRITU',    ty('AJUGFP','JRITU'),    'numeric(4,1)')
eq('ASOSMP.BSYNAM',   ty('ASOSMP','BSYNAM'),   'nchar(10)')
# レプリ対象外は、変換仕様書どおりに作られているか
eq('NIPSYOFP は仕様書で生成',  TABLES['NIPSYOFP']['src'], 'conv')
eq('NIPSYOFP.EGCODE X(02)→',  ty('NIPSYOFP','EGCODE'), 'char(02)')
eq('NIPSYOFP.EGNAME N(08)→',  ty('NIPSYOFP','EGNAME'), 'nchar(08)')
eq('JURITUFP.JYURIT 9(03)V9(01)→', ty('JURITUFP','JYURIT'), 'numeric(4,1)')
# 繰返し（OCCURS）の列名が仕様書どおりか
eq('KRIRIKFP 受注金額の1回目',  'JUCYUK_1' in col('KRIRIKFP'), True)
eq('KRIRIKFP 限度額の1回目(5桁→_2つ)', 'GENDO__1' in col('KRIRIKFP'), True)
eq('NOKIB4SF グループ終了(5桁→_2つ)',  'OWARI__1' in col('NOKIB4SF'), True)

print('\n■ 日報内訳（2026年10月度 21日～20日・部所11 北日本支店）')
j = repo.jutyu_list(con, '11')
eq('受注一覧 受注の小計', j['blocks'][0]['total'], 48120)
eq('受注一覧 増減の小計', j['blocks'][1]['total'], 8605)
eq('受注一覧 合計',       j['grand'], 56725)
z = repo.syutsuzu_list(con, '11')
eq('出図一覧 受注金額計', z['total']['jutyu_gaku'], 48190)
eq('出図一覧 当月出図計', z['total']['tougetsu'], 20590)
u = repo.uriage_list(con, '11')
eq('売上一覧 受注金額計', u['total']['jutyu_gaku'], 45220)
eq('売上一覧 当月売上計', u['total']['tougetsu'], 19105)
eq('売上一覧 売上残額計', u['total']['zan'], 10214)

print('\n■ 画面遷移（Ｇの分岐＝物件検討ファイルに製番があるか）')
eq('6-11071 は物件検討あり？', repo.has_bukken(con,'6-11071'), False)
eq('5-21251 は物件検討あり？', repo.has_bukken(con,'5-21251'), True)

print('\n■ 受注票／実行予算／工程進捗')
eq('受注票 6-11071 受注金額(千円)', repo.jutyuhyo(con,'6-11071')['jutyu_gaku'], 650)
eq('受注票 6-11071 明細行数',     len(repo.jutyuhyo(con,'6-11071')['meisai']), 2)
eq('実行予算 6-11071 受注率',     repo.yosan(con,'6-11071')['ritsu'], 115.1)
eq('実行予算 6-11071 主材費(総原価)', repo.yosan(con,'6-11071')['meisai'][0]['sougenka'], 321)
eq('検討物件 5-21251 受注金額',   repo.bukken(con,'5-21251')['jutyu_gaku'], 122038)
eq('検討物件 5-21251 総原価',     repo.bukken(con,'5-21251')['HIYOUC'], 122860)
eq('工程進捗 6-11071 行数',       len(repo.sinchoku(con,'6-11071')), 2)
eq('検討物件 5-21251 受注率',     repo.bukken(con,'5-21251')['ritsu'], 99.3)

print('\n■ 受注率の式と集計規則')
# 式の向き：現物のうち、受注金額と総原価が両方のっている唯一の例で検算する
b = repo.bukken(con, '5-21251')
sou = b['HIYOUC']   # 検討決定ファイル KETUTESF の総原価
eq('5-21251 受注金額÷総原価', repo._rate(b['jutyu_gaku'], sou), b['ritsu'])
# 集計規則：率を平均せず、金額と原価をそれぞれ足してから割る
#   （業務データではなく、計算規則そのものの検算）
A = [(12000, 10000), (300, 200), (900, 1000)]        # (受注予定金額, 標準原価)
kaku = [repo.juritsu(g, c) for g, c in A]
eq('各拠点の率', tuple(kaku), (120.0, 150.0, 90.0))
eq('足してから割る',   repo.juritsu(sum(g for g,_ in A), sum(c for _,c in A)), 117.8)   # 13,200 ÷ 11,200
eq('※率の単純平均なら', round(sum(kaku)/len(kaku), 1), 120.0)   # 117.8 とは別物

print('\n■ 目標メンテ（決定21：年度額÷12をひと月分として登録）')
before = [r['tsuki_gaku'] for r in repo.mokuhyo_list(con) if r['cd']=='11'][0]
repo.mokuhyo_save(con, 2026, [('11', 480000)])
eq('年度480,000 → ひと月分', [r['tsuki_gaku'] for r in repo.mokuhyo_list(con) if r['cd']=='11'][0], 40000)
repo.mokuhyo_save(con, 2026, [('11', before*12)])   # 元に戻す
eq('元に戻した', [r['tsuki_gaku'] for r in repo.mokuhyo_list(con) if r['cd']=='11'][0], before)
con.close()

print()
print('=' * 64)
if SKIP:
    print('■ 元データが無く、計算できなかった項目 %d 件' % len(SKIP))
    for x in SKIP[:4]: print('   ', x)
    if len(SKIP) > 4: print('    …ほか %d 件' % (len(SKIP) - 4))
    print('   → 実データでの検収は  python 点検/kenshu.py <現行データのフォルダ>  で行えます。')
if NG:
    print('■ 現物の紙と違った項目 %d 件' % len(NG))
    for x in NG: print('   ', x)
    print('=' * 64)
    sys.exit(1)
print('■ 計算した数字は、すべて現物の紙と一致しました。')
print('=' * 64)


sys.exit(1 if NG else 0)
