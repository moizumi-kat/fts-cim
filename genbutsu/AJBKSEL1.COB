*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　ＡＪＢＫＳＥＬ１　　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　ＩＴ管理室
* プログラム内容＝　情報物件ファイル（項目）の受注に紐づいた
*                   データだけを抽出し、オフライン同期用の
*                   ファイルに格納する。
*
*                                     作成日：15.03.13
*                                     更新日：00.00.00
*
*         ALL RIGHTS RESERVED COPYRIGHT FUJITSU LIMITED 1993
*
*　＊＊＊　ファイル情報　＊＊＊
*
*  DATA FILE     : 情報物件ファイル（項目）      <AJBKFL1 >
*  DATA FILE     : 同期用情報物件ファイル（項目）<RJBKFP  >
*
*＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃
 IDENTIFICATION                  DIVISION.
 PROGRAM-ID.                     AJBKSEL1.
 DATE-COMPILED.                  TODAY.
 ENVIRONMENT                     DIVISION.
 CONFIGURATION                   SECTION.
 SOURCE-COMPUTER.                FACOM  K6700SI.
 OBJECT-COMPUTER.                FACOM  K6700SI.
 SPECIAL-NAMES.
     CONSOLE                     IS     DSP.
 INPUT-OUTPUT                    SECTION.
 FILE-CONTROL.
*
     SELECT       情報物件Ｆ項目
                  ASSIGN    TO   DA-VI-AJBKFL1
                  ORGANIZATION   IS   INDEXED
                  RECORD  KEY    IS   項目－見積ナンバー
                                      項目－見積項番
                  ACCESS  MODE   IS   SEQUENTIAL
                  FILE  STATUS   IS   項目ＳＴＳ.
     SELECT       同期情報物件Ｆ項目
                  ASSIGN    TO   DA-S-RJBKFP
                  FILE  STATUS   IS   同期ＳＴＳ.
*
 DATA                            DIVISION.
 FILE                            SECTION.
*-----------------------------------------------------------------
*    情報物件Ｆ項目
*-----------------------------------------------------------------
 FD  情報物件Ｆ項目
             LABEL     RECORD    IS   STANDARD
             BLOCK     CONTAINS  1    RECORDS.
             COPY      AJBKFL1   OF   XFDLIB
             JOINING   項目  AS   PREFIX.
*-----------------------------------------------------------------
*    同期情報物件Ｆ項目
*-----------------------------------------------------------------
 FD  同期情報物件Ｆ項目
             LABEL     RECORD    IS   STANDARD
             BLOCK     CONTAINS  1    RECORDS.
             COPY      RJBKFP    OF   XFDLIB
             JOINING   同期  AS   PREFIX.
******************************************************************
*    ＷＯＲＫＩＮＧ－ＳＴＯＲＡＧＥ　ＳＥＣＴＩＯＮ
******************************************************************
 WORKING-STORAGE                 SECTION.

**************************　＜　ファイルステータスエリア　＞
 01  FILE-STATUS-AREA.
     03  項目ＳＴＳ              PIC  X(002).
     03  同期ＳＴＳ              PIC  X(002).

**************************　＜　フラグエリア　＞
 01  FLG-AREA.
     03  SW-READ                 PIC  9(001).

**************************　＜　カウンタエリア　＞
 01  CNT-AREA.
     03  ＷＫ件数.
       05  CNT-AJBKFL1-INPUT     PIC  9(006).
       05  CNT-RJBKFP-OUTPUT     PIC  9(006).
**************************　＜　ワークエリア　＞
 01  WK-AREA.
     03  WK-PGMID                PIC  X(008)    VALUE "AJBKSEL1".
     03  WK-VER                  PIC  X(007)    VALUE "V01/L01".
     03  WK-FLNAME               PIC  X(007).
     03  WK-FLMODE               PIC  X(007).
     03  WK-FLKEY1               PIC  X(013).
     03  WK-FLKEY2               PIC  X(013).
     03  WK-FLKEY3               PIC  X(013).
     03  WK-FLSTS                PIC  X(002).
     03  WK-FLSTS-R    REDEFINES WK-FLSTS.
       05  WK-STATUS             PIC  9(002).
