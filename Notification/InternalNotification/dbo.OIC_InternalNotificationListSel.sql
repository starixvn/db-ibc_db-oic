/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_InternalNotificationListSel]
	@MessageTypeId	TINYINT			= 0
	,@FromDate		DATETIME 
	,@ToDate		DATETIME 
	,@UserId		INT
	,@Sender		VARCHAR(MAX)	= 'All'
	,@ReadStatus	SMALLINT		= 2 -- ALL
	,@SortBy		BIT				= 0
	
	,@PageSize		INT				= 10
	,@PageIndex		INT				= 0
	,@TotalRecords	INT				= 0 OUTPUT
	
	
AS
/*
	Created by: Kathy
	Date: 20150731
	Task: Internal notification list [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20161216@Percy: Support sort message type [RedmineID: #68774]
		- 20170302@Percy: Expand length of Content [RedmineID: #70322]
		- 21701030@Scofield: Update LicenseeName IS NULL -- for Internal Notifications [ReadmineID: #84004]
	
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
		,ReminderTypeId		TINYINT
		,ReminderTypeValue	XML
		,CreateTime			DATETIME
		,Sender				NVARCHAR(50)
		,SubjectEn			NVARCHAR(300)
		,ContentEn			NVARCHAR(MAX)
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
	ELSE
	BEGIN
		INSERT INTO @tblMessageType (MessageTypeId, MessageTypeName)
		SELECT	MessageTypeId, MessageTypeName
		FROM	dbo.MessageType WITH(NOLOCK)
		WHERE	MessageTypeId = @MessageTypeId
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
			,ReminderTypeId
			,ReminderTypeValue
			,CreateTime
			,Sender
			,SubjectEn
			,ContentEn
			,IsRead
			,IsDisable
		)
	SELECT  m.MessageId
			,MessageTypeId
			,m.ReminderTypeId
			,m.ReminderTypeValue
			,m.CreateTime
			,CASE WHEN m.Creator <> 0 THEN (SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) ELSE 'System' END AS Sender
			,m.SubjectEn
			,m.ContentEn
			,um.IsRead
			,0 AS IsDisable
	FROM	dbo.Message m WITH(NOLOCK)
	INNER JOIN dbo.UserMessage um WITH(NOLOCK)
		ON	m.MessageId = um.MessageId AND um.LicenseeName IS NULL -- for Internal Notifications
	WHERE	(m.MessageTypeId = @MessageTypeId 
				OR @MessageTypeId = 0)
			AND m.MessageTypeId IN (SELECT MessageTypeId FROM @tblMessageType)
			AND m.CreateTime BETWEEN @FromDate AND @ToDate
			AND ( m.Creator IN (SELECT UserId FROM @tblSender) OR @Sender = 'All')
			AND um.UserId = @UserId
			AND (
				@ReadStatus = 2
				OR m.MessageTypeId = 24
				OR um.IsRead = @ReadStatus
			)
	
	SET @TotalRecords = @@rowcount
	
	IF @ReadStatus <> 0 -- unread
	BEGIN					
		;WITH cteMessageTarget
		AS(
			SELECT	m.MessageId
					,MessageTypeId
					,m.ReminderTypeId
					,m.ReminderTypeValue
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
			--GROUP BY m.MessageId, MessageTypeId, CreateTime, m.Creator, SubjectEn, ContentEn,m.ReminderTypeId,ISNULL(m.ReminderTypeValue, '')
		)
		INSERT INTO #tblMessage(
			MessageId			
			,MessageTypeId
			,ReminderTypeId
			,ReminderTypeValue
			,CreateTime	
			,Sender		
			,SubjectEn			
			,ContentEn			
			,IsRead		
			,IsDisable		
		)
		SELECT	MessageId	
				,MessageTypeId
				,ReminderTypeId
				,ReminderTypeValue	
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
		SELECT t.MessageId, STUFF((SELECT ', ' + u.DisplayName
								FROM	dbo.UserMessage lm WITH(NOLOCK)					
									INNER JOIN dbo.UserInfo u WITH(NOLOCK)
										ON u.UserId = lm.UserId AND lm.LicenseeName IS NULL -- for Internal Notifications
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
			,MessageTypeId
			,MessageTypeName
			,ReminderTypeId
			,ReminderTypeName
			,ReminderTypeValue
			,CreateTime
			,Sender
			,SubjectEn
			,ContentEn
			,IsRead
			,IsDisable
			,ToList
	FROM(
		SELECT	ROW_NUMBER() OVER(ORDER BY CASE WHEN @SortBy = 0 THEN mt.[Order] END ASC ,CreateTime DESC) AS RowNumber
				,MessageId
				,mt.MessageTypeId
				,mt.MessageTypeName
				,m.ReminderTypeId
				,m.ReminderTypeValue
				,rt.ReminderTypeName
				,CreateTime
				,Sender
				,SubjectEn
				,ContentEn
				,IsRead
				,IsDisable
				,ToList
		FROM #tblMessage m
			INNER JOIN dbo.MessageType mt WITH (NOLOCK) ON m.MessageTypeId = mt.MessageTypeId
			LEFT JOIN dbo.ReminderType rt WITH(NOLOCK) ON m.ReminderTypeId = rt.ReminderTypeId
	) Result
	WHERE RowNumber BETWEEN @RowStart AND @RowEnd
END
GO