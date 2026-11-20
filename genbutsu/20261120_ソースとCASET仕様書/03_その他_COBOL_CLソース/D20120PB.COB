*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０１２０ＰＢ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　作業実績ファイルに対し、条件項目に該当するレ
*                   コードを抽出し必要となるデータを中間ファイル
*                   に出力する。
*
*                                               作成日：93.03.30
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  作業実績ファイル　　　　    <CJISFL2  >
*                   受注ファイル（項目）　　　　<AJUKFL1  >
*                   原価ファイル（項目）　　　　<AGEKFL1  >
*                   運用条件ファイル            <AJKNML1  >
*                   中間ファイル        　　　　<D20120S1 >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20120PB.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
        CONSOLE   IS        DSP.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    作業実績ファイル
     SELECT      CJISFL2    ASSIGN       TO DA-VI-CJISFL2
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS WORKCD OF CJISFL2
                                            KJSKBI OF CJISFL2
                            ACCESS MODE  IS DYNAMIC
                            FILE STATUS  IS ST-CJISFL2.
*    受注ファイル（項目）
     SELECT      AJUKFL1    ASSIGN       TO DA-VI-AJUKFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUKFL1
                                            JYUKOU OF AJUKFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUKFL1.
*    原価ファイル（項目）
     SELECT      AGEKFL1    ASSIGN       TO DA-VI-AGEKFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AGEKFL1
                                            KOMOKU OF AGEKFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AGEKFL1.
*    運用条件ファイル
     SELECT      AJKNML1    ASSIGN       TO DA-VI-AJKNML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JKNKBN OF AJKNML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJKNML1.
*    中間ファイル
     SELECT      D20120S1   ASSIGN       TO DA-S-D20120S1
                            FILE STATUS  IS ST-D20120S1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    作業実績ファイル
******************************************************************
 FD  CJISFL2.
     COPY        CJISFL2    OF   XFDLIB.
