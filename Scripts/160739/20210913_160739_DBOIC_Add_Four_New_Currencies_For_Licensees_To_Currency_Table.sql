/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20210913@Alex
	DB: DBOIC.bodb_OIC
	Task: Add more currencies for licensees #160739
*/

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (97, 'BDT', 'BDT', 1);

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (121, 'PKR', 'PKR', 1);

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (122, 'KZT', 'KZT', 1);

INSERT INTO dbo.Currency (ExchangeId, Currency, Code, IsActive)
VALUES (123, 'NPR', 'NPR', 1);

GO