# -*- coding: utf-8 -*-
"""変換した COBOL を**実際に動かして、画面定義どおりに見せる**。

茂泉様のご指示（2026-11-20）
  「計算・動き・データベース構造・画面が確認できるプロトタイプ」
  「とりあえず全部動かし、現データを元に検証をしてもらいます」

■ 何をしているか
  1. 原文（.COB）を毎回 Python へ写して（`kumitate.kumu`）、その場で動かす。
     あらかじめ .py を書き出さないのは、**原文が正本**だとはっきりさせるため。
  2. 画面への WRITE は表が無いので `Pgm.kaita` に生のバイトで溜まる。
     それを**画面定義体（teigitai.json）の位置・桁**で切り分けて出す。
  3. 書き込みは既定で **ROLLBACK**（確かめるだけで現データを汚さない）。
     「書き込む」を選んだときだけ COMMIT する。

■ 止まったら隠さない
  止まった場所と理由をそのまま返す。黙って空の画面を出すと、
  動いていないことに気づけない（方針1-3「迷ったら安全側」）。
"""
import os, pathlib, types, threading, traceback, json

from . import db as cimdb
from .cobol import vld
from .cobol.hashiru import GamenDeta

_KOKO = pathlib.Path(__file__).resolve().parent
_MOTO = pathlib.Path(os.environ.get(
    'FTSCIM_SRC', str(_KOKO.parent.parent / 'cim' / 'utf8')))
_TEIGI = None
_IRE = {}            # 写したものの覚え（同じプログラムを何度も写さない）


def teigitai():
    global _TEIGI
    if _TEIGI is None:
        p = _KOKO / 'teigitai.json'
        _TEIGI = json.loads(p.read_text(encoding='utf-8')) if p.exists() else {}
    return _TEIGI


class Tometa(Exception):
    """画面が出たので、わざと止めた（異常ではない）。"""


class Sousa(vld.Kioku):
    """画面の操作役。

       現行は「画面を出す → 入力を待つ → 処理する」の繰返しで、入力を
       待たずに返すと**同じところを回り続ける**。そこで
       **画面が kai 回 書かれたところで止める**。止めた時点の画面が、
       利用者が最初に見る画面そのものになる。
       時間切れで打ち切ると、動いたままのスレッドが残って重くなるので、
       数えて止めるほうが確実。
    """

    def __init__(self, ire=None, kai=1):
        super().__init__()
        self.ire = dict(ire or {})
        self.kai = kai

    def kaku(self, rec, group):
        st = super().kaku(rec, group)
        if self.kai and len(self.kaita) >= self.kai:
            raise Tometa()
        return st

    def yomu(self, group, mode):
        return None, vld.NYURYOKU


def _cls(na):
    """原文を写して、プログラムの組（クラス）を取り出す。"""
    if na in _IRE:
        return _IRE[na]
    from cob2py import kumitate
    f = _MOTO / ('%s.COB' % na)
    if not f.exists():
        raise FileNotFoundError('原文がありません: %s' % f.name)
    honbun, _d = kumitate.kumu(str(f))
    m = types.ModuleType(na)
    exec(compile(honbun, na, 'exec'), m.__dict__)
    cls = next(v for k, v in m.__dict__.items()
               if isinstance(v, type)
               and getattr(v, 'KIOKU', None) is not None and k != 'Pgm')
    _IRE[na] = cls
    return cls


def _iriguchi(cls):
    """入口を決める。**原文の先頭の節**（COBOL はそこから動く）。

       段落だけのプログラムは、本文の節として丸ごと回す。
    """
    from cob2py.tetsuzuki import na_py
    for sna, dan in cls.DANRAKU:
        if sna.startswith('__'):
            for dna, dme in dan:
                if dna.startswith('__') or not dme:
                    continue
                return sna, None          # 本文の節として回す
            continue
        return None, na_py(sna)
    return None, None


def gamen_mei(na):
    """そのプログラムが使う画面定義体の名前（原文の COPY 〜 OF XMDLIB）。"""
    import re
    f = _MOTO / ('%s.COB' % na)
    if not f.exists():
        return []
    t = f.read_text(encoding='utf-8', errors='replace')
    hon = '\n'.join(ln[1:67] for ln in t.splitlines()
                    if ln and ln[0] not in '*/Dd')
    g = teigitai()
    return [x.upper() for x in
            re.findall(r'COPY\s+([A-Z0-9]+)\s+OF\s+XMDLIB', hon, re.I)
            if x.upper() in g]


