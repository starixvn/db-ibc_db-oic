/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeCategoryListIns]   
    @OriginalSite			INT
	,@ReplicateSite			INT
	,@SelectedCategories	VARCHAR(MAX) = ''

	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
	,@LogId					INT							OUTPUT
	,@CategoryAssigned		VARCHAR(1000)				OUTPUT

AS  
/*
    Created by: Kai
    Date: 2022-03-04
    Task: Enhance function to copy contact list for licensees [Redmine:#161538]
	Remark: Parent SP: OIC_ContactListCopy
    DB: DBOIC/BODB_OIC 
    
    Revisions:
		- 20220304@Kai: Copy contact list for licensees [RedmindId: #161538]
    
    Param's Explanation:
		*@OriginalSite: '321'
		*@ReplicateSite: '123'
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
	
	SET @startRun = GETDATE()
	DECLARE @xml XML -- write log

	--Copy Categories from Original Site to Replicate Site
	
	DECLARE @tblLicenseeCategoryAssigned TABLE(LicenseeId INT, CategoryId TINYINT)

	INSERT INTO @tblLicenseeCategoryAssigned (LicenseeId, CategoryId)
	SELECT @ReplicateSite as LicenseeId, lca.CategoryId
	FROM dbo.LicenseeCategoryAssigned lca WITH(NOLOCK)
	WHERE lca.LicenseeId = @OriginalSite

	-- Check someone change original categories
	IF EXISTS (SELECT TOP 1 1 FROM (
		SELECT lca.CategoryId FROM @tblLicenseeCategoryAssigned lca
		EXCEPT
		SELECT CONVERT(tinyint,value) AS CategoryId FROM STRING_SPLIT(@SelectedCategories,','))ca)
	BEGIN
		SELECT	@ErrCode = 104
				,@ErrMsg =  [dbo].[f_Get_MsgNamebyMsgID](504, @Language) -- Someone has changed the original categories, Please try again!
		RETURN
	END

	DELETE t
	FROM @tblLicenseeCategoryAssigned t
		INNER JOIN LicenseeCategoryAssigned lc WITH(NOLOCK) ON lc.LicenseeId = t.LicenseeId AND lc.CategoryId = t.CategoryId
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM @tblLicenseeCategoryAssigned)
	BEGIN
		RETURN -- Cannot assign selected categories to clients because all of them already have these categories.
	END

	BEGIN TRY		
		INSERT INTO dbo.LicenseeCategoryAssigned (LicenseeId, CategoryId)
		SELECT LicenseeId, CategoryId
		FROM @tblLicenseeCategoryAssigned
			
		--  Assign the categories to the client main's contact (Cc)
		INSERT INTO dbo.CategoryContact (ContactID, CategoryID, RecipientType)
		SELECT c.ContactID, t.CategoryId, 1 -- Cc
		FROM dbo.Contact c WITH(NOLOCK)
			INNER JOIN @tblLicenseeCategoryAssigned t ON c.LicenseeId = t.LicenseeId AND c.IsMain = 1

	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1500, @Language) -- Fail to assign category(ies). Please try again
		RETURN
	END CATCH

	IF @@ERROR <> 0
	BEGIN
		-- Rollback
		DELETE FROM dbo.LicenseeCategoryAssigned WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @ReplicateSite AND CategoryId IN (SELECT CategoryId FROM @tblLicenseeCategoryAssigned)

		DELETE cc
		FROM dbo.CategoryContact cc WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.Contact ct WITH(NOLOCK) ON cc.ContactId = ct.ContactId
		WHERE ct.LicenseeId = @ReplicateSite AND ct.IsMain = 1
			AND cc.CategoryId IN (SELECT CategoryId FROM @tblLicenseeCategoryAssigned)
		
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1500, @Language) -- Fail to assign category(ies). Please try again
		RETURN
		
	END

	--Write log
	SELECT  @procName = OBJECT_NAME(@@PROCID)
	
	SET @xml = (SELECT	l.LicenseeId	AS '@lid'
						,l.LicenseeName AS '@ln'
						,(SELECT c.CategoryId		AS '@cid'
						,c.CategoryName		AS '@cn'
						FROM dbo.Category c WITH(NOLOCK)
							INNER JOIN @tblLicenseeCategoryAssigned lc ON c.CategoryId = lc.CategoryId
						FOR XML PATH('row'), ROOT('c'), TYPE
						)
				FROM dbo.Licensee l WITH(NOLOCK)
				WHERE l.LicenseeId = @ReplicateSite
				FOR XML PATH('r'), TYPE
				)
	SELECT @logSPData = CONVERT(NVARCHAR(MAX), @xml)

	SELECT	@endRun		= GETDATE()  
			,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration

	SELECT @LogId = @@IDENTITY
	SELECT @CategoryAssigned = (SELECT STUFF((SELECT ',' + CONVERT(VARCHAR(3), CategoryId) FROM @tblLicenseeCategoryAssigned FOR XML PATH('')), 1, 1, ''))
END
GO
