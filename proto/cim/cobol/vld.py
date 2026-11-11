# -*- coding: utf-8 -*-
"""画面（ＶＬＤ）の実行時部品。現行の ASP 画面ファイルのふるまいを写す。

  ■ 現行の作り（A10040PO.COB で実測）
      画面出力Ｒ   MOVE "GRPALL" TO DSP-GROUP / MOVE SPACE TO DSP-MODE
                   WRITE DSP-REC FROM A10040D1 / DSP-STATUS が "00" 以外なら ABEND
      画面入力Ｒ   CALL "XMROTSTR" / MOVE SAVE-GROUP TO DSP-GROUP
                   MOVE READ-MODE TO DSP-MODE / READ 画面ファイル INTO A10040D1
                   DSP-STATUS が "00"・"04" なら正常、ほかは ABEND
      制御項目初期化Ｒ
                   全項目の EDIT-STATUS=" " EDIT-OPTION="M" EDIT-COLOR="M"
                             EDIT-MODE=" " EDIT-CURSOR=" "
      第ｎ項目群消去Ｒ
                   その群の項目に ZERO（数字）／SPACE（英数）を入れる

  ■ レコードの並び（.SMD で実測・A10080PO の手書き領域と15項目一致で裏取り済み）
      項目ごとに 「制御部5バイト ＋ データ」 が並ぶ。
      定義の「レコード内位置」はデータの開始位置で、その直前5バイトが制御部。
      制御部の5文字が EDIT-STATUS / OPTION / COLOR / MODE / CURSOR にあたる。

  ■ 画面そのものは端末が無いので、入出力は「操作役」に委ねる（差し替え可能）。
      操作役は kaku(rec: bytes) と yomu(group: str, mode: str) -> (bytes, status)
      を持てばよい。試験では Kioku（覚えておくだけ）を使う。
"""
import unicodedata

SEIJOU   = '00'          # DSP-STATUS 正常
NYURYOKU = '04'          # 入力あり（READ で正常扱い）

# 制御部5バイトの並び
SEIGYO = ('EDIT-STATUS', 'EDIT-OPTION', 'EDIT-COLOR', 'EDIT-MODE', 'EDIT-CURSOR')
# 制御項目初期化Ｒ が入れる値
HATSU = {'EDIT-STATUS': ' ', 'EDIT-OPTION': 'M', 'EDIT-COLOR': 'M',
         'EDIT-MODE': ' ', 'EDIT-CURSOR': ' '}


def _na(n):
    """Python は原文の全角英字を NFKC で詰めるので、属性名もそれに合わせる。
       （'端末ＩＤ' と書いたのに setattr では詰まらない、という取り違えを防ぐ）"""
    return unicodedata.normalize('NFKC', n)


class Koumoku:
    """画面の1項目。値と、制御部5バイトぶんの属性を持つ。

       **値はバイトで持つ。** COBOL の PIC X(40) は40**バイト**で、
       全角文字は1文字2バイトを占める（40文字ではなく20文字しか入らない）。
       文字数で詰めると、全角を入れたときに桁が合わなくなる。
    """

    __slots__ = ('gamen_na', 'na', 'gyo', 'keta', 'naga', 'naga2', 'ichi',
                 'kata', 'gun', 'data', 'zokusei')

    def __init__(self, t):
        (self.gamen_na, self.na, self.gyo, self.keta,
         self.naga, self.naga2, self.ichi, self.kata, self.gun) = t
        self.data = b' ' * self.naga2
        self.zokusei = dict(HATSU)

    @property
    def atai(self):
        """値を文字で見る（桁は詰めたまま）。"""
        return self.data.decode('cp932', 'replace')

    def kesu(self):
        """第ｎ項目群消去Ｒ の MOVE ZERO／SPACE。"""
        if self.kata == '9':
            self.data = b'0' * self.naga2
        elif self.kata == 'X':
            self.data = b' ' * self.naga2
        # 型が分からない項目（消去段落に出てこない）は触らない＝現行どおり

    def tsumeru(self, v):
        """COBOL の MOVE。数字は右詰めゼロ、英数は左詰め空白。**バイトで詰める。**"""
        if isinstance(v, bytes):
            b = v
        else:
            s = '' if v is None else str(v)
            if self.kata == '9':
                s = ''.join(c for c in s if c.isdigit()) or '0'
            b = s.encode('cp932', 'replace')
        if self.kata == '9':
            self.data = b[-self.naga2:].rjust(self.naga2, b'0')
        else:
            self.data = _kiru(b, self.naga2).ljust(self.naga2)

    def __repr__(self):
        return '<%s %s=%r>' % (self.gamen_na, self.na, self.atai)


