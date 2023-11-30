/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20231130@Kai
	DB: DBOIC.bodb_OIC
	Task: Add COP currency for licensees #197724
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (84, 'COP', 'COP', 1) ;

GO