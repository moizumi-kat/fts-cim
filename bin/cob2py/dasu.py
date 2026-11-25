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
    # AFTER / BEFORE / ADVANCING も文の切れ目（2026-11-24 実測）。
    #   `WRITE 帳票Ｒ FROM PRT-BODY-10 AFTER 1` の AFTER を、FROM のあとの
    #   「キーが複数ならぶ」取り込みが飲み込んでしまい、残った `1` から先が
    #   丸ごと未変換になっていた（201か所）。
    'AFTER BEFORE ADVANCING '
    'REMAINDER ON SIZE ERROR NEXT').split())


def _tome(g):
    return g.shu == 'na' and (g.v.upper() in TOME or g.v.upper() in BUN)


class Dasu:
    kari = 0                                 # ON SIZE ERROR 用の一時名の通し番号

    def __init__(self, pgm, setsu, namae, hairetsu, teisu=None):
        self.pgm = pgm              # プログラム名
        # SPECIAL-NAMES の SYMBOLIC CONSTANT（名前つきの直定数）。
        #   SPECIAL-NAMES.  SYMBOLIC CONSTANT 定数 IS 1000000  正常 IS "00" …
        # 849本すべてが持っている（実測）。これを見ないと「知らない項目 正常」で止まる。
        self.teisu = dict(teisu or {})
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
        if g.v in self.teisu:              # SYMBOLIC CONSTANT
            return self.teisu[g.v], i + 1
        if u == 'FUNCTION' and i + 1 < len(go):
            # 組込関数。原文で使われているのは CURRENT-DATE だけ（233か所・実測）。
            # 21文字 `YYYYMMDDhhmmss00+0900` を返す（COBOL の決まり）。
            if go[i+1].na('CURRENT-DATE'):
                return 'self.ima_moji()', i + 2
            raise ValueError('知らない組込関数 %s' % go[i+1].v)
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
        tobasu = 0
        for t in naka:
            # 添字の中も修飾で書く（`T-JSK-FLG (SEQNO OF D20010D1)`）。
            # `OF` と そのうしろの名前は**添字ではない**ので飛ばす。
            # これを数えてしまい、3次元の添字に見えていた（2026-11-24）。
            if tobasu:
                tobasu -= 1
                continue
            if t.shu == 'na' and t.v.upper() in ('OF', 'IN'):
                tobasu = 1
                continue
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
            return self._jibun_end(go, self._add(go, i, owari, T, de, u),
                                   owari, 'END-' + u)
        if u == 'COMPUTE':
            return self._jibun_end(go, self._compute(go, i, owari, T, de),
                                   owari, 'END-COMPUTE')
        if u == 'DIVIDE':
            return self._jibun_end(go, self._divide(go, i, owari, T, de),
                                   owari, 'END-DIVIDE')
        if u == 'INITIALIZE':
            # 終わりの語を見ないと、次の MOVE まで飲み込む（実測で飲み込んだ）
            i += 1
            while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                na = go[i].v
                i += 1
                # `INITIALIZE W020-NOTBL(2)` のように添字が付くことがある（49か所）。
                # 表ぜんぶではなく**その回だけ**戻すのが COBOL の決まり。
                soe = ''
                if i < owari and go[i].shu == 'ki' and go[i].v == '(':
                    (_na2, soe2), i = self._saki(go, i - 1)
                    soe = soe2
                # `INITIALIZE AJKN-REC OF AJKNML1` のように修飾で書くことが
                # ある。`OF` を**次の初期化先**と読んでしまい
                # `self.hatsu('OF')` を出していた（2026-11-24）。
                oya = None
                while (i + 1 < owari and go[i].shu == 'na'
                       and go[i].v.upper() in ('OF', 'IN')):
                    oya = go[i+1].v
                    i += 2
                if oya:
                    soe += ', oya=%r' % oya
                de.append('%sself.hatsu(%r%s)' % (T, na, soe))
            return i
        if u == 'INSPECT':
            # `INSPECT WK-BUNAME2 REPLACING ALL VAL-HEX28 BY VAL-HEX40`（4か所）
            j = i + 1
            (na, soe), j = self._saki(go, j)
            if j < owari and go[j].na('REPLACING'):
                j += 1
                kumi = []
                while j < owari and go[j].na('ALL', 'LEADING', 'FIRST'):
                    j += 1
                    a, j = self.atai(go, j)
                    if j < owari and go[j].na('BY'):
                        j += 1
                    b, j = self.atai(go, j)
                    kumi.append((a, b))
                for a, b in kumi:
                    de.append('%sself.S(%s, str(self.V(%s%s)).replace(%s, %s)%s)'
                              % (T, na, na, soe, a, b, soe))
                return j
            return self._owari(go, i, owari)
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
        if g.shu == 'ki' and g.v in ('.', ',', ';'):
            # `MOVE "Y" TO CR-KBN,` のように読点で文を切る書き方がある（5か所）。
            return i + 1
        if u == 'END' and i + 1 < owari and go[i+1].na('PROGRAM'):
            # `END PROGRAM 名前.` は入れ子プログラムの終わりの印。
            # 実行するものは無いので読み飛ばす（174本の末尾にある）。
            return self._owari(go, i, owari)
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
        while i < owari:
            # 送り先は読点で区切ることもできる
            # （`MOVE 見積１ TO Ｐ－見積番号１ , 保存－見積１`・3か所）。
            if go[i].shu == 'ki' and go[i].v == ',':
                i += 1
                continue
            # `READ … AT END MOVE "END" TO SW-END NOT AT END ADD …` のように
            # 後ろに句が続くことがある。**NOT／AT／INVALID／WHEN を送り先に
            # 取り込んでいた**ため `self.S('NOT','END')` を出していた
            # （2026-11-25 実測・M30311PP）。これらは予約語で項目名にならない。
            if go[i].na('NOT', 'AT', 'INVALID', 'WHEN', 'ON', 'SIZE', 'ERROR'):
                break
            if go[i].shu != 'na' or _tome(go[i]):
                break
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

    def _jibun_end(self, go, i, owari, na):
        """演算文の自分の END-xxx が残っていたら食べる（2026-11-24）。

           _nakami は TOME の語が来たら抜けるので、COMPUTE の END-COMPUTE を
           残したままだと、IF の中身が END-COMPUTE で終わったとみなされ、
           **続く ELSE が丸ごと未変換になっていた**（83か所）。
        """
        return i + 1 if (i < owari and go[i].na(na)) else i

    def _nakami(self, go, i, owari, ji, de, tome=None):
        """文の並びを、終わりを示す語が来るまで訳す。
           **終わりの語はここでは食べない。** 呼んだ側が自分のぶんだけ食べる。"""
        kaita = False
        while i < owari:
            g = go[i]
            if g.shu == 'ki' and g.v == '.':
                i += 1
                break
            # 呼んだ側が指定した終わりの語でも抜ける。**これを見ていなかった**ので
            # `READ … INVALID KEY … NOT INVALID KEY …` の NOT（TOME に無い）で
            # 抜けられず、NOT 以降が未変換になっていた（11か所・2026-11-24）。
            if g.shu == 'na' and tome and g.v.upper() in tome:
                break
            if g.shu == 'na' and g.v.upper() in TOME:
                # `NEXT SENTENCE`（＝何もしない）は文なので抜けない。
                # `IF … THEN NEXT SENTENCE ELSE …` の ELSE が落ちていた（2026-11-24）。
                if not (g.na('NEXT') and i + 1 < owari
                        and go[i+1].na('SENTENCE')):
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
        """EVALUATE。**主題が複数（ALSO）の形にも対応**（2026-11-24）。

             EVALUATE  項番開始     ALSO  項番終了
                WHEN   NOT ZERO    ALSO  NOT ZERO
                WHEN   NOT ZERO    ALSO  ZERO
                   …
           WHEN の中の ALSO は主題と位置で対応して **かつ**（and）、
           WHEN が続いているぶんは **または**（or）。48か所あった。
        """
        T = '    ' * ji
        i += 1
        shudai = []                      # 主題。TRUE のところは None
        while True:
            if go[i].na('TRUE'):
                shudai.append(None); i += 1
            else:
                v, i = self.atai(go, i)
                shudai.append(v)
            if i < owari and go[i].na('ALSO'):
                i += 1
                continue
            break
        hajime = True
        while i < owari and go[i].na('WHEN'):
            jouken = []
            while i < owari and go[i].na('WHEN'):
                i += 1
                if go[i].na('OTHER'):
                    jouken = None; i += 1; continue
                j = i
                # THRU は範囲の印なので、ここでは切れ目にしない
                # （`WHEN 1 THRU 2` の THRU 以降が落ちていた・5か所）。
                while j < owari and not (
                        go[j].shu == 'ki' and go[j].v == '.') and not (
                        _tome(go[j]) and not go[j].na('THRU', 'THROUGH')):
                    j += 1
                jouken.append('(%s)' % self._when_zenbu(shudai, go, i, j))
                i = j
                if i < owari and go[i].na('WHEN'):
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

    def _also_waru(self, go, i, j):
        """[i, j) を、括弧の外側の ALSO で区切る。"""
        kugiri = []
        kara = i
        kakko = 0
        for k in range(i, j):
            g = go[k]
            if g.shu == 'ki' and g.v == '(':
                kakko += 1
            elif g.shu == 'ki' and g.v == ')':
                kakko -= 1
            elif kakko == 0 and g.na('ALSO'):
                kugiri.append((kara, k)); kara = k + 1
        kugiri.append((kara, j))
        return kugiri

    def _when_zenbu(self, shudai, go, i, j):
        """WHEN の中身（ALSO で区切られる）を主題と突き合わせて条件にする。"""
        bu = self._also_waru(go, i, j)
        de = []
        for k, (a, b) in enumerate(bu):
            if a >= b:
                continue
            s = shudai[k] if k < len(shudai) else None
            de.append('(%s)' % (self.jouken(go, a, b) if s is None
                                else self._when(s, go, a, b)))
        return ' and '.join(de) if de else 'False'

    def _when(self, shudai, go, i, j):
        """EVALUATE の WHEN の値。THRU（範囲）・NOT・ANY にも対応。"""
        if go[i].na('ANY'):
            return 'True'
        if go[i].na('NOT'):
            saki = self._when(shudai, go, i + 1, j)
            # `== x` を `!= x` に、範囲は否定にする
            if saki.startswith('%s == ' % shudai):
                return '%s != %s' % (shudai, saki[len('%s == ' % shudai):])
            return 'not (%s)' % saki
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
            if i < owari and go[i].na('VARYING'):
                # `PERFORM AWKK-1300-RTN VARYING IX-1 FROM 1 BY 1 UNTIL …`
                # ＝節を呼ぶ形の PERFORM VARYING（12か所）。
                i += 1
                (na2, soe2), i = self._saki(go, i)
                i += 1                                   # FROM
                kara, i = self.atai(go, i)
                zutsu = 'D(1)'
                if i < owari and go[i].na('BY'):
                    zutsu, i = self.atai(go, i + 1)
                de.append('%sself.S(%s, %s%s)' % (T, na2, kara, soe2))
                j, _ = self._jouken_made(go, i + 1, owari) if (
                    i < owari and go[i].na('UNTIL')) else (i, i)
                jo = self.jouken(go, i + 1, j) if i < owari and go[i].na(
                    'UNTIL') else 'True'
                de.append('%swhile not (%s):' % (T, jo))
                de.append('%s    %s' % (T, yobi))
                de.append('%s    self.S(%s, self.V(%s%s) + (%s)%s)'
                          % (T, na2, na2, soe2, zutsu, soe2))
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
        # `ON SIZE ERROR …`（桁あふれのときだけ走る処理）。
        #   COBOL は「入れ先の整数部に収まらなければ入れずに、そちらを走らせる」。
        #   黙って飛ばすと誤った結果を出しうるので、**判定ごと写す**。
        if j < owari and (go[j].na('ON') or go[j].na('SIZE')):
            k = j
            while k < owari and go[k].na('ON', 'SIZE', 'ERROR'):
                k += 1
            self.kari += 1
            na_kari = '_v%d' % self.kari
            de.append('%s%s = %s' % (T, na_kari, shiki))
            jo = ' and '.join('self.hamaru(%s, %s%s)' % (na, na_kari, soe)
                              for na, soe, _m in saki)
            de.append('%sif %s:' % (T, jo))
            for na, soe, maru in saki:
                de.append('%s    self.S(%s, %s%s%s)'
                          % (T, na, na_kari, ', marume=True' if maru else '', soe))
            de.append('%selse:' % T)
            k = self._nakami(go, k, owari, int(len(T) / 4) + 1, de,
                             ('NOT', 'END-COMPUTE'))
            if k < owari and go[k].na('NOT'):
                while k < owari and go[k].na('NOT', 'ON', 'SIZE', 'ERROR'):
                    k += 1
                de.append('%s# NOT ON SIZE ERROR' % T)
                de.append('%sif %s:' % (T, jo))
                k = self._nakami(go, k, owari, int(len(T) / 4) + 1, de,
                                 ('END-COMPUTE',))
            return k
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
        # `DIVIDE 2 INTO WK-LCNT GIVING WK-WARI REMAINDER WK-AMAR`（44か所）。
        # 商は整数に切り捨て、余りを別の項目へ入れる（COBOL の決まり）。
        amari = None
        if i < owari and go[i].na('REMAINDER'):
            (amari, amari_soe), i = self._saki(go, i + 1)
        if amari is not None:
            waru_a, waru_b = (b, a) if 'WARU(%s, %s)' % (b, a) == shiki else (a, b)
            de.append('%sself.S(%s, SUUJIKA(%s) // SUUJIKA(%s)%s)'
                      % (T, na, waru_a, waru_b, soe))
            de.append('%sself.S(%s, SUUJIKA(%s) %% SUUJIKA(%s)%s)'
                      % (T, amari, waru_a, waru_b, amari_soe))
            return i
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
        # `WRITE FBHTFD OF FBHTML1.` のように修飾で書くことがある（157か所）。
        # この場合、実体は**修飾のほう（論理ファイル名）**。
        while (i + 1 < owari and go[i].na('OF', 'IN')
               and go[i+1].shu == 'na'):
            f = go[i+1].v
            i += 2
        soe = []
        if shu == 'START':
            # START ファイル [POSITIONING POINTER IS x] KEY [比べ方] キー1 キー2 …
            #   `POSITIONING POINTER IS WK-P1` は富士通の拡張（6か所）。
            #   どこから読み始めるかの覚えを持つ指定で、順に読む位置は
            #   f_hajime が持つので、ここでは読み飛ばす。
            if i < owari and go[i].na('POSITIONING'):
                i += 1
                if i < owari and go[i].na('POINTER'):
                    i += 1
                if i < owari and go[i].na('IS'):
                    i += 1
                if i < owari and go[i].shu == 'na' and not go[i].na('KEY'):
                    i += 1                      # 覚えを入れる項目（読み飛ばす）
            while i < owari and go[i].na('KEY', 'IS', 'NOT', 'GREATER',
                                         'EQUAL', 'THAN', 'OR'):
                i += 1
            if i < owari and go[i].shu == 'ki' and go[i].v in HIKAKU:
                soe.append(repr(go[i].v)); i += 1
            while i < owari and go[i].shu == 'na' and not _tome(go[i]):
                soe.append(repr(go[i].v))
                i += 1
                # キーも `SEIBAN OF FSKKML2` と修飾で書くことがある
                while (i + 1 < owari and go[i].na('OF', 'IN')
                       and go[i+1].shu == 'na'):
                    i += 2
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
                i = self._nakami(go, i, owari, ji + 1, de,
                                 ('INVALID', 'NOT', 'END-START'))
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
            # 句の語をいったん全部見てから決める。先頭だけ見ていたので
            # `NOT AT END` が「該当なし(23)」の判定になっていた（2026-11-25）。
            gyaku = False
            kotoba = []
            while i < owari and go[i].na('AT', 'END', 'INVALID', 'KEY', 'NOT'):
                if go[i].na('NOT'):
                    gyaku = True
                kotoba.append(go[i].v.upper())
                i += 1
            hantei = 'NASHI' if 'INVALID' in kotoba else 'OWARI'
            de.append('%sif %sself.jotai(%r) == %s:' % (T, 'not ' if gyaku else '', f, hantei))
            i = self._nakami(go, i, owari, ji + 1, de,
                             ('AT', 'INVALID', 'NOT', 'END-READ', 'END-START',
                              'END-WRITE', 'END-DELETE'))
        while i < owari and go[i].na('END-READ', 'END-START', 'END-WRITE',
                                     'END-DELETE', 'END-REWRITE'):
            i += 1
        return i
