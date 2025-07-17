/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20250703@Kai
	DB: DBOIC.bodb_OIC
	Task: Add KES currency for licensees #232236
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (79, 'KES', 'KES', 1);

GO