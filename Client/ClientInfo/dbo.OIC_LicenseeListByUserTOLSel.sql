USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByUserTOLSel]
	@UserId						INT,
	@SelectedLicenseeType		VARCHAR(50) = 'All',
	@SelectedPlatform			VARCHAR(50) = 'All',
	@SelectedIntegrationMethod	VARCHAR(50) = 'All'

AS

/*
	Creator: Kai
	Date: 2021-11-17
	DB: DBOIC.bodb_OIC
	Task: Enhancement of Type of Licensee  [RedmineID: #163521]

	Revisions:

	Param's Explanation:
		* @SelectedLicenseeType: list of Type of Licensee
		* @SelectedPlatform: list of Platform
		* @SelectedIntegrationMethod: list of Integration Method
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @tblLicenseeType	TABLE (LicenseeTypeId TINYINT)
	DECLARE @tblPlatform	TABLE (PlatformId TINYINT)
	DECLARE @tblIntegrationMethod	TABLE (IntegrationMethodId TINYINT)

	IF @SelectedLicenseeType = 'All'
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT	TypeId
		FROM	dbo.UserLicenseeTypes WITH(NOLOCK)
		WHERE	UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedLicenseeType, ',')

		DELETE lt
		FROM @tblLicenseeType lt
			LEFT JOIN dbo.UserLicenseeTypes ult WITH(NOLOCK) ON lt.LicenseeTypeId = ult.TypeId AND ult.UserId = @UserId
		WHERE ult.TypeId IS NULL
	END

	IF @SelectedPlatform = 'All'
	BEGIN
		INSERT INTO @tblPlatform (PlatformId)
		SELECT	PlatformId
		FROM	dbo.Platform WITH(NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO @tblPlatform (PlatformId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedPlatform, ',')
	END

	IF @SelectedIntegrationMethod = 'All'
	BEGIN
		INSERT INTO @tblIntegrationMethod (IntegrationMethodId)
		SELECT	IntegrationMethodId
		FROM	dbo.IntegrationMethod WITH(NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO @tblIntegrationMethod (IntegrationMethodId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedIntegrationMethod, ',')
	END
	
	SELECT	l.LicenseeId
			,l.LicenseeName
	FROM	dbo.UserLicensee ul WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK)
			ON	l.LicenseeId = ul.LicenseeId AND ul.UserId = @UserId
	WHERE l.LicenseeId IN (SELECT lim.LicenseeId FROM dbo.LicenseeIntegrationMethod lim WHERE lim.IntegrationMethodId IN (SELECT IntegrationMethodId FROM @tblIntegrationMethod))
		AND l.TypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
		AND l.PlatformId IN (SELECT PlatformId FROM @tblPlatform)
	ORDER BY l.LicenseeName ASC
END

GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeListByUserTOLSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LicenseeListByUserTOLSel] TO [vnteam] AS [dbo]
GO