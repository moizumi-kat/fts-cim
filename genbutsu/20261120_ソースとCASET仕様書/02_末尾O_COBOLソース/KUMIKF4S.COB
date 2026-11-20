************************************************************
* KUMIKF3S  組立工程表ファイル作成                         *
*                                                          *
* 使用ファイル名  説明                 格納ライブラリ      *
* AJUKFL1         受注項目Ｌ１         FADLIB              *
* AJUGFL1         受注鑑Ｌ１           FADLIB              *
* ASOSML1         組織マスタＬ１       FADLIB              *
* CJISFL1         作業実績Ｌ１         FCDLIB              *
* AGEKFL1         原価項目Ｌ１         FCDLIB              *
* CKMIFL1         生産項目別工数Ｌ１   FCDLIB              *
* GKUMIKSF        組立工程表ファイル   FCDLIB              *
* ASIYML1         仕様マスタ　　　　   FADLIB              *
* ATYUML1         凾体中分類マスタ　   FADLIB (2002.03.28) *
*                                                          *
* 原価連携用に仕様CODE、単位、製品区分を追加 （2006.09.15) *
* 仕様関係処理の不具合を修正した　　　　 　　（2006.10.25) *
*                                                          *
* 内容数の数値が正しく編集されない不具合の対応             *
*                       ＩＴ管理室　村上　　　(2013.08.10) *
*                                                          *
*                                                          *
* 受注項目ファイルをメインに組立工程表ファイルを作成する． *
************************************************************
*
****************************************************************
 IDENTIFICATION                  DIVISION.
 PROGRAM-ID.                     KUMIKF4O.

****************************************************************
 ENVIRONMENT                     DIVISION.
 CONFIGURATION                   SECTION.
 SPECIAL-NAMES.
     CONSOLE  IS  DSPMSG.
 INPUT-OUTPUT                    SECTION.
 FILE-CONTROL.

*受注項目Ｌ１
     SELECT  受注項目
             ASSIGN             TO  DA-01-VI-AJUKFL1
             ORGANIZATION           INDEXED
             ACCESS                 SEQUENTIAL
             RECORD                 受注項－製番
                                    受注項－受注項目
             FILE           STATUS  F1-STS.

*受注鑑Ｌ１
     SELECT  受注鑑
             ASSIGN             TO  DA-01-VI-AJUGFL1
             ORGANIZATION           INDEXED
             ACCESS                 RANDOM
             RECORD                 受注鑑－製番
             FILE           STATUS  F2-STS.

*組織マスタＬ１
     SELECT  組織マスタ
             ASSIGN             TO  DA-01-VI-ASOSML1
             ORGANIZATION           INDEXED
             ACCESS                 RANDOM
             RECORD                 組織－部所コード
                                    組織－担当者係コード
             FILE           STATUS  F3-STS.

*作業実績Ｌ１
     SELECT  作業実績
             ASSIGN             TO  DA-01-VI-CJISFL1
             ORGANIZATION           INDEXED
             ACCESS                 RANDOM
             RECORD                 作業－製番
                                    作業－項目
                                    作業－作業コード
             FILE           STATUS  F4-STS.

*原価項目Ｌ１
     SELECT  原価項目
             ASSIGN             TO  DA-01-VI-AGEKFL1
             ORGANIZATION           INDEXED
             ACCESS                 RANDOM
             RECORD                 原価項－製番
                                    原価項－項目
             FILE           STATUS  F5-STS.

*生産項目別工数Ｌ１
     SELECT  生産項目
             ASSIGN             TO  DA-01-VI-CKMIFL1
             ORGANIZATION           INDEXED
             ACCESS                 RANDOM
             RECORD                 生産－製番
                                    生産－項目
             FILE           STATUS  F6-STS.

*組立工程表ファイル
     SELECT  組立工程
             ASSIGN             TO  DA-01-S-GKUMIKSF
             ORGANIZATION           SEQUENTIAL
             ACCESS                 SEQUENTIAL
             FILE           STATUS  F7-STS.
