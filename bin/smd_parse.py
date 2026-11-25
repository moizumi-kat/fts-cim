# -*- coding: utf-8 -*-
"""富士通ASP の画面定義（.SMD）を読む。

   ■ 分かったこと（実物を読んで確かめた）
     ・ファイル全体が EBCDIC。先頭8バイトが画面名（例 'A10040D1'）
     ・0x0136 から **8バイトの名前表**（0xFFFF で終わる）
          [6バイト 項目名（0x40 で右詰め空白）][2バイト 値]
          値の上位ビット(0x8000)が立っていれば、下位が属性レコードの位置
     ・属性レコードは **16バイト**
          +0 : 2バイト 次の表への位置
          +2 : 2バイト 文字列などの位置（無ければ 0）
          +4 : 2バイト **行**（0起点）
          +6 : 2バイト **桁**（1起点）
          +8 : 2バイト **長さ**
          +10: 2バイト 長さ（+8 と同じ値が入っている）
          +12: 2バイト ／ +14: 2バイト  繰返し項目のときだけ値が入る

     ・**編集（表示の形）は「次の表」(+0) の指す18バイトのレコード**にある
       （2026-11-20 実測。画面220本・帳票201本の全項目で裏を取った）
          +8 : 編集の種類（ビット）
                 0x04 日付（区切り文字で3つに割る）  0x40 3桁ごとのカンマ
                 0x10 符号ぶん1桁                   0x80 ゼロを空白にする
                 0x01 数字（編集なし）
          +9 : 0x04 が立っていれば日付（+8 側に立っていないことがある）
          +10: 差し込む文字（EBCDIC。日付の '.' など）
          +11: 小数の桁数（1以上なら小数点が1文字入る）
       検算：差し込まれる文字の数が **表示長 － データ長** と合うか。
             画面 8,870/8,870 ・帳票 36,142/36,143 で一致した
             （合わない1件 A11320P1 W010 は 0x20 ＝ 通貨記号ぶん1桁）。

   ■ 確かめかた
     桁＋長さが80桁に収まるか、プログラム側が使っている項目名と合うかで検算する。

   使い方  python3 smd_parse.py <画面定義.SMD>
"""
import re
import sys, pathlib, struct
try:
    from . import teigitai_moji
except Exception:
    import teigitai_moji

def yomu(path):
    b = pathlib.Path(path).read_bytes()
    namae = b[:8].decode('cp500').strip()
    # ── 名前表の位置（2026-11-18 に直した）────────────────────
    #   はじめは EBCDIC の 'C000'（C3 F0 F0 F0）を目印に探していたが、
    #   **帳票定義体には この目印が無い**（画面定義体 220本は読めたが
    #   帳票定義体 201本が全部読めなかった）。
    #   よく見ると、画面も帳票も **ヘッダの 0x00A0 に名前表の先頭位置**が
    #   4バイトで入っている。推測ではなく構造から取るほうが確かなので、
    #   こちらを正とする。
    #     画面 A10040D1 … 0x00A0 = 0x0000012A（C000 の目印から求めた値と一致）
    #     帳票 A11110P1 … 0x00A0 = 0x00000100
    #   帳票の先頭8バイトは名前ではなく EBCDIC の空白なので、名前は空になる。
    if len(b) < 0xA4:
        raise ValueError('小さすぎて定義体に見えません: %s' % path)
    i = struct.unpack('>I', b[0xA0:0xA4])[0]
    if not (0 < i < len(b)):
        raise ValueError('名前表の位置（0x00A0）がおかしい: %s → %d' % (path, i))
    komoku = []
    while i + 8 <= len(b):
        nm = b[i:i+6]
        if nm[:2] == b'\xff\xff':
            break
        try:
            n = nm.decode('cp500').strip()
        except Exception:
            break
        if not n:
            break
        v = struct.unpack('>H', b[i+6:i+8])[0]
        komoku.append((n, v))
        i += 8
    out = []
    for n, v in komoku:
        if not (v & 0x8000):
            out.append({'nm': n, 'ichi': v, 'gyo': None, 'keta': None, 'naga': None})
            continue
        a = v & 0x7FFF
        if a + 16 > len(b):
            out.append({'nm': n, 'ichi': v, 'gyo': None, 'keta': None, 'naga': None})
            continue
        f = struct.unpack('>8H', b[a:a+16])
        k = {'nm': n, 'ichi': a, 'tsugi': f[0], 'moji': f[1],
             'gyo': f[2], 'keta': f[3], 'naga': f[4], 'naga2': f[5],
             'k6': f[6], 'k7': f[7]}
        k.update(hensyuu(b, f[0]))
        out.append(k)
    cob = komoku_na(b, {k['nm'] for k in out})
    # **コードが4文字とは限らない**（W00101 のような6文字もある・2026-11-25）。
    #   komoku_na は4バイトのコードしか見ないので、8バイトのコードも見る
    #   gun_na で補う。これで NPJYU4D1 の「当日受注＝W00101」などが付く。
    gun = gun_na(b)
    for k in out:
        k['cob'] = cob.get(k['nm']) or gun.get(k['nm'])
    return namae, out, len(b)


