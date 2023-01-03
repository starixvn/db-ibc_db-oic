/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeGroupDel] 
	@Id						INT
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
		- 20200110@Hogan: Create stored procedure OIC_LicenseeGroupDel [RedmineID: #126855]
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
	
	DECLARE @Name NVARCHAR(100)
	        ,@ParentName NVARCHAR(100) = NULL

	SET @startRun = GETDATE()
	
	SET @xml = (
		SELECT  g.Id	 AS '@lgi' 
				,g.Name  AS '@lgn'
				,pg.Name AS '@lgp'
		FROM	dbo.LicenseeGroup g WITH(NOLOCK)
			LEFT JOIN dbo.LicenseeGroup pg WITH(NOLOCK)
				ON g.ParentId = pg.Id
		WHERE	g.Id = @Id
		FOR XML PATH('r'), TYPE
		)
	
	IF EXISTS (SELECT TOP(1) 1 FROM dbo.LicenseeGroup WITH(NOLOCK) WHERE ParentId = @Id)
	BEGIN
		SELECT	@ErrCode = 103
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40020, @Language) -- Unable to delete the Client Group because it's containing one or more Client Group(s)
		RETURN
	END
	
	IF EXISTS (SELECT TOP(1) 1 FROM dbo.Licensee WITH(NOLOCK) WHERE LicenseeGroupId = @Id)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40014, @Language) -- Unable to delete the group of licensee because one or many assigned client(s) or user(s) exist(s)
		RETURN
	END

	BEGIN TRY
		DELETE
		FROM	dbo.LicenseeGroup WITH(ROWLOCK, UPDLOCK)
		WHERE	Id = @Id
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40015, @Language) -- Fail to delete group of licensee. Please try again.
		RETURN
	END CATCH

	SELECT @logSPData	= CONVERT(NVARCHAR(MAX), @xml)
		,@endRun		= GETDATE()
		,@duration		= DATEDIFF(MILLISECOND, @startRun, @endRun)   
		,@procName		= OBJECT_NAME(@@PROCID)

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
