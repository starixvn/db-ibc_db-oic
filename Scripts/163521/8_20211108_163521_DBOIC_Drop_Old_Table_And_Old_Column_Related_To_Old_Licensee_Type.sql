/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/


DROP TABLE [dbo].[MessageTarget]
GO

DROP TABLE [dbo].[LicenseeType]
GO

DROP TABLE [dbo].[UserLicenseeType]
GO

ALTER TABLE [dbo].[Licensee]
DROP COLUMN [LicenseeTypeId]
GO


