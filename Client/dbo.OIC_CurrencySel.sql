/*<info serverAlias="DBEXT-bodb02" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_CurrencySel]
AS 

/*
    Created by: Dom
    Date: 2014-12-18
    Task: Get Currency
    DB: DBEXT/BODB02 
    
    Revisions:
		- 20160111@Kathy: Exclude currencies: H, C, RUB, CHF, BND, MXN, DKK, SEK, NOK, PLN, CZK, RON, UUS, TWD
		- 20160201@Kathy: Change ExchangeId to CurrencyId
		- 20160506@Percy: Exclude currency: SGD [Redmine: #56935]
		- 20160823@Percy: Sort by Code [RedmineID: #62883]
		- 20180717@Scofield: Get all Currencies        
 */

BEGIN
    SET NOCOUNT ON;
	
	SELECT exchangeid AS CurrencyId, code, code AS currency  
	FROM 
		(SELECT exchangeid, code FROM exchange 
		 WHERE (code = 'IDR' AND currency = 'IN')
			OR (code = 'JPY' AND currency = 'JPY')
			OR (code = 'KRW' AND currency = 'Won')
			OR (code = 'THB' AND currency = 'TB')
			OR (code = 'USD' AND currency = 'US$')
			OR (code = 'CNY' AND currency = 'RMB')

		UNION

		SELECT MIN(exchangeid) AS exchangeid, code 
		FROM exchange WHERE code NOT IN ('', 'IDR', 'JPY', 'KRW', 'THB', 'USD', 'CNY')
		GROUP BY code) AS r
	ORDER BY code	
END
GO