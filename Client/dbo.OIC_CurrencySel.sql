USE [bodb02]
GO

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
        
 */

BEGIN
    SET NOCOUNT ON;

	SELECT Exchangeid AS CurrencyId, code, code AS currency 
	FROM
	(
		select exchangeid, code, currency from exchange 
		where 
		code not in (select a.code from (select count(code) as b, code from exchange where Code <> '' group by code having count(code)>=2) a)
		and exchangeid not in (42, 48, 20) --PE, ZAR, UUS
		AND Code NOT IN ('H', 'C', 'RUB', 'CHF', 'BND', 'MXN', 'DKK', 'SEK', 'NOK', 'PLN', 'CZK', 'RON','TWD', 'SGD')
		union
		select exchangeid, code, currency from exchange where code = 'USD' and currency = '$US'
		union
		select exchangeid, code, currency from exchange where code = 'IDR' and currency = 'IN'
		union
		select exchangeid, code, currency from exchange where code = 'JPY' and currency = 'JPY'
		union
		select exchangeid, code, currency from exchange where code = 'KRW' and currency = 'Won'
		union
		select exchangeid, code, currency from exchange where code = 'THB' and currency = 'THB'
		union
		select exchangeid, code, currency from exchange where code = 'THB' and currency = 'TB'
		union
		select exchangeid, code, currency from exchange where code = 'USD' and currency = 'US$'
		--union
		--select exchangeid, code, currency from exchange where code = '' and currency = 'UUS'
		union 
		select exchangeid, code, currency from exchange where code = 'CNY' and currency = 'RMB' 
	) AS result
	WHERE result.exchangeid NOT IN (35,43)
	
END

GO

GRANT EXECUTE ON [dbo].[OIC_CurrencySel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_CurrencySel] TO [vnteam] AS [dbo]
GO