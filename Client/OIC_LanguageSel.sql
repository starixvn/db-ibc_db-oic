ALTER PROCEDURE [dbo].[OIC_LanguageSel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get language list [Redmine:#27752]
	DB: DBOIC/BODB_OIC 
	
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