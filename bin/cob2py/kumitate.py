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
import re as _re
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
        # 原文置き場にも**コピー原文が混ざっている**（2026-11-24 実測）。
        #   `COPY JYUSYORI OF FZSLIB` の JYUSYORI は、ソース一覧では
        #   「PROCEDURE DIVISION が無いプログラム」として挙がっていたが、
        #   実体はコピー原文（段落だけを書いた断片）だった。8本ある。
        # **PROCEDURE DIVISION を持たないものだけ**を採る（プログラム本体を
        # 取り違えないため）。
        mo2 = os.environ.get('FTSCIM_SRC')
        if mo2:
            d = pathlib.Path(mo2)
            if d.exists():
                for f in d.rglob('*.COB'):
                    na = f.stem.upper()
                    if na in _COPY:
                        continue
                    try:
                        if 'PROCEDURE' in f.read_text('utf-8', 'replace').upper():
                            continue
                    except Exception:
                        continue
                    _COPY[na] = f
    return _COPY


def copy_tenkai(go, michi, fukasa=0):
    """手続き部の `COPY 〜 [OF ライブラリ].` を、原文の語に置き換える。

       FZSLIB のコピー原文は**段落を書いた断片**なので、データ部の COPY と違って
       「取り込んで展開する」しかない（8本・12文のうち8文がこれだった）。
       XMDLIB／XFDLIB は画面・ファイルなので触らない。
    """
    if fukasa > 5:
        return go
    mochi = _copybook()
    import os
    ima = pathlib.Path(michi).resolve().parent
    out = []
    i = 0
    kaeta = False
    while i < len(go):
        g = go[i]
        if not g.na('COPY') or i + 1 >= len(go) or go[i+1].shu != 'na':
            out.append(g); i += 1; continue
        na = go[i+1].v.upper()
        j = i + 2
        lib = ''
        if j + 1 < len(go) and go[j].na('OF', 'IN') and go[j+1].shu == 'na':
            lib = go[j+1].v.upper(); j += 2
        if j < len(go) and go[j].shu == 'ki' and go[j].v == '.':
            j += 1
        if lib in ('XMDLIB', 'XFDLIB'):
            out.append(g); i += 1; continue
        f = mochi.get(na)
        if f is None:
            kari = ima / ('%s.COB' % na)
            f = kari if kari.exists() else None
        if f is None:
            out.append(g); i += 1; continue
        naka = ji.waru(_yomu_moji(f))
        out += copy_tenkai(naka, str(f), fukasa + 1)
        i = j
        kaeta = True
    return out if kaeta else go


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
            # ■ 画面・帳票の定義体（XMDLIB／XRDLIB）も結びつける（2026-11-24）
            #   `FD 画面ファイル. COPY A18030D1 OF XMDLIB JOINING 画面
            #    AS PREFIX.` のとき、原文は `WRITE 画面－処理終了画面` と
            #   **レコード名**で書く。この対応が無いので書き先が引けず
            #   「WRITE 〜（表が無い）」で108本が止まっていた。
            t = _teigitai().get(na)
            if t:
                j, settou = i + 2, ''
                while j < owari and not (go[j].shu == 'ki' and go[j].v == '.'):
                    if go[j].na('JOINING') and j + 1 < owari:
                        pre = go[j+1].v.rstrip('.')
                        settou = pre + ('-' if pre.isascii() else '\uff0d')
                        break
                    j += 1
                # レコード名が定義体から取れないこともある（帳票など）。
                # そのときでも**定義体の名前そのもの**は書き先になる
                # （`WRITE M15010D1`）ので、必ず結びつける。
                if t.get('rec'):
                    out[settou + t['rec']] = ima
                out[na] = ima
                if settou:
                    out[settou + na] = ima
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


