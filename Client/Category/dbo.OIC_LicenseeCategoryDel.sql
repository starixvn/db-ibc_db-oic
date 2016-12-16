USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeCategoryDel] 
	@SelectedCategory	VARCHAR(500)
	,@SelectedLicensee	VARCHAR(500)
	
	,@UserId			INT
	,@Language			VARCHAR(10)		= 'E'
	,@IP				VARCHAR(50)		= NULL
	,@ErrCode			INT				= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Creator: Percy
	Date: 2016-09-28
	DB: DBOIC.bodb_OIC
	Task: Insert Category of Licensee
	Remark: Parent SP: OIC_LicenseeCategoryManage @ActionID = 0 -- Remove

	Revisions:

	Param's Explanation:
		*@SelectedLicensee: '1,2,3,4'
		*@SelectedCategory: '1,2,3,4'
*/
BEGIN
	SET NOCOUNT ON

	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPOldData	NVARCHAR(MAX)
		,@procName		VARCHAR(200)

		,@tempStartRun	DATETIME
		,@tempEndRun	DATETIME
	
	SET @startRun = GETDATE()

	DECLARE @xml XML -- write old data before remove

	DECLARE @tblLicenseeCategoryAssigned TABLE (LicenseeId INT, CategoryId TINYINT)
	INSERT INTO @tblLicenseeCategoryAssigned (LicenseeId, CategoryId)
	SELECT LicenseeId, CONVERT(INT, s.val) AS CategoryId
	FROM (
		SELECT CONVERT(INT, val) AS LicenseeId
		FROM dbo.strSplit(@SelectedLicensee, ',')
	) t
		CROSS APPLY dbo.strSplit(@SelectedCategory,',') s
		
	----Validate input param:
	DELETE	t
	FROM @tblLicenseeCategoryAssigned t
	WHERE t.LicenseeId NOT IN (SELECT l.LicenseeId
								FROM dbo.LicenseeCategoryAssigned l WITH(NOLOCK) 
								WHERE l.CategoryId = t.CategoryId
							)
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM @tblLicenseeCategoryAssigned)
	BEGIN
		SELECT @ErrCode = 104
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1505, @Language) -- Cannot retract selected categories from clients because all of them do not have these categories.
		RETURN
	END
		
	BEGIN TRY
		DELETE lc
		FROM dbo.LicenseeCategoryAssigned lc
		WHERE lc.LicenseeId IN (SELECT t.LicenseeId
								FROM @tblLicenseeCategoryAssigned t 
								WHERE t.CategoryId = lc.CategoryId
							)
								
		-- Remove contacts have been assigned by Category
		DELETE cc
		FROM dbo.CategoryContact cc
			INNER JOIN dbo.Contact c WITH(NOLOCK) 
				ON c.ContactID = cc.ContactID 
					AND c.LicenseeID IN (SELECT LicenseeId FROM @tblLicenseeCategoryAssigned)
					AND cc.CategoryID IN (SELECT CategoryId FROM @tblLicenseeCategoryAssigned)
			
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 102
			,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1501, @Language) -- Fail to dissociate category(ies). Please try again.
		RETURN
	END CATCH

	SELECT  @procName = OBJECT_NAME(@@PROCID)
			,@tempEndRun = GETDATE()
				
	DECLARE @LicenseeCategory TABLE (LicenseeId INT, CategoryId TINYINT)
	DECLARE @LicenseeId INT

	WHILE 1=1
	BEGIN
		SELECT @tempStartRun = GETDATE(), @LicenseeId = NULL
		DELETE @LicenseeCategory

		SELECT TOP 1 @LicenseeId = LicenseeId FROM @tblLicenseeCategoryAssigned
		IF @LicenseeId IS NULL
			BREAK

		DELETE @tblLicenseeCategoryAssigned OUTPUT DELETED.LicenseeId, DELETED.CategoryId INTO @LicenseeCategory WHERE LicenseeId = @LicenseeId

		SET @xml = (SELECT	l.LicenseeId	AS '@lid'
							,l.LicenseeName AS '@ln'
							,(SELECT c.CategoryId		AS '@cid'
									,c.CategoryName		AS '@cn'
								FROM dbo.Category c WITH(NOLOCK)
									INNER JOIN @LicenseeCategory lc ON c.CategoryId = lc.CategoryId
								FOR XML PATH('row'), ROOT('c'), TYPE
							)
					FROM dbo.Licensee l WITH(NOLOCK)
					WHERE l.LicenseeId = @LicenseeId
					FOR XML PATH('r'), TYPE
					)
		SELECT @logSPOldData = CONVERT(NVARCHAR(MAX), @xml)

		SELECT	@endRun		= GETDATE()  
				,@duration	= DATEDIFF(MILLISECOND, @startRun, @tempEndRun) + DATEDIFF(MILLISECOND, @tempStartRun, @endRun)

		EXEC dbo.OIC_LogRunSpIns
			@UserId			= @UserId
			,@SPName		= @procName
			,@Language		= @Language
			,@IP			= @IP
			,@Data			= NULL
			,@OldData		= @logSPOldData
			,@Duration		= @Duration
	END
END
GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeCategoryDel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LicenseeCategoryDel] TO [vnteam] AS [dbo]
GO