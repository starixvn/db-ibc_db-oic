/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

CREATE PROCEDURE [dbo].[OIC_API_AmendmentMessageListSel]
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@UserName			VARCHAR(100),
	@LicenseeName		VARCHAR(100),
	@IsOnlyUnread		BIT				= 0,	
	@PageSize			INT				= 10,
	@PageIndex			INT				= 0,
	@TotalRecords		INT				= 0	OUTPUT
AS
/*
	Created by: Scofield
	Date: 20171023 [#84004]
	DB: DBOIC.bodb_OIC
	
	Revisions:	
		- 20171030@Scofield: #84004 - Implement Deliver notification to licensee backend

	Param's Explanation:		
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT,
			@RowEnd	INT,
			@ActiveStatus INT = 1,
			@AmendmentMessageType INT = 2
	
	SELECT	@PageIndex   = @PageIndex, 
			@RowStart	 = @PageSize * @PageIndex + 1,
			@RowEnd	     = @RowStart + @PageSize - 1
	SELECT @ToDate = DATEADD(dd, DATEDIFF(dd, 0, @ToDate), 0) + CAST('23:59:59.999' AS Time)
			
	DECLARE @messageResult TABLE (
		MessageId 		INT, 
		SubjectEn 		NVARCHAR(300), 
		SubjectCh 		NVARCHAR(300), 
		SubjectCs 		NVARCHAR(300), 
		ContentEn 		NVARCHAR(MAX), 
		ContentCh 		NVARCHAR(MAX), 
		ContentCs 		NVARCHAR(MAX), 
		ReceivedDate	DateTime,
		IsRead			BIT,
		DataFilePath	VARCHAR(MAX),
		TotalRecords	INT)	
	 
	;WITH tempMessage AS
	(SELECT ROW_NUMBER() OVER(ORDER BY am.ReceivedDate DESC) AS RowNumber,
		am.MessageID, am.SubjectEn, am.SubjectCh, am.SubjectCs, am.ContentEn, am.ContentCh, am.ContentCs, am.ReceivedDate, at.DataFilePath, 
		ISNULL(mu.IsRead, 0) AS IsRead
	FROM dbo.AmendmentMessage am WITH(NOLOCK)
	INNER JOIN dbo.AmendmentTicket at WITH(NOLOCK) ON am.MessageID = at.MessageID
	LEFT JOIN dbo.ExternalMessageUser mu ON am.MessageID = mu.MessageID AND mu.MessageType = @AmendmentMessageType 
		AND mu.UserName = @UserName AND mu.LicenseeName = @LicenseeName
	WHERE am.Status = @ActiveStatus AND (am.ReceivedDate BETWEEN @FromDate AND @ToDate) AND am.IsTest = 0
		AND at.LicenseeName = @LicenseeName
		AND (@IsOnlyUnread = 0 OR mu.IsRead IS NULL OR mu.IsRead = 0)
	)
		
	INSERT INTO @messageResult(MessageID, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, ReceivedDate, DataFilePath, IsRead, TotalRecords)
	SELECT tmp.MessageID, tmp.SubjectEn, tmp.SubjectCh, tmp.SubjectCs, tmp.ContentEn, tmp.ContentCh, tmp.ContentCs, tmp.ReceivedDate, tmp.DataFilePath, tmp.IsRead,
		(SELECT MAX(RowNumber) FROM tempMessage) AS TotalRecords
	FROM tempMessage tmp
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.ReceivedDate DESC
	
	-- Select Results
	SELECT MessageID, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, ReceivedDate AS "Date", DataFilePath, IsRead
	FROM @messageResult
	
	SET @TotalRecords = (SELECT TOP 1 TotalRecords FROM @messageResult)
END
GO
