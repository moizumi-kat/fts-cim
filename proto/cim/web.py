# -*- coding: utf-8 -*-
"""画面（Flask）。

画面遷移は、村上様提供の「営業日報照会の画面遷移図」と、実ソース
（NPJYU4CS／NPJYU5CS と JYUSYORI・SZUGAMEN・URIGAMEN・JHYSYORI・GENSYOR1・
 BUTSYOR1・SINSYORI・KETGAMEN）で裏取りしたとおりです。

  営業日報照会（CHK4S010）        拠点行 J/Z/U → 3つの一覧、一覧の製番行 J → 受注票照会
  営業日報（Ａ）照会（CHK5S010）  上に加えて 製番行 G（物件検討あり→検討物件／なし→実行予算）、
                                  S → 営業用工程進捗、K → 打合せ決定内容
                                  ※ K は出図一覧・売上一覧だけ（受注一覧には無い）
"""
import csv, io, datetime
from flask import (Flask, render_template, request, redirect, url_for, abort,
                   Response, make_response)
from . import repo, koutei, hearing, jikkou
from .db import connect

app = Flask(__name__)
# 値が無い項目は空欄で出す（現行の画面と同じ）。None と表示しない。
app.jinja_env.finalize = lambda v: '' if v is None else v

LIST_OPS  = {'J': 'JGS', 'Z': 'JGSK', 'U': 'JGSK'}   # 実ソースで確認した選択肢
LIST_TITLE= {'J': '日報内訳　受注一覧', 'Z': '日報内訳　出図一覧', 'U': '日報内訳　売上一覧'}
LIST_SEL  = {'J': 'J:受票', 'Z': 'J:受注票', 'U': 'J:受注票'}
OPLBL     = {'J': '受注票照会', 'G': '製番別実行予算集計／検討物件', 'S': '営業用工程進捗', 'K': '打合せ決定内容'}
NO = {'営業日報照会': 211, '営業日報（Ａ）照会': 212, '営業日報マスタ（目標）メンテナス': 210}


def _nav(cur=None, q=''):
    con = connect()
    try:
        done = hearing.done_set(con)
    finally:
        con.close()
    tree = koutei.tree()
    if q:
        ql = q.lower()
        t2 = []
        for d in tree:
            cs = []
            for c in d['chu']:
                its = [p for p in c['rows'] if ql in (p['nm'] + p['cl']).lower()]
                if its: cs.append({'nm': c['nm'], 'rows': its})
            if cs: t2.append({'nm': d['nm'], 'chu': cs})
        tree = t2
        n = sum(len(c['rows']) for d in tree for c in d['chu'])
        cnt = '%d / %d 工程' % (n, len(koutei.all()))
    else:
        cnt = '%d 工程' % len(koutei.all())
    return {'tree': tree, 'cnt': cnt, 'cur': cur, 'q': q, 'done': done}


@app.route('/')
def home():
    q = request.args.get('q', '').strip()
    return render_template('home.html', st=koutei.stats(), **_nav(None, q))


@app.route('/koutei/<int:no>')
def koutei_page(no):
    p = koutei.get(no)
    if not p: abort(404)
    return render_template('koutei.html', p=p, **_nav(no))


# ------------------------------- 工程を実データで動かす（2026-11-24）
@app.route('/tables/<name>')
def table_rows(name):
    """表の中身を見る（実データの確かめ用・2026-11-24）。

       列名は現行の項目名（英名）＋日本語の項目名を見出しに添える。
       読むだけ。並び順は表のとおり（rowid 順）。
    """
    from .schema_gen import TABLES
    from .db import q
    t = TABLES.get(name)
    if not t:
        abort(404)
    kazu = max(1, min(200, int(request.args.get('n', 50))))
    saki = max(0, int(request.args.get('p', 0)))
    con = connect()
    try:
        try:
            zen = q(con, 'SELECT COUNT(*) AS n FROM "%s"' % name)[0]['n']
        except Exception:
            zen = 0
        try:
            gyo = q(con, 'SELECT * FROM "%s" LIMIT %d OFFSET %d'
                    % (name, kazu, saki))
        except Exception as e:
            gyo = []
            zen = 0
    finally:
        con.close()
    cols = [{'nm': c[0], 'ja': c[2], 'pic': c[3]} for c in t['cols']]
    return render_template('table_rows.html', t=t, name=name, cols=cols,
                           gyo=[dict(r) for r in gyo], zen=zen,
                           kazu=kazu, saki=saki, **_nav())