def fd_ireru(fc, sude, joining=None, copyna=None, rec_fd=None):
    """FILE-CONTROL の各ファイルのレコードを、表定義から組み立てて足す。"""
    TABLES = _hyo()
    out = []
    joining = dict(joining or {})
    copyna = dict(copyna or {})
    kouho = {}            # 別名 → [ファイル名…]
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
            # ■ 接頭辞の無いファイル（2026-11-24）
            #   `FD AJKNML1. COPY AJKNML1 OF XFDLIB.`（JOINING なし）だと
            #   項目は表の列名そのままで、原文は `JKNKBN OF AJKNML1` と
            #   **ファイル名で修飾**して書く。これを組んでいなかったので
            #   24本が「知らない項目 JKNKBN」で止まっていた。
            #   01 の名前をファイル名にすれば、OF 修飾（_hiku の oya）で引ける。
            settou = ''
            rec_na = na
        if kagi and (settou + kagi[0].split('-', 1)[-1]) in sude:
            continue                      # 原文に定義があるなら触らない
        ronri = (j[0] if j else (d.get('ronri') or ''))
        hyomei = None
        # **表定義が論理ファイル名を持っている**ので、まずそれで引く（2026-11-24）。
        #   YAMAHL1 → YAMAHSF（山積金額ファイル）。名前の形から
        #   YAMAHFP／YAMAHMP と作っても当たらない（13本がここで止まっていた）。
        hyomei = _ronri_hiki().get(ronri)
        if not hyomei:
            for k in (ronri, ronri[:-3] + 'FP', ronri[:-3] + 'MP'):
                if k in TABLES:
                    hyomei = k; break
        if not hyomei:
            continue
        # ■ 01 レコードの本当の名前は**表定義が持っている**（2026-11-25）
        #   KSIWFP の rec は 'FSIWFD'。論理名 KSIWFL1 からも物理名 KSIWFP
        #   からも作れない綴りで、ここを見ていなかったので
        #   `FSIWFD OF KSIWFL1` が引けなかった（478表が rec を持つ）。
        hon_rec = TABLES[hyomei].get('rec')
        if hon_rec and not j:
            rec_na = hon_rec              # 接頭辞が無いときはそのまま
        k = data_fd(settou, TABLES[hyomei]['cols'], rec_na,
                    TABLES[hyomei].get('kuri'),
                    _gun_teigi(ronri, hyomei))
        # ■ `COPY <原文名> OF XFDLIB` の原文名が FD 名と違うとき、
        #   **原文名のほうの定義体**が持つ 01 名も別名にする（2026-11-26）。
        cp_rec = None
        cp = copyna.get(na)
        if cp:
            cp_rec = (_fdef_rec().get(cp) or {}).get('rec')
        _rec_betsumei(k, settou, ronri, rec_na, hon_rec, cp_rec, na)
        # ■ レコード名 → ファイル名 を集める（2026-11-26）
        #   ＣＯＢＯＬ は WRITE／REWRITE に**レコード名**を書く
        #   （`WRITE １３－部所出力順レコード`）。ＦＤに 01 が書かれて
        #   いない（COPY だけ）ときは原文から対応が取れないため、
        #   ここで作った 01 とその別名をそのまま対応表にする。
        #   これが無いと「表が無い」で止まっていた（B30000PB・NOUJU09S）。
        for x in [rec_na] + [c.na for c in k.ko if c.kata is None]:
            kouho.setdefault(x, []).append(na)
        out.append(k)
    if rec_fd is not None:
        # **1つのファイルにしか当たらない名前だけ**入れる。`RECFD` のような
        # ありふれた綴りは複数のファイルに付くので、入れると書き先を
        # 取り違える（黙って間違うので必ず落とす）。
        for x, fs in kouho.items():
            if len(set(fs)) == 1:
                rec_fd.setdefault(x, fs[0])
    return out


def _zen(s):
    """英数字を全角にする。`L1` → `Ｌ１`。

       原文は日本語の名前の中で**全角の英数字**を使う
       （`順序－組織出力順序マスタＬ１`）。論理名 ASOJML1 の末尾 `L1` から
       作るので、ここで全角へ直す。
    """
    return s.translate({c: c + 0xFEE0 for c in range(0x21, 0x7F)})


