*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０１７０ＰＰ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　抽出条件の作業実績ファイルからなる中間ファイ
*                   ルにより完成品未出荷明細表を作成する
*
*                                               作成日：93.04.07
*                                               更新日：93.12.21
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  中間ファイル　　　　　　　　<D2016XS1 >
*                   受注ファイル（鑑）　　　　　<AJUGFL1  >
*                   製品区分マスタ    　　　　　<CSHKML1  >
*                   取引先マスタ　    　　　　　<ATORML1  >
*                   組織マスタ　　    　　　　　<ASOSML1  >
* ＊＊＊　リスト情報　　＊＊＊
*  SMED NAME    ：  完成品未出荷明細表　　　　　<XU04LP  >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20170PP.
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
*    完成品未出荷明細表
     SELECT      XU04LP     ASSIGN       TO GS-XU04LP
                            SYMBOLIC DESTINATION IS "PRT"
                            FORMAT       IS PRT-FORMAT
                            GROUP        IS PRT-GROUP
                            PROCESSING MODE      IS PRT-MODE
                            UNIT       CONTROL   IS PRT-SEIGYO
                            FILE  STATUS IS PRT-STATUS.
*    中間ファイル　
     SELECT      D2016XS1   ASSIGN       TO DA-S-D2016XS1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D2016XS1.
*    受注ファイル（鑑）
     SELECT      AJUGFL1    ASSIGN       TO DA-VI-AJUGFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUGFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUGFL1.
*    製品区分マスタ
     SELECT      CSHKML1    ASSIGN       TO DA-VI-CSHKML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIKBN OF CSHKML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSHKML1.
*    取引先マスタ
     SELECT      ATORML1    ASSIGN       TO DA-VI-ATORML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS TORICD OF ATORML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ATORML1.
*    組織マスタ
     SELECT      ASOSML1    ASSIGN       TO DA-VI-ASOSML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS BSYOCD OF ASOSML1
                                            TANCD  OF ASOSML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOSML1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    完成品未出荷明細表
******************************************************************
 FD  XU04LP.
     COPY        D20170P1   OF   XMDLIB.
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D2016XS1    BLOCK      CONTAINS   102  RECORDS.
     COPY        D2016XS1   OF   XFDLIB.
