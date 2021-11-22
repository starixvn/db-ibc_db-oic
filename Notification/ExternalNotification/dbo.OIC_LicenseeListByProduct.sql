/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByProduct] 
    @ProductId						TINYINT
	,@UserId						INT
	,@SelectedLicenseeType			VARCHAR(50) = 'All'
	,@SelectedPlatform				VARCHAR(50) = 'All'
	,@SelectedIntegrationMethod		VARCHAR(50) = 'All'
	,@ExcludeTerminationProduct		BIT		= 0
AS

/*
    Created by: Kathy
    Date: 20150825
    Task: Licensee list belong to product [Redmine:#29610]
    DB: DBOIC.bodb_OIC
    
    Revisions:
		- 20160225@Percy: change sitename dropdown [Redmine: #52858]
		- 20210729@Hogan: Enhance Site Name in Send mail notification function [Redmine: #159206]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
    
    Param's Explanation:
		
*/

BEGIN
    SET NOCOUNT ON
    
	DECLARE @tblLicenseeType	TABLE (LicenseeTypeId TINYINT)
	DECLARE @tblPlatform	TABLE (PlatformId TINYINT)
	DECLARE @tblIntegrationMethod	TABLE (IntegrationMethodId TINYINT)

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

    SELECT	f.LicenseeId, f.LicenseeName, f.TypeId, f.TypeName
    FROM	dbo.f_LicenseeBelongToProduct (@ProductId, @UserId, @ExcludeTerminationProduct) f
	WHERE (SELECT l.PlatformId FROM dbo.Licensee l WHERE l.LicenseeId = f.LicenseeId) IN (SELECT PlatformId FROM @tblPlatform)
	AND f.TypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
	AND f.LicenseeId IN (SELECT lim.LicenseeId FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK) WHERE lim.IntegrationMethodId IN (SELECT IntegrationMethodId FROM @tblIntegrationMethod))
   
END
GO