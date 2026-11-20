
*****************************************************************
*
* プログラムＩＤ＝　ＭＪＳ０９０ＣＧ　
* プログラム言語＝　ＣＯＢＯＬＧ
*
* サブシステム名＝　設計管理システム
*
* 処理概要　　　＝  未受注物件作図依頼データに設計部門を
*                   登録する
*
*
*
*
*
*
*                                ＳＲＣＬＩＢ： FCSLIB
*                                ＯＢＪＬＩＢ： FCPLIB
*                                作　成　日　： 2012.07.11
*                                変　更　日　：
*
*****************************************************************
 IDENTIFICATION      DIVISION.
*--------------------------------*
 PROGRAM-ID.         MJS090CG.
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
     SELECT  画面ファイル  ASSIGN  TO  01-GS-DSPF
                           FORMAT             IS  G-NAME
                           GROUP              IS  G-GRP
                           PROCESSING   MODE  IS  G-EXC
                           SELECTED FUNCTION  IS  G-ATT
                           FILE   STATUS      IS  F-STT.
*未受注物件作図依頼ファイル
     SELECT  依頼ファイル       ASSIGN  TO  DA-01-VI-MIJUSJL2
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD  KEY IS
                                               依頼－見積番号
                                FILE   STATUS    IS  F1-STS.
*組織マスタ
     SELECT  組織マスタ         ASSIGN  TO  DA-01-VI-ASOSML1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD      KEY  IS
                                            組織－部所コード
                                            組織－担当者係コード
                                FILE   STATUS    IS  F2-STS.
*取引先マスタ
     SELECT  取引先マスタ       ASSIGN  TO  DA-01-VI-ATORML1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD      KEY  IS
                                            取引－取引先コード
                                FILE   STATUS    IS  F3-STS.
*情報物件鑑ファイル
     SELECT  情報物件ファイル   ASSIGN  TO  DA-01-VI-AJBGFL1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD      KEY  IS
                                            物件－見積ナンバー
                                FILE   STATUS    IS  F4-STS.
*未受注物件作図依頼照会ファイル
     SELECT  照会ファイル       ASSIGN  TO  DA-01-VI-MIJUSSL1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD  KEY IS
                                               照会－部所コード
                                               照会－端末番号
                                               照会－見積番号
                                FILE   STATUS    IS  F5-STS.
*集約部所変換マスタ
     SELECT  変換マスタ
                                ASSIGN  TO  DA-01-VI-ASBHML1
                                ORGANIZATION     IS  INDEXED
                                ACCESS      MODE IS  RANDOM
                                RECORD KEY IS
                                       変換－部所コード
                                       変換－担当者係コード
                                FILE   STATUS    IS  F6-STS.
*--------------------------------*
 DATA                DIVISION.
*--------------------------------*
 FILE                SECTION.
*--------------------------------*
*       画面定義　　　           *
*--------------------------------*
 FD  画面ファイル.
     COPY  MJS090D1
                     OF  XMDLIB  JOINING   画面
                     AS  PREFIX.
*===============================================================*
*       未受注物件作図依頼ファイル
*===============================================================*
 FD  依頼ファイル.
     COPY  MIJUSJL2  OF  XFDLIB  JOINING  依頼 AS  PREFIX.
*===============================================================*
*       組織マスタ
*===============================================================*
 FD  組織マスタ.
     COPY  ASOSML1   OF  XFDLIB  JOINING  組織 AS  PREFIX.
*===============================================================*
*       取引先マスタ
*===============================================================*
 FD  取引先マスタ.
     COPY  ATORML1   OF  XFDLIB  JOINING  取引 AS  PREFIX.
*===============================================================*
*       情報物件鑑ファイル
*===============================================================*
 FD  情報物件ファイル.
     COPY  AJBGFL1   OF  XFDLIB  JOINING  物件 AS  PREFIX.
*===============================================================*
*       未受注物件作図依頼照会ファイル
*===============================================================*
 FD  照会ファイル.
     COPY  MIJUSSL1  OF  XFDLIB  JOINING  照会 AS  PREFIX.
