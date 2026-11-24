# -*- coding: utf-8 -*-
"""COBOL 1本を Python の1モジュールに組み立てる。

     python3 bin/cob2py/kumitate.py <ソース.COB> <出力.py>

  ■ 出てくる形
      class <プログラム名>(Pgm):
          KIOKU = [ … 記憶域の作り（DATA DIVISION から） … ]
          def <節の名前>(self): …

  ■ 段落の落ち込みと GO TO
    COBOL の節は、段落が上から下へ落ちていき、GO TO で飛ぶ。
    **GO TO の無い節**は、ふつうに上から下へ並べる（読みやすい）。
    **GO TO のある節**だけ、段落ごとの入れ物を作って順に回す形にする。
      while True:
          if _d == '段落A': …（終わったら _d を次の段落へ）
      GO TO は raise _Tobu('飛び先') で投げ、この回し場で受ける。
      入れ子の IF の中からでも飛べるようにするため、例外にしている。
"""
import sys, re, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cob2py import ji, data, tetsuzuki, dasu
from cob2py.tetsuzuki import na_py


def sagasu(go, *kotoba):
    for i in range(len(go) - 1):
        if go[i].na(kotoba[0]) and go[i+1].na(kotoba[1]):
            return i
    return -1


_COPY = None


def _copybook():
    """手元にあるコピー原文を名前で引けるようにする。

       COPY 〜 で取り込まれる原文は、いただけたぶんだけ手元にある
       （A10CPYPO・A1VLD001 など）。あるものは**そのまま読む**。
       無いもの（XMDLIB の画面・XFDLIB のファイル）は、定義体と表定義から
       組み立てる（gamen_ireru／fd_ireru）。
    """
    global _COPY
    if _COPY is None:
        import os
        _COPY = {}
        ne = pathlib.Path(__file__).resolve().parent.parent.parent
        sagasu_saki = [ne / 'genbutsu', ne.parent / 'genbutsu_copy',
                       ne.parent / 'murakami']
        mo = os.environ.get('FTSCIM_COPYBOOK')
        if mo:
            sagasu_saki.insert(0, pathlib.Path(mo))
        for d in sagasu_saki:
            if not d.exists():
                continue
            for f in d.rglob('*.COB'):
                _COPY.setdefault(f.stem.upper(), f)
    return _COPY


def fd_copy_rec(go, hajime, owari):
    """FD の中の `COPY 〜.` を開いて、その 01 レコードを FD に結びつける。

       例 `FD 更新ＶＬＤ２ EXTERNAL. COPY A1VLD002.` は
          A1VLD002 の 01 REC2 が 更新ＶＬＤ２ のレコード、という意味。
       これが分からないと WRITE REC2 の書き先が引けない（実測）。
    """
    if hajime < 0:
        return {}
    mochi = _copybook()
    out = {}
    ima = None
    i = hajime
    while i < owari:
        g = go[i]
        if g.na('FD', 'SD') and i + 1 < owari:
            ima = go[i+1].v; i += 2; continue
        if g.na('WORKING-STORAGE', 'LINKAGE'):
            break
        if g.na('COPY') and ima and i + 1 < owari:
            na = go[i+1].v.upper()
            f = mochi.get(na)
            if f:
                g2 = ji.waru(_yomu_moji(f))
                for k in data.yomu(g2, 0, len(g2)):
                    out[k.na] = ima
            i += 2; continue
        i += 1
    return out


def _yomu_moji(f):
    """原文を読む。**文字コードはファイルごとに違う**（cp932／UTF-8）。
       cim/utf8 は変換済みだが、genbutsu の原物は cp932 のことがある。
       取り違えると項目名が化けて、どの項目も引けなくなる（実測）。"""
    b = pathlib.Path(f).read_bytes()
    for e in ('utf-8', 'cp932'):
        try:
            return b.decode(e)
        except UnicodeDecodeError:
            pass
    return b.decode('cp932', 'replace')


def copy_ireru(t, go):
    """COPY 〜（ライブラリ指定なし）を、手元の原文から取り込む。"""
    import re as _re
    mochi = _copybook()
    out = []
    for m in _re.finditer(r'COPY\s+([A-Z0-9#@$-]+)\s*(?:OF\s+(\w+))?\s*\.',
                          t, _re.I):
        na, lib = m.group(1).upper(), (m.group(2) or '').upper()
        if lib in ('XMDLIB', 'XFDLIB'):
            continue                       # 画面・ファイルは別で組み立てる
        f = mochi.get(na)
        if not f:
            continue
        g2 = ji.waru(_yomu_moji(f))
        out += data.yomu(g2, 0, len(g2))
    return out


_HYO = None


