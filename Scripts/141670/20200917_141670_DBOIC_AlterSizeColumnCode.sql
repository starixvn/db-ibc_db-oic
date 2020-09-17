/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20200917@Howard
	DB: DBOIC.bodb_OIC
	Task: Extend size of column Code to VARCHAR(4) [RedmineID: #141670]
*/

ALTER TABLE [dbo].[Currency]
ALTER COLUMN [Code] VARCHAR(4)