*===============================================================*
*       集約部所変換マスタ
*===============================================================*
 FD  変換マスタ.
     COPY  ASBHML1  OF   XFDLIB  JOINING  変換    AS  PREFIX.
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
 77  FILE-FLAG               PIC  9(01)      VALUE   ZERO.
 77  INPUT-COUNT             PIC  9(05)      VALUE   ZERO.
 77  SY-BUCODE               PIC  X(02)      VALUE   SPACES.
*
*    ステータスエリア
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

*    フラグエリア
 01  FLG-AREA.
     03  END-FLG                 PIC  X(03).
     03  ERR-FLG                 PIC  9(02).
     03  SEL-FLG                 PIC  X(03).

*  　インデックスエリア
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
     03  C-IDX1                  PIC  S9(04) PACKED-DECIMAL.
     03  C-IDX2                  PIC  S9(04) PACKED-DECIMAL.

*    ワークエリア
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

*    システム日付・時間
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

*    異常終了管理インターフェイス
 01  ABEND-AREA.
     03  WK-PGMID                PIC  X(08)     VALUE "MJS090CG".
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
*----<<画面制御用ワーク>>
 01  G-SEIGYO.
     03  G-NAME              PIC  X(08)      VALUE   SPACES.
     03  G-GRP               PIC  X(08)      VALUE   SPACES.
     03  G-EXC               PIC  X(02)      VALUE   SPACES.
     03  G-ATT               PIC  X(04)      VALUE   SPACES.
     03  ATT-INF.
         05  PF1             PIC  X(04)      VALUE   "F001".
         05  PF3             PIC  X(04)      VALUE   "F003".
         05  PF5             PIC  X(04)      VALUE   "F005".
         05  PF9             PIC  X(04)      VALUE   "F009".
         05  PF10            PIC  X(04)      VALUE   "F010".
         05  ENTR            PIC  X(04)      VALUE   "E000".
     03  G-CONT              PIC  X(06)      VALUE   SPACES.
     03  G-DEST              PIC  X(08)      VALUE   SPACES.
     03  F-STT               PIC  X(02)      VALUE   SPACES.
*----操作表示ﾞ
*処理選択表示ﾞ
*画面表示
 01  HYOJI02.
     03  FILLER              PIC  N(10)  VALUE
     NC"ＰＦ１０：終了".
 01  HYOJI02A.
     03  FILLER              PIC  N(10)  VALUE
     NC"ＰＦ９：再入力".
 01  HYOJI03.
     03  FILLER              PIC  N(20)  VALUE
     NC"再入力：ＰＦ９".
 01  HYOJI04.
     03  FILLER              PIC  N(20)  VALUE
     NC"再入力：ＰＦ９　登録：ＰＦ１".
 01  HYOJI05.
     03  FILLER              PIC  N(20)  VALUE
     NC"再入力：ＰＦ９　削除：ＰＦ１".
 01  HYOJI99.
     03  FILLER              PIC  N(20)  VALUE
         NC"只今　未受注物件の作図依頼書とＶＥ案差額".
     03  FILLER              PIC  N(15)  VALUE
         NC"表を作成中です。".
 01  HYOJIAA.
     03  FILLER              PIC  N(20)  VALUE
         NC"しばらく　お待ち下さい。".
*----------------------------------------------------
*操作指示
*画面指示
 01  SHIJI01.
     03  FILLER              PIC  N(15)  VALUE
     NC"処理を選択して下さい".
 01  SHIJI02.
     03  FILLER              PIC  N(15)  VALUE
     NC"見積番号を入力して下さい".
 01  SHIJI03.
     03  FILLER              PIC  N(18)  VALUE
     NC"設計担当を入力して下さい".
 01  SHIJI05.
     03  FILLER              PIC  N(15)  VALUE
     NC"確認をして下さい".
 01  SHIJI99.
     03  FILLER              PIC  N(15)  VALUE
     NC"操作に誤りがあります".
*
*
 01  CH-DATE             PIC  9(06).
 01  CH-DATER   REDEFINES  CH-DATE.
     03  CH-YY              PIC  9(02).
     03  CH-MM              PIC  9(02).
     03  CH-DD              PIC  9(02).
*
 01  WK-WSNO                PIC  X(08).
*
*-----------------------------------------------------*
*
 LINKAGE          SECTION.
 01  WS-NO                  PIC  X(08).
*--------------------------------*
 PROCEDURE           DIVISION
                     USING    WS-NO.
