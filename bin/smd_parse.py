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

   ■ 確かめかた
     桁＋長さが80桁に収まるか、プログラム側が使っている項目名と合うかで検算する。

   使い方  python3 smd_parse.py <画面定義.SMD>
"""
import sys, pathlib, struct

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
        out.append({'nm': n, 'ichi': a, 'tsugi': f[0], 'moji': f[1],
                    'gyo': f[2], 'keta': f[3], 'naga': f[4], 'naga2': f[5],
                    'k6': f[6], 'k7': f[7]})
    return namae, out, len(b)


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
