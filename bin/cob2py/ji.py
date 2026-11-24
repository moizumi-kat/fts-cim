# -*- coding: utf-8 -*-
"""COBOL の原文を「語」に割る。

  ■ 桁の決まり（この会社の原文で実測。README 2.45）
      line[0]      標識欄（* / D d はコメント・デバッグ行。- は前の行のつづき）
      line[1:67]   本文
    **順番号欄は無い。** line[6:72] で切ると CONFIGURATION が GURATION になる。

  ■ 語の種類
      'na'   名前・予約語（A-Z 0-9 - # @ $ と全角）
      'su'   数（123 / 1.5 / -3）
      'mo'   文字の直定数（'...' "..."）。NC"..." は全角の直定数
      'ki'   記号（. ( ) , = > < >= <= + - * / **）
"""
import re

KIGOU = ['**', '>=', '<=', '<>', '=', '>', '<', '+', '-', '*', '/', '(', ')', ',', '.', ';', ':']
_NA = re.compile(r'[^\x00-\x20\'"().,;:=<>+*/]+')


class Go:
    """語ひとつ。keta は本文の中の桁（0起点）。

       ■ 桁がなぜ要るか（2026-11-21）
         COBOL は「A領域（本文の0-3桁）に書いたものが見出し」という決まり。
         これを見ないと、文の終わりの `MOVE "INT" TO END-FLG.` の END-FLG を
         段落の見出しと取り違える（実際に取り違えた）。
    """
    __slots__ = ('shu', 'v', 'gyo', 'keta')

    def __init__(self, shu, v, gyo, keta=99):
        self.shu, self.v, self.gyo, self.keta = shu, v, gyo, keta

    def __repr__(self):
        return '%s:%r' % (self.shu, self.v)

    def na(self, *v):
        """この語が、与えた名前（予約語）のどれかか。大小文字は見ない。"""
        return self.shu == 'na' and self.v.upper() in v


def honbun(text):
    """原文 → [(原文の行番号, 本文)]。コメント・デバッグ行は落とす。"""
    out = []
    for i, ln in enumerate(text.splitlines(), 1):
        ln = ln.rstrip('\r\n')
        if not ln:
            continue
        hyoshiki = ln[0]
        if hyoshiki in ('*', '/', 'D', 'd'):
            continue
        b = ln[1:67]
        if b.strip():
            out.append((i, b, hyoshiki))
    return out


def waru(text):
    """原文 → 語の並び。"""
    go = []
    for gyo, b, hyoshiki in honbun(text):
        i, n = 0, len(b)
        while i < n:
            c = b[i]
            if c in ' \t':
                i += 1; continue
            # *> から行末までは行内コメント（COBOL2002）。
            #   F10412PO に `= "1"  *>支払処理中` の形があり、
            #   * と > を演算子と取り違えていた（2026-11-21 実測）。
            if b.startswith('*>', i):
                break
            # 文字の直定数
            if c in '\'"':
                j = i + 1
                while j < n:
                    if b[j] == c:
                        if j + 1 < n and b[j+1] == c:
                            j += 2; continue
                        break
                    j += 1
                go.append(Go('mo', b[i+1:j].replace(c*2, c), gyo, i))
                i = j + 1; continue
            # 16進の直定数 X"28" / X'0027'（JEF のシフトコード等に使われる）
            #   `MOVE X"28" TO WK-HINMEIM` や `VALUE X"28"` の形（実測 208か所）。
            #   **バイトを1文字ずつに写す**（latin-1）。PIC X(01) VALUE X"28" のように
            #   桁とバイト数が合っていることが大事なので、長さが変わる変換はしない。
            if (c in 'Xx' and i + 1 < n and b[i+1] in '\'"'):
                q = b[i+1]
                j = b.find(q, i + 2)
                if j > 0:
                    h = b[i+2:j]
                    if re.fullmatch(r'[0-9A-Fa-f]*', h) and len(h) % 2 == 0:
                        go.append(Go('mo', bytes.fromhex(h).decode('latin-1'),
                                     gyo, i))
                        i = j + 1
                        continue
            # 全角の直定数 NC"..." / N"..."
            if c in 'Nn' and i + 1 < n and (b[i+1] in 'Cc' and i + 2 < n and b[i+2] in '\'"'
                                            or b[i+1] in '\'"'):
                k = i + 2 if b[i+1] in '\'"' else i + 3
                q = b[k-1]
                j = b.find(q, k)
                if j < 0:
                    j = n
                go.append(Go('mo', b[k:j], gyo, i))
                i = j + 1; continue
            # 記号（2文字のものを先に見る）
            kigou = None
            for k in KIGOU:
                if b.startswith(k, i):
                    kigou = k; break
            if kigou:
                # 123.45 の小数点、名前の中の - は記号にしない
                if kigou == '.' and i + 1 < n and b[i+1].isdigit() and go and go[-1].shu == 'su':
                    pass
                else:
                    go.append(Go('ki', kigou, gyo, i))
                    i += len(kigou); continue
            m = _NA.match(b, i)
            if not m:
                i += 1; continue
            w = m.group(0)
            owari_i = m.end()
            # 小数の直定数。名前は . を含まないので、**数のときだけ**つなぐ。
            #   `MOVE 1.00 TO …` の 1.00 が 1 と 00 に割れていた（2026-11-21）。
            #   逆に `１０－変更回数` のような**全角数字で始まる名前**を
            #   数と取り違えないよう、ASCII の数字だけを数とみなす。
            if re.fullmatch(r'[+-]?[0-9]+', w):
                m2 = re.match(r'\.[0-9]+', b[owari_i:])
                if m2:
                    w += m2.group(0)
                    owari_i += m2.end()
            if re.fullmatch(r'[+-]?[0-9]+(\.[0-9]+)?', w):
                go.append(Go('su', w, gyo, i))
            else:
                go.append(Go('na', w, gyo, i))
            i = owari_i
    return go
