# -*- coding: utf-8 -*-
"""残り36本の依頼文を作る。工程・呼び元・定義体の有無を添える。

     python3 bin/gen_irai_36.py <tarinai.json> <work_caset.json> <koutei405.json> \
                                <work_teigitai.json> <work_murakami.json> <出力.txt>
"""
import sys, json, pathlib, collections
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import cp932

TARINAI, CASETJ, KOUTEI, TEIGI, KAITO, OUT = sys.argv[1:7]
d = json.load(open(TARINAI, encoding='utf-8'))
cs = json.load(open(CASETJ, encoding='utf-8'))
ko = json.load(open(KOUTEI, encoding='utf-8'))
tg = json.load(open(TEIGI, encoding='utf-8'))
ka = json.load(open(KAITO, encoding='utf-8'))

SIYO = set(cs['caset']) | set(cs['dps']) | {'A16100KB', 'A16110KB', 'A16120KP', 'D40130KP'}
MANUAL = {'JCVEBCC', 'XSBSSI'}
TSUKURANAI = ('仕様書は無いのでこの部分は作成しなくて良い', '対象外')

kumi = collections.OrderedDict((
    ('１．カセット（末尾 KB／KP／KO）＝ 仕様書', d['kb_kp_ko']),
    ('２．末尾Ｏ ＝ ＣＯＢＯＬソース（末尾Ｓ）', d['owari_o']),
    ('３．そのほか ＝ ＣＯＢＯＬ／ＣＬソース', d['hoka'])))
nokori = collections.OrderedDict()
for na, mono in kumi.items():
    nokori[na] = [x for x in sorted(mono)
                  if x not in SIYO and x not in MANUAL
                  and not any(t in ' '.join(ka.get(x, [])) for t in TSUKURANAI)]
zen = [x for v in nokori.values() for x in v]

# どの工程で止まるか／呼び元
koutei = collections.defaultdict(list)
for k in ko:
    for c in k.get('callinfo', []):
        if c['n'] in zen:
            koutei[c['n']].append('%d-%d %s' % (k.get('o1') or 0, k.get('o2') or 0, k['nm']))
yobimoto = {x: ' '.join(ka.get(x, []))for x in zen}
amari = {k for k, v in tg.items() if not v['tsukau']}

SEN, HOSO = '=' * 64, '-' * 64
b = []; w = b.append
w(SEN)
w(' いま必要なものは、ソース %d本だけです' % len(zen))
w(' FTS-CIM                                   2026年11月18日')
w(' お願いする先：ＩＴ管理室')
w(SEN)
w('')
w(' 定義体421本をいただき、**画面・帳票は不足ゼロ**になりました。')
w(' ありがとうございました。')
w(' 残るお願いは、下記のソース %d本だけです。' % len(zen))
w('')
w(' ※ いずれも11月13日に「提供済、再度確認願います」とご回答いただいた分です。')
w('    こちらで下記を全部引き直しましたが、見つかりませんでした。')
w('      ・プログラムファイル／営業・設計製造・購買・管理自社開発その他')
w('      ・新プロジェクト／A1_見積サブシステム・CASET仕様書・DPS仕様書')
w('      ・途中の追加資料／設計製造・営業・管理自社開発その他・20261107_依頼分')
w('      ・画面定義体／帳票定義体（今回いただいた421本）')
w('      ・復旧済みソース一式（ＣＯＢＯＬ828本・ＣＬ587本）')
w('    末尾Ｏは**末尾Ｓへの読み替え**でも、綴り違いでも探しております。')
w('')
for na, mono in nokori.items():
    if not mono:
        continue
    w(HOSO)
    w(' %s  %d本' % (na, len(mono)))
    w(HOSO)
    w('')
    for x in mono:
        kt = koutei.get(x, [])
        w('   ■ %s' % x)
        if kt:
            for t in kt[:3]:
                w('        工程 %s' % t[:40])
            if len(kt) > 3:
                w('        …ほか %d工程' % (len(kt) - 3))
        else:
            w('        （工程表の入口からは直接出てきません）')
        mo = yobimoto.get(x, '')
        if '←' in mo:
            w('        呼び元ＣＬ %s' % mo.split('←')[1].split()[0])
        nita = sorted(a for a in amari if a[:6] == x[:6])
        if nita:
            w('        ※ 定義体 %s は受領済みです' % '／'.join(nita))
    w('')
w(HOSO)
w(' ■ あわせてご確認をお願いしたい2点')
w(HOSO)
w('')
w(' (1) A2・A3 のサブシステムの仕様書は、A1 のように**別の zip** に')
w('     なっておりますでしょうか。')
w('     A26100KB／A36100KB／A36110KB が、CASET仕様書.zip に入っておりません。')
w('     （A16100KB など A1 の3本は A1_見積サブシステム.zip にありました）')
w('')
w(' (2) D20710KP は、**D20710KB** という名前なら仕様書があります。')
w('     どちらが正しいか、ご確認いただけますでしょうか。')
w('')
w(HOSO)
w(' ■ 急ぎではありません')
w(HOSO)
w('')
w(' 405工程のうち、この%d本で止まるのは **%d工程**です。' % (len(zen), len({t for x in zen for t in koutei.get(x, [])})))
w(' **先頭50工程（営業・見積・設計）には1つもありません。**')
w(' いま進めている工程11-1（見積登録）も含め、当分このまま進められます。')
w('')
w(' 止まるのは 生産・工程管理（31〜34系）と 日報月報（51系）です。')
w('')
w(SEN)
n = cp932.kaku(OUT, '\n'.join(b) + '\n')
s = pathlib.Path(OUT).read_text('cp932')
print('→ %s（%d行）' % (OUT, len(s.splitlines())))
print('   76バイト超:', sum(1 for l in s.splitlines() if len(l.encode('cp932', 'replace')) > 76))
print('   ソース %d本（%s）' % (len(zen), '／'.join('%d' % len(v) for v in nokori.values())))
