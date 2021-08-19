/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LogListSel_Details]
	@ActionID INT
AS
/*
	Creator: Percy
	Date: 2016-10-10
	DB: DBOIC.bodb_OIC
	Task: View detail of log list [RedmineID: #64713]

	Revisions:
		- 20170328@Percy: Add new function: Client List [RemineID: #70323]
		- 20170525@Percy: Implement new request [RedmineID: #70326, #74330, #74879]
		- 20170802@Percy: Support Url testing account [RedmineID: #80712]
		- 20170828@Scofield: Add Reseller [#82144]
		- 20171019@Scofield: Update log for update Amendment Notification [#84004]
		- 201811016@Scofield: Update Result Amendment Language Order [#102847]
		- 20190717@Howard: Add Odds Type [#115460]
		- 20190815@Howard: Batch update features and products [#115462]
		- 20200203@Hogan: Add Licensee Group [RedmineID: #126855]
		- 20210810@Hogan: Add invoice base currency and invoice language for licensee [RedmindId: #157466]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @Result TABLE (ID TINYINT, Field NVARCHAR(100), OldValue NVARCHAR(MAX), NewValue NVARCHAR(MAX))

	DECLARE @LogActionId INT
	SELECT  @LogActionId = LogActionId FROM dbo.UserLog_RunSP WITH(NOLOCK) WHERE Id = @ActionID

	IF @LogActionId IN (7,8) -- Insert/Update Client
	BEGIN
		DECLARE
			@TypeOfLicensee NVARCHAR(30),
			@Sitename NVARCHAR(100),
			@RegisteredSitename NVARCHAR(100),
			@CompanyName NVARCHAR(100),
			@ClientStatus NVARCHAR(30),
			@ClientGroup NVARCHAR(100),
			@SoftLaunch NVARCHAR(10), -- datetime format: mm/dd/yyyy
			@FullLaunch NVARCHAR(10), -- datetime format: mm/dd/yyyy
			@MainUrl NVARCHAR(MAX),
			@BackupUrl NVARCHAR(MAX), -- list of backup link
			@APIUrl NVARCHAR(MAX),
			@ContactName NVARCHAR(100),
			@ContactPosition NVARCHAR(100),
			@ContactDepartment NVARCHAR(100),
			@ContactEmail NVARCHAR(50),
			@ContactMobile NVARCHAR(50),
			@ContactSkype NVARCHAR(50),
			@ContactRemark NVARCHAR(600),
			@OfferedCurrencies NVARCHAR(MAX), -- list of currencies
			@SBOfferedLanguages NVARCHAR(MAX), -- list of sportbook languagues
			@ClientLocation NVARCHAR(50),
			@ClientTargetMarket NVARCHAR(MAX), -- list of target markets
			@CommunicationLanguages NVARCHAR(MAX), -- list of communication languagues
			@OddsTypes NVARCHAR(300), -- list of odds types
			@InvoiceBaseCurrency VARCHAR(4),
			@InvoiceLanguage NVARCHAR(50),
			@UnasService NVARCHAR(100),
			@UnasService_Username NVARCHAR(100),
			@UnasService_Password NVARCHAR(100),
			@MobileService NVARCHAR(100),
			@MobileService_WAP NVARCHAR(MAX),
			@MobileService_Smartphone NVARCHAR(MAX),
			@BAAgreement NVARCHAR(100),
			@BAAgreement_Group NVARCHAR(100),
			@BAAgreement_JoinDate NVARCHAR(100),
			@Affiliate NVARCHAR(100),
			@RestrictedCountry NVARCHAR(MAX), -- list of restricted countries
			@RestrictedCountry_Exception NVARCHAR(2000),
			@Remark NVARCHAR(3000),
			@Products NVARCHAR(MAX), -- list of products
			@Features NVARCHAR(MAX), -- list of features
			@AM NVARCHAR(100),
			@PM NVARCHAR(100),
			@Acc1 NVARCHAR(MAX),
			@AccUrl1 NVARCHAR(MAX),
			@Acc2 NVARCHAR(MAX),
			@AccUrl2 NVARCHAR(MAX),
			@Acc3 NVARCHAR(MAX),
			@AccUrl3 NVARCHAR(MAX),
			@Acc4 NVARCHAR(MAX),
			@AccUrl4 NVARCHAR(MAX),
			@Acc5 NVARCHAR(MAX),
			@AccUrl5 NVARCHAR(MAX),
			@CS NVARCHAR(MAX),
			@TA NVARCHAR(MAX),
			@IsChineseMarketOnly NVARCHAR(MAX),
			@Reseller NVARCHAR(MAX),
			@InternalURL NVARCHAR(MAX),

			@TypeOfLicensee_old NVARCHAR(30),
			@Sitename_old NVARCHAR(100),
			@RegisteredSitename_old NVARCHAR(100),
			@CompanyName_old NVARCHAR(100),
			@ClientStatus_old NVARCHAR(30),
			@ClientGroup_old NVARCHAR(100),
			@SoftLaunch_old NVARCHAR(10), -- datetime format: mm/dd/yyyy
			@FullLaunch_old NVARCHAR(10), -- datetime format: mm/dd/yyyy
			@MainUrl_old NVARCHAR(MAX),
			@BackupUrl_old NVARCHAR(MAX), -- list of backup link
			@APIUrl_old NVARCHAR(MAX),
			@ContactName_old NVARCHAR(100),
			@ContactPosition_old NVARCHAR(100),
			@ContactDepartment_old NVARCHAR(100),
			@ContactEmail_old NVARCHAR(50),
			@ContactMobile_old NVARCHAR(50),
			@ContactSkype_old NVARCHAR(50),
			@ContactRemark_old NVARCHAR(600),
			@OfferedCurrencies_old NVARCHAR(MAX), -- list of currencies
			@SBOfferedLanguages_old NVARCHAR(MAX), -- list of sportbook languagues
			@ClientLocation_old NVARCHAR(50),
			@ClientTargetMarket_old NVARCHAR(MAX), -- list of target markets
			@CommunicationLanguages_old NVARCHAR(MAX), -- list of communication languagues
			@OddsTypes_old NVARCHAR(300), -- list of odds types
			@InvoiceBaseCurrency_old VARCHAR(4),
			@InvoiceLanguage_old NVARCHAR(50),
			@UnasService_old NVARCHAR(100),
			@UnasService_Username_old NVARCHAR(100),
			@UnasService_Password_old NVARCHAR(100),
			@MobileService_old NVARCHAR(100),
			@MobileService_WAP_old NVARCHAR(MAX),
			@MobileService_Smartphone_old NVARCHAR(MAX),
			@BAAgreement_old NVARCHAR(100),
			@BAAgreement_Group_old NVARCHAR(100),
			@BAAgreement_JoinDate_old NVARCHAR(100),
			@Affiliate_old NVARCHAR(100),
			@RestrictedCountry_old NVARCHAR(MAX), -- list of restricted countries
			@RestrictedCountry_Exception_old NVARCHAR(2000),
			@Remark_old NVARCHAR(3000),
			@Products_old NVARCHAR(MAX), -- list of products
			@Features_old NVARCHAR(MAX), -- list of features
			@AM_old NVARCHAR(100),
			@PM_old NVARCHAR(100),
			@Acc1_old NVARCHAR(MAX),
			@AccUrl1_old NVARCHAR(MAX),
			@Acc2_old NVARCHAR(MAX),
			@AccUrl2_old NVARCHAR(MAX),
			@Acc3_old NVARCHAR(MAX),
			@AccUrl3_old NVARCHAR(MAX),
			@Acc4_old NVARCHAR(MAX),
			@AccUrl4_old NVARCHAR(MAX),
			@Acc5_old NVARCHAR(MAX),
			@AccUrl5_old NVARCHAR(MAX),
			@CS_old NVARCHAR(MAX),
			@TA_old NVARCHAR(MAX),
			@IsChineseMarketOnly_old NVARCHAR(MAX),
			@Reseller_old NVARCHAR(MAX),
			@InternalURL_old NVARCHAR(MAX)

		-- Client Info
		SELECT
			@TypeOfLicensee = d.c.value('@tn', 'NVARCHAR(30)'), -- type of licensee
			@Sitename = d.c.value('@ln', 'NVARCHAR(100)'), -- site name
			@RegisteredSitename = d.c.value('@rln', 'NVARCHAR(100)'), -- registered site name
			@CompanyName = d.c.value('@cn', 'NVARCHAR(100)'), -- company name
			@ClientStatus = d.c.value('@sn', 'NVARCHAR(30)'), -- client status
			@ClientGroup = d.c.value('@gn', 'NVARCHAR(100)'), -- client group
			@SoftLaunch = d.c.value('@sl', 'DATE'), -- soft launch
			@FullLaunch = d.c.value('@fl', 'DATE'), -- full launch
			@MainUrl = d.c.value('@mu', 'NVARCHAR(MAX)'), -- main domain url
			@APIUrl = d.c.value('@au', 'NVARCHAR(MAX)'), -- api url
			@RestrictedCountry_Exception = d.c.value('@rlr', 'NVARCHAR(2000)'), -- add exception for client country restrict list
			@Remark = d.c.value('@rm', 'NVARCHAR(600)'), -- remark
			@ClientLocation = d.c.value('@lc', 'NVARCHAR(50)'), -- location
			@PM = d.c.value('@pmn', 'NVARCHAR(50)'), -- project manager
			@AM = d.c.value('@amn', 'NVARCHAR(50)'), -- account manager
			@IsChineseMarketOnly = d.c.value('@icm', 'NVARCHAR(1)'),
			@Reseller = d.c.value('@res', 'NVARCHAR(1)'),
			@InternalURL = d.c.value('@iu', 'NVARCHAR(MAX)'),
			@InvoiceBaseCurrency = d.c.value('@ibc', 'VARCHAR(4)'), -- invoice base currency
			@InvoiceLanguage = d.c.value('@il', 'NVARCHAR(50)'), -- invoice language

			@TypeOfLicensee_old = od.c.value('@tn', 'NVARCHAR(30)'), -- type of licensee
			@Sitename_old = od.c.value('@ln', 'NVARCHAR(100)'), -- site name
			@RegisteredSitename_old = od.c.value('@rln', 'NVARCHAR(100)'), -- registered site name
			@CompanyName_old = od.c.value('@cn', 'NVARCHAR(100)'), -- company name
			@ClientStatus_old = od.c.value('@sn', 'NVARCHAR(30)'), -- client status
			@ClientGroup_old = od.c.value('@gn', 'NVARCHAR(100)'), -- client group
			@SoftLaunch_old = od.c.value('@sl', 'DATE'), -- soft launch
			@FullLaunch_old = od.c.value('@fl', 'DATE'), -- full launch
			@MainUrl_old = od.c.value('@mu', 'NVARCHAR(MAX)'), -- main domain url
			@APIUrl_old = od.c.value('@au', 'NVARCHAR(MAX)'), -- api url
			@RestrictedCountry_Exception_old = od.c.value('@rlr', 'NVARCHAR(2000)'), -- add exception for client country restrict list
			@Remark_old = od.c.value('@rm', 'NVARCHAR(600)'), -- remark
			@ClientLocation_old = od.c.value('@lc', 'NVARCHAR(50)'), -- location
			@PM_old = od.c.value('@pmn', 'NVARCHAR(50)'), -- project manager
			@AM_old = od.c.value('@amn', 'NVARCHAR(50)'), -- account manager
			@IsChineseMarketOnly_old = od.c.value('@icm', 'NVARCHAR(1)'),
			@Reseller_old = od.c.value('@res', 'NVARCHAR(1)'),
			@InternalURL_old = od.c.value('@iu', 'NVARCHAR(MAX)'),
			@InvoiceBaseCurrency_old = od.c.value('@ibc', 'VARCHAR(4)'), -- invoice base currency
			@InvoiceLanguage_old = od.c.value('@il', 'NVARCHAR(50)') -- invoice language
		FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		IF ISNULL(@IsChineseMarketOnly, '0') = '0'
			SELECT @IsChineseMarketOnly = 'Unchecked'
		ELSE
			SELECT @IsChineseMarketOnly = 'Checked'

		IF ISNULL(@IsChineseMarketOnly_old, '0') = '0'
			SELECT @IsChineseMarketOnly_old = 'Unchecked'
		ELSE
			SELECT @IsChineseMarketOnly_old = 'Checked'
			
		IF ISNULL(@Reseller, '0') = '0'
			SELECT @Reseller = 'No'
		ELSE
			SELECT @Reseller = 'Yes'
		
		IF ISNULL(@Reseller_old, '0') = '0'
			SELECT @Reseller_old = 'No'
		ELSE
			SELECT @Reseller_old = 'Yes'

		IF @LogActionId = 7
		BEGIN
			SELECT @IsChineseMarketOnly_old = NULL
			SELECT @Reseller_old = NULL
		END

		-- Backup domain
		;WITH CTE_Url AS
		(
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r/bk/row') AS Data, CONVERT(XML, OldData).query('/r/bk/row') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		)
		, CTE1 AS (
			SELECT
				d.c.value('@lbul', 'NVARCHAR(MAX)') AS Url -- backup domain url
			FROM CTE_Url A
				OUTER APPLY A.Data.nodes('row') d(c)
		)
		, CTE2 AS (
			SELECT
				od.c.value('@lbul', 'NVARCHAR(MAX)') AS Url_old -- backup domain url
			FROM CTE_Url A
				OUTER APPLY A.OldData.nodes('row') od(c) 
		) 
		SELECT	@BackupUrl = (SELECT STUFF((SELECT '<br/>' + Url FROM CTE1 FOR XML PATH('')), 1, 11, '')),
				@BackupUrl_old = (SELECT STUFF((SELECT '<br/>' + Url_old FROM CTE2 FOR XML PATH('')), 1, 11, ''))

		-- Main Contact Info
		SELECT
			@ContactName = d.c.value('@cn', 'NVARCHAR(100)'), -- name
			@ContactPosition = d.c.value('@cp', 'NVARCHAR(100)'), -- position
			@ContactDepartment = d.c.value('@cd', 'NVARCHAR(100)'), -- department
			@ContactEmail = d.c.value('@ce', 'NVARCHAR(50)'), -- email
			@ContactSkype = d.c.value('@cs', 'NVARCHAR(50)'), -- skype
			@ContactMobile = d.c.value('@cpn', 'NVARCHAR(50)'), -- contact number
			@ContactRemark = d.c.value('@crm', 'NVARCHAR(600)'), -- remark

			@ContactName_old = od.c.value('@cn', 'NVARCHAR(100)'), -- name
			@ContactPosition_old = od.c.value('@cp', 'NVARCHAR(100)'), -- position
			@ContactDepartment_old = od.c.value('@cd', 'NVARCHAR(100)'), -- department
			@ContactEmail_old = od.c.value('@ce', 'NVARCHAR(50)'), -- email
			@ContactSkype_old = od.c.value('@cs', 'NVARCHAR(50)'), -- skype
			@ContactMobile_old = od.c.value('@cpn', 'NVARCHAR(50)'), -- contact number
			@ContactRemark_old = od.c.value('@crm', 'NVARCHAR(600)') -- remark
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r/lc/row') AS Data, CONVERT(XML, OldData).query('/r/lc/row') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('row') d(c)
			OUTER APPLY A.OldData.nodes('row') od(c)

		-- Offered Currency
		;WITH CTE_Currency AS (
			SELECT
				d.c.value('@cur', 'NVARCHAR(100)') AS Currency, -- currency name

				od.c.value('@cur', 'NVARCHAR(100)') AS Currency_old -- currency name
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/cr/row') AS Data, CONVERT(XML, OldData).query('/r/cr/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@OfferedCurrencies = (SELECT STUFF((SELECT DISTINCT ', ' + Currency FROM CTE_Currency FOR XML PATH('')), 1, 1, '')),
				@OfferedCurrencies_old = (SELECT STUFF((SELECT DISTINCT ', ' + Currency_old FROM CTE_Currency FOR XML PATH('')), 1, 1, ''))

		-- Sportbook Offered Languages
		;WITH CTE_SBLanguages AS (
			SELECT
				d.c.value('@llnsb', 'NVARCHAR(100)') AS SBLanguage, -- language name

				od.c.value('@llnsb', 'NVARCHAR(100)') AS SBLanguage_old -- language name
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/llsb/row') AS Data, CONVERT(XML, OldData).query('/r/llsb/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@SBOfferedLanguages = (SELECT STUFF((SELECT DISTINCT ', ' + SBLanguage FROM CTE_SBLanguages FOR XML PATH('')), 1, 1, '')),
				@SBOfferedLanguages_old = (SELECT STUFF((SELECT DISTINCT ', ' + SBLanguage_old FROM CTE_SBLanguages FOR XML PATH('')), 1, 1, ''))

		-- Client targeted market
		;WITH CTE_Target AS (
			SELECT
				d.c.value('@tmn', 'NVARCHAR(100)') AS TargetMarket, -- targeted market

				od.c.value('@tmn', 'NVARCHAR(100)') AS TargetMarket_old -- targeted market
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/tm/row') AS Data, CONVERT(XML, OldData).query('/r/tm/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@ClientTargetMarket = (SELECT STUFF((SELECT DISTINCT ', ' + TargetMarket FROM CTE_Target FOR XML PATH('')), 1, 1, '')),
				@ClientTargetMarket_old = (SELECT STUFF((SELECT DISTINCT ', ' + TargetMarket_old FROM CTE_Target FOR XML PATH('')), 1, 1, ''))
		
		-- Preferred communication language
		;WITH CTE_Languages AS (
			SELECT
				d.c.value('@lln', 'NVARCHAR(100)') AS [Language], -- language name

				od.c.value('@lln', 'NVARCHAR(100)') AS Language_old -- language name
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/ll/row') AS Data, CONVERT(XML, OldData).query('/r/ll/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@CommunicationLanguages = (SELECT STUFF((SELECT DISTINCT ', ' + [Language] FROM CTE_Languages FOR XML PATH('')), 1, 1, '')),
				@CommunicationLanguages_old = (SELECT STUFF((SELECT DISTINCT ', ' + Language_old FROM CTE_Languages FOR XML PATH('')), 1, 1, ''))
		
		-- Odds Types
		;WITH CTE_OddsTypes AS (
			SELECT
				d.c.value('@lotn', 'NVARCHAR(50)') AS OddsTypeName, --  odds type name (new)
				od.c.value('@lotn', 'NVARCHAR(50)') AS OddsTypeName_old -- odds type name (old)
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lot/row') AS Data, CONVERT(XML, OldData).query('/r/lot/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
			
		)
		SELECT	@OddsTypes = (SELECT STUFF((SELECT DISTINCT ', ' + OddsTypeName FROM CTE_OddsTypes FOR XML PATH('')), 1, 1, '')),
				@OddsTypes_old = (SELECT STUFF((SELECT DISTINCT ', ' + OddsTypeName_old FROM CTE_OddsTypes FOR XML PATH('')), 1, 1, ''))
		
		-- Services
		;WITH CTE_Service AS (
			SELECT
				d.c.value('@lsid', 'NVARCHAR(100)') AS ServiceId, -- service id
				d.c.value('@lsn', 'NVARCHAR(100)') AS ServiceName, -- service name
				d.c.value('@lspid', 'NVARCHAR(100)') AS SubServiceId, -- service-child id
				d.c.value('@lspv', 'NVARCHAR(MAX)') AS SubServiceName, -- service-child name

				od.c.value('@lsid', 'NVARCHAR(100)') AS ServiceId_old, -- service id
				od.c.value('@lsn', 'NVARCHAR(100)') AS ServiceName_old, -- service name
				od.c.value('@lspid', 'NVARCHAR(100)') AS SubServiceId_old, -- service-child id
				od.c.value('@lspv', 'NVARCHAR(MAX)') AS SubServiceName_old  -- service-child name
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/ls/row') AS Data, CONVERT(XML, OldData).query('/r/ls/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@UnasService = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId = 1),
				@UnasService_Username = (SELECT TOP 1 SubServiceName FROM CTE_Service WHERE SubServiceId = 2),
				@UnasService_Password = (SELECT TOP 1 SubServiceName FROM CTE_Service WHERE SubServiceId = 1),
				@MobileService = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId = 2),
				@MobileService_WAP = (SELECT TOP 1 SubServiceName FROM CTE_Service WHERE SubServiceId = 4),
				@MobileService_Smartphone = (SELECT TOP 1 SubServiceName FROM CTE_Service WHERE SubServiceId = 3),
				@BAAgreement = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId = 3),
				@BAAgreement_Group = (SELECT TOP 1 SubServiceName FROM CTE_Service WHERE SubServiceId = 6),
				@BAAgreement_JoinDate = (SELECT TOP 1 SubServiceName FROM CTE_Service WHERE SubServiceId = 5),
				@Affiliate = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId = 4),

				@UnasService_old = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId_old = 1),
				@UnasService_Username_old = (SELECT TOP 1 SubServiceName_old FROM CTE_Service WHERE SubServiceId_old = 2),
				@UnasService_Password_old = (SELECT TOP 1 SubServiceName_old FROM CTE_Service WHERE SubServiceId_old = 1),
				@MobileService_old = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId_old = 2),
				@MobileService_WAP_old = (SELECT TOP 1 SubServiceName_old FROM CTE_Service WHERE SubServiceId_old = 4),
				@MobileService_Smartphone_old = (SELECT TOP 1 SubServiceName_old FROM CTE_Service WHERE SubServiceId_old = 3),
				@BAAgreement_old = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId_old = 3),
				@BAAgreement_Group_old = (SELECT TOP 1 SubServiceName_old FROM CTE_Service WHERE SubServiceId_old = 6),
				@BAAgreement_JoinDate_old = (SELECT TOP 1 SubServiceName_old FROM CTE_Service WHERE SubServiceId_old = 5),
				@Affiliate_old = (SELECT TOP 1 N'Checked' FROM CTE_Service WHERE ServiceId_old = 4)
		
		IF @LogActionId = 8 -- update
		BEGIN
			SELECT	@UnasService = ISNULL(@UnasService, N'Unchecked'),
					@MobileService = ISNULL(@MobileService, N'Unchecked'),
					@BAAgreement = ISNULL(@BAAgreement, N'Unchecked'),
					@Affiliate = ISNULL(@Affiliate, N'Unchecked'),
				
					@UnasService_old = ISNULL(@UnasService_old, N'Unchecked'),
					@MobileService_old = ISNULL(@MobileService_old, N'Unchecked'),
					@BAAgreement_old = ISNULL(@BAAgreement_old, N'Unchecked'),
					@Affiliate_old = ISNULL(@Affiliate_old, N'Unchecked')
		END
		
		-- Client country restrict list
		;WITH CTE_Country AS (
			SELECT
				d.c.value('@rln', 'NVARCHAR(100)') AS Country, -- country name

				od.c.value('@rln', 'NVARCHAR(100)') AS Country_old  -- country name
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/rl/row') AS Data, CONVERT(XML, OldData).query('/r/rl/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@RestrictedCountry = (SELECT STUFF((SELECT DISTINCT ', ' + Country FROM CTE_Country FOR XML PATH('')), 1, 1, '')),
				@RestrictedCountry_old = (SELECT STUFF((SELECT DISTINCT  ', ' + Country_old FROM CTE_Country FOR XML PATH('')), 1, 1, ''))

		-- Products
		;WITH CTE_Product AS (
			SELECT
				d.c.value('@lpn', 'NVARCHAR(100)') AS ProductName, -- product name
				d.c.value('@lpl', 'DATE') AS LaunchDate, -- launch date
				d.c.value('@lpt', 'DATE') AS TerminatedDate, -- termination date
				d.c.value('@lpod', 'INT') AS [Order], -- order

				od.c.value('@lpn', 'NVARCHAR(100)') AS ProductName_old, -- product name
				od.c.value('@lpl', 'DATE') AS LaunchDate_old, -- launch date
				od.c.value('@lpt', 'DATE') AS TerminatedDate_old, -- termination date
				od.c.value('@lpod', 'INT') AS [Order_old] -- order
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lp/row') AS Data, CONVERT(XML, OldData).query('/r/lp/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Products = (SELECT STUFF((SELECT '<br/>' + ProductName + CASE WHEN LaunchDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate, 101) END + CASE WHEN TerminatedDate IS NULL THEN '' ELSE  ' - ' + CONVERT(VARCHAR(10), TerminatedDate, 101) END FROM (SELECT DISTINCT ProductName, [Order], LaunchDate, TerminatedDate FROM CTE_Product) CTE_Product ORDER BY [Order] FOR XML PATH('')), 1, 11, '')),
				@Products_old = (SELECT STUFF((SELECT '<br/>' + ProductName_old + CASE WHEN LaunchDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate_old, 101) END + CASE WHEN TerminatedDate_old IS NULL THEN '' ELSE  ' - ' + CONVERT(VARCHAR(10), TerminatedDate_old, 101) END FROM (SELECT DISTINCT ProductName_old, [Order_old], LaunchDate_old, TerminatedDate_old FROM CTE_Product) CTE_Product ORDER BY [Order_old] FOR XML PATH('')), 1, 11, ''))
		
		-- Features
		;WITH CTE_Feature AS (
			SELECT
				d.c.value('@lfid', 'INT') AS FeatureId, -- feature id
				d.c.value('@lfn', 'NVARCHAR(100)') AS FeatureName, -- feature name
				d.c.value('@lfl', 'DATE') AS LaunchDate, -- launch date
				d.c.value('@lft', 'DATE') AS TerminatedDate, -- termination date

				od.c.value('@lfid', 'INT') AS FeatureId_old, -- feature id
				od.c.value('@lfn', 'NVARCHAR(100)') AS FeatureName_old, -- feature name
				od.c.value('@lfl', 'DATE') AS LaunchDate_old, -- launch date
				od.c.value('@lft', 'DATE') AS TerminatedDate_old -- termination date
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lf/row') AS Data, CONVERT(XML, OldData).query('/r/lf/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Features = (SELECT STUFF((SELECT '<br/>' + FeatureName + CASE WHEN LaunchDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate, 101) END + CASE WHEN TerminatedDate IS NULL THEN '' ELSE  ' - ' + CONVERT(VARCHAR(10), TerminatedDate, 101) END FROM (SELECT DISTINCT FeatureId, FeatureName, LaunchDate, TerminatedDate FROM CTE_Feature) CTE_Feature ORDER BY FeatureId FOR XML PATH('')), 1, 11, '')),
				@Features_old = (SELECT STUFF((SELECT '<br/>' + FeatureName_old + CASE WHEN LaunchDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate_old, 101) END + CASE WHEN TerminatedDate_old IS NULL THEN '' ELSE  ' - ' + CONVERT(VARCHAR(10), TerminatedDate_old, 101) END FROM (SELECT DISTINCT FeatureId_old, FeatureName_old, LaunchDate_old, TerminatedDate_old FROM CTE_Feature) CTE_Feature ORDER BY FeatureId_old FOR XML PATH('')), 1, 11, ''))

		-- Account Info
		;WITH CTE_Account_Font AS (
			SELECT
				d.c.value('@lan', 'NVARCHAR(100)') AS Username, -- username
				d.c.value('@lap', 'NVARCHAR(100)') AS [Password], -- password
				d.c.value('@lat', 'NVARCHAR(10)') AS [Type], -- type -- 1: Customer front end, 2: Internal backend (OneonOne CS), 3: Internal backend (Training Account)
				d.c.value('@lod', 'NVARCHAR(10)') AS [Order], -- order
				d.c.value('@lu', 'VARCHAR(MAX)') AS Url, -- url

				od.c.value('@lan', 'NVARCHAR(100)') AS Username_old, -- username
				od.c.value('@lap', 'NVARCHAR(100)') AS Password_old, -- password
				od.c.value('@lat', 'NVARCHAR(10)') AS Type_old,  -- type -- 1: Customer front end, 2: Internal backend (OneonOne CS), 3: Internal backend (Training Account)
				od.c.value('@lod', 'NVARCHAR(10)') AS Order_old, -- order
				od.c.value('@lu', 'VARCHAR(MAX)') AS Url_old -- url
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/la/row') AS Data, CONVERT(XML, OldData).query('/r/la/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT
			@Acc1 = CASE WHEN [Type] = N'1' AND [Order] = 1 THEN Username + ' - ' + [Password] ELSE @Acc1 END,
			@Acc2 = CASE WHEN [Type] = N'1' AND [Order] = 2 THEN Username + ' - ' + [Password] ELSE @Acc2 END,
			@Acc3 = CASE WHEN [Type] = N'1' AND [Order] = 3 THEN Username + ' - ' + [Password] ELSE @Acc3 END,
			@Acc4 = CASE WHEN [Type] = N'1' AND [Order] = 4 THEN Username + ' - ' + [Password] ELSE @Acc4 END,
			@Acc5 = CASE WHEN [Type] = N'1' AND [Order] = 5 THEN Username + ' - ' + [Password] ELSE @Acc5 END,

			@Acc1_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 1 THEN Username_old + ' - ' + [Password_old] ELSE @Acc1_old END,
			@Acc2_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 2 THEN Username_old + ' - ' + [Password_old] ELSE @Acc2_old END,
			@Acc3_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 3 THEN Username_old + ' - ' + [Password_old] ELSE @Acc3_old END,
			@Acc4_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 4 THEN Username_old + ' - ' + [Password_old] ELSE @Acc4_old END,
			@Acc5_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 5 THEN Username_old + ' - ' + [Password_old] ELSE @Acc5_old END,

			@AccUrl1 = CASE WHEN [Type] = N'1' AND [Order] = 1 THEN Url ELSE @AccUrl1 END,
			@AccUrl2 = CASE WHEN [Type] = N'1' AND [Order] = 2 THEN Url ELSE @AccUrl2 END,
			@AccUrl3 = CASE WHEN [Type] = N'1' AND [Order] = 3 THEN Url ELSE @AccUrl3 END,
			@AccUrl4 = CASE WHEN [Type] = N'1' AND [Order] = 4 THEN Url ELSE @AccUrl4 END,
			@AccUrl5 = CASE WHEN [Type] = N'1' AND [Order] = 5 THEN Url ELSE @AccUrl5 END,

			@AccUrl1_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 1 THEN Url_old ELSE @AccUrl1_old END,
			@AccUrl2_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 2 THEN Url_old ELSE @AccUrl2_old END,
			@AccUrl3_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 3 THEN Url_old ELSE @AccUrl3_old END,
			@AccUrl4_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 4 THEN Url_old ELSE @AccUrl4_old END,
			@AccUrl5_old = CASE WHEN [Type_old] = N'1' AND [Order_old] = 5 THEN Url_old ELSE @AccUrl5_old END
		FROM CTE_Account_Font

		SELECT
			@Acc1 = ISNULL(@Acc1, ' - '),
			@Acc2 = ISNULL(@Acc2, ' - '),
			@Acc3 = ISNULL(@Acc3, ' - '),
			@Acc4 = ISNULL(@Acc4, ' - '),
			@Acc5 = ISNULL(@Acc5, ' - '),

			@Acc1_old = ISNULL(@Acc1_old, ' - '),
			@Acc2_old = ISNULL(@Acc2_old, ' - '),
			@Acc3_old = ISNULL(@Acc3_old, ' - '),
			@Acc4_old = ISNULL(@Acc4_old, ' - '),
			@Acc5_old = ISNULL(@Acc5_old, ' - '),

			@AccUrl1 = ISNULL(@AccUrl1, ''),
			@AccUrl2 = ISNULL(@AccUrl2, ''),
			@AccUrl3 = ISNULL(@AccUrl3, ''),
			@AccUrl4 = ISNULL(@AccUrl4, ''),
			@AccUrl5 = ISNULL(@AccUrl5, ''),

			@AccUrl1_old = ISNULL(@AccUrl1_old, ''),
			@AccUrl2_old = ISNULL(@AccUrl2_old, ''),
			@AccUrl3_old = ISNULL(@AccUrl3_old, ''),
			@AccUrl4_old = ISNULL(@AccUrl4_old, ''),
			@AccUrl5_old = ISNULL(@AccUrl5_old, '')

		;WITH CTE_Account_End AS (
			SELECT
				d.c.value('@lan', 'NVARCHAR(100)') AS Username, -- username
				d.c.value('@lap', 'NVARCHAR(100)') AS [Password], -- password
				d.c.value('@lat', 'NVARCHAR(10)') AS [Type], -- type -- 1: Customer front end, 2: Internal backend (OneonOne CS), 3: Internal backend (Training Account)
				d.c.value('@lod', 'NVARCHAR(10)') AS [Order], -- order

				od.c.value('@lan', 'NVARCHAR(100)') AS Username_old, -- username
				od.c.value('@lap', 'NVARCHAR(100)') AS Password_old, -- password
				od.c.value('@lat', 'NVARCHAR(10)') AS Type_old,  -- type -- 1: Customer front end, 2: Internal backend (OneonOne CS), 3: Internal backend (Training Account)
				od.c.value('@lod', 'NVARCHAR(10)') AS Order_old -- order
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/la/row') AS Data, CONVERT(XML, OldData).query('/r/la/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
			WHERE
				(  ISNULL(d.c.value('@lat', 'NVARCHAR(10)'), N'') IN (N'2', N'3')
					OR ISNULL(od.c.value('@lat', 'NVARCHAR(10)'), N'') IN (N'2', N'3')
				)
				AND (
					ISNULL(d.c.value('@lan', 'NVARCHAR(100)'), N'') <> ISNULL(od.c.value('@lan', 'NVARCHAR(100)'), N'')
					OR ISNULL(d.c.value('@lap', 'NVARCHAR(100)'), N'') <> ISNULL(od.c.value('@lap', 'NVARCHAR(100)'), N'')
				)
		)
		SELECT	@CS = (SELECT STUFF((SELECT DISTINCT '<br/>' + Username + ' - ' + [Password] FROM CTE_Account_End WHERE [Type] = N'2' FOR XML PATH('')), 1, 11, '')),
				@CS_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Username_old + ' - ' + Password_old FROM CTE_Account_End WHERE [Type_old] = N'2' FOR XML PATH('')), 1, 11, '')),
				@TA = (SELECT STUFF((SELECT DISTINCT '<br/>' + Username + ' - ' + [Password] FROM CTE_Account_End WHERE [Type] = N'3' FOR XML PATH('')), 1, 11, '')),
				@TA_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Username_old + ' - ' + Password_old FROM CTE_Account_End WHERE [Type_old] = N'3' FOR XML PATH('')), 1, 11, ''))

		SELECT @CS = ISNULL(@CS, N' - '), @CS_old = ISNULL(@CS_old, N' - '), @TA = ISNULL(@TA, N' - '), @TA_old = ISNULL(@TA_old, N' - ')

		INSERT INTO @Result(ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Type of licensee', @TypeOfLicensee, @TypeOfLicensee_old),
			(2, N'Registered Site name', @RegisteredSitename, @RegisteredSitename_old),
			(2, N'Site name', @Sitename, @Sitename_old),
			(3, N'Company name', @CompanyName, @CompanyName_old),
			(4, N'Client Status', @ClientStatus, @ClientStatus_old),
			(5, N'China Market Only', @IsChineseMarketOnly, @IsChineseMarketOnly_old),
			(6, N'Reseller', @Reseller, @Reseller_old),
			(7, N'Soft Launch', @SoftLaunch, @SoftLaunch_old),
			(8, N'Full Launch', @FullLaunch, @FullLaunch_old),
			(9, N'Main domain URL', @MainUrl, @MainUrl_old),
			(10, N'Backup Domain URL', @BackupUrl, @BackupUrl_old),
			(11, N'API URL', @APIUrl, @APIUrl_old),
			(12, N'Main Contact - Name', @ContactName, @ContactName_old),
			(13, N'Main Contact - Position', @ContactPosition, @ContactPosition_old),
			(14, N'Main Contact - Department', @ContactDepartment, @ContactDepartment_old),
			(15, N'Main Contact - Email', @ContactEmail, @ContactEmail_old),
			(16, N'Main Contact - Mobile Number', @ContactMobile, @ContactMobile_old),
			(17, N'Main Contact - Skype username', @ContactSkype, @ContactSkype_old),
			(18, N'Main Contact - Remark', @ContactRemark, @ContactRemark_old),
			(19, N'Offered currencies', @OfferedCurrencies, @OfferedCurrencies_old),
			(20, N'Sportsbook offered languages', @SBOfferedLanguages, @SBOfferedLanguages_old),
			(21, N'Client Location', @ClientLocation, @ClientLocation_old),
			(22, N'Client targeted market', @ClientTargetMarket, @ClientTargetMarket_old),
			(23, N'Preferred communication language', @CommunicationLanguages, @CommunicationLanguages_old),
			(24, N'Odds Type', @OddsTypes, @OddsTypes_old),
			(25, N'Unas service', @UnasService, @UnasService_old),
			(26, N'Unas service - Username', @UnasService_Username, @UnasService_Username_old),
			(27, N'Unas service - Password', @UnasService_Password, @UnasService_Password_old),
			(28, N'Mobile betting service', @MobileService, @MobileService_old),
			(29, N'Mobile betting service - WAP site URL', @MobileService_WAP, @MobileService_WAP_old),
			(30, N'Mobile betting service - Smartphone site URL', @MobileService_Smartphone, @MobileService_Smartphone_old),
			(31, N'BA Agreement', @BAAgreement, @BAAgreement_old),
			(32, N'BA Agreement - Group', @BAAgreement_Group, @BAAgreement_Group_old),
			(33, N'BA Agreement - BA Joined date', @BAAgreement_JoinDate, @BAAgreement_JoinDate_old),
			(34, N'Affiliate Agreement', @Affiliate, @Affiliate_old),
			(35, N'Client country restrict list', @RestrictedCountry, @RestrictedCountry_old),
			(36, N'Add exception for client country restrict list', @RestrictedCountry_Exception, @RestrictedCountry_Exception_old),
			(37, N'Remark', @Remark, @Remark_old),
			(38, N'Products - Launch - Termination', @Products, @Products_old),
			(39, N'Features - Launch - Termination', @Features, @Features_old),
			(40, N'Client Account Manager', @AM, @AM_old),
			(41, N'Client Project Manager', @PM, @PM_old),
			(42, N'Account 1''s URL', @AccUrl1, @AccUrl1_old),
			(43, N'Account 1 (username - password)', @Acc1, @Acc1_old),
			(44, N'Account 2''s URL', @AccUrl2, @AccUrl2_old),
			(45, N'Account 2 (username - password)', @Acc2, @Acc2_old),
			(46, N'Account 3''s URL', @AccUrl3, @AccUrl3_old),
			(47, N'Account 3 (username - password)', @Acc3, @Acc3_old),
			(48, N'Account 4''s URL', @AccUrl4, @AccUrl4_old),
			(49, N'Account 4 (username - password)', @Acc4, @Acc4_old),
			(50, N'Account 5''s URL', @AccUrl5, @AccUrl5_old),
			(51, N'Account 5 (username - password)', @Acc5, @Acc5_old),
			(52, N'Internal backend URL', @InternalURL, @InternalURL_old),
			(53, N'OneonOne CS (username - password)', @CS, @CS_old),
			(54, N'Training Account (username - password)', @TA, @TA_old),
			(55, N'Client Group', @ClientGroup, @ClientGroup_old),
			(55, N'Invoice Base Currency', @InvoiceBaseCurrency, @InvoiceBaseCurrency_old),
			(55, N'Invoice Language', @InvoiceLanguage, @InvoiceLanguage_old)
	END
	ELSE IF @LogActionId IN (600, 601, 602) -- Insert/Update Client Group
	BEGIN
		DECLARE
			@LicenseeGroupId INT,
			@LicenseeGroupName NVARCHAR(100),

			@LicenseeGroupId_old INT,
			@LicenseeGroupName_old NVARCHAR(100)

		SELECT
			@LicenseeGroupName = d.c.value('@lgn', 'NVARCHAR(100)'), -- Client Group

			@LicenseeGroupName_old = od.c.value('@lgn', 'NVARCHAR(100)') -- Client Group
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Group name', @LicenseeGroupName, @LicenseeGroupName_old)
	END
	ELSE IF @LogActionId IN (100,101,102) -- Insert/Update/Delete Contact
	BEGIN
		DECLARE
			@LicenseeId INT,
			@LicenseeName NVARCHAR(100),
			@Contact_Type NVARCHAR(10),
			@Contact_Name NVARCHAR(100),
			@Contact_Position NVARCHAR(100),
			@Contact_Department NVARCHAR(100),
			@Contact_Email NVARCHAR(50),
			@Contact_Skype NVARCHAR(50),
			@Contact_Mobile NVARCHAR(50),
			@Contact_Landline NVARCHAR(50),
			@Contact_Remark NVARCHAR(600),
			@Contact_Category NVARCHAR(MAX),

			@LicenseeId_old INT,
			@LicenseeName_old NVARCHAR(100),
			@Contact_Type_old NVARCHAR(10),
			@Contact_Name_old NVARCHAR(100),
			@Contact_Position_old NVARCHAR(100),
			@Contact_Department_old NVARCHAR(100),
			@Contact_Email_old NVARCHAR(50),
			@Contact_Skype_old NVARCHAR(50),
			@Contact_Mobile_old NVARCHAR(50),
			@Contact_Landline_old NVARCHAR(50),
			@Contact_Remark_old NVARCHAR(600),
			@Contact_Category_old NVARCHAR(MAX)

		SELECT
			@LicenseeId = d.c.value('@lid', 'INT'), -- client
			@Contact_Type = d.c.value('@lcct', 'NVARCHAR(10)'), -- contact type
			@Contact_Name = d.c.value('@lccn', 'NVARCHAR(100)'), -- contact name
			@Contact_Position = d.c.value('@lcp', 'NVARCHAR(100)'), -- contact position
			@Contact_Department = d.c.value('@lcd', 'NVARCHAR(100)'), -- contact department
			@Contact_Email = d.c.value('@lce', 'NVARCHAR(50)'), -- contact email
			@Contact_Skype = d.c.value('@lcs', 'NVARCHAR(50)'), -- contact skype
			@Contact_Mobile = d.c.value('@lcpn', 'NVARCHAR(50)'), -- contact mobile phone
			@Contact_Landline = d.c.value('@lcll', 'NVARCHAR(50)'), -- contact landline
			@Contact_Remark = d.c.value('@lcr', 'NVARCHAR(600)'), -- contact remark

			@LicenseeId_old = od.c.value('@lid', 'INT'), -- client
			@Contact_Type_old = od.c.value('@lcct', 'NVARCHAR(10)'), -- contact type
			@Contact_Name_old = od.c.value('@lccn', 'NVARCHAR(100)'), -- contact name
			@Contact_Position_old = od.c.value('@lcp', 'NVARCHAR(100)'), -- contact position
			@Contact_Department_old = od.c.value('@lcd', 'NVARCHAR(100)'), -- contact department
			@Contact_Email_old = od.c.value('@lce', 'NVARCHAR(50)'), -- contact email
			@Contact_Skype_old = od.c.value('@lcs', 'NVARCHAR(50)'), -- contact skype
			@Contact_Mobile_old = od.c.value('@lcpn', 'NVARCHAR(50)'), -- contact mobile phone
			@Contact_Landline_old = od.c.value('@lcll', 'NVARCHAR(50)'), -- contact landline
			@Contact_Remark_old = od.c.value('@lcr', 'NVARCHAR(600)') -- contact remark
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_ContactCategory AS (
			SELECT
				d.c.value('@cn', 'NVARCHAR(100)') AS Category, -- contact category
				d.c.value('@ct', 'TINYINT') AS ContactType, -- contact type

				od.c.value('@cn', 'NVARCHAR(100)') AS Category_old, -- contact category
				od.c.value('@ct', 'TINYINT') AS ContactType_old -- contact type
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/cc/row') AS Data, CONVERT(XML, OldData).query('/r/cc/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Contact_Category = (SELECT STUFF((SELECT DISTINCT '<br/>' + Category + ' - ' + CASE WHEN ContactType = 0 THEN 'To List' ELSE 'CC List' END FROM CTE_ContactCategory FOR XML PATH('')), 1, 11, '')),
				@Contact_Category_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Category_old + ' - ' + CASE WHEN ContactType_old = 0 THEN 'To List' ELSE 'CC List' END FROM CTE_ContactCategory FOR XML PATH('')), 1, 11, ''))

		SELECT	@LicenseeName = LicenseeName FROM dbo.Licensee WITH(NOLOCK) WHERE LicenseeId = @LicenseeId
		SELECT	@LicenseeName_old = LicenseeName FROM dbo.Licensee WITH(NOLOCK) WHERE LicenseeId = @LicenseeId_old

		SELECT	@Contact_Type = CASE WHEN @Contact_Type = N'1' THEN N'Group' ELSE N'Individual' END,
				@Contact_Type_old = CASE WHEN @Contact_Type_old = N'1' THEN N'Group' ELSE N'Individual' END
		
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Site name', @LicenseeName, @LicenseeName_old),
			(2, N'Contact type', @Contact_Type, @Contact_Type_old),
			(3, N'Name', @Contact_Name, @Contact_Name_old),
			(4, N'Position', @Contact_Position, @Contact_Position_old),
			(5, N'Department', @Contact_Department, @Contact_Department_old),
			(6, N'Email address', @Contact_Email, @Contact_Email_old),
			(7, N'Skype username', @Contact_Skype, @Contact_Skype_old),
			(8, N'Mobile number', @Contact_Mobile, @Contact_Mobile_old),
			(9, N'Landline', @Contact_Landline, @Contact_Landline_old),
			(10, N'Remark', @Contact_Remark, @Contact_Remark_old),
			(11, N'Category - List type', @Contact_Category, @Contact_Category_old)
	END
	ELSE IF @LogActionId IN (302,303) -- Insert/Delete Category - Client
	BEGIN
		DECLARE
			@Licensee NVARCHAR(100),
			@Categories NVARCHAR(MAX),

			@Licensee_old NVARCHAR(100),
			@Categories_old NVARCHAR(MAX)

		SELECT
			@Licensee = d.c.value('@ln', 'NVARCHAR(100)'), -- client

			@Licensee_old = od.c.value('@ln', 'NVARCHAR(100)') -- client
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_ClientCategory AS (
			SELECT
				d.c.value('@cn', 'NVARCHAR(100)') AS Category, -- category

				od.c.value('@cn', 'NVARCHAR(100)') AS Category_old -- category
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/c/row') AS Data, CONVERT(XML, OldData).query('/r/c/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Categories = (SELECT STUFF((SELECT DISTINCT '<br/>' + Category FROM CTE_ClientCategory FOR XML PATH('')), 1, 11, '')),
				@Categories_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Category_old FROM CTE_ClientCategory FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Category', @Categories, @Categories_old)
	END
	ELSE IF @LogActionId IN (301) -- Update Category Mailing List
	BEGIN
		DECLARE
			@Category NVARCHAR(100),
			@Contacts NVARCHAR(MAX),

			@Category_old NVARCHAR(100),
			@Contacts_old NVARCHAR(MAX)

		SELECT
			@Category = d.c.value('@cn', 'NVARCHAR(100)'), -- category

			@Category_old = od.c.value('@cn', 'NVARCHAR(100)') -- category
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_Contact AS (
			SELECT
				d.c.value('@lcc', 'INT') AS ContactId, -- contact id
				d.c.value('@lcn', 'NVARCHAR(100)') AS ContactName, -- contact name
				d.c.value('@lce', 'NVARCHAR(100)') AS ContactEmail, -- contact email
				d.c.value('@cct', 'TINYINT') AS ContactType, -- contact type

				od.c.value('@lcc', 'INT') AS ContactId_old, -- contact id
				od.c.value('@lcn', 'NVARCHAR(100)') AS ContactName_old, -- contact name
				od.c.value('@lce', 'NVARCHAR(100)') AS ContactEmail_old, -- contact email
				od.c.value('@cct', 'TINYINT') AS ContactType_old -- contact type
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/cc/row') AS Data, CONVERT(XML, OldData).query('/r/cc/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Contacts = (SELECT STUFF((SELECT '<br/>' + ContactName + ' - ' + ContactEmail + ' - ' + CASE WHEN ContactType = 0 THEN 'To List' ELSE 'CC List' END FROM (SELECT DISTINCT ContactId, ContactName, ContactEmail, ContactType FROM CTE_Contact) CTE_Contact ORDER BY ContactId FOR XML PATH('')), 1, 11, '')),
				@Contacts_old = (SELECT STUFF((SELECT '<br/>' + ContactName_old + ' - ' + ContactEmail_old + ' - ' + CASE WHEN ContactType_old = 0 THEN 'To List' ELSE 'CC List' END FROM (SELECT DISTINCT ContactId_old, ContactName_old, ContactEmail_old, ContactType_old FROM CTE_Contact) CTE_Contact ORDER BY ContactId_old FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, @Category, @Contacts, @Contacts_old)
	END
	ELSE IF @LogActionId IN (200) -- Update Client list of a Product
	BEGIN
		DECLARE
			@Product NVARCHAR(100),
			@Product_Clients NVARCHAR(MAX),

			@Product_old NVARCHAR(100),
			@Product_Clients_old NVARCHAR(MAX)

		SELECT
			@Product = d.c.value('@pn', 'NVARCHAR(100)'), -- product

			@Product_old = od.c.value('@pn', 'NVARCHAR(100)') -- product
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_Product AS (
			SELECT
				d.c.value('@ln', 'NVARCHAR(100)') AS Product, -- client
				d.c.value('@lpld', 'DATE') AS LaunchDate, -- launch date
				d.c.value('@lptd', 'DATE') AS TerminatedDate, -- termination date

				od.c.value('@ln', 'NVARCHAR(100)') AS Product_old, -- client
				od.c.value('@lpld', 'DATE') AS LaunchDate_old, -- launch date
				od.c.value('@lptd', 'DATE') AS TerminatedDate_old -- termination date
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lp/row') AS Data, CONVERT(XML, OldData).query('/r/lp/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Product_Clients = (SELECT STUFF((SELECT DISTINCT '<br/>' + Product + CASE WHEN LaunchDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate, 101) END + CASE WHEN TerminatedDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate, 101) END FROM CTE_Product WITH(NOLOCK) FOR XML PATH('')), 1, 11, '')),
				@Product_Clients_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Product_old + CASE WHEN LaunchDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate_old, 101) END + CASE WHEN TerminatedDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate_old, 101) END FROM CTE_Product WITH(NOLOCK) FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Client - Launch - Termination', @Product_Clients, @Product_Clients_old)
	END
	ELSE IF @LogActionId IN (201, 202) -- Update Products for a Client
	BEGIN
		DECLARE
			@Client NVARCHAR(100),
			@Client_Products NVARCHAR(MAX),

			@Client_old NVARCHAR(100),
			@Client_Products_old NVARCHAR(MAX)

		SELECT
			@Client = d.c.value('@ln', 'NVARCHAR(100)'), -- client

			@Client_old = od.c.value('@ln', 'NVARCHAR(100)') -- client
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_Product AS (
			SELECT
				d.c.value('@pn', 'NVARCHAR(100)') AS Product, -- product
				d.c.value('@pod', 'INT') AS ProductOrder, -- product
				d.c.value('@lld', 'DATE') AS LaunchDate, -- launch date
				d.c.value('@ltd', 'DATE') AS TerminatedDate, -- termination date

				od.c.value('@pn', 'NVARCHAR(100)') AS Product_old, -- product
				od.c.value('@pod', 'INT') AS ProductOrder_old, -- product
				od.c.value('@lld', 'DATE') AS LaunchDate_old, -- launch date
				od.c.value('@ltd', 'DATE') AS TerminatedDate_old -- termination date
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lp/row') AS Data, CONVERT(XML, OldData).query('/r/lp/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Client_Products = (SELECT STUFF((SELECT '<br/>' + Product + CASE WHEN LaunchDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate, 101) END + CASE WHEN TerminatedDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate, 101) END FROM (SELECT DISTINCT Product, ProductOrder, LaunchDate, TerminatedDate FROM CTE_Product) CTE_Product ORDER BY ProductOrder FOR XML PATH('')), 1, 11, '')),
				@Client_Products_old = (SELECT STUFF((SELECT '<br/>' + Product_old + CASE WHEN LaunchDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate_old, 101) END + CASE WHEN TerminatedDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate_old, 101) END FROM (SELECT DISTINCT Product_old, ProductOrder_old, LaunchDate_old, TerminatedDate_old FROM CTE_Product) CTE_Product ORDER BY ProductOrder_old FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Product - Launch - Termination', @Client_Products, @Client_Products_old)
	END
	ELSE IF @LogActionId IN (500) -- Update Client list of a Feature
	BEGIN
		DECLARE
			@Feature NVARCHAR(100),
			@Feature_Clients NVARCHAR(MAX),

			@Feature_old NVARCHAR(100),
			@Feature_Clients_old NVARCHAR(MAX)

		SELECT
			@Feature = d.c.value('@fn', 'NVARCHAR(100)'), -- feature

			@Feature_old = od.c.value('@fn', 'NVARCHAR(100)') -- feature
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_Feature AS (
			SELECT
				d.c.value('@ln', 'NVARCHAR(100)') AS Feature, -- client
				d.c.value('@lfld', 'DATE') AS LaunchDate, -- launch date
				d.c.value('@lftd', 'DATE') AS TerminatedDate, -- termination date

				od.c.value('@ln', 'NVARCHAR(100)') AS Feature_old, -- client
				od.c.value('@lfld', 'DATE') AS LaunchDate_old, -- launch date
				od.c.value('@lftd', 'DATE') AS TerminatedDate_old -- termination date
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lf/row') AS Data, CONVERT(XML, OldData).query('/r/lf/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Feature_Clients = (SELECT STUFF((SELECT DISTINCT '<br/>' + Feature + CASE WHEN LaunchDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate, 101) END + CASE WHEN TerminatedDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate, 101) END FROM CTE_Feature WITH(NOLOCK) FOR XML PATH('')), 1, 11, '')),
				@Feature_Clients_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Feature_old + CASE WHEN LaunchDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate_old, 101) END + CASE WHEN TerminatedDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate_old, 101) END FROM CTE_Feature WITH(NOLOCK) FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Client - Launch - Termination', @Feature_Clients, @Feature_Clients_old)
	END
	ELSE IF @LogActionId IN (501, 502) -- Update Features for a Client
	BEGIN
		DECLARE
			@Clients NVARCHAR(100),
			@Client_Features NVARCHAR(MAX),

			@Clients_old NVARCHAR(100),
			@Client_Features_old NVARCHAR(MAX)

		SELECT
			@Clients = d.c.value('@ln', 'NVARCHAR(100)'), -- client

			@Clients_old = od.c.value('@ln', 'NVARCHAR(100)') -- client
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		;WITH CTE_Feature AS (
			SELECT
				d.c.value('@fn', 'NVARCHAR(100)') AS Feature, -- Feature
				d.c.value('@fid', 'INT') AS FeatureOrder, -- Feature
				d.c.value('@lld', 'DATE') AS LaunchDate, -- launch date
				d.c.value('@ltd', 'DATE') AS TerminatedDate, -- termination date

				od.c.value('@fn', 'NVARCHAR(100)') AS Feature_old, -- Feature
				od.c.value('@fid', 'INT') AS FeatureOrder_old, -- Feature
				od.c.value('@lld', 'DATE') AS LaunchDate_old, -- launch date
				od.c.value('@ltd', 'DATE') AS TerminatedDate_old -- termination date
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lf/row') AS Data, CONVERT(XML, OldData).query('/r/lf/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Client_Features = (SELECT STUFF((SELECT '<br/>' + Feature + CASE WHEN LaunchDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate, 101) END + CASE WHEN TerminatedDate IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate, 101) END FROM (SELECT DISTINCT Feature, FeatureOrder, LaunchDate, TerminatedDate FROM CTE_Feature) CTE_Feature ORDER BY FeatureOrder FOR XML PATH('')), 1, 11, '')),
				@Client_Features_old = (SELECT STUFF((SELECT '<br/>' + Feature_old + CASE WHEN LaunchDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), LaunchDate_old, 101) END + CASE WHEN TerminatedDate_old IS NULL THEN '' ELSE ' - ' + CONVERT(VARCHAR(10), TerminatedDate_old, 101) END FROM (SELECT DISTINCT Feature_old, FeatureOrder_old, LaunchDate_old, TerminatedDate_old FROM CTE_Feature) CTE_Feature ORDER BY FeatureOrder_old FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Feature - Launch - Termination', @Client_Features, @Client_Features_old)

	END
	ELSE IF @LogActionId IN (400,401,402) -- Insert/Update/Delete Training
	BEGIN
		DECLARE
			@TrainingLicenseeName VARCHAR(50),
			@TrainingStatusName VARCHAR(200),
			@TrainingStatusValue VARCHAR(50),
			@TrainingStatusValue_DateTime DATETIME,
			@TrainingStatusValue_Date VARCHAR(50),
			@TrainingStatusValue_Time VARCHAR(50),
			@Language NVARCHAR(30),
			@Date NVARCHAR(10),
			@StartTime NVARCHAR(20),
			@TimeZone NVARCHAR(10),
			@Attendee NVARCHAR(MAX),

			@TrainingLicenseeName_old VARCHAR(50),
			@TrainingStatusName_old VARCHAR(200),
			@TrainingStatusValue_old VARCHAR(50),
			@TrainingStatusValue_DateTime_old DATETIME,
			@TrainingStatusValue_Date_old VARCHAR(50),
			@TrainingStatusValue_Time_old VARCHAR(50),
			@Language_old NVARCHAR(30),
			@Date_old NVARCHAR(10),
			@StartTime_old NVARCHAR(20),
			@TimeZone_old NVARCHAR(10),
			@Attendee_old NVARCHAR(MAX)

		SELECT
			@TrainingLicenseeName = d.c.value('@ln', 'VARCHAR(50)'), -- licensee
			@TrainingStatusName = d.c.value('@tsn', 'VARCHAR(200)'), -- status
			@TrainingStatusValue = d.c.value('@tsv', 'VARCHAR(50)'), -- status value
			@Language = d.c.value('@lu', 'NVARCHAR(30)'), -- language
			@Date = CONVERT(VARCHAR(10), d.c.value('@td', 'DATE'), 101), -- date
			@StartTime = d.c.value('@td', 'DATETIME'), -- start time
			@TimeZone = d.c.value('@tz', 'NVARCHAR(10)'), -- time zone

			@TrainingLicenseeName_old = od.c.value('@ln', 'VARCHAR(50)'), -- licensee
			@TrainingStatusName_old = od.c.value('@tsn', 'VARCHAR(200)'), -- status
			@TrainingStatusValue_old = od.c.value('@tsv', 'VARCHAR(50)'), -- status value
			@Language_old = od.c.value('@lu', 'NVARCHAR(30)'), -- language
			@Date_old = CONVERT(VARCHAR(10), od.c.value('@td', 'DATE'), 101), -- date
			@StartTime_old = od.c.value('@td', 'DATETIME'), -- start time
			@TimeZone_old = od.c.value('@tz', 'NVARCHAR(10)') -- time zone
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		IF ISNULL(@TimeZone, N'') <> N'' AND ISNUMERIC(@TimeZone) = 1
		BEGIN
			SELECT @StartTime = LTRIM(RTRIM(RIGHT(CONVERT(VARCHAR(19), DATEADD(HOUR, CONVERT(INT, @TimeZone), CONVERT(DATETIME, @StartTime)), 100), 7)))
			SELECT @StartTime = LEFT(@StartTime, LEN(@StartTime) - 2) + ' ' + RIGHT(@StartTime, 2)
		END
		
		IF ISNULL(@TimeZone_old, N'') <> N'' AND ISNUMERIC(@TimeZone_old) = 1
		BEGIN
			SELECT @StartTime_old = LTRIM(RTRIM(RIGHT(CONVERT(VARCHAR(19), DATEADD(HOUR, CONVERT(INT, @TimeZone_old), CONVERT(DATETIME, @StartTime_old)), 100), 7)))
			SELECT @StartTime_old = LEFT(@StartTime_old, LEN(@StartTime_old) - 2) + ' ' + RIGHT(@StartTime_old, 2)
		END

		IF ISNULL(@TrainingStatusValue, N'') <> N'' AND ISNUMERIC(@TimeZone) = 1
		BEGIN
			BEGIN TRY
				SELECT @TrainingStatusValue_DateTime = CONVERT(DATETIME, @TrainingStatusValue)
				SELECT @TrainingStatusValue_DateTime = DATEADD(HOUR, CONVERT(INT, @TimeZone), @TrainingStatusValue_DateTime)

				SELECT @TrainingStatusValue_Date = CONVERT(DATE, @TrainingStatusValue_DateTime)

				SELECT @TrainingStatusValue_Time = LTRIM(RTRIM(RIGHT(CONVERT(VARCHAR(19), @TrainingStatusValue_DateTime, 100), 7)))
				SELECT @TrainingStatusValue_Time = LEFT(@TrainingStatusValue_Time, LEN(@TrainingStatusValue_Time) - 2) + ' ' + RIGHT(@TrainingStatusValue_Time, 2)

				
			END TRY
			BEGIN CATCH
				SELECT @TrainingStatusValue_Date = NULL
				SELECT @TrainingStatusValue_Time = NULL
			END CATCH
		END

		IF ISNULL(@TrainingStatusValue_old, N'') <> N'' AND ISNUMERIC(@TimeZone_old) = 1
		BEGIN
			BEGIN TRY
				SELECT @TrainingStatusValue_DateTime_old = CONVERT(DATETIME, @TrainingStatusValue_old)
				SELECT @TrainingStatusValue_DateTime_old = DATEADD(HOUR, CONVERT(INT, @TimeZone_old), @TrainingStatusValue_DateTime_old)

				SELECT @TrainingStatusValue_Date_old = CONVERT(DATE, @TrainingStatusValue_DateTime_old)

				SELECT @TrainingStatusValue_Time_old = LTRIM(RTRIM(RIGHT(CONVERT(VARCHAR(19), @TrainingStatusValue_DateTime_old, 100), 7)))
				SELECT @TrainingStatusValue_Time_old = LEFT(@TrainingStatusValue_Time_old, LEN(@TrainingStatusValue_Time_old) - 2) + ' ' + RIGHT(@TrainingStatusValue_Time_old, 2)

				
			END TRY
			BEGIN CATCH
				SELECT @TrainingStatusValue_Date_old = NULL
				SELECT @TrainingStatusValue_Time_old = NULL
			END CATCH
		END

		IF ISNUMERIC(@TimeZone) = 1
		BEGIN
			IF CONVERT(INT, @TimeZone) < 0
				SELECT @TimeZone = 'GMT' + @TimeZone
			ELSE
				SELECT @TimeZone = 'GMT+' + @TimeZone
		END

		IF ISNUMERIC(@TimeZone_old) = 1
		BEGIN
			IF CONVERT(INT, @TimeZone_old) < 0
				SELECT @TimeZone_old = 'GMT' + @TimeZone_old
			ELSE
				SELECT @TimeZone_old = 'GMT+' + @TimeZone_old
		END

		;WITH CTE_Attendee AS (
			SELECT
				d.c.value('@an', 'NVARCHAR(100)') AS Attendee, -- Attendee
				d.c.value('@ap', 'NVARCHAR(100)') AS Position, -- Position
				d.c.value('@as', 'NVARCHAR(100)') AS Skype, -- Skype

				od.c.value('@an', 'NVARCHAR(100)') AS Attendee_old, -- Attendee
				od.c.value('@ap', 'NVARCHAR(100)') AS Position_old, -- Position
				od.c.value('@as', 'NVARCHAR(100)') AS Skype_old -- Skype
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/a/row') AS Data, CONVERT(XML, OldData).query('/r/a/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		SELECT	@Attendee = (SELECT STUFF((SELECT DISTINCT '<br/>' + Attendee + ' - ' + Position + ' - ' + Skype FROM CTE_Attendee FOR XML PATH('')), 1, 11, '')),
				@Attendee_old = (SELECT STUFF((SELECT DISTINCT '<br/>' + Attendee_old + ' - ' + Position_old + ' - ' + Skype_old FROM CTE_Attendee FOR XML PATH('')), 1, 11, ''))

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Site name', @TrainingLicenseeName, @TrainingLicenseeName_old),
			(1, N'Language', @Language, @Language_old),
			(2, N'Date', @Date, @Date_old),
			(3, N'Start time', @StartTime, @StartTime_old),
			(4, N'Time zone', @TimeZone, @TimeZone_old),
			(5, N'Attendee - Position - Skype', @Attendee, @Attendee_old),
			(6, N'Status', @TrainingStatusName, @TrainingStatusName_old),
			(7, N'Available Date', @TrainingStatusValue_Date, @TrainingStatusValue_Date_old),
			(8, N'Available Time', @TrainingStatusValue_Time, @TrainingStatusValue_Time_old)
	END
	ELSE IF @LogActionId IN (2000) -- Update User Profile
	BEGIN
		DECLARE
			@User_DisplayName NVARCHAR(100),
			@User_CompanyName NVARCHAR(100),
			@User_PositionName NVARCHAR(100),
			@User_JoinedDate NVARCHAR(100),
			@User_CountryName NVARCHAR(100),
			@User_Email NVARCHAR(100),
			@User_PhoneNumber NVARCHAR(100),
			@User_Skype NVARCHAR(100),
			@User_Line NVARCHAR(100),
			@User_Remark NVARCHAR(100),

			@User_DisplayName_old NVARCHAR(100),
			@User_CompanyName_old NVARCHAR(100),
			@User_PositionName_old NVARCHAR(100),
			@User_JoinedDate_old NVARCHAR(100),
			@User_CountryName_old NVARCHAR(100),
			@User_Email_old NVARCHAR(100),
			@User_PhoneNumber_old NVARCHAR(100),
			@User_Skype_old NVARCHAR(100),
			@User_Line_old NVARCHAR(100),
			@User_Remark_old NVARCHAR(100)

		SELECT
			@User_DisplayName = d.c.value('@udn', 'NVARCHAR(300)'), -- display name
			@User_CompanyName = d.c.value('@ucomn', 'NVARCHAR(300)'), -- company name
			@User_PositionName = d.c.value('@upn', 'NVARCHAR(300)'), -- position
			@User_JoinedDate = d.c.value('@ujd', 'DATE'), -- join date
			@User_CountryName = d.c.value('@ucoun', 'NVARCHAR(300)'), -- country
			@User_Email = d.c.value('@ue', 'NVARCHAR(300)'), -- email
			@User_PhoneNumber = d.c.value('@up', 'NVARCHAR(300)'), -- contact number
			@User_Skype = d.c.value('@us', 'NVARCHAR(300)'), -- skype
			@User_Line = d.c.value('@ul', 'NVARCHAR(300)'), -- line
			@User_Remark = d.c.value('@ur', 'NVARCHAR(300)'), -- remark
			
			@User_DisplayName_old = od.c.value('@udn', 'NVARCHAR(300)'), -- display name
			@User_CompanyName_old = od.c.value('@ucomn', 'NVARCHAR(300)'), -- company name
			@User_PositionName_old = od.c.value('@upn', 'NVARCHAR(300)'), -- position
			@User_JoinedDate_old = od.c.value('@ujd', 'DATE'), -- join date
			@User_CountryName_old = od.c.value('@ucoun', 'NVARCHAR(300)'), -- country
			@User_Email_old = od.c.value('@ue', 'NVARCHAR(300)'), -- email
			@User_PhoneNumber_old = od.c.value('@up', 'NVARCHAR(300)'), -- contact number
			@User_Skype_old = od.c.value('@us', 'NVARCHAR(300)'), -- skype
			@User_Line_old = od.c.value('@ul', 'NVARCHAR(300)'), -- line
			@User_Remark_old = od.c.value('@ur', 'NVARCHAR(300)') -- remark
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Display name', @User_DisplayName, @User_DisplayName_old),
			(2, N'Company', @User_CompanyName, @User_CompanyName_old),
			(3, N'Position', @User_PositionName, @User_PositionName_old),
			(4, N'Joined date', @User_JoinedDate, @User_JoinedDate_old),
			(5, N'Country base', @User_CountryName, @User_CountryName_old),
			(6, N'Email address', @User_Email, @User_Email_old),
			(7, N'Contact Number', @User_PhoneNumber, @User_PhoneNumber_old),
			(8, N'Skype username', @User_Skype, @User_Skype_old),
			(9, N'Line username', @User_Line, @User_Line_old),
			(10, N'Remark', @User_Remark, @User_Remark_old)
	END
	ELSE IF @LogActionId IN (2001) -- Update Manage Email
	BEGIN
		;WITH CTE_Email AS (
			SELECT
				d.c.value('@lti', 'INT') AS TOLId, -- type of licensee id
				d.c.value('@ltn', 'NVARCHAR(30)') AS TOL, -- type of licensee
				d.c.value('@em', 'NVARCHAR(50)') AS Email, -- email

				od.c.value('@lti', 'INT') AS TOLId_old, -- type of licensee id
				od.c.value('@ltn', 'NVARCHAR(30)') AS TOL_old, -- type of licensee
				od.c.value('@em', 'NVARCHAR(50)') AS Email_old -- email
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<row />') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/ltm/row') AS Data, CONVERT(XML, OldData).query('/r/ltm/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		), CTE_Email_Result AS (
			SELECT DISTINCT c1.TOLId, c1.TOL, c1.Email, c2.Email_old
			FROM CTE_Email c1
				INNER JOIN CTE_Email c2 ON c1.TOLId = c2.TOLId_old 
		)
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		SELECT ROW_NUMBER() OVER(ORDER BY TOLId), TOL, Email, Email_old
		FROM CTE_Email_Result

	END
	ELSE IF @LogActionId IN (3000,3001,3002) -- Insert/Update/Delete Type Of Licensee
	BEGIN
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		SELECT
			1,
			N'Type of licensee',

			d.c.value('@ltn', 'NVARCHAR(300)'), -- type of licensee name

			od.c.value('@ltn', 'NVARCHAR(300)') -- type of licensee name
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)
	END
	ELSE IF @LogActionId IN (3003,3004,3005) -- Insert/Update/Delete Product
	BEGIN
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		SELECT
			1,
			N'Product',

			d.c.value('@pn', 'NVARCHAR(300)'), -- product name

			od.c.value('@pn', 'NVARCHAR(300)') -- product name
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)
	END
	ELSE IF @LogActionId IN (3009,3010,3011) -- Insert/Update/Delete Feature
	BEGIN
		INSERT INTO @Result (Field, NewValue, OldValue)
		SELECT
			N'Feature',

			d.c.value('@fn', 'NVARCHAR(300)'), -- feature

			od.c.value('@fn', 'NVARCHAR(300)') -- feature
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)
	END
	ELSE IF @LogActionId IN (3006,3007,3008) -- Insert/Update/Delete Category
	BEGIN
		DECLARE
			@Category_EN NVARCHAR(100),
			@Category_CN NVARCHAR(200),

			@Category_EN_old NVARCHAR(100),
			@Category_CN_old NVARCHAR(200)
		
		SELECT
			@Category_EN = d.c.value('@cn', 'NVARCHAR(100)'), -- category english
			@Category_CN = d.c.value('@cncn', 'NVARCHAR(200)'), -- category chinese

			@Category_EN_old = od.c.value('@cn', 'NVARCHAR(100)'), -- category english
			@Category_CN_old = od.c.value('@cncn', 'NVARCHAR(200)') -- category chinese
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)

		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Category (English)', @Category_EN, @Category_EN_old),
			(2, N'Category (Simplified Chinese)', @Category_CN, @Category_CN_old)
	END
	ELSE IF @LogActionId IN (3013) -- Update Assign Type Of Licensee
	BEGIN
		;WITH CTE_TOL AS (
			SELECT
				d.c.value('@ltn', 'NVARCHAR(30)') AS TOL, -- Type Of Licensee
				od.c.value('@ltn', 'NVARCHAR(30)') AS TOL_old -- Type Of Licensee
			FROM (
				SELECT
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r><lt><row /></lt></r>') ELSE Data END AS Data,
					CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r><lt><row /></lt></r>') ELSE OldData END AS OldData
				FROM (
					SELECT CONVERT(XML, Data).query('/r/lt/row') AS Data, CONVERT(XML, OldData).query('/r/lt/row') AS OldData
					FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
					WHERE Id = @ActionID
				) B
			) A
				OUTER APPLY A.Data.nodes('row') d(c)
				OUTER APPLY A.OldData.nodes('row') od(c)
		)
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		SELECT	1, N'Type of licensee',
				(SELECT STUFF((SELECT DISTINCT '<br/>' + TOL FROM CTE_TOL FOR XML PATH('')), 1, 11, '')),
				(SELECT STUFF((SELECT DISTINCT '<br/>' + TOL_old FROM CTE_TOL FOR XML PATH('')), 1, 11, ''))
	END
	ELSE IF @LogActionId IN (3012) -- Update User Position
	BEGIN
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		SELECT
			1,
			N'Position',

			d.c.value('@upn', 'NVARCHAR(50)'), -- position

			od.c.value('@upn', 'NVARCHAR(50)') -- position
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)
	END
	ELSE IF @LogActionId IN (3014) -- Update Reminder
	BEGIN
		DECLARE 
				@MessageId INT,

				@Reminder_Date NVARCHAR(18),
				@Reminder_Subject NVARCHAR(600),
				@Reminder_Content NVARCHAR(MAX),
				@Reminder_TypeId INT,
				@Reminder_Type NVARCHAR(100),
				@Reminder_Option NVARCHAR(MAX),

				@Reminder_TypeId_Old INT,
				@Reminder_Type_Old NVARCHAR(100),
				@Reminder_Option_Old NVARCHAR(MAX)

		SELECT
			@MessageId = d.c.value('@mi', 'INT'), -- Message id
			@Reminder_TypeId = d.c.value('@rti', 'TINYINT'), -- reminder type id
			@Reminder_Option = d.c.value('@rtv', 'NVARCHAR(MAX)'), -- reminder type value

			@Reminder_TypeId_Old = od.c.value('@rti', 'TINYINT'), -- reminder type id
			@Reminder_Option_Old = od.c.value('@rtv', 'NVARCHAR(MAX)') -- reminder type value
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)
		
		SELECT
			@Reminder_Date = CONVERT(NVARCHAR(10), CreateTime, 101) + ' ' + RIGHT(CONVERT(NVARCHAR(19), CreateTime, 100), 7),
			@Reminder_Subject = SubjectEn,
			@Reminder_Content = ContentEn
		FROM dbo.Message WITH(NOLOCK)
		WHERE MessageId = @MessageId

		SELECT @Reminder_Type = ReminderTypeName
		FROM dbo.ReminderType WITH(NOLOCK) WHERE ReminderTypeId = @Reminder_TypeId

		SELECT @Reminder_Type_Old = ReminderTypeName
		FROM dbo.ReminderType WITH(NOLOCK) WHERE ReminderTypeId = @Reminder_TypeId_Old
		
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Date', @Reminder_Date, @Reminder_Date),
			(2, N'Subject', @Reminder_Subject, @Reminder_Subject),
			(3, N'Content', @Reminder_Content, @Reminder_Content),
			(4, N'Reminder Type', @Reminder_Type, @Reminder_Type_Old),
			(5, N'Reminder Options', @Reminder_Option, @Reminder_Option_Old)
	END
	ELSE IF @LogActionId IN (4006) -- Update Amendment Notification
	BEGIN
		DECLARE
			@Status NVARCHAR(100),
			@SubjectEn NVARCHAR(300),
			@SubjectCh NVARCHAR(300),
			@SubjectCs NVARCHAR(300),
			@ContentEn NVARCHAR(MAX),
			@ContentCh NVARCHAR(MAX),
			@ContentCs NVARCHAR(MAX),
			
			@Status_old NVARCHAR(100),
			@SubjectEn_old NVARCHAR(300),
			@SubjectCh_old NVARCHAR(300),
			@SubjectCs_old NVARCHAR(300),
			@ContentEn_old NVARCHAR(MAX),
			@ContentCh_old NVARCHAR(MAX),
			@ContentCs_old NVARCHAR(MAX)

		SELECT
			@Status = d.c.value('@sta', 'NVARCHAR(100)'),
			@SubjectEn = d.c.value('@sen', 'NVARCHAR(300)'),
			@SubjectCh = d.c.value('@sch', 'NVARCHAR(300)'),
			@SubjectCs = d.c.value('@scs', 'NVARCHAR(300)'),
			@ContentEn = d.c.value('@cen', 'NVARCHAR(MAX)'),
			@ContentCh = d.c.value('@cch', 'NVARCHAR(MAX)'),
			@ContentCs = d.c.value('@ccs', 'NVARCHAR(MAX)'),
			
			@Status_old = od.c.value('@sta', 'NVARCHAR(100)'),
			@SubjectEn_old = od.c.value('@sen', 'NVARCHAR(300)'),
			@SubjectCh_old = od.c.value('@sch', 'NVARCHAR(300)'),
			@SubjectCs_old = od.c.value('@scs', 'NVARCHAR(300)'),
			@ContentEn_old = od.c.value('@cen', 'NVARCHAR(MAX)'),
			@ContentCh_old = od.c.value('@cch', 'NVARCHAR(MAX)'),
			@ContentCs_old = od.c.value('@ccs', 'NVARCHAR(MAX)')
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)		

		SELECT @Status = CASE WHEN @Status = '1' THEN 'Active'
							  WHEN @Status = '2' THEN 'Inactive'
							  ELSE 'New' END,
			   @Status_old = CASE WHEN @Status_old = '1' THEN 'Active'
							  WHEN @Status_old = '2' THEN 'Inactive'
							  ELSE 'New' END;	
			  
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Status', @Status, @Status_old),
			(2, N'Subject (Smpl. Chinese)', @SubjectCs, @SubjectCs_old),			
			(3, N'Subject (Trad. Chinese)', @SubjectCh, @SubjectCh_old),
			(4, N'Subject (English)', @SubjectEn, @SubjectEn_old),
			(5, N'Content (Smpl. Chinese)', @ContentCs, @ContentCs_old),
			(6, N'Content (Trad. Chinese)', @ContentCh, @ContentCh_old),
			(7, N'Content (English)', @ContentEn, @ContentEn_old)			
	END
	ELSE IF @LogActionId IN (4009) -- Update Reminder
	BEGIN
		DECLARE
			@ReminderMessageId 		NVARCHAR(300),
			@Subject 		NVARCHAR(300),
			
			@ReminderTypeId INT,
			@ReminderType 	NVARCHAR(50),
			@ReminderOption NVARCHAR(MAX),
			
			@ReminderTypeId_old INT,
			@ReminderType_old 	NVARCHAR(50),
			@ReminderOption_old NVARCHAR(MAX)

		SELECT
			@ReminderMessageId = d.c.value('@mi', 'NVARCHAR(300)'),
			
			@ReminderTypeId = d.c.value('@rti', 'NVARCHAR(50)'),
			@ReminderOption = d.c.value('@rtv', 'NVARCHAR(MAX)'),
			
			@ReminderTypeId_old = od.c.value('@rti', 'NVARCHAR(50)'),
			@ReminderOption_old = od.c.value('@rtv', 'NVARCHAR(MAX)')
		FROM (
			SELECT
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(Data, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE Data END AS Data,
				CASE WHEN CONVERT(NVARCHAR(MAX), ISNULL(OldData, N'')) = N'' THEN CONVERT(XML, N'<r />') ELSE OldData END AS OldData
			FROM (
				SELECT CONVERT(XML, Data).query('/r') AS Data, CONVERT(XML, OldData).query('/r') AS OldData
				FROM dbo.UserLog_RunSP_Detail ud WITH(NOLOCK)
				WHERE Id = @ActionID
			) B
		) A
			OUTER APPLY A.Data.nodes('r') d(c)
			OUTER APPLY A.OldData.nodes('r') od(c)		

		SELECT @Subject = SubjectEn
		FROM dbo.Message WITH(NOLOCK)
		WHERE MessageId = @ReminderMessageId

		SELECT @ReminderType = ReminderTypeName
		FROM dbo.ReminderType WITH(NOLOCK) WHERE ReminderTypeId = @ReminderTypeId

		SELECT @ReminderType_old = ReminderTypeName
		FROM dbo.ReminderType WITH(NOLOCK) WHERE ReminderTypeId = @ReminderTypeId_old
			  
		INSERT INTO @Result (ID, Field, NewValue, OldValue)
		VALUES
			(1, N'Subject', @Subject, @Subject),
			(2, N'Reminder Type', @ReminderType, @ReminderType_old),
			(3, N'Reminder Options', @ReminderOption, @ReminderOption_old)		
	END
	
	-- return result
	IF @LogActionId NOT IN (101, 401, 3014, 202, 502) -- Update Contact/Training/Reminder
	BEGIN
		DELETE @Result
		WHERE ISNULL(OldValue, N'') = ISNULL(NewValue, N'')
	END

	;WITH CTE_Result AS (
		SELECT
			ROW_NUMBER() OVER(ORDER BY ID) AS rownum,
			*
		FROM @Result
	)
	SELECT
		rownum, Field, OldValue, NewValue
	FROM CTE_Result
	ORDER BY rownum 
END

GO