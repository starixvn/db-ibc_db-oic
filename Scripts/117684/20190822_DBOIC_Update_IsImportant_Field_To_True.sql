USE [bodb_OIC]
GO
/*
	Created: 20190822@Howard
	DB: DBOIC.bodb_OIC
	Task: update important field for category [RedmineID: #117684]
*/

UPDATE dbo.Category WITH (ROWLOCK, UPDLOCK)
SET IsImportant = 1
WHERE CategoryName IN ('API Notification', 'NEW PRODUCT LAUNCH NOTIFICATION')

GO