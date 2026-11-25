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


def yomu(go, hajime, owari, teisu=None):
    """語の並び（go[hajime:owari]）から、01 の並びを組み立てる。

       teisu … SPECIAL-NAMES の SYMBOLIC CONSTANT（`組織 IS 13`）。
       `OCCURS 組織` のように**記号定数で回数を書く**ことがあり、
       数字だけ取り出していたため 1 回として組み、表が小さくなって
       添字が領域の外へ出ていた（2026-11-25 実測・SUIHY1CP ほか）。
    """
    teisu = teisu or {}
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
                v = go[i].v
                if v in teisu:
                    v = str(teisu[v])
                elif str(v).upper() in teisu:
                    v = str(teisu[str(v).upper()])
                ko.occurs = int(re.sub(r'\D', '', str(v)) or 1)
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
                # `STATUS` でも切れる。`RECORD KEY F2-RECKBN STATUS F2-STATUS`
                # のように **FILE を省く書き方**があり、STATUS まで
                # キーに取り込んでいた（16本がここで止まっていた・2026-11-24）。
                while i < owari and go[i].shu == 'na' and not go[i].na(
                        'ALTERNATE', 'ACCESS', 'FILE', 'STATUS',
                        'ORGANIZATION', 'WITH', 'DUPLICATES', 'SELECT'):
                    # `RECORD KEY IS SEIBAN OF AJUGFL1` のように**修飾**で
                    # 書くことがある（2026-11-24 実測）。`OF ファイル名` を
                    # 鍵に取り込んでいたため、キーの値を取るときに
                    # `self.V('OF')` を引いて45本が止まっていた。
                    if go[i].na('OF', 'IN'):
                        i += 2                 # OF と、そのうしろの名前を飛ばす
                        continue
                    d['kagi'].append(go[i].v); i += 1
                continue
            if g.na('ALTERNATE'):
                i += 1
                while i < owari and go[i].na('RECORD', 'KEY', 'IS'):
                    i += 1
                hoka = []
                while i < owari and go[i].shu == 'na' and not go[i].na(
                        'ALTERNATE', 'ACCESS', 'FILE', 'STATUS',
                        'ORGANIZATION', 'WITH', 'DUPLICATES', 'SELECT'):
                    hoka.append(go[i].v); i += 1
                if hoka:
                    d['sub'].append(hoka)
                continue
            if g.na('STATUS') and not (i and go[i-1].na('FILE')):
                # `STATUS F2-STATUS`（FILE を省く書き方）
                i += 1
                while i < owari and go[i].na('IS'):
                    i += 1
                if i < owari:
                    d['jotai'] = go[i].v; i += 1
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


_TOSHI = re.compile(r'^[A-Z\]][0-9]+$')


def kioku_aru(k):
    """この項目は記憶域を占めるか（2026-11-25 実測）。

       位置（ichi）が 0 でなければ占める。
       **位置が 0 でも、名前があって見出しの無いものは占める**。
       位置は0起点なので、先頭に実データ項目が来る定義体がある
       （全421本で1,008項目。CHKJBK03 の「タイトル」など）。
       見出し（定義体に焼き付けてある字）は名前を持たないので外れる。
    """
    if k['ichi']:
        return True
    return bool(k.get('cob')) and not (k.get('midashi') or '').strip()


def komoku_na_aru(k):
    """この項目の COBOL での名前が分かっているか（2026-11-24 実測）。

       名前の出どころは2つある。
         ① 定義体の項目名表（`cob`）… R001 のような通し番号の項目に名前が付く
         ② **項目コードそのもの** … 定義体によってはコードが
            `SYURYO` `ERRKMK` のように COBOL の名前になっている
            （D20010D1 ほか。R001／W001／]00001 のような「印＋数字」でなければ名前）
       これを見ると、画面181本のうち119本が全項目に名前がそろう（従来80本）。
    """
    return bool(k.get('cob')) or not _TOSHI.match(k['nm'])


def komoku_na(k):
    """この項目の COBOL での名前（分からなければ定義体のコード）。"""
    return k.get('cob') or k['nm']


