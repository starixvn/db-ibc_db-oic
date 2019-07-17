/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeInfoIns]
	@UserId					INT
	,@LicenseeTypeId		TINYINT
	,@SiteName				NVARCHAR(50)
	,@RegisteredSiteName	NVARCHAR(50)
	,@CompanyName			NVARCHAR(50)	= NULL
	,@LicenseeStatusId		TINYINT
	,@IsReseller			BIT				= 0
	,@IsChineseMarketOnly	BIT				= 0
	,@SoftLaunch			DATETIME		= NULL
	,@FullLaunch			DATETIME		= NULL
	,@MainUrl				VARCHAR(3000)	= NULL
	,@APIUrl				VARCHAR(3000)	= NULL
	,@LicBackUpLink			XML				= NULL
	,@HasMainContact		BIT				= 0 -- has main contact info
	,@MainContactName		NVARCHAR(50)	= NULL
	,@Position				NVARCHAR(50)	= NULL
	,@Department			NVARCHAR(50)	= NULL
	,@Email					VARCHAR(50)		= NULL
	,@PhoneNumber			VARCHAR(50)		= NULL
	,@Skype					VARCHAR(50)		= NULL
	,@MainContactRemark		NVARCHAR(300)	= NULL
	,@LocationId			INT				= NULL
	,@CurrenciesOffered		VARCHAR(100)	= NULL
	,@LicTargetMarket		VARCHAR(1000)	= NULL
	,@LicLanguage			XML				= NULL
	,@LicLanguageSB			XML				= NULL
	,@LicOddsType			VARCHAR(100)    = NULL
	,@LicService			XML				= NULL
	,@LicRestrictCountry	VARCHAR(1000)	= NULL
	,@RestrictCountryRemark	NVARCHAR(2000)	= NULL		
	,@Remark				NVARCHAR(300)	= NULL
	,@LicProduct			XML				= NULL
	,@LicFeature			XML				= NULL
	,@AMUserId				INT				
	,@PMUserId				INT				
	,@LicAccount			XML				= NULL
	,@InternalURL			VARCHAR(3000)	= NULL
	
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2014-12-18
	Task: Insert Licensee [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160511@Percy: Change type of input param @LicFeature [RedmineID: #56935]
		- 20160805@Percy: Expand length of params: @LicTargetMarket, @LicRestrictCountry [RedmineID: #62099]
		- 20160823@Percy: Add param: @LicLanguageSB - Sportbook offered language [RedmineID: #62883]
		- 20170517@Percy: Add Chinese Market Only and Internal Backend URL [RedmineID: #74330]
		- 20170802@Percy: Add Url testing account - add element into @LicAccount [RedmineID: #80712]
		- 20170809@Percy: Extend Url length [RedmineID: #81392]
		- 20170828@Scofield: Add Reseller [#82144]
		- 20190715@Howard: Add OddsType [RedmindId: #115460]
	
	Param's Explanation:
	* @LicBackupLink
		<root>
			<row val="link1" />
			<row val="link2" />
		</root>
	* @LicService: List of Services
		Format:
				<root>
					<row pid="1" val="kathy.nguyen" />
					<row pid="2" val="password" />
					<row pid="3" val="http:..." />
					<row pid="4" val="http:..." />
				</root>
	* @LicLanguage, @LicLanguageSB
		Format:
				<root>
					<row id="1" />
					<row id="2" />
				</root>
	* @LicProduct, @LicFeature: list of product, feature
				<root>
					<row id="1" launchdate="2014-12-19" terminationdate="2016-05-11"/>
					<row id="3" launchdate="2014-12-19"/>
				</root>
				
	* @LicAccount:
				<root>
					<row order="1" type="1" username="webaccount" password="abc" url="https://" />
					<row order="1" type="2" username="csd" password="1234" url="https://" />
					<row order="1" type="3" username="training" password="12abc" url="https://" />
				</root>
				
	* @CurrenciesOffered, @LicTargetMarket, @LicRestrictCountry
	* @ErrCode:
		= 0: 
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
	
	* Log:
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @LicenseeId INT

	-- For write log
	DECLARE 
		@startRun					DATETIME
		,@endRun					DATETIME
		,@duration					INT
		,@logSPData					NVARCHAR(MAX)
		,@xml						XML
		,@procName					VARCHAR(200)
		-- log step 1
		,@log_backupLink			XML
		,@log_maincontact			XML
		,@log_currency				XML
		,@log_targetedMarket		XML
		,@log_restrictedLocation	XML
		,@log_language				XML
		,@log_languageSB			XML
		,@log_oddsType				XML
		,@log_service				XML
		-- log step 2
		,@log_product				XML
		,@log_feature				XML
		-- log step 3
		,@log_account				XML

	SET @startRun = GETDATE()
	
	-- check licensee name
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
		,@Language	= @Language
		,@ErrCode	= @ErrCode	OUTPUT
		,@ErrMsg	= @ErrMsg	OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode, @ErrMsg
		RETURN
	END
		
	-- Step1: Insert general info
	EXEC dbo.OIC_LicenseeInfoIns_Step1
		@UserId						= @UserId
		,@LicenseeTypeId			= @LicenseeTypeId
		,@SiteName					= @SiteName
		,@RegisteredSiteName		= @RegisteredSiteName
		,@CompanyName				= @CompanyName
		,@LicenseeStatusId			= @LicenseeStatusId
		,@IsReseller				= @IsReseller
		,@IsChineseMarketOnly		= @IsChineseMarketOnly
		,@SoftLaunch				= @SoftLaunch
		,@FullLaunch				= @FullLaunch
		,@MainUrl					= @MainUrl
		,@APIUrl					= @APIUrl
		,@LicBackUpLink				= @LicBackUpLink
		,@HasMainContact			= @HasMainContact -- has main contact info
		,@MainContactName			= @MainContactName
		,@Position					= @Position
		,@Department				= @Department
		,@Email						= @Email
		,@PhoneNumber				= @PhoneNumber
		,@Skype						= @Skype
		,@MainContactRemark			= @MainContactRemark
		,@LocationId				= @LocationId
		,@CurrenciesOffered			= @CurrenciesOffered
		,@LicTargetMarket			= @LicTargetMarket
		,@LicLanguage				= @LicLanguage
		,@LicLanguageSB				= @LicLanguageSB
		,@LicOddsType				= @LicOddsType
		,@LicService				= @LicService
		,@LicRestrictCountry		= @LicRestrictCountry
		,@RestrictCountryRemark		= @RestrictCountryRemark		
		,@Remark					= @Remark
		
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
		-- END rollback Step1
		
		RETURN
	END
	
	-- END step1
	
	-- Step2: Registered product & feature 
	IF @LicProduct IS NOT NULL OR @LicFeature IS NOT NULL
	BEGIN
		EXEC dbo.OIC_LicenseeInfoIns_Step2
		@UserId			= @UserId		
		,@LicenseeId	= @LicenseeId
		,@LicProduct	= @LicProduct
		,@LicFeature	= @LicFeature

		,@Language		= @Language
		,@IP			= @IP
		,@ErrCode		= @ErrCode	OUTPUT
		,@ErrMsg		= @ErrMsg	OUTPUT
		
		IF @ErrCode <> 0
		BEGIN
			SELECT	@ErrCode = @ErrCode
					,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](2, @Language) -- Fail to insert data step2
				
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
			
			DELETE FROM dbo.Licensee  WITH(ROWLOCK, UPDLOCK)
			WHERE LicenseeId = @LicenseeId
			-- END rollback Step1
			
			-- Rollback Step2:
			DELETE 
			FROM dbo.LicenseeProduct WITH(ROWLOCK,UPDLOCK)
			WHERE LicenseeId = @LicenseeId
			
			DELETE
			FROM dbo.LicenseeFeature WITH(ROWLOCK, UPDLOCK)
			WHERE LicenseeId = @LicenseeId
			-- END rollback Step2	
			
			RETURN
			
		END
	END	
	-- END Step2
	
	-- Step3: Internal Person in Charge 
	EXEC dbo.OIC_LicenseeInfoIns_Step3
		@UserId				= @UserId
		,@LicenseeId		= @LicenseeId
		,@AMUserId			= @AMUserId
		,@PMUserId			= @PMUserId
		,@LicAccount		= @LicAccount
		,@Language			= @Language
		,@IP				= @IP
		,@InternalURL		= @InternalURL

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
		-- END rollback Step1
		
		-- Rollback Step2:
		DELETE 
		FROM dbo.LicenseeProduct WITH(ROWLOCK,UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE
		FROM dbo.LicenseeFeature WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step2
		
		-- Rollback data Step3:
		DELETE FROM dbo.LicenseeAccountInfo WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		
		DELETE FROM dbo.UserLicensee  WITH(ROWLOCK, UPDLOCK)
		WHERE LicenseeId = @LicenseeId
		-- END rollback Step3
		
		RETURN
	END
	--END Step3

	-- write log
	SET @log_backupLink = (
							SELECT	lu.UrlValue AS '@lbul'
							FROM dbo.UrlBackup AS lu WITH (NOLOCK)
							WHERE	lu.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('bk')		
						)
						
	SET @log_maincontact = (SELECT	c.ContactID			AS '@cid'
									,c.ContactName		AS '@cn'
									,c.ContactPosition	AS '@cp'
									,c.ContactDepartment AS '@cd'
									,c.ContactEmail		AS '@ce'
									,c.ContactSkype		AS '@cs'
									,c.ContactPhoneNumber	AS '@cpn'
									,c.IsMain			AS '@cim'
									,c.Remark			AS '@crm'
							FROM	dbo.Contact c
							WHERE	licenseeid = @LicenseeId AND c.IsMain = 1
							FOR XML PATH('row'), ROOT('lc')	
						)
	
	SET @log_currency = (
							SELECT	e.exchangeid AS '@cid'
									,e.Code AS '@cur'
							FROM dbo.LicenseeCurrency AS lc WITH (NOLOCK)
								INNER JOIN bodb02.dbo.Exchange AS e WITH(NOLOCK) 
									ON e.exchangeid = lc.CurrencyId
							WHERE	lc.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('cr')	
						)
						
	SET @log_targetedMarket = (
							SELECT  lo.LocationId AS '@tmid'
									,lo.LocationName AS '@tmn'
							FROM dbo.LicenseeLocationLimit AS ll WITH (NOLOCK)
								INNER JOIN dbo.Location AS lo WITH(NOLOCK) 
									ON lo.LocationId = ll.LocationLimitId 
									AND ll.LicenseeLocationType = 1
							WHERE	ll.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('tm')	
						)
	SET @log_restrictedLocation = (
							SELECT lo.LocationId AS '@rlid'
									,lo.LocationName AS '@rln'
							FROM dbo.LicenseeLocationLimit AS ll WITH (NOLOCK)
								INNER JOIN dbo.Location AS lo WITH(NOLOCK) 
									ON lo.LocationId = ll.LocationLimitId 
									AND ll.LicenseeLocationType = 2
							WHERE	ll.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('rl')		
						)
						
	SET @log_Language = (
							SELECT	la.LanguageId AS '@llid'
									,la.LanguageName AS '@lln'
							FROM dbo.LicenseeLanguage AS ll WITH (NOLOCK)
								INNER JOIN dbo.Language AS la WITH(NOLOCK) 
									ON la.LanguageId = ll.LanguageId
							WHERE	ll.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('ll')	
						)
						
	SET @log_languageSB = (
							SELECT	la.LanguageId AS '@llidsb'
									,la.LanguageName AS '@llnsb'
							FROM dbo.LicenseeProductLanguage AS ll WITH (NOLOCK)
								INNER JOIN dbo.Language AS la WITH(NOLOCK) 
									ON la.LanguageId = ll.LanguageId
							WHERE	ll.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('llsb')	
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

	SET @log_service = (	SELECT	s.ServiceId				AS '@lsid'
									,s.ServiceName				AS '@lsn'
									,p.PropertyId				as '@lspid'
									,lp.PropertyValue as '@lspv'
							FROM dbo.LicenseeProperty lp
								INNER JOIN dbo.Property p 
									ON	p.PropertyId = lp.PropertyId
								INNER JOIN dbo.Service s 
									ON	s.ServiceId = p.ServiceId
							WHERE	licenseeid = @LicenseeId
							FOR XML PATH('row'), ROOT('ls')	
						)
	SET @log_product = (	SELECT	p.ProductId AS '@lpid'
									,p.ProductName AS '@lpn'
									,p.[Order] AS '@lpod'
									,lp.LaunchDate AS '@lpl'
									,lp.TerminationDate AS '@lpt'
							FROM dbo.LicenseeProduct AS lp WITH (NOLOCK)
								INNER JOIN dbo.Product AS p WITH(NOLOCK) 
									ON	p.ProductId = lp.ProductId
							WHERE	lp.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('lp')	
						)
	SET @log_feature = (	SELECT	f.FeatureId AS '@lfid'
									,f.FeatureName AS '@lfn'
									,lf.LaunchDate AS '@lfl'
									,lf.TerminationDate AS '@lft'
							FROM dbo.LicenseeFeature AS lf WITH (NOLOCK)
								INNER JOIN dbo.Feature AS f WITH(NOLOCK) 
									ON	f.FeatureId = lf.FeatureId
							WHERE	lf.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('lf')	
						)
	SET @log_account = (	SELECT	la.AccountId AS '@laid'
									,la.UserName AS '@lan'
									,la.UserPwd AS '@lap'
									,la.AccountType AS '@lat'
									,la.[Order] AS '@lod'
									,la.Url AS '@lu'
							FROM dbo.LicenseeAccountInfo la WITH (NOLOCK)
							WHERE la.LicenseeId = @LicenseeId
							FOR XML PATH('row'), ROOT('la')	
						)
	
	DECLARE @pmn NVARCHAR(100), @amn NVARCHAR(100), @location NVARCHAR(50)
	
	SELECT  @pmn = pui.DisplayName
	FROM dbo.UserLicensee pul WITH(NOLOCK)
		INNER JOIN dbo.UserInfo pui WITH(NOLOCK) ON pul.UserId = pui.UserId AND pui.PositionId = 5 AND pul.LicenseeId = @LicenseeId
	
	SELECT  @amn = pui.DisplayName
	FROM dbo.UserLicensee pul WITH(NOLOCK)
		INNER JOIN dbo.UserInfo pui WITH(NOLOCK) ON pul.UserId = pui.UserId AND pui.PositionId = 6 AND pul.LicenseeId = @LicenseeId
	
	SELECT @location = LocationName FROM dbo.Location WITH(NOLOCK) WHERE LocationId = @LocationId

	-- Write log
	SET @xml = (
		SELECT	@LicenseeId					AS '@lid'
				,t.LicenseeTypeName			AS '@tn'
				,l.LicenseeName				AS '@ln'
				,l.RegisteredLicenseeName	AS '@rln'
				,l.LicenseeCompanyName		AS '@cn'
				,s.LicenseeStatusName		AS '@sn'
				,l.SoftLaunch				AS '@sl'
				,l.FullLaunch				AS '@fl'
				,l.MainUrl					AS '@mu'
				,l.APILinkageUrl			AS '@au'
				,l.RestrictedLocationRemark	AS '@rlr'			
				,l.Remark					AS '@rm'
				,l.IsChineseMarketOnly		AS '@icm'
				,l.IsReseller				AS '@res'
				,l.InternalURL				AS '@iu'
				,@location					AS '@lc'
				,@pmn						AS '@pmn'
				,@amn						AS '@amn'
				,@log_backupLink
				,@log_maincontact
				,@log_currency
				,@log_Language
				,@log_LanguageSB
				,@log_oddsType
				,@log_restrictedLocation
				,@log_targetedMarket
				,@log_service
				,@log_product
				,@log_feature
				,@log_account
		FROM dbo.Licensee AS l WITH (NOLOCK)
			INNER JOIN dbo.LicenseeStatus AS s WITH(NOLOCK) ON l.LicenseeStatusId = s.LicenseeStatusId
			INNER JOIN dbo.LicenseeType AS t WITH(NOLOCK) ON l.LicenseeTypeId = t.LicenseeTypeId
		WHERE l.LicenseeId = @LicenseeId
		FOR XML PATH('r'), TYPE)		
		
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