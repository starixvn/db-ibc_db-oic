/*<info serverAlias="DBOIC-bodb_OIC" viewers="" isFunction="1" isNested="1"></info>*/
ALTER FUNCTION [dbo].[f_LicenseeBelongToUser] (@UserId INT)
RETURNS @res TABLE (
	LicenseeId INT NOT NULL
	,LicenseeName NVARCHAR(50) NOT NULL
	,RegisteredLicenseeName NVARCHAR(50) NOT NULL
	,TypeId TINYINT NOT NULL
	,LicenseeStatusID TINYINT NOT NULL
	,PRIMARY KEY CLUSTERED (LicenseeId ASC)
	) WITH EXECUTE AS CALLER
AS
/*
	Created by: 
	Date: 
	Task: 
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20211117@Alex: Change Type Of Licensee [RedmineID: #163521]
		- 20220825@Kai: Get RegisteredLicenseeName column data [RedmineID: #168502]
	
	Param's Explanation:
 */
BEGIN
	INSERT INTO @res (LicenseeId, LicenseeName, RegisteredLicenseeName, TypeId, LicenseeStatusID)
	SELECT  LicenseeId, LicenseeName, RegisteredLicenseeName, TypeId, LicenseeStatusId
	FROM	dbo.Licensee WITH(NOLOCK)
	WHERE	TypeId IN (	
						SELECT  TypeId
						FROM	dbo.UserLicenseeTypes WITH(NOLOCK)
						WHERE	UserId = @UserId
					)
	RETURN
END
GO