@app.route('/ugokasu/<int:no>')
@app.route('/ugokasu/<int:no>/<pgm>')
def ugokasu_page(no, pgm=None):
    """工程が呼ぶプログラムを**実際に動かして**、画面定義どおりに見せる。

       書き込みは取り消す（ROLLBACK）。確かめるだけで現データを汚さない。
    """
    p = koutei.get(no)
    if not p:
        abort(404)
    if pgm is None and p.get('calls'):
        pgm = p['calls'][0]
    r = {'tomatta': None, 'gamen': [], 'kaita': {}}
    if pgm:
        if pgm not in (p.get('calls') or []):
            abort(404)              # 一覧にあるプログラムだけ動かす
        r = jikkou.ugokasu(pgm)
    return render_template('ugokasu.html', p=p, pgm=pgm, r=r, **_nav(no))


# ------------------------------------------------------------------ 営業日報
@app.route('/nippou')
def nippou():
    adv = request.args.get('a') == '1'
    con = connect()
    try:
        d = repo.nippou(con)
    finally:
        con.close()
    nm = '営業日報（Ａ）照会' if adv else '営業日報照会'
    return render_template('nippou.html', d=d, adv=adv,
                           cl='CHK5S010.CL' if adv else 'CHK4S010.CL',
                           no=NO[nm], **_nav(NO[nm]))


@app.route('/sel')
def sel():
    """日報の拠点行の「選」に入れた J／Z／U を受ける。"""
    op = (request.args.get('op') or '').upper()
    busyo = request.args.get('busyo', '')
    a = request.args.get('a', '0')
    if op not in ('J', 'Z', 'U'):
        return redirect('/nippou?a=%s' % a)
    return redirect('/list/%s/%s?a=%s' % (op, busyo, a))


@app.route('/list/<kind>/<busyo>')
def lst(kind, busyo):
    if kind not in LIST_OPS: abort(404)
    adv = request.args.get('a') == '1'
    con = connect()
    try:
        nm = repo.busyo_nm(con, busyo)
        if kind == 'J':
            d = repo.jutyu_list(con, busyo); any_ = any(b['rows'] for b in d['blocks'])
        elif kind == 'Z':
            d = repo.syutsuzu_list(con, busyo); any_ = bool(d['rows'])
        else:
            d = repo.uriage_list(con, busyo); any_ = bool(d['rows'])
    finally:
        con.close()
    ops = LIST_OPS[kind] if adv else 'J'
    help_ = '／'.join('%s（%s）' % (o, OPLBL[o]) for o in ops)
    kno = NO['営業日報（Ａ）照会' if adv else '営業日報照会']
    return render_template('list.html', kind=kind, d=d, adv=adv, busyo_cd=busyo, busyo_nm=nm,
                           title=LIST_TITLE[kind], sel_label=LIST_SEL[kind], ops=ops, oplbl=OPLBL,
                           ops_help=help_, rows_any=any_, **_nav(kno))


@app.route('/sel2')
def sel2():
    """一覧の製番行の「選」に入れた J／G／S／K を受ける。"""
    op = (request.args.get('op') or '').upper()
    seiban = request.args.get('seiban', '')
    kind = request.args.get('kind', 'J')
    busyo = request.args.get('busyo', '')
    a = request.args.get('a', '0')
    allowed = LIST_OPS.get(kind, 'J') if a == '1' else 'J'
    if op not in allowed:
        return redirect('/list/%s/%s?a=%s' % (kind, busyo, a))
    return redirect('/go/%s/%s?kind=%s&busyo=%s&a=%s' % (op, seiban, kind, busyo, a))


