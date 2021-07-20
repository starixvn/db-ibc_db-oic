/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeListByTypeStatus] 
	@UserId					INT
	,@SelectedLicenseeType	VARCHAR(50)		= 'All'
	,@LicenseeStatusIds		VARCHAR(50)		= 'All'
AS

/*
	Created by: Mark
	Date: 20210625
	Task: Get All Licensee by Type and Status [Redmine:#156774]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		20210625@Mark: Get All Licensee by Type and Status [Redmine:#156774]

	Param's Explanation:
		* @LicenseeTypeIds: dropdown (select 0(All) or 1 licenseeTypeId)
		* @LicenseeStatusId: dropdown (select 0(All) or 1 licenseeStatusId)
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT	l.LicenseeTypeId,
			lt.LicenseeTypeName,
			l.LicenseeId,
			l.LicenseeName
	FROM	dbo.f_LicenseeBelongToUser (@UserId) as l
			INNER JOIN dbo.LicenseeType lt WITH(NOLOCK) 
				ON lt.LicenseeTypeId = l.LicenseeTypeId
	WHERE
		l.LicenseeId IS NOT NULL
		AND (@LicenseeStatusIds = 'All' OR (',' + @LicenseeStatusIds + ',' LIKE '%,' + CONVERT(VARCHAR(3), l.LicenseeStatusId) + ',%'))
		AND (@SelectedLicenseeType = 'All' OR (',' + @SelectedLicenseeType + ',' LIKE '%,' + CONVERT(VARCHAR(3), l.LicenseeTypeId) + ',%'))
	ORDER BY l.LicenseeTypeId
END
GO
