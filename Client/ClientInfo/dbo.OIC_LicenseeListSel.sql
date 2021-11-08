/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeListSel] 
	@UserId							INT				
	,@SelectedLicenseeType			VARCHAR(50)		= 'All'
	,@SelectedPlatform				VARCHAR(50)		= 'All'
	,@SelectedIntegrationMethod		VARCHAR(50)		= 'All'
	,@LicenseeName					NVARCHAR(50)	= '%'
	,@LicenseeStatusIds				VARCHAR(50)		= 'All'
	,@LicenseeGroupIds				VARCHAR(50)		= 'All'
	,@SelectedProduct				VARCHAR(500)	= 'All'
	,@SelectedCurrency				VARCHAR(100)	= 'All'
	,@SelectedOddsType				VARCHAR(50)		= 'All'
	,@AMUserId						INT				= 0			--All
	,@PMUserId						INT				= 0			--All
	,@ResellerType					INT				= -1		--All
	,@MarketType					INT				= -1		--All
	,@PageSize						INT 			= 10
	,@PageIndex						INT				= 0 
	,@TotalRecords					INT 			= 0 OUTPUT
AS

/*
	Created by: Kathy
	Date: 20150424
	Task: Client list [Redmine:#29609]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160628@Percy: Add Currency filter, return Currency column [RedmineID: #58982]
		- 20160805@Percy: Modify Currency filter for case no currency of Client [RedmineID: #62044]
		- 20161214@Percy: Change dropdown TOL filter multiple choices [RedmineID: #68774]
		- 20170828@Scofield: Add Reseller, Update LicenseeStatusIds [#82144]
		- 20180717@Scofield: Get all Currencies [#96489]
		- 20190716@Howard: Add Odds Types[RedmineID: #115460 ]
		- 20190717@Howard: Sort list by name[RedmineID: #115460]
		- 20200113@Hogan: Add Group into Client functions [RedmindId: #126855]
		- 20200917@Howard: Use table Currency instead of table Exchange [RedmindId: #141670]
		- 20210301@Mark: Add Registered Site name for Clients [RedmindId: #150728]
		- 20210810@Hogan: Add invoice base currency and invoice language for licensee [RedmindId: #157466]
		- 20210908@Hogan: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
		- 20211112@Kai: Enhancement of Type of Licensee (Add Platform and IntegrationMethod for licensee) [RedmineID: #163521]

	Param's Explanation:
	* @SelectedProduct: multiple selection dropdown(select 'All' or (1 or many product))(Product offered to the client)
	* @SelectedCurrency: multiple selection dropdown(select 'All' or (1 or many currency))(Currency offered to the client)
	* @SelectedOddsType: multiple selection dropdown(select 'All' or (1 or many odds type))
	* @LicenseeTypeIds: dropdown (select 0(All) or 1 licenseeTypeId)
	* @LicenseeStatusId: dropdown (select 0(All) or 1 licenseeStatusId)
	* @LicenseeGroupIds: dropdown (select 0(All) or 1 licenseeGroupIds)
	* @AMUser: dropdown(select 0(All) or 1 AMUser)
	* @PMUser: dropdown(select 0(All) or 1 PMUser)
	* @PageIndex: 0 - the first page
*/