def _rec_betsumei(oya, settou, ronri, rec_na, hon_rec=None, cp_rec=None,
                  fairu_na=None):
    """01レコードの**別名**を足す（2026-11-24 実測）。

       原文は 01 レコードをコピー原文の名前で書く。コピー原文（XFDLIB）が
       手元に無くても、実例から次の綴りだと分かっている。
         `FNHNFD OF FNHNFL1` `FNHNFD OF FNHNFL3`  … 論理名の末尾3文字を
                                                     落として FD を付ける
         `RECFD OF C10020S1`                      … 作業ファイルは RECFD
         `仮前－レコード` `原価鑑－レコード`        … 接頭辞＋「レコード」
       これが無いと WRITE／INITIALIZE の相手が引けず24本が止まっていた。
       範囲はレコード全体なので、取り違えようがない（集団項目と違い
       範囲を推測していない）。
    """
    from .data import Ko
    # 接頭辞の区切りは ASCII の `-`。原文が日本語の接頭辞を使うときは
    # **全角ハイフン U+FF0D** で書くので、両方を別名にする。
    moto = settou[:-1] if settou else ''
    kugiri = ['-', '\uff0d'] if (moto and not moto.isascii()) else ['-']
    na = []
    # `COPY <原文名> OF XFDLIB` の原文名側の 01 名（村上様ご指摘・2026-11-26）
    if cp_rec:
        na.append(cp_rec)
        for sep in kugiri:
            if moto:
                na.append(moto + sep + cp_rec)
    if hon_rec:
        na.append(hon_rec)
        for sep in kugiri:
            if moto:
                na.append(moto + sep + hon_rec)
    if ronri and len(ronri) > 3:
        na.append(ronri[:-3] + 'FD')
    na.append('RECFD')
    # ■ 接頭辞が無いファイルは**ファイル名**でも修飾される（2026-11-26 実測）
    #   `FD C10020S1. COPY C10020S1 OF XFDLIB.` の原文は
    #   `MOVE … TO SEIBAN OF C10020S1` と**ファイル名**で書き、
    #   01 の名前（RECFD）では書かない。rec_na を 01 名にした時点で
    #   ファイル名の別名が消えていたため、書き先の列が1つも引けず
    #   `INSERT INTO t () VALUES ()` になっていた（C10020PB）。
    if fairu_na:
        # 接頭辞があっても付ける。`_rec_toru_01` がファイル名で 01 を
        # 探すので、これが無いと書く列が1つも集まらない（B30000PB）。
        na.append(fairu_na)
    # ■ 接頭辞＋**ファイル名**（2026-11-26 実測）
    #   `FD 組織マスタ. COPY ASOSML1 OF XFDLIB JOINING １１ AS PREFIX.` のとき
    #   原文は `INITIALIZE １１－組織マスタ` と**接頭辞＋ＦＤ名**で書く。
    #   これが無くて13本が「知らない項目 １１－組織マスタ」で止まっていた
    #   （文字比較を直して処理が先へ進むようになり、はじめて表に出た）。
    if moto and fairu_na and fairu_na != moto:
        hoka = [fairu_na]
        # ＦＤ名の「ファイル」を「レコード」に替えたもの（実測）
        #   `FD 部所出力順ファイル` → `１３－部所出力順レコード`（B30000PB）
        if 'ファイル' in fairu_na:
            hoka.append(fairu_na.replace('ファイル', 'レコード'))
        # ＦＤ名＋論理名の末尾（Ｌ１ など・全角）（実測）
        #   `FD 組織出力順序マスタ` ＋ `COPY ASOJML1`
        #        → `順序－組織出力順序マスタＬ１`（B16320PB）
        if ronri and _re.search(r'L\d$', ronri):
            hoka.append(fairu_na + _zen(ronri[-2:]))
        for x in hoka:
            for sep in kugiri:
                na.append(moto + sep + x)
    if moto:
        for sep in kugiri:
            na.append(moto + sep + 'レコード')
            if ronri and len(ronri) > 3:
                na.append(moto + sep + ronri[:-3] + 'FD')
    for x in na:
        if x == rec_na or any(c.na == x for c in oya.ko):
            continue
        g = Ko(3, x)
        g.kata = None; g.keta = oya.naga; g.naga = oya.naga
        g.ichi = 0; g.occurs = 0; g.dan = []; g.oya = oya
        oya.ko.append(g)


_RONRI = None


def _ronri_hiki():
    """論理ファイル名 → 物理表名。表定義の `ronri` から逆引きを作る。"""
    global _RONRI
    if _RONRI is None:
        _RONRI = {}
        for t, v in (_hyo() or {}).items():
            for r in (v.get('ronri') or []):
                _RONRI.setdefault(r, t)
    return _RONRI


def data_fd(settou, cols, na, kuri=None, gun=None):
    return data.fd_ko(settou, cols, na, kuri, gun)


