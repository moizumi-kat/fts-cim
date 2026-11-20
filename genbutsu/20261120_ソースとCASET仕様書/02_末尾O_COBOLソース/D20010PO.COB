*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２００１０ＰＯ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　画面から作業指示の情報を入力することにより、
*                   作業指示ファイルに作業指示発行データを作成し
*                   作業実績ファイルの指示情報を更新する(新規)
*
*                   画面から取消作業指示の情報を入力することに
*                   より、作業指示ファイルに取消作業指示発行
*                   データを作成し作業実績ファイルの指示情報を
*                   クリアする                          (取消)
*
*                                               作成日：93.03.01
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  受注ファイル（鑑）　　　　　<AJUGFL1  >
*                   受注ファイル（項目）　　  　<AJUKFL1  >
*                   原価ファイル（項目）        <AGEKFL1  >
*                   組織マスタ                  <ASOSML1  >
*                   仕様マスタ                  <ASIYML1  >
*                   作業マスタ                  <CSAGML1  >
*                   運用条件ファイル            <AJKNML1  >
*                   カレンダマスタ              <CCALML1  >
*                   作業実績ファイル            <CJISFL1  >
*                   発番ファイル                <AHATML1  >
*                   ユニット管理ファイル        <CUNIFL1  >
*                   作業指示ファイル            <CSJIFL1  >
*
* ＊＊＊　画面情報　　　＊＊＊
*  SMED NAME    ：　作業指示入力画面    　　　　<DSP-F    >
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20010PO.
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
*    作業指示入力画面
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
*    原価ファイル（項目）
     SELECT      AGEKFL1    ASSIGN       TO DA-VI-AGEKFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF AGEKFL1
                                            KOMOKU OF AGEKFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AGEKFL.
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
*    運用条件ファイル
     SELECT      AJKNML1    ASSIGN       TO DA-VI-AJKNML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JKNKBN OF AJKNML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AJKNML.
*    カレンダマスタ
     SELECT      CCALML1    ASSIGN       TO DA-VI-CCALML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS YMD    OF CCALML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CCALML.
*    作業実績ファイル
     SELECT      CJISFL1    ASSIGN       TO DA-VI-CJISFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF CJISFL1
                                            KOMOKU OF CJISFL1
                                            WORKCD OF CJISFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CJISFL.
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
*    作業指示入力画面
******************************************************************
 FD  DSP-F.
     COPY        D20010D1   OF   XMDLIB.
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
*    原価ファイル（項目）
******************************************************************
 FD  AGEKFL1.
     COPY        AGEKFL1    OF   XFDLIB.
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
*    運用条件ファイル
******************************************************************
 FD  AJKNML1.
     COPY        AJKNML1    OF   XFDLIB.
******************************************************************
*    カレンダマスタ
******************************************************************
 FD  CCALML1.
     COPY        CCALML1    OF   XFDLIB.
******************************************************************
*    作業実績ファイル
******************************************************************
 FD  CJISFL1.
     COPY        CJISFL1    OF   XFDLIB.
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
     COPY        CSJIFL1    OF  XFDLIB.
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
     03  ST-AGEKFL               PIC  X(002).
     03  ST-ASOSML               PIC  X(002).
     03  ST-ASIYML               PIC  X(002).
     03  ST-CSAGML               PIC  X(002).
     03  ST-AJKNML               PIC  X(002).
     03  ST-CCALML               PIC  X(002).
     03  ST-CJISFL               PIC  X(002).
     03  ST-AHATML               PIC  X(002).
     03  ST-CUNIFL               PIC  X(002).
     03  ST-CSJIFL               PIC  X(002).
 01  WK-SAVE.
     03  WK-VAL-SAVE.
         05  WK-SYRKBN           PIC  9(001).
         05  WK-SEIBAN           PIC  X(006).
         05  WK-SJIKBN           PIC  9(001).
*
         05  WK-BKN-CD           PIC  X(004).
         05  WK-SKA-CD           PIC  X(004).
         05  WK-TSO-CD           PIC  X(004).
         05  WK-TSO-HCD          PIC  X(004).
         05  WK-KMI-CD           PIC  X(004).
         05  WK-KMI-HCD          PIC  X(004).
         05  WK-BZI-CD           PIC  X(004).
         05  WK-BZI-HCD          PIC  X(004).
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
         05  CNT-JIS             PIC  9(006).
         05  CNT-JIS2            PIC  9(006).
         05  CNT-HAT             PIC  9(006).
         05  CNT-UNI             PIC  9(006).
         05  CNT-SJI             PIC  9(006).
         05  CNT-SJI2            PIC  9(006).
     03  TRN-FLG.
         05  TRN-STR-FLG         PIC  X(003).
*    ワーク領域
 01  WORK-AREA.
     03  WK-SAVE-AREA.
         05  WK-SOSICD           PIC  X(004).
         05  WK-SIYOU            PIC  X(002).
         05  WK-JYUKOU           PIC  9(004).
         05  WK-KOMOKU           PIC  9(004).
         05  WK-WORKCD           PIC  X(004).
         05  WK-KEY-POINT        PIC  X(002).
         05  WK-TAIHI            PIC  9(008)V9(02).
         05  WK-TSO-SUU          PIC  9(004)V9(01).
         05  WK-KMI-SUU          PIC  9(004)V9(01).
         05  WK-KMK-SUU          PIC  9(004).
         05  WK-SGYCD            PIC  X(004).
         05  WK-SGYSTR           PIC  9(008).
         05  WK-SGYEND           PIC  9(008).
         05  WK-RENBAN           PIC  9(007).
         05  WK-JCD              PIC  X(004).
         05  WK-KEY-YMD          PIC  9(008).
         05  WK-SEQNO            PIC  9(002).
         05  WK-KMK-ERR          PIC  9(004).
     03  WK-UNIINF-AREA.
         05  WK-UNIINF           OCCURS 10.
             07  WK-UNITCD       PIC  X(004).
             07  WK-SJIFLG       PIC  X(001).
             07  WK-SAGJYO       PIC  X(001).
             07  WK-SYUJYO       PIC  X(001).
         05  WK-WYOTEI           PIC  9(008).
         05  WK-WKANBI           PIC  9(008).
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
         05  SW-INIT             PIC  X(001).
*    メッセージ
     03  WK-NO                   PIC  X(006).
     03  WK-GUID                 PIC  X(006).
     03  WK-MESSAGE              PIC  N(038).
     03  WK-GAIDO                PIC  N(038).
*    添字
     03  IX-MSG                  PIC  9(003).
     03  IX1                     PIC  9(002).
     03  IX2                     PIC  9(002).
     03  IX3                     PIC  9(002).
     03  IX4                     PIC  9(002).
     03  IX-T1                   PIC  9(001).
     03  IX-T2                   PIC  9(002).
*
     03  WK-CHECK.
         05  WK-ERR              PIC  X(003).
*    テーブル
     03  TBL-AREA-X.
         05  TBL-AREA            OCCURS 30.
             07  T-JSK-FLG       PIC  X(001).
             07  T-KMK-ERR       PIC  9(004).
             07  T-KMK-STR       PIC  9(004).
             07  T-KMK-END       PIC  9(004).
             07  T-TSO-SUU       PIC  9(004)V9(01).
             07  T-KMI-SUU       PIC  9(004)V9(01).
             07  T-KMK-SUU       PIC  9(004).
         05  TBL-ALL-FLG         PIC  X(003).
         05  TBL-ERR-FLG         PIC  X(003).
         05  TBL-CHK-FLG         PIC  X(001).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20010PO".
 01  WK-VER                      PIC  X(007) VALUE "V01/L01".
*    メッセージ
 01  VALUE-AREA.
   02  WK-MSG-X.
     03  WK-MSG-R.
         05  WK-MSGNO001         PIC  X(006) VALUE "MSG001".
         05  WK-MSGNM001         PIC  N(038) VALUE
             NC"処理区分を入力して下さい．".
         05  WK-MSGNO003         PIC  X(006) VALUE "MSG002".
         05  WK-MSGNM003         PIC  N(038) VALUE
             NC"取消指示書発行、製番を入力して下さい．".
         05  WK-MSGNO002         PIC  X(006) VALUE "MSG003".
         05  WK-MSGNM002         PIC  N(038) VALUE
             NC"製番を入力して下さい．".
         05  WK-MSGNO004         PIC  X(006) VALUE "MSG004".
         05  WK-MSGNM004         PIC  N(038) VALUE
             NC"項目指定を入力して下さい．".
         05  WK-MSGNO005         PIC  X(006) VALUE "MSG005".
         05  WK-MSGNM005         PIC  N(038) VALUE
             NC"ＳＥＱを入力して下さい．".
         05  WK-MSGNO006         PIC  X(006) VALUE "MSG006".
         05  WK-MSGNM006         PIC  N(038) VALUE
             NC"指示項目を入力して下さい．".
         05  WK-MSGNO007         PIC  X(006) VALUE "MSG007".
         05  WK-MSGNM007         PIC  N(038) VALUE
             NC"作業コード～指示工数を入力して下さい．".
         05  WK-MSGNO008         PIC  X(006) VALUE "MSG008".
         05  WK-MSGNM008         PIC  N(038) VALUE
             NC"ファイルを更新します．確認して下さい．".
         05  WK-MSGNO009         PIC  X(006) VALUE "MSG009".
         05  WK-MSGNM009         PIC  N(038) VALUE
             NC"指示項目を取消します．確認して下さい．".
         05  WK-MSGNO010         PIC  X(006) VALUE "ERR001".
         05  WK-MSGNM010         PIC  N(038) VALUE
             NC"処理区分が未入力です．".
         05  WK-MSGNO011         PIC  X(006) VALUE "ERR002".
         05  WK-MSGNM011         PIC  N(038) VALUE
             NC"処理区分が存在しません．".
         05  WK-MSGNO012         PIC  X(006) VALUE "ERR003".
         05  WK-MSGNM012         PIC  N(038) VALUE
             NC"取消指示書発行区分が未入力です．".
         05  WK-MSGNO013         PIC  X(006) VALUE "ERR004".
         05  WK-MSGNM013         PIC  N(038) VALUE
             NC"取消指示書発行区分が存在しません．".
         05  WK-MSGNO014         PIC  X(006) VALUE "ERR005".
         05  WK-MSGNM014         PIC  N(038) VALUE
             NC"製番が未入力です．".
         05  WK-MSGNO015         PIC  X(006) VALUE "ERR006".
         05  WK-MSGNM015         PIC  N(038) VALUE
             NC"製番が受注ファイルに存在しません．".
         05  WK-MSGNO016         PIC  X(006) VALUE "ERR007".
         05  WK-MSGNM016         PIC  N(038) VALUE
             NC"製番が受注取消になっています．".
         05  WK-MSGNO017         PIC  X(006) VALUE "ERR008".
         05  WK-MSGNM017         PIC  N(038) VALUE
             NC"項目指定が未入力です．".
         05  WK-MSGNO018         PIC  X(006) VALUE "ERR009".
         05  WK-MSGNM018         PIC  N(038) VALUE
             NC"項目指定が存在しません．".
         05  WK-MSGNO019         PIC  X(006) VALUE "ERR010".
         05  WK-MSGNM019         PIC  N(038) VALUE
             NC"指示項目の追加はこれ以上できません．".
         05  WK-MSGNO020         PIC  X(006) VALUE "ERR011".
         05  WK-MSGNM020         PIC  N(038) VALUE
             NC"修正または取消を選択して下さい．".
         05  WK-MSGNO021         PIC  X(006) VALUE "ERR012".
         05  WK-MSGNM021         PIC  N(038) VALUE
             NC"ＳＥＱが未入力です．".
         05  WK-MSGNO022         PIC  X(006) VALUE "ERR013".
         05  WK-MSGNM022         PIC  N(038) VALUE
             NC"ＳＥＱには１～３０の値を入力して下さい．".
         05  WK-MSGNO023         PIC  X(006) VALUE "ERR014".
         05  WK-MSGNM023         PIC  N(038) VALUE
             NC"ＳＥＱに対する指示項目が存在しません．".
         05  WK-MSGNO024         PIC  X(006) VALUE "ERR015".
         05  WK-MSGNM024         PIC  N(038) VALUE
             NC"指示項目が未入力です．".
         05  WK-MSGNO025         PIC  X(006) VALUE "ERR017".
         05  WK-MSGNM025         PIC  N(038) VALUE
             NC"開始指示項目が終了指示項目の値を越えています．".
         05  WK-MSGNO026         PIC  X(006) VALUE "ERR018".
         05  WK-MSGNM026         PIC  N(038) VALUE
             NC"指示項目が重複しています．".
         05  WK-MSGNO027         PIC  X(006) VALUE "ERR019".
         05  WK-MSGNM027         PIC  N(038) VALUE
             NC"指示項目が受注ファイルに存在しません．".
         05  WK-MSGNO028         PIC  X(006) VALUE "ERR020".
         05  WK-MSGNM028         PIC  N(038) VALUE
             NC"指示項目が受注取消になっています．".
         05  WK-MSGNO029         PIC  X(006) VALUE "ERR021".
         05  WK-MSGNM029         PIC  N(038) VALUE
             NC"既に指示されています．".
         05  WK-MSGNO030         PIC  X(006) VALUE "ERR022".
         05  WK-MSGNM030         PIC  N(038) VALUE
             NC"未だ指示されていません．".
         05  WK-MSGNO031         PIC  X(006) VALUE "ERR023".
         05  WK-MSGNM031         PIC  N(038) VALUE
             NC"実績済になっています．".
         05  WK-MSGNO032         PIC  X(006) VALUE "ERR024".
         05  WK-MSGNM032         PIC  N(038) VALUE
             NC"作業コードが未入力です．".
         05  WK-MSGNO033         PIC  X(006) VALUE "ERR025".
         05  WK-MSGNM033         PIC  N(038) VALUE
             NC"生産の作業コードではありません．".
         05  WK-MSGNO034         PIC  X(006) VALUE "ERR026".
         05  WK-MSGNM034         PIC  N(038) VALUE
             NC"作業コードが作業マスタに存在しません．".
         05  WK-MSGNO035         PIC  X(006) VALUE "ERR027".
         05  WK-MSGNM035         PIC  N(038) VALUE
             NC"作業期間が未入力です．".
         05  WK-MSGNO036         PIC  X(006) VALUE "ERR028".
         05  WK-MSGNM036         PIC  N(038) VALUE
             NC"カレンダマスタに存在しません．".
         05  WK-MSGNO037         PIC  X(006) VALUE "ERR029".
         05  WK-MSGNM037         PIC  N(038) VALUE
             NC"着手予定日が完了予定日を越えています．".
         05  WK-MSGNO038         PIC  X(006) VALUE "ERR030".
         05  WK-MSGNM038         PIC  N(038) VALUE
             NC"職場コードが未入力です．".
         05  WK-MSGNO039         PIC  X(006) VALUE "ERR031".
         05  WK-MSGNM039         PIC  N(038) VALUE
             NC"職場コードが組織マスタに存在しません．".
         05  WK-MSGNO040         PIC  X(006) VALUE "ERR032".
         05  WK-MSGNM040         PIC  N(038) VALUE
             NC"評価係数に不当な値が入力されました．".
         05  WK-MSGNO041         PIC  X(006) VALUE "ERR033".
         05  WK-MSGNM041         PIC  N(038) VALUE
             NC"指示工数は按分できないため入力できません．".
         05  WK-MSGNO042         PIC  X(006) VALUE "ERR034".
         05  WK-MSGNM042         PIC  N(038) VALUE
             NC"指示項目がありません．".
         05  WK-MSGNO043         PIC  X(006) VALUE "ERR035".
         05  WK-MSGNM043         PIC  N(038) VALUE
             NC"ＰＦキーエラーです．".
