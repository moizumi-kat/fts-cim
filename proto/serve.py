# -*- coding: utf-8 -*-
"""社内サーバで動かすときの起動（本番用）。

run.py は Flask の開発用サーバで、1人で試す分には十分ですが、
**何人もが同時に使うサーバには向きません**（同時処理が弱く、落ちたら止まったままです）。
こちらは waitress という本番用のサーバで動かします。Windows でもそのまま動きます。

    python serve.py

  環境変数
    FTSCIM_HOST   既定 0.0.0.0（社内LANのどのPCからも見える）
    PORT          既定 5000
    FTSCIM_DRIVER sqlite / mssql
    FTSCIM_DSN    SQL Server の接続文字列（FTSCIM_DRIVER=mssql のとき）
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

from cim import config
from cim.db import connect, init

def main():
    host = os.environ.get('FTSCIM_HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', '5000'))

    # 表が無ければ作る（SQL Server でも SQLite でも同じ呼び方）
    con = connect()
    try:
        init(con)
    finally:
        con.close()

    from cim.web import app
    try:
        from waitress import serve
    except ImportError:
        print('waitress が入っていません。  pip install waitress  を実行してください。')
        sys.exit(1)

    where = ('SQL Server' if config.DRIVER == 'mssql' else 'SQLite（%s）' % config.SQLITE_PATH)
    print('FTS-CIM  データベース＝%s' % where)
    print('  同じ社内LANのパソコンから  http://<このサーバのIPアドレス>:%d' % port)
    print('  止めるときは Ctrl+C')
    serve(app, host=host, port=port, threads=8, ident='FTS-CIM')

if __name__ == '__main__':
    main()
