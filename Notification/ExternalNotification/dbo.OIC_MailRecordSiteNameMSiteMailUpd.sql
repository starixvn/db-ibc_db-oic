/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_MailRecordSiteNameMSiteMailUpd]
	@MailRecordSiteId			INT,
	@MSiteMailId				BIGINT,		
	@UserId						INT,
	@LatestSendTime				DATETIME		= NULL,
	@Language					VARCHAR(10)		= 'E',
	@IP							VARCHAR(50)		= NULL,
	@ErrCode					INT				= 0			OUTPUT,
	@ErrMsg						VARCHAR(300)	= NULL		OUTPUT
AS
/*  
	Created by: Hogan  
	Date: 2019-10-28  
	Task: Upgrade mail client [Redmine:#120949]  
	DB: DBOIC.bodb_OIC  
   
	Revisions:  
		- 20191128@Hogan: Create stored procedure OIC_MailRecordSiteNameMSiteMailUpd [RedmineID: #120949]
		- 20230313@Kai: Enhance try catch deal to throw exceptions when have errors [RedmineId: #184690]
		- 20240321@Kai: Support LatestSendTime is NULL [Redmine:#197581]
 */ 
BEGIN
	SET NOCOUNT ON;
	
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)

	BEGIN TRY
		UPDATE dbo.MailRecordSiteName WITH(ROWLOCK, UPDLOCK)
		SET MSiteMailId = @MSiteMailId,
			LatestSendTime = @LatestSendTime
		WHERE Id = @MailRecordSiteId

	END TRY
	BEGIN CATCH
		SELECT	@Errcode = 100,
				@ErrMsg = dbo.f_Get_MsgNamebyMsgID (40010, @Language);
		THROW;
	END CATCH

	SET @xml = (
	SELECT	@MailRecordSiteId	AS '@mi'
			,@MSiteMailId		AS '@msi'
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
		,@OldData		= NULL
		,@Duration		= @Duration
END
GO
