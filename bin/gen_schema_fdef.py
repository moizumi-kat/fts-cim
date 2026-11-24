# -*- coding: utf-8 -*-
"""cim/schema_gen.py を、オフコンの**ファイル定義体（.SMB）**で起こし直す。

  これまで（bin/gen_schema_all.py）の出どころは2つだった。
    1) src='rep'  … レプリケーション対象。村上様の定義体（DDL）を一字一句そのまま。
    2) src='conv' … それ以外。「レコードリスト」を変換仕様書どおりに読んで起こしたもの。

  2) には**読み違いがあった**（実測）。たとえば納期物件管理ファイル４ NOKIK4SF は、
  「48バイトの集団項目」を「48回の繰返し」と取り違えて 700列に膨らんでいた
  （現物は 136列・800バイト）。ワークファイル（鑑）AWKGFP も 38列欠けていた
  （掛率 KAKRIT ほか）。レコードリストは紙の一覧なので、こうした取り違えが起きる。

  2026-11 に村上様より OBJ.zip（オフコンのファイル定義体 .SMB 1,061本）をいただけたので、
  **現物の定義体を正**として 2) を置き換える（src='teigitai'）。
  1) の DDL は周辺システム（CAD・営業支援）も同じ定義を見ているので**絶対に変えない**。

  型の対応は、1) の DDL と定義体を項目ごとに突き合わせて裏取りした（実測）。
    X(n) → char(n)    N(n) → nchar(n)
    U(n,m) → numeric(n,m)   （ゾーン10進。n=全桁数・m=小数桁数）
    P(n,m) → decimal(n,m)   （パック10進）
  81表 5,432項目のうち **5,298項目が完全一致**。残りは DDL 側が varchar/nvarchar や
  decimal を選んだ表記差（65+15+49）と、長さが違う5項目だけ（下の shirase に出す）。

  繰返し（OCCURS）は、これまでどおり英名を _ で6文字に詰めて _1, _2 … と水平展開する。
  定義体の繰返しは入れ子が無いことを実測で確認済み（従属項目の起点は必ず1つ）。

  使い方
    python3 gen_schema_fdef.py <.SMB置き場> <いまのschema_gen.py> <出力先.py>
"""
import sys, re, pprint, pathlib, collections, importlib.util

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import fdef

OBJDIR, IMA, OUT = sys.argv[1:4]


def _yomikomu(michi):
    """いまの schema_gen.py を（パッケージ無しで）読み込んで TABLES を取り出す。"""
    shiyo = importlib.util.spec_from_file_location('_ima_schema', michi)
    mod = importlib.util.module_from_spec(shiyo)
    shiyo.loader.exec_module(mod)
    return mod.TABLES


def kata_sql(k):
    """定義体の1項目 → SQL の型。上の対応表は DDL と突き合わせて裏取り済み。"""
    t, ke, sh = k['kata'], k['keta'], k['shou']
    # 表記は従来の流儀に合わせる（char/nchar は2桁ゼロ詰め、numeric/decimal は詰めない）
    if t == 'X':
        return 'char(%02d)' % ke
    if t == 'N':
        return 'nchar(%02d)' % ke
    if t == 'U':
        return 'numeric(%d,%d)' % (ke, sh)
    if t == 'P':
        return 'decimal(%d,%d)' % (ke, sh)
    raise ValueError('知らない型 %r' % t)


def pic(k):
    """定義体の1項目 → 現行の PIC 表記（画面・帳票の見出し用に添える）。"""
    t, ke, sh = k['kata'], k['keta'], k['shou']
    if t == 'X':
        return 'X(%02d)' % ke
    if t == 'N':
        return 'N(%02d)' % ke
    atama = 'S' if k['fugo'] else ''
    if sh:
        return '%s9(%02d)V9(%02d)' % (atama, ke - sh, sh)
    return '%s9(%02d)' % (atama, ke)


def retsu_na(k, i=None):
    """繰返しの列名 ＝ 英名を _ で6文字に詰めて _1, _2 …（これまでと同じ流儀）。"""
    if i is None:
        return k['na']
    return '%s_%d' % (k['na'].ljust(6, '_'), i)


def _kotachi(f):
    """定義体の項目を親子の木にする。並びは定義体のまま。"""
    ko = collections.defaultdict(list)
    ne = []
    for i, k in enumerate(f['ko']):
        (ko[k['oya']] if k['oya'] else ne).append(i)
    return ne, ko


