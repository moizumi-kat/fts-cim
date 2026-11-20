*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０２３０ＰＰ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　抽出条件からなる中間ファイルより生産日報を
*                   作成する
*
*                                               作成日：93.04.21
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  中間ファイル　　　　　　　　<D20220S1 >
*                   製品区分マスタ    　　　　　<CSHKML1  >
*                   組織マスタ　　    　　　　　<ASOSML1  >
* ＊＊＊　リスト情報　　＊＊＊
*  SMED NAME    ：  生産日報                    <XU04LP  >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20230PP.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
*SOURCE-COMPUTER.           FACOM  K6700.
*OBJECT-COMPUTER.           FACOM  K6700.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
     CONSOLE     IS         DSP
     YA-21       IS         YA-21.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    生産日報　　　　　
     SELECT      XU04LP     ASSIGN       TO LP-04
                            FILE  STATUS IS PRT-STATUS.
*    中間ファイル　
     SELECT      D20220S1   ASSIGN       TO DA-S-D20220S1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D20220S1.
*    製品区分マスタ
     SELECT      CSHKML1    ASSIGN       TO DA-VI-CSHKML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIKBN OF CSHKML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSHKML1.
*    組織マスタ
     SELECT      ASOSML1    ASSIGN       TO DA-VI-ASOSML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SOSICD OF ASOSML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOSML1.
*    運用条件ファイル
     SELECT      AJKNML1    ASSIGN       TO DA-VI-AJKNML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JKNKBN OF AJKNML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJKNML1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    生産日報
******************************************************************
 FD  XU04LP.
 01  D20230P1.
     03  FILLER                  PIC  X(300).
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D20220S1    BLOCK           CONTAINS   170  RECORDS.
     COPY        D20220S1       OF   XFDLIB.
