*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　ＳＥＭＩＣＨ０３　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　生産管理
* プログラム内容＝　前日までに出荷計上された製品について
*                 　生産計上されているかどうかチェックし
*                 　生産計上されていないものについては
*                 　生産未計上抽出ファイルに出力する。
*
*                                   ＩＴ管理センター　村上
*
*                                               作成日：20.08.31
*                                               更新日：  .  .
*
*
 IDENTIFICATION                  DIVISION.
 PROGRAM-ID.                     SEMICH03.
 ENVIRONMENT                     DIVISION.
 CONFIGURATION                   SECTION.
 SOURCE-COMPUTER.                FACOM.
 OBJECT-COMPUTER.                FACOM.
 SPECIAL-NAMES.
     CONSOLE                     IS  DSP
     SYSOUT                      IS  LST.
 INPUT-OUTPUT                    SECTION.
 FILE-CONTROL.
*    出荷指示ファイル
     SELECT      AJUKFL1    ASSIGN          TO   DA-01-VI-AJUKFL1
                            ORGANIZATION    IS   INDEXED
                            ACCESS MODE     IS   SEQUENTIAL
                            FILE STATUS     IS   AJUK-STS
                            RECORD KEY      IS   AJUK-SEIBAN
                                                 AJUK-JYUKOU.
*    当日生産実績分解ファイル
     SELECT      D20400S1   ASSIGN          TO   DA-02-S-D20400S1
                            ORGANIZATION    IS   SEQUENTIAL
                            ACCESS MODE     IS   SEQUENTIAL
                            FILE STATUS     IS   D2S1-STS.
*    生産未計上抽出ファイル
     SELECT      D20400S3   ASSIGN          TO   DA-02-S-D20400S3
                            ORGANIZATION    IS   SEQUENTIAL
                            ACCESS MODE     IS   SEQUENTIAL
                            FILE STATUS     IS   D2S3-STS.
*
 DATA                            DIVISION.
 FILE                            SECTION.
*    受注ファイル項目
 FD  AJUKFL1
     BLOCK    CONTAINS     1      RECORDS.
     COPY     AJUKFL1     OF      XFDLIB
     JOINING  AJUK        TO      ALL   NAMES
                          AS            PREFIX.
*    当日生産実績分解ファイル
 FD  D20400S1
     BLOCK    CONTAINS     136    RECORDS.
     COPY     D20400S1    OF      XFDLIB
     JOINING  D2S1        TO      ALL   NAMES
                          AS            PREFIX.
 01  D2S1-D204FD-R        PIC  X(30).
*    生産未計上抽出ファイル
 FD  D20400S3
     BLOCK    CONTAINS     136    RECORDS.
     COPY     D20400S3    OF      XFDLIB
     JOINING  D2S3        TO      ALL   NAMES
                          AS            PREFIX.
***************************************************************
 WORKING-STORAGE                 SECTION.
***************************************************************
 01   WORK-AREA.
*
   03   WK-GRPCD             PIC X(10).
   03   AJUK-END             PIC X(03).
   03   D2S1-END             PIC X(03).
   03   IX1                  PIC 9(04).
   03   IX2                  PIC 9(04).
   03   D2S1-MAX             PIC 9(05).
   03   WK-SEI-FLG           PIC 9(01).
*
*  ファイルステータス
   03   FSTS-AREA.
     05  AJUK-STS            PIC X(02).
     05  D2S1-STS            PIC X(02).
     05  D2S3-STS            PIC X(02).
*
*  プログラムステータス
   03  PG-STS                PIC 9(04).
   03  PGX-STS   REDEFINES   PG-STS.
     05  PG-STSH             PIC X(02).
     05  F-STS               PIC X(02).
*
*  入出力件数
   03  CNT-AREA.
     05  AJUK-IN-CNT         PIC 9(06).
     05  D2S1-IN-CNT         PIC 9(06).
     05  D2S3-OUT-CNT        PIC 9(06).
*
*  ＜システム日付　エリア＞
   03  WK-SYS-DATE.
     05  WK-SYS-YY           PIC 9(02).
     05  WK-SYS-MM           PIC 9(02).
     05  WK-SYS-DD           PIC 9(02).
*
*  ＜システム時間　エリア＞
   03  WK-SYS-TIME.
     05  WK-SYS-HT           PIC  9(02).
     05  WK-SYS-MT           PIC  9(02).
     05  WK-SYS-ST           PIC  9(02).
     05  WK-SYS-SST          PIC  9(02).
