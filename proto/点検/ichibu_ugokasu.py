# -*- coding: utf-8 -*-
"""指定したプログラムだけを、zenbu_ugokasu と同じやり方で動かす（A/B用）。

     python3 -I 点検/ichibu_ugokasu.py A30120PP B10092PP …
     python3 -I 点検/ichibu_ugokasu.py -60 A30120PP      # 打ち切りを60秒に

zenbu_ugokasu は 857本を回すので1回30分かかる。直した効き目を見るには
**同じ土俵で数本だけ**回したい。MOTO（原文の置き場）の glob を差し替える。
"""
import sys, pathlib

NA = [x for x in sys.argv[1:] if not x.startswith('-')]
# `-60` のように書くと打ち切りを60秒にする（遅いだけなのか確かめるため）
BYOU = next((x[1:] for x in sys.argv[1:]
             if x.startswith('-') and x[1:].isdigit()), None)
sys.argv = [sys.argv[0]] + (['0', BYOU] if BYOU else [])
ここ = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ここ))
import zenbu_ugokasu as z


class Hako:
    """glob だけ差し替えた、原文置き場の身代わり。"""

    def __init__(self, moto, na):
        self._moto, self._na = moto, na

    def glob(self, p):
        return [self._moto / (n + '.COB') for n in self._na]


if __name__ == '__main__':
    if not NA:
        print(__doc__)
        sys.exit(1)
    z.MOTO = Hako(z.MOTO, NA)
    z.main()
