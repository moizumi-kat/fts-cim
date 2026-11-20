*                                     FTS-CIM <CSP/FX E61:COBOLG>
*
* プログラムＩＤ＝　Ｄ２００９０ＰＯ　　（Ｖ０１－Ｌ０１）
*
* サブシステム名＝　工程管理サブシステム
* プログラム内容＝　完了実績情報の新規登録，修正，削除を行う．
*
*                                               作成日：93.03.18
*                                               更新日：93.00.00
*
*          ALL RIGHTS RESERVED COPYRIGHT _ FUJITSU LIMITED 1993
*
* ＊＊＊　ファイル情報　＊＊＊
*  DATA FILE    ：  受注ファイル（鑑）　　　　　<AJUGFL1  >
*                   受注ファイル（項目）　　  　<AJUKFL1  >
*                   作業実績ファイル            <CJISFL1  >
*                   組織マスタ                  <ASOSML1  >
*                   仕様マスタ                  <ASIYML1  >
*                   作業マスタ                  <CSAGML1  >
*                   カレンダマスタ              <CCALML1  >
*                   運用条件ファイル            <AJKNML1  >
*                   生産実績ジャーナル          <CSEIJL2  >
*                   生産実績ジャーナル          <CSEIJL1  >
*                   発番ファイル                <AHATML1  >
*
* ＊＊＊　画面情報　　　＊＊＊
*  SMED NAME    ：　完了実績入力画面    　　　　<DSP-F    >
*♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯♯
*
 IDENTIFICATION             DIVISION.
 PROGRAM-ID.                D20090PO.
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
*    完了実績入力画面
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
*    作業実績ファイル
     SELECT      CJISFL1    ASSIGN       TO DA-VI-CJISFL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS SEIBAN OF CJISFL1
                                            KOMOKU OF CJISFL1
                                            WORKCD OF CJISFL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CJISFL.
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
*    生産実績ジャーナル２
     SELECT      CSEIJL2    ASSIGN       TO DA-VI-CSEIJL2
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JSKKBN OF CSEIJL2
                                            SEIBAN OF CSEIJL2
                                            WORKNY OF CSEIJL2
                            ACCESS MODE  IS DYNAMIC
                            FILE STATUS  IS ST-CSEIJL2.
*    生産実績ジャーナル１
     SELECT      CSEIJL1    ASSIGN       TO DA-VI-CSEIJL1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS JSKNO  OF CSEIJL1
                                            JSKKBN OF CSEIJL1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-CSEIJL1.
*    発番ファイル
     SELECT      AHATML1    ASSIGN       TO DA-VI-AHATML1
                            ORGANIZATION IS INDEXED
                            RECORD KEY   IS HATKBN OF AHATML1
                                            HATUCD OF AHATML1
                            ACCESS MODE  IS RANDOM
                            FILE STATUS  IS ST-AHATML.
/
 DATA                       DIVISION.
 FILE                       SECTION.
******************************************************************
*    完了実績入力画面
******************************************************************
 FD  DSP-F.
     COPY        D20090D1   OF   XMDLIB.
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
*    作業実績ファイル
******************************************************************
 FD  CJISFL1.
     COPY        CJISFL1    OF   XFDLIB.
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
*    生産実績ジャーナル２
******************************************************************
 FD  CSEIJL2.
     COPY        CSEIJL2    OF   XFDLIB.
******************************************************************
*    生産実績ジャーナル１
******************************************************************
 FD  CSEIJL1.
     COPY        CSEIJL1    OF   XFDLIB.
******************************************************************
*    発番ファイル
******************************************************************
 FD  AHATML1.
     COPY        AHATML1    OF   XFDLIB.
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
     03  ST-CJISFL               PIC  X(002).
     03  ST-ASOSML               PIC  X(002).
     03  ST-ASIYML               PIC  X(002).
     03  ST-CSAGML               PIC  X(002).
     03  ST-CCALML               PIC  X(002).
     03  ST-AJKNML               PIC  X(002).
     03  ST-CSEIJL1              PIC  X(002).
     03  ST-CSEIJL2              PIC  X(002).
     03  ST-AHATML               PIC  X(002).
 01  WK-SAVE.
     03  WK-VAL-SAVE.
         05  WK-SYRKBN           PIC  9(001).
         05  WK-JSKBAN           PIC  9(006).
         05  WK-SEIBAN           PIC  X(006).
         05  WK-BKN-CD           PIC  X(004).
         05  WK-SKA-CD           PIC  X(004).
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
         05  CNT-WRT             PIC  9(006).
         05  CNT-UPD             PIC  9(006).
         05  CNT-DEL             PIC  9(006).
         05  CNT-HAT             PIC  9(006).
*    トランザクション管理フラグ
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
         05  WK-SGYCD            PIC  X(004).
         05  WK-KEY-POINT        PIC  X(002).
         05  WK-STRDAY           PIC  9(008).
         05  WK-ENDDAY           PIC  9(008).
         05  WK-ENDDAY-S         PIC  9(006).
         05  WK-RENBAN           PIC  9(007).
         05  WK-KEY-YMD          PIC  9(008).
         05  WK-SEQNO            PIC  9(002).
         05  WK-KAISIK           PIC  9(004).
         05  WK-SYRYOK           PIC  9(004).
         05  WK-KMK-ERR          PIC  9(004).
         05  WK-DUP-FLG          PIC  X(001).
         05  WK-DUP-IX           PIC  9(002).
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
         05  SW-INIT             PIC  X(001).
*    メッセージ
     03  WK-NO                   PIC  X(006).
     03  WK-GUID                 PIC  X(006).
     03  WK-MESSAGE              PIC  N(038).
     03  WK-GAIDO                PIC  N(038).
*    添字
     03  IX1                     PIC  9(002).
     03  IX2                     PIC  9(002).
     03  IX-T1                   PIC  9(001).
     03  IX-T2                   PIC  9(002).
     03  IX-MSG                  PIC  9(003).
*
     03  WK-CHECK.
         05  WK-ERR              PIC  X(003).
*    テーブル
     03  TBL-AREA-X.
         05  TBL-AREA            OCCURS 30.
             07  T-JSK-FLG       PIC  X(001).
             07  T-DUP-FLG       PIC  X(001).
             07  T-KMK-ERR       PIC  9(004).
             07  T-KMK-STR       PIC  9(004).
             07  T-KMK-END       PIC  9(004).
         05  TBL-ALL-FLG         PIC  X(003).
         05  TBL-ERR-FLG         PIC  X(003).
         05  TBL-CHK-FLG         PIC  X(001).
         05  TBL-KAISI           PIC  9(004).
         05  TBL-SYURYO          PIC  9(004).
*
 01  WK-PGMID                    PIC  X(008) VALUE "D20090PO".
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
             NC"実績№を入力して下さい．".
         05  WK-MSGNO003         PIC  X(006) VALUE "MSG003".
         05  WK-MSGNM003         PIC  N(038) VALUE
             NC"製番を入力して下さい．".
         05  WK-MSGNO004         PIC  X(006) VALUE "MSG004".
         05  WK-MSGNM004         PIC  N(038) VALUE
             NC"項目指定を入力して下さい．".
         05  WK-MSGNO005         PIC  X(006) VALUE "MSG005".
         05  WK-MSGNM005         PIC  N(038) VALUE
             NC"ＳＥＱを入力して下さい．".
         05  WK-MSGNO006         PIC  X(006) VALUE "MSG006".
         05  WK-MSGNM006         PIC  N(038) VALUE
             NC"実績項目を入力して下さい．".
         05  WK-MSGNO007         PIC  X(006) VALUE "MSG007".
         05  WK-MSGNM007         PIC  N(038) VALUE
             NC"作業コード～職場コードを入力して下さい．".
         05  WK-MSGNO008         PIC  X(006) VALUE "MSG008".
         05  WK-MSGNM008         PIC  N(038) VALUE
             NC"ジャーナルを作成します．確認して下さい．".
         05  WK-MSGNO009         PIC  X(006) VALUE "MSG009".
         05  WK-MSGNM009         PIC  N(038) VALUE
             NC"ジャーナルを更新します．確認して下さい．".
         05  WK-MSGNO010         PIC  X(006) VALUE "MSG010".
         05  WK-MSGNM010         PIC  N(038) VALUE
             NC"ジャーナルを削除します．確認して下さい．".
         05  WK-MSGNO011         PIC  X(006) VALUE "MSG011".
         05  WK-MSGNM011         PIC  N(038) VALUE
             NC"実績項目を取消します．確認して下さい．".
*
         05  WK-MSGNO012         PIC  X(006) VALUE "ERR001".
         05  WK-MSGNM012         PIC  N(038) VALUE
             NC"処理区分が未入力です．".
         05  WK-MSGNO013         PIC  X(006) VALUE "ERR002".
         05  WK-MSGNM013         PIC  N(038) VALUE
             NC"処理区分が存在しません．".
         05  WK-MSGNO014         PIC  X(006) VALUE "ERR003".
         05  WK-MSGNM014         PIC  N(038) VALUE
             NC"実績№が未入力です．".
         05  WK-MSGNO015         PIC  X(006) VALUE "ERR004".
         05  WK-MSGNM015         PIC  N(038) VALUE
             NC"ジャーナルが存在しません．".
         05  WK-MSGNO016         PIC  X(006) VALUE "ERR005".
         05  WK-MSGNM016         PIC  N(038) VALUE
             NC"ジャーナルの製番が存在しません．".
         05  WK-MSGNO017         PIC  X(006) VALUE "ERR006".
         05  WK-MSGNM017         PIC  N(038) VALUE
             NC"製番が未入力です．".
         05  WK-MSGNO018         PIC  X(006) VALUE "ERR007".
         05  WK-MSGNM018         PIC  N(038) VALUE
             NC"製番が受注ファイルに存在しません．".
         05  WK-MSGNO019         PIC  X(006) VALUE "ERR008".
         05  WK-MSGNM019         PIC  N(038) VALUE
             NC"項目指定が未入力です．".
         05  WK-MSGNO020         PIC  X(006) VALUE "ERR009".
         05  WK-MSGNM020         PIC  N(038) VALUE
             NC"項目指定が存在しません．".
         05  WK-MSGNO021         PIC  X(006) VALUE "ERR010".
         05  WK-MSGNM021         PIC  N(038) VALUE
             NC"修正または取消を選択して下さい．".
*
         05  WK-MSGNO022         PIC  X(006) VALUE "ERR011".
         05  WK-MSGNM022         PIC  N(038) VALUE
             NC"実績項目の追加はこれ以上できません．".
         05  WK-MSGNO023         PIC  X(006) VALUE "ERR012".
         05  WK-MSGNM023         PIC  N(038) VALUE
             NC"実績項目が有りません．".
         05  WK-MSGNO024         PIC  X(006) VALUE "ERR013".
         05  WK-MSGNM024         PIC  N(038) VALUE
             NC"ＳＥＱが未入力です．".
         05  WK-MSGNO025         PIC  X(006) VALUE "ERR014".
         05  WK-MSGNM025         PIC  N(038) VALUE
             NC"ＳＥＱには１～３０の値を入力して下さい．".
         05  WK-MSGNO026         PIC  X(006) VALUE "ERR015".
         05  WK-MSGNM026         PIC  N(038) VALUE
             NC"ＳＥＱに対する実績項目が存在しません．".
         05  WK-MSGNO027         PIC  X(006) VALUE "ERR016".
         05  WK-MSGNM027         PIC  N(038) VALUE
             NC"実績項目が未入力です．".
         05  WK-MSGNO028         PIC  X(006) VALUE "ERR018".
         05  WK-MSGNM028         PIC  N(038) VALUE
             NC"開始実績項目が終了実績項目の値を越えています．".
         05  WK-MSGNO029         PIC  X(006) VALUE "ERR019".
         05  WK-MSGNM029         PIC  N(038) VALUE
             NC"実績項目が重複しています．".
         05  WK-MSGNO030         PIC  X(006) VALUE "ERR020".
         05  WK-MSGNM030         PIC  N(038) VALUE
             NC"実績項目が受注ファイルに存在しません．".
