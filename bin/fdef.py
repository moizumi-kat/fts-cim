# -*- coding: utf-8 -*-
"""オフコンのファイル定義体（.SMB）を読む。

  ■ 出どころ
    村上様よりいただいた「ファイル定義解析.md」（2026-11-24）。
    .SMB は SAVMBR で退避した FDG のファイル定義体（FFD）。
    こちらで実物にあてて確かめながら実装した。

  ■ 全体の形
      0x000〜0x4FF  管理ヘッダ
      0x500〜       **256バイトの定義レコード**が並ぶ
    レコードの先頭4バイト ＝ 種別2バイト ＋ 連番（パック10進2バイト）
      1110 M 見出し（MFFD）／1120 G 履歴／1210 F ファイル情報
      1310 R レコード情報／1320 I 項目情報／1999 E 終了

  ■ 項目情報レコード（I）＝ いちばん大事
      +0x04 1  'I'
      +0x05 8  項目名
      +0x0D 8  親の集団項目名（空白なら最上位）
      +0x15 5  開始位置（1起点）
      +0x1A 5  桁数（集団項目は0）
      +0x1F 1  型  G集団／X英数／N日本語／U外部10進／P内部10進／B2進
      +0x20 1  符号（1=あり）
      +0x21 2  小数部の桁数
      +0x23 1  表区分 0なし／1繰返しの起点／2それに従属
      +0x24 5  反復数
      +0x29 5  バイト長（繰返し1回ぶん）
      +0xC1    見出し（'N'＋文字数2桁＋JEF）

  ■ 文字コード
    半角英数字・数字欄は EBCDIC（cp500）、日本語は JEF（EUC-JPと同じ並び）。
"""
import pathlib

try:
    from . import teigitai_moji
except Exception:
    import teigitai_moji

HAJIME = 0x500
NAGASA = 256


def _e(b):
    """EBCDIC の文字。"""
    return b.decode('cp500', 'replace').rstrip()


def _n(b):
    """EBCDIC の数字欄 → 整数。"""
    s = ''.join(chr(0x30 + (c - 0xF0)) if 0xF0 <= c <= 0xF9 else '' for c in b)
    return int(s) if s else 0


def _midashi(b, i):
    """見出し（'N'＋文字数2桁＋JEF）。"""
    if i + 3 > len(b) or b[i:i+1] != b'\xd5':          # EBCDIC の 'N'
        return ''
    n = _n(b[i+1:i+3])
    if not n:
        return ''
    return teigitai_moji._nibyte(b[i+3:i+3+n*2]).replace('　', '').strip()


def yomu(michi):
    """.SMB 1本 → {'na':定義体名, 'rec':レコード名, 'naga':レコード長,
                    'ko':[項目…]}。項目は定義体の並び順。"""
    b = pathlib.Path(michi).read_bytes()
    out = {'na': pathlib.Path(michi).stem.upper(), 'rec': None,
           'naga': 0, 'ko': [], 'midashi': ''}
    i = HAJIME
    while i + NAGASA <= len(b):
        r = b[i:i+NAGASA]
        shu = '%02x%02x' % (r[0], r[1])
        kind = r[4:5]
        if shu == '1999' or kind == b'\xc5':            # 'E' 終了
            break
        if kind == b'\xd4':                             # 'M' 見出し
            out['na'] = _e(r[0x09:0x11]) or out['na']
            out['midashi'] = _midashi(r, 0xC1)
        elif kind == b'\xc6':                           # 'F' ファイル情報
            out['naga'] = _n(r[0x29:0x2D])
        elif kind == b'\xd9':                           # 'R' レコード情報
            out['rec'] = _e(r[0x05:0x0D])
        elif kind == b'\xc9':                            # 'I' 項目情報
            k = {
                'na':     _e(r[0x05:0x0D]),
                'oya':    _e(r[0x0D:0x15]),
                'ichi':   _n(r[0x15:0x1A]),
                'keta':   _n(r[0x1A:0x1F]),
                'kata':   _e(r[0x1F:0x20]),
                'fugo':   _e(r[0x20:0x21]) == '1',
                'shou':   _n(r[0x21:0x23]),
                'hyo':    _n(r[0x23:0x24]),
                'kaisu':  _n(r[0x24:0x29]),
                'naga':   _n(r[0x29:0x2E]),
                'midashi': _midashi(r, 0xC1),
            }
            if k['na']:
                out['ko'].append(k)
        i += NAGASA
    return out


def naga_keisan(kata, keta):
    """型と桁数からバイト長を出す（FDG 表2.16）。"""
    if kata == 'X':
        return keta
    if kata == 'N':
        return keta * 2
    if kata == 'U':
        return keta
    if kata == 'P':
        return keta // 2 + 1
    if kata == 'B':
        return 2 if keta <= 4 else (4 if keta <= 9 else 8)
    return 0          # G（集団項目）は配下の合計


def kensan(d):
    """読み取りが筋の通ったものかを確かめる。合わない点を並べて返す。"""
    warui = []
    for k in d['ko']:
        if k['kata'] == 'G':
            continue
        y = naga_keisan(k['kata'], k['keta'])
        if y and y != k['naga']:
            warui.append('%s 型%s 桁%d → %dバイトのはずが %d'
                         % (k['na'], k['kata'], k['keta'], y, k['naga']))
    # 最後の項目の終わりがレコード長と合うか
    if d['ko'] and d['naga']:
        owari = max(k['ichi'] - 1 + k['naga'] * (k['kaisu'] if k['hyo'] == 1 else 1)
                    for k in d['ko'])
        if owari != d['naga']:
            warui.append('項目の終わり %d とレコード長 %d が合わない'
                         % (owari, d['naga']))
    return warui


def yomu_zenbu(dir_):
    """置き場の .SMB を全部読んで {ファイル名: 定義} にする。

       **ファイル名で引く**こと。定義体の中の名前は、まれにファイル名と食い違う
       （実測4本: AREGFS→AREGFP, AREKFS→AREKFP, CZDLFP→CZDLFS, FHNEMP→FHNEFP）。
       現行のプログラムはファイル名で開くので、ファイル名が正。
       中の名前でも引けるように、食い違う分は別名としても入れておく。"""
    import pathlib
    out, betsu = {}, {}
    for p in sorted(pathlib.Path(dir_).glob('*.SMB')):
        try:
            d = yomu(str(p))
        except Exception:
            continue
        if not d or not d.get('ko'):
            continue
        out[p.stem] = d
        if d.get('na') and d['na'] != p.stem:
            betsu.setdefault(d['na'], d)
    for k, v in betsu.items():
        out.setdefault(k, v)
    return out
