# -*- coding: utf-8 -*-
"""変換したプログラムを動かす土台。

   bin/cob2py が出す Python は、ここにある Pgm を継ぐ。
   COBOL の「記憶域」「索引ファイル」「画面」「呼び出し」の受け皿。
"""
from decimal import Decimal, ROUND_HALF_UP, ROUND_DOWN
import datetime

from .kioku import Ryoiki, Komoku
from . import fairu as F

SPACE = '\x00SPACE'            # MOVE SPACE の印（型を見て空白かゼロに変わる）
TAKAI = '\x00HIGH'
HIKUI = '\x00LOW'
SEIJOU, OWARI, NASHI, JYUUFUKU = '00', '10', '23', '22'
NAIFAIRU = '35'          # OPEN したがファイルが無い


def D(v):
    return Decimal(str(v))


def ZENBU(v):
    """ALL "x" … 入れ先の桁ぶん繰り返す。長さは入れるときに決まる。"""
    return '\x00ALL' + str(v)


def WARU(a, b):
    a, b = D(a), D(b)
    return Decimal(0) if b == 0 else a / b


def SUUJIKA(v):
    s = str(v).strip()
    return bool(s) and s.lstrip('-').replace('.', '', 1).isdigit()


def EIJIKA(v):
    s = str(v).replace(' ', '')
    return s.isalpha()


class Moji(str):
    """英数の項目の値。数と比べられたら**数として**比べる。

       ■ なぜ要るか（2026-11-21 実測）
         COBOL は `IF 集団項目 < 3` のように、文字の項目と数を比べる。
         Python では str と Decimal は比べられず落ちる。
         現行と同じ答えにするため、相手が数なら数にそろえて比べる。
         （出てくるコードを読みやすく保ちたいので、比較関数を挟まず
           値の側で引き受ける。）
    """
    __slots__ = ()

    def _kazu(self):
        t = self.strip()
        try:
            return Decimal(t or '0')
        except Exception:
            return None

    def _soroeru(self, hoka):
        if isinstance(hoka, (Decimal, int, float)):
            a = self._kazu()
            if a is not None:
                return a, Decimal(str(hoka))
        return None, None

    def __lt__(self, h):
        a, b = self._soroeru(h)
        return a < b if a is not None else str.__lt__(self, h)

    def __le__(self, h):
        a, b = self._soroeru(h)
        return a <= b if a is not None else str.__le__(self, h)

    def __gt__(self, h):
        a, b = self._soroeru(h)
        return a > b if a is not None else str.__gt__(self, h)

    def __ge__(self, h):
        a, b = self._soroeru(h)
        return a >= b if a is not None else str.__ge__(self, h)

    def __eq__(self, h):
        a, b = self._soroeru(h)
        return a == b if a is not None else str.__eq__(self, h)

    def __ne__(self, h):
        return not self.__eq__(h)

    def __hash__(self):
        return str.__hash__(self)

    # 計算に使われたら数として扱う（COBOL は集団項目を数として足せる）
    def _n(self):
        a = self._kazu()
        if a is None:
            raise TypeError('数として読めません: %r' % str(self)[:20])
        return a

    def __add__(self, h):
        return self._n() + Decimal(str(h)) if not isinstance(h, str) \
            else str.__add__(self, h)

    def __radd__(self, h):
        return Decimal(str(h)) + self._n()

    def __sub__(self, h):
        return self._n() - Decimal(str(h))

    def __rsub__(self, h):
        return Decimal(str(h)) - self._n()

    def __mul__(self, h):
        return self._n() * Decimal(str(h)) if not isinstance(h, int) \
            else str.__mul__(self, h)

    def __rmul__(self, h):
        return Decimal(str(h)) * self._n() if not isinstance(h, int) \
            else str.__mul__(self, h)

    def __truediv__(self, h):
        return WARU(self._n(), h)

    def __rtruediv__(self, h):
        return WARU(h, self._n())

    def __int__(self):
        return int(self._n())


class _Tobu(Exception):
    """GO TO。飛び先の段落名を持つ。"""
    def __init__(self, saki):
        super().__init__(saki); self.saki = saki


class ExitProgram(Exception):
    pass


class StopRun(Exception):
    pass


class Mikansei(Exception):
    """まだ写せていない文。**黙って通さない**ための印。"""
    def __init__(self, kotoba, gyo):
        super().__init__('%s（原文 %d行）' % (kotoba, gyo))


