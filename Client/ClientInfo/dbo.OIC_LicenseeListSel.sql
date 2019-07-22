/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeListSel] 
	@UserId				INT				
	,@SelectedLicenseeType VARCHAR(50)	= 'All'
	,@LicenseeName		NVARCHAR(50)	= '%'
	,@LicenseeStatusIds	VARCHAR(50)	= 'All'
	,@SelectedProduct	VARCHAR(500)	= 'All'
	,@SelectedCurrency  VARCHAR(100)	= 'All'
	,@SelectedOddsType  VARCHAR(50)		= 'All'
	,@AMUserId			INT				= 0			--All
	,@PMUserId			INT				= 0			--All
	,@ResellerType	INT 			= -1		--All
	,@MarketType	INT 			= -1		--All
	,@PageSize			INT = 10
	,@PageIndex			INT	= 0 
	,@TotalRecords		INT = 0 OUTPUT
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

	Param's Explanation:
	* @SelectedProduct: multiple selection dropdown(select 'All' or (1 or many product))(Product offered to the client)
	* @SelectedCurrency: multiple selection dropdown(select 'All' or (1 or many currency))(Currency offered to the client)
	* @SelectedOddsType: multiple selection dropdown(select 'All' or (1 or many odds type))
	* @LicenseeTypeIds: dropdown (select 0(All) or 1 licenseeTypeId)
	* @LicenseeStatusId: dropdown (select 0(All) or 1 licenseeStatusId)
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
	DECLARE @tblLicenseeProduct TABLE (LicenseeId INT)
	DECLARE @tblLicenseeCurrency TABLE (LicenseeId INT)
	DECLARE @tblLicenseeOddsType TABLE (LicenseeId INT)
	DECLARE @tblLicenseeAM TABLE (LicenseeId INT, UserId INT, DisplayName NVARCHAR(50))
	DECLARE @tblLicenseePM TABLE (LicenseeId INT,  UserId INT, DisplayName NVARCHAR(50))
	
	CREATE TABLE #tblResult	(
			RowNumber				INT
			,LicenseeId				INT
			,LicenseeName			NVARCHAR(50)
			,LicenseeStatusId		INT
			,LicenseeStatusName		VARCHAR(30)
			,LicenseeTypeId			TINYINT
			,LicenseeTypeName		VARCHAR(30)
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
		SELECT	LicenseeTypeId
		FROM	dbo.UserLicenseeType WITH(NOLOCK)
		WHERE	UserId = @UserId
	END
	ELSE
	BEGIN
		INSERT INTO @tblLicenseeType (LicenseeTypeId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@SelectedLicenseeType, ',')

		DELETE lt
		FROM @tblLicenseeType lt
			LEFT JOIN dbo.UserLicenseeType ult WITH(NOLOCK) ON lt.LicenseeTypeId = ult.LicenseeTypeId AND ult.UserId = @UserId
		WHERE ult.LicenseeTypeId IS NULL
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
			,LicenseeStatusId
			,LicenseeStatusName
			,LicenseeTypeId
			,SoftLaunch
			,FullLaunch
			,MainContactId
			,MainContactName
			,IsReseller
			,IsChineseMarketOnly
	)	
		 
	SELECT	ROW_NUMBER() OVER(ORDER BY LicenseeName) AS RowNumber
			,l.LicenseeId
			,l.LicenseeName
			,ls.LicenseeStatusId
			,ls.LicenseeStatusName
			,l.LicenseeTypeId
			,l.SoftLaunch
			,l.FullLaunch
			,c.ContactID
			,c.ContactName
			,l.IsReseller
			,l.IsChineseMarketOnly
	FROM	dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK)
			ON	ls.LicenseeStatusId = l.LicenseeStatusId
		LEFT JOIN dbo.Contact c WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId 
				AND c.IsMain = 1
			
	WHERE	l.LicenseeName LIKE ISNULL(@LicenseeName,'%') + '%'
			AND l.LicenseeTypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
			AND (@LicenseeStatusIds = 'All' OR ls.LicenseeStatusId IN (SELECT val FROM dbo.strSplit(@LicenseeStatusIds,','))) 				
			AND (@SelectedProduct = 'All' OR l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeProduct))
			AND l.LicenseeId IN (SELECT LicenseeId FROM  @tblLicenseePM)
			AND l.LicenseeId IN (SELECT LicenseeId FROM  @tblLicenseeAM)
			AND (@ResellerType = -1 OR l.IsReseller = @ResellerType)
			AND (@MarketType = -1 OR @MarketType = l.IsChineseMarketOnly)
			AND (@SelectedOddsType = 'All' OR l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeOddsType))
			AND (@SelectedCurrency = 'All' OR l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeCurrency)) 
	
	UPDATE	t 
		SET ProjectManager = ui.DisplayName
	FROM	#tblResult t 
		INNER JOIN UserLicensee ul WITH(NOLOCK)
			ON	ul.LicenseeId = t.LicenseeId
		INNER JOIN dbo.UserInfo ui WITH(NOLOCK)
			ON	ui.UserId = ul.UserId 
				AND ui.PositionId = 5 -- PM								

	IF @TotalRecords = 0
	BEGIN
		SELECT @TotalRecords = COUNT(1)
		FROM #tblResult
	END		

	SELECT	t.LicenseeId
			,t.LicenseeName
			,t.LicenseeStatusName
			,t.LicenseeTypeId
			,LicenseeType.value AS LicenseeTypeName
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
	 FROM (
				SELECT *
				FROM #tblResult tr
				WHERE tr.RowNumber BETWEEN @RowStart AND @RowEnd
		   ) t
			OUTER APPLY (SELECT dbo.f_GetOddsTypesNameByLicenseeId(t.LicenseeId)) OddsType(value)
			OUTER APPLY (SELECT lt.LicenseeTypeName 
						 FROM dbo.LicenseeType lt WITH(NOLOCK) 
						 WHERE lt.LicenseeTypeId = t.LicenseeTypeId) LicenseeType(value)
			OUTER APPLY (SELECT dbo.f_GetCurrencyCodeByLicenseeId(t.LicenseeId)) Currency(value)
			OUTER APPLY (SELECT lam.DisplayName FROM @tblLicenseeAM lam WHERE lam.LicenseeId = t.LicenseeId) AM(value)
			OUTER APPLY (SELECT lpm.DisplayName FROM @tblLicenseePM lpm WHERE lpm.LicenseeId = t.LicenseeId) PM(value)
			
	ORDER BY RowNumber

	DROP TABLE #tblResult
END

GO