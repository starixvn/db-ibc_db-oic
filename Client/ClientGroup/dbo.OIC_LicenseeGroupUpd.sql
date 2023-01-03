/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeGroupUpd] 
	@Id						INT
	,@Name					NVARCHAR(100)
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
		- 20200110@Hogan: Create stored procedure OIC_LicenseeGroupUpd [RedmineID: #126855]
		- 20221206@Cody: Enhance Client group [RedmineId: #174401]
 */

BEGIN
	SET NOCOUNT ON

	DECLARE @tblLicenseeGroupId TABLE (Id INT)

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
	
	IF EXISTS (SELECT TOP(1) 1 FROM dbo.LicenseeGroup WITH(NOLOCK) WHERE Name = @Name AND Id <> @Id)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40011, @Language) -- The licensee group name is already used. Please try another name.
		RETURN
	END

	;WITH cteLicenseeGroupId
	AS 
	(
		SELECT Id
		FROM LicenseeGroup WITH(NOLOCK)
		WHERE Id = @Id
		UNION ALL
		SELECT lp.Id
		FROM LicenseeGroup lp WITH(NOLOCK)
			INNER JOIN cteLicenseeGroupId c
				ON lp.ParentId = c.Id
	)
	INSERT INTO @tblLicenseeGroupId (Id)		
	SELECT Id
	FROM cteLicenseeGroupId WITH(NOLOCK)

	IF ((@ParentId IS NOT NULL) AND (NOT EXISTS(SELECT TOP(1) 1 FROM dbo.LicenseeGroup WITH(NOLOCK) WHERE Id = @ParentId)))
	   OR (NOT EXISTS(SELECT TOP(1) 1 FROM dbo.LicenseeGroup WITH(NOLOCK) WHERE Id = @Id))
	   OR (EXISTS (SELECT TOP(1) 1 FROM @tblLicenseeGroupId WHERE Id = @ParentId))
	BEGIN
		SELECT	@ErrCode = 102
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40019, @Language) -- Unable to edit because data is out of date. Please try again!
		RETURN
	END

	-- get old data
	
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
		
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)

	BEGIN TRY
		UPDATE	dbo.LicenseeGroup WITH(ROWLOCK, UPDLOCK)
			SET	Name = @Name
				,ParentId = @ParentId
		WHERE	Id = @Id	
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40012, @Language) -- Fail to edit group of licensee. Please try again.	
		RETURN
	END CATCH
	
	DECLARE @ParentName NVARCHAR(100) = NULL
	
	SELECT @ParentName = Name
	FROM dbo.LicenseeGroup WITH(NOLOCK)
	WHERE Id = @ParentId
	
	SET @xml = (
		SELECT	Id    AS '@lgi'
				,Name AS '@lgn'
				,@ParentName AS '@lgp'
		FROM	dbo.LicenseeGroup WITH(NOLOCK)
		WHERE	Id = @Id
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
