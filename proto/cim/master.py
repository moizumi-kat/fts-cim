# -*- coding: utf-8 -*-
"""マスタメンテ・マスタ一覧（原文が無く、ＣＡＳＥＴ仕様書から起こした分）。

 ■ なぜここにあるか
   村上様のご回答（2026-11-28）
     「上記は全て以前に提供したCASET仕様書をもとに作成してください。」
   ＣＯＢＯＬ の原文が無い１１２本のうち、**Ｍ系（マスタ管理サブシステム）**を
   ＣＡＳＥＴ仕様書（2026-11-20 受領・208本のＰＤＦ）から作る。

 ■ 仕様書を読んで分かったこと（実測・M10100KO／M20020KO／M30610KO ほか）
   ＣＡＳＥＴ のマスタメンテは**全て同じ形**をしている。

     処理区分   1=登録  2=修正  3=削除  4=複写
     チェック   ＥＲＲ００４  入力必須
                ＥＲＲ００１  コード外（処理区分が1〜4以外）
                ＥＲＲ００２  登録・複写のとき、既に存在してはいけない
                ＥＲＲ００３  修正・削除のとき、存在すること
     更新       マスタ本体へ反映し、**履歴ファイルへ1件記録**する
                （M20020KO の例：作業マスタ＋作業マスタ履歴ファイル）
     共通項目   作成日・更新日・更新時間・端末ＩＤ を持つ

   違うのは「どのマスタか」だけ。そこで、プログラムを1本ずつ写すのではなく
   **表定義（定義体から起こした列名・見出し・ＰＫ・繰返し）を使った共通処理**
   にしている。
   ＝ 茂泉様のご方針「同じ結果が出せれば、コードの効率化や近代化は図って下さい」
     「画面は必要なデータ項目さえ表示されれば良い」に沿った作り。

 ■ 安全側
   ・ＰＫ・必須・桁は**定義体が正**。ここで考えた値は1つも無い。
   ・仕様書で読み切れないチェックは**足さない**（勝手な判断をしない）。
   ・書き込みは必ず1件ずつ、履歴を残す。
"""
import re

from . import db
from .schema_gen import TABLES

# ---------------------------------------------------------------- 工程→マスタの対応
#   出典：ＣＡＳＥＴ仕様書「プログラム概要定義」の資源種一覧（アクセス名）。
#   論理ファイル名（…Ｌ１）は物理ファイル1本に対応する（db.py の ronri）。
#   rireki が None のものは、仕様書に履歴ファイルの記載が無いもの。
MASTER = {
 342: dict(pgm='M10020KO', nm='名称マスタメンテ',          hyo='ANAMMP', rireki='ARNAJP'),
 343: dict(pgm='M10040KO', nm='組織マスタメンテ',          hyo='ASOSMP', rireki='ARSOJP'),
 344: dict(pgm='M10050KP', nm='組織マスタ一覧出力',        hyo='ASOSMP', ichiran=True),
 346: dict(pgm='M10080KO', nm='部品マスタメンテ',          hyo='ABUHMP', rireki='ARBHJP'),
 347: dict(pgm='M10090KP', nm='部品マスタ一覧出力',        hyo='ABUHMP', ichiran=True),
 348: dict(pgm='M10100KO', nm='セットマスタメンテ',        hyo='ASETMP', rireki='ARSTJP'),
 349: dict(pgm='M10110KP', nm='セットマスタ一覧出力',      hyo='ASETMP', ichiran=True),
 350: dict(pgm='M10120KO', nm='掛率マスタメンテ',          hyo='AKAKMP', rireki='ARKAJP'),
 351: dict(pgm='M10140KO', nm='仕様マスタメンテ',          hyo='ASIYMP', rireki='ARSYJP'),
 352: dict(pgm='M10160KO', nm='寸法マスタメンテ',          hyo='ASUNMP', rireki='ARSNJP'),
 353: dict(pgm='M10200KO', nm='鈑金塗装価格マスタメンテ',  hyo='ABANMP', rireki='ARABJP'),
 365: dict(pgm='M10180KO', nm='凾体中分類マスタメンテ',    hyo='ATYUMP', rireki='ARTYJP'),
 366: dict(pgm='M10190KP', nm='凾体中分類マスタ一覧出力',  hyo='ATYUMP', ichiran=True),
 367: dict(pgm='M20010KO', nm='製品区分マスタメンテ',      hyo='CSHKMP', rireki='CRSEJP'),
 368: dict(pgm='M20020KO', nm='作業マスタメンテ',          hyo='CSAGMP', rireki='CRSAJP'),
 369: dict(pgm='M20030KO', nm='ユニット構成マスタメンテ',  hyo='CUNIMP', rireki=None),
 372: dict(pgm='M20060KO', nm='工程単価マスタメンテ',      hyo='CKOTMP', rireki=None),
 373: dict(pgm='M20070KP', nm='製品区分マスタ一覧出力',    hyo='CSHKMP', ichiran=True),
 374: dict(pgm='M20080KP', nm='作業マスタ一覧出力',        hyo='CSAGMP', ichiran=True),
 375: dict(pgm='M20090KP', nm='ユニット構成マスタ一覧出力',hyo='CUNIMP', ichiran=True),
 376: dict(pgm='M20100KP', nm='工程単価マスタ一覧出力',    hyo='CKOTMP', ichiran=True),
 395: dict(pgm='M30610KO', nm='品名値引テーブルメンテ',    hyo='FHNEMP', rireki=None, fukusha=False),
 400: dict(pgm='M10220KO', nm='予算マスタメンテ',          hyo='AYOSMP', rireki='ARYSJP'),
 401: dict(pgm='M10230KP', nm='予算マスタ一覧出力',        hyo='AYOSMP', ichiran=True),
 402: dict(pgm='M11010KO', nm='運用条件マスタメンテ',      hyo='AJKNMP', rireki=None),
}

