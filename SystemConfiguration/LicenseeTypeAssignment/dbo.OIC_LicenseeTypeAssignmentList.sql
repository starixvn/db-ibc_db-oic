USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeTypeAssignmentList] 
	@DisplayName			NVARCHAR(50)	= '%'
	,@SelectedPosition		VARCHAR(100)	= 'All'
	,@SelectedLicenseeType	VARCHAR(100)	= 'All'
	,@SiteId				INT  
AS

/*
	Created by: Kathy
	Date: 20151006
	Task: list licensee type of user  [Redmine:#44257]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		@PositionId: All - ALL position
		@SiteId: siteid on NAP Home
 */

BEGIN
	SET NOCOUNT ON;
			
	DECLARE @DynamicPIVOT		VARCHAR(MAX)
			,@strLicenseeType VARCHAR(MAX)
			
	SELECT	@strLicenseeType = ISNULL(@strLicenseeType, '') + '[' + LicenseeTypeName + '],'
	FROM	dbo.LicenseeType WITH(NOLOCK)
	
	SELECT @strLicenseeType = LEFT(@strLicenseeType,LEN(@strLicenseeType) -1)	
	
	SELECT	ci.custid AS UserId
			,CASE WHEN ISNULL(ui.DisplayName,'') = '' THEN ci.username ELSE ui.DisplayName END AS DisplayName
			,p.PositionName
	INTO	#tblResult
	FROM	bodb_NAP.dbo.Users u WITH(NOLOCK)
		INNER JOIN bodb_NAP.dbo.UserSite us WITH(NOLOCK) ON u.UserId = us.UserId
		INNER JOIN bodb02.dbo.custInfo ci WITH(NOLOCK)
			ON	ci.custid = us.UserId
		LEFT JOIN dbo.UserInfo ui WITH(NOLOCK)
			ON ui.UserId = ci.custid
		LEFT JOIN dbo.Position p WITH(NOLOCK)
			ON ui.PositionId = p.PositionId
		LEFT JOIN UserLicenseeType ul
			ON ci.custid = ul.UserId
	WHERE	us.SiteId = @SiteId
			AND us.IsActive = 1
			AND ISNULL(ui.DisplayName,ci.username) LIKE ISNULL(@DisplayName,ci.username) + '%'
			AND (@SelectedPosition = 'All' 
				OR (EXISTS (SELECT val FROM dbo.strSplit(@SelectedPosition,',') WHERE (val = 0 AND p.PositionId IS NULL) OR val = p.PositionId)) 
				)
			AND 1 = CASE WHEN @SelectedLicenseeType = 'All' THEN 1
						 WHEN EXISTS(SELECT val FROM dbo.strSplit(@SelectedLicenseeType,',') WHERE val = 0 AND ul.LicenseeTypeId IS NULL OR val = ul.LicenseeTypeId) THEN 1			
						 ELSE 0 
						 END
	GROUP BY ci.custid
			,CASE WHEN ISNULL(ui.DisplayName,'') = '' THEN ci.username ELSE ui.DisplayName END
			,p.PositionName
				
	SET @DynamicPIVOT = 'SELECT UserId
								,DisplayName
								,PositionName
								,' + @strLicenseeType + 
					'FROM
						(SELECT  t.UserId
									,t.DisplayName
									,t.PositionName
									,lt.LicenseeTypeId
									,lt.LicenseeTypeName
				
							FROM	#tblResult t
								LEFT JOIN dbo.UserLicenseeType ult WITH (NOLOCK)
									ON	ult.UserId = t.UserId
								LEFT JOIN dbo.LicenseeType lt WITH(NOLOCK)
									ON lt.LicenseeTypeId = ult.LicenseeTypeId							
						) l
					PIVOT (
						MAX(l.licenseeTypeId) FOR LicenseeTypeName IN (' + @strLicenseeType + ')
					) Result'
					
	EXEC (@DynamicPIVOT)
END
GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeTypeAssignmentList] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LicenseeTypeAssignmentList] TO [vnteam] AS [dbo]
GO