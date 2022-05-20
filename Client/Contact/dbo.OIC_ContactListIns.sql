/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[OIC_ContactListIns]
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
    Date: 2022-03-04
    Task: Enhance function to copy contact list for licensees [Redmine:#161538]
	Remark: Parent SP: OIC_ContactListCopy
    DB: DBOIC/BODB_OIC 
    
    Revisions:
		- 20220304@Kai: Copy contact list for licensees [RedmindId: #161538]
    
    Param's Explanation:
		*@SelectedContact: XML format
			<r> 
				<row cid="93" lid="21" lc="0" llct="1" llcn="Finance Team" lcp="Group" lcd="Finance Settlement" lce="oic_finapproval@pacificseainvests.com" lcs="finance"  ccl="categories name" tol="categories name"/>
				<row cid="94" lid="21" lc="0" llct="1" llcn="Jeffrey" lcp="NA" lcd="CSD" lce="oic_Jeffrey@pacificseainvests.com" lcs="a"  ccl="categories name" tol="categories name"/>
			</r> 
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
		,@log_category	XML

		,@tempStartRun	DATETIME
		,@tempEndRun	DATETIME
	
	SET @startRun = GETDATE()
	DECLARE @xml XML -- write log
	DECLARE @tblCopyContactId TABLE (ContactId INT)
	DECLARE @tmpContactId INT
	DECLARE @tmpCopyContactId INT
	DECLARE @dataTmp XML
	DECLARE @tblSelectedContact TABLE (ContactId INT,LicenseeId INT, IsLicenseeContact BIT, ContactType TINYINT, ContactName NVARCHAR(50), ContactPosition NVARCHAR(50), ContactDepartment NVARCHAR(50), ContactEmail NVARCHAR(50), ContactSkype NVARCHAR(50), ContactPhoneNumber NVARCHAR(50), ContactLandline NVARCHAR(50), Remark NVARCHAR(300), ToList VARCHAR(MAX), CcList VARCHAR(MAX))
	
	--Copy Contacts from Original Site to Replicate Site
	
	SET @dataTmp = CONVERT(XML, @SelectedContact)
	
	INSERT @tblSelectedContact
	SELECT 
		d.c.value('@cid', 'INT') AS ContactId, -- contact id
		d.c.value('@lid', 'INT') AS LicenseeId, -- client id
		d.c.value('@lc', 'NVARCHAR(10)') AS IsLicenseeContact, -- licenseee contact
		d.c.value('@llct', 'NVARCHAR(10)') AS ContactType, -- contact type
		d.c.value('@llcn', 'NVARCHAR(100)') AS ContactName, -- contact name
		d.c.value('@lcp', 'NVARCHAR(100)') AS ContactPosition, -- contact position
		d.c.value('@lcd', 'NVARCHAR(100)') AS ContactDepartment, -- contact department
		d.c.value('@lce', 'NVARCHAR(50)') AS ContactEmail, -- contact email
		d.c.value('@lcs', 'NVARCHAR(50)') AS ContactSkype, -- contact skype
		d.c.value('@lcpn', 'NVARCHAR(50)') AS ContactPhoneNumber, -- contact mobile phone
		d.c.value('@lcll', 'NVARCHAR(50)') AS ContactLandline, -- contact landline
		d.c.value('@lcr', 'NVARCHAR(600)') AS Remark, -- contact remark
		d.c.value('@tol', 'VARCHAR(MAX)') AS ToList, -- ToList
		d.c.value('@ccl', 'VARCHAR(MAX)') AS CcList -- CcList
	FROM  @dataTmp.nodes('r/row') d(c)

	IF EXISTS(SELECT TOP 1 1 FROM (
			SELECT	slct.ContactId,
					slct.LicenseeId,
					slct.IsLicenseeContact,
					slct.ContactType, 
					slct.ContactName, 
					slct.ContactPosition, 
					slct.ContactDepartment, 
					slct.ContactEmail, 
					slct.ContactSkype, 
					slct.ContactPhoneNumber, 
					slct.ContactLandline, 
					slct.Remark,
					slct.ToList,
					slct.CcList
			FROM @tblSelectedContact slct
			EXCEPT 
			SELECT	ct.ContactId,
					ct.LicenseeId, 
					ct.IsLicenseeContact, 
					ct.ContactType, 
					ct.ContactName, 
					ct.ContactPosition, 
					ct.ContactDepartment, 
					ct.ContactEmail, 
					ct.ContactSkype, 
					ct.ContactPhoneNumber, 
					ct.ContactLandline, 
					ct.Remark,
					(SELECT STUFF ((SELECT ', ' + c.CategoryName
					FROM dbo.CategoryContact cc WITH(NOLOCK)
						INNER JOIN dbo.Category c WITH(NOLOCK) 
							ON c.CategoryId = cc.CategoryID
					WHERE cc.ContactID = ct.ContactID 
							AND cc.RecipientType = 0 
					FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'),1,2,'')) AS ToList,
					(SELECT STUFF ((SELECT ', ' + c.CategoryName
					FROM dbo.CategoryContact cc WITH(NOLOCK)
						INNER JOIN dbo.Category c WITH(NOLOCK) 
							ON c.CategoryId = cc.CategoryID
					WHERE cc.ContactID = ct.ContactID 
							AND cc.RecipientType = 1
					FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'),1,2,'')) AS CcList
			FROM dbo.Contact ct WITH(NOLOCK)
			WHERE ct.LicenseeId = @OriginalSite) ct)
	BEGIN
		SELECT	@ErrCode = 103
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](502, @Language) -- Someone has changed the original contact list. Please try again
		RETURN
	END

	WHILE 1=1
	BEGIN
		SELECT @tmpContactId = NULL, @tmpCopyContactId = NULL

		SELECT TOP 1 @tmpContactId = ContactId FROM @tblSelectedContact
		IF @tmpContactId IS NULL
			BREAK
		
		DELETE @tblSelectedContact WHERE ContactId = @tmpContactId
		
		BEGIN TRY
			INSERT INTO dbo.Contact(LicenseeId, ContactName, ContactPosition, ContactDepartment, ContactEmail, ContactSkype, ContactPhoneNumber, ContactLandline, ContactType, Remark, IsMain, IsLicenseeContact)
			OUTPUT inserted.ContactId INTO @tblCopyContactId
			SELECT @ReplicateSite, ct.ContactName, ct.ContactPosition, ct.ContactDepartment, ct.ContactEmail, ct.ContactSkype, ct.ContactPhoneNumber, ct.ContactLandline, ct.ContactType, ct.Remark, 0, ct.IsLicenseeContact
			FROM dbo.Contact ct WITH(NOLOCK)
			WHERE ct.ContactId = @tmpContactId

			SET @tmpCopyContactId = Scope_Identity()
			
			INSERT INTO dbo.CategoryContact (
					ContactID
					,CategoryID
					,RecipientType
			)
			SELECT	@tmpCopyContactId
					,cc.CategoryId
					,cc.RecipientType
			FROM dbo.CategoryContact cc WITH(NOLOCK)
			WHERE cc.ContactId = @tmpContactId	

		END TRY
		BEGIN CATCH
			SELECT	@ErrCode = 101
					,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](503, @Language) -- Failed to copy contact. Please try again!
			RETURN
		END CATCH

	
	END
	
	IF @@ERROR <> 0
	BEGIN
		-- Rollback
		SELECT TOP 1 @tmpCopyContactId = ContactId FROM @tblCopyContactId
		IF @tmpCopyContactId IS NULL
			RETURN

		DELETE FROM dbo.Contact WITH(ROWLOCK, UPDLOCK)
		WHERE ContactID IN (SELECT ContactId FROM @tblCopyContactId)

		DELETE FROM dbo.CategoryContact WITH(ROWLOCK, UPDLOCK)
		WHERE ContactID IN (SELECT ContactId FROM @tblCopyContactId)
		
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](503, @Language) -- Failed to copy contact. Please try again!
		RETURN
		
	END

	--Write log
	SELECT @procName = OBJECT_NAME(@@PROCID)
			,@tempEndRun = GETDATE()

	WHILE 1=1
	BEGIN
		SELECT @tmpCopyContactId = NULL
			,@tempStartRun = GETDATE()

		SELECT TOP 1 @tmpCopyContactId = ContactId FROM @tblCopyContactId
		IF @tmpCopyContactId IS NULL
			BREAK

		DELETE @tblCopyContactId WHERE ContactId = @tmpCopyContactId

		SET @log_category = (
						SELECT c.CategoryName AS '@cn'
								,cc.RecipientType AS '@ct'
						FROM dbo.Category AS c WITH (NOLOCK)
							INNER JOIN dbo.CategoryContact AS cc WITH(NOLOCK) 
								ON c.CategoryId = cc.CategoryID
						WHERE cc.ContactID = @tmpCopyContactId
						FOR XML PATH('row'), ROOT('cc')	
			)
					
		SET @xml = (
			SELECT	@tmpCopyContactId		AS '@lcid'
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
			WHERE	c.ContactID = @tmpCopyContactId
			FOR XML PATH('r'), TYPE
			)		
		
		SELECT @logSPData = CONVERT(NVARCHAR(MAX),@xml)
			,@endRun	= GETDATE()  
			,@duration	= DATEDIFF(MILLISECOND, @startRun, @tempEndRun)  + DATEDIFF(MILLISECOND, @tempStartRun, @endRun) 
			,@procName	= OBJECT_NAME(@@procid)

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
