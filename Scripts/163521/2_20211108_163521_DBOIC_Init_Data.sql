/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/
INSERT INTO [bodb_OIC].[dbo].[LicenseeTypes]
           ([TypeId], [TypeName])
     VALUES
			(1,'Boping'),
			(2,'Oneworks'),
			(3,'Zelianta')			
GO

INSERT INTO [bodb_OIC].[dbo].[Platform]
           ([PlatformId], [PlatformName])
     VALUES
			(1,'Saba Sports'),
			(2,'White Label China View')
GO

INSERT INTO [bodb_OIC].[dbo].[IntegrationMethod]
           ([IntegrationMethodId], [IntegrationMethodName])
     VALUES
			(1,'API'),
			(2,'Athena'),
			(3,'Single Wallet'),
			(4,'Odds Feed'),
			(5,'Direct Odds')
GO




