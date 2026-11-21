# -*- coding: utf-8 -*-
"""PROCEDURE DIVISION（手続き）を Python に直す。

  ■ 方針（茂泉様 2026-11-21 ご指示）
    「COBOLと同じ結果が出れば、書き方は今風にしてよい」
      ・段落の落ち込みと GO TO は、**節ごとの状態機械**にする
        （GO TO が無い節は、ふつうの一本道で出す）
      ・項目は名前で引く（self.V/self.S）。名前に - や全角が入るため
      ・写せない文は**黙って通さず**、その場で止める（未変換）

  ■ 出てくる文（857本・628,003行で実測した上位）
     MOVE 154,913／IF 42,440／PERFORM 29,628／GO TO 21,570／
     EVALUATE 7,403／ADD 17,376／COMPUTE 11,906／READ 6,004／
     OPEN・CLOSE 6,141／WRITE 1,713／REWRITE 694／START 809／
     DELETE 229／CALL 526／INITIALIZE 3,534／DISPLAY 6,855
    MULTIPLY・STRING・UNSTRING・SET・SEARCH・SORT・ALTER は **0回**。
"""
import re, unicodedata

HIKAKU = {'=': '==', '>': '>', '<': '<', '>=': '>=', '<=': '<=', '<>': '!='}
TEISU = {'ZERO': '0', 'ZEROS': '0', 'ZEROES': '0',
         'SPACE': 'SPACE', 'SPACES': 'SPACE',
         'HIGH-VALUE': 'TAKAI', 'HIGH-VALUES': 'TAKAI',
         'LOW-VALUE': 'HIKUI', 'LOW-VALUES': 'HIKUI',
         'ALL': None}
OWARI = ('END-IF', 'END-EVALUATE', 'END-PERFORM', 'END-READ', 'END-START',
         'END-WRITE', 'END-CALL', 'END-ADD', 'END-COMPUTE', 'END-DELETE',
         'ELSE', 'WHEN')
BUN = ('MOVE', 'IF', 'EVALUATE', 'PERFORM', 'GO', 'ADD', 'SUBTRACT', 'DIVIDE',
       'COMPUTE', 'READ', 'WRITE', 'REWRITE', 'DELETE', 'START', 'OPEN',
       'CLOSE', 'INITIALIZE', 'DISPLAY', 'ACCEPT', 'CALL', 'STOP', 'EXIT',
       'CONTINUE', 'INSPECT', 'SET', 'UNSTRING', 'STRING')


def na_py(s):
    """COBOL の名前 → Python で使える名前。

       全角の英数・かな・漢字はそのまま使える（Python は識別子を NFKC で
       詰めるため）。ただし全角アンダースコア U+FF3F は識別子に使えないので
       半角に直す（ここで一度つまずいた。2026-11-21）。
    """
    s = s.replace(chr(0xFF3F), '_')
    s = re.sub(r'[^0-9A-Za-z_\u3040-\u30ff\u4e00-\u9fff\uff10-\uff5a]',
               '_', s)
    s = s.replace(chr(0xFF3F), '_')
    # Python は識別子を定義のときに NFKC で詰める（第２→第2）。
    # getattr は詰めてくれないので、**こちらで先に詰めて**おく。
    # （詰めずに出して 'object has no attribute' になった。2026-11-21）
    s = unicodedata.normalize('NFKC', s)
    if s and s[0].isdigit():
        s = '_' + s
    return s or '_'


class Dan:
    """段落ひとつ。"""
    def __init__(self, na, setsu):
        self.na = na
        self.setsu = setsu
        self.go = []            # 語の並び
        self.goto = set()       # この段落から飛ぶ先


class Setsu:
    """節ひとつ（SECTION）。段落の並びを持つ。"""
    def __init__(self, na):
        self.na = na
        self.dan = []


def wakeru(go, hajime, owari):
    """手続きを 節／段落 に割る。SECTION の無い原文は1つの節にまとめる。"""
    setsu = []
    ima_s = Setsu('__honbun__')
    ima_d = Dan('__hajime__', ima_s)
    ima_s.dan.append(ima_d)
    setsu.append(ima_s)
    i = hajime
    bunto = True            # いま文の先頭か（直前が . なら先頭）
    while i < owari:
        g = go[i]
        # 見出しは **A領域（本文の0-3桁）に、文の先頭として** 現れる
        midashi = bunto and g.shu == 'na' and g.keta <= 3
        if (midashi and i + 2 < owari and go[i+1].na('SECTION')
                and go[i+2].shu == 'ki' and go[i+2].v == '.'):
            ima_s = Setsu(g.v); setsu.append(ima_s)
            ima_d = Dan(g.v + '－本体', ima_s); ima_s.dan.append(ima_d)
            i += 3; bunto = True; continue
        if (midashi and i + 1 < owari
                and go[i+1].shu == 'ki' and go[i+1].v == '.'
                and g.v.upper() not in BUN):
            ima_d = Dan(g.v, ima_s); ima_s.dan.append(ima_d)
            i += 2; bunto = True; continue
        bunto = (g.shu == 'ki' and g.v == '.')
        ima_d.go.append(g)
        if g.na('GO') and i + 1 < owari:
            j = i + 1
            if go[j].na('TO'):
                j += 1
            if j < owari and go[j].shu == 'na':
                ima_d.goto.add(go[j].v)
        i += 1
    return [s for s in setsu if any(d.go for d in s.dan)]
