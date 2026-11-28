# -*- coding: utf-8 -*-
"""データベースにつながるかを確かめる。SQL Server へ切り替えたあとの確認用。

    python dbcheck.py

つまずきやすい所は、つなぐ前にこちらで見つけて画面に出します。
"""
import os, sys, re, platform
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cim import config
from cim.db import connect, init, q, ddl

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
NG = []        # 先に見つけた問題
def ng(title, body):
    NG.append((title, body))

print('=== FTS-CIM データベース接続確認 ===')
print('Python   : %s (%s)' % (platform.python_version(), platform.machine()))
print('OS       : %s' % platform.platform())

# ---- 1. Python のバージョン（pyodbc の対応状況）
MAJOR, MINOR = sys.version_info[:2]
PYODBC_OK = (3, 9) <= (MAJOR, MINOR) <= (3, 14)
if not PYODBC_OK:
    ng('Python %d.%d には pyodbc の出来合いの部品がありません' % (MAJOR, MINOR),
       'pyodbc が Windows用に配っているのは Python 3.9〜3.14 です。\n'
       '  それ以外だと、pip がソースから組み立てようとして\n'
       '  「Microsoft Visual C++ 14.0 or greater is required」で止まります。\n'
       '\n'
       '  → Python 3.13 を入れ直してください（こちらで動作を確認している版です）。\n'
       '     python.org から 3.13 の Windows installer (64-bit) を入れ、\n'
       '     インストール時に「Add python.exe to PATH」にチェック。\n'
       '     いまの %d.%d は消さなくても構いません。py ランチャーで使い分けられます：\n'
       '        py -3.13 -m pip install -r requirements.txt\n'
       '        py -3.13 dbcheck.py' % (MAJOR, MINOR))

print('つなぎ先 : %s' % ('SQL Server' if config.DRIVER == 'mssql' else 'SQLite'))
if getattr(config, 'FROM_SAVED', None):
    print('　（%s は setx で保存された値を読みました。'
          'この画面を開き直す必要はありません）' % '／'.join(config.FROM_SAVED))

