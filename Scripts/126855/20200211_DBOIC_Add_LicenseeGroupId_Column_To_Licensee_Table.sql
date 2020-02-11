USE [bodb_OIC]
GO

/*
	Created: 20200211@Hogan
	DB: DBOIC.bodb_OIC
	Task: Add Group into Client functions [RedmineID: #126855]
*/
ALTER TABLE dbo.Licensee
ADD LicenseeGroupId INT

GO