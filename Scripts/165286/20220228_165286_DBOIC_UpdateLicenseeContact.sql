/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220228@Howard
	DB: DBOIC.bodb_OIC
	Task:  LAP/OIC LAP New Licensee Contact function - Init Data [Redmine:#165286]
*/


UPDATE dbo.Contact WITH (ROWLOCK)
SET IsLicenseeContact = 1
WHERE ContactName NOT IN ('licenseepm', 'licensingpm', 'tm')

GO