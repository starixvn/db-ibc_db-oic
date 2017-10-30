/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

CREATE PROCEDURE [dbo].[OIC_APIExternalNotificationListSel]
	@MessageTypeId		INT			= 0,
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
	Date: 20171025
	Task: [Redmine:#84004]
	DB: DBOIC.bodb_OIC
	
	Revisions:	
		- 20171030@Scofield: #84004 - Implement Deliver notification to licensee backend

	Param's Explanation:
		@MessageTypeId:	 
			0 :"All"
			40:"Public",
			41:"Special",
			42:"Personal",
			43:"Match delay - New",
			44:"Match delay - Done"
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
		MessageTypeId	INT,
		SubjectEn 		VARCHAR(300), 
		SubjectCh 		VARCHAR(300), 
		SubjectCs 		VARCHAR(300), 
		ContentEn 		VARCHAR(MAX), 
		ContentCh 		VARCHAR(MAX), 
		ContentCs 		VARCHAR(MAX), 
		Date			DateTime,
		IsRead			BIT,
		TotalRecords	INT)			
	
	;WITH tempMessage AS
	(SELECT ROW_NUMBER() OVER(ORDER BY m.CreateTime DESC) AS RowNumber,
		m.MessageId, m.SubjectEn, m.SubjectCh, m.SubjectCs, m.ContentEn, m.ContentCh, m.ContentCs, m.MessageTypeId, m.CreateTime, ISNULL(um.IsRead, 0) AS IsRead
	FROM dbo.Message m
	INNER JOIN dbo.LicenseeMessage lm ON m.MessageId = lm.MessageId
	INNER JOIN dbo.Licensee l ON lm.LicenseeId = l.LicenseeId
	LEFT JOIN dbo.UserMessage um ON um.MessageId = m.MessageId AND um.UserId = @UserId AND um.LicenseeName = @LicenseeName
	WHERE (@MessageTypeId = 0 OR m.MessageTypeId =@MessageTypeId)
		AND m.CreateTime BETWEEN @FromDate AND @ToDate
		AND LOWER(RTRIM(LTRIM(l.LicenseeName))) = LOWER(RTRIM(LTRIM(@LicenseeName)))
		AND (@IsOnlyUnread = 0 OR um.MessageId IS NULL)
	)
	
	INSERT INTO @messageResult(MessageID, MessageTypeId, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, Date, IsRead, TotalRecords)
	SELECT tmp.MessageID, tmp.MessageTypeId, tmp.SubjectEn, tmp.SubjectCh, tmp.SubjectCs, tmp.ContentEn, tmp.ContentCh, tmp.ContentCs, tmp.CreateTime AS Date, tmp.IsRead, 
		(SELECT MAX(RowNumber) FROM tempMessage) AS TotalRecords
	FROM tempMessage tmp
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.CreateTime DESC
	
	-- Select Results
	SELECT MessageID, MessageTypeId, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, Date, IsRead
	FROM @messageResult
	
	SET @TotalRecords = (SELECT TOP 1 TotalRecords FROM @messageResult)
END
GO
