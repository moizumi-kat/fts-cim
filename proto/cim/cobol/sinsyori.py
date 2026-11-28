# -*- coding: utf-8 -*-
"""SINSYORI  営業用工程進捗照会（SINSYORI.COB の DDSET 部の移植）

画面の11列は、作業コードが**プログラムに直接書かれて**います。
受注項目ごとに、作業実績ファイル CJISFP を（製番・項目・作業コード）で引きます。

    行623 "1222" → 表示１     承認図面２作図指示
    行644 "1220" → 表示２     承認図面２作成作業
    行665 "1223" → 表示３     承認図２変更作図指示
    行686 "1402" → 表示４     製作図面作図指示
    行707 "1400" → 表示５     製作図面作成作業
    行728 "1403" → 表示６     製作図面変更作図指示
    行749 "1401" → 表示７     製作図面変更作業
    行770 "2000" → 表示８     鈑金作業
    行791 "2001" → 表示９     鈑金変更作業
    行818 "2400" → 表示10     組立作業
    行839 "2700" → 表示11     検査・出荷

  日付の出しかた（行625-635 ほか。どの列も同じ）
      完了実績日 ≠ 0  → その日付を「月.日」で表示（色 W＝実績）
      そうでなく 完了予定日 ≠ 0 → その日付を「月.日」で表示（色 T＝予定）
      どちらも 0 → 空欄
"""
# (作業コード, 画面の列, 作業の名称)  ← 名称は作業マスタ CSAGMP の値
RETSU = [
    ('1222', 'sj2_shiji',   '承認図面２作図指示'),
    ('1220', 'sj2_sakusei', '承認図面２作成作業'),
    ('1223', 'sj2_henshi',  '承認図２変更作図指示'),
    ('1402', 'sz_shiji',    '製作図面作図指示'),
    ('1400', 'sz_sakusei',  '製作図面作成作業'),
    ('1403', 'sz_henshi',   '製作図面変更作図指示'),
    ('1401', 'sz_henko',    '製作図面変更作業'),
    ('2000', 'bk_sagyo',    '鈑金作業'),
    ('2001', 'bk_henko',    '鈑金変更作業'),
    ('2400', 'kumitate',    '組立作業'),
    ('2700', 'kensa',       '検査・出荷'),
]

def _hi(v):
    """日付を「月.日」にする（行628-632 の HENSYU-DATE）。"""
    if not v: return ''
    n = int(v)
    if n <= 0: return ''
    return '%d.%d' % (n // 100 % 100, n % 100)

def gyo(jisseki):
    """作業実績の行（製番ぶん）→ 画面の行（受注項目ごと）。

    jisseki … CJISFP の行。KOMOKU／WORKCD／KJSKBI（完了実績日）／KYOTEI（完了予定日）
    """
    by = {}
    for r in jisseki:
        k = r.get('KOMOKU')
        by.setdefault(k, {})[(r.get('WORKCD') or '').strip()] = r
    out = []
    for k in sorted(by):
        d = {'komoku': k}
        for cd, col, _nm in RETSU:
            r = by[k].get(cd)
            if not r:
                d[col] = ''; continue
            # 実績があれば実績、無ければ予定（行625-640）
            d[col] = _hi(r.get('KJSKBI')) or _hi(r.get('KYOTEI'))
            d[col + '_yotei'] = not r.get('KJSKBI')
        out.append(d)
    return out
