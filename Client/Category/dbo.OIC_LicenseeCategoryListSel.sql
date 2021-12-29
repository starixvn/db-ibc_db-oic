/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeCategoryListSel]   
	@UserId							INT  
	,@SelectedLicenseeType			VARCHAR(50)	= 'All'
	,@SelectedPlatform				VARCHAR(50)	= 'All'
	,@SelectedIntegrationMethod		VARCHAR(50)	= 'All'
	,@LicenseeName					NVARCHAR(50) = '%'  
	,@StatusIds						VARCHAR(50)	= 'All'
	,@SelectedCategory				VARCHAR(500) = 'All'  
   
	,@PageSize						INT = 10  
	,@PageIndex						INT = 0  
	,@TotalRecords					INT = 0 OUTPUT  
AS  
/*  
	Created by: Kathy  
	Date: 2015-03-31  
	Task: Licensee category mailing list [Redmine:#29611]  
	DB: DBOIC.bodb_OIC  
   
	Revisions:  
		- 20160818@Percy: Return new column: CategoryNameCN -- Add Chinese name [RedmineID: #62642]
		- 20161214@Percy: Change dropdown TOL filter multiple choices [RedmineID: #68774]
		- 20170828@Scofield: Update LicenseeStatusIds [#82144]
		- 20210908@Hogan: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
		- 20211112@Kai: Enhancement of Type of Licensee (Add Platform and IntegrationMethod for licensee) [RedmineID: #163521]
		- 20211229@Kos: Hotfix - Upgrade SQL Server 2019 [RedmineID: #166701]

	Param's Explanation:  
		@SelectedCategory: support multiple selection  
		@PageIndex: 0 - the first page  
    
 */  
