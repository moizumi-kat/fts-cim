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
    'ア　ＧＯ ＴＯ の飛び先が節の外': [
        'ＣＯＢＯＬ は節をまたいで ＧＯ ＴＯ できます。写し方を直します。',
        '→ こちらで直します。ご判断は不要です。'],
    'イ　ＲＥＡＤ の先が見つからない': [
        '作業ファイル（ＣＬが実行前に作るもの）か、まだ手元に無いファイルです。',
        '→ 村上様へ「一時ファイルかどうか」をお尋ね中です。'],
    'ウ　書き先が見つからない': [
        'プログラム間の受け渡し用レコードです。イと同じ扱いになります。'],
    'エ　項目の名前が取れていない': [
        '画面定義体から名前が取れなかった項目です。',
        '→ こちらで直します（定義体の構造表をさらに読みます）。'],
    'オ　ＰＥＲＦＯＲＭ 〜 ＴＨＲＵ 〜 の飛び先が無い': [
        '飛び先の段落・節が、その原文の中に見当たりません。',
        '→ まず原文を読み直します。'],
    'カ　外部プログラムの呼び出し': [
        'Ｘ１００１０ＰＸ・ＸＳＢＳＳＩ は原文が手元にありません。',
        '→ 村上様へ「何をする部品か」をお尋ね中です。'],
    'キ　10秒で終わらない（入力待ち）': [
        '画面を出して入力を待つ作りです。試作画面では「画面が1枚出たところで',
        '止める」ようにしてあります。',
        '→ 問題ではありません。'],
    'ク　原文に ＰＲＯＣＥＤＵＲＥ ＤＩＶＩＳＩＯＮ が無い': [
        'この8本はプログラムではなくコピー原文（ＦＺＳＬＩＢ）です。',
        '→ 問題ではありません。'],
    'ケ　そのほか': ['個別に見ます。'],
}


def kubun(ku, r):
    x = re.sub(r'^.*…\s*', '', r)
    if ku == '_Tobu':
        return 'ア　ＧＯ ＴＯ の飛び先が節の外', x
    if ku == '時間切れ':
        return 'キ　10秒で終わらない（入力待ち）', x
    if ku == '変換できない':
        return 'ク　原文に ＰＲＯＣＥＤＵＲＥ ＤＩＶＩＳＩＯＮ が無い', x
    if re.match(r'^READ .*表が無い', x):
        return 'イ　ＲＥＡＤ の先が見つからない', x
    if re.match(r'^(WRITE|REWRITE|START|DELETE) .*表が無い', x):
        return 'ウ　書き先が見つからない', x
    if x.startswith('知らない項目'):
        return 'エ　項目の名前が取れていない', x
    if x.startswith('PERFORM'):
        return 'オ　ＰＥＲＦＯＲＭ 〜 ＴＨＲＵ 〜 の飛び先が無い', x
    if x.startswith('CALL'):
        return 'カ　外部プログラムの呼び出し', x
    return 'ケ　そのほか', x


def main():
    t = MOTO.read_text(encoding='utf-8')
    gyo = []
    for ln in t.splitlines()[2:]:
        b = ln.split('\t')
        if len(b) >= 3:
            gyo.append((b[0], b[1], re.sub(r'（原文 \d+行）', '', b[2]).strip()))
    g = collections.defaultdict(list)
    for ku, na, r in gyo:
        k, x = kubun(ku, r)
        g[k].append((na, x))

    o = ['ＦＴＳ－ＣＩＭ　実データで857本を動かして止まったところ（全件）',
         '作成 %s' % datetime.date.today().isoformat(), '',
         '　止まったのは %d本です。下に全件を区分ごとに並べました。' % len(gyo),
         '　「→ こちらで直します」「→ 問題ではありません」はご判断不要です。', '']
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
