# -*- coding: utf-8 -*-
"""**現行データの再現**で、計算が合っているかを確かめる。

     python3 -I 点検/saigen.py            # 候補を全部
     python3 -I 点検/saigen.py SHIZI74F   # 1本だけ
     python3 -I 点検/saigen.py --byou 300 # 1本あたりの打ち切り（既定120秒）

■ 考え方（2026-11-27）
  帳票や集計表を**作り直す**プログラム（`OPEN OUTPUT`）は、
  入力も出力も現物データとして手元にある。ですので

      ① 出力表のいまの中身（＝現行が作った答え）を控える
      ② 同じ入力で変換版を走らせる（表は作り直される）
      ③ できた中身を①と突き合わせる
      ④ 必ず ROLLBACK して元に戻す

  で、**計算の結果そのもの**を機械で確かめられる。
  鑑（Ａ１００４０ＰＯ）は現物の紙と47項目を突き合わせているが、
  紙があるのはそれ1本だけ。この方法なら紙が無くても確かめられる。

■ 一致しないときに「誤り」と決めつけない
  現物の表は、**いまの入力とは違う時点の入力**で作られていることがある
  （月次で作り直す表など）。ですので結果は
      一致 ／ 件数は同じだが中身が違う ／ 件数が違う ／ 動かなかった
  に分けて出し、一致しなかったものは**要調査**として人に見せる。
"""
import sys, pathlib, types, datetime, signal, re, collections

ここ = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ここ))
sys.path.insert(0, str(ここ.parent / 'fts-cim-repo' / 'bin'))
sys.path.insert(0, str(ここ / '点検'))
try:
    sys.stdout.reconfigure(errors='replace', line_buffering=True)
except Exception:
    pass

NA = [x for x in sys.argv[1:] if not x.startswith('-')]
BYOU = 120
if '--byou' in sys.argv:
    BYOU = int(sys.argv[sys.argv.index('--byou') + 1])
    NA = [x for x in NA if x != str(BYOU)]
sys.argv = [sys.argv[0]]

from cob2py import kumitate
from cob2py.tetsuzuki import na_py
from cim import db as cimdb
from cim.schema_gen import TABLES
from zenbu_ugokasu import Sousa, Jikan
from cim.cobol.hashiru import GamenDeta

MOTO = ここ.parent / 'cim' / 'utf8'


def dasu_na(go_hon):
    """原文から `OPEN OUTPUT` しているファイル名を拾う。"""
    out = set()
    for m in re.finditer(r'\bOPEN\s+((?:\s*(?:OUTPUT|INPUT|I-O|EXTEND)\s+[^\s.]+)+)',
                         go_hon, re.I):
        for mm in re.finditer(r'(OUTPUT|INPUT|I-O|EXTEND)\s+([^\s.]+)',
                              m.group(1), re.I):
            if mm.group(1).upper() == 'OUTPUT':
                out.add(mm.group(2))
    return out


def dasu_hyo(cls, go_hon, kensu):
    """`OPEN OUTPUT` している**中身のある表**を拾う。

       表の引き当ては**実行時と同じ** `Pgm._hyomei`（表定義の論理名）で行う。
       名前の形から当てる書き方では、論理名が物理名と綴りの違う表
       （ＰＮＯＫＩＩＤＬ→ＰＮＯＫＩＩＤＦ など）を取りこぼし、
       候補が 11本しか見つからなかった（実行時の引き当てだと17本）。
    """
    from cim.cobol.hashiru import Pgm
    out = []
    for na in dasu_na(go_hon):
        d = cls.FAIRU.get(na)
        if not d:
            continue
        t = Pgm._hyomei(d.get('ronri'))
        if t in TABLES and kensu.get(t, 0) > 0 and t not in out:
            out.append(t)
    return out


def hyo_yomu(con, t):
    """表の中身を、**列の並び順の組**の多重集合にする（_gyo は外す）。"""
    retsu = [c[0] for c in TABLES[t]['cols']]
    aru = {r[1] for r in con.execute('PRAGMA table_info([%s])' % t)}
    retsu = [c for c in retsu if c in aru]
    sql = 'SELECT %s FROM [%s]' % (','.join('[%s]' % c for c in retsu), t)
    return retsu, collections.Counter(
        tuple('' if v is None else str(v) for v in r)
        for r in con.execute(sql))


def retsu_betsu(retsu, a, b):
    """どの列が違うのかを数える（件数が同じときだけ意味がある）。"""
    # 多重集合の差から、列ごとの違いの件数を出す
    sa = list((a - b).elements())
    sb = list((b - a).elements())
    kazu = collections.Counter()
    for x, y in zip(sorted(sa), sorted(sb)):
        for i, (p, q) in enumerate(zip(x, y)):
            if p != q:
                kazu[retsu[i]] += 1
    return kazu


