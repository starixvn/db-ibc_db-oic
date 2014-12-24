ALTER PROCEDURE [dbo].[OIC_ServicePropertySel]
	@ShowTest BIT = 0
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get ServiceProperty
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		
 */

BEGIN
	SELECT s.ServiceId
			,s.ServiceName
			,sp.PropertyKey
			,sp.PropertyName
			,sp.DefaultValue
			,sp.PropertyType
			,sp.[Order]
			,s.Hint
	FROM Service s WITH(NOLOCK)
	INNER JOIN ServiceProperty sp  WITH(NOLOCK) ON s.ServiceId = sp.ServiceId
	WHERE @ShowTest=1 OR IsTest = @ShowTest
	ORDER BY s.ServiceId,sp.[Order]
END
GO

GRANT EXECUTE ON [OIC_ServicePropertySel] TO bodbadminnet