def _hyo():
    """表定義（cim/schema_gen）。無ければ空。"""
    global _HYO
    if _HYO is None:
        ne = pathlib.Path(__file__).resolve().parent.parent.parent
        for m in (ne / 'proto', ne.parent / 'proto'):
            if (m / 'cim' / 'schema_gen.py').exists():
                sys.path.insert(0, str(m))
                break
        try:
            from cim.schema_gen import TABLES
            _HYO = TABLES
        except Exception:
            _HYO = {}
    return _HYO


def fd_joining(go, hajime, owari):
    """FD の中の `COPY 論理名 OF XFDLIB JOINING 接頭辞 AS PREFIX.` を読む。

       接頭辞はプログラムごとに違う（AJBG-／M020-／M060- など）。
       レコード名は「接頭辞＋論理名の頭4文字＋FD」。
         COPY AKAKML1 OF XFDLIB JOINING M020 AS PREFIX → M020-AKAKFD
         COPY AWKKFL1 OF XFDLIB JOINING AWKK AS PREFIX → AWKK-AWKKFD
       （A10040PO と A10060PO の実物で確かめた。2026-11-24）
    """
    out = {}
    if hajime < 0:
        return out
    ima = None
    i = hajime
    while i < owari:
        g = go[i]
        if g.na('FD', 'SD') and i + 1 < owari:
            ima = go[i+1].v; i += 2; continue
        # WORKING-STORAGE にも JOINING 付きの COPY がある
        # （A10060PO の COPY AKAKML1 OF XFDLIB JOINING W010 AS PREFIX）。
        # ファイルに結びつかないので、接頭辞そのものを見出しにする。
        if g.na('WORKING-STORAGE', 'LINKAGE'):
            ima = None
        if g.na('COPY') and i + 1 < owari:
            ronri = go[i+1].v.upper()
            j = i + 2
            lib = settou = None
            while j < owari and not (go[j].shu == 'ki' and go[j].v == '.'):
                if go[j].na('OF') and j + 1 < owari:
                    lib = go[j+1].v.upper(); j += 2; continue
                if go[j].na('JOINING') and j + 1 < owari:
                    settou = go[j+1].v.upper(); j += 2; continue
                j += 1
            if lib == 'XFDLIB' and settou:
                midashi = ima or ('＊' + settou)
                out[midashi] = (ronri, settou,
                                '%s-%sFD' % (settou, ronri[:-3]))
            i = j + 1; continue
        i += 1
    return out


def fd_ireru(fc, sude, joining=None):
    """FILE-CONTROL の各ファイルのレコードを、表定義から組み立てて足す。"""
    TABLES = _hyo()
    out = []
    joining = dict(joining or {})
    # ファイルに結びつかない JOINING（WORKING-STORAGE のもの）も記憶域にする
    fc = dict(fc)
    for midashi, j in list(joining.items()):
        if midashi.startswith('＊') and midashi not in fc:
            fc[midashi] = {'ronri': j[0], 'kagi': [], 'kumi': 'WORK'}
    for na, d in fc.items():
        j = joining.get(na)
        kagi = d.get('kagi') or []
        if j:
            settou = j[1] + '-'
            rec_na = j[2]
        elif kagi and '-' in kagi[0]:
            settou = kagi[0].split('-', 1)[0] + '-'
            rec_na = settou + 'REC'
        else:
            continue
        if kagi and (settou + kagi[0].split('-', 1)[-1]) in sude:
            continue                      # 原文に定義があるなら触らない
        ronri = (j[0] if j else (d.get('ronri') or ''))
        hyomei = None
        for k in (ronri, ronri[:-3] + 'FP', ronri[:-3] + 'MP'):
            if k in TABLES:
                hyomei = k; break
        if not hyomei:
            continue
        out.append(data_fd(settou, TABLES[hyomei]['cols'], rec_na))
    return out


def data_fd(settou, cols, na):
    k = data.fd_ko(settou, cols, na)
    return k


_TEIGI = None


def _teigitai():
    global _TEIGI
    if _TEIGI is None:
        import json, os
        ne = pathlib.Path(__file__).resolve().parent.parent.parent
        kouho = [os.environ.get('FTSCIM_TEIGITAI'),
                 ne / 'proto' / 'cim' / 'teigitai.json',
                 ne.parent / 'proto' / 'cim' / 'teigitai.json']
        _TEIGI = {}
        for m in kouho:
            if m and pathlib.Path(m).exists():
                _TEIGI = json.loads(pathlib.Path(m).read_text(encoding='utf-8'))
                break
    return _TEIGI


