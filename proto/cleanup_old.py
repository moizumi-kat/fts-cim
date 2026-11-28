# -*- coding: utf-8 -*-
"""前の版が作ったテーブルを片付ける。

    py -3.13 cleanup_old.py          ← 何が消えるかを表示するだけ（消しません）
    py -3.13 cleanup_old.py --yes    ← 実際に消す

消すのは次の2つだけです。
  (1) 10/14 より前の版の、独自の名前のテーブル（busyo・nip_jisseki など20表）
  (2) 10/14 の版が作った、**列名が日本語**のテーブル（NIPSYOFP など）

★ 安全のための歯止め（重要）
  現行ファイル名のテーブル（AJUGFP など）は、データベースサーバへ
  レプリケーションしている**本番の表と同じ名前**です。
  そのため、列名が英名のテーブルには **絶対に触れません**。
  消すのは「列名が日本語になっている＝この試作の前の版が作ったと判る表」だけです。
  さらに、この試作が作らない表（AJBMFP・FSKBMP など）が見つかったときは、
  レプリケーション先につながっている可能性が高いので、その場で中止します。
"""
import os, sys, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cim import config
from cim.db import connect, q
from cim.schema_gen import TABLES

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

# (1) 2026-10-14 より前の版が作っていたテーブル
OLD = ['busyo', 'nip_mokuhyo', 'nip_jisseki', 'nip_juritsu', 'nip_seisan',
       'jutyu', 'syutsuzu', 'uriage',
       'jutyuhyo', 'jutyuhyo_meisai', 'yosan', 'yosan_meisai', 'mensu',
       'bukken', 'bukken_meisai', 'bukken_kettei',
       'sinchoku', 'uchiawase', 'seiban_mst', 'hearing']

MSSQL = lambda: config.DRIVER == 'mssql'
JA    = re.compile('[\u3041-\u309f\u30a1-\u30f6\u4e00-\u9fa5]')  # ひらがな・カタカナ・漢字

def tables(con):
    """いまつながっている先にある表の名前。"""
    if MSSQL():
        return [r['name'] for r in q(con, "SELECT name FROM sys.tables")]
    return [r['name'] for r in
            q(con, "SELECT name FROM sqlite_master WHERE type='table'")]

def columns(con, t):
    if MSSQL():
        return [r['name'] for r in q(con,
                "SELECT c.name FROM sys.columns c WHERE c.object_id=OBJECT_ID(?)", (t,))]
    return [r['name'] for r in q(con, 'PRAGMA table_info(%s)' % t)]

def count(con, t):
    try:    return q(con, 'SELECT COUNT(*) AS n FROM %s' % t)[0]['n']
    except Exception: return -1

def main():
    doit = '--yes' in sys.argv
    con = connect()
    try:
        print('つなぎ先 : %s' % ('SQL Server' if MSSQL() else 'SQLite'))
        here = set(tables(con))

        # ---- 歯止め：レプリケーション先につながっていないか ----------------
        # この試作が作らないのに、現行ファイル名の表がたくさんある＝本番の可能性
        yoso = {t.upper() for t in TABLES} | {'Z_HEARING', 'Z_ASOF'}
        hoka = sorted(t for t in here
                      if t.upper() not in yoso and t not in OLD
                      and re.match(r'^[A-Z0-9]{5,10}$', t.upper()))
        if hoka:
            print('\n【中止】この試作が作らない、現行ファイル名らしい表が %d 個あります。' % len(hoka))
            print('        ', '  '.join(hoka[:12]), ('…' if len(hoka) > 12 else ''))
            print('        レプリケーション先のデータベースにつながっている可能性があります。')
            print('        試作は**別のデータベース**（例 FTSCIM_PROTO）でお願いします。')
            print('        何も消していません。')
            return 2

        # ---- (1) 古い名前の表 ----------------------------------------------
        f1 = [t for t in OLD if t in here]
        # ---- (2) 列名が日本語の表（前の版が作ったもの）----------------------
        f2 = []
        for t in sorted(TABLES):
            real = next((x for x in here if x.upper() == t.upper()), None)
            if not real: continue
            cols = columns(con, real)
            if any(JA.search(c) for c in cols):
                f2.append(real)                     # 日本語の列＝前の版のもの
            # 英名の列なら、本番の表かもしれないので触れない

        if not f1 and not f2:
            print('\n古い名前のテーブルはありませんでした。片付けは不要です。')
            return 0

        if f1:
            print('\n(1) 古い名前のテーブル %d 個' % len(f1))
            for t in f1: print('   %-18s %6d件' % (t, count(con, t)))
        if f2:
            print('\n(2) 列名が日本語のテーブル（10/14 の版が作ったもの）%d 個' % len(f2))
            for t in f2: print('   %-18s %6d件' % (t, count(con, t)))

        if not doit:
            print('\n（まだ消していません）')
            print('消すときは  py -3.13 cleanup_old.py --yes  と実行してください。')
            return 0

        for t in f1 + f2:
            con.execute('DROP TABLE %s' % t)
        con.commit()
        print('\n%d個を消しました。' % len(f1 + f2))
        print('このあと  py -3.13 dbcheck.py  で、現行ファイル名のテーブルをご確認ください。')
    finally:
        con.close()
    return 0

if __name__ == '__main__':
    sys.exit(main())
