USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LanguageSel]    Script Date: 04/16/2015 14:20:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.OIC_LanguageSel    Script Date: 16/04/2015 9:22:41 AM ******/
ALTER PROCEDURE [dbo].[OIC_LanguageSel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get language list [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		
 */

BEGIN
	SET NOCOUNT ON
	SELECT LanguageId
		,LanguageName 
	FROM dbo.[Language] WITH(NOLOCK)
END
GO
GRANT EXECUTE ON [dbo].[OIC_LanguageSel] TO [bodbAdminNet] AS [dbo]