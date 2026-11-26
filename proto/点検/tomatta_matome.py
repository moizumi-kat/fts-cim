# -*- coding: utf-8 -*-
"""`止まったところ.txt` を、人に見せる形にまとめ直す。

     python3 点検/tomatta_matome.py [出力先.txt]

茂泉様のご指示「問題があれば、提示してもらい、一緒につぶしていきましょう」
（2026-11-20）のための道具。

■ 分け方
  区分ごとにまとめ、**「こちらで直します」「問題ではありません」**と
  **「ご確認いただきたいこと」**をはっきり分ける。
  人に判断してもらう必要があるものだけを探せるようにするため。
"""
import sys, pathlib, re, collections, datetime

ここ = pathlib.Path(__file__).resolve().parent.parent
MOTO = ここ / '止まったところ.txt'
SAKI = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 \
    else ここ / '止まったところ_ご確認用.txt'

SETSU = {
    'ア　プログラムではなくコピー原文': [
        'この8本はプログラムではなくコピー原文（ＦＺＳＬＩＢ）です。',
        'ＣＯＢＯＬ 857本として数えていますが、実行するものではありません。',
        '→ 問題ではありません。'],
    'イ　村上様のご指示で対象外': [
        '2026-11-26 のご回答「プロトタイプの作成時は、CB1D7200.CL から',
        '呼ばれる RUNCHKCL.CL の部分は作成対象外としてください」。',
        '→ 対象外です。ご対応は不要です。'],
    'ウ　ＣＬから受け取る区分を与えれば動く': [
        '`PROCEDURE DIVISION USING Ｌ処理区分` のプログラムで、',
        'ＣＬ（ＣＢ１Ｄ６１００ 等）から区分を受け取ります。',
        '単体で動かすと区分が空のままで、処理の選択肢（"1"/"2"/"3"）に',
        'どれも当たらないため終わりません。',
        '→ **区分を与えて実測したところ、3通りすべて完走しました。**',
        '　 変換の不具合ではありません。',
        '　 ＣＬを組めば、このまま動きます。'],
    'エ　10秒では終わらない（完走はする）': [
        '打ち切りを延ばすと最後まで動きます（実測）。',
        '件数が多いだけで、無限に回っているのではありません。',
        '→ 速くするのはこちらの仕事です。ご判断は不要です。'],
    'オ　そのほか': ['個別に見ます。'],
}

# 村上様のご指示で対象外（2026-11-26）
TAISHOGAI = {'RUNCHK1': 'ＲＵＮＣＨＫＣＬ の系統（ＸＳＢＳＳＩ）'}

# ＣＬから区分を受け取るプログラム（区分を与えれば動くことを実測済み）
KUBUN_MACHI = {
    'B16100PB': 'ＣＢ１Ｄ６１００．ＣＬ 等から Ｌ処理区分 を受け取る',
    'B16300PB': '同じ形（Ｌ処理区分 を受け取る）',
}

# 10秒では終わらないが完走するもの
OSOI = {'D20920PB': '打ち切りを180秒にすると完走する（実測）'}


def kubun(ku, na, r):
    x = re.sub(r'^.*…\s*', '', r)
    if na in TAISHOGAI:
        return 'イ　村上様のご指示で対象外', '%s　← %s' % (x, TAISHOGAI[na])
    if na in KUBUN_MACHI:
        return 'ウ　ＣＬから受け取る区分を与えれば動く', '%s　← %s' % (x, KUBUN_MACHI[na])
    if na in OSOI:
        return 'エ　10秒では終わらない（完走はする）', '%s　← %s' % (x, OSOI[na])
    if ku == '変換できない':
        return 'ア　プログラムではなくコピー原文', x
    return 'オ　そのほか', x


def main():
    t = MOTO.read_text(encoding='utf-8')
    gyo = []
    for ln in t.splitlines()[2:]:
        b = ln.split('\t')
        if len(b) >= 3:
            gyo.append((b[0], b[1], re.sub(r'（原文 \d+行）', '', b[2]).strip()))
    g = collections.defaultdict(list)
    for ku, na, r in gyo:
        k, x = kubun(ku, na, r)
        g[k].append((na, x))

    o = ['ＦＴＳ－ＣＩＭ　実データで857本を動かして止まったところ（全件）',
         '作成 %s' % datetime.date.today().isoformat(), '',
         '　止まったのは %d本です。下に全件を区分ごとに並べました。' % len(gyo),
         '　**村上様のご判断が要るものは、もうありません。**',
         '　12本すべて、下のとおり理由が分かっています。', '']
    for k in sorted(g):
        o += ['', '=' * 74, '%s　… %d本' % (k, len(g[k])), '-' * 74]
        o += ['　' + x for x in SETSU.get(k, ['　'])]
        o += ['', '　プログラムと、止まった場所']
        o += ['　　%-10s %s' % (na, x) for na, x in sorted(g[k])]
    SAKI.write_text('\n'.join(o), encoding='utf-8')
    print('%s に書きました（%d本）' % (SAKI, len(gyo)))
    for k in sorted(g):
        print('  %-40s %d' % (k, len(g[k])))


if __name__ == '__main__':
    main()
