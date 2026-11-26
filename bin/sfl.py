# -*- coding: utf-8 -*-
"""富士通ASPの保存ファイル（.SFL）から、レコードをそのまま取り出す。

  ■ 出どころ（2026-11-24）
    村上様が SFL.zip に同梱してくださった **sfl2csv.ps1**（.SFL を CSV にする
    PowerShell）が、形式を正確に書き起こしている。ここはその仕様どおりに作った。
    → genbutsu/20261124_SFL/sfl2csv.ps1
    それまでは「筋の通るレコードが並ぶ位置を探す」という当てもので読んでいた。
    当てものは120本中80本しか刻みを当てられず、**SF編成を取り違えていた**
    （SF編成はブロック構造なので、すきま無く並んでいない）。

  ■ 形式は 256バイト境界のブロックで見分ける
    PF編成（物理ファイル）… どこかの 256バイト境界に EBCDIC "CNTL" がある
      CNTL +0x10  レコード長（2バイト）
      CNTL +0x20  有効件数（4バイト）
      CNTL +0x24  総件数（削除済みを含む・4バイト）
      データ部は CNTL +0x800 から。
        1枠 ＝ 印1バイト（0x80 有効／0x00 削除済み）＋レコード
        印が 0xFF で終わり。
    SF編成（順編成ファイル）… 0x300 に EBCDIC "FLB " がある
      0x328  レコード長（2バイト）
      0x32A  1ブロックのレコード数
      0x32B  ブロック長（512バイト単位）
      データ部は 0x500 から。各ブロックの先頭4バイトは
        件数（2バイト）＋ブロック番号（2バイト）。件数 0x8000 のブロックで終わり。
      **SF編成はファイルの中に項目定義を持たない** → 定義体（.SMB）から与える。

  ■ 値の入りかた（型は定義体の X/N/U/P）
    X … EBCDIC（cp037）n バイト
    N … JEF n バイト。0x4040 は全角空白。どちらも 0xA1〜0xFE なら EUC-JP と同じ。
    U … ゾーン10進。各バイトの下位4ビットが数字。最後のバイトの上位が 0xD0 なら負。
    P … パック10進。16進にして最後の1桁が符号（D か B なら負）。
    小数は桁で表す（COBOL は小数点を持たない）ので、定義の小数桁で割る。
"""
import re, pathlib
from decimal import Decimal

try:
    from . import teigitai_moji            # JEF の読み取りを使い回す
except Exception:
    import teigitai_moji

SEI = 0x80                                  # 有効なレコードの印
KESHI = 0x00                                # 削除済み
OWARI = 0xFF                                # 終わりの印

_CNTL = bytes((0xC3, 0xD5, 0xE3, 0xD3))     # EBCDIC "CNTL"
_FLB = bytes((0xC6, 0xD3, 0xC2, 0x40))      # EBCDIC "FLB "


def _u16(b, o):
    return b[o] * 256 + b[o + 1]


def _u32(b, o):
    return _u16(b, o) * 65536 + _u16(b, o + 2)


# ── 形式を見分けて、レコードの位置を並べる ───────────
def kaiseki(michi_ka_byte):
    """.SFL → {'kata','naga','ichi','yuukou','soukei','kesu','owari_made'}

       ichi は**有効なレコードの先頭位置**の並び。
    """
    b = (michi_ka_byte if isinstance(michi_ka_byte, (bytes, bytearray))
         else pathlib.Path(michi_ka_byte).read_bytes())

    cntl = -1
    for o in range(0, len(b) - 4, 256):
        if b[o:o + 4] == _CNTL:
            cntl = o
            break

    if cntl >= 0:
        naga = _u16(b, cntl + 0x10)
        yuukou = _u32(b, cntl + 0x20)
        soukei = _u32(b, cntl + 0x24)
        ichi, kesu = [], 0
        p = cntl + 0x800
        while p + naga < len(b) and b[p] != OWARI:
            if b[p] == SEI:
                ichi.append(p + 1)
            else:
                kesu += 1
            p += naga + 1
        return {'kata': 'PF', 'naga': naga, 'ichi': ichi, 'yuukou': yuukou,
                'soukei': soukei, 'kesu': kesu,
                'owari_made': p + naga < len(b)}

    if b[0x300:0x304] != _FLB:
        raise ValueError('CNTL も FLB も見つかりません（未対応の形式）')

    naga = _u16(b, 0x328)
    hako = b[0x32A]                          # 1ブロックのレコード数
    hako_naga = b[0x32B] * 512               # ブロック長
    ichi = []
    p = 0x500
    while p + 4 <= len(b):
        kazu = _u16(b, p)
        if kazu == 0x8000:
            break
        if kazu > hako:
            raise ValueError('ブロックの件数が不正（0x%X で %d 件）' % (p, kazu))
        for k in range(kazu):
            ichi.append(p + 4 + k * naga)
        p += hako_naga
    return {'kata': 'SF', 'naga': naga, 'ichi': ichi, 'yuukou': len(ichi),
            'soukei': len(ichi), 'kesu': 0, 'hako': hako,
            'hako_naga': hako_naga, 'owari_made': p + 4 <= len(b)}


