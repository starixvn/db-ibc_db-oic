/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220825@Kai
	DB: DBOIC.bodb_OIC
	Task:  OIC - Enhance new launch product email [Redmine:#168502]
*/


ALTER TABLE [dbo].[MailRecordSiteName]
ADD [Type] TINYINT NOT NULL DEFAULT 0;
GO


CREATE TABLE LicenseeMailRecord (
	LicenseeId INT, 
	MailRecordId INT
	CONSTRAINT PK_LicenseeMailRecord PRIMARY KEY (LicenseeId, MailRecordId)
)
GO