/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="1" isNested="1"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20190717@Howard
	DB: DBOIC.bodb_OIC
	Task: get all of odds type name of licensee [RedmineID: #115460]
	
	Revisions:
		- 20190722@Howard: Created [RedmineID: #115460]
*/

CREATE FUNCTION [dbo].[f_GetCurrencyCodeByLicenseeId](@LicenseeId int)
 RETURNS VARCHAR(1000)
 AS BEGIN
    DECLARE  @currenciesCode varchar(1000) = NULL;
    
	SELECT @currenciesCode = COALESCE(@currenciesCode + ', ' + e.Code, e.Code) 
	FROM dbo.LicenseeCurrency lc WITH(NOLOCK)
			INNER JOIN bodb02.dbo.Exchange e WITH(NOLOCK) 
				ON lc.CurrencyId = e.exchangeid
	WHERE lc.LicenseeId = @LicenseeId AND e.Code IS NOT NULL
	RETURN @currenciesCode
 END

GO

