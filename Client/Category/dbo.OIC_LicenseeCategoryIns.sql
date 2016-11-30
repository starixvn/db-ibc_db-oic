USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeCategoryIns] 
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
	Remark: Parent SP: OIC_LicenseeCategoryManage @ActionID = 1 -- Add

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
		,@logSPData		NVARCHAR(MAX)
		,@procName		VARCHAR(200)

		,@tempStartRun	DATETIME
		,@tempEndRun	DATETIME
	
	SET @startRun = GETDATE()

	DECLARE @xml XML -- write log

	DECLARE @tblLicenseeCategoryAssigned TABLE(LicenseeId INT, CategoryId TINYINT)
	INSERT INTO @tblLicenseeCategoryAssigned (LicenseeId, CategoryId)
	SELECT LicenseeId, CONVERT(INT, s.val) AS CategoryId
	FROM (
		SELECT CONVERT(INT, val) AS LicenseeId FROM dbo.strSplit(@SelectedLicensee, ',')
	) t
		CROSS APPLY dbo.strSplit(@SelectedCategory,',') s

	DELETE t
	FROM @tblLicenseeCategoryAssigned t
		INNER JOIN LicenseeCategoryAssigned lc WITH(NOLOCK) ON lc.LicenseeId = t.LicenseeId AND lc.CategoryId = t.CategoryId
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM @tblLicenseeCategoryAssigned)
	BEGIN
		SELECT	@ErrCode = 103
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1504, @Language) -- Cannot assign selected categories to clients because all of them already have these categories.
		RETURN
	END
		
	BEGIN TRY		
		INSERT INTO dbo.LicenseeCategoryAssigned (LicenseeId, CategoryId)
		SELECT LicenseeId ,CategoryId
		FROM @tblLicenseeCategoryAssigned
			
		--  Assign the categories to the client main's contact (Cc)
		INSERT INTO dbo.CategoryContact (ContactID, CategoryID, RecipientType)
		SELECT c.ContactID, t.CategoryId, 1 -- Cc
		FROM dbo.Contact c WITH(NOLOCK)
			INNER JOIN @tblLicenseeCategoryAssigned t ON c.LicenseeID = t.LicenseeId AND c.IsMain = 1
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1500, @Language) -- Fail to assign category(ies). Please try again
		RETURN
	END CATCH

	-- write log
	DECLARE @LicenseeCategory TABLE (LicenseeId INT, CategoryId TINYINT)
	DECLARE @LicenseeId INT

	SELECT  @procName = OBJECT_NAME(@@PROCID)
			,@tempEndRun = GETDATE()

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
		SELECT @logSPData = CONVERT(NVARCHAR(MAX), @xml)

		SELECT	@endRun		= GETDATE()  
				,@duration	= DATEDIFF(MILLISECOND, @startRun, @tempEndRun) + DATEDIFF(MILLISECOND, @tempStartRun, @endRun)

		EXEC dbo.OIC_LogRunSpIns
			@UserId			= @UserId
			,@SPName		= @procName
			,@Language		= @Language
			,@IP			= @IP
			,@Data			= @logSPData
			,@OldData		= NULL
			,@Duration		= @Duration
	END
END
GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeCategoryIns] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LicenseeCategoryIns] TO [vnteam] AS [dbo]
GO