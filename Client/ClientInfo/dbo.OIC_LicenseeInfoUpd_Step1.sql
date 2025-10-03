/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeInfoUpd_Step1]
	@TypeId					TINYINT
	,@PlatformId			TINYINT
	,@IntegrationMethods	VARCHAR(1000)
	,@SiteName				NVARCHAR(50)
	,@RegisteredSiteName	NVARCHAR(50)
	,@CompanyName			NVARCHAR(50)	= NULL
	,@LicenseeStatusId		TINYINT
	,@LicenseeGroupId		INT				= NULL
	,@BusinessModelType		TINYINT			= NULL
	,@IsChineseMarketOnly	BIT				= 0
	,@SoftLaunch			DATETIME		= NULL
	,@FullLaunch			DATETIME		= NULL
	,@RelaunchDate			DATETIME		= NULL
	,@SuspendedDate			DATETIME		= NULL
	,@TerminatedDate		DATETIME		= NULL
	,@MainUrl				VARCHAR(3000)	= NULL
	,@APIUrl				VARCHAR(3000)	= NULL
	,@LicBackUpLink			XML				= NULL
	,@LocationId			INT				= NULL
	,@CurrenciesOffered		VARCHAR(4000)	= NULL
	,@LicTargetMarket		VARCHAR(1000)	= NULL
	,@LicLanguage			XML				= NULL
	,@LicLanguageSB			XML				= NULL
	,@LicOddsType			VARCHAR(100)	= NULL
	,@LicService			XML				= NULL
	,@LicRestrictCountry	VARCHAR(1000)	= NULL
	,@RestrictCountryRemark	NVARCHAR(500)	= NULL
	,@Remark				NVARCHAR(300)	= NULL
	,@TerminationRemark		NVARCHAR(300)	= NULL
	,@InvoiceBaseCurrency	VARCHAR(4)
	,@InvoiceLanguage		NVARCHAR(50)
	
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
	
	,@LicenseeId			INT				= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2014-12-18
	Task: Update client general info - Step1 [Redmine:#30959]
	DB: DBOIC.BODB_OIC 
	
	Revisions:
		- 20160805@Percy: Expand length of params: @LicTargetMarket, @LicRestrictCountry [RedmineID: #62099]
		- 20160823@Percy: Add param: @LicLanguageSB - Sportbook offered language [RedmineID: #62883]
		- 20170517@Percy: Add Chinese Market Only [RedmineID: #74330]
		- 20170809@Percy: Extend Url length [RedmineID: #81392]
		- 20170828@Scofield: Add Reseller [#82144]
		- 20190715@Howard: Add Odds Type [RedmineId: #115460]
		- 20200203@Hogan: Add Licensee Group [RedmineID: #126855]
		- 20210810@Hogan: Add invoice base currency and invoice language for licensee [RedmindId: #157466]
		- 20211110@Alex: Change Type Of Licensee [RedmindId: #163521]
		- 20221005@Kai: Support sending emails automatically [Redmine:#176447]
		- 20221028@Kai: Extend size of OfferedCurrencies [RedmindId: #179694]
		- 20251002@Kelvin: Offered Currencies list is truncated compared to the list pushed by SiteBuilder [Redmine:#240611]
		
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
	* @CurrenciesOffered, @LicTargetMarket, @LicRestrictCountry: 1,2,3
	
	* @ErrCode:
		= 0: 
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
 */
BEGIN
	SET NOCOUNT ON

	-- check licensee name
	EXEC dbo.OIC_LicenseeNameChecking
		@SiteName	= @SiteName
		,@LicenseeId = @LicenseeId
		,@Language	= @Language
		,@ErrCode	= @ErrCode	OUTPUT
		,@ErrMsg	= @ErrMsg	OUTPUT
	
	IF @ErrCode <> 0
	BEGIN
		SELECT @ErrCode = 100
		RETURN
	END
	
	DECLARE @tblUrlBackup			TABLE (urlValue VARCHAR(3000), [Order] TINYINT)
	DECLARE @tblLanguage			TABLE (LanguageId TINYINT)
	DECLARE @tblLanguageSB			TABLE (LanguageId TINYINT)
	DECLARE @tblService				TABLE (ServiceId TINYINT, PropertyId TINYINT, PropertyValue VARCHAR(3000))
	
	DECLARE @MainContactId			INT
	
	-- Update Licensee info
	BEGIN TRY
		UPDATE	dbo.Licensee WITH(ROWLOCK, UPDLOCK)
			SET	LicenseeName				= @SiteName
				,RegisteredLicenseeName 	= @RegisteredSiteName
				,LicenseeCompanyName		= @CompanyName
				,LicenseeStatusId			= @LicenseeStatusId
				,LicenseeGroupId			= @LicenseeGroupId
				,SoftLaunch					= @SoftLaunch
				,FullLaunch					= @FullLaunch
				,RelaunchDate				= @RelaunchDate
				,SuspendedDate				= @SuspendedDate
				,TerminatedDate				= @TerminatedDate
				,MainUrl					= @MainUrl
				,APILinkageUrl				= @APIUrl
				,LicenseeLocationId			= @LocationId
				,RestrictedLocationRemark	= @RestrictCountryRemark
				,Remark						= @Remark
				,TerminationRemark			= @TerminationRemark
				,TypeId						= @TypeId
				,PlatformId 				= @PlatformId
				,IsChineseMarketOnly		= @IsChineseMarketOnly
				,BusinessModelType			= @BusinessModelType
				,InvoiceBaseCurrency		= @InvoiceBaseCurrency
				,InvoiceLanguage			= @InvoiceLanguage
		WHERE	LicenseeId					= @LicenseeId
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 101
		RETURN
	END CATCH	
	
	-- Update url backup
	IF @LicBackUpLink IS NOT NULL
	BEGIN TRY
		INSERT INTO @tblUrlBackup(urlValue, [Order])
		SELECT	t.c.value('@val', 'varchar(3000)')
				,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rownumber
		FROM	@LicBackUpLink.nodes('root/row') t(c)
		
		MERGE	dbo.UrlBackup u
		USING	(SELECT urlValue, [Order] FROM @tblUrlBackup) t
			ON	u.[Order] = t.[Order] 
				AND u.LicenseeId = @LicenseeId
		WHEN MATCHED AND u.UrlValue <> t.urlValue THEN UPDATE SET u.UrlValue = t.urlValue
		WHEN NOT MATCHED BY TARGET THEN INSERT(LicenseeId, UrlValue, [Order]) VALUES(@LicenseeId, t.urlValue, t.[Order])
		WHEN NOT MATCHED BY SOURCE AND LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 102
		RETURN
	END CATCH	
			
	-- Update offered currencies
	IF @CurrenciesOffered IS NOT NULL
	BEGIN TRY
		MERGE	dbo.LicenseeCurrency lc
		USING	(SELECT	CONVERT(INT, val) AS CurrencyId FROM dbo.strSplit(@CurrenciesOffered, ',')) t
			ON	lc.CurrencyId = t.CurrencyId 
				AND lc.LicenseeId = @LicenseeId
		WHEN NOT MATCHED BY TARGET THEN INSERT(Licenseeid, CurrencyId) VALUES (@LicenseeId, t.CurrencyId)
		WHEN NOT MATCHED BY SOURCE AND lc.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 104
		RETURN
	END CATCH	
		
	-- Update targeted market
	IF @LicTargetMarket IS NOT NULL
	BEGIN TRY
		MERGE	dbo.LicenseeLocationLimit l
		USING	(SELECT	CONVERT(INT, val) AS LocationId FROM dbo.strSplit(@LicTargetMarket, ',')) t
			ON	l.LocationLimitId = t.LocationId 
				AND l.LicenseeId = @LicenseeId 
				AND l.LicenseeLocationType = 1
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, LicenseeLocationType, LocationLimitId) VALUES (@LicenseeId, 1, t.LocationId)
		WHEN NOT MATCHED BY SOURCE AND l.LicenseeId = @LicenseeId AND l.LicenseeLocationType = 1 THEN DELETE;			
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 105
		RETURN
	END CATCH	
		
	-- Update prefered comunicate language
	IF @LicLanguage IS NOT NULL
	BEGIN TRY
		INSERT INTO @tblLanguage(LanguageId)
		SELECT	t.c.value('@id','int')
		FROM @LicLanguage.nodes('root/row') t(c)
	
		MERGE	dbo.LicenseeLanguage l
		USING	(SELECT * FROM @tblLanguage) t
			ON	l.LanguageId = t.LanguageId 
				AND l.LicenseeId = @LicenseeId
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, LanguageId) VALUES (@LicenseeId, t.LanguageId)
		WHEN NOT MATCHED BY SOURCE AND l.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 106 
		RETURN
	END CATCH	
		
	-- Update service included
	IF @LicService IS NOT NULL
	BEGIN TRY
		INSERT INTO @tblService (PropertyId, PropertyValue)
		SELECT	t.c.value('@pid', 'tinyint') AS Propertyid
  				,t.c.value('@val', 'varchar(3000)') AS Value
		FROM @LicService.nodes('/root/row') AS t(c)	
		
		MERGE	dbo.LicenseeProperty l
		USING	(SELECT * FROM @tblService) t
			ON	l.PropertyId = t.PropertyId 
				AND l.LicenseeId = @LicenseeId
		WHEN MATCHED AND l.PropertyValue <> t.PropertyValue THEN UPDATE SET l.PropertyValue = t.PropertyValue
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, PropertyId, PropertyValue) VALUES (@LicenseeId, t.PropertyId, t.PropertyValue)
		WHEN NOT MATCHED BY SOURCE AND l.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 107
		RETURN
	END CATCH	
	
	-- Update Restrict country	
	IF @LicRestrictCountry IS NOT NULL
	BEGIN TRY
		MERGE	dbo.LicenseeLocationLimit l
		USING	(SELECT CONVERT(INT, val) AS LocationId FROM dbo.strSplit(@LicRestrictCountry,',')) t
			ON	l.LocationLimitId = t.LocationId
				AND l.LicenseeId = @LicenseeId
				AND l.LicenseeLocationType = 2
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, LicenseeLocationType, LocationLimitId) VALUES (@LicenseeId, 2, t.Locationid)
		WHEN NOT MATCHED BY SOURCE AND l.LicenseeId = @LicenseeId AND l.LicenseeLocationType = 2 THEN DELETE;		
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 108
		RETURN
	END CATCH

	-- Update Sportbook offered language
	IF @LicLanguageSB IS NOT NULL
	BEGIN TRY
		INSERT INTO @tblLanguageSB(LanguageId)
		SELECT	t.c.value('@id','int')
		FROM @LicLanguageSB.nodes('root/row') t(c)
	
		MERGE	dbo.LicenseeProductLanguage l
		USING	(SELECT * FROM @tblLanguageSB) t
			ON	l.LanguageId = t.LanguageId 
				AND l.LicenseeId = @LicenseeId
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, LanguageId) VALUES (@LicenseeId, t.LanguageId)
		WHEN NOT MATCHED BY SOURCE AND l.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 109
		RETURN
	END CATCH
	
	-- Update odds type
	IF @LicOddsType IS NOT NULL
	BEGIN TRY 
		MERGE dbo.LicenseeOddsType lot 
		USING (SELECT CONVERT(INT, val) AS OddsTypeId FROM dbo.strSplit(@LicOddsType, ',')) t
			ON lot.OddsTypeId = t.OddsTypeId
			AND lot.LicenseeId = @LicenseeId
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, OddsTypeId) VALUES (@LicenseeId, t.OddsTypeId)
		WHEN NOT MATCHED BY SOURCE AND lot.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 110
		RETURN
	END CATCH
	
	-- Update integration methods type
	IF @IntegrationMethods IS NOT NULL
	BEGIN TRY 
		MERGE dbo.LicenseeIntegrationMethod lit 
		USING (SELECT CONVERT(INT, val) AS IntegrationMethodId FROM dbo.strSplit(@IntegrationMethods, ',')) t
			ON lit.IntegrationMethodId = t.IntegrationMethodId
			AND lit.LicenseeId = @LicenseeId
		WHEN NOT MATCHED BY TARGET THEN INSERT (LicenseeId, IntegrationMethodId) VALUES (@LicenseeId, t.IntegrationMethodId)
		WHEN NOT MATCHED BY SOURCE AND lit.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 111
		RETURN
	END CATCH
		
	SELECT @ErrCode = 0
END
GO