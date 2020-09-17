/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE bodb_OIC
GO

/*
	Created: 20200917@Howard
	DB: DBOIC.bodb_OIC
	Task: Add and update offered currencies USDT, INH [RedmineID: #141670]
*/

INSERT INTO [dbo].[Currency]
           ([ExchangeId], [Currency], [Code], [IsActive])
     VALUES (96, 'USDT', 'USDT', 1)

GO

UPDATE [dbo].[Currency] WITH(ROWLOCK)
SET Code = 'INH'
WHERE ExchangeId = 51

GO