@app.route('/go/<op>/<seiban>')
def go(op, seiban):
    kind = request.args.get('kind', '')
    busyo = request.args.get('busyo', '')
    a = request.args.get('a', '0')
    adv = a == '1'
    back = '/list/%s/%s?a=%s' % (kind, busyo, a) if kind and busyo else ''
    kno = NO['営業日報（Ａ）照会' if adv else '営業日報照会']
    con = connect()
    try:
        info = repo.seiban_info(con, seiban)
        kenmei = info['kenmei'] if info else ''
        if op == 'J':
            d = repo.jutyuhyo(con, seiban)
            return render_template('jutyuhyo.html', d=d, seiban=seiban, back=back, adv=adv, **_nav(kno))
        if op == 'G':
            # COBOL と同じ判定：物件検討ファイルに該当製番があるか
            if repo.has_bukken(con, seiban):
                d = repo.bukken(con, seiban)
                return render_template('bukken.html', d=d, seiban=seiban, back=back, adv=adv, **_nav(kno))
            d = repo.yosan(con, seiban)
            return render_template('yosan.html', d=d, seiban=seiban, back=back, adv=adv,
                                   has_bukken=False, **_nav(kno))
        if op == 'S':
            d = repo.sinchoku(con, seiban)
            return render_template('sinchoku.html', d=d, seiban=seiban, kenmei=kenmei,
                                   back=back, adv=adv, **_nav(kno))
        if op == 'K':
            d = repo.uchiawase(con, seiban)
            return render_template('uchiawase.html', d=d, seiban=seiban, kenmei=kenmei,
                                   back=back, adv=adv, **_nav(kno))
    finally:
        con.close()
    abort(404)


@app.route('/jutyuhyo/<seiban>')
def jutyuhyo(seiban):
    adv = request.args.get('a') == '1'
    con = connect()
    try:
        d = repo.jutyuhyo(con, seiban)
    finally:
        con.close()
    kno = NO['営業日報（Ａ）照会' if adv else '営業日報照会']
    return render_template('jutyuhyo.html', d=d, seiban=seiban, back='', adv=adv, **_nav(kno))


# ------------------------------------------------------------------ 目標メンテ
@app.route('/mokuhyo', methods=['GET', 'POST'])
def mokuhyo():
    nendo = int(request.values.get('nendo') or 2026)
    saved = 0
    con = connect()
    try:
        if request.method == 'POST':
            pairs = []
            for cd in [r['cd'] for r in repo.mokuhyo_list(con, nendo)]:
                v = (request.form.get('g_' + cd) or '').replace(',', '').strip()
                if v:
                    pairs.append((cd, int(v)))
            saved = repo.mokuhyo_save(con, nendo, pairs)
        rows = repo.mokuhyo_list(con, nendo)
    finally:
        con.close()
    no = NO['営業日報マスタ（目標）メンテナス']
    return render_template('mokuhyo.html', rows=rows, nendo=nendo, saved=saved, no=no, **_nav(no))


# ------------------------------------------------------------------ 聞き取り
@app.route('/hearing')
def hearing_list():
    dai = request.args.get('dai', '')
    han = request.args.get('hantei', '')
    word = request.args.get('word', '')
    con = connect()
    try:
        sm = hearing.summary(con)
        rows = hearing.all_rows(con, dai, han, word)
    finally:
        con.close()
    dais = []
    for p in koutei.all():
        if p['dai'] not in dais: dais.append(p['dai'])
    return render_template('hearing_list.html', sm=sm, rows=rows, dai=dai, hantei=han, word=word,
                           dai_list=dais, hantei_list=hearing.HANTEI,
                           total=len(koutei.all()), **_nav(None))


