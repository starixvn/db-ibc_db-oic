/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_ContactListCopy]
	@SelectedContact	NVARCHAR(MAX)    = ''
    ,@OriginalSite		INT
	,@ReplicateSite		INT

	,@UserId			INT
	,@Language			VARCHAR(10)		= 'E'
	,@IP				VARCHAR(50)		= NULL
	,@ErrCode			INT				= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
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
				<row cid="93" lid="21" lc="0" llct="1" llcn="Finance Team" lcp="Group" lcd="Finance Settlement" lce="oic_finapproval@pacificseainvests.com" lcs="finance"/>
				<row cid="94" lid="21" lc="0" llct="1" llcn="Jeffrey" lcp="NA" lcd="CSD" lce="oic_Jeffrey@pacificseainvests.com" lcs="a"/>
			</r> 
		*@OriginalSite: '321'
		*@ReplicateSite: '123'
*/ 
BEGIN  
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRAN
	BEGIN TRY

	-- Assign Categories from orginal site to replicate site 
	EXEC [dbo].[OIC_LicenseeCategoryListIns]  
		@OriginalSite		= @OriginalSite
		,@ReplicateSite		= @ReplicateSite

		,@UserId			= @UserId
		,@Language			= @Language
		,@IP				= @IP
		,@ErrCode			= @ErrCode	OUTPUT
		,@ErrMsg			= @ErrMsg	OUTPUT

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

	COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT	@ErrCode = 101, 
				@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](503, @Language) -- Failed to copy contact. Please try again!
	END CATCH
END
GO
