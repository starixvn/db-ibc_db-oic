/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AmendmentNotificationListSel]
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@AmendmentStatus	INT	 			=  -1,
	@SelectedLanguage	VARCHAR(10)		= 'En',		
	@SelectedSiteNames	VARCHAR(MAX)	= 'All',
	@UserId				INT,
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
		- 20180123@Scofield: #89901 - Enhance Result Notification function : sorting records, update @SelectedSiteNames

	Param's Explanation:
		@@AmendmentStatus: -1: All, 0: New, 1: Active, 2: Inactive		
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT,
			@RowEnd	INT
	DECLARE @tblTicketBySites TABLE (MessageID INT)
	
	SELECT	@PageIndex   = @PageIndex, 
			@RowStart	 = @PageSize * @PageIndex + 1,
			@RowEnd	     = @RowStart + @PageSize - 1
			
	DECLARE @messageResult TABLE (
		MessageId 	INT, 
		Subject 		NVARCHAR(MAX), 
		Content 		NVARCHAR(MAX), 
		Status		INT,
		EventDate	DateTime,
		PublishedDate	DateTime,
		TotalRecords	INT)	
	
	IF @SelectedSiteNames <> 'All'
	BEGIN
		INSERT INTO @tblTicketBySites(MessageID)
		SELECT DISTINCT MessageID
		FROM dbo.AmendmentTicket
		WHERE LicenseeName IN (SELECT val FROM dbo.strSplit(@SelectedSiteNames, ','))			
	END
		
	;WITH tempMessage AS
	(SELECT ROW_NUMBER() OVER(ORDER BY EventDate DESC, MessageID DESC) AS RowNumber, MessageId, Status, EventDate, PublishedDate,
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
		AND (EventDate BETWEEN @FromDate AND @ToDate)
		AND IsTest = 0
		AND (@SelectedSiteNames = 'All' OR (MessageID IN (SELECT MessageID FROM @tblTicketBySites)))
	)
	
	INSERT INTO @messageResult (MessageId, Subject, Content, Status, EventDate, PublishedDate, TotalRecords)		
	SELECT tmp.MessageId, tmp.Subject, tmp.Content, tmp.Status, tmp.EventDate, tmp.PublishedDate,
		(SELECT MAX(RowNumber) FROM tempMessage) AS TotalRecords
	FROM tempMessage tmp		
	WHERE tmp.RowNumber BETWEEN @RowStart AND @RowEnd
	ORDER BY tmp.EventDate DESC
	
	-- Select Results
	SELECT MessageId, Subject, Content, Status, EventDate, PublishedDate
	FROM @messageResult
	
	SELECT TicketId, MessageId, LicenseeName AS SiteName, DataFilePath
	FROM dbo.AmendmentTicket WITH(NOLOCK)
	WHERE MessageId IN (SELECT MessageId FROM @messageResult)		
	
	SET @TotalRecords = (SELECT TOP 1 TotalRecords FROM @messageResult)
END
GO