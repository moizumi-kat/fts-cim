# -*- coding: utf-8 -*-
"""「呼ばれているのに、ソースが見当たらない」プログラムを数え直す（作り直し版）。

     python3 bin/shirabe_tarinai.py <COBOL/CLソース置き場> [out.json]

  ■ 2026-11-11 に見つけた、2026-11-04 の数えまちがい
     (1) SBMJOB の `PGM-xxx` から **`PGM-` を外していなかった**。
         ・同じ1本が「BANKIN9O」と「PGM-BANKIN9O」の2件に数えられた（重複）。
         ・さらに悪いことに、`PGM-BANKIN1O` は PROGRAM-ID 表と照合できないので
           **ソースがあるのに「無い」と数えられた**（素の BANKIN1O は
           BANKIN1S.COB に辿れる）。
     (2) CLの「名前のみで起動する形」を拾う正規表現が、CLのコマンド語
         （CNVFILE・SETPF・MONMSG 等）も拾っていた。
     (2') **CLのコメント「/.」〜「./」を外していなかった**（村上様ご教示
         2026-11-12）。コメントアウトされた呼び出しを生きていると数えていた。
         例) PKOUJOU3.CL 44行  /.  CLRFILE FILE-KUMIKSF.FCDLIB ./
     (3) `CALL PGM-D20070PP` から **`PGM`** を名前として拾っていた
         （`-` を名前の文字に入れていなかったため）。本体の D20070PP は
         SBMJOB 側の正規表現で拾えているので取りこぼしは無いが、
         `PGM` という存在しないプログラムが1件増えていた。

     そこで本版では、**どの書き方で呼ばれていたか**を名前ごとに持ち、
       確実（CALL／SBMJOB で呼ばれている）
       要精査（CLの「名前のみ」でしか現れない＝コマンド語の疑い）
     に分けて数える。
"""
import sys, re, json, pathlib, collections
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import cl_honbun

U = pathlib.Path(sys.argv[1])
OUT = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else None

src = {f.stem.upper(): f for f in list(U.glob('*.CL')) + list(U.glob('*.COB'))}
kind = {n: f.suffix.upper().lstrip('.') for n, f in src.items()}
# CL は「/.」〜「./」がコメント（村上様ご教示 2026-11-12）。
# 外さないと、コメントに書かれたコマンドやプログラム名を
# 「生きている」と数えてしまう。
txt = {}
for n, f in src.items():
    t = f.read_text('utf-8', 'replace')
    txt[n] = cl_honbun.honbun(t) if kind[n] == 'CL' else t

PID      = re.compile(r'^\s*PROGRAM-ID\.\s*([A-Z0-9#@$\-]+)\s*\.', re.M | re.I)
# CALL PGM-xxx の形では PGM を拾わない（名前は SBM 側で取る）
CL_CALL  = re.compile(r'\bCALL\s+(?!PGM-)([A-Z0-9#@$]+)')
BARE     = re.compile(r'^\s+([A-Z0-9#@$]{4,8})(?=[\s,]|$)', re.M)
SBM      = re.compile(r'PGM-([A-Z0-9#@$]+)')
COB_CALL = re.compile(r'CALL\s+["\']([A-Z0-9#@$\-]+)["\']')

# 富士通・ASP の実行時ルーチン／CLコマンド（プログラムではない。現物で確認したもの）
RUNTIME = {'XMROTSTR', 'XMROTEND', 'XMROTCNL', 'XMROTABN', 'XMROTCHK',
           'WAIT',                      # CALL WAIT        ＝ASPのCLコマンド
           'VLDSTART', 'VLDSTOP',       # CALL VLDSTART ./ ＝画面(VLD)の開始・終了
           'CALL', 'PGM'}               # 正規表現が拾ってしまう語

# PGM- の値だが、プログラム名か CL のキーワードか判別できないもの（4件・要確認）
AYAFUYA = {'END', 'START', 'STATUS', 'STS'}

