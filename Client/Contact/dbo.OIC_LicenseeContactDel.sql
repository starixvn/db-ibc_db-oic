/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeContactDel]
	@ContactId		INT
	
	,@UserId		INT
	,@Language		VARCHAR(10)		= 'E'
	,@IP			VARCHAR(50)		= NULL
	,@ErrCode		INT				= 0			OUTPUT
	,@ErrMsg		VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2015-02-09
	Task: Delete licensee contact [Redmine:#29610]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20220218@Kai: New Licensee Contact function [Redmine:#165286]
		- 20220505@Kai: Add Subsidiary for Licensee Contact [Redmine:#170641]
		- 20220530@Kai: Manage the main contact of licensee [Redmine:#172568]
	
	Param's Explanation:
	*
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
		,@log_category	XML
		
	SET @startRun = GETDATE()

	-- Write log
	-- get data to write log
	SET @log_category = (
						SELECT c.CategoryName AS '@cn'
								,cc.RecipientType AS '@ct'
						FROM dbo.Category AS c WITH (NOLOCK)
							INNER JOIN dbo.CategoryContact AS cc WITH(NOLOCK) 
								ON c.CategoryId = cc.CategoryID
						WHERE cc.ContactID = @ContactId
						FOR XML PATH('row'), ROOT('cc')	
					)

	SET @xml = (
		SELECT	@ContactId				AS '@lcid'
				,LicenseeId				AS '@lid'
				,c.ContactName			AS '@lccn'			
				,c.ContactPosition		AS '@lcp'
				,c.ContactDepartment	AS '@lcd'
				,c.ContactEmail			AS '@lce'
				,c.ContactSkype			AS '@lcs'
				,c.ContactPhoneNumber	AS '@lcpn'
				,c.ContactLandline		AS '@lcll'
				,c.ContactType			AS '@lcct'
				,c.Remark				AS '@lcr'
				,c.IsLicenseeContact	AS '@lc'
				,c.Subsidiary			AS '@lcsub'
				,@log_category
		FROM dbo.Contact c WITH(NOLOCK)
		WHERE c.ContactID = @ContactId
		FOR XML PATH('r'), TYPE
		)		
		
	SELECT	@logSPData = CONVERT(NVARCHAR(MAX),@xml)
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.Contact WITH(NOLOCK) WHERE ContactID = @ContactId)
	BEGIN
		DELETE 
		FROM dbo.Contact WITH(ROWLOCK, UPDLOCK)
		WHERE	ContactID = @ContactId

		-- Remove all categories assigned contact
		DELETE cct
		FROM dbo.CategoryContact cct WITH(ROWLOCK, UPDLOCK)
		WHERE cct.ContactId = @ContactId

		IF @@ERROR <> 0
		BEGIN
			SELECT	@ErrCode = 100
					,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](502, @Language) -- Failed to delete contact. Please try again!
			RETURN
		END
	END
	
	
	SELECT	@endRun		= GETDATE()  
			,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
			,@procName	= OBJECT_NAME(@@PROCID)

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