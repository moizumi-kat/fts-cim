# -*- coding: utf-8 -*-
"""レコードリストにも定義体にも無い表を、現行ソースの根拠で補う。

   ■ 2とおりで補う
     (1) 写し・別名   CL に「どのファイルの写しか」が書いてある。
                      CNVFILE／SETPF／OVRF／OVRSF はレコードをそのまま移すので、
                      写し元と同じ並びとみなす。**根拠の行を必ず残す。**
     (2) ソースから   プログラムが FD の下にレコードを直接書いている場合は、
                      そこから起こす（XFDLIB が無くても確実）。

   ■ 大事なこと
     (1) は**推定**。現物の定義体をいただいたら差し替える。
     生成した表には src='utsushi' を立て、根拠を konkyo に残す。
"""

# 表 → (写し元, 根拠にした現行ソースの行)
UTSUSHI = {
    'AREGFS':  ('SREGFS',  'CB1D1225.CL  CNVFILE FILE-AREGFS.FADLIB,TOFILE-SREGFS.FADLIB'),
    'AREKFS':  ('SREKFS',  'CB1D1225.CL  CNVFILE FILE-AREKFS.FADLIB,TOFILE-SREKFS.FADLIB'),
    'SENGFS':  ('SREGFS',  'CL4D0000.CL  CNVFILE FILE-SREGFS.@LIBL,TOFILE-SENGFS.FADLIB'),
    'SENKFS':  ('SREKFS',  'CL4D0000.CL  CNVFILE FILE-SREKFS.@LIBL,TOFILE-SENKFS.FADLIB'),
    'CSEICP':  ('CSEIJP',  'CKORNCL1.CL  SETPF FILE-CSEIJP.FCDLIB,TOFILE-CSEICP.FCDLIB'),
    'FGENKA':  ('CGENKA',  'CB2M5100.CL  OVRF FILE-CGENKA,TOFILE-FGENKA（ファイル名の上書き＝別名）'),
    'KFKNSWK': ('KFKNSDF', 'KOGYOCL8.CL  OVRSF FILE-KFKNSDF,TOFILE-KFKNSWK.@LIBL（別名）'),
    'AUKRFS':  ('AUKJFS',  'CB1D1225.CL  CNVFILE FILE-AUKJFS.FADLIB,TOFILE-AUKRFS.FADLIB'),
}

# 表 → (ソース, FD名, 根拠)
SOURCE = {
    'TENURISF': ('TENSO1CF', '売上ファイル',
                 'TENSO1CF.COB  FD 売上ファイル の 01 URIREC（レコードを直接書いている）'),
    'TENURI2F': ('TENSO2CF', 'TENURI2F',
                 'TENSO2CF.COB  FD TENURI2F の 01 URIREC2'),
    'TENURI3F': ('MJS110CF', '売上用ファィル３',
                 'MJS110CF.COB  FD 売上用ファィル３ の 01 URIREC3'),
}

# 現行ソースに書かれているレコード長。起こした定義の検算に使う
NAGASA = {
    'KFKNSWK': (323, 'KOGYOCL8.CL  OUTRL-323'),
    'AJKTFS': (7, 'CL6D0000.CL  SORTD INFILE-AJKTFS,INRL-7'),
}

# どうしても分からないもの（村上様へお願いする分）
WAKARANAI = {
    'AERGFS':   'CL1D0000 の SAVFILE と CL2D0000 の CNVFILE→RERGFS のみ。RERGFS にも定義が無い',
    'AERKFS':   '同上（→RERKFS にも定義が無い）',
    'AJKTFS':   'CB1Z0010 の CNVFILE FILE-B11200S1→AJKTFS。B11200S1 に定義が無い（レコード長7）',
    'D20520BK': 'CL3D0000 の CNVFILE FILE-D20520S3→D20520BK。D20520S3 に定義が無い',
    'D20530BK': 'CL3D0000 の CNVFILE FILE-D20530S1→D20530BK。D20530S1 に定義が無い',
    'GKUMIKSF': 'PKOUJOU3 の CLRFILE／FIMPORT のみ。写し元が書かれていない',
    'PJYURIFP': 'COBOL も CL も1本も触っていない',
}


def oginau(rec, rep, srcdir='cim/utf8'):
    """rec（レコードリストから起こした定義）に、上の根拠で足りない表を補う。

       rec をその場で書き足し、補った表の明細を返す。
       呼ぶのは「名前の読み替え（⑤ ファイル名の訂正）を当てた後」。
    """
    import pathlib
    import fd_hirou
    import recdef                      # noqa: F401  （hashira を使うのは呼び元）
    oginatta = {}

    # (1) プログラムが FD の下にレコードを直接書いているもの
    for hyo, (cob, fd, konkyo) in SOURCE.items():
        if hyo in rec or hyo in rep:
            continue
        p = pathlib.Path(srcdir) / (cob + '.COB')
        if not p.exists():
            continue
        _rec01, items = fd_hirou.hirou(p, fd)
        if not items:
            continue
        rec[hyo] = {'lib': '', 'nm': '', 'items': items, 'ronri': [],
                    '_moto': 'source', '_konkyo': konkyo}
        oginatta[hyo] = ('source', cob, konkyo)

    # (2) CL に「どのファイルの写しか」が書いてあるもの
    for hyo, (moto, konkyo) in UTSUSHI.items():
        if hyo in rec or hyo in rep:
            continue
        if moto not in rec:
            continue
        rec[hyo] = dict(rec[moto], _moto=moto, _konkyo=konkyo)
        oginatta[hyo] = ('utsushi', moto, konkyo)

    return oginatta
