/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20210922@Alex
	DB: DBOIC.bodb_OIC
	Task: Support Product Type on Client Product [Redmine:#161508]
*/

INSERT INTO MessageError(MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (30029, 3, 'Fail to edit status client product. Please try again!');
			
GO