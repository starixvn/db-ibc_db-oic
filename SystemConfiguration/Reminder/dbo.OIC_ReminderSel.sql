USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ReminderSel]
	@UserId				INT,
	@SelectedReminder	VARCHAR(1000) = 'All',
	@FromDate			DATETIME,
	@ToDate				DATETIME,
	@SelectedSender		VARCHAR(MAX) = 'All',

	@PageSize			INT = 10,
	@PageIndex			INT = 0,
	@TotalRecords		INT = 0 OUTPUT
AS

/*
	Creator: Percy
	Date: 2016-12-15
	DB: DBOIC.bodb_OIC
	Task: System Configuration - Select Reminder

	Revisions:
		- 20170302@Percy: Expand length of Content [RedmineID: #70322]

	Param's Explanation:
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @RowStart INT, @RowEnd INT
	SELECT	@PageIndex	= @PageIndex 
			,@RowStart	= @PageSize * @PageIndex + 1
			,@RowEnd	= @RowStart + @PageSize - 1

	DECLARE @tblSender TABLE (UserId INT)
	DECLARE @tblReminder TABLE (ReminderTypeId TINYINT)
	DECLARE @tblLicenseeType TABLE (LicenseeTypeId TINYINT)
	DECLARE @PositionId	TINYINT
	CREATE TABLE #tblMessage
	(
		MessageId			INT PRIMARY KEY
		,MessageTypeId		TINYINT
		,CreateTime			DATETIME
		,SenderId			INT
		,SubjectEn			NVARCHAR(300)
		,ContentEn			NVARCHAR(MAX)
		,IsRead				BIT
		,IsDisable			BIT
		,ReminderTypeId		TINYINT
		,ReminderTypeValue	XML
	)

	INSERT INTO @tblLicenseeType (LicenseeTypeId)
	SELECT	LicenseeTypeId
	FROM	dbo.UserLicenseeType WITH(NOLOCK)
	WHERE	UserId = @UserId

	SELECT	@PositionId = PositionId
	FROM	dbo.UserInfo WITH(NOLOCK)
	WHERE	UserId = @UserId

	IF @SelectedSender <> 'All'
	BEGIN
		INSERT INTO @tblSender (UserId)
		SELECT	val 
		FROM	dbo.strSplit(@SelectedSender, ',')
	END	

	IF @SelectedReminder <> 'All'
	BEGIN
		INSERT INTO @tblReminder (ReminderTypeId)
		SELECT	val 
		FROM	dbo.strSplit(@SelectedReminder, ',')
	END	

	INSERT INTO #tblMessage (MessageId, MessageTypeId, CreateTime, SenderId, SubjectEn, ContentEn, IsRead, IsDisable, ReminderTypeId, ReminderTypeValue)
	SELECT  m.MessageId, m.MessageTypeId, m.CreateTime, m.Creator, m.SubjectEn, m.ContentEn, um.IsRead, 0, m.ReminderTypeId, m.ReminderTypeValue
	FROM	dbo.Message m WITH(NOLOCK)
		INNER JOIN dbo.UserMessage um WITH(NOLOCK) ON m.MessageId = um.MessageId AND um.LicenseeName IS NULL -- for Internal Notifications
	WHERE	m.MessageTypeId IN (21, 24)
			AND m.CreateTime BETWEEN @FromDate AND @ToDate
			AND (m.Creator IN (SELECT UserId FROM @tblSender) OR @SelectedSender = 'All')
			AND um.UserId = @UserId
			AND (
				@SelectedReminder = 'All'
				OR ISNULL(m.ReminderTypeId, 1) IN (SELECT ReminderTypeId FROM @tblReminder)
			)
	
	SET @TotalRecords = @@ROWCOUNT

	;WITH cteMessageTarget AS (
		SELECT m.MessageId, m.MessageTypeId, m.CreateTime, m.Creator, m.SubjectEn, m.ContentEn, m.ReminderTypeId, m.ReminderTypeValue
		FROM dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.MessageTarget mt WITH(NOLOCK) ON	m.MessageId = mt.MessageId
		WHERE	m.MessageTypeId IN (21, 24)
				AND m.CreateTime BETWEEN @FromDate AND @ToDate
				AND (m.Creator IN (SELECT UserId FROM @tblSender) OR @SelectedSender = 'All')
				AND (mt.LicenseeTypeId IN (SELECT t.LicenseeTypeId FROM @tblLicenseeType t)
						OR mt.PositionId = @PositionId
					)
				AND m.MessageId NOT IN (SELECT MessageId FROM #tblMessage)
				AND (
					@SelectedReminder = 'All'
					OR ISNULL(m.ReminderTypeId, 1) IN (SELECT ReminderTypeId FROM @tblReminder)
				)
		--GROUP BY m.MessageId, m.MessageTypeId, m.CreateTime, m.Creator, m.SubjectEn, m.ContentEn, m.ReminderTypeId, m.ReminderTypeValue
	)
	INSERT INTO #tblMessage (MessageId, MessageTypeId, CreateTime, SenderId, SubjectEn, ContentEn, IsRead, IsDisable, ReminderTypeId, ReminderTypeValue)
	SELECT	MessageId, MessageTypeId, CreateTime, Creator, SubjectEn, ContentEn, 1, 1, ReminderTypeId, ReminderTypeValue
	FROM cteMessageTarget
	
	SET @TotalRecords = @TotalRecords + @@ROWCOUNT

	-- Result
	CREATE TABLE #Result (RowNumber INT, MessageId INT, MessageTypeId TINYINT, CreateTime DATETIME, SenderId INT,
						SubjectEn NVARCHAR(300), ContentEn NVARCHAR(MAX), IsRead BIT, IsDisable BIT, ReminderTypeId TINYINT, ReminderTypeValue XML)

	INSERT INTO #Result (RowNumber, MessageId, MessageTypeId, CreateTime, SenderId, SubjectEn, ContentEn, IsRead, IsDisable, ReminderTypeId, ReminderTypeValue)
	SELECT RowNumber, MessageId, MessageTypeId, CreateTime, SenderId, SubjectEn, ContentEn, IsRead, IsDisable, ISNULL(ReminderTypeId, 1), ReminderTypeValue
	FROM (
		SELECT	ROW_NUMBER() OVER(ORDER BY MessageTypeId DESC, CreateTime DESC) AS RowNumber
				,MessageId, MessageTypeId, CreateTime, SenderId, SubjectEn, ContentEn, IsRead, IsDisable, ReminderTypeId, ReminderTypeValue
		FROM #tblMessage
	) Result
	WHERE RowNumber BETWEEN @RowStart AND @RowEnd

	-- Return data
	SELECT r.*, rt.ReminderTypeName, u.DisplayName AS Sender
	FROM #Result r
		LEFT JOIN dbo.ReminderType rt WITH(NOLOCK) ON r.ReminderTypeId = rt.ReminderTypeId
		INNER JOIN dbo.UserInfo u WITH(NOLOCK) ON r.SenderId = u.UserId
	ORDER BY r.RowNumber

	DROP TABLE #Result
	DROP TABLE #tblMessage
END
GO
GRANT EXECUTE ON [dbo].[OIC_ReminderSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_ReminderSel] TO [vnteam] AS [dbo]