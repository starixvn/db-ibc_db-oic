USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByTOLSel]
	@UserId					INT,
	@LicenseeTypeId			INT,
	@PlatformId				INT,
	@IntegrationMethodId	INT

AS

/*
	Creator: Kai
	Date: 2021-11-22
	DB: DBOIC.bodb_OIC
	Task: Enhancement of Type of Licensee  [RedmineID: #163521]

	Revisions:

	Param's Explanation:
		
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT	l.LicenseeId
			,l.LicenseeName
	FROM	dbo.Licensee l WITH(NOLOCK)
	
	WHERE @PlatformId = l.PlatformId
	AND @IntegrationMethodId IN (SELECT lim.IntegrationMethodId FROM  dbo.LicenseeIntegrationMethod lim WHERE lim.LicenseeId = l.LicenseeId)
	AND @LicenseeTypeId IN (SELECT ul.TypeId FROM dbo.UserLicenseeTypes ul WHERE @UserId = ul.UserId)
	AND @LicenseeTypeId = l.TypeId
	ORDER BY l.LicenseeName ASC
END

GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeListByTOLSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LicenseeListByTOLSel] TO [vnteam] AS [dbo]
GO