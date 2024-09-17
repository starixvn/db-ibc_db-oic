/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240917@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

INSERT INTO dbo.LogAction(LogActionId, LogActionTypeId, SPName, ActionNameEn, Item, SubItem, [Enable], [Order])
VALUES (3016, 3, 'OIC_AutoMailUpd', 'Update AutoMail Recipient List', NULL, NULL, 1, 3017),
		(3017, 3, 'OIC_AutoMailIns', 'Add AutoMail Recipient List', NULL, NULL, 1, 3018),
		(3018, 3, 'OIC_AutoMailDel', 'Delete AutoMail Recipient List', NULL, NULL, 1, 3019)
		
GO