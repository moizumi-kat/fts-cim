*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２００２０ＰＯ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　ユニット作業指示情報の
*                               　　　新規登録，取消処理を行う
*
*                                               作成日：93.04.02
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  受注ファイル（鑑）　　　　　<AJUGFL1  >
*                   受注ファイル（項目）　　  　<AJUKFL1  >
*                   名称マスタ                  <ANAMML1  >
*                   組織マスタ                  <ASOSML1  >
*                   仕様マスタ                  <ASIYML1  >
*                   作業マスタ                  <CSAGML1  >
*                   カレンダマスタ              <CCALML1  >
*                   運用条件ファイル            <AJKNML1  >
*                   発番ファイル                <AHATML1  >
*                   ユニット管理ファイル        <CUNIFL1  >
*                   作業指示ファイル            <CSJIFL1  >
*
* ＊＊＊　画面情報　　　＊＊＊
*  SMED NAME    ：　ユニット作業指示入力画面　　<DSP-F    >
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20020PO.
 ENVIRONMENT                DIVISION.
 CONFIGURATION              SECTION.
*SOURCE-COMPUTER.           FACOM  K6700.
*OBJECT-COMPUTER.           FACOM  K6700.
 SOURCE-COMPUTER.           FACOM-K.
 OBJECT-COMPUTER.           FACOM-K.
 SPECIAL-NAMES.
        CONSOLE   IS        DSP.
 INPUT-OUTPUT               SECTION.
 FILE-CONTROL.
*    ユニット作業指示入力画面
     SELECT      DSP-F      ASSIGN                 TO GS-DSPFILE
                            SYMBOLIC   DESTINATION IS "DSP"
                            FORMAT                 IS DSP-FORMAT
                            GROUP                  IS DSP-GROUP
                            PROCESSING MODE        IS DSP-MODE
                            SELECTED   FUNCTION    IS DSP-FUNC
                            DESTINATION-1          IS DSP-WSID
                            FILE       STATUS      IS DSP-STATUS.

*    受注ファイル（鑑）
     SELECT      AJUGFL1    ASSIGN       TO DA-VI-AJUGFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUGFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJUGFL.
*    受注ファイル（項目）
     SELECT      AJUKFL1    ASSIGN       TO DA-VI-AJUKFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AJUKFL1
                                            JYUKOU OF AJUKFL1
                            ACCESS MODE  IS DYNAMIC
                            FILE STATUS  IS ST-AJUKFL.
*    名称マスタ
     SELECT      ANAMML1    ASSIGN       TO DA-VI-ANAMML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS NAMKBN OF ANAMML1
                                            NAMCD  OF ANAMML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ANAMML.
*    組織マスタ
     SELECT      ASOSML1    ASSIGN       TO DA-VI-ASOSML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS BSYOCD OF ASOSML1
                                            TANCD  OF ASOSML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASOSML.
*    仕様マスタ
     SELECT      ASIYML1    ASSIGN       TO DA-VI-ASIYML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SIYOCD OF ASIYML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-ASIYML.
*    作業マスタ
     SELECT      CSAGML1    ASSIGN       TO DA-VI-CSAGML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS WORKCD OF CSAGML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSAGML.
*    カレンダマスタ
     SELECT      CCALML1    ASSIGN       TO DA-VI-CCALML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS YMD    OF CCALML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CCALML.
*    運用条件ファイル
     SELECT      AJKNML1    ASSIGN       TO DA-VI-AJKNML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JKNKBN OF AJKNML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJKNML.
*    発番ファイル
     SELECT      AHATML1    ASSIGN       TO DA-VI-AHATML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS HATKBN OF AHATML1
                                            HATUCD OF AHATML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AHATML.
*    ユニット管理ファイル
     SELECT      CUNIFL1    ASSIGN       TO DA-VI-CUNIFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF CUNIFL1
                                            KOMOKU OF CUNIFL1
                                            UNITCD OF CUNIFL1
                            ACCESS MODE  IS DYNAMIC
                            FILE STATUS  IS ST-CUNIFL.
*    作業指示ファイル
     SELECT      CSJIFL1    ASSIGN       TO DA-VI-CSJIFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SIJINO OF CSJIFL1
                                            SEIBAN OF CSJIFL1
                                            KOMOKU OF CSJIFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSJIFL.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    ユニット作業指示入力画面
******************************************************************
 FD  DSP-F.
     COPY        D20020D1   OF   XMDLIB.
******************************************************************
*    受注ファイル（鑑）
******************************************************************
 FD  AJUGFL1.
     COPY        AJUGFL1    OF   XFDLIB.
******************************************************************
*    受注ファイル（項目）
******************************************************************
 FD  AJUKFL1.
     COPY        AJUKFL1    OF   XFDLIB.
******************************************************************
*    名称マスタ
******************************************************************
 FD  ANAMML1.
     COPY        ANAMML1    OF   XFDLIB.
******************************************************************
*    組織マスタ
******************************************************************
 FD  ASOSML1.
     COPY        ASOSML1    OF   XFDLIB.
******************************************************************
*    仕様マスタ
******************************************************************
 FD  ASIYML1.
     COPY        ASIYML1    OF   XFDLIB.
******************************************************************
*    作業マスタ
******************************************************************
 FD  CSAGML1.
     COPY        CSAGML1    OF   XFDLIB.
******************************************************************
*    カレンダマスタ
******************************************************************
 FD  CCALML1.
     COPY        CCALML1    OF   XFDLIB.
******************************************************************
*    運用条件ファイル
******************************************************************
 FD  AJKNML1.
     COPY        AJKNML1    OF   XFDLIB.
******************************************************************
*    発番ファイル
******************************************************************
 FD  AHATML1.
     COPY        AHATML1    OF   XFDLIB.
******************************************************************
*    ユニット管理ファイル
******************************************************************
 FD  CUNIFL1.
     COPY        CUNIFL1    OF   XFDLIB.
******************************************************************
*    作業指示ファイル
******************************************************************
 FD  CSJIFL1.
     COPY        CSJIFL1    OF   XFDLIB.