# ── 型とバイト数 ───────────────────────────────
def naga(ty):
    """列の型 → バイト数。定義体の型と1対1（可変長は無い）。

       以前は varchar／nvarchar に「先頭2バイトの長さ欄」があるとみていたが、
       それは誤りだった（2026-11-24）。ABUHMP 部品名称の謎の2バイトは
       長さ欄ではなく、DDL が char(30) と2バイト足りなかったため
       （定義体では X(32)。実データに32文字が16件ある）。
    """
    m = re.match(r'(nvarchar|varchar|char|nchar|numeric|decimal)\((\d+)(?:,(\d+))?\)',
                 str(ty))
    if not m:
        raise ValueError('知らない型: %r' % ty)
    k, a = m.group(1), int(m.group(2))
    if k in ('char', 'varchar'):
        return a
    if k in ('nchar', 'nvarchar'):
        return a * 2
    if k == 'numeric':
        return a
    return (a + 2) // 2


def rec_naga(cols):
    """列の並び → レコード長（印の1バイトは含めない）。"""
    return sum(naga(c[1]) for c in cols)


# ── 値の取り出し ───────────────────────────────
def _zone(b, shou=0):
    """ゾーン10進。各バイトの下位4ビットが数字。最後の上位が 0xD0 なら負。"""
    if not b:
        return None
    s = ''.join(str(x & 0x0F) for x in b)
    if not s.isdigit():
        return None
    v = Decimal(s)
    if (b[-1] & 0xF0) == 0xD0:
        v = -v
    return v / (10 ** shou) if shou else v


def _pack(b, shou=0):
    """パック10進。16進にして最後の1桁が符号（D か B なら負）。"""
    if not b:
        return None
    s = b.hex().upper()
    fugo, kazu = s[-1], s[:-1]
    if not kazu.isdigit():
        return None
    v = Decimal(kazu)
    if fugo in ('D', 'B'):
        v = -v
    return v / (10 ** shou) if shou else v


SO, SI = 0x28, 0x29          # 日本語の開始／終了コード


def _moji(b):
    """文字項目（X）のバイト列 → 文字。**シフトコードがあれば混じり読み**。

       ■ 根拠（2026-11-26 村上様ご回答）
         「SHIFT1 は日本語データ開始コード X'28'、SHIFT2 は日本語データ
           終了コード X'29'」
         文字項目の中に、この2つで囲んで日本語（ＪＥＦ2バイト）を入れる。
         ＡＢＵＨＭＰ の部品名称は 4,994件のうち **2,901件**がこれを含む。
             4040 e5d4 40 4d 40 f8f0 28 b3d1 29 5d
             ＝「  VM ( 80」＋〈日本語開始〉角〈終了〉＋「)」
         1バイトずつ読んでいたため「  VM ( 80·J)」と化けていた。

       ■ 安全側（方針1-3）
         **開始・終了の対がある項目だけ**混じり読みにする。無い項目は
         これまでどおり1バイトずつ（＝回帰ゼロ）。ＥＢＣＤＩＣ の
         `(` は 0x4D・`)` は 0x5D なので、0x28／0x29 を括弧と
         取り違えることはない。
    """
    if SO in b and SI in b and b.index(SO) < b.rindex(SI):
        return teigitai_moji._mazari(b)
    return teigitai_moji.ebcdic_data(b)


def _ebcdic(b):
    """EBCDIC n バイト → n 文字。**末尾の空白は切らない**（2026-11-24）。

       COBOL の項目は固定長で、現行ファイルは末尾を空白（0x40）で埋めている。
       切ってしまうと、SQL Server の char(n)（桁いっぱいまで空白で埋めて返す）
       と振る舞いが変わり、実データとの突き合わせで食い違う
       （鑑の 件名３・特記事項 で実測。9,796件＋α がずれた）。
    """
    return teigitai_moji.ebcdic_data(b)


