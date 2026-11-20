*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０１６０ＰＢ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　作業実績ファイルに対し、条件項目に該当するレ
*                   コードを抽出し必要となるデータを中間ファイル
*                   に出力する。
*
*                                               作成日：93.04.07
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  作業実績ファイル　　　　    <CJISFL2  >
*                   受注ファイル（項目）　　　　<AJUKFL1  >
*                   運用条件ファイル            <AJKNML1  >
*                   中間ファイル        　　　　<D2016XS1 >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20160PB.
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
*    運用条件ファイル
     SELECT      AJKNML1    ASSIGN       TO DA-VI-AJKNML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JKNKBN OF AJKNML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJKNML1.
*    集約部所変換マスタ
     SELECT      ASBHML1    ASSIGN       TO DA-VI-ASBHML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS
                                            BSYOCD OF ASBHML1
                                            TANCD  OF ASBHML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASBHML1.
*    組織出力順序マスタ
     SELECT      ASOJML1    ASSIGN       TO DA-VI-ASOJML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS
                                            BSYOCD OF ASOJML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOJML1.
*    中間ファイル
     SELECT      D2016XS1   ASSIGN       TO DA-S-D2016XS1
                            FILE STATUS  IS ST-D2016XS1.
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
*    運用条件ファイル
******************************************************************
 FD  AJKNML1.
     COPY        AJKNML1    OF   XFDLIB.
