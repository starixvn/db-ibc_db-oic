USE bodb_OIC
GO

/*
	Created: 20190625@Percy
	DB: DBOIC.bodb_OIC
	Task: Update LMD email address [RedmineID: #115475]
*/

UPDATE dbo.UserLicenseeType WITH (ROWLOCK, UPDLOCK)
SET Email = CASE	WHEN LicenseeTypeId IN (3,4) THEN 'lmd@bopingholdings.com'
					WHEN LicenseeTypeId IN (5,6) THEN 'lmd@zelianta.com'
					ELSE Email END
WHERE UserId IN (2456, 20404248, 20404294, 20404366, 21264956, 22028567, 22496083)
	AND LicenseeTypeId IN (3,4,5,6)
GO