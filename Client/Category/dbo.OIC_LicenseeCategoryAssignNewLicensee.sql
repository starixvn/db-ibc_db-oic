/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeCategoryAssignNewLicensee] 
	 @LicenseeId		INT
	,@UserId			INT
	,@ExtraInfo			NVARCHAR(100)	= NULL
	,@Language			VARCHAR(10)		= 'E'
	,@IP				VARCHAR(50)		= NULL
	,@ErrCode			INT				= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Creator: Kai
	Date: 2022-03-18
	DB: DBOIC.bodb_OIC
	Task: Enhance New Client [Redmine:#169959]
	Remark: Parent SP: OIC_LicenseeInfoIns

	Revisions:
		- 20220318@Kai: Enhance New Client [Redmine:#169959]
		- 20240229@Kai: Support write logs with ExtraInfo [Redmine:#197581]
	
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

	DECLARE @tblLicenseeCategoryAssigned TABLE(LicenseeId INT, CategoryId TINYINT)
	INSERT INTO @tblLicenseeCategoryAssigned (LicenseeId, CategoryId)
	SELECT @LicenseeId AS LicenseeId, CategoryId
	FROM dbo.Category WITH(NOLOCK)
		
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
		-- Rollback
		DELETE lca 
		FROM dbo.LicenseeCategoryAssigned lca WITH(ROWLOCK, UPDLOCK)
			INNER JOIN @tblLicenseeCategoryAssigned tlca ON lca.CategoryId = tlca.CategoryId AND lca.LicenseeId = tlca.LicenseeId

		DELETE cc
		FROM dbo.CategoryContact cc WITH(ROWLOCK, UPDLOCK)
			INNER JOIN dbo.Contact ct WITH(NOLOCK) ON cc.ContactId = ct.ContactId
			INNER JOIN @tblLicenseeCategoryAssigned tlca ON cc.CategoryId = tlca.CategoryId
		WHERE ct.LicenseeId = @LicenseeId AND ct.IsMain = 1
		
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1500, @Language) -- Fail to assign category(ies). Please try again
		RETURN
	END CATCH

	-- write log
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
				WHERE l.LicenseeId = @LicenseeId
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
		,@ExtraInfo		= @ExtraInfo
END