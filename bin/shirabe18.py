# -*- coding: utf-8 -*-
"""定義が見当たらない表について、現行ソースでの扱われかたを調べる。

   ・COBOL …  SELECT 〜 ASSIGN で使っているか。FD のレコードが
              「COPY 〜 OF XFDLIB」か「直書き」かを見る
   ・CL   …  CRTFILE/CLRFILE/DLTFILE/CPYFILE などで触っているか
"""
import sys, re, pathlib, collections
U = pathlib.Path(sys.argv[1])
NAMAE = sys.argv[2:]

cob = {p.stem: p.read_text('utf-8', 'replace') for p in U.glob('*.COB')}
cl = {p.stem: p.read_text('utf-8', 'replace') for p in U.glob('*.CL')}

SEL = re.compile(r'^\s*SELECT\s+(\S+)(.*?)$', re.M)
ASSIGN = re.compile(r'\bASSIGN\s+(?:TO\s+)?([A-Z0-9#@$]+(?:-[A-Z0-9#@$]+)*)')


def fd_no_naka(t, fname):
    """FD <fname> の直後が COPY か直書きかを返す"""
    lines = [x for x in t.splitlines()]
    for i, ln in enumerate(lines):
        if ln.lstrip().startswith('*'):
            continue
        m = re.match(r'^\s*FD\s+(\S+)', ln)
        if not m or m.group(1).rstrip('.') != fname:
            continue
        ato = []
        for x in lines[i + 1:i + 14]:
            if x.lstrip().startswith('*') or not x.strip():
                continue
            ato.append(x)
            if re.match(r'^\s*(FD|SD|WORKING-STORAGE|LINKAGE|PROCEDURE)\b', x):
                break
        txt = '\n'.join(ato)
        c = re.search(r'COPY\s+(\S+)\s+OF\s+(\w+)', txt, re.I)
        if c:
            return 'COPY', '%s OF %s' % (c.group(1), c.group(2)), ''
        o = re.search(r'^\s*01\s+(\S+)', txt, re.M)
        if o:
            return '直書き', o.group(1).rstrip('.'), txt
        return '不明', '', txt
    return None, '', ''


for nm in NAMAE:
    print('=' * 64)
    print('■ %s' % nm)
    tsukau = []
    for pg, t in cob.items():
        for mm in SEL.finditer(t):
            blk = t[mm.start():mm.start() + 400]
            for a in ASSIGN.findall(blk):
                if a.upper().split('-')[-1] == nm:
                    tsukau.append((pg, mm.group(1).rstrip('.')))
                    break
            else:
                continue
            break
    if tsukau:
        for pg, fname in sorted(set(tsukau)):
            kind, naka, _t = fd_no_naka(cob[pg], fname)
            print('   COBOL %-10s SELECT %-16s FD=%s %s' % (pg, fname, kind, naka))
    else:
        print('   COBOL: 使っているプログラムなし')
    clpg = sorted(p for p, t in cl.items() if re.search(r'\b%s\b' % nm, t))
    if clpg:
        print('   CL   : %s' % ' '.join(clpg[:8]))
        p0 = clpg[0]
        for ln in cl[p0].splitlines():
            if nm in ln and not ln.lstrip().startswith('*'):
                print('          例) %s … %s' % (p0, ln.strip()[:76]))
                break
    else:
        print('   CL   : なし')
