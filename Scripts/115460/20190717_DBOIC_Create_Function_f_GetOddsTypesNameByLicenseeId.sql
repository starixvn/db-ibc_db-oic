/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="1" isNested="1"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20190717@Howard
	DB: DBOIC.bodb_OIC
	Task: get all of odds type name of licensee [RedmineID: #115460]
*/

CREATE FUNCTION [dbo].[f_GetOddsTypesNameByLicenseeId](@LicenseeId int)
 RETURNS VARCHAR(100)
 AS BEGIN
    DECLARE  @oddsTypes varchar(100) = NULL;
    
	SELECT @oddsTypes = COALESCE(@oddsTypes + ', ' + ot.OddsTypeName, ot.OddsTypeName) 
	FROM LicenseeOddsType AS lot WITH(NOLOCK)
		INNER JOIN OddsType as ot WITH(NOLOCK)
			ON lot.OddsTypeId = ot.OddsTypeId 
	WHERE lot.LicenseeId = @LicenseeId
	
	RETURN @oddsTypes
 END

GO

