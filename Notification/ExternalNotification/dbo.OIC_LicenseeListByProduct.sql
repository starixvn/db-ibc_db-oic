/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListByProduct] 
    @ProductId						TINYINT
   ,@UserId							INT
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
    
    Param's Explanation:
		
*/

BEGIN
    SET NOCOUNT ON
    
    SELECT	LicenseeId, LicenseeName, LicenseeTypeId, LicenseeTypeName
    FROM	dbo.f_LicenseeBelongToProduct (@ProductId, @UserId, @ExcludeTerminationProduct)
   
END
GO