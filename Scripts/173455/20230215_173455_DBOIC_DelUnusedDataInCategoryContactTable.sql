/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20230215@Kai
	DB: DBOIC.bodb_OIC
	Task:  OIC - Delete unused data in CategoryContact table [RedmineId: #173455]
*/

DELETE cc
FROM bodb_OIC.dbo.CategoryContact cc
	LEFT JOIN bodb_OIC.dbo.Contact c WITH(NOLOCK) 
		ON cc.ContactId = c.ContactId 
WHERE c.ContactId IS NULL

GO