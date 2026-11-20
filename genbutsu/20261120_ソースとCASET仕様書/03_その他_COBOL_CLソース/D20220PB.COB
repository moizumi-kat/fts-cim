*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０２２０ＰＢ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　生産実績ファイルに対し、条件項目に該当するレ
*                   コードを抽出し必要となるデータを中間ファイル
*                   に出力する。
*
*                                               作成日：93.04.20
*                                               更新日：93.12.27
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  生産実績ファイル　　　　    <CSEIFL1  >
*                   製品区分マスタ              <CSHKML1  >
*                   組織マスタ                  <ASOSML1  >
*                   カレンダマスタ              <CCALML1  >
*                   運用条件マスタ              <AJKNML1  >
*                   中間ファイル        　　　　<D20220S1 >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20220PB.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
        CONSOLE   IS        DSP.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    生産実績ファイル
     SELECT      CSEIFL1    ASSIGN       TO DA-VI-CSEIFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS NENKBN OF CSEIFL1
                                            BSYOCD OF CSEIFL1
                                            TANCD  OF CSEIFL1
                                            SEIKBN OF CSEIFL1
                            ACCESS MODE  IS DYNAMIC
                            FILE STATUS  IS ST-CSEIFL1.
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
*    カレンダマスタ
     SELECT      CCALML1    ASSIGN       TO DA-VI-CCALML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS YMD    OF CCALML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CCALML1.
*    運用条件ファイル
     SELECT      AJKNML1    ASSIGN       TO DA-VI-AJKNML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JKNKBN OF AJKNML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJKNML1.
*    中間ファイル
     SELECT      D20220S1   ASSIGN       TO DA-S-D20220S1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D20220S1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    生産実績ファイル
******************************************************************
 FD  CSEIFL1.
     COPY        CSEIFL1    OF   XFDLIB.
