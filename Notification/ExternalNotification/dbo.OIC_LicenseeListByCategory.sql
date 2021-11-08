/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByCategory] 
	@CategoryId						TINYINT
	,@LicenseeTypeId				INT
	,@PlatformId					INT
	,@IntegrationMethodId			INT
	,@UserId						INT
	,@MarketType					INT		= -1 -- All
	,@ProductId						TINYINT	= 0 -- All
	,@ExcludeTerminationProduct		BIT		= 0
   
AS

/*
    Created by: Kathy
    Date: 20150825
    Task: Licensee list belong to category [Redmine:#29610]
    DB: DBOIC.bodb_OIC
    
    Revisions:
		- 20160225@Percy: change sitename dropdown [Redmine: #52858]
		- 20170517@Percy: Add Chinese Market Only [RedmineID: #74330]
		- 20190116@Scofield: Uppercase Licensee Name in Title of Emails and add Non-China Market checkbox [RedmineID: #107662]
		- 20200518@hogan: Support sending mail for upcoming licensees [RedmineID: #133714]
		- 20210203@Mark: Add more Product option for Email Notification [RedmineID: #148733]
		- 20210729@Hogan: Enhance Site Name in Send mail notification function [Redmine: #159206]
    
    Param's Explanation:
		
*/

BEGIN
    SET NOCOUNT ON

	SELECT l.LicenseeId, l.LicenseeName, ls.LicenseeStatusName
	FROM dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK) ON ls.LicenseeStatusId = l.LicenseeStatusId
		INNER JOIN dbo.UserLicenseeTypes ult WITH(NOLOCK) ON ult.TypeId = l.TypeId
		INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK) ON ult.TypeId = lt.TypeId
		INNER JOIN dbo.LicenseeCategoryAssigned	lca WITH(NOLOCK) ON l.LicenseeId = lca.LicenseeId
		INNER JOIN dbo.Contact c WITH(NOLOCK) ON l.LicenseeId = c.LicenseeId
		INNER JOIN dbo.CategoryContact cc WITH(NOLOCK) ON cc.ContactId = c.ContactId AND cc.CategoryId = lca.CategoryId
		INNER JOIN dbo.Category ct WITH(NOLOCK) ON cc.CategoryId = ct.CategoryId
	WHERE
		ult.UserId = @UserId
		AND lca.CategoryId = @CategoryId
		AND (
			@MarketType = -1
			OR l.IsChineseMarketOnly = @MarketType
		)
		AND (
			@ProductId = 0
			OR EXISTS (SELECT 1
						FROM dbo.licenseeproduct AS lp WITH(nolock)
						WHERE lp.productid = @ProductId
							AND lp.licenseeid = l.licenseeid
							AND (@ExcludeTerminationProduct = 0 OR (lp.TerminationDate IS NULL OR lp.TerminationDate > CAST(GETDATE() AS DATE))))
		)
		AND (
			l.LicenseeStatusId = 3 -- Active
			OR (ct.IsAllowUpComing = 1 AND l.LicenseeStatusId = 1 ) -- Upcoming if allowed
		)
		AND @LicenseeTypeId = l.TypeId
		AND @PlatformId = l.PlatformId
		AND @IntegrationMethodId IN (SELECT lim.IntegrationMethodId FROM dbo.LicenseeIntegrationMethod lim WHERE lim.LicenseeId = l.LicenseeId)
	GROUP BY l.LicenseeId, l.LicenseeName, ls.LicenseeStatusName
END
GO