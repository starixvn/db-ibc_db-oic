/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20240814@Kai
	DB: DBOIC.bodb_OIC
	Task: Add LAK currency for licensees #209326
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (93, 'LAK', 'LAK', 1) ;

GO