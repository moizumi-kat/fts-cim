# -*- coding: utf-8 -*-
"""DATA DIVISION（レコードの形）を読む。

  ■ なにを読むか
      01/03/05/77 … 階層。01 と 77 が一番上
      PIC X(n)   … 英数 n バイト
      PIC N(n)   … 全角 n 文字＝2n バイト
      PIC 9(n)   … 数 n 桁。V で小数点、S で符号
      COMP-3     … パック10進 (桁+2)÷2 バイト
      COMP / COMP-4 / BINARY … 2進（桁で 2/4/8 バイト）
      OCCURS n   … 繰返し
      REDEFINES  … 同じ場所を別の名前で見る
      VALUE      … 初期値
      FILLER     … 名前なし（場所だけ取る）
      88         … 条件名（値の別名。場所は取らない）

  ■ なぜバイトで持つか
    REDEFINES と 集団項目への MOVE を**現行どおり**にするには、
    項目を「バイトの並びの上の位置と長さ」として持つしかない。
    （桁あふれの切れかたまで合わせるため。CLAUDE.md の「同じ結果」）
"""
import re

SUU = re.compile(r'^(S?)(9+|9\((\d+)\))(V(9+|9\((\d+)\))?)?$', re.I)


class Ko:
    """項目ひとつ。"""

    def __init__(self, level, na):
        self.level = level
        self.na = na
        self.dan = []             # 繰返しの刻み（外側から順。多次元の表のため）
        self.pic = None
        self.kata = None          # 'X' 英数 / 'N' 全角 / '9' 数 / None 集団
        self.keta = 0             # 数の整数部＋小数部の桁数、文字なら文字数
        self.shou = 0             # 小数の桁数
        self.fugo = False         # S
        self.comp = None          # None=表示形 / '3'=パック / '4'=2進
        self.occurs = 0
        self.redefines = None
        self.value = None
        self.ko = []
        self.oya = None
        self.ichi = 0             # 先頭からのバイト位置
        self.naga = 0             # バイト数（繰返し1回ぶん）

    def __repr__(self):
        return '<%02d %s %s %d@%d>' % (self.level, self.na, self.pic or '集団',
                                       self.naga, self.ichi)

    # ── 大きさ ────────────────────────────────
    def hitotsu_naga(self):
        """繰返し1回ぶんのバイト数。"""
        if self.ko:
            n = 0
            for k in self.ko:
                if k.level == 88 or k.redefines:
                    continue
                n += k.naga * max(1, k.occurs)
            return n
        if self.kata == 'N':
            return self.keta * 2
        if self.kata == 'X':
            return self.keta
        if self.kata == '9':
            if self.comp == '3':
                return (self.keta + 2) // 2
            if self.comp == '4':
                return 2 if self.keta <= 4 else (4 if self.keta <= 9 else 8)
            return self.keta
        return 0

    def mina(self):
        yield self
        for k in self.ko:
            yield from k.mina()


def _pic(ko, s):
    """PIC の中身を読む。"""
    ko.pic = s
    u = s.upper()
    m = re.match(r'^X+$|^X\((\d+)\)$', u)
    if m:
        ko.kata = 'X'; ko.keta = int(m.group(1)) if m.group(1) else len(u)
        return
    m = re.match(r'^N+$|^N\((\d+)\)$', u)
    if m:
        ko.kata = 'N'; ko.keta = int(m.group(1)) if m.group(1) else len(u)
        return
    m = SUU.match(u)
    if m:
        ko.kata = '9'
        ko.fugo = bool(m.group(1))
        sei = int(m.group(3)) if m.group(3) else len(m.group(2))
        sho = 0
        if m.group(4):
            g = m.group(5) or ''
            sho = int(m.group(6)) if m.group(6) else len(g)
        ko.keta = sei + sho
        ko.shou = sho
        return
    # Z や , の入った編集用（帳票の見出しなど）。桁だけ数える
    n = len(re.sub(r'[^9Z0*$,./+-]', '', u))
    ko.kata = 'X'; ko.keta = max(1, n)


