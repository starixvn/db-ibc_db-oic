USE bodb_OIC
GO

/*
	Created: 20190815@Howard
	DB: DBOIC.bodb_OIC
	Task: Insert log action for new sp [RedmineID: #115462]
*/
INSERT INTO dbo.LogAction
           (LogActionId, LogActionTypeId, SPName, ActionNameEn, [Enable], [Order])
     VALUES
			(202, 1, 'OIC_LicenseeProductByLicenseeBatchUpd', 'Batch Update Products', 1, 1013),
			(502, 1, 'OIC_LicenseeFeatureByLicenseeBatchUpd', 'Batch Update Features', 1, 1022)
GO