# ---------------------------------------------------------------- キーの補い
#   ＰＫは**レプリケーション先のＤＤＬ（村上様ご提供）が正**で、db.py の
#   TABLES['…']['pk'] に入っている。
#   レプリケーションしていない表はＤＤＬが無いためＰＫが空になる。定義体
#   （.SMB）にもキーの記載は無い（実測）。
#   そこで**実データで一意になる組み合わせ**を使う。根拠を必ず書き残す。
#
#   ＣＫＯＴＭＰ（工程単価マスタ・176件）
#     仕様書 M20060KO「画面項目仕様」はアクセスＫＥＹを3項目として書いて
#     いるが、3項目のどの組み合わせでも実データが一意にならない
#     （作業＋係＋大中分類＝140件／176件）。
#     重複は**部所コード違い**（例 作業2000・係00・分類11 が 部所81＝単価8900、
#     部所83＝単価5310）で、単価が異なる別レコードだった。
#     → 大中分類＋作業＋部所＋係 の4項目で176件＝一意。これを使う。
#     ★村上様への確認事項（キーに部所コードを含めてよいか）
KAGI_OGINAI = {
 'CKOTMP': ['BUNRUI', 'WORKCD', 'BSYOCD', 'KKRICD'],
}

YOKAKUNIN = {
 'CKOTMP': '工程単価マスタのキーは仕様書では3項目だが、実データは部所コードを'
           '含めた4項目で一意。部所コードを含める扱いで良いか村上様へ確認中。',
}

KUBUN = {'1': '登録', '2': '修正', '3': '削除', '4': '複写'}

ERR = {
 'ERR001': '処理区分は 1(登録) 2(修正) 3(削除) 4(複写) のいずれかで入力してください',
 'ERR002': '既に登録されています',
 'ERR003': '登録されていません',
 'ERR004': '入力してください',
}

# 共通項目（ＣＡＳＥＴのマスタが必ず持つもの）。画面では編集させず、こちらで入れる。
KYOTU = ('CRTDAY', 'CRTDAT', 'CRTTIM', 'UPDDAY', 'UPDDAT', 'UPDTIM', 'WSID', 'SYORBI')


def aru(no):
    return no in MASTER


