/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20240301@Kai
	DB: DBOIC.bodb_OIC
	Task: Create a new client in OIC when adding a new licensee in Sitebuilder [Redmine:#197581]
*/

INSERT INTO LogAction(LogActionId, LogActionTypeId, SPName, ActionNameEn, Item, SubItem, [Enable], [Order])
VALUES (9, 1, 'OIC_API_LicenseeIns', 'Insert Client from Site Builder', NULL, NULL, 1, 1028);
			
GO