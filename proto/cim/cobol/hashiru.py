# -*- coding: utf-8 -*-
"""変換したプログラムを動かす土台。

   bin/cob2py が出す Python は、ここにある Pgm を継ぐ。
   COBOL の「記憶域」「索引ファイル」「画面」「呼び出し」の受け皿。
"""
from decimal import Decimal, ROUND_HALF_UP, ROUND_DOWN
import datetime
import re
import pathlib

from .kioku import Ryoiki, Komoku
from . import fairu as F

SPACE = '\x00SPACE'            # MOVE SPACE の印（型を見て空白かゼロに変わる）
TAKAI = '\x00HIGH'
HIKUI = '\x00LOW'
SEIJOU, OWARI, NASHI, JYUUFUKU = '00', '10', '23', '22'
NAIFAIRU = '35'          # OPEN したがファイルが無い

# 日本語の名前で書く集団項目（表には列として無い）。cob2py/data.py の
# _GUN_JA と同じ中身。RECORD KEY に集団項目を書くことがあるので
# （`RECORD KEY １０－年度区分 １０－組織コード`）、鍵は列へ開く。
_GUN_JA_KAGI = {
    '組織コード': ('BSYOCD', 'TANCD'),      # 部所コード(2)＋係コード(2)
}

_FDEF = None


def _fdef_gun(hyo, db=None):
    """その表の**集団項目** {名前: [子の列名]} を定義体から返す（2026-11-26）。

       英名（YMD）と見出しの日本語名（年月日）の両方を鍵にして返す。
       もとは `bin/gen_fdef_rec.py` が .SMB 1,061本から起こした
       `cim/fdef_rec.json`。無ければ空で動く（決め打ちの表だけになる）。
    """
    global _FDEF
    if _FDEF is None:
        import json
        _FDEF = {}
        for m in (pathlib.Path(__file__).resolve().parent.parent
                  / 'fdef_rec.json',):
            try:
                _FDEF = json.loads(m.read_text(encoding='utf-8'))
            except Exception:
                _FDEF = {}
    na = [hyo]
    try:
        na += list(db.TABLES[hyo].get('ronri') or [])
    except Exception:
        pass
    out = {}
    for x in na:
        for g in ((_FDEF.get(x) or {}).get('gun') or []):
            out.setdefault(g['na'], g['ko'])
            if g.get('ja'):
                out.setdefault(g['ja'], g['ko'])
    return out


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


class Kazu(Decimal):
    """数字項目の値。**文字リテラルとも比べられる**ようにしたもの。

       ■ なぜ要るか（2026-11-26 実測）
         原文は数字項目を文字リテラルと比べることがある。
             03  END-FLG  PIC 9(01).
             PERFORM UNTIL RED-FLG = "OK" OR END-FLG = "1"
         ＣＯＢＯＬ はこれを数として比べて真になるが、Python では
         `Decimal('1') == '1'` が偽。そのため終わりの印を立てても
         ループが抜けず、**ＳＱＬを1本も出さずに回り続けていた**
         （B10200PP。20秒で 1,899,469回 READ していた）。
       ■ どう比べるか
         相手が文字なら、**数として読めれば数で**、読めなければ
         文字どうしで比べる。`Moji`（文字項目）が数と比べられるのと対。
    """

    def _soroeru(self, h):
        if not isinstance(h, str):
            return None, None
        s = h.strip()
        try:
            return Decimal(self), Decimal(s or 0)
        except Exception:
            return str(self), s

    def __eq__(self, h):
        a, b = self._soroeru(h)
        if a is not None:
            return a == b
        return Decimal.__eq__(self, h)

    def __ne__(self, h):
        r = self.__eq__(h)
        return r if r is NotImplemented else (not r)

    def __lt__(self, h):
        a, b = self._soroeru(h)
        return a < b if a is not None else Decimal.__lt__(self, h)

    def __le__(self, h):
        a, b = self._soroeru(h)
        return a <= b if a is not None else Decimal.__le__(self, h)

    def __gt__(self, h):
        a, b = self._soroeru(h)
        return a > b if a is not None else Decimal.__gt__(self, h)

    def __ge__(self, h):
        a, b = self._soroeru(h)
        return a >= b if a is not None else Decimal.__ge__(self, h)

    def __hash__(self):
        return Decimal.__hash__(self)


