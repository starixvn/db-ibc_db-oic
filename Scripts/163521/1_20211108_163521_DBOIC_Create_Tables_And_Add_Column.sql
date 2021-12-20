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

CREATE TABLE [dbo].[Platform](
	[PlatformId] [tinyint] NOT NULL,
	[PlatformName] [nvarchar](50) NULL,
 CONSTRAINT [PK_Platform] PRIMARY KEY CLUSTERED 
(
	[PlatformId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO

CREATE TABLE [dbo].[IntegrationMethod](
	[IntegrationMethodId] [tinyint] NOT NULL,
	[IntegrationMethodName] [nvarchar](50) NULL,
 CONSTRAINT [PK_IntegrationMethod] PRIMARY KEY CLUSTERED 
(
	[IntegrationMethodId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO

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

CREATE TABLE [dbo].[MessageLicenseeType](
	[TypeId] [tinyint] NOT NULL,
	[MessageId] [int] NOT NULL,
	[PositionId] [tinyint] NOT NULL,
	CONSTRAINT [PK_MessageLicenseeType] PRIMARY KEY CLUSTERED 
(
	[TypeId] ASC,
	[MessageId] ASC,
	[PositionId] ASC
	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [bodb_OIC_Data]
) ON [bodb_OIC_Data]
GO

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

ALTER TABLE [dbo].[Licensee]
ADD [PlatformId] TINYINT NULL
GO

ALTER TABLE [dbo].[Licensee]
ADD [TypeId] TINYINT NULL
GO 






