/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/

CREATE PROCEDURE [dbo].[OIC_CurrencySel]
AS 

/*
    Created by: Scofield
    Date: 2018-07-26
    Task: Get Currency
    DB: DBOIC-bodb_OIC
    
    Revisions:
		- 20180726@Scofield: Get all Currencies [#96489]
 */

BEGIN
    SET NOCOUNT ON;	
	
	SELECT ExchangeId AS CurrencyId, Code AS CurrencyName  
	FROM [dbo].[Currency] WITH(NOLOCK)
	WHERE IsActive = 1
	ORDER BY Code;	
END
GO