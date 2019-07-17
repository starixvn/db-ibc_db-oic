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
	
	DECLARE @tblProduct			TABLE (ProductId INT)
	DECLARE @tblLicenseeType	TABLE (LicenseeTypeId TINYINT)
	DECLARE @tblLicenseeProduct TABLE (LicenseeId INT)
	DECLARE @tblLicenseeCurrency TABLE (LicenseeId INT, currency VARCHAR(1000))
	DECLARE @tblLicenseeOddsType TABLE (LicenseeId INT)
	
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
							
	INSERT INTO @tblProduct(ProductId)
	SELECT  p.ProductId
	FROM	dbo.Product p WITH(NOLOCK)
	WHERE	(@SelectedProduct = 'All' 
				OR p.ProductId IN (SELECT val FROM dbo.strSplit(@SelectedProduct,',')) 
			)
			
	INSERT INTO @tblLicenseeOddsType
	SELECT  DISTINCT l.LicenseeId
	FROM dbo.Licensee l WITH(NOLOCK)
			LEFT JOIN dbo.LicenseeOddsType lot WITH(NOLOCK)
				ON l.LicenseeId = lot.LicenseeId 
	WHERE @SelectedOddsType = 'All' OR lot.OddsTypeId IN (SELECT val FROM dbo.strSplit(@SelectedOddsType,',')) 
	
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
				
	INSERT INTO @tblLicenseeProduct(LicenseeId)
	SELECT	lp.LicenseeId
	FROM	@tblProduct p 
		INNER JOIN dbo.LicenseeProduct lp WITH(NOLOCK) 
			ON	p.ProductId = lp.ProductId
		INNER JOIN dbo.Licensee l WITH (NOLOCK) 
			ON	l.LicenseeId = lp.LicenseeId
	GROUP BY  lp.LicenseeId
	HAVING COUNT(DISTINCT lp.ProductId) = CASE WHEN @SelectedProduct = 'All' THEN COUNT(DISTINCT lp.ProductId)
											   ELSE (SELECT COUNT(1) FROM @tblProduct)
										  END					
	;WITH CTE_Licensee (LicenseeId) AS
	(
		SELECT DISTINCT LicenseeId
		FROM dbo.LicenseeCurrency WITH(NOLOCK)
		WHERE
			@SelectedCurrency = 'All'
			OR CurrencyId IN (SELECT CONVERT(INT, val) FROM dbo.strSplit(@SelectedCurrency, ','))
	)
	,CTE_LicenseeCurrency (LicenseeId, currency) AS
	(
		SELECT DISTINCT lc.LicenseeId, e.code
		FROM
			dbo.LicenseeCurrency lc WITH(NOLOCK)
			INNER JOIN CTE_Licensee l ON lc.LicenseeId = l.LicenseeId
			LEFT JOIN bodb02.dbo.Exchange e WITH(NOLOCK) ON lc.CurrencyId = e.exchangeid
		WHERE
			@SelectedCurrency = 'All'
			OR e.exchangeid IS NOT NULL
	)
	INSERT INTO @tblLicenseeCurrency
	SELECT
		LicenseeId,
		(SELECT STUFF((SELECT ', ' + currency FROM CTE_LicenseeCurrency WHERE LicenseeId = lc.LicenseeId FOR XML PATH('')), 1, 1, ''))
	FROM CTE_LicenseeCurrency lc
	GROUP BY LicenseeId
				
	INSERT INTO #tblResult
	(
			RowNumber
			,LicenseeId
			,LicenseeName
			,LicenseeStatusId
			,LicenseeStatusName
			,LicenseeTypeId
			,LicenseeTypeName
			,SoftLaunch
			,FullLaunch
			,AccountManager
			,MainContactId
			,MainContactName
			,currency	
			,IsReseller
			,IsChineseMarketOnly
	)	
		 
	SELECT	ROW_NUMBER() OVER(ORDER BY LicenseeName) AS RowNumber
			,l.LicenseeId
			,l.LicenseeName
			,ls.LicenseeStatusId
			,ls.LicenseeStatusName
			,lt.LicenseeTypeId
			,lt.LicenseeTypeName
			,l.SoftLaunch
			,l.FullLaunch
			,u.DisplayName AS AccountManager
			,c.ContactID
			,c.ContactName
			,lc.currency
			,l.IsReseller
			,l.IsChineseMarketOnly
	FROM	dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeType lt WITH(NOLOCK)
			ON	lt.LicenseeTypeId = l.LicenseeTypeId
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK)
			ON	ls.LicenseeStatusId = l.LicenseeStatusId
		LEFT JOIN dbo.Contact c WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId 
				AND c.IsMain = 1
		INNER JOIN (
			SELECT	ui.UserId
					,ui.DisplayName
					,ul.LicenseeId 
			FROM dbo.UserInfo ui WITH(NOLOCK)
				INNER JOIN UserLicensee ul WITH(NOLOCK)
					ON	ui.UserId = ul.UserId 
						AND ui.PositionId = 6 --AM 
						AND (@AMUserId = 0 OR ui.UserId = @AMUserId)
		) u 
			ON	u.LicenseeId = l.LicenseeId
		INNER JOIN @tblLicenseeCurrency lc
			ON l.LicenseeId = lc.LicenseeId
		INNER JOIN @tblLicenseeOddsType lot
			ON l.LicenseeId = lot.LicenseeId
		
	WHERE	l.LicenseeName LIKE ISNULL(@LicenseeName,'%') + '%'
			AND l.LicenseeTypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
			AND (@LicenseeStatusIds = 'All' OR ls.LicenseeStatusId IN (SELECT val FROM dbo.strSplit(@LicenseeStatusIds,','))) 				
			AND (
					(@SelectedProduct <> 'All' 
						AND EXISTS (SELECT t.LicenseeId FROM @tblLicenseeProduct t
										WHERE t.LicenseeId = l.LicenseeId)
					) 
					OR (@SelectedProduct = 'All')
				)
			
	
			AND EXISTS (SELECT	LicenseeId 
						FROM	dbo.UserLicensee ulp WITH(NOLOCK)
							INNER JOIN dbo.UserInfo uip WITH(NOLOCK)
								ON	ulp.UserId = uip.UserId
									AND uip.PositionId = 5 -- AM
						WHERE	(uip.UserId = @PMUserId OR @PMUserId = 0) 
								AND l.LicenseeId = LicenseeID)
			AND (@ResellerType = -1 OR l.IsReseller = @ResellerType)
			AND (@MarketType = -1 OR @MarketType = l.IsChineseMarketOnly)
	
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
			,t.LicenseeTypeName
			,t.FullLaunch
			,t.SoftLaunch
			,t.AccountManager
			,t.ProjectManager
			,t.MainContactId
			,t.MainContactName
			,t.currency
			,OddsType.value AS OddsType
			,t.IsReseller
			,t.IsChineseMarketOnly
	 FROM (
				SELECT *
				FROM #tblResult tr
				WHERE tr.RowNumber BETWEEN @RowStart AND @RowEnd
		   ) t
			OUTER APPLY (SELECT dbo.f_GetOddsTypesNameByLicenseeId(t.LicenseeId)) OddsType(value)
	ORDER BY RowNumber

	DROP TABLE #tblResult
END

GO