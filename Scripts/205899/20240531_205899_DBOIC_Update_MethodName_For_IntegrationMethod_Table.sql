/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240531@Cody
	DB: DBOIC.bodb_OIC
	Task: Update Integration Method naming API to API (transfer wallet) #205899
*/

UPDATE [dbo].[IntegrationMethod]
SET [IntegrationMethodName] = 'API (transfer wallet)'
WHERE [IntegrationMethodId] = 1

GO