/*****************************************************************
*    ＷＯＲＫ　ＡＲＥＡ
******************************************************************
 WORKING-STORAGE                 SECTION.
*    画面制御項目
 01  DSP-AREA.
     03  DSP-FORMAT              PIC  X(008).
     03  DSP-GROUP               PIC  X(008).
     03  DSP-MODE                PIC  X(002).
     03  DSP-FUNC                PIC  X(004).
     03  DSP-STATUS              PIC  X(002).
     03  DSP-WSID                PIC  X(008).
*    ファイルステータス
 01  ST-AREA.
     03  ST-AJUGFL               PIC  X(002).
     03  ST-AJUKFL               PIC  X(002).
     03  ST-ANAMML               PIC  X(002).
     03  ST-ASOSML               PIC  X(002).
     03  ST-ASIYML               PIC  X(002).
     03  ST-CSAGML               PIC  X(002).
     03  ST-CCALML               PIC  X(002).
     03  ST-AJKNML               PIC  X(002).
     03  ST-AHATML               PIC  X(002).
     03  ST-CUNIFL               PIC  X(002).
     03  ST-CSJIFL               PIC  X(002).
 01  WK-SAVE.
     03  WK-VAL-SAVE.
         05  WK-SYRKBN           PIC  9(001).
         05  WK-SJIKBN           PIC  9(001).
         05  WK-SEIBAN           PIC  X(006).
         05  WK-KOMOKU           PIC  9(004).
         05  WK-SGYCD-SAVE       PIC  X(004).
         05  WK-SGYNM-SAVE       PIC  N(010).
         05  WK-SKBCD-SAVE       PIC  X(004).
         05  WK-SKBNM-SAVE       PIC  N(010).
         05  WK-ENDYMD-SAVE      PIC  9(006).
*
         05  WK-BKN-CD           PIC  X(004).
         05  WK-BKN-HCD          PIC  X(004).
         05  WK-TSO-CD           PIC  X(004).
         05  WK-TSO-HCD          PIC  X(004).
         05  WK-AEN-CD           PIC  X(004).
         05  WK-AEN-HCD          PIC  X(004).
         05  WK-KMI-CD           PIC  X(004).
         05  WK-KMI-HCD          PIC  X(004).
*    システム情報退避エリア
     03  SYS-AREA.
         05  SYS-YMD.
             07  SYS-Y1          PIC  9(002).
             07  SYS-DATE        PIC  9(006).
         05  SYS-YMD-R           REDEFINES   SYS-YMD.
             07  SYS-YMD-RE      PIC  9(008).
         05  SYS-HMS             PIC  9(008).
*    カウント
     03  CNT-AREA.
         05  CNT-HAT             PIC  9(006).
         05  CNT-SJI             PIC  9(006).
         05  CNT-UNI1            PIC  9(006).
         05  CNT-UNI2            PIC  9(006).
         05  CNT-ENTR            PIC  9(002).
*    トランザクション管理フラグ
     03  TRN-FLG.
         05  TRN-STR-FLG         PIC  X(003).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SAVE-AREA.
         05  WK-SOSICD           PIC  X(004).
         05  WK-SIYOU            PIC  X(002).
         05  WK-JYUKOU           PIC  9(004).
         05  WK-SGYCD            PIC  X(004).
         05  WK-WORKCD           PIC  X(004).
         05  WK-KEY-POINT        PIC  X(002).
         05  WK-RENBAN           PIC  9(007).
         05  WK-ENDYMD           PIC  9(008).
         05  WK-KEY-YMD          PIC  9(008).
         05  WK-UNITCD           PIC  X(004).
*
     03  WK-ABEND.
         05  WK-SYORI            PIC  X(007).
         05  WK-FILE             PIC  X(008).
         05  WK-KEY1             PIC  X(009).
         05  WK-KEY2             PIC  X(009).
         05  WK-KEY3             PIC  X(009).
*
     03  WK-STATUS               PIC  X(002).
     03  WK-STATSU-R             REDEFINES   WK-STATUS.
         05  WK-STATUS-Q         PIC  9(002).
*    スイッチ／フラグ
     03  SW-AREA.
         05  SW-END              PIC  X(003).
         05  SW-INV              PIC  X(003).
         05  SW-SELECT           PIC  X(001).
*    メッセージ
     03  WK-NO                   PIC  X(006).
     03  WK-GUID                 PIC  X(006).
     03  WK-MESSAGE              PIC  N(038).
     03  WK-GAIDO                PIC  N(038).
*    添字
     03  IX1                     PIC  9(002).
     03  IX2                     PIC  9(002).
     03  IX3                     PIC  9(002).
     03  IX-T1                   PIC  9(001).
     03  IX-T2                   PIC  9(002).
     03  IX-MSG                  PIC  9(003).
*
     03  WK-CHECK.
         05  WK-ERR              PIC  X(003).
*    テーブル
     03  TBL-AREA-X.
         05  TBL-UNIT-JOHO       OCCURS 10.
             07  T-UNITCD        PIC  X(004).
             07  T-SYUKZM        PIC  9(008).
             07  TBL-SIJI-JOHO   OCCURS 12.
                 09  T-SJIKBN    PIC  X(001).
                 09  T-WYOTEI    PIC  9(008).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20020PO".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
*    メッセージ
 01  VALUE-AREA.
   02  WK-MSG-X.
     03  WK-MSG-R.
         05  WK-MSGNO001         PIC  X(006) VALUE "MSG001".
         05  WK-MSGNM001         PIC  N(038) VALUE
             NC"処理区分を入力して下さい．".
         05  WK-MSGNO002         PIC  X(006) VALUE "MSG002".
         05  WK-MSGNM002         PIC  N(038) VALUE
             NC"取消指示書発行、製番、項目を入力して下さい．".
         05  WK-MSGNO003         PIC  X(006) VALUE "MSG003".
         05  WK-MSGNM003         PIC  N(038) VALUE
             NC"製番、項目を入力して下さい．".
         05  WK-MSGNO004         PIC  X(006) VALUE "MSG004".
         05  WK-MSGNM004         PIC  N(038) VALUE
             NC"選択を入力して下さい．".
         05  WK-MSGNO005         PIC  X(006) VALUE "MSG005".
         05  WK-MSGNM005         PIC  N(038) VALUE
             NC"作業コード～作業完了日を入力して下さい．".
         05  WK-MSGNO006         PIC  X(006) VALUE "MSG006".
         05  WK-MSGNM006         PIC  N(038) VALUE
             NC"ファイルを更新します　確認して下さい．".
*
         05  WK-MSGNO007         PIC  X(006) VALUE "ERR001".
         05  WK-MSGNM007         PIC  N(038) VALUE
             NC"処理区分が未入力です．".
         05  WK-MSGNO008         PIC  X(006) VALUE "ERR002".
         05  WK-MSGNM008         PIC  N(038) VALUE
             NC"処理区分が存在しません．".
         05  WK-MSGNO009         PIC  X(006) VALUE "ERR003".
         05  WK-MSGNM009         PIC  N(038) VALUE
             NC"取消指示書発行区分が未入力です．".
         05  WK-MSGNO010         PIC  X(006) VALUE "ERR004".
         05  WK-MSGNM010         PIC  N(038) VALUE
             NC"取消指示書発行区分が存在しません．".
         05  WK-MSGNO011         PIC  X(006) VALUE "ERR005".
         05  WK-MSGNM011         PIC  N(038) VALUE
             NC"製番が未入力です．".
         05  WK-MSGNO012         PIC  X(006) VALUE "ERR006".
         05  WK-MSGNM012         PIC  N(038) VALUE
             NC"製番が受注ファイルに存在しません．".
         05  WK-MSGNO013         PIC  X(006) VALUE "ERR007".
         05  WK-MSGNM013         PIC  N(038) VALUE
             NC"項目が受注取消になっています．".
         05  WK-MSGNO014         PIC  X(006) VALUE "ERR008".
         05  WK-MSGNM014         PIC  N(038) VALUE
             NC"項目が未入力です．".
         05  WK-MSGNO015         PIC  X(006) VALUE "ERR009".
         05  WK-MSGNM015         PIC  N(038) VALUE
             NC"項目が受注ファイルに存在しません．".
         05  WK-MSGNO016         PIC  X(006) VALUE "ERR010".
         05  WK-MSGNM016         PIC  N(038) VALUE
             NC"製番が受注取消になっています．".
         05  WK-MSGNO017         PIC  X(006) VALUE "ERR011".
         05  WK-MSGNM017         PIC  N(038) VALUE
             NC"選択は１を入力して下さい．".
         05  WK-MSGNO018         PIC  X(006) VALUE "ERR012".
         05  WK-MSGNM018         PIC  N(038) VALUE
             NC"選択が未入力です．".
         05  WK-MSGNO019         PIC  X(006) VALUE "ERR013".
         05  WK-MSGNM019         PIC  N(038) VALUE
             NC"作業コードが未入力です．".
         05  WK-MSGNO020         PIC  X(006) VALUE "ERR014".
         05  WK-MSGNM020         PIC  N(038) VALUE
             NC"作業コードが作業マスタに存在しません．".
         05  WK-MSGNO021         PIC  X(006) VALUE "ERR015".
         05  WK-MSGNM021         PIC  N(038) VALUE
             NC"ユニットの中の作業コードではありません．".
         05  WK-MSGNO022         PIC  X(006) VALUE "ERR016".
         05  WK-MSGNM022         PIC  N(038) VALUE
             NC"既に指示されています．".
         05  WK-MSGNO023         PIC  X(006) VALUE "ERR017".
         05  WK-MSGNM023         PIC  N(038) VALUE
             NC"完成品で指示されています．".
         05  WK-MSGNO024         PIC  X(006) VALUE "ERR018".
         05  WK-MSGNM024         PIC  N(038) VALUE
             NC"未だ指示されていません．".
         05  WK-MSGNO025         PIC  X(006) VALUE "ERR019".
         05  WK-MSGNM025         PIC  N(038) VALUE
             NC"職場コードが未入力です．".
         05  WK-MSGNO026         PIC  X(006) VALUE "ERR020".
         05  WK-MSGNM026         PIC  N(038) VALUE
             NC"職場コードが組織マスタに存在しません．".
         05  WK-MSGNO027         PIC  X(006) VALUE "ERR021".
         05  WK-MSGNM027         PIC  N(038) VALUE
             NC"作業完了日が未入力です．".
         05  WK-MSGNO028         PIC  X(006) VALUE "ERR022".
         05  WK-MSGNM028         PIC  N(038) VALUE
             NC"カレンダマスタに存在しません．".
         05  WK-MSGNO029         PIC  X(006) VALUE "ERR023".
         05  WK-MSGNM029         PIC  N(038) VALUE
             NC"ＰＦキーエラーです．".
         05  WK-MSGNO031         PIC  X(006) VALUE "ERR025".
         05  WK-MSGNM031         PIC  N(038) VALUE
             NC"ユニットがありません．".
*
   02  WK-MSG-X-R                REDEFINES   WK-MSG-X.
     03  WK-MSG                  OCCURS  30.
         05  WK-MSGNO            PIC  X(006).
         05  WK-MSGNM            PIC  N(038).
*
*    ガイドメッセージ
 01  GUID-AREA.
   02  WK-GID-X.
     03  WK-GID-R.
         05  WK-GIDNO001         PIC  X(006) VALUE "GID001".
         05  WK-GIDNM001         PIC  N(038) VALUE
             NC"ＥＮＴ：入力　ＰＦ１０：終了".
         05  WK-GIDNO002         PIC  X(006) VALUE "GID003".
         05  WK-GIDNM002         PIC  N(038) VALUE
             NC"ＥＮＴ：入力　ＰＦ５：前項目".
*
   02  WK-GID-X-R                REDEFINES   WK-GID-X.
     03  WK-GID                  OCCURS   2.
         05  WK-GIDNO            PIC  X(006).
         05  WK-GIDNM            PIC  N(038).
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
     DISPLAY "*      AHATML1  UPD    = "  CNT-HAT        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CSJIFL1  OUT    = "  CNT-SJI        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CUNIFL1  OUT    = "  CNT-UNI1       "   *"
                                                     UPON    DSP.
     DISPLAY "*      CUNIFL1  UPD    = "  CNT-UNI2       "   *"
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
     INITIALIZE                  ST-AREA  WK-SAVE  DSP-AREA
                                 WORK-AREA.
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN         I-O            DSP-F.
     OPEN         INPUT          AJUGFL1   AJUKFL1   ANAMML1
                                 ASOSML1   ASIYML1   CSAGML1
                                 CCALML1   AJKNML1.
     OPEN         I-O            CUNIFL1   CSJIFL1   AHATML1.
     PERFORM                     OPEN-CHECK-SEC.
*
*  システム日付取得
     ACCEPT    SYS-DATE          FROM  DATE.
     IF        SYS-DATE(1:2)     >=    90
     THEN
       MOVE    19                TO    SYS-Y1
     ELSE
       MOVE    20                TO    SYS-Y1
     END-IF.
*
*  トランザクションSTART
     CALL      "XMROTSTR".
*
*  運用条件Ｆより鈑金ｺｰﾄﾞ／出荷ｺｰﾄﾞ取得（作業ｺｰﾄﾞﾁｪｯｸ 用）
     PERFORM                     JKNM-READ-SEC.
     MOVE      JCD13 OF AJKNML1  TO    WK-BKN-CD.
     MOVE      JCD14 OF AJKNML1  TO    WK-BKN-HCD.
     MOVE      JCD15 OF AJKNML1  TO    WK-TSO-CD.
     MOVE      JCD16 OF AJKNML1  TO    WK-TSO-HCD.
     MOVE      JCD17 OF AJKNML1  TO    WK-AEN-CD.
     MOVE      JCD18 OF AJKNML1  TO    WK-AEN-HCD.
     MOVE      JCD19 OF AJKNML1  TO    WK-KMI-CD.
     MOVE      JCD20 OF AJKNML1  TO    WK-KMI-HCD.
*
*  トランザクションEND
     CALL      "XMROTEND".
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
*  初期画面表示
     MOVE    SPACE               TO    D20020D1.
     INITIALIZE                        D20020D1.
     INITIALIZE                  WORK-AREA.
 MAIN-015.
*                                < ｼｮﾘ ｸﾌﾞﾝ ﾆｭｳﾘｮｸ ｼﾃｸﾀﾞｻｲ >
     MOVE    "GID001"            TO    WK-GUID.
     MOVE    "MSG001"            TO    WK-NO.
     PERFORM DSP-WRITE-SEC.
 MAIN-020.
*  処理区分入力
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP001"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK1-SEC
               IF     WK-ERR     =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-020
               END-IF
         WHEN  "F010"
               MOVE  "END"       TO    SW-END
*
*            トランザクション終了
               CALL      "XMROTEND"
               GO   TO           MAIN-999
         WHEN  OTHER
*                                < PFｷｰｴﾗｰ >
               MOVE  "ERR023"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-020
     END-EVALUATE.
*
 MAIN-030.
     EVALUATE  WK-SYRKBN
         WHEN  1
*                                < ｾｲﾊﾞﾝ ｺｳﾓｸ ﾆｭｳﾘﾖｸ ﾖｳｷｭｳ >
               MOVE  "MSG003"    TO    WK-NO
         WHEN  2
*                                < ﾄﾘｹｼｼｼﾞｼｮ ｾｲﾊﾞﾝ ｺｳﾓｸ ｦ ﾆｭｳﾘｮｸ >
               MOVE  "MSG002"    TO    WK-NO
     END-EVALUATE.
     MOVE    "GID003"            TO    WK-GUID.
     PERFORM                     DSP-WRITE-SEC.
*
 MAIN-035.
*  取消指示書発行区分／製番／項目
     EVALUATE  WK-SYRKBN
         WHEN  1
               MOVE  "GRP003"    TO    DSP-GROUP
         WHEN  2
               MOVE  "GRP002"    TO    DSP-GROUP
     END-EVALUATE.
     MOVE    "NE"                TO    DSP-MODE.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK2-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-035
               ELSE
                 PERFORM         UNIT-SET-SEC
                 IF  WK-ERR      =   "ERR"
                 THEN
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-035
                 END-IF
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR2-SEC
               MOVE  ZERO        TO    SJIKBN OF D20020D1
                                       KMKNO  OF D20020D1
                                       ENDYMD OF D20020D1
               MOVE  SPACE       TO    SEIBAN OF D20020D1
                                       KENMEI OF D20020D1
                                       TANTOU OF D20020D1
                                       SIYOU1 OF D20020D1
                                       SIYOU2 OF D20020D1
                                       KMKNM  OF D20020D1
                                       SGYCD  OF D20020D1
                                       SGYNM  OF D20020D1
                                       SKBCD  OF D20020D1
                                       SKBNM  OF D20020D1
               GO   TO           MAIN-015
         WHEN  OTHER
*                                < PFｷｰｴﾗｰ >
               MOVE  "ERR023"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-035
     END-EVALUATE.
*
 MAIN-040.
*                                < ｾﾝﾀｸｦ ﾆｭｳﾘﾖｸｼﾃｸﾀﾞｻｲ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG004"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-045.
*  選択入力
     PERFORM                     PROTECT-SEC.
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP004"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK4-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-045
               END-IF
         WHEN  "F005"
               MOVE    SPACE     TO    D20020D1
               INITIALIZE        D20020D1
               INITIALIZE        TBL-AREA-X
               PERFORM           ATR-CLR4-SEC
               PERFORM           MEISAI-SET-SEC
               MOVE    ZERO      TO    KMKNO  OF D20020D1
               MOVE    WK-SYRKBN TO    SYRKBN OF D20020D1
               MOVE    WK-SJIKBN TO    SJIKBN OF D20020D1
               MOVE    WK-SEIBAN TO    SEIBAN OF D20020D1
               MOVE    "C"       TO    EDIT-CURSOR OF KMKNO
                                              OF D20020D1
               GO   TO           MAIN-030
         WHEN  OTHER
*                                < PFｷｰｴﾗｰ >
               MOVE  "ERR023"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-045
     END-EVALUATE.
*
 MAIN-050.
*                                < ｻｷﾞｮｳｺｰﾄﾞ ﾎｶ ｦ ﾆｭｳﾘｮｸ ｼﾃｸﾀﾞｻｲ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG005"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-055.
*  作業コード．職場コード．作業完了日
     MOVE    SGYCD  OF D20020D1  TO    WK-SGYCD.
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP005"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.

     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK5-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 IF  WK-NO       =   "ERR016"  OR
                                     "ERR017"  OR
                                     "ERR018"
                 THEN
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-045
                 ELSE
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-055
                 END-IF
               ELSE
                 MOVE   SGYCD  OF  D20020D1    TO   WK-SGYCD-SAVE
                 MOVE   SGYNM  OF  D20020D1    TO   WK-SGYNM-SAVE
                 MOVE   SKBCD  OF  D20020D1    TO   WK-SKBCD-SAVE
                 MOVE   SKBNM  OF  D20020D1    TO   WK-SKBNM-SAVE
                 MOVE   ENDYMD OF  D20020D1    TO   WK-ENDYMD-SAVE
               END-IF
         WHEN  "F005"
               PERFORM           CHECK5-PF5-SEC
               PERFORM           ATR-CLR5-SEC
               GO      TO        MAIN-040
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR023"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-055
     END-EVALUATE.
*
 MAIN-060.
*                                < ﾌｧｲﾙ ｦ ｺｳｼﾝｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
     MOVE      "GID003"          TO    WK-GUID.
     MOVE      "MSG006"          TO    WK-NO.
     MOVE      SPACE             TO    DUMMY.
     PERFORM                     DSP-WRITE-SEC.
*
 MAIN-065.
*  ダミー　入力
     MOVE    "NE"                TO  DSP-MODE.
     MOVE    "GRP006"            TO  DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
*              ファイル更新処理を行う
               PERFORM           FILE-UPD-SEC
               MOVE    SPACE     TO    D20020D1
               INITIALIZE              D20020D1
               INITIALIZE              WK-SAVE-AREA
                                       TBL-AREA-X
               MOVE  WK-SYRKBN      TO SYRKBN OF D20020D1
               MOVE  WK-SJIKBN      TO SJIKBN OF D20020D1
               MOVE  WK-SEIBAN      TO SEIBAN OF D20020D1
               MOVE  WK-SGYCD-SAVE  TO SGYCD  OF D20020D1
               MOVE  WK-SGYNM-SAVE  TO SGYNM  OF D20020D1
               MOVE  WK-SKBCD-SAVE  TO SKBCD  OF D20020D1
               MOVE  WK-SKBNM-SAVE  TO SKBNM  OF D20020D1
               MOVE  WK-ENDYMD-SAVE TO ENDYMD OF D20020D1
               PERFORM           MEISAI-SET-SEC
               MOVE  ZERO        TO    KMKNO  OF D20020D1
               MOVE  "C"         TO    EDIT-CURSOR OF KMKNO
                                                   OF D20020D1
               GO    TO          MAIN-030
         WHEN  "F005"
               GO  TO   MAIN-050
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE    "ERR023"  TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-065
     END-EVALUATE.
 MAIN-999.
     EXIT.
/*****************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       AJUGFL1   AJUKFL1   ANAMML1
                                 ASOSML1   ASIYML1   CSAGML1
                                 CCALML1   AJKNML1   CUNIFL1
                                 CSJIFL1   AHATML1   DSP-F.
 FINAL-999.
     EXIT.
/*****************************************************************
*    ＯＰＥＮ－ＣＨＥＣＫ処理
******************************************************************
 OPEN-CHECK-SEC                  SECTION.
 OPEN-CHECK-010.
*
     IF         DSP-STATUS       NOT =   "00"
     THEN
       MOVE    "DSP-F"           TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     DSP-STATUS       TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-AJUGFL        NOT =   "00"
     THEN
       MOVE    "AJUGFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AJUGFL        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-AJUKFL        NOT =   "00"
     THEN
       MOVE    "AJUKFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AJUKFL        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-ANAMML        NOT =   "00"
     THEN
       MOVE    "ANAMML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-ANAMML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-ASOSML        NOT =   "00"
     THEN
       MOVE    "ASOSML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-ASOSML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-ASIYML        NOT =   "00"
     THEN
       MOVE    "ASIYML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-ASIYML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CSAGML        NOT =   "00"
     THEN
       MOVE    "CSAGML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CSAGML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CCALML        NOT =   "00"
     THEN
       MOVE    "CCALML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CCALML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-AJKNML        NOT =   "00"
     THEN
       MOVE    "AJKNML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AJKNML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-AHATML        NOT =   "00"
     THEN
       MOVE    "AHATML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AHATML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CUNIFL        NOT =   "00"
     THEN
       MOVE    "CUNIFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CUNIFL        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CSJIFL        NOT =   "00"
     THEN
       MOVE    "CSJIFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CSJIFL        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
 OPEN-CHECK-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ１処理　　－　処理区分　－
******************************************************************
 CHECK1-SEC                      SECTION.
 CHECK1-010.
*
     INITIALIZE                  WK-ERR.
     MOVE    "M"                 TO    EDIT-COLOR  OF SYRKBN
                                                   OF D20020D1.
     MOVE    SPACE               TO    EDIT-CURSOR OF SYRKBN
                                                   OF D20020D1.
*
     IF        SYRKBN OF D20020D1 =    ZERO
     THEN
*                                < ｼｮﾘｸﾌﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "R"               TO    EDIT-COLOR OF SYRKBN
                                                  OF D20020D1
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR001"          TO    WK-NO
     ELSE
       IF      SYRKBN OF D20020D1 =    1  OR  2
       THEN
         IF    SYRKBN OF D20020D1 =    1
         THEN
           MOVE  ZERO            TO    SJIKBN OF D20020D1
         END-IF
         MOVE SYRKBN OF D20020D1 TO    WK-SYRKBN
       ELSE
*                                < ｼｮﾘｸﾌﾞﾝ ｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE  "R"               TO    EDIT-COLOR OF SYRKBN
                                                  OF D20020D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR002"          TO    WK-NO
       END-IF
     END-IF.
 CHECK1-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ２処理　　－　取消指示区分／製番／項目　－
******************************************************************
 CHECK2-SEC                      SECTION.
 CHECK2-010.
*
     PERFORM                     ATR-CLR2-SEC.
     MOVE      SPACE             TO    WK-ERR.
     MOVE      SPACE             TO    KENMEI OF D20020D1
                                       TANTOU OF D20020D1
                                       SIYOU1 OF D20020D1
                                       SIYOU2 OF D20020D1
                                       KMKNM  OF D20020D1.
*
*    処理が新規の場合は製番．項目のチェックへ
     IF     WK-SYRKBN  = 1
     THEN
       MOVE    ZERO              TO    SJIKBN OF D20020D1
                                       WK-SJIKBN
       GO      TO        CHECK2-020
     END-IF.
*
*  取消指示書発行
     IF      SJIKBN OF D20020D1  =     ZERO
     THEN
*                                < ﾄﾘｹｼｼｼﾞｼｮﾊｯｺｳｸﾌﾞﾝ ｶﾞ ﾐﾆｭﾘｮｸﾃﾞｽ>
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR003"          TO    WK-NO
     ELSE
       IF    SJIKBN OF D20020D1  =     1    OR    2
       THEN
         MOVE    SJIKBN OF D20020D1
                                 TO    WK-SJIKBN
       ELSE
*                                < ﾄﾘｹｼｼｼﾞｼｮﾊｯｺｳｸﾌﾞﾝ ｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ>
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR004"        TO    WK-NO
       END-IF
     END-IF.
*
     IF      WK-ERR              =     "ERR"
     THEN
       MOVE    "C"     TO    EDIT-CURSOR OF SJIKBN OF D20020D1
       MOVE    "R"     TO    EDIT-COLOR  OF SJIKBN OF D20020D1
     END-IF.
*
 CHECK2-020.
*  製番
     MOVE    SPACE               TO    WK-SEIBAN.
     IF      SEIBAN OF D20020D1  =     SPACE
     THEN
       IF      WK-ERR            =     SPACE
       THEN
*                                < ｾｲﾊﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR005"        TO    WK-NO
         MOVE    "C"             TO    EDIT-CURSOR OF SEIBAN
                                                   OF D20020D1
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20020D1
     ELSE
*      実存チェック( 受注ファイル（鑑）)
       MOVE  SEIBAN OF D20020D1  TO    WK-SEIBAN
       PERFORM                   JUGF-READ-SEC
       IF      SW-INV            =    "INV"
       THEN
         IF    WK-ERR            =     SPACE
         THEN
*                                < ｾｲﾊﾞﾝｶﾞ ｼﾞｭﾁｭｳFﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "ERR006"      TO    WK-NO
           MOVE    "C"           TO    EDIT-CURSOR OF SEIBAN
                                                   OF D20020D1
         END-IF
         MOVE      "R"           TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20020D1
       ELSE
         IF  ( DELFLG OF AJUGFL1   =   "1"  )  AND
             ( SYRKBN OF D20020D1  =   "1"  )
         THEN
           IF    WK-ERR          =     SPACE
           THEN
*                                < ｾｲﾊﾞﾝｶﾞ ｼﾞｭﾁｭｳﾄﾘｹｼﾆ ﾅｯﾃｲﾏｽ >
             MOVE    "ERR"       TO    WK-ERR
             MOVE    "ERR010"    TO    WK-NO
             MOVE    "C"         TO    EDIT-CURSOR OF SEIBAN
                                                   OF D20020D1
           END-IF
           MOVE      "R"         TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20020D1
         ELSE
*          件名／担当者名／仕様１／仕様２セット
           PERFORM               MEISAI-SET-SEC
         END-IF
       END-IF
     END-IF.
*
*  製番入力エラー時は項目チェックをしない
     IF    ( WK-NO               =     "ERR005"  OR
                                       "ERR006"  OR
                                       "ERR010") AND
           ( WK-ERR              =     "ERR"   )
     THEN
       MOVE  ZERO                TO    KMKNO OF D20020D1
       GO    TO     CHECK2-999
     END-IF.
*
*  項目
     MOVE    ZERO                TO    WK-JYUKOU  WK-KOMOKU.
     IF      KMKNO  OF D20020D1  =     ZERO
     THEN
       IF      WK-ERR            =     SPACE
       THEN
*                                < ｺｳﾓｸ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR008"        TO    WK-NO
         MOVE    "C"             TO    EDIT-CURSOR OF KMKNO
                                                   OF D20020D1
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF KMKNO
                                                   OF D20020D1
     ELSE
*      実存チェック( 受注ファイル（項目）)
       MOVE  KMKNO  OF D20020D1  TO    WK-JYUKOU
       MOVE  "="                 TO    WK-KEY-POINT
       PERFORM                   JUKF-STR-SEC
       IF      SW-INV            =    "INV"
       THEN
         IF    WK-ERR            =     SPACE
         THEN
*                                < ｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳFﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "ERR009"      TO    WK-NO
           MOVE    "C"           TO    EDIT-CURSOR OF KMKNO
                                                   OF D20020D1
         END-IF
         MOVE      "R"           TO    EDIT-COLOR  OF KMKNO
                                                   OF D20020D1
       ELSE
         PERFORM                 JUKF-NEXT-SEC
         IF  ( DELFLG OF AJUKFL1   =  "1"  )  AND
             ( SYRKBN OF D20020D1  =  "1"  )
         THEN
           IF    WK-ERR          =     SPACE
           THEN
*                                < ｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳﾄﾘｹｼﾆ ﾅｯﾃｲﾏｽ >
             MOVE    "ERR"       TO    WK-ERR
             MOVE    "ERR007"    TO    WK-NO
             MOVE    "C"         TO    EDIT-CURSOR OF KMKNO
                                                   OF D20020D1
           END-IF
           MOVE      "R"         TO    EDIT-COLOR  OF KMKNO
                                                   OF D20020D1
         ELSE
           MOVE    KMKNO OF D20020D1
                                 TO    WK-KOMOKU
*          製品名（受注Ｆより）
           MOVE    SEIMEI OF AJUKFL1
                                 TO    KMKNM  OF D20020D1
         END-IF
       END-IF
     END-IF.
 CHECK2-999.
     EXIT.
/*****************************************************************
*    明細セット処理（製番．項目入力後セットされる項目）
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
*
*  件名（受注ファイル（鑑）より）
     MOVE    KENMEI OF AJUGFL1   TO    KENMEI OF D20020D1.
*
*  担当名（組織マスタより）
     MOVE    SOSICD OF AJUGFL1   TO    WK-SOSICD.
     PERFORM                     SOSM-READ-SEC.
     IF      SW-INV        =    "INV"
     THEN
       MOVE    SPACE             TO    TANTOU OF D20020D1
     ELSE
       MOVE    TANNAM OF ASOSML1 TO    TANTOU OF D20020D1
     END-IF.
*
*  仕様１（仕様マスタより）
     MOVE    SIYOU1 OF AJUGFL1   TO    WK-SIYOU.
     PERFORM                     SIYM-READ-SEC.
     IF      SW-INV        =    "INV"
     THEN
       MOVE    SPACE             TO    SIYOU1 OF D20020D1
     ELSE
       MOVE    SIYONA OF ASIYML1 TO    SIYOU1 OF D20020D1
     END-IF.
*  仕様２（仕様マスタより）
     MOVE    SIYOU2 OF AJUGFL1   TO    WK-SIYOU.
     PERFORM                     SIYM-READ-SEC.
     IF      SW-INV        =    "INV"
     THEN
       MOVE    SPACE             TO    SIYOU2 OF D20020D1
     ELSE
       MOVE    SIYONA OF ASIYML1 TO    SIYOU2 OF D20020D1
     END-IF.
 MEISAI-SET-999.
     EXIT.
/*****************************************************************
*    ユニット情報設定処理
******************************************************************
 UNIT-SET-SEC                    SECTION.
 UNIT-SET-010.
*
     INITIALIZE                  TBL-AREA-X  CNT-ENTR.
     MOVE       SPACE            TO    WK-ERR.
*
     MOVE       ">="             TO    WK-KEY-POINT.
     MOVE       SPACE            TO    WK-UNITCD.
     PERFORM                     UNIF-STR-SEC.
     IF         SW-INV           =    "INV"
     THEN
*                                < ﾕﾆｯﾄｶﾞ ｱﾘﾏｾﾝ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR025"          TO    WK-NO
       MOVE    "C"               TO    EDIT-CURSOR OF KMKNO
                                                   OF D20020D1
       MOVE    "R"               TO    EDIT-COLOR  OF KMKNO
                                                   OF D20020D1
       GO  TO   UNIT-SET-999
     ELSE
       PERFORM                   UNIF-NEXT-SEC
       IF       WK-SEIBAN        =     SEIBAN OF CUNIFL1  AND
                WK-KOMOKU        =     KOMOKU OF CUNIFL1
       THEN
         CONTINUE
       ELSE
*                                < ﾕﾆｯﾄｶﾞ ｱﾘﾏｾﾝ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR025"        TO    WK-NO
         MOVE    "C"             TO    EDIT-CURSOR OF KMKNO
                                                   OF D20020D1
         MOVE    "R"             TO    EDIT-COLOR  OF KMKNO
                                                   OF D20020D1
         GO  TO   UNIT-SET-999
       END-IF
     END-IF.
*
     MOVE       ZERO             TO    IX1.
*
     PERFORM    UNTIL ( SW-INV         =  "END"            )
                OR    ( WK-SEIBAN  NOT = SEIBAN OF CUNIFL1 )
                OR    ( WK-KOMOKU  NOT = KOMOKU OF CUNIFL1 )
*
*        ユニットコード
         ADD   1                 TO    IX1
         MOVE  UNITCD OF CUNIFL1 TO    T-UNITCD (IX1)
*        ユニット名取得（名称マスタ）
         PERFORM                 NAMM-READ-SEC
         IF    SW-INV            =    "INV"
         THEN
           MOVE  SPACE           TO    UNITNM OF D20020D1(IX1)
         ELSE
           MOVE  SESIKI OF ANAMML1
                                 TO    UNITNM OF D20020D1(IX1)
         END-IF
*
*
*        指示区分．作業完了予定日
         PERFORM  VARYING  IX2   FROM  1  BY  1
                  UNTIL    IX2   >    12
*
             MOVE  SJIKBN OF CUNIFL1(IX2)
                                 TO    T-SJIKBN (IX1 IX2)
             MOVE  WYOTEI OF CUNIFL1(IX2)
                                 TO    T-WYOTEI (IX1 IX2)
             IF    IX2           =     9
             THEN
*              出荷済
               MOVE  WKANBI OF CUNIFL1(9)
                                 TO    SYUKZM OF D20020D1(IX1)
                                       T-SYUKZM (IX1)
             END-IF
         END-PERFORM
         PERFORM                 UNIF-NEXT-SEC
     END-PERFORM.
*
     MOVE    IX1                 TO    CNT-ENTR.
 UNIT-SET-999.
     EXIT.
/*****************************************************************
*    選択プロテクト設定処理
******************************************************************
 PROTECT-SEC                     SECTION.
 PROTECT-010.
*
     PERFORM    VARYING  IX1     FROM  1  BY  1
                UNTIL    IX1     >     10
*
         IF     T-UNITCD(IX1)    = SPACE
         THEN
           MOVE    "X"           TO    EDIT-STATUS OF SENTAK
                                       OF D20020D1(IX1)
         ELSE
           MOVE    " "           TO    EDIT-STATUS OF SENTAK
                                       OF D20020D1(IX1)
         END-IF
     END-PERFORM.
 PROTECT-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ４処理　　－　選択　－
******************************************************************
 CHECK4-SEC                      SECTION.
 CHECK4-010.
*
     INITIALIZE                  WK-ERR    SW-SELECT.
     PERFORM                     ATR-CLR4-SEC.
*
     PERFORM  VARYING  IX1       FROM  1  BY  1
              UNTIL    IX1       >     10
*
         EVALUATE  SENTAK OF D20020D1(IX1)
            WHEN  0
                CONTINUE
            WHEN  1
                MOVE  "1"        TO    SW-SELECT
            WHEN  OTHER
*                                < ｾﾝﾀｸﾊ 1 ｦ ﾆｭｳﾘｮｸ ｼﾃｸﾀﾞｻｲ >
                IF   WK-ERR   =     SPACE
                THEN
                  MOVE  "ERR"    TO    WK-ERR
                  MOVE  "ERR011" TO    WK-NO
                  MOVE  "C"      TO    EDIT-CURSOR OF SENTAK
                                                  OF D20020D1(IX1)
                END-IF
                MOVE    "R"      TO    EDIT-COLOR OF SENTAK
                                                  OF D20020D1(IX1)
         END-EVALUATE
     END-PERFORM.
*
     IF        SW-SELECT  =  SPACE
     THEN
*                                < ｾﾝﾀｸｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       IF      WK-ERR     =  SPACE
       THEN
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR012"          TO    WK-NO
         MOVE  "C"               TO    EDIT-CURSOR OF SENTAK
                                                   OF D20020D1(1)
         PERFORM  VARYING  IX1   FROM  1  BY  1
                  UNTIL    IX1   >     CNT-ENTR
             MOVE  "R"           TO    EDIT-COLOR OF SENTAK
                                                  OF D20020D1(IX1)
         END-PERFORM
       END-IF
     END-IF.
 CHECK4-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ５処理（ＰＦ５）　－　作業コード　－
******************************************************************
 CHECK5-PF5-SEC                      SECTION.
 CHECK5-PF5-010.
*
     MOVE       SPACE            TO    SGYNM  OF D20020D1.
     PERFORM    VARYING  IX1     FROM  1  BY  1
                UNTIL    IX1     >     10
         MOVE   ZERO             TO    SIJIZM OF D20020D1(IX1)
     END-PERFORM.
     IF      SGYCD  OF D20020D1  =     SPACE
     THEN
       CONTINUE
     ELSE
       IF  ( SGYCD OF D20020D1   =     WK-BKN-CD )  OR
           ( SGYCD OF D20020D1   =     WK-BKN-HCD)  OR
           ( SGYCD OF D20020D1   =     WK-TSO-CD )  OR
           ( SGYCD OF D20020D1   =     WK-TSO-HCD)  OR
           ( SGYCD OF D20020D1   =     WK-AEN-CD )  OR
           ( SGYCD OF D20020D1   =     WK-AEN-HCD)  OR
           ( SGYCD OF D20020D1   =     WK-KMI-CD )  OR
           ( SGYCD OF D20020D1   =     WK-KMI-HCD)
       THEN
*        ユニット情報再設定
         PERFORM                 UNIT-SET-SEC
         PERFORM                 IDX-SET-SEC
*
*        指示済（画面）に情報出力
         PERFORM   VARYING  IX1  FROM  1  BY  1
                   UNTIL  ( IX1  >     10       )
                   OR     ( IX1  >     CNT-ENTR )
             MOVE  T-WYOTEI(IX1  IX2)
                                 TO    SIJIZM OF D20020D1(IX1)
         END-PERFORM
*
         MOVE  SGYCD OF D20020D1 TO    WK-WORKCD
         PERFORM                 SAGM-READ-SEC
         IF    SW-INV            =    "INV"
         THEN
           CONTINUE
         ELSE
*          作業名
           MOVE    WNEI OF CSAGML1
                                 TO    SGYNM OF D20020D1
         END-IF
       END-IF
     END-IF.
*
 CHECK5-PF5-010.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ５処理　　－　作業コード～作業完了日　－
******************************************************************
 CHECK5-SEC                      SECTION.
 CHECK5-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR5-SEC.
     MOVE       SPACE            TO    SGYNM  OF D20020D1.
     PERFORM    VARYING  IX1     FROM  1  BY  1
                UNTIL    IX1     >     10
         MOVE   ZERO             TO    SIJIZM OF D20020D1(IX1)
     END-PERFORM.
*
     IF      SGYCD  OF D20020D1  =     SPACE
     THEN
*                                < ｻｷﾞｮｳｺｰﾄﾞｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR013"          TO    WK-NO
     ELSE
*      入力作業コードが作業マスタに存在すること
       MOVE    SGYCD OF D20020D1 TO    WK-WORKCD
       PERFORM                   SAGM-READ-SEC
       IF      SW-INV            =    "INV"
       THEN
*                                < ｻｷﾞｮｳﾏｽﾀ ﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR014"          TO    WK-NO
       ELSE
*        作業名
         MOVE  WNEI  OF CSAGML1  TO    SGYNM OF D20020D1
         IF  ( SGYCD OF D20020D1 =     WK-BKN-CD )  OR
             ( SGYCD OF D20020D1 =     WK-BKN-HCD)  OR
             ( SGYCD OF D20020D1 =     WK-TSO-CD )  OR
             ( SGYCD OF D20020D1 =     WK-TSO-HCD)  OR
             ( SGYCD OF D20020D1 =     WK-AEN-CD )  OR
             ( SGYCD OF D20020D1 =     WK-AEN-HCD)  OR
             ( SGYCD OF D20020D1 =     WK-KMI-CD )  OR
             ( SGYCD OF D20020D1 =     WK-KMI-HCD)
         THEN
*          ユニット情報再設定
           PERFORM               UNIT-SET-SEC
           PERFORM               IDX-SET-SEC
*
*          指示済（画面）に情報出力
           PERFORM    VARYING  IX1     FROM  1  BY  1
                      UNTIL  ( IX1     >     10       )
                      OR     ( IX1     >     CNT-ENTR )
*
               MOVE  T-WYOTEI(IX1 IX2)
                                 TO    SIJIZM OF D20020D1(IX1)
           END-PERFORM
         ELSE
*                                < ﾕﾆｯﾄ ﾁｭｳﾉ ｻｷﾞｮｳｺｰﾄﾞﾃﾞﾊ ｱﾘﾏｾﾝ >
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "ERR015"      TO    WK-NO
         END-IF
       END-IF
     END-IF.
     IF        WK-ERR  =  "ERR"
     THEN
       MOVE    "R"     TO    EDIT-COLOR  OF SGYCD  OF D20020D1
       MOVE    "C"     TO    EDIT-CURSOR OF SGYCD  OF D20020D1
     END-IF.
*
*  職場コード
     IF     ( SKBCD OF D20020D1  = SPACE ) AND
            ( WK-SYRKBN          = 1     )
     THEN
*                                < ｼｮｸﾊﾞｺｰﾄﾞ ｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       IF        WK-ERR          = SPACE
       THEN
         MOVE    "C"             TO    EDIT-CURSOR OF SKBCD
                                                   OF D20020D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR019"        TO    WK-NO
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF SKBCD
                                                   OF D20020D1
       MOVE      SPACE           TO    SKBNM OF D20020D1
     ELSE
       IF   SKBCD OF D20020D1 NOT = SPACE
       THEN
*      組織マスタに存在チェックを行う(職場名の取得)
         MOVE  SKBCD OF D20020D1 TO    WK-SOSICD
         PERFORM                 SOSM-READ-SEC
*
         IF        SW-INV        = "INV"
         THEN
*                                < ｺｰﾄﾞ ｶﾞ ｿｼｷﾏｽﾀ ﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           IF      WK-ERR        = SPACE
           THEN
             MOVE  "C"           TO    EDIT-CURSOR OF SKBCD
                                                   OF D20020D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR020"      TO    WK-NO
           END-IF
           MOVE    "R"           TO    EDIT-COLOR  OF SKBCD
                                                   OF D20020D1
           MOVE    SPACE         TO    SKBNM OF D20020D1
         ELSE
           MOVE    BSYNAM OF ASOSML1
                                 TO    SKBNM OF D20020D1
         END-IF
       END-IF
     END-IF.
*
*  作業完了日チェック
     IF     ( ENDYMD OF D20020D1 = ZERO ) AND
            ( WK-SYRKBN          = 1    )
     THEN
*                                < ﾋﾂﾞｹｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       IF      WK-ERR            = SPACE
       THEN
         MOVE  "C"               TO    EDIT-CURSOR OF ENDYMD
                                                   OF D20020D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR021"          TO    WK-NO
       END-IF
       MOVE    "R"               TO    EDIT-COLOR  OF ENDYMD
                                                   OF D20020D1
     ELSE
       IF      ENDYMD OF D20020D1    NOT = ZERO
       THEN
         IF    ENDYMD OF D20020D1(1:2)  >=  90
         THEN
           MOVE  19              TO    WK-ENDYMD(1:2)
         ELSE
           MOVE  20              TO    WK-ENDYMD(1:2)
         END-IF
         MOVE    ENDYMD OF D20020D1
                                 TO    WK-ENDYMD(3:6)
*
         MOVE    WK-ENDYMD       TO    WK-KEY-YMD
         PERFORM                 CALM-READ-SEC
         IF        SW-INV        = "INV"
         THEN
*                                < ｶﾚﾝﾀﾞﾏｽﾀ ﾆ ｿﾝｻﾞｲ ｼﾏｾﾝ >
           IF      WK-ERR        = SPACE
           THEN
             MOVE  "C"           TO    EDIT-CURSOR OF ENDYMD
                                                   OF D20020D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR022"      TO    WK-NO
           END-IF
           MOVE    "R"           TO    EDIT-COLOR  OF ENDYMD
                                                   OF D20020D1
           MOVE    ZERO          TO    WK-ENDYMD
         END-IF
       END-IF
     END-IF.
*
*    単体チェックでエラーがある場合は処理を抜ける
     IF    WK-ERR = "ERR"
     THEN
       GO  TO        CHECK5-999
     END-IF.
*
*    作業コードが新規の場合指示済チェックを行う
     IF    SGYCD OF D20020D1(4:1)  =  ZERO
     THEN
       PERFORM                   UNIT-CHK-SEC
     END-IF.
 CHECK5-999.
     EXIT.
/*****************************************************************
*    ユニット指示済チェック処理
******************************************************************
 UNIT-CHK-SEC                    SECTION.
 UNIT-CHK-010.
*
     PERFORM    VARYING  IX1     FROM  1  BY  1
                UNTIL    IX1     >     10
*
         IF  SENTAK OF D20020D1(IX1) = "1"
         THEN
*          新規処理時
           IF      WK-SYRKBN         =  1
           THEN
             IF    T-SJIKBN(IX1 IX2) = "1"  OR  "2"
             THEN
               IF  WK-ERR            =  SPACE
               THEN
*                                < ｽﾃﾞﾆ ｼｼﾞ ｻﾚﾃｲﾏｽ >
                 MOVE  "ERR"     TO    WK-ERR
                 MOVE  "ERR016"  TO    WK-NO
                 MOVE  "C"       TO    EDIT-CURSOR OF SENTAK
                                            OF D20020D1 (IX1)
               END-IF
               MOVE    "R"       TO    EDIT-COLOR  OF SENTAK
                                            OF D20020D1 (IX1)
             END-IF
           END-IF
*
*          取消処理時
           IF    WK-SYRKBN           = 2
           THEN
             EVALUATE  T-SJIKBN (IX1 IX2)
                 WHEN  "1"
                     IF    WK-ERR    = SPACE
                     THEN
*                                < ｶﾝｾｲﾋﾝﾃﾞ ｼｼﾞ ｻﾚﾃｲﾏｽ >
                       MOVE "ERR"    TO    WK-ERR
                       MOVE "ERR017" TO    WK-NO
                       MOVE "C"      TO    EDIT-CURSOR OF SENTAK
                                             OF D20020D1 (IX1)
                     END-IF
                     MOVE   "R"      TO    EDIT-COLOR  OF SENTAK
                                             OF D20020D1 (IX1)
                 WHEN  "2"
                       CONTINUE
                 WHEN  OTHER
                     IF    WK-ERR    =     SPACE
                     THEN
*                                < ﾏﾀﾞ ｼｼﾞ ｻﾚﾃｲﾏｾﾝ >
                       MOVE "ERR"    TO    WK-ERR
                       MOVE "ERR018" TO    WK-NO
                       MOVE "C"      TO    EDIT-CURSOR OF SENTAK
                                                OF D20020D1 (IX1)
                     END-IF
                     MOVE   "R"      TO    EDIT-COLOR  OF SENTAK
                                                OF D20020D1 (IX1)
             END-EVALUATE
           END-IF
         END-IF
     END-PERFORM.
 UNIT-CHK-999.
     EXIT.
/*****************************************************************
*    ＩＤＸ設定処理
******************************************************************
 IDX-SET-SEC                     SECTION.
 IDX-SET-010.
*
     EVALUATE    SGYCD OF D20020D1
         WHEN    WK-BKN-CD
                 MOVE  1         TO    IX2
         WHEN    WK-BKN-HCD
                 MOVE  2         TO    IX2
         WHEN    WK-TSO-CD
                 MOVE  3         TO    IX2
         WHEN    WK-TSO-HCD
                 MOVE  4         TO    IX2
         WHEN    WK-AEN-CD
                 MOVE  5         TO    IX2
         WHEN    WK-AEN-HCD
                 MOVE  6         TO    IX2
         WHEN    WK-KMI-CD
                 MOVE  7         TO    IX2
         WHEN    WK-KMI-HCD
                 MOVE  8         TO    IX2
     END-EVALUATE.
 IDX-SET-999.
     EXIT.
/*****************************************************************
*    ファイル出力処理（新規／修正／削除）
******************************************************************
 FILE-UPD-SEC                    SECTION.
 FILE-UPD-010.
*
*    発番ファイルの更新
     PERFORM                     HATM-UPD-SEC.
*    作業指示ファイルの出力
     PERFORM                     SJIF-OUT-SEC.
*
*    ユニット管理ファイル更新
     PERFORM                     IDX-SET-SEC.
     PERFORM   VARYING     IX1   FROM  1   BY 1
               UNTIL       IX1   > 10
*
         IF    SENTAK OF D20020D1(IX1)    =  1
         THEN
           PERFORM               UNIF-UPD-SEC
         END-IF
     END-PERFORM.
 FILE-UPD-999.
     EXIT.
/*****************************************************************
*    発番ファイル更新処理
******************************************************************
 HATM-UPD-SEC                    SECTION.
 HATM-UPD-010.
*
*  発番ファイルの更新（連番１更新）
     PERFORM                     HATM-READ-SEC.
     COMPUTE  WK-RENBAN =  RENBAN OF AHATML1  +   1.
*
     IF       WK-RENBAN >  RJOGEN OF AHATML1
     THEN
       MOVE  RKAGEN OF AHATML1   TO    RENBAN OF AHATML1
                                       WK-RENBAN
     ELSE
       MOVE  WK-RENBAN           TO    RENBAN OF AHATML1
     END-IF.
*
     MOVE    SYS-YMD-RE          TO    UPDDAY OF AHATML1.
     ACCEPT  SYS-HMS   FROM  TIME.
     MOVE    SYS-HMS(1:6)        TO    UPDTIM OF AHATML1.
     MOVE    DSP-WSID            TO    WSID   OF AHATML1.

     REWRITE   AHATFD  OF AHATML1.
     EVALUATE  ST-AHATML
         WHEN  "00"
               ADD   1           TO    CNT-HAT
         WHEN  OTHER
               MOVE  "AHATML1"   TO    WK-FILE
               MOVE  "REWRITE"   TO    WK-SYORI
               MOVE  "43"        TO    WK-KEY1
               MOVE  HATUCD OF AHATML1
                                 TO    WK-KEY2
               MOVE  ST-AHATML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 HATM-UPD-999.
     EXIT.
/*****************************************************************
*    作業指示ファイル出力処理（WRITE)
******************************************************************
 SJIF-OUT-SEC                    SECTION.
 SJIF-OUT-010.
*
     INITIALIZE                  CSJIFD OF CSJIFL1.
*
     MOVE    WK-RENBAN           TO    SIJINO OF CSJIFL1.
     MOVE    WK-SEIBAN           TO    SEIBAN OF CSJIFL1.
     MOVE    KMKNO OF D20020D1   TO    KOMOKU OF CSJIFL1.
     MOVE    WK-SYRKBN           TO    SIJIKB OF CSJIFL1.
     MOVE    "2"                 TO    WRKKBN OF CSJIFL1.
*
     IF      WK-SYRKBN           =     2
     THEN
       MOVE  SJIKBN OF D20020D1  TO    THAKOF OF CSJIFL1
     ELSE
       MOVE  SPACE               TO    THAKOF OF CSJIFL1
     END-IF.
     MOVE    SGYCD OF D20020D1   TO    WORKCD OF CSJIFL1.
     MOVE    SKBCD OF D20020D1   TO    SJIOFC OF CSJIFL1.
     MOVE    WK-ENDYMD           TO    KYOTEI OF CSJIFL1.
*
     MOVE    ZERO                TO    IX3.
     PERFORM   VARYING    IX1    FROM    1     BY  1
               UNTIL      IX1            >     10
*
       IF      SENTAK OF D20020D1(IX1) = 1
       THEN
         ADD   1                 TO    IX3
         MOVE  T-UNITCD (IX1)    TO    UNITCD OF CSJIFL1(IX3)
*        新規登録で出荷済みの場合は出荷状況に”１”たてる
         IF  ( T-SYUKZM (IX1) NOT =    ZERO ) AND
             ( WK-SYRKBN          =    1    )
         THEN
           MOVE    "1"           TO    SYUJYO OF CSJIFL1(IX3)
         END-IF
       END-IF
     END-PERFORM.
*
     MOVE    SYS-YMD-RE          TO    SIJDAY OF CSJIFL1.
     MOVE    SYS-YMD-RE          TO    CRTDAY OF CSJIFL1.
     MOVE    SYS-YMD-RE          TO    UPDDAY OF CSJIFL1.
     ACCEPT  SYS-HMS             FROM  TIME.
     MOVE    SYS-HMS(1:6)        TO    UPDTIM OF CSJIFL1.
     MOVE    DSP-WSID            TO    WSID   OF CSJIFL1.
*
     WRITE     CSJIFD  OF CSJIFL1.
     EVALUATE  ST-CSJIFL
         WHEN  "00"
               ADD   1           TO    CNT-SJI
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "CSJIFL1"   TO    WK-FILE
               MOVE  "WRITE"     TO    WK-SYORI
               MOVE  SIJINO OF CSJIFL1
                                 TO    WK-KEY1
               MOVE  WK-SEIBAN   TO    WK-KEY2
               MOVE  WK-KOMOKU   TO    WK-KEY3
               MOVE  ST-CSJIFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SJIF-OUT-999.
     EXIT.
/*****************************************************************
*    ユニット管理ファイル更新処理（REWRITE)
******************************************************************
 UNIF-UPD-SEC                    SECTION.
 UNIF-UPD-010.
*
     MOVE    "="                 TO    WK-KEY-POINT.
     MOVE    T-UNITCD(IX1)       TO    WK-UNITCD.
     PERFORM                     UNIF-STR-SEC.
     PERFORM                     UNIF-NEXT-SEC.
*
     EVALUATE  WK-SYRKBN
         WHEN  1
               MOVE  "2"         TO    SJIKBN OF CUNIFL1(IX2)
               MOVE  SKBCD  OF D20020D1
                                 TO    SJIOFC OF CUNIFL1(IX2)
               MOVE  WK-ENDYMD   TO    WYOTEI OF CUNIFL1(IX2)
         WHEN  2
               MOVE  SPACE       TO    SJIKBN OF CUNIFL1(IX2)
               MOVE  SPACE       TO    SJIOFC OF CUNIFL1(IX2)
               MOVE  ZERO        TO    WYOTEI OF CUNIFL1(IX2)
     END-EVALUATE.
*
     MOVE    SYS-YMD-RE          TO    UPDDAY OF CUNIFL1.
     ACCEPT  SYS-HMS             FROM  TIME.
     MOVE    SYS-HMS(1:6)        TO    UPDTIM OF CUNIFL1.
     MOVE    DSP-WSID            TO    WSID   OF CUNIFL1.
*
     REWRITE   CUNIFD  OF  CUNIFL1.
     EVALUATE  ST-CUNIFL
         WHEN  "00"
               ADD   1           TO    CNT-UNI2
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "CUNIFL1"   TO    WK-FILE
               MOVE  "REWRITE"   TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-KOMOKU   TO    WK-KEY2
               MOVE  UNITCD OF   CUNIFL1
                                 TO    WK-KEY3
               MOVE  ST-CUNIFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 UNIF-UPD-999.
     EXIT.
/*****************************************************************
*    運用条件ファイル　ＲＥＡＤ処理(RAN)
******************************************************************
 JKNM-READ-SEC                   SECTION.
 JKNM-READ-010.
*
     MOVE    "0"                 TO    JKNKBN OF AJKNML1.
     READ    AJKNML1.
*
     EVALUATE  ST-AJKNML
         WHEN  "00"
               CONTINUE
         WHEN  OTHER
               MOVE  "AJKNML "   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  "0"         TO    WK-KEY1
               MOVE  ST-AJKNML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JKNM-READ-999.
     EXIT.
/*****************************************************************
*    ユニット管理ファイル　ＳＴＡＲＴ処理(START)
******************************************************************
 UNIF-STR-SEC                    SECTION.
 UNIF-STR-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  SEIBAN OF CUNIFL1
                                 KOMOKU OF CUNIFL1
                                 UNITCD OF CUNIFL1.
     MOVE    WK-SEIBAN           TO    SEIBAN OF CUNIFL1.
     MOVE    WK-KOMOKU           TO    KOMOKU OF CUNIFL1.
     MOVE    WK-UNITCD           TO    UNITCD OF CUNIFL1.
*
     EVALUATE  WK-KEY-POINT
        WHEN   ">="
               START   CUNIFL1  KEY IS >=  SEIBAN OF CUNIFL1
                                           KOMOKU OF CUNIFL1
                                           UNITCD OF CUNIFL1
        WHEN   "="
               START   CUNIFL1  KEY IS  =  SEIBAN OF CUNIFL1
                                           KOMOKU OF CUNIFL1
                                           UNITCD OF CUNIFL1
     END-EVALUATE.
     EVALUATE  ST-CUNIFL
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CUNIFL1"   TO    WK-FILE
               MOVE  "START"     TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-KOMOKU   TO    WK-KEY2
               MOVE  UNITCD OF CUNIFL1
                                 TO    WK-KEY3
               MOVE  ST-CUNIFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 UNIF-STR-999.
     EXIT.
/*****************************************************************
*    ユニット管理ファイル　ＮＥＸＴ処理(NEXT)
******************************************************************
 UNIF-NEXT-SEC                   SECTION.
 UNIF-NEXT-010.
*
     MOVE    SPACE               TO    SW-INV.
*
     READ    CUNIFL1  NEXT.
     EVALUATE  ST-CUNIFL
         WHEN  "00"
               CONTINUE
         WHEN  "10"
               MOVE  "END"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CUNIFL1"   TO    WK-FILE
               MOVE  "NEXT"      TO    WK-SYORI
               MOVE  SEIBAN OF CUNIFL1
                                 TO    WK-KEY1
               MOVE  KOMOKU OF CUNIFL1
                                 TO    WK-KEY2
               MOVE  UNITCD OF CUNIFL1
                                 TO    WK-KEY3
               MOVE  ST-CUNIFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 UNIF-NEXT-999.
     EXIT.
/*****************************************************************
*    受注ファイル（鑑）　ＲＥＡＤ処理 (RAN)
******************************************************************
 JUGF-READ-SEC                   SECTION.
 JUGF-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
*    MOVE    SPACE               TO    SEIBAN OF AJUGFL1.
*
     MOVE    WK-SEIBAN           TO    SEIBAN OF AJUGFL1.
     READ    AJUGFL1.
*
     EVALUATE  ST-AJUGFL
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "AJUGFL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  ST-AJUGFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JUGF-READ-999.
     EXIT.
/*****************************************************************
*    組織マスタ　　　　　ＲＥＡＤ処理 (RAN)
******************************************************************
 SOSM-READ-SEC                   SECTION.
 SOSM-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  SOSICD OF ASOSML1.
*
     MOVE    WK-SOSICD           TO    SOSICD OF ASOSML1.
     READ    ASOSML1.
*
     EVALUATE  ST-ASOSML
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "ASOSML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-SOSICD   TO    WK-KEY1
               MOVE  ST-ASOSML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SOSM-READ-999.
     EXIT.
/*****************************************************************
*    名称マスタ　ＲＥＡＤ処理 (RAN)
******************************************************************
 NAMM-READ-SEC                   SECTION.
 NAMM-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  NAMKBN OF ANAMML1
                                 NAMCD  OF ANAMML1.
*
     MOVE    "41"                TO    NAMKBN OF ANAMML1.
     MOVE    T-UNITCD(IX1)       TO    NAMCD  OF ANAMML1.
     READ    ANAMML1.
*
     EVALUATE  ST-ANAMML
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "ANAMML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  "41"        TO    WK-KEY1
               MOVE  T-UNITCD(IX1)
                                 TO    WK-KEY2
               MOVE  ST-ANAMML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 NAMM-READ-999.
     EXIT.
/*****************************************************************
*    仕様マスタ　　　　　ＲＥＡＤ処理 (RAN)
******************************************************************
 SIYM-READ-SEC                   SECTION.
 SIYM-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  SIYOCD OF ASIYML1.
*
     MOVE    WK-SIYOU            TO    SIYOCD OF ASIYML1.
     READ    ASIYML1.
*
     EVALUATE  ST-ASIYML
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "ASIYML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-SIYOU    TO    WK-KEY1
               MOVE  ST-ASIYML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SIYM-READ-999.
     EXIT.
/*****************************************************************
*    受注項目ファイル（項目）ＳＴＡＲＴ処理(START)
******************************************************************
 JUKF-STR-SEC                    SECTION.
 JUKF-STR-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  SEIBAN OF AJUKFL1
                                 JYUKOU OF AJUKFL1.
*
     MOVE    WK-SEIBAN           TO    SEIBAN OF AJUKFL1.
     MOVE    WK-JYUKOU           TO    JYUKOU OF AJUKFL1.
     EVALUATE  WK-KEY-POINT
         WHEN  "= "
               START  AJUKFL1    KEY IS  = SEIBAN OF AJUKFL1
                                           JYUKOU OF AJUKFL1
         WHEN  ">="
               START  AJUKFL1    KEY IS >= SEIBAN OF AJUKFL1
                                           JYUKOU OF AJUKFL1
     END-EVALUATE.
*
     EVALUATE  ST-AJUKFL
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "AJUKFL1"   TO    WK-FILE
               MOVE  "START"     TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-JYUKOU   TO    WK-KEY2
               MOVE  ST-AJUKFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JUKF-STR-999.
     EXIT.
/*****************************************************************
*    受注項目ファイル（項目）ＲＥＡＤ処理(NEXT)
******************************************************************
 JUKF-NEXT-SEC                   SECTION.
 JUKF-NEXT-010.
*
     MOVE    SPACE               TO    SW-INV.
     READ    AJUKFL1  NEXT.
*
     EVALUATE  ST-AJUKFL
         WHEN  "00"
               CONTINUE
         WHEN  "10"
               MOVE  "END"       TO    SW-INV
         WHEN  OTHER
               MOVE  "AJUKFL1"   TO    WK-FILE
               MOVE  "NEXT"      TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-JYUKOU   TO    WK-KEY2
               MOVE  ST-AJUKFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JUKF-NEXT-999.
     EXIT.
/*****************************************************************
*    作業マスタＲＥＡＤ処理(RAN)
******************************************************************
 SAGM-READ-SEC                   SECTION.
 SAGM-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  WORKCD OF CSAGML1.
     MOVE    WK-WORKCD           TO    WORKCD OF CSAGML1.
     READ    CSAGML1.
*
     EVALUATE  ST-CSAGML
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CSAGML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-WORKCD   TO    WK-KEY1
               MOVE  ST-CSAGML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SAGM-READ-999.
     EXIT.
/*****************************************************************
*    カレンダマスタＲＥＡＤ処理(RAN)
******************************************************************
 CALM-READ-SEC                   SECTION.
 CALM-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  YMD   OF CCALML1.
     MOVE    WK-KEY-YMD          TO    YMD    OF CCALML1.
     READ    CCALML1.
*
     EVALUATE  ST-CCALML
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CCALML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-KEY-YMD  TO    WK-KEY1
               MOVE  ST-CCALML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 CALM-READ-999.
     EXIT.
/*****************************************************************
*    発番ファイルＲＥＡＤ処理(RANDOM)
******************************************************************
 HATM-READ-SEC                   SECTION.
 HATM-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  HATKBN OF AHATML1
                                 HATUCD OF AHATML1.
*
     MOVE    "41"                TO    HATKBN OF AHATML1.
     MOVE    "000000"            TO    HATUCD OF AHATML1.
     READ    AHATML1.
     EVALUATE  ST-AHATML
         WHEN  "00"
               CONTINUE
         WHEN  OTHER
               MOVE  "AHATML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  "41"        TO    WK-KEY1
               MOVE  "000000"    TO    WK-KEY2
               MOVE  ST-AHATML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 HATM-READ-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群２）
******************************************************************
 ATR-CLR2-SEC                     SECTION.
 ATR-CLR2-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SJIKBN OF D20020D1
                             EDIT-COLOR  OF SEIBAN OF D20020D1
                             EDIT-COLOR  OF KMKNO  OF D20020D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SJIKBN OF D20020D1
                             EDIT-CURSOR OF SEIBAN OF D20020D1
                             EDIT-CURSOR OF KMKNO  OF D20020D1.
 ATR-CLR2-999.
     EXIT.
******************************************************************
*    アトリビュートクリア処理（項目群４）
******************************************************************
 ATR-CLR4-SEC                     SECTION.
 ATR-CLR4-010.
*
     PERFORM    VARYING    IX1  FROM  1  BY  1
                UNTIL      IX1  >     10
*
         MOVE  "M"     TO  EDIT-COLOR  OF SENTAK OF D20020D1 (IX1)
         MOVE  SPACE   TO  EDIT-CURSOR OF SENTAK OF D20020D1 (IX1)
     END-PERFORM.
 ATR-CLR4-999.
     EXIT.
******************************************************************
*    アトリビュートクリア処理（項目群５）
******************************************************************
 ATR-CLR5-SEC                     SECTION.
 ATR-CLR5-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SGYCD  OF D20020D1
                             EDIT-COLOR  OF SKBCD  OF D20020D1
                             EDIT-COLOR  OF ENDYMD OF D20020D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SGYCD  OF D20020D1
                             EDIT-CURSOR OF SKBCD  OF D20020D1
                             EDIT-CURSOR OF ENDYMD OF D20020D1.
 ATR-CLR5-999.
     EXIT.
/*****************************************************************
*    表示ファイル入力処理
******************************************************************
 DSP-READ-SEC                    SECTION.
 DSP-READ-010.
     READ      DSP-F.
     IF        DSP-STATUS        NOT =   "00"
     THEN
       MOVE    DSP-STATUS        TO    WK-STATUS
       MOVE    "DSP-F"           TO    WK-FILE
       MOVE    "READ"            TO    WK-SYORI
       PERFORM ABEND-SEC
     END-IF.
*
*  トランザクション開始
     CALL     "XMROTSTR".
     MOVE     "STR"              TO    TRN-STR-FLG.
 DSP-READ-999.
     EXIT.
/*****************************************************************
*    メッセージ検索処理
******************************************************************
 MSG-SEARCH-SEC                  SECTION.
 MSG-SEARCH-010.
*
*  メッセージ
     PERFORM   VARYING   IX-MSG  FROM    1   BY  1
               UNTIL     IX-MSG  >      30
       IF      WK-NO  =  WK-MSGNO(IX-MSG)
       THEN
         MOVE  WK-MSGNM(IX-MSG)  TO    WK-MESSAGE
         MOVE  99                TO    IX-MSG
       END-IF
     END-PERFORM.
*
*  ガイドメッセージ
     PERFORM   VARYING   IX-MSG  FROM    1   BY  1
               UNTIL     IX-MSG  >       2
       IF      WK-GUID = WK-GIDNO(IX-MSG)
       THEN
         MOVE  WK-GIDNM(IX-MSG)  TO    WK-GAIDO
         MOVE  99                TO    IX-MSG
       END-IF
     END-PERFORM.
 MSG-SEARCH-999.
     EXIT.
/*****************************************************************
*    表示ファイル出力処理　　
******************************************************************
 DSP-WRITE-SEC                   SECTION.
 DSP-WRITE-010.
*
     IF      TRN-STR-FLG   = "STR"
     THEN
*      トランザクション終了
        CALL     "XMROTEND"
        MOVE     SPACE           TO    TRN-STR-FLG
     END-IF.
*
     PERFORM                     MSG-SEARCH-SEC.
*
     MOVE    WK-MESSAGE          TO    MSG    OF D20020D1.
     MOVE    WK-GAIDO            TO    GIDMSG OF D20020D1.
     MOVE    "D20020D1"          TO    DSP-FORMAT.
     MOVE    SPACE               TO    DSP-MODE.
     MOVE    "SCREEN"            TO    DSP-GROUP.
*
     WRITE   D20020D1.
     IF      DSP-STATUS  NOT =  "00"
     THEN
       MOVE  DSP-STATUS          TO    WK-STATUS
       MOVE  "DSP-F"             TO    WK-FILE
       MOVE  "WRITE"             TO    WK-SYORI
       PERFORM                   ABEND-SEC
     END-IF.
 DSP-WRITE-999.
     EXIT.
/*****************************************************************
*    ＡＢＥＮＤ処理
******************************************************************
 ABEND-SEC                       SECTION.
 ABEND-010.
*
     DISPLAY "*****  " WK-FILE  " " WK-SYORI "  ERR  *****"
                                                     UPON    DSP.
     IF      WK-SYORI  =      "OPEN"
     THEN
       CONTINUE
     ELSE
       DISPLAY "*               KEY1   = "  WK-KEY1           "*"
                                                     UPON    DSP
       DISPLAY "*               KEY2   = "  WK-KEY2           "*"
                                                     UPON    DSP
       DISPLAY "*               KEY3   = "  WK-KEY3           "*"
                                                     UPON    DSP
     END-IF.
*
     DISPLAY "*               F-STS  = "  WK-STATUS  "       *"
                                                     UPON    DSP.
     DISPLAY "***** " WK-PGMID " " WK-VER "  ABEND *****"
                                                     UPON    DSP.
     COMPUTE PROGRAM-STATUS  =   4000    +   WK-STATUS-Q.
*
*  トランザクションキャンセル
     CALL     "XMROTCNL".
*
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20020PO.
