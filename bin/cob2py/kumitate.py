# -*- coding: utf-8 -*-
"""COBOL 1本を Python の1モジュールに組み立てる。

     python3 bin/cob2py/kumitate.py <ソース.COB> <出力.py>

  ■ 出てくる形
      class <プログラム名>(Pgm):
          KIOKU = [ … 記憶域の作り（DATA DIVISION から） … ]
          def <節の名前>(self): …

  ■ 段落の落ち込みと GO TO
    COBOL の節は、段落が上から下へ落ちていき、GO TO で飛ぶ。
    **GO TO の無い節**は、ふつうに上から下へ並べる（読みやすい）。
    **GO TO のある節**だけ、段落ごとの入れ物を作って順に回す形にする。
      while True:
          if _d == '段落A': …（終わったら _d を次の段落へ）
      GO TO は raise _Tobu('飛び先') で投げ、この回し場で受ける。
      入れ子の IF の中からでも飛べるようにするため、例外にしている。
"""
import sys, re, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))
from cob2py import ji, data, tetsuzuki, dasu
from cob2py.tetsuzuki import na_py


def sagasu(go, *kotoba):
    for i in range(len(go) - 1):
        if go[i].na(kotoba[0]) and go[i+1].na(kotoba[1]):
            return i
    return -1


def kioku_hyo(ne):
    """01 の並び → 記憶域の作り（出力に埋め込む表）。"""
    out = []
    for k in ne:
        ko = []
        for c in k.mina():
            if c is k or c.level == 88:
                continue
            ko.append((c.na, c.ichi - k.ichi, c.naga, c.kata, c.keta,
                       c.shou, c.fugo, c.comp, c.occurs))
        out.append((k.na, k.naga, ko,
                    [(c.na, c.value) for c in k.mina() if c.value is not None]))
    return out


def kumu(michi):
    t = pathlib.Path(michi).read_text('utf-8', 'replace')
    go = ji.waru(t)
    pgm = pathlib.Path(michi).stem
    m = re.search(r'PROGRAM-ID\s*\.\s*([A-Z0-9#@$\-]+)', t, re.I)
    if m:
        pgm = m.group(1)
    d_i = sagasu(go, 'DATA', 'DIVISION')
    p_i = sagasu(go, 'PROCEDURE', 'DIVISION')
    if p_i < 0:
        raise ValueError('PROCEDURE DIVISION がありません')
    ne = data.yomu(go, d_i + 2, p_i) if d_i >= 0 else []
    namae = {c.na for k in ne for c in k.mina()}
    hairetsu = {c.na for k in ne for c in k.mina() if c.occurs}
    # PROCEDURE DIVISION USING 〜 ＝ 呼ぶ側から受け取る項目
    j = p_i + 2
    uketori = []
    if j < len(go) and go[j].na('USING'):
        j += 1
        while j < len(go) and go[j].shu == 'na' and not go[j].na('SECTION'):
            if go[j].na('BY', 'REFERENCE', 'CONTENT', 'VALUE'):
                j += 1; continue
            uketori.append(go[j].v); j += 1
        if j < len(go) and go[j].shu == 'ki' and go[j].v == '.':
            j += 1
    setsu = tetsuzuki.wakeru(go, j, len(go))

    d = dasu.Dasu(pgm, setsu, namae, hairetsu)
    b = ['# -*- coding: utf-8 -*-',
         '"""%s を写したもの。bin/cob2py が自動生成。**手で直さない。**' % pathlib.Path(michi).name,
         '',
         '   もとの原文 %s 行。節 %d・段落 %d。' % (len(t.splitlines()), len(setsu),
                                                  sum(len(x.dan) for x in setsu)),
         '"""',
         'from cim.cobol.hashiru import Pgm, D, SPACE, TAKAI, HIKUI, ZENBU, \\',
         '    WARU, SUUJIKA, EIJIKA, _Tobu, ExitProgram, StopRun, OWARI, NASHI, SEIJOU',
         '',
         '',
         'class %s(Pgm):' % na_py(pgm),
         '    NA = %r' % pgm,
         '    UKETORI = %r' % (uketori,),
         '    KIOKU = %r' % (kioku_hyo(ne),),
         '']
    for s in setsu:
        if s.na == '__honbun__' and not any(x.go for x in s.dan):
            continue
        b += setsu_dasu(d, s)
    # PERFORM A THRU B のぶん
    for kara, made in sorted(d.thru):
        b.append('    def %s(self):' % na_py('%s＿から＿%s' % (kara, made)))
        b.append('        """PERFORM %s THRU %s"""' % (kara, made))
        b.append('        for na in self._thru(%r, %r):' % (kara, made))
        b.append('            getattr(self, na)()')
        b.append('')
    return '\n'.join(b) + '\n', d


def setsu_dasu(d, s):
    """節ひとつ → メソッド。"""
    tobu = {t for x in s.dan for t in x.goto}
    b = ['    def %s(self):' % na_py(s.na),
         '        """%s"""' % s.na]
    if not tobu:
        # 飛び越しが無い節は、段落を順に並べるだけ
        for dan in s.dan:
            if not dan.go:
                continue
            b.append('        # ── %s' % dan.na)
            naka = []
            i = 0
            while i < len(dan.go):
                i = d.bun(dan.go, i, len(dan.go), 2, naka)
            b += naka or ['        pass']
        if len(b) == 2:
            b.append('        pass')
        b.append('')
        return b
    # 飛び越しのある節は、段落を回す形にする
    b.append('        _d = %r' % s.dan[0].na)
    b.append('        while _d is not None:')
    b.append('            try:')
    hajime = True
    for k, dan in enumerate(s.dan):
        tsugi = s.dan[k+1].na if k + 1 < len(s.dan) else None
        b.append('                %s _d == %r:' % ('if' if hajime else 'elif', dan.na))
        hajime = False
        naka = []
        i = 0
        while i < len(dan.go):
            i = d.bun(dan.go, i, len(dan.go), 5, naka)
        b += naka or ['                    pass']
        b.append('                    _d = %r' % tsugi)
    b.append('                else:')
    b.append('                    _d = None')
    b.append('            except _Tobu as e:')
    b.append('                _d = e.saki')
    b.append('')
    return b


if __name__ == '__main__':
    src, out = sys.argv[1], sys.argv[2]
    honbun, d = kumu(src)
    pathlib.Path(out).write_text(honbun, encoding='utf-8')
    print('%s → %s  未変換 %d件' % (pathlib.Path(src).name, out, len(d.mikansei)))
    for gyo, k in d.mikansei[:10]:
        print('   %5d行  %s' % (gyo, k))
