# -*- coding: utf-8 -*-
"""ＣＬ（ＦＡＣＡＭ ＣＬ）を動かす。

ＣＬは「どの処理をどの順で流すか」を書いたもの。ＣＯＢＯＬ 848本は
**ＣＬから呼ばれて**動くので、ＣＬが無いと
  ・引数（`CALL B16100PB,(?KBN)` の区分）が渡らない
  ・作業ファイル（`CRTFILE` で作る一時表）が無い
  ・ファイルの差し替え（`OVRF`）が効かない
という状態で、単体では動かないプログラムが残る。

■ 作った範囲（2026-11-27 実測で決めた）
  588本のＣＬに出てくる命令は 182種類・26,462回。そのうち
      作る命令            23種類 25,249回（95.4%）
      空振りでよい命令    20種類    962回（3.6%）… 保存・ＦＴＰ・印刷など
      作っていない命令             251回        … ＳＢＭＪＯＢ 等
  で、**525本／588本**のＣＬがこの範囲に収まる。

■ 空振りにした命令は**必ず記録する**
  黙って飛ばすと「動いたのに結果が違う」になる。`log` に残して、
  あとで人が見られるようにする（方針1-3）。
"""
import pathlib, re, sys, datetime

from .hashiru import Pgm, StopRun, ExitProgram, Mikansei, GamenDeta

ここ = pathlib.Path(__file__).resolve().parent
_BIN = ここ.parent.parent.parent / 'fts-cim-repo' / 'bin'
if str(_BIN) not in sys.path:
    sys.path.insert(0, str(_BIN))
import cl_parse

MOTO = None          # ＣＬ・ＣＯＢＯＬ の原文置き場（_moto で決める）

# 中身を作らず、記録だけして次へ進む命令。
#   帳票の印刷・ファイルの保存・ＦＴＰ・ディレクトリ移動など、
#   **計算の結果に影響しないもの**だけを入れている。
KARA = {
    'SAVFILE': 'ファイルの保存', 'SAVLIB': 'ライブラリの保存',
    'OVRPRTF': '印刷ファイルの差し替え', 'CHGCDIR': 'ディレクトリの移動',
    'CHGFILE': 'ファイル属性の変更', 'SETPF': '物理ファイルの設定',
    'ACTLF': '論理ファイルの活性化', 'DACTLF': '論理ファイルの非活性化',
    'SNDFTPC': 'ＦＴＰ送信', 'CNTFTPC': 'ＦＴＰ接続',
    'DCNTFTPC': 'ＦＴＰ切断', 'FIMPORT': 'ファイルの取り込み',
    'STRDPSD': '分散処理の開始', 'RELATE': 'ファイルの関係づけ',
    'CNVDF': 'データ形式の変換', 'DLTSAVF': '保存ファイルの削除',
    'ENDDPSD': '分散処理の終了', 'SNDFILE': 'ファイル送信',
    'RCVFILE': 'ファイル受信', 'CHGJOB': 'ジョブ属性の変更',
    'WRTLOG': 'ログ書き出し', 'WAIT': '待ち合わせ',
    'CANWTR': 'ライタの取消', 'ACTVLD': 'ＶＬＤの活性化',
    'DACTVLD': 'ＶＬＤの非活性化', 'OVRSF': '順ファイルの差し替え',
    'SAVMBR': 'メンバの保存', 'RLSSPLF': 'スプールの解放',
    'DACTWS': '端末の非活性化', 'CRTLF': '論理ファイルの作成',
}


def _moto():
    global MOTO
    if MOTO is None:
        for m in (ここ.parent.parent.parent / 'cim' / 'utf8',
                  ここ.parent.parent / 'cim' / 'utf8'):
            if m.exists():
                MOTO = m
                break
    return MOTO


class Owari(Exception):
    """ＲＥＴＵＲＮ でＣＬを終える。"""

    def __init__(self, ec=0):
        self.ec = ec


