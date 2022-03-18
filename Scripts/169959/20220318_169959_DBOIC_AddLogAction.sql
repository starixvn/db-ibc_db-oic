/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220318@Kai
	DB: DBOIC.bodb_OIC
	Task:  Enhance new licensee [Redmine:#169959]
*/

--Update order before insert new SP Name and Action Name for log

-- Client
UPDATE dbo.LogAction SET [Order] = 1006 WHERE LogActionTypeId = 1 AND LogActionId = 2
UPDATE dbo.LogAction SET [Order] = 1011 WHERE LogActionTypeId = 1 AND LogActionId = 3
UPDATE dbo.LogAction SET [Order] = 1016 WHERE LogActionTypeId = 1 AND LogActionId = 4
UPDATE dbo.LogAction SET [Order] = 1021 WHERE LogActionTypeId = 1 AND LogActionId = 5
UPDATE dbo.LogAction SET [Order] = 1026 WHERE LogActionTypeId = 1 AND LogActionId = 6
UPDATE dbo.LogAction SET [Order] = 1031 WHERE LogActionTypeId = 1 AND LogActionId = 7
UPDATE dbo.LogAction SET [Order] = 1036 WHERE LogActionTypeId = 1 AND LogActionId = 8

-- Contact
UPDATE dbo.LogAction SET [Order] = 1101 WHERE LogActionTypeId = 1 AND LogActionId = 100
UPDATE dbo.LogAction SET [Order] = 1106 WHERE LogActionTypeId = 1 AND LogActionId = 101
UPDATE dbo.LogAction SET [Order] = 1111 WHERE LogActionTypeId = 1 AND LogActionId = 102

-- Product
UPDATE dbo.LogAction SET [Order] = 1201 WHERE LogActionTypeId = 1 AND LogActionId = 200
UPDATE dbo.LogAction SET [Order] = 1206 WHERE LogActionTypeId = 1 AND LogActionId = 201
UPDATE dbo.LogAction SET [Order] = 1211 WHERE LogActionTypeId = 1 AND LogActionId = 202

-- Category
UPDATE dbo.LogAction SET [Order] = 1301 WHERE LogActionTypeId = 1 AND LogActionId = 300
UPDATE dbo.LogAction SET [Order] = 1306 WHERE LogActionTypeId = 1 AND LogActionId = 301
UPDATE dbo.LogAction SET [Order] = 1311 WHERE LogActionTypeId = 1 AND LogActionId = 302
--UPDATE dbo.LogAction SET [Order] = 1316 WHERE LogActionTypeId = 1 AND LogActionId = 304
UPDATE dbo.LogAction SET [Order] = 1321 WHERE LogActionTypeId = 1 AND LogActionId = 303

-- Training
UPDATE dbo.LogAction SET [Order] = 1401 WHERE LogActionTypeId = 1 AND LogActionId = 400
UPDATE dbo.LogAction SET [Order] = 1406 WHERE LogActionTypeId = 1 AND LogActionId = 401
UPDATE dbo.LogAction SET [Order] = 1411 WHERE LogActionTypeId = 1 AND LogActionId = 402

-- Feature
UPDATE dbo.LogAction SET [Order] = 1501 WHERE LogActionTypeId = 1 AND LogActionId = 500
UPDATE dbo.LogAction SET [Order] = 1506 WHERE LogActionTypeId = 1 AND LogActionId = 501
UPDATE dbo.LogAction SET [Order] = 1516 WHERE LogActionTypeId = 1 AND LogActionId = 502

--Insert new SP Name and Action Name for log when SP exec
INSERT INTO dbo.LogAction (LogActionId, LogActionTypeId, SPName, ActionNameEn, Item, SubItem, [Enable], [Order])
VALUES (304, 1, 'OIC_LicenseeCategoryAssignNewLicensee', 'Insert Category to Client via Add New Client', NULL, NULL, 1, 1316)

GO