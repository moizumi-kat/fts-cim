# -*- coding: utf-8 -*-
"""JUHEN2CF  当月受注率ファイル作成（JUHEN2CF.COB 605行 の移植）

現行の動き
    入力  KRIRIKL1 集約履歴ファイル（順次）     ← 物理 KRIRIKFP
          SYOGAIL1 受注率計算対象外ファイル     ← 物理 SYOGAIFP
          AJUGFL1  受注ファイル鑑（OPENするが使っていない／行73-79）
    出力  JURITUL1 当月受注率ファイル（I-O）    ← 物理 JURITUFP

    主処理０１０〜０３０（行199-305）
      ・新規増減区分が "1"（新規）でないレコードは読み飛ばす        … 行202-204
      ・製番が対象外ファイルにあれば読み飛ばす                      … 行206-209
      ・受注金額＝受注金額(1)+(2)+(3)+(4)                            … 行213-217
      ・標準原価＝標準原価(1)+(2)+(3)+(4)                            … 行219-223
      ・部所（集約部所コード）の行に加算し、受注率を計算             … 行225-240
      ・本部計の行＝ "9" ＋ 集約部所コードの1桁目                    … 行348-350
      ・総合計の行＝ "99"                                            … 行462
      受注率  WK-JYURITU = 受注予定金額 ÷ 標準原価    PIC S9(05)V9999 → 小数4位で切り捨て
              率－受注率 = WK-JYURITU × 100          PIC S9(03)V9(01) → 小数1位で切り捨て
"""
from .arith import trunc, div, f

def _ritsu(kin, gen):
    """受注率。現行の2段階の桁詰めをそのまま再現する（行232-240）。

        COMPUTE WK-JYURITU = 率－受注予定金額 / 率－標準原価   ← S9(05)V9999
        COMPUTE 率－受注率 = WK-JYURITU * 100                  ← S9(03)V9(01)
    """
    if not kin or not gen:          # 行234-236 の ZERO チェック
        return 0.0
    wk = trunc(div(kin, gen), 4)    # WK-JYURITU は小数4桁
    return f(trunc(wk * 100, 1))    # 率－受注率 は小数1桁

def run(con, q, ex, ws_no='', date_area=None, time_area=None):
    """当月受注率ファイルを作る。戻り値＝作った行数。

    **ファイルのクリアはしません。** 現行では直前の別プログラム JUHEN2CD が
    全件削除します（PEGNIP01.CL STEP38→STEP39）。同じ順序で動かしてください。
        python batch.py pegnip01     ← JUHEN2CD → JUHEN2CF の順に動かします

    ws_no / date_area / time_area は現行の 率－作成端末／作成日／作成時間に
    入る値です（行243-246）。省くと実行時の日時になります。
    """
    import datetime as _dt
    now = _dt.datetime.now()
    if date_area is None: date_area = int(now.strftime('%Y%m%d'))
    if time_area is None: time_area = int(now.strftime('%H%M%S'))
    # 対象外ファイル（受注率計算対象外）… 行206-209
    taigai = {r['SEIBAN'] for r in q(con, 'SELECT SEIBAN FROM SYOGAIFP')}

    # 集約履歴ファイルを順次に読む … 行199-201
    rireki = q(con, """
      SELECT SEIBAN, SZKBN, SYUCOD,
             JUCYUK_1, JUCYUK_2, JUCYUK_3, JUCYUK_4,
             HYOGEN_1, HYOGEN_2, HYOGEN_3, HYOGEN_4
        FROM KRIRIKFP ORDER BY SEIBAN, HIZUKE, SZKBN""")

    # 率－当月受注率レコードを、部所コードごとに組み立てる
    ritu = {}                        # 部所コード → [受注予定金額, 標準原価, 件数]
    def add(cd, kin, gen):
        r = ritu.setdefault(cd, [0, 0, 0])
        r[0] += kin; r[1] += gen; r[2] += 1

    for k in rireki:
        if (k['SZKBN'] or '').strip() != '1':        # 新規のみ … 行202-204
            continue
        if (k['SEIBAN'] or '').strip() in taigai:    # 対象外は飛ばす … 行206-209
            continue
        busyo = (k['SYUCOD'] or '').strip()          # READ-BUSYO … 行211
        kin = sum(k['JUCYUK_%d' % i] or 0 for i in (1, 2, 3, 4))   # 行213-217
        gen = sum(k['HYOGEN_%d' % i] or 0 for i in (1, 2, 3, 4))   # 行219-223
        add(busyo, kin, gen)                                        # 行225-231
        if busyo:                                                   # 本部計 … 行348-356
            add('9' + busyo[:1], kin, gen)
        add('99', kin, gen)                                         # 総合計 … 行462

    # 既にある行には足しこみ、無ければ新しく書く（行225-231／主処理０３０）
    nokori = {(r['BUMON'] or '').strip(): r
              for r in q(con, 'SELECT BUMON,JUKING,HYOGEN,KENSU FROM JURITUFP')}
    for cd, (kin, gen, ken) in sorted(ritu.items()):
        old = nokori.get(cd)
        if old:                                   # READ できた → ADD して REWRITE
            kin += old['JUKING'] or 0
            gen += old['HYOGEN'] or 0
            ken += old['KENSU'] or 0
            ex(con, 'UPDATE JURITUFP SET JUKING=?,HYOGEN=?,KENSU=?,JYURIT=?,'
                    'CRTDAT=?,CRTTIM=?,CRTWS=? WHERE BUMON=?',
               (kin, gen, ken, _ritsu(kin, gen), date_area, time_area, ws_no, cd))
        else:                                     # INVALID → INITIALIZE して WRITE
            ex(con, 'INSERT INTO JURITUFP(BUMON,JUKING,HYOGEN,KENSU,JYURIT,'
                    'CRTDAT,CRTTIM,CRTWS) VALUES(?,?,?,?,?,?,?,?)',
               (cd, kin, gen, ken, _ritsu(kin, gen), date_area, time_area, ws_no))
    con.commit()
    return len(ritu)
