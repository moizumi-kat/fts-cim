# -*- coding: utf-8 -*-
"""A10040PO（鑑処理）。工程11-1 の子6本のうちの1本。

   現行 A10040PO.COB（5,159行・注記を除いて4,069行）を写したもの。
   段落名・判定の順番は現行のまま。行番号を註に残してあるので、
   迷ったら現物の同じ行を見ること。

   ■ 全体の形（処理開始 SECTION・559行）
       PERFORM 初期処理Ｒ
       PERFORM インターフェースＲ
       PERFORM 主処理Ｒ UNTIL END-FLG = "END"
       EXIT PROGRAM

   ■ 画面とファイル
       画面     A10040D1（55項目・1,123バイト）… gamen_a10040d1.py
       ファイル 索引18本                        … fairu_a10040po.py

   ■ いまどこまで出来ているか
       第1項目群（処理区の選択）まで。GRPA02〜07 はこれから。
       出来ていない段落は 未実装 を投げる（黙って素通りしない）。
"""
import datetime

from . import vld, fairu, vld_msg
from . import gamen_a10040d1 as 画面定義
from .fairu_a10040po import FAIRU
from .a10010po import Linkage, Abend


class ExitProgram(Exception):
    """COBOL の EXIT PROGRAM。親（A10010PO）へ戻る。"""


class StopRun(Exception):
    """COBOL の STOP RUN。ABEND-RTN を通らず、その場で止まるもの。

       現行 628行
           WHEN OTHER
               DISPLAY "鑑画面死亡" UPON DSP
               STOP RUN
       ＝ ABEND ではないので、PROGRAM-STATUS も立たない。表示した文を持つ。
    """

    def __init__(self, hyoji):
        super().__init__(hyoji)
        self.hyoji = hyoji


class 未実装(Exception):
    """まだ写していない段落。黙って素通りさせないために投げる。"""

    def __init__(self, danraku, gyo):
        super().__init__('%s（A10040PO.COB %d行）はまだ写していません' % (danraku, gyo))
        self.danraku, self.gyo = danraku, gyo


