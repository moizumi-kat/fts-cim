# -*- coding: utf-8 -*-
"""SFL.zip（村上様・2026-11-24／492本・展開7.4GB）をそのまま取り込む。

    python load_sfl_zip.py <SFL.zip> [表名 …]

1本ずつ取り出して取り込み、終わったら消す（展開しきると7.4GB要るため）。
分割されているもの（AJBKFP1/2 → AJBKFP、AJBMFP1/2/3 → AJBMFP）は、
**同じ表へ足し込む**（ファイルごとに CNTL があるので、別々に読んで足すのが正しい）。
"""
import os, re, sys, zipfile, pathlib, tempfile, collections

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                '..', 'fts-cim-repo', 'bin'))
try:
    sys.stdout.reconfigure(errors='replace', line_buffering=True)
except Exception:
    pass
import sfl
from cim.db import connect, Q
from cim.schema_gen import TABLES


def hyo_na(stem):
    """ファイル名 → 表名。末尾の数字は分割の通し番号なので落とす。"""
    t = stem.upper()
    if t in TABLES:
        return t
    k = t.rstrip('0123456789')
    return k if k in TABLES else None


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    zipmichi = sys.argv[1]
    hoshii = {t.upper() for t in sys.argv[2:]}
    z = zipfile.ZipFile(zipmichi)
    meibo = collections.defaultdict(list)       # 表名 → [zip の中の名前]
    hoka = []
    for n in z.namelist():
        if not n.upper().endswith('.SFL'):
            continue
        t = hyo_na(pathlib.Path(n).stem)
        if t is None:
            hoka.append(n)
            continue
        if hoshii and t not in hoshii:
            continue
        meibo[t].append(n)

    con = connect()
    ok = ng = 0
    kensu = 0
    warui = []
    kari = pathlib.Path(tempfile.mkdtemp(prefix='sfl_'))
    try:
        for t in sorted(meibo):
            atama = [c[0] for c in TABLES[t]['cols']]
            con.execute('DELETE FROM %s' % t)
            n = 0
            dame = None
            # **1件ずつ流しながら入れる**（AJBMFP1 は 1.9GB あり、
            # 全件リストに持つとメモリが足りない＝実際に殺された 2026-11-24）。
            for nm in sorted(meibo[t]):
                p = kari / pathlib.Path(nm).name
                try:
                    with z.open(nm) as fi, open(p, 'wb') as fo:
                        while True:
                            buf = fi.read(1 << 22)
                            if not buf:
                                break
                            fo.write(buf)
                    bun = 'INSERT INTO %s(%s) VALUES(%s)' % (
                        t, ','.join(Q(k) for k in atama),
                        ','.join('?' * len(atama)))
                    tama = []
                    for d in sfl.nagare(str(p), TABLES[t]['cols']):
                        tama.append(tuple(d.get(k) for k in atama))
                        if len(tama) >= 5000:
                            con.executemany(bun, tama)
                            n += len(tama)
                            tama = []
                    if tama:
                        con.executemany(bun, tama)
                        n += len(tama)
                except Exception as e:
                    dame = '%s: %s' % (type(e).__name__, str(e)[:60])
                    break
                finally:
                    if p.exists():
                        p.unlink()
            if dame:
                con.rollback()
                print('  %-10s %s' % (t, dame))
                warui.append((t, dame))
                ng += 1
                continue
            con.commit()
            print('  %-10s %10s件  (%s)'
                  % (t, format(n, ','), ' '.join(sorted(
                      pathlib.Path(x).name for x in meibo[t]))))
            ok += 1
            kensu += n
    finally:
        con.close()
        for x in kari.glob('*'):
            x.unlink()
        kari.rmdir()

    print()
    print('%d表 %s件を取り込みました（取り込めなかった表 %d）'
          % (ok, format(kensu, ','), ng))
    if hoka:
        print('表定義に無いファイル %d本: %s'
              % (len(hoka), ' '.join(pathlib.Path(x).name for x in hoka)))
    if warui:
        print('取り込めなかった表:')
        for t, e in warui:
            print('   %-10s %s' % (t, e))
    return 0


if __name__ == '__main__':
    sys.exit(main())
