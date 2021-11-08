/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeTypeUpd] 
	@LicenseeTypeId			TINYINT
	,@LicenseeTypeName		VARCHAR(40)
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 201501001
	Task: update TOL [Redmine:#44251]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20210908@Hogan: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
		- 20211116@Alex: Change Type Of Licensee [RedmineID: #163521]
		
*/
BEGIN
	SET NOCOUNT ON
	
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@logSPOlddata	NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)

	SET @startRun = GETDATE()
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.LicenseeTypes WITH(NOLOCK) WHERE TypeName = @LicenseeTypeName)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30003, @Language) -- The licensee type name is already used. Please try another name.
		RETURN
	END		
	
	-- get old data
	SET @xml = (
		SELECT	TypeId		AS '@lti'
				,TypeName	AS '@ltn'
		FROM	dbo.LicenseeTypes WITH(NOLOCK)
		WHERE	TypeId = @LicenseeTypeId
		FOR XML PATH('r'), TYPE
		)	
		
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)
	
	BEGIN TRY
		UPDATE	dbo.LicenseeTypes WITH(ROWLOCK, UPDLOCK)
			SET	TypeName = @LicenseeTypeName
		WHERE	TypeId = @LicenseeTypeId	
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30002, @Language) -- Fail to edit type of licensee. Please try again.	
		RETURN
	END CATCH
	
	SET @xml = (
		SELECT	TypeId		AS '@lti'
				,TypeName	AS '@ltn'
		FROM	dbo.LicenseeTypes WITH(NOLOCK)
		WHERE	TypeId = @LicenseeTypeId
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