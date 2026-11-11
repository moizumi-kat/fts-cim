# -*- coding: utf-8 -*-
"""指定した範囲を「8バイト1行」で、16進＋EBCDIC で並べる。"""
import sys, pathlib
p = pathlib.Path(sys.argv[1]); b = p.read_bytes()
start = int(sys.argv[2], 16); end = int(sys.argv[3], 16)
w = int(sys.argv[4]) if len(sys.argv) > 4 else 8
for i in range(start, min(end, len(b)), w):
    chunk = b[i:i+w]
    h = ' '.join('%02X' % c for c in chunk)
    e = chunk.decode('cp500', 'replace')
    e = ''.join(c if c.isprintable() and c != '\xa0' else '.' for c in e)
    print('%04X  %-*s  |%s|' % (i, w*3, h, e))