def hitotsu(na, byou):
    con = cimdb.connect()
    kensu = {}
    for t in TABLES:
        try:
            kensu[t] = con.execute('SELECT COUNT(*) FROM [%s]' % t).fetchone()[0]
        except Exception:
            kensu[t] = 0
    f = MOTO / (na + '.COB')
    hon = '\n'.join(ln[1:67] for ln in
                    f.read_text(encoding='utf-8', errors='replace').splitlines()
                    if ln and ln[0] not in '*/Dd')
    try:
        honbun, _d = kumitate.kumu(str(f))
        m = types.ModuleType(na)
        exec(compile(honbun, na, 'exec'), m.__dict__)
        cls = next(v for k, v in m.__dict__.items()
                   if isinstance(v, type)
                   and getattr(v, 'KIOKU', None) is not None and k != 'Pgm')
    except Exception as e:
        con.close()
        return na, '写し取れない: %s' % type(e).__name__, {}
    deru = dasu_hyo(cls, hon, kensu)
    if not deru:
        con.close()
        return na, '出力表が無い', {}
    mae = {t: hyo_yomu(con, t) for t in deru}

    setsu = me = honbun_na = None
    for sna, dan in cls.DANRAKU:
        if sna.startswith('__'):
            for dna, dme in dan:
                if not dna.startswith('__') and dme:
                    setsu, me, honbun_na = dna, dme, sna
                    break
            if setsu:
                break
            continue
        setsu, me = sna, na_py(sna)
        if '初期' in sna or 'INIT' in sna.upper():
            break

    def tome(s, fr):
        raise Jikan()
    signal.signal(signal.SIGALRM, tome)
    con.execute('BEGIN')
    kekka = '動いた'
    try:
        p = cls(con=con, db=cimdb, sousa=Sousa(),
                kyou=datetime.datetime(2026, 11, 24, 9, 0))
        p.gamen_tome = 1
        signal.setitimer(signal.ITIMER_REAL, byou)
        if honbun_na:
            p._setsu(honbun_na)
        else:
            getattr(p, me)()
    except Jikan:
        kekka = '%d秒で終わらない' % byou
    except GamenDeta:
        kekka = '画面が出た'
    except SystemExit:
        pass
    except Exception as e:
        kekka = '%s: %s' % (type(e).__name__, str(e)[:50])
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)

    sa = {}
    if kekka in ('動いた', '画面が出た'):
        for t in deru:
            retsu, a = mae[t]
            _r, b = hyo_yomu(con, t)
            if a == b:
                sa[t] = ('一致', sum(a.values()), {})
            elif sum(a.values()) == sum(b.values()):
                sa[t] = ('件数は同じ・中身が違う', sum(a.values()),
                         dict(retsu_betsu(retsu, a, b).most_common(5)))
            else:
                sa[t] = ('件数が違う（現物 %d → 変換版 %d）'
                         % (sum(a.values()), sum(b.values())),
                         sum(a.values()), {})
    con.rollback()
    con.close()
    return na, kekka, sa


def main():
    con = cimdb.connect()
    kensu = {}
    for t in TABLES:
        try:
            kensu[t] = con.execute('SELECT COUNT(*) FROM [%s]' % t).fetchone()[0]
        except Exception:
            kensu[t] = 0
    con.close()
    if NA:
        hon = NA
    else:
        hon = []
        for f in sorted(MOTO.glob('*.COB')):
            h = '\n'.join(ln[1:67] for ln in
                          f.read_text(encoding='utf-8', errors='replace').splitlines()
                          if ln and ln[0] not in '*/Dd')
            if not dasu_na(h):
                continue
            try:
                honbun, _d = kumitate.kumu(str(f))
                mm = types.ModuleType(f.stem)
                exec(compile(honbun, f.stem, 'exec'), mm.__dict__)
                cls = next(v for k, v in mm.__dict__.items()
                           if isinstance(v, type)
                           and getattr(v, 'KIOKU', None) is not None
                           and k != 'Pgm')
            except Exception:
                continue
            if dasu_hyo(cls, h, kensu):
                hon.append(f.stem)
    print('■ 現行データの再現で確かめる … %d本' % len(hon))
    print()
    matome = collections.Counter()
    for na in hon:
        n, kekka, sa = hitotsu(na, BYOU)
        if not sa:
            print('%-10s %s' % (n, kekka))
            matome[kekka] += 1
            continue
        for t, (han, ken, betsu) in sa.items():
            print('%-10s %-10s %7s件  %s%s'
                  % (n, t, format(ken, ','), han,
                     ('　違う列: ' + ' '.join('%s(%d)' % x for x in betsu.items()))
                     if betsu else ''))
            matome[han.split('（')[0]] += 1
    print()
    print('■ まとめ')
    for k, v in matome.most_common():
        print('   %-26s %d' % (k, v))
    return 0


if __name__ == '__main__':
    sys.exit(main())
