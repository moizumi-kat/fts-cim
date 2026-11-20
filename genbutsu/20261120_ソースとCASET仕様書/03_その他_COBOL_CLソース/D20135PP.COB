*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０１３５ＰＰ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　抽出条件の生産実績データからなる中間ファイル
*                   により生産実績明細表を作成する
*                   Ｄ２０１３０ＰＰをコピーして作成
*
*                                               作成日：20.11.07
*                                               更新日：  .  .
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  中間ファイル　　　　　　　　<D20120S1 >
*                   製品区分マスタ    　　　　　<CSHKML1  >
*                   組織マスタ                  <ASOSML1  >
* ＊＊＊　リスト情報　　　＊＊＊
*  SMED NAME    ：  生産実績明細書　　　　　　　<XU04LP  >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION              DIVISION.
 PROGRAM-ID.                 D20135PP.
 ENVIRONMENT                 DIVISION.
 CONFIGURATION               SECTION.
*SOURCE-COMPUTER.            FACOM  K6700.
*OBJECT-COMPUTER.            FACOM  K6700.
 SOURCE-COMPUTER.            FACOM-K.
 OBJECT-COMPUTER.            FACOM-K.
 SPECIAL-NAMES.
     CONSOLE     IS          DSP
     SYSOUT      IS          SYSOUT
     YA-21       IS          PRT.
 INPUT-OUTPUT                SECTION.
 FILE-CONTROL.
*    部品単価一覧表　　　　　
     SELECT      XU04LP      ASSIGN          TO  LP-04
                             FILE    STATUS  IS  PRT-STATUS.
*    中間ファイル
     SELECT      D20120S1    ASSIGN          TO  DA-S-D20120S1
                             ACCESS  MODE    IS  SEQUENTIAL
                             FILE    STATUS  IS  ST-D20120S1.
*    製品区分マスタ
     SELECT      CSHKML1     ASSIGN          TO  DA-VI-CSHKML1
                             ORGANIZATION    IS  INDEXED
                             RECORD  KEY     IS  SEIKBN OF CSHKML1
                             ACCESS  MODE    IS  RANDOM
                             FILE    STATUS  IS  ST-CSHKML1.
*    組織マスタ
     SELECT      ASOSML1     ASSIGN          TO  DA-VI-ASOSML1
                             ORGANIZATION    IS  INDEXED
                             RECORD  KEY     IS  BSYOCD OF ASOSML1
                                                 TANCD  OF ASOSML1
                             ACCESS  MODE    IS  RANDOM
                             FILE    STATUS  IS  ST-ASOSML1.
/
 DATA                        DIVISION.
 FILE                        SECTION.
******************************************************************
*    生産実績明細表
******************************************************************
 FD  XU04LP.
 01  D20130P1.
     03  FILLER                  PIC  X(300).
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D20120S1    BLOCK       CONTAINS  53  RECORDS.
     COPY        D20120S1    OF  XFDLIB.
