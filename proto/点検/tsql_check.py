# -*- coding: utf-8 -*-
"""実際に流れるSQLを全部ひろって、T-SQL（SQL Server）として通るか確かめる。
   アプリを SQLite で一通り動かしながら、発行されたSQL文を記録し、
   それぞれを sqlglot の tsql 方言で構文解析する。"""
import sys, os, sqlite3, collections
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import sqlglot
from sqlglot import exp

SEEN = collections.OrderedDict()

def rec(sql):
    SEEN.setdefault(' '.join(str(sql).split()), str(sql))

# sqlite3 の trace で、実際に発行されたSQLを全部ひろう
from cim import db, seed, repo, hearing
_orig_connect = db.connect
def connect():
    con = _orig_connect()
    con.set_trace_callback(rec)
    return con
db.connect = connect
seed.connect = connect

# ---- 1) 表の作成とサンプル投入
seed.run()
con = connect()
# ---- 2) 画面が使う問合せを一通り
repo.nippou(con); repo.busyo_nm(con, '11')
repo.jutyu_list(con, '11'); repo.syutsuzu_list(con, '11'); repo.uriage_list(con, '11')
repo.jutyuhyo(con, '6-11071'); repo.yosan(con, '6-11071')
repo.has_bukken(con, '6-11071'); repo.bukken(con, '5-21251')
repo.sinchoku(con, '6-11071'); repo.uchiawase(con, '5-11089')
repo.seiban_info(con, '6-11071')
repo.mokuhyo_list(con, 2026); repo.mokuhyo_save(con, 2026, [('11', 432000)])
# ---- 3) 聞き取り
p = {'no': 1, 'nm': 'テスト工程', 'dai': '営業', 'chu': '見積'}
hearing.save(con, p, '営業', '確認', '2026-10-13', [('設問', '答え')], '保留・要相談', 'メモ')
hearing.by_koutei(con, 1); hearing.all_rows(con, '営業', '保留・要相談', 'テスト')
hearing.all_rows(con); hearing.summary(con); hearing.done_set(con)
con.execute('DELETE FROM Z_HEARING'); con.commit()
con.close()

print('ひろったSQL文： %d 種類\n' % len(SEEN))

# ---- 4) T-SQL として解析できるか
ddl_mssql = db.ddl('mssql')
targets = [('表の定義（SQL Server用）', s) for s in ddl_mssql] + \
          [('実行時のSQL', s) for s in SEEN.values()]

ng = []
for kind, sql in targets:
    s = sql.strip()
    if s.upper().startswith('PRAGMA'):          # SQLite接続時のみ発行
        continue
    try:
        sqlglot.parse_one(s, dialect='tsql')
    except Exception as e:
        ng.append((kind, s, e))

print('解析した文： %d' % len([t for t in targets if not t[1].strip().upper().startswith('PRAGMA')]))
if ng:
    print('\n【T-SQLとして解析できなかった文】')
    for kind, s, e in ng:
        print(' ◆ %s\n   %s\n   → %s\n' % (kind, ' '.join(s.split())[:160], e))
else:
    print('→ すべて T-SQL として解析できました。')

# ---- 5) 予約語との衝突
RESERVED = set("""ADD ALL ALTER AND ANY AS ASC AUTHORIZATION BACKUP BEGIN BETWEEN BREAK BROWSE BULK BY
CASCADE CASE CHECK CHECKPOINT CLOSE CLUSTERED COALESCE COLLATE COLUMN COMMIT COMPUTE CONSTRAINT
CONTAINS CONTAINSTABLE CONTINUE CONVERT CREATE CROSS CURRENT CURRENT_DATE CURRENT_TIME
CURRENT_TIMESTAMP CURRENT_USER CURSOR DATABASE DBCC DEALLOCATE DECLARE DEFAULT DELETE DENY DESC
DISK DISTINCT DISTRIBUTED DOUBLE DROP DUMP ELSE END ERRLVL ESCAPE EXCEPT EXEC EXECUTE EXISTS EXIT
EXTERNAL FETCH FILE FILLFACTOR FOR FOREIGN FREETEXT FREETEXTTABLE FROM FULL FUNCTION GOTO GRANT
GROUP HAVING HOLDLOCK IDENTITY IDENTITY_INSERT IDENTITYCOL IF IN INDEX INNER INSERT INTERSECT INTO
IS JOIN KEY KILL LEFT LIKE LINENO LOAD MERGE NATIONAL NOCHECK NONCLUSTERED NOT NULL NULLIF OF OFF
OFFSETS ON OPEN OPENDATASOURCE OPENQUERY OPENROWSET OPENXML OPTION OR ORDER OUTER OVER PERCENT
PIVOT PLAN PRECISION PRIMARY PRINT PROC PROCEDURE PUBLIC RAISERROR READ READTEXT RECONFIGURE
REFERENCES REPLICATION RESTORE RESTRICT RETURN REVERT REVOKE RIGHT ROLLBACK ROWCOUNT ROWGUIDCOL
RULE SAVE SCHEMA SECURITYAUDIT SELECT SEMANTICKEYPHRASETABLE SESSION_USER SET SETUSER SHUTDOWN SOME
STATISTICS SYSTEM_USER TABLE TABLESAMPLE TEXTSIZE THEN TO TOP TRAN TRANSACTION TRIGGER TRUNCATE
TRY_CONVERT TSEQUAL UNION UNIQUE UNPIVOT UPDATE UPDATETEXT USE USER VALUES VARYING VIEW WAITFOR
WHEN WHERE WHILE WITH WITHIN WRITETEXT""".split())

names = set()
for s in ddl_mssql:
    t = sqlglot.parse_one(s, dialect='tsql')
    for c in t.find_all(exp.ColumnDef):
        names.add(c.this.name)
    for c in t.find_all(exp.Table):
        names.add(c.name)
hit = sorted(n for n in names if n and n.upper() in RESERVED)
print('\n表名・列名のうち T-SQL 予約語と同じもの： %s' % (('／'.join(hit)) if hit else 'なし'))
