USE [bodb_OIC]
GO

ALTER TABLE dbo.AmendmentMessage ADD PublishedDate Datetime NULL;

UPDATE AmendmentMessage
SET PublishedDate = ReceivedDate
WHERE Status <> 0;