def _kiru(b, n):
    """n バイトに切る。全角の途中で切れないようにする。"""
    if len(b) <= n:
        return b
    b = b[:n]
    # cp932 の2バイト目で切れていないか確かめる（切れていたら1バイト戻す）
    try:
        b.decode('cp932')
    except UnicodeDecodeError:
        b = b[:-1]
    return b


class Gamen:
    """画面レコード1枚。"""

    def __init__(self, teigi, sousa=None):
        self.na = teigi.GAMEN
        self.nagasa = teigi.NAGASA
        self.ko = [Koumoku(t) for t in teigi.KOUMOKU]
        self.byna = {_na(k.na): k for k in self.ko}
        self.sousa = sousa
        self.status = SEIJOU

    # ── 項目の出し入れ ──────────────────────────────
    def __getitem__(self, na):
        return self.byna[_na(na)]

    def atai(self, na):
        return self.byna[_na(na)].atai

    def ireru(self, na, v):
        self.byna[_na(na)].tsumeru(v)

    def zoku(self, na, shurui, v):
        """MOVE "X" TO EDIT-STATUS OF 〇〇 にあたる。"""
        self.byna[_na(na)].zokusei[shurui] = v

    # ── 現行の段落に対応する操作 ───────────────────
    def seigyo_shokika(self):
        """制御項目初期化Ｒ。全項目の属性を初期値へ戻す。"""
        for k in self.ko:
            k.zokusei = dict(HATSU)

    def gun_shoukyo(self, n):
        """第ｎ項目群消去Ｒ。"""
        for k in self.ko:
            if k.gun == n:
                k.kesu()

    def gun_no_ko(self, group):
        """DSP-GROUP が指す項目。GRPALL は全部。GRPAnn は第nn群。"""
        if group.upper().endswith('ALL'):
            return list(self.ko)
        n = int(group[-2:])
        return [k for k in self.ko if k.gun == n]

    # ── レコードの組み立て・取り出し ───────────────
    def rec(self):
        """DSP-REC を作る（制御部5バイト＋データ が項目ごとに並ぶ）。"""
        b = bytearray(b' ' * self.nagasa)
        for k in self.ko:
            s = k.ichi - len(SEIGYO)
            for i, shurui in enumerate(SEIGYO):
                b[s + i] = ord(k.zokusei[shurui])
            b[k.ichi:k.ichi + k.naga2] = k.data.ljust(k.naga2)[:k.naga2]
        return bytes(b)

    def rec_ireru(self, b):
        """READ で返ってきた DSP-REC を項目へ配る。"""
        for k in self.ko:
            s = k.ichi - len(SEIGYO)
            for i, shurui in enumerate(SEIGYO):
                k.zokusei[shurui] = chr(b[s + i])
            k.data = bytes(b[k.ichi:k.ichi + k.naga2])

    # ── 画面出力Ｒ／画面入力Ｒ ──────────────────────
    def kaku(self, group='GRPALL'):
        """画面出力Ｒ。DSP-STATUS を返す。"""
        self.status = SEIJOU
        if self.sousa is not None:
            self.status = self.sousa.kaku(self.rec(), group) or SEIJOU
        return self.status

    def yomu(self, group, mode=' '):
        """画面入力Ｒ。DSP-STATUS を返す（"00"・"04" が正常）。"""
        if self.sousa is None:
            self.status = SEIJOU
            return self.status
        b, st = self.sousa.yomu(group, mode)
        if b is not None:
            self.rec_ireru(b)
        self.status = st or SEIJOU
        return self.status


class Kioku:
    """試験用の操作役。書いたものを覚えておき、読みでは仕込んだ値を返す。"""

    def __init__(self):
        self.kaita = []          # 書かれたレコード
        self.yomaseru = []       # 読みで返すレコードを積んでおく

    def kaku(self, rec, group):
        self.kaita.append((group, rec))
        return SEIJOU

    def yomu(self, group, mode):
        if self.yomaseru:
            return self.yomaseru.pop(0), NYURYOKU
        return None, SEIJOU
