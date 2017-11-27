/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AmendmentNotificationListSel]
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@AmendmentStatus	INT	 			=  -1,
	@SelectedLanguage	VARCHAR(10)		= 'En',		
	@SelectedSiteIds	VARCHAR(MAX)	= 'All',
	@PageSize			INT				= 10,
	@PageIndex			INT				= 0,
	@TotalRecords		INT				= 0	OUTPUT
AS
/*
	Created by: Scofield
	Date: 20171017 [#84004]
	DB: DBOIC.bodb_OIC
	
	Revisions:	
		- 20171030@Scofield: #84004 - Implement Deliver notification to licensee backend

	Param's Explanation:
		@@AmendmentStatus: -1: All, 0: New, 1: Active, 2: Inactive		
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT,
			@RowEnd	INT
	DECLARE @tblTicketBySites TABLE (TicketID INT, MessageID INT)
	
	SELECT	@PageIndex   = @PageIndex, 
			@RowStart	 = @PageSize * @PageIndex + 1,
			@RowEnd	     = @RowStart + @PageSize - 1
			
	DECLARE @messageResult TABLE (
		MessageId 	INT, 
		Subject 		VARCHAR(MAX), 
		Content 		VARCHAR(MAX), 
		Status		INT,
		ReceivedDate	DateTime,
		TotalRecords	INT)
		
	IF @SelectedSiteIds <> 'All'
	BEGIN
		INSERT INTO @tblTicketBySites(TicketID, MessageID)
		SELECT TicketId, MessageID
		FROM dbo.AmendmentTicket
		WHERE LOWER(RTRIM(LTRIM(LicenseeName))) IN (
			SELECT LOWER(RTRIM(LTRIM(LicenseeName))) 
			FROM dbo.Licensee 
			WHERE LicenseeId IN (SELECT	val FROM dbo.strSplit(@SelectedSiteIds, ',')))
	END		
		
	;WITH tempMessage AS
	(SELECT ROW_NUMBER() OVER(ORDER BY ReceivedDate DESC) AS RowNumber, MessageId, Status, ReceivedDate,
		CASE WHEN @SelectedLanguage = 'Ch' AND ISNULL(SubjectCh, '') <> '' THEN SubjectCh
				WHEN @SelectedLanguage = 'Cs' AND ISNULL(SubjectCs, '') <> '' THEN SubjectCs
				ELSE SubjectEn 
				END AS Subject,
		CASE WHEN @SelectedLanguage = 'Ch' AND ISNULL(ContentCh, '') <> '' THEN ContentCh
			WHEN @SelectedLanguage = 'Cs' AND ISNULL(ContentCs, '') <> '' THEN ContentCs
			ELSE ContentEn
			END AS Content	
	FROM dbo.AmendmentMessage WITH(NOLOCK)
	WHERE (@AmendmentStatus = -1 OR Status = @AmendmentStatus) 
		AND (ReceivedDate BETWEEN @FromDate AND @ToDate)
		AND IsTest = 0
		AND (@SelectedSiteIds = 'All' OR MessageID IN (SELECT DISTINCT MessageID FROM @tblTicketBySites))
	)
	
	INSERT INTO @messageResult (MessageId, Subject, Content, Status, ReceivedDate, TotalRecords)		
	SELECT tmp.MessageId, tmp.Subject, tmp.Content, tmp.Status, tmp.ReceivedDate,
		(SELECT MAX(RowNumber) FROM tempMessage) AS TotalRecords
	FROM tempMessage tmp		
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.ReceivedDate DESC
	
	-- Select Results
	SELECT MessageId, Subject, Content, Status, ReceivedDate
	FROM @messageResult
	
	SELECT TicketId, MessageId, LicenseeName AS SiteName, DataFilePath
	FROM dbo.AmendmentTicket WITH(NOLOCK)
	WHERE MessageId IN (SELECT MessageId FROM @messageResult)
		AND (@SelectedSiteIds = 'All' OR TicketId IN (SELECT TicketID FROM @tblTicketBySites))
	
	SET @TotalRecords = (SELECT TOP 1 TotalRecords FROM @messageResult)
END
GO