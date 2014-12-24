ALTER PROCEDURE [dbo].[OIC_CurrencySel]
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Currency
	DB: DBOIC/BODB02 
	
	Revisions:
		
 */

BEGIN
	SELECT exchangeid CurrencyID
			,CASE WHEN exchangeid = 20 THEN 'UUS' ELSE Code END Currency 
	FROM dbo.exchange WITH(NOLOCK) 
	WHERE exchangeid not in(35,43)
END
GO

GRANT EXECUTE ON [OIC_CurrencySel] TO bodbadminnet