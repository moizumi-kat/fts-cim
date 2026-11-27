# -*- coding: utf-8 -*-
"""ＣＬ（ＦＡＣＡＭ ＣＬ）を読んで、文の並びにする。

     python3 -I bin/cl_parse.py <ＣＬのファイル>      # 読めたものを見る

■ ＣＬの形（実測・588本／マニュアル「システム開発手引書」）
    PGM                            プログラムの始まり
    PARA   ?A,STRING*6              呼ばれるときに受け取る変数
    VAR    ?VLD1,STRING*3,VALUE-'101'   変数の宣言（初期値つき）
    STEP1:                          ラベル（飛び先）
    CALL   A10020PB,(?VLD1)         プログラムを呼ぶ（引数つき）
    OVRF   FILE-AREGFS,TOFILE-SENGFS   ファイルの差し替え
    IF     ?A = '1' THEN            条件。THEN の後ろに続く
       …
    ELSE
       …
    END
    CASE   ?A
    WHEN   '1'
       …
    END
    GOTO   OWARI
    RETURN PGMEC-@PGMEC

  ・注釈は `/.` 〜 `./` で行をまたぐ（`cl_honbun` が潰す）。
  ・命令の引数は `キーワード-値` をカンマで並べる。順番だけの引数もある。
  ・`*` で始まる行も注釈（1行）。
"""
import sys, re, pathlib

ここ = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ここ))
import cl_honbun

RABERU = re.compile(r'^([A-Z@#$][A-Z0-9@#$_-]*)\s*:\s*(.*)$', re.I)
MEIREI = re.compile(r'^([A-Z@#$][A-Z0-9@#$_-]*)\s*(.*)$', re.I)
CASEJI = re.compile(r'^#([^#]*)#\s*(.*)$')
DAINYU = re.compile(r'^(\??[A-Z0-9@#$_-]+(?:\([^)]*\))?)\s*:=\s*(.*)$', re.I)


def _hikisu(s):
    """`FILE-A,TOFILE-B` や `A10020PB,(?V1,?V2)` を分ける。

       引用符の中とかっこの中のカンマでは切らない。
    """
    out, ima, fukasa, naka = [], '', 0, None
    for c in s:
        if naka:
            ima += c
            if c == naka:
                naka = None
            continue
        if c in "'\"":
            naka = c; ima += c; continue
        if c == '(':
            fukasa += 1; ima += c; continue
        if c == ')':
            fukasa -= 1; ima += c; continue
        if c == ',' and fukasa == 0:
            out.append(ima.strip()); ima = ''; continue
        ima += c
    if ima.strip():
        out.append(ima.strip())
    return out


def _kiiwaado(x):
    """`FILE-AREGFS` → ('FILE', 'AREGFS')。`-` が無ければ ('', x)。

       値のほうに `-` が入ることがある（`DA-01-S-A1WK10TM`）ので、
       **最初の `-` だけ**で切る。キーワードは英数字のみ。
    """
    m = re.match(r'^([A-Z][A-Z0-9]*)-(.*)$', x, re.I)
    if m:
        return m.group(1).upper(), m.group(2)
    return '', x


def tsunagu(hon):
    """行をつなぐ。ＣＬは**1つの文が何行にもわたる**（実測）。

       ■ つなぐ目印（588本を数えて決めた）
         ・前の行が `,` か `&&` で終わる     … 引数・式の続き
             SNDMSG MSG-?MSG2,
                    NPROMPT-@YES
         ・次の行が `&&` か `,` で始まる     … 式の続き
             ?MSG2 := ?CLID && ' '
                      && @JOBDATE
         ・前の行が `THEN` で終わらない `IF` … 条件の続き
       つながないと、`NPROMPT-` や `&& @JOBDATE` を**命令の名前**として
       数えてしまい、13,605行が「読めない行」になっていた。
    """
    out = []
    for no, ln in enumerate(hon.splitlines(), 1):
        s = ln.replace('\x1a', '').strip()
        if not s or s.startswith('*'):
            continue
        if out:
            mae = out[-1][1]
            if (mae.endswith((',', '&&', '+', '-', '*', '/', ':=', '='))
                    or s.startswith(('&&', ',', '+', '*', '/'))
                    or (re.match(r'^IF\b', mae, re.I)
                        and not re.search(r'\bTHEN\b', mae, re.I))):
                out[-1] = (out[-1][0], mae + ' ' + s)
                continue
        out.append((no, s))
    return out


