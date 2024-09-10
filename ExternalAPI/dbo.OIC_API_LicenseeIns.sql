/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_API_LicenseeIns] 
	 @SourceId				SMALLINT
	,@SiteName				NVARCHAR(50)
	,@RegisteredSiteName	NVARCHAR(50)
	,@TypeId				TINYINT
	,@PlatformId			TINYINT
	,@IntegrationMethods	VARCHAR(1000)
	,@GroupName				NVARCHAR(200)	= NULL
	,@OddsTypes				VARCHAR(100)    = NULL
	,@OfferedCurrencies		VARCHAR(1000)	= NULL
	,@StatusId				TINYINT
	,@AMUserName			NVARCHAR(100)			
	,@PMUserName			NVARCHAR(100)
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT

AS
/*
	Created by: Kai
	Date: 2024-02-29
	Task: Create a new client in OIC when adding a new licensee in Site Builder [Redmine:#197581]
	DB: DBOIC.bodb_OIC 
	
	Revisions:
		- 20240229@Kai: Init [Redmine:#197581]
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE 
		 @LicenseeId			INT
		,@LicenseeGroupId		INT
		,@OfferedCurrencyIds	VARCHAR(100)
		,@AMUserId				INT
		,@PMUserId				INT

	-- For write log
	DECLARE 
		 @startRun					DATETIME
		,@endRun					DATETIME
		,@duration					INT
		,@logSPData					NVARCHAR(MAX)
		,@xml						XML
		,@procName					VARCHAR(200)
		,@log_currency				XML
		,@log_integrationMethod		XML
		,@log_oddsType				XML
		,@ExtraInfo					NVARCHAR(100)

	SET @startRun = GETDATE()
	SET @ExtraInfo = CASE 
		WHEN @SourceId = -2 THEN 'Site Builder'
		ELSE NULL
	END

	-- Check licensee name
	EXEC dbo.OIC_LicenseeNameChecking
		 @SiteName	= @SiteName
		,@Language	= @Language
		,@ErrCode	= @ErrCode	OUTPUT
		,@ErrMsg	= @ErrMsg	OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode, @ErrMsg
		RETURN
	END
	
	EXEC dbo.OIC_RegisteredLicenseeNameChecking
		 @RegisteredSiteName	= @RegisteredSiteName
		,@Language				= @Language
		,@ErrCode				= @ErrCode	OUTPUT
		,@ErrMsg				= @ErrMsg	OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode, @ErrMsg
		RETURN
	END

	-- Check Licensee Type
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.LicenseeTypes lt WITH(NOLOCK) WHERE lt.TypeId = @TypeId)
	BEGIN
		SELECT @ErrCode = 99
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](12,@Language) 
		RETURN
	END

	-- Check Platform
	IF NOT EXISTS(SELECT TOP 1 1 FROM dbo.[Platform] p WITH(NOLOCK) WHERE p.PlatformId = @PlatformId)
	BEGIN
		SELECT @ErrCode = 99
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](13,@Language) 
		RETURN
	END

	-- Check Integration Method
	IF EXISTS(
		SELECT TOP 1 1 
		FROM (SELECT CONVERT(INT, s.value) AS IntegrationMethodId FROM STRING_SPLIT(@IntegrationMethods,',') s) AS t
			LEFT JOIN  dbo.IntegrationMethod im WITH(NOLOCK) 
			ON t.IntegrationMethodId = im.IntegrationMethodId 
		WHERE im.IntegrationMethodId IS NULL)
	BEGIN
		SELECT @ErrCode = 99
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](14,@Language) 
		RETURN
	END

	-- Step1: Insert general info

	SELECT @LicenseeGroupId = lg.Id
	FROM dbo.LicenseeGroup lg WITH(NOLOCK)
	WHERE lg.Name = @GroupName

	SELECT @OfferedCurrencyIds = STRING_AGG(c.ExchangeId, ',')
	FROM dbo.Currency c WITH(NOLOCK)
	WHERE c.Code IN (SELECT s.value FROM STRING_SPLIT(@OfferedCurrencies, ',') s )

	EXEC dbo.OIC_LicenseeInfoIns_Step1
		 @UserId					= @SourceId
		,@PlatformId				= @PlatformId
		,@TypeId					= @TypeId
		,@IntegrationMethods		= @IntegrationMethods
		,@SiteName					= @SiteName
		,@RegisteredSiteName		= @RegisteredSiteName
		,@LicenseeStatusId			= @StatusId
		,@LicenseeGroupId			= @LicenseeGroupId
		,@CurrenciesOffered			= @OfferedCurrencyIds
		,@LicOddsType				= @OddsTypes
		,@InvoiceBaseCurrency		= NULL
		,@InvoiceLanguage			= NULL
		
		,@Language					= @Language
		,@IP						= @IP
		,@ErrCode					= @ErrCode		OUTPUT
		,@ErrMsg					= @ErrMsg		OUTPUT
		
		,@LicenseeId				= @LicenseeId	OUTPUT
	
	
	IF @ErrCode <> 0
	BEGIN
		SELECT	@ErrCode = @ErrCode
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1, @Language) -- Fail to insert data step1
		
		-- Rollback Step1:
		DELETE FROM dbo.Licensee WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.UrlBackup WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeCurrency WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeLocationLimit WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeLanguage  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeOddsType WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeProperty  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.Contact WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeID = @LicenseeId
		
		DELETE FROM dbo.LicenseeIntegrationMethod WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step1
		
		RETURN
	END

	-- END step1

	-- Skip Step2: Registered product & feature

	-- Step3: Internal Person in Charge 
	SELECT @AMUserId = ui.UserId
	FROM dbo.UserInfo ui WITH(NOLOCK)
	WHERE ui.DisplayName = @AMUserName

	SELECT @PMUserId = ui.UserId
	FROM dbo.UserInfo ui WITH(NOLOCK)
	WHERE ui.DisplayName = @PMUserName

	EXEC dbo.OIC_LicenseeInfoIns_Step3
		 @UserId			= @SourceId
		,@LicenseeId		= @LicenseeId
		,@AMUserId			= @AMUserId
		,@PMUserId			= @PMUserId
		,@Language			= @Language
		,@IP				= @IP

		,@ErrCode			= @ErrCode	OUTPUT
		,@ErrMsg			= @ErrMsg	OUTPUT
		
	IF @ErrCode <> 0
	BEGIN
		SELECT	@ErrCode = @ErrCode
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](3, @Language) -- Fail to insert data step3
			
		-- Rollback Step1:
		DELETE FROM dbo.Licensee WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.UrlBackup WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeCurrency WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeLocationLimit WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeLanguage  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeOddsType WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeProperty  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeIntegrationMethod WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step1
		
		-- Skip rollback Step2
		
		-- Rollback data Step3:
		DELETE FROM dbo.LicenseeAccountInfo WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.UserLicensee  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step3
		
		RETURN
	END
	--END Step3

	-- Write logs
	SET @log_currency = (
							SELECT	c.ExchangeId AS '@cid'
									,c.Code AS '@cur'
							FROM dbo.LicenseeCurrency AS lc WITH (NOLOCK)
								INNER JOIN dbo.Currency AS c WITH(NOLOCK) 
									ON c.ExchangeId = lc.CurrencyId
							WHERE	lc.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('cr')	
						)			
						
	SET @log_oddsType = (
							SELECT ot.OddsTypeId AS '@lotid'
								   ,ot.OddsTypeName AS '@lotn'
							FROM dbo.LicenseeOddsType AS lot WITH(NOLOCK)
								INNER JOIN dbo.OddsType AS ot WITH(NOLOCK)
									ON lot.OddsTypeId = ot.OddsTypeId
							WHERE lot.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('lot')
						)
						
	SET @log_integrationMethod = (
							SELECT im.IntegrationMethodId AS '@limid'
								   ,im.IntegrationMethodName AS '@limn'
							FROM dbo.LicenseeIntegrationMethod AS lim WITH(NOLOCK)
								INNER JOIN dbo.IntegrationMethod AS im WITH(NOLOCK)
									ON lim.IntegrationMethodId = im.IntegrationMethodId
							WHERE lim.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('lot')
	
								 )

	DECLARE @pmn NVARCHAR(100), @amn NVARCHAR(100)
	
	SELECT  @pmn = pui.DisplayName
	FROM dbo.UserLicensee pul WITH(NOLOCK)
		INNER JOIN dbo.UserInfo pui WITH(NOLOCK) ON pul.UserId = pui.UserId AND pui.PositionId = 5 AND pul.LicenseeId = @LicenseeId
	
	SELECT  @amn = pui.DisplayName
	FROM dbo.UserLicensee pul WITH(NOLOCK)
		INNER JOIN dbo.UserInfo pui WITH(NOLOCK) ON pul.UserId = pui.UserId AND pui.PositionId = 6 AND pul.LicenseeId = @LicenseeId


	-- Write log add new client
	SET @xml = (
		SELECT	@LicenseeId					AS '@lid'
				,t.TypeName					AS '@tn'
				,i.PlatformName				AS '@pn'
				,l.LicenseeName				AS '@ln'
				,l.RegisteredLicenseeName	AS '@rln'
				,l.LicenseeCompanyName		AS '@cn'
				,s.LicenseeStatusName		AS '@sn'
				,g.Name						AS '@gn'
				,l.SoftLaunch				AS '@sl'
				,l.FullLaunch				AS '@fl'
				,l.RelaunchDate				AS '@rld'
				,l.SuspendedDate			AS '@sd'
				,l.TerminatedDate			AS '@td'
				,l.MainUrl					AS '@mu'
				,l.APILinkageUrl			AS '@au'
				,l.RestrictedLocationRemark	AS '@rlr'
				,l.Remark					AS '@rm'
				,l.TerminationRemark		AS '@trm'
				,l.IsChineseMarketOnly		AS '@icm'
				,l.IsReseller				AS '@res'
				,l.InternalURL				AS '@iu'
				,@pmn						AS '@pmn'
				,@amn						AS '@amn'
				,l.InvoiceBaseCurrency		AS '@ibc'
				,l.InvoiceLanguage			AS '@il'
				,@log_currency
				,@log_oddsType
				,@log_integrationMethod

		FROM dbo.Licensee AS l WITH (NOLOCK)
			INNER JOIN dbo.LicenseeStatus AS s WITH(NOLOCK) ON l.LicenseeStatusId = s.LicenseeStatusId
			INNER JOIN dbo.LicenseeTypes AS t WITH(NOLOCK) ON l.TypeId = t.TypeId
			INNER JOIN dbo.Platform AS i WITH(NOLOCK) ON l.PlatformId = i.PlatformId
			LEFT JOIN dbo.LicenseeGroup AS g WITH(NOLOCK) ON l.LicenseeGroupId = g.Id 
		WHERE l.LicenseeId = @LicenseeId
		FOR XML PATH('r'), TYPE)

	SELECT   @logSPData = CONVERT(NVARCHAR(MAX), @xml)
			,@endRun	= GETDATE()  
			,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
			,@procName	= OBJECT_NAME(@@PROCID)


	EXEC dbo.OIC_LogRunSpIns
		 @UserId		= @SourceId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration
		,@ExtraInfo		= @ExtraInfo

	DECLARE @LogId INT
	SELECT @LogId = @@IDENTITY

-- Assign all categories for new client
	EXEC dbo.OIC_LicenseeCategoryAssignNewLicensee
		 @LicenseeId	= @LicenseeId
		,@ExtraInfo		= @ExtraInfo
		,@UserId		= @SourceId
		,@Language		= @Language
		,@IP			= @IP
		,@ErrCode		= @ErrCode
		,@ErrMsg		= @ErrMsg

	IF @ErrCode <> 0
	BEGIN
		SELECT	@ErrCode = @ErrCode
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](1500, @Language) -- Fail to assign category(ies). Please try again
			
		-- Rollback Step1:
		DELETE FROM dbo.Licensee WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.UrlBackup WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeCurrency WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeLocationLimit WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeLanguage  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeOddsType WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeProperty  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.LicenseeIntegrationMethod WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step1
		
		-- Skip rollback Step2

		-- Rollback data Step3:
		DELETE FROM dbo.LicenseeAccountInfo WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.UserLicensee  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step3
		
		-- Rollback log add new client
		DELETE FROM dbo.UserLog_RunSP WITH(ROWLOCK, UPDLOCK)
		WHERE Id = @LogId

		DELETE FROM dbo.UserLog_RunSP_Detail WITH(ROWLOCK, UPDLOCK) 
		WHERE Id = @LogId
		-- END rollback log add new client

		RETURN
	END
	
END

GO