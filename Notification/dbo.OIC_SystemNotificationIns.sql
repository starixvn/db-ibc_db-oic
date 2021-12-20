/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/


ALTER PROCEDURE [dbo].[OIC_SystemNotificationIns] 
	@MessageTypeId		TINYINT
	,@MessageContent	XML	
	
	,@UserId			INT
	,@Language			VARCHAR(10)	= 'E'
	,@IP				VARCHAR(50)	= NULL
	,@ErrCode			INT			= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 20150728
	Task: Insert system notification [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20170302@Percy: Expand length of Content [RedmineID: #70322]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
	
	Param's Explanation:
		@MessageContent	=	<root>
								<row EventId="1" LicenseeTypeId="0" LicenseeId="1" SubjectEn="subject1">
									<contentEn> ContentEn</contentEn>
								</row>
								<row EventId="2" LicenseeTypeId ="0" LicenseeId="1" SubjectEn="subject2">
									<contentEn> ContentEn</contentEn>
								</row>
							</root>
	*LicenseeTypeId <> 0 (LicenseeId = 0): ignore LicenseeId, send notification to all user belong to this TOL
	*LicenseeType = 0 (LicenseeId <> 0): send notification to all user belong to TOL of this licensee
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT
			,@logSPData		NVARCHAR(MAX)
			,@xml			XML
			,@procName		VARCHAR(200)
			,@MessageId		INT	
			,@RowCount		INT = 0
			,@seq			INT = 1
			,@EventId		INT
			,@LicenseeId	INT
			,@LicenseeTypeId	TINYINT = 0
			,@IsTesting		BIT = 0	
			
	DECLARE @tblContent TABLE (seq INT IDENTITY(1,1), EventId INT, LicenseeTypeId TINYINT, LicenseeId INT, SubjectEn NVARCHAR(300), ContentEn NVARCHAR(MAX))
	DECLARE @tblUser TABLE (UserId INT)
	
	SET @startRun = GETDATE()
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName LIKE 'starix%' AND UserId = @UserId)
		SET @IsTesting = 1
	
	INSERT INTO @tblContent (EventId, LicenseeTypeId, LicenseeId, SubjectEn, ContentEn)				
	SELECT	t.c.value('@EventId', 'INT')
			,t.c.value('@LicenseeTypeId', 'TINYINT')
			,t.c.value('@LicenseeId', 'INT')
			,t.c.value('@SubjectEn', 'NVARCHAR(300)')
			,t.c.value('.', 'NVARCHAR(4000)')
	FROM	@MessageContent.nodes('root/row') t(c)	
	OPTION (OPTIMIZE FOR (@MessageContent = NULL))
	
	SET @RowCount = @@rowcount
	
	WHILE (@seq <= @RowCount)
	BEGIN
		
		SELECT	@EventId		= EventId
				,@LicenseeId	= LicenseeId
				,@LicenseeTypeId = LicenseeTypeId
		FROM	@tblContent
		WHERE	seq = @seq
		
		IF @LicenseeTypeId = 0
		BEGIN
			SELECT	@LicenseeTypeId = TypeId 
			FROM	dbo.Licensee WITH(NOLOCK)
			WHERE	LicenseeId = @LicenseeId
		END
		
		INSERT INTO @tblUser(UserId) 
		SELECT	@UserId	-- send notification for edited user & specific user's postion
		UNION 
		SELECT	UserId
		FROM	dbo.UserInfo WITH(NOLOCK)
		WHERE	PositionId IN (SELECT PositionId FROM dbo.f_PositionNotificationList(@EventId))
		UNION -- send notification for all internal user who has permission on licensee type of this licensee
		SELECT  UserId
		FROM	dbo.UserLicenseeTypes WITH(NOLOCK)
		WHERE	TypeId = @LicenseeTypeId
		
		BEGIN TRY
			INSERT INTO dbo.Message (SubjectEn, ContentEn, MessageTypeId, Creator, CreateTime)
			SELECT	SubjectEn, ContentEn, @MessageTypeId, 0, GETDATE()		
			FROM	@tblContent
			WHERE	seq = @seq
			
			SET @MessageId = SCOPE_IDENTITY()
			
			INSERT INTO dbo.UserMessage(UserId, MessageId, IsRead)
			SELECT	t.UserId, @MessageId, 0
			FROM	@tblUser t
				INNER JOIN dbo.UserInfo u WITH(NOLOCK)
					ON t.UserId = u.UserId
			WHERE	(@IsTesting = 0
						OR (@IsTesting = 1 AND u.DisplayName LIKE 'starix%')) -- if the msg for testing, dont send to real user
			
			IF @IsTesting = 0 -- just insert msg into MessageLicenseeType for real user
			BEGIN
				IF @LicenseeTypeId <> 0
				BEGIN
					INSERT INTO dbo.MessageLicenseeType(TypeId, MessageId, PositionId) VALUES (@LicenseeTypeId, @MessageId, 0)			
				END
				ELSE
				BEGIN
					INSERT INTO dbo.MessageLicenseeType(TypeId, MessageId, PositionId)
					SELECT	0, @MessageId, PositionId
					FROM	dbo.f_PositionNotificationList(@EventId)
				END
			END
		END TRY
		BEGIN CATCH
			DELETE FROM dbo.MessageLicenseeType WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			DELETE FROM dbo.UserMessage WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			DELETE FROM dbo.Message WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			SELECT	@Errcode = 100
					,@ErrMsg = dbo.f_Get_MsgNamebyMsgID(40000,@Language)
			
			RETURN
		END CATCH
		
		DELETE FROM @tblUser
		
		SET @seq = @seq + 1
	END
	
	-- write log
	SET @xml = (
		SELECT	@MessageTypeId AS '@mid'
				,@MessageContent
		FOR XML PATH('r'), TYPE
		)		
		
	SELECT	@logSPData	= CONVERT(NVARCHAR(MAX),@xml)
			,@endRun		= GETDATE()  
			,@duration		= DATEDIFF(millisecond, @startRun, @endRun)   
			,@procName		= OBJECT_NAME(@@procid)

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration	
END
