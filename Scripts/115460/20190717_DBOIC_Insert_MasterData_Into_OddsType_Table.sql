USE [bodb_OIC]
GO

/*
	Created: 20190717@Howard
	DB: DBOIC.bodb_OIC
	Task: Insert master data to OddsType Table [RedmineID: #115460]
*/
INSERT INTO [bodb_OIC].[dbo].[OddsType]
           ([OddsTypeName])
     VALUES
			('Dec'),
			('HK'),
			('Indo'),
			('MY'),
			('US')
GO

