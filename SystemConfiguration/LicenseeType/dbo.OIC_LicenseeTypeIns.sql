/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeTypeIns] 
	@LicenseeTypeName		VARCHAR(40)
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 201501001
	Task: insert new TOL [Redmine:#44251]
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

	DECLARE @LicenseeTypeId TINYINT

	SET @startRun = GETDATE()		
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.LicenseeTypes WITH(NOLOCK) WHERE TypeName = @LicenseeTypeName)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30003, @Language) -- The licensee type name is already used. Please try another name.
		RETURN
	END
	
	BEGIN TRY
		SELECT @LicenseeTypeId = MAX([TypeId]) FROM dbo.LicenseeTypes WITH (NOLOCK)
		SELECT @LicenseeTypeId = @LicenseeTypeId + 1
		INSERT INTO dbo.LicenseeTypes (TypeId, TypeName) VALUES (@LicenseeTypeId, @LicenseeTypeName)
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30001, @Language) -- Fail to create type of licensee. Please try again.
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
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration
END
GO