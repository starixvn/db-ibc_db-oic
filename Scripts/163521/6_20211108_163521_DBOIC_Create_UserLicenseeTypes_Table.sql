/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/

CREATE TABLE [dbo].[UserLicenseeTypes](
	[UserId] [int] NOT NULL,
	[TypeId]  [tinyint] NOT NULL,
	[Email]	 [varchar](50) NULL,
 CONSTRAINT [PK_UserLicenseeTypes] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[TypeId] ASC
	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO





