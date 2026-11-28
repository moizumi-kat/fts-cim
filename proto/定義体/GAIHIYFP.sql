-- =============================================================
-- テーブル定義 : GAIHIYFP（新入力外注費ファイル）
-- 変換元       : FILE/OBJ/GAIHIYFP.SMB / GAIHIYFP.SMM（FADLIB / PF / レコード名 GAIREC / レコード長 250）
-- 参照資料     : FILE/PHYSICAL FILE LIST FADLIB.TXT
-- 変換仕様     : FILE/COBOL ➔ SQL Server テーブル定義変換仕様書.md
-- 主キー       : 論理ファイル GAIHIYL1（!UNIQ）のキー（HASEIB, SHIIRE, KAMOKU, SEIBAN, RENBAN）
-- 索引         : 論理ファイル GAIHIYL2（!UNIQ）のキー（SHIIRE, HASEIB, KAMOKU, SEIBAN, RENBAN）
--                キー項目は COBOL の RECORD KEY 指定による（GAIHI1CG.COB / GAIHI2CP.COB）
-- =============================================================
USE [FTSCIM_PROTO]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GAIHIYFP](
    [HASEIB]      [decimal](8, 0)   NOT NULL, -- 取引発生日 9(08)
    [SHIIRE]      [char](5)         NOT NULL, -- 仕入先コード X(05)
    [KAMOKU]      [decimal](2, 0)   NOT NULL, -- 費用科目 9(02)
    [SEIBAN]      [char](6)         NOT NULL, -- 製番 X(06)
    [RENBAN]      [decimal](6, 0)   NOT NULL, -- 連番 9(06)

    -- 繰返し項目 (指定項目 KOMOKU: OCCURS 20 / 1回 8バイト)
    -- 第1回目 (_1)
    [SKOMOK_1]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（1 回目） 9(04)
    [EKOMOK_1]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（1 回目） 9(04)
    -- 第2回目 (_2)
    [SKOMOK_2]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（2 回目） 9(04)
    [EKOMOK_2]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（2 回目） 9(04)
    -- 第3回目 (_3)
    [SKOMOK_3]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（3 回目） 9(04)
    [EKOMOK_3]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（3 回目） 9(04)
    -- 第4回目 (_4)
    [SKOMOK_4]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（4 回目） 9(04)
    [EKOMOK_4]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（4 回目） 9(04)
    -- 第5回目 (_5)
    [SKOMOK_5]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（5 回目） 9(04)
    [EKOMOK_5]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（5 回目） 9(04)
    -- 第6回目 (_6)
    [SKOMOK_6]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（6 回目） 9(04)
    [EKOMOK_6]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（6 回目） 9(04)
    -- 第7回目 (_7)
    [SKOMOK_7]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（7 回目） 9(04)
    [EKOMOK_7]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（7 回目） 9(04)
    -- 第8回目 (_8)
    [SKOMOK_8]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（8 回目） 9(04)
    [EKOMOK_8]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（8 回目） 9(04)
    -- 第9回目 (_9)
    [SKOMOK_9]    [decimal](4, 0)   NOT NULL, -- 指定開始項目（9 回目） 9(04)
    [EKOMOK_9]    [decimal](4, 0)   NOT NULL, -- 指定終了項目（9 回目） 9(04)
    -- 第10回目 (_10)
    [SKOMOK_10]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（10 回目） 9(04)
    [EKOMOK_10]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（10 回目） 9(04)
    -- 第11回目 (_11)
    [SKOMOK_11]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（11 回目） 9(04)
    [EKOMOK_11]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（11 回目） 9(04)
    -- 第12回目 (_12)
    [SKOMOK_12]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（12 回目） 9(04)
    [EKOMOK_12]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（12 回目） 9(04)
    -- 第13回目 (_13)
    [SKOMOK_13]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（13 回目） 9(04)
    [EKOMOK_13]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（13 回目） 9(04)
    -- 第14回目 (_14)
    [SKOMOK_14]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（14 回目） 9(04)
    [EKOMOK_14]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（14 回目） 9(04)
    -- 第15回目 (_15)
    [SKOMOK_15]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（15 回目） 9(04)
    [EKOMOK_15]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（15 回目） 9(04)
    -- 第16回目 (_16)
    [SKOMOK_16]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（16 回目） 9(04)
    [EKOMOK_16]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（16 回目） 9(04)
    -- 第17回目 (_17)
    [SKOMOK_17]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（17 回目） 9(04)
    [EKOMOK_17]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（17 回目） 9(04)
    -- 第18回目 (_18)
    [SKOMOK_18]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（18 回目） 9(04)
    [EKOMOK_18]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（18 回目） 9(04)
    -- 第19回目 (_19)
    [SKOMOK_19]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（19 回目） 9(04)
    [EKOMOK_19]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（19 回目） 9(04)
    -- 第20回目 (_20)
    [SKOMOK_20]   [decimal](4, 0)   NOT NULL, -- 指定開始項目（20 回目） 9(04)
    [EKOMOK_20]   [decimal](4, 0)   NOT NULL, -- 指定終了項目（20 回目） 9(04)

    [KINGAK]      [decimal](9, 0)   NOT NULL, -- 外注金額 S9(09) C
    [ANBKBN]      [decimal](1, 0)   NOT NULL, -- 按分区分 9(01)
    [KOSHIN]      [decimal](1, 0)   NOT NULL, -- 更新フラグ 9(01)
    [YOBI1]       [char](1)         NOT NULL, -- 予備１ X(01)
    [YOBI2]       [char](1)         NOT NULL, -- 予備２ X(01)
    [YOHAKU]      [char](6)         NOT NULL, -- 余白 X(06)

    -- 共通仕様 (KYOUTU)
    [CRTDAT]      [decimal](8, 0)   NOT NULL, -- 作成日 9(08)
    [CRTTIM]      [decimal](8, 0)   NOT NULL, -- 作成時間 9(08)
    [CRTWS]       [char](8)         NOT NULL, -- 作成端末 X(08)
    [UPDDAT]      [decimal](8, 0)   NOT NULL, -- 変更日 9(08)
    [UPDTIM]      [decimal](8, 0)   NOT NULL, -- 変更時間 9(08)
    [UPDWS]       [char](8)         NOT NULL, -- 変更端末 X(08)

 CONSTRAINT [PK_GAIHIYFP] PRIMARY KEY CLUSTERED 
(
    [HASEIB] ASC,
    [SHIIRE] ASC,
    [KAMOKU] ASC,
    [SEIBAN] ASC,
    [RENBAN] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

-- 論理ファイル GAIHIYL2 のキー（SHIIRE, HASEIB, KAMOKU, SEIBAN, RENBAN）に対応する索引
-- GAIHIYL2 はキー重複なし（!UNIQ）の定義のため、UNIQUE を付ける
CREATE UNIQUE NONCLUSTERED INDEX [IX_GAIHIYL2] ON [dbo].[GAIHIYFP]
(
    [SHIIRE] ASC,
    [HASEIB] ASC,
    [KAMOKU] ASC,
    [SEIBAN] ASC,
    [RENBAN] ASC
) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF,
        DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

-- デフォルト制約の設定
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [HASEIB]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [SHIIRE]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [KAMOKU]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [SEIBAN]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [RENBAN]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_1]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_1]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_2]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_2]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_3]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_3]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_4]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_4]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_5]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_5]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_6]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_6]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_7]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_7]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_8]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_8]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_9]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_9]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_10]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_10]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_11]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_11]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_12]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_12]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_13]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_13]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_14]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_14]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_15]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_15]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_16]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_16]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_17]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_17]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_18]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_18]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_19]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_19]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [SKOMOK_20]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [EKOMOK_20]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [KINGAK]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [ANBKBN]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [KOSHIN]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [YOBI1]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [YOBI2]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [YOHAKU]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [CRTDAT]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [CRTTIM]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [CRTWS]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [UPDDAT]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT ((0)) FOR [UPDTIM]
GO
ALTER TABLE [dbo].[GAIHIYFP] ADD DEFAULT (' ') FOR [UPDWS]
GO
