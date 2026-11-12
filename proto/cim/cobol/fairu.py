# -*- coding: utf-8 -*-
"""COBOL の索引ファイル（ORGANIZATION INDEXED）のふるまいを、表の上で写す。

  ■ 現行の書き方（A10040PO.COB の FILE-CONTROL で実測）
      SELECT 鑑ファイル ASSIGN TO DA-01-VI-AJBGFL1
             ORGANIZATION IS INDEXED
             RECORD KEY   IS AJBG-MITUNO
             ACCESS MODE  IS DYNAMIC
             FILE STATUS  IS AJBG-STSCD
    ＝ **索引（キー）は FILE-CONTROL に書いてある。** XFDLIB は要らない。

  ■ 名前の対応（実測）
      COBOL の項目名   AWKG-MITUNO
                       ───┬── ─┬───
                          │     └ 表の列名 MITUNO
                          └ そのファイルの接頭辞
      論理ファイル AWKGFL1 → 物理ファイル AWKGFP（＝表）

  ■ FILE STATUS（現行が見ている値）
      "00" 正常 ／ "10" もう無い（AT END）／ "22" 同じキーが既にある（WRITE）
      "23" 見つからない（READ・REWRITE・DELETE）
    現行は "00" 以外をほぼ ABEND にしている（AWKGFL1-READ-START 等）。
    ここでは値を返すだけにし、どう扱うかは呼ぶ側（各プログラム）に任せる。
"""

SEIJOU    = '00'
OWARI     = '10'
JYUUFUKU  = '22'
NASHI     = '23'


def _moji_kagi(hyo, kagi):
    """キーのうち、文字の列はどれか。

       ■ なぜ要るか（2026-11-12 実測）
         db._val は読み取った文字の**末尾の半角空白を落とす**。
         SQL Server は char/nchar を桁いっぱいまで空白で埋めて返すが
         SQLite は埋めないので、両方をそろえるためにそうしている。
         ところが COBOL のキーは**固定長**で、発番キーなら "610A  " のように
         空白を含む。読んだときに "610A" になってしまうと、そのまま
         REWRITE／DELETE すると WHERE が外れて「見つからない（23）」になる。
         （実際にそうなった。発番の連番更新が 23 で落ちた。）
       ■ どうするか
         文字のキーは **両側の末尾空白を無いものとして比べる**。
         （RTRIM は SQLite にも SQL Server にもある）
    """
    try:
        from .. import schema_gen
        t = schema_gen.TABLES.get(hyo)
        if not t:
            return set()
        kata = {c[0]: c[1] for c in t['cols']}
        return {k for k in kagi
                if str(kata.get(k, '')).startswith(('char', 'nchar'))}
    except Exception:
        return set()


