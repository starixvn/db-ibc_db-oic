USE bodb_OIC
GO

/*
	Created: 20200211@Hogan
	DB: DBOIC.bodb_OIC
	Task: Add Group into Client functions [RedmineID: #126855]
*/
INSERT INTO dbo.LogAction
           (LogActionId, LogActionTypeId, SPName, ActionNameEn, [Enable], [Order])
     VALUES
			(600, 1, 'OIC_LicenseeGroupIns', 'Insert Client Group', 1, 600),
			(601, 1, 'OIC_LicenseeGroupUpd', 'Update Client Group', 1, 601),
			(602, 1, 'OIC_LicenseeGroupDel', 'Delete Client Group', 1, 602)
GO