def joho(no):
    """工程の定義（表・ＰＫ・列・見出し）をまとめて返す。"""
    m = MASTER.get(no)
    if not m:
        return None
    t = TABLES.get(m['hyo'])
    if not t:
        return None
    d = dict(m)
    d['no'] = no
    d['hyo_nm'] = t.get('nm') or m['hyo']
    d['pk'] = list(t.get('pk') or []) or list(KAGI_OGINAI.get(m['hyo'], []))
    d['kagi_moto'] = 'ＤＤＬ' if (t.get('pk') or []) else ('実データ（要確認）' if m['hyo'] in KAGI_OGINAI else 'なし')
    d['yokakunin'] = YOKAKUNIN.get(m['hyo'], '')
    d['cols'] = [c[0] for c in t['cols']]
    d['midashi'] = {c[0]: (c[2] if len(c) > 2 else c[0]) for c in t['cols']}
    d['kata'] = {c[0]: (c[1] if len(c) > 1 else '') for c in t['cols']}
    d['notnull'] = list(t.get('notnull') or [])
    d['kuri'] = list(t.get('kuri') or [])
    d['rireki_aru'] = bool(m.get('rireki') and m['rireki'] in TABLES)
    return d


def _keta(j, c):
    """char(nn) の nn を取る。数の列は None。"""
    k = (j['kata'].get(c) or '')
    m = re.match(r'n?char\((\d+)\)', k, re.I)
    return int(m.group(1)) if m else None


def kagi_soroeru(j, kagi):
    """キーを**現行と同じ空白詰め**にそろえる。

       実測（2026-11-28）：文字のキーは桁いっぱいまで半角空白で埋まっている。
         ＡＮＡＭＭＰ．ＮＡＭＣＤ は char(06) で '1     '（6バイト）
       ＣＯＢＯＬ の比較も空白詰めなので、画面から '1' と入れても
       '1     ' の行に当たらないといけない。db.py の読み出し側は
       逆に右の空白を落としている（_val）ので、**書くとき・探すときに埋める**。
    """
    out = {}
    for c, v in (kagi or {}).items():
        n = _keta(j, c)
        s2 = '' if v is None else str(v)
        out[c] = s2.ljust(n)[:n] if n else v
    return out


def _hyoji_retsu(j, kazu=12):
    """一覧に出す列を選ぶ。ＰＫ＋繰返しでない列を頭から。

       繰返し（ＯＣＣＵＲＳを _1.._n に展開した列）は一覧には出さない。
       明細は1件表示のほうで見る。
    """
    kuri_na = set()
    for k in j['kuri']:
        na = k[0] if isinstance(k, (list, tuple)) else k
        for c in j['cols']:
            if c == na or c.startswith(na.rstrip('_') + '_'):
                kuri_na.add(c)
    out = list(j['pk'])
    for c in j['cols']:
        if c in out or c in kuri_na or c in KYOTU:
            continue
        out.append(c)
        if len(out) >= kazu:
            break
    return out


def ichiran(con, no, joken=None, kagiri=200):
    """マスタ一覧（ＫＰ＝帳票）。検索条件があれば絞る。

       仕様書の検索条件（例 M10110KP＝部品コード）は、ＰＫの前方一致で受ける。
    """
    j = joho(no)
    if not j:
        return None
    retsu = _hyoji_retsu(j)
    sql = 'SELECT %s FROM %s' % (','.join(db.Q(c) for c in retsu), db.Q(j['hyo']))
    args = []
    if joken and j['pk']:
        sql += ' WHERE %s LIKE ?' % db.Q(j['pk'][0])
        args.append(str(joken).strip() + '%')
    if j['pk']:
        sql += ' ORDER BY ' + ','.join(db.Q(c) for c in j['pk'])
    sql += ' LIMIT %d' % int(kagiri)
    gyo = db.q(con, sql, tuple(args))
    zen = db.q1(con, 'SELECT COUNT(*) AS N FROM %s' % db.Q(j['hyo']))['N']
    return {'j': j, 'retsu': retsu, 'gyo': gyo, 'zenken': zen}


def hitotsu(con, no, kagi):
    """ＰＫで1件取る。kagi は {列名: 値}。"""
    j = joho(no)
    if not j or not j['pk']:
        return None
    k2 = kagi_soroeru(j, kagi)
    w = ' AND '.join('%s=?' % db.Q(c) for c in j['pk'])
    args = tuple(k2.get(c, '') for c in j['pk'])
    return db.q1(con, 'SELECT * FROM %s WHERE %s' % (db.Q(j['hyo']), w), args)


