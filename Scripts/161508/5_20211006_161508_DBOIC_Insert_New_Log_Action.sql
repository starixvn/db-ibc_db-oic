/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20210922@Alex
	DB: DBOIC.bodb_OIC
	Task: Support Product Type on Client Product [Redmine:#161508]
*/

INSERT INTO LogAction(LogActionId, LogActionTypeId, SPName, ActionNameEn, Item, SubItem, [Enable], [Order])
VALUES (3015, 3, 'OIC_ProductStatusUpd', 'Update Client Product Status', NULL, NULL, 1, 3016);
			
GO