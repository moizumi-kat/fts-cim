# -*- coding: utf-8 -*-
"""SQL Server のふるまいを手元で再現して、プロトタイプ一式を流す点検。

   手元（SQLite）と本番（SQL Server）は、同じ値でも返しかたが違います。
   この違いを手元で見つけられず、第9版・第10版・第11版と
   続けてお客様の環境で止めてしまいました。その反省からの道具です。

     ・numeric の列   SQL Server は Decimal ／ SQLite は float
     ・char/nchar     SQL Server は桁いっぱいまで半角空白で埋める
                      SQLite は埋めない

   cim/db.py の取り出し口（_val）で両方をそろえていますが、
   「そろえ忘れ」が起きていないかを、ここで**本番と同じ返しかたを
   作って**確かめます。

   使いかた（開発側の点検です。お客様の環境では不要です）
       python 点検/chk_mssql.py
"""
import os, sys, io, runpy, pathlib

MOTO = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(MOTO))
os.environ.setdefault('FTSCIM_DRIVER', 'sqlite')

try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

from cim import db

_honmono = db._val
def _mssql_fuu(v):
    """SQL Server と同じように、文字列を空白で埋めてから渡す。"""
    return _honmono(v + '   ' if isinstance(v, str) else v)
db._val = _mssql_fuu

print('■ SQL Server のふるまい（文字は空白詰め・数は Decimal）で流します')
print()

warui = 0

# ---- 1. 現物の紙との突き合わせ -------------------------------------------
mae = sys.stdout
sys.stdout = ukezara = io.StringIO()
try:
    runpy.run_path(str(MOTO / 'verify.py'), run_name='__main__')
    code = 0
except SystemExit as e:
    code = e.code or 0
except Exception as e:
    code, ukezara = 1, ukezara
    print('%s: %s' % (type(e).__name__, e))
finally:
    sys.stdout = mae
deta = ukezara.getvalue()
gyou = [l for l in deta.splitlines() if l.startswith(('[読]', '[算]', '[外]', '[!]'))]
ok   = len([l for l in gyou if l.rstrip().endswith('OK')])
print('  現物との突き合わせ  : %d 項目 ／ OK %d 件' % (len(gyou), ok))
if code or '一致しました' not in deta:
    warui += 1
    print('  [だめ] verify.py が通りませんでした。以下そのまま：')
    for l in deta.splitlines():
        if 'OK' not in l and l.strip(): print('      ' + l)
else:
    print('  [OK]  すべて現物の紙と一致しました')

# ---- 2. 画面 -------------------------------------------------------------
GAMEN = ('/', '/nippou', '/tables', '/mokuhyo', '/hearing', '/koutei/1',
         '/list/J/11', '/list/Z/11', '/list/U/11', '/go/J/6-11071',
         '/go/G/6-11071', '/go/G/5-21251', '/go/S/6-11071', '/go/K/6-11071')
from cim.web import app
c, dame = app.test_client(), []
for u in GAMEN:
    r = c.get(u, follow_redirects=True)
    h = r.data.decode('utf-8', 'replace')
    if r.status_code != 200 or 'Traceback' in h or 'Decimal(' in h:
        dame.append('%s（%d）' % (u, r.status_code))
print('  画面                : %d 本' % len(GAMEN))
if dame:
    warui += 1
    print('  [だめ] ' + '／'.join(dame))
else:
    print('  [OK]  どの画面も出ました')

print()
if warui:
    print('■ SQL Server のふるまいで、%d か所がうまくいきませんでした。' % warui)
    sys.exit(1)
print('■ SQL Server のふるまいでも、すべて手元どおりに動きました。')