/*****************************************************************
*    集約部所変換マスタ
******************************************************************
 FD  ASBHML1.
     COPY        ASBHML1    OF   XFDLIB.
/*****************************************************************
*    組織出力順序マスタ
******************************************************************
 FD  ASOJML1.
     COPY        ASOJML1    OF   XFDLIB.
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D2016XS1    BLOCK      CONTAINS   102  RECORDS.
     COPY        D2016XS1   OF   XFDLIB.
*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  ST-AREA.
     03  ST-CJISFL2              PIC  X(002).
     03  ST-AJUKFL1              PIC  X(002).
     03  ST-AJKNML1              PIC  X(002).
     03  ST-ASBHML1              PIC  X(002).
     03  ST-ASOJML1              PIC  X(002).
     03  ST-D2016XS1             PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
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
 01  WK-CODE                     PIC  X(04).
 01  WK-CODER   REDEFINES  WK-CODE.
     03  WK-CODE1                PIC  X(02).
     03  WK-CODE2                PIC  X(02).
*
 01  WK-JYUNCD                   PIC  9(05).
 01  WK-JYUNCDR  REDEFINES  WK-JYUNCD.
     03  WK-JYUNCD1              PIC  9(02).
     03  WK-JYUNCD2              PIC  9(03).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20160PB".
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
     DISPLAY "*     CJISFL2  IN =   " CNT-IN  "       *"
                                                 UPON    DSP.
     DISPLAY "*     D2016XS1 OUT=   " CNT-OUT "       *"
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
     INITIALIZE                  WK-CODE.
*
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN      INPUT             CJISFL2
                                 AJUKFL1
                                 AJKNML1
                                 ASBHML1
                                 ASOJML1.
     OPEN      OUTPUT            D2016XS1.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     UYJK-READ-SEC.
     IF  ST-AJKNML1   =   "23"
       THEN
         DISPLAY NC"該当する運用条件ファイルが存在しません"
                                                     UPON   DSP
         MOVE    "END"           TO    SW-END
       ELSE
         PERFORM                 SGJS-CHECK-SEC
         PERFORM                 SGJS-READ-SEC
     END-IF.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     PERFORM                     MEISAI-SET-SEC.
     PERFORM                     SGJS-READ-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       CJISFL2   AJUKFL1
                                 AJKNML1   D2016XS1.
     CLOSE                       ASBHML1.
     CLOSE                       ASOJML1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    明細セット処理
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
     INITIALIZE                  D201FD OF D2016XS1.
*    製番
     MOVE    SEIBAN OF CJISFL2   TO    SEIBAN OF D2016XS1.
*    項目
     MOVE    KOMOKU OF CJISFL2   TO    KOMOKU OF D2016XS1.
*    生産計上日
     MOVE    KJSKBI OF CJISFL2   TO    KJSKBI OF D2016XS1.
*    職場コード
     MOVE    JSKOFC OF CJISFL2   TO    JSKOFC OF D2016XS1.
*
     PERFORM JUCK-READ-SEC.
     IF  ( ST-AJUKFL1            =    "00"  )   AND
         ( SYKDAY OF AJUKFL1     =     ZERO )   AND
*****93.11.22追加
         ( DELFLG OF AJUKFL1     =    SPACE )
*****93.11.22追加終了
*****94.09.14製品区分による抽出条件削除
*        ( SEIKBN OF AJUKFL1     =    "01"  OR  "02"  OR  "03")
       THEN
*
*    営業所コード
*
         PERFORM  SOSICD-SET-SEC
*2012.05*MOVE  SOSICD OF AJUKFL1 TO    SOSICD OF D2016XS1
         MOVE  WK-CODE1          TO    SOSICD OF D2016XS1
*    組織出力順対応
*
         PERFORM  SYUTCD-SET-SEC
         MOVE  WK-JYUNCD         TO    OUTJUN OF D2016XS1
*    製品区分
         MOVE  SEIKBN OF AJUKFL1 TO    SEIKBN OF D2016XS1
*    仮売上フラグ
         MOVE  KURIFG OF AJUKFL1 TO    KURIFG OF D2016XS1
*    受注金額
         MOVE  JYOTEI OF AJUKFL1 TO    JYOTEI OF D2016XS1
*    納期
         MOVE  KANNOK OF AJUKFL1 TO    KANNOK OF D2016XS1
*    中間ファイル出力処理
         PERFORM                 RECORD-OUT-SEC
     END-IF.
 MEISAI-SET-999.
     EXIT.
******************************************************************
*    集約部所変換処理
******************************************************************
 SOSICD-SET-SEC                  SECTION.
 SOISCD-SET-010.
*
         MOVE  BSYOCD OF AJUKFL1 TO    BSYOCD OF ASBHML1.
         MOVE  KKRICD OF AJUKFL1 TO    TANCD  OF ASBHML1.
         READ  ASBHML1     INVALID
                           MOVE  BSYOCD OF AJUKFL1
                                           TO  WK-CODE1
                           MOVE  ZERO
                                           TO  WK-CODE2
                           GO  TO  SOSICD-SET-999.
*
         MOVE  SBSYCD OF ASBHML1    TO  WK-CODE1.
         MOVE  ZERO                 TO  WK-CODE2.
*
 SOSICD-SET-999.
     EXIT.
******************************************************************
*    組織出力順序処理
******************************************************************
 SYUTCD-SET-SEC                  SECTION.
 SYUTCD-SET-010.
         MOVE  BSYOCD OF AJUKFL1 TO    BSYOCD OF ASBHML1.
         MOVE  WK-CODE1          TO    BSYOCD OF ASOJML1.
         READ  ASOJML1     INVALID
                           MOVE  ZERO
                                           TO  WK-JYUNCD1
                           MOVE  ZERO
                                           TO  WK-JYUNCD2
                           GO  TO  SYUTCD-SET-999.
*
         MOVE  SEGBCD OF ASOJML1    TO  WK-JYUNCD1.
         MOVE  SYUJUN OF ASOJML1    TO  WK-JYUNCD2.
*
 SYUTCD-SET-999.
     EXIT.
******************************************************************
*    作業実績ファイル  ＣＨＥＣＫ処理
******************************************************************
 SGJS-CHECK-SEC                  SECTION.
 SGJS-CHECK-010.
     MOVE    JCD19 OF AJKNML1    TO    WORKCD OF CJISFL2.
     MOVE    ZERO                TO    KJSKBI OF CJISFL2.
*
     START   CJISFL2  KEY     IS >     WORKCD OF CJISFL2
                                       KJSKBI OF CJISFL2.
     IF      ST-CJISFL2      =   "00"  OR  "23"
       THEN
         CONTINUE
       ELSE
         MOVE    "CJISFL2"       TO    WK-FILE
         MOVE    "START"         TO    WK-SYORI
         MOVE    WORKCD OF CJISFL2
                                 TO    WK-KEY1
         MOVE    KJSKBI OF CJISFL2
                                 TO    WK-KEY2
         MOVE    ST-CJISFL2      TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
 SGJS-CHECK-999.
     EXIT.
******************************************************************
*    作業実績ファイル    ＲＥＡＤ処理
******************************************************************
 SGJS-READ-SEC                   SECTION.
 SGJS-READ-010.
     READ    CJISFL2     NEXT.
     EVALUATE    ST-CJISFL2
         WHEN    "00"
           IF  ( JCD19  OF AJKNML1      =   WORKCD OF CJISFL2) AND
               ( KJSKBI OF CJISFL2  NOT =   ZERO )
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
           PERFORM               ABEND-SEC
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
*
     READ    AJUKFL1.
     EVALUATE    ST-AJUKFL1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN    OTHER
           MOVE    "AJUKFL1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
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
*    運用条件ファイルＲＥＡＤ処理
******************************************************************
 UYJK-READ-SEC                   SECTION.
 UYJK-READ-010.
     MOVE    "0"                 TO    JKNKBN OF AJKNML1.
*
     READ    AJKNML1.
     EVALUATE    ST-AJKNML1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN    OTHER
           MOVE    "AJKNML1"     TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE    JKNKBN OF AJKNML1
                                 TO    WK-KEY1
           MOVE    ST-AJKNML1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 UYJK-READ-999.
     EXIT.
******************************************************************
*    中間ファイル出力処理
******************************************************************
 RECORD-OUT-SEC                  SECTION.
 RECORD-OUT-010.
     WRITE                       D201FD OF D2016XS1.
     IF  ST-D2016XS1     =   "00"
       THEN
         ADD     1               TO    CNT-OUT
       ELSE
         MOVE    "D2016XS1"      TO    WK-FILE
         MOVE    "WRITE"         TO    WK-SYORI
         MOVE    ST-D2016XS1     TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
 RECORD-OUT-999.
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
     IF  ST-AJKNML1      NOT =   "00"
       THEN
         MOVE    "AJKNML1"       TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-AJKNML1      TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-ASBHML1      NOT =   "00"
       THEN
         MOVE    "ASBHML1"       TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-ASBHML1      TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-D2016XS1     NOT =   "00"
       THEN
         MOVE    "D2016XS1"      TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-D2016XS1     TO      WK-STATUS
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
         DISPLAY "*                  " WK-KEY2       "*"
                                                     UPON    DSP
     END-IF.
     DISPLAY "***** " WK-PGMID " " WK-VER "  ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20160PB.