# 実行形式名 → ソース名。**末尾の文字で読み替えず、PROGRAM-ID を読む**
jikkou = {n: n for n in src}
for n in src:
    if kind[n] == 'COB':
        m = PID.search(txt[n])
        if m:
            jikkou[m.group(1).upper()] = n

kata = collections.defaultdict(set)        # 名前 → どの書き方で呼ばれたか
moto = collections.defaultdict(set)        # 名前 → 呼び元
for n in src:
    t = txt[n]
    if kind[n] == 'CL':
        mi = ([('CALL', x) for x in CL_CALL.findall(t)]
              + [('SBMJOB', x) for x in SBM.findall(t)]
              + [('名前のみ', x) for x in BARE.findall(t)])
    else:
        mi = ([('CALL', x) for x in COB_CALL.findall(t)]
              + [('CALL', x) for x in CL_CALL.findall(t)]
              + [('SBMJOB', x) for x in SBM.findall(t)])
    for k, x in mi:
        x = x.upper()
        kata[x].add(k)
        moto[x].add(n)

nai = sorted(x for x in kata
             if x not in jikkou and x not in RUNTIME and x not in src)
kakujitsu = [x for x in nai
             if (kata[x] & {'CALL', 'SBMJOB'}) and x not in AYAFUYA]
ayafuya   = [x for x in nai if x in AYAFUYA]
seisa     = [x for x in nai if not (kata[x] & {'CALL', 'SBMJOB'})]

def wake(mono):
    k1 = sorted(x for x in mono if re.search(r'(KB|KP|KO)$', x))
    k2 = sorted(x for x in mono if x.endswith('O') and x not in k1)
    k3 = sorted(x for x in mono if x not in k1 and x not in k2)
    return k1, k2, k3

print('■ 呼ばれているのに、ソースが見当たらない名前  %d件' % len(nai))
print('   うち 確実（CALL／SBMJOB で呼ばれている）   %3d件' % len(kakujitsu))
print('   うち 要精査（CLの「名前のみ」でしか出ない） %3d件  ← CLのコマンド語の疑い' % len(seisa))
print('   うち プログラム名か判別できない             %3d件  ← %s'
      % (len(ayafuya), '／'.join(sorted(ayafuya))))
print()
k1, k2, k3 = wake(kakujitsu)
print('■ 確実な %d件の内訳（2026-11-04 の依頼文と同じ区分）' % len(kakujitsu))
print('   １．末尾 KB／KP／KO    %3d本   （依頼文 134本）' % len(k1))
print('   ２．末尾 O（KOを除く）  %3d本   （依頼文 223本）' % len(k2))
print('   ３．そのほか           %3d本   （依頼文 454本）' % len(k3))
print()
for midashi, mono in (('１．末尾 KB／KP／KO', k1), ('２．末尾 O（KOを除く）', k2),
                      ('３．そのほか', k3)):
    print('── %s  %d本 ──' % (midashi, len(mono)))
    for i in range(0, len(mono), 6):
        print('    ' + '  '.join('%-10s' % y for y in mono[i:i + 6]))
    print()

if seisa:
    print('── 要精査（CLの「名前のみ」でしか出ない）  %d件 ──' % len(seisa))
    for i in range(0, len(seisa), 6):
        print('    ' + '  '.join('%-10s' % y for y in seisa[i:i + 6]))
    print()

if OUT:
    json.dump({'kakujitsu': {x: sorted(moto[x]) for x in kakujitsu},
               'ayafuya': {x: sorted(moto[x]) for x in ayafuya},
               'seisa': {x: sorted(moto[x]) for x in seisa},
               'kb_kp_ko': k1, 'owari_o': k2, 'hoka': k3,
               'jikkou': jikkou},
              open(OUT, 'w'), ensure_ascii=False, indent=1)
    print('書き出し:', OUT)
