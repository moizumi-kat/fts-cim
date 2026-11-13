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
    """注釈を uzume で潰した本文を返す（行数・桁は変えない）。

       ■ マニュアルの規則（システム開発手引書 4_4.html・2026-11-13 に確認）
         ・注釈は「/.」と「./」で囲む。数行にわたって書ける。
         ・空白を書けるところならどこに置いてもよい。
         ・**注釈と文字ストリング型直定数は、先に始まったほうが優先。**
           したがって
             − 注釈の中の引用符「'」は注釈の一部
             − **文字ストリング型直定数の中の「/.」「./」は、その値の一部**
           ＝ 引用符の中の「/.」は注釈の始まりではない。
         村上様のご教示（2026-11-12）に、この引用符の扱いを足したもの。
         （手元のCL587本では引用符の中に「/.」は0件だったので、
           いまの数には影響しない。規則として正しくしておく。）
    """
    out, i, n = [], 0, len(t)
    while i < n:
        c = t[i]
        if c == "'":                       # 文字ストリング型直定数
            j = t.find("'", i + 1)
            if j < 0:                      # 閉じていない
                out.append(t[i:]); break
            out.append(t[i:j + 1]); i = j + 1
            continue
        if t.startswith('/.', i):          # 注釈
            b = t.find('./', i + 2)
            owari = n if b < 0 else b + 2
            naka = t[i:owari]
            # 改行は残す（行番号がずれないように）
            out.append(''.join('\n' if ch == '\n' else uzume for ch in naka))
            i = owari
            continue
        out.append(c); i += 1
    return ''.join(out)


def komento_ka(t, ichi):
    """文字位置 ichi がコメントの中かどうか。"""
    return honbun(t, uzume='\x00')[ichi] == '\x00'