def _jef(b):
    """JEF n×2 バイト → n 文字。**末尾の全角空白も切らない**（_ebcdic と同じ理由）。

       外字は**桁が変わらない**置き換えを使う（nibyte_data）。見出し用の
       'No.'（3文字）を使うと固定長の項目で後ろの文字が半分に切れる。
    """
    return teigitai_moji.nibyte_data(b)


KAHEN = {
    # 「先頭2バイト＝後ろに続く有効データのバイト数（2バイトバイナリ）」の
    # **可変長文字項目**。表名 → 列名。
    #
    # ■ 根拠（2026-11-26）
    #   村上様ご回答「定義体の先頭2バイトは後ろに続く有効データのバイト数を
    #   2バイトのバイナリで表したもの。データベースのテーブルにデータを
    #   入れ込むときは先頭2バイトは対象外になります」
    #
    # ■ 定義体には可変長の印が無い（実測）
    #   ABUHMP の PARTNA と PARTCD の項目レコードを 0x00〜0x40 まで
    #   突き合わせたが、違うのは名前・位置・桁だけだった。
    #   ですので**実データで判定する**（`bin/chk_kahencho.py`）。判定は
    #     ① 先頭2バイトの n が 0 ≦ n ≦ 桁数−2
    #     ② 位置 2+n から後ろは全部詰め物（0x40／0x20／0x00）
    #
    # ■ 安全側に寄せている（方針1-3）
    #   取り違えて可変長にすると値が2バイトずれて**黙って間違う**。
    #   ですので**実データで確かめたものと、村上様が名指しされたものだけ**。
    #   同じレイアウトの写し（AWKMFP／FAJBMFP／TAJBMFP／論理ファイル）は
    #   実データが手元に無いので入れていない。届いたら chk_kahencho.py で
    #   判定して足す。
    'ABUHMP':   {'PARTNA'},                  # 部品名称 実測 4,994件すべて一致
    'ASETMP':   {'SETNAM'},                  # セット回路名称 実測 1,987件
    'BUHHOSFP': {'BUHMEI'},                  # 部品補足名称 実測 2,542件（52桁）
    'AJBMFP':   {'NAME___1', 'NAME___2'},    # 名称 村上様が名指しされた2列
    'FAJBMFP':  {'NAME___1', 'NAME___2'},    # 同じレイアウト・実データでも確認
}
# ■ AJBMFP／FAJBMFP の名称が2列ある理由（2026-11-26 実測）
#   定義体は `NAME`（32桁）1項目だが、親の集団項目 `NOTBL`（新旧テーブル）が
#   **ＯＣＣＵＲＳ 2** なので、列は NAME___1（位置34）と NAME___2（位置166・
#   刻み132）の2つになる。村上様が名指しされた NAME___1／NAME___2 はこれ。
#
# ■ 入れていないもの（実データが手元に無い）
#   AWKMFP／TAJBMFP（.SFL が空）・論理ファイル（ABUHML1 等。取り込みは
#   物理ファイルだけなので要らない）。届いたら chk_kahencho.py で判定する。


def kahen_hiku(michi):
    """ファイル名から、その表の可変長項目の列名を返す。

       `AJBMFP1.SFL`／`AJBMFP2.SFL` のように**分割して書き出された**ものが
       あるので（村上様 2026-11-24「AJBMFP1,2,3 ⇒ AJBMFP」）、
       末尾の数字を落としても引く。
    """
    na = pathlib.Path(michi).stem.upper()
    if na in KAHEN:
        return KAHEN[na]
    m = re.match(r'^(.*?)\d+$', na)
    if m and m.group(1) in KAHEN:
        return KAHEN[m.group(1)]
    return frozenset()


def _kahen_atai(bb):
    """可変長文字項目のバイト列 → **先頭2バイトを外した**バイト列。

       桁数は変えない（2バイトぶん右を空白で埋める）。レコードの中の
       位置も、ほかの列の位置も動かさないため。
    """
    n = int.from_bytes(bb[:2], 'big')
    honbun = bb[2:]
    if 0 <= n <= len(honbun):
        honbun = honbun[:n] + b'\x40' * (len(honbun) - n)
    return honbun + b'\x40\x40'


def hitotsu(rec, cols, kahen=()):
    """1レコードのバイト列 → {列名: 値}。筋が通らなければ None。"""
    d = {}
    i = 0
    for na_, ty, _ja, _pic in cols:
        n = naga(ty)
        bb = rec[i:i + n]
        if len(bb) < n:
            return None
        k = str(ty)
        if k.startswith(('nchar', 'nvarchar')):
            d[na_] = _jef(bb)
        elif k.startswith(('char', 'varchar')):
            d[na_] = _moji(_kahen_atai(bb) if na_ in kahen else bb)
        else:
            m = re.match(r'(numeric|decimal)\((\d+),(\d+)\)', k)
            shou = int(m.group(3))
            v = _zone(bb, shou) if m.group(1) == 'numeric' else _pack(bb, shou)
            if v is None:
                return None                  # HIGH-VALUE 等。呼び手が空で埋める
            d[na_] = v
        i += n
    return d


