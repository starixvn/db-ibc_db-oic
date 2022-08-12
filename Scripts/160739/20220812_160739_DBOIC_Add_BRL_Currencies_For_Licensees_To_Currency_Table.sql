/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20220811@Kai
	DB: DBOIC.bodb_OIC
	Task: Add BRL currency for licensees #160739
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (82, 'BRL', 'BRL', 1);

GO