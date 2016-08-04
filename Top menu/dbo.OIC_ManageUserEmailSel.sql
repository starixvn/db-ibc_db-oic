USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ManageUserEmailSel]
	@UserID INT
AS

/*
	Creator: Percy
	Date: 2016-08-04
	DB: DBOIC.bodb_OIC
	Task: Manage User Mail - Select

	Revisions:
*/

BEGIN
	SET NOCOUNT ON

	SELECT
		lt.LicenseeTypeId, lt.LicenseeTypeName, ult.Email
	FROM
		dbo.UserLicenseeType ult WITH(NOLOCK)
		INNER JOIN dbo.LicenseeType lt WITH(NOLOCK) ON ult.LicenseeTypeId = lt.LicenseeTypeId
	WHERE ult.UserId = @UserID
	ORDER BY lt.LicenseeTypeName
END
GO
GRANT EXECUTE ON [dbo].[OIC_ManageUserEmailSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_ManageUserEmailSel] TO [vnteam] AS [dbo]
GO