/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeListByType]
	@UserId INT
AS
/*
	Created by: Kathy
	Date: 20150825
	Task: get all licensee belong to user [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
	- 20211122@Kai: Enhancement of Type of Licensee [#163521]
	
	Param's Explanation:
	
	*
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT	TypeId
			,TypeName
			,LicenseeId
			,LicenseeName
	FROM	dbo.f_LicenseeBelongToLicenseeType (@UserId)
	WHERE	LicenseeId IS NOT NULL
	ORDER BY TypeId
END
