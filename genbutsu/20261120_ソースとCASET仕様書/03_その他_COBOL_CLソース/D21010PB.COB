*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２１０１０ＰＢ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　処理可能端末チェック　　　　　　　　　
* プログラム内容＝　処理しようとしている機能が処理端末で　
*                   処理可能かどうかをチェックする
*                   処理判定結果をパラメータに出力する。
*
*                                               作成日：12.09.07
*                                               更新日：  .  .
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
 IDENTIFICATION                  DIVISION.
 PROGRAM-ID.                     D21010PB.
 ENVIRONMENT                     DIVISION.
 CONFIGURATION                   SECTION.
 SOURCE-COMPUTER.                FACOM.
 OBJECT-COMPUTER.                FACOM.
 SPECIAL-NAMES.
     CONSOLE                     IS  DSP
     SYSOUT                      IS  LST.
 INPUT-OUTPUT                    SECTION.
 FILE-CONTROL.
*    端末グループ管理ファイル
     SELECT    CWSGRFL1     ASSIGN          TO   DA-VI-CWSGRFL1
                            ORGANIZATION    IS   INDEXED
                            ACCESS MODE     IS   RANDOM
                            FILE STATUS     IS   CWSG-STS
                            RECORD KEY      IS   CWSG-GYOMKB
                                                 CWSG-WKSTN.
 DATA                            DIVISION.
 FILE                            SECTION.
*    端末グループ管理ファイル
 FD  CWSGRFL1.
     COPY     CWSGRFL1     OF      XFDLIB
     JOINING  CWSG        TO      ALL   NAMES
                          AS            PREFIX.
****************************************************************
 WORKING-STORAGE                 SECTION.
****************************************************************
 01   WORK-AREA.
*
*  ファイルステータス
   03   FSTS-AREA.
     05  CWSG-STS            PIC X(02).
*
*  プログラムステータス
   03  PG-STS                PIC 9(04).
   03  PGX-STS   REDEFINES   PG-STS.
     05  PG-STSH             PIC X(02).
     05  F-STS               PIC X(02).
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
     05  KEY2-ABN            PIC  9(04).
     05  FILLER              PIC  X(08)  VALUE  "       *".
   03  ABEND-MSG4.
     05  FILLER              PIC  X(16)
                                  VALUE  "*               ".
     05  FILLER              PIC  X(08)  VALUE  "F-STS = ".
     05  FSTS-ABN            PIC  X(02).
     05  FILLER              PIC  X(09)  VALUE  "        *".
   03  ABEND-MSG5.
     05  FILLER              PIC  X(35)
             VALUE  "*****  D21010PB V01/L01 ABEND *****".
**************************************************************
 LINKAGE                         SECTION.
**************************************************************
 01  LINK-GYOMKB             PIC  X(05).
 01  LINK-WKSTN              PIC  X(08).
 01  LINK-ANS                PIC  X(01).
**************************************************************
 PROCEDURE    DIVISION           USING
                                 LINK-GYOMKB
                                 LINK-WKSTN
                                 LINK-ANS.
**************************************************************
*　主処理　                                                  *
**************************************************************
 MAIN             SECTION.
*
     PERFORM  INIT-RTN.
*    処理可能端末かどうかのチェックを行う
     PERFORM  WKSTN-CHK-RTN
*
     PERFORM  END-RTN.
     STOP  RUN.
 MAIN-EXIT.
     EXIT.
**************************************************************
*　初期処理                                                  *
**************************************************************
 INIT-RTN         SECTION.
*
     DISPLAY  "*****  D21010PB V01/L01 START *****"
                                            UPON  DSP.
*  ＜ 初期値設定 ＞
     INITIALIZE   WORK-AREA.
*  ＜ ファイル　ＯＰＥＮ ＞
     OPEN    INPUT           CWSGRFL1.
*  ＜ システム日付・時間の取得 ＞
     ACCEPT  WK-SYS-DATE     FROM           DATE.
     ACCEPT  WK-SYS-TIME     FROM           TIME.
 INIT-RTN-EXIT.
     EXIT.
**************************************************************
*　処理可能端末かどうかのチェックを行う                      *
**************************************************************
 WKSTN-CHK-RTN     SECTION.
*
     MOVE  LINK-GYOMKB       TO  CWSG-GYOMKB.
     MOVE  LINK-WKSTN        TO  CWSG-WKSTN.
     MOVE  "1"               TO  LINK-ANS.
     PERFORM      CWSG-READ-RTN.
*
 WKSTN-CHK-RTN-EXIT.
     EXIT.
***************************************************************
*　端末グループ管理ファイルＲＥＡＤ　　　　　                 *
***************************************************************
 CWSG-READ-RTN         SECTION.
     READ    CWSGRFL1.
     EVALUATE  CWSG-STS
         WHEN  "00"
              MOVE     "0"            TO    LINK-ANS
         WHEN  "23"
              MOVE     "1"            TO    LINK-ANS
         WHEN OTHER
              MOVE     "1"            TO    LINK-ANS
              MOVE     "CWSGRFL1"     TO    FNEM-ABN
              MOVE     "READ    "     TO    FCOM-ABN
              MOVE     CWSG-GYOMKB    TO    KEY1-ABN
              MOVE     CWSG-WKSTN     TO    KEY2-ABN
              MOVE     CWSG-STS       TO    FSTS-ABN
              PERFORM  ABEND-RTN
     END-EVALUATE.
 CWSG-READ-RTN-EXIT.
     EXIT.
****************************************************************
*    終了　処理                                                *
****************************************************************
 END-RTN                SECTION.
* ＜ ファイル　ＣＬＯＳＥ ＞
     CLOSE    CWSGRFL1.
     DISPLAY  "*****  D21010PB V01/L01  END  *****"
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
     CLOSE    CWSGRFL1.
     STOP  RUN.
 ABEND-RTN-EXIT.
     EXIT.