def rec_na(b, shiru=None, teigi_na=None):
    """**01レベル（レコード）の COBOL 名**を取り出す（2026-11-25）。

       1件24バイトの表に「**定義体の名前**（8バイト・EBCDIC・0x40 詰め）＋
       名前16バイト（JEF）」という欄があり、そこがレコード名。
           0x0720  "A18030D1" ＋ JEF16バイト → 処理終了画面
       定義体の名前と同じコードの欄だけを採るので、取り違えようがない。
       無ければ None（原文は定義体の名前そのままでレコードを呼ぶ）。
    """
    if not teigi_na:
        return None
    kagi = teigi_na.encode('cp500').ljust(8, b'\x40')
    i = b.find(kagi)
    while i >= 0:
        # レコード名の欄は**表の終わりの印 ff ff ff ff の直前**にある。
        # これを見ないと、定義体の名前が別のところ（画面の見出し）にも
        # 出てくるので取り違える（A10040D1 で「＊＊＊見積」を拾った）。
        if i + 28 <= len(b) and b[i+24:i+28] == b'\xff\xff\xff\xff':
            s = teigitai_moji._nibyte(b[i+8:i+24]).replace('\u3000', '').strip()
            if (s and '\x00' not in s and not s.startswith('\u3013')
                    and not re.search(r'[\x00-\x1f]', s)):
                return s
        i = b.find(kagi, i + 1)
    return None

def komoku_na(b, shiru=None):
    """項目の**COBOL での名前**を取り出す。

       ■ どこに入っているか（2026-11-24 実測。村上様のご指摘で見つけた）
         定義体の後ろのほうに「項目名表」があり、**1件24バイト**で並ぶ。
             +0  4バイト  項目のコード（EBCDIC。R001 など）
             +4  4バイト  空白（0x40）
             +8 16バイト  **項目の名前**（JEF。0x4040 で埋める）
         先頭の位置はヘッダ 0x00CC が指すこともあるが、**定義体によって
         違う**（0x00CC 方式だと 1.2% しか取れなかった）。そこで
         「コードが名前表に在る24バイトの並び」を探して決める。
       ■ 裏取り
         A10040D1 で、COBOL の「制御項目初期化Ｒ」から取った55個の名前と
         **完全に一致**した（システム日付／処理区／担当者ＣＤ／見積なんば…）。
    """
    shiru = shiru or set()
    out = {}
    n = len(b)
    # **続きの塊に限らず、形の合うものを全部拾う**。
    #   大きい定義体では表が途中で切れていることがあり、続きだけを
    #   追うと半分しか取れなかった（220本中47本がそうだった）。
    i = 0
    while i + 24 <= n:
        if b[i+4:i+8] != b'\x40\x40\x40\x40':
            i += 1; continue
        try:
            nm = b[i:i+4].decode('cp500').strip()
        except Exception:
            i += 1; continue
        if not nm or nm not in shiru or nm in out:
            i += 1; continue
        na = teigitai_moji._nibyte(b[i+8:i+24]).replace('\u3000', '').strip()
        if na and not na.startswith('\u3013'):
            out[nm] = na
            i += 24
            continue
        i += 1
    return out


def hensyuu(b, a):
    """編集（表示の形）を「次の表」の18バイトから取り出す。"""
    kara = {'hen': 0, 'hen2': 0, 'kugiri': '', 'shousuu': 0}
    if not a or a + 18 > len(b):
        return kara
    r = b[a:a+18]
    ku = ''
    if r[10]:
        try:
            ku = bytes([r[10]]).decode('cp500')
        except Exception:
            ku = ''
    return {'hen': r[8], 'hen2': r[9], 'kugiri': ku, 'shousuu': r[11]}


