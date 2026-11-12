# -*- coding: utf-8 -*-
"""CL の本文（コメントを除いたもの）を返す。

  ■ CL のコメント（村上様ご教示 2026-11-12）
      「/.」 から 「./」 までがコメント。**行をまたぐ。**
      例) /.  CLRFILE FILE-KUMIKSF.FCDLIB ./      ← 1行の中
          /.                                       ← 複数行にわたる
          ここは全部コメント
          ./
      全587本のCLがこの書き方を使っている（実測）。
      コメントを外さないと、**コメントの中に書かれたコマンドやプログラム名を
      「生きている」と数えてしまう。**
"""
import re

KOMENTO = re.compile(r'/\.(.*?)(?:\./|$)', re.S)


def honbun(t, uzume=' '):
    """コメントを uzume で潰した本文を返す（行数・桁は変えない）。"""
    out, i, n = [], 0, len(t)
    while True:
        a = t.find('/.', i)
        if a < 0:
            out.append(t[i:])
            break
        out.append(t[i:a])
        b = t.find('./', a + 2)
        if b < 0:                      # 閉じていない＝そこから末尾まで注記
            b = n
            naka = t[a:]
            owari = n
        else:
            naka = t[a:b + 2]
            owari = b + 2
        # 改行は残す（行番号がずれないように）
        out.append(''.join('\n' if c == '\n' else uzume for c in naka))
        i = owari
    return ''.join(out)


def komento_ka(t, ichi):
    """文字位置 ichi がコメントの中かどうか。"""
    return honbun(t, uzume='\x00')[ichi] == '\x00'