*
*********------------------------------------------------*********
*********                ﾒ ｲ ﾝ       ﾙｰﾁﾝ                *********
*********------------------------------------------------*********
 主処理                       SECTION.
 主処理－開始.
*
     PERFORM    初期処理.
*
     MOVE    ZERO   TO   INPUT-COUNT.
*
     PERFORM    修正処理.
     IF      INPUT-COUNT   =  ZERO
                             MOVE  "4091"   TO  PROGRAM-STATUS
                             PERFORM  終了処理
                             STOP  RUN.
*
 主処理０９０.
     PERFORM    終了処理.
     STOP  RUN.
******************************************************************
*    初期処理　　　　　　
******************************************************************
 初期処理                        SECTION.
 初期処理－開始.
*    ファイルのオープン
     OPEN    I-O            画面ファイル.
     OPEN    I-O            依頼ファイル.
     OPEN    I-O            照会ファイル.
     OPEN    INPUT          取引先マスタ
                            組織マスタ
                            情報物件ファイル.
     OPEN    INPUT          変換マスタ.
*
     PERFORM                ＯＰＥＮチェック処理.
*
*    システム日付の取得
     MOVE    FUNCTION    CURRENT-DATE   TO  DATE-AREA.
*
     ACCEPT       TIME-AREA      FROM      TIME.
*
*    作業項目の初期化
     INITIALIZE                  FLG-AREA
                                 SAVE-AREA
                                 INDEX-AREA.
*
     MOVE    ZERO                TO        STATUS-AREA.
     MOVE    ZERO                TO        SAVE-PAGE.
     MOVE    ZERO                TO        IDX.
     MOVE    ZERO                TO        SAVE-DATE.
     MOVE    ZERO                TO        SAVE-DKBN.
*
*
 初期処理－終了.
     EXIT.
*
*
*===============================================================*
*            修正登録処理
*===============================================================*
 修正処理               SECTION.
 修正処理－開始.
     MOVE    LOW-VALUE       TO  画面－未受注作図依頼書.
     MOVE    SPACES          TO  画面－操作指示.
*
     MOVE    "CL"            TO  G-EXC.
     MOVE    "SCREEN"        TO  G-GRP.
     MOVE    "MJU090D1"      TO  G-NAME.
*
 修正０１０.
     MOVE    SHIJI02        TO  画面－操作指示.
     MOVE    HYOJI02        TO  画面－操作表示１.
     MOVE    SPACES         TO  画面－操作表示２.
*
 修正０１１.
     PERFORM 画面出力処理.
 修正０１２.
     MOVE    ZERO            TO  PF-FLAG.
     MOVE    ZERO            TO  ERR-FLAG.
*
     MOVE    "NE"            TO  G-EXC.
     MOVE    "GRP001"        TO  G-GRP.
     READ    画面ファイル.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "READ"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
     IF      G-ATT           =   PF10
                                     GO  TO 修正処理－終了.
     IF      G-ATT           =   ENTR
                                     GO  TO 修正０１３.
*
     MOVE    SHIJI99          TO  画面－操作指示.
     PERFORM 画面出力処理.
     GO  TO  修正０１１.
 修正０１３.
     IF      画面－見積番号 =    LOW-VALUE
                             MOVE  SPACES TO  画面－見積番号
     END-IF.
     IF      画面－見積番号 =    SPACES
                             MOVE  1      TO  ERR-FLAG
                              GO  TO  修正０１４
     END-IF.
*
     MOVE    画面－見積番号 TO  依頼－見積番号.
     READ    依頼ファイル   INVALID
                            MOVE   3     TO  ERR-FLAG
                            GO  TO  修正０１４.
*
 修正０１３Ａ.
     MOVE    画面－見積番号 TO  物件－見積ナンバー.
     READ    情報物件ファイル   INVALID
                              MOVE   2     TO  ERR-FLAG
                              GO  TO  修正０１４.
     MOVE    物件－件名         TO  画面－物件名.
*
     MOVE    物件－依頼先コード TO  取引－取引先コード.
     READ    取引先マスタ  INVALID
                    MOVE  SPACES  TO 取引－取引略名.
*
     MOVE    取引－取引略名
                                  TO  画面－受注先名.
