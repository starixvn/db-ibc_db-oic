/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/

CREATE PROCEDURE [dbo].[OIC_RegisteredSiteNameSel]
	@LicenseeId	INT	= -1
AS 

/*
    Created by: Scofield
    Date: 2018-07-26
    Task: Get Currency
    DB: DBOIC-bodb_OIC
    
    Revisions:
		- 20180726@Scofield: Get all Currencies [#96489]
 */

BEGIN
    SET NOCOUNT ON;	
	
	DECLARE @LicenseeNames AS TABLE (LicenseeID INT, LicenseeName NVARCHAR(50));
	INSERT INTO @LicenseeNames
	EXEC [bodb02].[dbo].[Acc_SiteSel_Licensee];

	SELECT DISTINCT(rl.LicenseeName)
	FROM @LicenseeNames rl
	LEFT JOIN (SELECT * 
			 FROM [dbo].[Licensee] WITH(NOLOCK) 
			 WHERE LicenseeId <> @LicenseeId) l
	ON LOWER(rl.LicenseeName) = LOWER(l.RegisteredLicenseeName) 
	WHERE l.LicenseeId IS NULL;
END
GO