@app.route('/hearing/<int:no>', methods=['GET', 'POST'])
def hearing_page(no):
    p = koutei.get(no)
    if not p: abort(404)
    qs = hearing.questions(p['kind'])
    saved = 0
    con = connect()
    try:
        if request.method == 'POST':
            pairs = []
            for i in range(len(qs)):
                s_ = request.form.get('q%d' % i, '')
                a_ = request.form.get('a%d' % i, '')
                if s_: pairs.append((s_, a_))
            saved = hearing.save(con, p,
                                 request.form.get('bumon', ''), request.form.get('hito', ''),
                                 request.form.get('kiki_bi', ''), pairs,
                                 request.form.get('hantei', ''), request.form.get('memo', ''))
        rows = hearing.by_koutei(con, no)
        bumons = [r['bumon'] for r in hearing.all_rows(con) if r['bumon']]
    finally:
        con.close()
    seen, blist = set(), []
    for b in bumons:
        if b not in seen: seen.add(b); blist.append(b)
    # 部署・お名前は、このブラウザで前に入れた値を初期値にする。
    # 共用サーバで何人も同時に使うため、他の人が入れた値を引っぱらない。
    last = {'bumon': request.cookies.get('cim_bumon', ''),
            'hito':  request.cookies.get('cim_hito', ''),
            'kiki_bi': ''}
    body = render_template('hearing.html', p=p, questions=qs, rows=rows, saved=saved,
                           last=last, bumon_list=blist, hantei_list=hearing.HANTEI,
                           today=datetime.date.today().isoformat(),
                           kensu=len(rows), **_nav(no))
    resp = make_response(body)
    if request.method == 'POST':
        for k, v in (('cim_bumon', request.form.get('bumon', '')),
                     ('cim_hito',  request.form.get('hito', ''))):
            if v: resp.set_cookie(k, v, max_age=60*60*24*90, samesite='Lax')
    return resp


@app.route('/hearing.csv')
def hearing_csv():
    con = connect()
    try:
        rows = hearing.all_rows(con, request.args.get('dai', ''),
                                request.args.get('hantei', ''), request.args.get('word', ''))
    finally:
        con.close()
    buf = io.StringIO()
    w = csv.writer(buf)
    w.writerow(['工程No','工程名','大分類','中分類','部署','お名前','聞いた日','設問','答え','判定','メモ','記録日時'])
    for r in rows:
        w.writerow([r['koutei_no'], r['koutei_nm'], r['dai'], r['chu'], r['bumon'], r['hito'],
                    r['kiki_bi'], r['shitsumon'], r['kotae'], r['hantei'], r['memo'], r['created']])
    # Excel でそのまま開けるよう BOM 付き
    data = '\ufeff' + buf.getvalue()
    return Response(data, mimetype='text/csv; charset=utf-8',
                    headers={'Content-Disposition': 'attachment; filename="hearing.csv"'})


@app.route('/tables')
def tables():
    """現行ファイルに合わせたテーブルの一覧（IT部門の確認用）。"""
    from .schema_gen import TABLES
    from .db import q
    con = connect()
    tabs = []
    try:
        for name, t in sorted(TABLES.items()):
            try:
                n = q(con, 'SELECT COUNT(*) AS n FROM %s' % name)[0]['n']
            except Exception:
                n = 0
            tabs.append({'name': name, 'nm': t['nm'], 'n': n,
                         'lib': t.get('lib', ''), 'ronri': '／'.join(t.get('ronri', [])),
                         'src': t.get('src', ''),
                         # 列名は現行の英名。日本語の項目名は見出し用に添えるだけ
                         'cols': [{'nm': cname, 'ty': ty, 'ja': ja, 'pic': pic,
                                   'pk': cname in t['pk']}
                                  for cname, ty, ja, pic in t['cols']]})
    finally:
        con.close()
    return render_template('tables.html', tabs=tabs,
                           ncol=sum(len(x['cols']) for x in tabs), **_nav(None))
