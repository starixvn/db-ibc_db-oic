/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211215@Alex
	DB: DBOIC.bodb_OIC
	Task:  #164892
*/

ALTER TABLE [dbo].[AmendmentTicket]
ALTER COLUMN [DataFilePath] NVARCHAR(300) NULL;
GO

ALTER TABLE [dbo].[AmendmentTicket]
ADD [SessionID] NVARCHAR(300) NULL;
GO








