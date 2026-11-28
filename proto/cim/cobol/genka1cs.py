# -*- coding: utf-8 -*-
"""GENKA1CS  原価の集計（GENKA1CS.COB の限度額・実績額の格納部を移植）

■ 原価ファイル項目 AGEKFP の「原価項目情報」は4回くりかえします。
  1〜4 の意味は村上様よりご回答をいただきました（2026-10-19）。

        (1) 標準
        (2) 限度
        (3) 新規実績（正式）    … 1回目加算
        (4) 変更実績（変更）    … 2回目以降加算

  現行プログラムの使いかたも、このとおりになっています。

    ・限度額の格納（行2634-2635 ほか／コメント「----限度額　格納----」）
          ADD 項目－主材費 (2) TO AK-SYUZAI …  すべての費目で (2) を使う
    ・実績額の格納（行2825-2890／コメント「---実績額計算格納---」）
          ADD 項目－主材費 (3) TO AJ-SYUZAI
          ADD 項目－主材費 (4) TO AJ-SYUZAI   … (3)＋(4) を足す
      ただし **塗装費だけは (2) を使う**（行2828・2874）。現行のとおりにしています。
    ・削除フラグが空白でないレコードは読み飛ばす（行2630-2631）
    ・製品区分 "02" とそれ以外で、組立費の振り分け先が変わる（行2824／2864）

  小計・総原価（行2790-2798）
      小計1 ＝ 主材＋補材＋鈑金＋塗装＋亜鉛＋組立＋間接＋設計
      小計2 ＝ 販管費
      総原価 ＝ 小計1 ＋ 小計2
"""
# 画面に出す費目と、AGEKFP の英名（現行の項目名）
# (画面の見出し, AGEKFPの英名, 実績のとりかた)
HIMOKU = [
    ('主　材　費', 'SYZAI_',  'jisseki'),
    ('補　材　費', 'HOZAI_',  'jisseki'),
    ('鈑　金　費', 'BANKIN',  'jisseki'),
    ('塗　装　費', 'TOSOU_',  'gendo'),      # 塗装費の実績は (2) を使う … 行2828
    ('亜　鉛　費', 'AEN___',  'jisseki'),
    ('組　立　費', 'IKUMI_',  'jisseki'),
    ('組立間接費', 'KUBMON',  'jisseki'),
    ('設　計　費', 'ISEKEI',  'jisseki'),
    ('運　　　賃', 'NIZUN_',  'jisseki'),
    ('製造原価',   'SZGEN_',  'jisseki'),
    ('販　管　費', 'HANBAI',  'jisseki'),
    ('総原価額',   'SOGEN_',  'jisseki'),
]

HYOJUN, GENDO, SIN_JISSEKI, HEN_JISSEKI = 1, 2, 3, 4   # 村上様ご回答（2026-10-19）

def cols():
    """SELECT に並べる列名（4回ぶんすべて）。"""
    out = []
    for _, e, _k in HIMOKU:
        out += ['%s_%d' % (e, i) for i in (1, 2, 3, 4)]
    return out

def meisai(rows):
    """AGEKFP の行（同一製番の受注項目ぶん）から、画面の費目行を作る。

    戻り値の各行
        hyojun  (1) 標準
        gendo   (2) 限度        ← 画面の「実行予算」
        jisseki (3)+(4) 実績    ← 新規実績＋変更実績
    """
    out = []
    for nm, e, how in HIMOKU:
        h = g = j = 0
        for r in rows:
            if (r.get('DELFLG') or ' ').strip():      # 削除フラグ … 行2630-2631
                continue
            h += r.get('%s_%d' % (e, HYOJUN)) or 0
            g += r.get('%s_%d' % (e, GENDO)) or 0
            if how == 'gendo':                         # 塗装費 … 行2828
                j += r.get('%s_%d' % (e, GENDO)) or 0
            else:
                j += (r.get('%s_%d' % (e, SIN_JISSEKI)) or 0) \
                   + (r.get('%s_%d' % (e, HEN_JISSEKI)) or 0)
        out.append({'komoku': nm, 'hyojun': h, 'gendo': g, 'jisseki': j})
    return out
