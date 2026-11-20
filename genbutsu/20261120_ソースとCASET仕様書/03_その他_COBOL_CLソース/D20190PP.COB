*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２０１９０ＰＰ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　抽出条件からなる中間ファイルより完成品未出荷
*                   総括表を作成する
*
*                                               作成日：93.04.16
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  中間ファイル　　　　　　　　<D2018XS1 >
*                   組織マスタ　　    　　　　　<ASOSML1  >
* ＊＊＊　リスト情報　　＊＊＊
*  SMED NAME    ：  完成品未出荷総括表　        <XU04LP  >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20190PP.
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
*    完成品未出荷総括表
     SELECT      XU04LP     ASSIGN       TO LP-04
                            FILE  STATUS IS PRT-STATUS.
*    中間ファイル　
     SELECT      D2018XS1   ASSIGN       TO DA-S-D2018XS1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D2018XS1.
*    組織マスタ
     SELECT      ASOSML1    ASSIGN       TO DA-VI-ASOSML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SOSICD OF ASOSML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOSML1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    完成品未出荷総括表
******************************************************************
 FD  XU04LP.
 01  D20190P1.
     03  FILLER             PIC  X(300).
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D2018XS1    BLOCK      CONTAINS   240  RECORDS.
     COPY        D2018XS1   OF   XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1    OF   XFDLIB.
