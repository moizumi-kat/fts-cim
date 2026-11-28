# -*- coding: utf-8 -*-
"""現場での聞き取り（ヒアリング）。

画面を見せながら、その場で答えを記録するための仕組みです。
設問は工程の種別（帳票／照会／登録・更新／処理・運用）ごとに用意してあります。
あとから一覧・CSVで取り出せます。
"""
import datetime
from .db import q, q1

# 全工程で必ず聞くこと
KYOTSU = [
 'いまも使っていますか（使っている／たまに／使っていない／知らない）',
 '使うのはどなたですか（部署・担当）',
 'どのくらいの頻度ですか（毎日／週／月／年／随時）',
 'これが無いと何が困りますか',
 '新システムでは、こう変えたいということはありますか',
]
# 種別ごとに追加で聞くこと
BETSU = {
 '帳票': [
   '紙で必要ですか（紙／PDF／Excel／画面で足りる）',
   '何部つくって、どなたに渡しますか',
   '出てくる項目で、要らないもの・足りないものはありますか',
   '出力したあと、手で直したり書き足したりしていることはありますか',
   '保存・保管の決まりはありますか（年数・綴じ方）',
 ],
 '照会': [
   'どの条件で探しますか（製番／件名／得意先／期間／担当…）',
   '1画面に何件くらい、どの順番で出てほしいですか',
   'この画面から、次にどの画面へ行きたいですか',
   '見た内容をExcelなどに持ち出したいことはありますか',
 ],
 '登録・更新': [
   '入力の元になる紙やデータは何ですか',
   '入力するのはどなたで、いつ入れますか',
   '間違えやすい項目はどれですか。システムで止めてほしいチェックはありますか',
   '他の人の入力待ちになることはありますか',
   'あとから直すことはよくありますか（訂正・取消の流れ）',
 ],
 '処理': [
   'いつ動かしますか（締め・夜間・随時）',
   '失敗したときはどうしていますか',
   '自動で動かしてよい処理ですか',
   '動かす前後で、人がやっている確認はありますか',
 ],
 '運用': [
   'いつ動かしますか（締め・夜間・随時）',
   '失敗したときはどうしていますか',
   '自動で動かしてよい処理ですか',
   'バックアップ・退避の決まりはありますか',
 ],
}
HANTEI = ['', '残す（そのまま）', '残す（変える）', 'やめる', '保留・要相談']

def questions(kind):
    return KYOTSU + BETSU.get(kind, [])

def save(con, p, bumon, hito, kiki_bi, pairs, hantei, memo):
    """pairs = [(設問, 回答), ...]。回答が空のものは残さない。"""
    now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M')
    n = 0
    rows = [(s, k) for s, k in pairs if (k or '').strip()]
    if not rows and not (memo or '').strip() and not hantei:
        return 0
    if not rows:
        rows = [('（自由メモのみ）', '')]
    for s, k in rows:
        con.execute("""INSERT INTO Z_HEARING(koutei_no,koutei_nm,dai,chu,bumon,hito,kiki_bi,
                       shitsumon,kotae,hantei,memo,created) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)""",
                    (p['no'], p['nm'], p['dai'], p['chu'], bumon, hito, kiki_bi,
                     s, k, hantei, memo, now))
        n += 1
    con.commit()
    return n

def by_koutei(con, no):
    return q(con, 'SELECT * FROM Z_HEARING WHERE koutei_no=? ORDER BY id DESC', (no,))

def all_rows(con, dai='', hantei='', word=''):
    sql = 'SELECT * FROM Z_HEARING WHERE 1=1'
    a = []
    if dai:    sql += ' AND dai=?';    a.append(dai)
    if hantei: sql += ' AND hantei=?'; a.append(hantei)
    if word:
        sql += ' AND (koutei_nm LIKE ? OR kotae LIKE ? OR memo LIKE ? OR hito LIKE ?)'
        a += ['%%%s%%' % word] * 4
    sql += ' ORDER BY koutei_no, id'
    return q(con, sql, tuple(a))

def summary(con):
    """工程ごとの件数と判定。進み具合を見るため。"""
    return q(con, """SELECT koutei_no, koutei_nm, dai, chu,
                            COUNT(*) AS ken,
                            MAX(kiki_bi) AS saishu,
                            MAX(hantei)  AS hantei
                       FROM Z_HEARING GROUP BY koutei_no, koutei_nm, dai, chu
                      ORDER BY koutei_no""")

def done_set(con):
    return {r['koutei_no'] for r in q(con, 'SELECT DISTINCT koutei_no FROM Z_HEARING')}
