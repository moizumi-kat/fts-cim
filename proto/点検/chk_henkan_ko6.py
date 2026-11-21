# -*- coding: utf-8 -*-
"""工程11-1 の子6本を自動変換し、実データで動くところまで確かめる。

     python3 点検/chk_henkan_ko6.py

  鑑（A10040PO）は手で写した版と1,150件で一致済み。
  残り5本（概算・項目・明細・函体・科目）は手本が無いので、
  ここでは「変換できる／記憶域とファイルがそろう／実データで節が動く」
  ところまでを見る。**動かない箇所はその場で止まる**ので、何が足りないかが出る。
"""
import sys, pathlib, datetime, types, traceback
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent.parent
                       / 'fts-cim-repo' / 'bin'))
from cim import db as cimdb
from cim.cobol import vld
from cob2py import kumitate

KO = ['A10010PO', 'A10040PO', 'A10050PO', 'A10060PO', 'A10070PO',
      'A10080PO', 'A10090PO']
MOTO = pathlib.Path(__file__).resolve().parent.parent.parent / 'cim' / 'utf8'

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)


class Sousa(vld.Kioku):
    def yomu(self, group, mode):
        return None, vld.NYURYOKU


con = cimdb.connect()
kyou = datetime.datetime(2026, 11, 21, 9, 0, 0)

print('■ 工程11-1 の7本を自動変換する')
pgm = {}
for na in KO:
    f = MOTO / (na + '.COB')
    try:
        honbun, d = kumitate.kumu(str(f))
        m = types.ModuleType(na)
        exec(compile(honbun, na, 'exec'), m.__dict__)
        cls = next(v for k, v in m.__dict__.items()
                   if isinstance(v, type) and getattr(v, 'KIOKU', None) is not None
                   and k != 'Pgm')
        pgm[na] = cls
        gyo = len(f.read_text('utf-8', 'replace').splitlines())
        miru('%s（原文 %s行）' % (na, format(gyo, ',')), True,
             'Python %s行／未変換 %d件／記憶域 %d／ファイル %d'
             % (format(len(honbun.splitlines()), ','), len(d.mikansei),
                len(cls.KIOKU), len(cls.FAIRU)))
    except Exception as e:
        miru(na, False, '%s: %s' % (type(e).__name__, str(e)[:60]))

print()
print('■ 実データで節を動かしてみる（止まった場所が分かる）')
mituno = [r[0] for r in con.execute(
    'SELECT MITUNO FROM AJBGFP ORDER BY MITUNO LIMIT 3')]
print('   使う見積No', mituno)

import unicodedata
for na in ('A10040PO', 'A10050PO', 'A10060PO', 'A10070PO', 'A10080PO', 'A10090PO'):
    if na not in pgm:
        continue
    # 最初の処理の節（初期化にあたるもの）を変換結果から拾う
    setsu = None
    for sna, _dan in pgm[na].DANRAKU:
        if sna.startswith('__'):
            continue
        setsu = sna
        if '初期' in sna:
            break
    if setsu is None:
        miru(na, False, '節が無い'); continue
    from cob2py.tetsuzuki import na_py
    me = na_py(setsu)
    p = pgm[na](con=con, db=cimdb, sousa=Sousa(), kyou=kyou)
    if not hasattr(p, me):
        miru('%s の %s' % (na, setsu), False, '節が見つからない')
        continue
    try:
        con.execute('DELETE FROM ACHKFP'); con.commit()
        if na == 'A10040PO':
            setsu = '修正第２項目群'
            me = na_py(setsu)
            p.S('処理区', 2); p.S('見積なんば', mituno[0])
        getattr(p, me)()
        miru('%s の %s が通った' % (na, setsu), True)
    except Exception as e:
        miru('%s の %s' % (na, setsu), False,
             '%s: %s' % (type(e).__name__, str(e)[:70]))
    finally:
        con.execute('DELETE FROM ACHKFP'); con.commit()

print()
print('%s （止まったところ %d件）'
      % ('7本とも動きました。' if not warui else 'まだ止まるところがあります。', warui))
