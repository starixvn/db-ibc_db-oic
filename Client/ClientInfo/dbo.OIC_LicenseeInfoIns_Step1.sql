/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="1"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeInfoIns_Step1]
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
	
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
	
	,@LicenseeId			INT				= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2014-12-18
	Task: Insert client general info - Step1 [Redmine:#27752]
	DB: DBOIC/BODB_OIC 
	
	Revisions:
		- 20160805@Percy: Expand length of params: @LicTargetMarket, @LicRestrictCountry [RedmineID: #62099]
		- 20160823@Percy: Add param: @LicLanguageSB - Sportbook offered language [RedmineID: #62883]
		- 20170517@Percy: Add Chinese Market Only [RedmineID: #74330]
		- 20170809@Percy: Extend Url length [RedmineID: #81392]
		- 20170828@Scofield: Add Reseller [#82144]
		- 20190715@Howard: Add Odds Type [RedmineId: #115460]
	
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
	
	-- Insert Licensee
	BEGIN TRY
		INSERT INTO dbo.Licensee (
			LicenseeName
			,RegisteredLicenseeName
			,LicenseeTypeId
			,LicenseeCompanyName
			,LicenseeStatusId
			,SoftLaunch
			,FullLaunch
			,MainUrl
			,APILinkageUrl
			,LicenseeLocationId
			,RestrictedLocationRemark
			,Remark
			,IsChineseMarketOnly
			,IsReseller
			)
		VALUES(
			@SiteName
			,@RegisteredSiteName
			,@LicenseeTypeId
			,@CompanyName
			,@LicenseeStatusId
			,@SoftLaunch
			,@FullLaunch
			,@MainUrl
			,@APIUrl
			,@LocationId		
			,@RestrictCountryRemark	
			,@Remark
			,@IsChineseMarketOnly
			,@IsReseller
		)
	
		SET @LicenseeId = SCOPE_IDENTITY()
		
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 100
		RETURN
	END CATCH
	
	-- Insert Backup Url
	IF @LicBackUpLink IS NOT NULL
	BEGIN
		INSERT INTO dbo.UrlBackup(
				LicenseeId
				,UrlValue
				,[Order]
		)
		SELECT	@LicenseeId
				,t.c.value('@val', 'varchar(3000)')
				, ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS rownumber
		FROM @LicBackUpLink.nodes('root/row') t(c)
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 101
			RETURN
		END
	END
	
	-- Insert Main Contact
	IF @HasMainContact = 1
	BEGIN
		INSERT INTO dbo.Contact (
				LicenseeID
				,ContactName
				,ContactPosition
				,ContactDepartment
				,ContactEmail
				,ContactSkype
				,ContactPhoneNumber
				,ContactType
				,Remark
				,IsMain
		)
		SELECT @LicenseeId
				,@MainContactName
				,@Position
				,@Department
				,@Email
				,@Skype
				,@PhoneNumber
				,0
				,@MainContactRemark
				,1
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 102
			RETURN
		END
	END
	
	-- Insert currencies offered
	IF @CurrenciesOffered IS NOT NULL
	BEGIN
		INSERT INTO dbo.LicenseeCurrency (LicenseeId, CurrencyId)
		SELECT @LicenseeId, CONVERT(INT, s.val)
		FROM dbo.strSplit(@CurrenciesOffered, ',') s 
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 103
			RETURN
		END
	END
	
	-- Insert targeted market
	IF @LicTargetMarket IS NOT NULL
	BEGIN
		INSERT INTO dbo.LicenseeLocationLimit (LicenseeId, LocationLimitId, LicenseeLocationType)
		SELECT @LicenseeId, CONVERT(INT, s.val), 1
		FROM dbo.strSplit(@LicTargetMarket,',') s
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 104
			RETURN
		END
	END
	
	-- Insert prefer comunicate language
	IF @LicLanguage IS NOT NULL
	BEGIN
		INSERT INTO dbo.LicenseeLanguage (
				LicenseeId
				,LanguageId
		)		
		SELECT	@LicenseeId
				,t.c.value('@id','int')
		FROM @LicLanguage.nodes('root/row') t(c)
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 105
			RETURN
		END
	END
	
	-- Insert service included
	IF @LicService IS NOT NULL
	BEGIN
		INSERT INTO dbo.LicenseeProperty (
				LicenseeId
				,PropertyId
				,PropertyValue
		)
		SELECT	@LicenseeId
				,t.c.value('@pid', 'tinyint') AS Propertyid
	  			,t.c.value('@val', 'varchar(3000)') AS Value
		FROM @LicService.nodes('/root/row') AS t(c)	
	
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 106
			RETURN
		END
	END
	
	-- Insert country restrict		
	IF @LicRestrictCountry IS NOT NULL
	BEGIN
		
		INSERT INTO dbo.LicenseeLocationLimit (LicenseeId, LocationLimitId, LicenseeLocationType)
		SELECT @LicenseeId, CONVERT(INT, s.val), 2
		FROM dbo.strSplit(@LicRestrictCountry, ',') s	
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 107
			RETURN
		END
	END

	-- Insert Sportbook offered language
	IF @LicLanguageSB IS NOT NULL
	BEGIN
		INSERT INTO dbo.LicenseeProductLanguage (
				LicenseeId
				,LanguageId
		)		
		SELECT	@LicenseeId
				,t.c.value('@id','int')
		FROM @LicLanguageSB.nodes('root/row') t(c)
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 108
			RETURN
		END
	END
	
	-- Insert odds type
	IF @LicOddsType IS NOT NULL AND @LicOddsType <> ''
	BEGIN
		INSERT INTO dbo.LicenseeOddsType(
			LicenseeId,
			OddsTypeId
		)
		SELECT @LicenseeId, CONVERT(INT, s.val)
		FROM dbo.strSplit(@LicOddsType, ',') AS s
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 109
			RETURN
		END
	END

	SELECT @ErrCode = 0
END

GO