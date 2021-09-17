/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ProductTypeSel] 
AS
/*
	Created by: Alex
	Date: 2021-09-29
	Task: Support Product Type on Client Product [Redmine:#161508]
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		- 20210929@Alex: Create store procedure [Redmine: #161508]
	
 */
BEGIN
	SET NOCOUNT ON
	
	SELECT  p.Id AS ProductTypeId
			,p.ProductTypeName
			,P.[Order]
	FROM dbo.ProductType p WITH(NOLOCK)
	ORDER BY p.[Order]
END
GO
