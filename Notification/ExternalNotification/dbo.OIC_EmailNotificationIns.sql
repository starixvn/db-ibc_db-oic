/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_EmailNotificationIns] 
	@CategoryId				TINYINT
	,@SelectedLicensee		VARCHAR(MAX)	= 'All'
	,@SubjectEn				NVARCHAR(300)
	,@ContentEn				NVARCHAR(MAX)	= ''
	,@ContentCh				NVARCHAR(MAX)	= ''
	,@ContentCs				NVARCHAR(MAX)
	,@MailCCList			XML				= NULL
	
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 20150825
	Task: Insert email notification [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160229@Percy: Change write log when editing email cc list [Redmine: #52857]
		- 20170302@Percy: Expand length of Content [RedmineID: #70322]
		- 20180914@Scofield: Change content display orders of the languages [#100984]
	
	Param's Explanation:
		@MailCCList format:
			<root>
				<row lid="licenseeID" em="cc mail list" @rt="2"/>
			</root>
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT
			,@logSPData		NVARCHAR(MAX)
			,@xml			XML
			,@procName		VARCHAR(200)
			,@MessageId		INT
			,@IsTesting		BIT = 0	
			,@log_recipient	XML
			
	DECLARE @tblLicensee TABLE (LicenseeId INT PRIMARY KEY, LicenseeTypeId TINYINT)
	
	SET @startRun = GETDATE()
	
	INSERT INTO @tblLicensee (LicenseeId, LicenseeTypeId)
	SELECT	LicenseeId, LicenseeTypeId
	FROM	dbo.f_LicenseeBelongToUser(@UserId)
	WHERE	LicenseeId IN (SELECT LicenseeId FROM dbo.LicenseeCategoryAssigned WITH(NOLOCK) WHERE CategoryId = @CategoryId)
			AND (@SelectedLicensee = 'All' OR LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,',')))
			
	IF EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName LIKE 'starix%' AND UserId = @UserId)
		SET @IsTesting = 1
					
	BEGIN TRY
		INSERT INTO dbo.Message 
		(
				ContentEn
				,ContentCh
				,ContentCs
				,MessageTypeId
				,Creator
				,CreateTime
				,SubjectEn
			
		)
		SELECT	@ContentEn
				,@ContentCh
				,@ContentCs
				,60 -- email
				,@UserId
				,GETDATE()
				,@SubjectEn
		
		SET @MessageId = SCOPE_IDENTITY()
		
		INSERT INTO dbo.LicenseeMessage (LicenseeId, MessageId)
		SELECT	LicenseeId, @MessageId
		FROM	@tblLicensee
		
		IF @IsTesting = 0 -- just insert msg into MessageTarget for real user
		BEGIN
			INSERT INTO dbo.MessageTarget (MessageId, LicenseeTypeId, PositionId)
			SELECT	@MessageId, LicenseeTypeId, 0
			FROM	@tblLicensee
			GROUP BY LicenseeTypeId
		END
	END TRY
	BEGIN CATCH			
			DELETE FROM dbo.LicenseeMessage WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			DELETE FROM dbo.Message WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			SELECT	@Errcode = 100
					,@ErrMsg = dbo.f_Get_MsgNamebyMsgID (40000, @Language)
			RETURN
	END CATCH
	
	-- Log Recipient list
	
	SET @SelectedLicensee = ''
	SELECT @SelectedLicensee = @SelectedLicensee +  CAST(LicenseeId AS VARCHAR(10)) + ','
	FROM	@tblLicensee
	
	SET @log_recipient = (
		SELECT	LicenseeId		AS '@lid'
				,Recipient		AS '@re'
				,Recipientname	AS '@rn'
				,email			AS '@em'
				,IsContact		AS '@ic'
				,RecipientType	AS '@rt'
		FROM	dbo.f_RecipientList (@SelectedLicensee, @CategoryId, @UserId)
		WHERE RecipientType <> 2 -- remove type AddToCC
		FOR XML PATH ('row'),TYPE
	)
	-- write log
	SET @xml = (
		SELECT	@CategoryId			AS '@ci'
				,@SelectedLicensee	AS '@lt'
				,@log_recipient
				,CONVERT(XML, REPLACE(REPLACE(CONVERT(NVARCHAR(MAX), @MailCCList), '<root>', ''), '</root>', ''))
		FOR XML PATH('r'), TYPE
		)		
				
	SELECT	@logSPData		= CONVERT(NVARCHAR(MAX), @xml)
			,@endRun		= GETDATE()  
			,@duration		= DATEDIFF(MILLISECOND, @startRun, @endRun)   
			,@procName		= OBJECT_NAME(@@PROCID)

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration
END
GO