def yomu(go, hajime, owari):
    """語の並び（go[hajime:owari]）から、01 の並びを組み立てる。"""
    i = hajime
    ne = []          # 一番上（01・77）の並び
    tsumi = []       # いま開いている階層
    while i < owari:
        g = go[i]
        if not (g.shu == 'su' and re.fullmatch(r'\d{1,2}', g.v)):
            i += 1; continue
        level = int(g.v)
        if level not in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 20, 25,
                         30, 49, 66, 77, 88):
            i += 1; continue
        i += 1
        if i >= owari:
            break
        na = go[i].v if go[i].shu == 'na' else 'FILLER'
        if go[i].shu == 'na':
            i += 1
        ko = Ko(level, na)
        # 句を読む（次の . まで）
        while i < owari and not (go[i].shu == 'ki' and go[i].v == '.'):
            t = go[i]
            if t.na('PIC', 'PICTURE'):
                i += 1
                if i < owari and go[i].na('IS'):
                    i += 1
                s = go[i].v
                # X(10) のように括弧が別の語になることがある
                if i + 1 < owari and go[i+1].shu == 'ki' and go[i+1].v == '(':
                    s += '(' + go[i+2].v + ')'
                    i += 3
                _pic(ko, s)
            elif t.na('OCCURS'):
                i += 1
                ko.occurs = int(re.sub(r'\D', '', go[i].v) or 1)
            elif t.na('REDEFINES'):
                i += 1
                ko.redefines = go[i].v
            elif t.na('VALUE', 'VALUES'):
                i += 1
                if i < owari and go[i].na('IS', 'ARE'):
                    i += 1
                ko.value = go[i].v if go[i].shu != 'na' else go[i].v.upper()
            elif t.na('COMP-3', 'COMPUTATIONAL-3', 'PACKED-DECIMAL'):
                ko.comp = '3'
            elif t.na('COMP', 'COMP-4', 'COMP-5', 'BINARY',
                      'COMPUTATIONAL', 'COMPUTATIONAL-4'):
                ko.comp = '4'
            i += 1
        i += 1          # . をとばす
        if level in (1, 77):
            tsumi = [ko]; ne.append(ko)
        else:
            while tsumi and tsumi[-1].level >= level:
                tsumi.pop()
            if not tsumi:
                ne.append(ko); tsumi = [ko]; continue
            ko.oya = tsumi[-1]
            tsumi[-1].ko.append(ko)
            tsumi.append(ko)
    for k in ne:
        _ookisa(k)
        _ichi(k, 0)
        _dan(k)
    return ne


def _ookisa(k):
    for c in k.ko:
        _ookisa(c)
    k.naga = k.hitotsu_naga()


def _dan(k, oya_dan=()):
    """その項目にかかる繰返しの刻みを、外側から順に並べる。

       COBOL の表は入れ子になる（01 の下の 03 OCCURS 10 の下の 05 OCCURS 7）。
       X (i, j) の位置は 先頭 ＋ 外の刻み×i ＋ 内の刻み×j。
    """
    ima = list(oya_dan)
    if k.occurs:
        ima.append(k.naga)
    k.dan = ima
    for c in k.ko:
        _dan(c, ima)


def _ichi(k, ichi):
    k.ichi = ichi
    p = ichi
    mae = {}
    for c in k.ko:
        if c.level == 88:
            c.ichi = p; continue
        if c.redefines:
            c.ichi = mae.get(c.redefines, p)
        else:
            c.ichi = p
            p += c.naga * max(1, c.occurs)
        mae[c.na] = c.ichi
        _ichi(c, c.ichi)


# ── FILE-CONTROL（どのファイルがどの表か）────────────
"""■ 読み取るもの（A10040PO.COB で実測）
     SELECT 鑑ファイル ASSIGN TO DA-01-VI-AJBGFL1
            ORGANIZATION IS INDEXED
            RECORD KEY   IS AJBG-MITUNO
            ACCESS MODE  IS DYNAMIC
            FILE STATUS  IS AJBG-STSCD
   論理ファイル AJBGFL1 → 物理表 AJBGFP。索引（キー）はここに書いてある。
   項目名 AJBG-MITUNO の接頭辞を外すと列名 MITUNO。
"""

