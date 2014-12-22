ALTER PROCEDURE [dbo].[OIC_LicenseeStatusSel]
	@ShowTest INT = 0
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Licensee Status
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		
 */

BEGIN
	SELECT LicenseeStatusId, StatusName, Remark FROM LicenseeStatus WITH(NOLOCK)  WHERE @ShowTest = 1 OR IsTest=@ShowTest
END
GO

GRANT EXECUTE ON OIC_LicenseeStatusSel TO bodbadminnet