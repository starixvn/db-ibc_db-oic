/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_LicenseeListByTypeStatus] 
	@UserId					INT
	,@SelectedLicenseeType	VARCHAR(50)		= 'All'
	,@SelectedPlatform		VARCHAR(50)		= 'All'
	,@SelectedIntegrationMethod		VARCHAR(50)		= 'All'
	,@LicenseeStatusIds		VARCHAR(50)		= 'All'
AS

/*
	Created by: Mark
	Date: 20210625
	Task: Get All Licensee by Type and Status [Redmine:#156774]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20210625@Mark: Get All Licensee by Type and Status [Redmine:#156774]
		- 20211116@Alex: Change Type Of Licensee [RedmineID: #163521]

	Param's Explanation:
		* @LicenseeTypeIds: dropdown (select 0(All) or 1 licenseeTypeId)
		* @LicenseeStatusId: dropdown (select 0(All) or 1 licenseeStatusId)
*/

BEGIN
	SET NOCOUNT ON
	
	SELECT	DISTINCT 
			l.TypeId,
			lt.TypeName,
			l.LicenseeId,
			l.LicenseeName
	FROM	dbo.f_LicenseeBelongToUser (@UserId) as l
			INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK) 
				ON lt.TypeId = l.TypeId
			INNER JOIN dbo.Licensee li WITH(NOLOCK) 
				ON l.LicenseeId = li.LicenseeId
			INNER JOIN dbo.LicenseeIntegrationMethod lim WITH(NOLOCK)
				ON l.LicenseeId = lim.LicenseeId
	WHERE
		l.LicenseeId IS NOT NULL
		AND (@LicenseeStatusIds = 'All' OR (',' + @LicenseeStatusIds + ',' LIKE '%,' + CONVERT(VARCHAR(3), l.LicenseeStatusId) + ',%'))
		AND (@SelectedLicenseeType = 'All' OR (',' + @SelectedLicenseeType + ',' LIKE '%,' + CONVERT(VARCHAR(3), l.TypeId) + ',%'))
		AND (@SelectedPlatform = 'All' OR (',' + @SelectedPlatform + ',' LIKE '%,' + CONVERT(VARCHAR(3), li.PlatformId) + ',%'))
		AND (@SelectedIntegrationMethod = 'All' OR (',' + @SelectedIntegrationMethod + ',' LIKE '%,' + CONVERT(VARCHAR(3), lim.IntegrationMethodId) + ',%'))
	ORDER BY l.TypeId
END
GO
