USE [FTSCIM]
GO

/****** Object:  Table [dbo].[AJSKFP]    Script Date: 2026/10/15 14:43:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AJSKFP](
	[NENKBN] [numeric](4, 0) NOT NULL,
	[BSYOCD] [char](2) NOT NULL,
	[TANCD] [char](2) NOT NULL,
	[JUZENR_1] [decimal](11, 0) NOT NULL,
	[JUZENH_1] [decimal](11, 0) NOT NULL,
	[JUZENG_1] [decimal](11, 0) NOT NULL,
	[JUTOUS_1] [decimal](11, 0) NOT NULL,
	[JUTOSH_1] [decimal](11, 0) NOT NULL,
	[JUTOSG_1] [decimal](11, 0) NOT NULL,
	[JUTOUZ_1] [decimal](11, 0) NOT NULL,
	[JUTOZH_1] [decimal](11, 0) NOT NULL,
	[JUTOZG_1] [decimal](11, 0) NOT NULL,
	[JUTOUR_1] [decimal](11, 0) NOT NULL,
	[JUTORH_1] [decimal](11, 0) NOT NULL,
	[JUTORG_1] [decimal](11, 0) NOT NULL,
	[URZENR_1] [decimal](11, 0) NOT NULL,
	[URZENH_1] [decimal](11, 0) NOT NULL,
	[URZENG_1] [decimal](11, 0) NOT NULL,
	[URTOUS_1] [decimal](11, 0) NOT NULL,
	[URTOSH_1] [decimal](11, 0) NOT NULL,
	[URTOSG_1] [decimal](11, 0) NOT NULL,
	[URTOUZ_1] [decimal](11, 0) NOT NULL,
	[URTOZH_1] [decimal](11, 0) NOT NULL,
	[URTOZG_1] [decimal](11, 0) NOT NULL,
	[URTOUR_1] [decimal](11, 0) NOT NULL,
	[URTORH_1] [decimal](11, 0) NOT NULL,
	[URTORG_1] [decimal](11, 0) NOT NULL,
	[SYZENR_1] [decimal](11, 0) NOT NULL,
	[SYZENH_1] [decimal](11, 0) NOT NULL,
	[SYZENG_1] [decimal](11, 0) NOT NULL,
	[SYTOUS_1] [decimal](11, 0) NOT NULL,
	[SYTOSH_1] [decimal](11, 0) NOT NULL,
	[SYTOSG_1] [decimal](11, 0) NOT NULL,
	[SYTOUZ_1] [decimal](11, 0) NOT NULL,
	[SYTOZH_1] [decimal](11, 0) NOT NULL,
	[SYTOZG_1] [decimal](11, 0) NOT NULL,
	[SYTOUR_1] [decimal](11, 0) NOT NULL,
	[SYTORH_1] [decimal](11, 0) NOT NULL,
	[SYTORG_1] [decimal](11, 0) NOT NULL,
	[KAMISY_1] [decimal](11, 0) NOT NULL,
	[JUTEMG_1] [decimal](11, 0) NOT NULL,
	[ZUTMG1_1] [decimal](11, 0) NOT NULL,
	[ZUTMG2_1] [decimal](11, 0) NOT NULL,
	[NTMG1__1] [decimal](11, 0) NOT NULL,
	[NTMG2__1] [decimal](11, 0) NOT NULL,
	[JUTEMH_1] [decimal](11, 0) NOT NULL,
	[YOSSNG_1] [decimal](11, 0) NOT NULL,
	[JUZENR_2] [decimal](11, 0) NOT NULL,
	[JUZENH_2] [decimal](11, 0) NOT NULL,
	[JUZENG_2] [decimal](11, 0) NOT NULL,
	[JUTOUS_2] [decimal](11, 0) NOT NULL,
	[JUTOSH_2] [decimal](11, 0) NOT NULL,
	[JUTOSG_2] [decimal](11, 0) NOT NULL,
	[JUTOUZ_2] [decimal](11, 0) NOT NULL,
	[JUTOZH_2] [decimal](11, 0) NOT NULL,
	[JUTOZG_2] [decimal](11, 0) NOT NULL,
	[JUTOUR_2] [decimal](11, 0) NOT NULL,
	[JUTORH_2] [decimal](11, 0) NOT NULL,
	[JUTORG_2] [decimal](11, 0) NOT NULL,
	[URZENR_2] [decimal](11, 0) NOT NULL,
	[URZENH_2] [decimal](11, 0) NOT NULL,
	[URZENG_2] [decimal](11, 0) NOT NULL,
	[URTOUS_2] [decimal](11, 0) NOT NULL,
	[URTOSH_2] [decimal](11, 0) NOT NULL,
	[URTOSG_2] [decimal](11, 0) NOT NULL,
	[URTOUZ_2] [decimal](11, 0) NOT NULL,
	[URTOZH_2] [decimal](11, 0) NOT NULL,
	[URTOZG_2] [decimal](11, 0) NOT NULL,
	[URTOUR_2] [decimal](11, 0) NOT NULL,
	[URTORH_2] [decimal](11, 0) NOT NULL,
	[URTORG_2] [decimal](11, 0) NOT NULL,
	[SYZENR_2] [decimal](11, 0) NOT NULL,
	[SYZENH_2] [decimal](11, 0) NOT NULL,
	[SYZENG_2] [decimal](11, 0) NOT NULL,
	[SYTOUS_2] [decimal](11, 0) NOT NULL,
	[SYTOSH_2] [decimal](11, 0) NOT NULL,
	[SYTOSG_2] [decimal](11, 0) NOT NULL,
	[SYTOUZ_2] [decimal](11, 0) NOT NULL,
	[SYTOZH_2] [decimal](11, 0) NOT NULL,
	[SYTOZG_2] [decimal](11, 0) NOT NULL,
	[SYTOUR_2] [decimal](11, 0) NOT NULL,
	[SYTORH_2] [decimal](11, 0) NOT NULL,
	[SYTORG_2] [decimal](11, 0) NOT NULL,
	[KAMISY_2] [decimal](11, 0) NOT NULL,
	[JUTEMG_2] [decimal](11, 0) NOT NULL,
	[ZUTMG1_2] [decimal](11, 0) NOT NULL,
	[ZUTMG2_2] [decimal](11, 0) NOT NULL,
	[NTMG1__2] [decimal](11, 0) NOT NULL,
	[NTMG2__2] [decimal](11, 0) NOT NULL,
	[JUTEMH_2] [decimal](11, 0) NOT NULL,
	[YOSSNG_2] [decimal](11, 0) NOT NULL,
	[JUZENR_3] [decimal](11, 0) NOT NULL,
	[JUZENH_3] [decimal](11, 0) NOT NULL,
	[JUZENG_3] [decimal](11, 0) NOT NULL,
	[JUTOUS_3] [decimal](11, 0) NOT NULL,
	[JUTOSH_3] [decimal](11, 0) NOT NULL,
	[JUTOSG_3] [decimal](11, 0) NOT NULL,
	[JUTOUZ_3] [decimal](11, 0) NOT NULL,
	[JUTOZH_3] [decimal](11, 0) NOT NULL,
	[JUTOZG_3] [decimal](11, 0) NOT NULL,
	[JUTOUR_3] [decimal](11, 0) NOT NULL,
	[JUTORH_3] [decimal](11, 0) NOT NULL,
	[JUTORG_3] [decimal](11, 0) NOT NULL,
	[URZENR_3] [decimal](11, 0) NOT NULL,
	[URZENH_3] [decimal](11, 0) NOT NULL,
	[URZENG_3] [decimal](11, 0) NOT NULL,
	[URTOUS_3] [decimal](11, 0) NOT NULL,
	[URTOSH_3] [decimal](11, 0) NOT NULL,
	[URTOSG_3] [decimal](11, 0) NOT NULL,
	[URTOUZ_3] [decimal](11, 0) NOT NULL,
	[URTOZH_3] [decimal](11, 0) NOT NULL,
	[URTOZG_3] [decimal](11, 0) NOT NULL,
	[URTOUR_3] [decimal](11, 0) NOT NULL,
	[URTORH_3] [decimal](11, 0) NOT NULL,
	[URTORG_3] [decimal](11, 0) NOT NULL,
	[SYZENR_3] [decimal](11, 0) NOT NULL,
	[SYZENH_3] [decimal](11, 0) NOT NULL,
	[SYZENG_3] [decimal](11, 0) NOT NULL,
	[SYTOUS_3] [decimal](11, 0) NOT NULL,
	[SYTOSH_3] [decimal](11, 0) NOT NULL,
	[SYTOSG_3] [decimal](11, 0) NOT NULL,
	[SYTOUZ_3] [decimal](11, 0) NOT NULL,
	[SYTOZH_3] [decimal](11, 0) NOT NULL,
	[SYTOZG_3] [decimal](11, 0) NOT NULL,
	[SYTOUR_3] [decimal](11, 0) NOT NULL,
	[SYTORH_3] [decimal](11, 0) NOT NULL,
	[SYTORG_3] [decimal](11, 0) NOT NULL,
	[KAMISY_3] [decimal](11, 0) NOT NULL,
	[JUTEMG_3] [decimal](11, 0) NOT NULL,
	[ZUTMG1_3] [decimal](11, 0) NOT NULL,
	[ZUTMG2_3] [decimal](11, 0) NOT NULL,
	[NTMG1__3] [decimal](11, 0) NOT NULL,
	[NTMG2__3] [decimal](11, 0) NOT NULL,
	[JUTEMH_3] [decimal](11, 0) NOT NULL,
	[YOSSNG_3] [decimal](11, 0) NOT NULL,
	[JUZENR_4] [decimal](11, 0) NOT NULL,
	[JUZENH_4] [decimal](11, 0) NOT NULL,
	[JUZENG_4] [decimal](11, 0) NOT NULL,
	[JUTOUS_4] [decimal](11, 0) NOT NULL,
	[JUTOSH_4] [decimal](11, 0) NOT NULL,
	[JUTOSG_4] [decimal](11, 0) NOT NULL,
	[JUTOUZ_4] [decimal](11, 0) NOT NULL,
	[JUTOZH_4] [decimal](11, 0) NOT NULL,
	[JUTOZG_4] [decimal](11, 0) NOT NULL,
	[JUTOUR_4] [decimal](11, 0) NOT NULL,
	[JUTORH_4] [decimal](11, 0) NOT NULL,
	[JUTORG_4] [decimal](11, 0) NOT NULL,
	[URZENR_4] [decimal](11, 0) NOT NULL,
	[URZENH_4] [decimal](11, 0) NOT NULL,
	[URZENG_4] [decimal](11, 0) NOT NULL,
	[URTOUS_4] [decimal](11, 0) NOT NULL,
	[URTOSH_4] [decimal](11, 0) NOT NULL,
	[URTOSG_4] [decimal](11, 0) NOT NULL,
	[URTOUZ_4] [decimal](11, 0) NOT NULL,
	[URTOZH_4] [decimal](11, 0) NOT NULL,
	[URTOZG_4] [decimal](11, 0) NOT NULL,
	[URTOUR_4] [decimal](11, 0) NOT NULL,
	[URTORH_4] [decimal](11, 0) NOT NULL,
	[URTORG_4] [decimal](11, 0) NOT NULL,
	[SYZENR_4] [decimal](11, 0) NOT NULL,
	[SYZENH_4] [decimal](11, 0) NOT NULL,
	[SYZENG_4] [decimal](11, 0) NOT NULL,
	[SYTOUS_4] [decimal](11, 0) NOT NULL,
	[SYTOSH_4] [decimal](11, 0) NOT NULL,
	[SYTOSG_4] [decimal](11, 0) NOT NULL,
	[SYTOUZ_4] [decimal](11, 0) NOT NULL,
	[SYTOZH_4] [decimal](11, 0) NOT NULL,
	[SYTOZG_4] [decimal](11, 0) NOT NULL,
	[SYTOUR_4] [decimal](11, 0) NOT NULL,
	[SYTORH_4] [decimal](11, 0) NOT NULL,
	[SYTORG_4] [decimal](11, 0) NOT NULL,
	[KAMISY_4] [decimal](11, 0) NOT NULL,
	[JUTEMG_4] [decimal](11, 0) NOT NULL,
	[ZUTMG1_4] [decimal](11, 0) NOT NULL,
	[ZUTMG2_4] [decimal](11, 0) NOT NULL,
	[NTMG1__4] [decimal](11, 0) NOT NULL,
	[NTMG2__4] [decimal](11, 0) NOT NULL,
	[JUTEMH_4] [decimal](11, 0) NOT NULL,
	[YOSSNG_4] [decimal](11, 0) NOT NULL,
	[JUZENR_5] [decimal](11, 0) NOT NULL,
	[JUZENH_5] [decimal](11, 0) NOT NULL,
	[JUZENG_5] [decimal](11, 0) NOT NULL,
	[JUTOUS_5] [decimal](11, 0) NOT NULL,
	[JUTOSH_5] [decimal](11, 0) NOT NULL,
	[JUTOSG_5] [decimal](11, 0) NOT NULL,
	[JUTOUZ_5] [decimal](11, 0) NOT NULL,
	[JUTOZH_5] [decimal](11, 0) NOT NULL,
	[JUTOZG_5] [decimal](11, 0) NOT NULL,
	[JUTOUR_5] [decimal](11, 0) NOT NULL,
	[JUTORH_5] [decimal](11, 0) NOT NULL,
	[JUTORG_5] [decimal](11, 0) NOT NULL,
	[URZENR_5] [decimal](11, 0) NOT NULL,
	[URZENH_5] [decimal](11, 0) NOT NULL,
	[URZENG_5] [decimal](11, 0) NOT NULL,
	[URTOUS_5] [decimal](11, 0) NOT NULL,
	[URTOSH_5] [decimal](11, 0) NOT NULL,
	[URTOSG_5] [decimal](11, 0) NOT NULL,
	[URTOUZ_5] [decimal](11, 0) NOT NULL,
	[URTOZH_5] [decimal](11, 0) NOT NULL,
	[URTOZG_5] [decimal](11, 0) NOT NULL,
	[URTOUR_5] [decimal](11, 0) NOT NULL,
	[URTORH_5] [decimal](11, 0) NOT NULL,
	[URTORG_5] [decimal](11, 0) NOT NULL,
	[SYZENR_5] [decimal](11, 0) NOT NULL,
	[SYZENH_5] [decimal](11, 0) NOT NULL,
	[SYZENG_5] [decimal](11, 0) NOT NULL,
	[SYTOUS_5] [decimal](11, 0) NOT NULL,
	[SYTOSH_5] [decimal](11, 0) NOT NULL,
	[SYTOSG_5] [decimal](11, 0) NOT NULL,
	[SYTOUZ_5] [decimal](11, 0) NOT NULL,
	[SYTOZH_5] [decimal](11, 0) NOT NULL,
	[SYTOZG_5] [decimal](11, 0) NOT NULL,
	[SYTOUR_5] [decimal](11, 0) NOT NULL,
	[SYTORH_5] [decimal](11, 0) NOT NULL,
	[SYTORG_5] [decimal](11, 0) NOT NULL,
	[KAMISY_5] [decimal](11, 0) NOT NULL,
	[JUTEMG_5] [decimal](11, 0) NOT NULL,
	[ZUTMG1_5] [decimal](11, 0) NOT NULL,
	[ZUTMG2_5] [decimal](11, 0) NOT NULL,
	[NTMG1__5] [decimal](11, 0) NOT NULL,
	[NTMG2__5] [decimal](11, 0) NOT NULL,
	[JUTEMH_5] [decimal](11, 0) NOT NULL,
	[YOSSNG_5] [decimal](11, 0) NOT NULL,
	[JUZENR_6] [decimal](11, 0) NOT NULL,
	[JUZENH_6] [decimal](11, 0) NOT NULL,
	[JUZENG_6] [decimal](11, 0) NOT NULL,
	[JUTOUS_6] [decimal](11, 0) NOT NULL,
	[JUTOSH_6] [decimal](11, 0) NOT NULL,
	[JUTOSG_6] [decimal](11, 0) NOT NULL,
	[JUTOUZ_6] [decimal](11, 0) NOT NULL,
	[JUTOZH_6] [decimal](11, 0) NOT NULL,
	[JUTOZG_6] [decimal](11, 0) NOT NULL,
	[JUTOUR_6] [decimal](11, 0) NOT NULL,
	[JUTORH_6] [decimal](11, 0) NOT NULL,
	[JUTORG_6] [decimal](11, 0) NOT NULL,
	[URZENR_6] [decimal](11, 0) NOT NULL,
	[URZENH_6] [decimal](11, 0) NOT NULL,
	[URZENG_6] [decimal](11, 0) NOT NULL,
	[URTOUS_6] [decimal](11, 0) NOT NULL,
	[URTOSH_6] [decimal](11, 0) NOT NULL,
	[URTOSG_6] [decimal](11, 0) NOT NULL,
	[URTOUZ_6] [decimal](11, 0) NOT NULL,
	[URTOZH_6] [decimal](11, 0) NOT NULL,
	[URTOZG_6] [decimal](11, 0) NOT NULL,
	[URTOUR_6] [decimal](11, 0) NOT NULL,
	[URTORH_6] [decimal](11, 0) NOT NULL,
	[URTORG_6] [decimal](11, 0) NOT NULL,
	[SYZENR_6] [decimal](11, 0) NOT NULL,
	[SYZENH_6] [decimal](11, 0) NOT NULL,
	[SYZENG_6] [decimal](11, 0) NOT NULL,
	[SYTOUS_6] [decimal](11, 0) NOT NULL,
	[SYTOSH_6] [decimal](11, 0) NOT NULL,
	[SYTOSG_6] [decimal](11, 0) NOT NULL,
	[SYTOUZ_6] [decimal](11, 0) NOT NULL,
	[SYTOZH_6] [decimal](11, 0) NOT NULL,
	[SYTOZG_6] [decimal](11, 0) NOT NULL,
	[SYTOUR_6] [decimal](11, 0) NOT NULL,
	[SYTORH_6] [decimal](11, 0) NOT NULL,
	[SYTORG_6] [decimal](11, 0) NOT NULL,
	[KAMISY_6] [decimal](11, 0) NOT NULL,
	[JUTEMG_6] [decimal](11, 0) NOT NULL,
	[ZUTMG1_6] [decimal](11, 0) NOT NULL,
	[ZUTMG2_6] [decimal](11, 0) NOT NULL,
	[NTMG1__6] [decimal](11, 0) NOT NULL,
	[NTMG2__6] [decimal](11, 0) NOT NULL,
	[JUTEMH_6] [decimal](11, 0) NOT NULL,
	[YOSSNG_6] [decimal](11, 0) NOT NULL,
	[JUZENR_7] [decimal](11, 0) NOT NULL,
	[JUZENH_7] [decimal](11, 0) NOT NULL,
	[JUZENG_7] [decimal](11, 0) NOT NULL,
	[JUTOUS_7] [decimal](11, 0) NOT NULL,
	[JUTOSH_7] [decimal](11, 0) NOT NULL,
	[JUTOSG_7] [decimal](11, 0) NOT NULL,
	[JUTOUZ_7] [decimal](11, 0) NOT NULL,
	[JUTOZH_7] [decimal](11, 0) NOT NULL,
	[JUTOZG_7] [decimal](11, 0) NOT NULL,
	[JUTOUR_7] [decimal](11, 0) NOT NULL,
	[JUTORH_7] [decimal](11, 0) NOT NULL,
	[JUTORG_7] [decimal](11, 0) NOT NULL,
	[URZENR_7] [decimal](11, 0) NOT NULL,
	[URZENH_7] [decimal](11, 0) NOT NULL,
	[URZENG_7] [decimal](11, 0) NOT NULL,
	[URTOUS_7] [decimal](11, 0) NOT NULL,
	[URTOSH_7] [decimal](11, 0) NOT NULL,
	[URTOSG_7] [decimal](11, 0) NOT NULL,
	[URTOUZ_7] [decimal](11, 0) NOT NULL,
	[URTOZH_7] [decimal](11, 0) NOT NULL,
	[URTOZG_7] [decimal](11, 0) NOT NULL,
	[URTOUR_7] [decimal](11, 0) NOT NULL,
	[URTORH_7] [decimal](11, 0) NOT NULL,
	[URTORG_7] [decimal](11, 0) NOT NULL,
	[SYZENR_7] [decimal](11, 0) NOT NULL,
	[SYZENH_7] [decimal](11, 0) NOT NULL,
	[SYZENG_7] [decimal](11, 0) NOT NULL,
	[SYTOUS_7] [decimal](11, 0) NOT NULL,
	[SYTOSH_7] [decimal](11, 0) NOT NULL,
	[SYTOSG_7] [decimal](11, 0) NOT NULL,
	[SYTOUZ_7] [decimal](11, 0) NOT NULL,
	[SYTOZH_7] [decimal](11, 0) NOT NULL,
	[SYTOZG_7] [decimal](11, 0) NOT NULL,
	[SYTOUR_7] [decimal](11, 0) NOT NULL,
	[SYTORH_7] [decimal](11, 0) NOT NULL,
	[SYTORG_7] [decimal](11, 0) NOT NULL,
	[KAMISY_7] [decimal](11, 0) NOT NULL,
	[JUTEMG_7] [decimal](11, 0) NOT NULL,
	[ZUTMG1_7] [decimal](11, 0) NOT NULL,
	[ZUTMG2_7] [decimal](11, 0) NOT NULL,
	[NTMG1__7] [decimal](11, 0) NOT NULL,
	[NTMG2__7] [decimal](11, 0) NOT NULL,
	[JUTEMH_7] [decimal](11, 0) NOT NULL,
	[YOSSNG_7] [decimal](11, 0) NOT NULL,
	[JUZENR_8] [decimal](11, 0) NOT NULL,
	[JUZENH_8] [decimal](11, 0) NOT NULL,
	[JUZENG_8] [decimal](11, 0) NOT NULL,
	[JUTOUS_8] [decimal](11, 0) NOT NULL,
	[JUTOSH_8] [decimal](11, 0) NOT NULL,
	[JUTOSG_8] [decimal](11, 0) NOT NULL,
	[JUTOUZ_8] [decimal](11, 0) NOT NULL,
	[JUTOZH_8] [decimal](11, 0) NOT NULL,
	[JUTOZG_8] [decimal](11, 0) NOT NULL,
	[JUTOUR_8] [decimal](11, 0) NOT NULL,
	[JUTORH_8] [decimal](11, 0) NOT NULL,
	[JUTORG_8] [decimal](11, 0) NOT NULL,
	[URZENR_8] [decimal](11, 0) NOT NULL,
	[URZENH_8] [decimal](11, 0) NOT NULL,
	[URZENG_8] [decimal](11, 0) NOT NULL,
	[URTOUS_8] [decimal](11, 0) NOT NULL,
	[URTOSH_8] [decimal](11, 0) NOT NULL,
	[URTOSG_8] [decimal](11, 0) NOT NULL,
	[URTOUZ_8] [decimal](11, 0) NOT NULL,
	[URTOZH_8] [decimal](11, 0) NOT NULL,
	[URTOZG_8] [decimal](11, 0) NOT NULL,
	[URTOUR_8] [decimal](11, 0) NOT NULL,
	[URTORH_8] [decimal](11, 0) NOT NULL,
	[URTORG_8] [decimal](11, 0) NOT NULL,
	[SYZENR_8] [decimal](11, 0) NOT NULL,
	[SYZENH_8] [decimal](11, 0) NOT NULL,
	[SYZENG_8] [decimal](11, 0) NOT NULL,
	[SYTOUS_8] [decimal](11, 0) NOT NULL,
	[SYTOSH_8] [decimal](11, 0) NOT NULL,
	[SYTOSG_8] [decimal](11, 0) NOT NULL,
	[SYTOUZ_8] [decimal](11, 0) NOT NULL,
	[SYTOZH_8] [decimal](11, 0) NOT NULL,
	[SYTOZG_8] [decimal](11, 0) NOT NULL,
	[SYTOUR_8] [decimal](11, 0) NOT NULL,
	[SYTORH_8] [decimal](11, 0) NOT NULL,
	[SYTORG_8] [decimal](11, 0) NOT NULL,
	[KAMISY_8] [decimal](11, 0) NOT NULL,
	[JUTEMG_8] [decimal](11, 0) NOT NULL,
	[ZUTMG1_8] [decimal](11, 0) NOT NULL,
	[ZUTMG2_8] [decimal](11, 0) NOT NULL,
	[NTMG1__8] [decimal](11, 0) NOT NULL,
	[NTMG2__8] [decimal](11, 0) NOT NULL,
	[JUTEMH_8] [decimal](11, 0) NOT NULL,
	[YOSSNG_8] [decimal](11, 0) NOT NULL,
	[JUZENR_9] [decimal](11, 0) NOT NULL,
	[JUZENH_9] [decimal](11, 0) NOT NULL,
	[JUZENG_9] [decimal](11, 0) NOT NULL,
	[JUTOUS_9] [decimal](11, 0) NOT NULL,
	[JUTOSH_9] [decimal](11, 0) NOT NULL,
	[JUTOSG_9] [decimal](11, 0) NOT NULL,
	[JUTOUZ_9] [decimal](11, 0) NOT NULL,
	[JUTOZH_9] [decimal](11, 0) NOT NULL,
	[JUTOZG_9] [decimal](11, 0) NOT NULL,
	[JUTOUR_9] [decimal](11, 0) NOT NULL,
	[JUTORH_9] [decimal](11, 0) NOT NULL,
	[JUTORG_9] [decimal](11, 0) NOT NULL,
	[URZENR_9] [decimal](11, 0) NOT NULL,
	[URZENH_9] [decimal](11, 0) NOT NULL,
	[URZENG_9] [decimal](11, 0) NOT NULL,
	[URTOUS_9] [decimal](11, 0) NOT NULL,
	[URTOSH_9] [decimal](11, 0) NOT NULL,
	[URTOSG_9] [decimal](11, 0) NOT NULL,
	[URTOUZ_9] [decimal](11, 0) NOT NULL,
	[URTOZH_9] [decimal](11, 0) NOT NULL,
	[URTOZG_9] [decimal](11, 0) NOT NULL,
	[URTOUR_9] [decimal](11, 0) NOT NULL,
	[URTORH_9] [decimal](11, 0) NOT NULL,
	[URTORG_9] [decimal](11, 0) NOT NULL,
	[SYZENR_9] [decimal](11, 0) NOT NULL,
	[SYZENH_9] [decimal](11, 0) NOT NULL,
	[SYZENG_9] [decimal](11, 0) NOT NULL,
	[SYTOUS_9] [decimal](11, 0) NOT NULL,
	[SYTOSH_9] [decimal](11, 0) NOT NULL,
	[SYTOSG_9] [decimal](11, 0) NOT NULL,
	[SYTOUZ_9] [decimal](11, 0) NOT NULL,
	[SYTOZH_9] [decimal](11, 0) NOT NULL,
	[SYTOZG_9] [decimal](11, 0) NOT NULL,
	[SYTOUR_9] [decimal](11, 0) NOT NULL,
	[SYTORH_9] [decimal](11, 0) NOT NULL,
	[SYTORG_9] [decimal](11, 0) NOT NULL,
	[KAMISY_9] [decimal](11, 0) NOT NULL,
	[JUTEMG_9] [decimal](11, 0) NOT NULL,
	[ZUTMG1_9] [decimal](11, 0) NOT NULL,
	[ZUTMG2_9] [decimal](11, 0) NOT NULL,
	[NTMG1__9] [decimal](11, 0) NOT NULL,
	[NTMG2__9] [decimal](11, 0) NOT NULL,
	[JUTEMH_9] [decimal](11, 0) NOT NULL,
	[YOSSNG_9] [decimal](11, 0) NOT NULL,
	[JUZENR_10] [decimal](11, 0) NOT NULL,
	[JUZENH_10] [decimal](11, 0) NOT NULL,
	[JUZENG_10] [decimal](11, 0) NOT NULL,
	[JUTOUS_10] [decimal](11, 0) NOT NULL,
	[JUTOSH_10] [decimal](11, 0) NOT NULL,
	[JUTOSG_10] [decimal](11, 0) NOT NULL,
	[JUTOUZ_10] [decimal](11, 0) NOT NULL,
	[JUTOZH_10] [decimal](11, 0) NOT NULL,
	[JUTOZG_10] [decimal](11, 0) NOT NULL,
	[JUTOUR_10] [decimal](11, 0) NOT NULL,
	[JUTORH_10] [decimal](11, 0) NOT NULL,
	[JUTORG_10] [decimal](11, 0) NOT NULL,
	[URZENR_10] [decimal](11, 0) NOT NULL,
	[URZENH_10] [decimal](11, 0) NOT NULL,
	[URZENG_10] [decimal](11, 0) NOT NULL,
	[URTOUS_10] [decimal](11, 0) NOT NULL,
	[URTOSH_10] [decimal](11, 0) NOT NULL,
	[URTOSG_10] [decimal](11, 0) NOT NULL,
	[URTOUZ_10] [decimal](11, 0) NOT NULL,
	[URTOZH_10] [decimal](11, 0) NOT NULL,
	[URTOZG_10] [decimal](11, 0) NOT NULL,
	[URTOUR_10] [decimal](11, 0) NOT NULL,
	[URTORH_10] [decimal](11, 0) NOT NULL,
	[URTORG_10] [decimal](11, 0) NOT NULL,
	[SYZENR_10] [decimal](11, 0) NOT NULL,
	[SYZENH_10] [decimal](11, 0) NOT NULL,
	[SYZENG_10] [decimal](11, 0) NOT NULL,
	[SYTOUS_10] [decimal](11, 0) NOT NULL,
	[SYTOSH_10] [decimal](11, 0) NOT NULL,
	[SYTOSG_10] [decimal](11, 0) NOT NULL,
	[SYTOUZ_10] [decimal](11, 0) NOT NULL,
	[SYTOZH_10] [decimal](11, 0) NOT NULL,
	[SYTOZG_10] [decimal](11, 0) NOT NULL,
	[SYTOUR_10] [decimal](11, 0) NOT NULL,
	[SYTORH_10] [decimal](11, 0) NOT NULL,
	[SYTORG_10] [decimal](11, 0) NOT NULL,
	[KAMISY_10] [decimal](11, 0) NOT NULL,
	[JUTEMG_10] [decimal](11, 0) NOT NULL,
	[ZUTMG1_10] [decimal](11, 0) NOT NULL,
	[ZUTMG2_10] [decimal](11, 0) NOT NULL,
	[NTMG1__10] [decimal](11, 0) NOT NULL,
	[NTMG2__10] [decimal](11, 0) NOT NULL,
	[JUTEMH_10] [decimal](11, 0) NOT NULL,
	[YOSSNG_10] [decimal](11, 0) NOT NULL,
	[JUZENR_11] [decimal](11, 0) NOT NULL,
	[JUZENH_11] [decimal](11, 0) NOT NULL,
	[JUZENG_11] [decimal](11, 0) NOT NULL,
	[JUTOUS_11] [decimal](11, 0) NOT NULL,
	[JUTOSH_11] [decimal](11, 0) NOT NULL,
	[JUTOSG_11] [decimal](11, 0) NOT NULL,
	[JUTOUZ_11] [decimal](11, 0) NOT NULL,
	[JUTOZH_11] [decimal](11, 0) NOT NULL,
	[JUTOZG_11] [decimal](11, 0) NOT NULL,
	[JUTOUR_11] [decimal](11, 0) NOT NULL,
	[JUTORH_11] [decimal](11, 0) NOT NULL,
	[JUTORG_11] [decimal](11, 0) NOT NULL,
	[URZENR_11] [decimal](11, 0) NOT NULL,
	[URZENH_11] [decimal](11, 0) NOT NULL,
	[URZENG_11] [decimal](11, 0) NOT NULL,
	[URTOUS_11] [decimal](11, 0) NOT NULL,
	[URTOSH_11] [decimal](11, 0) NOT NULL,
	[URTOSG_11] [decimal](11, 0) NOT NULL,
	[URTOUZ_11] [decimal](11, 0) NOT NULL,
	[URTOZH_11] [decimal](11, 0) NOT NULL,
	[URTOZG_11] [decimal](11, 0) NOT NULL,
	[URTOUR_11] [decimal](11, 0) NOT NULL,
	[URTORH_11] [decimal](11, 0) NOT NULL,
	[URTORG_11] [decimal](11, 0) NOT NULL,
	[SYZENR_11] [decimal](11, 0) NOT NULL,
	[SYZENH_11] [decimal](11, 0) NOT NULL,
	[SYZENG_11] [decimal](11, 0) NOT NULL,
	[SYTOUS_11] [decimal](11, 0) NOT NULL,
	[SYTOSH_11] [decimal](11, 0) NOT NULL,
	[SYTOSG_11] [decimal](11, 0) NOT NULL,
	[SYTOUZ_11] [decimal](11, 0) NOT NULL,
	[SYTOZH_11] [decimal](11, 0) NOT NULL,
	[SYTOZG_11] [decimal](11, 0) NOT NULL,
	[SYTOUR_11] [decimal](11, 0) NOT NULL,
	[SYTORH_11] [decimal](11, 0) NOT NULL,
	[SYTORG_11] [decimal](11, 0) NOT NULL,
	[KAMISY_11] [decimal](11, 0) NOT NULL,
	[JUTEMG_11] [decimal](11, 0) NOT NULL,
	[ZUTMG1_11] [decimal](11, 0) NOT NULL,
	[ZUTMG2_11] [decimal](11, 0) NOT NULL,
	[NTMG1__11] [decimal](11, 0) NOT NULL,
	[NTMG2__11] [decimal](11, 0) NOT NULL,
	[JUTEMH_11] [decimal](11, 0) NOT NULL,
	[YOSSNG_11] [decimal](11, 0) NOT NULL,
	[JUZENR_12] [decimal](11, 0) NOT NULL,
	[JUZENH_12] [decimal](11, 0) NOT NULL,
	[JUZENG_12] [decimal](11, 0) NOT NULL,
	[JUTOUS_12] [decimal](11, 0) NOT NULL,
	[JUTOSH_12] [decimal](11, 0) NOT NULL,
	[JUTOSG_12] [decimal](11, 0) NOT NULL,
	[JUTOUZ_12] [decimal](11, 0) NOT NULL,
	[JUTOZH_12] [decimal](11, 0) NOT NULL,
	[JUTOZG_12] [decimal](11, 0) NOT NULL,
	[JUTOUR_12] [decimal](11, 0) NOT NULL,
	[JUTORH_12] [decimal](11, 0) NOT NULL,
	[JUTORG_12] [decimal](11, 0) NOT NULL,
	[URZENR_12] [decimal](11, 0) NOT NULL,
	[URZENH_12] [decimal](11, 0) NOT NULL,
	[URZENG_12] [decimal](11, 0) NOT NULL,
	[URTOUS_12] [decimal](11, 0) NOT NULL,
	[URTOSH_12] [decimal](11, 0) NOT NULL,
	[URTOSG_12] [decimal](11, 0) NOT NULL,
	[URTOUZ_12] [decimal](11, 0) NOT NULL,
	[URTOZH_12] [decimal](11, 0) NOT NULL,
	[URTOZG_12] [decimal](11, 0) NOT NULL,
	[URTOUR_12] [decimal](11, 0) NOT NULL,
	[URTORH_12] [decimal](11, 0) NOT NULL,
	[URTORG_12] [decimal](11, 0) NOT NULL,
	[SYZENR_12] [decimal](11, 0) NOT NULL,
	[SYZENH_12] [decimal](11, 0) NOT NULL,
	[SYZENG_12] [decimal](11, 0) NOT NULL,
	[SYTOUS_12] [decimal](11, 0) NOT NULL,
	[SYTOSH_12] [decimal](11, 0) NOT NULL,
	[SYTOSG_12] [decimal](11, 0) NOT NULL,
	[SYTOUZ_12] [decimal](11, 0) NOT NULL,
	[SYTOZH_12] [decimal](11, 0) NOT NULL,
	[SYTOZG_12] [decimal](11, 0) NOT NULL,
	[SYTOUR_12] [decimal](11, 0) NOT NULL,
	[SYTORH_12] [decimal](11, 0) NOT NULL,
	[SYTORG_12] [decimal](11, 0) NOT NULL,
	[KAMISY_12] [decimal](11, 0) NOT NULL,
	[JUTEMG_12] [decimal](11, 0) NOT NULL,
	[ZUTMG1_12] [decimal](11, 0) NOT NULL,
	[ZUTMG2_12] [decimal](11, 0) NOT NULL,
	[NTMG1__12] [decimal](11, 0) NOT NULL,
	[NTMG2__12] [decimal](11, 0) NOT NULL,
	[JUTEMH_12] [decimal](11, 0) NOT NULL,
	[YOSSNG_12] [decimal](11, 0) NOT NULL,
	[YOBIF] [char](10) NOT NULL,
	[YOBI] [char](92) NOT NULL,
	[CRTDAY] [decimal](8, 0) NOT NULL,
	[UPDDAY] [decimal](8, 0) NOT NULL,
	[UPDTIM] [decimal](6, 0) NOT NULL,
	[WSID] [char](8) NOT NULL,
 CONSTRAINT [PK_AJSKFP] PRIMARY KEY CLUSTERED 
(
	[NENKBN] ASC,
	[BSYOCD] ASC,
	[TANCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NENKBN]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT (' ') FOR [BSYOCD]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT (' ') FOR [TANCD]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_1]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_2]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_3]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_4]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_5]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_6]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_7]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_8]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_9]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_10]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_11]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENR_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUZENG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUS_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOSG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUZ_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOZG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTOUR_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTORG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENR_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URZENG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUS_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOSG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUZ_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOZG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTOUR_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [URTORG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENR_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYZENG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUS_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOSG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUZ_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOZG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTOUR_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [SYTORG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [KAMISY_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG1_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [ZUTMG2_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG1__12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [NTMG2__12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [JUTEMH_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [YOSSNG_12]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT (' ') FOR [YOBIF]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT (' ') FOR [YOBI]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [CRTDAY]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [UPDDAY]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT ((0)) FOR [UPDTIM]
GO

ALTER TABLE [dbo].[AJSKFP] ADD  DEFAULT (' ') FOR [WSID]
GO


