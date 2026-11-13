# -*- coding: utf-8 -*-
"""更新用ＶＬＤ（VLDA1001／VLDA1002）＝ うしろで動く更新処理へ渡すメッセージ。

  ■ これは何か（A10040PO.COB 4095・4133・4181行／コピー原文 2026-11-13 受領）
     画面で確定した見積を、**うしろ（バックグラウンド）の更新処理に知らせる**
     ための置き場。鑑は「バック開始処理１／２／３」でここに1件書く。
     レコードは メッセージ制御情報領域 ＋ データ領域。
       ＶＬＤ１（41バイト）… 見積ＮＯ＋処理ＩＤ（データ長 9）
       ＶＬＤ２（49バイト）… 見積ＮＯ＋複写先見積ＮＯ＋処理ＩＤ（データ長 17）
     宛先（論理宛先名）はリンケージの ＶＬＤ一／ＶＬＤ二 で渡ってくる。

  ■ 表ではない
     VLDA1001／VLDA1002 は村上様の489表の一覧に入っていない。
     現行でもデータファイルではなくメッセージの通り道。
     ここでは**書いたものを順に貯める**だけにしてある。
     本番で何に載せるか（キュー／表）は、うしろの更新処理を作るときに決める。
"""
from . import vld_rec

SEIJOU = '00'


class Msg:
    """ＶＬＤのレコード1件。桁はコピー原文のとおり。"""

    def __init__(self, teigi, nagasa):
        self.teigi = {t[0]: t for t in teigi if t[1] is not None}
        self.junjo = [t[0] for t in teigi if t[1] is not None]
        self.nagasa = nagasa
        self.hatsuka()

    def hatsuka(self):
        """INITIALIZE。数字はゼロ、英数は空白。"""
        self.atai = {}
        for na in self.junjo:
            _na, kata, _keta, n, _ichi = self.teigi[na]
            self.atai[na] = ('0' * n) if kata == '9' else (' ' * n)

    def __setitem__(self, na, v):
        _na, kata, _keta, n, _ichi = self.teigi[na]
        if kata == '9':
            s = ''.join(c for c in str(v) if c.isdigit()) or '0'
            self.atai[na] = s[-n:].rjust(n, '0')
        else:
            b = ('' if v is None else str(v)).encode('cp932', 'replace')
            self.atai[na] = b[:n].ljust(n).decode('cp932', 'replace')

    def __getitem__(self, na):
        return self.atai[na]

    def rec(self):
        b = bytearray(b' ' * self.nagasa)
        for na in self.junjo:
            _na, _kata, _keta, n, ichi = self.teigi[na]
            b[ichi:ichi + n] = self.atai[na].encode('cp932', 'replace')[:n].ljust(n)
        return bytes(b)


class Kyuu:
    """ＶＬＤファイル1本。WRITE で1件積む。"""

    def __init__(self, na, teigi, nagasa):
        self.na = na
        self.teigi, self.nagasa = teigi, nagasa
        self.tamatta = []
        self.status = SEIJOU

    def atarashii(self):
        return Msg(self.teigi, self.nagasa)

    def kaku(self, msg):
        self.tamatta.append(msg.rec())
        self.status = SEIJOU
        return self.status


def tsukuru():
    """更新ＶＬＤ１・２ を1組つくる。"""
    return (Kyuu('VLDA1001', vld_rec.REC1, vld_rec.NAGASA1),
            Kyuu('VLDA1002', vld_rec.REC2, vld_rec.NAGASA2))
