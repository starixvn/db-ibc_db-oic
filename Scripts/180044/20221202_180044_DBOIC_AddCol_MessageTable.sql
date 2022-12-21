/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20221202@Cody
	DB: DBOIC.bodb_OIC
	Task:  OIC - New Email Notification - Add more content of a new language [RedmineId: #180044]
*/

ALTER TABLE [dbo].[Message]
ADD [ContentVi] NVARCHAR(MAX) NULL;

GO