# -*- coding: utf-8 -*-
"""画面定義(.SMD)の項目と、COBOL の項目名を突き合わせる。

     python3 bin/gamen_awase.py <画面.SMD> <プログラム.COB>

  ■ 考え方（2026-11-11 実測で確かめた）
     XMDLIB のコピー原文は未入手だが、
       ・.SMD には項目の 行・桁・表示長・データ長・レコード内位置・順番 がある
       ・COBOL の「制御項目初期化Ｒ」が、項目名を**画面の順番どおり**に並べている
     ので、**順番で対応づけられる**。
     .SMD の R（入力）＋W（出力）の数と、COBOL の属性付き項目の数が一致することを
     対応づけの前提条件として検査する（合わなければ止める）。
"""
import sys, re, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import smd_parse

SMD, COB = sys.argv[1], sys.argv[2]
_namae, ko, _n = smd_parse.yomu(SMD)

# 画面の項目（R=入力・W=出力）。順番(k7)に並べる
kom = [k for k in ko if k['gyo'] is not None and k['nm'][0] in ('R', 'W')]
kom.sort(key=lambda k: k['k7'])

# COBOL 側：EDIT-STATUS OF xxx の並び＝画面の順番
hon = []
for ln in pathlib.Path(COB).read_text('utf-8', errors='replace').splitlines():
    ln = ln.rstrip('\r\n')
    if ln and ln[0] not in ('*', '/', 'D', 'd'):
        hon.append(ln[1:67])
zen = '\n'.join(hon)
# 「制御項目初期化Ｒ」は EDIT-STATUS OF を全項目ぶん**連続して**並べる。
# 入力強調処理Ｒ など他の段落も EDIT-STATUS を使うので、
# **最も長い連続並び**を採る（＝制御項目初期化Ｒ）。
R1 = re.compile(r'EDIT-STATUS\s+OF\s+(\S+)')
ima, saidai = [], []
for ln in hon:
    m = R1.search(ln)
    if m:
        ima.append(m.group(1))
    elif ima:
        if len(ima) > len(saidai):
            saidai = ima
        ima = []
if len(ima) > len(saidai):
    saidai = ima
junjo = [x.rstrip('.') for x in saidai]

print('■ %s  画面項目(R/W) %d ／ %s の属性付き項目 %d'
      % (pathlib.Path(SMD).stem, len(kom), pathlib.Path(COB).stem, len(junjo)))
if len(kom) != len(junjo):
    print('   **数が合いません。順番での対応づけはできません。**')
    sys.exit(1)
print('   数が一致。順番で対応づけます。')
print()
print('%-4s %-8s %-18s %4s %4s %5s %5s %6s' %
      ('順', '画面', 'COBOL項目名', '行', '桁', '表示長', 'データ長', 'レコード内'))
for i, (k, n) in enumerate(zip(kom, junjo), 1):
    print('%4d %-8s %-18s %4d %4d %5d %5d %6d'
          % (i, k['nm'], n, k['gyo'], k['keta'], k['naga'], k['naga2'], k['k6']))