*
*  ＜システム日付　編集＞
   03  WK-CRT-DATE           PIC  9(08).
   03  WK-CRTX-DATE          REDEFINES     WK-CRT-DATE.
     05  WK-CRT-YH           PIC 9(02).
     05  WK-CRT-YT           PIC 9(02).
     05  WK-CRT-MM           PIC 9(02).
     05  WK-CRT-DD           PIC 9(02).
*
*  ＜システム時間　編集＞
   03  WK-CRT-TIME           PIC  9(06).
   03  WK-CRTX-TIME          REDEFINES     WK-CRT-TIME.
     05  WK-CRT-HT           PIC  9(02).
     05  WK-CRT-MT           PIC  9(02).
     05  WK-CRT-ST           PIC  9(02).
*
*  ＜メッセージ＞
 01  MSG-AREA.
   03  FIO-AREA.
     05  FILLER              PIC  X(07)  VALUE  "*      ".
     05  FNEM-WK             PIC  X(08).
     05  FILLER              PIC  X(01)  VALUE  SPACE.
     05  FIO-WK              PIC  X(03).
     05  FILLER              PIC  X(04)  VALUE  "  = ".
     05  IO-CNT              PIC  9(06).
     05  FILLER              PIC  X(06)  VALUE  "     *".
   03  ABEND-MSG1.
     05  FILLER              PIC  X(07)  VALUE   "*****  ".
     05  FNEM-ABN            PIC  X(08).
     05  FILLER              PIC  X(01)  VALUE   " ".
     05  FCOM-ABN            PIC  X(08).
     05  ERR-ABN             PIC  X(11)
                                    VALUE  " ERR  *****".
   03  ABEND-MSG2.
     05  FILLER              PIC  X(16)
                                  VALUE  "*               ".
     05  FILLER              PIC  X(07)  VALUE  "KEY1 = ".
     05  KEY1-ABN            PIC  X(06).
     05  FILLER              PIC  X(06)  VALUE  "     *".
   03  ABEND-MSG3.
     05  FILLER              PIC  X(16)
                                  VALUE  "*               ".
     05  FILLER              PIC  X(07)  VALUE  "KEY2 = ".
     05  KEY2-ABN            PIC  X(01).
     05  FILLER              PIC  X(08)  VALUE  "       *".
   03  ABEND-MSG4.
     05  FILLER              PIC  X(16)
                                  VALUE  "*               ".
     05  FILLER              PIC  X(08)  VALUE  "F-STS = ".
     05  FSTS-ABN            PIC  X(02).
     05  FILLER              PIC  X(09)  VALUE  "        *".
   03  ABEND-MSG5.
     05  FILLER              PIC  X(35)
             VALUE  "*****  SEMICH03 V01/L01 ABEND *****".
*
 01 D2S1-AREA.
   03  D2S1-INCORE  OCCURS  10000.
     05  D2S1-REC              PIC  X(30).
     05  D2S1-REC-R            REDEFINES  D2S1-REC.
       07  S1-SEIBAN           PIC  X(06).
       07  S1-KOMOKU           PIC  9(04).
       07  S1-WORKCD           PIC  X(04).
       07  S1-JSKOFC           PIC  X(04).
       07  S1-YOBI             PIC  X(12).
*
**************************************************************
 PROCEDURE    DIVISION.
**************************************************************
*　主処理　                                                  *
**************************************************************
 MAIN             SECTION.
     PERFORM  INIT-RTN.
*
*    生産未計上抽出ファイルの作成
*
     PERFORM  DATA-CRT-RTN
              UNTIL    AJUK-END   =   "END".
*
 MAIN-0010.
     PERFORM  END-RTN.
     STOP  RUN.
 MAIN-EXIT.
     EXIT.
**************************************************************
*　初期処理                                                  *
**************************************************************
 INIT-RTN         SECTION.
*
     DISPLAY  "*****  SEMICH03 V01/L01 START *****"
                                            UPON  DSP.
*  ＜ 初期値設定 ＞
     INITIALIZE   WORK-AREA
                  CNT-AREA
                  D2S1-AREA.
*  ＜ ファイル　ＯＰＥＮ ＞
     OPEN    INPUT           AJUKFL1
                             D20400S1
             OUTPUT          D20400S3.