*
         05  WK-MSGNO031         PIC  X(006) VALUE "ERR021".
         05  WK-MSGNM031         PIC  N(038) VALUE
             NC"実績済になっています．".
         05  WK-MSGNO032         PIC  X(006) VALUE "ERR022".
         05  WK-MSGNM032         PIC  N(038) VALUE
             NC"ジャーナルに存在します．".
         05  WK-MSGNO033         PIC  X(006) VALUE "ERR023".
         05  WK-MSGNM033         PIC  N(038) VALUE
             NC"作業コードが未入力です．".
         05  WK-MSGNO034         PIC  X(006) VALUE "ERR024".
         05  WK-MSGNM034         PIC  N(038) VALUE
             NC"生産の作業コードではありません．".
         05  WK-MSGNO035         PIC  X(006) VALUE "ERR025".
         05  WK-MSGNM035         PIC  N(038) VALUE
             NC"作業コードが作業マスタに存在しません．".
         05  WK-MSGNO036         PIC  X(006) VALUE "ERR026".
         05  WK-MSGNM036         PIC  N(038) VALUE
             NC"カレンダマスタに存在しません．".
         05  WK-MSGNO037         PIC  X(006) VALUE "ERR027".
         05  WK-MSGNM037         PIC  N(038) VALUE
             NC"未来の日付は入力できません．".
         05  WK-MSGNO038         PIC  X(006) VALUE "ERR028".
         05  WK-MSGNM038         PIC  N(038) VALUE
             NC"日付が未入力です．".
         05  WK-MSGNO039         PIC  X(006) VALUE "ERR029".
         05  WK-MSGNM039         PIC  N(038) VALUE
             NC"開始日が完了日を越えています．".
         05  WK-MSGNO040         PIC  X(006) VALUE "ERR030".
         05  WK-MSGNM040         PIC  N(038) VALUE
             NC"職場コードが未入力です．".
*
         05  WK-MSGNO041         PIC  X(006) VALUE "ERR031".
         05  WK-MSGNM041         PIC  N(038) VALUE
             NC"職場コードが組織マスタに存在しません．".
         05  WK-MSGNO042         PIC  X(006) VALUE "ERR032".
         05  WK-MSGNM042         PIC  N(038) VALUE
             NC"ＰＦキーエラーです．".
         05  WK-MSGNO043         PIC  X(006) VALUE "ERR033".
         05  WK-MSGNM043         PIC  N(038) VALUE
             NC"完了日は当日日付以外入力できません．".
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
     DISPLAY "*      AHATML1  UPD    = "  CNT-HAT        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CSEIJL1  OUT    = "  CNT-WRT        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CSEIJL1  UPD    = "  CNT-UPD        "   *"
                                                     UPON    DSP.
     DISPLAY "*      CSEIJL1  DEL    = "  CNT-DEL        "   *"
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
     INITIALIZE                  ST-AREA  WK-SAVE  DSP-AREA.
*
*    ＦＩＬＥ　ＯＰＥＮ
     OPEN         I-O            DSP-F.
     OPEN         INPUT          AJUGFL1  AJUKFL1  CJISFL1
                                 ASOSML1  ASIYML1  CSAGML1
                                 CSEIJL2  AJKNML1  CCALML1.
     OPEN         I-O            CSEIJL1  AHATML1.
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
     MOVE      JCD23 OF AJKNML1  TO    WK-SKA-CD.
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
     MOVE    SPACE               TO    D20090D1.
     INITIALIZE                        D20090D1.
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
               ELSE
                 EVALUATE  WK-SYRKBN
                     WHEN  1
                           GO    TO    MAIN-040
                     WHEN  2
                     WHEN  3
                           GO    TO    MAIN-030
                 END-EVALUATE
               END-IF
         WHEN  "F010"
               MOVE  "END"       TO    SW-END
*
*            トランザクション終了
               CALL      "XMROTEND"
               GO   TO           MAIN-999
         WHEN  OTHER
*                                < PFｷｰｴﾗｰ >
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-020
     END-EVALUATE.
*
 MAIN-030.
*                                < ｼﾞｯｾｷﾅﾝﾊﾞｰ ｦ ﾆｭｳﾘｮｸｼﾃｸﾀﾞｻｲ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG002"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-035.
*  実績№
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
                 GO   TO         MAIN-035
               ELSE
                 EVALUATE  WK-SYRKBN
                     WHEN  2
                           MOVE  "1"   TO    TBL-CHK-FLG
                           GO    TO    MAIN-050
                     WHEN  3
                           GO    TO    MAIN-090
                 END-EVALUATE
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR2-SEC
               MOVE  ZERO        TO    JSKBAN OF D20090D1
               MOVE  SPACE       TO    SEIBAN OF D20090D1
                                       KENMEI OF D20090D1
                                       TANTOU OF D20090D1
                                       SIYOU1 OF D20090D1
                                       SIYOU2 OF D20090D1
               GO   TO           MAIN-015
         WHEN  OTHER
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-035
     END-EVALUATE.
*
 MAIN-040.
*                                < ｾｲﾊﾞﾝ ﾆｭｳﾘﾖｸ ﾖｳｷｭｳ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG003"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-045.
*  製番入力
     MOVE    "NE"                TO    DSP-MODE.
     MOVE    "GRP003"            TO    DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               PERFORM           CHECK3-SEC
               IF    WK-ERR      =   "ERR"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-045
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR3-SEC
               MOVE   SPACE      TO    SEIBAN OF D20090D1
                                       KENMEI OF D20090D1
                                       TANTOU OF D20090D1
                                       SIYOU1 OF D20090D1
                                       SIYOU2 OF D20090D1
               GO   TO           MAIN-015
         WHEN  OTHER
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-045
     END-EVALUATE.
*
 MAIN-050.
*                                < ｺｳﾓｸｼﾃｲｦ ﾆｭｳﾘｮｸ ｼﾃｸﾀﾞｻｲ >
     MOVE    "GID002"            TO    WK-GUID.
     MOVE    "MSG004"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-055.
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
                 GO   TO         MAIN-055
               ELSE
                 EVALUATE  KSTKBN OF D20090D1
                     WHEN  1
                           GO    TO   MAIN-070
                     WHEN  2
                           IF  SEQNO  OF D20090D1 = ZERO
                           THEN
                             GO  TO   MAIN-060
                           ELSE
                             GO  TO   MAIN-070
                           END-IF
                     WHEN  3
                           IF  SEQNO  OF D20090D1 = ZERO
                           THEN
                             GO  TO   MAIN-060
                           ELSE
                             GO  TO   MAIN-090
                           END-IF
                 END-EVALUATE
               END-IF
         WHEN  "F005"
               MOVE    SPACE     TO    D20090D1
               INITIALIZE              D20090D1
               PERFORM           ATR-CLR4-SEC
               PERFORM           ATR-CLR6-SEC
               INITIALIZE        WK-SAVE-AREA
                                 TBL-AREA-X
*
               MOVE      WK-SYRKBN        TO    SYRKBN OF D20090D1
               EVALUATE  WK-SYRKBN
                   WHEN  1
                         PERFORM          MEISAI-SET-SEC
                         MOVE  WK-SEIBAN  TO    SEIBAN OF D20090D1
                         GO    TO  MAIN-040
                   WHEN  2
                         MOVE  WK-JSKBAN  TO    JSKBAN OF D20090D1
                         MOVE  "1"        TO    TBL-CHK-FLG
                         GO    TO  MAIN-030
               END-EVALUATE
         WHEN  "F006"
               PERFORM           ATR-CLR4-SEC
               PERFORM           ZERO-CHK-SEC
               IF  WK-NO         = "ERR012"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-075
               ELSE
                 GO   TO         MAIN-080
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-055
     END-EVALUATE.
*
 MAIN-060.
*                                < SEQ ｦ ﾆｭｳﾘｮｸ ｼﾃ ｸﾀﾞｻｲ >
     MOVE    "GID002"            TO    WK-GUID.
     MOVE    "MSG005"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-065.
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
                 GO   TO         MAIN-065
               ELSE
                 EVALUATE  KSTKBN OF D20090D1
                     WHEN  2
                           GO  TO    MAIN-070
                     WHEN  3
                           GO  TO    MAIN-090
                 END-EVALUATE
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR5-SEC
               IF    TBL-ERR-FLG = SPACE
               THEN
                 MOVE  SPACE     TO    WK-ERR
                 MOVE  ZERO      TO    SEQNO  OF D20090D1
                                       JISKFR OF D20090D1
                                       JISKBY OF D20090D1
                                       ERRKMK OF D20090D1
               END-IF
               GO   TO           MAIN-050
         WHEN  "F006"
               PERFORM           ATR-CLR5-SEC
               PERFORM           ZERO-CHK-SEC
               IF  WK-NO         = "ERR012"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-075
               ELSE
                 GO   TO         MAIN-080
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-065
     END-EVALUATE.
*
 MAIN-070.
*                                < ｼｼﾞｺｳﾓｸ ｦ ﾆｭｳﾘｮｸ ｼﾃ ｸﾀﾞｻｲ >
     MOVE    "GID002"            TO    WK-GUID.
     MOVE    "MSG006"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
 MAIN-075.
* 実績項目入力
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
                   IF  TBL-ALL-FLG = "ALL"
                   THEN
                     MOVE  SPACE TO    TBL-ALL-FLG
                   END-IF
                   PERFORM       KMKERR-SET-SEC
*
*                  新規入力で重複／実績エラー時のﾃｰﾌﾞﾙﾁｪｯｸ
                   MOVE   SEQNO  OF D20090D1    TO   IX1
                                                     WK-SEQNO
                   PERFORM       IDX-SET-SEC
                   IF     KAISI  OF D20090D1(IX-T1 IX-T2) = ZERO
                   THEN
                     MOVE  1     TO    KSTKBN OF D20090D1
                     MOVE  ZERO  TO    SEQNO  OF D20090D1
                     MOVE  ZERO  TO    T-KMK-ERR(IX1)
                                       T-KMK-STR(IX1)
                                       T-KMK-END(IX1)
                     MOVE  SPACE TO    T-DUP-FLG(IX1)
                                       T-JSK-FLG(IX1)
                                       TBL-ERR-FLG
                   END-IF
                 END-IF
                 PERFORM         DSP-WRITE-SEC
                 GO   TO         MAIN-075
               ELSE
                 IF  TBL-ALL-FLG =   "ALL"
                 THEN
                   GO TO         MAIN-080
                 ELSE
                   EVALUATE  KSTKBN OF D20090D1
                       WHEN  1
                             IF    T-KMK-STR(30) NOT = ZERO
                             THEN
                               GO  TO  MAIN-080
                             ELSE
                               GO  TO  MAIN-070
                             END-IF
                       WHEN  2
                             MOVE  ZERO  TO    SEQNO  OF D20090D1
                                               JISKFR OF D20090D1
                                               JISKBY OF D20090D1
                             GO  TO    MAIN-060
                   END-EVALUATE
                 END-IF
               END-IF
         WHEN  "F005"
               IF    TBL-ERR-FLG =    SPACE
               THEN
                 PERFORM         KMKERR-SET-SEC
                 IF  ERRKMK OF D20090D1 = ZERO
                 THEN
                   PERFORM       ATR-CLR6-SEC
                   MOVE  SPACE   TO    WK-ERR
                   MOVE  ZERO    TO    SEQNO  OF D20090D1
                                       JISKFR OF D20090D1
                                       JISKBY OF D20090D1
                                       ERRKMK OF D20090D1
                 END-IF
               ELSE
*                新規入力で重複／実績エラー時のﾃｰﾌﾞﾙﾁｪｯｸ
                 IF    SEQNO  OF D20090D1    =  ZERO
                 THEN
                   MOVE  WK-SEQNO             TO    IX1
                 ELSE
                   MOVE  SEQNO   OF D20090D1  TO    IX1
                 END-IF
                 PERFORM         IDX-SET-SEC
*
                 IF    KAISI  OF D20090D1(IX-T1 IX-T2) = ZERO
                 THEN
                   MOVE  1       TO    KSTKBN OF D20090D1
                   MOVE  ZERO    TO    SEQNO  OF D20090D1
                                       JISKFR OF D20090D1
                                       JISKBY OF D20090D1
                                       ERRKMK OF D20090D1
                   MOVE  ZERO    TO    T-KMK-ERR(IX1)
                                       T-KMK-STR(IX1)
                                       T-KMK-END(IX1)
                   MOVE  SPACE   TO    T-DUP-FLG(IX1)
                                       T-JSK-FLG(IX1)
                                       TBL-ERR-FLG
                   MOVE  1       TO    KSTKBN OF D20090D1
                 ELSE
                   IF    T-KMK-ERR(IX1) = ZERO
                   THEN
                     MOVE  ZERO  TO    ERRKMK OF D20090D1
                                       JISKFR OF D20090D1
                                       JISKBY OF D20090D1
                                       SEQNO  OF D20090D1
                     MOVE  SPACE TO    T-JSK-FLG(IX1)
                                       T-DUP-FLG(IX1)
                     PERFORM     ATR-CLR6-SEC
                   ELSE
                     MOVE  T-KMK-ERR(IX1)
                                 TO    ERRKMK OF D20090D1
                     MOVE  T-KMK-STR(IX1)
                                 TO    JISKFR OF D20090D1
                     MOVE  T-KMK-END(IX1)
                                 TO    JISKBY OF D20090D1
                   END-IF
                 END-IF
               END-IF
               GO   TO           MAIN-050
         WHEN  "F006"
               PERFORM           ATR-CLR6-SEC
               PERFORM           ZERO-CHK-SEC
               IF  WK-NO         =   "ERR012"
               THEN
                 PERFORM         DSP-WRITE-SEC
                 GO    TO        MAIN-075
               ELSE
                 GO    TO        MAIN-080
               END-IF
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-075
     END-EVALUATE.
