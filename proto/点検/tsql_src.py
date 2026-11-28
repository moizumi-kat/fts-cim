# -*- coding: utf-8 -*-
"""ソースに書いてあるSQL文（置換パラメータ ? のまま）を取り出して、T-SQLとして解析する。
   trace でひろった「値が入った形」とは別に、?付きの素の形でも通ることを確かめる。"""
import ast, sys, os, re, glob
import sqlglot
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

SQL = re.compile(r'^\s*(SELECT|INSERT|UPDATE|DELETE|CREATE|IF)\b', re.I)
RE_LIKE = re.compile(r'\\[sSwWdD(]|\(\?|\[\^')      # 正規表現の文字列は除く

def fill(sql):
    """ソース中の %s を、SQLとして成り立つ形に埋める。
       VALUES(%s) は置換パラメータの並び、それ以外は表名とみなす。"""
    sql = re.sub(r'VALUES\(%s\)', 'VALUES(?,?,?)', sql, flags=re.I)
    return sql.replace('%s', 'syutsuzu')

found, ng = [], []
for f in sorted(glob.glob(os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'cim', '*.py'))):
    tree = ast.parse(open(f, encoding='utf-8').read(), f)
    for n in ast.walk(tree):
        v = None
        if isinstance(n, ast.Constant) and isinstance(n.value, str) and SQL.match(n.value):
            v = n.value
        elif isinstance(n, ast.BinOp) and isinstance(n.op, ast.Mod) and \
             isinstance(n.left, ast.Constant) and isinstance(n.left.value, str) \
             and SQL.match(n.left.value):
            v = n.left.value
        if v is None or RE_LIKE.search(v):      # 正規表現リテラルは SQL ではない
            continue
        found.append((f, n.lineno, fill(v)))

seen = set()
for f, ln, sql in found:
    k = ' '.join(sql.split())
    if k in seen: continue
    seen.add(k)
    try:
        sqlglot.parse_one(sql, dialect='tsql')
    except Exception as e:
        ng.append((f, ln, k, e))

print('ソースから取り出したSQL： %d 文（重複を除く）' % len(seen))
if ng:
    print('\n【T-SQLとして解析できなかった文】')
    for f, ln, k, e in ng:
        print(' ◆ %s:%d\n   %s\n   → %s\n' % (f, ln, k[:170], e))
else:
    print('→ すべて T-SQL として解析できました（置換パラメータ ? のまま）。')

# ? が T-SQL の置換パラメータとして扱われているかの念押し
t = sqlglot.parse_one("SELECT a FROM t WHERE b=? AND c LIKE ?", dialect='tsql')
print('\n「?」の扱い：', t.sql(dialect='tsql'))
