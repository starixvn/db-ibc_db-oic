/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_InternalNotificationNewestList] 
	@UserId		INT
	,@Mode		SMALLINT	= 0
	,@Top		INT			= 10	
	,@MessageId INT			= 0 
AS
/*
	Created by: Kathy
	Date: 20150803
	Task: notification detail [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20161221@Percy: Implement Important - Reminder [RedmineID: #68774]
		- 20181031@Scofield: Improve Performance for Notifications [#103766]
	
	Param's Explanation:
		@Mode:	0 - News
				1 - 1on1 team
				2 - Important
				3 - Private
				4 - Reminder
		@Top:	0 - ALL
				10 - 10 newest notification
				
		@MessageId:	0 - get all msg at the fist time
					max(messageid) - get more newest msg have id > max(messageid) since last call
		
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @CurrentDateTime DATETIME
	SELECT  @CurrentDateTime = CONVERT(VARCHAR(8), DATEADD(HOUR, 12, GETDATE()), 114) + ' ' + CONVERT(VARCHAR(10), DATEADD(HOUR, 12, GETDATE()), 101) --convert time to GMT +8

	IF @Mode = 4 -- Reminder
	BEGIN
		SELECT TOP (@Top) m.MessageId
			,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = m.MessageTypeId) AS MessageTypeName
			,CASE WHEN m.Creator <> 0 THEN (SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) ELSE 'System' END AS Sender
			,m.SubjectEn
			,m.ContentEn
			,m.CreateTime
		FROM dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.UserMessage um WITH(NOLOCK) ON m.MessageId = um.MessageId
		WHERE m.MessageTypeId = 24 AND um.UserId = @UserId
			AND (
					um.IsRead = 0
					OR um.LastReadTime IS NULL
					OR CONVERT(DATE, um.LastReadTime) <> CONVERT(DATE, @CurrentDateTime)
			)
			AND 1 = CASE m.ReminderTypeId
					WHEN 2 THEN 1 -- Daily
					WHEN 3 THEN CASE WHEN
							',' + REPLACE(REPLACE(CONVERT(VARCHAR(MAX), m.ReminderTypeValue), ';', ','), ' ', ',') + ',' LIKE '%,' + DATENAME(WEEKDAY, @CurrentDateTime) + ',%'
							THEN 1 ELSE 0 END -- Weekly
					WHEN 4 THEN CASE WHEN
							',' + REPLACE(REPLACE(CONVERT(VARCHAR(MAX), m.ReminderTypeValue), ';', ','), ' ', ',') + ',' LIKE '%,' + CONVERT(VARCHAR(5), DATEPART(DAY, @CurrentDateTime)) + ',%'
							OR ('End of month' LIKE '%' + CONVERT(VARCHAR(MAX), m.ReminderTypeValue) + '%'
								AND DATEPART(MONTH, @CurrentDateTime) <> DATEPART(MONTH, DATEADD(DAY, 1, @CurrentDateTime))
							)
							THEN 1 ELSE 0 END -- Monthly
					WHEN 5 THEN CASE WHEN
							',' + REPLACE(REPLACE(CONVERT(VARCHAR(MAX), m.ReminderTypeValue), ';', ','), ' ', ',') + ',' LIKE '%,' + CONVERT(VARCHAR(2), MONTH(@CurrentDateTime)) + '/' + CONVERT(VARCHAR(2), DAY(@CurrentDateTime)) + ',%'
							OR ',' + REPLACE(REPLACE(CONVERT(VARCHAR(MAX), m.ReminderTypeValue), ';', ','), ' ', ',') + ',' LIKE '%,0' + CONVERT(VARCHAR(2), MONTH(@CurrentDateTime)) + '/' + CONVERT(VARCHAR(2), DAY(@CurrentDateTime)) + ',%'
							OR ',' + REPLACE(REPLACE(CONVERT(VARCHAR(MAX), m.ReminderTypeValue), ';', ','), ' ', ',') + ',' LIKE '%,' + CONVERT(VARCHAR(2), MONTH(@CurrentDateTime)) + '/0' + CONVERT(VARCHAR(2), DAY(@CurrentDateTime)) + ',%'
							OR ',' + REPLACE(REPLACE(CONVERT(VARCHAR(MAX), m.ReminderTypeValue), ';', ','), ' ', ',') + ',' LIKE '%,0' + CONVERT(VARCHAR(2), MONTH(@CurrentDateTime)) + '/0' + CONVERT(VARCHAR(2), DAY(@CurrentDateTime)) + ',%'
							THEN 1 ELSE 0 END -- Yearly
					END
		ORDER BY m.CreateTime DESC
	END
	ELSE IF @Top <> 0
	BEGIN
		SELECT TOP (@Top) m.MessageId
			,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = m.MessageTypeId) AS MessageTypeName
			,CASE WHEN m.Creator <> 0 THEN (SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) ELSE 'System' END AS Sender
			,m.SubjectEn
			,m.ContentEn
			,m.CreateTime
		FROM	dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.UserMessage um WITH(NOLOCK)
				ON	m.MessageId = um.MessageId
		WHERE	(@Mode = 0 and m.MessageTypeId BETWEEN 1 AND 19 -- News - System, News - Manual
					OR (@Mode = 1 AND m.MessageTypeId = 20) -- 1on1
					OR (@Mode = 2 AND m.MessageTypeId BETWEEN 21 AND 39 AND m.MessageTypeId <> 23) -- Important - System, Important - Manual)
					OR (@Mode = 3 AND m.MessageTypeId = 23) -- Private
				)
				AND um.UserId = @UserId
				AND um.IsRead = 0
		ORDER BY m.CreateTime DESC
	END
	ELSE
	BEGIN
		SELECT m.MessageId
			,(SELECT MessageTypeName FROM dbo.MessageType WITH(NOLOCK) WHERE MessageTypeId = m.MessageTypeId) AS MessageTypeName
			,CASE WHEN m.Creator <> 0 THEN (SELECT DisplayName FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = m.Creator) ELSE 'System' END AS Sender
			,m.SubjectEn
			,m.ContentEn
			,m.CreateTime
		FROM	dbo.Message m WITH(NOLOCK)
			INNER JOIN dbo.UserMessage um WITH(NOLOCK)
				ON	m.MessageId = um.MessageId
		WHERE	(@Mode = 0 and m.MessageTypeId BETWEEN 1 AND 19 -- News - System, News - Manual
					OR (@Mode = 1 AND m.MessageTypeId = 20) -- 1on1
					OR (@Mode = 2 AND m.MessageTypeId BETWEEN 21 AND 39 AND m.MessageTypeId <> 23) -- Important - System, Important - Manual)
					OR (@Mode = 3 AND m.MessageTypeId = 23) -- Private
				)
				AND um.UserId = @UserId
				AND um.IsRead = 0
				AND (@MessageId = 0 OR m.MessageId > @MessageId)
		ORDER BY m.CreateTime DESC
	END
END
GO