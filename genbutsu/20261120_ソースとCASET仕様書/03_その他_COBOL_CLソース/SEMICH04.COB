*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　ＳＥＭＩＣＨ０４　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　生産未計上抽出ファイルから
*                   生産未計上一覧表を作成する
*
*                                     ＩＴ管理センター　村上
*
*                                               作成日：20.09.02
*                                               更新日：  .  .
*
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  生産未計上抽出ファイル　　　<D20400S3 >
*                   受注ファイル（鑑）　　　　　<AJUGFL1  >
*                   受注ファイル（項目）　　　　<AJUKFL1  >
*                   製品区分マスタ    　　　　　<CSHKML1  >
* ＊＊＊　リスト情報　　＊＊＊
*  SMED NAME    ：  生産未計上一覧表　　　　　　<XU04LP  >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                SEMICH04.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
*SOURCE-COMPUTER.           FACOM  K6700.
*OBJECT-COMPUTER.           FACOM  K6700.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
     CONSOLE     IS         DSP.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    生産未計上一覧表
     SELECT      XU04LP     ASSIGN       TO GS-XU04LP
                            SYMBOLIC DESTINATION IS "PRT"
                            FORMAT       IS PRT-FORMAT
                            GROUP        IS PRT-GROUP
                            PROCESSING MODE     IS PRT-MODE
                            UNIT       CONTROL  IS PRT-SEIGYO
                            FILE  STATUS IS PRT-STATUS.
*    生産未計上抽出ファイル
     SELECT      D20400S3   ASSIGN       TO DA-S-D20400S3
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D20400S3.
*    受注ファイル（鑑）
     SELECT      AJUGFL1    ASSIGN       TO DA-VI-AJUGFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUGFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUGFL1.
*    受注ファイル（項目）
     SELECT      AJUKFL1    ASSIGN       TO DA-VI-AJUKFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUKFL1
                                            JYUKOU OF AJUKFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUKFL1.
*    製品区分マスタ
     SELECT      CSHKML1    ASSIGN       TO DA-VI-CSHKML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIKBN OF CSHKML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSHKML1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    生産未計上一覧表
******************************************************************
 FD  XU04LP.
     COPY        SEMICHP1   OF   XMDLIB.
