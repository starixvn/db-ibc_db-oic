/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_LicenseeTypeByLicenseeId]
	@LicenseeId		INT
AS

/*
	Created by: Cody
	Date: 2023-12-29 
	Task: Get Licensee Type belong to LicenseeId [Redmine:#198195]
	DB: DBOIC.bodb_OIC 
	
	Revisions:
		- 20231229@Cody: Get LicenseeType by LicenseeId [RedmineID: #198195]
		
	Param's Explanation:
 */

BEGIN
	SET NOCOUNT ON;

	SELECT t.TypeId		AS LicenseeTypeId
			,t.TypeName	AS LicenseeTypeName
	FROM dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeTypes t WITH(NOLOCK)
			ON l.TypeId = t.TypeId
	WHERE l.LicenseeId = @LicenseeId
END