# -*- coding: utf-8 -*-
"""DATA DIVISION（レコードの形）を読む。

  ■ なにを読むか
      01/03/05/77 … 階層。01 と 77 が一番上
      PIC X(n)   … 英数 n バイト
      PIC N(n)   … 全角 n 文字＝2n バイト
      PIC 9(n)   … 数 n 桁。V で小数点、S で符号
      COMP-3     … パック10進 (桁+2)÷2 バイト
      COMP / COMP-4 / BINARY … 2進（桁で 2/4/8 バイト）
      OCCURS n   … 繰返し
      REDEFINES  … 同じ場所を別の名前で見る
      VALUE      … 初期値
      FILLER     … 名前なし（場所だけ取る）
      88         … 条件名（値の別名。場所は取らない）

  ■ なぜバイトで持つか
    REDEFINES と 集団項目への MOVE を**現行どおり**にするには、
    項目を「バイトの並びの上の位置と長さ」として持つしかない。
    （桁あふれの切れかたまで合わせるため。CLAUDE.md の「同じ結果」）
"""
import re

SUU = re.compile(r'^(S?)(9+|9\((\d+)\))(V(9+|9\((\d+)\))?)?$', re.I)


class Ko:
    """項目ひとつ。"""

    def __init__(self, level, na):
        self.level = level
        self.na = na
        self.pic = None
        self.kata = None          # 'X' 英数 / 'N' 全角 / '9' 数 / None 集団
        self.keta = 0             # 数の整数部＋小数部の桁数、文字なら文字数
        self.shou = 0             # 小数の桁数
        self.fugo = False         # S
        self.comp = None          # None=表示形 / '3'=パック / '4'=2進
        self.occurs = 0
        self.redefines = None
        self.value = None
        self.ko = []
        self.oya = None
        self.ichi = 0             # 先頭からのバイト位置
        self.naga = 0             # バイト数（繰返し1回ぶん）

    def __repr__(self):
        return '<%02d %s %s %d@%d>' % (self.level, self.na, self.pic or '集団',
                                       self.naga, self.ichi)

    # ── 大きさ ────────────────────────────────
    def hitotsu_naga(self):
        """繰返し1回ぶんのバイト数。"""
        if self.ko:
            n = 0
            for k in self.ko:
                if k.level == 88 or k.redefines:
                    continue
                n += k.naga * max(1, k.occurs)
            return n
        if self.kata == 'N':
            return self.keta * 2
        if self.kata == 'X':
            return self.keta
        if self.kata == '9':
            if self.comp == '3':
                return (self.keta + 2) // 2
            if self.comp == '4':
                return 2 if self.keta <= 4 else (4 if self.keta <= 9 else 8)
            return self.keta
        return 0

    def mina(self):
        yield self
        for k in self.ko:
            yield from k.mina()


def _pic(ko, s):
    """PIC の中身を読む。"""
    ko.pic = s
    u = s.upper()
    m = re.match(r'^X+$|^X\((\d+)\)$', u)
    if m:
        ko.kata = 'X'; ko.keta = int(m.group(1)) if m.group(1) else len(u)
        return
    m = re.match(r'^N+$|^N\((\d+)\)$', u)
    if m:
        ko.kata = 'N'; ko.keta = int(m.group(1)) if m.group(1) else len(u)
        return
    m = SUU.match(u)
    if m:
        ko.kata = '9'
        ko.fugo = bool(m.group(1))
        sei = int(m.group(3)) if m.group(3) else len(m.group(2))
        sho = 0
        if m.group(4):
            g = m.group(5) or ''
            sho = int(m.group(6)) if m.group(6) else len(g)
        ko.keta = sei + sho
        ko.shou = sho
        return
    # Z や , の入った編集用（帳票の見出しなど）。桁だけ数える
    n = len(re.sub(r'[^9Z0*$,./+-]', '', u))
    ko.kata = 'X'; ko.keta = max(1, n)


def yomu(go, hajime, owari):
    """語の並び（go[hajime:owari]）から、01 の並びを組み立てる。"""
    i = hajime
    ne = []          # 一番上（01・77）の並び
    tsumi = []       # いま開いている階層
    while i < owari:
        g = go[i]
        if not (g.shu == 'su' and re.fullmatch(r'\d{1,2}', g.v)):
            i += 1; continue
        level = int(g.v)
        if level not in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 20, 25,
                         30, 49, 66, 77, 88):
            i += 1; continue
        i += 1
        if i >= owari:
            break
        na = go[i].v if go[i].shu == 'na' else 'FILLER'
        if go[i].shu == 'na':
            i += 1
        ko = Ko(level, na)
        # 句を読む（次の . まで）
        while i < owari and not (go[i].shu == 'ki' and go[i].v == '.'):
            t = go[i]
            if t.na('PIC', 'PICTURE'):
                i += 1
                if i < owari and go[i].na('IS'):
                    i += 1
                s = go[i].v
                # X(10) のように括弧が別の語になることがある
                if i + 1 < owari and go[i+1].shu == 'ki' and go[i+1].v == '(':
                    s += '(' + go[i+2].v + ')'
                    i += 3
                _pic(ko, s)
            elif t.na('OCCURS'):
                i += 1
                ko.occurs = int(re.sub(r'\D', '', go[i].v) or 1)
            elif t.na('REDEFINES'):
                i += 1
                ko.redefines = go[i].v
            elif t.na('VALUE', 'VALUES'):
                i += 1
                if i < owari and go[i].na('IS', 'ARE'):
                    i += 1
                ko.value = go[i].v if go[i].shu != 'na' else go[i].v.upper()
            elif t.na('COMP-3', 'COMPUTATIONAL-3', 'PACKED-DECIMAL'):
                ko.comp = '3'
            elif t.na('COMP', 'COMP-4', 'COMP-5', 'BINARY',
                      'COMPUTATIONAL', 'COMPUTATIONAL-4'):
                ko.comp = '4'
            i += 1
        i += 1          # . をとばす
        if level in (1, 77):
            tsumi = [ko]; ne.append(ko)
        else:
            while tsumi and tsumi[-1].level >= level:
                tsumi.pop()
            if not tsumi:
                ne.append(ko); tsumi = [ko]; continue
            ko.oya = tsumi[-1]
            tsumi[-1].ko.append(ko)
            tsumi.append(ko)
    for k in ne:
        _ookisa(k)
        _ichi(k, 0)
    return ne


def _ookisa(k):
    for c in k.ko:
        _ookisa(c)
    k.naga = k.hitotsu_naga()


def _ichi(k, ichi):
    k.ichi = ichi
    p = ichi
    mae = {}
    for c in k.ko:
        if c.level == 88:
            c.ichi = p; continue
        if c.redefines:
            c.ichi = mae.get(c.redefines, p)
        else:
            c.ichi = p
            p += c.naga * max(1, c.occurs)
        mae[c.na] = c.ichi
        _ichi(c, c.ichi)
