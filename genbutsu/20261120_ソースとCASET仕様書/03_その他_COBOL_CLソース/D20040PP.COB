*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２００４０ＰＰ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　抽出条件の作業指示データからなる中間ファイル
*                   により作業指示一覧表を作成する
*
*                                               作成日：93.03.29
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  中間ファイル　　　　　　　　<D20030S1 >
*                   受注ファイル（鑑）　　　　　<AJUGFL1  >
*                   組織マスタ　　    　　　　　<ASOSML1  >
*                   作業マスタ  　    　　　　　<CSAGML1  >
* ＊＊＊　リスト情報　　＊＊＊
*  SMED NAME    ：  作業指示一覧表　　　　　　　<XU04LP  >
*
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20040PP.
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
*    作業指示一覧表
     SELECT      XU04LP     ASSIGN       TO GS-XU04LP
                            SYMBOLIC DESTINATION IS "PRT"
                            FORMAT       IS PRT-FORMAT
                            GROUP        IS PRT-GROUP
                            PROCESSING MODE      IS PRT-MODE
                            UNIT       CONTROL   IS PRT-SEIGYO
                            FILE  STATUS IS PRT-STATUS.
*    中間ファイル　
     SELECT      D20030S1   ASSIGN       TO DA-S-D20030S1
                            ACCESS MODE  IS SEQUENTIAL
                            FILE STATUS  IS ST-D20030S1.
*    受注ファイル（鑑）
     SELECT      AJUGFL1    ASSIGN       TO DA-VI-AJUGFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUGFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUGFL1.
*    組織マスタ
     SELECT      ASOSML1    ASSIGN       TO DA-VI-ASOSML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS BSYOCD OF ASOSML1
                                            TANCD  OF ASOSML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOSML1.
*    作業マスタ
     SELECT      CSAGML1    ASSIGN       TO DA-VI-CSAGML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS WORKCD OF CSAGML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSAGML1.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    作業指示一覧表
******************************************************************
 FD  XU04LP.
     COPY        D20040P1   OF   XMDLIB.