*
 MAIN-080.
*                                < ｻｷﾞｮｳｺｰﾄﾞ ｶﾗ ｼｼﾞｺｳｽｳｦ ﾆｭｳﾘｮｸ >
     MOVE    "GID003"            TO    WK-GUID.
     MOVE    "MSG007"            TO    WK-NO.
     PERFORM                     DSP-WRITE-SEC.
*
* 入力前の作業コード／完了日をＷＫへ退避
     MOVE    SGYCD  OF D20090D1  TO    WK-SGYCD.
     MOVE    ENDDAY OF D20090D1  TO    WK-ENDDAY-S.
*
 MAIN-085.
* 作業コードから職場コード入力
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
                   IF  ERRKMK OF D20090D1  = ZERO
                   THEN
                     GO   TO     MAIN-090
                   ELSE
                     PERFORM     DSP-WRITE-SEC
                     GO   TO     MAIN-075
                   END-IF
                 ELSE
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-085
                 END-IF
               END-IF
         WHEN  "F005"
               PERFORM           ATR-CLR7-SEC
               IF  ( WK-SGYCD    NOT = SGYCD  OF D20090D1 )  OR
                   ( WK-ENDDAY-S NOT = ENDDAY OF D20090D1 )
               THEN
                 IF  WK-SGYCD    NOT = SGYCD  OF D20090D1
                 THEN
                   MOVE  SPACE   TO    SGYNM  OF D20090D1
                 END-IF
*
                 MOVE  SPACE     TO    TBL-CHK-FLG
                                       TBL-ERR-FLG
                 PERFORM    VARYING    IX1     FROM  1  BY  1
                            UNTIL    ( IX1            >  30  )
                            OR       ( T-KMK-STR(IX1) = ZERO )
                     MOVE  SPACE TO    T-JSK-FLG(IX1)
                                       T-DUP-FLG(IX1)
                     MOVE  ZERO  TO    T-KMK-ERR(IX1)
                 END-PERFORM
               END-IF
*
               IF    TBL-ALL-FLG  =    "ALL"
               THEN
                 MOVE  1         TO    KSTKBN OF D20090D1
                 MOVE  ZERO      TO    SEQNO  OF D20090D1
                                       JISKFR OF D20090D1
                                       JISKBY OF D20090D1
                                       KAISI  OF D20090D1(1 1)
                                       SYURYO OF D20090D1(1 1)
                                       T-KMK-STR         (1)
                                       T-KMK-END         (1)
                 MOVE  SPACE     TO    TBL-ALL-FLG
                                       TBL-ERR-FLG
                                       TBL-CHK-FLG
                                       T-JSK-FLG         (1)
                                       T-DUP-FLG         (1)
               END-IF
               GO  TO  MAIN-050
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-085
     END-EVALUATE.
*
 MAIN-090.
     EVALUATE  WK-SYRKBN
         WHEN  1
               IF      KSTKBN OF D20090D1  =     3
               THEN
*                                < ｼﾞｯｾｷｺｳﾓｸｦ ﾄﾘｹｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
                 MOVE  "MSG011"  TO    WK-NO
               ELSE
*                                < ｼﾞｬｰﾅﾙｦ ｻｸｾｲｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
                 MOVE  "MSG008"  TO    WK-NO
               END-IF
         WHEN  2
               IF      KSTKBN OF D20090D1  =     3
               THEN
*                                < ｼﾞｯｾｷｺｳﾓｸｦ ﾄﾘｹｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
                 MOVE  "MSG011"  TO    WK-NO
               ELSE
*                                < ｼﾞｬｰﾅﾙｦ ｺｳｼﾝｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
                 MOVE  "MSG009"  TO    WK-NO
               END-IF
         WHEN  3
*                                < ｼﾞｬｰﾅﾙｦ ｻｸｼﾞｮｼﾏｽ ｶｸﾆﾝｼﾃｸﾀﾞｻｲ >
                 MOVE  "MSG010"  TO    WK-NO
     END-EVALUATE
*
     MOVE      SPACE             TO    DUMMY.
     MOVE     "GID003"           TO    WK-GUID.
     PERFORM                     DSP-WRITE-SEC.
*
 MAIN-095.
*  ダミー　入力
     MOVE    "NE"                TO  DSP-MODE.
     MOVE    "GRP008"            TO  DSP-GROUP.
     PERFORM                     DSP-READ-SEC.
*
     EVALUATE  DSP-FUNC
         WHEN  "E000"
               IF   ( WK-SYRKBN          =  1  OR  2 ) AND
                    ( KSTKBN OF D20090D1 =  3        )
               THEN
*              項目取消処理を行う
                 PERFORM         KMK-DEL-SEC
                 PERFORM         KMKERR-SET-SEC
                 IF  ERRKMK OF   D20090D1 = ZERO
                 THEN
*                  削除後テーブルに明細０件の場合項目指定へ
                   IF   KAISI OF D20090D1(1 1) = ZERO
                   THEN
                     MOVE  1     TO    KSTKBN OF D20090D1
                     MOVE  ZERO  TO    SEQNO  OF D20090D1
                     GO    TO    MAIN-050
                   ELSE
                     GO    TO    MAIN-060
                   END-IF
                 ELSE
                   PERFORM       DSP-WRITE-SEC
                   GO   TO       MAIN-075
                 END-IF
               END-IF
*              ファイル更新処理を行う
               PERFORM           FILE-UPD-SEC
*
               MOVE  SPACE       TO    TBL-CHK-FLG
               EVALUATE  WK-SYRKBN
                  WHEN   1
                         MOVE  WK-JSKBAN  TO  JSKBAN OF D20090D1
                         MOVE  SPACE      TO  SGYCD  OF D20090D1
                                              SKBCD  OF D20090D1
                                              SGYNM  OF D20090D1
                                              SKBNM  OF D20090D1
                         GO  TO     MAIN-080
                  WHEN   2
                  WHEN   3
                         MOVE    SPACE    TO    D20090D1
                         INITIALIZE             D20090D1
                         INITIALIZE       WK-SAVE-AREA
                                          TBL-AREA-X
                         MOVE  WK-SYRKBN  TO SYRKBN OF D20090D1
                         GO  TO     MAIN-030
               END-EVALUATE
         WHEN  "F005"
               EVALUATE  WK-SYRKBN
                  WHEN   1
                  WHEN   2
                      IF    KSTKBN OF D20090D1  =     3
                      THEN
                        IF  T-JSK-FLG (SEQNO OF D20090D1) = SPACE
                                                            AND
                            T-DUP-FLG (SEQNO OF D20090D1) = SPACE
                        THEN
                          GO  TO        MAIN-060
                        ELSE
                          GO  TO        MAIN-050
                        END-IF
                      ELSE
                        GO    TO        MAIN-080
                      END-IF
                  WHEN   3
                         MOVE    SPACE    TO    D20090D1
                         INITIALIZE             D20090D1
                         INITIALIZE       WK-SAVE-AREA
                                          TBL-AREA-X
                         MOVE  WK-SYRKBN  TO SYRKBN OF D20090D1
                         MOVE  WK-JSKBAN  TO JSKBAN OF D20090D1
                         GO  TO   MAIN-030
               END-EVALUATE
         WHEN  OTHER
*                                < PFｷｰ ｴﾗｰ ﾃﾞｽ >
               MOVE  "ERR032"    TO    WK-NO
               PERFORM           DSP-WRITE-SEC
               GO   TO           MAIN-095
     END-EVALUATE.
 MAIN-999.
     EXIT.
