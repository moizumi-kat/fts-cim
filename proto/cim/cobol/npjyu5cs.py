# -*- coding: utf-8 -*-
"""NPJYU5CS  営業日報（Ａ）照会 の表示（NPJYU5CS.COB 1,962行 の HYOJI-RTN 移植）

現行の動き（行1424-1527  HYOJI-RTN）
    入力  NIPSYOL2 営業日報マスタ（順次／出力順）  ← 物理 NIPSYOFP
          JURITUL1 当月受注率ファイル（ランダム）  ← 物理 JURITUFP

  ・当日受注 ＝ 受注実績額 － 受注当日累計                     … 行1428-1429
  ・営業所コードが "99" の行は総合計行として別扱い             … 行1431-1433
  ・受注対比（達成率）
        COMPUTE WK-RITU ROUNDED = (受注実績額 / 受注目標額) * 100
        WK-RITU は PIC S9(09)V99  → 小数2位で四捨五入          … 行1471-1472
        MOVE WK-RITU TO 画面－受注対比 → 小数1位で切り捨て
    拠点行は 目標≠0 **かつ** 実績≠0 のときだけ計算            … 行1469-1474
    総合計行は 目標≠0 **または** 実績≠0 のときに計算          … 行1508-1511
  ・受注率は受注率ファイルを引くだけ。無ければ 0               … 行1477-1480 / 1515-1518
  ・営業所コードの1桁目が "9" の行は本部計。色を変えて1行空ける … 行1482-1491
  ・総合計行は 2行あけて表示し、生産実績額もこの行から         … 行1500-1506
  ・画面の「現在」日付＝全レコードの最終更新日の **最大**      … 行1437-1456（2023.3.27 改訂）
  ・拠点行は14行まで                                           … 行1449-1451

**計はここで足していません。** 本部計・総合計も営業日報マスタに入っている
レコードです（作るのは NPHEN5CF＝日次バッチ）。現行と同じく、読んで並べるだけです。
"""
from .arith import trunc, rounded, div, f

def _taihi(jisseki, mokuhyo, sogo=False):
    """受注対比（達成率）。行1469-1474／1508-1511。

    ■ 現行ソースの記述（NPJYU4CS.COB 行1004／NPJYU5CS.COB 行1471。**両者は同一**）

        COMPUTE  WK-RITU ROUNDED = (営業－受注実績額 / 営業－受注目標額) * 100
        MOVE     WK-RITU      TO  画面－受注対比 (IDX)
        WK-RITU  PIC S9(09)V99

    ■ 現物の紙との突き合わせでわかったこと
      そのまま（丸め誤差なしで）計算して ROUNDED すると、
      システム事業部は 1,175 ÷ 28,000 × 100 ＝ 4.19642… → 4.20 → **4.2**。
      しかし現物の紙は **4.1** でした（村上様ご確認済み）。
      これは、割り算の**途中の結果が桁で打ち切られてから**100倍されているためです
      （COBOLの中間結果の桁はコンパイラ依存）。
      打ち切って1桁に詰めると、紙の11行すべてが一致します。
      そのため、**紙の出かたに合わせて切り捨て**で実装しています。
    """
    if sogo:
        if not mokuhyo and not jisseki: return None     # OR 条件 … 行1508-1509
    else:
        if not mokuhyo or not jisseki:  return None     # AND 条件 … 行1469-1470
    if not mokuhyo: return None                          # 0 除算よけ
    return f(trunc(div(jisseki, mokuhyo) * 100, 1))      # 画面－受注対比（小数1桁・切り捨て）

def hyoji(nip, ritu):
    """営業日報マスタの並び（出力順）と受注率ファイルから、画面の行を作る。

    nip  … 営業日報マスタのレコード（出力順に並んだもの）
    ritu … 部所コード → 受注率
    """
    rows, sogo, genzai = [], None, 0
    idx = 0
    for n in nip:
        cd = (n['EGCODE'] or '').strip()
        tojitu = (n['EGJJIT'] or 0) - (n['JYURUI'] or 0)        # 行1428-1429
        if (n['EGKOSN'] or 0) > genzai:                          # 行1437-1456
            genzai = n['EGKOSN'] or 0
        r = {'cd': cd, 'nm': n['EGNAME'], 'mokuhyo': n['EGJMOK'],
             'jutyu': n['EGJJIT'], 'syutsuzu': n['EGSJIT'],
             'uriage': n['EGUJIT'], 'tou_jutyu': tojitu,
             'ritsu': ritu.get(cd, 0.0)}
        if cd == '99':                                           # 行1431-1433 → HYOJI200
            r['tassei'] = _taihi(n['EGJJIT'], n['EGJMOK'], sogo=True)
            r['kind'] = 'sogo'
            r['seisan'] = n['EGTJIT']                            # 生産実績額 … 行1505
            sogo = r
            continue
        idx += 1
        if idx > 14:                                             # 行1449-1451
            break
        r['tassei'] = _taihi(n['EGJJIT'], n['EGJMOK'])
        r['kind'] = 'bu' if cd[:1] == '9' else 'kyoten'          # 行1482
        if r['kind'] == 'bu':
            idx += 1                                             # 1行あける … 行1490
        rows.append(r)
    return {'rows': rows, 'sogo': sogo, 'genzai': genzai}
