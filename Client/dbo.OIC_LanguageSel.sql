USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LanguageSel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get language list [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160826@Percy: Remove Other Language (ID = 4) [RedmineID: #62883]
		
 */

BEGIN
	SET NOCOUNT ON
	SELECT LanguageId
		,LanguageName 
	FROM dbo.[Language] WITH(NOLOCK)
	WHERE LanguageId <> 4
	ORDER BY LanguageName
END
GO
GRANT EXECUTE ON [dbo].[OIC_LanguageSel] TO [bodbAdminNet] AS [dbo]