*仕様マスタ
     SELECT  仕様マスタ
             ASSIGN             TO  DA-01-VI-ASIYML1
             ORGANIZATION           INDEXED
             ACCESS                 RANDOM
             RECORD                 仕様－仕様コード
             FILE           STATUS  F8-STS.
*    凾体中分類マスタ
     SELECT      凾体中分類マスタ
                            ASSIGN       TO DA-VI-ATYUML1
                            ORGANIZATION IS INDEXED
                            ACCESS MODE  IS RANDOM
                            RECORD KEY   IS
                                         凾体－凾体中分類コード
                            FILE STATUS  IS F9-STS.

****************************************************************
 DATA                            DIVISION.
 FILE                            SECTION.

 FD  受注項目.
     COPY  AJUKFL1   OF  XFDLIB  JOINING  受注項  AS  PREFIX.

 FD  受注鑑.
     COPY  AJUGFL1   OF  XFDLIB  JOINING  受注鑑  AS  PREFIX.

 FD  組織マスタ.
     COPY  ASOSML1   OF  XFDLIB  JOINING  組織    AS  PREFIX.

 FD  作業実績.
     COPY  CJISFL1   OF  XFDLIB  JOINING  作業    AS  PREFIX.

 FD  原価項目.
     COPY  AGEKFL1   OF  XFDLIB  JOINING  原価項  AS  PREFIX.

 FD  生産項目.
     COPY  CKMIFL1   OF  XFDLIB  JOINING  生産    AS  PREFIX.

 FD  組立工程.
     COPY  GKUMIKSF  OF  XFDLIB  JOINING  組立    AS  PREFIX.
 FD  仕様マスタ.
     COPY  ASIYML1  OF  XFDLIB  JOINING  仕様    AS  PREFIX.

******************************************************************
*    凾体中分類マスタ
******************************************************************
 FD  凾体中分類マスタ.
     COPY  ATYUML1  OF  XFDLIB  JOINING  凾体    AS  PREFIX.
****************************************************************
 WORKING-STORAGE                 SECTION.
 77  WK-TYUBCD                   PIC  X(06)     VALUE  SPACES.

***数字項目文字項目へ変換用****
 77  HENKAN                 PIC  ------------.

*    塗料算出用ワーク
 01  WK-KEISAN.
     03  WK-MKATRIT          PIC  9(002)V9(02).
     03  WK-KAKERIT          PIC  9(002)V9(02).
     03  WK-MENSEKI          PIC  9(010).
*    スイッチ／フラグ
 01  SW-AREA.
     03  SW-END              PIC  X(003).
     03  SW-INV              PIC  X(003).
     03  SW-EDT              PIC  9(001).

****************
* /フラグ項目/ *
****************

 01  END-FLAG                    PIC X(03)  VALUE  SPACE.

**************************
* /エラーメッセージ項目/ *
**************************

 01  エラーメッセージ項目.
     02  エラーメッセージ１.
         03                      PIC N(10)
                                 VALUE  NC"書込みエラー".
         03                      PIC N(10)
                                 VALUE  NC"ＯＰＥＮエラー".
     02  エラーメッセージ項目Ｒ
         REDEFINES  エラーメッセージ１.
         03         OCCURS  2.
             04  ERR-MSG         PIC N(10).

******************************
* /ファイルエラーメッセージ/ *
******************************

 01  エラー引数１                PIC X(06)  VALUE  SPACE.
 01  エラー引数２                PIC X(02)  VALUE  SPACE.
 01  エラー引数３                PIC N(12)  VALUE  SPACE.

************************
* /ファイルステータス/ *
************************

 01  F1-STS                      PIC X(02)  VALUE  SPACE.
 01  F2-STS                      PIC X(02)  VALUE  SPACE.
 01  F3-STS                      PIC X(02)  VALUE  SPACE.
 01  F4-STS                      PIC X(02)  VALUE  SPACE.
 01  F5-STS                      PIC X(02)  VALUE  SPACE.
 01  F6-STS                      PIC X(02)  VALUE  SPACE.
 01  F7-STS                      PIC X(02)  VALUE  SPACE.
 01  F8-STS                      PIC X(02)  VALUE  SPACE.
 01  F9-STS                      PIC X(02)  VALUE  SPACE.

