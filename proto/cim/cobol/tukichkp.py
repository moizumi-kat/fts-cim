# -*- coding: utf-8 -*-
"""TUKICHKP  月度チェック（TUKICHKP.COB の移植）

当社は **20日締め**。10月度＝9月21日〜10月20日。
現行のソースにも、そのとおり書かれています。

    IF    IN-DAY   >  20
      THEN
          IF  IN-MONTH = 12  THEN  COMPUTE WK-MONTH = 1
                             ELSE  COMPUTE WK-MONTH = IN-MONTH + 1
      ELSE  MOVE IN-MONTH TO WK-MONTH
    IF    WK-MONTH  NOT = IN-GATUDO  → エラー（月度が合っていない）

呼ばれかた：PEGNIP01.CL の STEPC
    CALL TUKICHKO.YAMSLIB,PARA-(?EJKDAY,?SJKDAY)
      ?EJKDAY … 最終更新日（西暦8桁）  ?SJKDAY … 何月分の処理か（2桁）
"""

def gatudo(yyyymmdd):
    """日付（YYYYMMDD）が何月度に属するかを返す。21日以降は翌月度。"""
    n = int(yyyymmdd)
    in_month, in_day = n // 100 % 100, n % 100
    if in_day > 20:                                   # IF IN-DAY > 20
        return 1 if in_month == 12 else in_month + 1  # 12月なら1月
    return in_month                                   # ELSE そのまま

def check(yyyymmdd, shitei_gatudo):
    """月度チェック。合っていれば True、合っていなければ False（現行はエラー終了）。"""
    return gatudo(yyyymmdd) == int(shitei_gatudo)

def kikan(nendo, gatudo_no):
    """その月度の期間（開始日, 終了日）を YYYYMMDD で返す。

    月度 M の期間 ＝ (M-1)月21日 〜 M月20日。
    1月度は前年12月21日から。
    """
    y, m = int(nendo), int(gatudo_no)
    sm, sy = (12, y - 1) if m == 1 else (m - 1, y)
    return sy * 10000 + sm * 100 + 21, y * 10000 + m * 100 + 20
