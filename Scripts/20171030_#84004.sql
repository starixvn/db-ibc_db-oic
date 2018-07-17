USE [bodb_OIC]
GO
/*
	Creator: Scofield
	Date: 2017-12-05
	DB: DBOIC.bodb_OIC
	Task: Create tables for Result Amendment, and update LogAction, MessageError [#84004]
*/
CREATE TABLE [dbo].[ExternalMessageUser](
	[MessageID] [int] NOT NULL,
	[MessageType] [int] NOT NULL,
	[UserName] [nvarchar](100) NOT NULL,
	[LicenseeName] [nvarchar](100) NOT NULL,
	[IsRead] [bit] NOT NULL,
	[UpdatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ExternalMessageUser] PRIMARY KEY CLUSTERED 
(
	[MessageID] ASC,
	[MessageType] ASC,
	[UserName] ASC,
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

INSERT INTO dbo.LogAction( LogActionId, LogActionTypeId, SPName, ActionNameEn, Enable, "Order" )
VALUES ( 4005, 4, 'OIC_API_AmendmentMessageIns', 'Insert Result Amendment Notification', 0, 4006 ),
	( 4006, 4, 'OIC_AmendmentNotificationUpd', 'Update Result Amendment / Recalculation', 1, 4007 ),
	( 4007, 4, 'OIC_API_ExternalMessageUserIns', 'Insert Amendment User', 0, 4008 ),
	( 4009, 4, 'OIC_ReminderUpd', 'Update Reminder', 1, 4010 );
GO

INSERT INTO dbo.MessageError(MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (40002, 4, 'Fail to add new amendment result'),
	(40003, 4, 'Fail to update amendment result'),
	(40004, 4, 'Fail to insert external message user');
GO
	
UPDATE dbo.LogAction
SET Enable = 0
WHERE LogActionId IN(4000, 4001, 4002, 4003, 4004);
GO