def _gun_teigi(*na):
    """定義体（.SMB）が持つ**集団項目**を返す。最初に見つかったものを使う。

       論理ファイル名（ASOSML1）でも物理名（ASOSMP）でも引けるようにする。
       どちらの .SMB も同じレイアウトなので、集団項目も同じ。
    """
    h = _fdef_rec()
    for x in na:
        if x and x in h and h[x].get('gun'):
            return h[x]['gun']
    return []


_FDEF_REC = None


def _fdef_rec():
    """ファイル定義体（.SMB）の **定義名 → 01レコード名**。

       ■ なぜ表定義（TABLES）と別に要るか（2026-11-26 村上様のご指摘）
         TABLES に入るのは**物理ファイル 486表だけ**。
         `COPY FSSIFL1 OF XFDLIB` の FSSIFL1 は**論理ファイル**なので
         TABLES に無く、rec（FSSIRC）が引けなかった。
         .SMB は 1,061本いただいているので、そこから直に引く。
       生成は `bin/gen_fdef_rec.py <OBJディレクトリ>`。
    """
    global _FDEF_REC
    if _FDEF_REC is None:
        import json, os
        ne = pathlib.Path(__file__).resolve().parent.parent.parent
        kouho = [os.environ.get('FTSCIM_FDEF_REC'),
                 ne / 'proto' / 'cim' / 'fdef_rec.json',
                 ne.parent / 'proto' / 'cim' / 'fdef_rec.json']
        _FDEF_REC = {}
        for m in kouho:
            if m and pathlib.Path(m).exists():
                _FDEF_REC = json.loads(
                    pathlib.Path(m).read_text(encoding='utf-8'))
                break
    return _FDEF_REC


def fd_copy_na(go, hajime, owari):
    """`FD <ファイル名>. COPY <原文名> OF XFDLIB.` の **原文名**を拾う。

       ■ 村上様のご指摘（2026-11-26）
         「COPY OF XFDLIB でファイル名と違う名称が指定されているもの」。
         原文名はファイル名と違うことがあり、**01レコード名は原文名の
         ほうの定義体が持っている**。

           SHIZI74F   FD  FSSIFL2.
                          COPY FSSIFL1 OF XFDLIB.
                      INITIALIZE FSSIRC OF FSSIFL2.
           FSSIFL2.SMB の rec = FSSIR2 ／ **FSSIFL1.SMB の rec = FSSIRC**

         ＦＤのファイル名しか見ていなかったので `FSSIRC` が引けず
         止まっていた。857本中11本・64箇所でファイル名と原文名が違う。
       JOINING 付きは fd_joining が別に見るので、ここでは名前だけ返す。
    """
    out = {}
    if hajime < 0:
        return out
    ima = None
    i = hajime
    while i < owari:
        g = go[i]
        if g.na('FD', 'SD') and i + 1 < owari:
            ima = go[i+1].v.upper(); i += 2; continue
        if g.na('WORKING-STORAGE', 'LINKAGE'):
            break
        if g.na('COPY') and ima and i + 1 < owari:
            na = go[i+1].v.upper()
            j, lib = i + 2, None
            while j < owari and not (go[j].shu == 'ki' and go[j].v == '.'):
                if go[j].na('OF') and j + 1 < owari:
                    lib = go[j+1].v.upper(); break
                j += 1
            if lib == 'XFDLIB' and na != ima:
                out[ima] = na
            i += 2; continue
        i += 1
    return out


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
    # 注記・デバッグ行を落とした本文で探す（継続行をまたぐため）
    hon = '\n'.join(ln[1:67] for ln in t.splitlines()
                    if ln and ln[0] not in '*/Dd')
    for m in _re.finditer(r'COPY\s+([A-Z0-9]+)\s+OF\s+XMDLIB((?:[^.]|\n)*)',
                          hon, _re.I):
        na = m.group(1).upper()
        if na not in teigi:
            continue
        # ■ JOINING の接頭辞を取る（2026-11-24）
        #   `COPY A18030D1 OF XMDLIB JOINING 画面 AS PREFIX.` に対し
        #   原文は `画面－操作指示` と書く。定義体から取った名前に
        #   **接頭辞を付けていなかった**ので「知らない項目」で止まっていた。
        #   区切りは、接頭辞が日本語なら全角ハイフン U+FF0D、英数なら `-`。
        mj = _re.search(r'JOINING\s+(\S+)', m.group(2) or '', _re.I)
        settou = ''
        if mj:
            pre = mj.group(1).rstrip('.')
            sep = '-' if pre.isascii() else '\uff0d'
            settou = pre + sep
        # 項目の名前は **定義体に入っている**（2026-11-24・村上様のご指摘で発見）。
        # 定義体に無いぶんだけ、COBOL の「制御項目初期化Ｒ」から補う。
        # 記憶域を占める項目は位置（ichi）が 0 でないもの（data.gamen_ko と同じ）。
        ko = [x for x in teigi[na]['ko'] if data.kioku_aru(x)]
        ko.sort(key=lambda x: x['ichi'])
        # 名前は「項目名表（cob）」と「項目コードそのもの」の両方から採る
        # （data.komoku_na_aru を参照）。
        teigi_na = [settou + data.komoku_na(x) if data.komoku_na_aru(x)
                    else None for x in ko]
        cob = _seigyo_namae(t)
        if all(teigi_na):
            namae = teigi_na
        elif len(cob) == len(ko):
            namae = cob
        else:
            namae = [a or b for a, b in zip(
                teigi_na, (cob + [None] * len(ko))[:len(ko)])]
            namae = [a or (settou + x['nm']) for a, x in zip(namae, ko)]
        # 01レベルの名前（`画面－処理終了画面`）。定義体から取る。
        rec = teigi[na].get('rec')
        # 接頭辞が無い画面もある（`COPY A30010D1 OF XMDLIB.`）。その場合は
        # レコード名そのまま（`仮受注登録画面１`）で原文が書く。
        rec_na = (settou + rec) if rec else None
        k = data.gamen_ko(teigi[na], namae, _gamen_kata(t, namae),
                          rec_na, settou)
        if k:
            # ■ 定義体の名前そのものでも引けるようにする（2026-11-25）
            #   `COPY M15010D1 OF XMDLIB JOINING 画面 AS PREFIX.` でも、
            #   原文は `MOVE LOW-VALUE TO M15010D1` と**定義体の名前**で
            #   レコードまるごと動かすことがある（13本が止まっていた）。
            from .data import Ko as _Ko
            for x in (na, (settou + na) if settou else None):
                if not x or x == k.na or any(c.na == x for c in k.ko):
                    continue
                g = _Ko(3, x)
                g.kata = None; g.keta = k.naga; g.naga = k.naga
                g.ichi = 0; g.occurs = 0; g.dan = []; g.oya = k
                k.ko.append(g)
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


