# -*- coding: utf-8 -*-
"""画面定義(.SMD)＋COBOL から、画面レコードの定義をPythonとして起こす。

     python3 bin/gen_gamen.py <画面.SMD> <プログラム.COB> <出力.py>

  ■ 何を根拠にしているか（2026-11-11 実測）
    位置・桁    … .SMD（行・桁・表示長・データ長・レコード内位置・順番）
    項目名      … COBOL「制御項目初期化Ｒ」の EDIT-STATUS OF の並び
                  （.SMD の R＝入力／W＝出力 の数と一致することを検査する）
    型          … COBOL「第ｎ項目群消去Ｒ」の MOVE ZERO（数字）/ MOVE SPACE（英数）
    項目群      … 同上。どの項目がどの群に属するか
  ※ XMDLIB のコピー原文は未入手。入手できたら、この生成結果と突き合わせること。
"""
import sys, re, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import smd_parse, cp932

SMD, COB, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
_na, ko, _n = smd_parse.yomu(SMD)
kom = sorted([k for k in ko if k['gyo'] is not None and k['nm'][0] in ('R', 'W')],
             key=lambda k: k['k7'])

hon = []
for ln in pathlib.Path(COB).read_text('utf-8', errors='replace').splitlines():
    ln = ln.rstrip('\r\n')
    if ln and ln[0] not in ('*', '/', 'D', 'd'):
        hon.append(ln[1:67])

# 項目名：EDIT-STATUS OF の**最も長い連続並び**＝制御項目初期化Ｒ
R1 = re.compile(r'EDIT-STATUS\s+OF\s+(\S+)')
ima, saidai = [], []
for ln in hon:
    m = R1.search(ln)
    if m:
        ima.append(m.group(1).rstrip('.'))
    elif ima:
        if len(ima) > len(saidai):
            saidai = ima
        ima = []
if len(ima) > len(saidai):
    saidai = ima
namae = saidai
if len(namae) != len(kom):
    sys.exit('項目の数が合いません（画面 %d／COBOL %d）。この画面は順番で'
             '対応づけられません。' % (len(kom), len(namae)))

# 群と型：「第ｎ項目群消去Ｒ－開始」の MOVE ZERO/SPACE
zen = '\n'.join(hon)
KAN = {'１': 1, '２': 2, '３': 3, '４': 4, '５': 5, '６': 6, '７': 7}
gun, kata = {}, {}
for m in re.finditer(r'第([１-７])項目群消去Ｒ－開始\.(.*?)(?=\n\s*第|\n\s*\S+\s+SECTION)',
                     zen, re.S):
    n = KAN[m.group(1)]
    ima_kata = None
    for ln in m.group(2).splitlines():
        mm = re.search(r'MOVE\s+(ZERO|SPACE)\s+TO\s+(.*)$', ln)
        if mm:
            ima_kata = '9' if mm.group(1) == 'ZERO' else 'X'
            ln = mm.group(2)
        for x in re.findall(r'[^\s.]+', ln):
            if x in namae:
                gun[x] = n
                if ima_kata:
                    kata[x] = ima_kata

b = ['# -*- coding: utf-8 -*-',
     '"""画面 %s の定義。bin/gen_gamen.py が自動生成。**手で直さない。**' % pathlib.Path(SMD).stem,
     '',
     '   位置・桁 … %s（現物）' % pathlib.Path(SMD).name,
     '   項目名   … %s の「制御項目初期化Ｒ」の並び' % pathlib.Path(COB).stem,
     '   型・群   … 同じソースの「第ｎ項目群消去Ｒ」',
     '   ※ XMDLIB のコピー原文は未入手。入手したら突き合わせること。',
     '',
     '   KOUMOKU の1件 = (画面名, 項目名, 行, 桁, 表示長, データ長, レコード内位置, 型, 群)',
     '     型 … "9"=数字（ZEROで消す） "X"=英数（SPACEで消す） ""=消去段落に出てこない',
     '     群 … 1-7。0＝どの消去段落にも出てこない',
     '"""', '',
     'GAMEN = %r' % pathlib.Path(SMD).stem,
     'KOUMOKU = [']
for k, n in zip(kom, namae):
    b.append('    (%-8r, %-20r, %2d, %2d, %3d, %3d, %5d, %-3r, %d),'
             % (k['nm'], n, k['gyo'], k['keta'], k['naga'], k['naga2'], k['k6'],
                kata.get(n, ''), gun.get(n, 0)))
b.append(']')
b.append('')
b.append('# レコードの長さ（最後の項目の位置＋データ長）')
b.append('NAGASA = %d' % (kom[-1]['k6'] + kom[-1]['naga2']))
# Pythonソースは UTF-8 で書く。cp932 の検査だけ通す
# （Windows のコンソールに出しても化けないように）
honbun = '\n'.join(b) + '\n'
warui = cp932.warui(honbun)
if warui:
    sys.exit('cp932 で出せない字があります: %r' % warui)
pathlib.Path(OUT).write_text(honbun, encoding='utf-8')
print('%s → %s  項目 %d／群つき %d／型つき %d／レコード %dバイト'
      % (pathlib.Path(SMD).name, OUT, len(kom), len(gun), len(kata),
         kom[-1]['k6'] + kom[-1]['naga2']))