*
   02  WK-MSG-X-R                REDEFINES   WK-MSG-X.
     03  WK-MSG                  OCCURS  43.
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
         05  WK-GIDNO002         PIC  X(006) VALUE "GID002".
         05  WK-GIDNM002         PIC  N(038) VALUE
             NC"ＥＮＴ：入力　ＰＦ５：前項目　ＰＦ６：次項目".
         05  WK-GIDNO003         PIC  X(006) VALUE "GID003".
         05  WK-GIDNM003         PIC  N(038) VALUE
             NC"ＥＮＴ：入力　ＰＦ５：前項目".
*
   02  WK-GID-X-R                REDEFINES   WK-GID-X.
     03  WK-GID                  OCCURS   3.
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
     DISPLAY "*      CJISFL1  UPD    = "  CNT-JIS        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CJISFL1  OUT    = "  CNT-JIS2       "   *"
                                                     UPON    DSP.
     DISPLAY "*      AHATML1  UPD    = "  CNT-HAT        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CUNIFL1  UPD    = "  CNT-UNI        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CSJIFL1  UPD    = "  CNT-SJI        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CSJIFL1  OUT    = "  CNT-SJI2       "   *"
                                                     UPON    DSP.
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
     INITIALIZE                  ST-AREA  WK-SAVE  WORK-AREA
                                 DSP-AREA.
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN         I-O            DSP-F.
     OPEN         INPUT          AJUGFL1  AJUKFL1  AGEKFL1
                                 ASOSML1  ASIYML1  CSAGML1
                                 AJKNML1  CCALML1.
     OPEN         I-O            CJISFL1  AHATML1  CUNIFL1
                                 CSJIFL1.
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
     CALL     "XMROTSTR".
