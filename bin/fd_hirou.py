# -*- coding: utf-8 -*-
"""プログラムが FD の下に直接書いているレコードを取り出す。

   XFDLIB（ファイル記述）をいただけていないファイルでも、
   プログラムが自分でレコードを書いていれば、そこから定義を起こせる。
   取り出した並びは recdef と同じ形（レベル・英名・PIC・繰返し）にそろえる。
"""
import sys, re, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).parent))

LVL = re.compile(r'^\s*(\d\d)\s+([^\s.]+)\s*(.*)$')
PIC = re.compile(r'\bPIC(?:TURE)?\s+(?:IS\s+)?([SX9NAV()0-9]+)', re.I)
OCC = re.compile(r'\bOCCURS\s+(\d+)', re.I)


def hirou(cob, fdname):
    """FD <fdname> の 01 以下を拾う"""
    t = pathlib.Path(cob).read_text('utf-8', 'replace')
    lines = t.splitlines()
    naka, out, hajime = False, [], None
    for i, ln in enumerate(lines):
        if ln.lstrip().startswith('*'):
            continue
        m = re.match(r'^\s*FD\s+(\S+)', ln)
        if m:
            naka = (m.group(1).rstrip('.') == fdname)
            continue
        if not naka:
            continue
        if re.match(r'^\s*(FD|SD|WORKING-STORAGE|LINKAGE|PROCEDURE)\b', ln):
            break
        g = LVL.match(ln)
        if not g:
            continue
        lv, nm, ato = int(g.group(1)), g.group(2), g.group(3)
        # 続きの行に PIC があることがある
        j = i
        while not PIC.search(ato) and '.' not in ato and j + 1 < len(lines):
            j += 1
            if lines[j].lstrip().startswith('*'):
                continue
            if LVL.match(lines[j]):
                break
            ato += ' ' + lines[j].strip()
        p = PIC.search(ato)
        o = OCC.search(ato)
        if lv == 1 and hajime is None:
            hajime = nm
        out.append({'lv': lv, 'en': nm, 'jp': '',
                    'pic': p.group(1) if p else '',
                    'you': 'C' if re.search(r'\bCOMP-3\b', ato, re.I) else '',
                    'occ': int(o.group(1)) if o else 0, 'len': 0, 'pos': 0})
    return hajime, [x for x in out if x['lv'] > 1]


if __name__ == '__main__':
    import recdef
    for cob, fd, hyo in (('cim/utf8/TENSO1CF.COB', '売上ファイル', 'TENURISF'),
                         ('cim/utf8/TENSO2CF.COB', 'TENURI2F', 'TENURI2F'),
                         ('cim/utf8/MJS110CF.COB', '売上用ファィル３', 'TENURI3F')):
        rec01, items = hirou(cob, fd)
        cols, warn = recdef.hashira(items, hyo)
        baito = 0
        for it in items:
            if it['pic']:
                _g, n = recdef.sqlgata(it['pic'])
                baito += (n or 0) * max(1, it['occ'])
        print('■ %-9s ← %s の FD %s（01 %s）' % (hyo, pathlib.Path(cob).stem, fd, rec01))
        print('   要素項目 %d ／ 起こせた列 %d' % (sum(1 for x in items if x['pic']), len(cols)))
        for c in cols[:6]:
            print('     %-10s %-14s %s' % (c[0], c[1], c[3]))
        if len(cols) > 6:
            print('     …ほか %d 列' % (len(cols) - 6))
        if warn:
            print('   警告:', '／'.join(warn))
        print()
