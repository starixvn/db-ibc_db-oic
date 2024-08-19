/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240808@Cody
	DB: DBOIC.bodb_OIC
	Task: Change recipient emails for Jollysports group #207804
*/

ALTER TABLE [dbo].[MailRecordSiteName]
ADD [LicenseeTypeMail] TINYINT NOT NULL DEFAULT 0

GO