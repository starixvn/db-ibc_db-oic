/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20210806@Hogan
	DB: DBOIC.bodb_OIC
	Task: Add invoice base currency and invoice language for licensee: #157466]
*/

ALTER TABLE dbo.Licensee
ADD InvoiceBaseCurrency VARCHAR(4)

ALTER TABLE dbo.Licensee
ADD InvoiceLanguage NVARCHAR(50)

GO