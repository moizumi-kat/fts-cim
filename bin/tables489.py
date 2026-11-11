# -*- coding: utf-8 -*-
"""村上様の「CL，COBOL使用ファイル一覧.xlsx」（489表）から、作る表の一覧を起こす。

  2026-11-11 村上様ご回答
    「表の数は489です。こちらで使用ファイルを調査したところ489ファイルになりました」
    「試作環境には489表全て作ります。新システムに残すのも今のところ489表」
    「要確認17表も全て一覧に存在するので、全て残す」

  こちらが405工程から数えた403表は取り下げ、この489に合わせる。
  名前のゆれは、仕分け提案書（第2版）の「⑤ ファイル名の訂正」で読み替える
  （台帳＝レコードリストの名前 → 一覧の名前。「一覧が正しい」と確認済み）。

  使い方
    python3 tables489.py <一覧.xlsx> <仕分け提案書.xlsx> <レコードリスト置き場> \
                         <定義体置き場> out.json
"""
import sys, json, pathlib, collections
sys.path.insert(0, str(pathlib.Path(__file__).parent))
import openpyxl, recdef, repdef, oginai

LIST, SHIWAKE, RECDIR, DEFDIR, OUT = sys.argv[1:6]
SRCDIR = sys.argv[6] if len(sys.argv) > 6 else 'cim/utf8'

wb = openpyxl.load_workbook(LIST, read_only=True, data_only=True)
rows = [r for r in wb[wb.sheetnames[0]].iter_rows(values_only=True)
        if r and any(c not in (None, '') for c in r)][1:]
M = {}
for r in rows:
    n = str(r[0]).strip().upper()
    M[n] = {'lib': str(r[1] or '').strip(), 'type': str(r[2] or '').strip(),
            'nm': str(r[3] or '').strip(), 'rep': bool(str(r[4] or '').strip())}

# ⑤ ファイル名の訂正（台帳の名前 → 正しい名前）
ws = openpyxl.load_workbook(SHIWAKE, read_only=True, data_only=True)['⑤ ファイル名の訂正']
naoshi = {}
for i, r in enumerate(ws.iter_rows(values_only=True)):
    if i == 0 or not r or not r[1]:
        continue
    a, b = str(r[1] or '').strip().upper(), str(r[6] or '').strip().upper()
    if a and b and a != b:
        naoshi[a] = b

rec = recdef.yomu(RECDIR)
rep = repdef.yomu(DEFDIR)
# 台帳名で持っているものを、正しい名前でも引けるようにする
for a, b in naoshi.items():
    if a in rec and b not in rec:
        rec[b] = rec[a]

# レコードリストにも定義体にも無い表を、現行ソースの根拠で補う（bin/oginai.py）
oginatta = oginai.oginau(rec, rep, SRCDIR)

hyo_rep = sorted(x for x in M if x in rep)
hyo_rec = sorted(x for x in M if x not in rep and x in rec)
nashi = sorted(x for x in M if x not in rep and x not in rec)

print('■ 村上様の一覧 %d 表' % len(M))
print('   定義体（レプリケーション）のまま %3d 表' % len(hyo_rep))
print('   レコードリストから起こす         %3d 表' % len(hyo_rec))
print('   定義が見当たらない               %3d 表' % len(nashi))
print('   → 作れるのは %d 表' % (len(hyo_rep) + len(hyo_rec)))
print()
print('■ 名前の読み替えが効いたもの %d 件'
      % sum(1 for a, b in naoshi.items() if b in M and a in rec))
for a, b in sorted(naoshi.items()):
    if b in M and a in rec:
        print('     %-10s → %s  %s' % (a, b, M[b]['nm']))
print()
print('■ 現行ソースの根拠で補った %d 表' % len(oginatta))
for x in sorted(oginatta):
    kind, moto, konkyo = oginatta[x]
    print('     %-10s %s  %s' % (x, 'ソースから' if kind == 'source' else '写し元 ' + moto, M.get(x, {}).get('nm', '')))
    print('       根拠 %s' % konkyo)
print()
print('■ それでも定義が見当たらない %d 表（お願いする分）' % len(nashi))
for x in nashi:
    print('     %-10s %-9s %-5s %s' % (x, M[x]['lib'], M[x]['type'], M[x]['nm']))
    if x in oginai.WAKARANAI:
        print('       %s' % oginai.WAKARANAI[x])

json.dump({'hyo': hyo_rep + hyo_rec,
           'rep': hyo_rep, 'conv': hyo_rec, 'teigi_nashi': nashi,
           'oginatta': oginatta,
           'naoshi': naoshi,
           'nm': {x: M[x]['nm'] for x in M},
           'lib': {x: M[x]['lib'] for x in M},
           'type': {x: M[x]['type'] for x in M},
           'hantei': {x: '残す' for x in M}},
          open(OUT, 'w'), ensure_ascii=False, indent=1)
print()
print('書き出し:', OUT)
