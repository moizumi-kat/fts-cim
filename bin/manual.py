# -*- coding: utf-8 -*-
"""オフコン（ASP V29）のマニュアルを引く。

     python3 bin/manual.py <マニュアルの置き場> 目録
     python3 bin/manual.py <マニュアルの置き場> 探す <ことば> [冊のディレクトリ名 …]
     python3 bin/manual.py <マニュアルの置き場> 読む <html のパス>

  ■ これは何か（村上様ご提供 2026-11-12）
     富士通 ASP V29 のオンラインマニュアル一式（HTML）。
     **ＣＬの文法・ＣＯＢＯＬの文法・コマンドは、推測せずここを引く。**
     105冊・HTML 13,673ページ・PDF 114冊。文字コードは cp932。

  ■ よく使う冊
     cobolg_bunpou   ＣＯＢＯＬ Ｇ文法書
     cobolg_siyou    ＣＯＢＯＬ Ｇ使用手引書
     command         コマンド関係
     cmd_kaisetsu    コマンド解説
"""
import sys, pathlib, re, html as _html

HTML = re.compile(r'<[^>]+>')
TITLE = re.compile(r'<title>(.*?)</title>', re.S | re.I)


CHARSET = re.compile(rb'charset\s*=\s*["\']?([\w-]+)', re.I)


def _yomu(p):
    """ページを読む。**冊によって文字コードが違う**（cp932 と UTF-8 が混在）。
       meta の charset を見て決める。無ければ cp932 → UTF-8 の順に試す。"""
    b = p.read_bytes()
    m = CHARSET.search(b[:2048])
    if m:
        na = m.group(1).decode('ascii', 'replace').lower()
        na = {'shift_jis': 'cp932', 'shift-jis': 'cp932', 'sjis': 'cp932',
              'x-sjis': 'cp932', 'utf-8': 'utf-8', 'utf8': 'utf-8'}.get(na, na)
        try:
            return b.decode(na)
        except (LookupError, UnicodeDecodeError):
            pass
    for na in ('cp932', 'utf-8'):
        try:
            return b.decode(na)
        except UnicodeDecodeError:
            continue
    return b.decode('cp932', 'replace')


def _honbun(t):
    """タグを落として本文だけにする。"""
    t = re.sub(r'(?is)<(script|style).*?</\1>', ' ', t)
    t = HTML.sub(' ', t)
    t = _html.unescape(t)
    return re.sub(r'[ \t　]+', ' ', t)


def mokuroku(ne):
    """冊の一覧（ディレクトリ名 → 書名）。"""
    out = []
    for d in sorted(p for p in ne.iterdir() if p.is_dir()):
        na = ''
        for f in ('index.html', 'cover.html', 'index.htm'):
            q = d / f
            if q.exists():
                m = TITLE.search(_yomu(q))
                if m:
                    na = _honbun(m.group(1)).strip()
                    break
        kazu = sum(1 for _ in d.rglob('*.htm*'))
        out.append((d.name, na, kazu))
    return out


def sagasu(ne, go, satsu=None, kazu=40, mae=60, ato=90):
    """全文から探す。見つかった所の前後を返す。"""
    atari = []
    moto = [ne / s for s in satsu] if satsu else [ne]
    for base in moto:
        for p in sorted(base.rglob('*.htm*')):
            t = _yomu(p)
            h = _honbun(t)
            for m in re.finditer(re.escape(go), h):
                a, b = max(0, m.start() - mae), m.end() + ato
                atari.append((p.relative_to(ne), h[a:b].strip()))
                if len(atari) >= kazu:
                    return atari
    return atari


if __name__ == '__main__':
    ne = pathlib.Path(sys.argv[1])
    shigoto = sys.argv[2]
    if shigoto == '目録':
        r = mokuroku(ne)
        print('■ %d冊' % len(r))
        for d, na, k in r:
            print('   %-18s %5dページ  %s' % (d, k, na))
    elif shigoto == '探す':
        go = sys.argv[3]
        satsu = sys.argv[4:] or None
        r = sagasu(ne, go, satsu)
        print('■ 「%s」 %d件%s' % (go, len(r), ('（%s の中）' % '／'.join(satsu)) if satsu else ''))
        for p, s in r:
            print('   %-34s %s' % (p, s.replace('\n', ' ')[:150]))
    elif shigoto == '読む':
        print(_honbun(_yomu(ne / sys.argv[3])))
    else:
        sys.exit(__doc__)