# ＳＱＬite の値の変換は**型がぴったり一致したものだけ**使われる。
# `Decimal` 用の登録（cim/db.py）は派生クラスには効かないので、
# ここで `Kazu` も同じやり方で登録する。でないとＳＱＬの引数に渡した
# ところで ProgrammingError になる（2026-11-26 実測）。
try:
    import sqlite3 as _sqlite3
    _sqlite3.register_adapter(Kazu, str)
except Exception:
    pass


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

    def _uzume(self, hoka):
        """文字どうしは**短いほうの右を空白で埋めて**から比べる。

           ■ ＣＯＢＯＬ の決まり（2026-11-25 実測で判明）
             `IF SEL-FLG = "ON"` は、SEL-FLG が X(003) なら
             `"ON "` と `"ON "` を比べるので**真**。
             そのまま比べていたため `'ON ' != 'ON'` となり、
             `PERFORM … UNTIL SEL-FLG = "ON"` が終わらなかった
             （A30120PP ほか。10秒で打ち切られていた）。
           ■ 値そのものは桁を詰めたまま持つ
             末尾の空白を落とすと、画面やファイルへ書くときに桁が変わる。
             **比べるときだけ**そろえる。
        """
        if not isinstance(hoka, str):
            return None, None
        a, b = str(self), str(hoka)
        n = max(len(a), len(b))
        return a.ljust(n), b.ljust(n)

    def __lt__(self, h):
        a, b = self._soroeru(h)
        if a is not None:
            return a < b
        a, b = self._uzume(h)
        if a is not None:
            return a < b
        return str.__lt__(self, h)

    def __le__(self, h):
        a, b = self._soroeru(h)
        if a is not None:
            return a <= b
        a, b = self._uzume(h)
        if a is not None:
            return a <= b
        return str.__le__(self, h)

    def __gt__(self, h):
        a, b = self._soroeru(h)
        if a is not None:
            return a > b
        a, b = self._uzume(h)
        if a is not None:
            return a > b
        return str.__gt__(self, h)

    def __ge__(self, h):
        a, b = self._soroeru(h)
        if a is not None:
            return a >= b
        a, b = self._uzume(h)
        if a is not None:
            return a >= b
        return str.__ge__(self, h)

    def __eq__(self, h):
        a, b = self._soroeru(h)
        if a is not None:
            return a == b
        a, b = self._uzume(h)
        if a is not None:
            return a == b
        return str.__eq__(self, h)

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


