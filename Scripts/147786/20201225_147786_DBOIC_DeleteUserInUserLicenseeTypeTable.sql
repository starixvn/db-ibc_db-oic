/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20201225@Hogan
	DB: DBOIC.bodb_OIC
	Task: Support to delete user in UserLicenseeType table [RedmineID: #147786]
*/

DELETE FROM dbo.UserLicenseeType
WHERE LicenseeTypeId = 12