/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeTypeAssignmentList] 
	@DisplayName			NVARCHAR(50)	= '%'
	,@SelectedPosition		VARCHAR(100)	= 'All'
	,@SelectedLicenseeType	VARCHAR(100)	= 'All'
	,@UserSite				VARCHAR(MAX)	= ''  
AS

/*
	Created by: Kathy
	Date: 20151006
	Task: list licensee type of user  [Redmine:#44257]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20180925@Helen: DB052.bodb_NAP Migration to DBCust - [Redmine:100493]
		- 20211116@Alex: Change Type Of Licensee [RedmineID: #163521]
		- 20230719@Cody: Migrate bodb_OIC to db054/db055 - [RedmineId: #191392]
	
	Parameters:	
		- @SelectedPosition: All - All position
		- @SelectedLicenseeType: All - All licensee type
		- @UserSite:
			<root>
				<UserSiteInfo>
					<UserId>1</UserId>
					<DisplayName>a</DisplayName>
				</UserSiteInfo>
			</root>
 */

BEGIN
	SET NOCOUNT ON;
			
	DECLARE @DynamicPIVOT		VARCHAR(MAX)
			,@strLicenseeType 	VARCHAR(MAX)
			,@XmlUserSite		XML
	DECLARE @UserSiteTable TABLE(UserId INT, DisplayName NVARCHAR(50))
	
	SELECT	@strLicenseeType = ISNULL(@strLicenseeType, '') + '[' + TypeName + '],'
	FROM	dbo.LicenseeTypes WITH(NOLOCK)
	
	SELECT @strLicenseeType = LEFT(@strLicenseeType,LEN(@strLicenseeType) -1)	
	
	IF @UserSite IS NOT NULL AND @UserSite <> ''
		BEGIN
			SELECT @XmlUserSite = @UserSite
			
			INSERT INTO @UserSiteTable (UserId, DisplayName)
			SELECT row.value('(UserId)[1]','INT') AS UserID
					,row.value('(DisplayName)[1]','NVARCHAR(50)') AS DisplayName
			FROM @XmlUserSite.nodes('/root/UserSiteInfo') AS T(row)
		END
	
	SELECT	us.UserId
			,ISNULL(ui.DisplayName,us.DisplayName) AS DisplayName
			,p.PositionName
	INTO	#tblResult
	FROM @UserSiteTable us
		LEFT JOIN dbo.UserInfo ui WITH(NOLOCK)
			ON ui.UserId = us.UserId
		LEFT JOIN dbo.Position p WITH(NOLOCK)
			ON ui.PositionId = p.PositionId
		LEFT JOIN UserLicenseeTypes ul
			ON us.UserId = ul.UserId
	WHERE	ISNULL(ui.DisplayName,us.DisplayName) LIKE ISNULL(@DisplayName,us.DisplayName) + '%'
			AND (@SelectedPosition = 'All' 
				OR (EXISTS (SELECT val FROM dbo.strSplit(@SelectedPosition,',') WHERE (val = 0 AND p.PositionId IS NULL) OR val = p.PositionId)) 
				)
			AND (@SelectedLicenseeType = 'All'
				OR (EXISTS(SELECT val FROM dbo.strSplit(@SelectedLicenseeType,',') WHERE (val = 0 AND ul.TypeId IS NULL) OR val = ul.TypeId))
				)
	GROUP BY us.UserId
			,ISNULL(ui.DisplayName,us.DisplayName)
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