/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeProductByProductSel]
	@ProductId			TINYINT
	,@UserId			INT
AS
/*
	Created by: Kathy
	Date: 2015-04-03
	Task: Offer product to clients [Redmine:#29613]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160513@Percy: return field TerminationDate [RedmineID: #56935]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
	
	Param's Explanation:
		
		
 */
BEGIN
	SET NOCOUNT ON
	
	SELECT	l.LicenseeId
			,l.LicenseeName
			,lp.LaunchDate
			,lp.TerminationDate
	FROM dbo.Licensee l WITH(NOLOCK)
		LEFT JOIN dbo.LicenseeProduct lp WITH(NOLOCK) 
			ON	l.LicenseeId = lp.LicenseeId 
				AND lp.ProductId = @ProductId
	WHERE l.TypeId IN (SELECT TypeId FROM dbo.UserLicenseeTypes WITH(NOLOCK) WHERE UserId = @UserId)
	ORDER BY l.LicenseeName
END
