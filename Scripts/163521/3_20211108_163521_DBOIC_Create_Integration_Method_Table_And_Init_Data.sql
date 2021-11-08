/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/

CREATE TABLE [dbo].[IntegrationMethod](
	[IntegrationMethodId] [tinyint] NOT NULL,
	[IntegrationMethodName] [nvarchar](50) NULL,
 CONSTRAINT [PK_IntegrationMethod] PRIMARY KEY CLUSTERED 
(
	[IntegrationMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO

INSERT INTO [bodb_OIC].[dbo].[IntegrationMethod]
           ([IntegrationMethodId], [IntegrationMethodName])
     VALUES
			(1,'API'),
			(2,'Athena'),
			(3,'Single Wallet'),
			(4,'Odds Feed'),
			(5,'Direct Odds')
GO




