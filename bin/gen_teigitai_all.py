# -*- coding: utf-8 -*-
"""画面定義体220本・帳票定義体201本を、ぜんぶ1つのJSONに起こす。

     python3 bin/gen_teigitai_all.py <画面定義体フォルダ> <帳票定義体フォルダ> <出力.json>

  ■ 何が入るか（1本あたり）
     na     定義体の名前（A10040D1 など）
     kind   'gamen'（画面）/ 'chohyo'（帳票）
     gyo    行数（いちばん下の行＋1）
     ko     項目の並び。1件 = {
              nm    定義体の中の名前（R001・F003・W002 など）
              gyo   行（0起点）   keta 桁（1起点）
              naga  表示長        naga2 データ長
              ichi  レコード内の位置
              midashi 見出しの文字（F＝画面に焼き付けてある字）。入力項目は None
              hen   表示の形 (編集, 編集2, 区切り文字, 小数桁)
            }
  ■ 根拠
     位置・桁・編集 … bin/smd_parse.py（画面220・帳票201の全45,013項目で検算済）
     見出しの文字  … bin/teigitai_moji.py（属性の+2で1バイト/2バイト/混ざりを分ける）
"""
import sys, json, pathlib
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import smd_parse, teigitai_moji

def hitotsu(path, kind):
    b = path.read_bytes()
    na, ko, size = smd_parse.yomu(str(path))
    out = []
    for k in ko:
        if k['gyo'] is None:
            continue
        a = k['tsugi']
        shurui = b[a+2] if a + 18 <= len(b) else 0
        midashi = None
        if k['moji']:
            midashi = teigitai_moji.moji(b[k['moji']:k['moji']+k['naga']], shurui)
        out.append({'nm': k['nm'], 'gyo': k['gyo'], 'keta': k['keta'],
                    'naga': k['naga'], 'naga2': k['naga2'], 'ichi': k['k6'],
                    'midashi': midashi,
                    'hen': [k['hen'], k['hen2'], k['kugiri'], k['shousuu']]})
    out.sort(key=lambda x: (x['gyo'], x['keta']))
    return {'na': path.stem, 'kind': kind,
            'gyo': (max(x['gyo'] for x in out) + 1) if out else 0,
            'ko': out}

def main():
    gdir, cdir, out = sys.argv[1], sys.argv[2], sys.argv[3]
    zen = {}
    warui = []
    for d, kind in ((gdir, 'gamen'), (cdir, 'chohyo')):
        for p in sorted(pathlib.Path(d).iterdir()):
            if not p.is_file():
                continue
            try:
                t = hitotsu(p, kind)
            except Exception as e:
                warui.append('%s: %s' % (p.name, e)); continue
            zen[t['na']] = t
    pathlib.Path(out).write_text(
        json.dumps(zen, ensure_ascii=False, separators=(',', ':')), encoding='utf-8')
    g = sum(1 for t in zen.values() if t['kind'] == 'gamen')
    c = len(zen) - g
    ko = sum(len(t['ko']) for t in zen.values())
    mi = sum(1 for t in zen.values() for x in t['ko'] if x['midashi'])
    print('%s → 画面 %d本・帳票 %d本／項目 %s（うち見出し %s）'
          % (out, g, c, format(ko, ','), format(mi, ',')))
    if warui:
        print('読めなかったもの %d: %s' % (len(warui), warui[:3]))
    return 1 if warui else 0

if __name__ == '__main__':
    sys.exit(main())
