/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByCategory] 
    @CategoryId				TINYINT
    ,@UserId				INT
	,@MarketType			INT		= -1 -- All
	,@ProductId				TINYINT		= 0 -- All
   
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
    
    Param's Explanation:
		
*/

BEGIN
    SET NOCOUNT ON

	SELECT l.LicenseeId, l.LicenseeName, l.LicenseeTypeId, lt.LicenseeTypeName, ls.LicenseeStatusName
	FROM dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK) ON ls.LicenseeStatusId = l.LicenseeStatusId
		INNER JOIN dbo.UserLicenseeType ult WITH(NOLOCK) ON ult.LicenseeTypeId = l.LicenseeTypeId
		INNER JOIN dbo.LicenseeType lt WITH(NOLOCK) ON ult.LicenseeTypeId = lt.LicenseeTypeId
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
			OR EXISTS (SELECT 1 FROM dbo.LicenseeProduct AS lp WITH(NOLOCK) WHERE lp.ProductId = @ProductId AND lp.LicenseeId = l.LicenseeId)
		)
		AND (
			l.LicenseeStatusId = 3 -- Active
			OR (ct.IsAllowUpComing = 1 AND l.LicenseeStatusId = 1 ) -- Upcoming if allowed
		)
	GROUP BY l.LicenseeId, l.LicenseeName, l.LicenseeTypeId, lt.LicenseeTypeName, ls.LicenseeStatusName
END
GO