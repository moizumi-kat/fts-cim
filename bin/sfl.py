# -*- coding: utf-8 -*-
"""富士通ASPの保存ファイル（.SFL）から、レコードをそのまま取り出す。

  ■ 分かったこと（2026-11-20 実測。ABANMP を CSV と1バイトずつ突き合わせて確定）
    ・先頭は EBCDIC の "SIB2IFADLIB" ではじまる容れ物。しばらくヘッダが続き、
      そのあとに**固定長のレコードがすきま無く**並ぶ。
    ・1レコードの形
        +0        1バイト  レコードの印（生きている＝0x80）
        +1 から   定義の順に項目が並ぶ
    ・項目の入りかた（表定義の型と1対1）
        char(n)      … EBCDIC n バイト
        nchar(n)     … JEF  n×2 バイト
        numeric(n,0) … ゾーン10進 n バイト（EBCDIC の F0-F9）
        decimal(n,m) … パック10進 (n+2)÷2 バイト（最後の半バイトが符号）
    ・レコード長は**表定義から計算できる**（印1バイト＋各項目）。
      ABANMP は 271 バイトで、現物の並び（271間隔）と一致した。
    ・データの始まる位置はファイルごとに違うので、**レコードとして
      筋が通る位置を探して**決める（下の さがす）。
    ・そこから先は**固定長の枠がすきま無く並ぶ**。枠の印が 0x80 でないものは
      空き枠（消したあと・予備）なので飛ばす。
      CCALMP で実証：4,864 から 51 バイトごとに枠が並び、生きている枠だけを
      拾うと 1096＋730＋365＋10227 ＝ **12,418件 でCSVと完全一致**した。
      空き枠の境目はすべて 51 の倍数＝同じ枠割りの上に乗っている。
"""
import re, sys, pathlib

try:
    from . import teigitai_moji            # JEF の読み取りを使い回す
except Exception:
    import teigitai_moji

SEI = 0x80                                  # 生きているレコードの印


def naga(ty):
    """列の型 → バイト数。

       varchar／nvarchar は**先頭2バイトに長さ**を持つ（可変長項目）。
       これが ABUHMP の謎の正体だった（2026-11-20）。部品名称4,994件すべての
       先頭に付いていた「文字でない2バイト」は、**長さの欄**。
       CSVへ書き出すときに、その2バイトごと文字として出てしまっていた。
    """
    m = re.match(r'(nvarchar|varchar|char|nchar|numeric|decimal)\((\d+)(?:,(\d+))?\)',
                 str(ty))
    if not m:
        raise ValueError('知らない型: %r' % ty)
    k, a = m.group(1), int(m.group(2))
    if k == 'char':
        return a
    if k == 'nchar':
        return a * 2
    if k == 'varchar':
        return a + 2
    if k == 'nvarchar':
        return a * 2 + 2
    if k == 'numeric':
        return a
    return (a + 2) // 2


def rec_naga(cols):
    return 1 + sum(naga(c[1]) for c in cols)


def _zone(b, shou=0):
    """ゾーン10進（EBCDIC の数字）→ 文字の数字。

       shou は小数の桁数。COBOL は小数点を**持たず**桁で表すので、
       numeric(5,1) の "00001" は 0.1 になる（ASUNMP の重量で実測）。"""
    out = []
    for c in b:
        if 0xF0 <= c <= 0xF9:
            out.append(chr(0x30 + (c - 0xF0)))
        elif 0xC0 <= c <= 0xC9:          # 正の符号つき最下位桁
            out.append(chr(0x30 + (c - 0xC0)))
        elif 0xD0 <= c <= 0xD9:          # 負
            out.append(chr(0x30 + (c - 0xD0)))
            s = ''.join(out)
            if shou:
                s = (s[:-shou] or '0') + '.' + s[-shou:]
            return '-' + s
        elif c == 0x40:
            out.append('0')              # 空白は0とみなす（現行もそう動く）
        else:
            return None
    s = ''.join(out)
    if shou:
        s = (s[:-shou] or '0') + '.' + s[-shou:]
    return s


