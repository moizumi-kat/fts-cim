# -*- coding: utf-8 -*-
"""コピー原文（A1VLD001／A1VLD002）から、ＶＬＤのレコード定義を起こす。

     python3 bin/gen_vld.py <A1VLD001.COB> <A1VLD002.COB> <出力.py>

  ■ ＶＬＤとは（A10040PO.COB 4095行ほか）
     更新用ＶＬＤ１（VLDA1001）・２（VLDA1002）＝ うしろで動く更新処理へ
     「この見積ナンバーを処理せよ」と伝えるメッセージの置き場。
     鑑は「バック開始処理１／２／３」でここに1件書く。
     レコードは **メッセージ制御情報領域**（宛先・処理種別・通番・優先順位・
     データ長）＋ **データ領域**（見積ＮＯ・処理ＩＤ）。

  ■ 根拠
     コピー原文は村上様より受領（2026-11-13）。**原文のとおりに起こす。**
     ※ ファイルによって文字コードが違う（cp932／UTF-8 が混在）。
"""
import sys, re, pathlib

PIC = re.compile(r'^\s*(\d\d)\s+([^\s.]+)\s*(?:PIC\s+([SN]?9|[XN])\((\d+)\)|\.)',
                 re.I)


def yomu(p):
    b = pathlib.Path(p).read_bytes().rstrip(b'\x1a')
    for enc in ('utf-8', 'cp932'):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            continue
    return b.decode('cp932', 'replace')


def hirou(p):
    """(レベル, 名前, 型, 桁) を並び順に返す。型が None なら集団項目。"""
    out = []
    for ln in yomu(p).splitlines():
        ln = ln.rstrip('\r\n')
        if not ln or ln.lstrip().startswith('*'):
            continue
        m = PIC.match(ln)
        if not m:
            continue
        lv, na, kata, keta = m.group(1), m.group(2), m.group(3), m.group(4)
        out.append((int(lv), na, kata.upper() if kata else None,
                    int(keta) if keta else 0))
    return out


def nagasa(kata, keta):
    if kata is None:
        return 0
    return keta * 2 if kata.upper().startswith('N') and kata.upper() != '9' else keta


OUT = sys.argv[3]
b = ['# -*- coding: utf-8 -*-',
     '"""ＶＬＤ（更新用メッセージ）のレコード定義。bin/gen_vld.py が自動生成。',
     '   **手で直さない。** 元はコピー原文 A1VLD001.COB／A1VLD002.COB（2026-11-13 受領）。',
     '',
     '   REC の1件 = (名前, 型, 桁, バイト数, レコード内位置)',
     '     型 "9"=数字 "X"=英数 None=集団項目（中身は次の行から）',
     '"""', '']
for i, p in enumerate(sys.argv[1:3], 1):
    ko = hirou(p)
    ichi, gyo = 0, []
    for lv, na, kata, keta in ko:
        if lv == 1:
            continue
        n = nagasa(kata, keta)
        gyo.append('    (%-20r, %-5r, %2d, %2d, %3d),' % (na, kata, keta, n, ichi))
        ichi += n
    b.append('# %s' % pathlib.Path(p).name)
    b.append('REC%d = [' % i)
    b += gyo
    b.append(']')
    b.append('NAGASA%d = %d' % (i, ichi))
    b.append('')
pathlib.Path(OUT).write_text('\n'.join(b) + '\n', encoding='utf-8')
print('→ %s' % OUT)
