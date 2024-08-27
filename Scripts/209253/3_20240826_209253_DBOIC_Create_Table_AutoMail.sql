/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240826@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

CREATE TABLE [dbo].[AutoMail](
	[Id] [INT] IDENTITY(1,1) NOT NULL,
	[Email] [NVARCHAR](50) NOT NULL,
	[RecipientType] [TINYINT] NOT NULL, /*0: To, 1: Cc*/
	[IsTest] [BIT] NOT NULL,
	[GroupId] [TINYINT] NOT NULL,
	[TypeId] [TINYINT] NOT NULL,
	[LicenseeTypeId] [TINYINT] NOT NULL,
	CONSTRAINT [PK__AutoMail] PRIMARY KEY CLUSTERED ([Id] ASC)
)
GO