def gamen_ireru(t, go, d_i, p_i):
    """COPY 〜 OF XMDLIB を、定義体から組み立てて足す。"""
    import re as _re
    teigi = _teigitai()
    out = []
    for m in _re.finditer(r'COPY\s+([A-Z0-9]+)\s+OF\s+XMDLIB', t, _re.I):
        na = m.group(1).upper()
        if na not in teigi:
            continue
        # 項目の名前は **定義体に入っている**（2026-11-24・村上様のご指摘で発見）。
        # 定義体に無いぶんだけ、COBOL の「制御項目初期化Ｒ」から補う。
        ko = [x for x in teigi[na]['ko']
              if x['midashi'] is None and x['nm'][:1] in ('R', 'W')]
        ko.sort(key=lambda x: x['ichi'])
        teigi_na = [x.get('cob') for x in ko]
        cob = _seigyo_namae(t)
        if all(teigi_na):
            namae = teigi_na
        elif len(cob) == len(ko):
            namae = cob
        else:
            namae = [a or b for a, b in zip(
                teigi_na, (cob + [None] * len(ko))[:len(ko)])]
            namae = [a or x['nm'] for a, x in zip(namae, ko)]
        k = data.gamen_ko(teigi[na], namae, _gamen_kata(t, namae))
        if k:
            out.append(k)
    return out


def _gamen_kata(t, namae):
    """画面項目が 数（9）か 英数（X）か。

       定義体には入っていないので、原文の「第ｎ項目群消去Ｒ」から取る。
         MOVE ZERO  TO 〜  → 数
         MOVE SPACE TO 〜  → 英数
       ここを取り違えると、桁あふれの切れかた（左か右か）と
       0埋め／空白埋めが逆になる。最終納期が 250929 でなく 202509 になった。
    """
    import re as _re
    kata = {}
    hon = []
    for ln in t.splitlines():
        if not ln or ln[0] in '*/Dd':
            continue
        hon.append(ln[1:67])
    ima = None
    for ln in hon:
        m = _re.search(r'MOVE\s+(ZERO|ZEROS|ZEROES|SPACE|SPACES)\s+TO\s+(.*)$',
                       ln, _re.I)
        if m:
            ima = '9' if m.group(1).upper().startswith('ZERO') else 'X'
            ln = m.group(2)
        elif _re.match(r'^\s*(MOVE|IF|PERFORM|EVALUATE|GO|ADD|COMPUTE)\b', ln, _re.I):
            ima = None
        if not ima:
            continue
        for w in _re.findall(r'[^\s.]+', ln):
            if w in namae:
                kata[w] = ima
    return kata


def _seigyo_namae(t):
    """制御項目初期化Ｒ の EDIT-STATUS OF 〜 の**いちばん長い連なり**。"""
    import re as _re
    R = _re.compile(r'EDIT-STATUS\s+OF\s+(\S+)')
    ima, saidai = [], []
    for ln in t.splitlines():
        if not ln or ln[0] in '*/Dd':
            continue
        b = ln[1:67]
        mm = R.search(b)
        if mm:
            ima.append(mm.group(1).rstrip('.'))
        elif ima:
            if len(ima) > len(saidai):
                saidai = ima
            ima = []
    if len(ima) > len(saidai):
        saidai = ima
    return saidai


def kioku_hyo(ne):
    """01 の並び → 記憶域の作り（出力に埋め込む表）。"""
    out = []
    for k in ne:
        ko = []
        for c in k.mina():
            if c is k or c.level == 88:
                continue
            ko.append((c.na, c.ichi - k.ichi, c.naga, c.kata, c.keta,
                       c.shou, c.fugo, c.comp, c.occurs, tuple(c.dan)))
        out.append((k.na, k.naga, ko,
                    [(c.na, c.value) for c in k.mina() if c.value is not None]))
    return out