def yomu(michi, cols):
    """.SFL 1本 → ([ {列名: 値} ], データの先頭位置, 読めなかった枠の数)。"""
    kahen = kahen_hiku(michi)
    b = pathlib.Path(michi).read_bytes()
    j = kaiseki(b)
    if j['naga'] != rec_naga(cols):
        raise ValueError('レコード長が合いません（ファイル %d / 定義 %d）'
                         % (j['naga'], rec_naga(cols)))
    out, dame = [], 0
    for p in j['ichi']:
        r = hitotsu(b[p:p + j['naga']], cols, kahen)
        if r is None:
            dame += 1
            continue
        out.append(r)
    return out, (j['ichi'][0] if j['ichi'] else 0), dame


def yomitoru(michi, cols):
    """load_sfl.py 向け。(列の並び, レコードの並び, 先頭位置) を返す。

       型の当て直し（旧 toku）は要らなくなった。レコード長はファイル自身が
       持っており、定義体（.SMB）と合うことを確かめるだけでよい。
    """
    rec, st, _dame = yomu(michi, cols)
    return cols, rec, st


# ── PF編成はファイル自身が項目定義を持つ ─────────────
"""■ どこにあるか（sfl2csv.ps1 より・2026-11-24）
     0x040E  項目数（2バイト）
     1280 + i*32 から1項目32バイト
       +8  (8)  項目名（EBCDIC）
       +16 (2)  1要素のバイト長
       +18 (1)  型（U ゾーン10進／P パック10進／X 英数／N 日本語JEF）
       +20 (2)  桁数
       +24 (2)  レコード内の開始位置（1起点）
       +26 (2)  繰返し1回分のバイト長
       +28 (2)  繰返し回数（0＝繰返しなし）
   **小数の桁はここに無い**（スクリプトも小数点を付けずに出す）。
   小数が要るときは定義体（.SMB）から取る。
"""


def ko_teigi(michi_ka_byte):
    """PF編成の .SFL → 項目定義の並び。SF編成は定義を持たないので [] を返す。"""
    b = (michi_ka_byte if isinstance(michi_ka_byte, (bytes, bytearray))
         else pathlib.Path(michi_ka_byte).read_bytes())
    cntl = -1
    for o in range(0, len(b) - 4, 256):
        if b[o:o + 4] == _CNTL:
            cntl = o
            break
    if cntl < 0:
        return []
    out = []
    for i in range(_u16(b, 0x40E)):
        o = 1280 + i * 32
        if o + 32 > len(b):
            break
        out.append({
            'na': b[o + 8:o + 16].decode('cp037', 'replace').strip(),
            'naga': _u16(b, o + 16),
            'kata': b[o + 18:o + 19].decode('cp037', 'replace'),
            'keta': _u16(b, o + 20),
            'ichi': _u16(b, o + 24),
            'step': _u16(b, o + 26),
            'kaisu': _u16(b, o + 28),
        })
    return out


def hirogeru(ko):
    """項目定義 → (列名, 項目, レコード内のオフセット0起点) の並び。

       **繰返しが「連なり」か「交互」かは 刻み(step) と 長さ(naga) で決まる**
       （2026-11-24 実測）。
         刻み＝長さ … その項目の繰返しが連続して並ぶ（例 AJBGFP MITGAK
                       位置549 長7 刻み7 反復2 → 549, 556）
         刻み＞長さ … 兄弟と交互に並ぶ＝集団項目の繰返し（例 NOKIB4SF
                       KAISHI 位置42 長4 刻み8 反復50、OWARI 位置46 長4 刻み8）
       sfl2csv.ps1 は「同じ刻み・反復の項目をまとめる」としているが、それだと
       AJBGFP の MITGAK と SASKIN（どちらも刻み7・反復2だが連なり）を交互に
       並べてしまう。値は明示オフセットで読むので CSV の値は正しく、列の順だけ
       入れ替わる。ここでは**位置どおりの順**にする（定義体から起こした表定義と
       一致し、422本中392本はもともと一致していた）。
       列名は英名を _ で6文字に詰めて _1, _2 …（変換仕様書4.2）。
    """
    out = []
    i = 0
    while i < len(ko):
        k = ko[i]
        if not k['kaisu']:
            out.append((k['na'], k, k['ichi'] - 1))
            i += 1
            continue
        if k['step'] == k['naga']:
            # 連なり。この項目だけで展開する。
            for n in range(1, k['kaisu'] + 1):
                out.append(('%s_%d' % (k['na'].ljust(6, '_'), n), k,
                            k['ichi'] - 1 + (n - 1) * k['step']))
            i += 1
            continue
        # 交互。同じ刻み・反復で、1回分の中に収まる兄弟をまとめる。
        g = [k]
        j = i + 1
        while (j < len(ko) and ko[j]['kaisu'] == k['kaisu']
               and ko[j]['step'] == k['step']
               and ko[j]['ichi'] < k['ichi'] + k['step']):
            g.append(ko[j])
            j += 1
        for n in range(1, k['kaisu'] + 1):
            for m in g:
                out.append(('%s_%d' % (m['na'].ljust(6, '_'), n), m,
                            m['ichi'] - 1 + (n - 1) * m['step']))
        i = j
    return out


