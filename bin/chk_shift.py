# -*- coding: utf-8 -*-
"""文字項目に**日本語の開始／終了コード**（X'28'／X'29'）が入っている表を洗い出す。

     python3 -I bin/chk_shift.py <SFL.zip か SFLのフォルダ> <表定義のあるproto>

■ なぜ（2026-11-26 村上様ご回答）
  「SHIFT1 は日本語データ開始コード X'28'、SHIFT2 は日本語データ終了コード X'29'」
  文字項目（X）の中に、この2つで囲んで日本語（ＪＥＦ2バイト）を入れている。
  1バイトずつ読むと化けるので、`sfl._moji` が混じり読みに直した。
  **すでに取り込んだデータは化けたまま**なので、どの表を取り込み直すかを
  ここで決める。1件でも含む表だけ取り込み直せばよい（ほかは不変）。
"""
import sys, pathlib, zipfile, io

SO, SI = 0x28, 0x29
ATAMA = 1 << 16                     # 先頭64KBだけ見る（当たりを付けるため）


def hairu(b, cols, sflmod):
    """先頭のレコードを何件か見て、文字項目にシフトコードがあるか返す。"""
    try:
        j = sflmod.kaiseki(b)
    except Exception:
        return None
    out = set()
    ichi = 0
    han = []
    for na_, ty, _ja, _pic in cols:
        n = sflmod.naga(ty)
        if str(ty).startswith(('char', 'varchar')):
            han.append((na_, ichi, n))
        ichi += n
    for p in j['ichi'][:200]:
        rec = b[p:p + j['naga']]
        if len(rec) < j['naga']:
            break
        for na_, o, n in han:
            f = rec[o:o + n]
            if SO in f and SI in f and f.index(SO) < f.rindex(SI):
                out.add(na_)
    return out


def main():
    moto = pathlib.Path(sys.argv[1])
    proto = pathlib.Path(sys.argv[2])
    sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
    sys.path.insert(0, str(proto))
    import sfl as sflmod
    from cim.schema_gen import TABLES
    aru, nashi, yome = {}, 0, 0
    if moto.is_dir():
        tama = [(p.stem.upper(), p.read_bytes) for p in sorted(moto.iterdir())
                if p.suffix.upper() == '.SFL']
    else:
        z = zipfile.ZipFile(moto)
        tama = []
        for i in z.infolist():
            na = pathlib.Path(i.filename).stem.upper()
            if pathlib.Path(i.filename).suffix.upper() != '.SFL':
                continue
            tama.append((na, (lambda n=i.filename: z.open(n).read(ATAMA))))
    for na, yomu in tama:
        t = na if na in TABLES else na.rstrip('0123456789')
        if t not in TABLES:
            nashi += 1
            continue
        try:
            b = yomu()
        except Exception:
            continue
        r = hairu(b, TABLES[t]['cols'], sflmod)
        if r is None:
            continue
        yome += 1
        if r:
            aru.setdefault(t, set()).update(r)
    print('■ 文字項目にシフトコードが入っている表 … %d表' % len(aru))
    for t in sorted(aru):
        print('   %-12s %s' % (t, ' '.join(sorted(aru[t]))))
    print()
    print('見た表 %d ／ 表定義に無いファイル %d' % (yome, nashi))
    return 0


if __name__ == '__main__':
    sys.exit(main())
