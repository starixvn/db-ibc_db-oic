/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/

CREATE TABLE [dbo].[LicenseeIntegrationMethod](
	[LicenseeId] [int] NOT NULL,
	[IntegrationMethodId] [tinyint] NOT NULL,
 CONSTRAINT [PK_LicenseeIntegrationMethod] PRIMARY KEY CLUSTERED 
(
	[LicenseeId] ASC,
	[IntegrationMethodId] ASC
	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO




