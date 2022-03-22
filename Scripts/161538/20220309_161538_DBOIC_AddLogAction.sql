/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220309@Kai
	DB: DBOIC.bodb_OIC
	Task:  Enhance function to copy contact list for licensees [Redmine:#161538]
*/

--Insert new SP Name and Action Name for log when SP exec
INSERT INTO dbo.LogAction (LogActionId, LogActionTypeId, SPName, ActionNameEn, Item, SubItem, [Enable], [Order])
VALUES (103, 1, 'OIC_ContactListIns', 'Copy Contacts', NULL, NULL, 1, 1106), (104, 1, 'OIC_ContactListCopy', 'Copy Contacts', NULL, NULL, 0, 1121), (305, 1, 'OIC_LicenseeCategoryListIns', 'Insert Category to Client via Copy Contacts', NULL, NULL, 1, 1316)

--Insert new message error
INSERT INTO dbo.MessageError (MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (502, 1, 'Someone has changed the original contact list. Please try again!'), (503, 1, 'Failed to copy contact. Please try again!')

GO