def sashikomi(hen, hen2, shousuu, naga2):
    """編集で差し込まれる文字の数。**表示長 － データ長 と一致する**（実測）。"""
    if (hen & 0x04) or (hen2 & 0x04):
        return 2                      # 日付は必ず3つに区切る
    n = 1 if shousuu else 0           # 小数点
    seisuu = naga2 - shousuu
    if hen & 0x40:
        n += max(0, (seisuu - 1) // 3)   # 3桁ごとのカンマ
    if hen & 0x20:
        n += 1                           # 通貨記号など
    if hen & 0x10:
        n += 1                           # 符号ぶん
    return n


if __name__ == '__main__':
    namae, ko, size = yomu(sys.argv[1])
    ari = [k for k in ko if k['gyo'] is not None]
    print('■ %s  %d バイト ／ 項目 %d（うち 行桁あり %d）'
          % (namae, size, len(ko), len(ari)))
    print()
    print('   %-7s %4s %4s %4s   %s' % ('項目', '行', '桁', '長さ', '備考'))
    for k in ko:
        if k['gyo'] is None:
            print('   %-7s %4s %4s %4s   値=%04X（属性レコード無し）'
                  % (k['nm'], '-', '-', '-', k['ichi']))
        else:
            biko = ''
            if k['naga'] != k['naga2']:
                biko += '長さ2=%d ' % k['naga2']
            if k['k6'] or k['k7']:
                biko += '繰返し?(%d,%d) ' % (k['k6'], k['k7'])
            migi = k['keta'] + k['naga'] - 1
            if migi > 80:
                biko += '★80桁を超える(右端%d) ' % migi
            print('   %-7s %4d %4d %4d   %s' % (k['nm'], k['gyo'], k['keta'], k['naga'], biko))


def gun_na(b):
    """定義体の中の **コード → 名前** を全部拾う（項目も集団項目もレコードも）。

       1件24バイト。8バイトのコード（EBCDIC・0x40 詰め）＋16バイトの名前（JEF）。
       `komoku_na` は4バイトのコード（項目）だけを見ていたが、
       **集団項目（MAS001＝項目表示領域）とレコード名は8バイト**なので拾えない。
    """
    out = {}
    i = 0
    while i + 24 <= len(b):
        try:
            c = b[i:i+8].decode('cp500')
        except Exception:
            i += 1; continue
        cs = c.rstrip(' ')
        if (not cs or not cs.isascii()
                or not re.match(r'^[A-Z0-9\]$#@]+$', cs)
                or c[len(cs):] != ' ' * (8 - len(cs))):
            i += 1; continue
        na = teigitai_moji._nibyte(b[i+8:i+24]).replace('\u3000', '').strip()
        if na and '\x00' not in na and not na.startswith('\u3013'):
            out.setdefault(cs, na)
            i += 24; continue
        i += 1
    return out


def kozo(b, shiru):
    """**項目の階層（レベル）と OCCURS** を取り出す（2026-11-25 実測）。

       ■ どこに入っているか
         定義体の後ろに、1件24バイトの「構造表」がある。
             +0   0x18（この表の1件の長さ）
             +1   レベル番号（01・02・03 …）
             +3   データの長さ
             +4   種別（0=英数 1=数 2=漢字 **16=集団項目**）
             +6-7 OCCURS の回数（集団項目のとき）
             +10-11 1回ぶんの長さ（刻み）
             +16-23 コード（EBCDIC。R001・MAS001 など）
       ■ 何が分かるか（A10060D1 で実測）
             lv01 MAS001 項目表示領域          ← 集団項目
             lv02 MAS002 項目表示テーブル OCCURS 15 刻み80
             lv03 W011〜W019 項番表示・品名・数量…  ← 明細1行ぶん
         ＝ コピー原文（XMDLIB）に書いてあるのと同じ中身。
         これが読めるので、**一覧画面の繰返しと集団項目を推測しないで**
         組めるようになった（従来は行の並びから推測していた）。
       ■ 無い定義体もある
         集団項目も繰返しも無い画面には、この表が無い（421本中323本）。
         その場合は従来どおり、位置の順に並べるだけでよい。
    """
    yoi = []
    i = 0
    while i + 24 <= len(b):
        r = b[i:i+24]
        if r[0] != 0x18 or not (1 <= r[1] <= 49):
            i += 1; continue
        j, mi = i, []
        while j + 24 <= len(b):
            q = b[j:j+24]
            if q[0] != 0x18 or not (1 <= q[1] <= 49):
                break
            try:
                cc = q[16:24].decode('cp500').rstrip(' ')
            except Exception:
                break
            # 集団項目（MAS001 など）は名前表に載っていないことがある。
            # 種別が16（集団項目）で綴りが名前の形なら、通す。
            #   これで打ち切っていたため、帳票は5項目で切れていた。
            if cc not in shiru and not (q[4] == 16
                                        and re.match(r'^[A-Z0-9]+$', cc)):
                break
            mi.append({'nm': cc, 'lv': q[1], 'naga': q[3], 'ty': q[4],
                       'occurs': int.from_bytes(q[6:8], 'big'),
                       'kizami': int.from_bytes(q[10:12], 'big')})
            j += 24
        if len(mi) > len(yoi):
            yoi = mi
        i = j if j > i else i + 1
    return yoi
