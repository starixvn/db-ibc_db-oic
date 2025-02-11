/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_API_ExternalNotificationListSel]
	@MessageTypeId		INT			= 0,
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@UserName			NVARCHAR(50),
	@LicenseeName		NVARCHAR(50),
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
		- 20250211@Cody: Fix the data types datetime and time are incompatible - [RedmineId: #211934]

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
			@ActiveStatus INT = 2,
			@GeneralMessageType INT = 1
	
	SELECT	@PageIndex   = @PageIndex, 
			@RowStart	 = @PageSize * @PageIndex + 1,
			@RowEnd	     = @RowStart + @PageSize - 1
	SELECT @ToDate = DATEADD(dd, DATEDIFF(dd, 0, @ToDate), 0) + CAST('23:59:59.999' AS DateTime)
			
	DECLARE @messageResult TABLE (
		MessageId 		INT, 
		MessageTypeId	INT,
		SubjectEn 		NVARCHAR(300), 
		SubjectCh 		NVARCHAR(300), 
		SubjectCs 		NVARCHAR(300), 
		ContentEn 		NVARCHAR(MAX), 
		ContentCh 		NVARCHAR(MAX), 
		ContentCs 		NVARCHAR(MAX), 
		CreateTime		DateTime,
		IsRead			BIT,
		TotalRecords	INT)			
	
	;WITH tempMessage AS
	(SELECT ROW_NUMBER() OVER(ORDER BY m.CreateTime DESC) AS RowNumber,
		m.MessageId, m.SubjectEn, m.SubjectCh, m.SubjectCs, m.ContentEn, m.ContentCh, m.ContentCs, m.MessageTypeId, m.CreateTime, ISNULL(um.IsRead, 0) AS IsRead
	FROM dbo.Message m
	INNER JOIN dbo.LicenseeMessage lm ON m.MessageId = lm.MessageId
	INNER JOIN dbo.Licensee l ON lm.LicenseeId = l.LicenseeId
	LEFT JOIN dbo.ExternalMessageUser um ON um.MessageId = m.MessageId AND um.MessageType = @GeneralMessageType 
		AND um.UserName = @UserName AND um.LicenseeName = @LicenseeName
	WHERE (@MessageTypeId = 0 OR m.MessageTypeId =@MessageTypeId)
		AND m.MessageTypeId IN (40, 41, 42, 43, 44)
		AND m.CreateTime BETWEEN @FromDate AND @ToDate
		AND l.LicenseeName = @LicenseeName
		AND (@IsOnlyUnread = 0 OR um.IsRead IS NULL OR um.IsRead = 0)
	)
	
	INSERT INTO @messageResult(MessageID, MessageTypeId, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, CreateTime, IsRead, TotalRecords)
	SELECT tmp.MessageID, tmp.MessageTypeId, tmp.SubjectEn, tmp.SubjectCh, tmp.SubjectCs, tmp.ContentEn, tmp.ContentCh, tmp.ContentCs, tmp.CreateTime, tmp.IsRead, 
		(SELECT MAX(RowNumber) FROM tempMessage) AS TotalRecords
	FROM tempMessage tmp
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.CreateTime DESC
	
	-- Select Results
	SELECT MessageID, MessageTypeId, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, CreateTime AS "Date", IsRead
	FROM @messageResult
	
	SET @TotalRecords = (SELECT TOP 1 TotalRecords FROM @messageResult)
END
GO
