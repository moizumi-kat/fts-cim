
*****************************************************************
*
* ƒvƒƒOƒ‰ƒ€‚h‚c@‚l‚i‚r‚O‚W‚O‚b‚r@
* ƒvƒƒOƒ‰ƒ€Œ¾Œê@‚b‚n‚a‚n‚k‚f
*
* ƒTƒuƒVƒXƒeƒ€–¼@ÝŒvŠÇ—ƒVƒXƒeƒ€
*
* ˆ—ŠT—v@@@  V–¢Žó’•¨Œì}ˆË—Š@Æ‰ï
*
*
*                                ‚r‚q‚b‚k‚h‚aF FCSLIB
*                                ‚n‚a‚i‚k‚h‚aF FCPLIB
*                                ì@¬@“ú@F 2012.07.03
*
* •ÏXŠT—v@@@@Žó’Ï‚ÌŒ©Ï”Ô†‚ªŽ¯•Ê‚Å‚«‚é‚æ‚¤‚É‘Î‰ž
*                   î•ñ•¨Œƒtƒ@ƒCƒ‹‚Ì‘S»”Ô”‚ª„‚O‚ÌŽž
*                   Œ©Ï‡‚‚ðÔF‚Å•\Ž¦‚·‚éB
*                   ‚h‚sŠÇ—Žº@‘ºã
*                                •Ï@X@“ú@F 2013.01.09
*
* •ÏXŠT—v@@@@‹àŠzŒðÂó‹µ‹æ•ª‚Ìà–¾•¶Œ¾•ÏX
*                   u–{•”’·³”FÏvËu“à’èÏv
*                   uâg‹cÏvËuŽó’“o˜^‘Ò‚¿vv
*                   ‚h‚sŠÇ—ƒZƒ“ƒ^[@‘ºã
*                                •Ï@X@“ú@F 2022.02.10
*
*****************************************************************
 IDENTIFICATION      DIVISION.
*--------------------------------*
 PROGRAM-ID.         MJS080CS.
*
 DATE-COMPILED.                  TODAY.
 ENVIRONMENT                     DIVISION.
 CONFIGURATION                   SECTION.
 SOURCE-COMPUTER.                FACOM  PRIMERGY6300.
 OBJECT-COMPUTER.                FACOM  PRIMERGY6300.
 SPECIAL-NAMES.
     CONSOLE                     IS     DSPMSG.
*
 INPUT-OUTPUT                    SECTION.
 FILE-CONTROL.
     SELECT  ‰æ–Êƒtƒ@ƒCƒ‹  ASSIGN  TO  01-GS-DSPF
                           FORMAT             IS  G-NAME
                           GROUP              IS  G-GRP
                           PROCESSING   MODE  IS  G-EXC
                           SELECTED FUNCTION  IS  G-ATT
                           FILE   STATUS      IS  F-STT.
*–¢Žó’•¨Œì}ˆË—Šƒtƒ@ƒCƒ‹
     SELECT  ˆË—Šƒtƒ@ƒCƒ‹       ASSIGN  TO  DA-01-VI-MIJUSJL1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD  KEY IS
                                               ˆË—Š|’[––”Ô†
                                               ˆË—Š|Œ©Ï”Ô†
                                FILE   STATUS    IS  F1-STS.
*‘gDƒ}ƒXƒ^
     SELECT  ‘gDƒ}ƒXƒ^         ASSIGN  TO  DA-01-VI-ASOSML1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD      KEY  IS
                                            ‘gD|•”ŠƒR[ƒh
                                            ‘gD|’S“–ŽÒŒWƒR[ƒh
                                FILE   STATUS    IS  F2-STS.
*Žæˆøæƒ}ƒXƒ^
     SELECT  Žæˆøæƒ}ƒXƒ^       ASSIGN  TO  DA-01-VI-ATORML1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD      KEY  IS
                                            Žæˆø|ŽæˆøæƒR[ƒh
                                FILE   STATUS    IS  F3-STS.
*î•ñ•¨ŒŠÓƒtƒ@ƒCƒ‹
     SELECT  î•ñ•¨Œƒtƒ@ƒCƒ‹   ASSIGN  TO  DA-01-VI-AJBGFL1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD      KEY  IS
                                            •¨Œ|Œ©Ïƒiƒ“ƒo[
                                FILE   STATUS    IS  F4-STS.
*–¢Žó’•¨Œì}ˆË—ŠÆ‰ïƒtƒ@ƒCƒ‹
     SELECT  Æ‰ïƒtƒ@ƒCƒ‹       ASSIGN  TO  DA-01-VI-MIJUSSL3
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  SEQUENTIAL
                                RECORD  KEY IS
                                               Æ‰ï|•”ŠƒR[ƒh
                                               Æ‰ï|Œ©Ï”Ô†
                                FILE   STATUS    IS  F5-STS.
*•¨ŒŒŸ“¢Œˆ’èƒtƒ@ƒCƒ‹
     SELECT  Œˆ’èƒtƒ@ƒCƒ‹       ASSIGN  TO  DA-01-VI-KETUTER1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD KEY IS
                                        Œˆ’è|Œ©Ï”Ô†
                                FILE   STATUS    IS  F6-STS.
*î•ñ•¨Œ€–Úƒtƒ@ƒCƒ‹
     SELECT  î•ñ€–Úƒtƒ@ƒCƒ‹   ASSIGN  TO  DA-01-VI-AJBKFL1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  SEQUENTIAL
                                RECORD KEY IS
                                        €–Ú|Œ©Ïƒiƒ“ƒo[
                                        €–Ú|Œ©Ï€”Ô
                                FILE   STATUS    IS  F7-STS.
     SELECT  Žd—lƒ}ƒXƒ^         ASSIGN  TO  DA-01-VI-ASIYML1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD KEY IS
                                        Žd—l|Žd—lƒR[ƒh
                                FILE   STATUS    IS  F8-STS.
*–¢Žó’•¨Œì}ˆË—ŠÆ‰ïƒtƒ@ƒCƒ‹
     SELECT  Æ‰ïƒtƒ@ƒCƒ‹‚Q     ASSIGN  TO  DA-01-VI-MIJUSSL2
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD  KEY IS
                                               Æ‰ï‚Q|’[––”Ô†
                                               Æ‰ï‚Q|Œ©Ï”Ô†
                                FILE   STATUS    IS  F9-STS.
*--------------------------------*
 DATA                DIVISION.
*--------------------------------*
 FILE                SECTION.
*--------------------------------*
*       ‰æ–Ê’è‹`@@@           *
*--------------------------------*
 FD  ‰æ–Êƒtƒ@ƒCƒ‹.
     COPY  MJS080D1
                     OF  XMDLIB  JOINING   ‰æ–Ê
                     AS  PREFIX.
     COPY  MJS080D2
                     OF  XMDLIB  JOINING   ‰æ–Ê‚P
                     AS  PREFIX.
*===============================================================*
*       –¢Žó’•¨Œì}ˆË—Šƒtƒ@ƒCƒ‹
*===============================================================*
 FD  ˆË—Šƒtƒ@ƒCƒ‹.
     COPY  MIJUSJL1  OF  XFDLIB  JOINING  ˆË—Š AS  PREFIX.
*===============================================================*
*       ‘gDƒ}ƒXƒ^
*===============================================================*
 FD  ‘gDƒ}ƒXƒ^.
     COPY  ASOSML1   OF  XFDLIB  JOINING  ‘gD AS  PREFIX.
*===============================================================*
*       Žæˆøæƒ}ƒXƒ^
*===============================================================*
 FD  Žæˆøæƒ}ƒXƒ^.
     COPY  ATORML1   OF  XFDLIB  JOINING  Žæˆø AS  PREFIX.
*===============================================================*
*       î•ñ•¨ŒŠÓƒtƒ@ƒCƒ‹
*===============================================================*
 FD  î•ñ•¨Œƒtƒ@ƒCƒ‹.
     COPY  AJBGFL1   OF  XFDLIB  JOINING  •¨Œ AS  PREFIX.
*===============================================================*
*       –¢Žó’•¨Œì}ˆË—ŠÆ‰ïƒtƒ@ƒCƒ‹
*===============================================================*
 FD  Æ‰ïƒtƒ@ƒCƒ‹.
     COPY  MIJUSSL1  OF  XFDLIB  JOINING  Æ‰ï AS  PREFIX.
*===============================================================*
*       •¨ŒŒŸ“¢Œˆ’èƒtƒ@ƒCƒ‹
*===============================================================*
 FD  Œˆ’èƒtƒ@ƒCƒ‹.
     COPY  KETUTER1 OF   XFDLIB  JOINING  Œˆ’è    AS  PREFIX.
*===============================================================*
*       î•ñ•¨Œ€–Úƒtƒ@ƒCƒ‹
*===============================================================*
 FD  î•ñ€–Úƒtƒ@ƒCƒ‹.
     COPY  AJBKFL1  OF   XFDLIB  JOINING  €–Ú    AS  PREFIX.
*===============================================================*
*       Žd—lƒ}ƒXƒ^
*===============================================================*
 FD  Žd—lƒ}ƒXƒ^.
     COPY  ASIYML1  OF   XFDLIB  JOINING  Žd—l    AS  PREFIX.
*===============================================================*
*       –¢Žó’•¨Œì}ˆË—ŠÆ‰ïƒtƒ@ƒCƒ‹
*===============================================================*
 FD  Æ‰ïƒtƒ@ƒCƒ‹‚Q.
     COPY  MIJUSSL2  OF  XFDLIB  JOINING  Æ‰ï‚Q AS  PREFIX.
*--------------------------------*
 WORKING-STORAGE     SECTION.
*
 77  ERR-FLAG                PIC  9(02)      VALUE   ZERO.
 77  PF-FLAG                 PIC  9(02)      VALUE   ZERO.
 77  WK-NE                   PIC  X(02)      VALUE   SPACES.
 77  GM-END                  PIC  9(01)      VALUE   ZERO.
 77  END-FLAG                PIC  9(01)      VALUE   ZERO.
 77  WK-SELECT               PIC  9(01)      VALUE   ZERO.
 77  WK-GOKEI1               PIC S9(09)V99   VALUE   ZERO.
 77  WK-GOKEI2               PIC S9(09)      VALUE   ZERO.
 77  WK-STANKA               PIC S9(09)      VALUE   ZERO.
 77  WK-ZTANKA               PIC S9(09)      VALUE   ZERO.
 77  WK-KTANKA               PIC S9(09)      VALUE   ZERO.
 77  WK-KINGAKU              PIC S9(09)      VALUE   ZERO.
 77  WK-COUNT                PIC S9(09)      VALUE   ZERO.
 77  READ-SEIBAN             PIC  X(07)      VALUE   SPACES.
 77  READ-BANGOU             PIC  X(05)      VALUE   SPACES.
 77  WK-SEIKAN               PIC S9(09)      VALUE   ZERO.
 77  WK-SEIGEN               PIC S9(09)      VALUE   ZERO.
 77  WK-SOGENKA              PIC S9(09)      VALUE   ZERO.
 77  WK-N                    PIC  9(03)      VALUE   ZERO.
 77  CH-BUCODE               PIC  X(02)      VALUE   SPACES.
*
*
 01  WK-PAGE.
     03  WK-PAGE1            PIC  S9(09).
     03  WK-PAGE2            PIC  S9(09).
     03  WK-PAGE3            PIC  S9(09).
     03  WK-PAGE4            PIC  S9(09).
     03  WK-PAGE5            PIC  S9(09).
*    ƒXƒe[ƒ^ƒXƒGƒŠƒA
 01  STATUS-AREA.
     03  F1-STS                  PIC  X(02).
     03  F2-STS                  PIC  X(02).
     03  F3-STS                  PIC  X(02).
     03  F4-STS                  PIC  X(02).
     03  F5-STS                  PIC  X(02).
     03  F6-STS                  PIC  X(02).
     03  F7-STS                  PIC  X(02).
     03  F8-STS                  PIC  X(02).
     03  F9-STS                  PIC  X(02).
     03  F10-STS                 PIC  X(02).
     03  LST-STACD               PIC  X(02).
     03  LST-STACD2              PIC  X(04).

*    ƒtƒ‰ƒOƒGƒŠƒA
 01  FLG-AREA.
     03  END-FLG                 PIC  X(03).
     03  ERR-FLG                 PIC  9(02).
     03  SEL-FLG                 PIC  X(03).

*  @ƒCƒ“ƒfƒbƒNƒXƒGƒŠƒA
 01  INDEX-AREA.
     03  IDX1                    PIC  S9(04) PACKED-DECIMAL.
     03  IDX2                    PIC  S9(04) PACKED-DECIMAL.
     03  IDX3                    PIC  S9(04) PACKED-DECIMAL.
     03  IDX4                    PIC  S9(04) PACKED-DECIMAL.
     03  IDX5                    PIC  S9(04) PACKED-DECIMAL.
     03  IDX6                    PIC  S9(04) PACKED-DECIMAL.
     03  IDX11                   PIC  S9(04) PACKED-DECIMAL.
     03  IDX12                   PIC  S9(04) PACKED-DECIMAL.
     03  IDX13                   PIC  S9(04) PACKED-DECIMAL.
     03  IDX14                   PIC  S9(04) PACKED-DECIMAL.
     03  IDX15                   PIC  S9(04) PACKED-DECIMAL.
     03  IDX16                   PIC  S9(04) PACKED-DECIMAL.
     03  IDX                     PIC  S9(04) PACKED-DECIMAL.
     03  WK-IDX2                 PIC  S9(04) PACKED-DECIMAL.
     03  START-IDX2              PIC  S9(04) PACKED-DECIMAL.
     03  N                       PIC  S9(04) PACKED-DECIMAL.
     03  C-IDX1                  PIC  S9(04) PACKED-DECIMAL.
     03  C-IDX2                  PIC  S9(04) PACKED-DECIMAL.

*    ƒ[ƒNƒGƒŠƒA
 01  SAVE-AREA.
     03  SAVE-GROUP              PIC   X(08).
     03  SAVE-MODE               PIC   X(02).
     03  SAVE-PAGE               PIC  S9(04) PACKED-DECIMAL.
     03  SAVE-LINE               PIC  S9(04) PACKED-DECIMAL.
     03  SAVE-MITUNO             PIC   X(08).
     03  SAVE-DATE               PIC   9(08).
     03  SAVE-DKBN               PIC   9(01).
     03  SAVE-KOMOKU             PIC  S9(04) PACKED-DECIMAL.
     03  SAVE-JYOTEI             PIC  S9(12) PACKED-DECIMAL.
*

*    ƒVƒXƒeƒ€“ú•tEŽžŠÔ
 01  DATE-AREA                   PIC  X(08).
 01  DATE-AREA-R       REDEFINES DATE-AREA.
     03  DATE-YY                 PIC  9(04).
     03  DATE-MM                 PIC  9(02).
     03  DATE-DD                 PIC  9(02).
 01  TIME-AREA                   PIC  9(08).
 01  TIME-AREA-R       REDEFINES TIME-AREA.
     03  TIME-OUT.
         05  TIME-HH             PIC  9(02).
         05  TIME-MM             PIC  9(02).
         05  TIME-SS             PIC  9(02).
     03  TIME-OO                 PIC  9(02).

*    ˆÙíI—¹ŠÇ—ƒCƒ“ƒ^[ƒtƒFƒCƒX
 01  ABEND-AREA.
     03  WK-PGMID                PIC  X(08)     VALUE "MJS080CS".
     03  WK-VER                  PIC  X(07)     VALUE "V01/L01".
     03  WK-FLNAME               PIC  X(08).
     03  WK-FLMODE               PIC  X(07).
     03  WK-FLSTS                PIC  X(02).
     03  WK-FLKEY.
         05  WK-KEY1             PIC  X(10).
         05  WK-KEY2             PIC  X(09).
     03  WK-STATUS.
         05  WK-STS1             PIC  X(02).
         05  WK-STS2             PIC  X(02).
*
*----<<‰æ–Ê§Œä—pƒ[ƒN>>
 01  G-SEIGYO.
     03  G-NAME              PIC  X(08)      VALUE   SPACES.
     03  G-GRP               PIC  X(08)      VALUE   SPACES.
     03  G-EXC               PIC  X(02)      VALUE   SPACES.
     03  G-ATT               PIC  X(04)      VALUE   SPACES.
     03  ATT-INF.
         05  PF1             PIC  X(04)      VALUE   "F001".
         05  PF2             PIC  X(04)      VALUE   "F002".
         05  PF9             PIC  X(04)      VALUE   "F009".
         05  PF10            PIC  X(04)      VALUE   "F010".
         05  ENTR            PIC  X(04)      VALUE   "E000".
     03  G-CONT              PIC  X(06)      VALUE   SPACES.
     03  G-DEST              PIC  X(08)      VALUE   SPACES.
     03  F-STT               PIC  X(02)      VALUE   SPACES.
*----‘€ì•\Ž¦Þ
*ˆ—‘I‘ð•\Ž¦Þ
 01  HYOJI01.
     03  FILLER              PIC  N(25)  VALUE
         NC"‚o‚e‚PFŽŸ‰æ–Ê@‚o‚e‚QF‘O‰æ–Ê@‚o‚e‚P‚OFI—¹".
*‰æ–Ê•\Ž¦
 01  HYOJI02.
     03  FILLER              PIC  N(10)  VALUE
     NC"‚o‚e‚P‚OFI—¹".
 01  HYOJI02A.
     03  FILLER              PIC  N(10)  VALUE
     NC"‚o‚e‚XFÄ“ü—Í".
 01  HYOJI03.
     03  FILLER              PIC  N(20)  VALUE
     NC"Ä“ü—ÍF‚o‚e‚X".
 01  HYOJI04.
     03  FILLER              PIC  N(20)  VALUE
     NC"‰Šú‰æ–Ê‚Ö–ß‚èF‚o‚e‚P@I—¹F‚o‚e‚P‚O".
 01  HYOJI05.
     03  FILLER              PIC  N(20)  VALUE
     NC"Ä“ü—ÍF‚o‚e‚X@íœF‚o‚e‚P".
*----------------------------------------------------
*‘€ìŽwŽ¦
*‰æ–ÊŽwŽ¦
 01  SHIJI01.
     03  FILLER              PIC  N(18)  VALUE
     NC"ŒÂ•ÊÚ×‚Í‘I‘ðs‚É‚r‚ð“ü—Í‚µ‚Ä‰º‚³‚¢".
 01  SHIJI05.
     03  FILLER              PIC  N(15)  VALUE
     NC"Å‰º’i‚Ì‘€ìŽwŽ¦‚É]‚Á‚Ä‰º‚³‚¢".
 01  SHIJI99.
     03  FILLER              PIC  N(15)  VALUE
     NC"‘€ì‚ÉŒë‚è‚ª‚ ‚è‚Ü‚·".
*
*
 01  ‚v‚j|‰æ–Ê•\Ž¦.
     03  ‚v‚j|‰æ–Ê•\Ž¦‚q    OCCURS   500.
         05  ‚v‚j|•”ŠƒR[ƒh            PIC  X(02).
         05  ‚v‚j|’[––”Ô†              PIC  X(08).
         05  ‚v‚j|‰c‹Æ•”–å              PIC  N(12).
         05  ‚v‚j|ÝŒv•”–å              PIC  X(02).
         05  ‚v‚j|Œ©Ï”Ô†              PIC  X(08).
         05  ‚v‚j|•¨Œ–¼                PIC  N(20).
         05  ‚v‚j|’S“––¼                PIC  N(12).
         05  ‚v‚j|’ñoŠó–]“ú            PIC  9(06).
         05  ‚v‚j|Žè“`}                PIC  9(01).
         05  ‚v‚j|¡–@}                PIC  9(01).
         05  ‚v‚j|‘Å‡}                PIC  9(01).
         05  ‚v‚j|³”F}                PIC  9(01).
         05  ‚v‚j|‚»‚Ì‘¼                PIC  9(01).
         05  ‚v‚j|”z§•ª‹àŠz            PIC S9(09).
         05  ‚v‚j|‚»‚Ì‘¼‹àŠz            PIC S9(09).
         05  ‚v‚j|”z“d”ÕŽó’—\’èŠz      PIC S9(09).
         05  ‚v‚j|§Œä”ÕŽó’—\’èŠz      PIC S9(09).
         05  ‚v‚j|•ª“d”ÕŽó’—\’èŠz      PIC S9(09).
         05  ‚v‚j|”z“d”Õ”[“ü—\’è“ú      PIC  9(06).
         05  ‚v‚j|§Œä”Õ”[“ü—\’è“ú      PIC  9(06).
         05  ‚v‚j|•ª“d”Õ”[“ü—\’è“ú      PIC  9(06).
         05  ‚v‚j|”z“d”Õ”              PIC S9(09).
         05  ‚v‚j|§Œä”Õ”              PIC S9(09).
         05  ‚v‚j|•ª“d”Õ”              PIC S9(09).
         05  ‚v‚j|‚»‚Ì‘¼”              PIC S9(09).
         05  ‚v‚j|‹àŠzŒðÂó‹µ‹æ•ª      PIC  9(01).
         05  ‚v‚j|Žó’—¦                PIC  9(03)V9(01).
         05  ‚v‚j|‘I‘ð                  PIC  X(01).
         05  ‚v‚j|‘¶Ý                  PIC  X(01).
         05  ‚v‚j|‘S»”Ô”              PIC  9(03).
*
*
 01  WK-BANSU.
     03  WK-HAIDENBAN               PIC  S9(09).
     03  WK-SEIGYOBAN               PIC  S9(09).
     03  WK-BUNDENBAN               PIC  S9(09).
     03  WK-SONOTABAN               PIC  S9(09).
     03  WK-GOKEIBAN                PIC  S9(09).
 01  WK-IRAINAIYO.
     03  WK-IRAI01                  PIC  N(01).
     03  WK-IRAI02                  PIC  N(01).
     03  WK-IRAI03                  PIC  N(01).
     03  WK-IRAI04                  PIC  N(01).
     03  WK-IRAI05                  PIC  N(01).
 01  WK-IRAINAIYO-R                 REDEFINES  WK-IRAINAIYO.
     03  WK-IRAI                    PIC  N(05).
*
*--------------------------------*
 PROCEDURE           DIVISION.
*
*********------------------------------------------------*********
*********                Ò ² Ý       Ù°ÁÝ                *********
*********------------------------------------------------*********
 Žåˆ—                       SECTION.
 Žåˆ—|ŠJŽn.
     PERFORM    ‰Šúˆ—.
*
     MOVE       "XX"           TO  CH-BUCODE.
 Žåˆ—‚O‚P‚O.
     READ    Æ‰ïƒtƒ@ƒCƒ‹     AT  END
                                 GO  TO  Žåˆ—‚P‚O‚O.
*
     PERFORM  Ši”[ˆ—.
*
     IF      IDX1    =  500
                                 GO  TO  Žåˆ—‚P‚O‚O
     END-IF.
*
     GO  TO  Žåˆ—‚O‚P‚O.
 Žåˆ—‚P‚O‚O.
*
     PERFORM    ‰æ–Êˆ—.
*
     PERFORM    I—¹ˆ—.
     STOP  RUN.
******************************************************************
*    ‰Šúˆ—@@@@@@
******************************************************************
 ‰Šúˆ—                        SECTION.
 ‰Šúˆ—|ŠJŽn.
*    ƒtƒ@ƒCƒ‹‚ÌƒI[ƒvƒ“
     OPEN    I-O            ‰æ–Êƒtƒ@ƒCƒ‹.
     OPEN    INPUT          Æ‰ïƒtƒ@ƒCƒ‹.
     OPEN    INPUT          ˆË—Šƒtƒ@ƒCƒ‹.
     OPEN    INPUT          Žæˆøæƒ}ƒXƒ^
                            ‘gDƒ}ƒXƒ^
                            î•ñ•¨Œƒtƒ@ƒCƒ‹.
     OPEN    INPUT          Œˆ’èƒtƒ@ƒCƒ‹.
     OPEN    INPUT          î•ñ€–Úƒtƒ@ƒCƒ‹.
     OPEN    INPUT          Žd—lƒ}ƒXƒ^.
     OPEN    INPUT          Æ‰ïƒtƒ@ƒCƒ‹‚Q.
*
     PERFORM                ‚n‚o‚d‚mƒ`ƒFƒbƒNˆ—.
*
*    ƒVƒXƒeƒ€“ú•t‚ÌŽæ“¾
     MOVE    FUNCTION    CURRENT-DATE   TO  DATE-AREA.
*
     ACCEPT       TIME-AREA      FROM      TIME.
*
*    ì‹Æ€–Ú‚Ì‰Šú‰»
     INITIALIZE                  FLG-AREA
                                 SAVE-AREA
                                 INDEX-AREA.
     INITIALIZE      ‚v‚j|‰æ–Ê•\Ž¦.
*
     MOVE    ZERO                TO        STATUS-AREA.
     MOVE    ZERO                TO        SAVE-PAGE.
     MOVE    ZERO                TO        IDX.
     MOVE    ZERO                TO        SAVE-DATE.
     MOVE    ZERO                TO        SAVE-DKBN.
*
 ‰Šúˆ—|I—¹.
     EXIT.
*===============================================================*
*            –¾×ƒf[ƒ^Ši”[ˆ—
*===============================================================*
 Ši”[ˆ—                 SECTION.
 Ši”[ˆ—|ŠJŽn.
*
     MOVE    Æ‰ï|Œ©Ï”Ô† TO  ˆË—Š|Œ©Ï”Ô†.
*
     MOVE    Æ‰ï|’[––”Ô† TO  ˆË—Š|’[––”Ô†.
     MOVE    Æ‰ï|Œ©Ï”Ô† TO  ˆË—Š|Œ©Ï”Ô†.
     READ    ˆË—Šƒtƒ@ƒCƒ‹   INVALID
                            GO  TO  Ši”[ˆ—|I—¹.
     IF  ˆË—Š|ƒvƒŠƒ“ƒgÏƒtƒ‰ƒO = ZERO
         GO TO Ši”[ˆ—|I—¹
     END-IF.
*
     ADD    1           TO  IDX1.
*
     MOVE   Æ‰ï|•”ŠƒR[ƒh  TO  ‚v‚j|•”ŠƒR[ƒh (IDX1).
     MOVE   Æ‰ï|•”ŠƒR[ƒh  TO  ‘gD|•”ŠƒR[ƒh.
     MOVE    "00"             TO  ‘gD|’S“–ŽÒŒWƒR[ƒh.
     READ   ‘gDƒ}ƒXƒ^  INVALID
                    MOVE  SPACES  TO ‘gD|•”Š–¼Š¿Žš.
     MOVE   ‘gD|•”Š–¼Š¿Žš
                              TO  ‚v‚j|‰c‹Æ•”–å (IDX1).
*
     MOVE   Æ‰ï|ÝŒv’S“–•”Š    TO  ‚v‚j|ÝŒv•”–å (IDX1).
     MOVE   Æ‰ï|Œ©Ï”Ô†        TO  ‚v‚j|Œ©Ï”Ô† (IDX1).
     MOVE   Æ‰ï|’[––”Ô†        TO  ‚v‚j|’[––”Ô† (IDX1).
*
     MOVE   SPACES                TO  ‚v‚j|‘¶Ý (IDX1).
*
     MOVE   Æ‰ï|Œ©Ï”Ô†      TO  •¨Œ|Œ©Ïƒiƒ“ƒo[.
     READ   î•ñ•¨Œƒtƒ@ƒCƒ‹    INVALID
                                MOVE  Æ‰ï|Œ–¼‚P
                                       TO  •¨Œ|Œ–¼‚P
                                MOVE  Æ‰ï|ì¬•”ŠƒR[ƒh
                                       TO  •¨Œ|•”ŠƒR[ƒh
                                MOVE  Æ‰ï|’S“–ŽÒŒWƒR[ƒh
                                       TO  •¨Œ|’S“–ŽÒŒWƒR[ƒh
                                MOVE  "A"
                                       TO  ‚v‚j|‘¶Ý (IDX1).
     IF     •¨Œ|íœƒtƒ‰ƒO  NOT  =  SPACES
                                MOVE  Æ‰ï|Œ–¼‚P
                                       TO  •¨Œ|Œ–¼‚P
                                MOVE  Æ‰ï|ì¬•”ŠƒR[ƒh
                                       TO  •¨Œ|•”ŠƒR[ƒh
                                MOVE  Æ‰ï|’S“–ŽÒŒWƒR[ƒh
                                       TO  •¨Œ|’S“–ŽÒŒWƒR[ƒh
                                MOVE  "A"
                                       TO  ‚v‚j|‘¶Ý (IDX1)
     END-IF.
*
     MOVE    •¨Œ|Œ–¼‚P       TO  ‚v‚j|•¨Œ–¼ (IDX1).
*
     IF      ‚v‚j|‘¶Ý (IDX1)   =  "A"
                         MOVE  Æ‰ï|ì¬•”ŠƒR[ƒh
                                       TO  ‘gD|•”ŠƒR[ƒh
                         MOVE  Æ‰ï|’S“–ŽÒŒWƒR[ƒh
                                       TO  ‘gD|’S“–ŽÒŒWƒR[ƒh
                         MOVE  ZERO
                               TO  ‚v‚j|‘S»”Ô” (IDX1)
             ELSE
                         MOVE  •¨Œ|•”ŠƒR[ƒh
                                       TO  ‘gD|•”ŠƒR[ƒh
                         MOVE  •¨Œ|’S“–ŽÒŒWƒR[ƒh
                                       TO  ‘gD|’S“–ŽÒŒWƒR[ƒh
                         MOVE  •¨Œ|‘S»”Ô”
                               TO  ‚v‚j|‘S»”Ô” (IDX1)
     END-IF.
*
     READ    ‘gDƒ}ƒXƒ^  INVALID
                    MOVE  SPACES  TO ‘gD|’S“–ŽÒ–¼ŒW–¼Š¿Žš.
*
     MOVE    ‘gD|’S“–ŽÒ–¼ŒW–¼Š¿Žš
                                  TO  ‚v‚j|’S“––¼ (IDX1).
*
     MOVE   Æ‰ï|Žè“`}        TO  ‚v‚j|Žè“`} (IDX1).
     MOVE   Æ‰ï|¡–@}        TO  ‚v‚j|¡–@} (IDX1).
     MOVE   Æ‰ï|‘Å‡}        TO  ‚v‚j|‘Å‡} (IDX1).
     MOVE   Æ‰ï|³”F}        TO  ‚v‚j|³”F} (IDX1).
     MOVE   Æ‰ï|‚»‚Ì‘¼        TO  ‚v‚j|‚»‚Ì‘¼ (IDX1).
*
     MOVE   Æ‰ï|’ñoŠó–]“ú    TO  ‚v‚j|’ñoŠó–]“ú (IDX1).
     MOVE   Æ‰ï|”z§•ª‹àŠz    TO  ‚v‚j|”z§•ª‹àŠz (IDX1).
     MOVE   Æ‰ï|‚»‚Ì‘¼‹àŠz    TO  ‚v‚j|‚»‚Ì‘¼‹àŠz (IDX1).
     MOVE   Æ‰ï|”z“d”ÕŽó’—\’èŠz
                           TO  ‚v‚j|”z“d”ÕŽó’—\’èŠz (IDX1).
     MOVE   Æ‰ï|§Œä”ÕŽó’—\’èŠz
                           TO  ‚v‚j|§Œä”ÕŽó’—\’èŠz (IDX1).
     MOVE   Æ‰ï|•ª“d”ÕŽó’—\’èŠz
                           TO  ‚v‚j|•ª“d”ÕŽó’—\’èŠz (IDX1).
     MOVE   Æ‰ï|”z“d”Õ”[“ü—\’è“ú
                           TO  ‚v‚j|”z“d”Õ”[“ü—\’è“ú (IDX1).
     MOVE   Æ‰ï|§Œä”Õ”[“ü—\’è“ú
                           TO  ‚v‚j|§Œä”Õ”[“ü—\’è“ú (IDX1).
     MOVE   Æ‰ï|•ª“d”Õ”[“ü—\’è“ú
                           TO  ‚v‚j|•ª“d”Õ”[“ü—\’è“ú (IDX1).
     MOVE   Æ‰ï|”z“d”Õ”
                               TO  ‚v‚j|”z“d”Õ” (IDX1).
     MOVE   Æ‰ï|§Œä”Õ”
                               TO  ‚v‚j|§Œä”Õ” (IDX1).
     MOVE   Æ‰ï|•ª“d”Õ”
                               TO  ‚v‚j|•ª“d”Õ” (IDX1).
     MOVE   Æ‰ï|‚»‚Ì‘¼”
                               TO  ‚v‚j|‚»‚Ì‘¼” (IDX1).
     MOVE   Æ‰ï|‹àŠzŒðÂó‹µ‹æ•ª
                           TO  ‚v‚j|‹àŠzŒðÂó‹µ‹æ•ª (IDX1).
     MOVE   Æ‰ï|Žó’—¦       TO  ‚v‚j|Žó’—¦ (IDX1).
*
 Ši”[ˆ—|I—¹.
     EXIT.
*===============================================================*
*            –¢Žó’ì}ˆË—Š•\Ž¦ˆ—
*===============================================================*
 ‰æ–Êˆ—                 SECTION.
 ‰æ–Êˆ—|ŠJŽn.
     MOVE    LOW-VALUE       TO  ‰æ–Ê|–¢Žó’ì}ˆË—Š.
     MOVE    SPACES          TO  ‰æ–Ê|‘€ìŽwŽ¦.
*
     MOVE    "CL"            TO  G-EXC.
     MOVE    "ALLF"          TO  G-GRP.
     MOVE    "MJS080D1"      TO  G-NAME.
*
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (1).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (1).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (1).

     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (2).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (2).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (2).

     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (3).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (3).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (3).

     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (4).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (4).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (4).

     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (5).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (5).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (5).

     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (6).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (6).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (6).

*
     MOVE    1               TO  IDX2.
     MOVE    ZERO            TO  IDX3.
 ‰æ–Ê‚O‚O‚P.
     IF      IDX2    >   IDX1
                         GO  TO  ‰æ–Ê‚O‚O‚Q.
     IF      IDX3    =   6
                         GO  TO  ‰æ–Ê‚O‚O‚Q.
*
     ADD     1           TO  IDX3.
*
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|Œ©Ï”Ô† (IDX3).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|‰c‹Æ’S“– (IDX3).
     MOVE   "M"  TO  EDIT-COLOR   OF ‰æ–Ê|•¨Œ–¼‚P (IDX3).
*
     IF      IDX3   =  1
                         MOVE  IDX2    TO   START-IDX2
     END-IF.
*
*    IF     CH-BUCODE         =   "XX"
*                             MOVE ‚v‚j|•”ŠƒR[ƒh (IDX2)
*                                            TO  CH-BUCODE
*                              GO  TO  ‰æ–Ê‚O‚O‚P‚`
*    END-IF.
*    IF     ‚v‚j|•”ŠƒR[ƒh (IDX2)  =   CH-BUCODE
*                 MOVE  NC"@@V"    TO  ‰æ–Ê|•”Š–¼ (IDX3)
*                 GO  TO  ‰æ–Ê‚O‚O‚P‚a
*    END-IF.
*
*    MOVE   ‚v‚j|•”ŠƒR[ƒh (IDX2)    TO  CH-BUCODE.
*
 ‰æ–Ê‚O‚O‚P‚`.
     MOVE    ‚v‚j|‰c‹Æ•”–å (IDX2) TO  ‰æ–Ê|‰c‹Æ•”–å (IDX3).
 ‰æ–Ê‚O‚O‚P‚a.
*
     IF      ‚v‚j|ÝŒv•”–å (IDX2) =  "00"
                   MOVE  SPACES   TO  ‰æ–Ê|ÝŒv•”–å (IDX3)
                   GO  TO  ‰æ–Ê‚O‚O‚P‚b
     END-IF.
     IF      ‚v‚j|ÝŒv•”–å (IDX2) =  SPACES
                   MOVE  SPACES   TO  ‰æ–Ê|ÝŒv•”–å (IDX3)
                   GO  TO  ‰æ–Ê‚O‚O‚P‚b
     END-IF.
*
     MOVE    ‚v‚j|ÝŒv•”–å (IDX2) TO  ‘gD|•”ŠƒR[ƒh.
     MOVE    "00"                  TO  ‘gD|’S“–ŽÒŒWƒR[ƒh.
     READ    ‘gDƒ}ƒXƒ^  INVALID
                    MOVE  SPACES  TO ‘gD|•”Š–¼Š¿Žš.
*
     MOVE    ‘gD|•”Š–¼Š¿Žš
                                  TO  ‰æ–Ê|ÝŒv•”–å (IDX3).
 ‰æ–Ê‚O‚O‚P‚b.
     MOVE    ‚v‚j|Œ©Ï”Ô† (IDX2)
                                   TO  ‰æ–Ê|Œ©Ï”Ô† (IDX3).
     MOVE    ‚v‚j|’S“––¼ (IDX2)
                                   TO  ‰æ–Ê|‰c‹Æ’S“– (IDX3).
     MOVE    ‚v‚j|•¨Œ–¼ (IDX2)
                                   TO  ‰æ–Ê|•¨Œ–¼‚P (IDX3).
     MOVE    ‚v‚j|’ñoŠó–]“ú (IDX2)
                                   TO  ‰æ–Ê|’ñoŠó–]“ú (IDX3).
     MOVE    SPACE                 TO  WK-IRAINAIYO.
     IF  ‚v‚j|Žè“`} (IDX2)  =  1
         MOVE  NC"Žè"              TO  WK-IRAI01
     ELSE
         MOVE  NC"@"              TO  WK-IRAI01
     END-IF.
     IF  ‚v‚j|¡–@} (IDX2)  =  1
         MOVE  NC"¡"              TO  WK-IRAI02
     ELSE
         MOVE  NC"@"              TO  WK-IRAI02
     END-IF.
     IF  ‚v‚j|‘Å‡} (IDX2)  =  1
         MOVE  NC"‘Å"              TO  WK-IRAI03
     ELSE
         MOVE  NC"@"              TO  WK-IRAI03
     END-IF.
     IF  ‚v‚j|³”F} (IDX2)  =  1
         MOVE  NC"³"              TO  WK-IRAI04
     ELSE
         MOVE  NC"@"              TO  WK-IRAI04
     END-IF.
     IF  ‚v‚j|‚»‚Ì‘¼ (IDX2)  =  1
         MOVE  NC"‚»"              TO  WK-IRAI05
     ELSE
         MOVE  NC"@"              TO  WK-IRAI05
     END-IF.
     MOVE    WK-IRAI               TO  ‰æ–Ê|ˆË—Š“à—e (IDX3).
     MOVE    ‚v‚j|”z§•ª‹àŠz (IDX2)
                                   TO  ‰æ–Ê|”z§•ª‹àŠz (IDX3).
     MOVE    ‚v‚j|‚»‚Ì‘¼‹àŠz (IDX2)
                                   TO  ‰æ–Ê|‚»‚Ì‘¼‹àŠz (IDX3).
     MOVE    ‚v‚j|”z“d”ÕŽó’—\’èŠz (IDX2)
                           TO  ‰æ–Ê|”z“d”ÕŽó’—\’èŠz (IDX3).
     MOVE    ‚v‚j|§Œä”ÕŽó’—\’èŠz (IDX2)
                           TO  ‰æ–Ê|§Œä”ÕŽó’—\’èŠz (IDX3).
     MOVE    ‚v‚j|•ª“d”ÕŽó’—\’èŠz (IDX2)
                           TO  ‰æ–Ê|•ª“d”ÕŽó’—\’èŠz (IDX3).
     MOVE    ‚v‚j|”z“d”Õ”[“ü—\’è“ú (IDX2)
                           TO  ‰æ–Ê|”z“d”Õ”[“ü—\’è“ú (IDX3).
     MOVE    ‚v‚j|§Œä”Õ”[“ü—\’è“ú (IDX2)
                           TO  ‰æ–Ê|§Œä”Õ”[“ü—\’è“ú (IDX3).
     MOVE    ‚v‚j|•ª“d”Õ”[“ü—\’è“ú (IDX2)
                           TO  ‰æ–Ê|•ª“d”Õ”[“ü—\’è“ú (IDX3).
     MOVE    ‚v‚j|”z“d”Õ” (IDX2)
                           TO  ‰æ–Ê|”z“d”Õ” (IDX3).
     MOVE    ‚v‚j|§Œä”Õ” (IDX2)
                           TO  ‰æ–Ê|§Œä”Õ” (IDX3).
     MOVE    ‚v‚j|•ª“d”Õ” (IDX2)
                           TO  ‰æ–Ê|•ª“d”Õ” (IDX3).
     EVALUATE  ‚v‚j|‹àŠzŒðÂó‹µ‹æ•ª (IDX2)
        WHEN  1
            MOVE NC"iŒðÂ’†j"  TO  ‰æ–Ê|‹àŠzŒðÂó‹µ (IDX3)
        WHEN  2
*           MOVE NC"i–{•”³j"  TO  ‰æ–Ê|‹àŠzŒðÂó‹µ (IDX3)
            MOVE NC"i“à’èÏj"  TO  ‰æ–Ê|‹àŠzŒðÂó‹µ (IDX3)
        WHEN  3
*           MOVE NC"iâg‹cÏj"  TO  ‰æ–Ê|‹àŠzŒðÂó‹µ (IDX3)
            MOVE NC"iŽó’‘Òj"  TO  ‰æ–Ê|‹àŠzŒðÂó‹µ (IDX3)
        WHEN  OTHER
            MOVE SPACES          TO  ‰æ–Ê|‹àŠzŒðÂó‹µ (IDX3)
     END-EVALUATE.
     MOVE    ‚v‚j|Žó’—¦ (IDX2)
                           TO  ‰æ–Ê|Žó’—¦ (IDX3).
*
     IF      ‚v‚j|‘¶Ý (IDX2)  =  "A"
                         MOVE   "Y"  TO  EDIT-COLOR
                                     OF ‰æ–Ê|Œ©Ï”Ô† (IDX3)
                         MOVE   "Y"  TO  EDIT-COLOR
                                     OF ‰æ–Ê|‰c‹Æ’S“– (IDX3)
                         MOVE   "Y"  TO  EDIT-COLOR
                                     OF ‰æ–Ê|•¨Œ–¼‚P (IDX3)
      END-IF.
      IF     ‚v‚j|‘S»”Ô” (IDX2) > ZERO
                         MOVE   "R"  TO  EDIT-COLOR
                                     OF ‰æ–Ê|Œ©Ï”Ô† (IDX3)
      END-IF.
*
     MOVE  NC"”z"          TO  ‰æ–Ê|”z (IDX3).
     MOVE  NC"§"          TO  ‰æ–Ê|§ (IDX3).
     MOVE  NC"•ª"          TO  ‰æ–Ê|•ª (IDX3).
*
     MOVE    IDX2          TO  WK-IDX2.
     ADD     1             TO  IDX2.
     GO  TO  ‰æ–Ê‚O‚O‚P.
 ‰æ–Ê‚O‚O‚Q.
     PERFORM ‰æ–Êo—Íˆ—.
*
 ‰æ–Ê‚O‚P‚O.
     MOVE    SHIJI01        TO  ‰æ–Ê|‘€ìŽwŽ¦.
     MOVE    HYOJI01        TO  ‰æ–Ê|‘€ì•\Ž¦.
*
     PERFORM ‰æ–Êo—Íˆ—.
 ‰æ–Ê‚O‚P‚P.
     MOVE    ZERO            TO  PF-FLAG.
     MOVE    ZERO            TO  ERR-FLAG.
     MOVE    ZERO            TO  WK-SELECT.
*
     MOVE    "NE"            TO  G-EXC.
     MOVE    "GRP001"        TO  G-GRP.
     READ    ‰æ–Êƒtƒ@ƒCƒ‹.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "READ"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*
     IF      G-ATT           =   ENTR
                                     GO  TO ‰æ–Ê‚O‚Q‚O
     END-IF.
     IF      G-ATT           =   PF1
             AND
             IDX1       <   7
             MOVE  NC"ŽŸ‰æ–Ê‘I‘ð‚Ío—ˆ‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
             PERFORM ‰æ–Êo—Íˆ—
                                     GO  TO ‰æ–Ê‚O‚P‚P.
     IF      G-ATT           =   PF1
             AND
             IDX2       >   IDX1
             MOVE  NC"ŽŸ‰æ–Ê‘I‘ð‚Ío—ˆ‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
             PERFORM ‰æ–Êo—Íˆ—
                                     GO  TO ‰æ–Ê‚O‚P‚P.
     IF      G-ATT           =   PF2
             AND
             WK-IDX2    <   7
             MOVE  NC"‘O‰æ–Ê‘I‘ð‚Ío—ˆ‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
             PERFORM ‰æ–Êo—Íˆ—
                                     GO  TO ‰æ–Ê‚O‚P‚P.
     IF      G-ATT           =   PF1
                   MOVE  LOW-VALUE TO  ‰æ–Ê|–¢Žó’ì}ˆË—Š
                   MOVE  SPACES    TO  ‰æ–Ê|‘€ìŽwŽ¦
                             ADD   1       TO  WK-IDX2
                             MOVE  WK-IDX2 TO  IDX2
                             MOVE  ZERO    TO  IDX3
                             MOVE  "XX"    TO  CH-BUCODE
                             GO  TO ‰æ–Ê‚O‚O‚P.
     IF      G-ATT           =   PF2
                   PERFORM  •Å•ÏXˆ—
                   MOVE  LOW-VALUE TO  ‰æ–Ê|–¢Žó’ì}ˆË—Š
                   MOVE  SPACES    TO  ‰æ–Ê|‘€ìŽwŽ¦
                   MOVE  WK-PAGE4  TO  WK-IDX2
                   MOVE  WK-IDX2   TO  IDX2
                   MOVE  ZERO      TO  IDX3
                   MOVE  "XX"      TO  CH-BUCODE
                   GO  TO ‰æ–Ê‚O‚O‚P.
*
     IF      G-ATT           =   PF10
                                     GO  TO ‰æ–Êˆ—|I—¹.
*
     MOVE    SHIJI99          TO  ‰æ–Ê|‘€ìŽwŽ¦.
     PERFORM ‰æ–Êo—Íˆ—.
     GO  TO  ‰æ–Ê‚O‚P‚P.
 ‰æ–Ê‚O‚Q‚O.
     MOVE    1             TO  N.
     MOVE    ZERO          TO  ERR-FLAG.
     MOVE    ZERO          TO  WK-COUNT.
     MOVE    ZERO          TO  WK-N.
 ‰æ–Ê‚O‚Q‚P.
     IF      N    >  6        GO  TO  ‰æ–Ê‚O‚R‚O.
*
     IF      ‰æ–Ê|‘I‘ð (N)   =  LOW-VALUE
                         MOVE  SPACES  TO  ‰æ–Ê|‘I‘ð (N)
     END-IF.
     IF      ‰æ–Ê|Œ©Ï”Ô† (N)   =  LOW-VALUE
                         MOVE  SPACES  TO  ‰æ–Ê|Œ©Ï”Ô† (N)
     END-IF.
*
     IF      ‰æ–Ê|Œ©Ï”Ô† (N)   =  SPACES
             AND
             ‰æ–Ê|‘I‘ð (N)  NOT  =  SPACES
                                   MOVE  1    TO  ERR-FLAG
                                   GO  TO  ‰æ–Ê‚O‚R‚P
     END-IF.
     IF      ‰æ–Ê|Œ©Ï”Ô† (N)   NOT  =  SPACES
             AND
             ‰æ–Ê|‘I‘ð (N)        =  SPACES
                                   ADD     1         TO  N
                                   GO  TO  ‰æ–Ê‚O‚Q‚P
     END-IF.
     IF      ‰æ–Ê|Œ©Ï”Ô† (N)   NOT  =  SPACES
             AND
             ‰æ–Ê|‘I‘ð (N)   NOT  =  "S"
                                   MOVE  3    TO  ERR-FLAG
                                   GO  TO  ‰æ–Ê‚O‚R‚P
     END-IF.
*
     IF      ‰æ–Ê|‘I‘ð (N)   NOT  =  SPACES
                              COMPUTE  WK-N  =  START-IDX2 - 1
                              COMPUTE  WK-N  =  WK-N  +  N
                              ADD  1   TO   WK-COUNT
     END-IF.
*
     ADD     1         TO  N.
     GO  TO  ‰æ–Ê‚O‚Q‚P.
 ‰æ–Ê‚O‚R‚O.
*
     IF      WK-COUNT   >   1
                            MOVE  2    TO  ERR-FLAG
     END-IF.
     IF      WK-COUNT   =   ZERO
                            MOVE  4    TO  ERR-FLAG
     END-IF.
*
 ‰æ–Ê‚O‚R‚P.
     EVALUATE     ERR-FLAG
        WHEN      1
          MOVE  NC"‰æ–Ê‘I‘ðŽw’è‚ÉŒë‚è‚ª‚ ‚è‚Ü‚·"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
          PERFORM ‰æ–Êo—Íˆ—
          GO  TO  ‰æ–Ê‚O‚P‚P
        WHEN      2
          MOVE  NC"•¡”‘I‘ðŽw’è‚Ío—ˆ‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
          PERFORM ‰æ–Êo—Íˆ—
          GO  TO  ‰æ–Ê‚O‚P‚P
        WHEN      3
          MOVE  NC"‘I‘ðŽw’è‚ÉŒë‚è‚ª‚ ‚è‚Ü‚·"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
          PERFORM ‰æ–Êo—Íˆ—
          GO  TO  ‰æ–Ê‚O‚P‚P
        WHEN      4
          MOVE  NC"‘I‘ðŽw’è‚ª‚³‚ê‚Ä‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
          PERFORM ‰æ–Êo—Íˆ—
          GO  TO  ‰æ–Ê‚O‚P‚P
        WHEN      OTHER
          CONTINUE
     END-EVALUATE.
     EVALUATE     ERR-FLAG
        WHEN      1
          MOVE  NC"–¢Žó’ˆË—Šƒf[ƒ^‚ª‚ ‚è‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
          PERFORM ‰æ–Êo—Íˆ—
          GO  TO  ‰æ–Ê‚O‚P‚P
        WHEN      2
          MOVE  NC"î•ñ•¨Œ‚ª‘¶Ý‚µ‚Ä‚Ü‚¹‚ñ"
                                 TO  ‰æ–Ê|‘€ìŽwŽ¦
          PERFORM ‰æ–Êo—Íˆ—
          GO  TO  ‰æ–Ê‚O‚P‚P
        WHEN      OTHER
          CONTINUE
     END-EVALUATE.
*
*------------------------------------------------------------*
 ‰æ–Ê‚P‚O‚O.
     MOVE    LOW-VALUE       TO  ‰æ–Ê‚P|–¢Žó’ì}ˆË—Š‘.
     MOVE    SPACES          TO  ‰æ–Ê‚P|‘€ìŽwŽ¦.
*
     MOVE    "  "            TO  G-EXC.
     MOVE    "SCREEN"        TO  G-GRP.
     MOVE    "MJS080D2"      TO  G-NAME.
*
     PERFORM  –¾×ˆ—.
*
*
     MOVE    HYOJI04        TO  ‰æ–Ê‚P|‘€ì•\Ž¦.
     MOVE    SHIJI05        TO  ‰æ–Ê‚P|‘€ìŽwŽ¦.
 ‰æ–Ê‚P‚P‚O.
*
     PERFORM ‰æ–Êo—Íˆ—‚P.
*
 ‰æ–Ê‚P‚Q‚O.
     MOVE    ZERO            TO  PF-FLAG.
     MOVE    ZERO            TO  ERR-FLAG.
*
     MOVE    SPACES          TO  G-EXC.
     MOVE    "GRP003"        TO  G-GRP.
     READ    ‰æ–Êƒtƒ@ƒCƒ‹.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "READ"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*
     IF      G-ATT    =   PF1
                         MOVE  "XX"     TO   CH-BUCODE
                         GO  TO  ‰æ–Êˆ—|ŠJŽn
     END-IF.
*
     IF      G-ATT    =   PF10
                         GO  TO  ‰æ–Êˆ—|I—¹
     END-IF.
*
     MOVE    SHIJI99          TO  ‰æ–Ê‚P|‘€ìŽwŽ¦.
     PERFORM ‰æ–Êo—Íˆ—‚P.
     GO  TO  ‰æ–Ê‚P‚Q‚O.


 ‰æ–Êˆ—|I—¹.
     EXIT.
*===============================================================*
*            ‰æ–Ê“WŠJŒvŽZˆ—
*===============================================================*
 •Å•ÏXˆ—     SECTION.
 •Å•ÏXˆ—|ŠJŽn.
     INITIALIZE   WK-PAGE.
*
     COMPUTE  WK-PAGE1  =  START-IDX2   /   6.
     COMPUTE  WK-PAGE2  =  WK-PAGE1  -   1.
     COMPUTE  WK-PAGE3  =  WK-PAGE2  *   6.
     COMPUTE  WK-PAGE4  =  WK-PAGE3  +   1.
 •Å•ÏXˆ—|I—¹.
     EXIT.
*
*===============================================================*
*            –¾×Æ‰ïˆ—
*===============================================================*
 –¾×ˆ—               SECTION.
 –¾×ˆ—|ŠJŽn.
*

     MOVE    ‚v‚j|Œ©Ï”Ô† (WK-N) TO  ‰æ–Ê‚P|Œ©Ï”Ô†.
*
     MOVE    ‚v‚j|’[––”Ô† (WK-N) TO  ˆË—Š|’[––”Ô†.
     MOVE    ‚v‚j|Œ©Ï”Ô† (WK-N) TO  ˆË—Š|Œ©Ï”Ô†.
     READ    ˆË—Šƒtƒ@ƒCƒ‹   INVALID
                            MOVE   1     TO  ERR-FLAG
                            GO  TO  –¾×ˆ—|I—¹.
*
     MOVE    ‚v‚j|’[––”Ô† (WK-N)   TO  Æ‰ï‚Q|’[––”Ô†.
     MOVE    ‚v‚j|Œ©Ï”Ô† (WK-N)   TO  Æ‰ï‚Q|Œ©Ï”Ô†.
     READ    Æ‰ïƒtƒ@ƒCƒ‹‚Q INVALID
                            MOVE   1     TO  ERR-FLAG
                            GO  TO  –¾×ˆ—|I—¹.
*
     IF      ‚v‚j|‘¶Ý (WK-N)  =  "A"
             MOVE  ‚v‚j|•¨Œ–¼ (WK-N)   TO  ‰æ–Ê‚P|•¨Œ–¼
             GO  TO  –¾×‚O‚O‚O‚`
     END-IF.
*
     MOVE    ‚v‚j|Œ©Ï”Ô† (WK-N) TO  •¨Œ|Œ©Ïƒiƒ“ƒo[.
     READ    î•ñ•¨Œƒtƒ@ƒCƒ‹   INVALID
                              MOVE   2     TO  ERR-FLAG
                              GO  TO  –¾×ˆ—|I—¹.
     MOVE    •¨Œ|Œ–¼         TO  ‰æ–Ê‚P|•¨Œ–¼.
*
 –¾×‚O‚O‚O‚`.
*
     IF      ‚v‚j|‘¶Ý (WK-N)  =  "A"
             MOVE  Æ‰ï‚Q|ˆË—ŠæƒR[ƒh TO  Žæˆø|ŽæˆøæƒR[ƒh
     ELSE
             MOVE  •¨Œ|ˆË—ŠæƒR[ƒh TO  Žæˆø|ŽæˆøæƒR[ƒh
     END-IF.
*
     READ    Žæˆøæƒ}ƒXƒ^  INVALID
                    MOVE  SPACES  TO Žæˆø|Žæˆø—ª–¼.
*
     MOVE    Žæˆø|Žæˆø—ª–¼
                                  TO  ‰æ–Ê‚P|Žó’æ–¼.
*
     MOVE    Æ‰ï‚Q|”z§•ª‹àŠz
                              TO  ‰æ–Ê‚P|”z§•ª‹àŠz.
     MOVE    Æ‰ï‚Q|‚»‚Ì‘¼‹àŠz
                              TO  ‰æ–Ê‚P|‚»‚Ì‘¼‹àŠz.
     MOVE    Æ‰ï‚Q|”[“üêŠ
                              TO  ‰æ–Ê‚P|”[“üêŠ.
     MOVE    Æ‰ï‚Q|ÝŒvŽ––±Š
                              TO  ‰æ–Ê‚P|ÝŒvŽ––±Š.
     MOVE    ‰æ–Ê‚P|ÝŒvŽ––±Š    TO  Žæˆø|ŽæˆøæƒR[ƒh.
     READ    Žæˆøæƒ}ƒXƒ^  INVALID
                           MOVE  SPACES   TO  Žæˆø|Žæˆø—ª–¼.
     MOVE    Žæˆø|Žæˆø—ª–¼      TO  ‰æ–Ê‚P|ÝŒvŽ––±Š–¼.
     MOVE    Æ‰ï‚Q|Žè“`}
                              TO  ‰æ–Ê‚P|Žè“`}.
     MOVE    Æ‰ï‚Q|¡–@}
                              TO  ‰æ–Ê‚P|¡–@}.
     MOVE    Æ‰ï‚Q|‘Å‡}
                              TO  ‰æ–Ê‚P|‘Å‡}.
     MOVE    Æ‰ï‚Q|³”F}
                              TO  ‰æ–Ê‚P|³”F}.
     MOVE    Æ‰ï‚Q|‚»‚Ì‘¼
                              TO  ‰æ–Ê‚P|‚»‚Ì‘¼.
     MOVE    Æ‰ï‚Q|ŠT—v‚P
                              TO  ‰æ–Ê‚P|ŠT—v‚P.
     MOVE    Æ‰ï‚Q|ŠT—v‚Q
                              TO  ‰æ–Ê‚P|ŠT—v‚Q.
     MOVE    Æ‰ï‚Q|ŠT—v‚R
                              TO  ‰æ–Ê‚P|ŠT—v‚R.
     MOVE    Æ‰ï‚Q|ˆË—Š“ú
                              TO  ‰æ–Ê‚P|ˆË—Š“ú.
     MOVE    Æ‰ï‚Q|’ñoŠó–]“ú
                              TO  ‰æ–Ê‚P|’ñoŠó–]“ú.
     MOVE    Æ‰ï‚Q|”z“d”Õ”[“ü—\’è“ú
                              TO  ‰æ–Ê‚P|”z“d”Õ”[“ü—\’è“ú.
     MOVE    Æ‰ï‚Q|§Œä”Õ”[“ü—\’è“ú
                              TO  ‰æ–Ê‚P|§Œä”Õ”[“ü—\’è“ú.
     MOVE    Æ‰ï‚Q|•ª“d”Õ”[“ü—\’è“ú
                              TO  ‰æ–Ê‚P|•ª“d”Õ”[“ü—\’è“ú.
     MOVE    Æ‰ï‚Q|”z“d”ÕŽó’—\’èŠz
                              TO  ‰æ–Ê‚P|”z“d”ÕŽó’—\’èŠz.
     MOVE    Æ‰ï‚Q|§Œä”ÕŽó’—\’èŠz
                              TO  ‰æ–Ê‚P|§Œä”ÕŽó’—\’èŠz.
     MOVE    Æ‰ï‚Q|•ª“d”ÕŽó’—\’èŠz
                              TO  ‰æ–Ê‚P|•ª“d”ÕŽó’—\’èŠz.
     MOVE    Æ‰ï‚Q|‚»‚Ì‘¼Žó’—\’èŠz
                              TO  ‰æ–Ê‚P|‚»‚Ì‘¼Žó’—\’èŠz.
     COMPUTE  WK-GOKEI2  = Æ‰ï‚Q|”z“d”ÕŽó’—\’èŠz +
                           Æ‰ï‚Q|§Œä”ÕŽó’—\’èŠz +
                           Æ‰ï‚Q|•ª“d”ÕŽó’—\’èŠz +
                           Æ‰ï‚Q|‚»‚Ì‘¼Žó’—\’èŠz.
     MOVE    WK-GOKEI2       TO  ‰æ–Ê‚P|‡ŒvŽó’—\’èŠz.
     MOVE    Æ‰ï‚Q|Žó’—¦  TO  ‰æ–Ê‚P|Žó’—¦.
     MOVE    Æ‰ï‚Q|”õl‚P
                              TO  ‰æ–Ê‚P|”õl‚P.
     MOVE    Æ‰ï‚Q|”õl‚Q
                              TO  ‰æ–Ê‚P|”õl‚Q.
     MOVE    Æ‰ï‚Q|”õl‚R
                              TO  ‰æ–Ê‚P|”õl‚R.
     EVALUATE  Æ‰ï‚Q|‹àŠzŒðÂó‹µ‹æ•ª
        WHEN  1
            MOVE NC"ŒðÂ’†"        TO  ‰æ–Ê‚P|‹àŠzŒðÂó‹µ
        WHEN  2
*           MOVE NC"–{•”’·³”FÏ"  TO  ‰æ–Ê‚P|‹àŠzŒðÂó‹µ
            MOVE NC"“à’èÏ"        TO  ‰æ–Ê‚P|‹àŠzŒðÂó‹µ
        WHEN  3
*           MOVE NC"âg‹cÏ"        TO  ‰æ–Ê‚P|‹àŠzŒðÂó‹µ
            MOVE NC"Žó’“o˜^‘Ò‚¿"  TO  ‰æ–Ê‚P|‹àŠzŒðÂó‹µ
        WHEN  OTHER
            MOVE SPACES            TO  ‰æ–Ê‚P|‹àŠzŒðÂó‹µ
     END-EVALUATE.
*
*
     IF      ‚v‚j|‘¶Ý (WK-N)  =  "A"
                   MOVE  Æ‰ï‚Q|Žd—l‚P  TO  Žd—l|Žd—lƒR[ƒh
             ELSE
                   MOVE  •¨Œ|Žd—l‚P  TO  Žd—l|Žd—lƒR[ƒh
     END-IF.
*
     READ    Žd—lƒ}ƒXƒ^       INVALID
                         MOVE  SPACES  TO  Žd—l|Žd—l–¼Ì.
     MOVE    Žd—l|Žd—l–¼Ì      TO  ‰æ–Ê‚P|Žd—l‚P.
*
     IF      ‚v‚j|‘¶Ý (WK-N)  =  "A"
                   MOVE  Æ‰ï‚Q|Žd—l‚Q  TO  Žd—l|Žd—lƒR[ƒh
             ELSE
                   MOVE  •¨Œ|Žd—l‚Q  TO  Žd—l|Žd—lƒR[ƒh
     END-IF.
*
     READ    Žd—lƒ}ƒXƒ^       INVALID
                         MOVE  SPACES  TO  Žd—l|Žd—l–¼Ì.
     MOVE    Žd—l|Žd—l–¼Ì      TO  ‰æ–Ê‚P|Žd—l‚Q.
*
*
     MOVE   Æ‰ï‚Q|Œ©Ï”Ô†       TO  Œˆ’è|Œ©Ï”Ô†.
     READ   Œˆ’èƒtƒ@ƒCƒ‹         INVALID
                           MOVE  SPACES   TO  ‰æ–Ê‚P|Œˆ’è‚P
                           MOVE  SPACES   TO  ‰æ–Ê‚P|Œˆ’è‚Q
                           MOVE  SPACES   TO  ‰æ–Ê‚P|Œˆ’è‚R
                           MOVE  SPACES   TO  ‰æ–Ê‚P|Œˆ’è‚S
                           MOVE  SPACES   TO  ‰æ–Ê‚P|Œˆ’è‚T
                           MOVE  SPACES   TO  ‰æ–Ê‚P|Œˆ’è‚U
                           GO  TO  –¾×‚O‚X‚O.
*
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚O"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚P"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚Q"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚R"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚S"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚T"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚U"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚V"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚W"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚P ( 1:1)  =  NC"‚X"
                                     GO  TO  –¾×‚O‚O‚P
     END-IF.
     MOVE    Œˆ’è|Œˆ’èŽ–€‚P  TO  ‰æ–Ê‚P|Œˆ’è‚P.
 –¾×‚O‚O‚P.
*
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚O"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚P"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚Q"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚R"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚S"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚T"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚U"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚V"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚W"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚Q ( 1:1)  =  NC"‚X"
                                     GO  TO  –¾×‚O‚O‚Q
     END-IF.
     MOVE    Œˆ’è|Œˆ’èŽ–€‚Q  TO  ‰æ–Ê‚P|Œˆ’è‚Q.
 –¾×‚O‚O‚Q.
*
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚O"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚P"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚Q"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚R"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚S"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚T"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚U"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚V"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚W"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚R ( 1:1)  =  NC"‚X"
                                     GO  TO  –¾×‚O‚O‚R
     END-IF.
     MOVE    Œˆ’è|Œˆ’èŽ–€‚R  TO  ‰æ–Ê‚P|Œˆ’è‚R.
 –¾×‚O‚O‚R.
*
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚O"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚P"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚Q"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚R"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚S"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚T"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚U"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚V"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚W"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚S ( 1:1)  =  NC"‚X"
                                     GO  TO  –¾×‚O‚O‚S
     END-IF.
     MOVE    Œˆ’è|Œˆ’èŽ–€‚S  TO  ‰æ–Ê‚P|Œˆ’è‚S.
 –¾×‚O‚O‚S.
*
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚O"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚P"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚Q"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚R"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚S"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚T"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚U"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚V"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚W"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚T ( 1:1)  =  NC"‚X"
                                     GO  TO  –¾×‚O‚O‚T
     END-IF.
     MOVE    Œˆ’è|Œˆ’èŽ–€‚T  TO  ‰æ–Ê‚P|Œˆ’è‚T.
 –¾×‚O‚O‚T.
*
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚O"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚P"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚Q"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚R"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚S"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚T"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚U"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚V"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚W"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     IF      Œˆ’è|Œˆ’èŽ–€‚U ( 1:1)  =  NC"‚X"
                                     GO  TO  –¾×‚O‚X‚O
     END-IF.
     MOVE    Œˆ’è|Œˆ’èŽ–€‚U  TO  ‰æ–Ê‚P|Œˆ’è‚U.
 –¾×‚O‚X‚O.
     MOVE  Æ‰ï‚Q|”z“d”Õ”  TO  ‰æ–Ê‚P|”z“d”Õ–Ê”.
     MOVE  Æ‰ï‚Q|§Œä”Õ”  TO  ‰æ–Ê‚P|§Œä”Õ–Ê”.
     MOVE  Æ‰ï‚Q|•ª“d”Õ”  TO  ‰æ–Ê‚P|•ª“d”Õ–Ê”.
     MOVE  Æ‰ï‚Q|‚»‚Ì‘¼”  TO  ‰æ–Ê‚P|‚»‚Ì‘¼–Ê”.
     MOVE  Æ‰ï‚Q|‡Œv”Õ”  TO  ‰æ–Ê‚P|‡Œv–Ê”.
*    IF      ‚v‚j|‘¶Ý (WK-N)  =  "A"
*              MOVE  Æ‰ï‚Q|”z“d”Õ”  TO  ‰æ–Ê‚P|”z“d”Õ–Ê”
*              MOVE  Æ‰ï‚Q|§Œä”Õ”  TO  ‰æ–Ê‚P|§Œä”Õ–Ê”
*              MOVE  Æ‰ï‚Q|•ª“d”Õ”  TO  ‰æ–Ê‚P|•ª“d”Õ–Ê”
*              MOVE  Æ‰ï‚Q|‚»‚Ì‘¼”  TO  ‰æ–Ê‚P|‚»‚Ì‘¼–Ê”
*              MOVE  Æ‰ï‚Q|‡Œv”Õ”  TO  ‰æ–Ê‚P|‡Œv–Ê”
*              GO  TO  –¾×ˆ—|I—¹
*    END-IF.
*
*    PERFORM   î•ñ€–Úˆ—.
*
*    MOVE    WK-HAIDENBAN      TO  ‰æ–Ê‚P|”z“d”Õ–Ê”.
*    MOVE    WK-SEIGYOBAN      TO  ‰æ–Ê‚P|§Œä”Õ–Ê”.
*    MOVE    WK-BUNDENBAN      TO  ‰æ–Ê‚P|•ª“d”Õ–Ê”.
*    MOVE    WK-SONOTABAN      TO  ‰æ–Ê‚P|‚»‚Ì‘¼–Ê”.
*    MOVE    WK-GOKEIBAN       TO  ‰æ–Ê‚P|‡Œv–Ê”.
 –¾×ˆ—|I—¹.
     EXIT.
******************************************************************
*       î•ñ€–Úƒtƒ@ƒCƒ‹‚ð“Ç‚ñ‚Å‚Ìˆ—
******************************************************************
 î•ñ€–Úˆ—            SECTION.
 î•ñ€–Úˆ—|ŠJŽn.
*
     INITIALIZE   WK-BANSU.
*
     MOVE    Æ‰ï‚Q|Œ©Ï”Ô†      TO  €–Ú|Œ©Ïƒiƒ“ƒo[.
     MOVE    ZERO                TO  €–Ú|Œ©Ï€”Ô
     START   î•ñ€–Úƒtƒ@ƒCƒ‹.
 î•ñ€–Ú‚O‚P‚O.
     READ    î•ñ€–Úƒtƒ@ƒCƒ‹    AT  END
                                 GO  TO  î•ñ€–Úˆ—|I—¹.
*
     IF      €–Ú|Œ©Ïƒiƒ“ƒo[  <   Æ‰ï‚Q|Œ©Ï”Ô†
                                 GO  TO  î•ñ€–Ú‚O‚P‚O
     END-IF.
     IF      €–Ú|Œ©Ïƒiƒ“ƒo[  >   Æ‰ï‚Q|Œ©Ï”Ô†
                                 GO  TO  î•ñ€–Úˆ—|I—¹
     END-IF.
*
     IF      €–Ú|»•i‹æ•ª (1) =  "01"
                     ADD   1     TO  WK-HAIDENBAN
                     ADD   1     TO  WK-GOKEIBAN
                     GO  TO  î•ñ€–Ú‚O‚P‚O
     END-IF.
     IF      €–Ú|»•i‹æ•ª (1) =  "02"
                     ADD   1     TO  WK-SEIGYOBAN
                     ADD   1     TO  WK-GOKEIBAN
                     GO  TO  î•ñ€–Ú‚O‚P‚O
     END-IF.
     IF      €–Ú|»•i‹æ•ª (1) =  "03"
                     ADD   1     TO  WK-BUNDENBAN
                     ADD   1     TO  WK-GOKEIBAN
                     GO  TO  î•ñ€–Ú‚O‚P‚O
     END-IF.
*
     ADD     1         TO  WK-SONOTABAN.
     ADD     1         TO  WK-GOKEIBAN.
     GO  TO  î•ñ€–Ú‚O‚P‚O.
 î•ñ€–Úˆ—|I—¹.
******************************************************************
*       ‚n‚o‚d‚mƒ`ƒFƒbƒNˆ—               (1.0)
******************************************************************
 ‚n‚o‚d‚mƒ`ƒFƒbƒNˆ—            SECTION.
 ‚n‚o‚d‚mƒ`ƒFƒbƒNˆ—|ŠJŽn.
*–¢Žó’•¨Œì}ˆË—Šƒtƒ@ƒCƒ‹
     EVALUATE     F1-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "MIJUSJL1"     TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F1-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*‘gDƒ}ƒXƒ^
     EVALUATE     F2-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "ASOSML1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F2-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*Žæˆøæƒ}ƒXƒ^
     EVALUATE     F3-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "ATORML1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F3-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*î•ñ•¨ŒŠÓƒtƒ@ƒCƒ‹ƒ‹
     EVALUATE     F4-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "AJBGFL1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F4-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*–¢Žó’•¨Œì}ˆË—ŠÆ‰ïƒtƒ@ƒCƒ‹
     EVALUATE     F5-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "MIJUSSL1"     TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F5-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*•¨ŒŒŸ“¢Œˆ’èƒtƒ@ƒCƒ‹
     EVALUATE     F6-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "KETUTER1"     TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F6-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*î•ñ•¨Œ€–Úƒtƒ@ƒCƒ‹
     EVALUATE     F7-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "AJBKFL1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F7-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*Žd—lƒ}ƒXƒ^
     EVALUATE     F8-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "ASIYML1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F8-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*–¢Žó’•¨Œì}ˆË—ŠÆ‰ïƒtƒ@ƒCƒ‹
     EVALUATE     F9-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "MIJUSSL2"     TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F9-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
*    ‰æ–Êƒtƒ@ƒCƒ‹.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
 ‚n‚o‚d‚mƒ`ƒFƒbƒNˆ—|I—¹.
     EXIT.
******************************************************************
 I—¹ˆ—            SECTION.
 I—¹ˆ—|ŠJŽn.
     CLOSE                  ‰æ–Êƒtƒ@ƒCƒ‹.
     CLOSE                  Æ‰ïƒtƒ@ƒCƒ‹.
     CLOSE                  ˆË—Šƒtƒ@ƒCƒ‹.
     CLOSE                  Žæˆøæƒ}ƒXƒ^
                            ‘gDƒ}ƒXƒ^
                            î•ñ•¨Œƒtƒ@ƒCƒ‹.
     CLOSE                  Œˆ’èƒtƒ@ƒCƒ‹.
     CLOSE                  î•ñ€–Úƒtƒ@ƒCƒ‹.
     CLOSE                  Žd—lƒ}ƒXƒ^.
     CLOSE                  Æ‰ïƒtƒ@ƒCƒ‹‚Q.
 I—¹ˆ—|I—¹.
     EXIT.
*=====================================================*
*       ‘æˆê‰æ–Êo—Í
*=====================================================*
 ‰æ–Êo—Íˆ—               SECTION.
 ‰æ–Êo—Í|ŠJŽn.
*
     MOVE      "ALLF"        TO     G-GRP.
     MOVE      "  "          TO     G-EXC.
     MOVE      "MJS080D1"    TO     G-NAME.
     WRITE     ‰æ–Ê|–¢Žó’ì}ˆË—Š.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "WRITE"        TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
 ‰æ–Êo—Í|I—¹.
     EXIT.
*=====================================================*
*       ‘æ“ñ‰æ–Êo—Í
*=====================================================*
 ‰æ–Êo—Íˆ—‚P             SECTION.
 ‰æ–Êo—Í‚P|ŠJŽn.
*
     MOVE      "SCREEN"      TO     G-GRP.
     MOVE      "  "          TO     G-EXC.
     MOVE      "MJS080D2"    TO     G-NAME.
     WRITE     ‰æ–Ê‚P|–¢Žó’ì}ˆË—Š‘.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS080CS"     TO        WK-PGMID
          MOVE    "GM-FILE1"     TO        WK-FLNAME
          MOVE    "WRITE"        TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           ˆÙíI—¹ˆ—
     END-EVALUATE.
 ‰æ–Êo—Í‚P|I—¹.
     EXIT.
******************************************************************
*    ˆÙíI—¹ˆ—@@@
******************************************************************
 ˆÙíI—¹ˆ—                    SECTION.
 ˆÙíI—¹ˆ—|ŠJŽn.
     DISPLAY "*****  " WK-FLNAME " "    WK-FLMODE " ERR   *****"
                                           UPON DSPMSG.
     DISPLAY "*                                 *"
                                           UPON DSPMSG.
     DISPLAY "*        F-STS    =   "      WK-FLSTS "          *"
                                           UPON DSPMSG.
     DISPLAY "*                                 *"
                                           UPON DSPMSG.
     DISPLAY "*****  " WK-PGMID " " WK-VER " ABEND *****"
                                           UPON DSPMSG.


     STOP RUN.

 ˆÙíI—¹ˆ—|I—¹.
     EXIT.
*