SEIGYO_NA = ('EDIT-STATUS', 'EDIT-OPTION', 'EDIT-COLOR',
             'EDIT-MODE', 'EDIT-CURSOR')


def _filler_seigyo(ko):
    """画面の制御部を名前で引けるようにする（2026-11-24）。

       画面レコードを原文の中に直接書いているプログラム（A10090PO の `Ｄ画面`）は、
       項目ごとの5バイトの制御部を **`FILLER PIC X(005)`** としか書いていない。
       それでも原文は `EDIT-MODE OF Ｄ見積ＮＯ` のように引く（ASP COBOL は
       画面レコードの制御部に名前を与える）。そこで
         「5バイトの FILLER の**直後に名前付きの基本項目**がある」
       ところを制御部とみなし、EDIT-STATUS/OPTION/COLOR/MODE/CURSOR を
       1バイトずつ名前付きで足す。繰返し（OCCURS）の中にも入るので、
       直後の項目の繰返しの刻みをそのまま引き継ぐ。
       画面でない記憶域に 5バイトの FILLER があっても、足した名前は誰も引かない
       ので害は無い（引かれたときだけ値が取れる）。
    """
    import re as _re2
    tasu = []
    for i, c in enumerate(ko):
        # 名前の無い FILLER だけでなく、**`D1-FIL01` のように名前を付けた
        # 5バイトの埋めもの**も制御部（2026-11-25 実測。B10511PO は
        # 画面レコードを原文に直接書き、`EDIT-STATUS OF D1-CODE1` と引く）。
        if not (c[0] == 'FILLER' or _re2.search(r'FIL\d*$', str(c[0]), _re2.I)):
            continue
        if c[2] != 5 or c[3] is None:
            continue
        if i + 1 >= len(ko):
            continue
        n = ko[i + 1]
        if n[0] == 'FILLER' or n[3] is None:
            continue
        for j, sn in enumerate(SEIGYO_NA):
            tasu.append(('%s OF %s' % (sn, n[0]), c[1] + j, 1, 'X', 1,
                         0, False, None, n[8], n[9]))
    return tasu


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
        ko += _filler_seigyo(ko)
        out.append((k.na, k.naga, ko,
                    [(c.na, c.value) for c in k.mina() if c.value is not None]))
    return out