# ── 大きいファイルを逐次に読む ─────────────────────
"""■ なぜ要るか（2026-11-24）
   AJBMFP1.SFL は 1.9GB、AJBKFP1.SFL は 1.7GB ある。ファイルを丸ごと読んで
   レコードを全部リストに持つ作りだとメモリが足りず、取り込みが途中で殺された。
   そこでヘッダだけ読んで、あとは**少しずつ読みながら1件ずつ返す**。
"""
_YOMI = 1 << 23                             # 一度に読む量（8MB）


def _cntl_sagasu(f, kagiri=1 << 26):
    """開いたファイルから CNTL の位置を探す。無ければ -1。256バイト境界のみ見る。"""
    f.seek(0)
    ichi = 0
    nokori = b''
    while ichi < kagiri:
        b = f.read(_YOMI)
        if not b:
            break
        b = nokori + b
        for o in range(0, len(b) - 3, 256):
            if b[o:o + 4] == _CNTL:
                return ichi + o
        tsukatta = (len(b) // 256) * 256
        nokori = b[tsukatta:]
        ichi += tsukatta
    return -1


def atama(michi):
    """.SFL のヘッダだけ読む → {'kata','naga','hajime','yuukou','soukei',...}"""
    with open(michi, 'rb') as f:
        cntl = _cntl_sagasu(f)
        if cntl >= 0:
            f.seek(cntl)
            h = f.read(0x30)
            return {'kata': 'PF', 'naga': _u16(h, 0x10),
                    'yuukou': _u32(h, 0x20), 'soukei': _u32(h, 0x24),
                    'hajime': cntl + 0x800}
        f.seek(0x300)
        h = f.read(0x30)
        if h[:4] != _FLB:
            raise ValueError('CNTL も FLB も見つかりません（未対応の形式）')
        return {'kata': 'SF', 'naga': _u16(h, 0x28), 'hako': h[0x2A],
                'hako_naga': h[0x2B] * 512, 'hajime': 0x500,
                'yuukou': None, 'soukei': None}


def nagare(michi, cols):
    """.SFL を少しずつ読みながら {列名: 値} を1件ずつ返す。

       レコード長が定義と合わなければ、最初に例外にする（黙って読まない）。
    """
    j = atama(michi)
    naga_ = j['naga']
    if naga_ != rec_naga(cols):
        raise ValueError('レコード長が合いません（ファイル %d / 定義 %d）'
                         % (naga_, rec_naga(cols)))
    with open(michi, 'rb') as f:
        if j['kata'] == 'PF':
            waku = naga_ + 1
            f.seek(j['hajime'])
            nokori = b''
            while True:
                b = f.read(max(_YOMI // waku, 1) * waku)
                if not b:
                    return
                b = nokori + b
                n = len(b) // waku
                for i in range(n):
                    p = i * waku
                    if b[p] == OWARI:
                        return
                    if b[p] != SEI:
                        continue
                    r = hitotsu(b[p + 1:p + waku], cols)
                    if r is not None:
                        yield r
                nokori = b[n * waku:]
        else:
            hako, hako_naga = j['hako'], j['hako_naga']
            f.seek(j['hajime'])
            while True:
                b = f.read(hako_naga)
                if len(b) < 4:
                    return
                kazu = _u16(b, 0)
                if kazu == 0x8000:
                    return
                if kazu > hako:
                    raise ValueError('ブロックの件数が不正（%d 件）' % kazu)
                for k in range(kazu):
                    p = 4 + k * naga_
                    r = hitotsu(b[p:p + naga_], cols)
                    if r is not None:
                        yield r
