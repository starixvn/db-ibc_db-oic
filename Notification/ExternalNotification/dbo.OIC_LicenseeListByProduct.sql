/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByProduct] 
    @ProductId						TINYINT
	,@UserId						INT
	,@LicenseeTypeId				INT
	,@PlatformId					INT
	,@IntegrationMethodId			INT
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
    
    SELECT	f.LicenseeId, f.LicenseeName, f.TypeId, f.TypeName
    FROM	dbo.f_LicenseeBelongToProduct (@ProductId, @UserId, @ExcludeTerminationProduct) f
	WHERE @PlatformId IN (SELECT l.PlatformId FROM dbo.Licensee l WHERE l.LicenseeId = f.LicenseeId)
	AND @LicenseeTypeId IN (SELECT l.TypeId FROM dbo.Licensee l WHERE l.LicenseeId = f.LicenseeId)
	AND @IntegrationMethodId IN (SELECT lim.IntegrationMethodId FROM dbo.LicenseeIntegrationMethod lim WHERE lim.LicenseeId = f.LicenseeId)
   
END
GO