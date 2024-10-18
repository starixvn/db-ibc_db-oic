/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240826@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

CREATE TABLE [dbo].[AutoMailGroup](
	[GroupId] [TINYINT] NOT NULL,
	[GroupName] [NVARCHAR](50) NOT NULL,
	[SpecialGroupId] [TINYINT] NOT NULL,
	CONSTRAINT [PK__AutoMailGroup] PRIMARY KEY CLUSTERED ([GroupId] ASC)
)
GO