/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20221206@Cody
	DB: DBOIC.bodb_OIC
	Task: Enhance Client group [RedmineId: 174401]
*/

ALTER TABLE [dbo].[LicenseeGroup]
ADD [ParentId] INT NULL

GO