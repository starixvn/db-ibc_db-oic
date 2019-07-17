/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20190717@Howard
	DB: DBOIC.bodb_OIC
	Task: Select all of odds type [RedmineID: #115460]
	
	Revisions:
*/

CREATE PROCEDURE [dbo].[OIC_OddsTypeSel]
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT OddsTypeId,OddsTypeName 
	FROM dbo.[OddsType] WITH(NOLOCK)
	ORDER BY OddsTypeName
END
GO

