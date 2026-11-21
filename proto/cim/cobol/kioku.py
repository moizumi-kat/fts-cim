# -*- coding: utf-8 -*-
"""COBOL の記憶域（01 のレコード）を、そのとおりに持つ。

  ■ なぜバイトで持つか
    REDEFINES（同じ場所を別の名前で見る）と、集団項目への MOVE を
    現行どおりにするには、項目を「バイトの並びの上の位置と長さ」として
    持つしかない。桁あふれの切れかたまで合わせるため。
      例 A10040PO の PGM-STATUS 9(004) を PGM-STS X(004) が REDEFINES する。
         数として入れて文字として取り出す、という使われ方をしている。

  ■ 文字の入れかた（COBOL の MOVE）
      英数（X）… 左詰め・右は空白で埋める・はみ出したら右を切る
      全角（N）… 同じ。ただし1文字2バイト
      数  （9）… 右詰め・左は0で埋める・はみ出したら左を切る
    小数は**小数点を持たない**。桁で表す（9(3)V9(1) の 12.3 は "0123"）。

  ■ 数の入りかた
      表示形（既定）… ゾーン10進。1桁1バイト
      COMP-3         … パック10進 (桁+2)÷2 バイト。最後の半バイトが符号
      COMP           … 2進。桁で 2/4/8 バイト
"""
from decimal import Decimal

KUUHAKU = 0x20


class Komoku:
    """記憶域の中の1項目。位置と長さと型だけを持ち、値は領域（Ryoiki）側にある。"""

    __slots__ = ('na', 'ichi', 'naga', 'kata', 'keta', 'shou', 'fugo',
                 'comp', 'occurs', 'ko')

    def __init__(self, na, ichi, naga, kata=None, keta=0, shou=0,
                 fugo=False, comp=None, occurs=0):
        self.na, self.ichi, self.naga = na, ichi, naga
        self.kata, self.keta, self.shou = kata, keta, shou
        self.fugo, self.comp, self.occurs = fugo, comp, occurs
        self.ko = []


class Ryoiki:
    """01 のレコード1つ。バイトの並びと、その上の項目表を持つ。"""

    def __init__(self, naga, hyo):
        self.b = bytearray(b' ' * naga)
        self.hyo = hyo                      # {名前: Komoku}

    # ── 生のバイト ──────────────────────────────
    def nama(self, k, kai=0):
        i = k.ichi + k.naga * kai
        return bytes(self.b[i:i + k.naga])

    def nama_ireru(self, k, v, kai=0):
        i = k.ichi + k.naga * kai
        v = (v + b' ' * k.naga)[:k.naga]
        self.b[i:i + k.naga] = v

    # ── 値として ────────────────────────────────
    def toru(self, na, kai=0):
        k = self.hyo[na]
        b = self.nama(k, kai)
        if k.kata == '9':
            return self._kazu(k, b)
        if k.kata == 'N':
            return b.decode('cp932', 'replace')
        return b.decode('cp932', 'replace')

    def ireru(self, na, v, kai=0):
        k = self.hyo[na]
        if k.kata == '9':
            self.nama_ireru(k, self._kazu_byte(k, v), kai)
        elif v is None:
            self.nama_ireru(k, b'', kai)
        elif isinstance(v, (bytes, bytearray)):
            self.nama_ireru(k, bytes(v), kai)
        else:
            self.nama_ireru(k, str(v).encode('cp932', 'replace'), kai)

    # ── 数の出し入れ ────────────────────────────
    def _kazu(self, k, b):
        if k.comp == '3':
            ke = []
            for c in b:
                ke.append(c >> 4); ke.append(c & 0x0F)
            fu = ke.pop()
            s = ''.join(str(x if x < 10 else 0) for x in ke)
            mainasu = (fu == 0x0D)
        elif k.comp == '4':
            n = int.from_bytes(b, 'big', signed=k.fugo)
            s = str(abs(n)); mainasu = n < 0
        else:
            s = ''.join(chr(c) if 0x30 <= c <= 0x39 else '0' for c in b)
            mainasu = False
        if not s:
            s = '0'
        d = Decimal(s)
        if k.shou:
            d = d.scaleb(-k.shou)
        return -d if mainasu else d

    def _kazu_byte(self, k, v):
        if v is None:
            v = 0
        if isinstance(v, (bytes, bytearray)):
            v = v.decode('cp932', 'replace')
        if isinstance(v, str):
            s = ''.join(c for c in v if c.isdigit() or c in '.-') or '0'
            v = Decimal(s)
        d = Decimal(v)
        mainasu = d < 0
        d = abs(d)
        if k.shou:
            d = d.scaleb(k.shou)
        s = str(int(d))                      # はみ出す小数は切り捨て（COBOLと同じ）
        s = s[-k.keta:].rjust(k.keta, '0')   # 左があふれたら切る
        if k.comp == '3':
            n = (k.keta + 2) // 2
            ke = list(s)
            if len(ke) % 2 == 0:
                ke.insert(0, '0')
            fu = 'D' if (mainasu and k.fugo) else 'C' if k.fugo else 'F'
            return bytes.fromhex(''.join(ke) + fu)
        if k.comp == '4':
            n = 2 if k.keta <= 4 else (4 if k.keta <= 9 else 8)
            return (-int(s) if mainasu else int(s)).to_bytes(n, 'big', signed=k.fugo)
        return s.encode('ascii')
