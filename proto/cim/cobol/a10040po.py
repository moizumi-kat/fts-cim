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

from . import vld, fairu
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
        # ACCEPT システム日付 FROM DATE（573行）＝ YYMMDD
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
        elif gun in ('GRPA02', 'GRPA03', 'GRPA04',
                     'GRPA05', 'GRPA06', 'GRPA07'):
            raise 未実装('%s-RTN' % gun, {'GRPA02': 745, 'GRPA03': 788,
                                          'GRPA04': 866, 'GRPA05': 0,
                                          'GRPA06': 0, 'GRPA07': 0}[gun])

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