def shiraberu(no, kubun, kagi):
    """画面項目仕様のチェック（ＥＲＲ００１〜００４）。

       仕様書 M10100KO「画面項目仕様」の形をそのまま使う。
         H-2 処理区分    入力必須 / 1〜4 であること
         H-3 キー        入力必須 / 1,4 のとき存在しないこと / 2,3 のとき存在すること
       ここに書いていないチェックは**足さない**（仕様書に無いものは勝手に作らない）。
    """
    j = joho(no)
    deta = []
    if not str(kubun or '').strip():
        deta.append(('処理区分', 'ERR004'))
    elif str(kubun) not in KUBUN:
        deta.append(('処理区分', 'ERR001'))
    for c in (j['pk'] if j else []):
        if not str(kagi.get(c, '')).strip():
            deta.append((j['midashi'].get(c, c), 'ERR004'))
    return deta


# ---------------------------------------------------------------- 書き込み
def _ima():
    import datetime
    t = datetime.datetime.now()
    return int(t.strftime('%Y%m%d')), int(t.strftime('%H%M%S'))


def _atai(j, c, v):
    """列の型に合わせて値を整える。数の列に空を入れない（ＣＯＢＯＬと同じ）。"""
    k = (j['kata'].get(c) or '').lower()
    if k.startswith(('decimal', 'numeric', 'int', 'smallint', 'bigint')):
        s = str(v).strip()
        if s == '':
            return 0
        try:
            from decimal import Decimal
            return Decimal(s)
        except Exception:
            return 0
    return '' if v is None else str(v)


def _kyotu_ireru(j, rec, atarashii):
    hi, ji = _ima()
    for c in j['cols']:
        if c not in ('CRTDAY', 'CRTDAT', 'UPDDAY', 'UPDDAT', 'UPDTIM', 'SYORBI'):
            continue
        if c in ('CRTDAY', 'CRTDAT') and not atarashii:
            continue                                   # 作成日は登録のときだけ
        rec[c] = _atai(j, c, ji if c == 'UPDTIM' else hi)
    for c in j['cols']:
        if c == 'UPDTIM':
            rec[c] = _atai(j, c, ji)
    return rec


def _rireki(con, j, kubun, kagi):
    """履歴ファイルへ1件。

       履歴は「キー＋処理区分(SYOKBN)＋転送フラグ(TENSF)＋共通項目」だけの
       小さな表（実測 ARSOJP／CRSAJP）。マスタと同じ名前の列はそのまま入れ、
       名前が違うキー列（例 ARSOJP の HENSOS＝変更キー組織）には
       **マスタのキーをつないだ値**を入れる。
    """
    na = MASTER[j['no']].get('rireki')
    if not na or na not in TABLES:
        return False
    rc = [c[0] for c in TABLES[na]['cols']]
    rec = {}
    for c in rc:
        if c in kagi:
            rec[c] = kagi[c]
        elif c == 'SYOKBN':
            rec[c] = str(kubun)
        elif c == 'TENSF':
            rec[c] = ' '
    tsunagi = ''.join(str(kagi.get(c, '')).strip() for c in j['pk'])
    for c in rc:
        if c in rec or c in KYOTU:
            continue
        if c.startswith('HEN'):                        # 変更キー…（連結キー）
            rec[c] = tsunagi
    hi, ji = _ima()
    for c in rc:
        if c in ('CRTDAY', 'CRTDAT', 'UPDDAY', 'UPDDAT', 'SYORBI'):
            rec.setdefault(c, hi)
        elif c == 'UPDTIM':
            rec.setdefault(c, ji)
        elif c == 'WSID':
            rec.setdefault(c, 'PROTO')
    if not rec:
        return False
    db.ex(con, 'INSERT INTO %s(%s) VALUES(%s)'
          % (db.Q(na), ','.join(db.Q(c) for c in rec), ','.join('?' * len(rec))),
          tuple(rec.values()))
    return True


