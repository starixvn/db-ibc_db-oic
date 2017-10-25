USE [bodb_OIC]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OIC_AmendmentNotificationSel]
	@MessageId	INT
AS
/*
	Created by: Scofield
	Date: 20171017 [#84004]
	DB: DBOIC.bodb_OIC
 */
BEGIN
	SET NOCOUNT ON
		
	SELECT MessageId, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, Status, ReceivedDate
	FROM dbo.AmendmentMessage WITH(NOLOCK)
	WHERE MessageID = @MessageId
			
	SELECT TicketId, MessageId, LicenseeName AS SiteName, DataFilePath
	FROM dbo.AmendmentTicket WITH(NOLOCK)
	WHERE MessageID = @MessageId
END
GO

GO
GRANT EXECUTE ON [dbo].OIC_AmendmentNotificationSel TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].OIC_AmendmentNotificationSel TO [vnteam] AS [dbo]