*
*
     MOVE    物件－部所コード      TO  変換－部所コード.
     MOVE    物件－担当者係コード  TO  変換－担当者係コード.
     READ    変換マスタ          INVALID
                             MOVE 画面－見積番号 (2:2)
                                          TO  SY-BUCODE
                             GO  TO  修正０１３Ｂ.
     MOVE    変換－集約部所コード
                                  TO  SY-BUCODE.
 修正０１３Ｂ.
     MOVE    SY-BUCODE      TO  照会－部所コード.
     MOVE    画面－見積番号 TO  照会－見積番号.
     MOVE    依頼－端末番号 TO  照会－端末番号.
     READ    照会ファイル   INVALID
                            MOVE   4     TO  ERR-FLAG
                            GO  TO  修正０１４.
*
     PERFORM   表示処理.
     PERFORM   画面出力処理.
*
 修正０１４.
*
     EVALUATE     ERR-FLAG
        WHEN      1
          MOVE  NC"見積番号が入力されてません"
                                 TO  画面－操作指示
          GO  TO  修正０１１
        WHEN      2
          MOVE  NC"該当の見積は存在しておりません"
                                 TO  画面－操作指示
          GO  TO  修正０１１
        WHEN      3
          MOVE  NC"未登録のデータです"
                                 TO  画面－操作指示
          GO  TO  修正０１１
        WHEN      4
          MOVE  NC"データ不整合発生。管理者に連絡"
                                 TO  画面－操作指示
          GO  TO  修正０１１
        WHEN      OTHER
          CONTINUE
     END-EVALUATE.
*
 修正０２０.
     MOVE    SHIJI03        TO  画面－操作指示.
     MOVE    HYOJI02A       TO  画面－操作表示１.
     MOVE    SPACES         TO  画面－操作表示２.
*
 修正０２１.
*
     PERFORM 画面出力処理.
 修正０２２.
     MOVE    ZERO            TO  PF-FLAG.
     MOVE    ZERO            TO  ERR-FLAG.
*
     MOVE    "NE"            TO  G-EXC.
     MOVE    "GRP002"        TO  G-GRP.
     READ    画面ファイル.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "READ"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
     IF      G-ATT           =   PF9
                                     GO  TO 修正処理－開始.
     IF      G-ATT           =   ENTR
                                     GO  TO 修正０２３.
*
     MOVE    SHIJI99          TO  画面－操作指示.
     PERFORM 画面出力処理.
     GO  TO  修正０２１.
 修正０２３.
     IF      画面－設計担当   =  LOW-VALUE
                       MOVE  SPACES  TO  画面－設計担当
     END-IF.
     IF      画面－設計担当    =  SPACES
                       MOVE SPACES  TO  画面－設計担当名
                       GO  TO  修正０２７
     END-IF.
*
     MOVE    画面－設計担当    TO  組織－部所コード.
     MOVE    "00"              TO  組織－担当者係コード.
     READ    組織マスタ        INVALID
                       MOVE  2       TO  ERR-FLAG
                       GO  TO  修正０２７
     END-READ.
     MOVE    組織－部所名漢字  TO  画面－設計担当名.
*
*
 修正０２７.
     EVALUATE     ERR-FLAG
        WHEN      1
          MOVE  NC"設計部門が入力されてません"
                                 TO  画面－操作指示
          GO  TO  修正０２１
        WHEN      2
          MOVE  NC"設計部門入力に誤りがあります"
                                 TO  画面－操作指示
          GO  TO  修正０２１
        WHEN      OTHER
          CONTINUE
     END-EVALUATE.
 修正０３０.
*
     IF      ERR-FLAG   NOT  =  ZERO
                                PERFORM  画面出力処理
                                GO  TO  修正０２１.
*
 修正０６０.
     MOVE    HYOJI04        TO  画面－操作表示１.
     MOVE    SPACES         TO  画面－操作表示２.
     MOVE    SHIJI05        TO  画面－操作指示.
 修正０６１.
*
     PERFORM 画面出力処理.
*
 修正０６２.
     MOVE    ZERO            TO  PF-FLAG.
     MOVE    ZERO            TO  ERR-FLAG.
*
     MOVE    SPACES          TO  G-EXC.
     MOVE    "GRP003"        TO  G-GRP.
     READ    画面ファイル.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "READ"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*
     IF      G-ATT    =   PF9
                         GO  TO  修正０２０
     END-IF.
