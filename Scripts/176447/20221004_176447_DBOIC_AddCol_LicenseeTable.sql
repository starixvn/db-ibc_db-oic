/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20221004@Kai
	DB: DBOIC.bodb_OIC
	Task:  OIC - Support sending emails automatically [Redmine:#176447]
*/


ALTER TABLE [dbo].[Licensee]
ADD [TerminationRemark] NVARCHAR(300) NULL,
	[RelaunchDate] DATETIME NULL,
	[SuspendedDate] DATETIME NULL,
	[TerminatedDate] DATETIME NULL;

GO