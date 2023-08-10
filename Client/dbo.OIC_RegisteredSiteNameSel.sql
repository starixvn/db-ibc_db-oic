/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_RegisteredSiteNameSel]
	@LicenseeId	INT	= -1
AS 

/*
    Created by: Scofield
    Date: 2018-07-26
    Task: Get Currency
    DB: DBOIC-bodb_OIC
    
    Revisions:
		- 20180726@Scofield: Get all Currencies [#96489]
		- 20230719@Cody: Migrate bodb_OIC to db054/db055 - [RedmineId: #191392]
 */

BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT(rl.LicenseeName)
	FROM (SELECT SiteId as LicenseeId, [Site] as LicenseeName
				FROM	[bodb02].[dbo].[Site] WITH(NOLOCK)
				WHERE	IsLicensee = 1 AND IsActive = 1 
						AND SiteID NOT IN (29,35)) rl
	LEFT JOIN (SELECT LicenseeId, RegisteredLicenseeName 
				FROM [dbo].[Licensee] WITH(NOLOCK) 
				WHERE LicenseeId <> @LicenseeId) l
		ON LOWER(rl.LicenseeName) = LOWER(l.RegisteredLicenseeName) 
	WHERE l.LicenseeId IS NULL
	ORDER BY rl.LicenseeName
END
GO