def kumu(michi):
    t = pathlib.Path(michi).read_text('utf-8', 'replace')
    go = ji.waru(t)
    pgm = pathlib.Path(michi).stem
    m = re.search(r'PROGRAM-ID\s*\.\s*([A-Z0-9#@$\-]+)', t, re.I)
    if m:
        pgm = m.group(1)
    io_i = sagasu(go, 'INPUT-OUTPUT', 'SECTION')
    d_i = sagasu(go, 'DATA', 'DIVISION')
    p_i = sagasu(go, 'PROCEDURE', 'DIVISION')
    if p_i < 0:
        raise ValueError('PROCEDURE DIVISION がありません')
    ne = data.yomu(go, d_i + 2, p_i) if d_i >= 0 else []
    ne += copy_ireru(t, go)
    ne += gamen_ireru(t, go, d_i, p_i)
    fc = data.file_control(go, io_i, d_i) if (io_i >= 0 and d_i > io_i) else {}
    fdrec = data.fd_rec(go, d_i, p_i) if d_i >= 0 else {}
    fdrec.update(fd_copy_rec(go, d_i, p_i))
    joining = fd_joining(go, d_i, p_i) if d_i >= 0 else {}
    ne += fd_ireru(fc, {c.na for k in ne for c in k.mina()}, joining)
    namae = {c.na for k in ne for c in k.mina()}
    hairetsu = {c.na for k in ne for c in k.mina() if c.occurs}
    # PROCEDURE DIVISION USING 〜 ＝ 呼ぶ側から受け取る項目
    j = p_i + 2
    uketori = []
    if j < len(go) and go[j].na('USING'):
        j += 1
        while j < len(go) and go[j].shu == 'na' and not go[j].na('SECTION'):
            if go[j].na('BY', 'REFERENCE', 'CONTENT', 'VALUE'):
                j += 1; continue
            uketori.append(go[j].v); j += 1
        if j < len(go) and go[j].shu == 'ki' and go[j].v == '.':
            j += 1
    setsu = tetsuzuki.wakeru(go, j, len(go))

    d = dasu.Dasu(pgm, setsu, namae, hairetsu)
    b = ['# -*- coding: utf-8 -*-',
         '"""%s を写したもの。bin/cob2py が自動生成。**手で直さない。**' % pathlib.Path(michi).name,
         '',
         '   もとの原文 %s 行。節 %d・段落 %d。' % (len(t.splitlines()), len(setsu),
                                                  sum(len(x.dan) for x in setsu)),
         '"""',
         'from cim.cobol.hashiru import Pgm, D, SPACE, TAKAI, HIKUI, ZENBU, \\',
         '    WARU, SUUJIKA, EIJIKA, _Tobu, ExitProgram, StopRun, OWARI, NASHI, SEIJOU',
         '',
         '',
         'class %s(Pgm):' % na_py(pgm),
         '    NA = %r' % pgm,
         '    UKETORI = %r' % (uketori,),
         '    FAIRU = %r' % (fc,),
         '    FD_REC = %r' % (fdrec,),
         '    KIOKU = %r' % (kioku_hyo(ne),),
         '']
    hon = []
    kumi = []                 # [(節名, [(段落名, メソッド名)…])]
    for s in setsu:
        if s.na == '__honbun__' and not any(x.go for x in s.dan):
            continue
        gyo, namae = setsu_dasu(d, s)
        hon += gyo
        kumi.append((s.na, namae))
    b.append('    DANRAKU = %r' % (kumi,))
    b.append('')
    b += hon
    # PERFORM A THRU B のぶん
    for kara, made in sorted(d.thru):
        b.append('    def %s(self):' % na_py('_thru_%s_%s' % (kara, made)))
        b.append('        """PERFORM %s THRU %s"""' % (kara, made))
        b.append('        self._thru(%r, %r)' % (kara, made))
        b.append('')
    return '\n'.join(b) + '\n', d


def setsu_dasu(d, s):
    """節ひとつ → 段落ごとのメソッド ＋ 節のメソッド。

       ■ なぜ段落ごとに出すか
         PERFORM A THRU B（1,521か所）は「段落Aから段落Bまでを順に実行」
         という意味なので、段落が呼べる形でないと写せない。
       ■ 落ち込みと GO TO
         節のメソッドが段落を順に呼ぶ。GO TO は _Tobu を投げ、
         節のメソッドが受けて飛び先の段落から続ける。
         入れ子の IF の中からでも飛べるよう、例外にしている。
    """
    b = []
    namae = []
    for dan in s.dan:
        if not dan.go:
            namae.append((dan.na, None))
            continue
        me = na_py('_dan_' + dan.na)
        namae.append((dan.na, me))
        b.append('    def %s(self):' % me)
        b.append('        """%s"""' % dan.na)
        naka = []
        i = 0
        while i < len(dan.go):
            i = d.bun(dan.go, i, len(dan.go), 2, naka)
        b += naka or ['        pass']
        b.append('')
    me = na_py(s.na)
    b.append('    def %s(self):' % me)
    b.append('        """%s"""' % s.na)
    b.append('        self._setsu(%r)' % s.na)
    b.append('')
    return b, [(na, m) for na, m in namae]


if __name__ == '__main__':

    src, out = sys.argv[1], sys.argv[2]
    honbun, d = kumu(src)
    pathlib.Path(out).write_text(honbun, encoding='utf-8')
    print('%s → %s  未変換 %d件' % (pathlib.Path(src).name, out, len(d.mikansei)))
    for gyo, k in d.mikansei[:10]:
        print('   %5d行  %s' % (gyo, k))
