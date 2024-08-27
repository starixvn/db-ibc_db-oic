/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240826@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

CREATE TABLE [dbo].[AutoMailType](
	[TypeId] [TINYINT] NOT NULL,
	[TypeName] [NVARCHAR](50) NOT NULL,
	CONSTRAINT [PK__AutoMailType] PRIMARY KEY CLUSTERED ([TypeId] ASC)
)
GO