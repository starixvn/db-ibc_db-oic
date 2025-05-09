/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20250509@Kai
	DB: DBOIC.bodb_OIC
	Task: Add AOA & XAF currency for licensees #226898
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (235, 'AOA', 'AOA', 1), (236, 'XAF', 'XAF', 1);

GO