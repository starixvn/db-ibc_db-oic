/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20240904@Kai
	DB: DBOIC.bodb_OIC
	Task: Add TZS currency for licensees #210315
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (135, 'TZS', 'TZS', 1) ;

GO