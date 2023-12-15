/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20231214@Kai
	DB: DBOIC.bodb_OIC
	Task: Add MP currency for licensees #198413
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (209, 'PHP', 'MP', 1) ;

GO