def tokubetsu_teisu(go):
    """SPECIAL-NAMES の SYMBOLIC CONSTANT を読む（2026-11-24 実測）。

         SPECIAL-NAMES.
                STATION   IS   DSP
                SYMBOLIC  CONSTANT
                定数      IS   1000000
                正常      IS   "00"
                終了      IS   "10"   …  .
       `IF WK-STS NOT = 正常` のように**名前つきの直定数**として使う。
       849本すべてが持っており、見ないと「知らない項目 正常」で止まる。
    """
    out = {}
    i = next((k for k, g in enumerate(go) if g.na('SPECIAL-NAMES')), -1)
    if i < 0:
        return out
    # SYMBOLIC CONSTANT のところまで進む。
    # `SPECIAL-NAMES.` の直後にピリオドが来るので、ピリオドでは止めない。
    # 次の SECTION／DIVISION まで見る。
    j = i + 1
    while j < len(go):
        if go[j].na('SYMBOLIC'):
            break
        if go[j].na('SECTION', 'DIVISION'):
            return out
        j += 1
    if j >= len(go) or not go[j].na('SYMBOLIC'):
        return out
    j += 1
    if j < len(go) and go[j].na('CONSTANT', 'CONSTANTS'):
        j += 1
    while j + 2 < len(go):
        if go[j].shu == 'ki' and go[j].v == '.':
            break
        if go[j].shu != 'na' or not go[j+1].na('IS'):
            break
        na = go[j].v
        v = go[j+2]
        if v.shu == 'mo':
            out[na] = repr(v.v)
        elif v.shu == 'su':
            out[na] = "D('%s')" % v.v
        else:
            out[na] = repr(v.v)
        j += 3
    return out


def kumu(michi):
    t = pathlib.Path(michi).read_text('utf-8', 'replace')
    go = ji.waru(t)
    p0 = sagasu(go, 'PROCEDURE', 'DIVISION')
    if p0 >= 0:
        # 手続き部の COPY（FZSLIB など）は原文で展開する。データ部の COPY は
        # 従来どおり copy_ireru が別に読む（二重に足さないため、ここは手続き部だけ）。
        go = go[:p0] + copy_tenkai(go[p0:], michi)
    pgm = pathlib.Path(michi).stem
    m = re.search(r'PROGRAM-ID\s*\.\s*([A-Z0-9#@$\-]+)', t, re.I)
    if m:
        pgm = m.group(1)
    io_i = sagasu(go, 'INPUT-OUTPUT', 'SECTION')
    d_i = sagasu(go, 'DATA', 'DIVISION')
    p_i = sagasu(go, 'PROCEDURE', 'DIVISION')
    if p_i < 0:
        raise ValueError('PROCEDURE DIVISION がありません')
    teisu = tokubetsu_teisu(go)
    ne = data.yomu(go, d_i + 2, p_i, teisu) if d_i >= 0 else []
    ne += copy_ireru(t, go)
    ne += gamen_ireru(t, go, d_i, p_i)
    fc = data.file_control(go, io_i, d_i) if (io_i >= 0 and d_i > io_i) else {}
    fdrec = data.fd_rec(go, d_i, p_i) if d_i >= 0 else {}
    fdrec.update(fd_copy_rec(go, d_i, p_i))
    joining = fd_joining(go, d_i, p_i) if d_i >= 0 else {}
    copyna = fd_copy_na(go, d_i, p_i) if d_i >= 0 else {}
    rec_fd = {}
    ne += fd_ireru(fc, {c.na for k in ne for c in k.mina()}, joining, copyna,
                   rec_fd)
    for _k, _v in rec_fd.items():
        fdrec.setdefault(_k, _v)      # 原文に書いてある対応を上書きしない
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

    d = dasu.Dasu(pgm, setsu, namae, hairetsu, teisu)
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
