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
WHERE UserId IN (2456,20404248,20404294,20404366,21264956,22028567,22496083,35182721)
	AND LicenseeTypeId IN (3,4,5,6)
GO

UPDATE dbo.UserLicenseeType WITH (ROWLOCK, UPDLOCK)
SET Email = 'lmd@enpine.com'
WHERE UserId IN (21264956,22028567,35182721)
	AND LicenseeTypeId IN (1,2,12)
GO