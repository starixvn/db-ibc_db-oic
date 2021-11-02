/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20210922@Alex
	DB: DBOIC.bodb_OIC
	Task: Support Product Type on Client Product [Redmine:#161508]
*/

INSERT INTO [bodb_OIC].[dbo].[ProductType]
           ([Id], [ProductTypeName], [Order])
     VALUES
			(1,'Sportsbook',1),
			(2,'Number Game',2),
			(3,'Virtual Sports',3),
			(4,'RNG',4),
			(5,'Live Casino',5),
			(6,'Others',100)
			
GO