******************************************************************
*    ＰＲＯＣＥＤＵＲＥ　ＤＩＶＩＳＩＯＮ
******************************************************************
 PROCEDURE                       DIVISION.

*-----------------------------------------------------------------
*       メイン　ルーチン　                (0.0)
*-----------------------------------------------------------------

 START-PROCESS.

     DISPLAY "*****  " WK-PGMID  " " WK-VER    " START *****"
                                           UPON DSP.

* 【 初期処理 】

     PERFORM                INIT-RTN.

* 【 主処理 】

     PERFORM                INS-PROC-RTN.

* 【 終了処理 】

     PERFORM                END-RTN.

     DISPLAY "*****  " WK-PGMID  " " WK-VER    "  END  *****"
                                           UPON DSP.

 END-PROCESS.

     STOP  RUN.

******************************************************************
*       初期処理                          (1.0)
******************************************************************
 INIT-RTN                        SECTION.

* 【 ＳＴＡＲＴメッセージ出力 】

**   DISPLAY  NC"　抽出処理　開始　"
**                                    UPON DSP.

* 【 ファイル　ＯＰＥＮ処理 】

     OPEN              INPUT          情報物件Ｆ項目.

      IF      項目ＳＴＳ               NOT =   "00"
             MOVE      項目ＳＴＳ     TO   WK-FLSTS
             MOVE     "OPEN   "       TO   WK-FLMODE
             MOVE     "AJBKFL1"       TO   WK-FLNAME
             MOVE      SPACE          TO   WK-FLKEY1
             MOVE      SPACE          TO   WK-FLKEY2
             MOVE      SPACE          TO   WK-FLKEY3
             PERFORM                  ABEND-RTN
     END-IF.

     OPEN              OUTPUT         同期情報物件Ｆ項目.

     IF      同期ＳＴＳ               NOT =   "00"
             MOVE      同期ＳＴＳ     TO   WK-FLSTS
             MOVE     "OPEN   "       TO   WK-FLMODE
             MOVE     "RJBKFP"        TO   WK-FLNAME
             MOVE      SPACE          TO   WK-FLKEY1
             MOVE      SPACE          TO   WK-FLKEY2
             MOVE      SPACE          TO   WK-FLKEY3
             PERFORM                  ABEND-RTN
     END-IF.

* 【 初期設定 】

     INITIALIZE                            ＷＫ件数.

 INIT-EXT.
     EXIT.

******************************************************************
*       情報物件Ｆ項目のレコード追加      (2.0)
******************************************************************
 INS-PROC-RTN                    SECTION.

     INITIALIZE                            SW-READ.
* 【 当月見積ファイル　ＳＴＡＲＴ 】

     INITIALIZE        項目－情報物件項目レコード.

* 【 情報物件Ｆ項目　ＲＥＡＤ 】

     PERFORM                  AJBKFL1-READ-RTN.

     PERFORM      UNTIL     SW-READ   =    1

*    【 同期情報物件Ｆ項目追加 】

       PERFORM                RJBKFP-INSERT-RTN

* 【 情報物件Ｆ項目　ＲＥＡＤ 】

       PERFORM                AJBKFL1-READ-RTN

     END-PERFORM.

 INS-PROC-EXT.
     EXIT.
******************************************************************
*       終了処理                          (4.0)
******************************************************************
 END-RTN                         SECTION.

* 【 ファイル　ＣＬＯＳＥ処理 】

     CLOSE                            情報物件Ｆ項目.

     IF      項目ＳＴＳ               NOT =   "00"
             MOVE      項目ＳＴＳ     TO   WK-FLSTS
             MOVE     "CLOSE  "       TO   WK-FLMODE
             MOVE     "AJBKFL1"       TO   WK-FLNAME
             MOVE      SPACE          TO   WK-FLKEY1
             MOVE      SPACE          TO   WK-FLKEY2
             MOVE      SPACE          TO   WK-FLKEY3
             PERFORM                  ABEND-RTN
     END-IF.

     CLOSE                            同期情報物件Ｆ項目.

     IF      同期ＳＴＳ               NOT =   "00"
             MOVE      同期ＳＴＳ     TO   WK-FLSTS
             MOVE     "CLOSE  "       TO   WK-FLMODE
             MOVE     "RJBKFP"        TO   WK-FLNAME
             MOVE      SPACE          TO   WK-FLKEY1
             MOVE      SPACE          TO   WK-FLKEY2
             MOVE      SPACE          TO   WK-FLKEY3
             PERFORM                  ABEND-RTN
     END-IF.

