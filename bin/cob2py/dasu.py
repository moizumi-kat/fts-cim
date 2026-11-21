# -*- coding: utf-8 -*-
"""文を Python に直して書き出す。

   値の読み書きは self.V（取る）／self.S（入れる）に寄せる。
   COBOL の名前には - や全角が入り、同じ名前が別の領域にも出るため、
   Python の変数名に直さず**名前で引く**。
"""
import re
from .tetsuzuki import na_py

JOGAI = {'ZERO': '0', 'ZEROS': '0', 'ZEROES': '0',
         'SPACE': 'SPACE', 'SPACES': 'SPACE',
         'HIGH-VALUE': 'TAKAI', 'HIGH-VALUES': 'TAKAI',
         'LOW-VALUE': 'HIKUI', 'LOW-VALUES': 'HIKUI',
         'QUOTE': "'\"'", 'QUOTES': "'\"'"}
HIKAKU = {'=': '==', '>': '>', '<': '<', '>=': '>=', '<=': '<=', '<>': '!='}


class Dasu:
    def __init__(self, pgm, setsu, namae, hairetsu):
        self.pgm = pgm              # プログラム名
        self.setsu = setsu          # 節の並び
        self.namae = namae          # 使える項目名の集合
        self.hairetsu = hairetsu    # 繰返しのある項目名
        self.mikansei = []          # 写せなかった文

    # ── 値 ───────────────────────────────────
    def atai(self, go, i):
        """ひとつの値（直定数・項目・添字つき項目）を読む。(式, 次の位置)"""
        g = go[i]
        if g.shu == 'mo':
            return repr(g.v), i + 1
        if g.shu == 'su':
            return "D('%s')" % g.v, i + 1
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
        if i < len(go) and go[i].shu == 'ki' and go[i].v == '(':
            j = i + 1; fukasa = 1; naka = []
            while j < len(go) and fukasa:
                if go[j].v == '(': fukasa += 1
                elif go[j].v == ')':
                    fukasa -= 1
                    if not fukasa: break
                naka.append(go[j]); j += 1
            soeji, _ = self.shiki(naka, 0, len(naka))
            i = j + 1
        oya = None
        while i + 1 < len(go) and go[i].na('OF', 'IN'):
            oya = go[i+1].v; i += 2
        hiki = [repr(na)]
        if soeji is not None:
            hiki.append('kai=int(%s)-1' % soeji)
        if oya:
            hiki.append('oya=%r' % oya)
        return 'self.V(%s)' % ', '.join(hiki), i

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
            h2, j2 = self._hikakuho(go, i, owari)
            if h2:                                  # ふつうの「左 比べ方 右」
                hikaku = h2
                migi, i = self.atai(go, j2)
                if i < owari and go[i].na('NUMERIC', 'ALPHABETIC'):
                    pass
                hidari = v
                de.append('%s %s %s' % (v, hikaku, migi)); continue
            if i < owari and go[i].na('NUMERIC', 'ALPHABETIC'):
                de.append('%s(%s)' % ('SUUJIKA' if go[i].v.upper() == 'NUMERIC'
                                      else 'EIJIKA', v))
                i += 1; continue
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
