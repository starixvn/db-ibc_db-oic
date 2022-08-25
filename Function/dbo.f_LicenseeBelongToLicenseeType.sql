/*<info serverAlias="DBOIC-bodb_OIC" viewers="" isFunction="1" isNested="0"></info>*/
ALTER FUNCTION [dbo].[f_LicenseeBelongToLicenseeType] (@UserId INT)
RETURNS @res TABLE (
	TypeId		TINYINT NOT NULL
	,TypeName	NVARCHAR(50) NOT NULL
	,LicenseeId			INT 
	,LicenseeName		NVARCHAR(50) 
	,RegisteredLicenseeName		NVARCHAR(50) 
	) WITH EXECUTE AS CALLER
AS

/*
    Created by:
    Date:
    Task:
    DB: DBOIC.bodb_OIC
    
    Revisions:
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
		- 20220825@Kai: Get RegisteredLicenseeName column data [RedmineID: #168502]
    
    Param's Explanation:
		
*/

BEGIN
	INSERT INTO @res (TypeId, TypeName, LicenseeId, LicenseeName, RegisteredLicenseeName)
	SELECT  lt.TypeId, lt.TypeName, f.LicenseeId, f.LicenseeName, f.RegisteredLicenseeName
	FROM	dbo.LicenseeTypes lt WITH(NOLOCK)
		LEFT JOIN dbo.f_LicenseeBelongToUser (@UserId) f
			ON lt.TypeId = f.TypeId
	
	RETURN
END
GO
