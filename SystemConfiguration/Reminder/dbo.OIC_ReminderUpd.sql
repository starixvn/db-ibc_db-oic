USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ReminderUpd]
	@UserId				INT,
	@MessageId			INT,
	@ReminderTypeId		TINYINT,
	@ReminderTypeValue	XML = NULL,

	@Language			VARCHAR(10)		= 'E',
	@IP					VARCHAR(50)		= NULL,
	@ErrCode			INT				= 0		OUTPUT,
	@ErrMsg				VARCHAR(2000)	= ''	OUTPUT
AS

/*
	Creator: Percy
	Date: 2016-12-15
	DB: DBOIC.bodb_OIC
	Task: System Configuration - Update Reminder

	Revisions:

	Param's Explanation:
		- @ReminderType: type of reminder
			. 1: None
			. 2: Daily
			. 3: Weekly
			. 4: Monthly
			. 5: Yearly
		- @ReminderValue: value of reminder
			. None, Daily: = NULL
			. Weekly, Monthly, Yearly: '<root>
											<r id="", value="">
										</root>'
*/

BEGIN
	SET NOCOUNT ON

	DECLARE @startTime DATETIME, @duration INT, @logSPData NVARCHAR(MAX), @logSPOldData NVARCHAR(MAX), @xml XML, @procName VARCHAR(200)
	SELECT  @startTime = GETDATE()

	-- check condition Important - Manual/Reminder
	IF NOT EXISTS (SELECT 1 FROM dbo.Message WITH(NOLOCK) WHERE MessageId = @MessageId AND MessageTypeId IN (21, 24))
	BEGIN
		SELECT	@ErrCode = 100,
				@ErrMsg = 'This message is not Important - Manual or Important - Reminder'
		RETURN
	END

	-- check input valid --
	IF @ReminderTypeId = 5 -- Yearly
	BEGIN
		DECLARE @dateInvalid VARCHAR(MAX)
		IF LEFT(REPLACE(REPLACE(CONVERT(VARCHAR(MAX), @ReminderTypeValue), ';', ','), ' ', ','), 1) = ','
			OR RIGHT(REPLACE(REPLACE(CONVERT(VARCHAR(MAX), @ReminderTypeValue), ';', ','), ' ', ','), 1) = ','
		BEGIN
			SELECT	@ErrCode = 101,
					@ErrMsg = 'Invalid date: '
			RETURN
		END

		IF EXISTS (
				SELECT rank, LTRIM(RTRIM(val))
				FROM dbo.strSplit(REPLACE(CONVERT(VARCHAR(MAX), @ReminderTypeValue), ';', ','), ',')
				WHERE CHARINDEX('/', LTRIM(RTRIM(val))) = 0
		)
		BEGIN
			SELECT TOP 1 @dateInvalid = LTRIM(RTRIM(val))
			FROM dbo.strSplit(REPLACE(CONVERT(VARCHAR(MAX), @ReminderTypeValue), ';', ','), ',')
			WHERE CHARINDEX('/', LTRIM(RTRIM(val))) = 0
			
			SELECT	@ErrCode = 101,
					@ErrMsg = 'Invalid date: ' + @dateInvalid
			RETURN
		END

		DECLARE @tblCheck TABLE (ID INT, val NVARCHAR(MAX))

		INSERT INTO @tblCheck (ID, val)
		SELECT rank, LTRIM(RTRIM(val))
		FROM dbo.strSplit(REPLACE(REPLACE(CONVERT(VARCHAR(MAX), @ReminderTypeValue), ';', ','), ' ', ','), ',')

		DELETE @tblCheck WHERE val = ''

		IF NOT EXISTS (SELECT 1 FROM @tblCheck)
		BEGIN
			SELECT @dateInvalid = ''
		END
		ELSE IF EXISTS (SELECT 1 FROM @tblCheck WHERE CHARINDEX('/', val) = 0)
		BEGIN
			SELECT TOP 1 @dateInvalid = val
			FROM @tblCheck WHERE CHARINDEX('/', val) = 0
			ORDER BY ID
		END
		ELSE IF EXISTS (SELECT 1 FROM @tblCheck t CROSS APPLY dbo.strSplit(t.val, '/') s WHERE LEN(t.val) > 5 OR LEN(s.val) > 2)
		BEGIN
			SELECT TOP 1 @dateInvalid = t.val
			FROM @tblCheck t
				CROSS APPLY dbo.strSplit(t.val, '/') s
			WHERE LEN(t.val) > 5 OR LEN(s.val) > 2
			ORDER BY t.ID
		END
		ELSE
		BEGIN
			UPDATE @tblCheck
			SET val = 
				CASE WHEN LEN(LEFT(val, CHARINDEX('/', val) - 1)) = 1 THEN '0' + LEFT(val, CHARINDEX('/', val) - 1) ELSE LEFT(val, CHARINDEX('/', val) - 1) END
				+ '/' +
				CASE WHEN LEN(RIGHT(val, LEN(val) - CHARINDEX('/', val))) = 1 THEN '0' + RIGHT(val, LEN(val) - CHARINDEX('/', val)) ELSE RIGHT(val, LEN(val) - CHARINDEX('/', val)) END

			SELECT TOP 1 @dateInvalid = val
			FROM @tblCheck
			WHERE ISDATE(val + '/1970') = 0
		END

		IF @dateInvalid IS NOT NULL
		BEGIN
			SELECT	@ErrCode = 101,
					@ErrMsg = 'Invalid date: ' + @dateInvalid
			RETURN
		END

		IF (SELECT COUNT(1) FROM @tblCheck) > 30
		BEGIN
			SELECT	@ErrCode = 102,
					@ErrMsg = 'Too many dates inputed (exceed 30 dates)'
			RETURN
		END
	END

	-- get old data before update
	SELECT	@xml = 
	(
		SELECT
			@UserId			AS '@uid',
			MessageId		AS '@mi',
			MessageTypeId	AS '@mti',
			ReminderTypeId	AS '@rti',
			CONVERT(NVARCHAR(MAX), ReminderTypeValue) AS '@rtv'
		FROM dbo.Message WITH(NOLOCK)
		WHERE MessageId = @MessageId
		FOR XML PATH('r'), TYPE
	)

	SELECT  @logSPOldData = CONVERT(NVARCHAR(MAX), @xml)

	BEGIN TRY
		UPDATE dbo.Message WITH(ROWLOCK, UPDLOCK)
		SET
			MessageTypeId		= CASE WHEN @ReminderTypeId = 1 THEN 21 ELSE 24 END,
			ReminderTypeId		= @ReminderTypeId,
			ReminderTypeValue	= CASE WHEN @ReminderTypeId IN (1, 2) THEN NULL ELSE @ReminderTypeValue END
		WHERE MessageId = @MessageId
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 103,
				@ErrMsg = 'Update failed! Please try again!'
		RETURN
	END CATCH

	-- get new data after update
	SELECT	@xml = 
	(
		SELECT
			@UserId			AS '@uid',
			MessageId		AS '@mi',
			MessageTypeId	AS '@mti',
			ReminderTypeId	AS '@rti',
			CONVERT(NVARCHAR(MAX), ReminderTypeValue) AS '@rtv'
		FROM dbo.Message WITH(NOLOCK)
		WHERE MessageId = @MessageId
		FOR XML PATH('r'), TYPE
	)

	SELECT  @logSPData = CONVERT(NVARCHAR(MAX), @xml)

	-- write log
	SELECT	@duration = DATEDIFF(MILLISECOND, @startTime, GETDATE()),
			@procName = OBJECT_NAME(@@PROCID)

	EXEC dbo.OIC_LogRunSpIns
		@UserId		= @UserId,
		@SPName		= @procName,
		@Language	= @Language,
		@IP			= @IP,
		@Data		= @logSPData,
		@OldData	= @logSPOldData,
		@Duration	= @duration
END
GO
GRANT EXECUTE ON [dbo].[OIC_ReminderUpd] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_ReminderUpd] TO [vnteam] AS [dbo]