ALTER PROCEDURE [dbo].[OIC_LanguageSel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Location
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		
 */

BEGIN
	SET NOCOUNT ON
	SELECT LanguageId
		,LanguageName,Remark 
	FROM dbo.[Language] WITH(NOLOCK)
END
GO

GRANT EXECUTE ON [OIC_LanguageSel] TO bodbadminnet

