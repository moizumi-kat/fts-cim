# -*- coding: utf-8 -*-
"""文を Python に直して書き出す。

   値の読み書きは self.V（取る）／self.S（入れる）に寄せる。
   COBOL の名前には - や全角が入り、同じ名前が別の領域にも出るため、
   Python の変数名に直さず**名前で引く**。
"""
import re
from .tetsuzuki import na_py, BUN

JOGAI = {'ZERO': '0', 'ZEROS': '0', 'ZEROES': '0',
         'SPACE': 'SPACE', 'SPACES': 'SPACE',
         'HIGH-VALUE': 'TAKAI', 'HIGH-VALUES': 'TAKAI',
         'LOW-VALUE': 'HIKUI', 'LOW-VALUES': 'HIKUI',
         'QUOTE': "'\"'", 'QUOTES': "'\"'"}
HIKAKU = {'=': '==', '>': '>', '<': '<', '>=': '>=', '<=': '<=', '<>': '!='}

# 文や値の並びを**そこで必ず終わらせる**語。
#   なぜ要るか（2026-11-21 実測）
#     これを見ずに値を読み続けると、`COMPUTE X = 1 ELSE …` の ELSE を
#     項目名として飲み込んでしまい、IF の対応が崩れる（実際に崩れた）。
TOME = frozenset((
    'ELSE WHEN END-IF END-EVALUATE END-PERFORM END-READ END-START '
    'END-WRITE END-DELETE END-REWRITE END-CALL END-ADD END-SUBTRACT '
    'END-COMPUTE END-DIVIDE END-STRING END-UNSTRING END-SEARCH '
    'AT INVALID THRU THROUGH GIVING UNTIL VARYING TIMES USING UPON '
    'REMAINDER ON SIZE ERROR NEXT').split())


def _tome(g):
    return g.shu == 'na' and (g.v.upper() in TOME or g.v.upper() in BUN)


