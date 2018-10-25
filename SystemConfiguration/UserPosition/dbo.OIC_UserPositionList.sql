/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_UserPositionList] 
	@DisplayName		NVARCHAR(50)	= '%'
	,@SelectedPosition	VARCHAR(100)	= 'All'
	,@SiteId			INT 
AS
/*
	Created by: Kathy
	Date: 20151002
	Task: list user position [Redmine:#44258]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20180925@Helen: DB052.bodb_NAP Migration to DBCust - [Redmine:100493]
	
	Parameters:	
		@PositionId: All - ALL position
		@SiteId: siteid on NAP Home
 */
BEGIN
	SET NOCOUNT ON;
	
	SELECT	ci.custid AS UserId
			,CASE WHEN ISNULL(ui.DisplayName,'') = '' THEN ci.username ELSE ui.DisplayName END AS DisplayName
			,p.PositionId
	FROM DBPOL.NAP_UserControl.dbo.NAP_UserSite u WITH(NOLOCK)
		INNER JOIN bodb02.dbo.custInfo ci WITH(NOLOCK)
			ON	ci.custid = u.UserId
		LEFT JOIN dbo.UserInfo ui WITH(NOLOCK)
			ON ui.UserId = ci.custid
		LEFT JOIN dbo.Position p WITH(NOLOCK)
			ON ui.PositionId = p.PositionId
	WHERE	u.SiteId = @SiteId
			AND CASE WHEN ui.UserId IS NOT NULL THEN ISNULL(ui.DisplayName,'%')
					 ELSE ISNULL(ci.username,'%') 
					 END LIKE ISNULL(@DisplayName,'%') + '%'
			AND (@SelectedPosition = 'All' 
				OR (EXISTS (SELECT val FROM dbo.strSplit(@SelectedPosition,',') WHERE (val = 0 AND p.PositionId IS NULL) OR val = p.PositionId)) 
				)
			
	
END
GO






GO
GRANT EXECUTE ON [dbo].[OIC_UserPositionList] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_UserPositionList] TO [vnteam] AS [dbo]