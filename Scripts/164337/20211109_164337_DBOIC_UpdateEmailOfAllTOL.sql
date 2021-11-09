/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

/*
	Created: 20211109@Kos
	DB: DBOIC.bodb_OIC
	Task: Update email of all type of licensee for AM account [RedmineID: #164337]
*/

USE bodb_OIC
GO

UPDATE UserLicenseeType WITH (ROWLOCK)
SET Email = CASE
				WHEN LicenseeTypeId IN (1, 18, 21, 24, 27, 39, 40, 41, 42, 43, 44, 45, 46) THEN 'lmd@enpine.com'
				WHEN LicenseeTypeId IN (3, 4, 16, 19, 22, 25, 28, 29, 31, 32, 33, 34, 35, 36, 37, 38) THEN 'lmd@bopingholdings.com'
				WHEN LicenseeTypeId IN (5, 6, 17, 20, 23, 26, 47, 48, 49, 50, 51, 52, 53, 54) THEN 'lmd@zelianta.com'
			END
WHERE UserId IN (2456, 20404248, 20404294, 20404366, 21264956, 22028567, 22496083, 35182721)

