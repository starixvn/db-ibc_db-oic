USE [bodb_OIC]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OIC_AmendmentNotificationListSel]
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@AmendmentStatus	INT	 			= 'all',
	@SelectedLanguage	VARCHAR(10)		= 'En',		
	@PageSize			INT				= 10,
	@PageIndex			INT				= 0,
	@TotalRecords		INT				= 0		OUTPUT
AS
/*
	Created by: Scofield
	Date: 20171017 [#84004]
	DB: DBOIC.bodb_OIC
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT,
			@RowEnd	INT
	
	SELECT	@PageIndex	= @PageIndex, 
			@RowStart	= @PageSize * @PageIndex + 1,
			@RowEnd	= @RowStart + @PageSize - 1
			
	DECLARE @tempMessage TABLE (
		RowNumber 		INT,
		MessageId 		INT, 
		Subject 		VARCHAR(MAX), 
		Content 		VARCHAR(MAX), 
		Status			INT,
		ReceivedDate	DateTime)
		
	DECLARE @messageResult TABLE (
		MessageId 		INT, 
		Subject 		VARCHAR(MAX), 
		Content 		VARCHAR(MAX), 
		Status			INT,
		ReceivedDate	DateTime)
		
	DECLARE @ticketResult TABLE (
		TicketId 		INT, 
		MessageId 		INT, 
		SiteName 	VARCHAR(MAX), 
		DataFilePath 	VARCHAR(MAX))
			
	INSERT INTO @tempMessage(RowNumber, MessageId, Status, ReceivedDate, Subject, Content)
	SELECT ROW_NUMBER() OVER(ORDER BY ReceivedDate DESC) AS RowNumber, MessageId, Status, ReceivedDate,
		CASE WHEN @SelectedLanguage = 'Ch' AND ISNULL(SubjectCh, '') <> '' THEN SubjectCh
				WHEN @SelectedLanguage = 'Cs' AND ISNULL(SubjectCs, '') <> '' THEN SubjectCs
				ELSE SubjectEn 
				END AS Subject,
		CASE WHEN @SelectedLanguage = 'Ch' AND ISNULL(ContentCh, '') <> '' THEN ContentCh
			WHEN @SelectedLanguage = 'Cs' AND ISNULL(ContentCs, '') <> '' THEN ContentCs
			ELSE ContentEn
			END AS Content	
	FROM dbo.AmendmentMessage
	WHERE (@AmendmentStatus = -1 OR Status = @AmendmentStatus) 
		AND (ReceivedDate BETWEEN @FromDate AND @ToDate)
		AND IsTest = 0	
	
	INSERT INTO @messageResult (MessageId, Subject, Content, Status, ReceivedDate)		
	SELECT tmp.MessageId, tmp.Subject, tmp.Content, tmp.Status, tmp.ReceivedDate
	FROM @tempMessage tmp		
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.ReceivedDate DESC
	
	INSERT INTO @ticketResult(TicketId, MessageId, SiteName, DataFilePath)
	SELECT TicketId, MessageId, LicenseeName AS SiteName, DataFilePath
	FROM dbo.AmendmentTicket
	WHERE MessageId IN (SELECT MessageId FROM @messageResult)
	
	SELECT * FROM @messageResult
	SELECT * FROM @ticketResult
	SET @TotalRecords = (SELECT MAX(RowNumber) FROM @tempMessage)
END
