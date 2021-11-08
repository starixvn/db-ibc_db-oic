/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_UserInfoListSel] 
	@DisplayName					NVARCHAR(50)	= '%'
	,@SelectedPosition				VARCHAR(100)	= 'All'
	,@SelectedLicenseeType			VARCHAR(100)	= 'All'
	,@SelectedPlatform				VARCHAR(50)		= 'All'
	,@SelectedIntegrationMethod		VARCHAR(50)		= 'All'
	,@PageSize						INT				= 10
	,@PageIndex						INT				= 0 
	,@TotalRecords					INT				= 0		OUTPUT
AS
/*
	Created by: Kathy
	Date: 20150618
	Task: list user [Redmine:#38088]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20210913@Hogan: Fix XML character reference [RedmineID: #160430]
		- 20211116@Kai: Enhancement of Type of Licensee (Add Platform and IntegrationMethod for licensee) [RedmineID: #163521]
	
	Param's Explanation:
		
		
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @RowStart		INT
			,@RowEnd		INT

	SELECT	ROW_NUMBER() OVER(ORDER BY DisplayName) AS RowNumber
			,u.UserId
			,u.DisplayName
			,(SELECT PositionName FROM dbo.Position WITH(NOLOCK) WHERE PositionId =  u.PositionId) AS PositionName
			,STUFF(
					(SELECT	',' + lt.TypeName
					FROM	dbo.UserLicenseeTypes ult WITH(NOLOCK)
						INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK) 
							ON	lt.TypeId = ult.TypeId
					WHERE	ult.UserId = u.UserId
					FOR XML PATH(''), TYPE
            ).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS LicenseeType
			,STUFF(
					(SELECT	',' + pf.PlatformName
					FROM	dbo.UserLicensee ul WITH(NOLOCK)
						INNER JOIN dbo.Licensee l WITH(NOLOCK) 
							ON	ul.LicenseeId = l.LicenseeId
						INNER JOIN dbo.Platform pf WITH(NOlOCK)
							ON l.PlatformId = pf.PlatformId
					WHERE	ul.UserId = u.UserId
					GROUP BY pf.PlatformName
					FOR XML PATH(''), TYPE
					
            ).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS PlatformName
			,STUFF(
					(SELECT	',' + im.IntegrationMethodName
					FROM	dbo.UserLicensee ul WITH(NOLOCK)
						INNER JOIN dbo.Licensee l WITH(NOLOCK) 
							ON	ul.LicenseeId = l.LicenseeId
						INNER JOIN dbo.LicenseeIntegrationMethod lim WITH(NOlOCK)
							ON l.LicenseeId = lim.LicenseeId
						INNER JOIN dbo.IntegrationMethod im WITH(NOLOCK)
							ON lim.IntegrationMethodId = im.IntegrationMethodId
					WHERE	ul.UserId = u.UserId
					GROUP BY im.IntegrationMethodName, im.IntegrationMethodId
					ORDER BY im.IntegrationMethodId asc
					FOR XML PATH(''), TYPE
					
            ).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS IntegrationMethodName
			,u.Email
			,u.Skype
			,u.PhoneNumber
			,u.Remark
	INTO	#tmpResult
	FROM	dbo.UserInfo u WITH(NOLOCK)
	WHERE	u.DisplayName LIKE ISNULL(@DisplayName,'%') + '%'
			AND (@SelectedPosition = 'All' OR u.PositionId IN (SELECT val FROM dbo.strSplit(@SelectedPosition,',')))
			AND EXISTS (SELECT	LicenseeTypeId 
						FROM	UserLicenseeType ult WITH(NOLOCK) 
						WHERE	u.UserId = ult.UserId 
								AND (@SelectedLicenseeType = 'All' 
										OR (ult.LicenseeTypeId IN (SELECT val FROM dbo.strSplit(@SelectedLicenseeType,',')))
									) 
						)
			AND EXISTS (SELECT	pf.PlatformId
						FROM	dbo.UserLicensee ul WITH(NOLOCK)
							INNER JOIN dbo.Licensee l WITH(NOLOCK) 
								ON	ul.LicenseeId = l.LicenseeId
							INNER JOIN dbo.Platform pf WITH(NOlOCK)
								ON l.PlatformId = pf.PlatformId
						WHERE	ul.UserId = u.UserId
								AND (@SelectedPlatform = 'All' 
										OR (pf.PlatformId IN (SELECT val FROM dbo.strSplit(@SelectedPlatform,',')))
									) 
						)
			AND EXISTS (SELECT	im.IntegrationMethodId
						FROM	dbo.UserLicensee ul WITH(NOLOCK)
							INNER JOIN dbo.Licensee l WITH(NOLOCK) 
								ON	ul.LicenseeId = l.LicenseeId
							INNER JOIN dbo.LicenseeIntegrationMethod lim WITH(NOlOCK)
								ON l.LicenseeId = lim.LicenseeId
							INNER JOIN dbo.IntegrationMethod im WITH(NOLOCK)
								ON lim.IntegrationMethodId = im.IntegrationMethodId
						WHERE	ul.UserId = u.UserId
								AND (@SelectedIntegrationMethod = 'All' 
										OR (im.IntegrationMethodId IN (SELECT val FROM dbo.strSplit(@SelectedIntegrationMethod,',')))
									) 
						)
	SELECT @TotalRecords = @@rowcount
	
	SELECT	@PageIndex	= @PageIndex 
			,@RowStart		= @PageSize * @PageIndex + 1
			,@RowEnd		= @RowStart + @PageSize - 1
	
	SELECT	UserId
			,DisplayName
			,PositionName
			,LicenseeType
			,PlatformName
			,IntegrationMethodName
			,Email
			,Skype
			,PhoneNumber
			,Remark
	FROM	#tmpResult
	WHERE	RowNumber BETWEEN @RowStart AND @RowEnd		
			
END
GO