/*****************************************************************
*    受注ファイル（鑑）
******************************************************************
 FD  AJUGFL1.
     COPY        AJUGFL1    OF   XFDLIB.
/*****************************************************************
*    製品区分マスタ
******************************************************************
 FD  CSHKML1.
     COPY        CSHKML1    OF   XFDLIB.
/*****************************************************************
*    取引先マスタ
******************************************************************
 FD  ATORML1.
     COPY        ATORML1    OF   XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1    OF   XFDLIB.
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
     03  ST-D2016XS1             PIC  X(002).
     03  ST-AJUGFL1              PIC  X(002).
     03  ST-CSHKML1              PIC  X(002).
     03  ST-ATORML1              PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYORI                PIC  X(007).
     03  WK-FILE                 PIC  X(008).
     03  WK-DATE                 PIC  9(006).
     03  WK-TIME                 PIC  9(008).
     03  WK-STATUS               PIC  X(002).
     03  WK-STATUS-R             REDEFINES     WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
     03  WK-SOSICD               PIC  X(004).
     03  WK-SEIBAN               PIC  X(006).
     03  WK-JYOTEI.
         05  WK-JYOTEI1          PIC S9(011).
         05  WK-JYOTEI2          PIC S9(011).
         05  WK-JYOTEI3          PIC S9(011).
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
 01  WK-PGMID                    PIC  X(008) VALUE "D20170PP".
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
     DISPLAY "*     D2016XS1 IN    =  " CNT-IN      "     *"
                                               UPON  DSP.
     DISPLAY "*     D20170P1 PAGE  =  " CNT-PAGE    "     *"
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
     OPEN        INPUT           D2016XS1
                                 AJUGFL1
                                 CSHKML1
                                 ATORML1
                                 ASOSML1.
     OPEN        OUTPUT          XU04LP.
*
     MOVE    "D20170P1"          TO    PRT-FORMAT.
     MOVE    "SCREEN"            TO    PRT-GROUP.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     ACCEPT-SEC.
     IF  SW-END      =   SPACE
       THEN
         PERFORM                 TUKN-READ-SEC
         MOVE  SOSICD OF D2016XS1
                                 TO    WK-SOSICD
         MOVE  SEIBAN OF D2016XS1
                                 TO    WK-SEIBAN
     END-IF.
     MOVE      1                 TO    IX-01.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     MOVE    SPACE               TO    D20170P1 OF XU04LP.
*
     PERFORM                     MEISAI-SET1-SEC.
*
     PERFORM UNTIL  ( SW-END     =     "END"               )
*****        OR     ( WK-SOSICD  NOT =  SOSICD OF D2016XS1 )
*****93.11.22修正
             OR     ( WK-SOSICD(1:2)  NOT =
                                   SOSICD OF D2016XS1(1:2))
*****93.11.22修正終了
             OR     ( IX-01      >      54                 )
*
         PERFORM                 MEISAI-SET2-SEC
         PERFORM                 TUKN-READ-SEC
*
         IF  ( WK-SEIBAN          =    SEIBAN OF D2016XS1 )  AND
*****        ( WK-SOSICD          =    SOSICD OF D2016XS1 )  AND
*****93.12.21修正
             ( WK-SOSICD(1:2)     =
                                   SOSICD OF D2016XS1(1:2))  AND
*****93.12.21修正終了
             ( SW-END            =    SPACE              )
           THEN
             IF  IX-01   =   55
               THEN
                 ADD     1      TO    IX-01
             END-IF
           ELSE
             PERFORM            MEISAI-SET3-SEC
         END-IF
     END-PERFORM.
*
     IF  ( SW-END               =  "END"               )  OR
*****    ( WK-SOSICD        NOT =   SOSICD OF D2016XS1 )
*****93.12.21修正
         ( WK-SOSICD(1:2)   NOT =
                                SOSICD OF D2016XS1(1:2))
*****93.12.21修正終了
       THEN
         PERFORM                MEISAI-SET4-SEC
     END-IF.
     PERFORM                    PRT-WRITE-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE       XU04LP
                 D2016XS1
                 AJUGFL1
                 CSHKML1
                 ATORML1
                 ASOSML1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    明細セット処理１（見出し）
******************************************************************
 MEISAI-SET1-SEC                 SECTION.
 MEISAI-SET1-010.
*    作成日
     MOVE    WK-DATE             TO    SYRBI  OF D20170P1.
*    時間
     MOVE    WK-TIME(1:2)        TO    JIKAN1 OF D20170P1.
     MOVE    WK-TIME(3:2)        TO    JIKAN2 OF D20170P1.
*    ページ
     ADD     1                   TO    CNT-PAGE.
     MOVE    CNT-PAGE            TO    PAGCNT OF D20170P1.
*
*    営業所
     PERFORM                     SOSK-READ-SEC.
     IF  ST-ASOSML1      =   "00"
       THEN
         MOVE  BSYNAM OF ASOSML1 TO    BSYNAM OF D20170P1
     END-IF.
 MEISAI-SET1-999.
     EXIT.
/*****************************************************************
*    明細セット処理２（明細行）
******************************************************************
 MEISAI-SET2-SEC                 SECTION.
 MEISAI-SET2-010.
     IF  SW-WRITE    =   SPACE
       THEN
         PERFORM                 SEIBAN-SET-SEC
         MOVE    "1"             TO    SW-WRITE
     END-IF.
*
*    製品区分
     PERFORM                     SHKB-READ-SEC.
     IF  ST-CSHKML1      =   "00"
       THEN
         MOVE  SRYAKU OF CSHKML1 TO    SRYAKU OF D20170P1(IX-01)
     END-IF.
*    項目
     MOVE  KOMOKU OF D2016XS1    TO    KOMOKU OF D20170P1(IX-01).
*
*    受注金額・仮売上
     MOVE  JYOTEI OF D2016XS1    TO    WK-JYOTEI1.
     COMPUTE      WK-JYOTEI1     =     WK-JYOTEI1
                                 /     1000.
     MOVE    WK-JYOTEI1          TO    JYOTEI OF D20170P1(IX-01).
*
     IF  KURIFG  OF  D2016XS1    =    "1"
       THEN
         MOVE    NC"＊"          TO    KURIFG OF D20170P1(IX-01)
       ELSE
         COMPUTE WK-JYOTEI2      =     WK-JYOTEI2  +  WK-JYOTEI1
         COMPUTE WK-JYOTEI3      =     WK-JYOTEI3  +  WK-JYOTEI1
     END-IF.
*    生産計上日
     MOVE  KJSKBI OF D2016XS1    TO    KJSKBI OF D20170P1(IX-01).
*    納期
     MOVE  KANNOK OF D2016XS1    TO    KANNOK OF D20170P1(IX-01).
     ADD   1                     TO    IX-01.
 MEISAI-SET2-999.
     EXIT.
/*****************************************************************
*    明細セット処理３（製番計）
******************************************************************
 MEISAI-SET3-SEC                 SECTION.
 MEISAI-SET3-010.
     MOVE    NC"【製番計】"      TO   TRNAS2 OF D20170P1(IX-01).
     MOVE    WK-JYOTEI2          TO   JYOTEI OF D20170P1(IX-01).
     MOVE    ZERO                TO   WK-JYOTEI2.
     MOVE    SEIBAN OF D2016XS1  TO   WK-SEIBAN.
     MOVE    SPACE               TO   SW-WRITE.
     ADD     1                   TO   IX-01.
 MEISAI-SET3-999.
     EXIT.
/*****************************************************************
*    明細セット処理４（営業所計）
******************************************************************
 MEISAI-SET4-SEC                 SECTION.
 MEISAI-SET4-010.
     MOVE    NC"【"              TO   TRNAS1 OF D20170P1(IX-01).
     MOVE    NC"営業所計】"      TO   TRNAS2 OF D20170P1(IX-01).
     MOVE    WK-JYOTEI3          TO   JYOTEI OF D20170P1(IX-01).
     MOVE    ZERO                TO   WK-JYOTEI3.
     MOVE    SOSICD OF D2016XS1  TO   WK-SOSICD.
     MOVE    SEIBAN OF D2016XS1  TO   WK-SEIBAN.
     MOVE    1                   TO   IX-01.
 MEISAI-SET4-999.
     EXIT.
/*****************************************************************
*    製番セット処理（営業所コード、製番ブレイク時）
******************************************************************
 SEIBAN-SET-SEC                  SECTION.
 SEIBAN-SET-010.
*    製番
     MOVE  SEIBAN OF D2016XS1(1:1)
                                 TO    SEIBN1 OF D20170P1(IX-01).
     MOVE  "-"                   TO    SEIBN2 OF D20170P1(IX-01).
     MOVE  SEIBAN OF D2016XS1(2:5)
                                 TO    SEIBN3 OF D20170P1(IX-01).
*    件名・受注先
     PERFORM                     JUTU-READ-SEC.
     IF  ST-AJUGFL1         =   "00"
       THEN
         MOVE  KENMEI OF AJUGFL1 TO    KENMEI OF D20170P1(IX-01)
         PERFORM                 TORI-READ-SEC
         IF  ST-ATORML1     =   "00"
           THEN
             MOVE  TORNAS OF ATORML1
                                 TO    TRNAS2 OF D20170P1(IX-01)
         END-IF
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
         WRITE   D20170P1
     END-IF.
*
*    内容印字
     MOVE     "SCREEN"           TO    PRT-GROUP.
     MOVE      SPACE             TO    PRT-MODE.
     MOVE      SPACE             TO    PRT-SEIGYO.
     WRITE     D20170P1.
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
 TUKN-READ-SEC                   SECTION.
 TUKN-READ-010.
     READ    D2016XS1.
     EVALUATE    ST-D2016XS1
         WHEN   "00"
           ADD   1               TO    CNT-IN
         WHEN   "10"
           MOVE    "END"         TO    SW-END
         WHEN    OTHER
           MOVE    "D2016XS1"    TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-D2016XS1   TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 TUKN-READ-999.
     EXIT.
/*****************************************************************
*    受注ファイル（鑑）ＲＥＡＤ処理
******************************************************************
 JUTU-READ-SEC                   SECTION.
 JUTU-READ-010.
     MOVE    SEIBAN OF D2016XS1  TO    SEIBAN OF AJUGFL1.
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
*    製品区分マスタＲＥＡＤ処理
******************************************************************
 SHKB-READ-SEC                   SECTION.
 SHKB-READ-010.
     MOVE    SEIKBN OF D2016XS1  TO    SEIKBN OF CSHKML1.
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
*    取引先マスタＲＥＡＤ処理
******************************************************************
 TORI-READ-SEC                   SECTION.
 TORI-READ-010.
     MOVE    JCYUCD OF AJUGFL1   TO    TORICD OF ATORML1.
     READ    ATORML1.
     EVALUATE    ST-ATORML1
         WHEN  "00"
         WHEN  "23"
           CONTINUE
         WHEN  OTHER
           MOVE    "ATORML1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-ATORML1    TO    WK-STATUS
           PERFORM ABEND-SEC
     END-EVALUATE.
 TORI-READ-999.
     EXIT.
/*****************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     MOVE    SOSICD OF D2016XS1(1:2)
                                 TO    BSYOCD OF ASOSML1.
*****93.11.24修正_
*****MOVE    SOSICD OF D2016XS1(3:2)
*****                            TO    TANCD  OF ASOSML1.
     MOVE    "00"                TO    TANCD  OF ASOSML1.
*****93.11.24修正_
     READ    ASOSML1.
     EVALUATE    ST-ASOSML1
         WHEN  "00"
         WHEN  "23"
           CONTINUE
         WHEN  OTHER
           MOVE    "ASOSML1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-ASOSML1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 SOSK-READ-999.
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
     IF  ST-D2016XS1  NOT =   "00"
       THEN
         MOVE    "D2016XS1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D2016XS1     TO    WK-STATUS
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
     IF  ST-CSHKML1   NOT =   "00"
       THEN
         MOVE    "CSHKML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CSHKML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-ATORML1   NOT =   "00"
       THEN
         MOVE    "ATORML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-ATORML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-ASOSML1   NOT =   "00"
       THEN
         MOVE    "ASOSML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-ASOSML1      TO    WK-STATUS
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
 END PROGRAM D20170PP.
