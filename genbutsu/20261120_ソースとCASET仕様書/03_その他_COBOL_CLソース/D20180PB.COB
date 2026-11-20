*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０１８０ＰＢ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　中間ファイル（完成品未出荷抽出）の実績集計コ
*                   ードを生産集計コードに変換し、営業所コード、
*                   金額を中間ファイル（未出荷データコード変換）
*                   に出力する。
*
*                                               作成日：93.04.14
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  中間ファイル（完成品未出荷抽出）<D2016XS1>
*                   組織マスタ                      <ASOSML1  >
*                   中間ファイル                    <D2018XS1 >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20180PB.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
        CONSOLE   IS        DSP.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    中間ファイル（完成品未出荷抽出）
     SELECT      D2016XS1   ASSIGN       TO DA-S-D2016XS1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D2016XS1.
*    組織マスタ
     SELECT      ASOSML1    ASSIGN       TO DA-VI-ASOSML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SOSICD OF ASOSML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOSML1.
*    中間ファイル（未出荷データコード変換）
     SELECT      D2018XS1   ASSIGN       TO DA-S-D2018XS1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D2018XS1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    中間ファイル（完成品未出荷抽出）
******************************************************************
 FD  D2016XS1    BLOCK      CONTAINS   102  RECORDS.
     COPY        D2016XS1   OF   XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1    OF   XFDLIB.
/*****************************************************************
*    中間ファイル（未出荷データコード変換）
******************************************************************
 FD  D2018XS1    BLOCK      CONTAINS   240  RECORDS.
     COPY        D2018XS1   OF   XFDLIB.
*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  ST-AREA.
     03  ST-D2016XS1             PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
     03  ST-D2018XS1             PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-ABEND.
         05  WK-KEY.
             07  WK-KEY1         PIC  X(015).
         05  WK-SYORI            PIC  X(007).
         05  WK-FILE             PIC  X(008).
*
     03  WK-STATUS               PIC  X(002).
     03  WK-STATSU-R             REDEFINES   WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
*    カウンタ
 01  CNT-AREA.
     03  CNT-IN                  PIC  9(005).
     03  CNT-OUT                 PIC  9(005).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20180PB".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
/
 PROCEDURE                       DIVISION.
******************************************************************
*    メイン　ルーチン                      (1.0)
******************************************************************
 CTRL-SEC                        SECTION.
 CTRL-010.
     DISPLAY "***** "   WK-PGMID  " " WK-VER "  START *****"
                                                 UPON    DSP.
     PERFORM INIT-SEC.
     PERFORM MAIN-SEC    UNTIL   SW-END  = "END".
     PERFORM FINAL-SEC.
*
     DISPLAY "*     D2016XS1 IN =   " CNT-IN  "       *"
                                                 UPON    DSP.
     DISPLAY "*     D2018XS1 OUT=   " CNT-OUT "       *"
                                                 UPON    DSP.
     DISPLAY "***** "   WK-PGMID  " " WK-VER "  END   *****"
                                                 UPON    DSP.
 CTRL-999.
     STOP    RUN.
/*****************************************************************
*    前　処　理
******************************************************************
 INIT-SEC                        SECTION.
 INIT-010.
*    作業領域初期化
     INITIALIZE                  ST-AREA   WORK-AREA
                                 CNT-AREA  SW-AREA.
*
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN      INPUT             D2016XS1
                                 ASOSML1.
     OPEN      OUTPUT            D2018XS1.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     TUKN-READ-SEC.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     PERFORM                     MEISAI-SET-SEC.
     PERFORM                     RECORD-OUT-SEC.
     PERFORM                     TUKN-READ-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       D2016XS1
                                 ASOSML1
                                 D2018XS1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    明細セット処理
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
     INITIALIZE                  D201FD OF D2018XS1.
*    出力順コード
     MOVE    OUTJUN OF D2016XS1  TO    OUTJUN OF D2018XS1.
*    営業所コード
     MOVE    SOSICD OF D2016XS1  TO    SOSICD OF D2018XS1.
*    生産累計コード
     PERFORM                     SOSK-READ-SEC.
     IF  ST-ASOSML1  = "00"
       THEN
         MOVE  SYUCD OF ASOSML1  TO    SYUCD  OF D2018XS1
     END-IF.
*    受注金額
     MOVE    JYOTEI OF D2016XS1  TO    JYOTEI OF D2018XS1.
 MEISAI-SET-999.
     EXIT.
******************************************************************
*    中間ファイル（完成品未出荷抽出）ＲＥＡＤ処理
******************************************************************
 TUKN-READ-SEC                   SECTION.
 TUKN-READ-010.
     READ    D2016XS1.
     EVALUATE    ST-D2016XS1
         WHEN    "00"
           ADD     1             TO    CNT-IN
         WHEN    "10"
           MOVE    "END"         TO    SW-END
         WHEN    OTHER
           MOVE    "D2016XS1"    TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    ST-D2016XS1   TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 TUKN-READ-999.
     EXIT.
******************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     MOVE    JSKOFC OF D2016XS1  TO    SOSICD OF ASOSML1.
     READ    ASOSML1.
     EVALUATE    ST-ASOSML1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN    OTHER
           MOVE    "ASOSML1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    SOSICD OF ASOSML1
                                 TO    WK-KEY1
           MOVE    ST-ASOSML1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 SOSK-READ-999.
     EXIT.
******************************************************************
*    中間ファイル（未出荷データコード変換）出力処理
******************************************************************
 RECORD-OUT-SEC                  SECTION.
 RECORD-OUT-010.
     WRITE                       D201FD OF D2018XS1.
     IF          ST-D2018XS1     =    "00"
       THEN
         ADD     1               TO    CNT-OUT
       ELSE
         MOVE    "D2018XS1"      TO    WK-FILE
         MOVE    "WRITE"         TO    WK-SYORI
         MOVE    ST-D2018XS1     TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
 RECORD-OUT-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
     IF  ST-D2016XS1     NOT =   "00"
       THEN
         MOVE    "D2016XS1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D2016XS1     TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-ASOSML1      NOT =   "00"
       THEN
         MOVE    "ASOSML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-ASOSML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-D2018XS1     NOT =   "00"
       THEN
         MOVE    "D2018XS1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D2018XS1     TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
******************************************************************
*    ＡＢＥＮＤ処理
******************************************************************
 ABEND-SEC                       SECTION.
 ABEND-010.
     DISPLAY "***** " WK-FILE  " " WK-SYORI "  ERR   *****"
                                                     UPON    DSP.
     DISPLAY "*     F-STS       =   " WK-STATUS "          *"
                                                     UPON    DSP.
     IF  WK-KEY   NOT =   SPACE
       THEN
         DISPLAY "*      KEY     =   " WK-KEY1       "*"
                                                     UPON    DSP
     END-IF.
     DISPLAY "***** " WK-PGMID " " WK-VER "  ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20180PB.
