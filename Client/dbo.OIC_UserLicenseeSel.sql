USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_UserLicenseeSel]
	@PositionId		TINYINT
	,@LicenseeName	VARCHAR(30)		
AS

/*
	Created by Percy
	Date: 2017-05-30
	DB: DBOIC.bodb_OIC
	Task: Select Display name of user by licensee [RedmineID: #74879]

	Revisions:
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @LicenseeId INT
	
	SELECT  @LicenseeId = LicenseeId
	FROM dbo.Licensee WITH(NOLOCK)
	WHERE LicenseeName = @LicenseeName

	SELECT ui.DisplayName
	FROM dbo.UserLicensee ul WITH(NOLOCK)
		INNER JOIN dbo.UserInfo ui WITH(NOLOCK) ON ul.UserId = ui.UserId
	WHERE ul.LicenseeId = @LicenseeId
		AND ui.PositionId = @PositionId
END
GO
GRANT EXECUTE ON [dbo].[OIC_UserLicenseeSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_UserLicenseeSel] TO [vnteam] AS [dbo]