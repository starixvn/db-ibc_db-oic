/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AutoMailDel]
	@EmailId	INT
	
	,@UserId	INT
	,@Language	VARCHAR(10)		= 'E'
	,@IP		VARCHAR(50)		= NULL
	,@ErrCode	INT				= 0			OUTPUT
	,@ErrMsg	VARCHAR(300)	= NULL		OUTPUT
AS

/*
	Created by: Cody
	Date: 2024-09-04
	Task: Manage recipient list of auto mails [RedmineId: #209253]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20240904@Cody: Init [RedmineId: #209253]

*/

BEGIN
	SET NOCOUNT ON;
	
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)
		
	SET @startRun = GETDATE()
	
	SET @xml = (
			SELECT	at.TypeName			AS '@atn'
					,lt.TypeName		AS '@ltn'
					,ag.GroupName		AS '@rgn'
					,a.Email			AS '@m'
					,a.RecipientType	AS '@rt'
			FROM dbo.AutoMail a WITH(NOLOCK) 
				INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK)
					ON lt.TypeId = a.LicenseeTypeId
				INNER JOIN dbo.AutoMailType at WITH(NOLOCK)
					ON at.TypeId = a.TypeId
				INNER JOIN dbo.AutoMailGroup ag WITH(NOLOCK)
					ON ag.GroupId = a.GroupId
			WHERE a.Id = @EmailId
			FOR XML PATH('r')
	)

	-- In case the email does not exist
	IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.AutoMail WITH(NOLOCK) WHERE Id = @EmailId)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = 'This email has been deleted already.'
				
		RETURN
	END
	
	-- In case the ToList has only one email
	DECLARE @GroupId TINYINT
			,@TypeId TINYINT
			,@LicenseeTypeId TINYINT
	
	SELECT @GroupId = GroupId
			,@TypeId = TypeId
			,@LicenseeTypeId = LicenseeTypeId
	FROM dbo.AutoMail WITH(NOLOCK)
	WHERE Id = @EmailId

	IF NOT EXISTS(SELECT TOP(1) 1 FROM dbo.AutoMail WITH(NOLOCK) WHERE RecipientType = 0
																		AND Id <> @EmailId 
																		AND GroupId = @GroupId 
																		AND TypeId = @TypeId
																		AND LicenseeTypeId = @LicenseeTypeId
																		AND IsTest = 0)
	BEGIN
		SELECT	@ErrCode = 101
				,@ErrMsg = 'Cannot Delete! TO List must contain at least 1 email!'
				
		RETURN
	END
	
	-- Delete email
	DELETE 
	FROM dbo.AutoMail WITH(ROWLOCK, UPDLOCK)
	WHERE Id = @EmailId

	SELECT	@endRun		= GETDATE()
			,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
			,@procName	= OBJECT_NAME(@@PROCID)
			,@logSPData = CONVERT(NVARCHAR(MAX),@xml)
			
	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= NULL
		,@OldData		= @logSPData
		,@Duration		= @duration
END
GO