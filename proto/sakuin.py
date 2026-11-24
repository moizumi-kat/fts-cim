# -*- coding: utf-8 -*-
"""索引（インデックス）を張る。

    python sakuin.py          # 張る
    python sakuin.py --miru   # 何を張るかだけ見る

■ なぜ要るか（2026-11-24 実測）
  現行は索引ファイル（ORGANIZATION INDEXED）なので、COBOL の READ は
  キーで1件を引く。索引が無いと**毎回の READ が全表走査**になり、
  鑑の検算（12,955件）が25分かかった。AJBMFP は 880万件あるので、
  索引が無いと実用にならない。

■ キーはどこから取るか
  **プログラムの FILE-CONTROL**（RECORD KEY／ALTERNATE RECORD KEY）。
  README 2.43 のとおり、索引は原文に書いてある。849本を変換して
  FAIRU（表名・キー）を集め、表ごとにまとめて張る。
  項目名から列名への引き当ては、実行時と同じ `Pgm._kagi_retsu` を使う。
"""
import sys, os, pathlib, types, collections

ここ = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ここ))
sys.path.insert(0, str(ここ.parent / 'fts-cim-repo' / 'bin'))
try:
    sys.stdout.reconfigure(errors='replace', line_buffering=True)
except Exception:
    pass
from cim import db as cimdb
from cim.db import connect, Q
from cim.schema_gen import TABLES
from cim.cobol.hashiru import Pgm
from cob2py import kumitate

MOTO = ここ.parent / 'cim' / 'utf8'


def atsumeru():
    """849本から {表名: {(列…)}} を集める。"""
    out = collections.defaultdict(set)
    for f in sorted(MOTO.glob('*.COB')):
        try:
            honbun, _d = kumitate.kumu(str(f))
            m = types.ModuleType(f.stem)
            exec(compile(honbun, f.stem, 'exec'), m.__dict__)
            cls = next(v for k, v in m.__dict__.items()
                       if isinstance(v, type)
                       and getattr(v, 'KIOKU', None) is not None and k != 'Pgm')
        except Exception:
            continue
        for _na, d in (cls.FAIRU or {}).items():
            if d.get('kumi') != 'INDEXED':
                continue
            hyo = Pgm._hyomei(d.get('ronri') or '')
            if hyo not in TABLES:
                continue
            aru = {c[0] for c in TABLES[hyo]['cols']}
            for kagi in [d.get('kagi') or []] + list(d.get('sub') or []):
                retsu = tuple(Pgm._kagi_retsu(k, hyo, cimdb) for k in kagi)
                retsu = tuple(x for x in retsu if x in aru)
                if retsu:
                    out[hyo].add(retsu)
    return out


def main():
    miru = '--miru' in sys.argv
    kagi = atsumeru()
    print('■ 索引を張る表 %d本（キーの組 %d通り）'
          % (len(kagi), sum(len(v) for v in kagi.values())))
    con = connect()
    n = 0
    for hyo in sorted(kagi):
        for i, retsu in enumerate(sorted(kagi[hyo]), 1):
            na = 'IX_%s_%d' % (hyo, i)
            bun = ('CREATE INDEX IF NOT EXISTS %s ON %s(%s)'
                   % (na, Q(hyo), ', '.join(Q(c) for c in retsu)))
            if miru:
                print('   ' + bun)
                continue
            try:
                con.execute(bun)
                n += 1
            except Exception as e:
                print('   %-14s だめ: %s' % (na, str(e)[:60]))
        if not miru:
            con.commit()
    if not miru:
        con.commit()
        print('   %d本の索引を張りました' % n)
    con.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
