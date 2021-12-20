/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_LicenseeTypeDel] 
	@LicenseeTypeId			TINYINT
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 201501001
	Task: delete TOL [Redmine:#44251]
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
		,@xml			XML
		,@procName		VARCHAR(200)
	
	DECLARE @LicenseeTypeName VARCHAR(40)

	SET @startRun = GETDATE()		
	
	SELECT	@LicenseeTypeName = TypeName
	FROM	dbo.LicenseeTypes WITH(NOLOCK)
	WHERE	TypeId = @LicenseeTypeId
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.UserLicenseeTypes WITH(NOLOCK) WHERE TypeId = @LicenseeTypeId)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30005, @Language) -- Unable to delete the type of licensee because one or many assigned client(s) or user(s) exist(s)
		RETURN
	END
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.Licensee WITH(NOLOCK) WHERE TypeId = @LicenseeTypeId)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30005, @Language) -- Unable to delete the type of licensee because one or many assigned client(s) or user(s) exist(s)
		RETURN
	END
	
	BEGIN TRY
		DELETE
		FROM	dbo.LicenseeTypes WITH(ROWLOCK, UPDLOCK)
		WHERE	TypeId = @LicenseeTypeId	
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30004, @Language) -- Fail to delete type of licensee. Please try again.
		RETURN
	END CATCH
	
	SET @xml = (
		SELECT	@LicenseeTypeId		AS '@lti'
				,@LicenseeTypeName	AS '@ltn'
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
		,@Data			= NULL
		,@OldData		= @logSPData
		,@Duration		= @Duration
END
GO