/*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    ファイルステータス
 01  PRT-ITEM.
     03  PRT-STATUS              PIC  X(002).
     03  ST-D2018XS1             PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYORI                PIC  X(007).
     03  WK-FILE                 PIC  X(008).
     03  WK-DATE                 PIC  9(006).
     03  WK-TIME                 PIC  9(008).
     03  WK-SOSICD               PIC  X(004).
     03  WK-SOSICD-FLG           PIC  X(001).
     03  WK-SYUCD                PIC  X(004).
     03  WK-JYOTEI.
         05  WK-JYOTEI1          PIC  9(011).
         05  WK-JYOTEI2          PIC  9(011).
         05  WK-JYTTBL           OCCURS  14.
             07  WK-JYOTEI3      PIC  9(011).
             07  WK-JYOTEI4      PIC  9(011).
             07  WK-JYOTEI5      PIC  9(011).
     03  WK-STATUS               PIC  X(002).
     03  WK-STATUS-R             REDEFINES     WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
     03  SW-PAGE                 PIC  X(001).
*    添字
 01  IX-AREA.
     03  IX-01                   PIC  9(002).
*    カウンター
 01  CNT-AREA.
     03  CNT-PAGE                PIC  9(005).
     03  CNT-LINE                PIC  9(002).
     03  CNT-IN                  PIC  9(005).
 01  WK-PGMID                    PIC  X(008) VALUE "D20190PP".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
*
*--- 総括表設定領域 -------------------------------------------*
 01  HEAD-01                     CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(005) VALUE SPACE.
     03  FILLER                  PIC  X(008) VALUE "D20190P1".
     03  FILLER                  PIC  X(080) VALUE SPACE.
     03  FILLER                  PIC  N(003) VALUE NC"作成日".
     03  FILLER                  PIC  X(001) VALUE ":".
     03  HD-CRTYY                PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-CRTMM                PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-CRTDD                PIC  9(002).
     03  FILLER                  PIC  X(003) VALUE SPACE.
     03  FILLER                  PIC  N(002) VALUE NC"時間".
     03  FILLER                  PIC  X(001) VALUE SPACE.
     03  HD-HH                   PIC  9(002).
     03  FILLER                  PIC  X(001) VALUE ".".
     03  HD-MM                   PIC  9(002).
     03  FILLER                  PIC  X(002) VALUE SPACE.
     03  FILLER                  PIC  X(005) VALUE "PAGE:".
     03  HD-PAGE                 PIC  ZZZ9.
*
 01  HEAD-02.
     03  FILLER                  PIC  X(045) VALUE SPACE.
     03  FILLER                  PIC  N(015) VALUE
         NC"※※　完成品未出荷総括表　※※"
                                 CHARACTER   TYPE  IS  YA-21.
     03  FILLER                  PIC  X(016) VALUE SPACE.
     03  FILLER                  PIC  N(007) VALUE
                                 NC"金額単位：千円"
                                 CHARACTER   TYPE  IS  MODE-1.
*
 01  HEAD-03                     CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(001) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"営業所".
     03  FILLER                  PIC  X(014) VALUE SPACE.
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"配電盤".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"制御盤".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"分電盤".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"システ".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"その他".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"小　計".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"商品　".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"船岡　".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"船岡　".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"運　輸".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"北海道".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"小　計".
     03  FILLER                  PIC  X(002) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"Ｇ　Ｓ".
     03  FILLER                  PIC  X(004) VALUE "!".
     03  FILLER                  PIC  N(003) VALUE NC"総合計".
     03  FILLER                  PIC  X(001) VALUE "!".
*
*    明細設定行
 01  BODY-01                     CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(001) VALUE "!".
     03  BD-BSYNAM               PIC  N(010).
     03  FILLER                  PIC  X(001) VALUE "!".
     03  BD-KINGAK               OCCURS  13.
         05  BD-KINGK            PIC  ZZZ,ZZ9.
         05  FILLER              PIC  X(001) VALUE "!".
     03  BD-SOGOKEI              PIC  Z,ZZZ,ZZ9.
     03  FILLER                  PIC  X(001) VALUE "!".
*
*    罫線設定行
 01  LINE-01.
     03  FILLER                  PIC  X(136) VALUE ALL "-".
 01  LINE-02.
     03  FILLER                  PIC  X(001) VALUE "!".
     03  FILLER                  PIC  X(020) VALUE ALL "-".
     03  FIL-OCC                 OCCURS  13.
         05  FILLER              PIC  X(001) VALUE "+".
         05  FILLER              PIC  X(007) VALUE ALL "-".
     03  FILLER                  PIC  X(001) VALUE "+".
     03  FILLER                  PIC  X(010) VALUE ALL "-".
     03  FILLER                  PIC  X(001) VALUE "!".
 01  LINE-02A.
     03  FILLER                  PIC  X(001) VALUE "!".
     03  FILLER                  PIC  X(020) VALUE ALL "=".
     03  FIL-OCC                 OCCURS  13.
         05  FILLER              PIC  X(001) VALUE "+".
         05  FILLER              PIC  X(007) VALUE ALL "=".
     03  FILLER                  PIC  X(001) VALUE "+".
     03  FILLER                  PIC  X(010) VALUE ALL "=".
     03  FILLER                  PIC  X(001) VALUE "!".
 01  LINE-03.
     03  FILLER                  PIC  X(001) VALUE "!".
     03  FILLER                  PIC  X(020) VALUE SPACE.
     03  FIL-OCC                 OCCURS  13.
         05  FILLER              PIC  X(001) VALUE "!".
         05  FILLER              PIC  X(007) VALUE SPACE.
     03  FILLER                  PIC  X(001) VALUE ALL "!".
     03  FILLER                  PIC  X(009) VALUE SPACE.
     03  FILLER                  PIC  X(001) VALUE "!".
*2005.06.27自社で追加START
 01  LINE-03A                    CHARACTER   TYPE  IS  MODE-1.
     03  FILLER                  PIC  X(001) VALUE "!".
     03  FILLER                  PIC  X(020) VALUE SPACE.
     03  FIL-OCCA                OCCURS  6.
         05  FILLER              PIC  X(001) VALUE "!".
         05  FILLER              PIC  X(007) VALUE SPACE.
     03  FILLER                  PIC  X(001) VALUE ALL "!".
*
     03  FILLER                  PIC  N(003) VALUE NC"　仕入".
     03  FILLER                  PIC  X(002) VALUE " !".
     03  FILLER                  PIC  N(003) VALUE NC"制御盤".
     03  FILLER                  PIC  X(002) VALUE " !".
     03  FILLER                  PIC  N(003) VALUE NC"分電盤".
     03  FILLER                  PIC  X(002) VALUE " !".
     03  FIL-OCCB                OCCURS  4.
         05  FILLER              PIC  X(007) VALUE SPACE.
         05  FILLER              PIC  X(001) VALUE ALL "!".
     03  FILLER                  PIC  X(009) VALUE SPACE.
     03  FILLER                  PIC  X(001) VALUE "!".
*2005.06.27自社で追加END
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
     DISPLAY "*     D2018XS1 IN    =  " CNT-IN      "     *"
                                               UPON  DSP.
     DISPLAY "*     D20190P1 PAGE  =  " CNT-PAGE    "     *"
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
     INITIALIZE                  PRT-ITEM   WORK-AREA   BODY-01
                                 SW-AREA    CNT-AREA.
*
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN      INPUT             D2018XS1
                                 ASOSML1.
     OPEN      OUTPUT            XU04LP.
*
     PERFORM                     OPEN-CHECK-SEC.
     PERFORM                     ACCEPT-SEC.
*
     PERFORM                     TUKN-READ-SEC.
     IF  SW-END      =   SPACE
       THEN
         MOVE  SOSICD OF D2018XS1
                                 TO    WK-SOSICD
         MOVE  SYUCD  OF D2018XS1
                                 TO    WK-SYUCD
         PERFORM                 HEAD-SET-SEC
     END-IF.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
*
     PERFORM      UNTIL    SW-END        =  "END"
*
         PERFORM  UNTIL  ( SW-END        =  "END"    )
              OR ( WK-SOSICD(1:2) NOT = SOSICD OF D2018XS1(1:2) )
*                               << 明細サマリ処理 >>
             PERFORM             MEISAI-SMR-SEC
         END-PERFORM
*
*                               << 小計／総合計退避サマリ処理 >>
         PERFORM                 GOKEI-SMR-SEC
*
         IF  WK-SOSICD(1:1)      NOT =   "8"
         THEN
*                               << 明細出力処理 >>
           MOVE  "Y"             TO   WK-SOSICD-FLG
           PERFORM               MEISAI-SET-SEC
           MOVE  SPACE           TO   WK-SOSICD-FLG
           IF    CNT-LINE        >=   63
           THEN
             PERFORM             HEAD-SET-SEC
           END-IF
         END-IF
*
         IF  ( WK-SOSICD(1:1)  = SOSICD OF D2018XS1(1:1)) AND
             ( SW-END          = SPACE                  )
         THEN
           CONTINUE
         ELSE
*                                << 地区計出力 >>
           PERFORM               CIKUKEI-SET-SEC
           IF  CNT-LINE          >=   63
           THEN
             PERFORM             HEAD-SET-SEC
           END-IF
*
         END-IF
         MOVE    SOSICD OF D2018XS1
                                 TO    WK-SOSICD
     END-PERFORM.
*
     IF    SW-END           =   "END"
     THEN
*                                << 総合計出力 >>
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
                                 D2018XS1
                                 ASOSML1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    見出し部設定処理
******************************************************************
 HEAD-SET-SEC                    SECTION.
 HEAD-SET-010.
     IF        CNT-PAGE    NOT   =     ZERO
     THEN
       WRITE   D20190P1          AFTER PAGE
     END-IF.
*
*    作成日
     MOVE    WK-DATE(1:2)        TO    HD-CRTYY.
     MOVE    WK-DATE(3:2)        TO    HD-CRTMM.
     MOVE    WK-DATE(5:2)        TO    HD-CRTDD.
*    時間
     MOVE    WK-TIME(1:2)        TO    HD-HH.
     MOVE    WK-TIME(3:2)        TO    HD-MM.
*    ページ
     ADD     1                   TO    CNT-PAGE.
     MOVE    CNT-PAGE            TO    HD-PAGE.
*
     WRITE   D20190P1            FROM  HEAD-01  AFTER  1.
     WRITE   D20190P1            FROM  HEAD-02  AFTER  1.
     WRITE   D20190P1            FROM  LINE-01  AFTER  2.
     WRITE   D20190P1            FROM  HEAD-03  AFTER  1.
*2005.06.27自社で変更  START
*****WRITE   D20190P1            FROM  LINE-03  AFTER  1.
     WRITE   D20190P1            FROM  LINE-03A AFTER  1.
*2005.06.27自社で変更  END
     WRITE   D20190P1            FROM  LINE-02A AFTER  1.
     MOVE    7                   TO    CNT-LINE.
 HEAD-SET-999.
     EXIT.
/*****************************************************************
*    明細サマリ処理
******************************************************************
 MEISAI-SMR-SEC                 SECTION.
 MEISAI-SMR-010.
*
     PERFORM UNTIL( SOSICD OF D2018XS1(1:2) NOT = WK-SOSICD(1:2) )
              OR  ( SYUCD       OF D2018XS1 NOT = WK-SYUCD  )
              OR  ( SW-END                      =  "END"    )
*
         MOVE    JYOTEI OF D2018XS1
                                 TO    WK-JYOTEI1
         COMPUTE WK-JYOTEI2      =     WK-JYOTEI2
                                 +     WK-JYOTEI1
*
         PERFORM                 TUKN-READ-SEC
     END-PERFORM.
*
     EVALUATE    WK-SYUCD
*    システム
       WHEN    "4000"
         COMPUTE WK-JYOTEI3(4)   =   WK-JYOTEI3(4)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(6)   =   WK-JYOTEI3(6)  +  WK-JYOTEI2
*    配電盤
       WHEN    "7210"
         COMPUTE WK-JYOTEI3(1)   =   WK-JYOTEI3(1)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(6)   =   WK-JYOTEI3(6)  +  WK-JYOTEI2
*    制御盤
       WHEN    "7220"
         COMPUTE WK-JYOTEI3(2)   =   WK-JYOTEI3(2)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(6)   =   WK-JYOTEI3(6)  +  WK-JYOTEI2
*    分電盤
       WHEN    "7230"
         COMPUTE WK-JYOTEI3(3)   =   WK-JYOTEI3(3)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(6)   =   WK-JYOTEI3(6)  +  WK-JYOTEI2
*    船岡
*2005.06.27自社で変更  START
*******WHEN    "8200"
       WHEN    "8210"
*2005.06.27自社で変更  END
         COMPUTE WK-JYOTEI3(9)   =   WK-JYOTEI3(9)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(12)  =   WK-JYOTEI3(12) +  WK-JYOTEI2
*    製作所
       WHEN    "8300"
         COMPUTE WK-JYOTEI3(7)   =   WK-JYOTEI3(7)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(12)  =   WK-JYOTEI3(12) +  WK-JYOTEI2
*    ＥＢ
*2005.06.27自社で変更  START
****** WHEN    "8310"
       WHEN    "8200"
*2005.06.27自社で変更  END
         COMPUTE WK-JYOTEI3(8)   =   WK-JYOTEI3(8)  +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(12)  =   WK-JYOTEI3(12) +  WK-JYOTEI2
*    北海道
       WHEN    "8500"
         COMPUTE WK-JYOTEI3(11)  =   WK-JYOTEI3(11) +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(12)  =   WK-JYOTEI3(12) +  WK-JYOTEI2
*    運輸
       WHEN    "8600"
         COMPUTE WK-JYOTEI3(10)  =   WK-JYOTEI3(10) +  WK-JYOTEI2
         COMPUTE WK-JYOTEI3(12)  =   WK-JYOTEI3(12) +  WK-JYOTEI2
     END-EVALUATE.
*
     EVALUATE    WK-SYUCD(1:1)
*    その他
       WHEN    "7"
         IF  WK-SYUCD   NOT =   "7210"  AND "7220"  AND "7230"
         THEN
           COMPUTE WK-JYOTEI3(5) =   WK-JYOTEI3(5)  +  WK-JYOTEI2
           COMPUTE WK-JYOTEI3(6) =   WK-JYOTEI3(6)  +  WK-JYOTEI2
         END-IF
*    ＧＳ
       WHEN    "9"
         COMPUTE WK-JYOTEI3(13)  =   WK-JYOTEI3(13) +  WK-JYOTEI2
     END-EVALUATE.
*
     COMPUTE     WK-JYOTEI3(14)  =   WK-JYOTEI3(14) +  WK-JYOTEI2.
*
     MOVE    ZERO                TO    WK-JYOTEI2.
     MOVE    SYUCD OF D2018XS1   TO    WK-SYUCD.
 MEISAI-SMR-999.
     EXIT.
/*****************************************************************
*    地区計総合計退避処理
******************************************************************
 GOKEI-SMR-SEC                       SECTION.
 GOKEI-SMR-010.
*
     PERFORM  VARYING   IX-01    FROM    1   BY  1
              UNTIL     IX-01    >       14
*
         COMPUTE WK-JYOTEI4(IX-01)   =
                 WK-JYOTEI4(IX-01)   +   WK-JYOTEI3(IX-01)
         COMPUTE WK-JYOTEI5(IX-01)   =
                 WK-JYOTEI5(IX-01)   +   WK-JYOTEI3(IX-01)
     END-PERFORM.
 GOKEI-SMR-999.
     EXIT.
/*****************************************************************
*    営業所名取得処理
******************************************************************
 EIGO-SET-SEC                    SECTION.
 EIGO-SET-010.
     PERFORM                     SOSK-READ-SEC.
     IF    ST-ASOSML1       =   "00"
       THEN
         MOVE  BSYNAM OF ASOSML1 TO    BD-BSYNAM
     END-IF.
 EIGO-SET-999.
     EXIT.
/*****************************************************************
*    明細行編集処理
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
*
     PERFORM                     EIGO-SET-SEC.
     PERFORM    VARYING  IX-01   FROM  1      BY 1
                UNTIL    IX-01   >     13
*
             COMPUTE  WK-JYOTEI3(IX-01)
                   =  WK-JYOTEI3(IX-01) /     1000
             MOVE     WK-JYOTEI3(IX-01)
                                 TO    BD-KINGK  (IX-01)
             MOVE     ZERO       TO    WK-JYOTEI3(IX-01)
     END-PERFORM.
*    総合計
     COMPUTE WK-JYOTEI3(14)
           = WK-JYOTEI3(14) /    1000.
     MOVE    WK-JYOTEI3(14)      TO    BD-SOGOKEI.
     MOVE    ZERO                TO    WK-JYOTEI3(14).
*
     WRITE   D20190P1            FROM  LINE-03  AFTER  1.
     WRITE   D20190P1            FROM  BODY-01  AFTER  1.
     INITIALIZE                        BODY-01.
     WRITE   D20190P1            FROM  LINE-02  AFTER  1.
     ADD     3                   TO    CNT-LINE.
*
 MEISAI-SET-999.
     EXIT.
/*****************************************************************
*    地区計編集処理
******************************************************************
 CIKUKEI-SET-SEC                 SECTION.
 CIKUKEI-SET-010.
*
     PERFORM                     EIGO-SET-SEC
     PERFORM    VARYING  IX-01   FROM  1      BY 1
                UNTIL    IX-01   >     13
*
             COMPUTE  WK-JYOTEI4(IX-01)
                   =  WK-JYOTEI4(IX-01) /     1000
             MOVE     WK-JYOTEI4(IX-01)
                                 TO    BD-KINGK  (IX-01)
             MOVE     ZERO       TO    WK-JYOTEI4(IX-01)
     END-PERFORM.
*    総合計
     COMPUTE WK-JYOTEI4(14)
           = WK-JYOTEI4(14) /    1000.
     MOVE    WK-JYOTEI4(14)      TO    BD-SOGOKEI.
     MOVE    ZERO                TO    WK-JYOTEI4(14).
*
     WRITE   D20190P1            FROM  LINE-03  AFTER  1.
     WRITE   D20190P1            FROM  LINE-03  AFTER  1.
     WRITE   D20190P1            FROM  BODY-01  AFTER  1.
     INITIALIZE                        BODY-01.
     WRITE   D20190P1            FROM  LINE-02  AFTER  1.
     ADD     4                   TO    CNT-LINE.
*
 CIKUKEI-SET-999.
     EXIT.
/*****************************************************************
*    総合計編集
******************************************************************
 SOGOKEI-SET-SEC                 SECTION.
 SOGOKEI-SET-010.
     MOVE    NC"総合計"          TO   BD-BSYNAM.
*
     PERFORM    VARYING  IX-01   FROM  1      BY 1
                UNTIL    IX-01   >     13
*
             COMPUTE  WK-JYOTEI5(IX-01)
                   =  WK-JYOTEI5(IX-01) /     1000
             MOVE     WK-JYOTEI5(IX-01)
                                 TO    BD-KINGK  (IX-01)
             MOVE     ZERO       TO    WK-JYOTEI5(IX-01)
     END-PERFORM.
*    総合計
     COMPUTE WK-JYOTEI5(14)
           = WK-JYOTEI5(14) /    1000.
     MOVE    WK-JYOTEI5(14)      TO    BD-SOGOKEI.
     MOVE    ZERO                TO    WK-JYOTEI5(14).
*
     WRITE   D20190P1            FROM  LINE-03  AFTER  1.
     WRITE   D20190P1            FROM  LINE-03  AFTER  1.
     WRITE   D20190P1            FROM  BODY-01  AFTER  1.
     INITIALIZE                        BODY-01.
     WRITE   D20190P1            FROM  LINE-01  AFTER  1.
*
 SOGOKEI-SET-999.
     EXIT.
/*****************************************************************
*    日付＆時間の取得＆セット処理
******************************************************************
 ACCEPT-SEC                      SECTION.
 ACCEPT-010.
     ACCEPT     WK-DATE          FROM  DATE.
     ACCEPT     WK-TIME          FROM  TIME.
 ACCEPT-999.
     EXIT.
/*****************************************************************
*    中間ファイルＲＥＡＤ処理
******************************************************************
 TUKN-READ-SEC                   SECTION.
 TUKN-READ-010.
     READ        D2018XS1.
     EVALUATE    ST-D2018XS1
         WHEN    "00"
           ADD      1            TO    CNT-IN
         WHEN    "10"
           MOVE    "END"         TO    SW-END
         WHEN    OTHER
           MOVE    "D2018XS1"    TO    WK-FILE
           MOVE    "READ"        TO    WK-SYORI
           MOVE     ST-D2018XS1  TO    WK-STATUS
           PERFORM               ABEND-SEC
     END-EVALUATE.
 TUKN-READ-999.
     EXIT.
/*****************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     IF  WK-SOSICD-FLG           =  "Y"
      THEN
         MOVE    "00"            TO  WK-SOSICD (3:2)
         MOVE    WK-SOSICD       TO  SOSICD OF ASOSML1
      ELSE
       IF  ( WK-SOSICD(1:1)    NOT =  SOSICD OF D2018XS1(1:1)) OR
           ( SW-END                =  "END"                   )
         THEN
           IF      WK-SOSICD(1:1)  =  "8"
           THEN
             MOVE    "00"          TO  WK-SOSICD (3:2)
             MOVE  WK-SOSICD       TO  SOSICD OF ASOSML1
           ELSE
             MOVE  WK-SOSICD(1:1)  TO  SOSICD OF ASOSML1(1:1)
             MOVE  "000"           TO  SOSICD OF ASOSML1(2:3)
           END-IF
         ELSE
           MOVE    "00"            TO  WK-SOSICD (3:2)
           MOVE    WK-SOSICD       TO  SOSICD OF ASOSML1
       END-IF
     END-IF.
*
     READ        ASOSML1.
     EVALUATE    ST-ASOSML1
         WHEN  "00"
           CONTINUE
         WHEN  "23"
           CONTINUE
         WHEN   OTHER
           MOVE   "ASOSML1"      TO    WK-FILE
           MOVE   "READ"         TO    WK-SYORI
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
*
     IF  PRT-STATUS  NOT =   "00"
       THEN
         MOVE    "XU04LP"        TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    PRT-STATUS      TO    WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-D2018XS1  NOT =   "00"
       THEN
         MOVE    "D2018XS1"      TO    WK-FILE
         MOVE    "OPEN"          TO    WK-SYORI
         MOVE    ST-D2018XS1     TO    WK-STATUS
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
 END PROGRAM D20190PP.
