ALTER PROCEDURE [dbo].[OIC_CurrencySel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Currency [Redmine:#27752]
	DB: DBOIC/BODB02 
	
	Revisions:
		
 */

BEGIN
	SET NOCOUNT ON;
	
	SELECT exchangeid CurrencyId
			,CASE WHEN exchangeid = 20 THEN 'UUS' ELSE Code END Currency
	FROM (
		SELECT exchangeid, code, currency FROM exchange 
		WHERE 
		code not in (SELECT a.code FROM (SELECT COUNT(code) AS b, code FROM exchange WHERE Code <> '' GROUP BY code HAVING COUNT(code)>=2) a)
		and exchangeid not in (42, 48)
		--UNION
		--SELECT exchangeid, code, currency FROM exchange WHERE code = 'USD' and currency = '$US'
		UNION
		SELECT exchangeid, code, currency FROM exchange WHERE code = 'IDR' and currency = 'IN'
		UNION
		SELECT exchangeid, code, currency FROM exchange WHERE code = 'JPY' and currency = 'JPY'
		UNION
		SELECT exchangeid, code, currency FROM exchange WHERE code = 'KRW' and currency = 'Won'
		--UNION
		--SELECT exchangeid, code, currency FROM exchange WHERE code = 'THB' and currency = 'THB'
		UNION
		SELECT exchangeid, code, currency FROM exchange WHERE code = 'THB' and currency = 'TB'
		UNION
		SELECT exchangeid, code, currency FROM exchange WHERE code = 'USD' and currency = 'US$'
		UNION
		SELECT exchangeid, code, currency FROM exchange WHERE code = '' and currency = 'UUS'
	) e
	WHERE exchangeid NOT IN(35,43)
END




GO
GRANT EXECUTE ON [dbo].[OIC_CurrencySel] TO [bodbAdminNet] AS [dbo]