class A10040PO:
    """鑑処理。"""

    PGMID = 'A10040PO'

    # 定数（WORKING-STORAGE 398-412行）
    新規, 修正, 変更, 取消, 複写１, 複写２ = 1, 2, 3, 4, 5, 6
    概算新規, 概算修正 = 8, 9
    計算済, 未計算 = 1, 0
    見積, 物件 = 1, 2                     # 発番区分（406-407行）
    製番あり, 製番なし = 1, 0             # （408-409行）

    # 受渡鑑処理区分（1088行）処理区 → 鑑画面処理区分
    鑑処理区分 = {新規: '1', 修正: '2', 変更: '3', 取消: '4',
                  複写１: '5', 複写２: '6', 概算新規: '8', 概算修正: '9'}

    def __init__(self, con=None, sousa=None, db=None, kyou=None):
        self.con, self.db = con, db
        self.画面 = vld.Gamen(画面定義, sousa)
        self.link = Linkage()        # 受け渡し領域は常にある（実行 で差し替わる）
        self.ファイル = {}
        if con is not None and db is not None:
            for ronri, (_na, hyo, kagi, _sts) in FAIRU.items():
                self.ファイル[ronri] = fairu.Fairu(con, hyo, kagi, ronri, db=db)
        self._kyou = kyou                      # 試験で日付を差し替えるため
        self.END_FLG = ''
        self.ERR_FLG = 0
        self.SAVE_GROUP = ''
        self.READ_MODE = '  '
        self.DSP_FUNC = ''
        self.総額計算フラグ = self.未計算
        self.WK_NEN = 0
        self.WK_SEIREKI = 0
        self.WK_YMD = 0
        self.WK_TIME = 0
        self.TR_CNL_FLG = 0
        self.発番区分 = 0
        self.端末ＩＤ = ''
        # 発番用ワーク（378行）年区分1＋支店区分2＋施主区分1＋空白2
        self.WK_NEN_KUBUN = ''
        self.WK_SITEN_KUBUN = ''
        self.WK_SESHU_KUBUN = ''
        # 更新用ＶＬＤ（うしろの更新処理へ渡すメッセージ）
        self.VLD1, self.VLD2 = vld_msg.tsukuru()
        self.作業見積ＮＯ = ''
        self.作業複写元見積ＮＯ = ''
        self.作業製番ステータス = 0        # 製番あり=1／なし=0（411行）
        self.退避見積番号 = ''
        self.項目フラグ = 0

    # ── 画面の項目を楽に読み書きする ───────────────
    def g(self, na):
        return self.画面.atai(na)

    def gs(self, na, v):
        self.画面.ireru(na, v)

    def 数(self, na):
        s = self.g(na).strip()
        return int(s) if s.isdigit() else None

    # ================================================================
    #  処理開始（559行）
    # ================================================================
    def 実行(self, link):
        self.link = link
        try:
            self.初期処理Ｒ()
            self.インターフェースＲ()
            while self.END_FLG != 'END':
                self.主処理Ｒ()
        except ExitProgram:
            pass
        return link

    # ================================================================
    #  初期処理Ｒ（567行）
    # ================================================================
    def 初期処理Ｒ(self):
        # MOVE 画面情報 TO A10040D1（571行）
        joho = self.link.画面情報.encode('cp932', 'replace')
        if len(joho) >= self.画面.nagasa and joho.strip():
            self.画面.rec_ireru(joho[:self.画面.nagasa])
        self.画面.seigyo_shokika()                       # 制御項目初期化Ｒ（572行）

        kyou = self._kyou or datetime.datetime.now()
        # ACCEPT システム日付 FROM DATE（574行）＝ YYMMDD
        #   **システム日付は画面の項目そのもの**（A10040D1 の 0行72桁）。
        #   ACCEPT はそこへ直に入る＝画面の右上に出る日付になる。
        #   ここを写し忘れていて、ハードコピーとの突き合わせで見つかった
        #   （紙は 26.11.20、移植は空白だった。2026-11-20）。
        self.gs('システム日付',
                '%02d%02d%02d' % (kyou.year % 100, kyou.month, kyou.day))
        self.WK_NEN = kyou.year % 100
        wk_tsuki_hi = kyou.month * 100 + kyou.day
        self.WK_TIME = kyou.hour * 10000 + kyou.minute * 100 + kyou.second

        # 年度編集（580行）
        self.WK_SEIREKI = 19 if self.WK_NEN >= 90 else 20
        # 年度区分判定（588行）3月21日より前は前の年度
        if wk_tsuki_hi < 321:
            # 00.01.04 FTH指示（594行）0年のときは99年にする
            self.WK_NEN = 99 if self.WK_NEN == 0 else self.WK_NEN - 1
        self.WK_YMD = (self.WK_SEIREKI * 1000000
                       + (kyou.year % 100) * 10000 + kyou.month * 100 + kyou.day)

        self.END_FLG = 'INT'                              # （600行）

    # ================================================================
    #  インターフェースＲ（606行）
    # ================================================================
    def インターフェースＲ(self):
        self.総額計算フラグ = self.未計算                 # （608行）
        iku = self.link.行き画面.strip()
        if iku == 'GRPA01':
            self.画面出力Ｒ(); self.SAVE_GROUP = 'GRPA01'
        elif iku == 'GRPA03':
            self.画面出力Ｒ(); self.前回入力値Ｒ(); self.SAVE_GROUP = 'GRPA03'
        elif iku == 'GRPA04':
            self.画面出力Ｒ(); self.SAVE_GROUP = 'GRPA04'
        elif iku == '':
            # WHEN SPACE（619行）鑑画面処理区分もキーＩＤも空白のときだけ
            if self.link.鑑画面処理区分.strip() == '' and self.link.キーＩＤ.strip() == '':
                self.初期処理Ｒ()
                self.SAVE_GROUP = 'GRPA01'
        else:
            # WHEN OTHER（628行）DISPLAY "鑑画面死亡" UPON DSP / STOP RUN
            raise StopRun('鑑画面死亡')

    # ================================================================
    #  主処理Ｒ（638行）
    # ================================================================
    def 主処理Ｒ(self):
        self.メッセージＲ()
        self.入力強調処理Ｒ()
        self.画面出力Ｒ()
        gun = self.SAVE_GROUP
        if gun == 'GRPA01':
            self.GRPA01_RTN()
        elif gun == 'GRPA02':
            self.GRPA02_RTN()
        elif gun in ('GRPA03', 'GRPA04', 'GRPA05', 'GRPA06', 'GRPA07'):
            raise 未実装('%s-RTN' % gun, {'GRPA03': 788, 'GRPA04': 866,
                                          'GRPA05': 0, 'GRPA06': 0,
                                          'GRPA07': 0}[gun])

    # ================================================================
    #  第１項目群処理（657行）
    # ================================================================
    def GRPA01_RTN(self):
        self.画面入力Ｒ()                                  # （659行）
        self.画面.seigyo_shokika()                         # （660行）
        if self.DSP_FUNC == 'E000':
            self.SAVE_GROUP = 'GRPA02'                     # （663行）
            ku = self.数('処理区')
            if ku in (self.新規, self.修正, self.変更,
                      self.取消, self.複写１, self.複写２):
                self.XMROTEND()                            # （672行）
            elif ku == self.概算新規:
                self.受渡第１項目１()                      # （674行）
            elif ku == self.概算修正:
                self.受渡第１項目２()                      # （676行）
            else:
                # WHEN OTHER（677行）処理区が正しくない
                self.画面.zoku('処理区', 'EDIT-COLOR', 'R')
                self.画面.zoku('処理区', 'EDIT-CURSOR', 'C')
                self.ERR_FLG = 2
                self.SAVE_GROUP = 'GRPA01'
                self.XMROTEND()
        elif self.DSP_FUNC == 'F010':
            self.受渡第１項目３()                          # （688行）
        else:
            self.ERR_FLG = 1                               # （690行）
            self.XMROTEND()

    # ── 受渡（699／714／729行）──────────────────
    def _受渡(self, modori, key_id, 区分あり=True):
        if 区分あり:
            self.受渡鑑処理区分()
        self.link.詰める('戻り画面', modori)
        self.link.詰める('キーＩＤ', key_id)
        self.link.詰める('見積ナンバー', self.g('見積なんば'))
        self.link.詰める('画面情報', self.画面.rec().decode('cp932', 'replace'))
        self.XMROTEND()
        raise ExitProgram()

    def 受渡第１項目１(self):
        """概算新規 → 概算画面へ（700行）"""
        self._受渡('GRPF01', 'E000')

    def 受渡第１項目２(self):
        """概算修正 → 概算画面へ（715行）"""
        self._受渡('GRPF01', 'E000')

    def 受渡第１項目３(self):
        """ＰＦ１０ → 終了（730行）鑑処理区分は渡さない"""
        self._受渡('    ', 'F010', 区分あり=False)

    def 受渡鑑処理区分(self):
        """処理区 → 鑑画面処理区分（1088行）
           概算（8・9）のときは処理区をゼロに戻す（1109・1112行）"""
        ku = self.数('処理区')
        if ku in self.鑑処理区分:
            self.link.詰める('鑑画面処理区分', self.鑑処理区分[ku])
            if ku in (self.概算新規, self.概算修正):
                self.gs('処理区', 0)

    # ================================================================
    #  第２項目群処理（745行）
    # ================================================================
    def GRPA02_RTN(self):
        self.画面入力Ｒ()                                  # （747行）
        self.画面.seigyo_shokika()                         # （748行）
        self.TR_CNL_FLG = 0                                # （749行）
        if self.DSP_FUNC == 'E000':
            self.SAVE_GROUP = 'GRPA03'                     # （752行）
            ku = self.数('処理区')
            if ku == self.新規:
                self.新規第２項目群()
            elif ku == self.修正:
                self.修正第２項目群()
            elif ku == self.変更:
                self.変更第２項目群()
            elif ku == self.取消:
                self.取消第２項目群()
            elif ku == self.複写１:
                self.複写物新第２項目群()
            elif ku == self.複写２:
                self.複写物修第２項目群()
            if self.TR_CNL_FLG == 0:                       # （762行）
                self.XMROTEND()
        elif self.DSP_FUNC == 'F005':
            # ＰＦ５ 前の項目群へ戻る（765行）
            for n in (1, 2, 3, 4):
                self.画面.gun_shoukyo(n)
            self.SAVE_GROUP = 'GRPA01'                     # （774行）
            self.XMROTCNL()
        else:
            self.ERR_FLG = 1                               # （778行）
            self.XMROTEND()

    def 新規第２項目群(self):
        """（1258行）担当者と施主大分類を確かめ、見積番号と物件番号を発番する。"""
        self.SAVE_GROUP = 'GRPA03'                         # （1259行）
        self.gs('変更回数', 0)                             # （1260行）
        self.画面初期設定()                                # （1261行）

        if self.g('担当者ＣＤ').strip() == '':             # （1263行）
            self._あかい('担当者ＣＤ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        st = self.担当者よみ()
        if st == fairu.NASHI:                              # （1280行）
            self._あかい('担当者ＣＤ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        # IF ASOS-STSCD = "00"（1296行）
        if self.g('施主大分類ＣＤ').strip() == '':         # （1297行）
            self.ERR_FLG = 2; self.SAVE_GROUP = 'GRPA02'
            self._あかい('施主大分類ＣＤ')
            return
        f = self.ファイル['ANAMML1']
        if f.yomu('00', self.g('施主大分類ＣＤ')) == fairu.NASHI:   # （1341行）
            self._あかい('施主大分類ＣＤ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        self.gs('施主大分類名', f['RYAKU'])                # （1311行）

        # 見積番号の発番（1313行）
        self.発番区分 = self.見積
        self.見積発番処理Ｒ()
        if self.g('見積なんば').strip() == '':             # （1315行）
            self.ERR_FLG = 7; self.SAVE_GROUP = 'GRPA02'
            self.XMROTCNL(); self.TR_CNL_FLG = 1
            return
        # 物件番号の発番（1323行）
        self.発番区分 = self.物件
        self.見積発番処理Ｒ()
        if self.g('物件ナンバー').strip() == '':           # （1325行）
            self.ERR_FLG = 8; self.SAVE_GROUP = 'GRPA02'
            self.XMROTCNL(); self.TR_CNL_FLG = 1
            return
        o = self.ファイル['ASOSML1']
        self.gs('作成部所名', o['BSYNAM'])                 # （1333行）
        self.gs('担当者名', o['TANNAM'])
        self.チェックＦ出力処理Ｒ(self.g('見積なんば'))    # （1336行）

    def 修正第２項目群(self):
        """（1362行）"""
        self.SAVE_GROUP = 'GRPA03'
        if self.g('見積なんば').strip() == '':
            self._あかい('見積なんば'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
        else:
            self.AJBGFL1_CHECK_RTN()

    def 変更第２項目群(self):
        """（1381行）修正との違いは CHECK-RTN-2（外注区分も見る）"""
        self.SAVE_GROUP = 'GRPA03'
        if self.g('見積なんば').strip() == '':
            self._あかい('見積なんば'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
        else:
            self.AJBGFL1_CHECK_RTN_2()

    def 取消第２項目群(self):
        """（1400行）取消は第7項目群（確認）へ進む。製番が付いていたら消せない。"""
        self.SAVE_GROUP = 'GRPA07'                      # （1401行）
        self.ERR_FLG = 3                                # （1403行）
        if self.g('見積なんば').strip() == '':
            self._あかい('見積なんば'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        self.受注項目存在判定()                          # （1413行）
        if self.作業製番ステータス != self.製番なし:
            self.ERR_FLG = 10                            # （1418行）製番あり＝消せない
        self.AJBGFL1_CHECK_RTN()                         # （1420行）

    def _複写第２項目群(self, gyo):
        """複写物新（1428行）・複写物修（1480行）。違いは全項目群出力の有無だけ。"""
        self.SAVE_GROUP = 'GRPA03'
        self.担当者コード判定()
        if self.ERR_FLG:
            return
        self.複写元見積判定()
        if self.ERR_FLG:
            return
        self.施主大分類判定()
        if self.ERR_FLG:
            return
        self.全項目群出力Ｒ()                            # （1436・1488行）
        self.発番区分 = self.見積
        self.見積発番処理Ｒ()
        if self.g('見積なんば').strip() == '':           # （1439・1491行）
            self.ERR_FLG = 7; self.SAVE_GROUP = 'GRPA02'
            self.XMROTCNL(); self.TR_CNL_FLG = 1
            return
        if gyo == 1:
            # 複写物新だけ 物件ナンバーも発番する（1447行）
            self.発番区分 = self.物件
            self.見積発番処理Ｒ()
            if self.g('物件ナンバー').strip() == '':
                self.ERR_FLG = 8; self.SAVE_GROUP = 'GRPA02'
                self.XMROTCNL(); self.TR_CNL_FLG = 1
                return
        self.チェックＦ出力処理Ｒ(self.g('見積なんば'))
        self.チェックＦ出力処理Ｒ(self.g('複写元見積ナンバ'))
        self.作業見積ＮＯ = self.g('見積なんば')
        self.作業複写元見積ＮＯ = self.g('複写元見積ナンバ')
        self.バック開始処理２()

    def 複写物新第２項目群(self):
        self._複写第２項目群(1)

    def 複写物修第２項目群(self):
        self._複写第２項目群(2)

    # ── 鑑ファイルの確認（1519／1570行）────────
    def _AJBG_CHECK(self, gaikbn_mo_miru):
        """見積なんばで鑑ファイルを引き、使えるかどうかを見る。
           CHECK-RTN（1519行）と CHECK-RTN-2（1570行）の違いは
           **外注区分も見るかどうか**だけ（1580行）。"""
        f = self.ファイル['AJBGFL1']
        st = f.yomu(self.g('見積なんば'))
        if st == fairu.NASHI:                            # （1555行）その見積が無い
            self._あかい('見積なんば'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        if st != fairu.SEIJOU:
            raise Abend('AJBGFL1', 'READ', st)
        achk = self.ACHKFL1_READ_RTN(self.g('見積なんば'))
        if achk != fairu.NASHI:                          # （1546行）ほかの人が使用中
            self._あかい('見積なんば'); self.ERR_FLG = 5
            self.SAVE_GROUP = 'GRPA02'
            return
        tsukaeru = (f['DELFLG'] != '1')                  # （1528行）消された見積は不可
        if gaikbn_mo_miru:
            tsukaeru = tsukaeru and ((f['GAIKBN'] or '').strip() == '')
        if not tsukaeru:                                 # （1536・1588行）
            self._あかい('見積なんば'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        self.チェックＦ出力処理Ｒ(self.g('見積なんば'))
        self.作業見積ＮＯ = self.g('見積なんば')
        self.バック開始処理２()
        self.全項目群出力Ｒ()

    def AJBGFL1_CHECK_RTN(self):
        self._AJBG_CHECK(False)

    def AJBGFL1_CHECK_RTN_2(self):
        self._AJBG_CHECK(True)

    def 複写元見積判定(self):
        """（1681行）複写元の見積が使えるかを見る。**外注区分が "1" なら不可。**"""
        self.SAVE_GROUP = 'GRPA03'
        f = self.ファイル['AJBGFL1']
        st = f.yomu(self.g('複写元見積ナンバ'))
        if st == fairu.NASHI:                            # （1710行）
            self._あかい('複写元見積ナンバ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        if st != fairu.SEIJOU:
            raise Abend('AJBGFL1', 'READ', st)
        achk = self.ACHKFL1_READ_RTN(self.g('複写元見積ナンバ'))
        if achk != fairu.NASHI:                          # （1702行）使用中
            self._あかい('複写元見積ナンバ'); self.ERR_FLG = 5
            self.SAVE_GROUP = 'GRPA02'
            return
        if (f['GAIKBN'] or '').strip() == '1':           # （1691行）
            self._あかい('複写元見積ナンバ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'

    def 受注項目存在判定(self):
        """（1623行）ワーク項目に製番の付いた行があるかを見る。"""
        self.作業製番ステータス = self.製番なし
        mituno = self.g('見積なんば')
        self.退避見積番号 = mituno
        f = self.ファイル['AWKKFL1']
        if f.hajime(mituno, 0) != fairu.SEIJOU:          # START KEY >=（1627行）
            return
        self.項目フラグ = 0
        while True:
            if f.tsugi() != fairu.SEIJOU:                # AT END（3106行）
                self.項目フラグ = 1
                break
            if (f['SEIBAN'] or '').strip() != '':
                self.作業製番ステータス = self.製番あり  # （3115行）
                break
            self.作業製番ステータス = self.製番なし
            if self.退避見積番号 != (f['MITUNO'] or '').strip():
                self.項目フラグ = 1                      # （3133行）別の見積に移った
                break
            if int(f['MITKOB'] or 0) == 999999:          # （3126行）
                self.項目フラグ = 1
                break

    # ── チェックＦ（4062／3814行）──────────────
    def ACHKFL1_READ_RTN(self, mituno):
        """（4062行）札があれば日付を書き直す。無ければ "23" のまま。"""
        f = self.ファイル['ACHKFL1']
        st = f.yomu(mituno)
        if st == fairu.SEIJOU:
            self.ACHKFL1_REWRITE_RTN()
        elif st != fairu.NASHI:
            raise Abend('ACHKFL1', 'READ', st)
        return st

    def ACHKFL1_REWRITE_RTN(self):
        """（3814行）"""
        f = self.ファイル['ACHKFL1']
        f['UPDDAY'] = self.WK_YMD
        f['UPDTIM'] = self.WK_TIME
        f['WSID'] = self.端末ＩＤ
        st = f.kakinaosu()
        if st != fairu.SEIJOU:
            raise Abend('ACHKFL1', 'REWRITE', st)
        return st

    # ── 鑑ファイルの中身を画面へ（3572行）──────
    def 担当者処理Ｒ(self):
        """（3528行）

           ■ AJBG-CRTTAN は表に無い（2026-11-17 実測）
             CRTBSY（部所コード 2桁）＋ CRTKKR（担当者係コード 2桁）をまとめた
             **集団項目**。画面の担当者ＣＤ（4桁）と同じ作り。
             現行 3528-3533行が
               MOVE AJBG-CRTTAN TO 担当者ＣＤ
               MOVE AJBG-CRTBSY TO ASOS-BSYOCD
               MOVE AJBG-CRTKKR TO ASOS-TANCD
             と続けて書いているのが根拠（ASUN-SUNPO と同じ形）。
        """
        a = self.ファイル['AJBGFL1']
        self.gs('担当者ＣＤ', '%s%s' % ((a['CRTBSY'] or '').ljust(2),
                                        (a['CRTKKR'] or '').ljust(2)))
        o = self.ファイル['ASOSML1']
        if o.yomu(a['CRTBSY'], a['CRTKKR']) != fairu.SEIJOU:
            raise Abend('ASOSML1', 'READ', o.status)
        self.gs('作成部所名', o['BSYNAM'])
        self.gs('担当者名', o['TANNAM'])

    def 施主大分類処理(self):
        """（3554行）"""
        a = self.ファイル['AJBGFL1']
        self.gs('施主大分類ＣＤ', a['SEDICD'])
        n = self.ファイル['ANAMML1']
        if n.yomu('00', a['SEDICD']) != fairu.SEIJOU:
            raise Abend('ANAMML1', 'READ', n.status)
        self.gs('施主大分類名', n['RYAKU'])

    def _namae(self, ronri, kagi, hashira, saki, nakereba=None):
        """マスタを引いて名前を画面へ。無ければ nakereba（既定は触らない）。"""
        f = self.ファイル[ronri]
        st = f.yomu(*kagi)
        if st == fairu.SEIJOU:
            self.gs(saki, f[hashira])
        elif st == fairu.NASHI:
            if nakereba is not None:
                self.gs(saki, nakereba)
        else:
            raise Abend(ronri, 'READ', st)

    def 全項目群出力Ｒ(self):
        """（3572行）鑑ファイルの中身を画面の全項目へ。"""
        a = self.ファイル['AJBGFL1']
        ku = self.数('処理区')
        if ku not in (self.複写１, self.複写２):          # （3573行）
            self.担当者処理Ｒ()
            self.施主大分類処理()
        # 変更回数（3582行）
        if ku in (self.新規, self.複写１, self.複写２):
            self.gs('変更回数', 0)
        elif ku == self.変更:
            a['UPDCNT'] = int(a['UPDCNT'] or 0) + 1       # （3588行）変更は1つ増やす
            self.gs('変更回数', a['UPDCNT'])
        elif ku in (self.修正, self.取消):
            self.gs('変更回数', a['UPDCNT'])

        self.gs('物件ナンバー', a['BKENNO'])
        self.gs('件名カナ', a['KNMEIK'])
        self.gs('件名１', a['KENME1'])
        self.gs('件名２', a['KENME2'])
        self.gs('件名３', a['KENME3'])
        self.gs('価格区分', a['KAKKBN'])
        self._namae('ANAMML1', ('02', a['KAKKBN']), 'RYAKU', '価格区分名')
        self.gs('依頼先コード', a['IRAICD'])
        self._namae('ATORML1', (a['IRAICD'],), 'TORNAR', '依頼先名')
        self.gs('仕様コード', a['SIYOU1'])
        self._namae('ASIYML1', (a['SIYOU1'],), 'SIYONA', '仕様名')
        self.gs('仕様２コード', a['SIYOU2'])
        self._namae('ASIYML1', (a['SIYOU2'],), 'SIYONA', '仕様名２', nakereba='')
        self.gs('宛名１', a['ATENA1'])
        self.gs('宛名２', a['ATENA2'])
        self.gs('施主コード', a['SESYCD'])
        self._namae('ATORML1', (a['SESYCD'],), 'TORNAR', '施主名', nakereba='')
        self.gs('設計事務所コード', a['SEKECD'])
        self._namae('ATORML1', (a['SEKECD'],), 'TORNAR', '設計事務所名', nakereba='')
        self.gs('建設業者', a['KENGCD'])
        self._namae('ATORML1', (a['KENGCD'],), 'TORNAR', '建設業者名', nakereba='')
        self.gs('電気工事業者ＣＤ', a['KETDEN'])
        self._namae('ATORML1', (a['KETDEN'],), 'TORNAR', '電気工事業者名', nakereba='')
        self.gs('最早納期', a['FASTNK'])
        self.gs('最終納期', a['LASTNK'])
        self.gs('納入期日', a['NONUHI'])
        self.gs('受渡場所', a['UKEWAB'])
        self.gs('支払条件', a['SIHARI'])
        self.gs('荷造及び運賃', a['NIDUUN'])
        self.gs('見積有効期限', a['MITKGN'])
        self.gs('御照会番号', a['SKAINO'])
        self.gs('御照会日付', a['SKAIHI'])
        for i, na in enumerate(('掛率配電盤', '掛率制御盤', '掛率分電盤', '掛率その他'), 1):
            self.gs(na, a['KAKRIT_%d' % i])
        self.gs('特記事項１', a['TOKKI1'])
        self.gs('特記事項２', a['TOKKI2'])
        self.gs('特記事項３', a['TOKKI3'])
        self.gs('見積総額', a['MITGAK_1'])
        self.gs('見積率', a['MITRIT'])
        self.gs('差引合計金額', a['SASKIN_1'])

    # ── 判定（1641／1724行）────────────────────
    def 担当者コード判定(self):
        """（1642行）"""
        self.SAVE_GROUP = 'GRPA03'
        if self.g('担当者ＣＤ').strip() == '':
            self._あかい('担当者ＣＤ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'
            return
        if self.担当者よみ() == fairu.NASHI:
            self._あかい('担当者ＣＤ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'

    def 施主大分類判定(self):
        """（1725行）"""
        self.SAVE_GROUP = 'GRPA03'
        if self.g('施主大分類ＣＤ').strip() == '':
            self.ERR_FLG = 2; self.SAVE_GROUP = 'GRPA02'
            self._あかい('施主大分類ＣＤ')
            return
        f = self.ファイル['ANAMML1']
        if f.yomu('00', self.g('施主大分類ＣＤ')) == fairu.SEIJOU:
            self.gs('施主大分類名', f['RYAKU'])
        else:
            self._あかい('施主大分類ＣＤ'); self.ERR_FLG = 2
            self.SAVE_GROUP = 'GRPA02'

    def 担当者よみ(self):
        """担当者ＣＤ（4桁）＝ 部所２桁＋担当２桁 で組織マスタを引く（1272行）"""
        cd = self.g('担当者ＣＤ')
        f = self.ファイル['ASOSML1']
        st = f.yomu(cd[0:2], cd[2:4])
        if st == fairu.SEIJOU:
            self.gs('作成部所名', f['BSYNAM'])             # （1278行）
            self.gs('担当者名', f['TANNAM'])
        return st

    def _あかい(self, na):
        """誤りの項目を赤くして、カーソルを置く。"""
        self.画面.zoku(na, 'EDIT-COLOR', 'R')
        self.画面.zoku(na, 'EDIT-CURSOR', 'C')

    # ================================================================
    #  発番（3374／3492／3506／3427／3466行）
    # ================================================================
    def 画面初期設定(self):
        """（4079行）新規のときの決まり文句と、掛率の初期値１"""
        self.gs('納入期日', '御打ち合わせの上')
        self.gs('受渡場所', '車上渡し')
        self.gs('支払条件', '従来通り')
        self.gs('荷造及び運賃', '含入')
        self.gs('見積有効期限', '６０日')
        for n in ('掛率配電盤', '掛率制御盤', '掛率分電盤', '掛率その他'):
            self.gs(n, 1)

    def 発番キー設定Ｒ(self):
        """（3506行）年の下1桁＋支店2桁＋施主1桁。区分は見積=01／物件=00"""
        self.WK_NEN_KUBUN = '%02d' % self.WK_NEN
        self.WK_NEN_KUBUN = self.WK_NEN_KUBUN[1]           # WK-NEN(2:1)
        self.WK_SITEN_KUBUN = self.g('担当者ＣＤ')[0:2]
        self.WK_SESHU_KUBUN = self.g('施主大分類ＣＤ')[0:1]
        f = self.ファイル['AHATML1']
        f['HATKBN'] = '01' if self.発番区分 == self.見積 else '00'
        f['HATUCD'] = self.発番用ワーク()
        return f

    def 発番用ワーク(self):
        """発番用ワーク（378行）年1＋支店2＋施主1＋空白2 ＝ 6桁"""
        return '%s%s%s%s' % (self.WK_NEN_KUBUN,
                             self.WK_SITEN_KUBUN.ljust(2),
                             self.WK_SESHU_KUBUN.ljust(1), '  ')

    def 発番編集Ｒ(self):
        """（3492行）発番用ワークの先頭4桁＋連番4桁 ＝ 8桁"""
        f = self.ファイル['AHATML1']
        edit = self.発番用ワーク()[:4] + '%04d' % int(f['RENBAN'] or 0)
        if self.発番区分 == self.見積:
            self.gs('見積なんば', edit)
        else:
            self.gs('物件ナンバー', edit)

    def _発番を空に(self):
        if self.発番区分 == self.見積:
            self.gs('見積なんば', '')
        else:
            self.gs('物件ナンバー', '')

    def 見積発番処理Ｒ(self):
        """（3374行）"""
        f = self.発番キー設定Ｒ()
        st = f.yomu(f['HATKBN'], f['HATUCD'])
        if st == fairu.SEIJOU:
            self.AHATML1_PROC_RTN_1()
            return
        if st != fairu.NASHI:
            raise Abend('AHATML1', 'READ', st)
        # "23"＝その年の発番レコードが無い（3382行）
        # 前の年で引き直す。年が0なら99にする（3388行）
        self.WK_NEN = 99 if self.WK_NEN == 0 else self.WK_NEN - 1
        f = self.発番キー設定Ｒ()
        st = f.yomu(f['HATKBN'], f['HATUCD'])
        if st == fairu.NASHI:                              # （3398行）
            self.WK_NEN += 1
            self._発番を空に()
        elif st == fairu.SEIJOU:
            self.AHATML1_PROC_RTN_3()                      # （3407行）
        else:
            raise Abend('AHATML1', 'READ', st)

    def AHATML1_PROC_RTN_1(self):
        """（3427行）連番を1つ進める。上限に達していたら空にする。"""
        f = self.ファイル['AHATML1']
        if int(f['RENBAN'] or 0) == int(f['RJOGEN'] or 0):
            self._発番を空に()
            return
        f['RENBAN'] = int(f['RENBAN'] or 0) + 1
        st = self.AHATML1_REWRITE_RTN()
        if st == fairu.SEIJOU:
            self.発番編集Ｒ()
        else:
            self._発番を空に()
            raise Abend('AHATML1', 'REWRITE', st)

    def AHATML1_PROC_RTN_3(self):
        """（3466行）前の年のレコードがあったので、今年のレコードを作る。"""
        self.WK_NEN += 1
        f = self.発番キー設定Ｒ()
        st = self.AHATML1_WRITE_RTN()
        if st == fairu.SEIJOU:
            self.発番編集Ｒ()
        else:
            self.gs('見積なんば', '')
            raise Abend('AHATML1', 'WRITE', st)

    def AHATML1_WRITE_RTN(self):
        """（3861行）下限0・連番1・上限9999で作る。"""
        f = self.ファイル['AHATML1']
        f['RKAGEN'] = 0
        f['RENBAN'] = 1
        f['RJOGEN'] = 9999
        f['CRTDAY'] = self.WK_YMD
        f['UPDDAY'] = self.WK_YMD
        f['UPDTIM'] = self.WK_TIME
        f['WSID'] = self.端末ＩＤ
        return f.kaku()

    def AHATML1_REWRITE_RTN(self):
        """（3845行）"""
        f = self.ファイル['AHATML1']
        f['UPDDAY'] = self.WK_YMD
        f['UPDTIM'] = self.WK_TIME
        f['WSID'] = self.端末ＩＤ
        return f.kakinaosu()

    def チェックＦ出力処理Ｒ(self, mituno):
        """（3166行）同時に触らせないための札を立てる。"""
        f = self.ファイル['ACHKFL1']
        f.rec = {'MITUNO': mituno, 'TENKFK': '0', 'TENKFM': '0',
                 'YOBIF': '', 'YOBI': '',
                 'CRTDAY': self.WK_YMD, 'UPDDAY': self.WK_YMD,
                 'UPDTIM': self.WK_TIME, 'WSID': self.端末ＩＤ}
        st = f.kaku()
        if st != fairu.SEIJOU:
            raise Abend('ACHKFL1', 'WRITE', st)
        return st

    # ================================================================
    #  バック開始処理（4095／4133／4181行）
    #    うしろで動く更新処理へ「この見積を処理せよ」と知らせる
    # ================================================================
    # 処理区 → 処理ＩＤ（4104・4147行）
    _SHORI_ID = {1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6'}

    def バック開始処理１(self):
        """（4095行）ＶＬＤ１へ1件。データ長は9（見積ＮＯ8＋処理ＩＤ1）。"""
        m = self.VLD1.atarashii()                      # INITIALIZE REC1
        m['見積ＮＯ１'] = self.作業見積ＮＯ
        m['論理宛先名１'] = self.link.ＶＬＤ一
        m['処理種別１'] = 'WT'
        m['データ長１'] = 9
        m['優先順位１'] = 9
        m['処理ＩＤ１'] = self._SHORI_ID.get(self.数('処理区'), ' ')
        st = self.VLD1.kaku(m)
        if st != vld_msg.SEIJOU:
            raise Abend('VLDA1001', 'WRITE', st)
        return m

    def バック開始処理２(self):
        """（4133行）ＶＬＤ２へ1件。データ長は17。
           複写のときだけ「複写元→複写先」の向きで入れる（4136行）。"""
        m = self.VLD2.atarashii()                      # INITIALIZE REC2
        ku = self.数('処理区')
        if ku in (self.複写１, self.複写２):
            m['見積ＮＯ２'] = self.作業複写元見積ＮＯ
            m['複写先見積ＮＯ２'] = self.作業見積ＮＯ
        else:
            m['見積ＮＯ２'] = self.作業見積ＮＯ
            m['複写先見積ＮＯ２'] = ''
        m['論理宛先名２'] = self.link.ＶＬＤ二
        m['処理種別２'] = 'WT'
        m['データ長２'] = 17
        if ku in self._SHORI_ID:
            m['処理ＩＤ２'] = self._SHORI_ID[ku]
        elif ku in (self.概算新規, self.概算修正):
            pass                                        # CONTINUE（4160行）
        else:
            m['処理ＩＤ２'] = '7'                       # （4165行）
        m['優先順位２'] = 9
        st = self.VLD2.kaku(m)
        if st != vld_msg.SEIJOU:
            raise Abend('VLDA1002', 'WRITE', st)
        return m

    def バック開始処理３(self):
        """（4181行）ＶＬＤ２へ1件。処理ＩＤは必ず "7"。"""
        m = self.VLD2.atarashii()
        m['見積ＮＯ２'] = self.作業見積ＮＯ
        m['複写先見積ＮＯ２'] = ''
        m['論理宛先名２'] = self.link.ＶＬＤ二
        m['処理種別２'] = 'WT'
        m['データ長２'] = 17
        m['処理ＩＤ２'] = '7'
        m['優先順位２'] = 9
        st = self.VLD2.kaku(m)
        if st != vld_msg.SEIJOU:
            raise Abend('VLDA1002', 'WRITE', st)
        return m

    def XMROTCNL(self):
        """取引の取消（776行ほか）。試作では何もしない。"""

    # ================================================================
    #  画面まわり（3271／3299／3336／3353行）
    # ================================================================
    def メッセージＲ(self):
        """（3271行）"""
        self.gs('ＰＦエリア', '')
        self.gs('メッセージ', '')
        if self.SAVE_GROUP == 'GRPA01':
            self.gs('ＰＦエリア', 'ＰＦ１０：終了')
        elif self.SAVE_GROUP in ('GRPA02', 'GRPA03', 'GRPA04',
                                 'GRPA05', 'GRPA06', 'GRPA07'):
            self.gs('ＰＦエリア', 'ＰＦ５：前項目')

    def 入力強調処理Ｒ(self):
        """（3299行）入力できない項目に "X" を立てる"""
        ku = self.数('処理区')
        if self.SAVE_GROUP == 'GRPA02':
            if ku == self.新規:
                for n in ('複写元見積ナンバ', '見積なんば', '物件ナンバー'):
                    self.画面.zoku(n, 'EDIT-STATUS', 'X')
            elif ku in (self.修正, self.変更, self.取消):
                for n in ('担当者ＣＤ', '複写元見積ナンバ',
                          '施主大分類ＣＤ', '物件ナンバー'):
                    self.画面.zoku(n, 'EDIT-STATUS', 'X')
            elif ku in (self.複写１, self.複写２):
                for n in ('見積なんば', '物件ナンバー'):
                    self.画面.zoku(n, 'EDIT-STATUS', 'X')
        elif self.SAVE_GROUP == 'GRPA03':
            if ku in (self.修正, self.変更):
                nouki = self.数('最終納期') or 0
                self.画面.zoku('最終納期', 'EDIT-STATUS',
                               ' ' if nouki == 0 else 'X')

    def 画面出力Ｒ(self):
        """（3336行）WRITE DSP-REC FROM A10040D1。"00" 以外は ABEND"""
        st = self.画面.kaku('GRPALL')
        if st != vld.SEIJOU:
            raise Abend('DSPFILE', 'WRITE', st)

    def 画面入力Ｒ(self):
        """（3353行）READ 画面ファイル。"00"・"04" が正常"""
        self.XMROTSTR()
        st = self.画面.yomu(self.SAVE_GROUP, self.READ_MODE)
        if st not in (vld.SEIJOU, vld.NYURYOKU):
            raise Abend('DSPFILE', 'READ', st)
        self.DSP_FUNC = getattr(self.画面.sousa, 'func', '') or self.DSP_FUNC

    # ── 富士通の実行時ルーチン ──────────────────
    def XMROTSTR(self):
        """取引の開始（3355行）。試作では何もしない。"""

    def XMROTEND(self):
        """取引の終了（672行ほか）。試作では何もしない。"""

    # ── まだ写していない段落 ────────────────────
    def 前回入力値Ｒ(self):
        raise 未実装('前回入力値Ｒ', 5133)
