# -*- coding: utf-8 -*-
"""確認結果を1つのテキストにまとめて保存する。

   python report.py          →  確認結果.txt を作る

接続確認（dbcheck.py）と、数字の照合（verify.py）をまとめて実行し、
その表示をそのままファイルに落とします。
このファイルをそのままお送りいただければ、こちらで確認できます。
パスワードは伏せ字にして出力します。
"""
import io, os, sys, subprocess, datetime

# Windows のコマンドプロンプトは cp932 です。万一そこに無い文字を出そうとしても
# 途中で止まらないようにします（止まると作業がそこで終わってしまうため）。
try:
    sys.stdout.reconfigure(errors='replace')
    sys.stderr.reconfigure(errors='replace')
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '確認結果.txt')

def run(title, args):
    buf = ['', '=' * 64, '■ %s' % title, '=' * 64]
    try:
        p = subprocess.run([sys.executable] + args, cwd=HERE,
                           capture_output=True, timeout=300)
        enc = 'cp932' if os.name == 'nt' else 'utf-8'
        for raw in (p.stdout, p.stderr):
            t = raw.decode(enc, errors='replace').replace('\r\n', '\n')
            if t.strip(): buf.append(t.rstrip())
        buf.append('(終了コード %d)' % p.returncode)
        ok = (p.returncode == 0)
    except Exception as e:
        buf.append('実行できませんでした: %s' % e); ok = False
    return '\n'.join(buf), ok

def main():
    import platform
    head = ['FTS-CIM  確認結果',
            '作成日時 : %s' % datetime.datetime.now().strftime('%Y-%m-%d %H:%M'),
            'コンピュータ名 : %s' % platform.node(),
            'Python : %s' % platform.python_version(),
            'OS : %s' % platform.platform(),
            '',
            '※ この内容をそのままお送りください（パスワードは伏せ字にしてあります）。']
    parts = [ '\n'.join(head) ]
    a, ok1 = run('接続確認（dbcheck.py）', ['dbcheck.py'])
    parts.append(a)
    b, ok2 = run('数字の照合（verify.py）', ['verify.py'])
    parts.append(b)
    c, ok3 = run('桁の点検（点検/chk_len.py）', [os.path.join('点検', 'chk_len.py')])
    parts.append(c)
    d, ok4 = run('画面に出す文字の点検（点検/chk_cp932.py）',
                 [os.path.join('点検', 'chk_cp932.py')])
    parts.append(d)
    parts.append('')
    parts.append('=' * 64)
    parts.append('まとめ : 接続 %s ／ 数字の照合 %s ／ 桁 %s ／ 文字 %s'
                 % ('OK' if ok1 else 'NG', 'OK' if ok2 else 'NG',
                    'OK' if ok3 else 'NG', 'OK' if ok4 else 'NG'))
    parts.append('=' * 64)
    text = '\n'.join(parts) + '\n'
    enc = 'cp932' if os.name == 'nt' else 'utf-8'
    with open(OUT, 'w', encoding=enc, errors='replace', newline='\r\n') as f:
        f.write(text)
    print(text)
    print('\n→ %s に保存しました。このファイルをお送りください。' % OUT)

if __name__ == '__main__':
    main()
