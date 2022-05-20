/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_ContactListCopy]
	@SelectedContact		NVARCHAR(MAX)    = ''
	,@SelectedCategories	VARCHAR(MAX)    = ''
    ,@OriginalSite			INT
	,@ReplicateSite			INT

	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS  
/*
    Created by: Kai
    Date: 2022-03-08
    Task: Enhance function to copy contact list for licensees [Redmine:#161538]
    DB: DBOIC/BODB_OIC 
    
    Revisions:
		- 20220308@Kai: Copy contact list for licensees [RedmindId: #161538]
    
    Param's Explanation:
		*@SelectedContact: XML format
			<r> 
				<row cid="93" lid="21" lc="0" llct="1" llcn="Finance Team" lcp="Group" lcd="Finance Settlement" lce="oic_finapproval@pacificseainvests.com" lcs="finance ccl="categories name" tol="categories name"/>
				<row cid="94" lid="21" lc="0" llct="1" llcn="Jeffrey" lcp="NA" lcd="CSD" lce="oic_Jeffrey@pacificseainvests.com" lcs="a" ccl="categories name" tol="categories name"/>
			</r> 
		*@OriginalSite: '321'
		*@ReplicateSite: '123'
*/ 
BEGIN  
	SET NOCOUNT ON
	DECLARE @LogId INT
	DECLARE @CategoryAssigned VARCHAR(1000)

	-- Assign Categories from orginal site to replicate site 
	EXEC [dbo].[OIC_LicenseeCategoryListIns]  
		@OriginalSite			= @OriginalSite
		,@ReplicateSite			= @ReplicateSite
		,@SelectedCategories	= @SelectedCategories

		,@UserId				= @UserId
		,@Language				= @Language
		,@IP					= @IP
		,@ErrCode				= @ErrCode	OUTPUT
		,@ErrMsg				= @ErrMsg	OUTPUT
		,@LogId					= @LogId	OUTPUT
		,@CategoryAssigned		= @CategoryAssigned OUTPUT

	IF @ErrCode = 0
	BEGIN
		-- Copy list selected Contact from orginal site to replicate site 
		EXEC [dbo].[OIC_ContactListIns]
				@SelectedContact   = @SelectedContact
			,@OriginalSite		= @OriginalSite
			,@ReplicateSite		= @ReplicateSite

			,@UserId			= @UserId
			,@Language			= @Language
			,@IP				= @IP
			,@ErrCode			= @ErrCode	OUTPUT
			,@ErrMsg			= @ErrMsg	OUTPUT

		IF @ErrCode <> 0
		BEGIN
			--Rollback step assign categories from original site to replicate site
			DELETE FROM dbo.LicenseeCategoryAssigned WITH(ROWLOCK, UPDLOCK)
			WHERE LicenseeId = @ReplicateSite AND CategoryId IN (SELECT value FROM STRING_SPLIT(@CategoryAssigned,','))

			DELETE cc
			FROM dbo.CategoryContact cc WITH(ROWLOCK, UPDLOCK)
				INNER JOIN dbo.Contact ct WITH(NOLOCK) ON cc.ContactId = ct.ContactId
			WHERE ct.LicenseeId = @ReplicateSite AND ct.IsMain = 1
				AND cc.CategoryId IN (SELECT value FROM STRING_SPLIT(@CategoryAssigned,','))

			DELETE FROM dbo.UserLog_RunSP WITH(ROWLOCK, UPDLOCK)
			WHERE Id = @LogId

			DELETE FROM dbo.UserLog_RunSP_Detail WITH(ROWLOCK, UPDLOCK)
			WHERE Id = @LogId

			RETURN
		END
	END
END
GO
