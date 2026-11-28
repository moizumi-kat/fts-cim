# -*- coding: utf-8 -*-
"""業務の問合せ。画面はここだけを呼ぶ（SQLを画面に書かない）。

**テーブルも列名も現行システムのファイル定義そのものです**（村上様ご指示・2026-10-16）。
  列名は現行の COBOL 英名（英大文字）。読みやすいよう、行末に現行の日本語項目名を
  コメントで併記しています。

  NIPSYOFP 営業日報照会マスタ／JURITUFP 当月受注率ファイル／KRIRIKFP 集約履歴ファイル／
  URIZSYFP 日報売上出図ファイル／AJUGFP 受注ファイル鑑／AJUKFP 受注ファイル項目／
  AGEGFP 原価ファイル鑑／AGEKFP 原価ファイル項目／KETUTESF 検討決定ファイル／
  CJISFP 作業実績ファイル／ASOSMP 組織マスタ／ATORMP 取引先マスタ／
  KENTOUSF 物件検討ファイル／NOKIB4SF 納期物件管理ファイル４

画面に渡す名前（mokuhyo など）は SQL の AS で付けています。

■ 繰返し項目（OCCURS）の扱い
  現行の定義では、金額がレコード内で4回くりかえす項目があります。
  合計の取りかたは現行の COBOL で裏を取りました。
    ・KRIRIKFP 受注金額   JUCYUK_1〜4 の合計   （JUKAN1CF.COB / GENK11CS.COB）
    ・KRIRIKFP 増減受注   ZJUCYU_1〜4 の合計   （JUKAN1CF.COB）
    ・AGEGFP   受注予定金額 JYOTEI_1〜4 の合計 （GENKA4CP.COB / KENTOUNS.COB）
  AGEKFP の原価費目も4回くりかえしますが、
  1〜4 がそれぞれ何を指すかは **村上様のご確認待ち** です。
  GENKA4CP.COB に「限度額 格納」として (2) を使う箇所があることから、
  いまは (1)=総原価、(2)=実行予算 として扱っています（画面にも明記）。

集計の規則は、現物の紙と数字が一致することを確かめて決めています。
  ・各金額の「計」＝明細の単純合計
  ・達成率＝受注実績額 ÷ 受注目標額 ×100 の小数第2位切り捨て
  ・受注率＝受注予定金額 ÷ 標準原価 ×100。計は率を平均せず、金額と原価を足してから割る
    （JUHEN2CF.COB で確認）
"""
from .db import connect, q, q1, ex
from .cobol import npjyu5cs, juhen2cf, genka1cs, sinsyori, jhysyori

BUCALC = {'東北営業部': '91', '東京営業部': '92'}   # 本部計のコード
SOGO   = '99'                                      # 総合計のコード

# 4回くりかえす金額項目の合計を、SQL の式として組み立てる
def _sum4(col6, alias):
    """例) _sum4('JUCYUK','kin') → COALESCE(K.JUCYUK_1,0)+… AS kin"""
    tbl, nm = col6.split('.')
    return ('(' + '+'.join('COALESCE(%s.%s_%d,0)' % (tbl, nm, i) for i in (1, 2, 3, 4))
            + ') AS ' + alias)

# ---------------------------------------------------------------- 画面に出す形に直す
# ファイルが持っている形と、人が読む形は別です。現行の COBOL と同じ直しかたをします。
#   製番  ファイル 611071（X(06)）→ 画面 6-11071
#         B10100PP.COB … 製番(1:1) ＋ "-" ＋ 製番(2:5)
#   日付  ファイル 20261220（9(08)）→ 画面 26.12.20
#         B10100PP.COB … 9(08) の下6桁だけを印字
def key(seiban):
    """画面から来た 6-11071 を、ファイルの 611071 に直す。"""
    return str(seiban or '').replace('-', '').strip()

def sb(v):
    """ファイルの 611071 を、画面の 6-11071 に直す。"""
    v = str(v or '').strip()
    return (v[:1] + '-' + v[1:]) if len(v) >= 2 else v