def _pack(b, shou):
    """パック10進 → 文字の数。最後の半バイトが符号（C/F=正 D=負）。"""
    ke = []
    for c in b:
        ke.append(c >> 4); ke.append(c & 0x0F)
    fugo = ke.pop()
    if any(k > 9 for k in ke):
        return None
    s = ''.join(str(k) for k in ke)
    if shou:
        s = (s[:-shou] or '0') + '.' + s[-shou:]
    return ('-' if fugo == 0x0D else '') + s


def _ebcdic(b):
    return b.decode('cp500', 'replace')


def _jef(b):
    return teigitai_moji._nibyte(b)


def hitotsu(rec, cols):
    """1レコードのバイト列 → {列名: 値}。筋が通らなければ None。"""
    d = {}
    i = 1
    for na, ty, _ja, _pic in cols:
        n = naga(ty)
        b = rec[i:i+n]
        if len(b) < n:
            return None
        k = str(ty)
        if k.startswith('nvarchar'):
            ln = b[0] * 256 + b[1]
            if ln > n - 2:
                return None
            d[na] = _jef(b[2:2+ln])
        elif k.startswith('varchar'):
            ln = b[0] * 256 + b[1]
            if ln > n - 2:
                return None
            d[na] = _ebcdic(b[2:2+ln])
        elif k.startswith('nchar'):
            d[na] = _jef(b)
        elif k.startswith('char'):
            d[na] = _ebcdic(b)
        elif k.startswith('numeric'):
            m = re.match(r'numeric\((\d+),(\d+)\)', k)
            v = _zone(b, int(m.group(2)) if m else 0)
            if v is None:
                return None
            d[na] = v
        else:
            m = re.match(r'decimal\((\d+),(\d+)\)', k)
            v = _pack(b, int(m.group(2)))
            if v is None:
                return None
            d[na] = v
        i += n
    return d