BEGIN  
 
	SET NOCOUNT ON  
   
	DECLARE @RowCount INT   
		,@RowStart INT  
		,@RowEnd INT  
     
	SELECT @PageIndex = @PageIndex ,  
		@RowStart = @PageSize * @PageIndex + 1  
		,@RowEnd = @RowStart + @PageSize - 1  
     
	DECLARE @tblCategory     TABLE (CategoryId TINYINT, CategoryName VARCHAR(100), CategoryNameCN NVARCHAR(200))         
	DECLARE @tblLicenseeCategoryAssigned TABLE (LicenseeId INT)  
	DECLARE @tblLicenseeType    TABLE (LicenseeTypeId TINYINT)  
	DECLARE @tblPlatform    TABLE (PlatformId TINYINT) 
	DECLARE @tblIntegrationMethod    TABLE (IntegrationMethodId TINYINT)
	DECLARE @tblStatusId	TABLE (StatusId TINYINT)

	CREATE TABLE #tblResult (  
		RowNumber				INT  
		,LicenseeId				INT  
		,LicenseeName			NVARCHAR(50)
		,StatusName				VARCHAR(30)  
		,TypeName				NVARCHAR(50)  
		,PlatformName			NVARCHAR(50)
		,IntegrationMethodName	NVARCHAR(400)
	)  
   
	INSERT INTO @tblCategory (CategoryId, CategoryName, CategoryNameCN)  
	SELECT CategoryId, CategoryName, CategoryNameCN  
	FROM dbo.Category   
	WHERE
		@SelectedCategory = 'All'  
		OR CategoryId IN (SELECT val FROM dbo.strSplit(@SelectedCategory,',' ))  
   
	INSERT INTO @tblLicenseeCategoryAssigned (LicenseeId)        
	SELECT lc.LicenseeId  
	FROM dbo.LicenseeCategoryAssigned lc WITH(NOLOCK)  
		INNER JOIN @tblCategory c   
			ON lc.CategoryId = c.CategoryId  
	GROUP BY lc.LicenseeId  
	HAVING COUNT(DISTINCT lc.CategoryId) = CASE WHEN @SelectedCategory = 'All' THEN COUNT(DISTINCT lc.CategoryId) ELSE (SELECT COUNT(1) FROM @tblCategory) END           
            
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

	IF @StatusIds <> 'All'
	BEGIN
		INSERT INTO @tblStatusId(StatusId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@StatusIds, ',')
	END

	INSERT INTO #tblResult(  
		RowNumber  
		,LicenseeId  
		,LicenseeName  
		,StatusName  
		,TypeName
		,PlatformName
	)       
	SELECT ROW_NUMBER() OVER(ORDER BY l.LicenseeName) AS RowNumber  
		,l.LicenseeId  
		,l.LicenseeName  
		,ls.LicenseeStatusName  
		,lt.TypeName
		,pf.PlatformName
	FROM dbo.Licensee l WITH(NOLOCK)  
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK)   
			ON l.LicenseeStatusId = ls.LicenseeStatusId  
		INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK)   
			ON l.TypeId = lt.TypeId
		INNER JOIN [dbo].[Platform] pf WITH(NOLOCK)
			ON l.PlatformId = pf.PlatformId
	WHERE l.TypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
		AND (@StatusIds = 'All' OR ls.LicenseeStatusId IN (SELECT StatusId FROM @tblStatusId))
		AND l.LicenseeName LIKE @LicenseeName + '%'  
		AND l.LicenseeId IN (SELECT LicenseeId FROM @tblLicenseeCategoryAssigned)
		AND l.PlatformId IN (SELECT PlatformId FROM @tblPlatform)
		AND l.LicenseeId IN (SELECT lim.LicenseeId FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK) WHERE lim.IntegrationMethodId IN (SELECT IntegrationMethodId FROM @tblIntegrationMethod))

      
	IF @TotalRecords = 0  
	BEGIN  
		SELECT @TotalRecords = COUNT(1)  
		FROM #tblResult  
	END   
   
	SELECT t.LicenseeId  
		,t.LicenseeName
		,t.StatusName  
		,t.TypeName
		,t.PlatformName
		,IntegrationName.value AS IntegrationMethodName
	FROM ( SELECT * FROM #tblResult  
	WHERE RowNumber BETWEEN @RowStart AND @RowEnd ) t
	OUTER APPLY (
							SELECT STUFF((SELECT ', ' + im.IntegrationMethodName
										FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK)
											INNER JOIN dbo.IntegrationMethod im WITH(NOLOCK) 
												ON lim.IntegrationMethodId = im.IntegrationMethodId
										WHERE lim.LicenseeId = t.LicenseeId AND im.IntegrationMethodName IS NOT NULL 
										ORDER BY im.IntegrationMethodId asc
										FOR XML PATH('')), 1, 1, '')
						) IntegrationName(value)
   
	SELECT t.LicenseeId  
		,lc.CategoryId  
		,c.CategoryName
		,c.CategoryNameCN
		,(SELECT c.ContactEmail  
				,c.ContactName  
				,c.IsMain  
			FROM dbo.CategoryContact cc WITH(NOLOCK)  
				INNER JOIN dbo.Contact c WITH(NOLOCK)   
					ON c.ContactID = cc.ContactID   
						AND cc.RecipientType = 0   
						AND cc.CategoryID = lc.CategoryId   
						AND c.LicenseeID = t.LicenseeId  
			FOR XML RAW('row'), ROOT('root')  
		) ToList  
	   ,(SELECT c.ContactEmail  
				,c.ContactName  
				,c.IsMain  
			FROM dbo.CategoryContact cc WITH(NOLOCK)  
				INNER JOIN dbo.Contact c WITH(NOLOCK)   
					ON c.ContactID = cc.ContactID   
					   AND cc.RecipientType = 1   
					   AND cc.CategoryID = lc.CategoryId   
					   AND c.LicenseeID = t.LicenseeId  
			FOR XML RAW('row'), ROOT('root')  
		) CcList  
	FROM #tblResult t  
		INNER JOIN dbo.LicenseeCategoryAssigned lc    
			ON t.LicenseeId = lc.LicenseeId  
		INNER JOIN @tblCategory c   
			ON c.CategoryId = lc.CategoryId  
	WHERE t.RowNumber BETWEEN @RowStart AND @RowEnd  
END
GO