def yomu(michi):
    """ＣＬ 1本 → [{'shu':種類, …}]。種類は raberu／meirei／if／else／end …"""
    t = pathlib.Path(michi).read_text(encoding='utf-8', errors='replace')
    hon = cl_honbun.honbun(t)
    bun = []
    for no, s in tsunagu(hon):
        # ラベルは行の先頭。`STEP1:  CALL …` と続くこともある
        m = RABERU.match(s)
        if m:
            bun.append({'shu': 'raberu', 'na': m.group(1).upper(), 'gyo': no})
            s = m.group(2).strip()
            if not s:
                continue
        # ＣＡＳＥ の値ラベル `#4091#`（戻りコードの分岐）
        #   CASE @PGMEC OF
        #       #4091#  ?MSG1 := …
        #   命令の名前として数えていたため、92本のＣＬで
        #   「知らない命令」になっていた（2026-11-27 実測）。
        mm = CASEJI.match(s)
        if mm:
            bun.append({'shu': 'caseji', 'atai': mm.group(1), 'gyo': no})
            s = mm.group(2).strip()
            if not s:
                continue
        # 代入 `?A := 式`（ＣＬの代入文）
        mm = DAINYU.match(s)
        if mm:
            bun.append({'shu': 'dainyu', 'saki': mm.group(1),
                        'shiki': mm.group(2).strip(), 'gyo': no})
            continue
        m = MEIREI.match(s)
        if not m:
            bun.append({'shu': 'fumei', 'moji': s, 'gyo': no})
            continue
        meirei = m.group(1).upper()
        ato = m.group(2).strip()
        if meirei == 'IF':
            # `IF 条件 THEN` の THEN は後ろ。THEN の後ろに文が続くこともある
            mm = re.match(r'^(.*?)\bTHEN\b(.*)$', ato, re.I)
            joken, tsuzuki = (mm.group(1).strip(), mm.group(2).strip()) \
                if mm else (ato, '')
            bun.append({'shu': 'if', 'joken': joken, 'gyo': no})
            if tsuzuki:
                bun.extend(yomu_moji(tsuzuki, no))
            continue
        if meirei in ('ELSE', 'END', 'ENDCASE'):
            bun.append({'shu': meirei.lower(), 'gyo': no})
            continue
        if meirei in ('CASE', 'WHEN', 'GOTO', 'RETURN'):
            if meirei == 'CASE':
                ato = re.sub(r'\s+OF\s*$', '', ato, flags=re.I)
            bun.append({'shu': meirei.lower(), 'ato': ato, 'gyo': no})
            continue
        hiki = _hikisu(ato)
        bun.append({'shu': 'meirei', 'na': meirei, 'hiki': hiki,
                    'kw': dict(_kiiwaado(x) for x in hiki), 'gyo': no})
    return bun


def yomu_moji(s, no=0):
    """1行ぶんの文字列を文にする（THEN の後ろなど）。

       `IF ?A = '1' THEN ?EIGCD := '03'` のように、THEN の後ろに
       **代入文**が来ることがある。ここで代入を見ていなかったので
       288行が「読めない行」になっていた（2026-11-27 実測）。
    """
    s = s.strip()
    mm = DAINYU.match(s)
    if mm:
        return [{'shu': 'dainyu', 'saki': mm.group(1),
                 'shiki': mm.group(2).strip(), 'gyo': no}]
    m = MEIREI.match(s)
    if not m:
        return [{'shu': 'fumei', 'moji': s, 'gyo': no}]
    meirei, ato = m.group(1).upper(), m.group(2).strip()
    if meirei in ('GOTO', 'RETURN', 'CASE', 'WHEN'):
        return [{'shu': meirei.lower(), 'ato': ato, 'gyo': no}]
    if meirei in ('ELSE', 'END', 'ENDCASE'):
        return [{'shu': meirei.lower(), 'gyo': no}]
    hiki = _hikisu(ato)
    return [{'shu': 'meirei', 'na': meirei, 'hiki': hiki,
             'kw': dict(_kiiwaado(x) for x in hiki), 'gyo': no}]


if __name__ == '__main__':
    for b in yomu(sys.argv[1]):
        print(b)
