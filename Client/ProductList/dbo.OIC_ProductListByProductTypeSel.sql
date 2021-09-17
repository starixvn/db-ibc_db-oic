/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_ProductListByProductType]
AS
/*
	Created by: Alex
	Date: 2021-09-19
	Task: Support Product Type on Client Product [Redmine:#161508]
	DB: DBOIC/BODB_OIC 

	Revisions:
		- 20210921@Alex: Get Grouped product data [Redmine:#161508]

	Param's Explanation:
	
 */
BEGIN
	SET NOCOUNT ON

	SELECT  pt.Id AS ProductTypeId
			,pt.ProductTypeName
			,p.ProductId
			,p.ProductName
	FROM dbo.ProductType pt WITH(NOLOCK)
		LEFT JOIN dbo.Product p WITH(NOLOCK)
			   ON pt.Id = p.ProductTypeId
	WHERE p.[Active] = 1
	ORDER BY pt.[Id]
END
GO