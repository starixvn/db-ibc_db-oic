/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/****** Object:  Table [dbo].[ProductType]    Script Date: 20/09/2021 4:52:23 CH ******/
/*
	Created: 20210916@Alex
	DB: DBOIC.bodb_OIC
	Task: Support Product Type on Client Product #161508
*/

CREATE TABLE [dbo].[ProductType](
	[Id] [tinyint] NOT NULL,
	[ProductTypeName] [nvarchar](50) NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]

GO


