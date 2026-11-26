import sys, pathlib, types, datetime, signal, collections
sys.path.insert(0, '.')
sys.path.insert(0, str(pathlib.Path('..').resolve()/'fts-cim-repo'/'bin'))
sys.path.insert(0, '点検')
na = sys.argv[1]; byou = int(sys.argv[2]) if len(sys.argv) > 2 else 25
sys.argv = [sys.argv[0]]
from cob2py import kumitate
from cob2py.tetsuzuki import na_py
from cim import db as cimdb
from zenbu_ugokasu import Sousa, Jikan
honbun, d = kumitate.kumu(str(pathlib.Path('..')/'cim'/'utf8'/(na+'.COB')))
m = types.ModuleType(na); exec(compile(honbun, na, 'exec'), m.__dict__)
cls = next(v for k,v in m.__dict__.items() if isinstance(v,type) and getattr(v,'KIOKU',None) is not None and k!='Pgm')
kazu = collections.Counter()
for sna, dan in cls.DANRAKU:
    for dna, dme in dan:
        if not dme or not hasattr(cls, dme): continue
        f = getattr(cls, dme)
        def tsukuru(f=f, dna=dna):
            def g(self, *a, **k):
                kazu[dna] += 1
                return f(self, *a, **k)
            return g
        setattr(cls, dme, tsukuru())
con = cimdb.connect()
def tome(s, fr): raise Jikan()
signal.signal(signal.SIGALRM, tome)
p = cls(con=con, db=cimdb, sousa=Sousa(), kyou=datetime.datetime(2026,11,24,9,0))
p.gamen_tome = 1
setsu = [s for s,_ in cls.DANRAKU if not s.startswith('__')]
signal.setitimer(signal.ITIMER_REAL, byou)
try:
    # zenbu_ugokasu と同じ入口の選び方にする
    sna_me = None; honbun_na = None
    for sna, dan in cls.DANRAKU:
        if sna.startswith('__'):
            for dna, dme in dan:
                if not dna.startswith('__') and dme:
                    sna_me, honbun_na = dme, sna; break
            if sna_me: break
            continue
        sna_me = na_py(sna)
        if '初期' in sna or 'INIT' in sna.upper(): break
    print('入口:', honbun_na or sna_me)
    if honbun_na:
        p._setsu(honbun_na)
    else:
        getattr(p, sna_me)()
    print('通った')
except Jikan: print('%d秒で打ち切り' % byou)
except Exception as e: print('止まった', type(e).__name__, str(e)[:80])
print('通った段落（多い順）:')
for k, v in kazu.most_common(6):
    print('   %-28s %8d 回' % (k, v))
