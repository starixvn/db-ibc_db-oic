/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20200723@Howard
	DB: DBOIC.bodb_OIC
	Task: Update Status MailRecordSiteName to 1  [RedmineID: #138205]
*/

 UPDATE [dbo].[MailRecordSiteName] WITH(ROWLOCK)
 SET Status = 1
 WHERE Id >= 24207 AND Id <= 24365 