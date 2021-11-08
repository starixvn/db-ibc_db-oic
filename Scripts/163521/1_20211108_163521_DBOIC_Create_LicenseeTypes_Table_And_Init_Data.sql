/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20211108@Alex
	DB: DBOIC.bodb_OIC
	Task:  #163521
*/

CREATE TABLE [dbo].[LicenseeTypes](
	[TypeId] [tinyint] NOT NULL,
	[TypeName] [nvarchar](50) NULL,
 CONSTRAINT [PK_LicenseeTypes] PRIMARY KEY CLUSTERED 
(
	[TypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO

INSERT INTO [bodb_OIC].[dbo].[LicenseeTypes]
           ([TypeId], [TypeName])
     VALUES
			(1,'Boping'),
			(2,'Oneworks'),
			(3,'Zelianta')			
GO




