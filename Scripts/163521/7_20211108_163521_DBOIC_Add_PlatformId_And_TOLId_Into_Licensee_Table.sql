/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/


ALTER TABLE [dbo].[Licensee]
ADD [PlatformId] TINYINT NULL
GO

ALTER TABLE [dbo].[Licensee]
ADD [TypeId] TINYINT NULL
GO 





