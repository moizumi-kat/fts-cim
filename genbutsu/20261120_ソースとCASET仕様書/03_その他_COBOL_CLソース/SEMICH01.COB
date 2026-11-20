*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　ＳＥＭＩＣＨ０１　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　生産管理
* プログラム内容＝　生産実績ジャーナルの１～３０の項目を
*                 　展開して製番，項目毎に当日生産実績分解
*                 　ファイルに出力する。
*
*                                   ＩＴ管理センター　村上
*
*                                               作成日：20.08.26
*                                               更新日：  .  .
*
*
 IDENTIFICATION                  DIVISION.
 PROGRAM-ID.                     SEMICH01.
 ENVIRONMENT                     DIVISION.
 CONFIGURATION                   SECTION.
 SOURCE-COMPUTER.                FACOM.
 OBJECT-COMPUTER.                FACOM.
 SPECIAL-NAMES.
     CONSOLE                     IS  DSP
     SYSOUT                      IS  LST.
 INPUT-OUTPUT                    SECTION.
 FILE-CONTROL.
*    生産実績ジャーナルファイル
     SELECT      CSEIJL1    ASSIGN          TO   DA-01-VI-CSEIJL1
                            ORGANIZATION    IS   INDEXED
                            ACCESS MODE     IS   SEQUENTIAL
                            FILE STATUS     IS   CSEI-STS
                            RECORD KEY      IS   CSEI-JSKNO
                                                 CSEI-JSKKBN.
*    当日生産実績分解ファイル
     SELECT      D20400S1   ASSIGN          TO   DA-02-S-D20400S1
                            ORGANIZATION    IS   SEQUENTIAL
                            ACCESS MODE     IS   SEQUENTIAL
                            FILE STATUS     IS   D204-STS.
*
 DATA                            DIVISION.
 FILE                            SECTION.
*    生産実績ジャーナルファイル
 FD  CSEIJL1
     BLOCK    CONTAINS     1      RECORDS.
     COPY     CSEIJL1     OF      XFDLIB
     JOINING  CSEI        TO      ALL   NAMES
                          AS            PREFIX.
*    当日生産実績分解ファイル
 FD  D20400S1
     BLOCK    CONTAINS     136    RECORDS.
     COPY     D20400S1    OF      XFDLIB
     JOINING  D204        TO      ALL   NAMES
                          AS            PREFIX.
****************************************************************
 WORKING-STORAGE                 SECTION.
****************************************************************
 01   WORK-AREA.
*
   03   WK-GRPCD             PIC X(10).
   03   CSEI-END             PIC X(03).
   03   IX1                  PIC 9(03).
   03   IX2                  PIC 9(04).
*
*  ファイルステータス
   03   FSTS-AREA.
     05  CSEI-STS            PIC X(02).
     05  D204-STS            PIC X(02).
*
*  プログラムステータス
   03  PG-STS                PIC 9(04).
   03  PGX-STS   REDEFINES   PG-STS.
     05  PG-STSH             PIC X(02).
     05  F-STS               PIC X(02).
*
*  入出力件数
   03  CNT-AREA.
     05  IN-CNT              PIC 9(06).
     05  OUT-CNT             PIC 9(06).
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
             VALUE  "*****  SEMICH01 V01/L01 ABEND *****".
**************************************************************
 PROCEDURE    DIVISION.
**************************************************************
*　主処理　                                                  *
**************************************************************
 MAIN             SECTION.
     PERFORM  INIT-RTN.
*
*    当日生産実績分解ファイルの作成
*
     PERFORM  DATA-CRT-RTN
              UNTIL    CSEI-END   =   "END".
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
     DISPLAY  "*****  SEMICH01 V01/L01 START *****"
                                            UPON  DSP.
*  ＜ 初期値設定 ＞
     INITIALIZE   WORK-AREA.
*  ＜ ファイル　ＯＰＥＮ ＞
     OPEN    INPUT           CSEIJL1
             OUTPUT          D20400S1.
*  ＜ システム日付・時間の取得 ＞
     ACCEPT  WK-SYS-DATE     FROM           DATE.
     ACCEPT  WK-SYS-TIME     FROM           TIME.
 INIT-RTN-EXIT.
     EXIT.
**************************************************************
*　生産実績ジャーナルの抽出                                  *
**************************************************************
 DATA-CRT-RTN     SECTION.
*  生産実績ジャーナルファイルＲＥＡＤ
     PERFORM      CSEI-READ-RTN.
     IF           CSEI-END      =  "END"
                  GO  TO  DATA-CRT-RTN-EXIT
     END-IF.
*
*  ＜ 初期値設定 ＞
     INITIALIZE   D204-D204FD.