/*****************************************************************
*    受注ファイル（項目）
******************************************************************
 FD  AJUKFL1.
     COPY        AJUKFL1    OF   XFDLIB.
/*****************************************************************
*    原価ファイル（項目）
******************************************************************
 FD  AGEKFL1.
     COPY        AGEKFL1    OF   XFDLIB.
/*****************************************************************
*    運用条件ファイル
******************************************************************
 FD  AJKNML1.
     COPY        AJKNML1    OF   XFDLIB.
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D20120S1    BLOCK      CONTAINS   53  RECORDS.
     COPY        D20120S1   OF   XFDLIB.
*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  ST-AREA.
     03  ST-CJISFL2              PIC  X(002).
     03  ST-AJUKFL1              PIC  X(002).
     03  ST-AGEKFL1              PIC  X(002).
     03  ST-AJKNML1              PIC  X(002).
     03  ST-D20120S1             PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-F-DAY                PIC  9(008).
     03  WK-B-DAY                PIC  9(008).
*
     03  WK-ABEND.
         05  WK-KEY.
             07  WK-KEY1         PIC  X(015).
             07  WK-KEY2         PIC  X(015).
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
 01  WK-PGMID                    PIC  X(008) VALUE "D20120PB".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
/*****************************************************************
*    パラメタ
******************************************************************
 LINKAGE                         SECTION.
 01  LINK-FROM-DAY               PIC S9(009) BINARY.
 01  LINK-BY-DAY                 PIC S9(009) BINARY.
/
 PROCEDURE                       DIVISION    USING   LINK-FROM-DAY
                                                     LINK-BY-DAY.
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
     DISPLAY "*     CJISFL2  IN =   " CNT-IN  "       *"
                                                 UPON    DSP.
     DISPLAY "*     D20120S1 OUT=   " CNT-OUT "       *"
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
*    パラメタチェック
     PERFORM                     LINK-CHECK-SEC.
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN      INPUT             CJISFL2
                                 AJUKFL1
                                 AGEKFL1
                                 AJKNML1.
     OPEN      OUTPUT            D20120S1.
     PERFORM                     OPEN-CHECK-SEC.
*
     PERFORM                     UYJK-READ-SEC.
     IF        ST-AJKNML1   =   "23"
       THEN
         DISPLAY NC"該当する運用条件ファイルが存在しません"
                                                     UPON   DSP
     END-IF.
     PERFORM                     SGJS-CHECK-SEC.
     PERFORM                     SGJS-READ-SEC.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     PERFORM                     MEISAI-SET-SEC.
     PERFORM                     RECORD-OUT-SEC.
     PERFORM                     SGJS-READ-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       CJISFL2  AJUKFL1  AGEKFL1
                                 AJKNML1  D20120S1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    パラメタチェック処理
******************************************************************
 LINK-CHECK-SEC                  SECTION.
 LINK-CHECK-010.
     MOVE    LINK-FROM-DAY       TO    WK-F-DAY.
     MOVE    LINK-BY-DAY         TO    WK-B-DAY.
*
     EVALUATE    LINK-FROM-DAY
         WHEN    000000
             MOVE    19000101    TO    WK-F-DAY
         WHEN    999999
             MOVE    20991231    TO    WK-F-DAY
         WHEN    OTHER
             IF  WK-F-DAY(3:2)   >     90
             THEN
               COMPUTE WK-F-DAY  =     WK-F-DAY    +   19000000
             ELSE
               COMPUTE WK-F-DAY  =     WK-F-DAY    +   20000000
             END-IF
     END-EVALUATE.
*
     EVALUATE    LINK-BY-DAY
         WHEN    000000
             MOVE    19000101    TO    WK-B-DAY
         WHEN    999999
             MOVE    20991231    TO    WK-B-DAY
         WHEN    OTHER
             IF  WK-B-DAY(3:2)   >     90
             THEN
               COMPUTE WK-B-DAY  =     WK-B-DAY    +   19000000
             ELSE
               COMPUTE WK-B-DAY  =     WK-B-DAY    +   20000000
             END-IF
     END-EVALUATE.
 LINK-CHECK-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
     IF  ST-CJISFL2      NOT =   "00"
       THEN
         MOVE    "CJISFL2"       TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-CJISFL2      TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-AJUKFL1      NOT =   "00"
       THEN
         MOVE    "AJUKFL1"       TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-AJUKFL1      TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-AGEKFL1      NOT =   "00"
       THEN
         MOVE    "AGEKFL1"       TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-AGEKFL1      TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-AJKNML1      NOT =   "00"
       THEN
         MOVE    "AJKNML1"       TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-AJKNML1      TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-D20120S1     NOT =   "00"
       THEN
         MOVE    "D20120S1"      TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-D20120S1     TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
/*****************************************************************
*    明細セット処理
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
     INITIALIZE                  D201FD  OF  D20120S1.
*    職場コード
     MOVE    JSKOFC OF CJISFL2   TO    JSKOFC OF D20120S1.
*    製番
     MOVE    SEIBAN OF CJISFL2   TO    SEIBAN OF D20120S1.
*    項目
     MOVE    KOMOKU OF CJISFL2   TO    KOMOKU OF D20120S1.
*    実績工数
     MOVE    JSKOSU OF CJISFL2   TO    JSKOSU OF D20120S1.
*    生産計上日
     MOVE    KJSKBI OF CJISFL2   TO    KJSKBI OF D20120S1.
     PERFORM JUCK-READ-SEC.
     IF  ST-AJUKFL1      =   "00"
       THEN
*    製品区分
         MOVE  SEIKBN OF AJUKFL1 TO    SEIKBN OF D20120S1
*    製品名
         MOVE  SEIMEI OF AJUKFL1 TO    SEIMEI OF D20120S1
*    数量
         MOVE  SURYO  OF AJUKFL1 TO    SURYO  OF D20120S1
*    生産金額
         MOVE  JYOTEI OF AJUKFL1 TO    JYOTEI OF D20120S1
     END-IF.
     PERFORM                     GNKK-READ-SEC.
     IF        ST-AGEKFL1   =   "00"
       THEN
*    標準工数
         MOVE  IKMIKO OF AGEKFL1(1)
                                 TO    IKMIKO OF D20120S1
     END-IF.
 MEISAI-SET-999.
     EXIT.
******************************************************************
*    作業実績ファイル  ＣＨＥＣＫ処理
******************************************************************
 SGJS-CHECK-SEC                  SECTION.
 SGJS-CHECK-010.
     MOVE    JCD19   OF  AJKNML1 TO    WORKCD OF CJISFL2.
     MOVE    WK-F-DAY            TO    KJSKBI OF CJISFL2.
*
     START   CJISFL2 KEY     IS  >=    WORKCD OF CJISFL2
                                       KJSKBI OF CJISFL2.
     IF      ST-CJISFL2           =   "00" OR "23"
       THEN
         CONTINUE
       ELSE
         MOVE  "CJISFL2"         TO    WK-FILE
         MOVE  "START"           TO    WK-SYORI
         MOVE  WORKCD OF CJISFL2 TO    WK-KEY1
         MOVE  KJSKBI OF CJISFL2 TO    WK-KEY2
         MOVE  ST-CJISFL2        TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
 SGJS-CHECK-999.
     EXIT.
******************************************************************
*    作業実績ファイル    ＲＥＡＤ処理
******************************************************************
 SGJS-READ-SEC                   SECTION.
 SGJS-READ-010.
     READ        CJISFL2     NEXT.
     EVALUATE    ST-CJISFL2
         WHEN    "00"
           IF ( JCD19  OF AJKNML1 =  WORKCD OF CJISFL2 ) AND
              ( KJSKBI OF CJISFL2 >  ZERO              ) AND
              ( WK-F-DAY         <=  KJSKBI OF CJISFL2 ) AND
              ( WK-B-DAY         >=  KJSKBI OF CJISFL2 )
             THEN
               ADD     1         TO    CNT-IN
             ELSE
               MOVE    "END"     TO    SW-END
           END-IF
         WHEN    "10"
           MOVE    "END"         TO    SW-END
         WHEN    OTHER
           MOVE    "CJISFL2"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    WORKCD OF CJISFL2
                                 TO    WK-KEY1
           MOVE    KJSKBI OF CJISFL2
                                 TO    WK-KEY2
           MOVE    ST-CJISFL2    TO    WK-STATUS
           PERFORM ABEND-SEC
     END-EVALUATE.
 SGJS-READ-999.
     EXIT.
******************************************************************
*    受注ファイル（項目）ＲＥＡＤ処理
******************************************************************
 JUCK-READ-SEC                   SECTION.
 JUCK-READ-010.
     MOVE    SEIBAN OF CJISFL2   TO    SEIBAN OF AJUKFL1.
     MOVE    KOMOKU OF CJISFL2   TO    JYUKOU OF AJUKFL1.
     READ      AJUKFL1.
     EVALUATE  ST-AJUKFL1
         WHEN  "00"
         WHEN  "23"
           CONTINUE
         WHEN  OTHER
           MOVE   "AJUKFL1"      TO    WK-FILE
           MOVE   "READ"         TO    WK-SYORI
           MOVE    SEIBAN OF AJUKFL1
                                 TO    WK-KEY1
           MOVE    JYUKOU OF AJUKFL1
                                 TO    WK-KEY2
           MOVE    ST-AJUKFL1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 JUCK-READ-999.
     EXIT.
******************************************************************
*    原価ファイル（項目）ＲＥＡＤ処理
******************************************************************
 GNKK-READ-SEC                   SECTION.
 GNKK-READ-010.
     MOVE    SEIBAN OF CJISFL2   TO    SEIBAN OF AGEKFL1.
     MOVE    KOMOKU OF CJISFL2   TO    KOMOKU OF AGEKFL1.
     READ    AGEKFL1.
     EVALUATE  ST-AGEKFL1
         WHEN  "00"
         WHEN  "23"
           CONTINUE
         WHEN  OTHER
           MOVE   "AGEKFL1"      TO    WK-FILE
           MOVE   "READ"         TO    WK-SYORI
           MOVE    SEIBAN OF AGEKFL1
                                 TO    WK-KEY1
           MOVE    KOMOKU OF AGEKFL1
                                 TO    WK-KEY2
           MOVE    ST-AGEKFL1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 GNKK-READ-999.
     EXIT.
******************************************************************
*    運用条件ファイルＲＥＡＤ処理
******************************************************************
 UYJK-READ-SEC                   SECTION.
 UYJK-READ-010.
     MOVE    "0"                 TO    JKNKBN OF AJKNML1.
     READ    AJKNML1.
     EVALUATE  ST-AJKNML1
         WHEN  "00"
         WHEN  "23"
           CONTINUE
         WHEN  OTHER
           MOVE   "AJKNML1"      TO    WK-FILE
           MOVE   "READ"         TO    WK-SYORI
           MOVE    JKNKBN OF AJKNML1
                                 TO    WK-KEY1
           MOVE    ST-AJKNML1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 UYJK-READ-999.
     EXIT.
******************************************************************
*    中間ファイル　　　　出力処理
******************************************************************
 RECORD-OUT-SEC                  SECTION.
 RECORD-OUT-010.
     WRITE  D201FD OF D20120S1.
     IF     ST-D20120S1     =   "00"
       THEN
         ADD     1               TO    CNT-OUT
       ELSE
         MOVE    "D20120S1"      TO    WK-FILE
         MOVE    "WRITE"         TO    WK-SYORI
         MOVE    ST-D20120S1     TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
 RECORD-OUT-999.
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
         DISPLAY "*      KEY     =   " WK-KEY1     "*"
                                                     UPON    DSP
         DISPLAY "*                  " WK-KEY2     "*"
                                                     UPON    DSP
     END-IF.
     DISPLAY "***** " WK-PGMID " " WK-VER "  ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20120PB.