class Fairu:
    """索引ファイル1つ。ACCESS MODE DYNAMIC（乱＋順）。"""

    def __init__(self, con, hyo, kagi, ronri=None, db=None):
        """con … つなぎ先／hyo … 表名／kagi … キーの列（並び順のまま）"""
        self.con = con
        self.hyo = hyo
        self.kagi = list(kagi)
        self.ronri = ronri or hyo
        self.db = db
        self.moji = _moji_kagi(hyo, self.kagi)    # 末尾空白を見ないで比べる列
        self.rec = {}                 # いま読んでいるレコード
        self.status = SEIJOU
        self._ichi = None             # 順読みの位置（キーの値）
        self._owari = False

    # ── 組み立て ────────────────────────────────
    def _Q(self, n):
        return '[%s]' % n

    def _hidari(self, k):
        """比較の左辺。文字のキーは末尾空白を落として比べる。"""
        return 'RTRIM(%s)' % self._Q(k) if k in self.moji else self._Q(k)

    def _migi(self, k, v):
        """比較の右辺の値。文字のキーは末尾空白を落とす。"""
        return v.rstrip(' ') if (k in self.moji and isinstance(v, str)) else v

    def _where(self, hikaku='='):
        """キーの比較。複数キーは辞書順で比べる。"""
        if hikaku == '=':
            return ' AND '.join('%s = ?' % self._hidari(k) for k in self.kagi)
        # START / READ NEXT 用。(a,b,c) > (?,?,?) を素のSQLで書く。
        #
        #   辞書順の「より大きい」は
        #     (a > A) OR (a = A AND b > B) OR (a = A AND b = B AND c > C)
        #   で、**途中のキーは必ず「＝」と「＞」に分ける。**
        #   最初の項を (a >= A) と書くと、a が同じ行を**全部**拾ってしまい、
        #   START KEY >= (B0000001, 2) が (B0000001, 1) に止まる（実際にやった）。
        #   「以上」は、これに「全部＝」を足したもの。
        joken = []
        for i in range(len(self.kagi)):
            mae = ' AND '.join('%s = ?' % self._hidari(k) for k in self.kagi[:i])
            ato = '%s > ?' % self._hidari(self.kagi[i])
            joken.append('(%s)' % (' AND '.join(filter(None, [mae, ato]))))
        if hikaku == '>=':
            joken.append('(%s)' % ' AND '.join('%s = ?' % self._hidari(k)
                                               for k in self.kagi))
        return ' OR '.join(joken)

    def _junjo(self):
        return ', '.join(self._Q(k) for k in self.kagi)

    def _hikisu(self, atai, hikaku):
        """_where が組んだ順に値を並べる。"""
        v = [self._migi(k, a) for k, a in zip(self.kagi, atai)]
        if hikaku == '=':
            return v
        a = []
        for i in range(len(self.kagi)):
            a += list(v[:i]) + [v[i]]
        if hikaku == '>=':
            a += list(v)                     # 「全部＝」の分
        return a

    # ── 入出力 ──────────────────────────────────
    def yomu(self, *kagi_atai):
        """READ（乱）。キーを指定して1件読む。"""
        if not kagi_atai:
            kagi_atai = tuple(self.rec.get(k) for k in self.kagi)
        sql = 'SELECT * FROM %s WHERE %s' % (self._Q(self.hyo), self._where())
        r = self.db.q1(self.con, sql, tuple(self._hikisu(kagi_atai, '=')))
        if r is None:
            self.status = NASHI
        else:
            self.rec = dict(r)
            self._ichi = tuple(self.rec[k] for k in self.kagi)
            self._owari = False
            self.status = SEIJOU
        return self.status

    def hajime(self, *kagi_atai, ijou=True):
        """START。順読みの開始位置を決める（KEY >= / KEY >）。"""
        hikaku = '>=' if ijou else '>'
        sql = ('SELECT * FROM %s WHERE %s ORDER BY %s'
               % (self._Q(self.hyo), self._where(hikaku), self._junjo()))
        r = self.db.q1(self.con, sql, tuple(self._hikisu(kagi_atai, hikaku)))
        if r is None:
            self.status = NASHI
            self._owari = True
        else:
            # START は位置を決めるだけ。レコードは読まない（現行どおり）
            self._ichi = tuple(r[k] for k in self.kagi)
            self._owari = False
            self.status = SEIJOU
            self._tsugi_wa_ima = True
        return self.status

    def tsugi(self):
        """READ NEXT（順）。もう無ければ "10"（AT END）。"""
        if self._owari:
            self.status = OWARI
            return self.status
        if getattr(self, '_tsugi_wa_ima', False):
            # START の直後は、その位置のレコードが1件目になる
            self._tsugi_wa_ima = False
            sql = ('SELECT * FROM %s WHERE %s ORDER BY %s'
                   % (self._Q(self.hyo), self._where(), self._junjo()))
            r = self.db.q1(self.con, sql, tuple(self._hikisu(self._ichi, '=')))
        else:
            if self._ichi is None:
                sql = 'SELECT * FROM %s ORDER BY %s' % (self._Q(self.hyo), self._junjo())
                r = self.db.q1(self.con, sql, ())
            else:
                sql = ('SELECT * FROM %s WHERE %s ORDER BY %s'
                       % (self._Q(self.hyo), self._where('>'), self._junjo()))
                r = self.db.q1(self.con, sql, tuple(self._hikisu(self._ichi, '>')))
        if r is None:
            self._owari = True
            self.status = OWARI
        else:
            self.rec = dict(r)
            self._ichi = tuple(self.rec[k] for k in self.kagi)
            self.status = SEIJOU
        return self.status

    def kaku(self, rec=None):
        """WRITE。同じキーが既にあれば "22"。"""
        if rec is not None:
            self.rec = dict(rec)
        kagi_atai = tuple(self.rec.get(k) for k in self.kagi)
        sql = 'SELECT * FROM %s WHERE %s' % (self._Q(self.hyo), self._where())
        if self.db.q1(self.con, sql, tuple(self._hikisu(kagi_atai, '='))) is not None:
            self.status = JYUUFUKU
            return self.status
        hashira = list(self.rec.keys())
        sql = ('INSERT INTO %s (%s) VALUES (%s)'
               % (self._Q(self.hyo), ', '.join(self._Q(h) for h in hashira),
                  ', '.join('?' * len(hashira))))
        self.db.ex(self.con, sql, tuple(self.rec[h] for h in hashira))
        self.status = SEIJOU
        return self.status

    def kakinaosu(self, rec=None):
        """REWRITE。無ければ "23"。"""
        if rec is not None:
            self.rec = dict(rec)
        kagi_atai = tuple(self.rec.get(k) for k in self.kagi)
        hashira = [h for h in self.rec if h not in self.kagi]
        sql = ('UPDATE %s SET %s WHERE %s'
               % (self._Q(self.hyo), ', '.join('%s = ?' % self._Q(h) for h in hashira),
                  self._where()))
        cur = self.db.ex(self.con, sql,
                         tuple(self.rec[h] for h in hashira)
                         + tuple(self._hikisu(kagi_atai, '=')))
        self.status = SEIJOU if cur.rowcount else NASHI
        return self.status

    def kesu(self, *kagi_atai):
        """DELETE。無ければ "23"。"""
        if not kagi_atai:
            kagi_atai = tuple(self.rec.get(k) for k in self.kagi)
        sql = 'DELETE FROM %s WHERE %s' % (self._Q(self.hyo), self._where())
        cur = self.db.ex(self.con, sql, tuple(self._hikisu(kagi_atai, '=')))
        self.status = SEIJOU if cur.rowcount else NASHI
        return self.status

    # ── レコードの項目 ──────────────────────────
    def __getitem__(self, na):
        return self.rec.get(na)

    def __setitem__(self, na, v):
        self.rec[na] = v

    def __repr__(self):
        return '<%s(%s) %s=%s>' % (self.ronri, self.hyo, ','.join(self.kagi),
                                   tuple(self.rec.get(k) for k in self.kagi))
