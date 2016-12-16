USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_UserListByTOLPositionSel]
	@UserId					INT,
	@PositionId				TINYINT,
	@SelectedLicenseeType	VARCHAR(50) = 'All'
AS

/*
	Creator: Percy
	Date: 2016-12-20
	DB: DBOIC.bodb_OIC
	Task: Get User List by Type of Licensee and Position

	Revisions:

	Param's Explanation:
		* @SelectedLicenseeType: list of Type of Licensee
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @tblLicenseeType TABLE (LicenseeTypeId TINYINT)

	IF @SelectedLicenseeType <> 'All'
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT ul.LicenseeTypeId
		FROM dbo.UserLicenseeType ul WITH(NOLOCK)
		WHERE ul.UserId = @UserId
			AND EXISTS (SELECT TOP 1 1 FROM dbo.strSplit(@SelectedLicenseeType, ',') s WHERE ul.LicenseeTypeId = CONVERT(TINYINT, s.val))
	END
	
	SELECT  DISTINCT ui.UserId
			,ui.DisplayName
	FROM	dbo.UserInfo ui WITH(NOLOCK)
		INNER JOIN UserLicenseeType ul WITH(NOLOCK)
			ON ui.UserId = ul.UserId
	WHERE	ui.PositionId = @PositionId
			AND (
				@SelectedLicenseeType = 'All'
				OR EXISTS (SELECT TOP 1 1 FROM @tblLicenseeType lt WHERE ul.LicenseeTypeId = lt.LicenseeTypeId)
			)
END

GO
GRANT EXECUTE ON [dbo].[OIC_UserListByTOLPositionSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_UserListByTOLPositionSel] TO [vnteam] AS [dbo]
GO