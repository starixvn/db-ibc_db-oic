/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LicenseeGroupIns]    Script Date: 2/12/2020 1:36:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeGroupIns] 
	@Name		VARCHAR(30)
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Hogan
	Date: 2020-1-10
	Task: Add Group into Client functions [Redmine:#126855]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20200110@Hogan: Create stored procedure OIC_LicenseeGroupIns [RedmineID: #126855]
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

	DECLARE @Id INT

	SET @startRun = GETDATE()

	IF EXISTS (SELECT TOP 1 1 FROM dbo.LicenseeGroup WITH(NOLOCK) WHERE Name = @Name)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40016, @Language) -- The licensee group name is already used. Please try another name.
		RETURN
	END

	BEGIN TRY
		INSERT INTO dbo.LicenseeGroup (Name) VALUES (@Name)

		SET @Id = SCOPE_IDENTITY()
	
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40017, @Language) -- Fail to create group of licensee. Please try again.
		RETURN
	END CATCH

	SET @xml = (
		SELECT	@Id		AS '@lgi'
				,@Name	AS '@lgn'
		FOR XML PATH('r'), TYPE
		)

	SELECT @logSPData	= CONVERT(NVARCHAR(MAX), @xml)
		,@endRun		= GETDATE()
		,@duration		= DATEDIFF(MILLISECOND, @startRun, @endRun)
		,@procName		= OBJECT_NAME(@@PROCID)

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
