# -*- coding: utf-8 -*-
"""849本すべてを実データで動かしてみて、**止まる場所を数える**。

     python3 点検/zenbu_ugokasu.py [何本まで] [秒数]

茂泉様のご指示「とりあえず全部動かし、現データを元に検証をしてもらいます。
そこで問題があれば、提示してもらい、一緒につぶしていきましょう」（2026-11-20）
のための道具。原因別にまとめて出すので、**直す順番を決める材料**になる。

■ 実データを壊さないこと
  変換した版の runtime（cim/cobol/hashiru.py）は**コミットしない**ので、
  1本ごとに `ROLLBACK` すれば書き込みは残らない（実測で確認）。
  念のため、はじめに件数を数えて、終わりにもう一度数えて見せる。

■ 止まるのは「悪いこと」ではない
  写せない文はゼロだが、**画面の項目名が定義体から取れていない**画面
  （181本のうち62本）や、入力待ちの作りはここで止まる。
  止まった場所が分かることが目的。
"""
import sys, os, pathlib, datetime, types, traceback, collections, signal

ここ = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ここ))
sys.path.insert(0, str(ここ.parent / 'fts-cim-repo' / 'bin'))
try:
    sys.stdout.reconfigure(errors='replace', line_buffering=True)
except Exception:
    pass

from cim import db as cimdb
from cim.cobol import vld
from cob2py import kumitate
from cob2py.tetsuzuki import na_py

MOTO = ここ.parent / 'cim' / 'utf8'
KAZU = int(sys.argv[1]) if len(sys.argv) > 1 else 0
BYOU = int(sys.argv[2]) if len(sys.argv) > 2 else 10


class Sousa(vld.Kioku):
    """画面の操作。入力待ちにならないよう、すぐ「入力あり」で返す。"""

    def yomu(self, group, mode):
        return None, vld.NYURYOKU


class Jikan(Exception):
    pass


def _tomeru(signum, frame):
    raise Jikan()


def main():
    con = cimdb.connect()
    kyou = datetime.datetime(2026, 11, 24, 9, 0, 0)
    moto = sorted(MOTO.glob('*.COB'))
    if KAZU:
        moto = moto[:KAZU]

    # 動かす前の件数（あとで比べる）
    hyo = [r[0] for r in con.execute(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")]
    mae = {}
    for t in hyo:
        try:
            mae[t] = con.execute('SELECT COUNT(*) FROM "%s"' % t).fetchone()[0]
        except Exception:
            pass

    signal.signal(signal.SIGALRM, _tomeru)
    kekka = collections.Counter()
    riyuu = collections.defaultdict(list)
    tsuuka = []
    for f in moto:
        na = f.stem
        try:
            honbun, d = kumitate.kumu(str(f))
            m = types.ModuleType(na)
            exec(compile(honbun, na, 'exec'), m.__dict__)
            cls = next(v for k, v in m.__dict__.items()
                       if isinstance(v, type)
                       and getattr(v, 'KIOKU', None) is not None and k != 'Pgm')
        except Exception as e:
            kekka['変換できない'] += 1
            riyuu['変換できない'].append((na, '%s: %s' % (type(e).__name__, str(e)[:60])))
            continue

        # 入口を決める。節があればその先頭（「初期」があればそれ）。
        # **節を持たず段落だけのプログラム**もある（19本。EGNIP01S ほか）。
        # そのときは `__honbun__` の先頭の段落が入口。
        setsu = me = None
        honbun = None
        for sna, dan in cls.DANRAKU:
            if sna.startswith('__'):
                # ■ 節を持たず段落だけのプログラム（2026-11-24 直し）
                #   段落のメソッドを直に呼ぶと `GO TO MAIN-RTN` を受ける人が
                #   いないので _Tobu が外へ抜けていた（20本）。
                #   節として回せば、元のプログラムどおり飛び先から続く。
                for dna, dme in dan:
                    if dna.startswith('__') or not dme:
                        continue
                    setsu, me, honbun = dna, dme, sna
                    break
                if setsu:
                    break
                continue
            setsu = sna
            me = na_py(sna)
            if '初期' in sna or 'INIT' in sna.upper():
                break
        if setsu is None:
            kekka['入口が無い'] += 1
            riyuu['入口が無い'].append((na, ''))
            continue
        try:
            con.execute('BEGIN')
        except Exception:
            pass
        try:
            p = cls(con=con, db=cimdb, sousa=Sousa(), kyou=kyou)
            if not hasattr(p, me):
                raise AttributeError('節 %s が見つからない' % setsu)
            signal.setitimer(signal.ITIMER_REAL, BYOU)
            if honbun:
                p._setsu(honbun)
            else:
                getattr(p, me)()
            kekka['通った'] += 1
            tsuuka.append(na)
        except Jikan:
            kekka['時間切れ'] += 1
            riyuu['時間切れ'].append((na, '%s が %d秒で終わらない' % (setsu, BYOU)))
        except BaseException as e:
            ku = type(e).__name__
            mes = str(e)[:70]
            if ku in ('ExitProgram', 'StopRun'):
                kekka['通った'] += 1
                tsuuka.append(na)
            else:
                kekka[ku] += 1
                riyuu[ku].append((na, '%s … %s' % (setsu, mes)))
        finally:
            signal.setitimer(signal.ITIMER_REAL, 0)
            try:
                con.rollback()
            except Exception:
                pass

    print()
    print('■ %d本を動かしてみた結果' % len(moto))
    for k, v in kekka.most_common():
        print('   %-24s %4d本' % (k, v))

    print()
    print('■ 止まった原因（多い順。これが直す順番の材料）')
    for k in sorted(riyuu, key=lambda x: -len(riyuu[x])):
        if k == '通った':
            continue
        print('   ── %s（%d本）' % (k, len(riyuu[k])))
        mato = collections.Counter(x[1].split('…')[-1].strip()[:60] for x in riyuu[k])
        for mes, n in mato.most_common(6):
            print('        %4d本  %s' % (n, mes))
            rei = [x[0] for x in riyuu[k]
                   if x[1].split('…')[-1].strip()[:60] == mes][:4]
            print('                 例: %s' % ' '.join(rei))

    # 止まったところを全件、一覧に書き出す（人に見せて一緒に潰すため）
    ichiran = ここ / '止まったところ.txt'
    with open(ichiran, 'w', encoding='utf-8') as f:
        f.write('# %d本を動かしてみて止まったところ（全件）\n' % len(moto))
        f.write('# 区分\tプログラム\t止まった場所と理由\n')
        for k in sorted(riyuu, key=lambda x: -len(riyuu[x])):
            for na_, mes in sorted(riyuu[k]):
                f.write('%s\t%s\t%s\n' % (k, na_, mes))
    print()
    print('■ 止まったところの全件を %s に書き出しました' % ichiran)

    # 実データが変わっていないこと
    chigai = []
    for t, n in mae.items():
        try:
            ima = con.execute('SELECT COUNT(*) FROM "%s"' % t).fetchone()[0]
        except Exception:
            continue
        if ima != n:
            chigai.append((t, n, ima))
    print()
    print('■ 実データの件数が変わっていないか: %s'
          % ('変わっていない（%d表）' % len(mae) if not chigai
             else '⚠ 変わった %d表 %s' % (len(chigai), chigai[:5])))
    con.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
