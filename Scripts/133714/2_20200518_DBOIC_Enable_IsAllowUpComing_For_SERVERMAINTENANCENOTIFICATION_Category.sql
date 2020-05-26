/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20200518@Hogan
	DB: DBOIC.bodb_OIC
	Task: Support sending mail for upcoming licensees [RedmineID: #133714]
*/
UPDATE dbo.Category WITH(ROWLOCK, UPDLOCK)
	SET IsAllowUpComing = 1
WHERE UPPER(CategoryName) LIKE 'SERVER MAINTENANCE NOTIFICATION%'

GO