/*****************************************************************
*    製品区分マスタ
******************************************************************
 FD  CSHKML1.
     COPY        CSHKML1         OF   XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1         OF   XFDLIB.
/*****************************************************************
*    運用条件ファイル
******************************************************************
 FD  AJKNML1.
     COPY        AJKNML1    OF   XFDLIB.
/*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  PRT-ITEM.
     03  PRT-STATUS              PIC  X(002).
     03  ST-D20220S1             PIC  X(002).
     03  ST-CSHKML1              PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
     03  ST-AJKNML1              PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYORI                PIC  X(007).
     03  WK-FILE                 PIC  X(008).
     03  WK-DATE                 PIC  9(006).
     03  WORK-DATE.
         05  WORK-YY             PIC  9(002).
         05  WORK-MM             PIC  9(002).
         05  WORK-DD             PIC  9(002).
     03  WK-TIME                 PIC  9(008).
     03  WK-SBSSCD               PIC  X(004).
     03  WK-SRYAKU.
         05  WK-SRYAKU1          PIC  N(005).
         05  WK-SRYAKU2          PIC  N(005).
     03  WK-SETOU.
         05  WK-SETOUS           PIC S9(011).
         05  WK-SETOUZ           PIC S9(011).
         05  WK-SETOUR           PIC S9(011).
         05  WK-SETTBL           OCCURS  9.
             07  WK-SETOU1       PIC S9(011).
             07  WK-SETOU2       PIC S9(011).
             07  WK-SETOU3       PIC S9(011).
     03  WK-STATUS               PIC  X(002).
     03  WK-STATUS-R             REDEFINES     WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
*    添字
 01  IX-AREA.
     03  IX-01                   PIC  9(002).
     03  IX-02                   PIC  9(002).
     03  IX-03                   PIC  9(002).
     03  IX-04                   PIC  9(002).
*    カウンター
 01  CNT-AREA.
     03  CNT-PAGE                PIC  9(005).
     03  CNT-LINE                PIC  9(002).
     03  CNT-IN                  PIC  9(005).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20230PP".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
*
*--- 生産日報出力領域 -----------------------------------------*
 01  HEAD-01                     CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(005) VALUE SPACE.
     03  FILLER                  PIC  X(008) VALUE "D20230P1".
     03  FILLER                  PIC  X(080) VALUE SPACE.
     03  FILLER                  PIC  X(013) VALUE SPACE.
     03  FILLER                  PIC  N(003) VALUE NC"作成日".
     03  FILLER                  PIC  X(001) VALUE ":".
     03  HD-CRTYY                PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-CRTMM                PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-CRTDD                PIC  9(002).
***  03  FILLER                  PIC  X(003) VALUE SPACE.
***  03  FILLER                  PIC  N(002) VALUE NC"時間".
***  03  FILLER                  PIC  X(001) VALUE SPACE.
***  03  HD-HH                   PIC  9(002).
***  03  FILLER                  PIC  X(001) VALUE ".".
***  03  HD-MM                   PIC  9(002).
     03  FILLER                  PIC  X(002) VALUE SPACE.
     03  FILLER                  PIC  X(005) VALUE "PAGE:".
     03  HD-PAGE                 PIC  ZZZ9.
*
 01  HEAD-02.
     03  FILLER                  PIC  X(045) VALUE SPACE.
     03  FILLER                  PIC  N(010) VALUE
                                 NC"※※　生産日報　※※"
                                 CHARACTER   TYPE  IS  YA-21.
     03  FILLER                  PIC  X(034) VALUE SPACE.
     03  FILLER                  PIC  N(007) VALUE
                                 NC"金額単位：千円"
                                 CHARACTER   TYPE  IS  MODE-1.
*    職場名設定行
 01  HEAD-03                     CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(004) VALUE "  ! ".
     03  FILLER                  PIC  N(003) VALUE NC"職場名".
     03  FILLER                  PIC  X(014) VALUE SPACE.
     03  FILLER                  PIC  X(002) VALUE "! ".
     03  HD-SEIKBN               OCCURS  9.
         05  HD-SEINM            PIC  N(005).
         05  FILLER              PIC  X(002) VALUE " !".
*
*    明細設定行
 01  BODY-01                     CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(004) VALUE "  ! ".
     03  BD-BSYNAM               PIC  N(010).
     03  FILLER                  PIC  X(002) VALUE "! ".
     03  BD-KINGAK               OCCURS   9.
         05  BD-KINGK            PIC  ---,---,---.
         05  FILLER              PIC  X(001) VALUE "!".
*
*    罫線設定行
 01  LINE-01.
     03  FILLER                  PIC  X(002) VALUE SPACE.
     03  FILLER                  PIC  X(132) VALUE ALL "-".
 01  LINE-02.
     03  FILLER                  PIC  X(003) VALUE "  !".
     03  FILLER                  PIC  X(021) VALUE ALL "-".
     03  FILLER                  PIC  X(002) VALUE "+-".
     03  FIL-OCC                 OCCURS   8.
         05  FILLER              PIC  X(011) VALUE ALL "-".
         05  FILLER              PIC  X(001) VALUE "+".
     03  FILLER                  PIC  X(011) VALUE ALL "-".
     03  FILLER                  PIC  X(001) VALUE "!".
 01  LINE-02A.
     03  FILLER                  PIC  X(003) VALUE "  !".
     03  FILLER                  PIC  X(021) VALUE ALL "=".
     03  FILLER                  PIC  X(002) VALUE "+=".
     03  FIL-OCC                 OCCURS   8.
         05  FILLER              PIC  X(011) VALUE ALL "=".
         05  FILLER              PIC  X(001) VALUE "+".
     03  FILLER                  PIC  X(011) VALUE ALL "=".
     03  FILLER                  PIC  X(001) VALUE "!".
 01  LINE-03.
     03  FILLER                  PIC  X(003) VALUE "  !".
     03  FILLER                  PIC  X(021) VALUE SPACE.
     03  FILLER                  PIC  X(002) VALUE "! ".
     03  FIL-OCC                 OCCURS   8.
         05  FILLER              PIC  X(011) VALUE SPACE.
         05  FILLER              PIC  X(001) VALUE "!".
     03  FILLER                  PIC  X(011) VALUE SPACE.
     03  FILLER                  PIC  X(001) VALUE "!".
/
 LINKAGE                         SECTION.
 01  LINK-YYMMDD                 PIC S9(009) BINARY.
 PROCEDURE                       DIVISION
                                 USING       LINK-YYMMDD.
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
     DISPLAY "*     D20220S1 IN    =  " CNT-IN      "     *"
                                               UPON  DSP.
     DISPLAY "*     D20230P1 PAGE  =  " CNT-PAGE    "     *"
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
     OPEN        INPUT           D20220S1
                                 CSHKML1
                                 AJKNML1
                                 ASOSML1.
     OPEN        OUTPUT          XU04LP.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     ACCEPT-SEC.
*
     PERFORM                     TUKN-READ-SEC.
     PERFORM   UNTIL ( SBSSCD OF D20220S1(1:1)   >   "3"   )
               OR    ( SW-END                    =   "END" )
               PERFORM           TUKN-READ-SEC
     END-PERFORM.
*
     IF  SW-END  NOT =   "END"
     THEN
       MOVE  SBSSCD OF D20220S1  TO    WK-SBSSCD
       PERFORM                   HEAD-SET-SEC
     END-IF.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
*
     PERFORM UNTIL  ( SW-END         =   "END"                )
             OR     ( WK-SBSSCD  NOT =   SBSSCD  OF  D20220S1 )
*        明細退避
         PERFORM                 TAIHI1-SEC
     END-PERFORM.
*
*    小計／総合計退避
     PERFORM                     TAIHI2-SEC.
*****IF      WK-SBSSCD(1:1)      NOT =   "9"
*****  THEN
         PERFORM                 MEISAI-SET-SEC
*****END-IF.
*
     IF      CNT-LINE            >=  60
     THEN
       PERFORM                   HEAD-SET-SEC
     END-IF.
*
     IF (( SBSSCD OF D20220S1(1:1)    =   "8" )    AND
         ( WK-SBSSCD                  <   "8" ))   OR
        (( SBSSCD OF D20220S1(1:1)    =   "9" )    AND
         ( WK-SBSSCD                  <   "9" ))   OR
         ( SW-END                     =   "END")
       THEN
         PERFORM                 GOKEI-SET-SEC
     END-IF.
*
     IF      CNT-LINE            >=  60
     THEN
       PERFORM                   HEAD-SET-SEC
     END-IF.
*
     MOVE    SBSSCD OF D20220S1  TO    WK-SBSSCD.
     IF      SW-END              =     "END"
     THEN
       PERFORM                   SOGOKEI-SET-SEC
     END-IF.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       XU04LP
                                 D20220S1
                                 CSHKML1
                                 AJKNML1
                                 ASOSML1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    ヘッダ部設定処理（見出し編集）
******************************************************************
 HEAD-SET-SEC                    SECTION.
 HEAD-SET-010.
*
     IF      CNT-PAGE            >     0
     THEN
       WRITE    D20230P1         AFTER PAGE
     END-IF.
*
***  作成日
     IF      LINK-YYMMDD         =     ZERO
       THEN
         CONTINUE
       ELSE
         MOVE    LINK-YYMMDD     TO    WK-DATE
     END-IF.
     MOVE    WK-DATE(1:2)        TO    HD-CRTYY.
     MOVE    WK-DATE(3:2)        TO    HD-CRTMM.
     MOVE    WK-DATE(5:2)        TO    HD-CRTDD.
*    時間
***  MOVE    WK-TIME(1:2)        TO    HD-HH.
***  MOVE    WK-TIME(3:2)        TO    HD-MM.
*    ページ
     ADD     1                   TO    CNT-PAGE.
     MOVE    CNT-PAGE            TO    HD-PAGE.
*
*＊ 製品区分名称を設定している所です＊＊＊＊＊ ＳＴＲ
*    製品区分名設定（製品区分マスタより）
     PERFORM    VARYING  IX-02   FROM  1   BY  1
                UNTIL    IX-02   >     7
*
         EVALUATE  IX-02
             WHEN  1
                 MOVE    "01"    TO    SEIKBN OF CSHKML1
             WHEN  2
                 MOVE    "02"    TO    SEIKBN OF CSHKML1
             WHEN  3
                 MOVE    "03"    TO    SEIKBN OF CSHKML1
             WHEN  4
                 MOVE    "04"    TO    SEIKBN OF CSHKML1
             WHEN  5
                 MOVE    "06"    TO    SEIKBN OF CSHKML1
             WHEN  6
                 MOVE    "10"    TO    SEIKBN OF CSHKML1
             WHEN  7
                 MOVE    "12"    TO    SEIKBN OF CSHKML1
         END-EVALUATE
*
         PERFORM                 SHKB-READ-SEC
         IF      ST-CSHKML1      =   "00"
         THEN
           MOVE  SRYAKU OF CSHKML1
                                 TO    WK-SRYAKU1
           MOVE  SPACE           TO    WK-SRYAKU2
           MOVE  5               TO    IX-04
*
           PERFORM  VARYING   IX-03    FROM  5  BY  -1
                    UNTIL     IX-03    <     1

               IF         WK-SRYAKU1(IX-03:1) NOT =   SPACE
               THEN
                 MOVE     WK-SRYAKU1(IX-03:1)
                                 TO    WK-SRYAKU2(IX-04:1)
                 COMPUTE  IX-04  =     IX-04      -   1
               END-IF
           END-PERFORM
*
           MOVE    WK-SRYAKU2    TO    HD-SEINM (IX-02)
         END-IF
     END-PERFORM.
*＊ 製品区分名称を設定している所です＊＊＊＊＊ ＥＮＤ
*
     MOVE    NC"　　当日計"      TO    HD-SEINM (8).
     MOVE    NC"　当月累計"      TO    HD-SEINM (9).
*
     WRITE   D20230P1            FROM  HEAD-01   AFTER     1.
     WRITE   D20230P1            FROM  HEAD-02   AFTER     1.
     WRITE   D20230P1            FROM  LINE-01   AFTER     2.
     WRITE   D20230P1            FROM  HEAD-03   AFTER     1.
     WRITE   D20230P1            FROM  LINE-03   AFTER     1.
     WRITE   D20230P1            FROM  LINE-02A  AFTER     1.
     MOVE    7                   TO    CNT-LINE.
*
 HEAD-SET-999.
     EXIT.
/*****************************************************************
*    明細セット処理
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
*
     INITIALIZE                  BODY-01.
*    職場名設定（組織マスタより）
     PERFORM                     SOSK-READ-SEC.
     IF      ST-ASOSML1  =  "00"
     THEN
       MOVE  BSYNAM OF ASOSML1   TO    BD-BSYNAM
     END-IF.
*
     PERFORM   VARYING  IX-01    FROM  1      BY 1
               UNTIL    IX-01    >     9
*
               COMPUTE  WK-SETOU1(IX-01)
                     =  WK-SETOU1(IX-01)      /  1000
*
               MOVE     WK-SETOU1(IX-01)
                                 TO    BD-KINGK (IX-01)
               MOVE     ZERO     TO    WK-SETOU1(IX-01)
     END-PERFORM.
*
     WRITE   D20230P1            FROM  LINE-03   AFTER     1.
     ADD     1                   TO    CNT-LINE.
     WRITE   D20230P1            FROM  BODY-01   AFTER     1.
     ADD     1                   TO    CNT-LINE.
     WRITE   D20230P1            FROM  LINE-02   AFTER     1.
     ADD     1                   TO    CNT-LINE.
     MOVE    SPACE               TO    D20230P1.
 MEISAI-SET-999.
     EXIT.
/*****************************************************************
*    合計セット処理（小計／ＧＳ編集）
******************************************************************
 GOKEI-SET-SEC                   SECTION.
 GOKEI-SET-010.
*
     IF  WK-SBSSCD(1:1)      =   "9"
       THEN
         CONTINUE
******   MOVE  NC"Ｇ　Ｓ"        TO    BD-BSYNAM
       ELSE
         MOVE  NC"小　計"        TO    BD-BSYNAM
     END-IF.
*
     PERFORM   VARYING  IX-01    FROM  1      BY 1
               UNTIL    IX-01    >     9
*
               COMPUTE  WK-SETOU2(IX-01)
                     =  WK-SETOU2(IX-01)      /  1000
*
               MOVE     WK-SETOU2(IX-01)
                                 TO    BD-KINGK (IX-01)
               MOVE     ZERO     TO    WK-SETOU2(IX-01)
     END-PERFORM.
*
     IF      WK-SBSSCD(1:1)      =   "9"
     THEN
       CONTINUE
****** WRITE   D20230P1          FROM  LINE-03   AFTER     1
****** WRITE   D20230P1          FROM  BODY-01   AFTER     1
****** WRITE   D20230P1          FROM  LINE-02   AFTER     1
****** ADD     3                 TO    CNT-LINE
     ELSE
       WRITE   D20230P1          FROM  LINE-03   AFTER     1
       WRITE   D20230P1          FROM  LINE-03   AFTER     1
       WRITE   D20230P1          FROM  BODY-01   AFTER     1
       WRITE   D20230P1          FROM  LINE-02   AFTER     1
       ADD     4                 TO    CNT-LINE
     END-IF.
 GOKEI-SET-999.
     EXIT.
/*****************************************************************
*    総合計セット処理
******************************************************************
 SOGOKEI-SET-SEC                 SECTION.
 SOGOKEI-SET-010.
*
     MOVE    NC"総合計"          TO    BD-BSYNAM.
*
     PERFORM   VARYING  IX-01    FROM  1      BY 1
               UNTIL    IX-01    >     9
*
               COMPUTE  WK-SETOU3(IX-01)
                     =  WK-SETOU3(IX-01)      /  1000
*
               MOVE     WK-SETOU3(IX-01)
                                 TO    BD-KINGK (IX-01)
               MOVE     ZERO     TO    WK-SETOU3(IX-01)
     END-PERFORM.
*
     WRITE     D20230P1          FROM  LINE-03   AFTER     1.
     WRITE     D20230P1          FROM  LINE-03   AFTER     1.
     WRITE     D20230P1          FROM  BODY-01   AFTER     1.
     WRITE     D20230P1          FROM  LINE-01   AFTER     1.
*
 SOGOKEI-SET-999.
     EXIT.
/*****************************************************************
*    職場生産集計コード毎退避処理
******************************************************************
 TAIHI1-SEC                      SECTION.
 TAIHI1-010.
     MOVE    SETOUS OF D20220S1  TO    WK-SETOUS.
     MOVE    SETOUZ OF D20220S1  TO    WK-SETOUZ.
     MOVE    SETOUR OF D20220S1  TO    WK-SETOUR.
*
     EVALUATE  SKSRCD OF D20220S1
         WHEN  "01"
           COMPUTE WK-SETOU1(1)  =     WK-SETOU1(1)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
         WHEN    "02"
           COMPUTE WK-SETOU1(2)  =     WK-SETOU1(2)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
         WHEN    "03"
           COMPUTE WK-SETOU1(3)  =     WK-SETOU1(3)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
         WHEN    "04"
           COMPUTE WK-SETOU1(4)  =     WK-SETOU1(4)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
         WHEN    "06"
           COMPUTE WK-SETOU1(5)  =     WK-SETOU1(5)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
         WHEN    "10"
           COMPUTE WK-SETOU1(6)  =     WK-SETOU1(6)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
         WHEN    "12"
           COMPUTE WK-SETOU1(7)  =     WK-SETOU1(7)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(8)  =     WK-SETOU1(8)  +  WK-SETOUS
                                                     +  WK-SETOUZ
           COMPUTE WK-SETOU1(9)  =     WK-SETOU1(9)  +  WK-SETOUR
     END-EVALUATE.
*
     PERFORM                     TUKN-READ-SEC.
 TAIHI1-999.
     EXIT.
/*****************************************************************
*    小計総合計退避処理
******************************************************************
 TAIHI2-SEC                      SECTION.
 TAIHI2-010.
     PERFORM    VARYING   IX-01  FROM   1   BY  1
                UNTIL     IX-01  >      9
*
        COMPUTE WK-SETOU2(IX-01) =
                WK-SETOU2(IX-01) +     WK-SETOU1(IX-01)
        COMPUTE WK-SETOU3(IX-01) =
                WK-SETOU3(IX-01) +     WK-SETOU1(IX-01)
     END-PERFORM.
 TAIHI2-999.
     EXIT.
/*****************************************************************
*    中間ファイルＲＥＡＤ処理
******************************************************************
 TUKN-READ-SEC                   SECTION.
 TUKN-READ-010.
     READ      D20220S1.
     EVALUATE  ST-D20220S1
         WHEN  "00"
               ADD    1          TO    CNT-IN
         WHEN  "10"
               MOVE  "END"       TO    SW-END
         WHEN  OTHER
               MOVE  "D20220S1"  TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-D20220S1 TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 TUKN-READ-999.
     EXIT.
/*****************************************************************
*    製品区分マスタＲＥＡＤ処理
******************************************************************
 SHKB-READ-SEC                   SECTION.
 SHKB-READ-010.
     READ      CSHKML1.
     EVALUATE  ST-CSHKML1
         WHEN  "00"
         WHEN  "23"
             CONTINUE
         WHEN   OTHER
             MOVE  "CSHKML1"     TO    WK-FILE
             MOVE  "READ"        TO    WK-SYORI
             MOVE   ST-CSHKML1   TO    WK-STATUS
             PERFORM             ABEND-SEC
     END-EVALUATE.
 SHKB-READ-999.
     EXIT.
/*****************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     MOVE    WK-SBSSCD           TO    SOSICD OF ASOSML1.
     READ       ASOSML1.
     EVALUATE   ST-ASOSML1
         WHEN  "00"
         WHEN  "23"
             CONTINUE
         WHEN   OTHER
             MOVE  "ASOSML1"     TO    WK-FILE
             MOVE  "READ"        TO    WK-SYORI
             MOVE   ST-ASOSML1   TO    WK-STATUS
             PERFORM ABEND-SEC
     END-EVALUATE.
 SOSK-READ-999.
     EXIT.
/*****************************************************************
*    運用条件ファイル　　ＲＥＡＤ処理(RAN)
******************************************************************
 AJKNML1-READ-RTN                SECTION.
*
     MOVE    "0"                 TO    JKNKBN OF AJKNML1.
     READ    AJKNML1.
*
     EVALUATE  ST-AJKNML1
         WHEN  "00"
               CONTINUE
         WHEN  OTHER
               MOVE  "AJKNML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-AJKNML1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 AJKNML1-READ-EXIT.
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
*--＜日報用中間ファイル＞
     IF  ST-D20220S1  NOT =   "00"
       THEN
         MOVE    "D20220S1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D20220S1     TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*--＜製品区分マスタ＞
     IF  ST-CSHKML1   NOT =   "00"
       THEN
         MOVE    "CSHKML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CSHKML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*--＜組織マスタ＞
     IF  ST-ASOSML1   NOT =   "00"
       THEN
         MOVE    "ASOSML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-ASOSML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*--＜運用条件ファイル＞
     IF         ST-AJKNML1       NOT =   "00"
     THEN
       MOVE    "AJKNML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AJKNML1       TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
/*****************************************************************
*    日付＆時間の取得＆セット処理
******************************************************************
 ACCEPT-SEC                      SECTION.
 ACCEPT-010.
     PERFORM   AJKNML1-READ-RTN.
     MOVE    YY1 OF AJKNML1(3:2) TO    WORK-YY
     MOVE    MM1 OF AJKNML1      TO    WORK-MM
     MOVE    DD1 OF AJKNML1      TO    WORK-DD
     MOVE    WORK-DATE           TO    WK-DATE
     ACCEPT    WK-TIME           FROM    TIME.
 ACCEPT-999.
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
 END PROGRAM D20230PP.
