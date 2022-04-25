/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_API_LicenseeContactDel]
	 @ContactId			INT
	,@SiteId			INT
	,@SiteName			NVARCHAR(50)
	,@SubsidiaryList	VARCHAR(1000)
	,@UserName			NVARCHAR(50)
	,@Language			VARCHAR(10)		= 'E'
	,@IP				VARCHAR(50)		= NULL
	,@ErrCode			INT				= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Howard
	Date: 2022-02-14
	Task: Add new licensee contact from external system (LAP) [Redmine:#165286]
	DB: DBOIC.bodb_OIC 
	
	Revisions:
		- 20220214@Howard: Init [Redmine:#165286]
		- 20220424@Howard: Support Subsidiary business [Redmine:#170641]
	
	Param's Explanation:
	- @SiteId: -1 - LAP
	*
*/
BEGIN
	SET NOCOUNT ON


	DECLARE @LicenseeId INT

	SELECT @LicenseeId = l.LicenseeId
	FROM dbo.Licensee l WITH(NOLOCK)
	WHERE l.RegisteredLicenseeName = @SiteName

	IF(@LicenseeId IS NULL) 
	BEGIN
			SELECT	@ErrCode = 101
				,@ErrMsg = 'SiteName does not exist.'
		RETURN
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.Contact c WITH(NOLOCK) WHERE c.ContactId = @ContactId AND c.LicenseeId = @LicenseeId AND c.IsLicenseeContact = 1
						AND ',' + @SubsidiaryList + ',' LIKE '%,' + ISNULl(c.Subsidiary, @SiteName) + ',%')
	BEGIN
		SELECT	@ErrCode = 102
				,@ErrMsg = 'Contact does not exist.'
		RETURN
	END

    -- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)
		,@extraInfo		NVARCHAR(100)
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
				,c.Subsidiary			AS '@lcsub'
				,c.IsLicenseeContact	AS '@lc'
				,@log_category
		FROM dbo.Contact c WITH(NOLOCK)
		WHERE c.ContactID = @ContactId AND c.LicenseeId = @LicenseeId
		FOR XML PATH('r'), TYPE
		)		
		
	SELECT	@logSPData = CONVERT(NVARCHAR(MAX),@xml)
	

		DELETE 
		FROM dbo.Contact WITH(ROWLOCK, UPDLOCK)
		WHERE ContactID = @ContactId
		
		IF @@ERROR <> 0
		BEGIN
			SELECT	@ErrCode = 100
					,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](502, @Language) -- Failed to delete contact. Please try again!
			RETURN
		END
	
	
	SELECT	@endRun		= GETDATE()  
			,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
			,@procName	= 'OIC_LicenseeContactDel'
			,@extraInfo = @SiteName + '/' + @UserName

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @SiteId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= NULL
		,@OldData		= @logSPData
		,@Duration		= @Duration
		,@ExtraInfo		= @extraInfo
END

GO
