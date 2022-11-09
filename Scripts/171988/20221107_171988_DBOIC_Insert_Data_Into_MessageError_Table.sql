/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20221107@Cody
	DB: DBOIC.bodb_OIC
	Task: Support to order Client product [Redmine:#171988]
*/

INSERT INTO [bodb_OIC].[dbo].[MessageError]
			([MessageErrorId], [MessageErrorGroupId], [ContentEn])
	VALUES (30030, 3, 'Fail to change client product order. Please try again!')
GO