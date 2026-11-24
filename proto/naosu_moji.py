# -*- coding: utf-8 -*-
"""取り込んだ日本語の字を、現行システム（cp932）の流儀へ揃える。

    python naosu_moji.py

■ なぜ要るか（2026-11-24 実測）
  JEF の2バイト文字は EUC-JP とほぼ同じ並びなので EUC-JP として読んでいるが、
  **同じ JIS の字でも Unicode への写し方が EUC-JP と cp932 で違う**
  （有名な「波ダッシュ問題」）。現行システムのデータは SQL Server 経由で
  cp932 の流儀で入っているため、揃えないと突き合わせたときに食い違う。
  実データで 情報物件データ鑑 AJBGFP の 特記事項３ が70件ちがった。

  読み取り側（bin/teigitai_moji.py の CP932_NI）は直したので、
  これから取り込む分は正しい。**すでに取り込んだ分**をここで直す。
"""
import sys, os, pathlib, time

ここ = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ここ))
try:
    sys.stdout.reconfigure(errors='replace', line_buffering=True)
except Exception:
    pass
from cim.db import connect, Q
from cim.schema_gen import TABLES

KUMI = [('−', '－'),   # − → －
        ('〜', '～'),   # 〜 → ～
        ('‖', '∥'),   # ‖ → ∥
        ('¢', '￠'),   # ¢ → ￠
        ('£', '￡'),   # £ → ￡
        ('¬', '￢')]   # ¬ → ￢


def main():
    con = connect()
    naoshi = 0
    hyo = 0
    for t, v in sorted(TABLES.items()):
        cols = [c[0] for c in v['cols']
                if str(c[1]).startswith(('nchar', 'nvarchar'))]
        if not cols:
            continue
        try:
            if not con.execute('SELECT 1 FROM %s LIMIT 1' % Q(t)).fetchone():
                continue
        except Exception:
            continue
        # 1回の走査で、全部の日本語の列をまとめて直す
        setq = []
        for c in cols:
            shiki = Q(c)
            for a, b in KUMI:
                shiki = 'replace(%s, ?, ?)' % shiki
            setq.append('%s = %s' % (Q(c), shiki))
        atai = [x for _c in cols for ab in KUMI for x in ab]
        jo = ' OR '.join('instr(%s, ?) > 0' % Q(c) for c in cols for _ab in KUMI)
        atai += [ab[0] for c in cols for ab in KUMI]
        t0 = time.time()
        cur = con.execute('UPDATE %s SET %s WHERE %s'
                          % (Q(t), ', '.join(setq), jo), tuple(atai))
        n = cur.rowcount
        con.commit()
        if n:
            hyo += 1
            naoshi += n
            print('   %-10s %8s件 直した（%.1f秒）' % (t, format(n, ','),
                                                 time.time() - t0))
    print()
    print('%d表 %s件を直しました' % (hyo, format(naoshi, ',')))
    con.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