/*****************************************************************
*    生産未計上抽出ファイル
******************************************************************
 FD  D20400S3    BLOCK      CONTAINS   136  RECORDS.
     COPY        D20400S3   OF   XFDLIB.
/*****************************************************************
*    受注ファイル（鑑）
******************************************************************
 FD  AJUGFL1.
     COPY        AJUGFL1    OF   XFDLIB.
/*****************************************************************
*    受注ファイル（項目）
******************************************************************
 FD  AJUKFL1.
     COPY        AJUKFL1    OF   XFDLIB.
/*****************************************************************
*    製品区分マスタ
******************************************************************
 FD  CSHKML1.
     COPY        CSHKML1    OF   XFDLIB.
/*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
 01  PRT-ITEM.
     03  PRT-FORMAT              PIC  X(008).
     03  PRT-GROUP               PIC  X(008).
     03  PRT-STATUS              PIC  X(002).
     03  PRT-MODE                PIC  X(002).
     03  PRT-SEIGYO              PIC  X(006).
*    ファイルステータス
     03  ST-D20400S3             PIC  X(002).
     03  ST-AJUGFL1              PIC  X(002).
     03  ST-AJUKFL1              PIC  X(002).
     03  ST-CSHKML1              PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYORI                PIC  X(007).
     03  WK-FILE                 PIC  X(008).
     03  WK-DATE                 PIC  9(006).
     03  WK-TIME                 PIC  9(008).
     03  WK-STATUS               PIC  X(002).
     03  WK-STATUS-R             REDEFINES     WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
     03  WK-TOJFLG               PIC  X(001).
     03  WK-SEIBAN               PIC  X(006).
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
     03  SW-PAGE                 PIC  X(001).
     03  SW-WRITE                PIC  X(001).
*    添字
 01  IX-AREA.
     03  IX-01                   PIC  9(002).
*    カウンター
 01  CNT-AREA.
     03  CNT-PAGE                PIC  9(005).
     03  CNT-IN                  PIC  9(005).
 01  WK-PGMID                    PIC  X(008) VALUE "SEMICH04".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
/
 PROCEDURE                       DIVISION.
******************************************************************
*    メイン　ルーチン                      (1.0)
******************************************************************
 CTRL-SEC                        SECTION.
 CTRL-010.
     DISPLAY "***** "   WK-PGMID  " " WK-VER "  START *****"
                                               UPON  DSP.
*
     PERFORM INIT-SEC.
     PERFORM MAIN-SEC    UNTIL   SW-END  = "END".
     PERFORM FINAL-SEC.
*
     DISPLAY "*     D20400S3 IN    =  " CNT-IN      "     *"
                                               UPON  DSP.
     DISPLAY "*     SEMICHP1 PAGE  =  " CNT-PAGE    "     *"
                                               UPON  DSP.
     DISPLAY "***** "   WK-PGMID  " " WK-VER "  END   *****"
                                               UPON  DSP.
 CTRL-999.
     STOP    RUN.
/*****************************************************************
*    前　処　理
******************************************************************
 INIT-SEC                        SECTION.
 INIT-010.
     INITIALIZE                  PRT-ITEM
                                 WORK-AREA
                                 SW-AREA
                                 CNT-AREA.
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN        INPUT           D20400S3
                                 AJUGFL1
                                 AJUKFL1
                                 CSHKML1.
     OPEN        OUTPUT          XU04LP.
*
     MOVE    "SEMICHP1"          TO    PRT-FORMAT.
     MOVE    "SCREEN"            TO    PRT-GROUP.
*
     PERFORM  OPEN-CHECK-SEC.
     PERFORM  ACCEPT-SEC.
     IF  SW-END      =   SPACE
       THEN
         PERFORM  D20400S3-READ-SEC
     END-IF.
     MOVE      1                 TO    IX-01.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     MOVE    SPACE  TO  SEMICHP1 OF XU04LP.
*
     PERFORM  MEISAI-SET1-SEC.
*
     PERFORM UNTIL  ( SW-END     =     "END"               )
             OR     ( IX-01      >      54                 )
*
         PERFORM  MEISAI-SET2-SEC
         PERFORM  D20400S3-READ-SEC
*
         IF  SW-END  =  SPACE
           THEN
             IF  IX-01   =   55
               THEN
                 ADD     1      TO    IX-01
             END-IF
           ELSE
             CONTINUE
         END-IF
     END-PERFORM.
     PERFORM  PRT-WRITE-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
     IF  CNT-IN = ZERO
       THEN
         MOVE    SPACE  TO  SEMICHP1 OF XU04LP
         PERFORM  MEISAI-SET1-SEC
         MOVE  NC"＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊"
                                      TO  KENMEI OF SEMICHP1(1)
         MOVE  SPACE                  TO  KENMEI OF SEMICHP1(2)
         MOVE  NC"　　　生産未計上はありませんでした。"
                                      TO  KENMEI OF SEMICHP1(3)
         MOVE  SPACE                  TO  KENMEI OF SEMICHP1(4)
         MOVE  NC"＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊"
                                      TO  KENMEI OF SEMICHP1(5)
         PERFORM  PRT-WRITE-SEC
     ELSE
         CONTINUE
     END-IF.
*
 FINAL-020.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE       XU04LP
                 D20400S3
                 AJUGFL1
                 AJUKFL1
                 CSHKML1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    明細セット処理１（見出し）
******************************************************************
 MEISAI-SET1-SEC                 SECTION.
 MEISAI-SET1-010.
*    作成日
     MOVE    WK-DATE             TO    SYRBI  OF SEMICHP1.
*    時間
     MOVE    WK-TIME(1:2)        TO    JIKAN1 OF SEMICHP1.
     MOVE    WK-TIME(3:2)        TO    JIKAN2 OF SEMICHP1.
*    ページ
     ADD     1                   TO    CNT-PAGE.
     MOVE    CNT-PAGE            TO    PAGCNT OF SEMICHP1.
*
     MOVE  HIGH-VALUE    TO    WK-TOJFLG.
     MOVE  HIGH-VALUE    TO    WK-SEIBAN.
*
 MEISAI-SET1-999.
     EXIT.
/*****************************************************************
*    明細セット処理２（明細行）
******************************************************************
 MEISAI-SET2-SEC                 SECTION.
 MEISAI-SET2-010.
*
     IF  ( WK-TOJFLG  =  TOJFLG OF D20400S3 )
       THEN
         IF  ( WK-SEIBAN  =  SEIBAN OF D20400S3)
           THEN
             CONTINUE
         ELSE
             PERFORM  SEIBAN-SET-SEC
             MOVE  SEIBAN OF D20400S3  TO  WK-SEIBAN
         END-IF
     ELSE
         IF  TOJFLG OF D20400S3 = "1"
           THEN
             MOVE NC"当日出荷分　" TO TOJITU OF SEMICHP1(IX-01)
         ELSE
             MOVE NC"前日迄出荷分" TO TOJITU OF SEMICHP1(IX-01)
         END-IF
         PERFORM  SEIBAN-SET-SEC
         MOVE  TOJFLG OF D20400S3  TO  WK-TOJFLG
         MOVE  SEIBAN OF D20400S3  TO  WK-SEIBAN
     END-IF.
*
*
     PERFORM  JUTUK-READ-SEC.
     IF  ST-AJUKFL1  =  "00"
       THEN
*        製品区分
         PERFORM  SHKB-READ-SEC
         IF  ST-CSHKML1  =  "00"
           THEN
             MOVE SRYAKU OF CSHKML1 TO SRYAKU OF SEMICHP1(IX-01)
         END-IF
     END-IF.
*    項目
     MOVE  KOMOKU OF D20400S3  TO  KOMOKU OF SEMICHP1(IX-01).
*
*    出荷日
     MOVE  SYUYMD OF D20400S3  TO  SYUYMD OF SEMICHP1(IX-01).
*
     ADD   1                   TO    IX-01.
 MEISAI-SET2-999.
     EXIT.
/*****************************************************************
*    製番セット処理（製番ブレイク時）
******************************************************************
 SEIBAN-SET-SEC                  SECTION.
 SEIBAN-SET-010.
*    製番
     MOVE  SEIBAN OF D20400S3(1:1)
                                 TO    SEIBN1 OF SEMICHP1(IX-01).
     MOVE  "-"                   TO    SEIBN2 OF SEMICHP1(IX-01).
     MOVE  SEIBAN OF D20400S3(2:5)
                                 TO    SEIBN3 OF SEMICHP1(IX-01).
*    件名
     PERFORM                     JUTU-READ-SEC.
     IF  ST-AJUGFL1         =   "00"
       THEN
         MOVE  KENMEI OF AJUGFL1 TO  KENMEI OF SEMICHP1(IX-01)
     ELSE
         MOVE  NC"＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊"
                                  TO  KENMEI OF SEMICHP1(IX-01)
     END-IF.
 SEIBAN-SET-999.
     EXIT.
/*****************************************************************
*    リスト出力処理
******************************************************************
 PRT-WRITE-SEC                   SECTION.
 PRT-WRITE-010.
*    改ページ
     IF          SW-PAGE         NOT = SPACE
       THEN
         MOVE    SPACE           TO    PRT-GROUP
         MOVE   "CT"             TO    PRT-MODE
         MOVE   "PAGE"           TO    PRT-SEIGYO
         WRITE   SEMICHP1
     END-IF.
*
*    内容印字
     MOVE     "SCREEN"           TO    PRT-GROUP.
     MOVE      SPACE             TO    PRT-MODE.
     MOVE      SPACE             TO    PRT-SEIGYO.
     WRITE     SEMICHP1.
     MOVE     "1"                TO    SW-PAGE.
     MOVE      SPACE             TO    SW-WRITE.
     MOVE      1                 TO    IX-01.
 PRT-WRITE-999.
     EXIT.
/*****************************************************************
*    日付＆時間の取得＆セット処理
******************************************************************
 ACCEPT-SEC                      SECTION.
 ACCEPT-010.
     ACCEPT    WK-DATE           FROM    DATE.
     ACCEPT    WK-TIME           FROM    TIME.
 ACCEPT-999.
     EXIT.
/*****************************************************************
*    中間ファイルＲＥＡＤ処理
******************************************************************
 D20400S3-READ-SEC                   SECTION.
 D20400S3-READ-010.
     READ    D20400S3.
     EVALUATE    ST-D20400S3
         WHEN   "00"
           ADD   1               TO    CNT-IN
         WHEN   "10"
           MOVE    "END"         TO    SW-END
         WHEN    OTHER
           MOVE    "D20400S3"    TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-D20400S3   TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 D20400S3-READ-999.
     EXIT.
/*****************************************************************
*    受注ファイル（鑑）ＲＥＡＤ処理
******************************************************************
 JUTU-READ-SEC                   SECTION.
 JUTU-READ-010.
     MOVE    SEIBAN OF D20400S3  TO  SEIBAN OF AJUGFL1.
     READ    AJUGFL1.
     EVALUATE    ST-AJUGFL1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN    OTHER
           MOVE    "AJUGFL1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-AJUGFL1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 JUTU-READ-999.
     EXIT.
/*****************************************************************
*    受注ファイル（項目）ＲＥＡＤ処理
******************************************************************
 JUTUK-READ-SEC                   SECTION.
 JUTUK-READ-010.
     MOVE    SEIBAN OF D20400S3  TO  SEIBAN OF AJUKFL1.
     MOVE    KOMOKU OF D20400S3  TO  JYUKOU OF AJUKFL1.
     READ    AJUKFL1.
     EVALUATE    ST-AJUKFL1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN    OTHER
           MOVE    "AJUKFL1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-AJUKFL1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 JUTUK-READ-999.
     EXIT.
/*****************************************************************
*    製品区分マスタＲＥＡＤ処理
******************************************************************
 SHKB-READ-SEC                   SECTION.
 SHKB-READ-010.
     MOVE    SEIKBN OF AJUKFL1  TO  SEIKBN OF CSHKML1.
     READ    CSHKML1.
     EVALUATE    ST-CSHKML1
       WHEN  "00"
       WHEN  "23"
         CONTINUE
       WHEN  OTHER
         MOVE    "CSHKML1"       TO    WK-FILE
         MOVE    "READ"          TO    WK-SYORI
         MOVE    ST-CSHKML1      TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-EVALUATE.
 SHKB-READ-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
     IF  PRT-STATUS  NOT =   "00"
       THEN
         MOVE    "XU04LP"        TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    PRT-STATUS      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-D20400S3  NOT =   "00"
       THEN
         MOVE    "D20400S3"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D20400S3     TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-AJUGFL1   NOT =   "00"
       THEN
         MOVE    "AJUGFL1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-AJUGFL1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-AJUKFL1   NOT =   "00"
       THEN
         MOVE    "AJUKFL1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-AJUKFL1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-CSHKML1   NOT =   "00"
       THEN
         MOVE    "CSHKML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CSHKML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
/*****************************************************************
*    ＡＢＥＮＤ処理
******************************************************************
 ABEND-SEC                       SECTION.
 ABEND-010.
     DISPLAY "*****  " WK-FILE  " " WK-SYORI "  ERR  *****"
                                                     UPON    DSP.
     DISPLAY "*     F-STS           = " WK-STATUS "        *"
                                                     UPON    DSP.
     DISPLAY "***** " WK-PGMID "  " WK-VER " ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM SEMICH04.