def kakikomi(con, no, kubun, kagi, atai=None, moto_kagi=None, wsid='PROTO'):
    """マスタメンテの1件処理。戻り値 (ok, メッセージ)。

       処理区分  1=登録 2=修正 3=削除 4=複写
       ＣＡＳＥＴ の画面項目仕様どおりの順で、チェック → 本体 → 履歴。
       **1件ずつ**しか書かない（まとめ更新はしない＝現行と同じ）。
    """
    j = joho(no)
    if not j:
        return False, '工程%s は対象外です' % no
    if j.get('ichiran'):
        return False, 'この工程は一覧出力です（更新はできません）'
    kubun = str(kubun or '').strip()
    deta = shiraberu(no, kubun, kagi)
    if deta:
        na, e = deta[0]
        return False, '%s：%s（%s）' % (na, ERR[e], e)

    kagi = kagi_soroeru(j, kagi)
    if moto_kagi:
        moto_kagi = kagi_soroeru(j, moto_kagi)
    ima = hitotsu(con, no, kagi)
    if kubun in ('1', '4') and ima:
        return False, '%s（ERR002）' % ERR['ERR002']
    if kubun in ('2', '3') and not ima:
        return False, '%s（ERR003）' % ERR['ERR003']

    if kubun == '3':
        w = ' AND '.join('%s=?' % db.Q(c) for c in j['pk'])
        db.ex(con, 'DELETE FROM %s WHERE %s' % (db.Q(j['hyo']), w),
              tuple(kagi[c] for c in j['pk']))
        _rireki(con, j, kubun, kagi)
        con.commit()
        return True, '削除しました'

    if kubun == '4':
        if not moto_kagi:
            return False, '複写元を入力してください（ERR004）'
        moto = hitotsu(con, no, moto_kagi)
        if not moto:
            return False, '複写元が%s（ERR003）' % ERR['ERR003']
        rec = dict(moto)
        rec.update(kagi)
        if atai:
            rec.update({k: v for k, v in atai.items() if k in j['cols']})
        rec = _kyotu_ireru(j, rec, True)
        rec['WSID'] = wsid if 'WSID' in j['cols'] else rec.get('WSID')
        rec = {k: _atai(j, k, v) for k, v in rec.items() if k in j['cols']}
        db.ex(con, 'INSERT INTO %s(%s) VALUES(%s)'
              % (db.Q(j['hyo']), ','.join(db.Q(c) for c in rec), ','.join('?' * len(rec))),
              tuple(rec.values()))
        _rireki(con, j, kubun, kagi)
        con.commit()
        return True, '複写しました'

    if kubun == '1':
        rec = dict(kagi)
        if atai:
            rec.update({k: v for k, v in atai.items() if k in j['cols']})
        for c in j['cols']:
            rec.setdefault(c, '')
        rec = _kyotu_ireru(j, rec, True)
        if 'WSID' in j['cols']:
            rec['WSID'] = wsid
        rec = {k: _atai(j, k, v) for k, v in rec.items() if k in j['cols']}
        db.ex(con, 'INSERT INTO %s(%s) VALUES(%s)'
              % (db.Q(j['hyo']), ','.join(db.Q(c) for c in rec), ','.join('?' * len(rec))),
              tuple(rec.values()))
        _rireki(con, j, kubun, kagi)
        con.commit()
        return True, '登録しました'

    # 修正
    rec = {k: v for k, v in (atai or {}).items() if k in j['cols'] and k not in j['pk']}
    rec = _kyotu_ireru(j, rec, False)
    if 'WSID' in j['cols']:
        rec['WSID'] = wsid
    rec = {k: _atai(j, k, v) for k, v in rec.items()}
    if not rec:
        return False, '変更する項目がありません'
    w = ' AND '.join('%s=?' % db.Q(c) for c in j['pk'])
    db.ex(con, 'UPDATE %s SET %s WHERE %s'
          % (db.Q(j['hyo']), ','.join('%s=?' % db.Q(c) for c in rec), w),
          tuple(rec.values()) + tuple(kagi[c] for c in j['pk']))
    _rireki(con, j, kubun, kagi)
    con.commit()
    return True, '修正しました'