def _hira(f, i, ko):
    """1項目を基本項目の並びに潰す。繰返しは**1回目の全項目→2回目の全項目**と
       交互に並べる（＝現物のバイトの並び。DDL と突き合わせて裏取り済み）。"""
    k = f['ko'][i]
    if k['kata'] == 'G':
        naka = []
        for j in ko.get(k['na'], []):
            naka += _hira(f, j, ko)
    else:
        naka = [(k['na'], k)]
    kai = k['kaisu'] if k['hyo'] == 1 and k['kaisu'] else 0
    if not kai:
        return naka
    out = []
    for n in range(1, kai + 1):
        for na, kk in naka:
            out.append((retsu_na({'na': na}, n), kk))
    return out


def hirogeru(f):
    """定義体 → (列名, 定義体の項目) の並び。集団項目そのものは列にしない。"""
    ne, ko = _kotachi(f)
    out = []
    for i in ne:
        out += _hira(f, i, ko)
    return out


def _seiki(s):
    """char(08) と char(8) を同じものとして見るための正規化。"""
    return re.sub(r'\((\d+)\)', lambda m: '(%d)' % int(m.group(1)), s)


# ---- 本体 -------------------------------------------------------------
TABLES = _yomikomu(IMA)
teigi = fdef.yomu_zenbu(OBJDIR)

naoshita, teigi_nashi = [], []
shirase = []                 # 村上様に確認したい食い違い

for na in sorted(TABLES):
    t = TABLES[na]
    f = teigi.get(na)
    if f is None:
        teigi_nashi.append(na)
        continue

    hiro = hirogeru(f)
    furui = {c[0]: c for c in t['cols']}
    moto_src = t.get('src')

    cols = []
    for rna, k in hiro:
        wamei = k['midashi'] or (furui[rna][2] if rna in furui else '')
        cols.append((rna, kata_sql(k), wamei, pic(k)))

    # DDL（レプリケーション先）との食い違いを残す。DDL は周辺システムも見ているので、
    # **バイトの並びは定義体を正**としつつ、違いは必ず人に見せる。
    if moto_src == 'rep':
        sa = []
        ima = {c[0]: c for c in cols}
        for c in t['cols']:
            d = ima.get(c[0].strip())      # DDL の列名に末尾空白がある例あり（KFKNSBK SURYO）
            if d is None:
                sa.append((c[0], c[1], None))
                continue
            a, b = _seiki(c[1]), d[1]
            if a == b:
                continue
            # varchar/nvarchar/decimal は SQL 側の言い換え。長さが同じなら黙る。
            if (a.replace('nvarchar', 'nchar').replace('varchar', 'char') == b
                    or a.replace('decimal', 'numeric') == b):
                continue                   # SQL 側の言い換え。長さが同じなら黙る。
            sa.append((c[0], c[1], d[1]))
        furui_s = {k.strip() for k in furui}
        for c in cols:
            if c[0] not in furui_s:
                sa.append((c[0], None, c[1]))
        if sa:
            t['ddl_chigai'] = sa
            for x in sa:
                shirase.append('%-9s %-9s DDL %-14s 定義体 %-14s'
                               % (na, x[0], x[1] or '（無し）', x[2] or '（無し）'))

    ikiru = {c[0] for c in cols}
    t['cols'] = cols
    t['naga'] = f['naga']
    t['rec'] = f['rec']
    t['src'] = 'teigitai'
    t['moto'] = moto_src                 # もとの出どころ（rep/conv/utsushi/source）
    t['pk'] = [c for c in t.get('pk') or [] if c in ikiru]
    t['notnull'] = [c for c in t.get('notnull') or [] if c in ikiru]
    t['default'] = {c: v for c, v in (t.get('default') or {}).items() if c in ikiru}
    naoshita.append(na)

