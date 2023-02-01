/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeGroupIns] 
	@Name					NVARCHAR(100)
	,@ParentId				INT				= NULL
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
		- 20221206@Cody: Enhance Client group [RedmineId: #174401]
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

	IF (@ParentId IS NOT NULL) AND (NOT EXISTS(SELECT TOP(1) 1 FROM dbo.LicenseeGroup WITH (NOLOCK) WHERE Id = @ParentId))
	BEGIN
		SELECT	@ErrCode = 102
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40018, @Language) -- Unable to create because data is out of date. Please try again!
		RETURN
	END

	IF EXISTS (SELECT TOP(1) 1 FROM dbo.LicenseeGroup WITH(NOLOCK) WHERE Name = @Name)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40016, @Language) -- The licensee group name is already used. Please try another name.
		RETURN
	END

	BEGIN TRY
		INSERT INTO dbo.LicenseeGroup (Name, ParentId) VALUES (@Name, @ParentId)

		SET @Id = SCOPE_IDENTITY()
	
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40017, @Language) -- Fail to create group of licensee. Please try again.
		RETURN
	END CATCH

	DECLARE @ParentName NVARCHAR(100) = NULL
	
	SELECT @ParentName = Name
	FROM dbo.LicenseeGroup WITH(NOLOCK)
	WHERE Id = @ParentId

	SET @xml = (
		SELECT	@Id    AS '@lgi'
				,@Name AS '@lgn'
				,@ParentName AS '@lgp'
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