/*****************************************************************
*    後　処　理
******************************************************************
 FINAL-SEC                       SECTION.
 FINAL-010.
*    ＦＩＬＥ　ＣＬＯＳＥ
     CLOSE                       AJUGFL1  AJUKFL1  CJISFL1
                                 ASOSML1  ASIYML1  CSAGML1
                                 CSEIJL2  CCALML1  AJKNML1
                                 CSEIJL1  AHATML1  DSP-F.
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
     IF         ST-CJISFL        NOT =   "00"
     THEN
       MOVE    "CJISFL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CJISFL        TO    WK-STATUS
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
       MOVE    "CCALML "         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CJISFL        TO    WK-STATUS
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
     IF         ST-CSEIJL2       NOT =   "00"
     THEN
       MOVE    "CSEIJL2"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CSEIJL2       TO    WK-STATUS
       PERFORM  ABEND-SEC
     END-IF.
*
     IF         ST-CSEIJL1       NOT =   "00"
     THEN
       MOVE    "CSEIJL1"         TO    WK-FILE
       MOVE    "OPEN"            TO    WK-SYORI
       MOVE     ST-CSEIJL1       TO    WK-STATUS
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
                                                   OF D20090D1.
     MOVE    SPACE               TO    EDIT-CURSOR OF SYRKBN
                                                   OF D20090D1.
*
     IF        SYRKBN OF D20090D1 =    ZERO
     THEN
*                                < ｼｮﾘｸﾌﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "R"               TO    EDIT-COLOR OF SYRKBN
                                                  OF D20090D1
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR001"          TO    WK-NO
     ELSE
       IF      SYRKBN OF D20090D1 =    1  OR  2  OR  3
       THEN
         IF    SYRKBN OF D20090D1 =    1
         THEN
           MOVE  ZERO            TO    JSKBAN OF D20090D1
         END-IF
         MOVE    SYRKBN OF D20090D1
                                 TO    WK-SYRKBN
       ELSE
*                                < ｼｮﾘｸﾌﾞﾝ ｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE  "R"               TO    EDIT-COLOR OF SYRKBN
                                                  OF D20090D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR002"          TO    WK-NO
       END-IF
     END-IF.
 CHECK1-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ２処理　　－　実績№　－
******************************************************************
 CHECK2-SEC                      SECTION.
 CHECK2-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR2-SEC.
*
     IF      JSKBAN OF D20090D1  =     ZERO
     THEN
*                                < ｼﾞｯｾｷﾅﾝﾊﾞｰｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR003"          TO    WK-NO
     ELSE
*      実績№実存チェック( 生産実績ｼﾞｬｰﾅﾙ )
       MOVE  JSKBAN OF D20090D1  TO    WK-JSKBAN
       PERFORM                   SEIJ1-READ-SEC
       IF    SW-INV              =    "INV"
       THEN
*                                < ｼﾞｬｰﾅﾙ ｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR004"          TO    WK-NO
       ELSE
*      実績№実存チェック( 受注ﾌｧｲﾙ(鑑) )
         MOVE  SEIBAN OF CSEIJL1 TO    WK-SEIBAN
         PERFORM                 JUGF-READ-SEC
         IF  SW-INV              =    "INV"
         THEN
*                                < ｼﾞｬｰﾅﾙﾉ ｾｲﾊﾞﾝｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR005"        TO    WK-NO
         END-IF
       END-IF
     END-IF.
*
     IF         WK-ERR           =     "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF JSKBAN
                                                   OF D20090D1
     ELSE
*      エラーがない場合　画面へジャーナル情報をセットする
*
       MOVE    WK-SEIBAN         TO    SEIBAN OF D20090D1
*      製番．件名．担当名．仕様をセットする
       PERFORM                   MEISAI-SET-SEC
*      その他の情報をセットする
*     (実績項目　開始～終了）
       MOVE    1                 TO    IX-T1  IX-T2
*
       PERFORM     VARYING  IX1  FROM  1  BY  1
                   UNTIL    IX1  >     30
*
           IF      KAISIK OF CSEIJL1 (IX1)   = ZERO
           THEN
             MOVE  30        TO    IX1
           ELSE
             MOVE  KAISIK OF CSEIJL1(IX1)
                             TO    KAISI  OF D20090D1(IX-T1 IX-T2)
                                   T-KMK-STR(IX1)
             MOVE  SYRYOK OF CSEIJL1(IX1)
                             TO    SYURYO OF D20090D1(IX-T1 IX-T2)
                                   T-KMK-END(IX1)
             ADD   1         TO    IX-T2
             IF    IX-T2     =     11  OR  21
             THEN
               ADD    1      TO    IX-T1
               MOVE   1      TO    IX-T2
             END-IF
           END-IF
       END-PERFORM
*
*     (作業コード　名称）
       MOVE    WORKNY OF CSEIJL1 TO    SGYCD  OF D20090D1
                                       WK-WORKCD
       PERFORM                         SAGM-READ-SEC
       IF    SW-INV   =  "INV"
       THEN
         MOVE  SPACE             TO    SGYNM OF D20090D1
       ELSE
         MOVE  WNEI OF CSAGML1   TO    SGYNM OF D20090D1
       END-IF
*     (開始日　完了日）
       MOVE    KAISID OF CSEIJL1 TO    WK-STRDAY
       MOVE    WK-STRDAY (3:6)   TO    STRDAY OF D20090D1
       MOVE    KANRYD OF CSEIJL1 TO    WK-ENDDAY
       MOVE    WK-ENDDAY (3:6)   TO    ENDDAY OF D20090D1
*     (職場コード　名称）
       MOVE    JSKOFC OF CSEIJL1 TO    SKBCD  OF D20090D1
                                       WK-SOSICD
       PERFORM                   SOSM-READ-SEC
       IF      SW-INV   =  "INV"
       THEN
         MOVE  SPACE             TO    SKBNM  OF D20090D1
       ELSE
         MOVE  BSYNAM OF ASOSML1 TO    SKBNM OF D20090D1
       END-IF
     END-IF.
 CHECK2-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ３処理　　－　製番　－
******************************************************************
 CHECK3-SEC                      SECTION.
 CHECK3-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR3-SEC.
*
*  製番
     IF      SEIBAN OF D20090D1  =     SPACE
     THEN
*                                < ｾｲﾊﾞﾝ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR006"          TO    WK-NO
     ELSE
*      実存チェック( 受注ファイル（鑑）)
       MOVE  SEIBAN OF D20090D1  TO    WK-SEIBAN
       PERFORM                   JUGF-READ-SEC
       IF      SW-INV            =    "INV"
       THEN
*                                < ｾｲﾊﾞﾝｶﾞ ｼﾞｭﾁｭｳFﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR007"        TO    WK-NO
       END-IF
     END-IF.
*
     IF    WK-ERR    =    "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF SEIBAN
                                                   OF D20090D1
     ELSE
*      製番．件名．担当名．仕様をセット
       PERFORM                   MEISAI-SET-SEC
*      項目指定初期値設定
       MOVE    1                 TO    KSTKBN OF D20090D1
     END-IF.
 CHECK3-999.
     EXIT.
/*****************************************************************
*    明細セット処理（製番入力後セットされる項目）
******************************************************************
 MEISAI-SET-SEC                  SECTION.
 MEISAI-SET-010.
*
*  件名（受注ファイル（鑑）より）
     MOVE    KENMEI OF AJUGFL1   TO    KENMEI OF D20090D1.
*
*  担当名（組織マスタより）
     MOVE    SOSICD OF AJUGFL1   TO    WK-SOSICD.
     PERFORM                     SOSM-READ-SEC.
     IF      SW-INV =  "INV"
     THEN
       MOVE  SPACE               TO    TANTOU OF D20090D1
     ELSE
       MOVE  TANNAM OF ASOSML1   TO    TANTOU OF D20090D1
     END-IF.
*
*  仕様１（仕様マスタより）
     MOVE    SIYOU1 OF AJUGFL1   TO    WK-SIYOU.
     PERFORM                     SIYM-READ-SEC.
     IF      SW-INV =  "INV"
     THEN
       MOVE  SPACE               TO    SIYOU1 OF D20090D1
     ELSE
       MOVE  SIYONA OF ASIYML1   TO    SIYOU1 OF D20090D1
     END-IF.
*  仕様２（仕様マスタより）
     MOVE    SIYOU2 OF AJUGFL1   TO    WK-SIYOU.
     PERFORM                     SIYM-READ-SEC.
     IF      SW-INV =  "INV"
     THEN
       MOVE  SPACE               TO    SIYOU2 OF D20090D1
     ELSE
       MOVE  SIYONA OF ASIYML1   TO    SIYOU2 OF D20090D1
     END-IF.
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
     IF      KSTKBN OF D20090D1  =     ZERO
     THEN
*                                < ｺｳﾓｸ ｼﾃｲｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "R"               TO    EDIT-COLOR  OF KSTKBN
                                                   OF D20090D1
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR008"          TO    WK-NO
     ELSE
*
       IF    KSTKBN OF D20090D1  =    1  OR  2  OR  3
       THEN
*        実績フラグ="1"または重複フラグ="1"の場合
*                                         追加処理はエラーとなる
         PERFORM  VARYING  IX1  FROM  1  BY  1
                  UNTIL    IX1  > 30
             IF   ( T-JSK-FLG(IX1)     = "1")   OR
                  ( T-DUP-FLG(IX1)     = "1")
             THEN
               MOVE  T-KMK-STR(IX1)
                                 TO    JISKFR     OF D20090D1
               MOVE  T-KMK-END(IX1)
                                 TO    JISKBY     OF D20090D1
               MOVE  T-KMK-ERR(IX1)
                                 TO    ERRKMK     OF D20090D1
               MOVE  IX1         TO    SEQNO      OF D20090D1
               MOVE  "R"         TO    EDIT-COLOR OF JISKFR
                                                  OF D20090D1
                                       EDIT-COLOR OF JISKBY
                                                  OF D20090D1
                                       EDIT-COLOR OF ERRKMK
                                                  OF D20090D1
*
               IF  KSTKBN OF D20090D1  =  1
               THEN
*                                < ｼｭｳｾｲ ﾏﾀﾊ ﾄﾘｹｼ ｦ ｾﾝﾀｸｼﾃ ｸﾀﾞｻｲ >
                 MOVE  "ERR"     TO    WK-ERR
                 MOVE  "ERR010"  TO    WK-NO
               END-IF
               MOVE    30        TO    IX1
             END-IF
         END-PERFORM
*
*       追加時にテーブルが３０件フル入力時エラー
         IF  ( KSTKBN OF D20090D1   =      1 )  AND
             ( T-KMK-STR(30)  NOT   =   ZERO )
         THEN
*                                < ｼｼﾞｺｳﾓｸﾉ ﾂｲｶﾊ ｺﾚｲｼﾞｮｳ ﾃﾞｷﾏｾﾝ >
           IF      WK-ERR  =  SPACE
           THEN
             MOVE  "R"           TO    EDIT-COLOR  OF KSTKBN
                                                   OF D20090D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR011"      TO    WK-NO
           END-IF
         END-IF
       ELSE
*                                < ｺｳﾓｸｼﾃｲｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ >
         MOVE    "R"             TO    EDIT-COLOR  OF KSTKBN
                                                   OF D20090D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR009"        TO    WK-NO
       END-IF
     END-IF.
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
     IF      SEQNO  OF D20090D1  =     ZERO
     THEN
*                                < SEQ ｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR013"          TO    WK-NO
     ELSE
       IF  ( SEQNO OF D20090D1   >=   1  )    AND
           ( SEQNO OF D20090D1   <=   30 )
       THEN
*        テーブルに実績項目が設定されていること
         MOVE  SEQNO OF D20090D1 TO    IX1
*
         IF    T-KMK-STR(IX1)     >    ZERO
         THEN
           MOVE  T-KMK-STR(IX1)  TO    JISKFR OF D20090D1
           MOVE  T-KMK-END(IX1)  TO    JISKBY OF D20090D1
         ELSE
*                                < SEQ ﾆ ﾀｲｽﾙ ｼｼﾞｺｳﾓｸｶﾞ ｿﾝｻﾞｲｼﾏｾﾝ>
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR015"        TO    WK-NO
           MOVE  30              TO    IX1
         END-IF
       ELSE
*                                < SEQ ﾆﾊ 1～30 ｦ ﾆｭｳﾘｮｸｼﾃｸﾀﾞｻｲ>
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR014"        TO    WK-NO
       END-IF
     END-IF.
*
     IF        WK-ERR   =   "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF SEQNO
                                                   OF D20090D1
     END-IF.
 CHECK5-999.
     EXIT.
/*****************************************************************
*    ＣＨＥＣＫ６処理　　－　実績項目　－
******************************************************************
 CHECK6-SEC                      SECTION.
 CHECK6-010.
*
     INITIALIZE                  WK-ERR  TBL-ERR-FLG.
     PERFORM                     ATR-CLR6-SEC.
     MOVE    ZERO                TO    ERRKMK OF D20090D1
                                       WK-KMK-ERR.
*
     IF      JISKFR OF D20090D1  =     ZERO
     THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR016"          TO    WK-NO
     ELSE
       IF    JISKBY OF D20090D1   =    ZERO
       THEN
         MOVE JISKFR OF D20090D1 TO    JISKBY OF D20090D1
       END-IF
*      大小関係チェック
       IF    JISKFR OF D20090D1  <=  JISKBY OF D20090D1
       THEN
*
         PERFORM  VARYING  IX1   FROM  1  BY  1
                  UNTIL  ( IX1            >  30   )
                  OR     ( T-KMK-STR(IX1) =  ZERO )
*
             IF  ( KSTKBN OF D20090D1  =   2   )       AND
                 ( SEQNO  OF D20090D1  =   IX1 )
             THEN
               CONTINUE
             ELSE
*                チェック１
               IF   JISKFR OF D20090D1 >  T-KMK-STR(IX1)  AND
                    JISKFR OF D20090D1 <= T-KMK-END(IX1)
               THEN
                 MOVE  JISKFR OF D20090D1
                                 TO    ERRKMK OF D20090D1
               ELSE
*                チェック２
                 IF   JISKBY OF D20090D1 >  T-KMK-STR(IX1)  AND
                      JISKBY OF D20090D1 <= T-KMK-END(IX1)
                 THEN
                   MOVE  T-KMK-STR(IX1)
                                 TO    ERRKMK OF D20090D1
                 ELSE
*                チェック３
                   IF   JISKFR OF D20090D1 <  T-KMK-STR(IX1)  AND
                        JISKBY OF D20090D1 >= T-KMK-END(IX1)
                   THEN
                     MOVE  T-KMK-STR(IX1)
                                 TO    ERRKMK OF D20090D1
                   ELSE
*                チェック４
                     IF  JISKFR OF D20090D1 >  T-KMK-STR(IX1) AND
                         JISKBY OF D20090D1 <= T-KMK-END(IX1)
                     THEN
                       MOVE  JISKFR OF D20090D1
                                 TO    ERRKMK OF D20090D1
                     ELSE
*                チェック５
                       IF JISKFR OF D20090D1 = T-KMK-STR(IX1) OR
                          JISKFR OF D20090D1 = T-KMK-END(IX1)
                       THEN
                         MOVE  JISKFR OF D20090D1
                                 TO    ERRKMK OF D20090D1
                       ELSE
                         IF  JISKBY OF D20090D1 = T-KMK-STR(IX1)
                                                             OR
                             JISKBY OF D20090D1 = T-KMK-END(IX1)
                         THEN
                           MOVE  JISKBY OF D20090D1
                                 TO    ERRKMK OF D20090D1
                         END-IF
                       END-IF
                     END-IF
                   END-IF
                 END-IF
               END-IF
*
               IF  ERRKMK OF D20090D1 NOT = ZERO
               THEN
*                                < ｼﾞｭｳﾌｸ ｼﾃｲﾏｽ >
                 MOVE  "ERR"     TO    WK-ERR
                 MOVE  "ERR019"  TO    WK-NO
                 MOVE   30       TO    IX1
               END-IF
             END-IF
         END-PERFORM
       ELSE
*                                < ｶｲｼｶﾞ ｼｭｳﾘｮｳ ｦ ｺｴﾃｲﾏｽ >
         MOVE  JISKFR OF D20090D1
                                 TO    ERRKMK OF D20090D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR018"          TO    WK-NO
       END-IF
     END-IF.
*
*  単体チェックでエラーの場合は処理を抜ける
     IF    WK-ERR   = "ERR"
     THEN
       IF  WK-NO    = "ERR016"
       THEN
         CONTINUE
       ELSE
         MOVE  "R"     TO    EDIT-COLOR  OF ERRKMK OF D20090D1
       END-IF
*
       MOVE    "R"     TO    EDIT-COLOR  OF JISKFR OF D20090D1
                             EDIT-COLOR  OF JISKBY OF D20090D1
       MOVE    "C"     TO    EDIT-CURSOR OF JISKFR OF D20090D1
       GO      TO            CHECK6-999
     END-IF.
*
*--＊実績項目　1～9999　　の場合---------------------------*
     IF  ( JISKFR OF D20090D1    = 1       AND
           JISKBY OF D20090D1    = 9999 )   OR
         ( TBL-ALL-FLG           = "ALL")
     THEN
       MOVE    "ALL"             TO    TBL-ALL-FLG
       MOVE    1                 TO    IX1
*
*    重複チェック
       IF  ( TBL-CHK-FLG             = "1"  )  AND
           ( SGYCD  OF D20090D1(4:1) = ZERO )
       THEN
         PERFORM                 SEIJ2-STR-SEC
         IF    SW-INV            =    "INV"
         THEN
           CONTINUE
         ELSE
           PERFORM               SEIJ2-NEXT-SEC
           PERFORM    UNTIL  ( SW-INV  =  "END"                  )
                      OR     ( WK-ERR  =  "ERR"                  )
                      OR     ( JSKKBN OF CSEIJL2 NOT = 2         )
                      OR     ( SEIBAN OF CSEIJL2 NOT = WK-SEIBAN )
                      OR     ( WORKNY OF CSEIJL2 NOT = WK-WORKCD )
*
             IF  ( WK-SYRKBN          = 2                ) AND
                 ( JSKBAN OF D20090D1 = JSKNO OF CSEIJL2 )
             THEN
               CONTINUE
             ELSE
*
               IF (( WK-STRDAY         NOT =  ZERO )   AND
                   ( KAISID OF CSEIJL2 NOT =  ZERO ))  OR
                  (( WK-ENDDAY         NOT =  ZERO )   AND
                   ( KANRYD OF CSEIJL2 NOT =  ZERO ))
               THEN
                 MOVE    JISKFR  OF D20090D1
                                 TO    TBL-KAISI
                 MOVE    JISKBY  OF D20090D1
                                 TO    TBL-SYURYO
                 PERFORM         DUP-CHK-SEC
               END-IF
             END-IF
             PERFORM             SEIJ2-NEXT-SEC
           END-PERFORM
         END-IF
       END-IF
*
*    受注Ｆ(項目)チェック
       MOVE    1                 TO    WK-JYUKOU
       MOVE    SPACE             TO    SW-INIT
                                       WK-ERR
*
       MOVE    ">="              TO    WK-KEY-POINT
       PERFORM                   JUKF-STR-SEC
       IF        SW-INV    =   "INV"
       THEN
*                                < ｼﾞｯｾｷ ｺｳﾓｸｶﾞ ｱﾘﾏｾﾝ >
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR012"        TO    WK-NO
         MOVE    1               TO    KSTKBN OF D20090D1
       ELSE
         PERFORM                 JUKF-NEXT-SEC
*
         PERFORM  UNTIL   ( SW-INV    = "END"             )
                  OR      ( WK-ERR    = "ERR"             )
                  OR      ( WK-SEIBAN < SEIBAN OF AJUKFL1 )
*
             MOVE  JYUKOU OF AJUKFL1
                                 TO    WK-KOMOKU
             IF    SW-INIT       =     SPACE
             THEN
               MOVE  JYUKOU OF AJUKFL1
                                 TO    JISKFR OF D20090D1
               MOVE  "1"         TO    SW-INIT
             ELSE
               MOVE  JYUKOU OF AJUKFL1
                                 TO    JISKBY OF D20090D1
             END-IF
*
*            作業実績ファイルへのチェックを既に行っていて
*                           新規作業の場合実績チェックを行う
             IF  ( TBL-CHK-FLG             = "1"  )  AND
                 ( SGYCD  OF D20090D1(4:1) = ZERO )
             THEN
               PERFORM           JSK-CHK-SEC
             END-IF
             PERFORM             JUKF-NEXT-SEC
         END-PERFORM
*
         IF  WK-ERR = "ERR"
         THEN
           MOVE    1             TO    JISKFR OF D20090D1
           MOVE    9999          TO    JISKBY OF D20090D1
         END-IF
       END-IF
*
*--実績項目　1～9999以外の場合-----------------------------*
     ELSE
       IF      KSTKBN OF D20090D1 = 1
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
         MOVE  SEQNO OF D20090D1 TO    IX1
       END-IF
*
*    重複チェック
       IF  ( TBL-CHK-FLG             = "1"  )  AND
           ( SGYCD  OF D20090D1(4:1) = ZERO )
       THEN
         PERFORM                 SEIJ2-STR-SEC
         IF    SW-INV            =    "INV"
         THEN
           CONTINUE
         ELSE
           PERFORM               SEIJ2-NEXT-SEC
           MOVE    JISKFR OF D20090D1
                                 TO    TBL-KAISI
           MOVE    JISKBY OF D20090D1
                                 TO    TBL-SYURYO
*
           PERFORM    UNTIL  ( SW-INV  =  "END"                  )
                      OR     ( WK-ERR  =  "ERR"                  )
                      OR     ( JSKKBN OF CSEIJL2 NOT = 2         )
                      OR     ( SEIBAN OF CSEIJL2 NOT = WK-SEIBAN )
                      OR     ( WORKNY OF CSEIJL2 NOT = WK-WORKCD )
*
             IF  ( WK-SYRKBN          = 2                ) AND
                 ( JSKBAN OF D20090D1 = JSKNO OF CSEIJL2 )
             THEN
               CONTINUE
             ELSE
               IF (( WK-STRDAY         NOT =  ZERO )   AND
                   ( KAISID OF CSEIJL2 NOT =  ZERO ))  OR
                  (( WK-ENDDAY         NOT =  ZERO )   AND
                   ( KANRYD OF CSEIJL2 NOT =  ZERO ))
               THEN
                 PERFORM         DUP-CHK-SEC
               END-IF
             END-IF
             PERFORM             SEIJ2-NEXT-SEC
           END-PERFORM
         END-IF
       END-IF
*
*  受注Ｆ(項目)チェック＊実績項目　1～9999以外の場合
       MOVE  SPACE               TO    WK-ERR
       MOVE  JISKFR OF D20090D1  TO    WK-JYUKOU
       MOVE  "="                 TO    WK-KEY-POINT
       PERFORM                   JUKF-STR-SEC
       IF    SW-INV    =   "INV"
       THEN
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳﾌｧｲﾙﾆ ｿﾝｻﾞｲｼﾅｲ>
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR020"          TO    WK-NO
         MOVE  JYUKOU OF AJUKFL1 TO    ERRKMK OF D20090D1
       ELSE
         PERFORM                 JUKF-NEXT-SEC
*
         PERFORM  UNTIL  ( SW-INV    = "END" )             OR
                         ( WK-ERR    = "ERR" )             OR
                         ( WK-SEIBAN < SEIBAN OF AJUKFL1 ) OR
                         ( JISKBY OF D20090D1 < JYUKOU OF AJUKFL1)
*
             MOVE  JYUKOU OF AJUKFL1
                                 TO    WK-KOMOKU
*            作業実績ファイルへのチェックを既に行っていて
*                                         新規作業の場合
             IF  ( TBL-CHK-FLG             = "1"  )  AND
                 ( SGYCD  OF D20090D1(4:1) = ZERO )
             THEN
               PERFORM           JSK-CHK-SEC
             END-IF
*
             PERFORM             JUKF-NEXT-SEC
             COMPUTE  WK-JYUKOU  = WK-JYUKOU + 1
*
             IF       WK-JYUKOU  > JISKBY OF D20090D1
             THEN
               CONTINUE
             ELSE
               IF     WK-JYUKOU  = JYUKOU OF AJUKFL1
               THEN
                 CONTINUE
               ELSE
*                                < ｼｼﾞｺｳﾓｸｶﾞ ｼﾞｭﾁｭｳﾌｧｲﾙﾆ ｿﾝｻﾞｲｼﾅｲ>
                 MOVE  "ERR"     TO    WK-ERR
                 MOVE  "ERR020"  TO    WK-NO
                 MOVE  WK-JYUKOU TO    ERRKMK OF D20090D1
               END-IF
             END-IF
         END-PERFORM
       END-IF
     END-IF.
*
     IF    TBL-ERR-FLG   = "ERR" OR    WK-ERR = "ERR"
     THEN
       MOVE      "ERR"           TO    WK-ERR
*
       IF  ( WK-NO       = "ERR020" )  AND
           ( WK-DUP-FLG  = "1"      )
       THEN
         MOVE    "1"             TO    T-DUP-FLG(WK-DUP-IX)
       END-IF
*
       IF    WK-NO       = "ERR012"
       THEN
         CONTINUE
       ELSE
         MOVE  "R"     TO    EDIT-COLOR  OF ERRKMK OF D20090D1
       END-IF
       MOVE    "R"     TO    EDIT-COLOR  OF JISKFR OF D20090D1
                             EDIT-COLOR  OF JISKBY OF D20090D1
       MOVE    "C"     TO    EDIT-CURSOR OF JISKFR OF D20090D1
       GO      TO            CHECK6-999
     END-IF.
*
     IF  T-JSK-FLG(IX1) = SPACE  AND  T-DUP-FLG(IX1)  =  SPACE
     THEN
       MOVE    ZERO              TO    ERRKMK OF D20090D1
       MOVE    ZERO              TO    T-KMK-ERR(IX1)
     END-IF.
*
*    画面の添字設定
     PERFORM           IDX-SET-SEC.
*
     MOVE  JISKFR OF D20090D1  TO  KAISI  OF D20090D1(IX-T1 IX-T2)
                                   T-KMK-STR(IX1).
     MOVE  JISKBY OF D20090D1  TO  SYURYO OF D20090D1(IX-T1 IX-T2)
                                   T-KMK-END(IX1).
*
     IF  ( KSTKBN OF D20090D1   =  1    )   OR
         ( TBL-ALL-FLG          = "ALL" )
     THEN
       MOVE    ZERO            TO    JISKFR OF D20090D1
                                     JISKBY OF D20090D1
     END-IF.
 CHECK6-999.
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
*    ＣＨＥＣＫ７処理　　－　作業コード～職場コード　－
******************************************************************
 CHECK7-SEC                      SECTION.
 CHECK7-010.
*
     INITIALIZE                  WK-ERR.
     PERFORM                     ATR-CLR7-SEC.
     MOVE  ZERO                  TO    WK-KMK-ERR.
*
     IF      SGYCD  OF D20090D1  =     SPACE
     THEN
*                                < ｻｷﾞｮｳｺｰﾄﾞｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       MOVE    SPACE             TO    SGYNM OF D20090D1
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR023"          TO    WK-NO
     ELSE
       IF  ( SGYCD  OF D20090D1  >=    WK-BKN-CD )  AND
           ( SGYCD  OF D20090D1  <     WK-SKA-CD )
       THEN
*        入力作業コードが作業マスタに存在すること
         MOVE  SGYCD OF D20090D1 TO    WK-WORKCD
         PERFORM                 SAGM-READ-SEC
         IF    SW-INV            =    "INV"
         THEN
*                                < ｻｷﾞｮｳﾏｽﾀ ﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           MOVE  "ERR"           TO    WK-ERR
           MOVE  "ERR025"        TO    WK-NO
           MOVE  SPACE           TO    SGYNM OF D20090D1
         ELSE
*        作業名
           MOVE  WNEI OF CSAGML1 TO    SGYNM OF D20090D1
         END-IF
       ELSE
*                                < ｾｲｻﾝﾉ ｻｷﾞｮｳｺｰﾄﾞ ﾃﾞﾊ ｱﾘﾏｾﾝ >
         MOVE    SPACE           TO    SGYNM OF D20090D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR024"        TO    WK-NO
       END-IF
     END-IF.
     IF     WK-ERR  =  "ERR"
     THEN
       MOVE    "R"               TO    EDIT-COLOR  OF SGYCD
                                                   OF D20090D1
       MOVE    "C"               TO    EDIT-CURSOR OF SGYCD
                                                   OF D20090D1
     END-IF.
*
*  開始日／完了日チェック
     MOVE    ZERO                TO    WK-ENDDAY.
     MOVE    ZERO                TO    WK-STRDAY.
     IF  ( STRDAY OF D20090D1 = ZERO ) AND
         ( ENDDAY OF D20090D1 = ZERO )
     THEN
*                                < ﾋﾂﾞｹｶﾞ ﾐﾆｭｳﾘｮｸ ﾃﾞｽ >
       IF      WK-ERR  =  SPACE
       THEN
         MOVE  "C"               TO    EDIT-CURSOR OF STRDAY
                                                   OF D20090D1
         MOVE  "ERR"             TO    WK-ERR
         MOVE  "ERR028"          TO    WK-NO
       END-IF
       MOVE    "R"               TO    EDIT-COLOR  OF STRDAY
                                                   OF D20090D1
                                       EDIT-COLOR  OF ENDDAY
                                                   OF D20090D1
     ELSE
*      開始日チェック
       IF    STRDAY OF D20090D1  = ZERO
       THEN
         MOVE  ZERO              TO    WK-STRDAY
       ELSE
         IF    STRDAY OF D20090D1(1:2)  >=  90
         THEN
           MOVE  19              TO    WK-STRDAY(1:2)
         ELSE
           MOVE  20              TO    WK-STRDAY(1:2)
         END-IF
         MOVE  STRDAY OF D20090D1
                                 TO    WK-STRDAY(3:6)
*
         MOVE  WK-STRDAY         TO    WK-KEY-YMD
         PERFORM                 CALM-READ-SEC
         IF    SW-INV   =  "INV"
         THEN
*                                < ｶﾚﾝﾀﾞﾏｽﾀ ﾆ ｿﾝｻﾞｲ ｼﾏｾﾝ >
           IF  WK-ERR   =  SPACE
           THEN
             MOVE  "C"           TO    EDIT-CURSOR OF STRDAY
                                                   OF D20090D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR026"      TO    WK-NO
           END-IF
           MOVE    "R"           TO    EDIT-COLOR  OF STRDAY
                                                   OF D20090D1
           MOVE    ZERO          TO    WK-STRDAY
         ELSE
           IF  WK-STRDAY  >  SYS-YMD-RE
           THEN
*                                < ﾐﾗｲﾉ ﾋﾞﾂﾞｹﾊ ﾆｭｳﾘｮｸ ﾃﾞｷﾏｾﾝ >
             IF  WK-ERR   =  SPACE
             THEN
               MOVE  "C"         TO    EDIT-CURSOR OF STRDAY
                                                   OF D20090D1
               MOVE  "ERR"       TO    WK-ERR
               MOVE  "ERR027"    TO    WK-NO
             END-IF
             MOVE    "R"         TO    EDIT-COLOR  OF STRDAY
                                                   OF D20090D1
             MOVE    ZERO        TO    WK-STRDAY
           END-IF
         END-IF
       END-IF
*
*      完了日チェック
       IF    ENDDAY OF D20090D1  = ZERO
       THEN
         MOVE  ZERO              TO    WK-ENDDAY
       ELSE
         IF    ENDDAY OF D20090D1(1:2)  >=  90
         THEN
           MOVE  19              TO    WK-ENDDAY(1:2)
         ELSE
           MOVE  20              TO    WK-ENDDAY(1:2)
         END-IF
         MOVE  ENDDAY OF D20090D1
                                 TO    WK-ENDDAY(3:6)
*
         MOVE  WK-ENDDAY         TO    WK-KEY-YMD
         PERFORM                 CALM-READ-SEC
         IF    SW-INV   =  "INV"
         THEN
*                                < ｶﾚﾝﾀﾞﾏｽﾀ ﾆ ｿﾝｻﾞｲ ｼﾏｾﾝ >
           IF    WK-ERR = SPACE
           THEN
             MOVE  "C"           TO    EDIT-CURSOR OF ENDDAY
                                                   OF D20090D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR026"      TO    WK-NO
           END-IF
           MOVE    "R"           TO    EDIT-COLOR  OF ENDDAY
                                                   OF D20090D1
           MOVE    ZERO          TO    WK-ENDDAY
         ELSE
           IF  WK-ENDDAY         NOT = SYS-YMD-RE
           THEN
*                                < ﾄｳｼﾞﾂﾋﾂﾞｹ ｲｶﾞｲ ﾆｭｳﾘｮｸ ﾌｶ >
             IF      WK-ERR      =  SPACE
             THEN
               MOVE  "C"         TO    EDIT-CURSOR OF ENDDAY
                                                   OF D20090D1
               MOVE  "ERR"       TO    WK-ERR
               MOVE  "ERR033"    TO    WK-NO
             END-IF
             MOVE    "R"         TO    EDIT-COLOR  OF ENDDAY
                                                   OF D20090D1
             MOVE    ZERO        TO    WK-ENDDAY
           END-IF
         END-IF
       END-IF
*
       IF    ( WK-STRDAY         >  ZERO      )   AND
             ( WK-ENDDAY         >  ZERO      )   AND
             ( WK-STRDAY         >  WK-ENDDAY )
       THEN
*                                < ｶｲｼﾋﾞｶﾞ ｶﾝﾘｮｳﾋﾞ ｦ ｺｴﾃｲﾏｽ >
         IF    WK-ERR = SPACE
         THEN
           MOVE    "C"           TO    EDIT-CURSOR OF STRDAY
                                                   OF D20090D1
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "ERR029"      TO    WK-NO
         END-IF
         MOVE      "R"           TO    EDIT-COLOR  OF STRDAY
                                                   OF D20090D1
       END-IF
     END-IF.
*
*  職場コード
     IF  ( SKBCD OF D20090D1     = SPACE )  AND
         ( WK-SYRKBN             = 1     )
     THEN
*                                < ｼｮｸﾊﾞｺｰﾄﾞ ｶﾞ ﾐﾆｭｳﾘｮｸﾃﾞｽ >
       IF    WK-ERR = SPACE
       THEN
         MOVE    "C"             TO    EDIT-CURSOR OF SKBCD
                                                   OF D20090D1
         MOVE    "ERR"           TO    WK-ERR
         MOVE    "ERR030"        TO    WK-NO
       END-IF
       MOVE      "R"             TO    EDIT-COLOR  OF SKBCD
                                                   OF D20090D1
       MOVE      SPACE           TO    SKBNM OF D20090D1
     ELSE
       IF   SKBCD OF D20090D1 NOT = SPACE
       THEN
*      組織マスタに存在チェックを行う(職場名の取得)
         MOVE  SKBCD OF D20090D1 TO    WK-SOSICD
         PERFORM                 SOSM-READ-SEC
         IF    SW-INV  = "INV"
         THEN
*                                < ｺｰﾄﾞ ｶﾞ ｿｼｷﾏｽﾀ ﾆ ｿﾝｻﾞｲｼﾏｾﾝ >
           IF    WK-ERR = SPACE
           THEN
             MOVE  "C"           TO    EDIT-CURSOR OF SKBCD
                                                   OF D20090D1
             MOVE  "ERR"         TO    WK-ERR
             MOVE  "ERR031"      TO    WK-NO
           END-IF
           MOVE    "R"           TO    EDIT-COLOR  OF SKBCD
                                                   OF D20090D1
           MOVE    SPACE         TO    SKBNM OF D20090D1
         ELSE
           MOVE    BSYNAM OF ASOSML1
                                 TO    SKBNM OF D20090D1
         END-IF
       END-IF
     END-IF.
*
*    単体チェックでエラーがある場合は処理を抜ける
     IF    WK-ERR = "ERR"
     THEN
       GO  TO        CHECK7-999
     END-IF.
*----------------------------------------------------------------*
     IF  (  SGYCD  OF D20090D1   =  WK-SGYCD    ) AND
         (  ENDDAY OF D20090D1   =  WK-ENDDAY-S )
     THEN
       IF  TBL-CHK-FLG           =  "1"
       THEN
*        実績エラー重複エラーがあるときは処理を抜ける
         PERFORM  VARYING  IX1   FROM  1  BY   1
                  UNTIL  ( IX1            >   30 )
                  OR     ( T-KMK-STR(IX1) = ZERO )
             IF  T-JSK-FLG(IX1)  =   "1"    OR
                 T-DUP-FLG(IX1)  =   "1"
             THEN
               MOVE  "ERR"       TO    TBL-ERR-FLG
                                       WK-ERR
               MOVE  30          TO    IX1
             END-IF
         END-PERFORM
       END-IF
     ELSE
       MOVE    SPACE             TO    TBL-CHK-FLG
                                       TBL-ERR-FLG
       PERFORM    VARYING  IX1   FROM  1  BY   1
                  UNTIL  ( IX1            >   30 )
                  OR     ( T-KMK-STR(IX1) = ZERO )
           MOVE      SPACE       TO    T-JSK-FLG(IX1)
                                       T-DUP-FLG(IX1)
           MOVE      ZERO        TO    T-KMK-ERR(IX1)
       END-PERFORM
     END-IF.
*
     IF    WK-ERR                =     SPACE
     THEN
*      作業コード新規の場合のみチェックを行う
       IF    SGYCD OF D20090D1(4:1) = ZERO
       THEN
         MOVE    "1"             TO    TBL-CHK-FLG
*        実績項目　1～9999 の場合
         IF    TBL-ALL-FLG =  "ALL"
         THEN
           MOVE   1              TO    IX1
           PERFORM               SEIJ2-STR-SEC
           IF    SW-INV          =    "INV"
           THEN
             CONTINUE
           ELSE
             PERFORM              SEIJ2-NEXT-SEC
*
             PERFORM  UNTIL  ( SW-INV  =  "END"                  )
                      OR     ( WK-ERR  =  "ERR"                  )
                      OR     ( JSKKBN OF CSEIJL2 NOT = 2         )
                      OR     ( SEIBAN OF CSEIJL2 NOT = WK-SEIBAN )
                      OR     ( WORKNY OF CSEIJL2 NOT = WK-WORKCD )
*
               IF    ( WK-SYRKBN          = 2                ) AND
                     ( JSKBAN OF D20090D1 = JSKNO OF CSEIJL2 )
               THEN
                 CONTINUE
               ELSE
                 IF (( WK-STRDAY         NOT =  ZERO )   AND
                     ( KAISID OF CSEIJL2 NOT =  ZERO ))  OR
                    (( WK-ENDDAY         NOT =  ZERO )   AND
                     ( KANRYD OF CSEIJL2 NOT =  ZERO ))
                 THEN
*                  ジャーナル重複チェック
                   MOVE    T-KMK-STR(IX1)
                                 TO    TBL-KAISI
                   MOVE    T-KMK-END(IX1)
                                 TO    TBL-SYURYO
                   PERFORM       DUP-CHK-SEC
                 END-IF
               END-IF
               PERFORM           SEIJ2-NEXT-SEC
             END-PERFORM
*
             IF    WK-ERR  = "ERR"
             THEN
               MOVE  WK-KMK-ERR  TO    T-KMK-ERR(IX1)
             END-IF
           END-IF
*
*    作業実績ファイルチェックを行う
           MOVE   T-KMK-STR(IX1) TO    WK-JYUKOU
           MOVE   ">="           TO    WK-KEY-POINT
           PERFORM               JUKF-STR-SEC
           IF     SW-INV   =  "INV"
           THEN
             CONTINUE
           ELSE
             PERFORM             JUKF-NEXT-SEC
*
             PERFORM  UNTIL    ( SW-INV    = "END" )
                      OR       ( WK-ERR    = "ERR" )
                      OR       ( WK-SEIBAN < SEIBAN OF AJUKFL1 )
                 PERFORM         JSK-CHK-SEC
                 PERFORM         JUKF-NEXT-SEC
             END-PERFORM
*
             IF    WK-ERR        = "ERR"
             THEN
               MOVE  WK-KMK-ERR  TO    T-KMK-ERR(IX1)
             END-IF
           END-IF
         END-IF
*
*      実績項目　1～9999 以外の場合
         IF    TBL-ALL-FLG   =  SPACE
         THEN
           PERFORM  VARYING    IX1  FROM  1  BY 1
                    UNTIL    ( IX1  > 30             )
                    OR       ( T-KMK-STR(IX1) = ZERO )
*
             MOVE  SPACE         TO    WK-ERR
             PERFORM             SEIJ2-STR-SEC
             IF    SW-INV        =    "INV"
             THEN
               CONTINUE
             ELSE
               PERFORM           SEIJ2-NEXT-SEC
               PERFORM  UNTIL  ( SW-INV  =  "END"              )
                      OR     ( WK-ERR  =  "ERR"                )
                      OR     ( JSKKBN OF CSEIJL2 NOT = 2       )
                      OR     ( SEIBAN OF CSEIJL2 NOT = WK-SEIBAN )
                      OR     ( WORKNY OF CSEIJL2 NOT = WK-WORKCD )
*
                 IF  ( WK-SYRKBN          = 2                ) AND
                     ( JSKBAN OF D20090D1 = JSKNO OF CSEIJL2 )
                 THEN
                   CONTINUE
                 ELSE
                   IF (( WK-STRDAY         NOT =  ZERO )   AND
                       ( KAISID OF CSEIJL2 NOT =  ZERO ))  OR
                      (( WK-ENDDAY         NOT =  ZERO )   AND
                       ( KANRYD OF CSEIJL2 NOT =  ZERO ))
                   THEN
*                    ジャーナル重複チェック
                     MOVE  T-KMK-STR(IX1)
                                 TO    TBL-KAISI
                     MOVE  T-KMK-END(IX1)
                                 TO    TBL-SYURYO
                     PERFORM     DUP-CHK-SEC
                   END-IF
                 END-IF
                 PERFORM         SEIJ2-NEXT-SEC
               END-PERFORM
*
               IF    WK-ERR    = "ERR"
               THEN
                 MOVE WK-KMK-ERR TO    T-KMK-ERR(IX1)
               END-IF
             END-IF
*
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
                        OR    (WK-ERR        = "ERR" )
                        OR    (WK-SEIBAN      < SEIBAN OF AJUKFL1)
                        OR    (T-KMK-END(IX1) < JYUKOU OF AJUKFL1)
*
                   PERFORM       JSK-CHK-SEC
                   PERFORM       JUKF-NEXT-SEC
               END-PERFORM
*
               IF    WK-ERR      = "ERR"
               THEN
                 MOVE WK-KMK-ERR TO    T-KMK-ERR(IX1)
               END-IF
             END-IF
           END-PERFORM
*
           IF    TBL-ERR-FLG  = "ERR"
           THEN
             MOVE  "ERR"         TO    WK-ERR
           END-IF
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
*    ジャーナル重複チェック処理
******************************************************************
 DUP-CHK-SEC                     SECTION.
 DUP-CHK-010.
*
     IF      T-DUP-FLG(IX1)      =  "1"
     THEN
       MOVE  "1"                 TO    WK-DUP-FLG
       MOVE  IX1                 TO    WK-DUP-IX
     END-IF.
     MOVE    SPACE               TO    T-DUP-FLG(IX1).
*
     PERFORM  VARYING  IX2   FROM  1  BY  1
              UNTIL  ( IX2                    >  30 )
              OR     ( KAISIK OF CSEIJL2(IX2) = ZERO)
*
         MOVE  KAISIK OF CSEIJL2(IX2)
                                 TO    WK-KAISIK
         MOVE  SYRYOK OF CSEIJL2(IX2)
                                 TO    WK-SYRYOK
*
*        チェック１
         IF   TBL-KAISI          >  WK-KAISIK    AND
              TBL-KAISI          <= WK-SYRYOK
         THEN
           MOVE  TBL-KAISI       TO    WK-KMK-ERR
         ELSE
*        チェック２
           IF   TBL-SYURYO       >  WK-KAISIK    AND
                TBL-SYURYO       <= WK-SYRYOK
           THEN
             MOVE  WK-KAISIK     TO    WK-KMK-ERR
           ELSE
*        チェック３
             IF   TBL-KAISI      <  WK-KAISIK    AND
                  TBL-SYURYO     >= WK-SYRYOK
             THEN
               MOVE  WK-KAISIK   TO    WK-KMK-ERR
             ELSE
*        チェック４
               IF  TBL-KAISI     >  WK-KAISIK    AND
                   TBL-SYURYO    <= WK-SYRYOK
               THEN
                 MOVE  TBL-KAISI TO    WK-KMK-ERR
               ELSE
*        チェック５
                 IF TBL-KAISI    = WK-KAISIK    OR
                    TBL-KAISI    = WK-SYRYOK
                 THEN
                   MOVE  TBL-KAISI
                                 TO    WK-KMK-ERR
                 ELSE
                   IF  ( TBL-SYURYO  = WK-KAISIK ) OR
                       ( TBL-SYURYO  = WK-SYRYOK )
                   THEN
                     MOVE  TBL-SYURYO
                                 TO    WK-KMK-ERR
                   END-IF
                 END-IF
               END-IF
             END-IF
           END-IF
         END-IF
*
         IF    WK-KMK-ERR        NOT = ZERO
         THEN
           MOVE    "ERR"         TO    WK-ERR
           MOVE    "1"           TO    T-DUP-FLG(IX1)
           MOVE    30            TO    IX2
         END-IF
     END-PERFORM.
*
     IF    WK-ERR     =  "ERR"
     THEN
       MOVE    "ERR"             TO    TBL-ERR-FLG
     END-IF.
 DUP-CHK-999.
     EXIT.
/*****************************************************************
*    作業実績ファイルチェック処理
******************************************************************
 JSK-CHK-SEC                     SECTION.
 JSK-CHK-010.
*
     MOVE    SPACE               TO    T-JSK-FLG(IX1).
*
     MOVE    JYUKOU OF AJUKFL1   TO    WK-KOMOKU.
     MOVE    SGYCD  OF D20090D1  TO    WK-WORKCD.
     PERFORM                     JISF-READ-SEC.
*
     IF   SW-INV = "INV"
     THEN
       CONTINUE
     ELSE
       IF   ( KJSKBI OF CJISFL1  NOT =  ZERO )  AND
            ( WK-ENDDAY          NOT =  ZERO )
       THEN
         MOVE  "ERR"             TO    WK-ERR
       END-IF
     END-IF.
*
     IF        WK-ERR            =     "ERR"
     THEN
       IF      T-DUP-FLG(IX1)    =     SPACE
       THEN
         MOVE  KOMOKU OF CJISFL1 TO    WK-KMK-ERR
       END-IF
       MOVE    "1"               TO    T-JSK-FLG(IX1)
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
*  項目指定／ＳＥＱ／実績項目のクリアを行う
     MOVE    ZERO                TO    KSTKBN OF D20090D1
                                       SEQNO  OF D20090D1
                                       JISKFR OF D20090D1
                                       JISKBY OF D20090D1
                                       ERRKMK OF D20090D1.
     PERFORM                     ATR-CLR4-SEC.
     PERFORM                     ATR-CLR5-SEC.
     PERFORM                     ATR-CLR6-SEC.
*
*  項目ゼロ件チェック
     IF  KAISI OF D20090D1(1 1) = ZERO
     THEN
*                                < ｼﾞｯｾｷｺｳﾓｸｶﾞ ｱﾘﾏｾﾝ >
       MOVE    "ERR"             TO    WK-ERR
       MOVE    "ERR012"          TO    WK-NO
       MOVE    "R"               TO    EDIT-COLOR  OF JISKFR
                                                   OF D20090D1
                                       EDIT-COLOR  OF JISKBY
                                                   OF D20090D1
       MOVE    "C"               TO    EDIT-CURSOR OF JISKFR
                                                   OF D20090D1
       MOVE    1                 TO    KSTKBN OF D20090D1
     ELSE
       IF      WK-ERR = "ERR"    OR    TBL-ERR-FLG = "ERR"
       THEN
*      画面のテーブル項目をＷＫ－ＴＢＬに退避しなおす
         MOVE     1              TO    IX1
         MOVE     SPACE          TO    TBL-ERR-FLG
                                       WK-ERR
*
         PERFORM  VARYING  IX-T1  FROM  1  BY  1
                  UNTIL    IX-T1  >     3
*
           PERFORM  VARYING  IX-T2  FROM  1  BY  1
                    UNTIL    IX-T2  >     10
*
             IF   KAISI OF D20090D1(IX-T1 IX-T2) = ZERO
             THEN
               MOVE  ZERO        TO    T-KMK-STR(IX1)
                                       T-KMK-END(IX1)
             ELSE
               MOVE  KAISI  OF D20090D1(IX-T1 IX-T2)
                                 TO    T-KMK-STR(IX1)
               MOVE  SYURYO OF D20090D1(IX-T1 IX-T2)
                                 TO    T-KMK-END(IX1)
               IF    T-KMK-ERR(IX1) = ZERO
               THEN
                 MOVE  SPACE     TO    T-JSK-FLG(IX1)
                 MOVE  SPACE     TO    T-DUP-FLG(IX1)
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
     MOVE       ZERO             TO    ERRKMK OF D20090D1.
     MOVE       ZERO             TO    IX2.
*
     PERFORM    VARYING  IX1     FROM  1  BY  1
                UNTIL    IX1     > 30
*
         IF   ( T-JSK-FLG(IX1)   =     "1" )  OR
              ( T-DUP-FLG(IX1)   =     "1" )
         THEN
           MOVE  2               TO    KSTKBN OF D20090D1
           MOVE  IX1             TO    SEQNO  OF D20090D1
*
           IF    DSP-GROUP       =     "GRP006"
           THEN
             IF  DSP-FUNC        =     "F005"
             THEN
               MOVE T-KMK-STR(IX1) TO    JISKFR OF D20090D1
               MOVE T-KMK-END(IX1) TO    JISKBY OF D20090D1
               MOVE T-KMK-ERR(IX1) TO    ERRKMK OF D20090D1
             ELSE
               MOVE  WK-KMK-ERR    TO    ERRKMK OF D20090D1
             END-IF
           ELSE
             MOVE   T-KMK-STR(IX1) TO    JISKFR OF D20090D1
             MOVE   T-KMK-END(IX1) TO    JISKBY OF D20090D1
             MOVE   T-KMK-ERR(IX1) TO    ERRKMK OF D20090D1
           END-IF
           MOVE    "R"     TO    EDIT-COLOR  OF JISKFR OF D20090D1
                                 EDIT-COLOR  OF JISKBY OF D20090D1
                                 EDIT-COLOR  OF ERRKMK OF D20090D1
           MOVE    "C"     TO    EDIT-CURSOR OF JISKFR OF D20090D1
*
           IF    T-DUP-FLG(IX1)  =     "1"
           THEN
*                                < ｼﾞｬｰﾅﾙｶﾞ ｿﾝｻﾞｲｼﾏｽ >
             MOVE    "ERR022"    TO    WK-NO
           ELSE
*                                < ｼﾞｯｾｷｽﾞﾐ ﾆ ﾅｯﾃｲﾏｽ >
             MOVE    "ERR021"    TO    WK-NO
           END-IF
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
*    実績項目削除処理
******************************************************************
 KMK-DEL-SEC                     SECTION.
 KMK-DEL-010.
*
     MOVE    ZERO                TO    JISKFR OF D20090D1
                                       JISKBY OF D20090D1.
     MOVE    SEQNO OF D20090D1   TO    IX1  IX2.
     ADD     1                   TO    IX2.
*
     IF    ( IX1  = 30                                 )   OR
           ( IX2  < 31    AND    T-KMK-STR(IX2)  = ZERO)
     THEN
       INITIALIZE                T-KMK-STR(IX1)
                                 T-KMK-END(IX1)
                                 T-KMK-ERR(IX1)
                                 T-JSK-FLG(IX1)
                                 T-DUP-FLG(IX1)
     ELSE
       PERFORM  UNTIL ( T-KMK-STR(IX2)  = ZERO ) OR
                      ( IX2             > 30   )
*
           MOVE  T-KMK-STR(IX2)  TO    T-KMK-STR(IX1)
           MOVE  T-KMK-END(IX2)  TO    T-KMK-END(IX1)
           MOVE  T-KMK-ERR(IX2)  TO    T-KMK-ERR(IX1)
           MOVE  T-JSK-FLG(IX2)  TO    T-JSK-FLG(IX1)
           MOVE  T-DUP-FLG(IX2)  TO    T-DUP-FLG(IX1)
           INITIALIZE                  T-KMK-STR(IX2)
                                       T-KMK-END(IX2)
                                       T-KMK-ERR(IX2)
                                       T-JSK-FLG(IX2)
                                       T-DUP-FLG(IX2)
           ADD   1               TO    IX1  IX2
       END-PERFORM
     END-IF.
*
*  実績項目（開始～終了）の再セットを行う
     MOVE     1                  TO    IX-T1  IX-T2.
     PERFORM  VARYING  IX1  FROM  1  BY  1
              UNTIL  ( IX1  > 30                             )
              OR     ( KAISI OF D20090D1(IX-T1 IX-T2) = ZERO )
*
         IF    T-KMK-STR(IX1) = ZERO
         THEN
           MOVE  ZERO    TO    KAISI  OF D20090D1(IX-T1 IX-T2)
           MOVE  ZERO    TO    SYURYO OF D20090D1(IX-T1 IX-T2)
         ELSE
           MOVE  T-KMK-STR(IX1)
                         TO    KAISI  OF D20090D1(IX-T1 IX-T2)
           MOVE  T-KMK-END(IX1)
                         TO    SYURYO OF D20090D1(IX-T1 IX-T2)
         END-IF
         IF      IX1  =  10  OR  20
         THEN
           ADD   1               TO    IX-T1
           MOVE  ZERO            TO    IX-T2
         END-IF
         ADD     1               TO    IX-T2
     END-PERFORM.
*
     MOVE        ZERO            TO    SEQNO  OF D20090D1.
 KMK-DEL-999.
     EXIT.
/*****************************************************************
*    ファイル出力処理（新規／修正／削除）
******************************************************************
 FILE-UPD-SEC                    SECTION.
 FILE-UPD-010.
*
*  新規更新の場合　発番ファイルより連番取得
     IF      WK-SYRKBN     =     1
     THEN
       PERFORM                   HATM-ACS-SEC
       PERFORM                   HATM-UPD-SEC
     END-IF.
*
     PERFORM   VARYING     IX1  FROM  1   BY 1
                 UNTIL   ( IX1            > 30   )
                 OR      ( T-KMK-STR(IX1) = ZERO )
*
           EVALUATE  WK-SYRKBN
               WHEN  1
*                    生産実績ジャーナルの出力
                     PERFORM     SEIJ1-OUT-SEC
               WHEN  2
*                    生産実績ジャーナルの更新
                     PERFORM     SEIJ1-UPD-SEC
               WHEN  3
*                    生産実績ジャーナルの削除
                     PERFORM     SEIJ1-DEL-SEC
           END-EVALUATE
     END-PERFORM.
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
*    生産実績ジャーナル出力処理（WRITE)
******************************************************************
 SEIJ1-OUT-SEC                   SECTION.
 SEIJ1-OUT-010.
*
     INITIALIZE                  CSEIFD OF CSEIJL1.
*
     MOVE    WK-RENBAN           TO    JSKNO  OF CSEIJL1
                                       WK-JSKBAN.
     MOVE    "2"                 TO    JSKKBN OF CSEIJL1.
     MOVE    WK-SEIBAN           TO    SEIBAN OF CSEIJL1.
     MOVE    WK-WORKCD           TO    WORKNY OF CSEIJL1.
*
     PERFORM   VARYING    IX1    FROM    1     BY  1
               UNTIL      IX1            >     30
               OR         T-KMK-STR(IX1) =   ZERO
*
         MOVE  T-KMK-STR(IX1)    TO    KAISIK OF CSEIJL1(IX1)
         MOVE  T-KMK-END(IX1)    TO    SYRYOK OF CSEIJL1(IX1)
     END-PERFORM.
*
     MOVE    WK-STRDAY           TO    KAISID OF CSEIJL1.
     MOVE    WK-ENDDAY           TO    KANRYD OF CSEIJL1.
     MOVE    SKBCD OF D20090D1   TO    JSKOFC OF CSEIJL1.
*
     MOVE    SYS-YMD-RE          TO    CRTDAY OF CSEIJL1.
     MOVE    SYS-YMD-RE          TO    UPDDAY OF CSEIJL1.
     ACCEPT  SYS-HMS     FROM  TIME.
     MOVE    SYS-HMS(1:6)        TO    UPDTIM OF CSEIJL1.
     MOVE    DSP-WSID            TO    WSID   OF CSEIJL1.
*
     WRITE     CSEIFD  OF CSEIJL1.
     EVALUATE  ST-CSEIJL1
         WHEN  "00"
               ADD   1           TO    CNT-WRT
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "CSEIJL1"   TO    WK-FILE
               MOVE  "WRITE"     TO    WK-SYORI
               MOVE  JSKNO  OF CSEIJL1
                                 TO    WK-KEY1
               MOVE  "2"         TO    WK-KEY2
               MOVE  ST-CSEIJL1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SEIJ1-OUT-999.
     EXIT.
/*****************************************************************
*    生産実績ジャーナル更新処理（REWRITE)
******************************************************************
 SEIJ1-UPD-SEC                    SECTION.
 SEIJ1-UPD-010.
*
     PERFORM                     SEIJ1-READ-SEC.
*
     MOVE    WK-SEIBAN           TO    SEIBAN OF CSEIJL1.
     MOVE    WK-WORKCD           TO    WORKNY OF CSEIJL1.
*
     PERFORM   VARYING    IX1    FROM  1   BY  1
               UNTIL      IX1    >     30
*
         IF    T-KMK-STR(IX1)         = ZERO
         THEN
           IF  KAISIK OF CSEIJL1(IX1) = ZERO
           THEN
             MOVE    30          TO    IX1
           ELSE
             MOVE    ZERO        TO    KAISIK OF CSEIJL1(IX1)
             MOVE    ZERO        TO    SYRYOK OF CSEIJL1(IX1)
           END-IF
         ELSE
           MOVE  T-KMK-STR(IX1)  TO    KAISIK OF CSEIJL1(IX1)
           MOVE  T-KMK-END(IX1)  TO    SYRYOK OF CSEIJL1(IX1)
         END-IF
     END-PERFORM.
*
     MOVE    WK-STRDAY           TO    KAISID OF CSEIJL1.
     MOVE    WK-ENDDAY           TO    KANRYD OF CSEIJL1.
     MOVE    SKBCD OF D20090D1   TO    JSKOFC OF CSEIJL1.
*
     MOVE    SYS-YMD-RE          TO    UPDDAY OF CSEIJL1.
     ACCEPT  SYS-HMS     FROM  TIME.
     MOVE    SYS-HMS(1:6)        TO    UPDTIM OF CSEIJL1.
     MOVE    DSP-WSID            TO    WSID   OF CSEIJL1.
*
     REWRITE   CSEIFD  OF CSEIJL1.
     EVALUATE  ST-CSEIJL1
         WHEN  "00"
               ADD   1           TO    CNT-UPD
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "CSEIJL1"   TO    WK-FILE
               MOVE  "REWRITE"   TO    WK-SYORI
               MOVE  JSKNO  OF CSEIJL1
                                 TO    WK-KEY1
               MOVE  "2"         TO    WK-KEY2
               MOVE  ST-CSEIJL1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SEIJ1-UPD-999.
     EXIT.
/*****************************************************************
*    生産実績ジャーナル削除処理（DELETE)
******************************************************************
 SEIJ1-DEL-SEC                   SECTION.
 SEIJ1-DEL-010.
*
     PERFORM                     SEIJ1-READ-SEC.
*
     DELETE    CSEIJL1.
     EVALUATE  ST-CSEIJL1
         WHEN  "00"
               ADD   1           TO    CNT-DEL
         WHEN  "23"
               CONTINUE
         WHEN  OTHER
               MOVE  "CSEIJL1"   TO    WK-FILE
               MOVE  "DELETE"    TO    WK-SYORI
               MOVE  JSKNO  OF CSEIJL1
                                 TO    WK-KEY1
               MOVE  "2"         TO    WK-KEY2
               MOVE  ST-CSEIJL1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SEIJ1-DEL-999.
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
     ACCEPT  SYS-HMS     FROM  TIME.
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
               MOVE  "43"        TO    WK-KEY1
               MOVE  HATUCD OF AHATML1
                                 TO    WK-KEY2
               MOVE  ST-AHATML   TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 HATM-UPD-999.
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
*    生産実績ジャーナル１　ＲＥＡＤ処理(RAN)
******************************************************************
 SEIJ1-READ-SEC                  SECTION.
 SEIJ1-READ-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  JSKNO  OF CSEIJL1
                                 JSKKBN OF CSEIJL1.
     MOVE    WK-JSKBAN           TO    JSKNO  OF CSEIJL1.
     MOVE    "2"                 TO    JSKKBN OF CSEIJL1.
     READ    CSEIJL1.
*
     EVALUATE  ST-CSEIJL1
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CSEIJL1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  WK-JSKBAN   TO    WK-KEY1
               MOVE  "2"         TO    WK-KEY2
               MOVE  ST-CSEIJL1  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SEIJ1-READ-999.
     EXIT.
/*****************************************************************
*    生産実績ジャーナル２　ＳＴＡＲＴ処理(START)
******************************************************************
 SEIJ2-STR-SEC                   SECTION.
 SEIJ2-STR-010.
*
     MOVE    SPACE               TO    SW-INV.
     INITIALIZE                  JSKKBN OF CSEIJL2
                                 SEIBAN OF CSEIJL2
                                 WORKNY OF CSEIJL2.
     MOVE    "2"                 TO     JSKKBN OF CSEIJL2.
     MOVE    WK-SEIBAN           TO     SEIBAN OF CSEIJL2.
     MOVE    WK-WORKCD           TO     WORKNY OF CSEIJL2.
*
     START   CSEIJL2  KEY IS >=  JSKKBN OF CSEIJL2
                                 SEIBAN OF CSEIJL2
                                 WORKNY OF CSEIJL2.
     EVALUATE  ST-CSEIJL2
         WHEN  "00"
               CONTINUE
         WHEN  "23"
               MOVE  "INV"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CSEIJL2"   TO    WK-FILE
               MOVE  "START"     TO    WK-SYORI
               MOVE  "2"         TO    WK-KEY1
               MOVE  WK-SEIBAN   TO    WK-KEY2
               MOVE  WK-WORKCD   TO    WK-KEY3
               MOVE  ST-CSEIJL2  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SEIJ2-STR-999.
     EXIT.
/*****************************************************************
*    生産実績ジャーナル２　ＮＥＸＴ処理(NEXT)
******************************************************************
 SEIJ2-NEXT-SEC                  SECTION.
 SEIJ2-NEXT-010.
*
     MOVE    SPACE               TO    SW-INV.
*
     READ    CSEIJL2  NEXT.
     EVALUATE  ST-CSEIJL2
         WHEN  "00"
               CONTINUE
         WHEN  "10"
               MOVE  "END"       TO    SW-INV
         WHEN  OTHER
               MOVE  "CSEIJL2"   TO    WK-FILE
               MOVE  "NEXT"      TO    WK-SYORI
               MOVE  JSKKBN OF CSEIJL2
                                 TO    WK-KEY1
               MOVE  SEIBAN OF CSEIJL2
                                 TO    WK-KEY2
               MOVE  WORKNY OF CSEIJL2
                                 TO    WK-KEY3
               MOVE  ST-CSEIJL2  TO    WK-STATUS
               PERFORM           ABEND-SEC
     END-EVALUATE.
 SEIJ2-NEXT-999.
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
     MOVE    "43"                TO    HATKBN OF AHATML1.
     MOVE    "000000"            TO    HATUCD OF AHATML1.
     READ    AHATML1.
     EVALUATE  ST-AHATML
         WHEN  "00"
               CONTINUE
         WHEN  OTHER
               MOVE  "AHATML1"   TO    WK-FILE
               MOVE  "READ"      TO    WK-SYORI
               MOVE  "43"        TO    WK-KEY1
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
     MOVE    "M"       TO    EDIT-COLOR  OF JSKBAN OF D20090D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF JSKBAN OF D20090D1.
 ATR-CLR2-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群３）
******************************************************************
 ATR-CLR3-SEC                    SECTION.
 ATR-CLR3-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SEIBAN OF D20090D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SEIBAN OF D20090D1.
 ATR-CLR3-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群４）
******************************************************************
 ATR-CLR4-SEC                    SECTION.
 ATR-CLR4-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF KSTKBN OF D20090D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF KSTKBN OF D20090D1.
 ATR-CLR4-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群５）
******************************************************************
 ATR-CLR5-SEC                    SECTION.
 ATR-CLR5-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SEQNO  OF D20090D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF SEQNO  OF D20090D1.
 ATR-CLR5-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群６）
******************************************************************
 ATR-CLR6-SEC                    SECTION.
 ATR-CLR6-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF JISKFR OF D20090D1
                             EDIT-COLOR  OF JISKBY OF D20090D1
                             EDIT-COLOR  OF ERRKMK OF D20090D1.
     MOVE    SPACE     TO    EDIT-CURSOR OF JISKFR OF D20090D1
                             EDIT-CURSOR OF JISKBY OF D20090D1
                             EDIT-CURSOR OF ERRKMK OF D20090D1.
 ATR-CLR6-999.
     EXIT.
/*****************************************************************
*    アトリビュートクリア処理（項目群７）
******************************************************************
 ATR-CLR7-SEC                    SECTION.
 ATR-CLR7-010.
*
     MOVE    "M"       TO    EDIT-COLOR  OF SGYCD  OF D20090D1
                             EDIT-COLOR  OF STRDAY OF D20090D1
                             EDIT-COLOR  OF ENDDAY OF D20090D1
                             EDIT-COLOR  OF SKBCD  OF D20090D1.
*
     MOVE    SPACE     TO    EDIT-CURSOR OF SGYCD  OF D20090D1
                             EDIT-CURSOR OF STRDAY OF D20090D1
                             EDIT-CURSOR OF ENDDAY OF D20090D1
                             EDIT-CURSOR OF SKBCD  OF D20090D1.
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
     IF      TRN-STR-FLG   = "STR"
     THEN
*      トランザクション終了
        CALL     "XMROTEND"
        MOVE     SPACE           TO    TRN-STR-FLG
     END-IF.
*
     PERFORM                     MSG-SEARCH-SEC.
*
     MOVE    WK-MESSAGE          TO    MSG    OF D20090D1.
     MOVE    WK-GAIDO            TO    GIDMSG OF D20090D1.
     MOVE    "D20090D1"          TO    DSP-FORMAT.
     MOVE    SPACE               TO    DSP-MODE.
     MOVE    "SCREEN"            TO    DSP-GROUP.
*
     WRITE   D20090D1.
     IF      DSP-STATUS   NOT = "00"
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
*  トランザクションキャンセル
     CALL     "XMROTCNL".
*
     STOP    RUN.
 ABEND-999.
     EXIT.
 END PROGRAM D20090PO.