# ---- 検算 -------------------------------------------------------------
warui = []
for na in naoshita:
    t = TABLES[na]
    y = 0
    for _rna, ty in ((c[0], c[1]) for c in t['cols']):
        m = re.match(r'(char|nchar|numeric|decimal)\((\d+)(?:,(\d+))?\)', ty)
        a = int(m.group(2))
        y += a if m.group(1) in ('char', 'numeric') else (
            a * 2 if m.group(1) == 'nchar' else (a + 2) // 2)
    if y != t['naga']:
        warui.append('%-9s 列の合計 %d バイトとレコード長 %d が合わない' % (na, y, t['naga']))

# ---- 書き出し ---------------------------------------------------------
kazu = collections.Counter(v['src'] for v in TABLES.values())
h = collections.Counter(v['hantei'] for v in TABLES.values())

atama = '''# -*- coding: utf-8 -*-
"""現行システムのファイル定義そのもの。bin/gen_schema_fdef.py が自動生成。
   **手で直さないこと。** 直すなら生成器のほうを直して、作り直す。

  テーブル名 ＝ 現行の物理ファイル名（論理ファイル名は ronri に保持）
  列名      ＝ 現行の COBOL 英名（英大文字）。繰返し（OCCURS）は英名を _ で
              6文字に詰めて _1, _2 … と水平展開する（DDL と同じ流儀）。

  src='teigitai' … オフコンの**ファイル定義体（.SMB／OBJ.zip）**から起こしたもの。
                   現物なので、これを正とする。moto にもとの出どころを残す。
  moto='rep'     … レプリケーション対象。村上様の定義体（DDL）があるもの。
                   DDL と食い違う項目は ddl_chigai に (列名, DDL, 定義体) で残す。
  moto='conv'    … 以前は「レコードリスト」を変換仕様書どおりに読んで起こしていた。
                   **読み違いがあった**ので定義体で置き換えた（下記）。
  moto='utsushi' / 'source' … 定義体も無く、CL や FD の記述から推定したもの。

  ■ 定義体で置き換えた理由（2026-11 実測）
    ・納期物件管理ファイル４ NOKIK4SF … 「48バイトの集団項目」を「48回の繰返し」と
      取り違えて 700列に膨らんでいた（現物は 136列・800バイト）。
    ・ワークファイル（鑑）AWKGFP … 38列欠けていた（掛率 KAKRIT ほか）。
    ・集団項目の OCCURS の並び … 「項目ごとにまとめて」ではなく
      **1回目の全項目→2回目の全項目**と交互が正しい（DDL 79表の並びと一致）。

  ■ 裏取り（すべて実測）
    ・型の対応 X(n)→char(n) / N(n)→nchar(n) / U(n,m)→numeric(n,m) /
      P(n,m)→decimal(n,m) … DDL 81表 5,432項目のうち 5,298項目が完全一致。
    ・列の並び … DDL 80表のうち 79表が完全一致（残り1表も DDL 側の列名の
      末尾空白だけの差）。
    ・レコード長 … .SFL（実データ）の枠の刻みが**レコード長＋1**（先頭1バイトの
      在/空フラグ）と一致（116本）。
    ・部品名称 PARTNA は DDL が char(30) だが実データに 32文字が 16件ある
      ＝定義体の 32 が正（ddl_chigai に記録）。

  naga … 定義体のレコード長（バイト）。rec は定義体のレコード名。

  hantei … 「FTS-CIM ファイル・テーブル仕分け提案書（第2版）」村上様ご確認済
            の判定。残す／作らない（ワーク・一時が主）／要確認。
            試作環境では**現行の処理をそのまま写すため全部作る**が、
            新システムに残すのは「残す」だけ。

  cols の並び ＝ (列名, 型, 現行の日本語項目名, 現行のPIC)
                 日本語名は画面の見出し用で、列名には使わない。
'''
atama += ('\n   %d表 %d列（定義体から %d表 ／ 定義体が無く従来のまま %d表）\n') % (
    len(TABLES), sum(len(v['cols']) for v in TABLES.values()),
    len(naoshita), len(teigi_nashi))
for k, v in h.most_common():
    atama += '     %-12s %3d表\n' % (k, v)
atama += '"""\n'

pathlib.Path(OUT).write_text(
    atama + 'TABLES = ' + pprint.pformat(TABLES, width=100, sort_dicts=True) + '\n',
    encoding='utf-8')

print('■ 書き出し %s' % OUT)
print('   %d表 %d列' % (len(TABLES), sum(len(v['cols']) for v in TABLES.values())))
print('   定義体から起こした %d表 ／ 定義体が無く従来のまま %d表'
      % (len(naoshita), len(teigi_nashi)))
print('   定義体が見当たらない表:', ' '.join(teigi_nashi))
print()
print('■ 検算（列の合計バイト ＝ レコード長）: %s'
      % ('%d表すべて合う' % len(naoshita) if not warui else '%d表で合わない' % len(warui)))
for x in warui:
    print('     ' + x)
print()
print('■ 村上様に確認したい DDL との食い違い %d件' % len(shirase))
for x in shirase:
    print('     ' + x)