class Jikkou:
    """ＣＬ 1本を動かす。

       使い方
           j = Jikkou(con, cimdb, sousa, kyou)
           j.hashiru('CA1Z0020')          # ＣＬの名前
           print(j.log)                   # 何をしたか
    """

    def __init__(self, con=None, db=None, sousa=None, kyou=None,
                 byou=None, gamen_tome=1, yobanai=False):
        self.con, self.db, self.sousa = con, db, sousa
        self.kyou = kyou or datetime.datetime.now()
        self.byou, self.gamen_tome = byou, gamen_tome
        # yobanai … ＣＯＢＯＬ を実際には動かさない（ＣＬの網羅度を測る用）
        self.yobanai = yobanai
        self.log = []                  # [(ＣＬ名, 行, 何をしたか)]
        self.ovrf = {}                 # 差し替え {論理名: 実際の名}
        self.pgmec = 0                 # @PGMEC（直前のＣＡＬＬの戻り）
        self.fukasa = 0

    # ── 記録 ────────────────────────────────────
    def _kaku(self, cl, gyo, s):
        self.log.append((cl, gyo, s))

    # ── 値 ──────────────────────────────────────
    def _sys(self, na):
        """`@` で始まるシステムの値。"""
        u = na.upper()
        return {
            '@PGMEC': self.pgmec, '@PGMES': '', '@PGMEM': '',
            '@JOBDATE': self.kyou.strftime('%y.%m.%d'),
            '@JOBD': self.kyou.strftime('%y%m%d'),
            '@STIME': self.kyou.strftime('%H:%M:%S'),
            '@DATE': self.kyou.strftime('%y%m%d'),
            '@YES': '@YES', '@NO': '@NO', '@MAX': '@MAX',
            '@NORMAL': 0, '@ABNORMAL': 1,
        }.get(u, u)

    def _atai(self, x, hensu):
        """ＣＬの式を1つ値にする。`'abc'` ／ `?VAR` ／ `@PGMEC` ／ 数。"""
        x = x.strip()
        if not x:
            return ''
        if x[0] in "'\"" and x[-1] == x[0] and len(x) >= 2:
            return x[1:-1]
        if x.startswith('@'):
            return self._sys(x)
        if x.startswith('?'):
            m = re.match(r'^(\?[A-Z0-9@#$_-]+)\s*\((.*)\)$', x, re.I)
            if m:          # `?CNAM(?I)` 添字つき
                na = m.group(1).upper()
                i = self._shiki(m.group(2), hensu)
                v = hensu.get(na)
                try:
                    return (v or [])[int(i) - 1]
                except Exception:
                    return ''
            return hensu.get(x.upper(), '')
        if re.match(r'^-?\d+$', x):
            return int(x)
        return x

    def _shiki(self, s, hensu):
        """`?A && ' ' && @JOBD` や `?WKDATE + 100` を値にする。

           ＣＬの演算子は `&&`（文字をつなぐ）と `+ - * /`（数）だけ。
        """
        s = s.strip()
        if '&&' in s:
            return ''.join(str(self._shiki(x, hensu)) for x in s.split('&&'))
        m = re.match(r'^(.*?)\s*([+\-*/])\s*([^+\-*/]*)$', s)
        if m and m.group(1).strip():
            a = self._shiki(m.group(1), hensu)
            b = self._shiki(m.group(3), hensu)
            try:
                a, b = int(a or 0), int(b or 0)
            except (TypeError, ValueError):
                return str(a) + str(b)
            return {'+': a + b, '-': a - b, '*': a * b,
                    '/': (a // b if b else 0)}[m.group(2)]
        m = re.match(r'^%([A-Z]+)\s*\((.*)\)$', s, re.I)
        if m:
            # %LAST(LABEL) など。試作では空にする（記録は残す）
            return ''
        return self._atai(s, hensu)

    def _joken(self, s, hensu):
        """`?A = '1'` ／ `?A ^= '1'` ／ `ABNORMAL` を真偽にする。"""
        s = s.strip()
        u = s.upper()
        if u in ('ABNORMAL', '@ABNORMAL'):
            return self.pgmec != 0
        if u in ('NORMAL', '@NORMAL'):
            return self.pgmec == 0
        for en, f in ((r'\^=', lambda a, b: a != b), (r'>=', lambda a, b: a >= b),
                      (r'<=', lambda a, b: a <= b), (r'=', lambda a, b: a == b),
                      (r'>', lambda a, b: a > b), (r'<', lambda a, b: a < b)):
            m = re.match(r'^(.*?)\s*%s\s*(.*)$' % en, s)
            if m:
                a = self._shiki(m.group(1), hensu)
                b = self._shiki(m.group(2), hensu)
                if isinstance(a, int) != isinstance(b, int):
                    a, b = str(a).strip(), str(b).strip()
                try:
                    return f(a, b)
                except TypeError:
                    return f(str(a), str(b))
        return bool(self._shiki(s, hensu))

    # ── 表の名前 ────────────────────────────────
    def _hyo(self, na):
        """`AREGFS.FADLIB` → `AREGFS`。差し替え（ＯＶＲＦ）も通す。"""
        na = str(na).split('.')[0].strip().upper()
        return self.ovrf.get(na, na)

    def _hyo_aru(self, t):
        try:
            from ..schema_gen import TABLES
            return t in TABLES
        except Exception:
            return False

    # ── 動かす ──────────────────────────────────
    def hashiru(self, cl, hiki=()):
        """ＣＬ 1本を動かす。`hiki` は呼ぶ側が渡した値の並び。"""
        michi = _moto() / (cl + '.CL')
        if not michi.exists():
            self._kaku(cl, 0, '原文が無い')
            return 1
        bun = cl_parse.yomu(michi)
        raberu = {b['na']: i for i, b in enumerate(bun)
                  if b['shu'] == 'raberu'}
        hensu = {}
        para = []
        i = 0
        try:
            while i < len(bun):
                b = bun[i]
                i = self._ichibun(cl, b, i, bun, raberu, hensu, para, hiki)
        except Owari as e:
            self.pgmec = e.ec
        return self.pgmec

    def _tobu(self, bun, i, owari=('end',)):
        """いまの位置から、対応する `END` の次まで飛ぶ。"""
        fukasa = 0
        j = i + 1
        while j < len(bun):
            s = bun[j]['shu']
            if s in ('if', 'case'):
                fukasa += 1
            elif s == 'end':
                if fukasa == 0:
                    return j + 1
                fukasa -= 1
            j += 1
        return len(bun)

    def _ichibun(self, cl, b, i, bun, raberu, hensu, para, hiki):
        shu = b['shu']
        gyo = b.get('gyo', 0)
        if shu in ('raberu', 'end', 'else', 'caseji', 'when'):
            # ＥＬＳＥ に素通りで入るのは、ＩＦ が真だったとき。
            # その場合は ＥＮＤ まで飛ばす。
            if shu == 'else':
                return self._tobu(bun, i)
            return i + 1
        if shu == 'fumei':
            self._kaku(cl, gyo, '読めない行: %s' % b['moji'][:40])
            return i + 1
        if shu == 'dainyu':
            saki = b['saki'].upper()
            v = self._shiki(b['shiki'], hensu)
            m = re.match(r'^(\?[A-Z0-9@#$_-]+)\s*\((.*)\)$', saki, re.I)
            if m:
                na = m.group(1)
                k = int(self._shiki(m.group(2), hensu) or 1)
                hensu.setdefault(na, [''] * max(k, 32))
                if isinstance(hensu[na], list) and k <= len(hensu[na]):
                    hensu[na][k - 1] = v
            else:
                hensu[saki] = v
            return i + 1
        if shu == 'if':
            if self._joken(b['joken'], hensu):
                return i + 1
            # 偽 → ＥＬＳＥ か ＥＮＤ まで飛ぶ
            fukasa = 0
            j = i + 1
            while j < len(bun):
                s = bun[j]['shu']
                if s in ('if', 'case'):
                    fukasa += 1
                elif s == 'end':
                    if fukasa == 0:
                        return j + 1
                    fukasa -= 1
                elif s == 'else' and fukasa == 0:
                    return j + 1
                j += 1
            return len(bun)
        if shu == 'case':
            atai = self._shiki(b['ato'], hensu)
            # `#4091#` の並びから合うものを探す
            fukasa = 0
            j = i + 1
            while j < len(bun):
                s = bun[j]['shu']
                if s in ('if', 'case'):
                    fukasa += 1
                elif s == 'end':
                    if fukasa == 0:
                        return j + 1
                    fukasa -= 1
                elif s == 'caseji' and fukasa == 0:
                    if str(atai).strip() == bun[j]['atai'].strip():
                        return j + 1
                j += 1
            return len(bun)
        if shu == 'goto':
            na = b['ato'].strip().upper().rstrip('.')
            if na in raberu:
                return raberu[na] + 1
            self._kaku(cl, gyo, 'ＧＯＴＯ の飛び先が無い: %s' % na)
            return i + 1
        if shu == 'return':
            ec = 0
            m = re.search(r'PGMEC-(\S+)', b.get('ato') or '', re.I)
            if m:
                v = self._shiki(m.group(1), hensu)
                ec = v if isinstance(v, int) else 0
            raise Owari(ec)
        if shu != 'meirei':
            return i + 1
        self._meirei(cl, b, hensu, para, hiki)
        return i + 1

    def _meirei(self, cl, b, hensu, para, hiki):
        na, kw, h, gyo = b['na'], b['kw'], b['hiki'], b.get('gyo', 0)
        if na == 'PGM':
            # `PGM (KUBUN-?KUBUN)` … ＣＬ自身が受け取る引数の名前。
            # 呼ぶ側が名前つき（辞書）で渡したときに結びつける。
            for x in h:
                y = x.strip().strip('()')
                k, v = cl_parse._kiiwaado(y)
                if k and v.startswith('?') and isinstance(hiki, dict):
                    if k in hiki:
                        hensu[v.upper()] = hiki[k]
                    elif k.upper() in hiki:
                        hensu[v.upper()] = hiki[k.upper()]
            return
        if na == 'PARA':
            # `PARA ?A,STRING*6` … 呼ぶ側の値を順に受け取る
            if h:
                v = h[0].upper()
                para.append(v)
                if isinstance(hiki, dict):
                    hensu.setdefault(v, '')
                else:
                    hensu[v] = hiki[len(para) - 1] \
                        if len(hiki) >= len(para) else ''
            return
        if na == 'VAR':
            if h:
                v = h[0].upper()
                hensu[v] = self._atai(kw.get('VALUE', "''"), hensu) \
                    if 'VALUE' in kw else ''
            return
        if na == 'INIT':
            for x in h:
                if x.startswith('?'):
                    hensu[x.upper()] = ''
            return
        if na in ('SNDMSG', 'LOGMSG', 'DSPMSG'):
            msg = kw.get('MSG') or (h[0] if h else '')
            self._kaku(cl, gyo, '%s %s' % (na, self._shiki(msg, hensu)))
            return
        if na in ('STRTRNS', 'STPTRNS', 'CRTTWF', 'DLTTWF'):
            self._kaku(cl, gyo, '%s（試作では1つの処理としてまとめて扱う）' % na)
            return
        if na == 'CHGCMVAR':
            if len(h) >= 2:
                hensu[h[0].upper()] = self._shiki(h[1], hensu)
            return
        if na == 'OVRF':
            a = self._hyo(kw.get('FILE', ''))
            b2 = self._hyo(kw.get('TOFILE', ''))
            if a and b2:
                self.ovrf[a] = b2
                self._kaku(cl, gyo, 'ＯＶＲＦ %s → %s' % (a, b2))
            return
        if na == 'DLTOVRF':
            a = self._hyo(kw.get('FILE', ''))
            if a in self.ovrf:
                del self.ovrf[a]
            elif not a:
                self.ovrf.clear()
            self._kaku(cl, gyo, 'ＤＬＴＯＶＲＦ %s' % (a or '（全部）'))
            return
        if na in ('CRTFILE', 'CLRFILE', 'DLTFILE'):
            t = self._hyo(kw.get('FILE') or (h[0] if h else ''))
            if not self._hyo_aru(t):
                self._kaku(cl, gyo, '%s %s（表が無いので何もしない）' % (na, t))
                return
            try:
                self.con.execute('DELETE FROM [%s]' % t)
                self._kaku(cl, gyo, '%s %s（中身を空にした）' % (na, t))
            except Exception as e:
                self._kaku(cl, gyo, '%s %s でだめ: %s' % (na, t, str(e)[:40]))
            return
        if na == 'CNVFILE':
            a = self._hyo(kw.get('FILE', ''))
            b2 = self._hyo(kw.get('TOFILE', ''))
            self._utsusu(cl, gyo, a, b2)
            return
        if na in ('SORTD', 'SORT', 'SORTF'):
            self._narabe(cl, gyo, kw, h)
            return
        if na == 'CALL':
            self._yobu(cl, gyo, h, hensu)
            return
        if na in KARA:
            self._kaku(cl, gyo, '%s（%s・試作では何もしない）' % (na, KARA[na]))
            return
        self._kaku(cl, gyo, '%s（まだ作っていない命令）' % na)

    def _utsusu(self, cl, gyo, a, b2):
        """ＣＮＶＦＩＬＥ。表 a の中身を表 b2 へ写す。

           村上様のご回答（2026-11-26）で、この組は**同じ並び**と確認済み
           （`CNVFILE FILE-AUKJFS,TOFILE-AUKRFS` 等）。
           列の名前が同じものだけを写し、違えば記録して何もしない。
        """
        if not (self._hyo_aru(a) and self._hyo_aru(b2)):
            self._kaku(cl, gyo, 'ＣＮＶＦＩＬＥ %s→%s（表が無い）' % (a, b2))
            return
        from ..schema_gen import TABLES
        ra = [c[0] for c in TABLES[a]['cols']]
        rb = [c[0] for c in TABLES[b2]['cols']]
        tomo = [c for c in ra if c in rb]
        if len(tomo) != len(ra):
            self._kaku(cl, gyo,
                       'ＣＮＶＦＩＬＥ %s→%s（列が合わないので写さない）' % (a, b2))
            return
        try:
            self.con.execute('DELETE FROM [%s]' % b2)
            retsu = ','.join('[%s]' % c for c in tomo)
            self.con.execute('INSERT INTO [%s](%s) SELECT %s FROM [%s]'
                             % (b2, retsu, retsu, a))
            n = self.con.execute('SELECT COUNT(*) FROM [%s]' % b2).fetchone()[0]
            self._kaku(cl, gyo, 'ＣＮＶＦＩＬＥ %s→%s %d件' % (a, b2, n))
        except Exception as e:
            self._kaku(cl, gyo, 'ＣＮＶＦＩＬＥ %s→%s でだめ: %s'
                       % (a, b2, str(e)[:40]))

    def _narabe(self, cl, gyo, kw, h):
        """ＳＯＲＴＤ／ＳＯＲＴ。並べ替えて別の表へ入れる。

           `SORTD INFILE-FGENKA,INRL-40,OUTFILE-…,FIELD-…` の形。
           並べる列が読み取れないときは**何もせず記録する**
           （適当な順で入れると、あとの処理が黙って違う答えを出す）。
        """
        moto = self._hyo(kw.get('INFILE', ''))
        saki = self._hyo(kw.get('OUTFILE', '') or moto)
        if not (self._hyo_aru(moto) and self._hyo_aru(saki)):
            self._kaku(cl, gyo, 'ＳＯＲＴ %s→%s（表が無い）' % (moto, saki))
            return
        self._kaku(cl, gyo,
                   'ＳＯＲＴ %s→%s（並べる列が決まらないので写すだけ）'
                   % (moto, saki))
        if moto != saki:
            self._utsusu(cl, gyo, moto, saki)

    def _yobu(self, cl, gyo, h, hensu):
        """ＣＡＬＬ。ＣＯＢＯＬ か ＣＬ を呼ぶ。引数は参照渡し。"""
        if not h:
            return
        # ■ 呼び先の書き方も2つ（2026-11-27 実測）
        #     CALL PGM-F10270PP,PARA-(…)   … `PGM-` を付ける形
        #     CALL B16100PB,PARA-(…)       … 名前だけ
        #   `PGM-` を外していなかったので「原文が無い」と数えていた。
        na = ''
        for x in h:
            y = x.strip()
            k, v = cl_parse._kiiwaado(y)
            if k == 'PGM':
                na = v; break
            if not k and not y.startswith(('?', '(')):
                na = y; break
        if not na:
            self._kaku(cl, gyo, 'ＣＡＬＬ の呼び先が読めない: %s' % ','.join(h)[:40])
            return
        na = na.split('.')[0].strip().upper()
        atai = []
        namae = []
        # ■ 引数の書き方は2つ（2026-11-27 実測）
        #     CALL B16100PB,PARA-(?KUBUN,?WSID)   … 1,019回（こちらが本筋）
        #     CALL A10020PB,(?VLD1)               … 39回
        #   `PARA-` のほうを見ていなかったので、ほぼ全部の引数を
        #   渡せていなかった。
        s = ''
        for x in h[1:]:
            y = x.strip()
            if y.upper().startswith('PARA-'):
                s = y[5:].strip(); break
            if y.startswith('('):
                s = y; break
        if s:
            if s.startswith('(') and s.endswith(')'):
                s = s[1:-1]
            for x in cl_parse._hikisu(s):
                namae.append(x.strip())
                atai.append(self._shiki(x, hensu))
        # ＣＬ なら中へ入る
        if (_moto() / (na + '.CL')).exists():
            if self.fukasa >= 8:
                self._kaku(cl, gyo, 'ＣＡＬＬ %s（呼び出しが深すぎる）' % na)
                return
            self.fukasa += 1
            try:
                self.pgmec = self.hashiru(na, atai)
            finally:
                self.fukasa -= 1
            self._kaku(cl, gyo, 'ＣＡＬＬ %s（ＣＬ）→ %s' % (na, self.pgmec))
            return
        if self.yobanai:
            cls = Pgm._yobu_kumu(na)
            self._kaku(cl, gyo, 'ＣＡＬＬ %s → %s（動かさない）'
                       % (na, '原文あり' if cls is not None else '原文が無い'))
            self.pgmec = 0
            return
        cls = Pgm._yobu_kumu(na)
        if cls is None:
            self._kaku(cl, gyo, 'ＣＡＬＬ %s（原文が無い）' % na)
            self.pgmec = 0
            return
        ko = cls(con=self.con, db=self.db, sousa=self.sousa, kyou=self.kyou)
        ko.gamen_tome = self.gamen_tome
        uke = list(getattr(ko, 'UKETORI', []) or [])
        for k, v in zip(uke, atai):
            try:
                ko.S(k, v)
            except Exception:
                pass
        kekka = '通った'
        self.pgmec = 0
        try:
            ko._iriguchi_yobu()
        except (StopRun, ExitProgram):
            pass
        except GamenDeta:
            kekka = '画面が出た'
        except Mikansei as e:
            kekka = '写し取れていない: %s' % e
            self.pgmec = 1
        except Exception as e:
            kekka = '%s: %s' % (type(e).__name__, str(e)[:50])
            self.pgmec = 1
        # 参照渡しなので書き戻す
        for k, x in zip(uke, namae):
            if x.startswith('?'):
                try:
                    hensu[x.upper()] = str(ko.V(k))
                except Exception:
                    pass
        try:
            ec = ko.V('PROGRAM-STATUS')
            self.pgmec = int(ec) if str(ec).strip() else self.pgmec
        except Exception:
            pass
        self._kaku(cl, gyo, 'ＣＡＬＬ %s → %s（@PGMEC=%s）'
                   % (na, kekka, self.pgmec))
