/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20210917@Alex
	DB: DBOIC.bodb_OIC
	Task: Support Product Type on Client Product #161508
*/

ALTER TABLE [dbo].[Product]
ADD [Active] BIT NOT NULL DEFAULT 1

GO

ALTER TABLE [dbo].[Product]
ADD [MainProductId] TINYINT NULL

GO 

ALTER TABLE [dbo].[Product]
ADD [ProductTypeId] TINYINT NULL

GO



