# -*- coding: utf-8 -*-
"""A10040PO が使うファイルの定義。bin/gen_fairu.py が自動生成。**手で直さない。**

   FILE-CONTROL をそのまま写したもの。
   FAIRU の1件 = 論理名: (COBOLの名前, 物理表, [キーの列], 状態項目)
"""

FAIRU = {
    'AWKGFL1' : ('ワーク鑑'          , 'AWKGFP' , ['MITUNO'], 'AWKG-STSCD'),
    'AWKKFL1' : ('ワーク項目'         , 'AWKKFP' , ['MITUNO', 'MITKOB'], 'AWKK-STSCD'),
    'AWKMFL1' : ('ワーク明細'         , 'AWKMFP' , ['MITUNO', 'MITKOB', 'GYOBAN'], 'AWKM-STSCD'),
    'AJBGFL1' : ('鑑ファイル'         , 'AJBGFP' , ['MITUNO'], 'AJBG-STSCD'),
    'AHATML1' : ('発番ファイル'        , 'AHATMP' , ['HATKBN', 'HATUCD'], 'AHAT-STSCD'),
    'ASOSML1' : ('組織マスタ'         , 'ASOSMP' , ['BSYOCD', 'TANCD'], 'ASOS-STSCD'),
    'ANAMML1' : ('名称マスタ'         , 'ANAMMP' , ['NAMKBN', 'NAMCD'], 'ANAM-STSCD'),
    'ATORML1' : ('取引先マスタ'        , 'ATORMP' , ['TORICD'], 'ATOR-STSCD'),
    'ASIYML1' : ('仕様マスタ'         , 'ASIYMP' , ['SIYOCD'], 'ASIY-STSCD'),
    'AKAKML1' : ('掛率マスタ'         , 'AKAKMP' , ['YOBKEY'], 'AKAK-STSCD'),
    'ABUHML1' : ('部品マスタ'         , 'ABUHMP' , ['PARTCD'], 'ABUH-STSCD'),
    'ABANML1' : ('鈑金マスタ'         , 'ABANMP' , ['DAIBCD'], 'ABAN-STSCD'),
    'ATYUML1' : ('中分類マスタ'        , 'ATYUMP' , ['TYUBCD'], 'ATYU-STSCD'),
    'ACHKFL1' : ('チェックＦ'         , 'ACHKFP' , ['MITUNO'], 'ACHK-STSCD'),
    'CCALML1' : ('カレンダマスタ'       , 'CCALMP' , ['NEN', 'TSUKI', 'HIZUKE'], 'CCAL-STSCD'),
    'ARMIJL1' : ('履歴ファイル'        , 'ARMIJP' , ['MITUNO'], 'ARMI-STSCD'),
    # SUNPO は集団項目 → WIDTH＋HIGH＋DEPTH（A10040PO.COB 4478-4480行（注記）に MOVE AWKM-DW/DH/DD TO ASUN-WIDTH/HIGH/DEPTH とあり、ASUN-SUNPO は MOVE HIGH-VALUE で丸ごと埋められている（4348行）＝巾・高さ・奥行をまとめた集団項目）
    'ASUNML1' : ('寸法マスタ１'        , 'ASUNMP' , ['DAIBCD', 'WIDTH', 'HIGH', 'DEPTH'], 'ASUN-STSCD'),
    'ASUNML3' : ('寸法マスタ３'        , 'ASUNMP' , ['DAIBCD', 'ROKMEN'], 'ASU3-STSCD'),
}
