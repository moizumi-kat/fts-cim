# -*- coding: utf-8 -*-
"""ＣＬの注釈の外し方が、マニュアルの規則どおりかを確かめる。

     python3 zcheck/chk_cl_honbun.py <COBOL/CLソース置き場>

  根拠 … システム開発手引書 4_4.html（ASP V29 マニュアル）
"""
import sys, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent / 'bin'))
import cl_honbun

warui = 0
def miru(na, ok, soe=''):
    global warui
    print('   %s %s%s' % ('[OK]  ' if ok else '[NG]  ', na, ('  ' + soe) if soe else ''))
    warui += (not ok)

print('■ 注釈の外し方')
t0 = "CLRFILE A /. けす ./ B"
h0 = cl_honbun.honbun(t0)
miru('1行の中の注釈が消える', 'けす' not in h0 and 'CLRFILE A' in h0 and h0.endswith(' B'),
     repr(h0))
miru('桁はずれない（長さが同じ）', len(h0) == len(t0), '%d / %d' % (len(h0), len(t0)))
miru('行をまたぐ注釈',
     'DLTF' not in cl_honbun.honbun("/.\nDLTF X\n./\nCLRFILE Y"))
miru('またいでも行数は変わらない',
     cl_honbun.honbun("/.\nDLTF X\n./\nCLRFILE Y").count('\n') == 3)
miru('閉じていない注釈は末尾まで',
     'DLTF' not in cl_honbun.honbun("CLRFILE Y\n/. ここから\nDLTF X"))

print()
print('■ 文字ストリング型直定数の中は注釈にしない（マニュアル 4_4.html）')
t = "SBMJOB PARA-'JOB-A,PGM-B/.C'"
miru("引用符の中の「/.」は値の一部", cl_honbun.honbun(t) == t, repr(cl_honbun.honbun(t)))
t2 = "A '/. x ./' B"
miru('引用符の中はそのまま残る', cl_honbun.honbun(t2) == t2, repr(cl_honbun.honbun(t2)))
t3 = "/. '注釈の中の引用符' ./ CLRFILE Z"
miru('注釈の中の引用符は注釈の一部', 'CLRFILE Z' in cl_honbun.honbun(t3)
     and '注釈' not in cl_honbun.honbun(t3), repr(cl_honbun.honbun(t3)))

if len(sys.argv) > 1:
    print()
    print('■ 手元のＣＬ全部で、前と同じ結果になるか（引用符の中に /. は0件のはず）')
    U = pathlib.Path(sys.argv[1])
    chigau = []
    for p in sorted(U.glob('*.CL')):
        t = p.read_text('utf-8', errors='replace')
        for m in __import__('re').finditer(r"'[^'\n]*'", t):
            if '/.' in m.group(0) or './' in m.group(0):
                chigau.append(p.name)
    miru('引用符の中に「/.」「./」のあるＣＬは無い', not chigau,
         '／'.join(sorted(set(chigau))[:5]))

print()
print('=' * 60)
print('■ %d件 合いませんでした。' % warui if warui else '■ すべてマニュアルどおりでした。')
print('=' * 60)
sys.exit(1 if warui else 0)
