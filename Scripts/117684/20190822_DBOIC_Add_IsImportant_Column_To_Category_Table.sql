USE [bodb_OIC]
GO
/*
	Created: 20190822@Howard
	DB: DBOIC.bodb_OIC
	Task: Mark important email [RedmineID: #117684]
*/
ALTER TABLE dbo.Category
ADD IsImportant BIT NOT NULL DEFAULT 0

GO