BEGIN

	SET NOCOUNT ON
	
	DECLARE @RowCount	INT	
			,@RowStart	INT
			,@RowEnd	INT		
	
	SELECT @PageIndex	= @PageIndex ,
			@RowStart	= @PageSize * @PageIndex + 1
			,@RowEnd	= @RowStart + @PageSize - 1	
	
	DECLARE @tblLicenseeType	TABLE (LicenseeTypeId TINYINT)
	DECLARE @tblPlatform	TABLE (PlatformId TINYINT)
	DECLARE @tblIntegrationMethod	TABLE (IntegrationMethodId TINYINT)
	DECLARE @tblLicenseeProduct TABLE (LicenseeId INT)
	DECLARE @tblLicenseeCurrency TABLE (LicenseeId INT)
	DECLARE @tblLicenseeOddsType TABLE (LicenseeId INT)
	DECLARE @tblLicenseeAM TABLE (LicenseeId INT, UserId INT, DisplayName NVARCHAR(50))
	DECLARE @tblLicenseePM TABLE (LicenseeId INT,  UserId INT, DisplayName NVARCHAR(50))
	
	CREATE TABLE #tblResult	(
			RowNumber				INT
			,LicenseeId				INT
			,LicenseeName			NVARCHAR(50)
			,RegisteredLicenseeName NVARCHAR(50)
			,LicenseeStatusId		INT
			,LicenseeStatusName		VARCHAR(30)
			,LicenseeTypeId			TINYINT
			,LicenseeTypeName		VARCHAR(40)
			,PlatformId				TINYINT
			,PlatformName			VARCHAR(50)
			,IntegrationMethodName	VARCHAR(400)
			,SoftLaunch				DATETIME
			,FullLaunch				DATETIME
			,AccountManager			NVARCHAR(50)
			,ProjectManager			NVARCHAR(50)
			,MainContactId			INT
			,MainContactName		NVARCHAR(50)
			,currency				VARCHAR(400)
			,OddsType				VARCHAR(100)
			,IsReseller				BIT
			,IsChineseMarketOnly 	BIT
			,InvoiceBaseCurrency	VARCHAR(4)
			,InvoiceLanguage		NVARCHAR(50)
	)				

	IF @SelectedProduct <> 'All'	
	BEGIN
		INSERT INTO @tblLicenseeProduct(LicenseeId)
		SELECT DISTINCT lp.LicenseeId
		FROM dbo.LicenseeProduct lp WITH(NOLOCK)
		WHERE lp.ProductId IN (SELECT val FROM dbo.strSplit(@SelectedProduct,',')) 
	END
		
	IF @SelectedOddsType <> 'All'
	BEGIN
			INSERT INTO @tblLicenseeOddsType(LicenseeId)
			SELECT DISTINCT lot.LicenseeId
			FROM dbo.LicenseeOddsType lot WITH(NOLOCK)
			WHERE lot.OddsTypeId IN (SELECT val FROM dbo.strSplit(@SelectedOddsType,',')) 
	END
	
	IF @SelectedLicenseeType = 'All'
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT	TypeId
		FROM	dbo.UserLicenseeTypes WITH(NOLOCK)
		WHERE	UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedLicenseeType, ',')

		DELETE lt
		FROM @tblLicenseeType lt
			LEFT JOIN dbo.UserLicenseeTypes ult WITH(NOLOCK) ON lt.LicenseeTypeId = ult.TypeId AND ult.UserId = @UserId
		WHERE ult.TypeId IS NULL
	END

	IF @SelectedPlatform = 'All'
	BEGIN
		INSERT INTO @tblPlatform (PlatformId)
		SELECT	PlatformId
		FROM	dbo.Platform WITH(NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO @tblPlatform (PlatformId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedPlatform, ',')
	END

	IF @SelectedIntegrationMethod = 'All'
	BEGIN
		INSERT INTO @tblIntegrationMethod (IntegrationMethodId)
		SELECT	IntegrationMethodId
		FROM	dbo.IntegrationMethod WITH(NOLOCK)
	END
	ELSE
	BEGIN
		INSERT INTO @tblIntegrationMethod (IntegrationMethodId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedIntegrationMethod, ',')
	END
	
	IF @SelectedCurrency <> 'All'
	BEGIN
		INSERT INTO @tblLicenseeCurrency(LicenseeId)
		SELECT DISTINCT lc.LicenseeId
		FROM dbo.LicenseeCurrency lc WITH(NOLOCK)
		WHERE lc.CurrencyId IN (SELECT val FROM dbo.strSplit(@SelectedCurrency,','))  
	END
	
	INSERT INTO @tblLicenseePM (LicenseeId, UserId, DisplayName)
	SELECT LicenseeId, uip.UserId, uip.DisplayName
	FROM dbo.UserLicensee ulp WITH(NOLOCK)
	INNER JOIN dbo.UserInfo uip WITH(NOLOCK)
		ON	ulp.UserId = uip.UserId
			AND uip.PositionId = 5 -- PM
	WHERE (@PMUserId = 0 OR uip.UserId = @PMUserId)
	
	INSERT INTO @tblLicenseeAM (LicenseeId, UserId, DisplayName)
	SELECT LicenseeId, uip.UserId, uip.DisplayName
	FROM dbo.UserLicensee ulp WITH(NOLOCK)
	INNER JOIN dbo.UserInfo uip WITH(NOLOCK)
		ON	ulp.UserId = uip.UserId
			AND uip.PositionId = 6 -- AM
	WHERE (@AMUserId = 0 OR uip.UserId = @AMUserId)
	
							
	INSERT INTO #tblResult
	(
			RowNumber
			,LicenseeId
			,LicenseeName
			,RegisteredLicenseeName
			,LicenseeStatusId
			,LicenseeStatusName
			,LicenseeTypeId
			,PlatformId
			,SoftLaunch
			,FullLaunch
			,MainContactId
			,MainContactName
			,IsReseller
			,IsChineseMarketOnly
			,InvoiceBaseCurrency
			,InvoiceLanguage
	)	
		 
	SELECT	ROW_NUMBER() OVER(ORDER BY LicenseeName) AS RowNumber
			,l.LicenseeId
			,l.LicenseeName
			,l.RegisteredLicenseeName
			,ls.LicenseeStatusId
			,ls.LicenseeStatusName
			,l.TypeId
			,l.PlatformId
			,l.SoftLaunch
			,l.FullLaunch
			,c.ContactID
			,c.ContactName
			,l.IsReseller
			,l.IsChineseMarketOnly
			,l.InvoiceBaseCurrency
			,l.InvoiceLanguage
	FROM	dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK)
			ON	ls.LicenseeStatusId = l.LicenseeStatusId
		LEFT JOIN dbo.Contact c WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId 
				AND c.IsMain = 1
			
	WHERE	l.LicenseeName LIKE ISNULL(@LicenseeName,'%') + '%'
			AND l.TypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
			AND l.PlatformId IN (SELECT PlatformId FROM @tblPlatform)
			AND (@LicenseeStatusIds = 'All' OR ls.LicenseeStatusId IN (SELECT val FROM dbo.strSplit(@LicenseeStatusIds,','))) 				
			AND (@SelectedProduct = 'All' OR l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeProduct))
			AND l.LicenseeId IN (SELECT lim.LicenseeId FROM dbo.LicenseeIntegrationMethod lim WHERE lim.IntegrationMethodId IN (SELECT IntegrationMethodId FROM @tblIntegrationMethod))
			AND l.LicenseeId IN (SELECT LicenseeId FROM  @tblLicenseePM)
			AND l.LicenseeId IN (SELECT LicenseeId FROM  @tblLicenseeAM)
			AND (@ResellerType = -1 OR l.IsReseller = @ResellerType)
			AND (@MarketType = -1 OR @MarketType = l.IsChineseMarketOnly)
			AND (@SelectedOddsType = 'All' OR l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeOddsType))
			AND (@SelectedCurrency = 'All' OR l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeCurrency)) 
			AND (@LicenseeGroupIds = 'All' OR l.LicenseeGroupId IN (SELECT val FROM dbo.strSplit(@LicenseeGroupIds,',')))
								
	IF @TotalRecords = 0
	BEGIN
		SELECT @TotalRecords = COUNT(1)
		FROM #tblResult
	END		

	SELECT	t.LicenseeId
			,t.LicenseeName
			,t.RegisteredLicenseeName
			,t.LicenseeStatusName
			,t.LicenseeTypeId
			,LicenseeType.value AS LicenseeTypeName
			,t.PlatformId
			,PlatformName.value AS PlatformName
			,IntegrationName.value AS IntegrationMethodName
			,t.FullLaunch
			,t.SoftLaunch
			,AM.value AS AccountManager
			,PM.value AS ProjectManager
			,t.MainContactId
			,t.MainContactName
			,Currency.value AS currency 
			,OddsType.value AS OddsType
			,t.IsReseller
			,t.IsChineseMarketOnly
			,t.InvoiceBaseCurrency
			,t.InvoiceLanguage
	 FROM (
				SELECT *
				FROM #tblResult tr
				WHERE tr.RowNumber BETWEEN @RowStart AND @RowEnd
		   ) t
			OUTER APPLY (
							SELECT STUFF((SELECT ', ' + ot.OddsTypeName
										 FROM LicenseeOddsType AS lot WITH(NOLOCK)
											INNER JOIN OddsType as ot WITH(NOLOCK)
												ON lot.OddsTypeId = ot.OddsTypeId 
										 WHERE LicenseeId = t.LicenseeId 
										 FOR XML PATH('')), 1, 1, '')
						) OddsType(value)
			OUTER APPLY (SELECT lt.TypeName 
						 FROM dbo.LicenseeTypes lt WITH(NOLOCK) 
						 WHERE lt.TypeId = t.LicenseeTypeId) LicenseeType(value)
			OUTER APPLY (SELECT pl.PlatformName 
						 FROM dbo.Platform pl WITH(NOLOCK) 
						 WHERE pl.PlatformId = t.PlatformId) PlatformName(value)
			OUTER APPLY (
							SELECT STUFF((SELECT ', ' + im.IntegrationMethodName
										FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK)
											INNER JOIN dbo.IntegrationMethod im WITH(NOLOCK) 
												ON lim.IntegrationMethodId = im.IntegrationMethodId
										WHERE lim.LicenseeId = t.LicenseeId AND im.IntegrationMethodName IS NOT NULL 
										ORDER BY im.IntegrationMethodId asc
										FOR XML PATH('')), 1, 1, '')
						) IntegrationName(value)
			OUTER APPLY (
							SELECT STUFF((SELECT ', ' + c.Code
										FROM dbo.LicenseeCurrency lc WITH(NOLOCK)
											INNER JOIN dbo.Currency c WITH(NOLOCK) 
												ON lc.CurrencyId = c.ExchangeId
										WHERE lc.LicenseeId = t.LicenseeId AND c.Code IS NOT NULL 
										FOR XML PATH('')), 1, 1, '')
						) Currency(value)
			OUTER APPLY (SELECT lam.DisplayName FROM @tblLicenseeAM lam WHERE lam.LicenseeId = t.LicenseeId) AM(value)
			OUTER APPLY (SELECT lpm.DisplayName FROM @tblLicenseePM lpm WHERE lpm.LicenseeId = t.LicenseeId) PM(value)
			
	ORDER BY RowNumber

	DROP TABLE #tblResult
END

GO