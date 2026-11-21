# -*- coding: utf-8 -*-
"""入っている値が、現行の定義体の桁に収まっているかを確かめる。

SQLite は桁あふれを黙って受けるが、SQL Server は
「String or binary data would be truncated」で止まる。
手元（SQLite）では気づけないので、投入後に必ずこれで見る。

    python 点検/chk_len.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from cim.db import connect, q
from cim.schema_gen import TABLES

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

con = connect()
bad = []
for t in sorted(TABLES):
    ty = dict((c[0], c[1]) for c in TABLES[t]['cols'])
    ja = dict((c[0], c[2]) for c in TABLES[t]['cols'])
    try:
        rows = q(con, 'SELECT * FROM %s' % t)
    except Exception:
        continue
    for i, r in enumerate(rows, 1):
        for c, v in r.items():
            if v is None or v == '': continue
            s = ty.get(c, '')
            m = re.match(r'^(n?)(?:char|varchar)\((\d+)\)$', s)
            if m:
                wide, n = m.group(1) == 'n', int(m.group(2))
                txt = str(v)
                # char/varchar はバイト数、nchar/nvarchar は文字数
                size = len(txt) if wide else len(txt.encode('cp932', 'replace'))
                if size > n:
                    bad.append((t, i, c, ja.get(c, ''), s, txt[:30],
                                '%d%s > %d' % (size, '文字' if wide else 'バイト', n)))
                continue
            m = re.match(r'^(?:decimal|numeric)\((\d+),\s*(\d+)\)$', s)
            if m and isinstance(v, str):
                bad.append((t, i, c, ja.get(c, ''), s, str(v)[:30], '数値の列に文字列'))
con.close()

if not bad:
    print('桁あふれはありません。（%d 表を確認）' % len(TABLES))
    sys.exit(0)
print('■ SQL Server で「切り捨て」エラーになる値が %d 件' % len(bad))
for t, i, c, j, s, v, why in bad:
    print('  %-10s %2d行目 %-9s %-12s %-14s %-30s %s' % (t, i, c, j, s, v, why))
sys.exit(1)
