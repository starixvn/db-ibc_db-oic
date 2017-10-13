USE [bodb_OIC]
GO

CREATE TABLE [dbo].[AmendmentTicket](
	[TicketID] [int] IDENTITY(1,1) NOT NULL,
	[LicenseeName] [nvarchar](300) NOT NULL,
	[DataFilePath] [nvarchar](300) NOT NULL,
	[MessageID] [int] NOT NULL,
CONSTRAINT [PK_AmendmentTicket] PRIMARY KEY CLUSTERED ([TicketID] ASC)
)
GO


