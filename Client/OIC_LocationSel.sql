ALTER PROCEDURE [dbo].[OIC_LocationSel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Location
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		
 */

BEGIN
	SELECT LocationId
		,LocationName
		,[Description] 
	FROM dbo.Location WITH(NOLOCK)
END
GO

GRANT EXECUTE ON OIC_LocationSel TO bodbadminnet