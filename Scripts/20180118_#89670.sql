USE [bodb_OIC]
GO

ALTER TABLE dbo.AmendmentMessage ADD EventDate Datetime NULL;

UPDATE AmendmentMessage
SET EventDate = '2018-01-17 00:00:00.000'

ALTER TABLE dbo.AmendmentMessage ALTER COLUMN EventDate Datetime NOT NULL;

ALTER TABLE [dbo].[ExternalMessageUser] DROP  CONSTRAINT [PK_ExternalMessageUser];

ALTER TABLE dbo.AmendmentTicket
ALTER COLUMN LicenseeName NVARCHAR(50) NOT NULL;

ALTER TABLE dbo.ExternalMessageUser
ALTER COLUMN LicenseeName NVARCHAR(50) NOT NULL;

ALTER TABLE dbo.ExternalMessageUser
ALTER COLUMN UserName NVARCHAR(50) NOT NULL;

ALTER TABLE [dbo].[ExternalMessageUser] ADD  CONSTRAINT [PK_ExternalMessageUser] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC,
	[MessageType] ASC,
	[UserName] ASC,
	[LicenseeName] ASC
);