def _gyo_kurikaeshi(ko):
    """一覧画面の**繰返し行**を見つける（2026-11-24 実測）。

       定義体は、2行目以降の入力項目を `]00001` `]00002` … という連番で持つ。
       これは**直前の行（雛形）の繰り返し**で、COBOL 側は OCCURS で書く。
         A10060D1 … 雛形 9項目（項番表示／項目区分／製品区分／見積書用品名／
                     品名／数量／単位／掛率／金額）× 15行・刻み113バイト
         A10070D1 … 雛形 6項目 × 10行・刻み82
         A30010D2 … 雛形 6項目 × 16行・刻み79
       **筋が通ることを確かめてからでないと組まない**（長さの並びが雛形と一致し、
       位置が刻みどおりに並び、雛形の全項目に名前があること）。合わなければ
       None を返し、呼んだ側は「長さだけ正しい入れ物」に落とす
       ＝COBOL の名前で引いたところで止まる（黙って別の値を出さない）。
       戻り値 (雛形の開始位置, 雛形の項目数, 行数, 刻み)
    """
    kakko = [i for i, k in enumerate(ko) if k['nm'][:1] == ']']
    if not kakko:
        return None
    if kakko != list(range(kakko[0], kakko[-1] + 1)):
        return None                       # 連なっていない
    i0 = kakko[0]
    if i0 == 0:
        return None
    kl = [ko[i]['naga'] for i in kakko]
    for m in range(1, min(i0, 40) + 1):
        if len(kl) % m:
            continue
        hina = ko[i0 - m:i0]
        if not all(kl[j] == hina[j % m]['naga'] for j in range(len(kl))):
            continue
        kizami = ko[kakko[0]]['ichi'] - hina[0]['ichi']
        if kizami <= 0:
            continue
        if not all(ko[kakko[j]]['ichi']
                   == hina[j % m]['ichi'] + kizami * (j // m + 1)
                   for j in range(len(kl))):
            continue
        if not all(komoku_na_aru(x) for x in hina):
            return None                   # 雛形に名前が無ければ組まない
        return i0 - m, m, len(kl) // m + 1, kizami
    return None


def _gamen_ko_kuri(teigi, ko, kuri, kata=None, rec_na=None, settou=''):
    """繰返し行のある画面の記憶域を組む。位置は**定義体のものをそのまま使う**。

       項目ごとに「制御部5バイト＋データ」で、制御部は直前の5バイト
       （データの位置 −5）。A10050D1・A10040D1 で位置が連なることを確認済み。
    """
    hajime, m, gyo_su, kizami = kuri
    oya = Ko(1, rec_na or teigi['na'])
    naga = 0
    for i, k in enumerate(ko):
        if k['nm'][:1] == ']':
            naga = max(naga, k['ichi'] + k['naga2'])
            continue                       # 2行目以降は雛形の繰返しで表す
        # 接頭辞（`画面－`）を付ける。付けないと原文の名前で引けない。
        na = settou + komoku_na(k)
        kai = gyo_su if hajime <= i < hajime + m else 0
        dan = (kizami,) if kai else ()
        g = Ko(3, na)
        g.oya = oya
        g.occurs = kai
        g.dan = list(dan)
        # ichi は**0起点**（現物の A10040D1 と突き合わせて確認・2026-11-25）。
        # 1 を引いていたため、画面の記憶域が丸ごと1バイトずれていた。
        moto = k['ichi'] - len(SEIGYO)
        for j, sn in enumerate(SEIGYO):
            c = Ko(5, sn + ' OF ' + na)
            c.kata = 'X'; c.keta = 1; c.naga = 1; c.ichi = moto + j
            c.occurs = kai; c.dan = list(dan)
            c.oya = g
            g.ko.append(c)
        d = Ko(5, na)
        d.kata = (kata or {}).get(na, 'X')
        d.keta = k['naga2']; d.naga = k['naga2']; d.ichi = k['ichi']
        if d.kata == '9':
            d.shou = (k.get('hen') or [0, 0, '', 0])[3] or 0
        d.occurs = kai; d.dan = list(dan)
        d.oya = g
        g.ko.append(d)
        g.ichi = g.ko[0].ichi
        g.naga = d.ichi + d.naga - g.ichi
        oya.ko.append(g)
        # 名前とコードの両方で引けるようにする（2026-11-25）
        hoka = settou + (k['nm'] if na != settou + k['nm']
                         else (k.get('cob') or ''))
        if hoka != na:
            _ko_betsumei(oya, g, hoka)
        naga = max(naga, d.ichi + d.naga)
    oya.naga = naga
    return oya


def _ko_betsumei(oya, g, na2):
    """同じ位置を指す**別名**の項目を足す（名前とコードの両方で引くため）。"""
    if not na2 or any(c.na == na2 for c in oya.ko):
        return
    g2 = Ko(3, na2)
    g2.oya = oya; g2.kata = g.kata; g2.keta = g.keta
    g2.naga = g.naga; g2.ichi = g.ichi
    g2.occurs = g.occurs; g2.dan = list(g.dan); g2.shou = g.shou
    for c in g.ko:
        na3 = (c.na.split(' OF ')[0] + ' OF ' + na2) if ' OF ' in c.na else na2
        c2 = Ko(c.level, na3)
        c2.kata = c.kata; c2.keta = c.keta; c2.naga = c.naga
        c2.ichi = c.ichi; c2.shou = c.shou
        c2.occurs = c.occurs; c2.dan = list(c.dan); c2.oya = g2
        g2.ko.append(c2)
    oya.ko.append(g2)


def _gamen_ko_1(na, k, kata, kai, dan, oyako):
    """画面・帳票の項目ひとつ（制御部5バイト＋データ）を作る。

       ichi は**0起点**（現物の A10040D1 と突き合わせて確認・2026-11-25）。
       制御部5バイトはデータの手前。先頭すぎて入らない項目には付けない
       （付けると位置が負になり、別の項目を壊す）。
    """
    g = Ko(3, na)
    g.oya = oyako
    g.occurs = kai
    g.dan = list(dan)
    moto = k['ichi'] - len(SEIGYO)
    if moto >= 0:
        for j, sn in enumerate(SEIGYO):
            c = Ko(5, sn + ' OF ' + na)
            c.kata = 'X'; c.keta = 1; c.naga = 1; c.ichi = moto + j
            c.occurs = kai; c.dan = list(dan); c.oya = g
            g.ko.append(c)
    d = Ko(5, na)
    d.kata = (kata or {}).get(na, 'X')
    d.keta = k['naga2']; d.naga = k['naga2']; d.ichi = k['ichi']
    if d.kata == '9':
        d.shou = (k.get('hen') or [0, 0, '', 0])[3] or 0
    d.occurs = kai; d.dan = list(dan); d.oya = g
    g.ko.append(d)
    g.ichi = g.ko[0].ichi
    g.naga = d.ichi + d.naga - g.ichi
    oyako.ko.append(g)
    return g


def _gamen_ko_zoku(k, settou, kata, kai, dan, oyako, sumi):
    """**日本語の名前と英字のコードの両方**で引けるように作る（2026-11-25）。

       定義体は項目に「名前（品名・数量…）」と「コード（BCODE・RRUNNO…）」の
       両方を持っていて、原文はどちらでも書く。
         `MOVE … TO BCODE OF F10530P1`（コード）
         `MOVE … TO 画面－品名`（名前）
       片方しか作っていなかったので、もう片方で引くと止まっていた。
    """
    g = None
    for x in (k.get('cob'), k['nm']):
        if not x:
            continue
        na = settou + x
        if na in sumi:
            continue
        sumi.add(na)
        g2 = _gamen_ko_1(na, k, kata, kai, dan, oyako)
        g = g or g2
    return g


def _gamen_ko_kozo(teigi, kata=None, rec_na=None, settou=''):
    """**定義体の構造表どおり**に画面の記憶域を組む（2026-11-25）。

       定義体には、コピー原文（XMDLIB）と同じ階層が入っている
       （smd_parse.kozo 参照）。
           lv01 項目表示領域                      ← 集団項目
           lv02 項目表示テーブル OCCURS 15 刻み80
           lv03 項番表示・品名・数量 …            ← 明細1行ぶん
       これを使うと、**一覧画面の繰返しも集団項目も推測しないで**組める。
       従来は行の並びから繰返しを当てていたため、名前が決まらない画面が
       53本あった。

       構造表の無い定義体（繰返しも集団項目も無い画面）では None を返し、
       従来どおり位置の順に並べる。
    """
    kz = teigi.get('kozo')
    if not kz:
        return None
    gun = teigi.get('gun') or {}
    ko = {k['nm']: k for k in teigi['ko']}
    oya = Ko(1, rec_na or teigi['na'])
    sumi = set()                     # もう作った名前
    tsumi = []                       # [(レベル, Ko, 繰返し, 刻み)]
    for e in kz:
        lv = e['lv']
        while tsumi and tsumi[-1][0] >= lv:
            tsumi.pop()
        oyako = tsumi[-1][1] if tsumi else oya
        kai = kiz = 0
        for _l, _g, o, z in tsumi:
            if o:
                kai, kiz = o, z
        if e['ty'] == 16:            # 集団項目
            g = Ko(3, settou + (gun.get(e['nm']) or e['nm']))
            g.kata = None
            g.occurs = 0
            g.dan = []
            g.oya = oyako
            g._occ = e.get('occurs') or 0      # 範囲を出すときに使う
            g._kiz = e.get('kizami') or 0
            oyako.ko.append(g)
            tsumi.append((lv, g, g._occ, g._kiz))
            continue
        k = ko.get(e['nm'])
        if not k or not kioku_aru(k):
            continue
        dan = [kiz] if kai else []
        _gamen_ko_zoku(k, settou, kata, kai, dan, oyako, sumi)

    def _hani(g):
        """集団項目の位置と長さを、中身から決める。"""
        ko2 = [x for x in g.ko if x.level != 88]
        for x in ko2:
            if x.kata is None:
                _hani(x)
        mochi = [x for x in ko2 if x.naga]
        if not mochi:
            return
        a = min(x.ichi for x in mochi)
        # 繰返しの集団項目は「1回ぶんの長さ×回数」。項目ごとの長さ×回数で
        # 出すと、刻みの隙間を数えないので範囲がはみ出す（実測で 4172 に
        # なり、次の集団項目に食い込んだ）。
        occ = getattr(g, '_occ', 0)
        kiz = getattr(g, '_kiz', 0)
        if occ and kiz:
            b = a + occ * kiz
        else:
            b = max(x.ichi + x.naga * max(1, x.occurs) for x in mochi)
        if g.kata is None and g is not oya:
            g.ichi, g.naga = a, b - a

    _hani(oya)
    # レコードの長さは、**繰返しの最後の回まで**入れて数える（2026-11-25）。
    #   繰返しの中の項目は ichi＋(回数-1)×刻み＋長さ まで使う。
    #   数え落とすと領域が足りず、添字が領域の外に出てしまう。
    owari = 0
    for x in oya.mina():
        if x is oya or not x.naga:
            continue
        n = x.ichi + x.naga
        if x.occurs and x.dan:
            n = x.ichi + (x.occurs - 1) * x.dan[-1] + x.naga
        owari = max(owari, n)
    oya.naga = owari
    return oya


def gamen_ko(teigi, namae, kata=None, rec_na=None, settou=''):
    """定義体1本 ＋ 項目名の並び → Ko（01レコード）。合わなければ None。"""
    # R＝入力項目／W＝出力項目。S（区切りの印）は場所を取らないので外す。
    # **記憶域を占める項目は「位置（ichi）が 0 でないもの」**（2026-11-24 実測）。
    # 以前は項目の印が R／W のものだけを採っていたが、印は A〜Z や ] まであり
    # （A10050D1 の 件名かな=A001・件名２=A004・件名３=A002 が落ちていた）、
    # 印で絞るのは誤りだった。位置で絞ると A10040D1 は 55項目・1,123バイトの
    # まま（＝実機で裏取り済みの値を再現）、A10050D1 は 28項目そろう。
    # **定義体に構造表があれば、それが正しい**（推測しない・2026-11-25）
    k0 = _gamen_ko_kozo(teigi, kata, rec_na, settou)
    if k0 is not None:
        return k0
    ko = [k for k in teigi['ko'] if kioku_aru(k)]
    ko.sort(key=lambda k: k['ichi'])
    if len(ko) != len(namae):
        # 繰返し行（] の連なり）が筋よく決まるなら、OCCURS として組む。
        kuri = _gyo_kurikaeshi(ko)
        if kuri:
            return _gamen_ko_kuri(teigi, ko, kuri, kata, rec_na,
                                  settou)
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
    oya = Ko(1, rec_na or teigi['na'])
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
        hoka = settou + (k['nm'] if na != settou + k['nm']
                         else (k.get('cob') or ''))
        if hoka != na:
            _ko_betsumei(oya, g, hoka)
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
import re as _re
_re2 = _re


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

# 日本語の名前で書かれる集団項目。接頭辞は案件ごとに違う（`１０－` `１１－`）
# ので、**接頭辞を問わず**当てる。列は連なっている必要がある。
_GUN_JA = {
    # 組織コード＝部所コード(2)＋係コード(2)。表には無い。
    # 根拠（B10010PP 実測・2026-11-24）
    #   532-534行  MOVE ZERO TO １２－組織コード / MOVE WK-KEY-ASOSM TO
    #              １２－部所コード      … 組織コードが部所コードを含む
    #   45-46行    RECORD KEY １０－年度区分 １０－組織コード
    #              …表の鍵は NENKBN＋BSYOCD＋TANCD なので 組織コード＝後ろ2つ
    #   395行      MOVE SPACE TO １０－組織コード  … まとめて空白にする
    '組織コード': ('BSYOCD', 'TANCD'),
    # YMD＝年(4)＋月(2)＋日(1〜2)。カレンダマスタ CCALMP で使う。
    # 根拠（X10010PX 実測・2026-11-25）
    #   88行 MOVE KIJYUNBI（8桁の基準日）TO L1-YMD
    #   89行 READ CCALML1 KEY IS L1-NEN L1-TSUKI L1-HIZUKE
    #   ＝ YMD は 年・月・日 をまとめた8桁の日付。
    'YMD': ('NEN', 'TSUKI', 'HIZUKE'),
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


def _nihongo_betsumei(oya, settou, cols):
    """日本語の項目名の**別名**を足す（2026-11-24）。

       `COPY DKANRIL1 OF XFDLIB JOINING 連携 AS PREFIX.` に対して、
       原文は `連携－起動画面番号` と**日本語の項目名**で書く。
       表定義は日本語名も持っている（cols の3つめ）ので別名にする。
       区切りは全角ハイフン U+FF0D と ASCII の `-` の両方を入れる。

       ■ 以前は繰返しのある表（kuri あり）のときだけ足していたので、
         繰返しの無い表では別名が1つも付かず、35本がここで止まっていた。
    """
    betsu = []
    for c in cols:
        ja = (c[2] or '').strip() if len(c) > 2 else ''
        if not ja:
            continue
        m = _re2.match(r'^(.*?)_+(\d+)$', c[0])
        moto = m.group(1).rstrip('_') if m else c[0]
        mot = next((k for k in oya.ko if k.na == settou + moto), None)
        if mot is None:
            continue
        for sep in ('-', '\uff0d'):
            nm = settou[:-1] + sep + ja
            if any(k.na == nm for k in oya.ko) or any(k.na == nm for k in betsu):
                continue
            k2 = Ko(3, nm)
            k2.kata, k2.keta, k2.shou, k2.comp = (mot.kata, mot.keta,
                                                  mot.shou, mot.comp)
            k2.naga = mot.naga; k2.ichi = mot.ichi
            k2.occurs = mot.occurs; k2.dan = list(mot.dan); k2.oya = oya
            betsu.append(k2)
    oya.ko += betsu
    _gun_ja(oya, settou, cols)


def _gun_ja(oya, settou, cols):
    """日本語の名前で書く集団項目（`１０－組織コード`）を足す。

       _GUN_JA の組（列名の並び）がぜんぶ揃い、**位置が連なっている**ときだけ
       作る。連なっていなければ作らない（黙って別の場所を指さないため）。
    """
    ichi_hyo = {}
    for c in cols:
        k = next((x for x in oya.ko if x.na == settou + c[0]), None)
        if k is not None:
            ichi_hyo[c[0]] = (k.ichi, k.naga, k)
    for ja, bu in _GUN_JA.items():
        if not all(b in ichi_hyo for b in bu):
            continue
        tsuzuki = all(ichi_hyo[bu[i]][0] + ichi_hyo[bu[i]][1]
                      == ichi_hyo[bu[i+1]][0] for i in range(len(bu) - 1))
        if not tsuzuki:
            continue
        a = ichi_hyo[bu[0]][0]
        owari = ichi_hyo[bu[-1]][0] + ichi_hyo[bu[-1]][1]
        for sep in ('-', '\uff0d'):
            nm = settou[:-1] + sep + ja if settou else ja
            if any(x.na == nm for x in oya.ko):
                continue
            g = Ko(3, nm)
            g.kata = 'X'; g.keta = owari - a; g.naga = owari - a
            g.ichi = a; g.occurs = 0; g.dan = []; g.oya = oya
            oya.ko.append(g)


def fd_ko(settou, cols, na=None, kuri=None):
    """接頭辞＋表の列 → Ko（01レコード）。繰返しと集団項目を戻す。

       kuri（表定義の `kuri`＝定義体から起こした [(基本名, 回数, 刻み)]）が
       あればそれを使う（2026-11-24）。無ければ列名から推測する（_kurikaeshi）。
       列名からの推測では、**交互に並ぶ集団項目の繰返し**
       （KOMKBN_1 KOMRIT_1 KOMKBN_2 KOMRIT_2 …）を見落とす。
       これで `AWKK-KOMKBN (1)` が引けるようになった。
    """
    oya = Ko(1, na or (settou + 'REC'))
    ichi = 0
    ichi_hyo = {}
    if kuri:
        kuri_hyo = {b: (n, kz) for b, n, kz in kuri}
        # まず列の物理位置を出す（列の並び＝現物の並び。定義体で裏取り済み）
        ichi_retsu = {}
        for c in cols:
            _ka, _ke, _sh, _co, nn = _kata_kara(c[1])
            ichi_retsu[c[0]] = (ichi, nn)
            ichi += nn
        dekita = set()
        for c in cols:
            cna = c[0]
            m = _re2.match(r'^(.*?)_+(\d+)$', cna)
            moto = m.group(1).rstrip('_') if m else None
            if moto in kuri_hyo:
                if moto in dekita:
                    continue
                n, kz = kuri_hyo[moto]
                kata, keta, shou, comp, naga = _kata_kara(c[1])
                k = Ko(3, settou + moto)
                k.kata, k.keta, k.shou, k.comp = kata, keta, shou, comp
                k.naga = naga
                k.ichi = ichi_retsu['%s_1' % (moto.ljust(6, '_')
                                              if len(moto) < 6 else moto)][0] \
                    if ('%s_1' % (moto.ljust(6, '_') if len(moto) < 6 else moto)
                        ) in ichi_retsu else ichi_retsu[cna][0]
                k.occurs = n
                k.dan = [kz]
                k.oya = oya
                oya.ko.append(k)
                ichi_hyo[moto] = (k.ichi, naga)
                dekita.add(moto)
                continue
            kata, keta, shou, comp, naga = _kata_kara(c[1])
            k = Ko(3, settou + cna)
            k.kata, k.keta, k.shou, k.comp = kata, keta, shou, comp
            k.naga = naga; k.ichi = ichi_retsu[cna][0]; k.occurs = 0; k.oya = oya
            k.dan = []
            oya.ko.append(k)
            ichi_hyo[cna] = (k.ichi, naga)
        # 接頭辞が日本語のときは、COBOL は**日本語の項目名**で書く（2026-11-24 実測）。
        #   `COPY AWKGFL1 OF XFDLIB JOINING ワ鑑 AS PREFIX.` に対して
        #   `ワ鑑－見積ナンバー`（MITUNO）・`ワ鑑－科目名称(IX1)`（KAMNAM_n）。
        # 表定義は日本語の項目名も持っている（cols の3つめ）ので、別名として足す。
        # 区切りは全角ハイフン U+FF0D。
        _nihongo_betsumei(oya, settou, cols)
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
    for cna, ty, occ in _kurikaeshi(cols):
        kata, keta, shou, comp, naga = _kata_kara(ty)
        k = Ko(3, settou + cna)
        k.kata, k.keta, k.shou, k.comp = kata, keta, shou, comp
        k.naga = naga; k.ichi = ichi; k.occurs = occ; k.oya = oya
        k.dan = [naga] if occ else []
        oya.ko.append(k)
        ichi_hyo[cna] = (ichi, naga)
        ichi += naga * max(1, occ)
    _nihongo_betsumei(oya, settou, cols)
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
