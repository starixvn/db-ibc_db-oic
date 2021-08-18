/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20210817@Hogan
	DB: DBOIC.bodb_OIC
	Task: Add invoice base currency and invoice language for licensee [RedmineID: #157466]
*/

CREATE TABLE #OIC_Licensee (RegisteredLicenseeName NVARCHAR(100), InvoiceBaseCurrency VARCHAR(4),InvoiceLanguage NVARCHAR(50) )
INSERT INTO #OIC_Licensee(RegisteredLicenseeName)
SELECT lo.RegisteredLicenseeName
FROM bodb_OIC.dbo.Licensee lo WITH(NOLOCK) 
	INNER JOIN bodb_Licensee.dbo.Licensees l WITH(NOLOCK) ON lo.RegisteredLicenseeName = l.LicenseeName

--get InvoiceLanguage
UPDATE oic
SET oic.InvoiceLanguage = pd.InvoiceLanguage
FROM #OIC_Licensee oic
	INNER JOIN bodb_Licensee.dbo.Licensees l WITH(NOLOCK) ON oic.RegisteredLicenseeName = l.LicenseeName
	INNER JOIN bodb_Licensee.dbo.OAS_Party p WITH(NOLOCK) ON l.LicenseeId = p.OldRefId AND p.PartyType IN (1,5)
	INNER JOIN bodb_Licensee.dbo.OAS_PartyDetail pd with (nolock) ON p.PartyId = pd.PartyId AND pd.IsDeposit = 1

--get InvoiceBaseCurrency
UPDATE oic
SET oic.InvoiceBaseCurrency = e.Code
FROM #OIC_Licensee oic
	INNER JOIN bodb_Licensee.dbo.Licensees l  WITH(NOLOCK) ON oic.RegisteredLicenseeName = l.LicenseeName
	INNER JOIN bodb_Licensee.dbo.OAS_Party p  WITH(NOLOCK) ON l.LicenseeId = p.OldRefId AND p.PartyType IN (1,5)
	INNER JOIN bodb_Licensee.dbo.OAS_PartyDetail pd  WITH(NOLOCK) ON p.PartyId = pd.PartyId AND pd.IsDeposit = 1
	INNER JOIN
		(SELECT c.partyid, c.basecurrencyid,ROW_NUMBER() OVER(PARTITION BY partyid ORDER BY todate DESC) AS RN
		FROM bodb_Licensee.dbo.OAS_PartyBaseCurrency c  WITH(NOLOCK)
		) b ON pd.PartyID = b.PartyID AND b.RN = 1
	INNER JOIN bodb02.dbo.exchange e  WITH(NOLOCK) ON b.BaseCurrencyId = e.exchangeid

--update data to OIC Licensee
UPDATE lo WITH(ROWLOCK, UPDLOCK)
SET lo.InvoiceBaseCurrency = tempLic.InvoiceBaseCurrency
	,lo.InvoiceLanguage = tempLic.InvoiceLanguage
FROM bodb_OIC.dbo.Licensee lo
	INNER JOIN #OIC_Licensee tempLic ON lo.RegisteredLicenseeName = tempLic.RegisteredLicenseeName

DROP TABLE #OIC_Licensee

GO