def file_control(go, hajime, owari):
    """FILE-CONTROL → {COBOLのファイル名: {...}}"""
    out = {}
    i = hajime
    while i < owari:
        if not go[i].na('SELECT'):
            i += 1; continue
        i += 1
        if i < owari and go[i].na('OPTIONAL'):
            i += 1
        na = go[i].v; i += 1
        d = {'na': na, 'ronri': None, 'kumi': 'SEQUENTIAL',
             'kagi': [], 'sub': [], 'jotai': None, 'mode': 'SEQUENTIAL'}
        while i < owari and not (go[i].shu == 'ki' and go[i].v == '.'):
            g = go[i]
            if g.na('ASSIGN'):
                i += 1
                while i < owari and go[i].na('TO'):
                    i += 1
                if i < owari:
                    v = go[i].v
                    d['ronri'] = v.split('-')[-1]
                    i += 1
                continue
            if g.na('ORGANIZATION'):
                i += 1
                while i < owari and go[i].na('IS'):
                    i += 1
                d['kumi'] = go[i].v.upper(); i += 1; continue
            if g.na('ACCESS'):
                i += 1
                while i < owari and go[i].na('MODE', 'IS'):
                    i += 1
                d['mode'] = go[i].v.upper(); i += 1; continue
            if g.na('RECORD') and i + 1 < owari and go[i+1].na('KEY'):
                i += 2
                while i < owari and go[i].na('IS'):
                    i += 1
                while i < owari and go[i].shu == 'na' and not go[i].na(
                        'ALTERNATE', 'ACCESS', 'FILE', 'ORGANIZATION',
                        'WITH', 'DUPLICATES', 'SELECT'):
                    d['kagi'].append(go[i].v); i += 1
                continue
            if g.na('ALTERNATE'):
                i += 1
                while i < owari and go[i].na('RECORD', 'KEY', 'IS'):
                    i += 1
                hoka = []
                while i < owari and go[i].shu == 'na' and not go[i].na(
                        'ALTERNATE', 'ACCESS', 'FILE', 'ORGANIZATION',
                        'WITH', 'DUPLICATES', 'SELECT'):
                    hoka.append(go[i].v); i += 1
                if hoka:
                    d['sub'].append(hoka)
                continue
            if g.na('FILE') and i + 1 < owari and go[i+1].na('STATUS'):
                i += 2
                while i < owari and go[i].na('IS'):
                    i += 1
                d['jotai'] = go[i].v; i += 1
                if i < owari and go[i].shu == 'na' and not go[i].na('SELECT'):
                    i += 1          # 第2状態項目
                continue
            i += 1
        out[na] = d
        i += 1
    return out


# ── COPY 〜 OF XMDLIB（画面の記憶域）────────────────
"""■ なぜ組み立てが要るか（2026-11-21）
   画面の記憶域は `COPY A10040D1 OF XMDLIB.` で取り込まれていて、
   **コピー原文が手元に無い**（いただけたのは5本だけ）。
   ただし必要な情報は全部そろっている。
     ・項目の並び・桁・データ長 … 定義体（.SMD）→ cim/teigitai.json
     ・項目の名前               … そのプログラムの「制御項目初期化Ｒ」の
                                  EDIT-STATUS OF 〜 の並び（最長の連なり）
   画面レコードの形は「項目ごとに 制御部5バイト＋データ」。
     制御部 = EDIT-STATUS / EDIT-OPTION / EDIT-COLOR / EDIT-MODE / EDIT-CURSOR
"""
SEIGYO = ('EDIT-STATUS', 'EDIT-OPTION', 'EDIT-COLOR', 'EDIT-MODE', 'EDIT-CURSOR')


def _wakeru(ko_kazu, na_kazu):
    """項目 ko_kazu 個を「見出し atama 個 ＋ 行(na_kazu-atama 個)×n」に割る。

       いちばん行数の多い割り方を採る。割り切れなければ None。
    """
    ichiban = None
    for atama in range(0, na_kazu):
        gyo = na_kazu - atama
        if gyo <= 0:
            continue
        nokori = ko_kazu - atama
        if nokori <= 0 or nokori % gyo:
            continue
        n = nokori // gyo
        if n < 2:
            continue
        if ichiban is None or n > ichiban[1]:
            ichiban = (atama, n)
    return ichiban


