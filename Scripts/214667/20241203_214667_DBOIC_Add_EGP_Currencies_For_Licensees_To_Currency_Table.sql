/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20241203@Kai
	DB: DBOIC.bodb_OIC
	Task: Add EGP currency for licensees #214667
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (216, 'EGP', 'EGP', 1) ;

GO