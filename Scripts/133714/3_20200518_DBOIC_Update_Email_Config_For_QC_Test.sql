/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20200518@Hogan
	DB: DBOIC.bodb_OIC
	Task: Support sending mail for upcoming licensees [RedmineID: #133714]
*/
UPDATE dbo.EmailConfiguration WITH(ROWLOCK, UPDLOCK)
	SET CcList = 'roshan.nguyen@starixsoft.com'
WHERE CcList LIKE 'csoneonone@enpine.com'

GO