/*****************************************************************
*    製品区分マスタ
******************************************************************
 FD  CSHKML1.
     COPY        CSHKML1     OF  XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1     OF  XFDLIB.
/*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
 01  PRT-ITEM.
     03  PRT-STATUS              PIC  X(002).
*    ファイルステータス
     03  ST-D20120S1             PIC  X(002).
     03  ST-CSHKML1              PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYORI                PIC  X(007).
     03  WK-FILE                 PIC  X(008).
     03  WK-DATE                 PIC  9(006).
     03  WK-TIME                 PIC  9(008).
     03  WK-TSDAY1               PIC  9(006).
     03  WK-TSDAY2.
         05  WK-TSTYYY           PIC  9(002).
         05  WK-TSTMMM           PIC  9(002).
         05  WK-TSTDDD           PIC  9(002).
     03  WK-STATUS               PIC  X(002).
     03  WK-STATUS-R             REDEFINES     WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
     03  WK-JSKOFC               PIC  X(004).
     03  WK-SEIKBN               PIC  X(002).
     03  WK-BODY-SEIKBN          PIC  X(002).
     03  WK-JYOTEI.
         05  WK-JYOTEI1          PIC S9(011)       PACKED-DECIMAL.
         05  WK-JYOTEI2          PIC S9(011)       PACKED-DECIMAL.
         05  WK-JYOTEI3          PIC S9(011)       PACKED-DECIMAL.
     03  WK-IKMIKO.
         05  WK-IKMIKO1          PIC  9(4)V9(1)    PACKED-DECIMAL.
         05  WK-IKMIKO2          PIC  9(4)V9(1)    PACKED-DECIMAL.
     03  WK-JSKOSU.
         05  WK-JSKOSU1          PIC S9(4)V9(1)    PACKED-DECIMAL.
         05  WK-JSKOSU2          PIC S9(4)V9(1)    PACKED-DECIMAL.
*    ワーク領域
 01  CNT-AREA.
     03  CNT-PAG                 PIC  9(005).
     03  CNT-LIN                 PIC  9(002).
     03  CNT-IN                  PIC  9(005).
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
     03  SW-READ                 PIC  X(001).
     03  SW-WRITE                PIC  X(001).
 01  WK-PGMID                    PIC  X(008) VALUE "D20135PP".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
*    リスト出力領域
 01  HD-010                      CHARACTER   TYPE    IS  MODE-1.
     03  FILLER                  PIC  X(005) VALUE SPACE.
     03  FILLER                  PIC  X(008) VALUE "D20130P1".
     03  FILLER                  PIC  X(079) VALUE SPACE.
     03  FILLER                  PIC  N(003) VALUE NC"作成日".
     03  FILLER                  PIC  X(001) VALUE ":".
     03  HD-CRTYYY               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-CRTMMM               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-CRTDDD               PIC  9(002).
     03  FILLER                  PIC  X(003) VALUE SPACE.
     03  FILLER                  PIC  N(002) VALUE NC"時間".
     03  FILLER                  PIC  X(001) VALUE SPACE.
     03  HD-TIMHHH               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-TIMMMM               PIC  9(002).
     03  FILLER                  PIC  X(002) VALUE SPACE.
     03  FILLER                  PIC  X(005) VALUE "PAGE:".
     03  HD-PAGCNT               PIC  ZZZ9.
 01  HD-020.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  FILLER                  PIC  N(005)
                 VALUE   NC"抽出範囲："
                                 CHARACTER   TYPE    IS  MODE-1.
     03  HD-TSFYYY               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-TSFMMM               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-TSFDDD               PIC  9(002).
     03  FILLER                  PIC  X(002) VALUE SPACE.
     03  FILLER                  PIC  N(001) VALUE NC"～"
                                 CHARACTER   TYPE    IS  MODE-1.
     03  FILLER                  PIC  X(002) VALUE SPACE.
     03  HD-TSBYYY               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-TSBMMM               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-TSBDDD               PIC  9(002).
     03  FILLER                  PIC  X(008) VALUE SPACE.
     03  FILLER                  PIC  N(013)
                 VALUE   NC"※※　生産実績明細表　※※"
                                 CHARACTER   TYPE    IS  PRT.
     03  FILLER                  PIC  X(022) VALUE SPACE.
     03  FILLER                  PIC  N(006)
                 VALUE   NC"金額単位：円"
                                 CHARACTER   TYPE    IS  MODE-1.
 01  HD-030                      CHARACTER   TYPE    IS  MODE-1.
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  FILLER                  PIC  N(004) VALUE NC"【職場：".
     03  HD-BSYNAM               PIC  N(010).
     03  FILLER                  PIC  N(001) VALUE NC"】".
 01  HD-040                      CHARACTER   TYPE    IS  MODE-1.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  FILLER                  PIC  N(004) VALUE NC"製品区分".
     03  FILLER                  PIC  X(012) VALUE SPACE.
     03  FILLER                  PIC  N(002) VALUE NC"製番".
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  FILLER                  PIC  N(002) VALUE NC"項目".
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  FILLER                  PIC  N(003) VALUE NC"製品名".
     03  FILLER                  PIC  X(030) VALUE SPACE.
     03  FILLER                  PIC  N(002) VALUE NC"数量".
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  FILLER                  PIC  N(004) VALUE NC"生産金額".
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  FILLER                  PIC  N(004) VALUE NC"標準工数".
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  FILLER                  PIC  N(004) VALUE NC"実績工数".
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  FILLER                  PIC  N(005)
                 VALUE   NC"生産計上日".
 01  DT-010                      CHARACTER   TYPE    IS  MODE-1.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-SRYAKU               PIC  N(007).
     03  FILLER                  PIC  X(003) VALUE SPACE.
     03  DT-SEIBAN               PIC  X(007).
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  DT-KOMOKU               PIC  ZZZ9.
     03  FILLER                  PIC  X(004) VALUE SPACE.
     03  DT-SEIMEI               PIC  N(015).
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-SURYO                PIC  ZZZ9.
     03  FILLER                  PIC  X(001) VALUE SPACE.
     03  DT-JYOTEI1              PIC  Z,ZZZ,ZZZ,ZZ9.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-IKMIKO1              PIC  ZZZ9.9.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-JSKOSU1              PIC  ZZZ9.9.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-KJSKYY               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  DT-KJSKMM               PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  DT-KJSKDD               PIC  9(002).
 01  DT-020                      CHARACTER   TYPE    IS  MODE-1.
     03  FILLER                  PIC  X(018) VALUE SPACE.
     03  DT-KEIMEI               PIC  N(007).
     03  FILLER                  PIC  X(051) VALUE SPACE.
     03  DT-JYOTEI2              PIC  Z,ZZZ,ZZZ,ZZ9.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-IKMIKO2              PIC  ZZZ9.9.
     03  FILLER                  PIC  X(006) VALUE SPACE.
     03  DT-JSKOSU2              PIC  ZZZ9.9.
/*****************************************************************
*    パラメタ　　　　　
******************************************************************
 LINKAGE                         SECTION.
 01  LINK-FROM-DAY               PIC S9(009)   BINARY.
 01  LINK-BY-DAY                 PIC S9(009)   BINARY.
/
 PROCEDURE                       DIVISION    USING   LINK-FROM-DAY
                                                     LINK-BY-DAY.
******************************************************************
*    メイン　ルーチン                      (1.0)
******************************************************************
 CTRL-SEC                    SECTION.
 CTRL-010.
     DISPLAY "***** "   WK-PGMID  " " WK-VER "  START *****"
                                               UPON  DSP.
*
     PERFORM INIT-SEC.
     PERFORM MAIN-SEC    UNTIL   SW-END  = "END".
     PERFORM FINAL-SEC.
*
     DISPLAY "*     D20120S1 IN    =  " CNT-IN      "     *"
                                               UPON  DSP.
     DISPLAY "*     D20130P1 PAGE  =  " CNT-PAG     "     *"
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
*    作業領域初期化
     INITIALIZE                  PRT-ITEM   WORK-AREA
                                 CNT-AREA   SW-AREA.
     MOVE      99                TO    CNT-LIN.
*
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN     INPUT              D20120S1
                                 ASOSML1
                                 CSHKML1.
     OPEN     OUTPUT             XU04LP.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     ACCEPT-SEC.
*　中間ファイル初期ＲＥＡＤ
     PERFORM                     TUKN-READ-SEC.
     IF    SW-END    =    "END"
           GO        TO    INIT-999
     END-IF.
     MOVE    JSKOFC OF D20120S1  TO    WK-JSKOFC.
     MOVE    SEIKBN OF D20120S1  TO    WK-SEIKBN.
     PERFORM                     MIDASI1-SEC.
     PERFORM                     MIDASI2-SEC.
*
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理（職場計編集印刷）
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
*    製品区分計編集印刷
     PERFORM     GOKEI1-SEC      UNTIL
                 SW-END              =   "END"
            OR   WK-JSKOFC       NOT =    JSKOFC OF D20120S1.
*    職場計編集印刷
     MOVE    NC"　　【職場計】"  TO    DT-KEIMEI  OF DT-020.
*    生産金額
     MOVE    WK-JYOTEI3          TO    DT-JYOTEI2 OF DT-020.
*    標準工数
     MOVE    WK-IKMIKO2          TO    DT-IKMIKO2 OF DT-020.
*    実績工数
     MOVE    WK-JSKOSU2          TO    DT-JSKOSU2 OF DT-020.
*
     IF    CNT-LIN                >    63
       THEN
           PERFORM               MIDASI1-SEC
           PERFORM               MIDASI2-SEC
     END-IF.
     WRITE   D20130P1            FROM  DT-020     AFTER   2.
     ADD     2                   TO    CNT-LIN.
     MOVE    ZERO                TO    WK-JYOTEI3.
     MOVE    ZERO                TO    WK-IKMIKO2.
     MOVE    ZERO                TO    WK-JSKOSU2.
     MOVE    JSKOFC OF D20120S1  TO    WK-JSKOFC.
     IF    SW-END             NOT =   "END"
           PERFORM               MIDASI2-SEC
     END-IF.
     MOVE    SPACE               TO    WK-BODY-SEIKBN.
*
 MAIN-999.
     EXIT.
/*****************************************************************
*    合計印字処理１（製品区分計）
******************************************************************
 GOKEI1-SEC                      SECTION.
 GOKEI1-010.
*    明細編集印刷
     PERFORM     BODY-SEC        UNTIL
                 SW-END              =   "END"
            OR   WK-JSKOFC       NOT =    JSKOFC OF D20120S1
            OR   WK-SEIKBN       NOT =    SEIKBN OF D20120S1.
*    製品区分計編集印刷
     MOVE    NC"【製品区分計】"  TO    DT-KEIMEI  OF DT-020.
*    生産金額
     MOVE    WK-JYOTEI2          TO    DT-JYOTEI2 OF DT-020.
*    標準工数
     MOVE    WK-IKMIKO1          TO    DT-IKMIKO2 OF DT-020.
*    実績工数
     MOVE    WK-JSKOSU1          TO    DT-JSKOSU2 OF DT-020.
*
     IF    CNT-LIN                >    63
       THEN
           PERFORM               MIDASI1-SEC
           PERFORM               MIDASI2-SEC
     END-IF.
     WRITE   D20130P1            FROM  DT-020     AFTER   2.
     ADD     2                   TO    CNT-LIN.
     MOVE   "W"                  TO    SW-WRITE.
     MOVE    ZERO                TO    WK-JYOTEI2.
     MOVE    ZERO                TO    WK-IKMIKO1.
     MOVE    ZERO                TO    WK-JSKOSU1.
     MOVE    SEIKBN OF D20120S1  TO    WK-SEIKBN.
     MOVE    SPACE               TO    WK-BODY-SEIKBN.
*
 GOKEI1-999.
     EXIT.
/*****************************************************************
*    明細編集印刷処理
******************************************************************
 BODY-SEC                        SECTION.
 BODY-010.
*  　明細印刷処理
*    製品区分
     IF  WK-BODY-SEIKBN      NOT =   SEIKBN OF D20120S1
       THEN
         PERFORM                 SHKB-READ-SEC
         IF        ST-CSHKML1    =  "00"
           THEN
             MOVE  SRYAKU OF CSHKML1
                                 TO    DT-SRYAKU OF DT-010
           ELSE
             MOVE  SPACE         TO    DT-SRYAKU OF DT-010
         END-IF
         MOVE      SEIKBN OF D20120S1
                                 TO    WK-BODY-SEIKBN
       ELSE
         MOVE      SPACE         TO    DT-SRYAKU OF DT-010
     END-IF.
*    製番
     MOVE  SEIBAN OF D20120S1(1:1)
                                 TO    DT-SEIBAN OF DT-010(1:1).
     MOVE  "-"                   TO    DT-SEIBAN OF DT-010(2:1).
     MOVE  SEIBAN OF D20120S1(2:5)
                                 TO    DT-SEIBAN OF DT-010(3:5).
*    項目
     MOVE  KOMOKU OF D20120S1    TO    DT-KOMOKU OF DT-010.
*    製品名
     MOVE  SEIMEI OF D20120S1    TO    DT-SEIMEI OF DT-010.
*    数量
     MOVE  SURYO  OF D20120S1    TO    DT-SURYO  OF DT-010.
*
*    生産金額
     MOVE  JYOTEI OF D20120S1    TO    WK-JYOTEI1.
*    COMPUTE  WK-JYOTEI1         =     WK-JYOTEI1  /   1000.
     MOVE     WK-JYOTEI1         TO    DT-JYOTEI1 OF DT-010.
     COMPUTE  WK-JYOTEI2         =     WK-JYOTEI2  +   WK-JYOTEI1.
     COMPUTE  WK-JYOTEI3         =     WK-JYOTEI3  +   WK-JYOTEI1.
*
*    標準工数
     MOVE  IKMIKO OF D20120S1    TO    DT-IKMIKO1 OF DT-010.
     COMPUTE  WK-IKMIKO1  =      WK-IKMIKO1 + IKMIKO OF D20120S1.
     COMPUTE  WK-IKMIKO2  =      WK-IKMIKO2 + IKMIKO OF D20120S1.
*
*    実績工数
     MOVE  JSKOSU OF D20120S1    TO    DT-JSKOSU1 OF DT-010.
     COMPUTE  WK-JSKOSU1  =      WK-JSKOSU1 +  JSKOSU OF D20120S1.
     COMPUTE  WK-JSKOSU2  =      WK-JSKOSU2 +  JSKOSU OF D20120S1.
*
*    生産計上日
     MOVE    KJSKBI OF D20120S1  TO    WK-TSDAY1.
     MOVE    WK-TSDAY1           TO    WK-TSDAY2.
     MOVE    WK-TSTYYY           TO    DT-KJSKYY OF DT-010.
     MOVE    WK-TSTMMM           TO    DT-KJSKMM OF DT-010.
     MOVE    WK-TSTDDD           TO    DT-KJSKDD OF DT-010.
*
*    明細行出力
     IF      CNT-LIN              >    63
       THEN
         PERFORM                 MIDASI1-SEC
         PERFORM                 MIDASI2-SEC
     END-IF.
     IF      SW-WRITE             =   "W"
       THEN
         WRITE  D20130P1         FROM  DT-010    AFTER   2
         ADD    2                TO    CNT-LIN
         MOVE   SPACE            TO    SW-WRITE
       ELSE
         WRITE  D20130P1         FROM  DT-010    AFTER   1
         ADD    1                TO    CNT-LIN
     END-IF.
*
     MOVE    JSKOFC OF D20120S1  TO    WK-JSKOFC.
     MOVE    SEIKBN OF D20120S1  TO    WK-SEIKBN.
     MOVE    SPACE               TO    SW-READ.
     PERFORM                     TUKN-READ-SEC.
*
 BODY-999.
     EXIT.
/*****************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE     D20120S1   CSHKML1
               ASOSML1    XU04LP.
 FINAL-999.
     EXIT.
/*****************************************************************
*    見出し印字処理１
******************************************************************
 MIDASI1-SEC                     SECTION.
 MIDASI1-010.
     IF  CNT-PAG     NOT =   ZERO
       THEN
         MOVE    SPACE           TO    D20130P1
         WRITE   D20130P1        AFTER PAGE
     END-IF.
*    作成日
     MOVE    WK-DATE(1:2)        TO    HD-CRTYYY OF HD-010.
     MOVE    WK-DATE(3:2)        TO    HD-CRTMMM OF HD-010.
     MOVE    WK-DATE(5:2)        TO    HD-CRTDDD OF HD-010.
*    時間
     MOVE    WK-TIME(1:2)        TO    HD-TIMHHH OF HD-010.
     MOVE    WK-TIME(3:2)        TO    HD-TIMMMM OF HD-010.
*    ページ
     ADD     1                   TO    CNT-PAG.
     MOVE    CNT-PAG             TO    HD-PAGCNT OF HD-010.
*    抽出範囲
     MOVE    LINK-FROM-DAY       TO    WK-TSDAY1.
     MOVE    WK-TSDAY1           TO    WK-TSDAY2.
     MOVE    WK-TSTYYY           TO    HD-TSFYYY OF HD-020.
     MOVE    WK-TSTMMM           TO    HD-TSFMMM OF HD-020.
     MOVE    WK-TSTDDD           TO    HD-TSFDDD OF HD-020.
     MOVE    LINK-BY-DAY         TO    WK-TSDAY1.
     MOVE    WK-TSDAY1           TO    WK-TSDAY2.
     MOVE    WK-TSTYYY           TO    HD-TSBYYY OF HD-020.
     MOVE    WK-TSTMMM           TO    HD-TSBMMM OF HD-020.
     MOVE    WK-TSTDDD           TO    HD-TSBDDD OF HD-020.
*
     WRITE   D20130P1            FROM  HD-010    AFTER   2.
     WRITE   D20130P1            FROM  HD-020    AFTER   1.
     MOVE    4                   TO    CNT-LIN.
 MIDASI1-999.
     EXIT.
/*****************************************************************
*    見出し印字処理２
******************************************************************
 MIDASI2-SEC                     SECTION.
 MIDASI2-010.
*    職場
     PERFORM                     SOSK-READ-SEC.
     IF  ST-ASOSML1      =   "00"
       THEN
         MOVE  BSYNAM OF ASOSML1 TO    HD-BSYNAM OF HD-030
       ELSE
         MOVE  SPACE             TO    HD-BSYNAM OF HD-030
     END-IF.
*
     WRITE     D20130P1          FROM  HD-030    AFTER   2.
     WRITE     D20130P1          FROM  HD-040    AFTER   1.
     ADD       3                 TO    CNT-LIN.
     MOVE     "W"                TO    SW-WRITE.
 MIDASI2-999.
     EXIT.
/*****************************************************************
*    日付＆時間の取得＆セット処理
******************************************************************
 ACCEPT-SEC                      SECTION.
 ACCEPT-010.
     ACCEPT    WK-DATE           FROM  DATE.
     ACCEPT    WK-TIME           FROM  TIME.
 ACCEPT-999.
     EXIT.
/*****************************************************************
*    中間ファイルＲＥＡＤ処理
******************************************************************
 TUKN-READ-SEC                   SECTION.
 TUKN-READ-010.
     READ        D20120S1.
     EVALUATE    ST-D20120S1
         WHEN   "00"
             ADD     1           TO    CNT-IN
         WHEN   "10"
             MOVE   "END"        TO    SW-END
             MOVE    HIGH-VALUE  TO    WK-JSKOFC
             MOVE    HIGH-VALUE  TO    WK-SEIKBN
         WHEN   OTHER
             MOVE   "D20120S1"   TO    WK-FILE
             MOVE   "READ"       TO    WK-SYORI
             MOVE    ST-D20120S1 TO    WK-STATUS
             PERFORM             ABEND-SEC
     END-EVALUATE.
 TUKN-READ-999.
     EXIT.
/*****************************************************************
*    製品区分マスタＲＥＡＤ処理
******************************************************************
 SHKB-READ-SEC                   SECTION.
 SHKB-READ-010.
     MOVE    SEIKBN OF D20120S1  TO    SEIKBN OF CSHKML1.
     READ    CSHKML1.
     EVALUATE  ST-CSHKML1
         WHEN  "00"
         WHEN  "23"
             CONTINUE
         WHEN  OTHER
              MOVE  "CSHKML1"    TO    WK-FILE
              MOVE  "READ"       TO    WK-SYORI
              MOVE  ST-CSHKML1   TO    WK-STATUS
              PERFORM            ABEND-SEC
     END-EVALUATE.
 SHKB-READ-999.
     EXIT.
/*****************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     MOVE    WK-JSKOFC(1:2)      TO    BSYOCD OF ASOSML1.
     MOVE    WK-JSKOFC(3:2)      TO    TANCD  OF ASOSML1.
     READ    ASOSML1.
     EVALUATE    ST-ASOSML1
         WHEN  "00"
         WHEN  "23"
             CONTINUE
         WHEN  OTHER
             MOVE  "ASOSML1"     TO    WK-FILE
             MOVE  "READ"        TO    WK-SYORI
             MOVE  ST-ASOSML1    TO    WK-STATUS
             PERFORM ABEND-SEC
     END-EVALUATE.
 SOSK-READ-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
     IF          PRT-STATUS      NOT =   "00"
       THEN
         MOVE    "XU04LP"        TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    PRT-STATUS      TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
     IF          ST-D20120S1     NOT =   "00"
       THEN
         MOVE    "D20120S1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D20120S1     TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
     IF          ST-CSHKML1      NOT =   "00"
       THEN
         MOVE    "CSHKML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CSHKML1      TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
     IF          ST-ASOSML1      NOT =   "00"
       THEN
         MOVE    "ASOSML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-ASOSML1      TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
/*****************************************************************
*    ＡＢＥＮＤ処理
******************************************************************
 ABEND-SEC                       SECTION.
 ABEND-010.
     DISPLAY "***** " WK-FILE  " " WK-SYORI "  ERR   *****"
                                                     UPON    DSP.
     DISPLAY "*     F-STS           = " WK-STATUS "        *"
                                                     UPON    DSP.
     DISPLAY "***** " WK-PGMID " " WK-VER "  ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20135PP.
