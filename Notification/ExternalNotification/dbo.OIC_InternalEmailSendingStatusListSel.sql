/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_InternalEmailSendingStatusListSel]
	@FromDate			DATETIME,
	@ToDate				DATETIME, 
	@SelectedStatuses	VARCHAR(20)		= 'All',		
	@SelectedSiteNames	VARCHAR(MAX)	= 'All',
	@SelectedRecipients	VARCHAR(MAX)	= 'All',
	@UserId				INT,
	
	@PageSize			INT				= 10,
	@PageIndex			INT				= 0,
	@TotalRecords		INT				= 0	OUTPUT
AS
/*
	Created by: Kai
	Date: 2022-06-15
	Task: Launched emails of a new licensee [RedmineID: #168502]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20220615@Kai: Launched emails of a new licensee [RedmineID: #168502]
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT,
			@RowEnd	INT
			
	DECLARE @tblStatus TABLE ([Status] INT)		
	DECLARE @tblLicensees TABLE (Licensee VARCHAR(50))
	DECLARE @tblRecipient TABLE (Recipient VARCHAR(50))
	
	CREATE TABLE #tblMail (
		MailSiteNameId		INT PRIMARY KEY
	)
	
	SELECT	@PageIndex   = @PageIndex, 
			@RowStart	 = @PageSize * @PageIndex + 1,
			@RowEnd	     = @RowStart + @PageSize - 1
	
	IF @SelectedStatuses <> 'All'
	BEGIN
		SET @SelectedStatuses = REPLACE(@SelectedStatuses, '8', '2,5');
		SET @SelectedStatuses = REPLACE(@SelectedStatuses, '9', '1,3');		
		
		INSERT INTO @tblStatus ([Status])
		SELECT	val 
		FROM	dbo.strSplit(@SelectedStatuses, ',')
	END	
	
	IF @SelectedSiteNames <> 'All'
	BEGIN
		INSERT INTO @tblLicensees (Licensee)
		SELECT	val 
		FROM	dbo.strSplit(@SelectedSiteNames, ',')
	END	
	
	IF @SelectedRecipients <> 'All'
	BEGIN
		INSERT INTO @tblRecipient (Recipient)
		SELECT	val 
		FROM	dbo.strSplit(@SelectedRecipients, ',')
	END		
	
	INSERT INTO #tblMail (MailSiteNameId)
	SELECT	msn.Id
	FROM	MailRecordSiteName msn WITH(NOLOCK)
	WHERE	msn.CreateTime BETWEEN @FromDate AND @ToDate
			AND (msn.LicenseeId IN (SELECT Licensee FROM @tblLicensees)
				OR @SelectedSiteNames = 'ALL')
			AND (msn.ToRecipientId IN (SELECT Recipient FROM @tblRecipient)
				OR @SelectedRecipients = 'ALL')
			AND (msn.[Status] IN (SELECT [Status] FROM @tblStatus)
				OR @SelectedStatuses = 'ALL')
			AND (msn.LicenseeId != 0)
	
	SELECT MailSiteNameId
			,Sender
			,Recipient
			,Content
			,[Subject]
			,[To]
			,[Cc]
			,[Bcc]
			,[Status]
			,CreateTime
			,LatestSendTime
			,CountSend
	FROM
	(
	SELECT	ROW_NUMBER() OVER(ORDER BY msn.Id DESC ,msn.CreateTime DESC) AS RowNumber
			,msn.Id AS MailSiteNameId
			,ui.DisplayName AS Sender
			,msn.ToRecipientId AS Recipient
			,mr.Content AS Content
			,msn.[Subject]
			,msn.[To]
			,msn.[Cc]
			,msn.[Bcc]
			,[Status] = CASE WHEN msn.[Status] IN (2,5) THEN 8 WHEN msn.[Status] IN (1,3) THEN 9 ELSE msn.[Status] END
			,msn.CreateTime
			,LatestSendTime = CASE WHEN msn.[Status] = 4 THEN msn.LatestSendTime ELSE NULL END
			,msn.CountSend
	FROM	MailRecordSiteName msn WITH(NOLOCK) 
			INNER JOIN UserInfo ui WITH(NOLOCK)
				ON msn.FromUserId = ui.UserId
			INNER JOIN MailRecord mr WITH(NOLOCK)
				ON msn.MailRecordId = mr.Id
			INNER JOIN #tblMail t
				ON msn.Id = t.MailSiteNameId
	) AS Result
	WHERE RowNumber BETWEEN @RowStart AND @RowEnd
	
	SELECT @TotalRecords = COUNT(*) FROM #tblMail
END
GO
