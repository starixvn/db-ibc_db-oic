USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_InternalNotificationListSel]    Script Date: 09/08/2015 16:38:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.OIC_InternalNotificationListSel    Script Date: 26/08/2015 12:33:24 PM ******/
ALTER PROCEDURE [dbo].[OIC_InternalNotificationListSel]
	@MessageTypeId	TINYINT				= 0
	,@FromDate		DATETIME 
	,@ToDate		DATETIME 
	,@UserId		INT
	,@Sender		VARCHAR(1000)		= 'All'
	,@ReadStatus	SMALLINT			= 2 -- ALL
	,@SortBy		BIT					= 0
	
	,@PageSize				INT			= 10
	,@PageIndex				INT			= 0
	,@TotalRecords			INT			= 0 OUTPUT
	
	
AS
/*
	Created by: Kathy
	Date: 20150731
	Task: Internal notification list [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
	
	Param's Explanation:
		@ReadStatus: 0: un-read
					 1: read
					 2: ALL	
		@SortBy: 0: Message Type ASC
				 1: created time DESC
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @RowStart	INT
			,@RowEnd	INT
	
	DECLARE @tblSender TABLE (UserId INT)
	DECLARE @tblLicenseeType TABLE (LicenseeTypeId TINYINT)
	DECLARE @PositionId	TINYINT 	
	CREATE TABLE #tblMessage(
		MessageId			INT PRIMARY KEY
		,MessageTypeId		TINYINT
		,MessageTypeName	VARCHAR(50)
		,CreateTime			DATETIME
		,Sender				NVARCHAR(50)
		,SubjectEn			NVARCHAR(300)
		,ContentEn			NVARCHAR(4000)
		,IsRead				BIT
		,IsDisable			BIT
		,ToList				VARCHAR(MAX)
	)
	
	DECLARE @tblMessageType TABLE (MessageTypeId TINYINT, MessageTypeName VARCHAR(50))
	
	IF @MessageTypeId = 0 -- internal system + manual
	BEGIN
		INSERT INTO @tblMessageType (MessageTypeId, MessageTypeName)
				EXEC dbo.OIC_MessageTypeSel @Mode = 3
	END
	
	SELECT	@PageIndex	= @PageIndex 
			,@RowStart	= @PageSize * @PageIndex + 1
			,@RowEnd	= @RowStart + @PageSize - 1
			
	SELECT	@PositionId = PositionId
	FROM	dbo.UserInfo WITH(NOLOCK)
	WHERE	UserId = @UserId
	
	INSERT INTO @tblLicenseeType (LicenseeTypeId)
	SELECT	LicenseeTypeId
	FROM	dbo.UserLicenseeType WITH(NOLOCK)
	WHERE	UserId = @UserId
	
	IF @Sender <> 'All'
	BEGIN
		INSERT INTO @tblSender (UserId)
		SELECT	val 
		FROM	dbo.strSplit(@Sender, ',')
	END	
	
	INSERT INTO #tblMessage(
			MessageId			
			,MessageTypeId
			,MessageTypeName	
			,CreateTime		
			,Sender	
			,SubjectEn			
			,ContentEn			
			,IsRead		
			,IsDisable		
		)
	SELECT  m.MessageId
			,MessageTypeId
			,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = m.MessageTypeId) AS MessageTypeName
			,m.CreateTime
			,CASE WHEN m.Creator <> 0 THEN (SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) ELSE 'System' END AS Sender
			,m.SubjectEn
			,m.ContentEn
			,um.IsRead
			,0 AS IsDisable
	FROM	dbo.Message m WITH(NOLOCK)
	INNER JOIN dbo.UserMessage um WITH(NOLOCK)
		ON	m.MessageId = um.MessageId
	WHERE	(m.MessageTypeId = @MessageTypeId 
				OR @MessageTypeId = 0)
			AND m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType)
			AND m.CreateTime BETWEEN @FromDate AND @ToDate
			AND ( m.Creator IN (SELECT UserId FROM @tblSender) OR @Sender = 'All')
			AND um.UserId = @UserId
			AND (um.IsRead = @ReadStatus OR @ReadStatus = 2)
	
	SET @TotalRecords = @@rowcount
	
	IF @ReadStatus <> 0 -- unread
	BEGIN					
		;WITH cteMessageTarget
		AS(
			SELECT	m.MessageId
					,MessageTypeId
					,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = m.MessageTypeId) MessageTypeName
					,m.CreateTime
					,CASE WHEN m.Creator <> 0 THEN (SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) ELSE 'System' END AS Sender
					,m.SubjectEn
					,m.ContentEn
					,1 AS IsRead -- read
			FROM	dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.MessageTarget mt WITH(NOLOCK)
				ON	m.MessageId = mt.MessageId
			WHERE	(m.MessageTypeId = @MessageTypeId OR @MessageTypeId = 0)
					AND m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType)
					AND m.CreateTime BETWEEN @FromDate AND @ToDate
					AND ( m.Creator IN (SELECT UserId FROM @tblSender) OR @Sender = 'All')
					AND (mt.LicenseeTypeId IN (SELECT t.LicenseeTypeId FROM @tblLicenseeType t)
							OR mt.PositionId = @PositionId
						)
					AND m.MessageId NOT IN (SELECT MessageId FROM #tblMessage)
			GROUP BY m.MessageId, MessageTypeId, CreateTime, m.Creator, SubjectEn, ContentEn
		)
		INSERT INTO #tblMessage(
			MessageId			
			,MessageTypeId
			,MessageTypeName	
			,CreateTime	
			,Sender		
			,SubjectEn			
			,ContentEn			
			,IsRead		
			,IsDisable		
		)
		SELECT	MessageId	
				,MessageTypeId		
				,MessageTypeName	
				,CreateTime	
				,Sender		
				,SubjectEn			
				,ContentEn			
				,IsRead	
				,1 -- always disable old messages for the new authorized user
		FROM cteMessageTarget
	
		SET @TotalRecords = @TotalRecords + @@rowcount
	END
	
	-- get tolist if messagetype is private
	;WITH ctePrivateMessage
	AS(
		SELECT t.MessageId, STUFF((SELECT ',' + u.DisplayName
								FROM	dbo.UserMessage lm WITH(NOLOCK)					
									INNER JOIN dbo.UserInfo u WITH(NOLOCK)
										ON u.UserId = lm.UserId
								WHERE	lm.MessageId = t.MessageId
								FOR XML PATH ('')
						),1,1,'') AS ToList
		FROM	#tblMessage t
		WHERE	t.MessageTypeId = 23 -- Private
		GROUP BY t.MessageId
	)
	
	UPDATE t
		SET t.ToList = c.ToList
	FROM #tblMessage t
		INNER JOIN ctePrivateMessage c
			ON t.MessageId = c.MessageId
	
	SELECT	MessageId
			,MessageTypeName
			,CreateTime
			,Sender
			,SubjectEn
			,ContentEn
			,IsRead
			,IsDisable
			,ToList
	FROM(
		SELECT	ROW_NUMBER() OVER(ORDER BY CASE WHEN @SortBy = 0 THEN MessageTypeId END ASC 
											,CreateTime DESC) AS RowNumber
				,MessageId
				,MessageTypeName
				,CreateTime
				,Sender
				,SubjectEn
				,ContentEn
				,IsRead
				,IsDisable
				,ToList
		FROM #tblMessage
	) Result
	WHERE RowNumber BETWEEN @RowStart AND @RowEnd
	
END

GO
GRANT EXECUTE ON [dbo].[OIC_InternalNotificationListSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_InternalNotificationListSel] TO [vnteam] AS [dbo]