def gamen_ko(teigi, namae, kata=None):
    """定義体1本 ＋ 項目名の並び → Ko（01レコード）。合わなければ None。"""
    # R＝入力項目／W＝出力項目。S（区切りの印）は場所を取らないので外す。
    # **記憶域を占める項目は「位置（ichi）が 0 でないもの」**（2026-11-24 実測）。
    # 以前は項目の印が R／W のものだけを採っていたが、印は A〜Z や ] まであり
    # （A10050D1 の 件名かな=A001・件名２=A004・件名３=A002 が落ちていた）、
    # 印で絞るのは誤りだった。位置で絞ると A10040D1 は 55項目・1,123バイトの
    # まま（＝実機で裏取り済みの値を再現）、A10050D1 は 28項目そろう。
    ko = [k for k in teigi['ko'] if k['ichi']]
    ko.sort(key=lambda k: k['ichi'])
    if len(ko) != len(namae):
        # 一覧画面（概算・項目・明細・科目）は「見出し部＋繰返しの行」で、
        # COBOL 側は OCCURS で書くため数が合わない。
        #
        # ここは **推測で割り当てない**（2026-11-21 判断）。
        #   割り切れる組み合わせは何通りもあり、どれが正しいかを決める
        #   根拠が手元に無い（XMDLIB のコピー原文が未入手）。
        #   当てずっぽうで割り当てると、画面に別の項目の値が出たまま
        #   気づけない。そこで **長さだけ正しい入れ物** を作り、名前は
        #   定義体のもの（R001 など）にしておく。COBOL の名前で引いた
        #   ところで止まるので、黙って間違った値を出すことはない。
        #   → XMDLIB のコピー原文をいただければ解決する。
        namae = [k[chr(39)+"nm"+chr(39)] for k in ko] if False else [k["nm"] for k in ko]
    if len(ko) != len(namae):
        # 繰返し行のある一覧画面（概算・項目・明細・科目）は、COBOL 側が
        # OCCURS で書くので数が合わない。ここでは**長さだけ正しい入れ物**を
        # 作り、名前は定義体のもの（R001 など）にしておく。
        # COBOL の名前で引こうとしたところで止まるので、黙って通りはしない。
        namae = [k['nm'] for k in ko]
    oya = Ko(1, teigi['na'])
    ichi = 0
    for k, na in zip(ko, namae):
        g = Ko(3, na)
        g.oya = oya
        for s in SEIGYO:
            c = Ko(5, s + ' OF ' + na)
            c.kata = 'X'; c.keta = 1; c.naga = 1; c.ichi = ichi
            c.oya = g
            g.ko.append(c)
            ichi += 1
        d = Ko(5, na)
        d.kata = (kata or {}).get(na, 'X')
        d.keta = k['naga2']; d.naga = k['naga2']; d.ichi = ichi
        # 小数の桁は定義体の編集から取る（掛率は3桁で小数2桁＝3.60）。
        # 取らないと 3.6 を入れたとき 003 になり、画面が 0.03 と出る。
        if d.kata == '9':
            d.shou = (k.get('hen') or [0, 0, '', 0])[3] or 0
        d.oya = g
        g.ko.append(d)
        ichi += k['naga2']
        g.ichi = g.ko[0].ichi
        g.naga = ichi - g.ichi
        oya.ko.append(g)
    oya.naga = ichi
    return oya


# ── FD のレコード（COPY 〜 OF XFDLIB）────────────────
"""■ なぜ組み立てが要るか（2026-11-21）
   ファイルのレコードも `COPY 〜 OF XFDLIB.` で取り込まれていて、
   コピー原文が手元に無い。ただし必要な情報はそろっている。
     ・列の並び・桁・型 … 表定義（cim/schema_gen・482表20,010列）
     ・項目名の接頭辞   … FILE-CONTROL の RECORD KEY（AJBG-MITUNO → AJBG-）
   COBOL の項目名は「接頭辞＋列名」。これで AJBG-MITUNO が引ける。
"""
import re as _re2


def _kata_kara(ty):
    """SQLの型 → (kata, keta, shou, comp, バイト数)"""
    m = _re2.match(r'(nvarchar|varchar|nchar|char|numeric|decimal)\((\d+)(?:,(\d+))?\)',
                   str(ty))
    if not m:
        return 'X', 1, 0, None, 1
    k, a = m.group(1), int(m.group(2))
    b = int(m.group(3) or 0)
    if k in ('char', 'varchar'):
        return 'X', a, 0, None, a
    if k in ('nchar', 'nvarchar'):
        return 'N', a, 0, None, a * 2
    if k == 'numeric':
        return '9', a, b, None, a
    return '9', a, b, '3', (a + 2) // 2


