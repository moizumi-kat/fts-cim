# -*- coding: utf-8 -*-
"""ファイル定義体（.SMB）全件から **「定義名 → 01レコード名」** の対応表を起こす。

     python3 bin/gen_fdef_rec.py <OBJ ディレクトリ> [出力先.json]

■ なぜ要るか（2026-11-26 村上様のご指摘）
  ＣＯＢＯＬ は `FD <ファイル名>.` の中で `COPY <原文名> OF XFDLIB.` と書くが、
  **原文名はファイル名と違うことがある**。

      SHIZI74F.COB
          SELECT FSSIFL2 ASSIGN TO DA-VI-FSSIFL2
          FD  FSSIFL2.
              COPY FSSIFL1 OF XFDLIB.        ← ファイル名と違う
          INITIALIZE FSSIRC OF FSSIFL2.      ← 01レコード名は FSSIRC

  FSSIFL2.SMB の rec は FSSIR2、**FSSIFL1.SMB の rec が FSSIRC**。
  ＦＤのファイル名だけ見ていたので `FSSIRC` が引けず止まっていた。
  原文名のほうの定義体を見れば、コピー原文が無くても01名が分かる。

  表定義（cim/schema_gen の TABLES・486表）には**物理ファイルだけ**が入る。
  論理ファイル（DA-VI-… の FSSIFL1／FSSIFL2 など）は入っていないので、
  .SMB を直接読んだこの対応表が別に必要になる。
"""
import sys, json, pathlib

ここ = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ここ))
import fdef


def _gun(d):
    """定義体の**集団項目**（kata='G'）を、子の列名つきで返す。

       ■ なぜ（2026-11-26）
         ＣＯＢＯＬ は集団項目の名前でまとめて読み書きする。
             AEJGFP   CRTTAN（作成担当者コード）＝ CRTBSY ＋ CRTKKR
             原文     `MOVE 連携鑑－作成担当者コード TO …`
         これまでは決め打ちの2件（組織コード・YMD）しか持っていなかったので
         ほかは「知らない項目」で止まっていた。定義体は 809本・3,270個の
         集団項目を**位置と長さつきで**持っているので、そこから起こす。

       ■ 子が繰返す集団項目も返す（2026-11-26）
         `SERTBL`（設計配分率ＴＢＬ・12バイト）＝ `SERITU`（4バイト）×3。
         列は `SERITU_1`〜`SERITU_3` に展開されるので、`kaisu` を添えて
         返し、範囲は**展開後の列の位置**から出す（_gun_teigitai）。
       ■ 子に集団項目がある（入れ子）ものは対象外（安全側）
         範囲を推測することになるため。
    """
    ko = d.get('ko') or []
    oyako = {}
    for x in ko:
        if x.get('oya'):
            oyako.setdefault(x['oya'], []).append(x)
    out = []
    for g in ko:
        if g['kata'] != 'G':
            continue
        ks = oyako.get(g['na']) or []
        if not ks:
            continue
        # 子に集団項目があるもの（入れ子）は入れない（安全側）
        if any(k['kata'] == 'G' for k in ks):
            continue
        if g.get('kaisu'):
            continue
        out.append({'na': g['na'], 'ja': g.get('midashi') or '',
                    'ko': [k['na'] for k in ks],
                    'kaisu': {k['na']: k['kaisu'] for k in ks if k.get('kaisu')}})
    return out


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    moto = pathlib.Path(sys.argv[1])
    saki = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 \
        else ここ.parent / 'proto' / 'cim' / 'fdef_rec.json'
    out, dame = {}, []
    for f in sorted(moto.glob('*.SMB')) + sorted(moto.glob('*.smb')):
        try:
            d = fdef.yomu(f)
        except Exception as e:
            dame.append('%s %s' % (f.name, e))
            continue
        rec = d.get('rec')
        gun = _gun(d)
        if not rec and not gun:
            continue
        v = {'rec': rec, 'naga': d.get('naga')}
        if gun:
            v['gun'] = gun
        # ■ **ファイル名と定義体の中の名前が違う**ことがある（2026-11-26 実測）
        #   F10540I1.SMB の中の名前は F10540S1。原文は SELECT に書いた
        #   ファイル名（F10540I1）で引くので、片方だけだと引けず
        #   `RECORD KEY IS KEY01` が開けなかった（F10585PB）。
        #   中身は同じなので**両方の名前で登録**する。
        for na in {(d.get('na') or '').upper(), f.stem.upper()}:
            if na:
                out.setdefault(na, v)
    saki.parent.mkdir(parents=True, exist_ok=True)
    saki.write_text(json.dumps(out, ensure_ascii=False, indent=0,
                               sort_keys=True), encoding='utf-8')
    print('%s に %d本ぶん書きました（読めなかったもの %d本）'
          % (saki, len(out), len(dame)))
    for x in dame[:5]:
        print('   ', x)
    return 0


if __name__ == '__main__':
    sys.exit(main())
