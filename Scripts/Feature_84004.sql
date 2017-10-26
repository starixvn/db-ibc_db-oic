USE [bodb_OIC]
GO

CREATE TABLE [dbo].[AmendmentMessageUser](
	[TicketID] [int] NOT NULL,
	[UserID] [int] NOT NULL,
	[LicenseeName] [nvarchar](300) NOT NULL,
	[IsRead] [bit] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TicketIdUserIdLicenseeName] PRIMARY KEY CLUSTERED 
(
	[TicketID] ASC,
	[UserID] ASC,
	[LicenseeName] ASC
))
GO

CREATE TABLE [dbo].[AmendmentMessage](
	[MessageID] [int] IDENTITY(1,1) NOT NULL,
	[ContentEn] [nvarchar](max) NULL,
	[ContentCh] [nvarchar](max) NULL,
	[ContentCs] [nvarchar](max) NULL,
	[SubjectEn] [nvarchar](300) NOT NULL,
	[SubjectCh] [nvarchar](300) NULL,
	[SubjectCs] [nvarchar](300) NULL,
	[Status] [smallint] NOT NULL,
	[ReceivedDate] [datetime] NOT NULL,
	[UpdatedDate] [datetime] NULL,
	[UpdatedBy] [int] NULL,
	[IsTest] [bit] NOT NULL,
 CONSTRAINT [PK_AmendmentMessage] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC
))
GO

CREATE TABLE [dbo].[AmendmentTicket](
	[TicketID] [int] IDENTITY(1,1) NOT NULL,
	[LicenseeName] [nvarchar](300) NOT NULL,
	[DataFilePath] [nvarchar](300) NOT NULL,
	[MessageID] [int] NOT NULL,
 CONSTRAINT [PK_AmendmentTicket] PRIMARY KEY CLUSTERED 
(
	[TicketID] ASC
))
GO

ALTER TABLE dbo.UserMessage ADD LicenseeName VARCHAR(300) NOT NULL DEFAULT '';
ALTER TABLE dbo.UserMessage DROP CONSTRAINT PK_UserMessage;
ALTER TABLE dbo.UserMessage ADD CONSTRAINT PK_UserMessage PRIMARY KEY (MessageId, UserId, LicenseeName);
GO

ALTER TABLE dbo.AmendmentMessageUser ADD CONSTRAINT PK_AmendmentMessageUser PRIMARY KEY (TicketID, UserId, LicenseeName);
GO

INSERT INTO dbo.LogAction( LogActionId, LogActionTypeId, SPName, ActionNameEn, Enable, "Order" )
VALUES ( 4005, 4, 'OIC_AmendmentResultIns', 'Insert Result Amendment Notification', 1, 4006 ),
	( 4006, 4, 'OIC_AmendmentNotificationUpd', 'Update Result Amendment Notification', 1, 4007 ),
	( 4007, 4, 'OIC_AmendmentMessageUserIns', 'Insert Amendment User', 1, 4008 ),
	( 4008, 4, 'OIC_APIUserMessageIns', 'API Insert User Message', 1, 4009 );
GO

INSERT INTO dbo.MessageError(MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (40002, 4, 'Fail to add new amendment result'),
	(40003, 4, 'Fail to update amendment result'),
	(40004, 4, 'Fail to insert amendment user'),
	(40005, 4, 'Fail to insert user message from api');
GO
	
UPDATE dbo.LogAction
SET Enable = 0
WHERE LogActionId IN(4000, 4001, 4002, 4003, 4004);
GO