def sagasu(b, cols, hoshii=3):
    """データの始まる位置を探す。**連続して筋の通るレコード**が
       hoshii 件そろう最初の位置を採る。"""
    n = rec_naga(cols)
    for st in range(0, min(len(b) - n, 200000)):
        if b[st] != SEI:
            continue
        ok = 0
        for k in range(hoshii):
            p = st + k * n
            if p + n > len(b):
                break
            if b[p] != SEI or hitotsu(b[p:p+n], cols) is None:
                break
            ok += 1
        if ok >= min(hoshii, (len(b) - st) // n):
            return st, n
    return None, n


def yomu(michi, cols):
    """.SFL 1本 → ([ {列名: 値} ], データの先頭位置, 飛ばした空き枠の数)。"""
    b = pathlib.Path(michi).read_bytes()
    st, n = sagasu(b, cols)
    if st is None:
        return [], 0, 0
    out = []
    aki = 0
    for p in range(st, len(b) - n + 1, n):
        if b[p] != SEI:
            aki += 1
            continue
        d = hitotsu(b[p:p+n], cols)
        if d is None:
            aki += 1
            continue
        out.append(d)
    return out, st, aki


# ── 型の当て直し ────────────────────────────────
"""■ なぜ要るか（2026-11-20 実測）
   表定義（cim/schema_gen）の numeric／decimal は、出どころが
   ファイル一覧のPDFだったり変換表だったりで、**ゾーン10進かパック10進かが
   表によって食い違う**。
     ABANMP … 作成日は decimal（パック5バイト）＝現物と合う
     AHATMP … 作成日は numeric（ゾーン8バイト）と書いてあるが、
               現物の枠は81バイトで、パック（5バイト）でないと合わない
   原文のコピー原文は手元に無い（5本だけ）ので、**現物の並びから当て直す**。
   当て方は「枠の長さが合い、かつ全レコードが筋の通る形で読めること」。
"""

def _tsukuri(cols, pakku):
    """pakku（パックにする列名の集合）を当てはめた列定義を返す。"""
    out = []
    for na, ty, ja, pic in cols:
        k = str(ty)
        if na in pakku and k.startswith('numeric'):
            m = re.match(r'numeric\((\d+),(\d+)\)', k)
            ty = 'decimal(%s,%s)' % (m.group(1), m.group(2))
        elif na not in pakku and k.startswith('decimal'):
            m = re.match(r'decimal\((\d+),(\d+)\)', k)
            if m.group(2) == '0':
                ty = 'numeric(%s,0)' % m.group(1)
        out.append((na, ty, ja, pic))
    return out


def _tameshi(b, cols):
    """この列定義で読めるか試す。読めた件数を返す。"""
    st, n = sagasu(b, cols, hoshii=3)
    if st is None:
        return 0, None, 0
    rec, aki = [], 0
    for p in range(st, len(b) - n + 1, n):
        if b[p] != SEI:
            aki += 1; continue
        d = hitotsu(b[p:p+n], cols)
        if d is None:
            aki += 1; continue
        rec.append(d)
    return len(rec), st, aki


def ateru(michi, cols):
    """現物に合う列定義を探し当てる。

       戻り値 (列定義, レコード, 先頭位置)。見つからなければ (None, [], 0)。
       試す順番
         1. 表定義そのまま
         2. 作成日・更新日・更新時間など**日付時刻らしい列**をパックに
         3. 小数桁のある列をパックに
         4. 2と3のくみあわせ
    """
    b = pathlib.Path(michi).read_bytes()
    suu = [c[0] for c in cols if str(c[1]).startswith(('numeric', 'decimal'))]
    hiduke = [c[0] for c in cols
              if str(c[1]).startswith(('numeric', 'decimal'))
              and re.search(r'(DAY|TIM|HI|YMD|NICHI)$', c[0])]
    shosu = [c[0] for c in cols
             if re.match(r'(numeric|decimal)\(\d+,[1-9]\)', str(c[1]))]
    ima = {c[0] for c in cols if str(c[1]).startswith('decimal')}
    kouho = [ima,
             ima | set(hiduke),
             ima | set(shosu),
             ima | set(hiduke) | set(shosu),
             set(hiduke),
             set(hiduke) | set(shosu),
             set(),
             set(suu)]
    ichiban = (0, None, None, 0)
    mita = []
    for p in kouho:
        if p in mita:
            continue
        mita.append(p)
        c2 = _tsukuri(cols, p)
        n, st, aki = _tameshi(b, c2)
        if n > ichiban[0]:
            ichiban = (n, c2, st, aki)
    if not ichiban[1]:
        return None, [], 0
    c2, st = ichiban[1], ichiban[2]
    rec, _st, _aki = yomu(michi, c2)
    return c2, rec, st


# ── 現物の枠長から型を解く ──────────────────────────
"""■ なぜ要るか（2026-11-20 実測）
   表定義の型は出どころがまちまちで、現物と食い違うことがある。
     ・numeric と書いてあるがパック10進（AHATMP の作成日）
     ・varchar と書いてあるが**固定長で入っている**（ABKNFP。SQL Server へ
       移すときの書き方であって、オフコンの並びではない）
   そこで、現物から**枠の長さ**を測り、その長さになる型の組み合わせを
   探して、実際に全件読めるものを採る。推測ではなく現物に合わせる。
"""

def waku_nagasa(b, atari=None, haba=400):
    """現物から枠の長さを測る。0x80 の印が等間隔に並ぶことを使う。"""
    ins = [i for i in range(len(b)) if b[i] == SEI]
    if len(ins) < 8:
        return []
    mi = {}
    lo, hi = (max(8, atari - haba), atari + haba) if atari else (8, 1200)
    inset = set(ins)
    hajime = ins[len(ins)//4]
    for n in range(lo, hi + 1):
        k = 0
        p = hajime
        while p + n < len(b) and k < 400:
            if p not in inset:
                break
            k += 1; p += n
        if k >= 8:
            mi[n] = k
    return [n for n, _ in sorted(mi.items(), key=lambda kv: (-kv[1], kv[0]))[:6]]


def _erabi(ty):
    """その列が取りうるバイト数（現物でありうる形）。"""
    k = str(ty)
    m = re.match(r'(nvarchar|varchar|char|nchar|numeric|decimal)\((\d+)(?:,(\d+))?\)', k)
    if not m:
        return []
    shu, a = m.group(1), int(m.group(2))
    b = int(m.group(3) or 0)
    if shu == 'char':
        return [('char(%d)' % a, a)]
    if shu == 'nchar':
        return [('nchar(%d)' % a, a * 2)]
    if shu == 'varchar':                        # 固定長 か 長さ2バイト付き
        return [('char(%d)' % a, a), ('varchar(%d)' % a, a + 2)]
    if shu == 'nvarchar':
        return [('nchar(%d)' % a, a * 2), ('nvarchar(%d)' % a, a * 2 + 2)]
    # 数はゾーンかパックか
    return [('numeric(%d,%d)' % (a, b), a), ('decimal(%d,%d)' % (a, b), (a + 2) // 2)]


def waku_tanmatsu(b):
    """端末ＩＤ（WKSTN…）の出てくる間隔から枠の長さを測る。
       0x80 の並びで測れない表（空き枠が続く表）でも、こちらなら測れる。"""
    import collections
    w = 'WKSTN'.encode('cp500')
    ichi = []; i = -1
    while True:
        i = b.find(w, i + 1)
        if i < 0:
            break
        ichi.append(i)
    if len(ichi) < 4:
        return []
    c = collections.Counter(ichi[k+1] - ichi[k] for k in range(len(ichi) - 1))
    return [n for n, k in c.most_common(4) if 8 <= n <= 4000 and k >= 3]


def toku(michi, cols, kouho=None, tameshi=40):
    """現物に合う型の組み合わせを解く。(列定義, レコード, 先頭位置)。"""
    b = pathlib.Path(michi).read_bytes()
    try:
        atari = rec_naga(cols)
    except Exception:
        atari = None
    nagasa = kouho or (waku_tanmatsu(b) + waku_nagasa(b, atari))
    nagasa = list(dict.fromkeys(nagasa))
    eri = [_erabi(c[1]) for c in cols]
    if any(not e for e in eri):
        return None, [], 0
    for N in nagasa:
        mato = N - 1                              # 印1バイトを除く
        # 動的計画法で「合計が mato になる選び方」を数通り作る
        michi_dp = [{} for _ in range(len(cols) + 1)]
        michi_dp[0][0] = []
        for i, e in enumerate(eri):
            tsugi = michi_dp[i + 1]
            for s, sen in michi_dp[i].items():
                for j, (_ty, ln) in enumerate(e):
                    t = s + ln
                    if t <= mato and t not in tsugi:
                        tsugi[t] = sen + [j]
            if len(tsugi) > 20000:
                break
        sen = michi_dp[len(cols)].get(mato)
        if sen is None:
            continue
        c2 = [(c[0], eri[i][sen[i]][0], c[2], c[3]) for i, c in enumerate(cols)]
        n, st, _aki = _tameshi(b, c2)
        if n >= 1:
            rec, _st, _a = yomu(michi, c2)
            if rec:
                return c2, rec, st
    return None, [], 0


def yomitoru(michi, cols):
    """まず定義どおり、だめなら現物の枠長から解く。"""
    c2, rec, st = ateru(michi, cols)
    if rec:
        return c2, rec, st
    return toku(michi, cols)