class Dasu:
    def __init__(self, pgm, setsu, namae, hairetsu):
        self.pgm = pgm              # プログラム名
        self.setsu = setsu          # 節の並び
        self.namae = namae          # 使える項目名の集合
        self.hairetsu = hairetsu    # 繰返しのある項目名
        self.mikansei = []          # 写せなかった文
        self.thru = set()           # PERFORM A THRU B の組
        # PERFORM の飛び先は **節のことも段落のこともある**。
        # 段落は _dan_〜 という別のメソッドになるので、ここで引けるようにする。
        self.yobisaki = {}
        for x in setsu or []:
            self.yobisaki[x.na] = na_py(x.na)
            for d in x.dan:
                self.yobisaki.setdefault(d.na, na_py('_dan_' + d.na))

    # ── 値 ───────────────────────────────────
    def atai(self, go, i):
        """ひとつの値（直定数・項目・添字つき項目）を読む。(式, 次の位置)"""
        g = go[i]
        if g.shu == 'mo':
            return repr(g.v), i + 1
        if g.shu == 'su':
            return "D('%s')" % g.v, i + 1
        # 負の直定数（-1）。字句では記号と数に割れる
        if (g.shu == 'ki' and g.v in ('-', '+')
                and i + 1 < len(go) and go[i+1].shu == 'su'):
            return "D('%s%s')" % ('-' if g.v == '-' else '', go[i+1].v), i + 2
        u = g.v.upper()
        if u in JOGAI:
            return JOGAI[u], i + 1
        if u == 'ALL' and i + 1 < len(go):
            v, j = self.atai(go, i + 1)
            return 'ZENBU(%s)' % v, j
        # 項目。添字と OF がつくことがある
        na = g.v
        i += 1
        soeji = None
        kiri = None
        oya = None
        # 括弧（添字 または 部分参照）と OF（限定子）は**順不同で何度でも**
        # 付く。EDIT-COLOR OF Ｄ科目名称１ (IX1) のように OF のあとに
        # 添字が来る形があり、前だけ見ていると取りこぼす（2026-11-21 実測）。
        while i < len(go):
            if go[i].shu == 'ki' and go[i].v == '(':
                j = i + 1; fukasa = 1; naka = []
                while j < len(go) and fukasa:
                    if go[j].v == '(':
                        fukasa += 1
                    elif go[j].v == ')':
                        fukasa -= 1
                        if not fukasa:
                            break
                    naka.append(go[j]); j += 1
                koron = [k for k, t in enumerate(naka)
                         if t.shu == 'ki' and t.v == ':']
                if koron:
                    c = koron[0]
                    a1, _ = self.shiki(naka, 0, c)
                    a2 = (self.shiki(naka, c + 1, len(naka))[0]
                          if c + 1 < len(naka) else 'None')
                    kiri = '(%s, %s)' % (a1, a2)
                else:
                    atarashii = self._soeji(naka)
                    if atarashii is not None:
                        soeji = (atarashii if soeji is None
                                 else '(%s, %s)' % (soeji.strip('()'),
                                                    atarashii.strip('()')))
                i = j + 1
                continue
            if i + 1 < len(go) and go[i].na('OF', 'IN'):
                oya = go[i+1].v; i += 2
                continue
            break
        hiki = [repr(na)]
        if soeji is not None:
            hiki.append('kai=%s' % soeji)
        if kiri is not None:
            hiki.append('kiri=%s' % kiri)
        if oya:
            hiki.append('oya=%r' % oya)
        return 'self.V(%s)' % ', '.join(hiki), i

    def _soeji(self, naka):
        """添字の中身 → (i, j, …) の形。カンマでも空白でも区切られる。

           COBOL の表は入れ子になる（TBL-SL-JSK1 (IX-1, IX-2)）。
           1次元なら整数、多次元なら組にして渡す。"""
        bu = []
        ima = []
        kakko = 0
        for t in naka:
            if t.shu == 'ki' and t.v == '(':
                kakko += 1
            elif t.shu == 'ki' and t.v == ')':
                kakko -= 1
            if kakko == 0 and t.shu == 'ki' and t.v == ',':
                bu.append(ima); ima = []
                continue
            # 空白区切り：いまの塊が式として完結していて、次が値なら切る
            if (kakko == 0 and ima and t.shu in ('na', 'su')
                    and not (ima[-1].shu == 'ki'
                             and ima[-1].v in ('+', '-', '*', '/', '**', '('))):
                bu.append(ima); ima = [t]; continue
            ima.append(t)
        if ima:
            bu.append(ima)
        shiki = ['int(%s)-1' % self.shiki(b, 0, len(b))[0] for b in bu if b]
        if not shiki:
            return None
        if len(shiki) == 1:
            return shiki[0]
        return '(%s)' % ', '.join(shiki)

    def shiki(self, go, i, owari):
        """算術式（+ - * / ** と括弧）。"""
        de = []
        while i < owari:
            g = go[i]
            if g.shu == 'ki' and g.v in ('+', '-', '*', '/', '**', '(', ')'):
                de.append(g.v); i += 1; continue
            v, i = self.atai(go, i)
            de.append(v)
        return ' '.join(de), i

    # ── 条件 ──────────────────────────────────
    def jouken(self, go, i, owari):
        """条件を Python の式にする。

           ■ 略した書き方に気をつける（2026-11-21 実測）
             COBOL は `A = "1" OR "2"` と書ける。意味は
             `A == "1" or A == "2"`。素直に訳すと `== "1" or "2"` になり、
             Python では**つねに真**になってしまう（実際にそうなった）。
             そこで、直前の左辺と比べ方を覚えておいて補う。
        """
        de = []
        hidari = None          # 直前の左辺
        hikaku = '=='          # 直前の比べ方
        while i < owari:
            g = go[i]
            if g.na('AND'):
                de.append('and'); i += 1; continue
            if g.na('OR'):
                de.append('or'); i += 1; continue
            if g.na('IS', 'THAN', 'THEN'):
                i += 1; continue
            if g.shu == 'ki' and g.v in '()':
                de.append(g.v); i += 1; continue
            if g.na('NOT') and self._hikakuho(go, i, owari)[0]:
                hikaku, j = self._hikakuho(go, i, owari)
                v, i = self.atai(go, j)
                de.append('%s %s %s' % (hidari, hikaku, v)); continue
            if g.na('NOT'):
                de.append('not'); i += 1; continue
            h, j = self._hikakuho(go, i, owari)
            if h:                                   # 比べ方が先に来た＝略した形
                hikaku = h
                v, i = self.atai(go, j)
                de.append('%s %s %s' % (hidari, hikaku, v)); continue
            v, i = self.atai(go, i)
            # 値のあとに算術が続くことがある（WK-DSPNO + 17 >= TBL-CNT）
            while (i < owari and go[i].shu == 'ki'
                   and go[i].v in ('+', '-', '*', '/', '**')):
                kigou = go[i].v
                migi, i = self.atai(go, i + 1)
                v = '(%s %s %s)' % (v, kigou, migi)
            # 「X IS [NOT] NUMERIC／ALPHABETIC」（種類の判定）
            j = i
            gyaku = False
            if j < owari and go[j].na('IS'):
                j += 1
            if j < owari and go[j].na('NOT'):
                gyaku = True; j += 1
            if j < owari and go[j].na('NUMERIC', 'ALPHABETIC', 'ALPHABETIC-UPPER',
                                      'ALPHABETIC-LOWER'):
                f = 'SUUJIKA' if go[j].v.upper() == 'NUMERIC' else 'EIJIKA'
                de.append('%s%s(%s)' % ('not ' if gyaku else '', f, v))
                hidari = None; i = j + 1; continue
            h2, j2 = self._hikakuho(go, i, owari)
            if h2:                                  # ふつうの「左 比べ方 右」
                hikaku = h2
                migi, i = self.atai(go, j2)
                while (i < owari and go[i].shu == 'ki'
                       and go[i].v in ('+', '-', '*', '/', '**')):
                    kigou = go[i].v
                    m2, i = self.atai(go, i + 1)
                    migi = '(%s %s %s)' % (migi, kigou, m2)
                hidari = v
                de.append('%s %s %s' % (v, hikaku, migi)); continue
            if hidari is not None and de and de[-1] in ('and', 'or'):
                de.append('%s %s %s' % (hidari, hikaku, v))   # 略した右辺だけ
            else:
                # 単独で出てきた名前＝条件名（88レベル）
                na = v[len('self.V('):-1] if v.startswith('self.V(') else repr(v)
                de.append('self.J(%s)' % na)
                hidari = None
        return ' '.join(x for x in de if x)

    HANTAI = {'==': '!=', '>': '<=', '<': '>=', '>=': '<', '<=': '>', '!=': '=='}

    def _hikakuho(self, go, i, owari):
        """その位置に比べ方があるか。(Pythonの比べ方, 次の位置)

           `A NOT = B` のように NOT が比べ方の前に付く形も、ここで拾う。
           （拾わないと A が条件名に見えてしまう。2026-11-21 実測）"""
        if i >= owari:
            return None, i
        if go[i].na('NOT'):
            h, j = self._hikakuho(go, i + 1, owari)
            if h:
                return self.HANTAI[h], j
            return None, i
        g = go[i]
        if g.shu == 'ki' and g.v in HIKAKU:
            return HIKAKU[g.v], i + 1
        if g.na('GREATER', 'LESS', 'EQUAL'):
            h = {'GREATER': '>', 'LESS': '<', 'EQUAL': '=='}[g.v.upper()]
            j = i + 1
            while j < owari and go[j].na('THAN', 'TO'):
                j += 1
            if j < owari and go[j].na('OR'):
                j += 1
                while j < owari and go[j].na('EQUAL', 'TO', 'THAN'):
                    j += 1
                h = {'>': '>=', '<': '<='}.get(h, h)
            return h, j
        return None, i

    # ── 文 ───────────────────────────────────
    def bun(self, go, i, owari, ji, de):
        """文をひとつ訳して de（出力行）に足す。次の位置を返す。
           ji はインデント（字下げ）の深さ。"""
        g = go[i]
        u = g.v.upper() if g.shu == 'na' else g.v
        T = '    ' * ji

        if u == 'MOVE':
            return self._move(go, i, owari, T, de)
        if u == 'IF':
            return self._if(go, i, owari, ji, de)
        if u == 'EVALUATE':
            return self._evaluate(go, i, owari, ji, de)
        if u == 'PERFORM':
            return self._perform(go, i, owari, ji, de)
        if u == 'GO':
            return self._goto(go, i, owari, T, de)
        if u in ('ADD', 'SUBTRACT'):
            return self._add(go, i, owari, T, de, u)
        if u == 'COMPUTE':
            return self._compute(go, i, owari, T, de)
        if u == 'DIVIDE':
            return self._divide(go, i, owari, T, de)
        if u == 'INITIALIZE':
            # 終わりの語を見ないと、次の MOVE まで飲み込む（実測で飲み込んだ）
            i += 1
            while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                de.append('%sself.hatsu(%r)' % (T, go[i].v)); i += 1
            return i
        if u == 'CONTINUE':
            de.append('%spass' % T); return i + 1
        if u == 'NEXT' and i + 1 < owari and go[i+1].na('SENTENCE'):
            # NEXT SENTENCE ＝ 何もしないで次の文へ（古い書き方）
            de.append('%spass' % T); return i + 2
        if u == 'EXIT':
            j = i + 1
            if j < owari and go[j].na('PROGRAM'):
                de.append('%sraise ExitProgram()' % T); return j + 1
            de.append('%sreturn' % T); return j
        if u == 'STOP':
            j = i + 1
            if j < owari and go[j].na('RUN'):
                de.append('%sraise StopRun()' % T); return j + 1
            de.append('%sraise StopRun()' % T); return j
        if u == 'DISPLAY':
            return self._display(go, i, owari, T, de)
        if u == 'ACCEPT':
            return self._accept(go, i, owari, T, de)
        if u == 'CALL':
            return self._call(go, i, owari, T, de)
        if u in ('OPEN', 'CLOSE'):
            return self._open(go, i, owari, T, de, u)
        if u in ('READ', 'WRITE', 'REWRITE', 'DELETE', 'START'):
            return self._file(go, i, owari, ji, de, u)
        if g.shu == 'ki' and g.v == '.':
            return i + 1
        if u in ('END-COMPUTE', 'END-ADD', 'END-SUBTRACT', 'END-DIVIDE',
                 'END-IF', 'END-EVALUATE', 'END-PERFORM', 'END-READ',
                 'END-START', 'END-WRITE', 'END-DELETE', 'END-REWRITE',
                 'END-CALL', 'THEN'):
            return i + 1
        # 写せない文は黙って通さない
        j = i
        kotoba = []
        while j < owari and not (go[j].shu == 'ki' and go[j].v == '.'):
            kotoba.append(go[j].v); j += 1
        self.mikansei.append((g.gyo, ' '.join(kotoba[:12])))
        de.append('%sself.未変換(%r, %d)' % (T, ' '.join(kotoba[:12]), g.gyo))
        return j

    def _owari(self, go, i, owari):
        """文の切れ目（次の文のはじまり）まで飛ばす。"""
        while i < owari and not (go[i].shu == 'ki' and go[i].v == '.'):
            i += 1
        return i

    def _move(self, go, i, owari, T, de):
        i += 1
        if go[i].na('CORRESPONDING', 'CORR'):
            # 名前が同じ項目どうしを写す
            i += 1
            moto, i = self.atai(go, i)
            i += 1                       # TO
            saki, i = self.atai(go, i)
            de.append('%sself.utsusu_corr(%s, %s)'
                      % (T, self._na(moto), self._na(saki)))
            return i

        moto, i = self.atai(go, i)
        if i < owari and go[i].na('TO'):
            i += 1
        saki = []
        while i < owari and go[i].shu == 'na' and not _tome(go[i]):
            na, i = self._saki(go, i)
            saki.append(na)
        for na, soe in saki:
            de.append('%sself.S(%s, %s%s)' % (T, na, moto, soe))
        return i

    def _na(self, shiki):
        """self.V('X') → 'X'（名前だけ取り出す）"""
        m = re.match(r"^self\.V\((.+?)(?:,.*)?\)$", shiki)
        return m.group(1) if m else shiki

    def _saki(self, go, i):
        """入れ先（添字・OF つき）を (名前, 付け足しの引数) で返す。

           self.S は「名前, 値, kai=…, oya=…」の順でないと Python の文法に
           合わない（名前つき引数のあとに位置引数は置けない）。"""
        v, j = self.atai(go, i)
        m = re.match(r"^self\.V\((.*)\)$", v)
        naka = m.group(1) if m else v
        bu = []
        fukasa = 0; ima = ''
        for c in naka:
            if c == '(':
                fukasa += 1
            elif c == ')':
                fukasa -= 1
            if c == ',' and fukasa == 0:
                bu.append(ima); ima = ''
            else:
                ima += c
        bu.append(ima)
        na = bu[0].strip()
        soe = ''.join(', ' + x.strip() for x in bu[1:] if x.strip())
        return (na, soe), j

    # ── 条件分岐 ─────────────────────────────
    def _jouken_made(self, go, i, owari):
        """IF のうしろの条件が、どこまでか。
           THEN が来たらそこまで。無ければ**最初の文が始まるところ**まで。"""
        j = i
        kakko = 0
        while j < owari:
            g = go[j]
            if g.shu == 'ki' and g.v == '(':
                kakko += 1
            elif g.shu == 'ki' and g.v == ')':
                kakko -= 1
            elif g.shu == 'ki' and g.v == '.':
                return j, j
            elif g.na('THEN'):
                return j, j + 1
            elif kakko == 0 and _tome(g):
                # 直前が AND/OR/NOT/比べ方なら、まだ条件の途中
                mae = go[j-1] if j > i else None
                if mae is not None and (mae.na('AND', 'OR', 'NOT', 'IS')
                                        or (mae.shu == 'ki' and mae.v in HIKAKU)):
                    pass
                else:
                    return j, j
            j += 1
        return j, j

    def _nakami(self, go, i, owari, ji, de, tome=None):
        """文の並びを、終わりを示す語が来るまで訳す。
           **終わりの語はここでは食べない。** 呼んだ側が自分のぶんだけ食べる。"""
        kaita = False
        while i < owari:
            g = go[i]
            if g.shu == 'ki' and g.v == '.':
                i += 1
                break
            if g.shu == 'na' and g.v.upper() in TOME:
                break
            i = self.bun(go, i, owari, ji, de)
            kaita = True
        if not kaita:
            de.append('%spass' % ('    ' * ji))
        return i

    def _if(self, go, i, owari, ji, de):
        T = '    ' * ji
        j, k = self._jouken_made(go, i + 1, owari)
        de.append('%sif %s:' % (T, self.jouken(go, i + 1, j) or 'False'))
        i = self._nakami(go, k, owari, ji + 1, de, ('ELSE', 'END-IF'))
        if i < owari and go[i].na('ELSE'):
            de.append('%selse:' % T)
            i = self._nakami(go, i + 1, owari, ji + 1, de, ('END-IF',))
        if i < owari and go[i].na('END-IF'):
            i += 1
        return i

    def _evaluate(self, go, i, owari, ji, de):
        T = '    ' * ji
        i += 1
        shudai = None
        if not go[i].na('TRUE'):
            shudai, i = self.atai(go, i)
        else:
            i += 1
        hajime = True
        while i < owari and go[i].na('WHEN'):
            jouken = []
            while i < owari and go[i].na('WHEN'):
                i += 1
                if go[i].na('OTHER'):
                    jouken = None; i += 1; continue
                j = i
                while j < owari and not _tome(go[j]) and not (
                        go[j].shu == 'ki' and go[j].v == '.'):
                    j += 1
                if shudai is None:
                    jouken.append('(%s)' % self.jouken(go, i, j))
                else:
                    jouken.append('(%s)' % self._when(shudai, go, i, j))
                i = j
                if i < owari and (go[i].na('WHEN')):
                    continue
                break
            if jouken is None:
                de.append('%selse:' % T)
            else:
                de.append('%s%s %s:' % (T, 'if' if hajime else 'elif',
                                        ' or '.join(jouken)))
                hajime = False
            i = self._nakami(go, i, owari, ji + 1, de, ('WHEN', 'END-EVALUATE'))
        if i < owari and go[i].na('END-EVALUATE'):
            i += 1
        return i

    def _when(self, shudai, go, i, j):
        """EVALUATE の WHEN の値。THRU（範囲）にも対応。"""
        if j - i >= 3 and go[i+1].na('THRU', 'THROUGH'):
            a, _ = self.atai(go, i)
            b, _ = self.atai(go, i + 2)
            return '%s <= %s <= %s' % (a, shudai, b)
        v, _ = self.atai(go, i)
        return '%s == %s' % (shudai, v)

    # ── 繰返し・飛び越し ───────────────────────
    def _perform(self, go, i, owari, ji, de):
        T = '    ' * ji
        i += 1
        if i < owari and go[i].shu == 'na' and not go[i].na(
                'UNTIL', 'VARYING', 'WITH', 'TEST', 'FOREVER') \
                and not (i + 1 < owari and go[i+1].na('TIMES')):
            na = go[i].v; i += 1
            saki = None
            if i < owari and go[i].na('THRU', 'THROUGH'):
                saki = go[i+1].v; i += 2
            yobi = ('self.%s()' % self.yobisaki.get(na, na_py(na)) if not saki
                    else 'self.%s()' % na_py('_thru_%s_%s' % (na, saki)))
            if saki:
                self.thru.add((na, saki))
            if i < owari and go[i].na('UNTIL'):
                j, _ = self._jouken_made(go, i + 1, owari)
                de.append('%swhile not (%s):' % (T, self.jouken(go, i + 1, j)))
                de.append('%s    %s' % (T, yobi))
                return j
            de.append('%s%s' % (T, yobi))
            return i
        if i < owari and go[i].na('UNTIL'):
            j, k = self._jouken_made(go, i + 1, owari)
            de.append('%swhile not (%s):' % (T, self.jouken(go, i + 1, j)))
            i = self._nakami(go, k, owari, ji + 1, de, ('END-PERFORM',))
            if i < owari and go[i].na('END-PERFORM'):
                i += 1
            return i
        if i + 1 < owari and go[i+1].na('TIMES'):
            v, _ = self.atai(go, i)
            de.append('%sfor _ in range(int(%s)):' % (T, v))
            i = self._nakami(go, i + 2, owari, ji + 1, de, ('END-PERFORM',))
            if i < owari and go[i].na('END-PERFORM'):
                i += 1
            return i
        if i < owari and go[i].na('VARYING'):
            i += 1
            (na, soe), i = self._saki(go, i)
            i += 1                                   # FROM
            kara, i = self.atai(go, i)
            zutsu = 'D(1)'
            if i < owari and go[i].na('BY'):
                zutsu, i = self.atai(go, i + 1)
            j, k = self._jouken_made(go, i + 1, owari) if go[i].na('UNTIL') else (i, i)
            jou = self.jouken(go, i + 1, j) if go[i].na('UNTIL') else 'True'
            de.append('%sself.S(%s, %s%s)' % (T, na, kara, soe))
            de.append('%swhile not (%s):' % (T, jou))
            i = self._nakami(go, k, owari, ji + 1, de, ('END-PERFORM',))
            de.append('%s    self.S(%s, self.V(%s) + %s%s)'
                      % (T, na, na, zutsu, soe))
            if i < owari and go[i].na('END-PERFORM'):
                i += 1
            return i
        return self._owari(go, i, owari)

    def _goto(self, go, i, owari, T, de):
        i += 1
        if i < owari and go[i].na('TO'):
            i += 1
        if i < owari and go[i].shu == 'na':
            de.append('%sraise _Tobu(%r)' % (T, go[i].v))
            return i + 1
        return i

    # ── 計算 ─────────────────────────────────
    def _marume(self, go, i, owari):
        """ROUNDED が付いているか。"""
        if i < owari and go[i].na('ROUNDED'):
            return True, i + 1
        return False, i

    def _add(self, go, i, owari, T, de, shu):
        """ADD a TO b ／ ADD a b GIVING c ／ SUBTRACT a FROM b"""
        i += 1
        moto = []
        while i < owari and not go[i].na('TO', 'FROM', 'GIVING') and not _tome(go[i]):
            v, i = self.atai(go, i)
            moto.append(v)
        tashi = ' + '.join(moto) if moto else 'D(0)'
        if i < owari and go[i].na('TO', 'FROM'):
            i += 1
            while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                (na, soe), i = self._saki(go, i)
                maru, i = self._marume(go, i, owari)
                if i < owari and go[i].na('GIVING'):
                    i += 1
                    (na2, soe2), i = self._saki(go, i)
                    maru, i = self._marume(go, i, owari)
                    # 添字は self.V の**中**に入れる（外に出すと引数が壊れる）。
                    #   SUBTRACT 1 FROM WK-NENDO (3) GIVING WK-NENDO (2)
                    shiki = ('self.V(%s%s) %s (%s)'
                             % (na, soe, '-' if shu == 'SUBTRACT' else '+', tashi))
                    de.append('%sself.S(%s, %s%s%s)'
                              % (T, na2, shiki, ', marume=True' if maru else '', soe2))
                else:
                    kigou = '-' if shu == 'SUBTRACT' else '+'
                    de.append('%sself.S(%s, self.V(%s%s) %s (%s)%s%s)'
                              % (T, na, na, soe, kigou, tashi,
                                 ', marume=True' if maru else '', soe))
            return i
        if i < owari and go[i].na('GIVING'):
            i += 1
            (na, soe), i = self._saki(go, i)
            maru, i = self._marume(go, i, owari)
            de.append('%sself.S(%s, %s%s%s)'
                      % (T, na, tashi, ', marume=True' if maru else '', soe))
        return i

    def _compute(self, go, i, owari, T, de):
        i += 1
        saki = []
        while i < owari and go[i].shu == 'na' and not _tome(go[i]):
            (na, soe), i = self._saki(go, i)
            maru, i = self._marume(go, i, owari)
            saki.append((na, soe, maru))
            if i < owari and go[i].shu == 'ki' and go[i].v == '=':
                break
        if i < owari and go[i].shu == 'ki' and go[i].v == '=':
            i += 1
        j = self._shiki_owari(go, i, owari)
        shiki, _ = self.shiki(go, i, j)
        for na, soe, maru in saki:
            de.append('%sself.S(%s, %s%s%s)'
                      % (T, na, shiki, ', marume=True' if maru else '', soe))
        return j

    def _shiki_owari(self, go, i, owari):
        """算術式がどこまで続くか。次の文か . まで。"""
        j = i; kakko = 0
        while j < owari:
            g = go[j]
            if g.shu == 'ki' and g.v == '(':
                kakko += 1
            elif g.shu == 'ki' and g.v == ')':
                if kakko == 0:
                    return j
                kakko -= 1
            elif g.shu == 'ki' and g.v == '.':
                return j
            elif kakko == 0 and _tome(g):
                mae = go[j-1] if j > i else None
                if mae is None or not (mae.shu == 'ki'
                                       and mae.v in ('+', '-', '*', '/', '**', '(')):
                    return j
            elif g.na('ROUNDED'):
                return j
            j += 1
        return j

    def _divide(self, go, i, owari, T, de):
        i += 1
        a, i = self.atai(go, i)
        if i < owari and go[i].na('INTO'):
            b, i = self.atai(go, i + 1)
            shiki = 'WARU(%s, %s)' % (b, a)
        elif i < owari and go[i].na('BY'):
            b, i = self.atai(go, i + 1)
            shiki = 'WARU(%s, %s)' % (a, b)
        else:
            return self._owari(go, i, owari)
        if i < owari and go[i].na('GIVING'):
            (na, soe), i = self._saki(go, i + 1)
        else:
            na, soe = self._na(b), ''
        maru, i = self._marume(go, i, owari)
        de.append('%sself.S(%s, %s%s%s)'
                  % (T, na, shiki, ', marume=True' if maru else '', soe))
        return i

    # ── そのほか ────────────────────────────
    def _display(self, go, i, owari, T, de):
        i += 1; mono = []
        while i < owari and not go[i].na('UPON') and not _tome(go[i]) and not (
                go[i].shu == 'ki' and go[i].v == '.'):
            v, i = self.atai(go, i)
            mono.append(v)
        saki = "'DSP'"
        if i < owari and go[i].na('UPON'):
            saki = repr(go[i+1].v); i += 2
        de.append('%sself.hyouji([%s], %s)' % (T, ', '.join(mono), saki))
        return i

    def _accept(self, go, i, owari, T, de):
        i += 1
        (na, soe), i = self._saki(go, i)
        moto = 'DATE'
        if i < owari and go[i].na('FROM'):
            moto = go[i+1].v.upper(); i += 2
        de.append('%sself.S(%s, self.uketoru(%r)%s)' % (T, na, moto, soe))
        return i

    def _call(self, go, i, owari, T, de):
        i += 1
        na, i = self.atai(go, i)
        hiki = []
        if i < owari and go[i].na('USING'):
            i += 1
            while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                if go[i].na('BY', 'REFERENCE', 'CONTENT', 'VALUE'):
                    i += 1; continue
                hiki.append(repr(go[i].v)); i += 1
        de.append('%sself.yobu(%s, [%s])' % (T, na, ', '.join(hiki)))
        if i < owari and go[i].na('END-CALL'):
            i += 1
        return i

    def _open(self, go, i, owari, T, de, shu):
        i += 1; mode = 'I-O'
        fairu = []
        while i < owari and go[i].shu == 'na' and not _tome(go[i]):
            u = go[i].v.upper()
            if u in ('INPUT', 'OUTPUT', 'I-O', 'EXTEND'):
                mode = u
            else:
                fairu.append(go[i].v)
            i += 1
        for f in fairu:
            de.append('%sself.%s(%r%s)' % (T, 'hiraku' if shu == 'OPEN' else 'tojiru',
                                           f, (', %r' % mode) if shu == 'OPEN' else ''))
        return i

    def _file(self, go, i, owari, ji, de, shu):
        T = '    ' * ji
        i += 1
        if i >= owari:
            return i
        f = go[i].v; i += 1
        soe = []
        if shu == 'START':
            # START ファイル KEY [比べ方] キー1 キー2 …
            while i < owari and go[i].na('KEY', 'IS', 'NOT', 'GREATER',
                                         'EQUAL', 'THAN', 'OR'):
                i += 1
            if i < owari and go[i].shu == 'ki' and go[i].v in HIKAKU:
                soe.append(repr(go[i].v)); i += 1
            while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                soe.append('kagi=%r' % go[i].v if False else repr(go[i].v))
                i += 1
            de.append('%sself.f_hajime(%r%s)'
                      % (T, f, (', ' + ', '.join(soe)) if soe else ''))
            while i < owari and go[i].na('INVALID', 'KEY', 'NOT', 'END-START'):
                hantei = 'NASHI'
                gyaku = False
                while i < owari and go[i].na('INVALID', 'KEY', 'NOT', 'END-START'):
                    if go[i].na('NOT'):
                        gyaku = True
                    if go[i].na('END-START'):
                        return i + 1
                    i += 1
                de.append('%sif %sself.jotai(%r) == %s:'
                          % (T, 'not ' if gyaku else '', f, hantei))
                i = self._nakami(go, i, owari, ji + 1, de)
            return i
        while i < owari and go[i].na('RECORD', 'INTO', 'FROM', 'KEY', 'IS',
                                     'NEXT', 'PREVIOUS', 'WITH', 'NO', 'LOCK',
                                     'GREATER', 'EQUAL', 'THAN', 'OR', 'NOT',
                                     'ALL') or (i < owari and go[i].shu == 'ki'
                                                and go[i].v in HIKAKU):
            if go[i].na('NEXT'):
                soe.append("'NEXT'")
            if go[i].shu == 'ki' and go[i].v in HIKAKU:
                soe.append(repr(go[i].v))
            if go[i].na('GREATER'):
                soe.append("'>'")
            i += 1
            if i < owari and go[i].shu == 'na' and go[i-1].na('INTO', 'FROM', 'KEY'):
                # キーは複数ならぶことがある（RECORD KEY が集団のとき）
                while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                    soe.append(repr(go[i].v)); i += 1
        okuri = None
        if i < owari and go[i].na('AFTER', 'BEFORE'):
            saki = go[i].v.upper() == 'AFTER'
            i += 1
            while i < owari and go[i].na('ADVANCING'):
                i += 1
            if i < owari and (go[i].shu in ('su', 'na')) and not _tome(go[i]):
                if go[i].na('PAGE'):
                    okuri = "'PAGE'"; i += 1
                else:
                    okuri, i = self.atai(go, i)
                while i < owari and go[i].na('LINE', 'LINES'):
                    i += 1
            soe.append('okuri=%s' % (okuri or 'D(1)'))
            soe.append('saki=%s' % saki)
        de.append('%sself.%s(%r%s)'
                  % (T, {'READ': 'f_yomu', 'WRITE': 'f_kaku',
                         'REWRITE': 'f_kakinaosu', 'DELETE': 'f_kesu',
                         'START': 'f_hajime'}[shu], f,
                     (', ' + ', '.join(soe)) if soe else ''))
        # AT END / INVALID KEY / NOT INVALID KEY
        while i < owari and (go[i].na('AT', 'END', 'INVALID', 'KEY', 'NOT')):
            hantei = 'OWARI' if go[i].na('AT', 'END') else 'NASHI'
            gyaku = False
            while i < owari and go[i].na('AT', 'END', 'INVALID', 'KEY', 'NOT'):
                if go[i].na('NOT'):
                    gyaku = True
                i += 1
            de.append('%sif %sself.jotai(%r) == %s:' % (T, 'not ' if gyaku else '', f, hantei))
            i = self._nakami(go, i, owari, ji + 1, de,
                             ('AT', 'INVALID', 'NOT', 'END-READ', 'END-START',
                              'END-WRITE', 'END-DELETE'))
        while i < owari and go[i].na('END-READ', 'END-START', 'END-WRITE',
                                     'END-DELETE', 'END-REWRITE'):
            i += 1
        return i
