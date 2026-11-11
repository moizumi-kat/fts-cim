# -*- coding: utf-8 -*-
"""工程11-1 の子6本の骨格を調べる（移植に入る前の下調べ）。

     python3 bin/shirabe_ko6.py <COBOLソース置き場>
"""
import sys, pathlib, re, collections

SRC = pathlib.Path(sys.argv[1])
KO = [('A10040PO', '鑑'), ('A10050PO', '概算'), ('A10060PO', '項目'),
      ('A10070PO', '明細'), ('A10080PO', '函体'), ('A10090PO', '科目')]

R_SEL   = re.compile(r'^\s*SELECT\s+([\w-]+)', re.I)
R_ASG   = re.compile(r'ASSIGN\s+TO\s+([\w-]+)', re.I)
R_FD    = re.compile(r'^\s*FD\s+([\w-]+)', re.I)
R_COPY  = re.compile(r'\bCOPY\s+([\w-]+)\s+OF\s+([\w-]+)', re.I)
R_CALL  = re.compile(r'\bCALL\s+[\'"]?([\w-]+)', re.I)
R_SECT  = re.compile(r'^\s{0,6}([^\s.]+)\s+SECTION\s*\.', re.I)
R_PARA  = re.compile(r'^\s{0,6}([^\s.]+)\s*\.\s*$')
R_PID   = re.compile(r'PROGRAM-ID\s*\.\s*([\w-]+)', re.I)

def gyo(p):
    """原文の行。注記行・デバッグ行を外し、標識欄を落として本文だけ返す。

       ■ 桁について（実測 2026-11-11）
         このソースは**行番号欄（1-6桁）が無い**。1桁目が標識欄で、
         2桁目から A領域、6桁目から B領域（＝原本の7桁目以降がそのまま来ている）。
         例）A10080PO.COB 33行目  " PROGRAM-ID.                     A10080PO."
         1桁目から6文字削ると CONFIGURATION が GURATION に化けるので注意。
    """
    for ln in p.read_text('utf-8', errors='replace').splitlines():
        ln = ln.rstrip('\r\n')
        if not ln:
            continue
        if ln[0] in ('*', '/', 'D', 'd'):      # 注記行・デバッグ行
            continue
        b = ln[1:67]                            # 標識欄を落とす（本文は66桁）
        if b.strip():
            yield b

for pg, yaku in KO:
    p = SRC / (pg + '.COB')
    if not p.exists():
        print('%s  ソースなし' % pg); continue
    hon = list(gyo(p))
    zen = '\n'.join(hon)
    pid = (R_PID.search(zen) or [None, '?'])[1]

    sel = {}
    for ln in hon:
        m = R_SEL.search(ln)
        if m:
            nazuke = m.group(1).upper()
            a = R_ASG.search(ln)
            sel[nazuke] = (a.group(1).upper() if a else '')
    # SELECT と ASSIGN が行をまたぐ場合
    for i, ln in enumerate(hon):
        m = R_SEL.search(ln)
        if m and not R_ASG.search(ln):
            for j in range(i + 1, min(i + 4, len(hon))):
                a = R_ASG.search(hon[j])
                if a:
                    sel[m.group(1).upper()] = a.group(1).upper(); break

    copy = sorted({(a.upper(), b.upper()) for a, b in R_COPY.findall(zen)})
    call = sorted({c.upper() for c in R_CALL.findall(zen)})
    sect = [m.group(1).upper() for ln in hon if (m := R_SECT.match(ln))]
    para = [m.group(1).upper() for ln in hon if (m := R_PARA.match(ln))]

    gamen = sorted({a for a, b in copy if b.endswith('MDLIB')})
    fdlib = sorted({a for a, b in copy if b.endswith('FDLIB')})
    hoka  = sorted({'%s OF %s' % (a, b) for a, b in copy
                    if not b.endswith(('MDLIB', 'FDLIB'))})

    print('━' * 72)
    print('%s（%s）  PROGRAM-ID %s  %d行（注記・デバッグ行を除いて %d行）'
          % (pg, yaku, pid, sum(1 for _ in p.open(encoding='utf-8', errors='replace')), len(hon)))
    print('  画面定義 : %s' % ('／'.join(gamen) or 'なし'))
    print('  COPY(FD) : %s' % ('／'.join(fdlib) or 'なし'))
    if hoka:
        print('  COPY(他) : %s' % '／'.join(hoka))
    print('  使うファイル %d本' % len(sel))
    for k, v in sorted(sel.items()):
        print('      %-14s → %s' % (k, v or '（ASSIGNが読めない）'))
    print('  CALL %d本 : %s' % (len(call), '／'.join(call) or 'なし'))
    print('  SECTION %d ／ 段落 %d' % (len(sect), len(para)))
    if sect:
        print('      ' + '／'.join(sect[:14]) + ('…' if len(sect) > 14 else ''))
