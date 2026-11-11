# -*- coding: utf-8 -*-
"""補った表の検算。起こした定義が、現行ソースに書かれたレコード長と合うかを見る。

     python3 bin/oginai_kensan.py <schema_gen.py>
"""
import sys, importlib.util, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import oginai

spec = importlib.util.spec_from_file_location('sg', sys.argv[1])
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
T = m.TABLES

def naga(cols):
    n = 0
    for c in cols:
        t = c[1]
        if t.startswith('char('):     n += int(t[5:-1])
        elif t.startswith('nchar('):  n += int(t[6:-1]) * 2
        elif t.startswith(('numeric(', 'decimal(')):
            n += int(t.split('(')[1].split(',')[0])
        else:
            return None
    return n

print('■ 現行ソースの根拠で補った表')
for x in sorted(set(oginai.SOURCE) | set(oginai.UTSUSHI)):
    if x not in T:
        print('   %-9s 作れていません' % x); continue
    t = T[x]
    print('   %-9s %2d列  %4s バイト  %s%s'
          % (x, len(t['cols']), naga(t['cols']),
             {'source': 'ソースから', 'utsushi': '写し元 '}.get(t['src'], t['src']),
             t.get('moto', '') if t['src'] == 'utsushi' else ''))

print()
print('■ 検算（現行ソースに書かれたレコード長と合うか）')
warui = 0
for x, (n, k) in sorted(oginai.NAGASA.items()):
    if x not in T:
        print('   %-9s ソース %3d ／ まだ作れていません   ← %s' % (x, n, k)); continue
    a = naga(T[x]['cols'])
    ok = (a == n)
    warui += (not ok)
    print('   %-9s ソース %3d ／ 起こした定義 %s  %s   ← %s'
          % (x, n, a, 'ピタリ' if ok else '**合いません**', k))

print()
print('■ 写し元と列が同じか')
for x, (moto, _k) in sorted(oginai.UTSUSHI.items()):
    if x in T and moto in T:
        a = [c[0] for c in T[x]['cols']]; b = [c[0] for c in T[moto]['cols']]
        print('   %-9s ← %-9s %s' % (x, moto, '同じ' if a == b else '**ちがう**'))
        warui += (a != b)
    elif x in T:
        print('   %-9s ← %-9s 写し元は定義体の側（列の比較は省略）' % (x, moto))

print()
print('合計 %d表 %d列' % (len(T), sum(len(t['cols']) for t in T.values())))
sys.exit(1 if warui else 0)
