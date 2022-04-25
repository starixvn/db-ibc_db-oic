/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_API_LicenseeContactIns]
	 @SiteId				INT
	,@SiteName			    NVARCHAR(50)
	,@SubsidiaryList		VARCHAR(1000)
	,@UserName				NVARCHAR(50)
	,@ContactType			BIT
	,@ContactName			NVARCHAR(50)
	,@Position				NVARCHAR(50)
	,@Department			NVARCHAR(50) 
	,@Email					VARCHAR(50)
	,@Skype					VARCHAR(50)
	,@Remark				NVARCHAR(300)	= NULL
	,@Subsidiary			VARCHAR(50)		= NULL
	,@SelectedCategories	XML
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
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
	- @ContactType: 0 - Individual
					1 - Group
	- @SelectedCategorie: 
		<root>
			<row id="1" type="1" />
			<row id="2" type="0" />
		</root>
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LicenseeId INT
	DECLARE @ContactId INT

	SELECT @LicenseeId = l.LicenseeId
	FROM dbo.Licensee l WITH(NOLOCK)
	WHERE l.RegisteredLicenseeName =  @SiteName

	IF(@LicenseeId IS NULL) 
	BEGIN
			SELECT	@ErrCode = 101
				,@ErrMsg = 'SiteName does not exist.'
		RETURN
	END

	IF(',' + @SubsidiaryList + ',' NOT LIKE '%,' + ISNULl(@Subsidiary, @SiteName) + ',%') 
	BEGIN
			SELECT	@ErrCode = 103
				,@ErrMsg = 'Subsidiary does not exist.'
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
		,@log_category	XML
		,@extraInfo		NVARCHAR(100)

	SET @startRun = GETDATE()			
	
	BEGIN TRY
		INSERT INTO dbo.Contact (
			LicenseeID
			,ContactName
			,ContactPosition
			,ContactDepartment
			,ContactEmail
			,ContactSkype
			,ContactType
			,Remark
			,Subsidiary
			,IsLicenseeContact
		)
		VALUES(
			@LicenseeId
			,@ContactName
			,@Position
			,@Department
			,@Email
			,@Skype
			,@ContactType
			,@Remark
			,@Subsidiary
			,1
		)
	
	SET @ContactId = SCOPE_IDENTITY()
	
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 102
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](500, @Language) -- Failed to add new contact. Please try again
		RETURN
	END CATCH
	
	;WITH selectedCategory
	AS (
		SELECT	@ContactId				AS ContactId
			,t.c.value('@id','int')		AS CategoryId
			,t.c.value('@type', 'bit')	AS Value
		FROM @SelectedCategories.nodes('root/row') t(c)
	)
	INSERT INTO dbo.CategoryContact (
			ContactID
			,CategoryID
			,RecipientType
	)
	SELECT	ContactId
			,s.CategoryId
			,s.Value
	FROM selectedCategory s 
		INNER JOIN dbo.LicenseeCategoryAssigned l WITH(NOLOCK) ON s.CategoryId = l.CategoryId AND l.LicenseeId = @LicenseeId	
	
	IF @@ERROR <> 0
	BEGIN
		DELETE FROM dbo.Contact WITH(ROWLOCK, UPDLOCK)
		WHERE ContactID = @ContactId
		
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](500, @Language) -- 
		RETURN
	END
	
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
				,c.ContactType			AS '@lcct'
				,c.Remark				AS '@lcr'
				,c.Subsidiary			AS '@lcsub'
				,c.IsLicenseeContact	AS '@lc'
				,@log_category
		FROM dbo.Contact AS c WITH (NOLOCK)
		WHERE	c.ContactID = @ContactId
		FOR XML PATH('r'), TYPE
		)		
		
	SELECT @logSPData = CONVERT(NVARCHAR(MAX),@xml)
		,@endRun	= GETDATE()  
		,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
		,@procName	= 'OIC_LicenseeContactIns'
		,@extraInfo = @SiteName + '/' + @UserName

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @SiteId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration
		,@ExtraInfo		= @extraInfo
	
END

GO