*  ＜ システム日付・時間の取得 ＞
     ACCEPT  WK-SYS-DATE     FROM           DATE.
     ACCEPT  WK-SYS-TIME     FROM           TIME.
*
*    当日日付８桁YYYYMMDD設定
*
     MOVE 20         TO   WK-CRT-YH.
     MOVE WK-SYS-YY  TO   WK-CRT-YT.
     MOVE WK-SYS-MM  TO   WK-CRT-MM.
     MOVE WK-SYS-DD  TO   WK-CRT-DD.
*
*
*    当日生産実績分解ファイルをメモリー上に読込み
     MOVE  ZERO  TO  IX1.
     PERFORM  D2S1-INCORE-RTN
              UNTIL    D2S1-END   =   "END".
     MOVE  IX1   TO  D2S1-MAX.
*
 INIT-RTN-EXIT.
     EXIT.
**************************************************************
*　当日生産実績分解ファイルをメモリー上に読込み              *
**************************************************************
 D2S1-INCORE-RTN     SECTION.
*  出荷指示ファイルＲＥＡＤ
     PERFORM      D2S1-READ-RTN.
     IF           D2S1-END      =  "END"
                  GO  TO  D2S1-INCORE-RTN-EXIT
     END-IF.
*
     ADD  1  TO  IX1.
*
     MOVE  D2S1-D204FD-R   TO  D2S1-REC ( IX1 ).
*
 D2S1-INCORE-RTN-EXIT.
     EXIT.
**************************************************************
*　生産未計上抽出ファイルの作成                              *
**************************************************************
 DATA-CRT-RTN     SECTION.
*  受注ファイル項目ＲＥＡＤ
     PERFORM      AJUK-READ-RTN.
     IF           AJUK-END      =  "END"
                  GO  TO  DATA-CRT-RTN-EXIT
     END-IF.
*
*    WK-SEIMI-FLG　０：生産未計上　1：生産計上済
*
     MOVE  ZERO   TO  WK-SEI-FLG.
*    当日生産実績分解Ｆのテーブルから生産計上済の確認
     PERFORM  D2S1-CHECK-RTN.
*
     IF  WK-SEI-FLG  =  1  THEN
         GO  TO  DATA-CRT-RTN-EXIT
     END-IF.
*
*  ＜ 初期値設定 ＞
     INITIALIZE   D2S3-D204F3.
*    共通項目を移送
     MOVE    SPACE               TO        D2S3-TOJFLG.
     MOVE    AJUK-SEIBAN         TO        D2S3-SEIBAN.
     MOVE    AJUK-JYUKOU         TO        D2S3-KOMOKU.
     MOVE    AJUK-SYKDAY         TO        D2S3-SYUYMD.
*
     PERFORM  D2S3-WRITE-RTN.
*
 DATA-CRT-RTN-EXIT.
     EXIT.
***************************************************************
*　当日生産実績分解ファイルＲＥＡＤ　                         *
***************************************************************
 D2S1-READ-RTN         SECTION.
*
 D2S1-READ-RTN-01.
*
     READ  D20400S1
           AT        END
           MOVE     "END"         TO       D2S1-END
           GO        TO           D2S1-READ-RTN-EXIT
     END-READ.
     IF       D2S1-STS   NOT =  "00"
       THEN
         MOVE     "D20400S1"      TO       FNEM-ABN
         MOVE     "READ    "      TO       FCOM-ABN
         MOVE     D2S1-SEIBAN     TO       KEY1-ABN
         MOVE     D2S1-KOMOKU     TO       KEY2-ABN
         MOVE     D2S1-STS        TO       FSTS-ABN
         PERFORM  ABEND-RTN
     END-IF.
     COMPUTE  D2S1-IN-CNT  =  D2S1-IN-CNT  +  1.
 D2S1-READ-RTN-EXIT.
     EXIT.
***************************************************************
*　受注ファイル項目ＲＥＡＤ　                                 *
***************************************************************
 AJUK-READ-RTN         SECTION.
*
 AJUK-READ-RTN-01.
*
     READ  AJUKFL1   NEXT
           AT        END
           MOVE     "END"         TO       AJUK-END
           GO        TO           AJUK-READ-RTN-EXIT
     END-READ.
     IF       AJUK-STS   NOT =  "00"
       THEN
         MOVE     "AJUKFL1 "      TO       FNEM-ABN
         MOVE     "READ    "      TO       FCOM-ABN
         MOVE     AJUK-SEIBAN     TO       KEY1-ABN
         MOVE     AJUK-JYUKOU     TO       KEY2-ABN
         MOVE     AJUK-STS        TO       FSTS-ABN
         PERFORM  ABEND-RTN
     END-IF.
     COMPUTE  AJUK-IN-CNT  =  AJUK-IN-CNT  +  1.
