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
            for (kna, ichi, knaga, kata, keta, shou, fugo, comp, occ) in ko:
                h[kna] = Komoku(kna, ichi, knaga, kata, keta, shou, fugo, comp, occ)
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
        # 索引でないファイル（VLD のメッセージ列・画面・帳票）へ書いたもの。
        # 表が無いので、ここに貯めて後ろの処理へ渡す。
        self.kaita = {}
        if con is not None and db is not None:
            for na, d in self.FAIRU.items():
                if d.get('kumi') != 'INDEXED' or not d.get('kagi'):
                    continue
                hyo = (d['ronri'] or '')[:-3] + 'FP' if (d['ronri'] or '').endswith('FL1') \
                    else (d['ronri'] or '')
                hyo = self._hyomei(d['ronri'])
                kagi = [k.split('-', 1)[-1] for k in d['kagi']]
                try:
                    self.f[na] = F.Fairu(con, hyo, kagi, d['ronri'], db=db)
                except Exception:
                    pass
                self.f_jotai[na] = SEIJOU

    # ── 名前から表を引く ─────────────────────────
    @staticmethod
    def _hyomei(ronri):
        """論理ファイル名 → 物理表名。AJBGFL1→AJBGFP／ASOSML1→ASOSMP。"""
        if not ronri:
            return ''
        if len(ronri) >= 3 and ronri[-3] in 'FML' and ronri[-2:].isdigit():
            return ronri[:-3] + ('FP' if ronri[-3] == 'F' else 'MP')
        if ronri.endswith(('FL1', 'ML1', 'ML3')):
            return ronri[:-3] + ('FP' if ronri[-3] == 'F' else 'MP')
        return ronri

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
        if oya and oya in self.ryoiki:
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
            v = r.nama(k, kai).decode('cp932', 'replace')
        else:
            v = r.toru(na, kai) if na in r.hyo else r.nama(k, kai)
        if kiri is not None:
            s = v if isinstance(v, str) else str(v)
            a = int(kiri[0]) - 1
            n = None if kiri[1] is None else int(kiri[1])
            b = s.encode('cp932', 'replace')
            b = b[a:a + n] if n is not None else b[a:]
            return b.decode('cp932', 'replace')
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
        r.ireru(na, v, kai)

    def J(self, na):
        """88レベル（条件名）。いまは写していないので止める。"""
        raise Mikansei('条件名 %s（88レベル）' % na, 0)

    def hatsu(self, na):
        """INITIALIZE。英数は空白・数はゼロに戻す。"""
        r, k = self._hiku(na)
        for kna, kk in r.hyo.items():
            if kk.ichi < k.ichi or kk.ichi + kk.naga > k.ichi + k.naga:
                continue
            if kk.kata == '9':
                r.ireru(kna, 0)
            elif kk.kata in ('X', 'N'):
                r.nama_ireru(kk, b' ' * kk.naga)

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
        self.f_jotai[f] = SEIJOU

    def tojiru(self, f):
        self.f_jotai[f] = SEIJOU

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

    def _kagi(self, f):
        d = self.FAIRU.get(f, {})
        return [self.V(k) for k in d.get('kagi', [])]

    def f_yomu(self, f, *soe):
        f = self._fname(f)
        fa = self.f.get(f)
        if fa is None:
            raise Mikansei('READ %s（表が無い）' % f, 0)
        if 'NEXT' in soe:
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
        s = self._settou(f)
        d = {}
        if not s:
            return d
        for na, (r, k) in self.hyo.items():
            if not na.startswith(s) or not k.kata:
                continue
            retsu = na[len(s):]
            if k.occurs:
                for i in range(k.occurs):
                    d['%s_%d' % (retsu.ljust(6, '_') if len(retsu) < 6 else retsu,
                                 i + 1)] = self.V(na, kai=i)
                    d['%s_%d' % (retsu, i + 1)] = self.V(na, kai=i)
            else:
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

    def yobu(self, na, hiki):
        raise Mikansei('CALL %s' % na, 0)
