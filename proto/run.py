# -*- coding: utf-8 -*-
"""起動。

  初回だけ：  python3 run.py --seed     （データベースを作って現物サンプルを入れる）
  ふだん：    python3 run.py            （http://127.0.0.1:5000 で開く）
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

if '--seed' in sys.argv:
    from cim import seed
    try:
        n = seed.run()
    except ValueError as e:
        # 現行の桁に収まらない値があった。SQL Server は切り捨てでエラーになるので、
        # 中途半端に入れずにここで止める。
        print('\n' + '!' * 64)
        print('[中止] 現物サンプルが現行ファイルの桁に収まりませんでした。')
        print('  %s' % e)
        print('\n  この表示をそのままお送りください。修正版をお出しします。')
        print('!' * 64)
        sys.exit(1)
    print('データベースを作りました：%s（製番 %d件）' % (__import__('cim.config', fromlist=['x']).SQLITE_PATH, n))
    if '--run' not in sys.argv:
        sys.exit(0)

from cim.config import SQLITE_PATH
if not os.path.exists(SQLITE_PATH):
    from cim import seed
    seed.run()
    print('データベースが無かったので作りました：%s' % SQLITE_PATH)

# 既にあるデータベースにも、足りない表（聞き取りなど）を作っておく
from cim.db import connect, init
_c = connect(); init(_c); _c.close()

from cim.web import app
if __name__ == '__main__':
    port = int(os.environ.get('PORT', '5000'))
    # 既定は自分のPCの中だけ。社内LANの他のPCからも見せたいときは
    #   FTSCIM_HOST=0.0.0.0  を指定する（導入手順書 8 を参照）。
    #   ログイン機能はないので、つながる人は誰でも見られます。
    host = os.environ.get('FTSCIM_HOST', '127.0.0.1')
    print('FTS-CIM Python版 試作  →  http://127.0.0.1:%d' % port)
    if host != '127.0.0.1':
        print('  ※ 社内LANに公開しています（ログイン機能はありません）')
    app.run(host=host, port=port, debug=False)