**************
* /カウンタ/ *
**************

 01  IDX01                       PIC 9(02).
 01  IDX02                       PIC 9(02).

****************************************************************

 PROCEDURE                       DIVISION.

****************************************************************
*                                                              *
* /メイン/                                                     *
*                                                              *
****************************************************************

 メイン                          SECTION.

     PERFORM  前処理

     PERFORM  保存処理

     PERFORM  後処理.

****************************************************************
* /保存処理/                                                   *
****************************************************************

 保存処理                        SECTION.

     PERFORM  受注項目読込

     PERFORM  チェック処理  UNTIL  END-FLAG  =  "END".

****************************************************************
* /チェック処理/                                               *
****************************************************************

 チェック処理                    SECTION.

     MOVE    SPACES              TO  SW-INV.
*
***受注項目チェック***
     IF  受注項－削除フラグ      =  SPACE  AND
         受注項－生産計上日      =  ZERO   AND
*-----------------------------------------------------
*2001.02.26配電盤も追加
*
*******( 受注項－内容数１ (1:1)  =  "C"    OR
*******  受注項－内容数１ (1:1)  =  "D")
*
*2001.03.23内容数P.BOXをも追加
*******( 受注項－内容数１ (1:1)  =  "P")
*
*------------------------------------------------------
*配電盤を追加の場合は上２行をコメントし、下６行を生かす．
       ( 受注項－内容数１ (1:1)  =  "A"    OR
         受注項－内容数１ (1:1)  =  "C"    OR
         受注項－内容数１ (1:1)  =  "D"    OR
         受注項－内容数１ (1:1)  =  "I"    OR
         受注項－内容数１ (1:1)  =  "O"    OR
         受注項－内容数１ (1:1)  =  "P"    OR
         受注項－内容数１ (1:1)  =  "W" )
*------------------------------------------------------
***作業実績チェック***
         MOVE  受注項－製番      TO  作業－製番
         MOVE  受注項－受注項目  TO  作業－項目
         MOVE  "2400"            TO  作業－作業コード
         READ  作業実績
           INVALID  KEY
             MOVE   SPACES  TO  SW-INV
             PERFORM  ファイル書込処理
           NOT INVALID  KEY
             MOVE   "1"     TO  SW-INV
         END-READ
         IF   SW-INV  NOT  =  SPACES
              AND
              作業－指示職場コード   =  SPACES
              PERFORM  ファイル書込処理
         END-IF
     END-IF

***受注項目読込***
     PERFORM  受注項目読込.

****************************************************************
* /ファイル書込処理/                                           *
****************************************************************

 ファイル書込処理                SECTION.

*-- 2006.11.02 TUIKA --------*
     INITIALIZE     組立－組立工程表レコード
*----------------------------*
*--シフトコードを入れる----------------------------------
     MOVE  X"28"                 TO  組立－件名シフト開始
                                     組立－担当シフト開始
                                     組立－亜鉛シフト開始
                                     組立－製品シフト開始
                                     組立－仕様１シフト開始
                                     組立－仕様２シフト開始
     MOVE  X"29"                 TO  組立－件名シフト終了
                                     組立－担当シフト終了
                                     組立－亜鉛シフト終了
                                     組立－製品シフト終了
                                     組立－仕様１シフト終了
                                     組立－仕様２シフト終了
     MOVE  SPACES                TO  組立－余白