* 【 ファイル　Ｉ／Ｏ件数出力 】

     DISPLAY "*     AJBKFL1 INP  = " CNT-AJBKFL1-INPUT  "     *"
                                           UPON DSP.
     DISPLAY "*     RJBKFP  OUT  = " CNT-RJBKFP-OUTPUT "     *"
                                           UPON DSP.
     DISPLAY  NC"　抽出処理　終了　"
                                           UPON DSP.

 END-EXT.
     EXIT.

******************************************************************
*       異常終了処理
******************************************************************
 ABEND-RTN                       SECTION.

     DISPLAY "*****  " WK-FLNAME " " WK-FLMODE " ERR    *****"
                                           UPON DSP.

     DISPLAY "*             KEY1= "  WK-FLKEY1 " *"
                                           UPON DSP.
     DISPLAY "*             KEY2= "  WK-FLKEY2 " *"
                                           UPON DSP.
     DISPLAY "*             KEY3= "  WK-FLKEY3 " *"
                                           UPON DSP.
     DISPLAY "*             F-STS    = " WK-FLSTS    "       *"
                                           UPON DSP.

     DISPLAY "*****  " WK-PGMID  " " WK-VER    " ABEND *****"
                                           UPON DSP.

     COMPUTE  PROGRAM-STATUS  =  4000  +  WK-STATUS.

     STOP RUN.

 ABEND-EXT.
     EXIT.

******************************************************************
*       情報物件Ｆ項目　ＲＥＡＤ処理
******************************************************************
 AJBKFL1-READ-RTN                SECTION.

 AJBKFL1-01.

     READ           情報物件Ｆ項目          NEXT
        AT   END
             MOVE      1              TO   SW-READ
             GO        TO             AJBKFL1-READ-EXT
     END-READ.


     IF      項目ＳＴＳ               NOT =   "00"
             MOVE      項目ＳＴＳ     TO   WK-FLSTS
             MOVE     "READ   "       TO   WK-FLMODE
             MOVE     "AJBKFL1"       TO   WK-FLNAME
             MOVE      項目－見積ナンバー
                                      TO   WK-FLKEY1
             MOVE      項目－見積項番
                                      TO   WK-FLKEY2
             MOVE      SPACE          TO   WK-FLKEY3
             PERFORM                  ABEND-RTN
     END-IF.

     ADD     1              TO   CNT-AJBKFL1-INPUT.

     IF  項目－受注項目  >  ZERO  THEN
       CONTINUE
     ELSE
       GO TO  AJBKFL1-01
     END-IF.


 AJBKFL1-READ-EXT.
     EXIT.
******************************************************************
*     同期情報物件Ｆ項目　ＩＮＳＥＲＴ処理
******************************************************************
 RJBKFP-INSERT-RTN              SECTION.

     MOVE  項目－情報物件項目レコード
                                 TO  同期－情報物件項目レコード.

     WRITE       同期－情報物件項目レコード.

     IF      同期ＳＴＳ               NOT =   "00"
             MOVE      同期ＳＴＳ     TO   WK-FLSTS
             MOVE     "WRITE  "       TO   WK-FLMODE
             MOVE     "RJBKFP"        TO   WK-FLNAME
             MOVE      同期－見積ナンバー
                                      TO   WK-FLKEY1
             MOVE      同期－見積項番
                                      TO   WK-FLKEY2
             MOVE      SPACE          TO   WK-FLKEY3
             PERFORM                  ABEND-RTN
     END-IF.

     ADD     1              TO   CNT-RJBKFP-OUTPUT.

 RJBKFP-INSERT-EXT.
     EXIT.
