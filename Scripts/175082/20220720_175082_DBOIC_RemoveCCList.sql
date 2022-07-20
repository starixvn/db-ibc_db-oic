/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220720@Howard
	DB: DBOIC.bodb_OIC
	Task:  LAP - Licensee Contact - Transfer existing data from "CC List" into "TO List" for Licensee Contact only [Redmine:#175082]
*/

  UPDATE cc WITH(ROWLOCK)
  SET cc.RecipientType = 0
  FROM [dbo].[CategoryContact] cc
	INNER JOIN [dbo].[Contact] c ON cc.ContactId = c.ContactId
  WHERE c.IsLicenseeContact = 1 AND cc.RecipientType = 1

GO