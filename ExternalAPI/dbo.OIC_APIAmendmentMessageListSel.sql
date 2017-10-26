USE [bodb_OIC]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OIC_APIAmendmentMessageListSel]
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@UserId				INT,
	@LicenseeName		VARCHAR(300),
	@IsOnlyUnread		BIT				= 0,	
	@PageSize			INT				= 10,
	@PageIndex			INT				= 0,
	@TotalRecords		INT				= 0	OUTPUT
AS
/*
	Created by: Scofield
	Date: 20171023 [#84004]
	DB: DBOIC.bodb_OIC

	Param's Explanation:		
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT,
			@RowEnd	INT,
			@ActiveStatus INT = 2
	
	SELECT	@PageIndex   = @PageIndex, 
			@RowStart	 = @PageSize * @PageIndex + 1,
			@RowEnd	     = @RowStart + @PageSize - 1
			
	DECLARE @messageResult TABLE (
		MessageId 		INT, 
		TicketID 		INT, 
		SubjectEn 		VARCHAR(300), 
		SubjectCh 		VARCHAR(300), 
		SubjectCs 		VARCHAR(300), 
		ContentEn 		VARCHAR(MAX), 
		ContentCh 		VARCHAR(MAX), 
		ContentCs 		VARCHAR(MAX), 
		Date			DateTime,
		IsRead			BIT,
		DataFilePath	VARCHAR(MAX),
		TotalRecords	INT)	
	 
	;WITH tempMessage AS
	(SELECT ROW_NUMBER() OVER(ORDER BY am.ReceivedDate DESC) AS RowNumber,
		am.MessageID, am.SubjectEn, am.SubjectCh, am.SubjectCs, am.ContentEn, am.ContentCh, am.ContentCs, am.ReceivedDate, at.TicketID, at.DataFilePath, 
		ISNULL(mu.IsRead, 0) AS IsRead
	FROM dbo.AmendmentMessage am WITH(NOLOCK)
	INNER JOIN dbo.AmendmentTicket at WITH(NOLOCK) ON am.MessageID = at.MessageID
	LEFT JOIN dbo.AmendmentMessageUser mu ON at.TicketID = mu.TicketID AND mu.UserID = @UserId AND mu.LicenseeName = @LicenseeName
	WHERE am.Status = @ActiveStatus AND (am.ReceivedDate BETWEEN @FromDate AND @ToDate) AND am.IsTest = 0
		AND LOWER(RTRIM(LTRIM(at.LicenseeName))) = LOWER(RTRIM(LTRIM(@LicenseeName)))
		AND (@IsOnlyUnread = 0 OR mu.TicketID IS NULL)
	)
		
	INSERT INTO @messageResult(MessageID, TicketID, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, Date, DataFilePath, IsRead, TotalRecords)
	SELECT tmp.MessageID, tmp.TicketID, tmp.SubjectEn, tmp.SubjectCh, tmp.SubjectCs, tmp.ContentEn, tmp.ContentCh, tmp.ContentCs, tmp.ReceivedDate AS Date, tmp.DataFilePath, tmp.IsRead,
		(SELECT MAX(RowNumber) FROM tempMessage) AS TotalRecords
	FROM tempMessage tmp
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.ReceivedDate DESC
	
	-- Select Results
	SELECT MessageID, TicketID, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, Date, DataFilePath, IsRead
	FROM @messageResult
	
	SET @TotalRecords = (SELECT TOP 1 TotalRecords FROM @messageResult)
END
GO

GRANT EXECUTE ON [dbo].[OIC_APIAmendmentMessageListSel] TO [bodbAdminNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[OIC_APIAmendmentMessageListSel] TO [vnteam] AS [dbo]
GO