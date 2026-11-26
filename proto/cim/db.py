# -*- coding: utf-8 -*-
"""接続と表の定義。

**テーブルも列名も現行システムのファイル定義そのものです**（村上様ご指示・2026-10-16）。

  src='rep'  データベースサーバへ**レプリケーションしている**ファイル。
             村上様よりお送りいただいた定義体（DDL）を一字一句そのまま使う。
             列名・型・桁・NOT NULL・既定値・主キー・並び順まで同じ。
             CAD・営業支援システム等の周辺ソフトが同じ定義を見ているため、
             ここを変えると周辺ソフト全部の改修になってしまう。
             → 点検/rep_same.py で定義体と突き合わせて確かめられる。

  src='conv' レプリケーションしていないファイル。
             「COBOLファイル定義からSQL Serverテーブル定義への
               フィールド名変換仕様書」（村上様ご提供）に従って
             現行のレコードリストの PIC から機械的に生成する。
             繰返し（OCCURS）は英名を _ で6文字に詰めて _1, _2 … と水平展開。

  テーブル名 ＝ 現行の**物理**ファイル名    例）NIPSYOFP（営業日報照会マスタ）
                COBOL が COPY する NIPSYOL2 などは論理ファイル（キー順違い）なので、
                実体である物理ファイル1本につき1表にしています。論理名も保持（ronri）。
  列名      ＝ 現行の COBOL 英名（英大文字）例）EGJMOK（受注目標額）
                日本語の項目名は画面の見出し用に別に持っています。

★ レプリケーション対象の表は**本番の表と名前が同じ**です。
   試作は必ず別のデータベース（例 FTSCIM_PROTO）でお使いください。
   dbcheck.py / cleanup_old.py に、取り違いを止める歯止めを入れてあります。

定義は cim/schema_gen.py。gen_schema.py が機械的に生成しており、
こちらで名前・桁を考えたものはありません。

SQLite と SQL Server のどちらでも通る書き方にしてあります。
"""
import sqlite3, re
from decimal import Decimal
from . import config
from .schema_gen import TABLES

# ---------------------------------------------------------------- 値の型をそろえる
#   SQL Server（pyodbc）は numeric の列を decimal.Decimal で返し、
#   SQLite は float で返します。同じコードが両方で同じように動くよう、
#   取り出した時点で **Decimal にそろえます**（COBOL も10進で計算するため、
#   Decimal のほうが現行に近い）。float のまま混ぜると
#   「Decimal と float は掛けられない」で止まります。
def _val(v):
    if isinstance(v, float):
        return Decimal(str(v))
    if isinstance(v, str):
        # SQL Server は char／nchar の値を、桁いっぱいまで**半角の空白で埋めて**
        # 返します（SQLite は埋めません）。埋めぶんは現行ファイルの桁合わせで
        # あって中身ではないので、ここで落として両方をそろえます。
        # 落とすのは半角の空白だけです。全角の空白は中身の一部（例「　総合計　」）
        # ですので残します。
        return v.rstrip(' ')
    return v

# ---------------------------------------------------------------- 接続
def connect():
    if config.DRIVER == 'mssql':                      # 本番（SQL Server）
        import pyodbc
        return pyodbc.connect(config.MSSQL_DSN)
    # SQLite は Decimal をそのままでは書けません（SQL Server は書けます）。
    # 文字にして渡すと、numeric の列には数として入ります。
    sqlite3.register_adapter(Decimal, str)
    con = sqlite3.connect(config.SQLITE_PATH)
    con.row_factory = sqlite3.Row
    con.execute('PRAGMA foreign_keys=ON')
    return con

def q(con, sql, args=()):
    cur = con.cursor()                                # pyodbc も sqlite3 も同じ
    cur.execute(sql, args)
    cols = [d[0] for d in cur.description]
    return [dict(zip(cols, [_val(v) for v in r])) for r in cur.fetchall()]

def q1(con, sql, args=()):
    """1件だけ取る。

       ■ 全件を読んでいた（2026-11-26 実測）
         これまで `q()` を呼んでいたので、**合致する行を全部** Python の
         dict に移してから先頭1件を返していた。ＣＯＢＯＬ の
         READ／START は1件取るだけなので、
             START AJBKFL1 KEY >= …   → AJBKFP 753,364件を全部読む
         になり、1回の START で10秒を超えていた（A30120PP ほか12本）。
         `fetchone()` に変えると、ＳＱＬ側が1件見つけたところで止まる。
         返す形（{列名: 値} か None）は前と同じ。
    """
    cur = con.cursor()
    cur.execute(sql, args)
    r = cur.fetchone()
    if r is None:
        return None
    cols = [d[0] for d in cur.description]
    return dict(zip(cols, [_val(v) for v in r]))

def ex(con, sql, args=()):
    cur = con.cursor()
    cur.execute(sql, args)
    return cur

