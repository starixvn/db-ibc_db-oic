/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20230222@Cody
	DB: DBOIC.bodb_OIC
	Task:  OIC - Enhance email sending status function to resend the failed emails [RedmineId: #156775]
*/

ALTER TABLE [dbo].[MailRecordSiteName]
ADD [UpdatedTime] DATETIME NULL;

GO