/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByCategory] 
	@CategoryId						TINYINT
	,@SelectedLicenseeType			VARCHAR(50) = 'All'
	,@SelectedPlatform				VARCHAR(50) = 'All'
	,@SelectedIntegrationMethod		VARCHAR(50) = 'All'
	,@UserId						INT
	,@MarketType					INT		= -1 -- All
	,@FeatureId						TINYINT	= 0 -- All
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
		- 20211116@Kai: Enhancement of Type of Licensee [RedmineID: #163521]
		- 20230821@Loki: Feature filter on New Email Notification[RedmineID: #191100]
		- 20231229@Cody: Get LicenseeTypeId [RedmineID: 198195]
    
    Param's Explanation:
		
*/

BEGIN
    SET NOCOUNT ON

	DECLARE @tblLicenseeType	TABLE (LicenseeTypeId TINYINT)
	DECLARE @tblPlatform	TABLE (PlatformId TINYINT)
	DECLARE @tblIntegrationMethod	TABLE (IntegrationMethodId TINYINT)
	DECLARE @currentDate DATE = CAST(GETDATE() AS DATE)

	IF @SelectedLicenseeType = 'All'
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT	TypeId
		FROM	dbo.UserLicenseeTypes WITH(NOLOCK)
		WHERE	UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedLicenseeType, ',')

		DELETE lt
		FROM @tblLicenseeType lt
			LEFT JOIN dbo.UserLicenseeTypes ult WITH(NOLOCK) ON lt.LicenseeTypeId = ult.TypeId AND ult.UserId = @UserId
		WHERE ult.TypeId IS NULL
	END

	IF @SelectedPlatform = 'All'
	BEGIN
		INSERT INTO @tblPlatform (PlatformId)
		SELECT	PlatformId
		FROM	dbo.Platform WITH(NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO @tblPlatform (PlatformId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedPlatform, ',')
	END

	IF @SelectedIntegrationMethod = 'All'
	BEGIN
		INSERT INTO @tblIntegrationMethod (IntegrationMethodId)
		SELECT	IntegrationMethodId
		FROM	dbo.IntegrationMethod WITH(NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO @tblIntegrationMethod (IntegrationMethodId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedIntegrationMethod, ',')
	END

	SELECT l.LicenseeId, l.LicenseeName, ls.LicenseeStatusName, l.TypeId AS LicenseeTypeId
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
			@FeatureId = 0
			OR EXISTS (
				SELECT 1
				FROM dbo.LicenseeFeature lf WITH(NOLOCK)
				WHERE lf.FeatureId = @FeatureId
					AND lf.LicenseeId = l.LicenseeId
					AND (lf.TerminationDate IS NULL OR lf.TerminationDate > @currentDate)
			)
		)
		AND (
			@ProductId = 0
			OR EXISTS (SELECT 1
						FROM dbo.LicenseeProduct AS lp WITH(NOLOCK)
						WHERE lp.ProductId = @ProductId
							AND lp.LicenseeId = l.LicenseeId
							AND (@ExcludeTerminationProduct = 0 OR (lp.TerminationDate IS NULL OR lp.TerminationDate > @currentDate)))
		)
		AND (
			l.LicenseeStatusId = 3 -- Active
			OR (ct.IsAllowUpComing = 1 AND l.LicenseeStatusId = 1 ) -- Upcoming if allowed
		)
		AND l.TypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
		AND l.PlatformId IN (SELECT PlatformId FROM @tblPlatform)
		AND l.LicenseeId IN (SELECT lim.LicenseeId FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK) WHERE lim.IntegrationMethodId IN (SELECT IntegrationMethodId FROM @tblIntegrationMethod))
	GROUP BY l.LicenseeId, l.LicenseeName, ls.LicenseeStatusName, l.TypeId
END
GO