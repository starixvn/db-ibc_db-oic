/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_MailRecordSiteNameIns]
	@To						NVARCHAR(1000)
	,@Cc					NVARCHAR(1000)
	,@Bcc					NVARCHAR(300)
	,@Subject				NVARCHAR(300)
	,@LicenseeIds			NVARCHAR(MAX)   = NULL
	,@ToRecipientId			INT
	,@Type					INT				= 0
	,@Status				TINYINT			= 0
	,@MailRecordId			INT				= 0
	,@LatestSendTime		DATETIME		= NULL
	,@CountSend				INT				= 0
	
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
	,@IdentityInserted		INT				= 0			OUTPUT
AS
/*
	Created by: Hogan
	Date: 2019-10-21
	Task: Upgrade mail client [Redmine:#120949]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20191017@Hogan: Create stored procedure OIC_MailRecordSiteNameIns [RedmineID: #120949]
		- 20200212@Hogan: Extend length of column CC in MailRecordSiteName table to 1000 [RedmineID: #128373]
		- 20220615@Kai: Launched emails of a new licensee [RedmineID: #168502]
		- 20220907@Kai: Enhance launched new product emails [RedmineID: #168502]

	Param's Explanation:
	@Status:	0: mail waiting for send process
				1: email sent successfully
				2: email sent failed	
	@Type:	0: email notification
			1: internal email notification
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
		,@userName		NVARCHAR(50)

    BEGIN TRY

		IF @Type = 0 -- email notification
		BEGIN
			INSERT INTO dbo.MailRecordSiteName ([To], Cc, Bcc,[Subject], [Status], MailRecordId, FromUserId, ToRecipientId, [Type], LatestSendTime, CountSend, CreateTime) 
			VALUES (@To, @Cc, @Bcc, @Subject, @Status, @MailRecordId, @UserId, @ToRecipientId, @Type, @LatestSendTime, @CountSend, GETDATE())
		END
		ELSE IF @Type = 1 -- internal email notification
		BEGIN
			INSERT INTO dbo.LicenseeMailRecord
			SELECT value, @MailRecordId FROM STRING_SPLIT(@LicenseeIds,',')
			WHERE NOT EXISTS (SELECT * FROM dbo.LicenseeMailRecord lmr WITH(NOLOCK) WHERE lmr.MailRecordId = @MailRecordId AND value = lmr.LicenseeId) 

			INSERT INTO dbo.MailRecordSiteName ([To], Cc, Bcc,[Subject], [Status], MailRecordId, FromUserId, ToRecipientId, [Type], LatestSendTime, CountSend, CreateTime) 
			VALUES (@To, @Cc, @Bcc, @Subject, @Status, @MailRecordId, @UserId, @ToRecipientId, @Type, @LatestSendTime, @CountSend, GETDATE())
		END

		SET @IdentityInserted = SCOPE_IDENTITY()

	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 110
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](40007, @Language) -- Fail to create mail record site name. Please try again.
		RETURN
	END CATCH
	
	SET @xml = (
	SELECT	@To					AS '@to'
			,@Cc				AS '@cc'
			,@Bcc				AS '@bcc'
			,@Subject			AS '@sj'
			,@Status			AS '@st'
			,@MailRecordId		AS '@mi'
			,@UserId			AS '@fu'
			,@ToRecipientId		AS '@tr'
			,@LicenseeIds		AS '@lid'
			,@LatestSendTime	AS '@lst'
			,@CountSend			AS '@cs'
			,@Type				AS '@type'
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