*
*  運用条件ファイル読込み(塗装コード．組立コード取得）
     PERFORM                     JKNM-READ-SEC.
     MOVE    JCD15  OF AJKNML1   TO    WK-TSO-CD.
     MOVE    JCD16  OF AJKNML1   TO    WK-TSO-HCD.
     MOVE    JCD19  OF AJKNML1   TO    WK-KMI-CD.
     MOVE    JCD20  OF AJKNML1   TO    WK-KMI-HCD.
     MOVE    JCD21  OF AJKNML1   TO    WK-BZI-CD.
     MOVE    JCD22  OF AJKNML1   TO    WK-BZI-HCD.
*
     MOVE    JCD13  OF AJKNML1   TO    WK-BKN-CD.
     MOVE    JCD23  OF AJKNML1   TO    WK-SKA-CD.
*
*  トランザクションEND
     CALL     "XMROTEND".
 INIT-999.
     EXIT.
/*****************************************************************
*    主　処　理
******************************************************************
 MAIN-SEC                        SECTION.
 MAIN-010.
*  初期画面表示
     MOVE    SPACE               TO    D20010D1.
     INITIALIZE                  D20010D1.
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
*              トランザクションEND
                CALL     "XMROTEND"
               GO   TO           MAIN-999
         WHEN  OTHER
*                                < PFｷｰｴﾗｰ >
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-020
     END-EVALUATE.
*
 MAIN-030.
     EVALUATE  WK-SYRKBN
         WHEN  1
               GO  TO    MAIN-050
         WHEN  2
               GO  TO    MAIN-040
     END-EVALUATE.
*
 MAIN-040.
*                                < ﾊｯｺｳｸﾌﾞﾝ/ｾｲﾊﾞﾝ ｦ ﾆｭｳﾘｮｸｼﾃｸﾀﾞｻｲ>
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG002"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-045.
*  取消指示書発行区分
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP002"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK2-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-045
               ELSE
*              項目指定／評価係数に初期値設定
                 MOVE  1         TO    KSTKBN OF D20010D1
                 MOVE  6         TO    KEISUU OF D20010D1
                 GO   TO         MAIN-060
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR2-SEC
               MOVE   ZERO       TO    SJIKBN OF D20010D1
               MOVE   SPACE      TO    SEIBAN OF D20010D1
                                       KENMEI OF D20010D1
                                       TANTOU OF D20010D1
                                       SIYOU1 OF D20010D1
                                       SIYOU2 OF D20010D1
               GO   TO           MAIN-015
         WHEN  OTHER
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-045
     END-EVALUATE.
*
 MAIN-050.
*                                < ｾｲﾊﾞﾝ ﾆｭｳﾘﾖｸ ﾖｳｷｭｳ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG003"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-055.
*  製番入力
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP003"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK2-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-055
               ELSE
*              項目指定／評価係数に初期値設定
                 MOVE  1         TO    KSTKBN OF D20010D1
                 MOVE  6         TO    KEISUU OF D20010D1
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR3-SEC
               MOVE   SPACE      TO    SEIBAN OF D20010D1
                                       KENMEI OF D20010D1
                                       TANTOU OF D20010D1
                                       SIYOU1 OF D20010D1
                                       SIYOU2 OF D20010D1
               GO   TO           MAIN-015
         WHEN  OTHER
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-055
     END-EVALUATE.
*
 MAIN-060.
*                                < ｺｳﾓｸｼﾃｲｦ ﾆｭｳﾘｮｸ ｼﾃｸﾀﾞｻｲ >
     MOVE    "GID002"            TO    WK-GUID.
     MOVE    "MSG004"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-065.
*  項目指定
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
                 GO   TO         MAIN-065
               ELSE
                 EVALUATE  KSTKBN OF D20010D1
                     WHEN  1
                           GO  TO    MAIN-080
                     WHEN  2
                           IF  SEQNO OF D20010D1 = ZERO
                           THEN
                             GO  TO  MAIN-070
                           ELSE
                             GO  TO  MAIN-080
                           END-IF
                     WHEN  3
                           IF  SEQNO OF D20010D1 = ZERO
                           THEN
                             GO  TO  MAIN-070
                           ELSE
                             GO  TO  MAIN-100
                           END-IF
                 END-EVALUATE
               END-IF
         WHEN  "F005"
               INITIALIZE        WK-SAVE-AREA
                                 TBL-AREA-X
               MOVE  SPACE       TO    D20010D1
               INITIALIZE        D20010D1
               MOVE  WK-SYRKBN   TO    SYRKBN OF D20010D1
               MOVE  WK-SEIBAN   TO    SEIBAN OF D20010D1
               MOVE  WK-SJIKBN   TO    SJIKBN OF D20010D1
               PERFORM           MEISAI-SET-SEC
               PERFORM           ATR-CLR4-SEC
               PERFORM           ATR-CLR6-SEC
               EVALUATE  WK-SYRKBN
                   WHEN  1
                         GO  TO  MAIN-050
                   WHEN  2
                         MOVE  "C"     TO    EDIT-CURSOR OF SEIBAN
                                                  OF D20010D1
                         GO  TO  MAIN-040
               END-EVALUATE
         WHEN  "F006"
               PERFORM           ATR-CLR4-SEC
               PERFORM           ZERO-CHK-SEC
               IF  WK-NO         = "ERR034"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO    TO        MAIN-085
               ELSE
                 GO    TO        MAIN-090
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-065
     END-EVALUATE.
*
 MAIN-070.
*                                < SEQ ｦ ﾆｭｳﾘｮｸ ｼﾃ ｸﾀﾞｻｲ >
     MOVE    "GID002"            TO    WK-GUID.
     MOVE    "MSG005"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-075.
*  ＳＥＱ入力
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP005"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK5-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-075
               ELSE
                 EVALUATE  KSTKBN OF D20010D1
                     WHEN  2
                           GO  TO    MAIN-080
                     WHEN  3
                           GO  TO    MAIN-100
                 END-EVALUATE
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR5-SEC
               IF    TBL-ERR-FLG = SPACE
               THEN
                 MOVE  SPACE     TO    WK-ERR
                 MOVE  ZERO      TO    SEQNO  OF D20010D1
                                       SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
                                       ERRKMK OF D20010D1
               END-IF
               GO   TO           MAIN-060
         WHEN  "F006"
               PERFORM           ATR-CLR5-SEC
               PERFORM           ZERO-CHK-SEC
               IF  WK-NO         = "ERR034"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-085
               ELSE
                 GO   TO         MAIN-090
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-075
     END-EVALUATE.
*
 MAIN-080.
*                                < ｼｼﾞｺｳﾓｸ ｦ ﾆｭｳﾘｮｸ ｼﾃ ｸﾀﾞｻｲ >
     MOVE    "GID002"            TO    WK-GUID.
     MOVE    "MSG006"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-085.
* 指示項目入力
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP006"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK6-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 IF  TBL-ERR-FLG =   "ERR"
                 THEN
                   IF  TBL-ALL-FLG  = "ALL"
                   THEN
                     MOVE  SPACE TO    TBL-ALL-FLG
                   END-IF
                   PERFORM       KMKERR-SET-SEC
*                  新規入力で指示／実績エラー時チェック
                   MOVE  SEQNO   OF D20010D1    TO    IX1
                                                      WK-SEQNO
                   PERFORM       IDX-SET-SEC
*
                   IF  KAISI  OF D20010D1(IX-T1 IX-T2) = ZERO
                   THEN
                     MOVE  1     TO    KSTKBN OF D20010D1
                     MOVE  ZERO  TO    SEQNO  OF D20010D1
                     MOVE  ZERO  TO    T-KMK-ERR(IX1)
                                       T-KMK-STR(IX1)
                                       T-KMK-END(IX1)
                     MOVE  SPACE TO    T-JSK-FLG(IX1)
                                       TBL-ERR-FLG
                   END-IF
                 END-IF
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-085
               ELSE
                 IF  TBL-ALL-FLG =   "ALL"
                 THEN
                   GO TO         MAIN-090
                 ELSE
                   EVALUATE  KSTKBN OF D20010D1
                       WHEN  1
                             IF    T-KMK-STR(30) NOT = ZERO
                             THEN
                               GO  TO  MAIN-090
                             ELSE
                               GO  TO  MAIN-080
                             END-IF
                       WHEN  2
                             MOVE  ZERO  TO    SEQNO  OF D20010D1
                                               SIJIFR OF D20010D1
                                               SIJIBY OF D20010D1
                             GO  TO    MAIN-070
                   END-EVALUATE
                 END-IF
               END-IF
         WHEN  "F005"
               IF    TBL-ERR-FLG   =    SPACE
               THEN
                 PERFORM         KMKERR-SET-SEC
                 IF    ERRKMK OF D20010D1 = ZERO
                 THEN
                   PERFORM       ATR-CLR6-SEC
                   MOVE  SPACE   TO    WK-ERR
                   MOVE  ZERO    TO    SEQNO  OF D20010D1
                                       SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
                                       ERRKMK OF D20010D1
                 END-IF
               ELSE
                 IF  SEQNO  OF D20010D1 = ZERO
                 THEN
                   MOVE  WK-SEQNO             TO    IX1
                 ELSE
                   MOVE  SEQNO  OF D20010D1   TO    IX1
                 END-IF
                 PERFORM         IDX-SET-SEC
*
                 IF  KAISI  OF D20010D1(IX-T1 IX-T2) = ZERO
                 THEN
                   MOVE  ZERO    TO    T-KMK-ERR(IX1)
                                       T-KMK-STR(IX1)
                                       T-KMK-END(IX1)
                                       SEQNO  OF D20010D1
                                       SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
                                       ERRKMK OF D20010D1
                   MOVE  SPACE   TO    T-JSK-FLG(IX1)
                                       TBL-ERR-FLG
                   MOVE  1       TO    KSTKBN OF D20010D1
                 ELSE
                   IF    T-KMK-ERR(IX1) = ZERO
                   THEN
                     MOVE  ZERO  TO    ERRKMK OF D20010D1
                                       SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
                                       SEQNO  OF D20010D1
                     MOVE  SPACE TO    T-JSK-FLG(IX1)
                     PERFORM     ATR-CLR6-SEC
                   ELSE
                     MOVE  T-KMK-ERR(IX1)
                                 TO    ERRKMK OF D20010D1
                     MOVE  T-KMK-STR(IX1)
                                 TO    SIJIFR OF D20010D1
                     MOVE  T-KMK-END(IX1)
                                 TO    SIJIBY OF D20010D1
                   END-IF
                 END-IF
               END-IF
               GO   TO           MAIN-060
         WHEN  "F006"
               PERFORM           ATR-CLR6-SEC
               PERFORM           ZERO-CHK-SEC
               IF  WK-NO         =   "ERR034"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO    TO        MAIN-085
               ELSE
                 GO    TO        MAIN-090
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-085
     END-EVALUATE.
*
 MAIN-090.
*                                < ｻｷﾞｮｳｺｰﾄﾞ ｶﾗ ｼｼﾞｺｳｽｳｦ ﾆｭｳﾘｮｸ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG007"            TO    WK-NO.
* 作業コードが入力済みなら標準工数合計を出力する
     IF  SGYCD  OF D20010D1  NOT =     ZERO
     THEN
       PERFORM                   KSUKEI-SET-SEC
     END-IF.
     PERFORM                     DSP-WRITE-SEC.
*
* 入力前の作業コードをＷＫへ退避
     MOVE    SGYCD  OF D20010D1  TO    WK-SGYCD.
*
 MAIN-095.
* 作業コードから指示工数入力
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP007"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK7-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 IF  TBL-ERR-FLG =   "ERR"
                 THEN
                   PERFORM       KMKERR-SET-SEC
                   IF  ERRKMK OF D20010D1  = ZERO
                   THEN
                     GO   TO     MAIN-100
                   ELSE
                     PERFORM     DSP-WRITE-SEC
                     GO   TO     MAIN-085
                   END-IF
                 ELSE
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-095
                 END-IF
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR7-SEC
               IF    WK-SGYCD    NOT = SGYCD  OF D20010D1
               THEN
                 MOVE  SPACE     TO    SGYNM  OF D20010D1
                 MOVE  SPACE     TO    TBL-CHK-FLG
                                       TBL-ERR-FLG
                 PERFORM  VARYING  IX1  FROM  1  BY  1
                          UNTIL  ( IX1  >  30            ) OR
                                 ( T-KMK-STR(IX1) = ZERO )
*
                     MOVE  SPACE TO    T-JSK-FLG(IX1)
                     MOVE  ZERO  TO    T-KMK-ERR(IX1)
                 END-PERFORM
               END-IF
               IF    TBL-ALL-FLG  =    "ALL"
               THEN
                 MOVE  1         TO    KSTKBN OF D20010D1
                 MOVE  ZERO      TO    SEQNO  OF D20010D1
                                       SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
                                       KAISI  OF D20010D1(1 1)
                                       SYURYO OF D20010D1(1 1)
                                       KSUKEI OF D20010D1
                                       T-KMK-STR         (1)
                                       T-KMK-END         (1)
                 MOVE  SPACE     TO    TBL-ALL-FLG
                                       TBL-ERR-FLG
                                       TBL-CHK-FLG
                                       T-JSK-FLG         (1)
               END-IF
               GO  TO  MAIN-060
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR035"    TO    WK-NO
               MOVE  "ERR"       TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-095
     END-EVALUATE.
*
 MAIN-100.
     IF      KSTKBN OF D20010D1  =     3
     THEN
*                                < ｼｼﾞｺｳﾓｸ ｦ ﾄﾘｹｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
       MOVE    "MSG009"          TO    WK-NO
     ELSE
*                                < ﾌｧｲﾙ ｦ ｺｳｼﾝｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
       MOVE    "MSG008"          TO    WK-NO
     END-IF.
     MOVE      "GID003"          TO    WK-GUID.
     MOVE      SPACE             TO    DUMMY.
     PERFORM                     DSP-WRITE-SEC.
*
 MAIN-105.
*  ダミー　入力
     MOVE    "NE"                TO  DSP-MODE.
     MOVE    "GRP008"            TO  DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               IF    KSTKBN OF D20010D1 =  3
*             項目取消処理を行う
               THEN
                 PERFORM         KMK-DEL-SEC
                 PERFORM         KMKERR-SET-SEC
                 IF  ERRKMK OF   D20010D1 = ZERO
                 THEN
*                 テーブルに明細０件の場合項目指定を行う
                   IF   KAISI OF D20010D1 (1 1) = ZERO
                   THEN
                     MOVE  1     TO    KSTKBN OF D20010D1
                     MOVE  ZERO  TO    SEQNO  OF D20010D1
                     GO    TO    MAIN-060
                   ELSE
                     GO    TO    MAIN-070
                   END-IF
                 ELSE
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-085
                 END-IF
*             ファイル更新処理を行う
               ELSE
                 PERFORM         FILE-UPD-SEC
                 MOVE  ZERO      TO    SJKSUU OF D20010D1
                                       KSUKEI OF D20010D1
                 MOVE  SPACE     TO    SGYCD  OF D20010D1
                                       SKBCD  OF D20010D1
                                       SGYNM  OF D20010D1
                                       SKBNM  OF D20010D1
                 MOVE  6         TO    KEISUU OF D20010D1
                 MOVE  SPACE     TO    TBL-CHK-FLG
                 GO    TO        MAIN-090
               END-IF
         WHEN  "F005"
               IF      KSTKBN OF D20010D1  =     3
               THEN
                 IF    T-JSK-FLG (SEQNO OF D20010D1) = SPACE
                 THEN
                   GO  TO        MAIN-070
                 ELSE
                   GO  TO        MAIN-060
                 END-IF
               ELSE
                 GO    TO        MAIN-090
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE    "ERR035"  TO    WK-NO
               MOVE    "ERR"     TO    WK-ERR
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-105
     END-EVALUATE.
 MAIN-999.
     EXIT.
/*****************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       AJUGFL1  AJUKFL1  AGEKFL1
                                 ASOSML1  ASIYML1  CSAGML1
                                 AJKNML1  CCALML1  CJISFL1
                                 AHATML1  CUNIFL1  CSJIFL1
                                 DSP-F.
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
     IF         ST-AGEKFL        NOT =   "00"
     THEN
       MOVE    "AGEKFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AGEKFL        TO    WK-STATUS
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
     IF         ST-AJKNML        NOT =   "00"
     THEN
       MOVE    "AJKNML1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-AJKNML        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CCALML        NOT =   "00"
     THEN
       MOVE    "CCALML "         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CJISFL        TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CJISFL        NOT =   "00"
     THEN
       MOVE    "CJISFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CJISFL        TO    WK-STATUS
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
                                                   OF D20010D1.
     MOVE    SPACE               TO    EDIT-CURSOR OF SYRKBN
                                                   OF D20010D1.
*
     IF        SYRKBN OF D20010D1 =    ZERO
     THEN
*                                < ｼｮﾘｸﾌﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "R"               TO    EDIT-COLOR OF SYRKBN
                                                  OF D20010D1
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR001"          TO    WK-NO
     ELSE
       IF      SYRKBN OF D20010D1 =    1  OR  2
       THEN
         IF    SYRKBN OF D20010D1 =    1
         THEN
           MOVE  ZERO            TO    SJIKBN OF D20010D1
         END-IF
         MOVE SYRKBN OF D20010D1 TO    WK-SYRKBN
       ELSE
*                                < ｼｮﾘｸﾌﾞﾝ ｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE  "R"               TO    EDIT-COLOR OF SYRKBN
                                                  OF D20010D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR002"          TO    WK-NO
       END-IF
     END-IF.
 CHECK1-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ２処理　　－　取消指示書発行区分・製番　－
******************************************************************
 CHECK2-SEC                      SECTION.
 CHECK2-010.
*
     INITIALIZE                  WK-ERR.
     EVALUATE  WK-SYRKBN
         WHEN  1
               PERFORM           ATR-CLR3-SEC
               MOVE ZERO         TO    WK-SJIKBN
               GO   TO           CHECK2-020
         WHEN  2
               PERFORM           ATR-CLR2-SEC
     END-EVALUATE.
*
*  取消指示書発行区分チェック
     IF      SJIKBN OF D20010D1  =     ZERO
     THEN
*                                < ﾊｯｺｳ ｸﾌﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR003"          TO    WK-NO
     ELSE
       IF    SJIKBN OF D20010D1  =     1  OR  2
       THEN
         MOVE SJIKBN OF D20010D1 TO    WK-SJIKBN
       ELSE
*                                < ﾊｯｺｳ ｸﾌﾞﾝｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR004"          TO    WK-NO
       END-IF
     END-IF.
*
     IF         WK-ERR           =     "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF SJIKBN
                                                   OF D20010D1
       MOVE    "C"               TO    EDIT-CURSOR OF SJIKBN
                                                   OF D20010D1
     END-IF.
*
 CHECK2-020.
*  製番
     IF      SEIBAN OF D20010D1  =     SPACE
     THEN
*                                < ｾｲﾊﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       IF      WK-ERR            =     SPACE
       THEN
         MOVE    "C"             TO    EDIT-CURSOR OF SEIBAN
                                                   OF D20010D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR005"        TO    WK-NO
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20010D1
     ELSE
*      受注ファイル（鑑）へ既存チェックを行う
       MOVE  SEIBAN OF D20010D1  TO    WK-SEIBAN
       PERFORM                   JUGF-READ-SEC
       IF      SW-INV            =    "INV"
       THEN
*                                < ｾｲﾊﾞﾝｶﾞ ｼﾞｭﾁｭｳFﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
         IF      WK-ERR          =     SPACE
         THEN
           MOVE    "C"           TO    EDIT-CURSOR OF SEIBAN
                                                   OF D20010D1
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "ERR006"      TO    WK-NO
         END-IF
         MOVE      "R"           TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20010D1
       ELSE
         IF   ( DELFLG OF AJUGFL1   =  "1" )  AND
              ( SYRKBN OF D20010D1  =  "1" )
         THEN
*                                < ｾｲﾊﾞﾝｶﾞ ｼﾞｭﾁｭｳﾄﾘｹｼ ﾆ ﾅｯﾃｲﾙ >
           IF      WK-ERR        =     SPACE
           THEN
             MOVE    "C"         TO    EDIT-CURSOR OF SEIBAN
                                                   OF D20010D1
             MOVE    "ERR"       TO    WK-ERR
             MOVE    "ERR007"    TO    WK-NO
           END-IF
           MOVE      "R"         TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20010D1
         ELSE
           MOVE    SEIBAN OF D20010D1
                                 TO    WK-SEIBAN
*         受注ファイルチェックＯＫで件名他　出力項目取得
           PERFORM               MEISAI-SET-SEC
         END-IF
       END-IF
     END-IF.
 CHECK2-999.
     EXIT.
/*****************************************************************
*    明細セット処理（製番入力後セットされる項目）
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
*
*  件名（受注ファイル（鑑）より）
     MOVE    KENMEI OF AJUGFL1   TO    KENMEI OF D20010D1.
*
*  担当名（組織マスタより）
     MOVE    SOSICD OF AJUGFL1   TO    WK-SOSICD.
     PERFORM                     SOSM-READ-SEC.
     IF      SW-INV        =    "INV"
     THEN
       MOVE    SPACE             TO    TANTOU OF D20010D1
     ELSE
       MOVE    TANNAM OF ASOSML1 TO    TANTOU OF D20010D1
     END-IF.
*
*  仕様１（仕様マスタより）
     MOVE    SIYOU1 OF AJUGFL1   TO    WK-SIYOU.
     PERFORM                     SIYM-READ-SEC.
     IF      SW-INV        =    "INV"
     THEN
       MOVE    SPACE             TO    SIYOU1 OF D20010D1
     ELSE
       MOVE    SIYONA OF ASIYML1 TO    SIYOU1 OF D20010D1
     END-IF.
*  仕様２（仕様マスタより）
     MOVE    SIYOU2 OF AJUGFL1   TO    WK-SIYOU.
     PERFORM                     SIYM-READ-SEC.
     IF      SW-INV        =    "INV"
     THEN
       MOVE    SPACE             TO    SIYOU2 OF D20010D1
     ELSE
       MOVE    SIYONA OF ASIYML1 TO    SIYOU2 OF D20010D1
     END-IF.
*
 MEISAI-SET-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ４処理　　－　項目指定　－
******************************************************************
 CHECK4-SEC                      SECTION.
 CHECK4-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR4-SEC.
*
     IF      KSTKBN OF D20010D1  =     ZERO
     THEN
*                                < ｺｳﾓｸ ｼﾃｲｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR008"          TO    WK-NO
       MOVE    "R"               TO    EDIT-COLOR  OF KSTKBN
                                                   OF D20010D1
     ELSE
       IF    KSTKBN OF D20010D1  =    1  OR  2  OR  3
       THEN
*        指示実績フラグ="1"または"2"の時　追加処理はエラー
         PERFORM  VARYING  IX1  FROM  1  BY  1
                  UNTIL    IX1  > 30
             IF  ( T-JSK-FLG(IX1)      = "1")   OR
                 ( T-JSK-FLG(IX1)      = "2")   OR
                 ( T-JSK-FLG(IX1)      = "3")
             THEN
               MOVE T-KMK-STR(IX1) TO    SIJIFR OF D20010D1
               MOVE T-KMK-END(IX1) TO    SIJIBY OF D20010D1
               MOVE T-KMK-ERR(IX1) TO    ERRKMK OF D20010D1
               MOVE IX1            TO    SEQNO  OF D20010D1
               MOVE "R"            TO    EDIT-COLOR  OF SIJIFR
                                                     OF D20010D1
                                         EDIT-COLOR  OF SIJIBY
                                                     OF D20010D1
                                         EDIT-COLOR  OF ERRKMK
                                                     OF D20010D1
               IF  KSTKBN OF D20010D1  =  1
*                                < ｼｭｳｾｲ ﾏﾀﾊ ﾄﾘｹｼ ｦ ｾﾝﾀｸｼﾃ ｸﾀﾞｻｲ >
                 MOVE  "ERR"       TO    WK-ERR
                 MOVE  "ERR011"    TO    WK-NO
               END-IF
               MOVE     30         TO    IX1
             END-IF
         END-PERFORM
*
*       追加時にテーブルが３０件フル入力時エラー
         IF  ( KSTKBN OF D20010D1   =      1 )  AND
             ( T-KMK-STR(30)  NOT   =   ZERO )
         THEN
*                                < ｼｼﾞｺｳﾓｸﾉ ﾂｲｶﾊ ｺﾚｲｼﾞｮｳ ﾃﾞｷﾏｾﾝ >
           IF    WK-ERR  =  SPACE
           THEN
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR010"      TO    WK-NO
             MOVE  "R"           TO    EDIT-COLOR  OF KSTKBN
                                                   OF D20010D1
           END-IF
         END-IF
       ELSE
*                                < ｺｳﾓｸｼﾃｲｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR009"        TO    WK-NO
         MOVE    "R"             TO    EDIT-COLOR  OF KSTKBN
                                                   OF D20010D1
       END-IF
     END-IF.
*
 CHECK4-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ５処理　　－　ＳＥＱ　－
******************************************************************
 CHECK5-SEC                      SECTION.
 CHECK5-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR5-SEC.
*
     IF      SEQNO  OF D20010D1  =     ZERO
     THEN
*                                < SEQ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR012"          TO    WK-NO
     ELSE
       IF  ( SEQNO OF D20010D1   >=   1  )    AND
           ( SEQNO OF D20010D1   <=   30 )
       THEN
*        テーブルに指示項目が設定されていること
         MOVE  SEQNO OF D20010D1 TO    IX1
*
         IF    T-KMK-STR(IX1)     >    ZERO
         THEN
           MOVE  T-KMK-STR(IX1)  TO    SIJIFR OF D20010D1
           MOVE  T-KMK-END(IX1)  TO    SIJIBY OF D20010D1
         ELSE
*                                < SEQ ﾆ ﾀｲｽﾙ ｼｼﾞｺｳﾓｸｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ>
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR014"        TO    WK-NO
           MOVE  30              TO    IX1
         END-IF
       ELSE
*                                < SEQ ﾆﾊ 1～30 ｦ ﾆｭｳﾘｮｸｼﾃｸﾀﾞｻｲ>
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR013"        TO    WK-NO
       END-IF
     END-IF.
*
     IF        WK-ERR   =   "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF SEQNO
                                                   OF D20010D1
       MOVE    "C"               TO    EDIT-CURSOR OF SEQNO
                                                   OF D20010D1
     END-IF.
 CHECK5-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ６処理　　－　指示項目　－
******************************************************************
 CHECK6-SEC                      SECTION.
 CHECK6-010.
*
     INITIALIZE                  WK-ERR  TBL-ERR-FLG.
     PERFORM                     ATR-CLR6-SEC.
     MOVE    ZERO                TO    ERRKMK OF D20010D1.
     MOVE    ZERO                TO    WK-TSO-SUU
                                       WK-KMI-SUU.
*
     IF      SIJIFR OF D20010D1  =     ZERO
     THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR015"          TO    WK-NO
     ELSE
       IF    SIJIBY OF D20010D1   =    ZERO
       THEN
         MOVE SIJIFR OF D20010D1 TO    SIJIBY OF D20010D1
       END-IF
*      不当値チェック
       IF    ( SIJIFR OF D20010D1  >=  1    )  AND
             ( SIJIBY OF D20010D1  <=  9999 )
       THEN
*        大小関係チェック
         IF    SIJIFR OF D20010D1  <=  SIJIBY OF D20010D1
         THEN
*
           PERFORM  VARYING  IX1   FROM  1  BY  1
                    UNTIL  ( IX1            >  30   )    OR
                           ( T-KMK-STR(IX1) =  ZERO )
*
               IF  ( KSTKBN OF D20010D1  =   2   )       AND
                   ( SEQNO  OF D20010D1  =   IX1 )
               THEN
                 CONTINUE
               ELSE
*                チェック１
                 IF   SIJIFR OF D20010D1 >  T-KMK-STR(IX1)  AND
                      SIJIFR OF D20010D1 <= T-KMK-END(IX1)
                 THEN
                   MOVE  SIJIFR OF D20010D1
                                 TO    ERRKMK OF D20010D1
                 ELSE
*                チェック２
                   IF   SIJIBY OF D20010D1 >  T-KMK-STR(IX1)  AND
                        SIJIBY OF D20010D1 <= T-KMK-END(IX1)
                   THEN
                     MOVE  T-KMK-STR(IX1)
                                 TO    ERRKMK OF D20010D1
                   ELSE
*                チェック３
                     IF   SIJIFR OF D20010D1 <  T-KMK-STR(IX1) AND
                          SIJIBY OF D20010D1 >= T-KMK-END(IX1)
                     THEN
                       MOVE  T-KMK-STR(IX1)
                                 TO    ERRKMK OF D20010D1
                     ELSE
*                チェック４
                       IF SIJIFR OF D20010D1 >  T-KMK-STR(IX1) AND
                          SIJIBY OF D20010D1 <= T-KMK-END(IX1)
                       THEN
                         MOVE  SIJIFR OF D20010D1
                                 TO    ERRKMK OF D20010D1
                       ELSE
*                チェック５
                         IF SIJIFR OF D20010D1 = T-KMK-STR(IX1) OR
                            SIJIFR OF D20010D1 = T-KMK-END(IX1)
                         THEN
                           MOVE  SIJIFR OF D20010D1
                                 TO    ERRKMK OF D20010D1
                         ELSE
                           IF  SIJIBY OF D20010D1
                                              = T-KMK-STR(IX1) OR
                               SIJIBY OF D20010D1 = T-KMK-END(IX1)
                           THEN
                             MOVE  SIJIBY OF D20010D1
                                 TO    ERRKMK OF D20010D1
                           END-IF
                         END-IF
                       END-IF
                     END-IF
                   END-IF
                 END-IF
                 IF  ERRKMK OF D20010D1 NOT = ZERO
                 THEN
*                                < ｼﾞｭｳﾌｸ ｼﾃｲﾏｽ >
                   MOVE "ERR"    TO    WK-ERR
                   MOVE "ERR018" TO    WK-NO
                   MOVE  30      TO    IX1
                 END-IF
               END-IF
           END-PERFORM
         ELSE
*                                < ｶｲｼｶﾞ ｼｭｳﾘｮｳ ｦ ｺｴﾃｲﾏｽ >
           MOVE  SIJIFR OF D20010D1
                                 TO    ERRKMK OF D20010D1
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR017"        TO    WK-NO
         END-IF
       END-IF
     END-IF.
*
     IF    WK-ERR   = "ERR"
     THEN
       IF  WK-NO    = "ERR015"
       THEN
         CONTINUE
       ELSE
         MOVE  "R"               TO    EDIT-COLOR  OF ERRKMK
                                                   OF D20010D1
       END-IF
*
       MOVE    "R"               TO    EDIT-COLOR  OF SIJIFR
                                                   OF D20010D1
                                       EDIT-COLOR  OF SIJIBY
                                                   OF D20010D1
       MOVE    "C"               TO    EDIT-CURSOR OF SIJIFR
                                                   OF D20010D1
       GO  TO       CHECK6-999
     END-IF.
*
*  受注Ｆ(項目)チェック＊指示項目　1～9999　　の場合
     IF  ( SIJIFR OF D20010D1    = 1       AND
           SIJIBY OF D20010D1    = 9999 )   OR
         ( TBL-ALL-FLG           = "ALL")
     THEN
       MOVE    "ALL"             TO    TBL-ALL-FLG
       MOVE    1                 TO    IX1
                                       WK-JYUKOU
       MOVE    SPACE             TO    SW-INIT
       MOVE    SPACE             TO    WK-ERR
*
       MOVE    ">="              TO    WK-KEY-POINT
       PERFORM                   JUKF-STR-SEC
       IF        SW-INV          =    "INV"
       THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｱﾘﾏｾﾝ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR034"        TO    WK-NO
         MOVE    1               TO    KSTKBN OF D20010D1
       ELSE
         PERFORM                 JUKF-NEXT-SEC
         PERFORM  UNTIL   ( SW-INV    = "END"             )   OR
                          ( WK-ERR    = "ERR"             )   OR
                          ( WK-SEIBAN < SEIBAN OF AJUKFL1 )
             MOVE  JYUKOU OF AJUKFL1     TO    WK-KOMOKU
             IF    DELFLG OF AJUKFL1 = "1"
             THEN
               CONTINUE
             ELSE
               IF  SW-INIT       =     SPACE
               THEN
                 MOVE  JYUKOU OF AJUKFL1
                                 TO    SIJIFR OF D20010D1
                 MOVE  "1"       TO    SW-INIT
               ELSE
                 MOVE  JYUKOU OF AJUKFL1
                                 TO    SIJIBY OF D20010D1
               END-IF
               PERFORM             SIJI-CHK-SEC
             END-IF
*
             IF    WK-ERR        =    "ERR"
             THEN
               INITIALIZE        WK-TSO-SUU  WK-KMI-SUU
                                 WK-KMK-SUU
             ELSE
               PERFORM  JUKF-NEXT-SEC
             END-IF
         END-PERFORM
*
         IF  WK-ERR              =    "ERR"
         THEN
           MOVE    1             TO    SIJIFR OF D20010D1
           MOVE    9999          TO    SIJIBY OF D20010D1
         END-IF
       END-IF
*
*  受注Ｆ(項目)チェック＊指示項目　1～9999以外の場合
     ELSE
       IF      KSTKBN OF D20010D1 = 1
       THEN
         PERFORM  VARYING  IX2   FROM  1  BY  1
                  UNTIL    IX2   >     30
             IF   T-KMK-STR(IX2) = ZERO
             THEN
               MOVE  IX2         TO    IX1
               MOVE  30          TO    IX2
             END-IF
         END-PERFORM
       ELSE
         MOVE  SEQNO OF D20010D1 TO    IX1
       END-IF
*
       MOVE  SPACE               TO    WK-ERR
       MOVE  SIJIFR OF D20010D1  TO    WK-JYUKOU
       MOVE  "="                 TO    WK-KEY-POINT
       PERFORM                   JUKF-STR-SEC
       IF    SW-INV    =   "INV"
       THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳﾌｧｲﾙﾆ ｿﾝｻﾞｲｼﾅｲ>
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR019"          TO    WK-NO
         MOVE  JYUKOU OF AJUKFL1 TO    ERRKMK OF D20010D1
       ELSE
         PERFORM                 JUKF-NEXT-SEC
*
         PERFORM  UNTIL  ( SW-INV    = "END" )             OR
                         ( WK-ERR    = "ERR" )             OR
                         ( WK-SEIBAN < SEIBAN OF AJUKFL1 ) OR
                         ( SIJIBY OF D20010D1 < JYUKOU OF AJUKFL1)
             MOVE  JYUKOU OF AJUKFL1     TO    WK-KOMOKU
             IF  ( DELFLG OF AJUKFL1   =  "1" )  AND
                 ( SYRKBN OF D20010D1  =  "1" )
             THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳﾄﾘｹｼﾆ ﾅｯﾃｲﾏｽ >
               MOVE  "ERR"       TO    WK-ERR
               MOVE  "ERR020"    TO    WK-NO
               MOVE  JYUKOU OF AJUKFL1
                                 TO    ERRKMK OF D20010D1
             ELSE
               PERFORM             SIJI-CHK-SEC
             END-IF
*
             IF    WK-ERR        =    "ERR"
             THEN
               INITIALIZE        WK-TSO-SUU  WK-KMI-SUU
                                 WK-KMK-SUU
             ELSE
               PERFORM  JUKF-NEXT-SEC
               COMPUTE  WK-JYUKOU = WK-JYUKOU + 1
*
               IF       WK-JYUKOU > SIJIBY OF D20010D1
               THEN
                 CONTINUE
               ELSE
                 IF       WK-JYUKOU = JYUKOU OF AJUKFL1
                 THEN
                   CONTINUE
                 ELSE
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳﾌｧｲﾙﾆ ｿﾝｻﾞｲｼﾅｲ>
                   MOVE  "ERR"     TO    WK-ERR
                   MOVE  "ERR019"  TO    WK-NO
                   MOVE  WK-JYUKOU TO    ERRKMK OF D20010D1
                 END-IF
               END-IF
             END-IF
         END-PERFORM
       END-IF
     END-IF.
*
     IF    WK-ERR        = "ERR"
     THEN
       IF  WK-NO         = "ERR034"
       THEN
         CONTINUE
       ELSE
         MOVE  "R"               TO    EDIT-COLOR  OF ERRKMK
                                                   OF D20010D1
       END-IF
*
       MOVE    "R"               TO    EDIT-COLOR  OF SIJIFR
                                                   OF D20010D1
                                       EDIT-COLOR  OF SIJIBY
                                                   OF D20010D1
       MOVE    "C"               TO    EDIT-CURSOR OF SIJIFR
                                                   OF D20010D1
       GO  TO  CHECK6-999
     END-IF.
*
     IF  T-JSK-FLG(IX1) = SPACE
     THEN
       MOVE    ZERO              TO    ERRKMK OF D20010D1
       MOVE    ZERO              TO    T-KMK-ERR(IX1)
     END-IF.
*
*    画面の添字算出処理
     PERFORM                     IDX-SET-SEC.
*
     MOVE  SIJIFR OF D20010D1  TO  KAISI  OF D20010D1(IX-T1 IX-T2)
                                   T-KMK-STR(IX1).
     MOVE  SIJIBY OF D20010D1  TO  SYURYO OF D20010D1(IX-T1 IX-T2)
                                   T-KMK-END(IX1).
     MOVE    WK-TSO-SUU          TO    T-TSO-SUU(IX1).
     MOVE    WK-KMI-SUU          TO    T-KMI-SUU(IX1).
     MOVE    WK-KMK-SUU          TO    T-KMK-SUU(IX1).
     INITIALIZE                  WK-TSO-SUU WK-KMI-SUU WK-KMK-SUU.
*
     IF  ( KSTKBN OF D20010D1    =     1     )   OR
         ( TBL-ALL-FLG           =     "ALL" )
     THEN
       MOVE    ZERO              TO    SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
     END-IF.
 CHECK6-999.
     EXIT.
/*****************************************************************
*    指示項目チェック処理（受注Ｆ(項目). 作業実績Ｆ）
******************************************************************
 SIJI-CHK-SEC                    SECTION.
 SIJI-CHK-010.
*
*    作業実績Ｆへのチェックを既に行っていて新規作業の場合
     IF  ( TBL-CHK-FLG             = "1"  )  AND
         ( SGYCD  OF D20010D1(4:1) = ZERO )
     THEN
       PERFORM                   JSK-CHK-SEC
     END-IF
*
*   塗装工数．組立工数サマリ
     COMPUTE  WK-TSO-SUU =  WK-TSO-SUU  +  THKOSU OF AJUKFL1.
     PERFORM                     GEKF-READ-SEC.
     IF       SW-INV     = "INV"
     THEN
       CONTINUE
     ELSE
       COMPUTE  WK-KMI-SUU =  WK-KMI-SUU  + IKMIKO  OF AGEKFL1(1)
     END-IF.
     ADD     1                   TO    WK-KMK-SUU.
 SIJI-CHK-999.
     EXIT.
/*****************************************************************
*    インデックス設定処理
******************************************************************
 IDX-SET-SEC                     SECTION.
 IDX-SET-010.
*
     IF    IX1  >=  1    AND     IX1  <= 10
     THEN
       MOVE    1                 TO    IX-T1
       MOVE    IX1               TO    IX-T2
     END-IF.
*
     IF    IX1  >=  11   AND     IX1  <= 20
     THEN
       MOVE    2                 TO    IX-T1
       COMPUTE IX-T2   = IX1  -  10
     END-IF.
*
     IF    IX1  >=  21   AND     IX1  <= 30
     THEN
       MOVE    3                 TO    IX-T1
       COMPUTE IX-T2   = IX1  -  20
     END-IF.
 IDX-SET-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ７処理　　－　作業コード～指示工数　－
******************************************************************
 CHECK7-SEC                      SECTION.
 CHECK7-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR7-SEC.
*
     IF      SGYCD  OF D20010D1  =     SPACE
     THEN
*                                < ｻｷﾞｮｳｺｰﾄﾞｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    SPACE             TO    SGYNM OF D20010D1
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR024"          TO    WK-NO
     ELSE
       IF  ( SGYCD  OF D20010D1  >=    WK-BKN-CD )  AND
           ( SGYCD  OF D20010D1  <     WK-SKA-CD )
       THEN
*        入力作業コードが作業マスタに存在すること
         MOVE  SGYCD OF D20010D1 TO    WK-WORKCD
         PERFORM                 SAGM-READ-SEC
         IF    SW-INV            =    "INV"
         THEN
*                                < ｻｷﾞｮｳﾏｽﾀ ﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           MOVE  SPACE           TO    SGYNM OF D20010D1
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR026"        TO    WK-NO
         ELSE
*        作業名
           MOVE  WNEI OF CSAGML1 TO    SGYNM OF D20010D1
         END-IF
       ELSE
*                                < ｾｲｻﾝﾉ ｻｷﾞｮｳｺｰﾄﾞ ﾃﾞﾊ ｱﾘﾏｾﾝ >
         MOVE    SPACE           TO    SGYNM OF D20010D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR025"        TO    WK-NO
       END-IF
     END-IF.
     IF     WK-ERR  =  "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF SGYCD
                                                   OF D20010D1
       MOVE    "C"               TO    EDIT-CURSOR OF SGYCD
                                                 OF D20010D1
     END-IF.
*
*  作業期間チェック
     MOVE    ZERO                TO    WK-SGYSTR
                                       WK-SGYEND.
*    カレンダマスタ実存日チェック(着手日)
     IF      SGYSTR OF D20010D1    NOT = ZERO
     THEN
       IF    SGYSTR OF D20010D1(1:2)  >=  90
       THEN
         MOVE    19              TO    WK-SGYSTR(1:2)
       ELSE
         MOVE    20              TO    WK-SGYSTR(1:2)
       END-IF
       MOVE  SGYSTR OF D20010D1  TO    WK-SGYSTR(3:6)
*
       MOVE  WK-SGYSTR           TO    WK-KEY-YMD
       PERFORM                   CALM-READ-SEC
       IF    SW-INV   =  "INV"
       THEN
*                                < ｶﾚﾝﾀﾞﾏｽﾀ ﾆ ｿﾝｻﾞｲ ｼﾏｾﾝ >
         IF  WK-ERR   =  SPACE
         THEN
           MOVE  "C"             TO    EDIT-CURSOR OF SGYSTR
                                                   OF D20010D1
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR028"        TO    WK-NO
         END-IF
         MOVE    "R"             TO    EDIT-COLOR  OF SGYSTR
                                                   OF D20010D1
       END-IF
     END-IF.
*
*    未入力チェック（完了日）
     IF  ( SGYEND OF D20010D1 = ZERO ) AND
         ( WK-SYRKBN          = 1    )
     THEN
*                                < ｻｷﾞｮｳｷｶﾝｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       IF      WK-ERR  =  SPACE
       THEN
         MOVE  "C"               TO    EDIT-CURSOR OF SGYEND
                                                   OF D20010D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR027"          TO    WK-NO
       END-IF
       MOVE    "R"               TO    EDIT-COLOR  OF SGYEND
                                                   OF D20010D1
     END-IF.
*
*    カレンダマスタ実存日チェック(完了日)
     IF    SGYEND OF D20010D1      NOT = ZERO
     THEN
       IF    SGYEND OF D20010D1(1:2)  >=  90
       THEN
         MOVE  19                TO    WK-SGYEND(1:2)
       ELSE
         MOVE  20                TO    WK-SGYEND(1:2)
       END-IF
       MOVE  SGYEND OF D20010D1  TO    WK-SGYEND(3:6)
*
       MOVE  WK-SGYEND           TO    WK-KEY-YMD
       PERFORM                   CALM-READ-SEC
       IF    SW-INV   =  "INV"
       THEN
*                                < ｶﾚﾝﾀﾞﾏｽﾀ ﾆ ｿﾝｻﾞｲ ｼﾏｾﾝ >
         IF      WK-ERR = SPACE
         THEN
           MOVE  "C"             TO    EDIT-CURSOR OF SGYEND
                                                   OF D20010D1
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR028"        TO    WK-NO
         END-IF
         MOVE    "R"             TO    EDIT-COLOR  OF SGYEND
                                                   OF D20010D1
       END-IF
     END-IF.
*
*    関連チェック
     IF      ( WK-SGYSTR  NOT = ZERO       )  AND
             ( WK-SGYEND  NOT = ZERO       )  AND
             ( WK-SGYSTR      >  WK-SGYEND )
     THEN
*                                < ﾁｬｸｼｭﾋﾞｶﾞ ｶﾝﾘｮｳﾋﾞ ｦ ｺｴﾃｲﾏｽ >
       IF    WK-ERR = SPACE
       THEN
         MOVE    "C"             TO    EDIT-CURSOR OF SGYSTR
                                                   OF D20010D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR029"        TO    WK-NO
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF SGYSTR
                                                   OF D20010D1
     END-IF.
*
*  職場コード
     IF  ( SKBCD OF D20010D1  = SPACE)  AND
         ( WK-SYRKBN          = 1    )
     THEN
*                                < ｼｮｸﾊﾞｺｰﾄﾞ ｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       IF    WK-ERR = SPACE
       THEN
         MOVE    "C"             TO    EDIT-CURSOR OF SKBCD
                                                   OF D20010D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR030"        TO    WK-NO
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF SKBCD
                                                   OF D20010D1
       MOVE      SPACE           TO    SKBNM OF D20010D1
     ELSE
       IF   SKBCD OF D20010D1 NOT = SPACE
       THEN
*      組織マスタに存在チェックを行う(職場名の取得)
         MOVE  SKBCD OF D20010D1 TO    WK-SOSICD
         PERFORM                 SOSM-READ-SEC
         IF    SW-INV  = "INV"
         THEN
*                                < ｺｰﾄﾞ ｶﾞ ｿｼｷﾏｽﾀ ﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           IF    WK-ERR = SPACE
           THEN
             MOVE  "C"           TO    EDIT-CURSOR OF SKBCD
                                                   OF D20010D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR031"      TO    WK-NO
           END-IF
           MOVE    "R"           TO    EDIT-COLOR  OF SKBCD
                                                   OF D20010D1
           MOVE    SPACE         TO    SKBNM OF D20010D1
         ELSE
           MOVE    BSYNAM OF ASOSML1
                                 TO    SKBNM OF D20010D1
         END-IF
       END-IF
     END-IF.
*
*  評価係数チェック
     IF    KEISUU OF D20010D1    =  ZERO
     THEN
       MOVE    6                 TO    KEISUU OF D20010D1
     ELSE
       IF ( KEISUU OF D20010D1    >= 1 ) AND
          ( KEISUU OF D20010D1    <= 6 )
       THEN
         CONTINUE
       ELSE
*                                < ﾋｮｳｶｹｲｽｳ ﾆ ﾌﾄｳﾁ ｶﾞ ﾆｭｳﾘｮｸｻﾚﾀ >
         IF    WK-ERR = SPACE
         THEN
           MOVE    "C"           TO    EDIT-CURSOR OF KEISUU
                                                   OF D20010D1
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "ERR032"      TO    WK-NO
         END-IF
         MOVE      "R"           TO    EDIT-COLOR  OF KEISUU
                                                   OF D20010D1
       END-IF
     END-IF.
*
*  指示工数
     IF    SJKSUU OF D20010D1   NOT = ZERO
     THEN
*      運用条件ファイルの塗装作業コードか組立作業コードならＯＫ
       IF  ( SGYCD OF D20010D1      = WK-TSO-CD ) OR
           ( SGYCD OF D20010D1      = WK-TSO-HCD) OR
           ( SGYCD OF D20010D1      = WK-KMI-CD ) OR
           ( SGYCD OF D20010D1      = WK-KMI-HCD) OR
           ( SGYCD OF D20010D1      = WK-BZI-CD ) OR
           ( SGYCD OF D20010D1      = WK-BZI-HCD)
       THEN
         CONTINUE
       ELSE
*        指示項目が１件のみ入力で開始と終了が同項目の場合ＯＫ
         IF  ( T-KMK-STR(1)  = T-KMK-END(1) ) AND
             ( T-KMK-STR(2)  = ZERO         )
         THEN
           CONTINUE
         ELSE
*                                < ｼｼﾞｺｳｽｳ ﾊ ﾆｭｳﾘｮｸ ﾃﾞｷﾏｾﾝ >
           IF    WK-ERR = SPACE
           THEN
             MOVE    "C"         TO    EDIT-CURSOR OF SJKSUU
                                                   OF D20010D1
             MOVE    "ERR"       TO    WK-ERR
             MOVE    "ERR033"    TO    WK-NO
           END-IF
           MOVE      "R"         TO    EDIT-COLOR  OF SJKSUU
                                                   OF D20010D1
         END-IF
       END-IF
     END-IF.
*
*  標準工数合計
     PERFORM                     KSUKEI-SET-SEC.
*
*    単体チェックでエラーがある場合は処理を抜ける
     IF    ( WK-ERR                      = "ERR" )  OR
           ( SGYCD OF D20010D1 (4:1) NOT = ZERO  )
     THEN
       GO  TO        CHECK7-999
     END-IF.
*
*    作業実績ファイルチェックを行う
     IF    SGYCD OF D20010D1     =  WK-SGYCD
     THEN
       IF  TBL-CHK-FLG           =  "1"
       THEN
*      実績エラーがあるときはエラーを表示し指示項目修正へ移る
         PERFORM    VARYING  IX1  FROM  1  BY  1
                    UNTIL  ( IX1  >  30            ) OR
                           ( T-KMK-STR(IX1) = ZERO )
*
             IF     T-JSK-FLG (IX1) NOT = SPACE
             THEN
               MOVE "ERR"        TO    TBL-ERR-FLG
                                       WK-ERR
               MOVE 30           TO    IX1
             END-IF
         END-PERFORM
       END-IF
     ELSE
       MOVE    SPACE             TO    TBL-CHK-FLG
                                       TBL-ERR-FLG
       PERFORM      VARYING  IX1  FROM  1  BY  1
                    UNTIL  ( IX1  >  30            ) OR
                           ( T-KMK-STR(IX1) = ZERO )
*
           MOVE  SPACE           TO    T-JSK-FLG(IX1)
           MOVE  ZERO            TO    T-KMK-ERR(IX1)
       END-PERFORM
     END-IF
*
     IF    WK-ERR                =    SPACE
     THEN
       MOVE     "1"              TO    TBL-CHK-FLG
*
*    指示項目　1～9999 の場合
       IF    TBL-ALL-FLG =  "ALL"
       THEN
         MOVE   1                TO    IX1
         MOVE   T-KMK-STR(IX1)   TO    WK-JYUKOU
         MOVE   ">="             TO    WK-KEY-POINT
         PERFORM                 JUKF-STR-SEC
         IF     SW-INV   =  "INV"
         THEN
           CONTINUE
         ELSE
           PERFORM               JUKF-NEXT-SEC
*
           PERFORM  UNTIL   ( SW-INV    = "END" )
                    OR      ( WK-ERR    = "ERR" )
                    OR      ( WK-SEIBAN < SEIBAN OF AJUKFL1 )
               IF  DELFLG OF AJUKFL1    = "1"
               THEN
                 CONTINUE
               ELSE
                 PERFORM         JSK-CHK-SEC
               END-IF
               PERFORM           JUKF-NEXT-SEC
           END-PERFORM
*
           IF  WK-ERR                   = "ERR"
           THEN
             MOVE  WK-KMK-ERR    TO    T-KMK-ERR(IX1)
           END-IF
*
         END-IF
       END-IF
*
*    指示項目　1～9999 以外の場合
       IF    TBL-ALL-FLG   =  SPACE
       THEN
         PERFORM  VARYING    IX1  FROM  1  BY 1
                  UNTIL    ( IX1  > 30             )
                  OR       ( T-KMK-STR(IX1) = ZERO )
             MOVE  SPACE         TO    WK-ERR
             MOVE T-KMK-STR(IX1) TO    WK-JYUKOU
             MOVE  "="           TO    WK-KEY-POINT
             PERFORM             JUKF-STR-SEC
*
             IF    SW-INV    =   "INV"
             THEN
               CONTINUE
             ELSE
               PERFORM           JUKF-NEXT-SEC
*
               PERFORM  UNTIL (SW-INV        = "END" )
                         OR   (WK-ERR        = "ERR" )
                         OR   (WK-SEIBAN      < SEIBAN OF AJUKFL1)
                         OR   (T-KMK-END(IX1) < JYUKOU OF AJUKFL1)
*
                   PERFORM       JSK-CHK-SEC
                   PERFORM       JUKF-NEXT-SEC
               END-PERFORM
             END-IF
*
             IF  WK-ERR                   = "ERR"
             THEN
               MOVE  WK-KMK-ERR  TO    T-KMK-ERR(IX1)
             END-IF
*
         END-PERFORM
         IF  TBL-ERR-FLG  = "ERR"
         THEN
           MOVE  "ERR"           TO    WK-ERR
         END-IF
       END-IF
     END-IF.
*
*  実績エラーがあった場合　TBL-ALL-FLG のクリアをする
     IF  ( TBL-ALL-FLG   =  "ALL" )  AND
         ( WK-ERR        =  "ERR" )
     THEN
       MOVE    SPACE             TO    TBL-ALL-FLG
     END-IF.
 CHECK7-999.
     EXIT.
/*****************************************************************
*    標準工数合計セット処理
******************************************************************
 KSUKEI-SET-SEC                  SECTION.
 KSUKEI-SET-010.
*
     MOVE    ZERO                TO    WK-TSO-SUU
                                       WK-KMI-SUU
                                       KSUKEI OF D20010D1.
*    作業コード（画）と塗装コードが同一の場合
     IF  ( SGYCD OF D20010D1 = WK-TSO-CD  )    OR
         ( SGYCD OF D20010D1 = WK-TSO-HCD )
     THEN
*
       PERFORM  VARYING  IX1  FROM  1  BY  1
                UNTIL  ( IX1  > 30              ) OR
                       ( T-KMK-STR(IX1)  = ZERO )
           COMPUTE  WK-TSO-SUU
                 =  WK-TSO-SUU + T-TSO-SUU(IX1)
       END-PERFORM
*
       MOVE  WK-TSO-SUU          TO    KSUKEI OF D20010D1
     END-IF.
*
*    作業コード（画）と組立コード／部材コードが同一の場合
     IF  ( SGYCD OF D20010D1 = WK-KMI-CD  ) OR
         ( SGYCD OF D20010D1 = WK-KMI-HCD ) OR
         ( SGYCD OF D20010D1 = WK-BZI-CD  ) OR
         ( SGYCD OF D20010D1 = WK-BZI-HCD )
     THEN
*
       PERFORM  VARYING  IX1  FROM  1  BY  1
                UNTIL  ( IX1  > 30              ) OR
                       ( T-KMK-STR(IX1)  = ZERO )
           COMPUTE  WK-KMI-SUU
                 =  WK-KMI-SUU + T-KMI-SUU(IX1)
       END-PERFORM
*
       MOVE  WK-KMI-SUU          TO    KSUKEI OF D20010D1
     END-IF.
 KSUKEI-SET-999.
     EXIT.
/*****************************************************************
*    作業実績ファイルチェック処理
******************************************************************
 JSK-CHK-SEC                     SECTION.
 JSK-CHK-010.
*
     MOVE    SPACE               TO    T-JSK-FLG(IX1).
     MOVE    JYUKOU OF AJUKFL1   TO    WK-KOMOKU.
     MOVE    SGYCD  OF D20010D1  TO    WK-WORKCD.
     PERFORM                     JISF-READ-SEC.
*
     IF      WK-SYRKBN = 1
*    指示の場合
     THEN
*      指示情報チェック
       IF   SW-INV = "INV"
       THEN
         CONTINUE
       ELSE
         IF   SIJIHI OF CJISFL1 = 0
         THEN
*        実績情報チェック
           IF ( SW-INV = SPACE            ) AND
              ( TJSKBI OF CJISFL1  = ZERO ) AND
              ( KJSKBI OF CJISFL1  = ZERO )
*             ( JSKOSU OF CJISFL1  = ZERO )
           THEN
             CONTINUE
           ELSE
             MOVE  KOMOKU OF CJISFL1
                                   TO    WK-KMK-ERR
             MOVE  "3"             TO    T-JSK-FLG(IX1)
*                                < ｼﾞｯｾｷｽﾞﾐ ﾆ ﾅｯﾃｲﾏｽ >
             MOVE  "ERR"           TO    WK-ERR
             MOVE  "ERR023"        TO    WK-NO
           END-IF
         ELSE
           MOVE  KOMOKU OF CJISFL1 TO  WK-KMK-ERR
           MOVE  "1"               TO  T-JSK-FLG(IX1)
*                                < ｽﾃﾞﾆ ｼｼﾞ ｻﾚﾃｲﾏｽ >
           MOVE  "ERR"             TO    WK-ERR
           MOVE  "ERR021"          TO    WK-NO
         END-IF
       END-IF
*
     ELSE
*    取消の場合
*      指示情報チェック
       IF ( SW-INV                = SPACE ) AND
          ( SIJIHI OF CJISFL1 NOT = ZERO  )
       THEN
*        実績情報チェック
         IF ( SW-INV = SPACE            ) AND
            ( TJSKBI OF CJISFL1  = ZERO ) AND
            ( KJSKBI OF CJISFL1  = ZERO )
*           ( JSKOSU OF CJISFL1  = ZERO )
         THEN
           CONTINUE
         ELSE
           MOVE  KOMOKU OF CJISFL1
                                 TO  WK-KMK-ERR
           MOVE  "3"             TO  T-JSK-FLG(IX1)
*                                < ｼﾞｯｾｷｽﾞﾐ ﾆ ﾅｯﾃｲﾏｽ >
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR023"        TO    WK-NO
         END-IF
       ELSE
         MOVE  KOMOKU OF CJISFL1 TO  WK-KMK-ERR
         MOVE  "2"               TO  T-JSK-FLG(IX1)
*                                < ﾏﾀﾞ ｼｼﾞ ｻﾚﾃｲﾏｾﾝ >
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR022"          TO    WK-NO
       END-IF
     END-IF.
*
     IF    WK-ERR     =  "ERR"
     THEN
       MOVE    "ERR"             TO    TBL-ERR-FLG
     END-IF.
 JSK-CHK-999.
     EXIT.
/*****************************************************************
*    項目ゼロ件チェック
******************************************************************
 ZERO-CHK-SEC                    SECTION.
 ZERO-CHK-010.
*
*  項目指定／ＳＥＱ／指示項目のクリアを行う
     MOVE    ZERO                TO    KSTKBN OF D20010D1
                                       SEQNO  OF D20010D1
                                       SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1
                                       ERRKMK OF D20010D1.
     PERFORM                     ATR-CLR4-SEC.
     PERFORM                     ATR-CLR5-SEC.
     PERFORM                     ATR-CLR6-SEC.
*
*  項目ゼロ件チェック
     IF  KAISI OF D20010D1(1 1) = ZERO
     THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｱﾘﾏｾﾝ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR034"          TO    WK-NO
       MOVE    "R"               TO    EDIT-COLOR  OF SIJIFR
                                                   OF D20010D1
                                       EDIT-COLOR  OF SIJIBY
                                                   OF D20010D1
       MOVE    "C"               TO    EDIT-CURSOR OF SIJIFR
                                                   OF D20010D1
       MOVE    1                 TO    KSTKBN OF D20010D1
     ELSE
       IF      WK-ERR = "ERR"    OR    TBL-ERR-FLG = "ERR"
       THEN
*      画面の指示項目をＴＢＬに退避しなおす
         MOVE     1              TO    IX1
         MOVE     SPACE          TO    TBL-ERR-FLG
                                       WK-ERR
*
         PERFORM  VARYING  IX-T1   FROM  1  BY  1
                  UNTIL    IX-T1   >     3
*
           PERFORM  VARYING  IX-T2  FROM  1  BY  1
                    UNTIL    IX-T2  >  10
             IF   KAISI OF D20010D1(IX-T1 IX-T2) = ZERO
             THEN
               CONTINUE
             ELSE
               MOVE  KAISI  OF D20010D1(IX-T1 IX-T2)
                                 TO    T-KMK-STR(IX1)
               MOVE  SYURYO OF D20010D1(IX-T1 IX-T2)
                                 TO    T-KMK-END(IX1)
               IF    T-KMK-ERR(IX1)    =  ZERO
               THEN
                 MOVE  SPACE     TO    T-JSK-FLG(IX1)
               END-IF
             END-IF
*
             ADD     1           TO    IX1
           END-PERFORM
         END-PERFORM
       END-IF
     END-IF.
 ZERO-CHK-999.
     EXIT.
/*****************************************************************
*    項目エラーセット処理
******************************************************************
 KMKERR-SET-SEC                  SECTION.
 KMKERR-SET-010.
*
     MOVE       ZERO             TO    ERRKMK OF D20010D1.
     MOVE       ZERO             TO    IX2.
*
     PERFORM    VARYING  IX1     FROM  1  BY  1
                UNTIL    IX1     > 30
         IF     T-JSK-FLG(IX1)   =     "1"  OR  "2"  OR  "3"
         THEN
           MOVE  2               TO    KSTKBN OF D20010D1
           MOVE  IX1             TO    SEQNO  OF D20010D1
*
           IF    DSP-GROUP       =     "GRP006"
           THEN
             IF  DSP-FUNC        =     "F005"
             THEN
               MOVE  T-KMK-ERR(IX1)  TO    ERRKMK OF D20010D1
               MOVE  T-KMK-STR(IX1)  TO    SIJIFR OF D20010D1
               MOVE  T-KMK-END(IX1)  TO    SIJIBY OF D20010D1
             ELSE
               MOVE  WK-KMK-ERR      TO    ERRKMK OF D20010D1
             END-IF
           ELSE
             MOVE  T-KMK-ERR(IX1)    TO    ERRKMK OF D20010D1
             MOVE  T-KMK-STR(IX1)    TO    SIJIFR OF D20010D1
             MOVE  T-KMK-END(IX1)    TO    SIJIBY OF D20010D1
           END-IF
*
           MOVE  "R"             TO    EDIT-COLOR  OF SIJIFR
                                                   OF D20010D1
                                       EDIT-COLOR  OF SIJIBY
                                                   OF D20010D1
                                       EDIT-COLOR  OF ERRKMK
                                                   OF D20010D1
           MOVE  "C"             TO    EDIT-CURSOR OF SIJIFR
                                                   OF D20010D1
           EVALUATE  T-JSK-FLG(IX1)
              WHEN  "1"
                  MOVE  "ERR021" TO    WK-NO
              WHEN  "2"
                  MOVE  "ERR022" TO    WK-NO
              WHEN  "3"
                  MOVE  "ERR023" TO    WK-NO
           END-EVALUATE
*
           MOVE  30              TO    IX1
         ELSE
           ADD   1               TO    IX2
         END-IF
     END-PERFORM.
*
     IF    IX2      =  30
     THEN
       MOVE    SPACE             TO    TBL-ERR-FLG
     END-IF.
 KMKERR-SET-999.
     EXIT.
/*****************************************************************
*    指示項目削除処理
******************************************************************
 KMK-DEL-SEC                     SECTION.
 KMK-DEL-010.
*
     MOVE    ZERO                TO    SIJIFR OF D20010D1
                                       SIJIBY OF D20010D1.
     MOVE    SEQNO OF D20010D1   TO    IX1  IX2.
     ADD     1                   TO    IX2.
*
     IF    ( IX1                 = 30  ) OR
           ( IX2                 < 31    AND
             T-KMK-STR(IX2)      = ZERO)
     THEN
       INITIALIZE                T-KMK-STR(IX1)
                                 T-KMK-END(IX1)
                                 T-KMK-ERR(IX1)
                                 T-JSK-FLG(IX1)
                                 T-KMI-SUU(IX1)
                                 T-TSO-SUU(IX1)
     ELSE
       PERFORM  UNTIL ( T-KMK-STR(IX2)  = ZERO ) OR
                      ( IX2             > 30   )
           MOVE  T-KMK-STR(IX2)  TO    T-KMK-STR(IX1)
           MOVE  T-KMK-END(IX2)  TO    T-KMK-END(IX1)
           MOVE  T-KMK-ERR(IX2)  TO    T-KMK-ERR(IX1)
           MOVE  T-JSK-FLG(IX2)  TO    T-JSK-FLG(IX1)
           MOVE  T-KMI-SUU(IX2)  TO    T-KMI-SUU(IX1)
           MOVE  T-TSO-SUU(IX2)  TO    T-TSO-SUU(IX1)
           INITIALIZE                  T-KMK-STR(IX2)
                                       T-KMK-END(IX2)
                                       T-KMK-ERR(IX2)
                                       T-JSK-FLG(IX2)
                                       T-KMI-SUU(IX2)
                                       T-TSO-SUU(IX2)
           ADD   1               TO    IX1  IX2
       END-PERFORM
     END-IF.
*
*  指示項目（開始～終了）の再セットを行う
     MOVE     1                  TO    IX-T1  IX-T2.
     PERFORM  VARYING  IX1  FROM  1  BY  1
              UNTIL  ( IX1  > 30                     )  OR
                     ( KAISI OF D20010D1(IX-T1 IX-T2) = ZERO )
         IF    T-KMK-STR(IX1) = ZERO
         THEN
           MOVE  ZERO    TO    KAISI  OF D20010D1(IX-T1 IX-T2)
           MOVE  ZERO    TO    SYURYO OF D20010D1(IX-T1 IX-T2)
         ELSE
           MOVE  T-KMK-STR(IX1)
                         TO    KAISI  OF D20010D1(IX-T1 IX-T2)
           MOVE  T-KMK-END(IX1)
                         TO    SYURYO OF D20010D1(IX-T1 IX-T2)
         END-IF
         IF      IX1  =  10  OR  20
         THEN
           ADD   1               TO    IX-T1
           MOVE  ZERO            TO    IX-T2
         END-IF
         ADD     1               TO    IX-T2
     END-PERFORM.
*
     MOVE        ZERO            TO    SEQNO  OF D20010D1.
 KMK-DEL-999.
     EXIT.
/*****************************************************************
*    ファイル更新処理
******************************************************************
 FILE-UPD-SEC                    SECTION.
 FILE-UPD-010.
*  発番ファイルより連番取得
     PERFORM                     HATM-ACS-SEC.
*
*  受注Ｆ(項目)チェック＊指示項目　1～9999　　の場合
     IF  TBL-ALL-FLG    =  "ALL"
     THEN
       MOVE    1                 TO    WK-JYUKOU
       MOVE    ">="              TO    WK-KEY-POINT
*    受注ファイル（項目）ＲＥＡＤ
       PERFORM                   JUKF-STR-SEC
       IF    SW-INV    =   "INV"
       THEN
         CONTINUE
       ELSE
         PERFORM                 JUKF-NEXT-SEC
         MOVE  JYUKOU OF AJUKFL1 TO    WK-KOMOKU
*
         PERFORM     UNTIL     ( SW-INV  = "END" )       OR
                               ( WK-SEIBAN < SEIBAN OF AJUKFL1 )
           IF  DELFLG OF AJUKFL1 = SPACE
           THEN
*            ユニット管理ファイルの更新
             PERFORM             UNIF-UPD-SEC
*            作業指示ファイルの出力
             PERFORM             SJIF-OUT-SEC
*            作業実績ファイルの更新
             PERFORM             JISF-UPD-SEC
           END-IF
*
           PERFORM             JUKF-NEXT-SEC
           MOVE  JYUKOU OF AJUKFL1 TO    WK-KOMOKU
         END-PERFORM
       END-IF
*
*    指示項目　1～9999 以外の場合
     ELSE
       PERFORM   VARYING     IX1  FROM  1   BY 1
                 UNTIL     ( IX1            > 30   )  OR
                           ( T-KMK-STR(IX1) = ZERO )
         MOVE    T-KMK-STR(IX1)  TO    WK-JYUKOU
         MOVE    "="             TO    WK-KEY-POINT
         PERFORM                 JUKF-STR-SEC
*
         IF    SW-INV    =   "INV"
         THEN
           CONTINUE
         ELSE
           PERFORM               JUKF-NEXT-SEC
           MOVE  JYUKOU OF AJUKFL1 TO    WK-KOMOKU
*
           PERFORM  UNTIL  ( SW-INV         = "END"             )
                     OR    ( WK-SEIBAN      < SEIBAN OF AJUKFL1 )
                     OR    ( T-KMK-END(IX1) < JYUKOU OF AJUKFL1 )
*              ユニット管理ファイルの更新
               PERFORM           UNIF-UPD-SEC
*              作業指示ファイルの出力
               PERFORM           SJIF-OUT-SEC
*              作業実績ファイルの更新
               PERFORM           JISF-UPD-SEC
*
               PERFORM           JUKF-NEXT-SEC
               MOVE  JYUKOU OF AJUKFL1 TO    WK-KOMOKU
           END-PERFORM
         END-IF
       END-PERFORM
     END-IF.
*
*    発番ファイルの更新
     PERFORM                     HATM-UPD-SEC.
 FILE-UPD-999.
     EXIT.
/*****************************************************************
*    発番ファイル連番取得処理
******************************************************************
 HATM-ACS-SEC                    SECTION.
 HATM-ACS-010.
*
*  発番ファイルの更新（連番１更新）
     PERFORM                     HATM-READ-SEC.
     COMPUTE  WK-RENBAN =  RENBAN OF AHATML1  +   1.
     IF       WK-RENBAN >  RJOGEN OF AHATML1
     THEN
       MOVE  RKAGEN OF AHATML1   TO    RENBAN OF AHATML1
                                       WK-RENBAN
     ELSE
       MOVE  WK-RENBAN           TO    RENBAN OF AHATML1
     END-IF.
 HATM-ACS-999.
     EXIT.
/*****************************************************************
*    ユニット管理ファイル更新処理（REWRITE)
******************************************************************
 UNIF-UPD-SEC                    SECTION.
 UNIF-UPD-010.
*
     INITIALIZE                  WK-UNIINF-AREA.
     MOVE    ZERO                TO    IX3.
     PERFORM                     UNIF-STR-SEC.
*
     IF    SW-INV   =   "INV"
     THEN
       CONTINUE
     ELSE
       PERFORM                   UNIF-NEXT-SEC
*
       PERFORM  UNTIL  ( SW-INV    = "END"             ) OR
                       ( WK-SEIBAN < SEIBAN OF CUNIFL1 ) OR
                       ( WK-KOMOKU < KOMOKU OF CUNIFL1 )
*
         PERFORM  VARYING  IX2 FROM  1  BY  1
                  UNTIL    IX2 > 8
           EVALUATE  IX2
               WHEN  1
                     MOVE  JCD13 OF AJKNML1   TO  WK-JCD
               WHEN  2
                     MOVE  JCD14 OF AJKNML1   TO  WK-JCD
               WHEN  3
                     MOVE  JCD15 OF AJKNML1   TO  WK-JCD
               WHEN  4
                     MOVE  JCD16 OF AJKNML1   TO  WK-JCD
               WHEN  5
                     MOVE  JCD17 OF AJKNML1   TO  WK-JCD
               WHEN  6
                     MOVE  JCD18 OF AJKNML1   TO  WK-JCD
               WHEN  7
                     MOVE  JCD19 OF AJKNML1   TO  WK-JCD
               WHEN  8
                     MOVE  JCD20 OF AJKNML1   TO  WK-JCD
           END-EVALUATE
*
           IF      WK-WORKCD = WK-JCD
           THEN
*            作業指示ファイル出力用ユニット情報退避
             ADD   1                       TO    IX3
             MOVE  SJIKBN OF CUNIFL1(IX2)  TO    WK-SJIFLG (IX3)
             MOVE  UNITCD OF CUNIFL1       TO    WK-UNITCD (IX3)
             MOVE  WYOTEI OF CUNIFL1(IX2)  TO    WK-WYOTEI
             IF    WK-WYOTEI    >     ZERO
             THEN
               MOVE  "1"                   TO    WK-SAGJYO (IX3)
             END-IF
*
             MOVE  WKANBI OF CUNIFL1(9)    TO    WK-WKANBI
             IF    WK-WKANBI    >     ZERO
             THEN
               MOVE  "1"                   TO    WK-SYUJYO (IX3)
             END-IF
           END-IF
*
           IF    ( WK-WORKCD                  = WK-JCD ) AND
                 ( SJIKBN OF CUNIFL1(IX2) NOT = "2"    )
           THEN
             IF    WK-SYRKBN             =  1
             THEN
*            指示（新規）の場合
               MOVE  "1"         TO    SJIKBN OF CUNIFL1(IX2)
               MOVE  SKBCD OF D20010D1
                                 TO    SJIOFC OF CUNIFL1(IX2)
               MOVE  WK-SGYEND   TO    WYOTEI OF CUNIFL1(IX2)
             ELSE
*            取消の場合
               MOVE  SPACE       TO    SJIKBN OF CUNIFL1(IX2)
               MOVE  SPACE       TO    SJIOFC OF CUNIFL1(IX2)
               MOVE  ZERO        TO    WYOTEI OF CUNIFL1(IX2)
             END-IF
*
             MOVE  SYS-YMD-RE    TO    UPDDAY OF CUNIFL1
             ACCEPT  SYS-HMS     FROM  TIME
             MOVE  SYS-HMS(1:6)  TO    UPDTIM OF CUNIFL1
             MOVE  DSP-WSID      TO    WSID   OF CUNIFL1
*
             REWRITE   CUNIFD  OF CUNIFL1
             EVALUATE  ST-CUNIFL
                 WHEN  "00"
                       ADD   1             TO    CNT-UNI
                 WHEN  OTHER
                       MOVE  "CUNIFL1"     TO    WK-FILE
                       MOVE  "REWRITE"     TO    WK-SYORI
                       MOVE  WK-SEIBAN     TO    WK-KEY1
                       MOVE  WK-KOMOKU     TO    WK-KEY2
                       MOVE  UNITCD OF CUNIFL1
                                           TO    WK-KEY3
                       MOVE  ST-CSJIFL     TO    WK-STATUS
                       PERFORM             ABEND-SEC
             END-EVALUATE
           END-IF
         END-PERFORM
*
         PERFORM                 UNIF-NEXT-SEC
       END-PERFORM
     END-IF.
 UNIF-UPD-999.
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
     MOVE    JYUKOU OF AJUKFL1   TO    KOMOKU OF CSJIFL1.
     MOVE    WK-SYRKBN           TO    SIJIKB OF CSJIFL1.
     MOVE    "1"                 TO    WRKKBN OF CSJIFL1.
*
     IF      WK-SYRKBN           =  2
     THEN
       MOVE  SJIKBN OF D20010D1  TO    THAKOF OF CSJIFL1
     END-IF.
*
     MOVE    SGYCD  OF D20010D1  TO    WORKCD OF CSJIFL1.
     MOVE    SKBCD  OF D20010D1  TO    SJIOFC OF CSJIFL1.
     MOVE    WK-SGYSTR           TO    TYOTEI OF CSJIFL1.
     MOVE    WK-SGYEND           TO    KYOTEI OF CSJIFL1.
*
*  指示工数
     MOVE    ZERO                TO    WK-KMK-SUU.
     PERFORM     VARYING   IX2   FROM  1  BY  1
                 UNTIL     IX2   >     30
                 OR        T-KMK-SUU(IX2) = ZERO
*
         ADD     T-KMK-SUU(IX2)  TO    WK-KMK-SUU
     END-PERFORM.
*    運用条件Ｆの塗装作業ｺｰﾄﾞと画面の作業ｺｰﾄﾞが同一の場合
     IF  ( SGYCD OF D20010D1     =     WK-TSO-CD  )  OR
         ( SGYCD OF D20010D1     =     WK-TSO-HCD )
     THEN
       IF  SJKSUU OF D20010D1    =     ZERO
       THEN
         MOVE  THKOSU OF AJUKFL1 TO    SJKOSU OF CSJIFL1
       ELSE
         MOVE  ZERO              TO    WK-TSO-SUU
                                       WK-TAIHI
*
         IF  KSUKEI OF D20010D1  =     ZERO
         THEN
           DIVIDE   SJKSUU OF D20010D1      BY  WK-KMK-SUU
                    GIVING    WK-TSO-SUU    ROUNDED
         ELSE
           COMPUTE  WK-TAIHI
               =    SJKSUU OF D20010D1  *  THKOSU OF AJUKFL1
           DIVIDE   WK-TAIHI                BY  KSUKEI OF D20010D1
                    GIVING    WK-TSO-SUU    ROUNDED
         END-IF
         MOVE  WK-TSO-SUU        TO    SJKOSU OF CSJIFL1
       END-IF
*
     ELSE
*    運用条件Ｆの組立作業ｺｰﾄﾞと画面の作業ｺｰﾄﾞが同一の場合
       IF  ( SGYCD OF D20010D1     =     WK-KMI-CD  ) OR
           ( SGYCD OF D20010D1     =     WK-KMI-HCD ) OR
           ( SGYCD OF D20010D1     =     WK-BZI-CD  ) OR
           ( SGYCD OF D20010D1     =     WK-BZI-HCD )
       THEN
         MOVE  JYUKOU OF AJUKFL1 TO    WK-KOMOKU
         PERFORM                 GEKF-READ-SEC
*        原価ファイル　ＩＮＶの場合
         IF    SW-INV            =     "INV"
         THEN
           IF  SJKSUU OF D20010D1  =     ZERO
           THEN
             CONTINUE
           ELSE
             MOVE  ZERO          TO    WK-KMI-SUU
                                       WK-TAIHI
             IF  KSUKEI OF D20010D1  =     ZERO
             THEN
               DIVIDE   SJKSUU OF D20010D1   BY  WK-KMK-SUU
                        GIVING    WK-KMI-SUU     ROUNDED
             END-IF
             MOVE  WK-KMI-SUU    TO    SJKOSU OF CSJIFL1
           END-IF
*
*        原価ファイル　正常読込みの場合
         ELSE
           IF    SJKSUU OF D20010D1  =     ZERO
           THEN
             MOVE  IKMIKO OF AGEKFL1(1)
                                   TO    SJKOSU OF CSJIFL1
           ELSE
             MOVE  ZERO              TO    WK-KMI-SUU
                                         WK-TAIHI
             IF  KSUKEI OF D20010D1  =     ZERO
             THEN
               DIVIDE   SJKSUU OF D20010D1   BY  WK-KMK-SUU
                        GIVING    WK-KMI-SUU     ROUNDED
             ELSE
               COMPUTE  WK-TAIHI
                  =    SJKSUU OF D20010D1  *  IKMIKO OF AGEKFL1(1)
               DIVIDE   WK-TAIHI           BY  KSUKEI OF D20010D1
                        GIVING    WK-KMI-SUU     ROUNDED
             END-IF
             MOVE  WK-KMI-SUU        TO    SJKOSU OF CSJIFL1
           END-IF
         END-IF
*
       ELSE
         IF  SJKSUU OF D20010D1 NOT = ZERO
         THEN
           MOVE  SJKSUU OF D20010D1
                                   TO    SJKOSU OF CSJIFL1
         END-IF
       END-IF
     END-IF.
*
     MOVE    SJKSUU OF D20010D1  TO    INKOSU OF CSJIFL1.
     MOVE    KEISUU OF D20010D1  TO    HYOUKE OF CSJIFL1.
*
*    ユニット情報(ユニットコード．作業状況．出荷状況)
     MOVE    ZERO                TO    IX4.
     PERFORM   VARYING  IX3    FROM  1  BY  1
               UNTIL  ( IX3            >    10 )
               OR     ( WK-UNITCD(IX3) = SPACE )
*
       IF        WK-SYRKBN         =     1
       THEN
         MOVE    WK-UNITCD(IX3)  TO    UNITCD OF CSJIFL1(IX3)
         MOVE    WK-SAGJYO(IX3)  TO    SAGJYO OF CSJIFL1(IX3)
         MOVE    WK-SYUJYO(IX3)  TO    SYUJYO OF CSJIFL1(IX3)
       ELSE
         IF      WK-SJIFLG (IX3)   =     "1"
         THEN
           ADD   1               TO    IX4
           MOVE  WK-UNITCD(IX3)  TO    UNITCD OF CSJIFL1(IX4)
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
     WRITE   CSJIFD  OF CSJIFL1.
     EVALUATE  ST-CSJIFL
         WHEN  "00"
               ADD   1                 TO    CNT-SJI2
         WHEN  OTHER
               MOVE  "CSJIFL1"         TO    WK-FILE
               MOVE  "WRITE"           TO    WK-SYORI
               MOVE  SIJINO OF CSJIFL1 TO    WK-KEY1
               MOVE  SEIBAN OF CSJIFL1 TO    WK-KEY2
               MOVE  KOMOKU OF CSJIFL1 TO    WK-KEY3
               MOVE  ST-CSJIFL         TO    WK-STATUS
               PERFORM                 ABEND-SEC
     END-EVALUATE.
 SJIF-OUT-999.
     EXIT.
/*****************************************************************
*    作業実績ファイル更新処理（WRITE / REWRITE)
******************************************************************
 JISF-UPD-SEC                    SECTION.
 JISF-UPD-010.
*
     MOVE  JYUKOU OF AJUKFL1     TO    WK-KOMOKU.
     MOVE  SGYCD  OF D20010D1    TO    WK-WORKCD.
     PERFORM                     JISF-READ-SEC.
*
     IF    WK-SYRKBN             =  1
     THEN
*    指示（新規）の場合
       IF  SW-INV                =  "INV"
       THEN
         INITIALIZE              CJISFD OF CJISFL1
*
         MOVE  WK-SEIBAN         TO    SEIBAN OF CJISFL1
         MOVE  WK-KOMOKU         TO    KOMOKU OF CJISFL1
         MOVE  WK-WORKCD         TO    WORKCD OF CJISFL1
         MOVE  SKBCD OF D20010D1 TO    SJIOFC OF CJISFL1
         MOVE  WK-SGYSTR         TO    TYOTEI OF CJISFL1
         MOVE  WK-SGYEND         TO    KYOTEI OF CJISFL1
         MOVE  SYS-YMD-RE        TO    SIJIHI OF CJISFL1
         ADD   1                 TO    SIJIHE OF CJISFL1
*
         MOVE  SYS-YMD-RE        TO    CRTDAY OF CJISFL1
         MOVE  SYS-YMD-RE        TO    UPDDAY OF CJISFL1
         ACCEPT  SYS-HMS         FROM  TIME
         MOVE  SYS-HMS(1:6)      TO    UPDTIM OF CJISFL1
         MOVE  DSP-WSID          TO    WSID   OF CJISFL1
*
         WRITE   CJISFD  OF CJISFL1
         EVALUATE  ST-CJISFL
             WHEN  "00"
                   ADD   1             TO    CNT-JIS2
             WHEN  "23"
                   CONTINUE
             WHEN  OTHER
                   MOVE  "CJISFL1"     TO    WK-FILE
                   MOVE  "WRITE"       TO    WK-SYORI
                   MOVE  WK-SEIBAN     TO    WK-KEY1
                   MOVE  WK-KOMOKU     TO    WK-KEY2
                   MOVE  WK-WORKCD     TO    WK-KEY3
                   MOVE  ST-CJISFL     TO    WK-STATUS
                   PERFORM             ABEND-SEC
         END-EVALUATE
*
       ELSE
*      新規で既存データの場合
         MOVE  SKBCD OF D20010D1 TO    SJIOFC OF CJISFL1
         MOVE  WK-SGYSTR         TO    TYOTEI OF CJISFL1
         MOVE  WK-SGYEND         TO    KYOTEI OF CJISFL1
         MOVE  SYS-YMD-RE        TO    SIJIHI OF CJISFL1
*
*      指示変更回数
*        作業コード新規時
         IF    WK-WORKCD(4:1)    =     ZERO
         THEN
           ADD   1               TO    SIJIHE OF CJISFL1
         END-IF
*        作業コード変更時
         IF    WK-WORKCD(4:1)    =     1
         THEN
           ADD   1               TO    SIJIHE OF CJISFL1
         END-IF
*
         MOVE  SYS-YMD-RE        TO    UPDDAY OF CJISFL1
         ACCEPT  SYS-HMS         FROM  TIME
         MOVE  SYS-HMS(1:6)      TO    UPDTIM OF CJISFL1
         MOVE  DSP-WSID          TO    WSID   OF CJISFL1
*
         REWRITE   CJISFD  OF CJISFL1
         EVALUATE  ST-CJISFL
             WHEN  "00"
                   ADD   1             TO    CNT-JIS
             WHEN  "23"
                   CONTINUE
             WHEN  OTHER
                   MOVE  "CJISFL1"     TO    WK-FILE
                   MOVE  "REWRITE"     TO    WK-SYORI
                   MOVE  WK-SEIBAN     TO    WK-KEY1
                   MOVE  WK-KOMOKU     TO    WK-KEY2
                   MOVE  WK-WORKCD     TO    WK-KEY3
                   MOVE  ST-CJISFL     TO    WK-STATUS
                   PERFORM             ABEND-SEC
         END-EVALUATE
       END-IF
     ELSE
*
*    取消の場合
       IF  SW-INV                =  "INV"
       THEN
         CONTINUE
       ELSE
         MOVE  SPACE             TO    SJIOFC OF CJISFL1
         MOVE  ZERO              TO    TYOTEI OF CJISFL1
         MOVE  ZERO              TO    KYOTEI OF CJISFL1
         MOVE  ZERO              TO    SIJIHI OF CJISFL1
*
*      指示変更回数
*        作業コード新規時
         IF    WK-WORKCD(4:1)    =     ZERO
         THEN
           CONTINUE
*******    MOVE  ZERO            TO    SIJIHE OF CJISFL1
         END-IF
*        作業コード変更時
         IF    WK-WORKCD(4:1)    =     1
         THEN
           CONTINUE
*******    ADD   1               TO    SIJIHE OF CJISFL1
         END-IF
*
         MOVE  SYS-YMD-RE        TO    UPDDAY OF CJISFL1
         ACCEPT  SYS-HMS         FROM  TIME
         MOVE  SYS-HMS(1:6)      TO    UPDTIM OF CJISFL1
         MOVE  DSP-WSID          TO    WSID   OF CJISFL1
*
         REWRITE   CJISFD  OF CJISFL1
         EVALUATE  ST-CJISFL
             WHEN  "00"
                   ADD   1             TO    CNT-JIS
             WHEN  "23"
                   CONTINUE
             WHEN  OTHER
                   MOVE  "CJISFL1"     TO    WK-FILE
                   MOVE  "REWRITE"     TO    WK-SYORI
                   MOVE  WK-SEIBAN     TO    WK-KEY1
                   MOVE  WK-KOMOKU     TO    WK-KEY2
                   MOVE  WK-WORKCD     TO    WK-KEY3
                   MOVE  ST-CJISFL     TO    WK-STATUS
                   PERFORM             ABEND-SEC
         END-EVALUATE
       END-IF
     END-IF.
 JISF-UPD-999.
     EXIT.
/*****************************************************************
*    発番ファイル更新処理（REWRITE)
******************************************************************
 HATM-UPD-SEC                    SECTION.
 HATM-UPD-010.
*
*  連番はファイル更新処理の中でセット済
*
     MOVE    SYS-YMD-RE          TO    UPDDAY OF AHATML1.
     ACCEPT  SYS-HMS             FROM  TIME.
     MOVE    SYS-HMS(1:6)        TO    UPDTIM OF AHATML1.
     MOVE    DSP-WSID            TO    WSID   OF AHATML1.
*
     REWRITE   AHATFD  OF AHATML1.
     EVALUATE  ST-AHATML
         WHEN  "00"
               ADD   1           TO    CNT-HAT
         WHEN  OTHER
               MOVE  "AHATML1"   TO    WK-FILE
               MOVE  "REWRITE"   TO    WK-SYORI
               MOVE  "41"        TO    WK-KEY1
               MOVE  HATUCD OF AHATML1
                                 TO    WK-KEY2
               MOVE  ST-AHATML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 HATM-UPD-999.
     EXIT.
/*****************************************************************
*    運用条件ファイルＲＥＡＤ処理(RAN)
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
               MOVE  "AJKNML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  "0"         TO    WK-KEY1
               MOVE  ST-AJKNML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JKNM-READ-999.
     EXIT.
/*****************************************************************
*    受注ファイル（鑑）　ＲＥＡＤ処理 (RAN)
******************************************************************
 JUGF-READ-SEC                   SECTION.
 JUGF-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     MOVE    SPACE               TO    SEIBAN OF AJUGFL1.
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
*    作業実績ファイルＲＥＡＤ処理(RAN)
******************************************************************
 JISF-READ-SEC                   SECTION.
 JISF-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  SEIBAN OF CJISFL1
                                 KOMOKU OF CJISFL1
                                 WORKCD OF CJISFL1.
     MOVE    WK-SEIBAN           TO    SEIBAN OF CJISFL1.
     MOVE    WK-KOMOKU           TO    KOMOKU OF CJISFL1.
     MOVE    WK-WORKCD           TO    WORKCD OF CJISFL1.
     READ    CJISFL1.
*
     EVALUATE  ST-CJISFL
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CJISFL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-KOMOKU   TO    WK-KEY2
               MOVE  WK-WORKCD   TO    WK-KEY3
               MOVE  ST-CJISFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 JISF-READ-999.
     EXIT.
/*****************************************************************
*    原価ファイル（項目）ＲＥＡＤ処理(RAN)
******************************************************************
 GEKF-READ-SEC                   SECTION.
 GEKF-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  SEIBAN OF AGEKFL1
                                 KOMOKU OF AGEKFL1.
     MOVE    WK-SEIBAN           TO    SEIBAN OF AGEKFL1.
     MOVE    WK-KOMOKU           TO    KOMOKU OF AGEKFL1.
     READ    AGEKFL1.
*
     EVALUATE  ST-AGEKFL
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "AGEKFL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-KOMOKU   TO    WK-KEY2
               MOVE  ST-AGEKFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 GEKF-READ-999.
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
*    ユニット管理ファイルＳＴＡＲＴ処理(START)
******************************************************************
 UNIF-STR-SEC                     SECTION.
 UNIF-STR-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                        SEIBAN OF CUNIFL1
                                       KOMOKU OF CUNIFL1
                                       UNITCD OF CUNIFL1.
     MOVE    WK-SEIBAN           TO    SEIBAN OF CUNIFL1.
     MOVE    WK-KOMOKU           TO    KOMOKU OF CUNIFL1.
*
     START   CUNIFL1   KEY  IS   >     SEIBAN OF CUNIFL1
                                       KOMOKU OF CUNIFL1
                                       UNITCD OF CUNIFL1.
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
*    ユニット管理ファイルＲＥＡＤ処理(NEXT)
******************************************************************
 UNIF-NEXT-SEC                   SECTION.
 UNIF-NEXT-010.
*
     MOVE    SPACE               TO    SW-INV.
     READ    CUNIFL1  NEXT.
     EVALUATE  ST-CUNIFL
         WHEN  "00"
               CONTINUE
         WHEN  "10"
               MOVE  "END"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CUNIFL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-SEIBAN   TO    WK-KEY1
               MOVE  WK-KOMOKU   TO    WK-KEY2
               MOVE  UNITCD OF CUNIFL1
                                 TO    WK-KEY3
               MOVE  ST-CUNIFL   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 UNIF-NEXT-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群２）
******************************************************************
 ATR-CLR2-SEC                     SECTION.
 ATR-CLR2-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SJIKBN OF D20010D1
                             EDIT-COLOR  OF SEIBAN OF D20010D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SJIKBN OF D20010D1
                             EDIT-CURSOR OF SEIBAN OF D20010D1.
 ATR-CLR2-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群３）
******************************************************************
 ATR-CLR3-SEC                     SECTION.
 ATR-CLR3-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SEIBAN OF D20010D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SEIBAN OF D20010D1.
 ATR-CLR3-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群４）
******************************************************************
 ATR-CLR4-SEC                     SECTION.
 ATR-CLR4-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF KSTKBN OF D20010D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF KSTKBN OF D20010D1.
 ATR-CLR4-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群５）
******************************************************************
 ATR-CLR5-SEC                     SECTION.
 ATR-CLR5-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SEQNO  OF D20010D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SEQNO  OF D20010D1.
 ATR-CLR5-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群６）
******************************************************************
 ATR-CLR6-SEC                     SECTION.
 ATR-CLR6-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SIJIFR OF D20010D1
                             EDIT-COLOR  OF SIJIBY OF D20010D1
                             EDIT-COLOR  OF ERRKMK OF D20010D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SIJIFR OF D20010D1
                             EDIT-CURSOR OF SIJIBY OF D20010D1
                             EDIT-CURSOR OF ERRKMK OF D20010D1.
 ATR-CLR6-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群７）
******************************************************************
 ATR-CLR7-SEC                     SECTION.
 ATR-CLR7-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SGYCD  OF D20010D1
                             EDIT-COLOR  OF SGYSTR OF D20010D1
                             EDIT-COLOR  OF SGYEND OF D20010D1
                             EDIT-COLOR  OF SKBCD  OF D20010D1
                             EDIT-COLOR  OF KEISUU OF D20010D1
                             EDIT-COLOR  OF SJKSUU OF D20010D1.
*
     MOVE    SPACE     TO    EDIT-CURSOR OF SGYCD  OF D20010D1
                             EDIT-CURSOR OF SGYSTR OF D20010D1
                             EDIT-CURSOR OF SGYEND OF D20010D1
                             EDIT-CURSOR OF SKBCD  OF D20010D1
                             EDIT-CURSOR OF KEISUU OF D20010D1
                             EDIT-CURSOR OF SJKSUU OF D20010D1.
 ATR-CLR7-999.
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
*    トランザクションSTART
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
               UNTIL     IX-MSG  >      43
       IF      WK-NO  =  WK-MSGNO(IX-MSG)
       THEN
         MOVE  WK-MSGNM(IX-MSG)  TO    WK-MESSAGE
         MOVE  99                TO    IX-MSG
       END-IF
     END-PERFORM.
*
*  ガイドメッセージ
     PERFORM   VARYING   IX-MSG  FROM    1   BY  1
               UNTIL     IX-MSG  >       3
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
     IF  TRN-STR-FLG   = "STR"
     THEN
*    トランザクションEND
       CALL     "XMROTEND"
       MOVE     SPACE            TO    TRN-STR-FLG
     END-IF.
*
     PERFORM                     MSG-SEARCH-SEC.
*
     MOVE    WK-MESSAGE          TO    MSG    OF D20010D1.
     MOVE    WK-GAIDO            TO    GIDMSG OF D20010D1.
     MOVE    "D20010D1"          TO    DSP-FORMAT.
     MOVE    SPACE               TO    DSP-MODE.
     MOVE    "SCREEN"            TO    DSP-GROUP.
*
     WRITE   D20010D1.
     IF      DSP-STATUS      NOT =     "00"
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
     IF      WK-SYORI  =     "OPEN"
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
*    トランザクションCANCEL
     CALL    "XMROTCNL".
*
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20010PO.
