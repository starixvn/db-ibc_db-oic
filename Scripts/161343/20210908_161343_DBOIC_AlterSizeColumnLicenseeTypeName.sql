/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20210908@Hogan
	DB: DBOIC.bodb_OIC
	Task: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
*/

ALTER TABLE [dbo].[LicenseeType]
ALTER COLUMN [LicenseeTypeName] VARCHAR(40)
