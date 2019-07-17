USE [bodb_OIC]
GO

/*
	Created: 20190717@Howard
	DB: DBOIC.bodb_OIC
	Task: Add Odds Type [RedmineID: #115460]
*/

CREATE TABLE [dbo].[LicenseeOddsType](
	[LicenseeId] [int] NOT NULL,
	[OddsTypeId] [tinyint] NOT NULL,
	CONSTRAINT [PK_LicenseeOddsType] PRIMARY KEY CLUSTERED ([LicenseeId] ASC, [OddsTypeId] ASC)
 )
GO


