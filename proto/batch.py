# -*- coding: utf-8 -*-
"""現行の夜間ジョブを、現行と同じ順序で動かす。

    python batch.py pegnip01 [最終更新日 YYYYMMDD] [月度]
        営業日報照会ファイル作成（PEGNIP01.CL の受注率まわり）
        STEP C  月度チェック            TUKICHKP.COB
        STEP38  当月受注率データのクリア JUHEN2CD.COB
        STEP39  当月受注率ファイル作成   JUHEN2CF.COB

    python batch.py juhen2cd        STEP38 だけ
    python batch.py juhen2cf        STEP39 だけ

当社は20日締めです。10月度＝9月21日〜10月20日。
月度チェックは現行 TUKICHKP.COB と同じ判定をします（21日以降は翌月度）。
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cim.db import connect, q, ex
from cim.cobol import juhen2cd, juhen2cf, tukichkp

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

def pegnip01(con, args):
    """PEGNIP01.CL のうち、受注率ファイルを作る部分。"""
    if len(args) >= 2:
        ejkday, gatudo = int(args[0]), int(args[1])
        print('STEP C  月度チェック … 最終更新日 %d／指定月度 %d' % (ejkday, gatudo))
        if not tukichkp.check(ejkday, gatudo):
            print('  [中止] 月度が合っていません。%d は %d月度です（20日締め）。'
                  % (ejkday, tukichkp.gatudo(ejkday)))
            return 1
        s, e = tukichkp.kikan(ejkday // 10000, gatudo)
        print('  月度チェックＯＫ … %d月度＝%d〜%d' % (gatudo, s, e))
    n = juhen2cd.run(con, q, ex)
    print('STEP38  当月受注率データのクリア … %d 件を削除' % n)
    n = juhen2cf.run(con, q, ex)
    print('STEP39  当月受注率ファイル作成   … %d 件を作成' % n)
    return 0

JOBS = {
    'pegnip01': ('営業日報照会ファイル作成（受注率まわり）', pegnip01),
    'juhen2cd': ('当月受注率データのクリア', lambda c, a: print('%d 件を削除' % juhen2cd.run(c, q, ex)) or 0),
    'juhen2cf': ('当月受注率ファイル作成',   lambda c, a: print('%d 件を作成' % juhen2cf.run(c, q, ex)) or 0),
}

def main():
    name = sys.argv[1] if len(sys.argv) > 1 else ''
    if name not in JOBS:
        print(__doc__)
        for k, (nm, _) in JOBS.items(): print('   %-10s %s' % (k, nm))
        return 2
    nm, fn = JOBS[name]
    con = connect()
    try:
        print('■ %s' % nm)
        return fn(con, sys.argv[2:]) or 0
    finally:
        con.close()

if __name__ == '__main__':
    sys.exit(main())
