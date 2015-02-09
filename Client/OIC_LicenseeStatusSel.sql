ALTER PROCEDURE [dbo].[OIC_LicenseeStatusSel]
	@ShowTest INT = 0
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Licensee Status [Redmine:#27752]
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		
 */

BEGIN
	SET NOCOUNT ON;
	SELECT LicenseeStatusId
		,StatusName
		,Remark 
	FROM dbo.LicenseeStatus WITH(NOLOCK)  
	WHERE @ShowTest = 1 
		OR IsTest=@ShowTest
END

GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeStatusSel] TO [bodbAdminNet] AS [dbo]