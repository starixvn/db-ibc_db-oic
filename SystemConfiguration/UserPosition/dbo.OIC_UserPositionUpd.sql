USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_UserPositionUpd]
	@updUserId		INT
	,@PositionId	TINYINT		
	,@UserId		INT
	,@Language		VARCHAR(10)		= 'E'
	,@IP			VARCHAR(50)		= NULL
	,@ErrCode		INT				= 0			OUTPUT
	,@ErrMsg		VARCHAR(300)	= NULL		OUTPUT
AS

/*
	Created by: Kathy
	Date: 20151002
	Task: update user position [Redmine:#44258]
	DB: DBOIC.bodb_OIC
	
	Revisions:

*/

BEGIN
	SET NOCOUNT ON;
		
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@logSPOlddata	NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)
		,@isNewUser		BIT = 0
		,@newDisplayName NVARCHAR(50)

	SET @startRun = GETDATE()
	
	-- If the user is AM or PM, check if there is any client assigned to him.
	IF EXISTS (SELECT TOP 1 1 FROM UserLicensee WITH(NOLOCK) WHERE UserId = @updUserId)
	BEGIN
		SELECT @ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30023,@Language) -- Unable to change the user position because one or many assigned exist(s)
		RETURN
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = @updUserId)
	BEGIN
		SELECT	@newDisplayName = username
		FROM	bodb02.dbo.custInfo WITH(NOLOCK) 
		WHERE	custid = @updUserId 
				AND roleid >= 5

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT @ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30021, @Language) -- User does not exist
			RETURN
		END
		
		SET @isNewUser = 1
		
		IF EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName = @newDisplayName)
		BEGIN
			DECLARE @seq INT = 1
			WHILE(1 = 1)
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName = @newDisplayName +' (' + CAST(@seq AS VARCHAR(10)) +')') 
				BEGIN
					SET @newDisplayName = @newDisplayName +' (' + CAST(@seq AS VARCHAR(10)) +')' 
					BREAK
				END
				
				SET @seq = @seq + 1
			END
		END
	END	
	
	IF @isNewUser = 0
		SET @xml = (SELECT	UserId			AS '@uid'
							,DisplayName	AS '@udn'
							,ui.PositionId	AS '@upi'
							,p.PositionName	AS '@upn'
					FROM	dbo.UserInfo ui WITH(NOLOCK)
						INNER JOIN dbo.Position p WITH (NOLOCK)
							ON p.PositionId = ui.PositionId
					WHERE	UserId = @updUserId
					FOR XML PATH('r'), TYPE
				)
	ELSE
		SET @xml = (SELECT	@updUserId			AS '@uid'
							,@newDisplayName	AS '@ddn'
							,NULL				AS '@dpi'
							,NULL				AS '@dpn'
					FOR XML PATH('r'), TYPE
				)
				
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)
	
	BEGIN TRY
		IF @isNewUser = 0
		BEGIN
			UPDATE	dbo.UserInfo WITH(ROWLOCK, UPDLOCK)
				SET	PositionId = @PositionId
			WHERE	UserId = @updUserId
		END
		ELSE 
		BEGIN
			INSERT INTO dbo.UserInfo (UserId, DisplayName, PositionId) VALUES (@updUserId, @newDisplayName, @PositionId)
		END
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 102
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30022, @Language) -- Fail to edit user position. Please try again.
		
		RETURN
	END CATCH
	
	SET @xml = (SELECT	UserId			AS '@uid'
						,DisplayName	AS '@udn'
						,ui.PositionId	AS '@upi'
						,p.PositionName	AS '@upn'
				FROM	dbo.UserInfo ui WITH(NOLOCK)
					INNER JOIN dbo.Position p WITH (NOLOCK)
						ON p.PositionId = ui.PositionId
				WHERE	UserId = @updUserId
				FOR XML PATH('r'), TYPE
				)
		
	SELECT @logSPData = CONVERT(NVARCHAR(MAX), @xml)
		,@endRun	= GETDATE()  
		,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
		,@procName	= OBJECT_NAME(@@PROCID)

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= @logSPOlddata
		,@Duration		= @Duration	
	
END
GO
GRANT EXECUTE ON [dbo].[OIC_UserPositionUpd] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_UserPositionUpd] TO [vnteam] AS [dbo]
GO