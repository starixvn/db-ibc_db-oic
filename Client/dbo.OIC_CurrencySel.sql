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
		- 20180717@Scofield: Get all Currencies [#96489]
 */

BEGIN
    SET NOCOUNT ON;
	
	SELECT exchangeid AS CurrencyId, code, code AS currency  
	FROM exchange 
	WHERE (currency = 'SD$' AND code = 'SGD')
		OR (currency = 'RM' AND code = 'MYR')
		OR (currency = 'US$' AND code = 'USD')
		OR (currency = 'TB' AND code = 'THB')
		OR (currency = 'HK$' AND code = 'HKD')
		OR (currency = 'EURO' AND code = 'EUR')
		OR (currency = 'AUD' AND code = 'AUD')
		OR (currency = 'GBP' AND code = 'GBP')
		OR (currency = 'RMB' AND code = 'CNY')
		OR (currency = 'IN' AND code = 'IDR')
		OR (currency = 'CAD' AND code = 'CAD')
		OR (currency = 'NT' AND code = 'TWD')
		OR (currency = 'JPY' AND code = 'JPY')
		OR (currency = 'CHF' AND code = 'CHF')
		OR (currency = 'PE' AND code = 'PHP')
		OR (currency = 'Won' AND code = 'KRW')
		OR (currency = 'BND' AND code = 'BND')
		OR (currency = 'ZAR' AND code = 'ZAR')
		OR (currency = 'MXN' AND code = 'MXN')
		OR (currency = 'INH' AND code = 'VND')
		OR (currency = 'DKK' AND code = 'DKK')
		OR (currency = 'SEK' AND code = 'SEK')
		OR (currency = 'NOK' AND code = 'NOK')
		OR (currency = 'RUB' AND code = 'RUB')
		OR (currency = 'PLN' AND code = 'PLN')
		OR (currency = 'CZK' AND code = 'CZK')
		OR (currency = 'RON' AND code = 'RON')
		OR (currency = 'INR' AND code = 'INR')
		OR (currency = 'NZD' AND code = 'NZD')
		OR (currency = 'MMK' AND code = 'MMK')
		OR (currency = 'KHR' AND code = 'KHR')
		OR (currency = 'YNG' AND code = 'YNG')
		OR (currency = 'LIR' AND code = 'TRY')
	ORDER BY code	
END
GO