class GamenDeta(Exception):
    """画面がきまった回数だけ書かれたので、わざと止めた（異常ではない）。

       試作画面で「最初の1枚を見る」ために使う。`gamen_tome` を立てた
       ときだけ飛ぶ。既定は立てないので、本来の動きは変わらない。
    """


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
        # ファイル → [(原文の鍵の名前, [(列名, 長さ), …])]
        self.f_kagi_bu = {}
        # OPEN したのに表をつなげられなかったファイル（後で人に見せる）
        self.hyo_nai = set()
        # 索引でないファイル（VLD のメッセージ列・画面・帳票）へ書いたもの。
        # 表が無いので、ここに貯めて後ろの処理へ渡す。
        self.kaita = {}
        # 非蓄積型論理宛先（VLD）・作業ファイルの待ち行列。
        # 書いたものを同じ走りの中で読み返せるようにする。
        self.machi = {}
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
                kagi, bu = [], []
                for k in (d.get('kagi') or []):
                    hira = self._kagi_hiraku(
                        self._kagi_retsu(k, hyo, db), hyo, db)
                    kagi += [x[0] for x in hira]
                    bu.append((k, hira))
                self.f_kagi_bu[na] = bu
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
            t = self._rec_sagasu(na)
        if t is None:
            raise Mikansei('知らない項目 %s' % na, 0)
        return t

    def _rec_sagasu(self, na):
        """`接頭辞－…レコード` を、そのファイルの 01 レコードとみなす。

           ■ なぜ要るか（2026-11-25 実測）
             `INITIALIZE １０－生産実績レコードＬ１` のように、原文は
             コピー原文（XFDLIB）に書かれた**01 レコードの名前**で
             レコードまるごと動かす。コピー原文が手元に無いので、
             この綴りだけは定義体からも表定義からも起こせない。
           ■ 安全側にするための縛り
             ・**レコードを指す綴り**に限る（レコード／REC／FD で終わる）
             ・その接頭辞の 01 が**ちょうど1つ**のときだけ
             当てはまらなければ、従来どおり「知らない項目」で止める。
        """
        if not re.search(r'(レコード.{0,3}|REC|FD)$', na):
            return None
        for sep in ('-', '\uff0d'):
            if sep not in na:
                continue
            moto = na.split(sep, 1)[0]
            atari = [k for k in self.ryoiki
                     if k.split('-', 1)[0] == moto
                     or k.split('\uff0d', 1)[0] == moto]
            if len(atari) == 1:
                r = self.ryoiki[atari[0]]
                k = r.hyo.get(atari[0])
                if k is not None:
                    return r, k
            return None
        return None

    def V(self, na, kai=0, oya=None, kiri=None):
        r, k = self._hiku(na, oya)
        if k.kata is None:                     # 集団項目は生のまま
            v = Moji(r.nama(k, kai).decode('cp932', 'replace'))
        else:
            # 表の見出しは項目自身の名前（EDIT-STATUS OF 件名カナ など）
            v = r.toru(k.na, kai) if k.na in r.hyo else r.nama(k, kai)
            if isinstance(v, str):
                v = Moji(v)
            elif isinstance(v, Decimal) and not isinstance(v, Kazu):
                v = Kazu(v)          # 文字リテラルとも比べられるように
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

    def hatsu(self, na, kai=None, oya=None):
        """INITIALIZE。英数は空白・数はゼロに戻す。

           kai を付けると**その回だけ**戻す（`INITIALIZE W020-NOTBL(2)` の形。
           表ぜんぶを戻してしまうと他の回を壊すので、回を指定する）。
           oya は修飾（`INITIALIZE AJKN-REC OF AJKNML1`）の OF のうしろ。
        """
        r, k = self._hiku(na, oya)
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
                # ■ 節の外への GO TO（2026-11-25）
                #   COBOL は節をまたいで GO TO でき、飛び先から**そのまま
                #   順に**続く。節の中しか探していなかったので6本が
                #   抜けていた。
                mina = [d for _s, d, _m in self._jun()]
                if e.saki in mina:
                    return self._zentai(mina.index(e.saki))
                # ■ 飛び先が**節の名前**のこともある（2026-11-26 実測）
                #   `AURIFL1-NEXTREAD-RTN SECTION.` の中から
                #   `GO TO AURIFL1-NEXTREAD-RTN`（自分の節の先頭へ戻る）と
                #   書く形。段落名だけ探していたので外へ抜けていた
                #   （B10222PP）。
                if e.saki == na:
                    i = 0; continue
                k = self._setsu_saki(e.saki)
                if k is not None:
                    return self._zentai(k)
                raise
            i += 1

    def _zentai(self, k):
        """節をまたいだ GO TO の飛び先から、原文の終わりまで順に動かす。"""
        zen = list(self._jun())
        na = [d for _s, d, _m in zen]
        i = k
        while i < len(zen):
            me = zen[i][2]
            if me is None:
                i += 1; continue
            try:
                getattr(self, me)()
            except _Tobu as e:
                if e.saki in na:
                    i = na.index(e.saki); continue
                k = self._setsu_saki(e.saki)
                if k is not None:
                    i = k; continue
                raise
            i += 1

    def _setsu_saki(self, saki):
        """飛び先が**節の名前**なら、その節の最初の段落の位置を返す。"""
        for k, (sna, _d, _m) in enumerate(self._jun()):
            if sna == saki:
                return k
        return None

    def _thru(self, kara, made):
        """PERFORM 〜 THRU 〜。

           ■ 飛び先は段落とは限らない（2026-11-25 実測）
             `PERFORM KOMK-RTN THRU KOMK-EXT` の KOMK-RTN は**節**で、
             KOMK-EXT はその節の中の段落。段落名だけで探していたため
             8本が「段落が無い」で止まっていた（コピー原文の不足ではない）。
             節の名前なら、その節の**最初の段落**を始まりに、
             **最後の段落**を終わりに読み替える。
        """
        zen = list(self._jun())
        na = [d for _s, d, _m in zen]
        setsu_a = {}
        setsu_b = {}
        for k, (sna, _d, _m) in enumerate(zen):
            setsu_a.setdefault(sna, k)
            setsu_b[sna] = k

        def _saki(x, owari=False):
            if x in na:
                return na.index(x)
            if x in setsu_a:
                return setsu_b[x] if owari else setsu_a[x]
            return None

        a, b = _saki(kara), _saki(made, True)
        if a is None or b is None:
            raise Mikansei('PERFORM %s THRU %s' % (kara, made), 0)
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
        # 区切りは ASCII の `-` と**全角ハイフン U+FF0D** のどちらもある。
        # 全角を見ていなかったので `WRITE 新営業－営業日報照会マスタ` の
        # 書き先が引けなかった（13本・2026-11-25）。
        # ここへ来るのは WRITE／READ／START など**レコードまるごと**の
        # 操作だけなので、接頭辞でファイルを決めてよい。
        for sep in ('-', '\uff0d'):
            if sep not in na:
                continue
            s = na.split(sep, 1)[0] + sep
            for f, d in self.FAIRU.items():
                for k in d.get('kagi', []):
                    if k.startswith(s):
                        return f
            break
        # 01 レコード名が FD と同じ綴りのこともある
        for f, d in self.FAIRU.items():
            if (d.get('ronri') or '').upper().startswith(na.upper()[:4]):
                return f
        # ■ 接頭辞の 01 がちょうど1つなら、そのファイルとみなす（2026-11-26）
        #   原文は `WRITE １３－部所出力順レコード` と**コピー原文に書かれた
        #   日本語の 01 名**で書く。コピー原文は手元に無く、定義体にも
        #   見出しが入っていないので、この綴りはどこからも起こせない
        #   （B30005PB・NOUJU09S）。
        #   _rec_sagasu（項目を引くとき）と同じ縛りで安全側にする。
        #     ・**レコードを指す綴り**に限る（レコード／REC／FD で終わる）
        #     ・その接頭辞の 01 が**ちょうど1つ**のときだけ
        if re.search(r'(レコード.{0,3}|REC|FD)$', na):
            for sep in ('-', '\uff0d'):
                if sep not in na:
                    continue
                moto = na.split(sep, 1)[0]
                atari = [k for k in self.ryoiki
                         if k.split('-', 1)[0] == moto
                         or k.split('\uff0d', 1)[0] == moto]
                if len(atari) == 1 and atari[0] in self.FD_REC:
                    return self.FD_REC[atari[0]]
                break
        return na

    @staticmethod
    def _kagi_hiraku(c, hyo, db):
        """鍵が集団項目なら、中の列へ開く（2026-11-24）。

           `RECORD KEY １０－年度区分 １０－組織コード` のように**集団項目**を
           鍵に書くことがある。組織コードは表に列が無い（部所コード＋係コード）
           ので、そのまま使うと `no such column: 組織コード` になった（15本）。
        """
        try:
            kata = {x[0]: x[1] for x in db.TABLES[hyo]['cols']}
        except Exception:
            return [(c, None)]
        if c in kata:
            return [(c, None)]
        # 決め打ちの表 → 無ければ**定義体の集団項目**（2026-11-26）
        bu = _GUN_JA_KAGI.get(c) or _fdef_gun(hyo, db).get(c)
        if not bu or not all(b in kata for b in bu):
            return [(c, None)]
        # 値を切り分けるので、**長さが一意に決まる列だけ**開く。
        #   文字  char(n)/nchar(n) … n 文字
        #   数字  numeric(d,0)     … d 桁（小数があるものは開かない）
        # ＣＣＡＬＭＬ１ の `RECORD KEY IS YMD`（年4＋月2＋日2）がこれ。
        # 数字は str で切ったあと int に戻す（列が数のままなので、
        # 文字で渡すと SQL が別物として扱い、黙って0件になる）。
        naga = []
        for b in bu:
            k2 = str(kata[b])
            mm = re.match(r'n?char\((\d+)\)', k2)
            if mm:
                naga.append((b, int(mm.group(1)), False))
                continue
            mm = re.match(r'(?:numeric|decimal)\((\d+),\s*0\)', k2)
            if mm:
                naga.append((b, int(mm.group(1)), True))
                continue
            return [(c, None)]         # 開かない（ここで止まって人が見る）
        return naga

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
        """READ／START に渡す鍵の値。

           集団項目を鍵に書いた形（`RECORD KEY １０－組織コード`）では
           列が2つに開かれているので、**値も長さで切り分ける**。
           切り分けないと zip で片方が落ち、WHERE が1列ぶん緩くなって
           別のレコードを読む（黙って間違うので必ず切る）。
        """
        bu = self.f_kagi_bu.get(f)
        if not bu:
            d = self.FAIRU.get(f, {})
            return [self.V(k) for k in d.get('kagi', [])]
        atai = []
        for na, hira in bu:
            v = self.V(na)
            if len(hira) == 1:
                atai.append(v)
                continue
            keta = sum(x[1] for x in hira)
            if isinstance(v, str):
                mo = v
            else:
                # 数をまとめて入れた集団項目（`MOVE WK-DATE TO YMD`）は
                # **桁いっぱいまで0で埋めて**から切る。20261126 → 2026/11/26
                mo = str(v).split('.')[0].rjust(keta, '0')
            i = 0
            for x in hira:
                n = x[1]
                kire = mo[i:i+n]
                if len(x) > 2 and x[2]:
                    try:
                        kire = int(kire or 0)
                    except ValueError:
                        pass
                atai.append(kire)
                i += n
        return atai

    def f_yomu(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            st = self._machi_yomu(f)
            if st is not None:
                # ■ ＦＩＬＥ ＳＴＡＴＵＳ を書いてから返す（2026-11-26 実測）
                #   表を持たないファイル（ＶＬＤ・作業ファイル）の READ は
                #   ここで返っていたが、**状態を書いていなかった**ので
                #   原文の `EVALUATE U10-STATUS` がどちらにも当たらず、
                #   `PERFORM UNTIL … END-FLG = "1"` が終わらなかった
                #   （B10200PP。ＳＱＬを1本も出さずに回り続けていた）。
                #   `hiraku`／`tojiru` で同じ抜けを直したのと同じ形。
                self.f_jotai[f] = st
                self._jotai_kaku(f, st)
                return st
            raise Mikansei('READ %s（表が無い）' % f, 0)
        # ■ ACCESS MODE IS SEQUENTIAL の索引ファイルも順読み（2026-11-25）
        #   `READ 営業日報マスタ AT END …` は順読みで、終わりなら "10"。
        #   乱読みにしていたため「該当なし(23)」が返り、AT END が働かず
        #   `GO TO 主処理０１０` で回り続けていた（9本が時間切れ）。
        mode = (self.FAIRU.get(f) or {}).get('mode')
        if 'NEXT' in soe or fa.jun or mode == 'SEQUENTIAL':
            st = fa.tsugi()
        else:
            st = fa.yomu(*self._kagi(f))
        self.f_jotai[f] = st
        if st == SEIJOU:
            self._rec_ireru(f, fa)
        self._jotai_kaku(f, st)
        return st

    def _machi_yomu(self, f):
        """表を持たないファイル（VLD・作業ファイル）の READ。

           ■ なぜ要るか（2026-11-24 実測）
             `FD 更新ＶＬＤ１. COPY A1VLD001.`（ASP の「非蓄積型論理宛先」）
             のように、**表ではなくプログラム間の受け渡し**に使うファイルが
             ある。READ を「表が無い」で止めていたため59本が止まっていた。
           ■ どうするか
             同じ走りの中で WRITE されたものを順に返す。
             空なら COBOL の決まりどおり AT END（"10"）。
             **索引ファイルなのに表が無い場合は、ここへ来ない**（本当の
             取りこぼしなので、従来どおり止めて人に見せる）。
        """
        d = self.FAIRU.get(f)
        if d is None or d.get('kumi') == 'INDEXED':
            return None
        nami = self.machi.get(f) or []
        if not nami:
            self.f_jotai[f] = OWARI
            self._jotai_kaku(f, OWARI)
            return OWARI
        moto, nama = nami.pop(0)
        r = self.ryoiki.get(moto)
        if r is not None and nama:
            n = min(len(r.b), len(nama))
            r.b[:n] = nama[:n]
        self.f_jotai[f] = SEIJOU
        self._jotai_kaku(f, SEIJOU)
        return SEIJOU

    def f_hajime(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            d = self.FAIRU.get(f)
            if d is not None and d.get('kumi') != 'INDEXED':
                self.f_jotai[f] = SEIJOU
                self._jotai_kaku(f, SEIJOU)
                return SEIJOU
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
                nama = bytes(r.b) if r is not None else b''
                self.kaita.setdefault(f, []).append(nama)
                # 読み返せるように、待ち行列にも積む（下の f_yomu 参照）
                self.machi.setdefault(f, []).append((moto, nama))
                self.f_jotai[f] = SEIJOU
                self._jotai_kaku(f, SEIJOU)
                tome = getattr(self, 'gamen_tome', 0)
                if tome and sum(len(v) for v in self.kaita.values()) >= tome:
                    raise GamenDeta()
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
        """そのファイルの項目につく接頭辞（AJBG- や 新営業－ など）。

           区切りは ASCII の `-` と**全角ハイフン U+FF0D** のどちらもある。
           全角を見ていなかったので、日本語の接頭辞のファイルでは
           読んだレコードを項目へ配れず、書くときは列が0個の
           INSERT になって `near ")": syntax error` が出た（2026-11-25）。
        """
        d = self.FAIRU.get(f, {})
        for k in d.get('kagi', []):
            for sep in ('-', '\uff0d'):
                if sep in k:
                    # 記憶域には**英名＋ASCIIの `-`** で入っている
                    # （JOINING 新営業 → 新営業-SYOCD）。原文の鍵は
                    # 全角ハイフンで書かれるので、ここで ASCII に直す。
                    return k.split(sep, 1)[0] + '-'
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

    def _rec_toru_01(self, f):
        """接頭辞の無いファイルの書き先を、**その 01 レコードから**集める。

           ■ なぜ要るか（2026-11-26 実測）
             `FD C10020S1. COPY C10020S1 OF XFDLIB.`（JOINING なし）だと
             項目に接頭辞が付かないので、接頭辞で集める従来のやり方では
             **1列も集まらず** `INSERT INTO C10020S1 () VALUES ()` になり
             「near ")": syntax error」で止まっていた（C10020PB）。
             以前は表が無く別の道を通っていたので表に出なかった。
           ■ どう集めるか
             01 レコードには**ファイル名の別名**が入っている（kumitate の
             `_rec_betsumei` が必ず足す）。それでレコードを特定し、
             その中の**型のある項目で、かつその表の列にあるもの**だけ採る。
             値は `oya=` でレコード名を指定して引く。同じ名前の列
             （SEIBAN など）が他のファイルにもあるので、指定しないと
             別のレコードの値を書いてしまう。
        """
        fa = self.f.get(f)
        aru = None
        if fa is not None and getattr(fa, 'db', None) is not None:
            try:
                aru = {c[0] for c in fa.db.TABLES[fa.hyo]['cols']}
            except Exception:
                aru = None
        for rna, r in self.ryoiki.items():
            if f not in r.hyo:
                continue
            d = {}
            for na, k in r.hyo.items():
                if not k.kata:
                    continue
                # 項目名には接頭辞が付いていることがある（`１３-SOSICD`）。
                # 列名はそのままなので、**接頭辞を外した形も試す**。
                kouho = [na]
                for sep in ('-', '\uff0d'):
                    if sep in na:
                        kouho.append(na.split(sep, 1)[1])
                        break
                for retsu in kouho:
                    if k.occurs:
                        tsuketa = False
                        for i in range(k.occurs):
                            for nm in ('%s_%d' % (retsu.ljust(6, '_')
                                                  if len(retsu) < 6 else retsu,
                                                  i + 1),
                                       '%s_%d' % (retsu, i + 1)):
                                if aru is None or nm in aru:
                                    d[nm] = self.V(na, kai=i, oya=rna)
                                    tsuketa = True
                        if tsuketa:
                            break
                    elif aru is None or retsu in aru:
                        d[retsu] = self.V(na, oya=rna)
                        break
            d.pop('STSCD', None)
            if d:
                return d
        return {}

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
            # 接頭辞（JOINING）の無いファイルは、**その 01 レコードから**集める。
            return self._rec_toru_01(f)
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

    # 呼んだ先のプログラム（原文を写したもの）の覚え
    _YONDA_CLS = {}
    _FUKASA = 0

    _PGMID = None

    @staticmethod
    def _pgmid_hiku(na):
        """ＰＲＯＧＲＡＭ-ＩＤ → 原文のファイル。無ければ None。

           857本を1回だけ走査して索引を作る（2回目からは覚えている）。
        """
        if Pgm._PGMID is None:
            import os, pathlib as _p, re as _re
            Pgm._PGMID = {}
            ne = _p.Path(__file__).resolve().parent.parent.parent.parent
            moto = None
            if os.environ.get('FTSCIM_SRC'):
                moto = _p.Path(os.environ['FTSCIM_SRC'])
            for m in (moto, ne / 'cim' / 'utf8', ne.parent / 'cim' / 'utf8'):
                if m and m.exists():
                    moto = m
                    break
            if moto and moto.exists():
                for x in sorted(moto.glob('*.COB')):
                    try:
                        s = x.read_text(encoding='utf-8', errors='replace')
                    except Exception:
                        continue
                    mm = _re.search(r'PROGRAM-ID[.\s]+([A-Z0-9#@$-]+)', s, _re.I)
                    if mm:
                        Pgm._PGMID.setdefault(mm.group(1).upper(), x)
        return Pgm._PGMID.get(str(na).strip().upper())

    @staticmethod
    def _yobu_kumu(na):
        """CALL の相手の原文を写して、クラスを返す。無ければ None。

           原文は FTSCIM_SRC（既定は cim/utf8）から探す。
           一度写したら覚えておく（同じプログラムを何度も写さない）。
        """
        if na in Pgm._YONDA_CLS:
            return Pgm._YONDA_CLS[na]
        import os, pathlib as _p, types as _t
        moto = _p.Path(os.environ.get('FTSCIM_SRC', '')) if os.environ.get(
            'FTSCIM_SRC') else None
        kouho = []
        if moto:
            kouho.append(moto / ('%s.COB' % na))
        ne = _p.Path(__file__).resolve().parent.parent.parent.parent
        kouho += [ne / 'cim' / 'utf8' / ('%s.COB' % na),
                  ne.parent / 'cim' / 'utf8' / ('%s.COB' % na)]
        f = next((x for x in kouho if x.exists()), None)
        if f is None:
            # ■ ファイル名と ＰＲＯＧＲＡＭ-ＩＤ が違う（2026-11-27 実測）
            #   `BANKIN1S.COB` の中身は `PROGRAM-ID. BANKIN1O.`。
            #   ＣＬ も ＣＯＢＯＬ も **ＰＲＯＧＲＡＭ-ＩＤ** で呼ぶので、
            #   ファイル名で探すと見つからない。857本中**192本**が該当。
            #   ＡＳＰ の決まり（原文の名前と呼び名が別）。
            f = Pgm._pgmid_hiku(na)
        if f is None:
            Pgm._YONDA_CLS[na] = None
            return None
        try:
            # 写し取りの道具（cob2py）の置き場を、呼ぶ側に頼らず自分で通す
            import sys as _sys
            for _b in (ne / 'fts-cim-repo' / 'bin',
                       ne.parent / 'fts-cim-repo' / 'bin'):
                if _b.exists() and str(_b) not in _sys.path:
                    _sys.path.insert(0, str(_b))
            from cob2py import kumitate
            honbun, _d = kumitate.kumu(str(f))
            m = _t.ModuleType(na)
            exec(compile(honbun, na, 'exec'), m.__dict__)
            cls = next(v for k, v in m.__dict__.items()
                       if isinstance(v, type)
                       and getattr(v, 'KIOKU', None) is not None and k != 'Pgm')
        except Exception:
            cls = None
        Pgm._YONDA_CLS[na] = cls
        return cls

    def _iriguchi_yobu(self):
        """原文の先頭の節（段落だけなら本文の節）を動かす。"""
        from cob2py.tetsuzuki import na_py
        for sna, dan in self.DANRAKU:
            if sna.startswith('__'):
                for dna, dme in dan:
                    if not dna.startswith('__') and dme:
                        return self._setsu(sna)
                continue
            me = na_py(sna)
            if hasattr(self, me):
                return getattr(self, me)()
        return None

    def _hiki_utsusu(self, saki, hiki, uke):
        """引数を**生バイトのまま**写す（COBOL は参照渡し）。"""
        for a, b in zip(hiki, uke):
            try:
                r1, k1 = self._hiku(a)
                r2, k2 = saki._hiku(b)
            except Exception:
                continue
            n = min(k1.naga, k2.naga)
            r2.b[k2.ichi:k2.ichi + n] = r1.b[k1.ichi:k1.ichi + n]

    def yobu(self, na, hiki):
        na = str(na).strip().upper()
        if na in self.ASP:
            self.yonda = getattr(self, 'yonda', [])
            self.yonda.append(na)
            return
        hoka = getattr(self, 'HOKA', None)
        if hoka and na in hoka:
            return hoka[na](self, hiki)
        # ■ 原文のあるプログラムは、その場で動かす（2026-11-25）
        #   COBOL の CALL 〜 USING は**参照渡し**なので、呼ぶ前に引数を
        #   相手の受取項目へ生バイトで写し、終わったら書き戻す。
        if Pgm._FUKASA >= 8:
            raise Mikansei('CALL %s（呼び出しが深すぎます）' % na, 0)
        cls = Pgm._yobu_kumu(na)
        if cls is None:
            raise Mikansei('CALL %s' % na, 0)
        ko = cls(con=self.con, db=self.db, sousa=self.sousa, kyou=self._kyou)
        uke = list(getattr(ko, 'UKETORI', []) or [])
        self._hiki_utsusu(ko, hiki, uke)
        Pgm._FUKASA += 1
        try:
            ko._iriguchi_yobu()
        except (ExitProgram, StopRun):
            pass
        finally:
            Pgm._FUKASA -= 1
        ko._hiki_utsusu(self, uke, hiki)      # 戻す
        return
