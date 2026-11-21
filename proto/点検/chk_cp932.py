# -*- coding: utf-8 -*-
"""Windows のコマンドプロンプト（cp932）で表示できない文字が混ざっていないか調べる。

    python 点検/chk_cp932.py

画面に出す文字が cp932 にないと、Windows では
    UnicodeEncodeError: 'cp932' codec can't encode character ...
で**その場で止まります**。手元（Linux／UTF-8）では起きないので気づけません。
ソースを機械的に調べて、使ってはいけない文字を洗い出します。
"""
import os, sys

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# 画面（コマンドプロンプト）に出るのは .py だけ。ここに出せない文字があると止まります。
MITARU  = ('.py',)
# 参考として見るだけのもの（ブラウザやエディタで見るので cp932 でなくても困りません）
SANKOU  = ('.md', '.html', '.css')
TOBASU  = ('__pycache__', 'vendor', '.git')

def main():
    warui, sanko_list, mita = [], [], 0
    for base, dirs, files in os.walk(HERE):
        dirs[:] = [d for d in dirs if d not in TOBASU]
        for f in sorted(files):
            if not f.endswith(MITARU + SANKOU): continue
            sankou = f.endswith(SANKOU)
            p = os.path.join(base, f)
            try:
                t = open(p, encoding='utf-8').read()
            except (UnicodeDecodeError, OSError):
                continue
            mita += 1
            for no, line in enumerate(t.splitlines(), 1):
                for ch in line:
                    try:
                        ch.encode('cp932')
                    except UnicodeEncodeError:
                        (sanko_list if sankou else warui).append(
                            (os.path.relpath(p, HERE), no, ch, line.strip()[:60]))
    if sanko_list:
        print('（参考）ブラウザ・エディタで見るファイルにある分 %d か所 … 画面は止まりません'
              % len(sanko_list))
        for p, no, ch, line in sanko_list[:5]:
            print('      %-26s %4d行  %r (U+%04X)' % (p, no, ch, ord(ch)))
        print()
    if not warui:
        print('画面に出す文字は、すべて cp932 で出せます。（%d ファイルを確認）' % mita)
        return 0
    print('■ cp932 で出せない文字が %d か所あります' % len(warui))
    for p, no, ch, line in warui[:40]:
        print('  %-28s %4d行  %r (U+%04X)  %s' % (p, no, ch, ord(ch), line))
    if len(warui) > 40:
        print('  …ほか %d か所' % (len(warui) - 40))
    return 1

if __name__ == '__main__':
    sys.exit(main())