# 表の列に戻っていない集団項目（根拠を書いてから足すこと）
_GUN = {
    # AJBG-CRTTAN は列に無い。CRTBSY（部所2桁）＋CRTKKR（担当2桁）をまとめた
    # 集団項目。A10040PO 3528-3533行が
    #   MOVE AJBG-CRTTAN TO 担当者ＣＤ / MOVE AJBG-CRTBSY TO ASOS-BSYOCD
    #   / MOVE AJBG-CRTKKR TO ASOS-TANCD  と続けて書いているのが根拠。
    'AJBG-CRTTAN': ('CRTBSY', 'CRTKKR'),
    'AWKG-CRTTAN': ('CRTBSY', 'CRTKKR'),
    # ASUN-SUNPO は 巾＋高さ＋奥行 をまとめたもの。
    # A10040PO 4478-4480行が MOVE AWKM-DW/DH/DD TO ASUN-WIDTH/HIGH/DEPTH、
    # 4348行が MOVE HIGH-VALUE TO ASUN-SUNPO（丸ごと埋める）。
    'ASUN-SUNPO': ('WIDTH', 'HIGH', 'DEPTH'),
}


def _kurikaeshi(cols):
    """表の列 → 繰返しを戻した並び。

       ■ なぜ戻すのか（2026-11-21）
         表の列は、繰返し項目を **BASE_1 BASE_2 …** と横へ展開してある
         （bin/recdef.py の決まり。英名を _ で6文字に詰めて _n を付ける）。
         COBOL 側は `AWKG-KAKRIT (1)` と書くので、戻さないと引けない。
       戻り値 [(名前, 型, 繰返し数)]
    """
    out = []
    i = 0
    while i < len(cols):
        na, ty = cols[i][0], cols[i][1]
        m = _re2.match(r'^(.*?)_+(\d+)$', na)
        if m and m.group(2) == '1':
            moto = m.group(1).rstrip('_')
            n = 1
            j = i + 1
            while j < len(cols):
                m2 = _re2.match(r'^(.*?)_+(\d+)$', cols[j][0])
                if not (m2 and m2.group(1).rstrip('_') == moto
                        and int(m2.group(2)) == n + 1 and cols[j][1] == ty):
                    break
                n += 1; j += 1
            if n > 1:
                out.append((moto, ty, n)); i = j; continue
        out.append((na, ty, 0)); i += 1
    return out


def fd_ko(settou, cols, na=None):
    """接頭辞＋表の列 → Ko（01レコード）。繰返しと集団項目を戻す。"""
    oya = Ko(1, na or (settou + 'REC'))
    ichi = 0
    ichi_hyo = {}
    for cna, ty, occ in _kurikaeshi(cols):
        kata, keta, shou, comp, naga = _kata_kara(ty)
        k = Ko(3, settou + cna)
        k.kata, k.keta, k.shou, k.comp = kata, keta, shou, comp
        k.naga = naga; k.ichi = ichi; k.occurs = occ; k.oya = oya
        k.dan = [naga] if occ else []
        oya.ko.append(k)
        ichi_hyo[cna] = (ichi, naga)
        ichi += naga * max(1, occ)
    # 列に戻っていない集団項目（根拠つき）
    for gna, bu in _GUN.items():
        if not gna.startswith(settou):
            continue
        if all(b in ichi_hyo for b in bu):
            a = ichi_hyo[bu[0]][0]
            owari = ichi_hyo[bu[-1]][0] + ichi_hyo[bu[-1]][1]
            g = Ko(3, gna)
            g.kata = None; g.naga = owari - a; g.ichi = a; g.oya = oya
            oya.ko.append(g)
    oya.naga = ichi
    return oya


def fd_rec(go, hajime, owari):
    """FILE SECTION の「FD ファイル名 … 01 レコード名」の対応を取る。

       WRITE はレコード名で書くので（WRITE REC2）、どのファイルの
       レコードかをここで結びつけないと、書き先が分からない。
    """
    out = {}
    ima = None
    i = hajime
    while i < owari:
        g = go[i]
        if g.na('FD', 'SD') and i + 1 < owari:
            ima = go[i+1].v; i += 2; continue
        if (g.shu == 'su' and g.v in ('01', '1') and ima
                and i + 1 < owari and go[i+1].shu == 'na'):
            out[go[i+1].v] = ima
            i += 2; continue
        if g.na('WORKING-STORAGE', 'LINKAGE'):
            break
        i += 1
    return out