def Q(name):
    """日本語を含む名前を囲む。SQLite も SQL Server も [ ] を受ける。"""
    return '[%s]' % name

# ---------------------------------------------------------------- 本システム独自の表
#   現行システムには無い、このプロトタイプだけの表。名前が現行と混ざらないよう接頭辞をつける。
LOCAL = """
-- 現場での聞き取り（ヒアリング）の記録。現行システムには無い、このプロトタイプ独自の表。
CREATE TABLE IF NOT EXISTS Z_HEARING(
  id        INT IDENTITY PRIMARY KEY,
  koutei_no INT NOT NULL,
  koutei_nm NVARCHAR(120),
  dai       NVARCHAR(40), chu NVARCHAR(40),
  bumon     NVARCHAR(60), hito NVARCHAR(60), kiki_bi NVARCHAR(20),
  shitsumon NVARCHAR(200), kotae NVARCHAR(4000),
  hantei    NVARCHAR(30), memo NVARCHAR(4000), created NVARCHAR(20)
);
CREATE INDEX IF NOT EXISTS ix_z_hearing ON Z_HEARING(koutei_no);

-- 営業日報の「現在時点」。現行は日次更新で上書きするが、
-- 試作では現物サンプルの時点（26年9月30日現在）を持たせるために使う。
CREATE TABLE IF NOT EXISTS Z_ASOF(
  key_nm    NVARCHAR(20) NOT NULL PRIMARY KEY,
  val       NVARCHAR(60)
);
"""

def _default(expr, driver):
    """定義体の既定値を、つなぎ先のデータベースで通る書き方に直す。

    SQL Server は N'　' や (0.) を受けるが、SQLite は受けない。
    値そのものは変えない（空白は空白、0 は 0）。
    """
    e = expr.strip()
    if driver == 'mssql':
        return e
    if e.startswith("N'"):          # N'　' → '　'
        e = e[1:]
    if re.match(r'^\(\s*\d+\.\s*\)$', e):     # (0.) → (0.0)
        e = e[:-1].rstrip() + '0)'
    return e

def _ddl_table(name, t, driver):
    # 列は (列名, SQLの型, 現行の日本語項目名, 現行のPIC)
    nn   = set(t.get('notnull') or [])
    dflt = t.get('default') or {}
    cols = []
    for c, ty, ja, pic in t['cols']:
        s = '  %-14s %s' % (Q(c), ty)
        if c in nn:   s += ' NOT NULL'
        if c in dflt: s += ' DEFAULT %s' % _default(dflt[c], driver)
        cols.append(s)
    if t['pk']:
        cols.append('  PRIMARY KEY(%s)' % ', '.join(Q(c) for c in t['pk']))
    return 'CREATE TABLE IF NOT EXISTS %s(\n%s\n)' % (name, ',\n'.join(cols))

def _strip_comments(s):
    return re.sub(r'--[^\n]*', '', s)

def ddl(driver=None):
    """CREATE 文を、つなぎ先のデータベースに合わせて組み立てて返す。"""
    driver = driver or config.DRIVER
    stmts = [_ddl_table(n, t, driver) for n, t in sorted(TABLES.items())]
    stmts += [s.strip() for s in _strip_comments(LOCAL).split(';') if s.strip()]
    out = []
    for stmt in stmts:
        stmt = _strip_comments(stmt).strip()
        if driver == 'mssql':
            m = re.match(r'CREATE TABLE IF NOT EXISTS\s+(\w+)\s*\((.*)\)\s*$', stmt, re.S | re.I)
            if m:
                nm, body = m.group(1), m.group(2)
                body = body.replace('INT IDENTITY PRIMARY KEY', 'INT IDENTITY(1,1) PRIMARY KEY')
                out.append("IF OBJECT_ID(N'%s', N'U') IS NULL\nCREATE TABLE %s(%s)" % (nm, nm, body))
                continue
            m = re.match(r'CREATE INDEX IF NOT EXISTS\s+(\w+)\s+ON\s+(\w+)\s*\((.*)\)\s*$', stmt, re.S | re.I)
            if m:
                ix, tbl, cols = m.groups()
                out.append("IF INDEXPROPERTY(OBJECT_ID(N'%s'), N'%s', 'IndexID') IS NULL\n"
                           "CREATE INDEX %s ON %s(%s)" % (tbl, ix, ix, tbl, cols))
                continue
            out.append(stmt)
        else:
            out.append(stmt.replace('INT IDENTITY PRIMARY KEY', 'INTEGER PRIMARY KEY'))
    return out

def init(con, driver=None):
    for stmt in ddl(driver):
        con.execute(stmt)
    con.commit()

def table_list():
    """現行ファイル一覧（画面で出すため）。"""
    return [(n, t['nm'], len(t['cols'])) for n, t in sorted(TABLES.items())]
