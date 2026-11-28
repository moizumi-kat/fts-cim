# -*- coding: utf-8 -*-
"""JUHEN2CD  当月受注率データの内容をクリアする（JUHEN2CD.COB の移植）

現行では JUHEN2CF の**直前の別プログラム**として動きます。
    PEGNIP01.CL  STEP38: CALL JUHEN2CD   ← ここ
                 STEP39: CALL JUHEN2CF

  主処理０１０（順次に読んで1件ずつ DELETE）
      READ    受注率ファイル   AT END → 終了
      DELETE  受注率ファイル
  ＝ レコードを残さず全件削除します（0クリアではありません）。
"""

def run(con, q, ex):
    n = q(con, 'SELECT COUNT(*) AS n FROM JURITUFP')[0]['n']
    ex(con, 'DELETE FROM JURITUFP')      # 主処理０１０ の DELETE に相当
    con.commit()
    return n