*
     IF      G-ATT    =   PF1
                         PERFORM  修正ファイル作成
                         PERFORM  照会修正ファイル作成
                         ADD   1     TO   INPUT-COUNT
                         GO  TO   修正処理－開始.
*
     MOVE    SHIJI99          TO  画面－操作指示.
     PERFORM 画面出力処理.
     GO  TO  修正０６２.


 修正処理－終了.
     EXIT.
*===============================================================*
*            登録内容の表示
*===============================================================*
 表示処理         SECTION.
 表示処理－開始.
     MOVE    照会－配制分金額
                              TO  画面－配制分受注予定額.
     MOVE    照会－その他金額
                              TO  画面－その他受注予定額.
     MOVE    照会－金額交渉状況区分
                              TO  画面－金額交渉状況区分.
     MOVE    照会－納入場所
                              TO  画面－納入場所.
     MOVE    照会－設計事務所
                              TO  画面－設計事務所コード.
     MOVE    画面－設計事務所コード  TO  取引－取引先コード.
     READ    取引先マスタ  INVALID
                           MOVE  SPACES   TO  取引－取引略名.
     MOVE    取引－取引略名      TO  画面－設計事務所名称.
     MOVE    照会－手伝図
                              TO  画面－手伝図.
     MOVE    照会－寸法図
                              TO  画面－寸法図.
     MOVE    照会－打合図
                              TO  画面－打合図.
     MOVE    照会－承認図
                              TO  画面－承認図.
     MOVE    照会－その他
                              TO  画面－その他.
     MOVE    照会－概要１
                              TO  画面－概要１.
     MOVE    照会－概要２
                              TO  画面－概要２.
     MOVE    照会－概要３
                              TO  画面－概要３.
     MOVE    照会－提出希望日
                              TO  画面－提出希望日.
     MOVE    照会－配電盤納入予定日
                              TO  画面－配電盤納入予定日.
     MOVE    照会－制御盤納入予定日
                              TO  画面－制御盤納入予定日.
     MOVE    照会－分電盤納入予定日
                              TO  画面－分電盤納入予定日.
     MOVE    照会－備考１
                              TO  画面－備考１.
     MOVE    照会－備考２
                              TO  画面－備考２.
     MOVE    照会－備考３
                              TO  画面－備考３.
*
     MOVE    照会－設計担当部所  TO  画面－設計担当.
     IF      画面－設計担当   =  SPACES
                          MOVE SPACES  TO  画面－設計担当名
                          GO  TO  表示処理－終了
     END-IF.
*
     MOVE    照会－設計担当部所  TO  組織－部所コード.
     MOVE    "00"              TO  組織－担当者係コード.
     READ    組織マスタ        INVALID
                       MOVE  SPACES  TO  組織－部所名漢字.
     MOVE    組織－部所名漢字  TO  画面－設計担当名.
*
*
 表示処理－終了.
     EXIT.
*===============================================================*
*            修正分ファイル作成
*===============================================================*
 修正ファイル作成         SECTION.
 修正ファイル作成－開始.
*
*****MOVE    WS-NO            TO  依頼－端末番号.
     MOVE    画面－見積番号   TO  依頼－見積番号.
     READ    依頼ファイル     INVALID
                            GO  TO  修正ファイル作成－終了.
*
*
     MOVE    画面－設計担当   TO  依頼－設計担当部所.
*
     ACCEPT       TIME-AREA      FROM      TIME.
     MOVE    DATE-AREA           TO  依頼－変更日.
     MOVE    TIME-AREA           TO  依頼－変更時間.
     MOVE    WS-NO               TO  依頼－変更端末.
*
     REWRITE    依頼－未受注物件作図依頼レコード.
     EVALUATE     F1-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "MIJUSJL2"     TO        WK-FLNAME
          MOVE    "REWRITE"      TO        WK-FLMODE
          MOVE    F1-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*
     MOVE    依頼－端末番号      TO  WK-WSNO.
 修正ファイル作成－終了.
     EXIT.
*===============================================================*
*            照会修正分ファイル作成
*===============================================================*
 照会修正ファイル作成         SECTION.
 照会修正ファイル作成－開始.
     MOVE    SPACES        TO  SY-BUCODE.
