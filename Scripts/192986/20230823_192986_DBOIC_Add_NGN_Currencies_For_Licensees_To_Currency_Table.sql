/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20230823@Kai
	DB: DBOIC.bodb_OIC
	Task: Add NGN currency for licensees #192986
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (207, 'NGN', 'NGN', 1) ;

GO