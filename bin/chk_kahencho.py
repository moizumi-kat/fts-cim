# -*- coding: utf-8 -*-
"""文字項目が「先頭2バイト＝後続の有効バイト数」の**可変長**かを実データで判定する。

     python3 -I chk_kahencho.py <OBJディレクトリ> <SFLディレクトリ> [...]

■ なぜ（2026-11-26 村上様のご回答）
  「定義体の先頭2バイトは後ろに続く有効データのバイト数を2バイトのバイナリで
    表したもの。データベースのテーブルにデータを入れ込むときは先頭2バイトは
    対象外になります。プロトタイプのプログラムも先頭2バイトの扱いは不要」

  定義体には**可変長であるという印が無い**（ABUHMP の PARTNA と PARTCD の
  項目レコードを 0x00〜0x40 まで突き合わせ、違うのは名前・位置・桁だけと実測）。
  ですので**実データで判定する**。推測しない。

■ 不変条件（これを満たすものだけ可変長とみなす）
    ① 先頭2バイトを big-endian で読んだ n が 0 ≦ n ≦ 桁数−2
    ② 位置 2+n から後ろは**全部詰め物**（0x40／0x20／0x00）
  n が実際の文字列長と一致するか、ではなく上の②で見る。
  ＪＥＦ漢字の中に 0x40 が出るので「右の空白を落とした長さ」では測れない（実測）。

■ から文字との区別
  全部 0x00 の項目は n=0 で②も満たすため、**中身のある件が20件以上ある**
  ことも条件に入れる。でないと「空の列」まで可変長に見える。
"""
import sys, pathlib, collections

ここ = pathlib.Path(__file__).resolve().parent
TSUME = (0x40, 0x20, 0x00)
SITA = 20              # 中身のある件数の下限


def shiraberu(b, j, o, keta):
    ok = ng = nakami = 0
    for p in j['ichi']:
        fld = b[p:p + j['naga']][o:o + keta]
        if len(fld) < keta:
            continue
        n = int.from_bytes(fld[:2], 'big')
        if n <= keta - 2 and all(c in TSUME for c in fld[2 + n:]):
            ok += 1
            if n > 0 and fld[2] not in TSUME:
                nakami += 1
        else:
            ng += 1
    return ok, ng, nakami


def main():
    obj = pathlib.Path(sys.argv[1])
    dirs = [pathlib.Path(x) for x in sys.argv[2:]]
    sys.path.insert(0, str(ここ / 'fts-cim-repo' / 'bin'))
    import fdef, sfl as sflmod
    kahen, futsu, mi = [], 0, 0
    for f in sorted(obj.glob('*.SMB')):
        try:
            d = fdef.yomu(f)
        except Exception:
            continue
        tgt = [x for x in d['ko'] if x['kata'] == 'X' and x['keta'] >= 4]
        if not tgt:
            continue
        data = None
        for dd in dirs:
            if (dd / (d['na'] + '.SFL')).exists():
                data = dd / (d['na'] + '.SFL'); break
        if data is None:
            mi += 1
            continue
        b = data.read_bytes()
        try:
            j = sflmod.kaiseki(b)
        except Exception:
            continue
        if not j['ichi']:
            continue
        for x in tgt:
            ok, ng, nakami = shiraberu(b, j, x['ichi'] - 1, x['keta'])
            if ok + ng < SITA:
                continue
            if ng == 0 and nakami >= SITA:
                kahen.append((d['na'], x['na'], x['ichi'], x['keta'],
                              ok, nakami, x['midashi']))
            else:
                futsu += 1
    print('■ 可変長（先頭2バイト＝長さ）と実データで判定できたもの … %d件'
          % len(kahen))
    print('%-11s %-9s %5s %4s %7s %7s  %s'
          % ('定義体', '項目', 'ichi', '桁', '件数', '中身あり', '見出し'))
    for x in kahen:
        print('%-11s %-9s %5d %4d %7d %7d  %s' % x)
    print()
    print('ふつうの文字項目と判定 %d件 ／ 実データが手元に無い定義体 %d本'
          % (futsu, mi))
    return 0


if __name__ == '__main__':
    sys.exit(main())
