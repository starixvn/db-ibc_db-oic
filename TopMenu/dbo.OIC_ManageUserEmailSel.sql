/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
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
		- 20160823@Percy: Sort TOL by Id [RedmineID: #62883]
		- 20211116@Alex: Change Type Of Licensee [RedmineID: #163521]
*/

BEGIN
	SET NOCOUNT ON

	SELECT
		lt.TypeId, lt.TypeName, ult.Email
	FROM
		dbo.UserLicenseeTypes ult WITH(NOLOCK)
		INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK) ON ult.TypeId = lt.TypeId
	WHERE ult.UserId = @UserID
	ORDER BY lt.TypeId
END
GO
