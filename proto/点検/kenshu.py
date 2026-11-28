# -*- coding: utf-8 -*-
"""検収：現行と同じ入力を入れ、現行と同じフローで処理し、結果を全項目つき合わせる。

    python 点検/kenshu.py  <現行データCSVのフォルダ>  [最終更新日 月度]

やること（村上様ご指示の確認のしかた）
    (1) 現行のファイルを取り込む                      load_csv.py
    (2) 現行と同じ順序でバッチを動かす                batch.py pegnip01
          STEPC  月度チェック            TUKICHKP.COB
          STEP38 当月受注率データのクリア JUHEN2CD.COB
          STEP39 当月受注率ファイル作成   JUHEN2CF.COB
    (3) 処理後のデータベースの中身を、全項目つき合わせる  compare_db.py

    (2) で作り直した当月受注率ファイルが、現行の結果と1項目も違わなければ合格です。
"""
import os, subprocess, sys

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def run(title, args):
    print('\n' + '=' * 64)
    print('■ %s' % title)
    print('=' * 64)
    p = subprocess.run([sys.executable] + args, cwd=HERE)
    return p.returncode

def main():
    if len(sys.argv) < 2:
        print(__doc__); return 2
    src = os.path.abspath(sys.argv[1])
    if not os.path.isdir(src):
        print('フォルダがありません: %s' % src); return 2
    extra = sys.argv[2:4]

    if run('(1) 現行のファイルを取り込む', ['load_csv.py', src]):
        return 1
    if run('(2) 現行と同じ順序でバッチを動かす', ['batch.py', 'pegnip01'] + list(extra)):
        return 1
    rc = run('(3) 処理後のデータベースを全項目つき合わせる',
             [os.path.join('点検', 'compare_db.py'), src])
    print()
    print('=' * 64)
    print('検収の結果： %s' % ('合格（1項目も違いません）' if rc == 0 else '不合格（上の一覧をご覧ください）'))
    print('=' * 64)
    return rc

if __name__ == '__main__':
    sys.exit(main())
