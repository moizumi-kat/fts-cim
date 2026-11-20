*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２００３０ＰＢ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　パラメータで受け取った抽出開始日付、抽出終了
*                   日付、抽出コードで作業指示ファイル、受注ファ
*                   イル（項目）を読み、中間ファイルに出力する。
*
*                                               作成日：93.03.22
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  作業指示ファイル　　　　    <CSJIFP   >
*                   受注ファイル（項目）　　　　<AJUKFL1  >
*                   中間ファイル        　　　　<D20030S1 >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20030PB.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
        CONSOLE   IS        DSP.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    作業指示ファイル
     SELECT      CSJIFP     ASSIGN       TO DA-S-CSJIFP
                            FILE STATUS  IS ST-CSJIFP.
*    受注ファイル（項目）
     SELECT      AJUKFL1    ASSIGN       TO DA-VI-AJUKFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUKFL1
                                            JYUKOU OF AJUKFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUKFL1.
*    中間ファイル
     SELECT      D20030S1   ASSIGN       TO DA-S-D20030S1
                            FILE STATUS  IS ST-D20030S1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    作業指示ファイル
******************************************************************
 FD  CSJIFP.
     COPY        CSJIFP     OF   XFDLIB.
/*****************************************************************
*    受注ファイル（項目）
******************************************************************
 FD  AJUKFL1.
     COPY        AJUKFL1    OF   XFDLIB.
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D20030S1    BLOCK      CONTAINS   27  RECORDS.
     COPY        D20030S1   OF   XFDLIB.
*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  ST-AREA.
     03  ST-CSJIFP               PIC  X(002).
     03  ST-AJUKFL1              PIC  X(002).
     03  ST-D20030S1             PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYRKBN               PIC  9(001).
     03  WK-SIRECD               PIC  X(005).
     03  WK-NYUKBI               PIC  9(008).
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
 01  WK-PGMID                    PIC  X(008) VALUE "D20030PB".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
/*****************************************************************
*    パラメタ
******************************************************************
 LINKAGE                         SECTION.
 01  LINK-FROM-DAY               PIC S9(009) BINARY.
 01  LINK-BY-DAY                 PIC S9(009) BINARY.
 01  LINK-WORKCD                 PIC  X(004).
/
 PROCEDURE                       DIVISION    USING   LINK-FROM-DAY
                                                     LINK-BY-DAY
                                                     LINK-WORKCD.
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
     DISPLAY "*     CSJIFP   IN =   " CNT-IN  "       *"
                                                 UPON    DSP.
     DISPLAY "*     D20030S1 OUT=   " CNT-OUT "       *"
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
     INITIALIZE                  ST-AREA     WORK-AREA
                                 CNT-AREA    SW-AREA.
*    パラメタチェック
     PERFORM                     LINK-CHECK-SEC.
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN      INPUT             CSJIFP    AJUKFL1.
     OPEN      OUTPUT            D20030S1.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     SGSJ-READ-SEC.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     IF  LINK-WORKCD              =  SPACE
       THEN
         IF  ( WK-F-DAY          <=  SIJDAY OF CSJIFP )  AND
             ( SIJDAY OF CSJIFP  <=  WK-B-DAY)
           THEN
             PERFORM             MEISAI-SET-SEC
             PERFORM             RECORD-OUT-SEC
           ELSE
             CONTINUE
         END-IF
       ELSE
         IF  ( WK-F-DAY          <=  SIJDAY OF CSJIFP )  AND
             ( SIJDAY OF CSJIFP  <=  WK-B-DAY)           AND
             ( LINK-WORKCD        =  WORKCD OF CSJIFP )
           THEN
             PERFORM             MEISAI-SET-SEC
             PERFORM             RECORD-OUT-SEC
           ELSE
             CONTINUE
         END-IF
     END-IF.
     PERFORM                     SGSJ-READ-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE       CSJIFP
                 AJUKFL1
                 D20030S1.
 FINAL-999.
     EXIT.
******************************************************************
*    パラメタチェック処理
******************************************************************
 LINK-CHECK-SEC                  SECTION.
 LINK-CHECK-010.
     MOVE    LINK-FROM-DAY       TO    WK-F-DAY.
     MOVE    LINK-BY-DAY         TO    WK-B-DAY.
     EVALUATE  LINK-FROM-DAY
         WHEN  000000
               MOVE  19000101    TO    WK-F-DAY
         WHEN  999999
               MOVE  20991231    TO    WK-F-DAY
         WHEN  OTHER
               IF    WK-F-DAY(3:2)     >   90
               THEN
                 COMPUTE  WK-F-DAY     =   WK-F-DAY  +  19000000
               ELSE
                 COMPUTE  WK-F-DAY     =   WK-F-DAY  +  20000000
               END-IF
     END-EVALUATE.
*
     EVALUATE  LINK-BY-DAY
         WHEN  000000
               MOVE  19000101    TO    WK-B-DAY
         WHEN  999999
               MOVE  20991231    TO    WK-B-DAY
         WHEN  OTHER
               IF    WK-B-DAY(3:2)     >   90
               THEN
                 COMPUTE  WK-B-DAY     =   WK-B-DAY  +  19000000
               ELSE
                 COMPUTE  WK-B-DAY     =   WK-B-DAY  +  20000000
               END-IF
     END-EVALUATE.
 LINK-CHECK-999.
     EXIT.
******************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
     IF  ST-CSJIFP       NOT =   "00"
       THEN
         MOVE    "CSJIFP"        TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-CSJIFP       TO      WK-STATUS
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
     IF  ST-D20030S1     NOT =   "00"
       THEN
         MOVE    "D20030S1"      TO      WK-FILE
         MOVE    "OPEN"          TO      WK-SYORI
         MOVE    ST-D20030S1     TO      WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
******************************************************************
*    明細セット処理
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
     INITIALIZE                  D200FD OF D20030S1.
*    作業コード
     MOVE    WORKCD OF CSJIFP    TO    WORKCD OF D20030S1.
*    職場コード
     MOVE    SJIOFC OF CSJIFP    TO    SJIOFC OF D20030S1.
*    指示番号
     MOVE    SIJINO OF CSJIFP    TO    SIJINO OF D20030S1.
*    伝票番号
     MOVE    DENPNO OF CSJIFP    TO    DENPNO OF D20030S1.
*    製番
     MOVE    SEIBAN OF CSJIFP    TO    SEIBAN OF D20030S1.
*    項目
     MOVE    KOMOKU OF CSJIFP    TO    KOMOKU OF D20030S1.
*    指示区分
     MOVE    SIJIKB OF CSJIFP    TO    SIJIKB OF D20030S1.
*    作業区分
     MOVE    WRKKBN OF CSJIFP    TO    WRKKBN OF D20030S1.
*    作業着手日
     MOVE    TYOTEI OF CSJIFP    TO    TYOTEI OF D20030S1.
*    作業完了日
     MOVE    KYOTEI OF CSJIFP    TO    KYOTEI OF D20030S1.
*    工数
     MOVE    SJKOSU OF CSJIFP    TO    SJKOSU OF D20030S1.
*
     PERFORM                     JUCK-READ-SEC.
     IF  ST-AJUKFL1      =   "00"
       THEN
*    内容数
         MOVE  NAISU  OF AJUKFL1 TO    NAISU  OF D20030S1
*    数量
         MOVE  SURYO  OF AJUKFL1 TO    SURYO  OF D20030S1
*    受注金額
         MOVE  JYOTEI OF AJUKFL1 TO    JYUPTE OF D20030S1
*    鈑金寸法１
         MOVE  BANKWG OF AJUKFL1 TO    BANKWG OF D20030S1
*    鈑金寸法２
         MOVE  BANKHG OF AJUKFL1 TO    BANKHG OF D20030S1
*    鈑金寸法３
         MOVE  BANKDG OF AJUKFL1 TO    BANKDG OF D20030S1
*    木板寸法１
         MOVE  MOKU1W OF AJUKFL1 TO    MOKU1W OF D20030S1
*    木板寸法２
         MOVE  MOKU1H OF AJUKFL1 TO    MOKU1H OF D20030S1
*    木板寸法３
         MOVE  MOKU1D OF AJUKFL1 TO    MOKU1D OF D20030S1
*    塗色内面
         MOVE  NAIMEN OF AJUKFL1 TO    NAIMEN OF D20030S1
*    塗色外面
         MOVE  GAIMEN OF AJUKFL1 TO    GAIMEN OF D20030S1
*    塗色扉裏
         MOVE  TOBURA OF AJUKFL1 TO    TOBURA OF D20030S1
*    塗色その他
         MOVE  SONOTA OF AJUKFL1 TO    SONOTA OF D20030S1
*    膜厚
         MOVE  MAKATU OF AJUKFL1 TO    MAKATU OF D20030S1
*    木板種別
         MOVE  MOKSYU OF AJUKFL1 TO    MOKSYU OF D20030S1
*    完成品納期
         MOVE  KANNOK OF AJUKFL1 TO    KANNOK OF D20030S1
     END-IF.
 MEISAI-SET-999.
     EXIT.
******************************************************************
*    作業指示ファイル    ＲＥＡＤ処理
******************************************************************
 SGSJ-READ-SEC                   SECTION.
 SGSJ-READ-010.
     READ      CSJIFP.
     EVALUATE  ST-CSJIFP
         WHEN  "00"
               ADD   1           TO    CNT-IN
         WHEN  "10"
               MOVE  "END"       TO    SW-END
         WHEN  OTHER
               MOVE  "CSJIFP"    TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-CSJIFP   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SGSJ-READ-999.
     EXIT.
******************************************************************
*    受注ファイル（項目）ＲＥＡＤ処理
******************************************************************
 JUCK-READ-SEC                   SECTION.
 JUCK-READ-010.
     MOVE    SEIBAN OF CSJIFP    TO    SEIBAN OF AJUKFL1.
     MOVE    KOMOKU OF CSJIFP    TO    JYUKOU OF AJUKFL1.
     READ      AJUKFL1.
     EVALUATE  ST-AJUKFL1
         WHEN  "00"
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "AJUKFL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  SEIBAN OF AJUKFL1
                                 TO    WK-KEY1
               MOVE  JYUKOU OF AJUKFL1
                                 TO    WK-KEY2
               MOVE  ST-AJUKFL1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JUCK-READ-999.
     EXIT.
******************************************************************
*    中間ファイル　　　　出力処理
******************************************************************
 RECORD-OUT-SEC                  SECTION.
 RECORD-OUT-010.
     WRITE     D200FD OF D20030S1.
     IF        ST-D20030S1       =     "00"
       THEN
         ADD   1                 TO    CNT-OUT
       ELSE
         MOVE  "D20030S1"        TO    WK-FILE
         MOVE  "WRITE"           TO    WK-SYORI
         MOVE  ST-D20030S1       TO    WK-STATUS
         PERFORM                 ABEND-SEC
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
 END PROGRAM D20030PB.