def dt(v):
    """ファイルの 20261220 を、画面の 26.12.20 に直す。0 と空は空欄。"""
    if v in (None, ''): return ''
    try: n = int(v)
    except (TypeError, ValueError): return str(v)
    if n <= 0: return ''
    return '%2d.%2d.%2d' % (n // 10000 % 100, n // 100 % 100, n % 100)

def _shape(rows, seiban=(), hizuke=()):
    """行の中の製番・日付を、画面に出す形に直す。"""
    for r in ([rows] if isinstance(rows, dict) else (rows or [])):
        for k in seiban:
            if k in r: r[k] = sb(r[k])
        for k in hizuke:
            if k in r: r[k] = dt(r[k])
    return rows

def _rate(a, b):
    """a/b×100 を小数第1位まで切り捨て（COBOL の MOVE と同じ）。

    Decimal で計算します。SQL Server は numeric の列を Decimal で返すため、
    float の定数と混ぜると掛け算ができずに止まります（第9版の不具合）。
    """
    from .cobol.arith import div, trunc
    if not b: return trunc(0, 1)
    return trunc(div(a, b) * 100, 1)

def juritsu(yotei, genka, hikae=None):
    """受注率＝受注予定金額 ÷ 標準原価 ×100。金額が未投入なら控えの率を返す。"""
    if yotei and genka: return _rate(yotei, genka)
    return hikae

def asof(con):
    r = q1(con, "SELECT val FROM Z_ASOF WHERE key_nm='asof'")
    return r['val'] if r else ''

# ---------------------------------------------------------------- 営業日報
def nippou(con, _asof=None):
    """営業日報（Ａ）照会。表示のしかたは NPJYU5CS.COB のとおり。

    **ここで計を足していません。** 本部計・総合計も営業日報マスタのレコードです
    （作るのは日次バッチ NPHEN5CF）。現行と同じく、出力順に読んで並べるだけです。
    達成率と当日受注は NPJYU5CS.COB の式で計算し、受注率は受注率ファイルを引きます
    （受注率ファイルを作るのは JUHEN2CF。batch.py で動かせます）。
    """
    nip = q(con, """
      SELECT EGCODE, EGNAME, SYOZOK, JYUNCD, EGJMOK, EGJJIT,
             EGSJIT, EGUJIT, EGTJIT, JYURUI, EGKOSN
        FROM NIPSYOFP ORDER BY JYUNCD, EGCODE""")
    ritu = {(r['BUMON'] or '').strip(): r['JYURIT']
            for r in q(con, 'SELECT BUMON, JYURIT FROM JURITUFP')}
    d = npjyu5cs.hyoji(nip, ritu)

    # 画面は営業部ごとにまとめて出すので、本部計の行で区切る
    groups, cur = [], None
    for r in d['rows']:
        if cur is None:
            cur = {'nm': '', 'rows': [], 'total': None}; groups.append(cur)
        if r['kind'] == 'bu':
            cur['nm'] = r['nm']; cur['total'] = r; cur = None
        else:
            cur['rows'].append(r)
    groups = [g for g in groups if g['rows'] or g['total']]
    g = d['sogo'] or {}
    gz = d['genzai'] or 0
    asof = ('%d年%d月%d日現在' % (gz // 10000 % 100, gz // 100 % 100, gz % 100)) if gz else ''
    return {'asof': asof, 'groups': groups, 'grand': g,
            'seisan': g.get('seisan'),
            'keisan': any(r.get('ritsu') for r in d['rows'])}

def busyo_nm(con, cd):
    r = q1(con, 'SELECT BSYNAM AS nm FROM ASOSMP WHERE BSYOCD=?', (cd,))   # 部所名漢字
    return r['nm'] if r else cd

# ---------------------------------------------------------------- 日報内訳（3つの一覧）
def jutyu_list(con, busyo_cd, tsuki=None):
    """受注一覧＝集約履歴ファイル KRIRIKFP。新規(1)と増減(2)に分かれ、それぞれ小計。"""
    blocks = []
    for kubun in ('1', '2'):
        rs = q(con, """
          SELECT K.SEIBAN AS seiban,       -- 製番
                 T.TORNAR AS ukesaki,      -- 受注先（コード→取引略名）
                 K.KENMEI AS kenmei,       -- 件名
                 %s,
                 %s,
                 J.JRITU  AS ritsu,        -- 受注率（受注鑑）
                 K.NOUKI  AS nouki,        -- 納期
                 K.HAKKOD AS hakko,        -- 発行日
                 K.ZOGENR AS riyu          -- 増減理由
            FROM KRIRIKFP K
            LEFT JOIN AJUGFP J ON J.SEIBAN = K.SEIBAN
            LEFT JOIN ATORMP T ON T.TORICD = K.JUCYUS
           WHERE K.SYUCOD=? AND K.SZKBN=?  -- 集約部所コード／新規増減区分
           ORDER BY K.SEIBAN""" % (_sum4('K.JUCYUK', 'kin'),      # 受注金額(1〜4)
                                   _sum4('K.ZJUCYU', 'zogen')),   # 増減受注(1〜4)
          (busyo_cd, kubun))
        _shape(rs, seiban=('seiban',), hizuke=('nouki',))
        for r in rs:
            # 発行日は紙と同じく日だけを出す（現行も 9(08) の下2桁を印字している）
            r['hakko'] = (str(int(r['hakko']))[-2:].lstrip('0') if r['hakko'] else '')
            r['gaku'] = r['kin'] if kubun == '1' else r['zogen']
            r['han']  = '所' if kubun == '1' else ''
            if kubun == '2': r['ritsu'] = None
        blocks.append({'rows': rs, 'total': sum((r['gaku'] or 0) for r in rs)})
    return {'blocks': blocks, 'grand': sum(b['total'] for b in blocks)}

def _zu_list(con, kubun, busyo_cd):
    """出図／売上一覧＝日報売上出図ファイル URIZSYFP（売上出図区分 Z／U）。"""
    rs = q(con, """
      SELECT U.SEIBAN AS seiban,        -- 製番
             T.TORNAR AS ukesaki,       -- 取引略名
             J.KENMEI AS kenmei,        -- 件名
             J.JYOTEI AS jutyu_gaku,    -- 受注予定金額
             U.TJITGK AS tougetsu,      -- 当月実績額
             U.RJITGK AS zan,           -- 累積実績額
             U.SAISYU AS saishu_nouki   -- 最終納期
        FROM URIZSYFP U
        LEFT JOIN AJUGFP J ON J.SEIBAN = U.SEIBAN
        LEFT JOIN ATORMP T ON T.TORICD = J.JCYUCD     -- 取引先コード＝受注先コード
       WHERE U.UZKUBN=? AND U.BUSYOC=?                -- 売上出図区分／部所コード
       ORDER BY U.SEIBAN""", (kubun, busyo_cd))
    _shape(rs, seiban=('seiban',), hizuke=('saishu_nouki',))
    return {'rows': rs,
            'total': {k: sum((r[k] or 0) for r in rs) for k in ('jutyu_gaku','tougetsu','zan')}}

def syutsuzu_list(con, busyo_cd, tsuki=None): return _zu_list(con, 'Z', busyo_cd)
def uriage_list  (con, busyo_cd, tsuki=None): return _zu_list(con, 'U', busyo_cd)

# ---------------------------------------------------------------- 明細の各画面
def jutyuhyo(con, seiban):
    """受注票＝受注ファイル鑑 AJUGFP ＋ 受注ファイル項目 AJUKFP。"""
    h = q1(con, """
      SELECT J.SEIBAN AS seiban,       -- 製番
             J.JYOTEI AS jutyu_gaku,   -- 受注予定金額
             J.HAKKPD AS hakko_bi,     -- 発行日
             J.DENKBN AS denpyo_kubun, -- 伝票区分
             J.JRITU  AS ritsu,        -- 受注率
             J.TATAID AS tachiai,      -- 立会日
             J.LASTNK AS saishu_nouki, -- 最終納期
             J.KENMEI AS kenmei,       -- 件名
             J.SIYOU1 AS siyo1,        -- 仕様１
             J.SIYOU2 AS siyo2,        -- 仕様２
             J.SEDICD AS sesyu_dai,    -- 施主大分類コード
             J.MITUNO AS mitsumori_no, -- 見積ナンバー
             T.TORNAS AS ukesaki,      -- 取引名漢字
             E.RYAKU  AS sesyu_nm,     -- 施主大分類の名称（名称マスタ 漢字略称）
             S1.SIYONA AS siyo1_nm,    -- 仕様１の名称（仕様マスタ）
             S2.SIYONA AS siyo2_nm     -- 仕様２の名称（仕様マスタ）
        FROM AJUGFP J
        LEFT JOIN ATORMP T  ON T.TORICD = J.JCYUCD
        LEFT JOIN ANAMMP E  ON E.NAMKBN = '%s' AND E.NAMCD = J.SEDICD
        LEFT JOIN ASIYMP S1 ON S1.SIYOCD = J.SIYOU1
        LEFT JOIN ASIYMP S2 ON S2.SIYOCD = J.SIYOU2
       WHERE J.SEIBAN=?""" % jhysyori.NAMKBN_SESYU, (key(seiban),))
    if not h: return None
    _shape(h, seiban=('seiban',), hizuke=('hakko_bi', 'tachiai', 'saishu_nouki'))
    # 画面にはコードではなく名称を出す（JHYSYORI.COB 行396-455）
    h['denpyo_kubun'] = jhysyori.denpyo_kubun(h.get('denpyo_kubun'))
    for cd, nm in (('sesyu_dai','sesyu_nm'), ('siyo1','siyo1_nm'), ('siyo2','siyo2_nm')):
        if h.get(nm): h[cd] = h[nm]
    h['meisai'] = q(con, """
      SELECT JYUKOU AS gyo,     -- 受注項目
             SEIKBN AS hin,     -- 製品区分
             SEIMEI AS hinmei,  -- 製品名
             SURYO  AS suryo,   -- 数量
             TANICD AS tani,    -- 単位コード
             JYOTEI AS gaku     -- 受注予定金額
        FROM AJUKFP WHERE SEIBAN=? ORDER BY JYUKOU""", (key(seiban),))
    for r in h['meisai']:
        for k in ('kubun', 'komoku', 'zogen', 'sakide', 'kansei', 'syutsuzu', 'uriage'):
            r.setdefault(k, None)
        r['komoku'] = r['gyo']
    # 現行ファイルに該当する項目が見あたらないもの
    for k in ('torikeshi', 'tsuika', 'henko', 'sesyu', 'sekkeisaki', 'kensetsu',
              'meiban', 'siyo2', 'maker', 'tanto'):
        h.setdefault(k, None)
    h['machi'] = '取消・追加・変更・施主・設計先・建設業者・銘板名・担当者などは、'\
                 '現行のどの項目に当たるかがまだ特定できていません。'
    return h

def yosan(con, seiban):
    """製番別実行予算集計＝原価ファイル鑑 AGEGFP ＋ 原価ファイル項目 AGEKFP。

    費目の集計は GENKA1CS.COB の「限度額 格納」「実績額計算格納」の移植です
    （cim/cobol/genka1cs.py）。原価項目情報の 1〜4 は村上様ご回答のとおり
    (1)標準 (2)限度 (3)新規実績 (4)変更実績。
    画面の「総原価」＝(1)標準、「実行予算」＝(2)限度、「実績」＝(3)+(4)。
    """
    h = q1(con, """
      SELECT G.SEIBAN AS seiban,   -- 製番
             G.KENMEI AS kenmei,   -- 件名
             %s,
             J.JRITU  AS ritsu,    -- 受注率
             J.LASTNK AS nouki,    -- 最終納期
             S.SIYONA AS siyo,     -- 仕様１（コード→名称）
             T.TORNAR AS ukesaki   -- 取引略名
        FROM AGEGFP G
        LEFT JOIN AJUGFP J ON J.SEIBAN = G.SEIBAN
        LEFT JOIN ATORMP T ON T.TORICD = J.JCYUCD
        LEFT JOIN ASIYMP S ON S.SIYOCD = J.SIYOU1
       WHERE G.SEIBAN=?""" % _sum4('G.JYOTEI', 'jutyu_gaku'),   # 受注予定金額(1〜4)
        (key(seiban),))
    if not h: return None
    _shape(h, seiban=('seiban',), hizuke=('nouki',))
    rs = q(con, 'SELECT SEIBAN,KOMOKU,SEIKBN,DELFLG,%s FROM AGEKFP'
                ' WHERE SEIBAN=? ORDER BY KOMOKU'
                % ','.join(genka1cs.cols()), (key(seiban),))
    h['meisai'] = [{'komoku': m['komoku'],
                    'sougenka': m['hyojun'],    # (1) 標準
                    'jikkou':   m['gendo'],     # (2) 限度＝実行予算
                    'jisseki':  m['jisseki'],   # (3)+(4) 実績
                    'gaichu': None}
                   for m in genka1cs.meisai(rs)]
    h['mensu'] = []
    for k in ('tanto', 'yosan_sagaku', 'jisseki_sagaku'):
        h.setdefault(k, None)
    h['machi'] = '担当者・予算差額・実績差額・面数は、現行のどの項目に当たるかが'\
                 'まだ特定できていません。'
    return h

def has_bukken(con, seiban):
    """Ｇの分岐。物件検討ファイル KENTOUSF に該当製番があるか（COBOL と同じ判定）。"""
    return q1(con, 'SELECT SEIBAN FROM KENTOUSF WHERE SEIBAN=?', (key(seiban),)) is not None

KETU = [('主材費','HIYOU1'), ('補材費','HIYOU2'), ('鈑金費','HIYOU3'),
        ('塗装・亜鉛','HIYOU4'), ('組立費','HIYOU5'), ('製造間接費','HIYOU6'),
        ('設計費','HIYOU7'), ('運賃','HIYOU8'), ('製造原価','HIYOU9'),
        ('販売手数料','HIYOUA'), ('販売管理費','HIYOUB'), ('総原価','HIYOUC')]

def bukken(con, seiban):
    """検討物件照会＝検討決定ファイル KETUTESF ＋ 受注ファイル鑑 AJUGFP。"""
    cols = ','.join('K.%s' % c for _, c in KETU)
    h = q1(con, """
      SELECT K.SEIBAN AS seiban,      -- 製番
             K.KANRI1 AS kanri_no,    -- 管理番号１
             K.KENTOB AS kento_bi,    -- 検討日
             K.KANRI2 AS kanri2,      -- 管理番号２
             K.KANRI3 AS kanri3,      -- 管理番号３
             K.KETU01 AS kettei_txt,  -- 決定事項１
             K.KETU02 AS kettei_txt2, -- 決定事項２
             %s,
             J.KENMEI AS kenmei,      -- 件名
             J.LASTNK AS nouki,       -- 最終納期
             J.JYOTEI AS jutyu_gaku,  -- 受注予定金額
             J.JRITU  AS ritsu,       -- 受注率
             S.SIYONA AS siyo,        -- 仕様１（コード→名称）
             T.TORNAR AS ukesaki      -- 取引略名
        FROM KETUTESF K
        LEFT JOIN AJUGFP J ON J.SEIBAN = K.SEIBAN
        LEFT JOIN ATORMP T ON T.TORICD = J.JCYUCD
        LEFT JOIN ASIYMP S ON S.SIYOCD = J.SIYOU1
       WHERE K.SEIBAN=?""" % cols, (key(seiban),))
    if not h: return None
    _shape(h, seiban=('seiban',), hizuke=('kento_bi', 'nouki'))
    h['siyo'] = h.get('siyo') or ''      # 仕様が未設定なら空欄（None と出さない）
    # 管理番号は現行が1桁／2桁／4桁の3項目。紙と同じ並びに戻す
    h['kanri_no'] = ' - '.join(x for x in (h.get('kanri_no'), h.get('kanri2'),
                                           h.get('kanri3')) if x)
    # 決定事項は N(35)×6本。35文字を超えた分は2本目に入っている
    h['kettei_txt'] = (h.get('kettei_txt') or '') + (h.get('kettei_txt2') or '')
    h['meisai'] = [{'komoku': nm, 'sougenka': h.get(c), 'jikkou': None,
                    'kettei': None, 'jisseki': None} for nm, c in KETU]
    h['kettei'] = [{'bi': (h.get('kettei_txt') or '')[:8].strip(),
                    'gaku': '', 'ritsu': '', 'naiyo': h.get('kettei_txt') or ''}] \
                  if h.get('kettei_txt') else []
    h['mensu'] = ''
    for k in ('yosan_sagaku', 'syusoku_sagaku', 'hozai'):
        h.setdefault(k, None)
    h['machi'] = '予算差額・収束差額・補材費・面数・検討決定額の列は、現行のどの項目に'\
                 '当たるかがまだ特定できていません。'
    return h

def sinchoku(con, seiban):
    """営業用工程進捗＝作業実績ファイル CJISFP。表示は SINSYORI.COB のとおり。

    画面の11列に対応する作業コードは、現行プログラムに直接書かれています
    （1222/1220/1223/1402/1400/1403/1401/2000/2001/2400/2700）。
    日付は 完了実績日、無ければ 完了予定日 を「月.日」で出します。
    """
    rs = q(con, """
      SELECT KOMOKU, WORKCD, KJSKBI, KYOTEI
        FROM CJISFP WHERE SEIBAN=? ORDER BY KOMOKU""", (key(seiban),))
    if not rs: return None
    out = sinsyori.gyo(rs)
    for d in out:                       # 画面にあって現行に無い列は空欄
        for x in ('kansei_nouki', 'iro'):
            d.setdefault(x, '')
    return out

def uchiawase(con, seiban):
    """出図 打合せ決定内容＝納期物件管理ファイル４ NOKIB4SF。"""
    rs = q(con, """
      SELECT SAKINK AS sakide_nouki,    -- 先出納期
             KANNOK AS nouki,           -- 完成品納期
             JYOTAI AS jokyo,           -- 工程状況区分
             JYUKIN AS yotei_gaku,      -- 受注金額
             SYUTKA AS kettei_syukka,   -- 出荷予定日
             SYUTUZ AS kettei_syutsuzu  -- 出図予定日
        FROM NOKIB4SF WHERE SEIBAN=? ORDER BY OUTJUN""", (key(seiban),))
    # 日付は現行と同じく「年.月.日」で出す
    return _shape(rs, hizuke=('sakide_nouki', 'nouki', 'kettei_syukka', 'kettei_syutsuzu'))

def seiban_info(con, seiban):
    r = q1(con, 'SELECT SEIBAN AS seiban, KENMEI AS kenmei, BSYOCD AS busyo_cd'
                   ' FROM AJUGFP WHERE SEIBAN=?', (key(seiban),))
    return _shape(r, seiban=('seiban',)) if r else r

# ---------------------------------------------------------------- 目標メンテ
BUNAME = {1: '東北営業部', 2: '東京営業部'}   # 営業日報照会マスタの「営業部計」(9(02))

def mokuhyo_list(con, nendo=None):
    rows = q(con, """
      SELECT A.BSYOCD AS cd,            -- 部所コード
             A.BSYNAM AS nm,            -- 部所名漢字
             N.SYOZOK AS bu_no,         -- 営業部計
             N.JYUNCD AS seq,           -- 出力順
             N.EGJMOK AS tsuki_gaku,    -- 受注目標額（ひと月分）
             N.EGJMOK*12 AS nendo_gaku
        FROM ASOSMP A
        LEFT JOIN NIPSYOFP N ON N.EGCODE = A.BSYOCD
       WHERE A.TANCD='00'               -- 担当者係コード
       ORDER BY N.JYUNCD""")
    for r in rows:
        r['bu'] = BUNAME.get(int(r['bu_no'] or 0), '')
    return rows

def mokuhyo_save(con, nendo, pairs):
    """村上様 2026-10-13 ご回答（決定21）：
       年度分の目標金額を12ヶ月で割った「ひと月分」を、年度初めに一度だけ登録する。
       登録先は現行どおり 営業日報照会マスタ NIPSYOFP の受注目標額。"""
    n = 0
    for cd, nendo_gaku in pairs:
        con.execute('UPDATE NIPSYOFP SET EGJMOK=? WHERE EGCODE=?',
                    (int(nendo_gaku) // 12, cd))
        n += 1
    con.commit()
    return n