# ---- 2. 環境変数が「この画面に」効いているか
def win_env(name):
    """Windows に setx で保存された値を読む（いまの画面に効いていなくても読める）。"""
    if os.name != 'nt': return None
    import winreg
    for root, path in ((winreg.HKEY_LOCAL_MACHINE,
                        r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'),
                       (winreg.HKEY_CURRENT_USER, 'Environment')):
        try:
            with winreg.OpenKey(root, path) as k:
                return winreg.QueryValueEx(k, name)[0]
        except OSError:
            pass
    return None

env_drv = os.environ.get('FTSCIM_DRIVER')
env_dsn = os.environ.get('FTSCIM_DSN')
if config.DRIVER != 'mssql':
    print('\n（SQLite として動いています）')
    saved = win_env('FTSCIM_DRIVER')
    if saved:
        ng('setx で設定した FTSCIM_DRIVER の値が "%s" です' % saved,
           'SQL Server につなぐには mssql を設定してください。\n'
           '        setx /M FTSCIM_DRIVER mssql')
    elif env_drv and env_drv != 'mssql':
        ng('FTSCIM_DRIVER の値が "%s" です' % env_drv,
           'SQL Server につなぐには mssql を設定してください。')
    else:
        print('　SQL Server につなぐ場合は、サーバ導入手順書 6 をご覧ください。')
else:
    try:
        import pyodbc
        print('pyodbc   : %s' % pyodbc.version)
        drv = pyodbc.drivers()
        print('ODBCドライバ（このPCに入っているもの）:')
        for d in drv: print('   - %s' % d)
        if not any('SQL Server' in d for d in drv):
            ng('SQL Server用の ODBC ドライバが見つかりません',
               'Microsoft ODBC Driver 18 for SQL Server を入れてください。\n'
               '  （「msodbcsql18」で検索）')
    except ImportError:
        ng('pyodbc が入っていません',
           'python -m pip install --no-index --find-links vendor pyodbc\n'
           '  （vendor が無ければ） python -m pip install pyodbc')

    dsn = env_dsn or ''
    if not dsn:
        ng('環境変数 FTSCIM_DSN が空です', 'サーバ導入手順書 6 をご覧ください。')
    else:
        print('接続文字列: %s' % re.sub(r'(PWD=)[^;]*', r'\1********', dsn, flags=re.I))
        ph = re.findall(r'<[^>]+>', dsn)
        if ph:
            ng('接続文字列に、書き換えていない部分が残っています： %s' % '／'.join(ph),
               '手順書の例をそのまま貼ると <サーバ名> などが残ります。\n'
               '  実際のサーバ名・パスワードに置き換えて、setx をやり直してください。\n'
               '  例： SERVER=SRV01   または  SERVER=SRV01\\SQLEXPRESS')

    # SQLite のファイルが残っていると紛らわしい
    if os.path.exists(config.SQLITE_PATH):
        print('\n（参考）SQLite のファイル %s が残っています。'
              % os.path.basename(config.SQLITE_PATH))
        print('　　　　SQL Server に切り替えたあとは使いません。消してかまいません。')

# --sqlite を付けると、SQLite のままでも以下の確認を続けます（手元での下見用）。
if NG and '--sqlite' in sys.argv and config.DRIVER != 'mssql':
    print('\n（--sqlite が付いているので、SQLite のまま確認を続けます）')
    NG = []

if NG:
    print('\n' + '!' * 64)
    for i, (t, b) in enumerate(NG, 1):
        print('\n[%d] %s\n  %s' % (i, t, b))
    print('\n' + '!' * 64)
    print('\n上の点を直してから、もう一度 dbcheck.py を実行してください。')
    print('\n--- ここまでの表示を、そのままお送りいただければ確認いたします ---')
    sys.exit(1)

# ---- 3. 実際につなぐ
try:
    con = connect()
except Exception as e:
    print('\n[NG] つながりませんでした。\n  %s' % e)
    print('\n  よくある原因（サーバ導入手順書 14 もご覧ください）：')
    print('   ・ODBC Driver 18 が未導入')
    print('   ・SERVER名／DATABASE名の誤り（名前付きインスタンスは SRV01\\SQLEXPRESS）')
    print('   ・SQL Server 認証（混合モード）が無効')
    print('   ・TCP/IP が無効、または 1433番がファイアウォールで閉じている')
    print('\n--- この表示をそのままお送りください ---')
    sys.exit(1)
print('\n[OK] つながりました。')
if config.DRIVER == 'mssql':
    try:
        v = q(con, 'SELECT @@VERSION AS v')[0]['v']
        print('  %s' % ' '.join(str(v).split())[:140])
        d = q(con, 'SELECT DB_NAME() AS db, SUSER_SNAME() AS usr')[0]
        print('  データベース=%s  ログイン=%s' % (d['db'], d['usr']))
    except Exception as e:
        print('  （バージョン取得でエラー: %s）' % e)
else:
    print('  ファイル : %s' % config.SQLITE_PATH)

# ---- setx した値と、いま開いている画面の環境変数が食い違っていないか -------
if getattr(config, 'CONFLICT', None):
    print('\n' + '!' * 64)
    print('[中止] setx で保存した値と、いまのコマンドプロンプトの値が違います。')
    for _n, _env, _sav in config.CONFLICT:
        def _mask(v):
            import re as _re2
            return _re2.sub(r'(?i)(PWD=)[^;]*', r'\1********', v)
        print('  %s' % _n)
        print('     いまの画面 : %s' % _mask(_env))
        print('     setx の保存 : %s' % _mask(_sav))
    print('\n  setx は「次に開くコマンドプロンプトから」効きます。')
    print('  このままだと古いほうの設定で動いてしまい、')
    print('  つなぎ先を取り違えます（前回これで DATABASE=FTSCIM のまま動きました）。')
    print('  → コマンドプロンプトを**開き直して**から、もう一度実行してください。')
    print('!' * 64)
    sys.exit(1)

# ---- 本番（レプリケーション先）につないでいないかの確認 -------------------
#   現行ファイル名のテーブルは、データベースサーバへレプリケーションしている
#   本番の表と同じ名前です。間違って本番につなぐと取り返しがつかないので、
#   表を作る前に確かめます。
from cim.schema_gen import TABLES as _T
def _tablist():
    if config.DRIVER == 'mssql':
        return [r['name'] for r in q(con, 'SELECT name FROM sys.tables')]
    return [r['name'] for r in
            q(con, "SELECT name FROM sqlite_master WHERE type='table'")]
try:
    import re as _re
    _yoso = {t.upper() for t in _T} | {'Z_HEARING', 'Z_ASOF'}
    _hoka = sorted(t for t in _tablist()
                   if t.upper() not in _yoso
                   and _re.match(r'^[A-Za-z0-9]{5,10}$', t))
    if len(_hoka) >= 3:
        print('\n' + '!' * 64)
        print('[中止] この試作が作らない、現行ファイル名らしい表が %d 個あります。' % len(_hoka))
        print('  %s %s' % ('  '.join(_hoka[:12]), '…' if len(_hoka) > 12 else ''))
        print('  レプリケーション先のデータベースにつながっている可能性があります。')
        print('  試作は**別のデータベース**（例 FTSCIM_PROTO）でお願いします。')
        print('  表は作っていません。')
        print('!' * 64)
        con.close(); sys.exit(1)
except SystemExit:
    raise
except Exception as _e:
    print('  （表の一覧が取れませんでした: %s）' % _e)

try:
    init(con)
    print('[OK] 表の確認・作成ができました（%d 文）。' % len(ddl()))
except Exception as e:
    print('[NG] 表を作れませんでした。\n  %s' % e)
    print('  → そのデータベースに対する CREATE TABLE の権限をご確認ください。')
    con.close(); sys.exit(1)

# 件数は、いまの表の定義（現行システムのファイル）から自動で並べる
from cim.schema_gen import TABLES
print('\n件数（テーブル名＝現行の物理ファイル名）')
for t in sorted(TABLES):
    try:
        n = q(con, 'SELECT COUNT(*) AS n FROM %s' % t)[0]['n']
        print('  %-10s %-22s %6d' % (t, TABLES[t]['nm'], n))
    except Exception as e:
        print('  %-10s  読めません: %s' % (t, e))
for t in ('Z_HEARING', 'Z_ASOF'):
    try:
        n = q(con, 'SELECT COUNT(*) AS n FROM %s' % t)[0]['n']
        print('  %-10s %-22s %6d' % (t, '（このプロトタイプ独自）', n))
    except Exception:
        pass

# 列が定義どおりか（前の版の表が残っていると、名前が同じでも中身が違う）
def _cols(t):
    if config.DRIVER == 'mssql':
        return [r['name'] for r in q(con,
                'SELECT c.name FROM sys.columns c WHERE c.object_id=OBJECT_ID(?)', (t,))]
    return [r['name'] for r in q(con, 'PRAGMA table_info(%s)' % t)]

chigau = []
for t in sorted(TABLES):
    try:
        ima  = [c.strip() for c in _cols(t)]
        hazu = [c[0].strip() for c in TABLES[t]['cols']]
        if sorted(ima) != sorted(hazu):
            chigau.append((t, len(hazu), len(ima)))
    except Exception:
        pass
if chigau:
    print('\n' + '!' * 64)
    print('[ご注意] 列が定義と違う表が %d 個あります。' % len(chigau))
    for t, a, b in chigau:
        print('   %-10s 定義 %3d列 ／ いま %3d列' % (t, a, b))
    print('  前の版（列名が日本語）の表が残っていると、名前が同じでも中身が違います。')
    print('  py -3.13 cleanup_old.py --yes  で片付けてから、もう一度お試しください。')
    print('!' * 64)
else:
    print('\n[OK] どの表も、列が定義どおりでした。')

# 2026-10-14 より前の版が作った古い名前のテーブルが残っていないか
OLD = ['busyo','nip_mokuhyo','nip_jisseki','nip_juritsu','nip_seisan','jutyu','syutsuzu',
       'uriage','jutyuhyo','jutyuhyo_meisai','yosan','yosan_meisai','mensu','bukken',
       'bukken_meisai','bukken_kettei','sinchoku','uchiawase','seiban_mst','hearing']
left = []
for t in OLD:
    try:
        q(con, 'SELECT COUNT(*) AS n FROM %s' % t); left.append(t)
    except Exception:
        pass
con.close()
if left:
    print('\n' + '!' * 64)
    print('[ご注意] 古い版が作ったテーブルが %d 個残っています。' % len(left))
    print('  %s' % '／'.join(left))
    print('  いまの版は使いません。確認のときに紛らわしいので、')
    print('  py -3.13 cleanup_old.py --yes  で消してください。')
    print('!' * 64)
print('\n中身が空のときは  python run.py --seed  で現物サンプルを入れられます。')
print('そのあと  verify.py （確認.bat）で、現物の紙と数字が合うか照合できます。')
print('\n--- ここまでの表示を、そのままお送りいただければ確認いたします ---')
