USE [bodb_OIC]
GO

/*
	Created: 20200212Hogan
	DB: DBOIC.bodb_OIC
	Task: Extend length of column CC in MailRecordSiteName table to 1000: #128373]
*/

ALTER TABLE MailRecordSiteName ALTER COLUMN [To] nvarchar(1000)
ALTER TABLE MailRecordSiteName ALTER COLUMN [Cc] nvarchar(1000)