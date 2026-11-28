# -*- coding: utf-8 -*-
"""COBOL の計算のしかたをそのまま再現する。

COBOL は計算結果を「受け取る項目の桁」に収めるときに、
  ・COMPUTE ... （ROUNDED なし） → **切り捨て**
  ・COMPUTE ... ROUNDED          → **四捨五入**
  ・MOVE                          → **切り捨て**
で詰めます。Python の丸めは銀行丸めなので、そのままでは合いません。
ここで COBOL と同じ詰めかたを用意します。
"""
from decimal import Decimal, ROUND_DOWN, ROUND_HALF_UP

def _d(v):
    if v is None: return Decimal(0)
    if isinstance(v, Decimal): return v
    return Decimal(str(v))

def trunc(v, scale):
    """小数第 scale 位で切り捨て（COMPUTE／MOVE の詰めかた）。"""
    q = Decimal(1).scaleb(-scale)
    return _d(v).quantize(q, rounding=ROUND_DOWN)

def rounded(v, scale):
    """小数第 scale 位で四捨五入（COMPUTE ... ROUNDED）。"""
    q = Decimal(1).scaleb(-scale)
    return _d(v).quantize(q, rounding=ROUND_HALF_UP)

def div(a, b):
    """COBOL の割り算。0 除算は 0（現行も ZERO チェックをしてから割る）。"""
    a, b = _d(a), _d(b)
    return Decimal(0) if b == 0 else a / b

def f(v):
    """画面に渡すため float に戻す。"""
    return float(v) if v is not None else None
