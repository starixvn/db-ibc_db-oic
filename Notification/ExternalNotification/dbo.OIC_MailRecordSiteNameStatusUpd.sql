/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_MailRecordSiteNameStatusUpd]
	@MailRecordSiteId			INT,
	@Status						TINYINT,
	@IsRestoreDeadLock			BIT				= 0,		
	@UserId						INT,
	@CountSend					INT				= 0,
	@Language					VARCHAR(10)		= 'E',
	@IP							VARCHAR(50)		= NULL,
	@ErrCode					INT				= 0			OUTPUT,
	@ErrMsg						VARCHAR(300)	= NULL		OUTPUT
AS
/*  
	Created by: Hogan  
	Date: 2019-10-23  
	Task: Upgrade mail client [Redmine:#120949]  
	DB: DBOIC.bodb_OIC  
   
	Revisions:  
		- 20191023@Hogan: Create stored procedure OIC_MailRecordSiteNameUpd [RedmineID: #120949]
		- 20230223@Cody: Enhance email sending status function to resend the failed emails [RedmineId: #156775]
		- 20230313@Kai: Enhance try catch deal to throw exceptions when have errors [RedmineId: #184690]
						
	Param's Explanation:
	@Status: 0: waiting
			1: error
			2: sent
			3: fail
			4: success
			5: processing
 */ 
BEGIN
	SET NOCOUNT ON;
	
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@logSPOlddata	NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)
	
	SET @xml = (
		SELECT	@MailRecordSiteId	AS '@mi'
				,[Status]			AS '@st'
				,UpdatedTime		AS '@udt'
		FROM dbo.MailRecordSiteName WITH(NOLOCK)
		WHERE Id = @MailRecordSiteId
		FOR XML PATH('r'), TYPE
		)

	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)

	DECLARE @UpdatedTime DATETIME
	SET @UpdatedTime = GETDATE()

	BEGIN TRY
		UPDATE dbo.MailRecordSiteName WITH(ROWLOCK, UPDLOCK)
		SET [Status] = @Status,
			CountSend = CASE WHEN @CountSend = 0 THEN CountSend ELSE @CountSend END,
			UpdatedTime = @UpdatedTime
		WHERE Id = @MailRecordSiteId AND (@IsRestoreDeadLock = 0 OR [Status] = 5)

	END TRY
	BEGIN CATCH
		SELECT	@Errcode = 100,
				@ErrMsg = dbo.f_Get_MsgNamebyMsgID (40008, @Language);
		THROW;
	END CATCH

	SET @xml = (
		SELECT	@MailRecordSiteId	AS '@mi'
				,@Status			AS '@st'
				,@UpdatedTime		AS '@udt'
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
		,@OldData		= @logSPOlddata
		,@Duration		= @Duration
END
GO