/*****************************************************************
*    中間ファイル
******************************************************************
 FD  D20030S1    BLOCK      CONTAINS   27  RECORDS.
     COPY        D20030S1   OF   XFDLIB.
/*****************************************************************
*    受注ファイル（鑑）
******************************************************************
 FD  AJUGFL1.
     COPY        AJUGFL1    OF   XFDLIB.
/*****************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1    OF   XFDLIB.
/*****************************************************************
*    作業マスタ
******************************************************************
 FD  CSAGML1.
     COPY        CSAGML1    OF   XFDLIB.
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
     03  ST-D20030S1             PIC  X(002).
     03  ST-AJUGFL1              PIC  X(002).
     03  ST-ASOSML1              PIC  X(002).
     03  ST-CSAGML1              PIC  X(002).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SYORI                PIC  X(007).
     03  WK-FILE                 PIC  X(008).
     03  WK-DATE                 PIC  9(006).
     03  WK-TIME                 PIC  9(008).
     03  WK-STATUS               PIC  X(002).
     03  WK-STATUS-R             REDEFINES     WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
     03  WK-WNEI                 PIC  N(008).
     03  WK-WORKCD               PIC  X(004).
     03  WK-SJIOFC               PIC  X(004).
     03  WK-SIJINO               PIC  9(006).
     03  WK-DENPNO               PIC  9(006).
     03  WK-SEIBAN               PIC  X(006).
     03  WK-JYUPTE               PIC  9(011).
     03  WK-NAISU.
       05  WK-NAISU1             PIC  X(001)  OCCURS  6.
     03  WK-NAISU-R.
       05  WK-NAISU2             PIC  X(001)  OCCURS  6.
*    スイッチ・フラグ
 01  SW-AREA.
     03  SW-END                  PIC  X(003).
     03  SW-WRITE                PIC  X(001).
     03  SW-PAGE                 PIC  X(001).
*    添字
 01  IX-AREA.
     03  IX-01                   PIC  9(002).
     03  IDX1                    PIC  9(002).
     03  IDX2                    PIC  9(002).
*    カウンター
 01  CNT-AREA.
     03  CNT-PAGE                PIC  9(005).
     03  CNT-IN                  PIC  9(005).
 01  WK-PGMID                    PIC  X(008) VALUE "D20040PP".
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
                                               UPON  DSP.
*
     PERFORM INIT-SEC.
     PERFORM MAIN-SEC    UNTIL   SW-END  = "END".
     PERFORM FINAL-SEC.
*
     DISPLAY "*     D20030S1 IN    =  " CNT-IN      "     *"
                                               UPON  DSP.
     DISPLAY "*     D20040P1 PAGE  =  " CNT-PAGE    "     *"
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
     OPEN        INPUT           D20030S1
                                 AJUGFL1
                                 ASOSML1
                                 CSAGML1.
     OPEN        OUTPUT          XU04LP.
*
     MOVE    "D20040P1"          TO    PRT-FORMAT.
     MOVE    "SCREEN"            TO    PRT-GROUP.
     PERFORM                     OPEN-CHECK-SEC.
*
*    中間ファイルリード
     PERFORM                     TUKN-READ-SEC.
*
     IF       SW-END =   SPACE
       THEN
         MOVE      WORKCD OF D20030S1  TO  WK-WORKCD
         PERFORM                 SAGO-READ-SEC
         IF   ST-CSAGML1 = "00"
           THEN
             MOVE  WNEI OF CSAGML1  TO  WK-WNEI
           ELSE
             MOVE  SPACE            TO  WK-WNEI
         END-IF
     END-IF.
     MOVE    1                   TO    IX-01.
     PERFORM                     ACCEPT-SEC.
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
     MOVE    SPACE               TO    D20040P1 OF XU04LP.
     PERFORM                     MEISAI-SET1-SEC.
     PERFORM    UNTIL   ( SW-END =   "END" )
                OR      ( WORKCD OF D20030S1  NOT =  WK-WORKCD )
                OR      ( IX-01  >   17    )
         IF   ( WK-SJIOFC  =     SJIOFC OF D20030S1 )   AND
              ( WK-SIJINO  =     SIJINO OF D20030S1 )   AND
              ( WK-DENPNO  =     DENPNO OF D20030S1 )   AND
              ( WK-SEIBAN  =     SEIBAN OF D20030S1 )   AND
              ( SW-WRITE   =     SPACE)
           THEN
             CONTINUE
           ELSE
             PERFORM             MEISAI-SET2-SEC
         END-IF
         PERFORM                 MEISAI-SET3-SEC
     END-PERFORM.
     PERFORM                     PRT-WRITE-SEC.
 MAIN-999.
     EXIT.
******************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE       XU04LP
                 D20030S1
                 AJUGFL1
                 ASOSML1
                 CSAGML1.
 FINAL-999.
     EXIT.
/*****************************************************************
*    明細セット処理１
******************************************************************
 MEISAI-SET1-SEC                 SECTION.
 MEISAI-SET1-010.
*    作成日
     MOVE    WK-DATE             TO    SYRBI  OF D20040P1.
*    時間
     MOVE    WK-TIME(1:2)        TO    JIKAN1 OF D20040P1.
     MOVE    WK-TIME(3:2)        TO    JIKAN2 OF D20040P1.
*    ページ
     ADD     1                   TO    CNT-PAGE.
     MOVE    CNT-PAGE            TO    PAGCNT OF D20040P1.
*    作業内容
     MOVE    WK-WNEI             TO    WNEI   OF D20040P1.
*    抽出範囲
     MOVE    LINK-FROM-DAY       TO    TSFDAY OF D20040P1.
     MOVE    LINK-BY-DAY         TO    TSBDAY OF D20040P1.
 MEISAI-SET1-999.
     EXIT.
/*****************************************************************
*    明細セット処理２
******************************************************************
 MEISAI-SET2-SEC                 SECTION.
 MEISAI-SET2-010.
*    指示区分
     IF      SIJIKB OF D20030S1  =   "2"
       THEN
         MOVE  NC"取消"          TO    SIJIKB OF D20040P1(IX-01)
     END-IF.
*    伝票№
     MOVE    DENPNO OF D20030S1  TO    DENPNO OF D20040P1(IX-01).
*    職場
     PERFORM                     SOSK-READ-SEC.
     IF      ST-ASOSML1      =    "00"
       THEN
         MOVE  BSYNAM OF ASOSML1 TO    BSYNAM OF D20040P1(IX-01)
     END-IF.
*    作業期間
     MOVE    TYOTEI OF D20030S1  TO    TYOTEI OF D20040P1(IX-01).
     IF    ( TYOTEI OF D20030S1  =     ZERO ) AND
           ( KYOTEI OF D20030S1  =     ZERO )
     THEN
       MOVE  SPACE               TO    KKNHNI OF D20040P1(IX-01)
     ELSE
       MOVE  NC"～"              TO    KKNHNI OF D20040P1(IX-01)
     END-IF.
     MOVE    KYOTEI OF D20030S1  TO    KYOTEI OF D20040P1(IX-01).
*    製番
     MOVE    SEIBAN OF D20030S1(1:1)
                                 TO    SEIBN1 OF D20040P1(IX-01).
     MOVE    "-"                 TO    SEIBN2 OF D20040P1(IX-01).
     MOVE    SEIBAN OF D20030S1(2:5)
                                 TO    SEIBN3 OF D20040P1(IX-01).
*    件名
     PERFORM                     JUTU-READ-SEC.
     IF      ST-AJUGFL1  =  "00"
       THEN
         MOVE  KENMEI OF AJUGFL1 TO    KENMEI OF D20040P1(IX-01)
     END-IF.
     MOVE    SJIOFC OF D20030S1  TO    WK-SJIOFC.
     MOVE    SIJINO OF D20030S1  TO    WK-SIJINO.
     MOVE    DENPNO OF D20030S1  TO    WK-DENPNO.
     MOVE    SEIBAN OF D20030S1  TO    WK-SEIBAN.
     MOVE    SPACE               TO    SW-WRITE.
 MEISAI-SET2-999.
     EXIT.
/*****************************************************************
*    明細セット処理３
******************************************************************
 MEISAI-SET3-SEC                 SECTION.
 MEISAI-SET3-010.
*
*    作業区分
     EVALUATE  WRKKBN OF D20030S1
         WHEN  "1"
             MOVE  NC"完成品　"  TO    WRKKBN OF D20040P1(IX-01)
         WHEN  "2"
             MOVE  NC"ユニット"  TO    WRKKBN OF D20040P1(IX-01)
     END-EVALUATE.
*    項目
     MOVE  KOMOKU OF D20030S1    TO    KOMOKU OF D20040P1(IX-01).
*    内容数
     INITIALIZE                        IDX1
                                       IDX2
                                       WK-NAISU
                                       WK-NAISU-R.
     MOVE  NAISU  OF D20030S1    TO    WK-NAISU .
     IF    WK-NAISU(5:2)         =     ZERO
       THEN
         MOVE  SPACE             TO    WK-NAISU(5:2)
       ELSE
       IF  WK-NAISU(5:1)         =     ZERO
         THEN
           MOVE  SPACE           TO    WK-NAISU(5:1)
         ELSE
           CONTINUE
       END-IF
     END-IF.
     PERFORM  VARYING    IDX1    FROM  1  BY  1
              UNTIL      IDX1    >     6
       IF     WK-NAISU1(IDX1)     NOT =    SPACE
         THEN
           ADD           1          TO    IDX2
           MOVE   WK-NAISU1(IDX1)   TO    WK-NAISU2(IDX2)
         ELSE
           CONTINUE
       END-IF
     END-PERFORM.
     MOVE  WK-NAISU-R            TO    NAISU  OF D20040P1(IX-01).
***  MOVE  NAISU  OF D20030S1    TO    NAISU  OF D20040P1(IX-01).
***  IF    NAISU  OF D20030S1(5:1) = "0"
***  THEN
***    IF  NAISU  OF D20030S1(6:1) = "0"
***    THEN
***      MOVE     SPACE          TO    NAISU  OF D20040P1
***                                              (IX-01)(5:2)
***    ELSE
***      MOVE     SPACE          TO    NAISU  OF D20040P1
***                                              (IX-01)(5:1)
***    END-IF
***  END-IF.
*    数量
     MOVE  SURYO  OF D20030S1    TO    SURYO  OF D20040P1(IX-01).
*    受注金額
     MOVE  JYUPTE OF D20030S1    TO    WK-JYUPTE.
     COMPUTE      WK-JYUPTE      =     WK-JYUPTE / 1000.
     MOVE  WK-JYUPTE             TO    JYUPTE OF D20040P1(IX-01).
*    工数
     MOVE  SJKOSU OF D20030S1    TO    SJKOSU OF D20040P1(IX-01).
*    鈑金寸法
     MOVE  "("                   TO    BANLKK OF D20040P1(IX-01).
     MOVE  BANKWG OF D20030S1    TO    BANKWG OF D20040P1(IX-01).
     MOVE  "*"                   TO    BANAS1 OF D20040P1(IX-01).
     MOVE  BANKHG OF D20030S1    TO    BANKHG OF D20040P1(IX-01).
     MOVE  "*"                   TO    BANAS2 OF D20040P1(IX-01).
     MOVE  BANKDG OF D20030S1    TO    BANKDG OF D20040P1(IX-01).
     MOVE  ")"                   TO    BANRKK OF D20040P1(IX-01).
*    木板寸法
     MOVE  "("                   TO    MOKLKK OF D20040P1(IX-01).
     MOVE  MOKU1W OF D20030S1    TO    MOKU1W OF D20040P1(IX-01).
     MOVE  "*"                   TO    MOKAS1 OF D20040P1(IX-01).
     MOVE  MOKU1H OF D20030S1    TO    MOKU1H OF D20040P1(IX-01).
     MOVE  "*"                   TO    MOKAS2 OF D20040P1(IX-01).
     MOVE  MOKU1D OF D20030S1    TO    MOKU1D OF D20040P1(IX-01).
     MOVE  ")"                   TO    MOKRKK OF D20040P1(IX-01).
*    内面
     MOVE  NAIMEN OF D20030S1    TO    NAIMEN OF D20040P1(IX-01).
*    外面
     MOVE  GAIMEN OF D20030S1    TO    GAIMEN OF D20040P1(IX-01).
*    扉裏
     MOVE  TOBURA OF D20030S1    TO    TOBURA OF D20040P1(IX-01).
*    その他
     MOVE  SONOTA OF D20030S1    TO    SONOTA OF D20040P1(IX-01).
*    膜厚
     MOVE  MAKATU OF D20030S1    TO    MAKATU OF D20040P1(IX-01).
*    納期
     MOVE  KANNOK OF D20030S1    TO    KANNOK OF D20040P1(IX-01).
*    木板種別
     EVALUATE  MOKSYU  OF  D20030S1
         WHEN  "1"
             MOVE  NC"ラワン"    TO    MOKSYU OF D20040P1(IX-01)
         WHEN  "2"
             MOVE  NC"堅木　"    TO    MOKSYU OF D20040P1(IX-01)
     END-EVALUATE.
     PERFORM                     TUKN-READ-SEC.
*
     IF       SW-END =   SPACE
       THEN
         PERFORM                 SAGO-READ-SEC
         IF   ST-CSAGML1 = "00"
           THEN
             MOVE  WNEI OF CSAGML1  TO  WK-WNEI
           ELSE
             MOVE  SPACE            TO  WK-WNEI
         END-IF
     END-IF.
     ADD     1                   TO    IX-01.
 MEISAI-SET3-999.
     EXIT.
/*****************************************************************
*    リスト出力処理
******************************************************************
 PRT-WRITE-SEC                   SECTION.
 PRT-WRITE-010.
*    改ページ
     IF  SW-PAGE NOT =   SPACE
       THEN
         MOVE    SPACE           TO    PRT-GROUP
         MOVE    "CT"            TO    PRT-MODE
         MOVE    "PAGE"          TO    PRT-SEIGYO
         WRITE   D20040P1
     END-IF.
*    内容印字
     MOVE   "SCREEN"             TO    PRT-GROUP.
     MOVE    SPACE               TO    PRT-MODE.
     MOVE    SPACE               TO    PRT-SEIGYO.
     WRITE   D20040P1.
     MOVE    "1"                 TO    SW-PAGE.
     MOVE    "1"                 TO    SW-WRITE.
     MOVE     1                  TO    IX-01.
     IF       SW-END =   SPACE
       THEN
         MOVE    WORKCD OF D20030S1  TO    WK-WORKCD
       ELSE
         CONTINUE
     END-IF.
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
     READ      D20030S1.
     EVALUATE  ST-D20030S1
         WHEN  "00"
               ADD    1          TO    CNT-IN
         WHEN  "10"
               MOVE  "END"       TO    SW-END
         WHEN  OTHER
               MOVE  "D20030S1"  TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-D20030S1 TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 TUKN-READ-999.
     EXIT.
/*****************************************************************
*    受注ファイル（鑑）ＲＥＡＤ処理
******************************************************************
 JUTU-READ-SEC                   SECTION.
 JUTU-READ-010.
     MOVE    SEIBAN OF D20030S1  TO    SEIBAN OF AJUGFL1.
     READ      AJUGFL1.
     EVALUATE  ST-AJUGFL1
         WHEN  "00"
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "AJUGFL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-AJUGFL1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JUTU-READ-999.
     EXIT.
/*****************************************************************
*    組織マスタＲＥＡＤ処理
******************************************************************
 SOSK-READ-SEC                   SECTION.
 SOSK-READ-010.
     MOVE    SJIOFC OF D20030S1(1:2)
                                 TO    BSYOCD OF ASOSML1.
     MOVE    SJIOFC OF D20030S1(3:2)
                                 TO    TANCD  OF ASOSML1.
     READ      ASOSML1.
     EVALUATE  ST-ASOSML1
         WHEN  "00"
         WHEN  "23"
                CONTINUE
         WHEN  OTHER
               MOVE  "ASOSML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-ASOSML1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SOSK-READ-999.
     EXIT.
/*****************************************************************
*    作業マスタＲＥＡＤ処理
******************************************************************
 SAGO-READ-SEC                   SECTION.
 SAGO-READ-010.
     IF      LINK-WORKCD         =     SPACE
       THEN
         MOVE    WORKCD OF D20030S1  TO    WORKCD OF CSAGML1
       ELSE
         MOVE    LINK-WORKCD         TO    WORKCD OF CSAGML1
     END-IF.
     READ      CSAGML1.
     EVALUATE  ST-CSAGML1
         WHEN  "00"
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "CSAGML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  ST-CSAGML1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SAGO-READ-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
     IF  PRT-STATUS  NOT =   "00"
       THEN
         MOVE    "XU04LP"        TO  WK-FILE
         MOVE    "OPEN"          TO  WK-SYORI
         MOVE    PRT-STATUS      TO  WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-D20030S1  NOT =   "00"
       THEN
         MOVE    "D20030S1"       TO  WK-FILE
         MOVE    "OPEN"           TO  WK-SYORI
         MOVE    ST-D20030S1      TO  WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-AJUGFL1   NOT =   "00"
       THEN
         MOVE    "AJUGFL1"        TO  WK-FILE
         MOVE    "OPEN"           TO  WK-SYORI
         MOVE    ST-AJUGFL1       TO  WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-ASOSML1   NOT =   "00"
       THEN
         MOVE    "ASOSML1"        TO  WK-FILE
         MOVE    "OPEN"           TO  WK-SYORI
         MOVE    ST-ASOSML1       TO  WK-STATUS
         PERFORM ABEND-SEC
     END-IF.
*
     IF  ST-CSAGML1   NOT =   "00"
       THEN
         MOVE    "CSAGML1"        TO  WK-FILE
         MOVE    "OPEN"           TO  WK-SYORI
         MOVE    ST-CSAGML1       TO  WK-STATUS
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
     DISPLAY "*     F-STS          = " WK-STATUS "         *"
                                                     UPON    DSP.
*
     DISPLAY "***** " WK-PGMID "  " WK-VER " ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20040PP.
