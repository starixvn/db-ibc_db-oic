/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220615@Kai
	DB: DBOIC.bodb_OIC
	Task:  OIC - Launched emails of a new licensee [Redmine:#168502]
*/


ALTER TABLE [dbo].[MailRecordSiteName]
ADD [LicenseeId] INT NOT NULL DEFAULT 0;
GO