/*****************************************************************
*    製品区分マスタ
******************************************************************
 FD  CSHKML1.
     COPY        CSHKML1    OF   XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1    OF   XFDLIB.
/*****************************************************************
*    カレンダマスタ
******************************************************************
 FD  CCALML1.
     COPY        CCALML1    OF   XFDLIB.
/*****************************************************************
*    運用条件ファイル
******************************************************************
 FD  AJKNML1.
     COPY        AJKNML1    OF   XFDLIB.
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D20220S1    BLOCK      CONTAINS   170  RECORDS.
     COPY        D20220S1   OF   XFDLIB.
*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  ST-AREA.
     03  ST-CSEIFL1              PIC  X(002).
     03  ST-CSHKML1              PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
     03  ST-CCALML1              PIC  X(002).
     03  ST-AJKNML1              PIC  X(002).
     03  ST-D20220S1             PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-ABEND.
         05  WK-KEY.
             07  WK-KEY1         PIC  X(015).
             07  WK-KEY2         PIC  X(015).
             07  WK-KEY3         PIC  X(015).
             07  WK-KEY4         PIC  X(015).
         05  WK-SYORI            PIC  X(007).
         05  WK-FILE             PIC  X(008).
*
     03  WK-STATUS               PIC  X(002).
     03  WK-STATSU-R             REDEFINES   WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
*
     03  WK-DATE                 PIC  9(008).
     03  WK-YY                   PIC  9(004).
     03  WK-MM                   PIC  9(002).
     03  WK-LINK                 PIC  9(006).
     03  WORK-DATE.
         05  WORK-YY             PIC  9(004).
         05  WORK-MM             PIC  9(002).
         05  WORK-DD             PIC  9(002).
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
*
 01  IX-AREA.
     03  IX-01                   PIC  9(002).
*    カウンタ
 01  CNT-AREA.
     03  CNT-IN                  PIC  9(005).
     03  CNT-OUT                 PIC  9(005).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20220PB".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
/
 LINKAGE                         SECTION.
 01  LINK-YYMMDD                 PIC S9(009) BINARY.
*
 PROCEDURE                       DIVISION
                                 USING       LINK-YYMMDD.
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
     DISPLAY "*     CSEIFL1  IN =   " CNT-IN  "       *"
                                                 UPON    DSP.
     DISPLAY "*     D20220S1 OUT=   " CNT-OUT "       *"
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
     INITIALIZE                  ST-AREA
                                 WORK-AREA
                                 CNT-AREA
                                 IX-AREA
                                 SW-AREA.
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN      INPUT             CSEIFL1
                                 CSHKML1
                                 ASOSML1
                                 CCALML1
                                 AJKNML1.
     OPEN      OUTPUT            D20220S1.
*
     PERFORM                     DATE-SEC
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     SSJS-STR-SEC.
     IF     SW-END = SPACE
     THEN
       PERFORM                   SSJS-NEXT-SEC
     END-IF.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     INITIALIZE                  D202FD OF D20220S1.
*    職場生産集計コード
     PERFORM                     SOSK-READ-SEC.
     IF  ST-ASOSML1      =   "00"
       THEN
         MOVE  SYUCD  OF ASOSML1 TO    SBSSCD OF D20220S1
       ELSE
         GO    TO                MAIN-998
     END-IF.
*
*    製品区分生産集計コード
     PERFORM                     SHKB-READ-SEC.
     IF  ST-CSHKML1      =   "00"
       THEN
         MOVE  SYUCD  OF CSHKML1 TO    SKSRCD OF D20220S1
       ELSE
         GO    TO                MAIN-998
     END-IF.
*    生産実績当日金額
     MOVE    SETOUS OF CSEIFL1(IX-01)
                                 TO    SETOUS OF D20220S1.
*    生産実績当日増減
     MOVE    SETOUZ OF CSEIFL1(IX-01)
                                 TO    SETOUZ OF D20220S1.
*    生産実績累計金額
     MOVE    SETOUR OF CSEIFL1(IX-01)
                                 TO    SETOUR OF D20220S1.
     PERFORM                     RECORD-OUT-SEC.
*
 MAIN-998.
     PERFORM                     SSJS-NEXT-SEC.
 MAIN-999.
     EXIT.
/*****************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       CSEIFL1
                                 CSHKML1
                                 ASOSML1
                                 CCALML1
                                 AJKNML1
                                 D20220S1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    日付設定処理（実績Ｆアクセス時対応キーの取得）
******************************************************************
 DATE-SEC                        SECTION.
 DATE-010.
     MOVE    ZERO                TO    WK-YY  WK-MM.
     MOVE    LINK-YYMMDD         TO    WK-LINK.
     IF      WK-LINK     =   ZERO
     THEN
*      パラメタ無しの場合（運用条件ファイル）
       PERFORM   AJKNML1-READ-RTN
       MOVE    YY1 OF AJKNML1    TO    WORK-YY
       MOVE    MM1 OF AJKNML1    TO    WORK-MM
       MOVE    DD1 OF AJKNML1    TO    WORK-DD
       MOVE    WORK-DATE         TO    WK-DATE
*
       PERFORM                   CALM-READ-SEC
       IF    ST-CCALML1  =  "00"
       THEN
         MOVE  NEN    OF CCALML1 TO    WK-YY
         MOVE  JTSUKI OF CCALML1 TO    WK-MM
       END-IF
     ELSE
*      パラメタ有りの場合（随時処理）
       IF    WK-LINK  (1:2)    >   90
       THEN
         MOVE    19              TO    WK-YY(1:2)
                                       WK-DATE(1:2)
       ELSE
         MOVE    20              TO    WK-YY(1:2)
                                       WK-DATE(1:2)
       END-IF
       MOVE  WK-LINK  (1:2)      TO    WK-YY(3:2)
       MOVE  WK-LINK  (3:2)      TO    WK-MM
       MOVE  WK-LINK             TO    WK-DATE(3:6)
       MOVE  WK-DATE             TO    WORK-DATE
       PERFORM                   CALM-READ-SEC
       IF    ST-CCALML1  =  "00"
       THEN
         MOVE  NEN    OF CCALML1 TO    WK-YY
         MOVE  JTSUKI OF CCALML1 TO    WK-MM
       END-IF
     END-IF.
*
     IF    ( WK-MM    >=    04 ) AND
           ( WK-MM    <=    12 )
     THEN
       COMPUTE  IX-01            =     WK-MM   -    3
     ELSE
       COMPUTE  IX-01            =     WK-MM   +    9
*94.12.27 ADD FTH(1ｶﾞﾂﾄﾞﾃﾞ ｶﾂ 20ﾋ ｲｾﾞﾝﾉ ﾊﾞｱｲ ﾉﾐ ﾈﾝｦ -1ｽﾙ)
       IF    ( WK-MM     =    01 ) AND
             ( WORK-DD   >    20 )
       THEN
             CONTINUE
       ELSE
             COMPUTE  WK-YY    =     WK-YY   -    1
       END-IF
*94.12.27 ADD
     END-IF.
     DISPLAY  "WK-YY ==> "   WK-YY   UPON  DSP.
     DISPLAY  "WK-MM ==> "   WK-MM   UPON  DSP.
     DISPLAY  "IX-01 ==> "   IX-01   UPON  DSP.
 DATE-999.
     EXIT.
/*****************************************************************
*    カレンダマスタＲＥＡＤ処理
******************************************************************
 CALM-READ-SEC                   SECTION.
 CALM-READ-010.
     MOVE    WK-DATE             TO    YMD    OF CCALML1.
     READ    CCALML1.
     EVALUATE    ST-CCALML1
         WHEN    "00"
         WHEN    "23"
             CONTINUE
         WHEN    OTHER
             MOVE  "CCALML1"     TO    WK-FILE
             MOVE  "READ"        TO    WK-SYORI
             MOVE   WK-DATE      TO    WK-KEY1
             MOVE   ST-CCALML1   TO    WK-STATUS
             PERFORM             ABEND-SEC
     END-EVALUATE.
 CALM-READ-999.
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
*    生産実績ファイルＳＴＡＲＴ処理
******************************************************************
 SSJS-STR-SEC                    SECTION.
 SSJS-STR-010.
     INITIALIZE                  NENKBN OF CSEIFL1
                                 BSYOCD OF CSEIFL1
                                 TANCD  OF CSEIFL1
                                 SEIKBN OF CSEIFL1.
     MOVE    WK-YY               TO    NENKBN OF CSEIFL1.
*

     START   CSEIFL1 KEY IS >=   NENKBN OF CSEIFL1
                                 BSYOCD OF CSEIFL1
                                 TANCD  OF CSEIFL1
                                 SEIKBN OF CSEIFL1.
     EVALUATE  ST-CSEIFL1
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE    "END"     TO    SW-END
         WHEN  OTHER
               MOVE    "CSEIFL1" TO     WK-FILE
               MOVE    "START"   TO     WK-SYORI
               MOVE    WK-YY     TO     WK-KEY1
               MOVE    BSYOCD OF CSEIFL1
                                 TO     WK-KEY2
               MOVE    TANCD  OF CSEIFL1
                                 TO     WK-KEY3
               MOVE    SEIKBN OF CSEIFL1
                                 TO     WK-KEY4
               MOVE   ST-CSEIFL1 TO     WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SSJS-READ-999.
     EXIT.
/*****************************************************************
*    生産実績ファイルＲＥＡＤ処理(NEXT)
******************************************************************
 SSJS-NEXT-SEC                   SECTION.
 SSJS-NEXT-010.
     READ      CSEIFL1  NEXT.
     EVALUATE  ST-CSEIFL1
         WHEN  "00"
               IF    WK-YY  = NENKBN OF CSEIFL1
               THEN
                 ADD   1         TO    CNT-IN
               ELSE
                 MOVE  "END"     TO    SW-END
               END-IF
         WHEN    "10"
               MOVE    "END"     TO    SW-END
         WHEN    OTHER
               MOVE    "CSEIFL1" TO    WK-FILE
               MOVE    "READ"    TO    WK-SYORI
               MOVE     NENKBN OF CSEIFL1
                                 TO    WK-KEY1
               MOVE     BSYOCD OF CSEIFL1
                                 TO    WK-KEY2
               MOVE     TANCD  OF CSEIFL1
                                 TO    WK-KEY3
               MOVE     SEIKBN OF CSEIFL1
                                 TO    WK-KEY4
               MOVE     ST-CSEIFL1
                                 TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SSJS-NEXT-999.
     EXIT.
/*****************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     MOVE    SOSICD OF CSEIFL1   TO    SOSICD OF ASOSML1.
     READ    ASOSML1.
     EVALUATE    ST-ASOSML1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN    OTHER
           MOVE   "ASOSML1"      TO    WK-FILE
           MOVE   "READ"         TO    WK-SYORI
           MOVE    SOSICD OF ASOSML1
                                 TO    WK-KEY1
           MOVE    ST-ASOSML1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 SOSK-READ-999.
     EXIT.
/*****************************************************************
*    製品区分ファイルＲＥＡＤ処理
******************************************************************
 SHKB-READ-SEC                   SECTION.
 SHKB-READ-010.
     MOVE    SEIKBN OF CSEIFL1   TO    SEIKBN OF CSHKML1.
     READ    CSHKML1.
     EVALUATE    ST-CSHKML1
         WHEN    "00"
         WHEN    "23"
           CONTINUE
         WHEN     OTHER
           MOVE   "CSHKFM1"      TO    WK-FILE
           MOVE   "READ"         TO    WK-SYORI
           MOVE    SEIKBN OF CSHKML1
                                 TO    WK-KEY1
           MOVE    ST-CSHKML1    TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 SHKB-READ-999.
     EXIT.
/*****************************************************************
*    中間ファイル出力処理
******************************************************************
 RECORD-OUT-SEC                  SECTION.
 RECORD-OUT-010.
     WRITE                       D202FD OF D20220S1.
     IF  ST-D20220S1  =  "00"
       THEN
         ADD     1               TO    CNT-OUT
       ELSE
         MOVE   "D20220S1"       TO    WK-FILE
         MOVE   "WRITE"          TO    WK-SYORI
         MOVE    ST-D20220S1     TO    WK-STATUS
         PERFORM                 ABEND-SEC
     END-IF.
 RECORD-OUT-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
*--＜生産実績ファイル＞
     IF  ST-CSEIFL1      NOT =   "00"
       THEN
         MOVE    "CSEIFL1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CSEIFL1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*--＜製品区分マスタ＞
     IF  ST-CSHKML1      NOT =   "00"
       THEN
         MOVE    "CSHKML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CSHKML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*--＜組織マスタ＞
     IF  ST-ASOSML1      NOT =   "00"
       THEN
         MOVE    "ASOSML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-ASOSML1      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*--＜カレンダマスタ＞
     IF  ST-CCALML1      NOT =   "00"
       THEN
         MOVE    "CCALML1"       TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-CCALML1      TO    WK-STATUS
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
*--＜日報用中間ファイル＞
     IF  ST-D20220S1     NOT =   "00"
       THEN
         MOVE    "D20220S1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D20220S1     TO    WK-STATUS
         PERFORM ABEND-SEC
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
     DISPLAY "*     F-STS       =   " WK-STATUS "          *"
                                                     UPON    DSP.
     IF  WK-KEY   NOT =   SPACE
       THEN
         DISPLAY "*      KEY     =   " WK-KEY1     "*"
                                                     UPON    DSP
         DISPLAY "*                  " WK-KEY2     "*"
                                                     UPON    DSP
         DISPLAY "*                  " WK-KEY3     "*"
                                                     UPON    DSP
     END-IF.
     DISPLAY "***** " WK-PGMID " " WK-VER "  ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20220PB.