*    共通項目を移送
     MOVE    CSEI-SEIBAN         TO        D204-SEIBAN.
     MOVE    CSEI-WORKNY         TO        D204-WORKCD.
     MOVE    CSEI-JSKOFC         TO        D204-JSKOFC.
*
*   項目の展開及び出力
*
     PERFORM  KOUMOKU-TENKAI-RTN
              VARYING  IX1  FROM 1 BY 1 UNTIL IX1 > 30.
*
 DATA-CRT-RTN-EXIT.
     EXIT.
***************************************************************
*　項目の展開及び出力　                                       *
***************************************************************
 KOUMOKU-TENKAI-RTN         SECTION.
*
     IF  ( CSEI-KAISIK ( IX1 )  =  ZERO )  AND
         ( CSEI-SYRYOK ( IX1 )  =  ZERO )
       THEN
         GO  TO  KOUMOKU-TENKAI-RTN-EXIT
     END-IF.
*
*    DISPLAY "FROM=" CSEI-KAISIK ( IX1 )   UPON   DSP.
*    DISPLAY "TO  =" CSEI-SYRYOK ( IX1 )   UPON   DSP.

     MOVE  CSEI-KAISIK ( IX1 )  TO  IX2.
     PERFORM  VARYING IX2  FROM  CSEI-KAISIK ( IX1 )  BY  1
              UNTIL   IX2   >    CSEI-SYRYOK ( IX1 )
*
         MOVE  IX2  TO  D204-KOMOKU
*        DISPLAY "IX2=" IX2   UPON   DSP
*
*        当日作業実績分解ファイル出力
         PERFORM      D204-WRITE-RTN

     END-PERFORM.
*
*
 KOUMOKU-TENKAI-RTN-EXIT.
     EXIT.
***************************************************************
*　生産実績ジャーナルファイルＲＥＡＤ　                       *
***************************************************************
 CSEI-READ-RTN         SECTION.
*
 CSEI-READ-RTN-01.
*
     READ  CSEIJL1   NEXT
           AT        END
           MOVE     "END"         TO       CSEI-END
           GO        TO           CSEI-READ-RTN-EXIT
     END-READ.
     IF       CSEI-STS   NOT =  "00"
       THEN
         MOVE     "CSEIJL1 "      TO       FNEM-ABN
         MOVE     "READ    "      TO       FCOM-ABN
         MOVE     CSEI-SEIBAN     TO       KEY1-ABN
         MOVE     SPACE           TO       KEY2-ABN
         MOVE     CSEI-STS        TO       FSTS-ABN
         PERFORM  ABEND-RTN
     END-IF.
     COMPUTE  IN-CNT  =  IN-CNT  +  1.
*
*    作業コードが組立のみ抽出
     IF ( CSEI-JSKKBN = "2" ) AND ( CSEI-WORKNY = "2400" )
       THEN
         CONTINUE
     ELSE
         GO  TO  CSEI-READ-RTN-01
     END-IF.
 CSEI-READ-RTN-EXIT.
     EXIT.
***************************************************************
*　　　生産実績ジャーナルファイルＷＲＩＴＥ　　　　　　       *
***************************************************************
 D204-WRITE-RTN        SECTION.
     WRITE D204-D204FD.
     IF       D204-STS   NOT =  "00"
       THEN
         MOVE     "D20400S1"     TO        FNEM-ABN
         MOVE     "WRITE   "     TO        FCOM-ABN
         MOVE     D204-SEIBAN    TO        KEY1-ABN
         MOVE     D204-KOMOKU    TO        KEY2-ABN
         MOVE     D204-STS       TO        FSTS-ABN
         PERFORM   ABEND-RTN
     END-IF.
     COMPUTE  OUT-CNT  =  OUT-CNT  +  1.
 D204-WRITE-RTN-EXIT.
     EXIT.
****************************************************************
*    終了　処理                                                *
****************************************************************
 END-RTN                SECTION.
* ＜ ファイル　ＣＬＯＳＥ ＞
     CLOSE    CSEIJL1
              D20400S1.
     MOVE     "CSEIJL1 "    TO        FNEM-WK.
     MOVE     "IN "         TO        FIO-WK.
     MOVE     IN-CNT        TO        IO-CNT.
     DISPLAY  FIO-AREA      UPON      DSP.
     MOVE     "D20400S1"    TO        FNEM-WK.
     MOVE     "OUT "        TO        FIO-WK.
     MOVE     OUT-CNT       TO        IO-CNT.
     DISPLAY  FIO-AREA      UPON      DSP.
     DISPLAY  "*****  SEMICH01 V01/L01  END  *****"
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
     CLOSE    CSEIJL1
              D20400S1.
     STOP  RUN.
 ABEND-RTN-EXIT.
     EXIT.
