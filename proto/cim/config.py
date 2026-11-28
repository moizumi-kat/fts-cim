# -*- coding: utf-8 -*-
"""接続先の設定。

  FTSCIM_DRIVER   'sqlite'（既定） または 'mssql'
  FTSCIM_DSN      SQL Server の接続文字列（FTSCIM_DRIVER='mssql' のとき）
  FTSCIM_DB       SQLite のファイル位置（既定はこのフォルダの ftscim.db）

Windows の setx で設定した値は「次に開くコマンドプロンプトから」しか効きません。
開き直し忘れで SQLite のまま動いてしまう事故が多いので、
**環境変数に無ければ、setx が書き込んだ値（レジストリ）を直接読みます。**
→ setx した直後の画面でも、そのまま SQL Server につながります。
"""
import os

def _win_saved(name):
    """setx が保存した値を読む（システム → ユーザーの順）。Windows 以外では None。"""
    if os.name != 'nt':
        return None
    try:
        import winreg
    except ImportError:
        return None
    for root, path in ((winreg.HKEY_LOCAL_MACHINE,
                        r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment'),
                       (winreg.HKEY_CURRENT_USER, 'Environment')):
        try:
            with winreg.OpenKey(root, path) as k:
                v = winreg.QueryValueEx(k, name)[0]
                if v: return v
        except OSError:
            pass
    return None

def setting(name, default=''):
    """環境変数 → setx で保存された値 → 既定値 の順に見る。"""
    v = os.environ.get(name)
    if v: return v
    v = _win_saved(name)
    if v: return v
    return default

# setx の値を使ったかどうか（画面で知らせるため）
FROM_SAVED = [n for n in ('FTSCIM_DRIVER', 'FTSCIM_DSN')
              if not os.environ.get(n) and _win_saved(n)]

# いま開いている画面の環境変数と、setx で保存した値が**食い違っている**もの。
#   setx は「次に開く画面から」効くので、setx した直後の画面では
#   古い値のほうが勝ってしまう。どちらが本意か分からないので、
#   dbcheck.py はこれが見つかったら止める。
CONFLICT = []
for _n in ('FTSCIM_DRIVER', 'FTSCIM_DSN', 'FTSCIM_DB'):
    _env, _sav = os.environ.get(_n), _win_saved(_n)
    if _env and _sav and _env != _sav:
        CONFLICT.append((_n, _env, _sav))

DRIVER = setting('FTSCIM_DRIVER', 'sqlite')
SQLITE_PATH = setting('FTSCIM_DB',
                os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'ftscim.db'))
MSSQL_DSN = setting('FTSCIM_DSN', '')

# 画面に出す会社名・システム名
COMPANY = '古川電気工業株式会社'
SYSTEM  = 'FTS-CIM'