*--------------------------------------------------------
     MOVE  受注項－製番          TO  組立－製番
     MOVE  受注項－受注項目      TO  組立－受注項目
     MOVE  受注項－数量          TO  組立－数量
     MOVE  受注項－受注予定金額  TO  組立－受注金額
     MOVE  受注項－出図計上日    TO  組立－出図日
     MOVE  受注項－完成品納期    TO  組立－完成品納期
     MOVE  受注項－ＢＯＸ納期    TO  組立－ＢＯＸ納期
     MOVE  受注項－ＣＨ納期      TO  組立－ＣＨ納期
     MOVE  受注項－立会検査日    TO  組立－立会検査日
     MOVE  受注項－膜厚          TO  組立－膜厚
     MOVE  受注項－内面          TO  組立－内面
     MOVE  受注項－外面          TO  組立－外面
     MOVE  受注項－扉裏          TO  組立－扉裏
     MOVE  受注項－その他        TO  組立－その他
     MOVE  受注項－製品名        TO  組立－製品名
     MOVE  受注項－凾体中分類コード
                                 TO  組立－凾体中分類コード
     MOVE  受注項－鈑金巾技術    TO  組立－鈑金巾技術
     MOVE  受注項－鈑金高さ技術  TO  組立－鈑金高さ技術
     MOVE  受注項－鈑金奥行技術  TO  組立－鈑金奥行技術

**** 06.09.15 追加 ********
     MOVE  受注項－製品区分      TO  組立－製品区分
     MOVE  受注項－単位コード    TO  組立－単位コード
     MOVE  受注項－標準原価      TO  組立－標準原価
**** 06.09.15 追加 END ****