*
*集約部所処理対応改善   START
     MOVE    依頼－見積番号      TO  物件－見積ナンバー.
     READ    情報物件ファイル    INVALID
                             MOVE 画面－見積番号 (2:2)
                                          TO  SY-BUCODE
                             GO  TO  照会修正ファイル０００.
*
     MOVE    物件－部所コード      TO  変換－部所コード.
     MOVE    物件－担当者係コード  TO  変換－担当者係コード.
     READ    変換マスタ          INVALID
                             MOVE 画面－見積番号 (2:2)
                                          TO  SY-BUCODE
                             GO  TO  照会修正ファイル０００.
     MOVE    変換－集約部所コード
                                  TO  SY-BUCODE.
 照会修正ファイル０００.

*****MOVE    画面－見積番号 (2:2)  TO  照会－部所コード.
     MOVE    SY-BUCODE             TO  照会－部所コード.
     MOVE    画面－見積番号        TO  照会－見積番号.
*****MOVE    WS-NO                 TO  照会－端末番号.
     MOVE    WK-WSNO               TO  照会－端末番号.
     READ    照会ファイル     INVALID
                         GO  TO  照会修正ファイル作成－終了.
*
     MOVE    画面－設計担当      TO  照会－設計担当部所.
*
     ACCEPT       TIME-AREA      FROM      TIME.
     MOVE    DATE-AREA           TO  照会－変更日.
     MOVE    TIME-AREA           TO  照会－変更時間.
     MOVE    WS-NO               TO  照会－変更端末.
*
     REWRITE    照会－未受注物件作図依頼照会レコード.
     EVALUATE     F5-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "MIJUSYL1"     TO        WK-FLNAME
          MOVE    "REWRITE"      TO        WK-FLMODE
          MOVE    F5-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*
 照会修正ファイル作成－終了.
     EXIT.
******************************************************************
*       ＯＰＥＮチェック処理               (1.0)
******************************************************************
 ＯＰＥＮチェック処理            SECTION.
 ＯＰＥＮチェック処理－開始.
*未受注物件作図依頼ファイル
     EVALUATE     F1-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "MIJUSJL2"     TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F1-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*組織マスタ
     EVALUATE     F2-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "ASOSML1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F2-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*取引先マスタ
     EVALUATE     F3-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "ATORML1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F3-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*情報物件鑑ファイルル
     EVALUATE     F4-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "AJBGFL1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F4-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*未受注物件作図依頼照会ファイル
     EVALUATE     F5-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "MIJUSYL1"     TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F5-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*集約部所変換マスタ
     EVALUATE     F6-STS
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "ASBHML1"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F6-STS         TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
*    画面ファイル.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "OPEN"         TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
 ＯＰＥＮチェック処理－終了.
     EXIT.
******************************************************************
 終了処理            SECTION.
 終了処理－開始.
     CLOSE                  画面ファイル.
     CLOSE                  依頼ファイル.
     CLOSE                  照会ファイル.
     CLOSE                  取引先マスタ
                            組織マスタ
                            情報物件ファイル.
     CLOSE                  変換マスタ.
 終了処理－終了.
     EXIT.
*=====================================================*
*       第一画面出力
*=====================================================*
 画面出力処理               SECTION.
 画面出力－開始.
*
     MOVE      "SCREEN"      TO     G-GRP.
     MOVE      "  "          TO     G-EXC.
     MOVE      "MJS090D1"    TO     G-NAME.
     WRITE     画面－未受注作図依頼書.
     EVALUATE     F-STT
        WHEN      "00"
          CONTINUE
        WHEN      OTHER
          MOVE    "MJS090CG"     TO        WK-PGMID
          MOVE    "GM-FILE"      TO        WK-FLNAME
          MOVE    "WRITE"        TO        WK-FLMODE
          MOVE    F-STT          TO        WK-FLSTS
          MOVE    SPACE          TO        WK-FLKEY
          PERFORM           異常終了処理
     END-EVALUATE.
 画面出力－終了.
     EXIT.
******************************************************************
*    異常終了処理　　　
******************************************************************
 異常終了処理                    SECTION.
 異常終了処理－開始.
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

 異常終了処理－終了.
     EXIT.
*
