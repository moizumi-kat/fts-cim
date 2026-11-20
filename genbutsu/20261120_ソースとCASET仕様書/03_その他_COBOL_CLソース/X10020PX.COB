*X10020PX  COPYGIGHT FUJITSU LIMITED 1993
******************************************************************
*
*    REMARKS         V01/L01
*
*    ｻﾌﾞｼｽﾃﾑﾒｲ   :   共通
*    ﾌｧﾝｸｼｮﾝﾒｲ   :
*    ﾓｼﾞｭｰﾙﾒｲ    :   日付取得サブルーチン
*    ﾓｼﾞｭｰﾙID    :   X10020PX
*
*
******************************************************************
 IDENTIFICATION          DIVISION.
 PROGRAM-ID.             X10020PX.
*
 ENVIRONMENT             DIVISION.
 CONFIGURATION           SECTION.
 SOURCE-COMPUTER.        FACOM K.
 OBJECT-COMPUTER.        FACOM K.
 SPECIAL-NAMES.
     CONSOLE                           IS    DSPOUT.
 INPUT-OUTPUT            SECTION.
 FILE-CONTROL.
     SELECT  CCALML1     ASSIGN  TO    DA-VI-CCALML1
             ORGANIZATION        IS    INDEXED
             ACCESS      MODE    IS    DYNAMIC
             RECORD      KEY     IS    L1-NEN
                                       L1-TSUKI
                                       L1-HIZUKE
             FILE        STATUS  IS    L1-STATUS.
     SELECT  CCALML2     ASSIGN  TO    DA-VI-CCALML2
             ORGANIZATION        IS    INDEXED
             ACCESS      MODE    IS    DYNAMIC
             RECORD      KEY     IS    L2-KADOUH
                                 WITH  DUPLICATES
             FILE        STATUS  IS    L2-STATUS.

/
 DATA                    DIVISION.
 FILE                    SECTION.
 FD  CCALML1             IS      EXTERNAL.
     COPY    CCALML1     OF      XFDLIB
     JOINING  L1         TO      ALL   NAMES
                         AS            PREFIX.
 FD  CCALML2             IS      EXTERNAL.
     COPY    CCALML2     OF      XFDLIB
     JOINING  L2         TO      ALL   NAMES
                         AS            PREFIX.
*
 WORKING-STORAGE         SECTION.
 01  WORK-AREA.
     03  L1-STATUS       PIC     X(02).
     03  L2-STATUS       PIC     X(02).
     03  WORK-NISU       PIC     9(04).
 01  PARADATA.
     03  KIJYUNBI        PIC     9(08).
     03  SYORIKBN        PIC     X(01).
     03  NISU            PIC     9(04).
     03  KAITOBI         PIC     9(08).
     03  ERRFLG          PIC     X(03).
 LINKAGE                 SECTION.
 01  PARADATAX           PIC     X(24).
/
 PROCEDURE               DIVISION    USING      PARADATAX.
*
**********************************************************
*       メイン　ルーチン
**********************************************************
 MAIN                    SECTION.
 BEGIN.
     MOVE    PARADATAX   TO      PARADATA.
***  OPEN    INPUT       CCALML1.
***  OPEN    INPUT       CCALML2.
***  CALL    "XMROTSTR"
     PERFORM             SUB-RTN.
*    DISPLAY "ｶｲﾄｳﾋﾞ==>  "  KAITOBI  UPON DSPOUT.
*    DISPLAY "ﾌﾗｸﾞ  ==>  "  ERRFLG   UPON DSPOUT.
     MOVE    PARADATA    TO PARADATAX.
***  CALL    "XMROTEND"
***  CLOSE               CCALML1.
***  CLOSE               CCALML2.
 FIN.
     EXIT    PROGRAM.
/
 SUB-RTN                 SECTION.
**********************************************************
*         S U B - R T N                                  *
**********************************************************
     INITIALIZE    KAITOBI   WORK-AREA   ERRFLG.
     MOVE   KIJYUNBI   TO        L1-YMD.
     READ   CCALML1    KEY   IS  L1-NEN L1-TSUKI L1-HIZUKE
            INVALID    KEY
              MOVE     "NG1"     TO  ERRFLG
              GO                 TO  SUB-RTN-EXT.
     IF  SYORIKBN   =     "1"
         COMPUTE   WORK-NISU  =  L1-KADOUH + NISU
         ELSE
          IF  SYORIKBN   =    "2"
              COMPUTE   WORK-NISU =  L1-KADOUH - NISU
              IF        L1-KADOUF    =  "1"
                COMPUTE WORK-NISU =  WORK-NISU + 1
              END-IF
              ELSE
              MOVE     "NG3"     TO  ERRFLG
               GO TO  SUB-RTN-EXT
          END-IF
     END-IF.
     MOVE   WORK-NISU  TO      L2-KADOUH.
     START  CCALML2    KEY IS = L2-KADOUH
            INVALID    KEY
              MOVE     "NG2"     TO  ERRFLG
              GO                 TO  SUB-RTN-EXT.
 SUB-RTN-001.
     READ   CCALML2    NEXT
            AT END     MOVE    "NG2"   TO   ERRFLG
                       GO              TO   SUB-RTN-EXT.
     IF     L2-KADOUF       =    "0"
            MOVE    L2-YMD       TO  KAITOBI
            MOVE    "OK "        TO  ERRFLG
         ELSE
            GO TO   SUB-RTN-001
     END-IF.
 SUB-RTN-EXT.
     EXIT.