***受注鑑処理(件名）***
     PERFORM  受注鑑処理
*
***仕様マスタ処理***// 061025 受注鑑処理へ移動 //
*    IF       受注鑑－仕様１  NOT  =  SPACES
*                     PERFORM  仕様１処理.
*    IF       受注鑑－仕様２  NOT  =  SPACES
*                     PERFORM  仕様２処理.

***組織マスタ処理(担当者名係名漢字)
     PERFORM  組織マスタ処理

***作業実績処理(板金指示完了日、板金入荷日)
     PERFORM  作業実績処理

***原価項目処理(亜鉛、組標工数)
     PERFORM  原価項目処理

***生産項目別工数処理(組指工数)
     PERFORM  生産項目別工数処理

***内容数変更処理(内容数)
     PERFORM  内容数変更処理

*2002.03.28追加START
***設計関係処理
     PERFORM  設計関係処理
     PERFORM  必要量処理
*2002.03.28追加END

     WRITE  組立－組立工程表レコード

     IF  F2-STS  NOT =  "00"
         MOVE  "F2-STS"          TO  エラー引数１
         MOVE  F2-STS            TO  エラー引数２
         MOVE  ERR-MSG (1)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF.

****************************************************************
* /受注項目読込/                                               *
****************************************************************

 受注項目読込                    SECTION.
 受注項目読込－開始.

     READ  受注項目
       AT  END
           MOVE  "END"           TO  END-FLAG
     END-READ.
 受注項目読込－終了.
     EXIT.

****************************************************************
* /受注鑑処理/                                                 *
****************************************************************

 受注鑑処理                      SECTION.

     MOVE  受注項－製番          TO  受注鑑－製番
     READ  受注鑑
       INVALID  KEY
         MOVE  SPACE             TO  組立－件名
         MOVE  SPACE             TO  組立－仕様１
         MOVE  SPACE             TO  組立－仕様２
/*************  ↑↓ 061025 修正 ↑↓   ***************/
****     MOVE  SPACE             TO  受注鑑－仕様１
****     MOVE  SPACE             TO  受注鑑－仕様２
       NOT INVALID  KEY
         MOVE  受注鑑－件名      TO  組立－件名
********* 061025 TUIKA ***********************
         PERFORM  仕様１処理
         PERFORM  仕様２処理
********* 061025 TUIKA END *******************
     END-READ.

****************************************************************
* 仕様マスタ１処理                                            *
****************************************************************

 仕様１処理                      SECTION.

     MOVE  受注鑑－仕様１        TO  仕様－仕様コード.
**** 06.09.15 追加 *****
     MOVE  受注鑑－仕様１        TO  組立－仕様コード１.
************************
     READ  仕様マスタ
       INVALID  KEY
         MOVE  SPACE             TO  組立－仕様１
       NOT INVALID  KEY
         MOVE  仕様－仕様名称    TO  組立－仕様１
     END-READ.


****************************************************************
* 仕様マスタ２処理                                            *
****************************************************************

 仕様２処理                      SECTION.

     MOVE  受注鑑－仕様２        TO  仕様－仕様コード.
**** 06.09.15 追加 *****
     MOVE  受注鑑－仕様２        TO  組立－仕様コード２.
************************
     READ  仕様マスタ
       INVALID  KEY
         MOVE  SPACE             TO  組立－仕様２
       NOT INVALID  KEY
         MOVE  仕様－仕様名称    TO  組立－仕様２
     END-READ.
****************************************************************
* /組織マスタ処理/                                             *
****************************************************************

 組織マスタ処理                  SECTION.

     MOVE  受注項－部所コード    TO  組織－部所コード
     MOVE  受注項－係コード      TO  組織－担当者係コード
     READ  組織マスタ
       INVALID  KEY
         MOVE  SPACE             TO  組立－担当者名係名漢字
       NOT INVALID  KEY
         MOVE  組織－担当者名係名漢字
                                 TO  組立－担当者名係名漢字
     END-READ.

****************************************************************
* /作業実績処理/                                               *
****************************************************************

 作業実績処理                    SECTION.

     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "2000"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO              TO  組立－板金指示完了日
                                     組立－板金入荷日
       NOT INVALID  KEY
         MOVE  作業－完了予定日  TO  組立－板金指示完了日
         MOVE  作業－完了実績日  TO  組立－板金入荷日
     END-READ.
*2002.03.28追加START
****************************************************************
* 設計関係データ取り込み                                       *
****************************************************************

 設計関係処理                    SECTION.

     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "1402"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO              TO  組立－製作図指示日
         MOVE  ZERO              TO  組立－製作図出図要求日
       NOT INVALID  KEY
         MOVE  作業－指示日      TO  組立－製作図指示日
         MOVE  作業－出図要求日  TO  組立－製作図出図要求日
     END-READ.


     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "1400"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO              TO  組立－製作図作業完了実績日
       NOT INVALID  KEY
         MOVE  作業－完了実績日 TO  組立－製作図作業完了実績日
     END-READ.

     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "1222"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO              TO  組立－承認図指示日
         MOVE  ZERO              TO  組立－承認図出図要求日
       NOT INVALID  KEY
         MOVE  作業－指示日      TO  組立－承認図指示日
         MOVE  作業－出図要求日  TO  組立－承認図出図要求日
     END-READ.


     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "1220"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO              TO  組立－承認図作業完了実績日
       NOT INVALID  KEY
         MOVE  作業－完了実績日 TO  組立－承認図作業完了実績日
     END-READ.

     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "1223"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO              TO  組立－承認図変更指示日
         MOVE  ZERO              TO  組立－承認図変更出図要求日
       NOT INVALID  KEY
         MOVE  作業－指示日      TO  組立－承認図変更指示日
         MOVE  作業－出図要求日 TO  組立－承認図変更出図要求日
     END-READ.


     MOVE  受注項－製番          TO  作業－製番
     MOVE  受注項－受注項目      TO  作業－項目
     MOVE  "1221"                TO  作業－作業コード
     READ  作業実績
       INVALID  KEY
         MOVE  ZERO         TO  組立－承認図変更作業完了実績日
       NOT INVALID  KEY
         MOVE  作業－完了実績日 TO
                                組立－承認図変更作業完了実績日
     END-READ.
*2002.03.28追加END
*
*2002.03.28追加START
****************************************************************
* /内面・外面の必要量計算                                      *
****************************************************************

 必要量処理                    SECTION.
 必要量処理－開始.

     COMPUTE WK-MENSEKI          =
                                       (受注項－鈑金巾技術 *
                                       受注項－鈑金高さ技術)
                                       * 2
                                 +     (受注項－鈑金高さ技術 *
                                       受注項－鈑金奥行技術)
                                       * 2
                                 +     (受注項－鈑金奥行技術 *
                                       受注項－鈑金巾技術)
                                       * 2.
     IF      受注項－膜厚    NOT < 50
     THEN
       DIVIDE       受注項－膜厚       BY   50
       GIVING       WK-MKATRIT   ROUNDED
     ELSE
       MOVE  1                   TO    WK-MKATRIT
     END-IF.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  凾体－凾体中分類コード.
* 　 凾体中分類マスタアクセス
*****MOVE    凾体－凾体中分類コード   TO    WK-TYUBCD.
     MOVE    受注項－凾体中分類コード   TO    WK-TYUBCD.
     PERFORM 中分類処理.
     IF      SW-INV              =     "INV"
     THEN
       MOVE  ZERO                TO    WK-KAKERIT
     ELSE
       MOVE  凾体－標準原価平米掛率 (2)  TO WK-KAKERIT
     END-IF.
     COMPUTE 組立－内面必要量
                                 =  WK-MENSEKI * 0.5
                                 *  WK-MKATRIT
                                 *  WK-KAKERIT / 1000000.
     COMPUTE 組立－外面必要量
                                 =  WK-MENSEKI * 0.5
                                 *  WK-MKATRIT
                                 *  WK-KAKERIT / 1000000.
*2002.03.28追加END
****************************************************************
* /原価項目処理/                                               *
****************************************************************

 原価項目処理                    SECTION.

     MOVE  受注項－製番          TO  原価項－製番
     MOVE  受注項－受注項目      TO  原価項－項目
     READ  原価項目
       INVALID  KEY
         MOVE  SPACE             TO  組立－亜鉛
         MOVE  ZERO              TO  組立－組標工数
       NOT INVALID  KEY
         IF  原価項－亜鉛費 (1)  >  ZERO
             MOVE  NC"有"        TO  組立－亜鉛
         ELSE
             MOVE  SPACE         TO  組立－亜鉛
         END-IF

         MOVE  原価項－社内組立工数 (1)
                                 TO  組立－組標工数
     END-READ.

****************************************************************
* /生産項目別工数処理/                                         *
****************************************************************

 生産項目別工数処理              SECTION.

     MOVE  受注項－製番          TO  生産－製番
     MOVE  受注項－受注項目      TO  生産－項目
     READ  生産項目
       INVALID  KEY
         MOVE  ZERO              TO  組立－組指工数
       NOT INVALID  KEY
         MOVE  生産－組立指示工数
                                 TO  組立－組指工数
     END-READ.

****************************************************************
* /内容数変更処理/                                             *
****************************************************************

 内容数変更処理                  SECTION.

     INITIALIZE  IDX02
                 組立－内容数
*
*  2013.8.10 Y.MURAKAMI UPDATE START
*
     INITIALIZE  SW-EDT
*
*  2013.8.10 Y.MURAKAMI UPDATE END
*

*--内容数１格納--*
     PERFORM  VARYING  IDX01  FROM  1  BY  1
       UNTIL  IDX01  >  4
       IF  受注項－内容数１ (IDX01 : 1)  NOT =  SPACE
           ADD  1                TO  IDX02
           MOVE  受注項－内容数１ (IDX01 : 1)
                                 TO  組立－内容数 (IDX02 : 1)
       END-IF
     END-PERFORM
*--内容数２格納--*
     PERFORM  VARYING  IDX01  FROM  1  BY  1
       UNTIL  IDX01  >  2
*
*  2013.8.10 Y.MURAKAMI UPDATE START
*
*       IF  受注項－内容数２ (IDX01 : 1)  NOT =  ZERO
*          ADD  1                TO  IDX02
*          MOVE  受注項－内容数２ (IDX01 : 1)
*                                TO  組立－内容数 (IDX02 : 1)
*      END-IF
       IF  受注項－内容数２ (IDX01 : 1)  NOT =  ZERO
           ADD  1                TO  IDX02
           MOVE  受注項－内容数２ (IDX01 : 1)
                                 TO  組立－内容数 (IDX02 : 1)
           MOVE  1               TO  SW-EDT
       ELSE
           IF  SW-EDT  > ZERO
               ADD  1                TO  IDX02
               MOVE  受注項－内容数２ (IDX01 : 1)
                                 TO  組立－内容数 (IDX02 : 1)
           END-IF
       END-IF
*
*  2013.8.10 Y.MURAKAMI UPDATE END
*
     END-PERFORM.

/*****************************************************************
*    中分類マスタ                ＲＥＡＤ処理(RAN)
******************************************************************
 中分類処理                      SECTION.
 中分類処理－開始.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  凾体－凾体中分類コード.
*
     MOVE    WK-TYUBCD           TO    凾体－凾体中分類コード.
*
     READ    凾体中分類マスタ    INVALID
               MOVE  "INV"       TO    SW-INV.
 中分類処理－終了.
     EXIT.
****************************************************************
* /ファイルオープン/                                           *
****************************************************************

 ファイルオープン                SECTION.

     OPEN  INPUT   受注項目
                   受注鑑
                   組織マスタ
                   作業実績
                   原価項目
                   生産項目
                   仕様マスタ
                   凾体中分類マスタ
           OUTPUT  組立工程.

     IF  F1-STS  NOT =  "00"
         MOVE  "F1-STS"          TO  エラー引数１
         MOVE  F1-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF
     IF  F2-STS  NOT =  "00"
         MOVE  "F2-STS"          TO  エラー引数１
         MOVE  F2-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF
     IF  F3-STS  NOT =  "00"
         MOVE  "F3-STS"          TO  エラー引数１
         MOVE  F3-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF
     IF  F4-STS  NOT =  "00"
         MOVE  "F4-STS"          TO  エラー引数１
         MOVE  F4-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF
     IF  F5-STS  NOT =  "00"
         MOVE  "F5-STS"          TO  エラー引数１
         MOVE  F5-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF
     IF  F6-STS  NOT =  "00"
         MOVE  "F6-STS"          TO  エラー引数１
         MOVE  F6-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF
     IF  F7-STS  NOT =  "00"
         MOVE  "F7-STS"          TO  エラー引数１
         MOVE  F7-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF.
     IF  F8-STS  NOT =  "00"
         MOVE  "F8-STS"          TO  エラー引数１
         MOVE  F8-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF.
     IF  F9-STS  NOT =  "00"
         MOVE  "F9-STS"          TO  エラー引数１
         MOVE  F9-STS            TO  エラー引数２
         MOVE  ERR-MSG (2)       TO  エラー引数３
         PERFORM  ファイルクローズ
         PERFORM  エラー処理
     END-IF.

****************************************************************
* /ファイルクローズ/                                           *
****************************************************************

 ファイルクローズ                SECTION.

     CLOSE  受注項目
            受注鑑
            組織マスタ
            作業実績
            原価項目
            生産項目
            仕様マスタ
            凾体中分類マスタ
            組立工程.

****************************************************************
* /前処理/                                                     *
****************************************************************

 前処理                          SECTION.

     DISPLAY  "********** KUMIKF4O  START **********"
              UPON  DSPMSG
     PERFORM  ファイルオープン.

****************************************************************
* /後処理/                                                     *
****************************************************************

 後処理                          SECTION.

     PERFORM  ファイルクローズ
     DISPLAY  NC"組立工程表ファイル作成終了"
              UPON  DSPMSG
     DISPLAY  "********** KUMIKF4O    END **********"
              UPON  DSPMSG
     STOP  RUN.

****************************************************************
* /エラー処理/                                                 *
****************************************************************

 エラー処理                      SECTION.

     DISPLAY  エラー引数３       UPON  DSPMSG
     DISPLAY  "***********"      UPON  DSPMSG
     DISPLAY  "*" エラー引数１  "="  エラー引数２  "*"
                                 UPON  DSPMSG
     DISPLAY  "***********"      UPON  DSPMSG
     MOVE  エラー引数２          TO  PROGRAM-STATUS
     STOP  RUN.