def _kiri(b, k):
    """レコードのバイト列から、項目1つを切り出して文字にする。"""
    a = k['ichi'] - 1
    n = k.get('naga2') or k.get('naga') or 0
    if a < 0 or n <= 0 or a + n > len(b):
        return ''
    return b[a:a+n].decode('cp932', 'replace')


def gamen_hyo(teigi, rec=None):
    """画面定義体（＋書かれたレコード）→ 行ごとの枠の並び。

       枠 = {gyo, keta, naga, moji, ko(項目名), iri(入力欄か)}
       見出し（定義体に焼き付けてある字）は moji をそのまま出す。
       データ項目は、レコードがあればその値、無ければ空。
    """
    gyo = {}
    for k in teigi['ko']:
        if k.get('gyo') is None:
            continue
        if k['ichi']:
            moji = _kiri(rec, k) if rec else ''
            ko = k.get('cob') or k['nm']
            iri = str(k['nm'])[:1] in ('R', 'A', ']')
        else:
            moji = k.get('midashi') or ''
            ko, iri = None, False
        if not moji.strip() and ko is None:
            continue
        gyo.setdefault(k['gyo'], []).append(
            {'gyo': k['gyo'], 'keta': k['keta'], 'naga': k.get('naga') or 0,
             'moji': moji, 'ko': ko, 'iri': iri})
    return [{'gyo': g, 'waku': sorted(gyo[g], key=lambda x: x['keta'])}
            for g in sorted(gyo)]


def ugokasu(na, ire=None, byou=20, kakikomu=False):
    """プログラム1本を動かして、画面と止まった場所を返す。

       ■ 時間切れの見張りと、つなぎ先の置き場所
         目覚まし（SIGALRM）は**本スレッドでしか使えない**。Flask は
         要求ごとに別スレッドで動かすので、そこでは使えない
         （`signal only works in main thread`・2026-11-24）。
         そこで、動かす役を**いつも別スレッド**にして `join(秒)` で待つ。
         SQLite のつなぎは**作ったスレッドでしか使えない**ので、
         つなぐのも閉じるのも、その別スレッドの中でやる。
    """
    kekka = {'pgm': na, 'tomatta': None, 'ato': None, 'gamen': [], 'kaita': {}}
    try:
        cls = _cls(na)
    except Exception as e:
        kekka['tomatta'] = '写せません: %s: %s' % (type(e).__name__, e)
        return kekka
    setsu, me = _iriguchi(cls)
    hako = {}

    def _honbun():
        con = cimdb.connect()
        try:
            try:
                con.execute('BEGIN')
            except Exception:
                pass
            p = cls(con=con, db=cimdb, sousa=Sousa(ire), kyou=None)
            p.gamen_tome = 1          # 画面が1枚書かれたら止める
            hako['p'] = p
            if setsu:
                p._setsu(setsu)
            elif me and hasattr(p, me):
                getattr(p, me)()
            else:
                hako['tomatta'] = '入口が決まりません'
        except (Tometa, GamenDeta):
            hako['dekita'] = '画面が出たところまで動かしました'
        except BaseException as e:            # noqa: BLE001
            hako['tomatta'] = '%s: %s' % (type(e).__name__, str(e)[:200])
            hako['ato'] = traceback.format_exc()[-1500:]
        finally:
            try:
                con.commit() if kakikomu else con.rollback()
            except Exception:
                pass
            con.close()

    th = threading.Thread(target=_honbun, daemon=True)
    th.start()
    th.join(byou)
    if th.is_alive():
        kekka['tomatta'] = ('%d秒で終わりませんでした'
                            '（入力待ちの作りかもしれません）' % byou)
        return kekka
    kekka['tomatta'] = hako.get('tomatta')
    kekka['ato'] = hako.get('ato')
    kekka['dekita'] = hako.get('dekita')

    # 画面に書かれたものを、定義体の位置で切り分ける
    g = teigitai()
    pp = hako.get('p')
    kaita = getattr(pp, 'kaita', {}) or {}
    so = getattr(pp, 'sousa', None)
    if not kaita and getattr(so, 'kaita', None):
        # 画面出力Ｒ（vld 経由）で書かれたぶん
        kaita = {'画面': [r for _g, r in so.kaita]}
    rec = None
    for _f, nami in kaita.items():
        if nami:
            rec = nami[-1]
    for mei in gamen_mei(na):
        kekka['gamen'].append({'na': mei, 'gyo': gamen_hyo(g[mei], rec)})
    kekka['kaita'] = {k: len(v) for k, v in kaita.items()}
    return kekka
