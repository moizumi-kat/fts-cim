# -*- coding: utf-8 -*-
"""終わらないプログラムが**何をしているのか**を数える。

     python3 -I 点検/osoi_shiraberu.py B16100PB [秒]

無限に回っているのか、件数が多くて時間がかかっているだけなのかを
分けるための道具。ＳＱＬの本数・読んだ件数・表ごとの内訳を出す。
"""
import sys, pathlib, types, datetime, signal, collections, time

ここ = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ここ))
sys.path.insert(0, str(ここ.parent / 'fts-cim-repo' / 'bin'))
sys.path.insert(0, str(ここ / '点検'))
# zenbu_ugokasu は sys.argv[1] を本数として読むので、先に伏せておく
NA = sys.argv[1] if len(sys.argv) > 1 else ''
BYOU = int(sys.argv[2]) if len(sys.argv) > 2 else 120
sys.argv = [sys.argv[0]]
from cob2py import kumitate
from cob2py.tetsuzuki import na_py
from cim import db as cimdb
from zenbu_ugokasu import Sousa, Jikan


def main():
    na, byou = NA, BYOU
    kazu = collections.Counter()
    moto_q1, moto_ex = cimdb.q1, cimdb.ex

    def hyomei(sql):
        import re
        m = re.search(r'FROM\s+\[?([A-Z0-9_]+)', sql, re.I)
        return m.group(1) if m else '？'

    def q1(con, sql, args=()):
        kazu['q1 ' + hyomei(sql)] += 1
        return moto_q1(con, sql, args)

    def ex(con, sql, args=()):
        kazu['ex ' + hyomei(sql)] += 1
        return moto_ex(con, sql, args)
    cimdb.q1, cimdb.ex = q1, ex

    honbun, _d = kumitate.kumu(
        str(ここ.parent / 'cim' / 'utf8' / (na + '.COB')))
    m = types.ModuleType(na)
    exec(compile(honbun, na, 'exec'), m.__dict__)
    cls = next(v for k, v in m.__dict__.items()
               if isinstance(v, type) and getattr(v, 'KIOKU', None) is not None
               and k != 'Pgm')
    con = cimdb.connect()
    p = cls(con=con, db=cimdb, sousa=Sousa(), kyou=datetime.datetime(2026, 11, 24, 9, 0))
    p.gamen_tome = 1

    def tome(s, fr):
        raise Jikan()
    signal.signal(signal.SIGALRM, tome)
    setsu = [s for s, dan in cls.DANRAKU if not s.startswith('__')]
    honbun_na = None
    me = None
    for sna, dan in cls.DANRAKU:
        if sna.startswith('__'):
            for dna, dme in dan:
                if not dna.startswith('__') and dme:
                    me, honbun_na = dme, sna
                    break
            if me:
                break
            continue
        me = na_py(sna)
        if '初期' in sna or 'INIT' in sna.upper():
            break
    t0 = time.time()
    signal.setitimer(signal.ITIMER_REAL, byou)
    owari = '通った'
    try:
        if honbun_na:
            p._setsu(honbun_na)
        else:
            getattr(p, me)()
    except Jikan:
        owari = '%d秒で打ち切り' % byou
    except Exception as e:
        owari = '%s: %s' % (type(e).__name__, str(e)[:60])
    t = time.time() - t0
    print('%s … %s（%.1f秒）' % (na, owari, t))
    print('ＳＱＬの本数 合計 %d（毎秒 %.0f本）' % (sum(kazu.values()),
                                                 sum(kazu.values()) / max(t, 1)))
    for k, v in kazu.most_common(12):
        print('   %-24s %8d' % (k, v))
    return 0


if __name__ == '__main__':
    sys.exit(main())
