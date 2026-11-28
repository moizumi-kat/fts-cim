# -*- coding: utf-8 -*-
"""ＣＬを動かしてみる。

     python3 -I 点検/cl_ugokasu.py CA1Z0020        # 1本
     python3 -I 点検/cl_ugokasu.py --zenbu         # 588本ぜんぶ
     python3 -I 点検/cl_ugokasu.py --zenbu --byou 60

表は必ず ROLLBACK するので、データは変わらない。
"""
import sys, pathlib, signal, collections

ここ = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ここ))
sys.path.insert(0, str(ここ.parent / 'fts-cim-repo' / 'bin'))
sys.path.insert(0, str(ここ / '点検'))
try:
    sys.stdout.reconfigure(errors='replace', line_buffering=True)
except Exception:
    pass

ZENBU = '--zenbu' in sys.argv
YOBANAI = '--yobanai' in sys.argv
BYOU = 60
if '--byou' in sys.argv:
    BYOU = int(sys.argv[sys.argv.index('--byou') + 1])
MEISAI = ''
if '--meisai' in sys.argv:
    MEISAI = sys.argv[sys.argv.index('--meisai') + 1]
NA = [x for x in sys.argv[1:] if not x.startswith('-') and x != str(BYOU)
      and x != MEISAI]
sys.argv = [sys.argv[0]]

import datetime
from cim import db as cimdb
from cim.cobol import cl as clmod
from zenbu_ugokasu import Sousa, Jikan

MOTO = ここ.parent / 'cim' / 'utf8'


def hitotsu(na, byou):
    con = cimdb.connect()
    con.execute('BEGIN')
    j = clmod.Jikkou(con=con, db=cimdb, sousa=Sousa(),
                     kyou=datetime.datetime(2026, 11, 24, 9, 0),
                     yobanai=YOBANAI)

    def tome(s, fr):
        raise Jikan()
    signal.signal(signal.SIGALRM, tome)
    kekka = '通った'
    try:
        signal.setitimer(signal.ITIMER_REAL, byou)
        j.hashiru(na)
    except Jikan:
        kekka = '%d秒で終わらない' % byou
    except Exception as e:
        kekka = '%s: %s' % (type(e).__name__, str(e)[:60])
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
    con.rollback()
    con.close()
    return kekka, j.log


def main():
    hon = NA if NA else ([f.stem for f in sorted(MOTO.glob('*.CL'))] if ZENBU else [])
    if not hon:
        print(__doc__)
        return 1
    matome = collections.Counter()
    tsukutte_nai = collections.Counter()
    yobi = collections.Counter()
    warui = collections.Counter()
    for na in hon:
        kekka, log = hitotsu(na, BYOU)
        matome[kekka.split(':')[0]] += 1
        for _c, _g, s in log:
            if 'まだ作っていない命令' in s:
                tsukutte_nai[s.split('（')[0]] += 1
            if s.startswith('ＣＡＬＬ'):
                yobi[s.split('→')[-1].strip()] += 1
                # 写し取れていない呼び先は、**プログラム名ごと**に数える
                # （どれを直せばよいか分かるようにするため）
                if '写し取れていない' in s or '原文が無い' in s:
                    warui[s] += 1
        # ＣＬ1本ごとの結果を別ファイルへ（どれが変わったか**後から比べる**ため。
        #   2026-11-28：命令を足したあと「通った」が540→537に動いたとき、
        #   どのＣＬが変わったのか分からず測り直すことになった反省から。）
        if MEISAI:
            with open(MEISAI, 'a', encoding='utf-8') as f:
                f.write('%s\t%s\n' % (na, kekka))
        if len(hon) <= 5:
            print('=== %s … %s' % (na, kekka))
            for c, g, s in log:
                print('   %-10s %4s  %s' % (c, g, s))
    if len(hon) > 5:
        print('■ ＣＬ %d本を動かしてみた結果' % len(hon))
        for k, v in matome.most_common():
            print('   %-28s %d本' % (k, v))
        print()
        print('■ ＣＡＬＬ の結果（多い順）')
        for k, v in yobi.most_common(10):
            print('   %-40s %d回' % (k[:40], v))
        if warui:
            print()
            print('■ 呼び先で止まったもの（プログラム名つき）')
            for k, v in warui.most_common(20):
                print('   %-60s %d回' % (k[:60], v))
        if tsukutte_nai:
            print()
            print('■ まだ作っていない命令が出たもの')
            for k, v in tsukutte_nai.most_common(12):
                print('   %-24s %d回' % (k, v))
    return 0


if __name__ == '__main__':
    sys.exit(main())
