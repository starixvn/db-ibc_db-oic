/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

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
	- 20211122@Kai: Enhancement of Type of Licensee [#163521]

	Param's Explanation:
		* @SelectedLicenseeType: list of Type of Licensee
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @tblLicenseeType TABLE (LicenseeTypeId TINYINT)

	IF @SelectedLicenseeType <> 'All'
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT ul.TypeId
		FROM dbo.UserLicenseeTypes ul WITH(NOLOCK)
		WHERE ul.UserId = @UserId
			AND EXISTS (SELECT TOP 1 1 FROM dbo.strSplit(@SelectedLicenseeType, ',') s WHERE ul.TypeId = CONVERT(TINYINT, s.val))
	END
	
	SELECT  DISTINCT ui.UserId
			,ui.DisplayName
	FROM	dbo.UserInfo ui WITH(NOLOCK)
		INNER JOIN UserLicenseeTypes ul WITH(NOLOCK)
			ON ui.UserId = ul.UserId
	WHERE	ui.PositionId = @PositionId
			AND (
				@SelectedLicenseeType = 'All'
				OR EXISTS (SELECT TOP 1 1 FROM @tblLicenseeType lt WHERE ul.TypeId = lt.LicenseeTypeId)
			)
END

GO
