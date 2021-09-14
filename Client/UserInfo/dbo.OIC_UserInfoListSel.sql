/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_UserInfoListSel] 
	@DisplayName			NVARCHAR(50)	= '%'
	,@SelectedPosition		VARCHAR(100)	= 'All'
	,@SelectedLicenseeType	VARCHAR(100)	= 'All'
	,@PageSize				INT				= 10
	,@PageIndex				INT				= 0 
	,@TotalRecords			INT				= 0		OUTPUT
AS
/*
	Created by: Kathy
	Date: 20150618
	Task: list user [Redmine:#38088]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20210913@Hogan: Fix XML character reference [RedmineID: #160430]
	
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
					(SELECT	',' + lt.LicenseeTypeName
					FROM	dbo.UserLicenseeType ult WITH(NOLOCK)
						INNER JOIN dbo.LicenseeType lt WITH(NOLOCK) 
							ON	lt.LicenseeTypeId = ult.LicenseeTypeId
					WHERE	ult.UserId = u.UserId
					FOR XML PATH(''), TYPE
            ).value('.', 'VARCHAR(MAX)'), 1, 1, '') AS LicenseeType
			,u.Email
			,u.Skype
			,u.PhoneNumber
			,u.Remark
	INTO	#tmpResult
	FROM	dbo.UserInfo u WITH(NOLOCK)
	WHERE	u.DisplayName LIKE ISNULL(@DisplayName,'%') + '%'
			AND (@SelectedPosition = 'All' OR u.PositionId IN (SELECT val FROM dbo.strSplit(@SelectedPosition,',')))
			AND (
				@SelectedLicenseeType = 'All' 
				OR
				EXISTS (SELECT	LicenseeTypeId 
						FROM	UserLicenseeType ult WITH(NOLOCK) 
						WHERE	u.UserId = ult.UserId 
								AND (ult.LicenseeTypeId IN (SELECT val FROM dbo.strSplit(@SelectedLicenseeType,',')))
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
			,Email
			,Skype
			,PhoneNumber
			,Remark
	FROM	#tmpResult
	WHERE	RowNumber BETWEEN @RowStart AND @RowEnd		
			
END
GO