*
*    出荷済かつ生産未計上のレコードを抽出
     IF  ( AJUK-SYKDAY NOT = ZERO ) AND
         ( AJUK-SEIDAY     = ZERO )
       THEN
         CONTINUE
     ELSE
         GO  TO  AJUK-READ-RTN-01
     END-IF.
 AJUK-READ-RTN-EXIT.
     EXIT.
***************************************************************
*　当日生産実績分解Ｆのテーブルから生産計上済の確認           *
***************************************************************
 D2S1-CHECK-RTN         SECTION.
*
     MOVE  ZERO  TO  IX2.
     PERFORM  VARYING IX2  FROM  1  BY  1
              UNTIL   ( IX2  >  D2S1-MAX )
         IF  ( S1-SEIBAN ( IX2 ) = AJUK-SEIBAN ) AND
             ( S1-KOMOKU ( IX2 ) = AJUK-JYUKOU )
           THEN
*            生産計上済
             MOVE  1  TO  WK-SEI-FLG
         ELSE
             CONTINUE
         END-IF
     END-PERFORM.
*
 D2S1-CHECK-RTN-EXIT.
     EXIT.
***************************************************************
*　　　生産未計上抽出ファイルＷＲＩＴＥ　　　　　　　　       *
***************************************************************
 D2S3-WRITE-RTN        SECTION.
     WRITE D2S3-D204F3.
     IF       D2S3-STS   NOT =  "00"
       THEN
         MOVE     "D20400S3"     TO        FNEM-ABN
         MOVE     "WRITE   "     TO        FCOM-ABN
         MOVE     D2S3-SEIBAN    TO        KEY1-ABN
         MOVE     D2S3-KOMOKU    TO        KEY2-ABN
         MOVE     D2S3-STS       TO        FSTS-ABN
         PERFORM   ABEND-RTN
     END-IF.
     COMPUTE  D2S3-OUT-CNT  =  D2S3-OUT-CNT  +  1.
 D2S3-WRITE-RTN-EXIT.
     EXIT.
***************************************************************
*    終了　処理                                               *
***************************************************************
 END-RTN                SECTION.
* ＜ ファイル　ＣＬＯＳＥ ＞
     CLOSE    AJUKFL1
              D20400S1
              D20400S3.
*
     MOVE     "AJUKFL1 "    TO        FNEM-WK.
     MOVE     "IN "         TO        FIO-WK.
     MOVE     AJUK-IN-CNT   TO        IO-CNT.
     DISPLAY  FIO-AREA      UPON      DSP.
*
     MOVE     "D20400S1"    TO        FNEM-WK.
     MOVE     "IN "         TO        FIO-WK.
     MOVE     D2S1-IN-CNT   TO        IO-CNT.
     DISPLAY  FIO-AREA      UPON      DSP.
*
     MOVE     "D20400S3"    TO        FNEM-WK.
     MOVE     "OUT "        TO        FIO-WK.
     MOVE     D2S3-OUT-CNT  TO        IO-CNT.
     DISPLAY  FIO-AREA      UPON      DSP.
     DISPLAY  "*****  SEMICH03 V01/L01  END  *****"
                             UPON     DSP.
 END-RTN-EXIT.
     EXIT.
****************************************************************
*    異常終了　                                                *
****************************************************************
 ABEND-RTN               SECTION.
     DISPLAY  ABEND-MSG1    UPON      DSP.
     DISPLAY  ABEND-MSG2    UPON      DSP.
     DISPLAY  ABEND-MSG3    UPON      DSP.
     DISPLAY  ABEND-MSG4    UPON      DSP.
     DISPLAY  ABEND-MSG5    UPON      DSP.
     MOVE     "40"          TO        PG-STSH.
     MOVE     FSTS-ABN      TO        F-STS.
     MOVE     PG-STS        TO        PROGRAM-STATUS.
* ＜ ファイル　ＣＬＯＳＥ ＞
     CLOSE    AJUKFL1
              D20400S1
              D20400S3.
     STOP  RUN.
 ABEND-RTN-EXIT.
     EXIT.
