# -*- coding: utf-8 -*-
"""CASET仕様書／DPS仕様書の目録を作る。

     python3 bin/caset_mokuroku.py <CASET仕様書.zip> <DPS仕様書.zip> out.json

  ■ カセットとは（2026-11-11 村上様ご教示・現物で確認）
     末尾が KB／KP／KO のプログラムは **CASET（カセット言語）** で書かれており、
     **COBOLソースは存在しない。** 仕様書が実体である。
     現行ソース中にも裏づけがある：
       MITHN1CF.COB 430行「カセット言語で開発されていたＡ２００３０ＫＢでは…」

     仕様書は1プログラム1冊のPDF（画像・テキスト層なし）。1冊の構成は
       C1SS11 プログラム概要定義 … プログラムID／作成言語CASET／動作形態／
                                   **資源種（ファイル名・アクセス名・順乱・I/O・編成）**
       C1PS11 CAPEユニット定義   … 入力表／出力表／抽出条件／ユニット連結フロー
       C1PS13 プログラム処理定義 … パラメタの入力チェック等の詳細
       C1PS15 出力項目仕様       … 項目ごとの 更新/出力条件・参照項目・編集方法
     ＝ COBOLソースの代わりに**そのまま移植できる**水準。

  ■ 置き場所（155MBあるのでリポジトリには入れない）
     Dropbox /CIM更新/新プロジェクト/CASET仕様書.zip  （2026-09-16 受領）
     Dropbox /CIM更新/新プロジェクト/DPS仕様書.zip    （同上）
"""
import sys, zipfile, json, os

OUT = sys.argv[3]
def yomu(p):
    z = zipfile.ZipFile(p)
    r = {}
    for x in z.namelist():
        try: nm = x.encode('cp437').decode('cp932')
        except Exception: nm = x
        if not nm.lower().endswith('.pdf'):
            continue
        bu = nm.split('/')
        r[os.path.splitext(bu[-1])[0].upper()] = {
            'sub': bu[1] if len(bu) > 2 else '',
            'path': nm,
            'bytes': z.getinfo(x).file_size,
        }
    return r

caset, dps = yomu(sys.argv[1]), yomu(sys.argv[2])
json.dump({'caset': caset, 'dps': dps,
           'moto': {'caset': '/CIM更新/新プロジェクト/CASET仕様書.zip',
                    'dps': '/CIM更新/新プロジェクト/DPS仕様書.zip'}},
          open(OUT, 'w'), ensure_ascii=False, indent=1)
print('CASET仕様書 %d本 ／ DPS仕様書 %d本 → %s' % (len(caset), len(dps), OUT))
import collections
for na, r in (('CASET', caset), ('DPS', dps)):
    c = collections.Counter(v['sub'] for v in r.values())
    for a, b in sorted(c.items()):
        print('   %-6s %-28s %3d本' % (na, a or '(直下)', b))
