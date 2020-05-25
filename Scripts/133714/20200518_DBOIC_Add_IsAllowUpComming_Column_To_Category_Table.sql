/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20200518@Hogan
	DB: DBOIC.bodb_OIC
	Task: Support sending mail for upcoming licensees [RedmineID: #133714]
*/
ALTER TABLE dbo.Category
ADD IsAllowUpComming BIT NOT NULL DEFAULT 0

GO