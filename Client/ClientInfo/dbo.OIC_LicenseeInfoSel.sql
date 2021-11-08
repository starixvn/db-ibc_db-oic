/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeInfoSel]	
	@LicenseeId		INT
	,@Step			TINYINT	= 1
AS
/*
	Created by: Kathy
	Date: 20150505
	Task: Select licensee info [Redmine:#30959]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160513@Percy: Add field TerminationDate [RedmineID: #56935]
		- 20160805@Percy: Expand length of params: @LicTargetMarket, @LicRestrictCountry [RedmineID: #62099]
		- 20160823@Percy: Return param: @LicLanguageSB - column: SBOfferedLanguage - Sportbook offered language [RedmineID: #62883]
		- 20170517@Percy: Return Chinese Market Only and Internal Backend URL [RedmineID: #74330]
		- 20170802@Percy: Return Url testing account [RedmineID: #80712]
		- 20170828@Scofield: Add Reseller [#82144]
		- 20190715@Howard: Add Odds Type [RedmineID: 115460]
		- 20200203@Hogan: Return licenseeGroupId [RedmineID: #126855]
		- 20210810@Hogan: Add invoice base currency and invoice language for licensee [RedmindId: #157466]
		- 20211001@Alex: Support Product Type on Client Product [RedmindId: #161508]
		- 20211115@Alex: Change Type Of Licensee [RedmindId: #163521]
	
	Param's Explanation:
		@Step: 1,2,3

 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @LicBackupLink			XML
			,@OfferedCurrencies		VARCHAR(100)
			,@LicTargetMarket		VARCHAR(1000)
			,@LicLanguage			XML
			,@LicLanguageSB			XML
			,@LicOddsType			VARCHAR(100)
			,@IntegrationMethod		VARCHAR(1000)
			,@LicService			XML
			,@LicRestrictCountry	VARCHAR(1000)
			,@PMUserId				INT
			,@AMUserId				INT
			,@LicAccount			XML
			
	IF @Step = 1
	BEGIN
		SET @LicBackupLink = (
								SELECT	lu.UrlValue		AS '@val'
								FROM	dbo.UrlBackup	AS lu WITH (NOLOCK)
								WHERE	lu.LicenseeId = @LicenseeId
								FOR XML PATH('row'), ROOT('root')		
							)
		
		SELECT	@OfferedCurrencies = COALESCE(@OfferedCurrencies + ',' + CONVERT(VARCHAR(10),CurrencyId), CONVERT(VARCHAR(10),CurrencyId)) 
		FROM	dbo.LicenseeCurrency WITH(NOLOCK)
		WHERE	LicenseeId = @LicenseeId
		
		SELECT	@LicTargetMarket = COALESCE(@LicTargetMarket + ',' + CONVERT(VARCHAR(10),LocationLimitId), CONVERT(VARCHAR(10),LocationLimitId)) 
		FROM	dbo.LicenseeLocationLimit WITH(NOLOCK)
		WHERE	LicenseeId = @LicenseeId
				AND LicenseeLocationType = 1
				
		SELECT	@LicRestrictCountry = COALESCE(@LicRestrictCountry + ',' + CONVERT(VARCHAR(10),LocationLimitId), CONVERT(VARCHAR(10),LocationLimitId)) 
		FROM	dbo.LicenseeLocationLimit WITH(NOLOCK)
		WHERE	LicenseeId = @LicenseeId
				AND LicenseeLocationType = 2
				
		SELECT @LicOddsType = COALESCE(@LicOddsType + ',' + CONVERT(VARCHAR(10), OddsTypeId), CONVERT(VARCHAR(10), OddsTypeId))
		FROM dbo.LicenseeOddsType WITH(NOLOCK)
		WHERE LicenseeId = @LicenseeId
		
		SELECT @IntegrationMethod = COALESCE(@IntegrationMethod + ',' + CONVERT(VARCHAR(10), IntegrationMethodId), CONVERT(VARCHAR(10), IntegrationMethodId))
		FROM dbo.LicenseeIntegrationMethod WITH(NOLOCK)
		WHERE LicenseeId = @LicenseeId
				
		SET @LicLanguage = (
								SELECT	ll.LanguageId	AS '@id'
								FROM	dbo.LicenseeLanguage AS ll WITH (NOLOCK)
								WHERE	ll.LicenseeId = @LicenseeId AND ll.LanguageId <> 4
								FOR XML PATH('row'), ROOT('root')		
							)
		
		SET @LicLanguageSB = (
								SELECT	ll.LanguageId	AS '@id'
								FROM	dbo.LicenseeProductLanguage AS ll WITH (NOLOCK)
								WHERE	ll.LicenseeId = @LicenseeId
								FOR XML PATH('row'), ROOT('root')		
							)
		
		SET @LicService = (
								SELECT	p.ServiceId			AS '@sid'
										,lp.PropertyId		AS '@pid'
										,lp.PropertyValue	AS '@val'
								FROM	dbo.LicenseeProperty lp WITH (NOLOCK)
									INNER JOIN dbo.Property p WITH (NOLOCK)
										ON	p.PropertyId = lp.PropertyId
								WHERE	lp.LicenseeId = @LicenseeId
								FOR XML PATH('row'), ROOT('root')		
							)
			
		SELECT	l.LicenseeName
				,l.RegisteredLicenseeName
				,l.LicenseeCompanyName
				,l.LicenseeStatusId
				,l.LicenseeGroupId
				,l.SoftLaunch
				,l.FullLaunch
				,l.MainUrl
				,l.APILinkageUrl
				,@LicBackupLink				AS BackUpLink
				,CASE WHEN c.ContactID IS NOT NULL THEN 1 ELSE 0 END AS HasMainContact
				,c.ContactName
				,c.ContactPosition			AS Position
				,c.ContactDepartment		AS Department
				,c.ContactEmail				AS Email
				,c.ContactPhoneNumber		AS PhoneNumber
				,c.ContactSkype				AS Skype
				,c.Remark					AS MainContactRemark
				,@OfferedCurrencies			AS OfferedCurrencies
				,l.LicenseeLocationId
				,@LicTargetMarket			AS TargetedMarket
				,@LicLanguage				AS PreferredLanguage
				,@LicLanguageSB				AS SBOfferedLanguage
				,@LicOddsType				AS OddsType
				,@LicService				AS ServiceIncluded
				,@LicRestrictCountry		AS RestrictCountry
				,@IntegrationMethod			AS IntegrationMethod
				,l.RestrictedLocationRemark
				,l.Remark					AS LicenseeRemark
				,l.IsChineseMarketOnly		AS IsChineseMarketOnly
				,l.IsReseller				AS IsReseller
				,l.InvoiceBaseCurrency		AS InvoiceBaseCurrency
				,l.InvoiceLanguage			AS InvoiceLanguage
				,l.PlatformId				AS PlatformId
				,l.TypeId					AS TypeId
		FROM	dbo.Licensee l WITH(NOLOCK)
			LEFT JOIN dbo.Contact c WITH(NOLOCK) 
				ON	l.LicenseeId = c.LicenseeID AND c.IsMain = 1	
		WHERE	l.LicenseeId = @LicenseeId
	END
	ELSE IF @Step = 2
	BEGIN
		SELECT	p.ProductId
				,p.ProductName
				,pt.Id AS ProductTypeId
				,pt.ProductTypeName
				,lp.LaunchDate
				,lp.TerminationDate
				,CASE WHEN lp.ProductId IS NOT NULL THEN 1 ELSE 0 END AS Selected
		FROM	dbo.Product p WITH(NOLOCK)
			LEFT JOIN dbo.LicenseeProduct lp WITH(NOLOCK)
				ON	p.ProductId = lp.ProductId
					AND lp.LicenseeId = @LicenseeId
			LEFT JOIN dbo.ProductType pt WITH(NOLOCK)
				ON p.ProductTypeId = pt.Id
		WHERE 	p.Active = 1
		ORDER BY pt.[Order], p.[Order]
					
		SELECT f.FeatureId
				,f.FeatureName
				,lf.LaunchDate
				,lf.TerminationDate
				,CASE WHEN lf.FeatureId IS NOT NULL THEN 1 ELSE 0 END AS Selected
		FROM	dbo.Feature f WITH(NOLOCK)
			LEFT JOIN dbo.LicenseeFeature lf WITH(NOLOCK)
				ON	lf.FeatureId = f.FeatureId
					AND lf.LicenseeId = @LicenseeId
		ORDER BY f.FeatureId
	END
	ELSE IF @Step = 3
	BEGIN
		SELECT	@PMUserId = ui.UserId
		FROM	dbo.UserInfo ui WITH(NOLOCK)
			INNER JOIN dbo.UserLicensee ul WITH(NOLOCK)
				ON	ui.UserId = ul.UserId
					AND ui.PositionId = 5 -- PM
					AND ul.LicenseeId = @LicenseeId
					
		SELECT	@AMUserId = ui.UserId
		FROM	dbo.UserInfo ui WITH(NOLOCK)
			INNER JOIN dbo.UserLicensee ul WITH(NOLOCK)
				ON	ui.UserId = ul.UserId
					AND ui.PositionId = 6 -- AM
					AND ul.LicenseeId = @LicenseeId
					
		SET @LicAccount = (
								SELECT	la.[Order]		AS '@order'
										,la.AccountType AS '@type'
										,la.UserName	AS '@username'
										,la.UserPwd		AS '@password'
										,la.Url			AS '@url'
								FROM	dbo.LicenseeAccountInfo AS la WITH (NOLOCK)
								WHERE	la.LicenseeId = @LicenseeId
								FOR XML PATH('row'), ROOT('root')		
							)
							
		SELECT @AMUserId		AS AMUser
				,@PMUserId		AS PMUser
				,@LicAccount	AS AccountInfo
				,InternalURL
		FROM dbo.Licensee WITH(NOLOCK)
		WHERE LicenseeId = @LicenseeId
	END
END

GO