USE [bodb_OIC]
GO

/*
	Created: 20190717@Howard
	DB: DBOIC.bodb_OIC
	Task: Add Odds Type [RedmineID: #115460]
*/

CREATE TABLE [dbo].[OddsType](
	[OddsTypeId] [tinyint] IDENTITY(1,1) NOT NULL,
	[OddsTypeName] [varchar](30) NULL,
 CONSTRAINT [PK_OddsType] PRIMARY KEY CLUSTERED ([OddsTypeId] ASC)
)

GO