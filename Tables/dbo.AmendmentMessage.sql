USE [bodb_OIC]
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
 CONSTRAINT [PK_AmendmentMessage] PRIMARY KEY CLUSTERED ([MessageID] ASC)
 )
GO