class Pgm:
    NA = ''
    UKETORI = []
    FAIRU = {}
    FD_REC = {}
    KIOKU = []
    DANRAKU = []

    def __init__(self, con=None, db=None, sousa=None, kyou=None):
        self.con, self.db, self.sousa = con, db, sousa
        self._kyou = kyou
        self.ryoiki = {}
        self.hyo = {}                    # 名前 → (領域, 項目)
        for na, naga, ko, shoki in self.KIOKU:
            h = {}
            for t in ko:
                (kna, ichi, knaga, kata, keta, shou, fugo, comp, occ) = t[:9]
                dan = t[9] if len(t) > 9 else ()
                h[kna] = Komoku(kna, ichi, knaga, kata, keta, shou, fugo,
                                comp, occ, dan)
            r = Ryoiki(naga, h)
            r.hyo.setdefault(na, Komoku(na, 0, naga, None, naga))
            self.ryoiki[na] = r
            for kna in list(h) + [na]:
                self.hyo.setdefault(kna, (r, r.hyo[kna]))
            for kna, v in shoki:
                try:
                    self.S(kna, self._teisu(v))
                except Exception:
                    pass
        # COBOL の特殊レジスタ（宣言しないで使える欄）
        #   PROGRAM-STATUS … 異常終了コード。現行は ABEND-RTN で使う
        #   RETURN-CODE    … 呼んだ先へ返す値
        toku = Ryoiki(8, {'PROGRAM-STATUS': Komoku('PROGRAM-STATUS', 0, 4, '9', 4),
                          'RETURN-CODE': Komoku('RETURN-CODE', 4, 4, '9', 4)})
        self.ryoiki['＊特殊'] = toku
        for na in ('PROGRAM-STATUS', 'RETURN-CODE'):
            self.hyo.setdefault(na, (toku, toku.hyo[na]))
        self.f = {}
        self.f_jotai = {}
        # OPEN したのに表をつなげられなかったファイル（後で人に見せる）
        self.hyo_nai = set()
        # 索引でないファイル（VLD のメッセージ列・画面・帳票）へ書いたもの。
        # 表が無いので、ここに貯めて後ろの処理へ渡す。
        self.kaita = {}
        if con is not None and db is not None:
            for na, d in self.FAIRU.items():
                sakuin = d.get('kumi') == 'INDEXED' and d.get('kagi')
                hyo = self._hyomei(d.get('ronri'))
                if not sakuin:
                    # ■ 順ファイルもつなぐ（2026-11-24）
                    #   `SELECT FJKNML1 ASSIGN TO DA-VS-FJKNMP` のように
                    #   ORGANIZATION も RECORD KEY も書かない**順ファイル**が
                    #   あり、これを一切つないでいなかったので READ が
                    #   「表が無い」で止まっていた（94本）。
                    #   物理名は ASSIGN 句に書いてあるので、**その表が
                    #   実在するときだけ**つなぐ。実在しないものは帳票・
                    #   画面・メッセージ列なので、従来どおり self.kaita へ。
                    try:
                        if not hyo or hyo not in db.TABLES:
                            continue
                    except Exception:
                        continue
                kagi = [self._kagi_retsu(k, hyo, db)
                        for k in (d.get('kagi') or [])]
                try:
                    self.f[na] = F.Fairu(con, hyo, kagi, d['ronri'], db=db)
                except Exception:
                    pass
                self.f_jotai[na] = SEIJOU

    # ── 名前から表を引く ─────────────────────────
    @staticmethod
    def _hyomei(ronri):
        """論理ファイル名 → 物理表名。AJBGFL1→AJBGFP／ASOSML1→ASOSMP。

           **まず表定義の `ronri`（論理名の一覧）で引く**（2026-11-24）。
           名前の形から作る当てものでは YAMAHL1→YAMAHSF が当たらない。
        """
        if not ronri:
            return ''
        h = Pgm._ronri_hyo()
        if ronri in h:
            return h[ronri]
        if len(ronri) >= 3 and ronri[-3] in 'FML' and ronri[-2:].isdigit():
            return ronri[:-3] + ('FP' if ronri[-3] == 'F' else 'MP')
        if ronri.endswith(('FL1', 'ML1', 'ML3')):
            return ronri[:-3] + ('FP' if ronri[-3] == 'F' else 'MP')
        return ronri

    _RONRI_HYO = None

    @classmethod
    def _ronri_hyo(cls):
        """論理ファイル名 → 物理表名（表定義の `ronri` から逆引き）。"""
        if cls._RONRI_HYO is None:
            cls._RONRI_HYO = {}
            try:
                from ..schema_gen import TABLES
            except Exception:
                return cls._RONRI_HYO
            for t, v in TABLES.items():
                for r in (v.get('ronri') or []):
                    cls._RONRI_HYO.setdefault(r, t)
        return cls._RONRI_HYO

    def ima_moji(self):
        """FUNCTION CURRENT-DATE。21文字 `YYYYMMDDhhmmssss+hhmm`。

           COBOL の決まりでは 8桁の日付＋6桁の時刻＋100分の1秒2桁＋
           時差（符号＋4桁）。再現性のため、kyou（試験用の日時）があればそれを使う。
        """
        t = self._kyou or __import__('datetime').datetime.now()
        return Moji('%04d%02d%02d%02d%02d%02d%02d+0900'
                    % (t.year, t.month, t.day, t.hour, t.minute, t.second,
                       t.microsecond // 10000))

    def _teisu(self, v):
        if v in ('ZERO', 'ZEROS', 'ZEROES'):
            return 0
        if v in ('SPACE', 'SPACES'):
            return SPACE
        if v in ('HIGH-VALUE', 'HIGH-VALUES'):
            return TAKAI
        if v in ('LOW-VALUE', 'LOW-VALUES'):
            return HIKUI
        return v

    # ── 値の出し入れ ────────────────────────────
    def _hiku(self, na, oya=None):
        if oya:
            # 画面の制御部は「EDIT-STATUS OF 件名カナ」という名前で持っている
            # （項目ごとに5バイトの制御部がある）。
            t = self.hyo.get('%s OF %s' % (na, oya))
            if t is not None:
                return t
            if oya in self.ryoiki:
                r = self.ryoiki[oya]
                if na in r.hyo:
                    return r, r.hyo[na]
        t = self.hyo.get(na)
        if t is None:
            raise Mikansei('知らない項目 %s' % na, 0)
        return t

    def V(self, na, kai=0, oya=None, kiri=None):
        r, k = self._hiku(na, oya)
        if k.kata is None:                     # 集団項目は生のまま
            v = Moji(r.nama(k, kai).decode('cp932', 'replace'))
        else:
            # 表の見出しは項目自身の名前（EDIT-STATUS OF 件名カナ など）
            v = r.toru(k.na, kai) if k.na in r.hyo else r.nama(k, kai)
            if isinstance(v, str):
                v = Moji(v)
        if kiri is not None:
            s = v if isinstance(v, str) else str(v)
            a = int(kiri[0]) - 1
            n = None if kiri[1] is None else int(kiri[1])
            b = s.encode('cp932', 'replace')
            b = b[a:a + n] if n is not None else b[a:]
            return Moji(b.decode('cp932', 'replace'))
        return v

    def S(self, na, v, kai=0, oya=None, kiri=None, marume=False):
        r, k = self._hiku(na, oya)
        if isinstance(v, str) and v.startswith('\x00ALL'):
            moji = v[4:] or ' '
            v = (moji * (k.naga // max(1, len(moji.encode('cp932'))) + 1))
        if v is SPACE or v == SPACE:
            v = 0 if k.kata == '9' else ' ' * k.naga
        elif v == TAKAI:
            v = b'\xff' * k.naga
        elif v == HIKUI:
            v = b'\x00' * k.naga
        if marume and k.kata == '9' and not isinstance(v, (str, bytes)):
            q = Decimal(1).scaleb(-k.shou)
            v = D(v).quantize(q, rounding=ROUND_HALF_UP)
        if kiri is not None:
            moto = self.V(na, kai, oya)
            b = (moto if isinstance(moto, str) else str(moto)).encode('cp932', 'replace')
            a = int(kiri[0]) - 1
            n = k.naga - a if kiri[1] is None else int(kiri[1])
            atarashii = (str(v) if not isinstance(v, bytes) else v.decode('cp932', 'replace'))
            ab = atarashii.encode('cp932', 'replace')[:n].ljust(n, b' ')
            b = (b.ljust(k.naga, b' ')[:a] + ab + b.ljust(k.naga, b' ')[a + n:])
            r.nama_ireru(k, b, kai)
            return
        if k.kata is None:
            b = v if isinstance(v, bytes) else str(v).encode('cp932', 'replace')
            r.nama_ireru(k, b, kai)
            return
        r.ireru(k.na, v, kai)

    def J(self, na):
        """88レベル（条件名）。いまは写していないので止める。"""
        raise Mikansei('条件名 %s（88レベル）' % na, 0)

    def hamaru(self, na, v, oya=None):
        """その項目に値が収まるか（桁あふれしないか）。

           COBOL の `ON SIZE ERROR` は、計算結果が入れ先の桁に収まらないときだけ
           走る。収まるかどうかは**整数部の桁数**で決まる（小数は丸められる）。
        """
        _r, k = self._hiku(na, oya)
        if not k.keta:
            return True
        seisu = k.keta - (k.shou or 0)
        try:
            return abs(D(v)) < (D(10) ** seisu)
        except Exception:
            return True

    def hatsu(self, na, kai=None):
        """INITIALIZE。英数は空白・数はゼロに戻す。

           kai を付けると**その回だけ**戻す（`INITIALIZE W020-NOTBL(2)` の形。
           表ぜんぶを戻してしまうと他の回を壊すので、回を指定する）。
        """
        r, k = self._hiku(na)
        if kai is None:
            hajime, naga = k.ichi, k.naga
        else:
            kk = kai if isinstance(kai, tuple) else (kai,)
            hajime = r._ichi(k, kk[0] if len(kk) == 1 else kk)
            naga = k.naga
        for kna, c in r.hyo.items():
            if c.ichi < hajime or c.ichi + c.naga > hajime + naga:
                continue
            if c.kata == '9':
                r.ireru(kna, 0)
            elif c.kata in ('X', 'N'):
                r.nama_ireru(c, b' ' * c.naga)

    def 未変換(self, kotoba, gyo):
        raise Mikansei(kotoba, gyo)

    def utsusu_corr(self, moto, saki):
        a = self.ryoiki.get(moto); b = self.ryoiki.get(saki)
        if not a or not b:
            raise Mikansei('MOVE CORRESPONDING %s %s' % (moto, saki), 0)
        for na in a.hyo:
            if na in b.hyo and a.hyo[na].kata:
                self.S(na, a.toru(na), oya=saki)

    # ── 段落・節を回す ──────────────────────────
    def _jun(self, setsu=None):
        for sna, dan in self.DANRAKU:
            if setsu is None or sna == setsu:
                for dna, me in dan:
                    yield sna, dna, me

    def _setsu(self, na):
        dan = [(dna, me) for sna, dna, me in self._jun(na)]
        i = 0
        while i < len(dan):
            dna, me = dan[i]
            if me is None:
                i += 1; continue
            try:
                getattr(self, me)()
            except _Tobu as e:
                saki = [k for k, (d2, _m) in enumerate(
                    [(d, m) for d, m in dan]) if d2 == e.saki]
                if saki:
                    i = saki[0]; continue
                raise
            i += 1

    def _thru(self, kara, made):
        zen = list(self._jun())
        na = [d for _s, d, _m in zen]
        if kara not in na or made not in na:
            raise Mikansei('PERFORM %s THRU %s' % (kara, made), 0)
        a, b = na.index(kara), na.index(made)
        i = a
        while i <= b:
            me = zen[i][2]
            if me is None:
                i += 1; continue
            try:
                getattr(self, me)()
            except _Tobu as e:
                if e.saki in na:
                    i = na.index(e.saki); continue
                raise
            i += 1

    # ── ファイル ────────────────────────────
    def hiraku(self, f, mode='I-O'):
        """OPEN。**FILE STATUS の項目へ状態を書く**（2026-11-24）。

           書き忘れていたため、原文の
             `IF AJBG-STSCD NOT = '00' … OPEN ERR … ABEND`
           が空文字と '00' を比べて必ず異常になり、**532本が ABEND**
           していた。OPEN は実際には成功している（`hiraku` は常に正常）。

           索引ファイルなのに表をつなげていない（表が無い）ときだけ
           '35'（ファイル無し）を返す。黙って成功にすると、無い表を
           読んだのか空の表を読んだのか分からなくなる。"""
        d = self.FAIRU.get(f, {})
        if d.get('kumi') == 'INDEXED' and d.get('kagi') and f not in self.f:
            st = NAIFAIRU
            self.hyo_nai.add(f)
        else:
            st = SEIJOU
        self.f_jotai[f] = st
        self._jotai_kaku(f, st)
        return st

    def tojiru(self, f):
        self.f_jotai[f] = SEIJOU
        self._jotai_kaku(f, SEIJOU)
        return SEIJOU

    def jotai(self, f):
        return self.f_jotai.get(f, SEIJOU)

    def _fname(self, na):
        """名前をファイル名に直す。

           COBOL は READ にはファイル名、WRITE／REWRITE には**レコード名**を
           書く（WRITE ACHK-ACHKFD）。レコード名は接頭辞（ACHK-）を持つので、
           その接頭辞のファイルへつなぐ。"""
        if na in self.FAIRU:
            return na
        if na in self.FD_REC:
            return self.FD_REC[na]
        if '-' in na:
            s = na.split('-', 1)[0] + '-'
            for f, d in self.FAIRU.items():
                for k in d.get('kagi', []):
                    if k.startswith(s):
                        return f
        # 01 レコード名が FD と同じ綴りのこともある
        for f, d in self.FAIRU.items():
            if (d.get('ronri') or '').upper().startswith(na.upper()[:4]):
                return f
        return na

    @staticmethod
    def _kagi_retsu(na, hyo, db):
        """RECORD KEY の項目名 → 表の列名（2026-11-24）。

           接頭辞を外す。区切りは ASCII の `-` と**全角ハイフン U+FF0D** の
           どちらもある（接頭辞が日本語だと全角）。
           外した名前が列に無ければ、**日本語の項目名から英名を引く**
             `ワ鑑－見積ナンバー` → `見積ナンバー` → `MITUNO`
           （表定義の cols は (列名, 型, 日本語項目名, PIC)）。
        """
        mo = na
        for sep in ('-', '\uff0d'):
            if sep in mo:
                mo = mo.split(sep, 1)[-1]
                break
        try:
            cols = db.TABLES[hyo]['cols']
        except Exception:
            return mo
        aru = {c[0] for c in cols}
        if mo in aru:
            return mo
        for c in cols:
            if len(c) > 2 and (c[2] or '').strip() == mo:
                return c[0]
        return mo

    def _kagi(self, f):
        d = self.FAIRU.get(f, {})
        return [self.V(k) for k in d.get('kagi', [])]

    def f_yomu(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            raise Mikansei('READ %s（表が無い）' % f, 0)
        if 'NEXT' in soe or fa.jun:
            # 順ファイルは `READ ファイル` だけでも順読み（NEXT と同じ）
            st = fa.tsugi()
        else:
            st = fa.yomu(*self._kagi(f))
        self.f_jotai[f] = st
        if st == SEIJOU:
            self._rec_ireru(f, fa)
        self._jotai_kaku(f, st)
        return st

    def f_hajime(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            raise Mikansei('START %s（表が無い）' % f, 0)
        ijou = any(s in ('>=', '>') for s in soe) or not soe
        st = fa.hajime(*self._kagi(f), ijou=ijou)
        self.f_jotai[f] = st
        self._jotai_kaku(f, st)
        return st

    def f_kaku(self, f, *soe, **kw):
        moto = f
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            d = self.FAIRU.get(f) or self.FAIRU.get(moto)
            if d is not None and d.get('kumi') != 'INDEXED':
                # メッセージ列・帳票など。中身を取っておく
                r = self.ryoiki.get(moto)
                self.kaita.setdefault(f, []).append(
                    bytes(r.b) if r is not None else b'')
                self.f_jotai[f] = SEIJOU
                self._jotai_kaku(f, SEIJOU)
                return SEIJOU
            raise Mikansei('WRITE %s（表が無い）' % f, 0)
        st = fa.kaku(self._rec_toru(f))
        self.f_jotai[f] = st
        self._jotai_kaku(f, st)
        return st

    def f_kakinaosu(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            raise Mikansei('REWRITE %s（表が無い）' % f, 0)
        st = fa.kakinaosu(self._rec_toru(f))
        self.f_jotai[f] = st
        self._jotai_kaku(f, st)
        return st

    def f_kesu(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            raise Mikansei('DELETE %s（表が無い）' % f, 0)
        st = fa.kesu(*self._kagi(f))
        self.f_jotai[f] = st
        self._jotai_kaku(f, st)
        return st

    def _jotai_kaku(self, f, st):
        na = self.FAIRU.get(f, {}).get('jotai')
        if na and na in self.hyo:
            self.S(na, st)

    def _settou(self, f):
        """そのファイルの項目につく接頭辞（AJBG- など）。"""
        d = self.FAIRU.get(f, {})
        for k in d.get('kagi', []):
            if '-' in k:
                return k.split('-', 1)[0] + '-'
        return None

    def _rec_ireru(self, f, fa):
        """読んだレコードを、COBOL の項目へ移す。

           繰返し項目は表では BASE_1 BASE_2 … と横に展開されているので、
           回ごとに入れ直す（入れ忘れると見積総額が 0 のままになった）。"""
        s = self._settou(f)
        if not s:
            return
        for na, (r, k) in self.hyo.items():
            if not na.startswith(s) or not k.kata:
                continue
            retsu = na[len(s):]
            if k.occurs:
                for i in range(k.occurs):
                    c = self._retsu_na(retsu, i + 1, fa.rec)
                    if c:
                        try:
                            self.S(na, fa.rec[c], kai=i)
                        except Exception:
                            pass
            elif retsu in fa.rec:
                try:
                    self.S(na, fa.rec[retsu])
                except Exception:
                    pass

    @staticmethod
    def _retsu_na(moto, n, rec):
        """繰返しの n 回目にあたる列名。英名を _ で6文字に詰めて _n。"""
        for c in ('%s_%d' % (moto, n), '%s_%d' % (moto.ljust(6, '_'), n)):
            if c in rec:
                return c
        return None

    def _rec_toru(self, f):
        """レコードの項目を {列名: 値} にする。

           接頭辞（JOINING … AS PREFIX）が同じ項目を集めるが、**その表の列に
           あるものだけ**を採る（2026-11-24）。接頭辞は作業領域の項目にも
           付いていることがあり（`W020-STACD` は AWKKFP の列ではなく
           FILE STATUS の項目）、混ぜると INSERT が落ちる。
        """
        s = self._settou(f)
        d = {}
        if not s:
            return d
        fa = self.f.get(f)
        aru = None
        if fa is not None and getattr(fa, 'db', None) is not None:
            try:
                aru = {c[0] for c in fa.db.TABLES[fa.hyo]['cols']}
            except Exception:
                aru = None
        for na, (r, k) in self.hyo.items():
            if not na.startswith(s) or not k.kata:
                continue
            retsu = na[len(s):]
            if k.occurs:
                for i in range(k.occurs):
                    for nm in ('%s_%d' % (retsu.ljust(6, '_')
                                          if len(retsu) < 6 else retsu, i + 1),
                               '%s_%d' % (retsu, i + 1)):
                        if aru is None or nm in aru:
                            d[nm] = self.V(na, kai=i)
            elif aru is None or retsu in aru:
                d[retsu] = self.V(na)
        d.pop('STSCD', None)
        return d

    # ── そのほか ────────────────────────────
    def hyouji(self, mono, saki='DSP'):
        print('[%s] %s' % (saki, ' '.join(str(x) for x in mono)))

    def uketoru(self, moto):
        k = self._kyou or datetime.datetime.now()
        if moto == 'DATE':
            return '%02d%02d%02d' % (k.year % 100, k.month, k.day)
        if moto == 'TIME':
            return '%02d%02d%02d' % (k.hour, k.minute, k.second)
        if moto == 'DAY':
            return '%02d%03d' % (k.year % 100, k.timetuple().tm_yday)
        return ''

    # ASP が用意している呼び出し。中身は運用側の仕組みなので、
    # ここでは「呼ばれたことを覚える」だけにする（結果に影響しない）。
    ASP = {
        'XMROTSTR': 'トランザクション開始',
        'XMROTEND': 'トランザクション終了',
        'XMROTCNL': 'トランザクション取消',
        'XMSNDMSG': 'メッセージ送信',
        'XMRCVMSG': 'メッセージ受信',
    }

    def yobu(self, na, hiki):
        na = str(na).strip().upper()
        if na in self.ASP:
            self.yonda = getattr(self, 'yonda', [])
            self.yonda.append(na)
            return
        hoka = getattr(self, 'HOKA', None)
        if hoka and na in hoka:
            return hoka[na](self, hiki)
        raise Mikansei('CALL %s' % na, 0)
