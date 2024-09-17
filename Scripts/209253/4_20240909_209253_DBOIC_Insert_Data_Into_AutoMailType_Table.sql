/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240909@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

INSERT INTO [dbo].[AutoMailType]
		(TypeId, TypeName)
	VALUES
		(1, 'Launch Licensee Email'),
		(2, 'Relaunch Licensee Email'),
		(3, 'New Product Launch Email'),
		(4, 'Suspended/ Terminated Licensee Email'),
		(5, 'Terminated Product Email')