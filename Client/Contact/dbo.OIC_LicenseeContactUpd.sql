/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeContactUpd]
	@ContactId				INT
	,@LicenseeId			INT
	,@ContactType			BIT
	,@IsLicenseeContact		BIT
	,@ContactName			NVARCHAR(50)
	,@Position				NVARCHAR(50)
	,@Department			NVARCHAR(50) 
	,@Email					VARCHAR(50)
	,@Skype					VARCHAR(50)
	,@PhoneNumber			VARCHAR(50)		= NULL
	,@LandLine				VARCHAR(50)		= NULL
	,@Remark				NVARCHAR(300)	= NULL
	
	,@SelectedCategories	XML				= NULL 
	
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2015-02-09
	Task: Update licensee contact [Redmine:#30037]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20220117@Kai: New Licensee Contact function [Redmine:#165286]
	
	Param's Explanation:
	- @SelectedCategories: NULL: no changing
							<> NULL: changed data
*/
BEGIN
	SET NOCOUNT ON
	
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@logSPOldData	NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)
		
		,@log_category	XML
	
	DECLARE @tblCategoryContact TABLE (CategoryId INT, RecipientType TINYINT)

	SET @startRun = GETDATE()			
	
	-- get data to write log before doing	
	IF @SelectedCategories IS NOT NULL
	BEGIN
		SET @log_category = (
							SELECT	c.CategoryName		AS '@cn'
									,cc.RecipientType	AS '@ct'
							FROM	dbo.Category AS c WITH (NOLOCK)
								INNER JOIN dbo.CategoryContact AS cc WITH(NOLOCK) 
									ON	c.CategoryId = cc.CategoryID
							WHERE	cc.ContactID = @ContactId
							FOR XML PATH('row'), ROOT('cc')	
						)
	END
					
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
				,@log_category
		FROM dbo.Contact AS c WITH (NOLOCK)
		WHERE c.ContactID = @ContactId
		FOR XML PATH('r'), TYPE
		)		
		
	SELECT @logSPOldData = CONVERT(NVARCHAR(MAX),@xml)
	
	BEGIN TRY
		UPDATE	dbo.Contact WITH(ROWLOCK, UPDLOCK)
			SET LicenseeID			= @LicenseeId
				,ContactType		= @ContactType
				,IsLicenseeContact	= @IsLicenseeContact
				,ContactName		= @ContactName
				,ContactPosition	= @Position
				,ContactDepartment	= @Department
				,ContactEmail		= @Email
				,ContactSkype		= @Skype
				,ContactPhoneNumber	= @PhoneNumber
				,ContactLandline	= @Landline
				,Remark				= @Remark
		WHERE	ContactID = @ContactId
		
		IF @SelectedCategories IS NOT NULL
		BEGIN
		
			;WITH selectedCategory
			AS (
				SELECT	t.c.value('@id','int') CategoryId
						,t.c.value('@type', 'bit') AS Value
				FROM	@SelectedCategories.nodes('root/row') t(c)
			)
			INSERT INTO @tblCategoryContact (
					CategoryID
					,RecipientType
			)
			SELECT	s.CategoryId
					,s.Value
			FROM	selectedCategory s 
				INNER JOIN dbo.LicenseeCategoryAssigned l WITH(NOLOCK)
					ON	s.CategoryId = l. CategoryId
						AND l.LicenseeId = @LicenseeId					
			
			MERGE	dbo.CategoryContact c
			USING	(SELECT * FROM @tblCategoryContact) t
				ON	c.CategoryID = t.CategoryId
					AND c.ContactID = @ContactId
			WHEN MATCHED AND c.RecipientType <> t.RecipientType THEN UPDATE SET c.RecipientType = t.RecipientType
			WHEN NOT MATCHED BY TARGET THEN INSERT (ContactID, CategoryID, RecipientType) VALUES (@ContactId, t.CategoryId, t.RecipientType)
			WHEN NOT MATCHED BY SOURCE AND c.ContactId = @ContactId THEN DELETE;
		END
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](501,@Language) -- Failed to edit contact. Please try again!		
		RETURN
	END CATCH	
	
	-- Write log
	-- get data to write log
	IF @SelectedCategories IS NOT NULL
	BEGIN
		SET @log_category = (
							SELECT	c.CategoryName		AS '@cn'
									,cc.RecipientType	AS '@ct'
							FROM	dbo.Category AS c WITH (NOLOCK)
								INNER JOIN dbo.CategoryContact AS cc WITH(NOLOCK) 
									ON	c.CategoryId = cc.CategoryID
							WHERE	cc.ContactID = @ContactId
							FOR XML PATH('row'), ROOT('cc')	
						)
	END
					
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
				,@log_category
		FROM dbo.Contact AS c WITH (NOLOCK)
		WHERE c.ContactID = @ContactId
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
		,@OldData		= @logSPOldData
		,@Duration		= @Duration
END
GO