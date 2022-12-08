/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20221206@Cody
	DB: DBOIC.bodb_OIC
	Task: Enhance Client group [RedmineId: #174401]
*/

INSERT INTO [bodb_OIC].[dbo].[MessageError]
			([MessageErrorId], [MessageErrorGroupId], [ContentEn])
	VALUES (40018, 1, 'Unable to create because data is out of date. Please try again!')
		   ,(40019, 1, 'Unable to edit because data is out of date. Please try again!')
		   ,(40020, 1, 'Unable to delete the Client Group because it''s containing one or more Client Group(s)')