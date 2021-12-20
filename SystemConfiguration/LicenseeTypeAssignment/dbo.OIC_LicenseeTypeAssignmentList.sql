/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
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
		- 20180925@Helen: DB052.bodb_NAP Migration to DBCust - [Redmine:100493]
		- 20211116@Alex: Change Type Of Licensee [RedmineID: #163521]
	
	Parameters:	
		@PositionId: All - ALL position
		@SiteId: siteid on NAP Home
 */

BEGIN
	SET NOCOUNT ON;
			
	DECLARE @DynamicPIVOT		VARCHAR(MAX)
			,@strLicenseeType VARCHAR(MAX)
			
	SELECT	@strLicenseeType = ISNULL(@strLicenseeType, '') + '[' + TypeName + '],'
	FROM	dbo.LicenseeTypes WITH(NOLOCK)
	
	SELECT @strLicenseeType = LEFT(@strLicenseeType,LEN(@strLicenseeType) -1)	
	
	SELECT	ci.custid AS UserId
			,CASE WHEN ISNULL(ui.DisplayName,'') = '' THEN ci.username ELSE ui.DisplayName END AS DisplayName
			,p.PositionName
	INTO	#tblResult
	FROM	DBPOL.NAP_UserControl.dbo.NAP_Users u WITH(NOLOCK)
		INNER JOIN DBPOL.NAP_UserControl.dbo.NAP_UserSite us WITH(NOLOCK) ON u.UserId = us.UserId
		INNER JOIN bodb02.dbo.custInfo ci WITH(NOLOCK)
			ON	ci.custid = us.UserId
		LEFT JOIN dbo.UserInfo ui WITH(NOLOCK)
			ON ui.UserId = ci.custid
		LEFT JOIN dbo.Position p WITH(NOLOCK)
			ON ui.PositionId = p.PositionId
		LEFT JOIN UserLicenseeTypes ul
			ON ci.custid = ul.UserId
	WHERE	us.SiteId = @SiteId
			AND us.IsActive = 1
			AND ISNULL(ui.DisplayName,ci.username) LIKE ISNULL(@DisplayName,ci.username) + '%'
			AND (@SelectedPosition = 'All' 
				OR (EXISTS (SELECT val FROM dbo.strSplit(@SelectedPosition,',') WHERE (val = 0 AND p.PositionId IS NULL) OR val = p.PositionId)) 
				)
			AND 1 = CASE WHEN @SelectedLicenseeType = 'All' THEN 1
						 WHEN EXISTS(SELECT val FROM dbo.strSplit(@SelectedLicenseeType,',') WHERE val = 0 AND ul.TypeId IS NULL OR val = ul.TypeId) THEN 1			
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
									,lt.TypeId
									,lt.TypeName
				
							FROM	#tblResult t
								LEFT JOIN dbo.UserLicenseeTypes ult WITH (NOLOCK)
									ON	ult.UserId = t.UserId
								LEFT JOIN dbo.LicenseeTypes lt WITH(NOLOCK)
									ON lt.TypeId = ult.TypeId							
						) l
					PIVOT (
						MAX(l.TypeId) FOR TypeName IN (' + @strLicenseeType + ')
					) Result'
					
	EXEC (@DynamicPIVOT)
END
GO