USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_ExternalNotificationListSel]    Script Date: 09/18/2015 15:02:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OIC_ExternalNotificationListSel]
	@MessageTypeId		TINYINT			= 0
	,@FromDate			DATETIME 
	,@ToDate			DATETIME 
	,@UserId			INT
	,@Sender			VARCHAR(1000)	= 'All'
	,@SelectedLicensee	VARCHAR(MAX)	= 'All'
	,@SortBy			BIT				= 0
	,@Language			VARCHAR(10)		= 'All'
	
	,@PageSize			INT				= 10
	,@PageIndex			INT				= 0
	,@TotalRecords		INT				= 0		OUTPUT
	
	
AS
/*
	Created by: Kathy
	Date: 20150731
	Task: External notification list [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
	
	Param's Explanation:
		@SortBy:	0: Message Type ASC
					1: created time DESC
					
		@Language:	All - En + Ch + Cs
					En - English
					Ch - Traditional Chinese
					Cs - Simplified Chinese
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT
			,@RowEnd	INT
	
	DECLARE @tblMessageType TABLE (MessageTypeId TINYINT, MessageTypeName VARCHAR(50))
	
	DECLARE @tblSender TABLE (UserId INT)
	
	CREATE TABLE #tblMessage (
		MessageId		INT PRIMARY KEY
		,MessageTypeId	TINYINT
		,ToList			NVARCHAR(MAX)
	)
	
	SELECT	@PageIndex	= @PageIndex 
			,@RowStart	= @PageSize * @PageIndex + 1
			,@RowEnd	= @RowStart + @PageSize - 1
			
	IF @MessageTypeId = 0 -- external + email
	BEGIN
		INSERT INTO @tblMessageType (MessageTypeId, MessageTypeName)
		EXEC dbo.OIC_MessageTypeSel @Mode = 4 
	END
	ELSE
	BEGIN
		INSERT INTO @tblMessageType (MessageTypeId, MessageTypeName)
		SELECT	MessageTypeId, MessageTypeName
		FROM	dbo.MessageType WITH(NOLOCK)
		WHERE	MessageTypeId = @MessageTypeId
	END
	
	IF @Sender <> 'All'
	BEGIN
		INSERT INTO @tblSender (UserId)
		SELECT	val 
		FROM	dbo.strSplit(@Sender, ',')
	END		
	
	 -- public, special
	INSERT INTO #tblMessage (MessageId, MessageTypeId)		
	SELECT	m.MessageId, m.MessageTypeId
	FROM	dbo.Message m WITH(NOLOCK)
		INNER JOIN dbo.LicenseeMessage l WITH(NOLOCK)
			ON m.MessageId = l.MessageId
	WHERE	m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType WHERE MessageTypeId IN (40,41))
			AND m.CreateTime BETWEEN @FromDate AND @ToDate
			AND (m.Creator IN (SELECT UserId FROM @tblSender) 
				OR @Sender = 'All'
				)
			AND (@SelectedLicensee = 'All' 
				OR l.LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
				)
	GROUP BY m.MessageId, m.MessageTypeId
	
	SET @TotalRecords = @@rowcount
	
	-- for new user
	;WITH cteMessage 
	AS
	(
		SELECT	m.MessageId, m.MessageTypeId
		FROM	dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.MessageTarget mt WITH(NOLOCK)
				ON m.MessageId = mt.MessageId
		WHERE	m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType WHERE MessageTypeId IN (40,41))				
				AND m.CreateTime BETWEEN @FromDate AND @ToDate
				AND (m.Creator IN (SELECT UserId FROM @tblSender) 
					OR @Sender = 'All'
					)	
		GROUP BY m.MessageId, m.MessageTypeId		
	)
	INSERT INTO #tblMessage (MessageId, MessageTypeId)		
	SELECT	MessageId, MessageTypeId
	FROM	cteMessage c
	WHERE	MessageId NOT IN (SELECT MessageId FROM #tblMessage)
	
	SET @TotalRecords = @TotalRecords + @@rowcount
	
	-------------------------------	
	-- match delay-new, match delay-done, personal
	INSERT INTO #tblMessage (MessageId, MessageTypeId)		
	SELECT	m.MessageId, m.MessageTypeId
	FROM	dbo.Message m WITH(NOLOCK)
		INNER JOIN dbo.LicenseeMessage l WITH(NOLOCK)
			ON m.MessageId = l.MessageId
		INNER JOIN dbo.f_LicenseeBelongToUser (@UserId) f
			ON f.LicenseeId = l.LicenseeId
	WHERE	(m.MessageTypeId = @MessageTypeId
				OR @MessageTypeId = 0)
			AND m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType WHERE MessageTypeId IN(42, 43, 44, 60))
			AND m.CreateTime BETWEEN @FromDate AND @ToDate
			AND (m.Creator IN (SELECT UserId FROM @tblSender) 
				OR @Sender = 'All'
				)
			AND (@SelectedLicensee = 'All' 
				OR l.LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
				)
			AND m.MessageId NOT IN (SELECT MessageId FROM #tblMessage)
	GROUP BY m.MessageId, m.MessageTypeId
				
	SET @TotalRecords = @TotalRecords + @@rowcount
			
	-- for new user
	;WITH cteMessageTarget
	AS
	(
		SELECT	m.MessageId, m.MessageTypeId
		FROM	dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.MessageTarget mt WITH(NOLOCK)
				ON m.MessageId = mt.MessageId
		WHERE	(m.MessageTypeId = @MessageTypeId 
					OR @MessageTypeId = 0)
				AND m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType )				
				AND m.CreateTime BETWEEN @FromDate AND @ToDate
				AND (m.Creator IN (SELECT UserId FROM @tblSender) 
					OR @Sender = 'All'
					)			
				AND mt.LicenseeTypeId IN (SELECT LicenseeTypeId FROM dbo.f_LicenseeTypeBelongToUser (@UserId))
		GROUP BY m.MessageId, m.MessageTypeId
	)
	
	INSERT INTO #tblMessage (MessageId, MessageTypeId)		
	SELECT	MessageId, MessageTypeId
	FROM	cteMessageTarget c
	WHERE	MessageId NOT IN (SELECT MessageId FROM #tblMessage)
		
	SET @TotalRecords = @TotalRecords + @@rowcount
	
	-- get tolist if messagetype is personal. match- delay
	;WITH ctePersonalMessage
	AS(
		SELECT t.MessageId, STUFF((SELECT ', ' + l.LicenseeName
								FROM	dbo.LicenseeMessage lm WITH(NOLOCK)
									INNER JOIN dbo.Licensee l WITH(NOLOCK)
										ON l.LicenseeId = lm.LicenseeId
								WHERE	lm.MessageId = t.MessageId
								FOR XML PATH ('')
						),1,1,'') AS ToList
		FROM	#tblMessage t
		WHERE	t.MessageTypeId IN (42, 43, 44, 60) -- personal, match delay, email
		GROUP BY t.MessageId
	)
	UPDATE	t 
		SET	t.ToList = c.ToList 
	FROM	#tblMessage t
		INNER JOIN ctePersonalMessage c 
			ON t.MessageId = c.MessageId
			
	IF @Language <> 'All'
	BEGIN
		SELECT  MessageId
				,MessageTypeId
				,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = Result.MessageTypeId) AS MessageTypeName
				,CreateTime
				,Sender
				,ToList
				,Subject
				,Content				
		FROM
		(
			SELECT 	ROW_NUMBER() OVER(ORDER BY CASE WHEN @SortBy = 0 THEN m.MessageTypeId END ASC 
												,CreateTime DESC) AS RowNumber
					,m.MessageId
					,m.MessageTypeId
					,m.CreateTime
					,(SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) AS Sender
					,t.ToList
					,CASE WHEN @Language = 'Ch' AND ISNULL(m.SubjectCh, '') <> '' THEN m.SubjectCh
						WHEN @Language = 'Cs' AND ISNULL(m.SubjectCs, '') <> '' THEN m.SubjectCs
						ELSE m.SubjectEn 
						END AS Subject
					,CASE WHEN @Language = 'Ch' AND ISNULL(m.ContentCh, '') <> '' THEN m.ContentCh
						WHEN @Language = 'Cs' AND ISNULL(m.ContentCs, '') <> '' THEN m.ContentCs
						ELSE m.ContentEn
						END AS Content					
			FROM	dbo.Message m WITH(NOLOCK)
				INNER JOIN #tblMessage t 
					ON m.MessageId = t.MessageId
		) AS Result
		WHERE RowNumber BETWEEN @RowStart AND @RowEnd
	END
	ELSE
	BEGIN
		SELECT  MessageId
				,MessageTypeId
				,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = Result.MessageTypeId) AS MessageTypeName
				,CreateTime
				,Sender
				,ToList
				,SubjectEn
				,SubjectCh
				,SubjectCs
				,ContentEn	
				,ContentCh
				,ContentCs	
		FROM
		(
			SELECT 	ROW_NUMBER() OVER(ORDER BY CASE WHEN @SortBy = 0 THEN m.MessageTypeId END ASC 
												,CreateTime DESC) AS RowNumber
					,m.MessageId
					,m.MessageTypeId
					,m.CreateTime
					,(SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) AS Sender
					,t.ToList
					,m.SubjectEn
					,m.SubjectCh
					,m.SubjectCs
					,m.ContentEn
					,m.ContentCh
					,m.ContentCs	
			FROM	dbo.Message m WITH(NOLOCK)
				INNER JOIN #tblMessage t 
					ON m.MessageId = t.MessageId
		) AS Result
		WHERE RowNumber BETWEEN @RowStart AND @RowEnd
	END
END
















GO
GRANT EXECUTE ON [dbo].[OIC_ExternalNotificationListSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_ExternalNotificationListSel] TO [vnteam] AS [dbo]