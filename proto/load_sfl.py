# -*- coding: utf-8 -*-
"""富士通ASPの保存ファイル（.SFL）をそのまま取り込む。

    python load_sfl.py <SFLの入ったフォルダ> [表名 …]

CSV を経由しないので、書き出しで混じる余計なバイトの問題が起きません
（ABUHMP の部品名称で実際に起きた）。
"""
import os, sys, pathlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'fts-cim-repo', 'bin'))
try:
    sys.stdout.reconfigure(errors='replace')
except Exception:
    pass
import sfl
from cim.db import connect, Q
from cim.schema_gen import TABLES


def main():
    if len(sys.argv) < 2:
        print(__doc__); return 2
    moto = sys.argv[1]
    hoshii = [t.upper() for t in sys.argv[2:]]
    con = connect()
    ok = ng = 0
    kensu = 0
    try:
        for p in sorted(pathlib.Path(moto).iterdir()):
            t = p.stem.upper()
            if t not in TABLES or (hoshii and t not in hoshii):
                continue
            try:
                cols, rec, _st = sfl.yomitoru(str(p), TABLES[t]['cols'])
            except Exception as e:
                print('  %-10s 読めません: %s' % (t, str(e)[:50])); ng += 1; continue
            if not cols:
                print('  %-10s 形が合いません' % t); ng += 1; continue
            atama = [c[0] for c in TABLES[t]['cols']]
            con.execute('DELETE FROM %s' % t)
            n = 0
            for d in rec:
                v = {k: d.get(k) for k in atama if d.get(k) is not None}
                if not v:
                    continue
                con.execute('INSERT INTO %s(%s) VALUES(%s)'
                            % (t, ','.join(Q(k) for k in v), ','.join('?' * len(v))),
                            tuple(v.values()))
                n += 1
            con.commit()
            print('  %-10s %8s件' % (t, format(n, ',')))
            ok += 1; kensu += n
    finally:
        con.close()
    print()
    print('%d表 %s件を取り込みました（取り込めなかった表 %d）' %
          (ok, format(kensu, ','), ng))
    return 0


if __name__ == '__main__':
    sys.exit(main())
