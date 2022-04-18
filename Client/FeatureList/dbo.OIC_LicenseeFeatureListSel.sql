/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeFeatureListSel] 
	@UserId							INT
	,@SelectedLicenseeType			VARCHAR(50)	= 'All'
	,@SelectedPlatform				VARCHAR(50)		= 'All'
	,@SelectedIntegrationMethod		VARCHAR(50)		= 'All'
	,@LicenseeName					NVARCHAR(50)		= '%'
	,@LicenseeStatusIds				VARCHAR(50)	= 'All'
	,@SelectedFeature				VARCHAR(500)	= 'All'
	,@FeatureShown					VARCHAR(500)
	,@FeatureStatusId				TINYINT			= 0
	,@LaunchFrom					DATETIME		= NULL
	,@LaunchTo						DATETIME		= NULL
	,@TerminationFrom				DATETIME		= NULL
	,@TerminationTo					DATETIME		= NULL
		
	,@PageSize						INT = 10
	,@PageIndex						INT	= 0 
	,@TotalRecords					INT = 0 OUTPUT
AS

/*
	Created by: Percy
	Date: 2017-03-28
	Task: Licensee Feature list [RedmineID: #70323]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20170828@Scofield: Update LicenseeStatusIds [#82144]
		- 20210908@Hogan: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
		- 20211116@Kai: Enhancement of Type of Licensee (Add Platform and IntegrationMethod for licensee) [RedmineID: #163521]
		- 20211229@Kos: Hotfix - Upgrade SQL Server 2019 [RedmineID: #166701]
		- 20220414@Kai: Enhance product filter [RedmineID: #171483]

	Param's Explanation:
		@SelectedFeature: multiple selection feature
		@FeatureShown: list features shall be shown, support multiple selection
		@PageIndex: 0 - the first page
		@FeatureStatusId:
			0: All
			1: Upcoming
			2: Launched
			3: To be terminated
			4: Terminated
		
*/

BEGIN
	SET NOCOUNT ON
	DECLARE @DynamicPIVOT		VARCHAR(MAX)
			,@strFeatureName	VARCHAR(MAX)
	
	DECLARE @RowCount	INT	
			,@RowStart	INT
			,@RowEnd	INT
	
	SELECT @PageIndex = @PageIndex,
			@RowStart = @PageSize * @PageIndex + 1
			,@RowEnd = @RowStart + @PageSize - 1
	
	DECLARE @today				DATETIME = CONVERT(DATE, GETDATE())
	DECLARE @tblFeature			TABLE (FeatureId INT)
	DECLARE @tblLicenseeType	TABLE (LicenseeTypeId TINYINT)
	DECLARE @tblPlatform	TABLE (PlatformId TINYINT)
	DECLARE @tblIntegrationMethod	TABLE (IntegrationMethodId TINYINT)
	DECLARE @tblStatusId	TABLE (StatusId TINYINT)
	CREATE TABLE #tblLicenseeFeature (LicenseeId INT, FeatureId INT, IsFilled BIT)
	
	CREATE TABLE #tblResult	(
		RowNumber				INT
		,LicenseeId				INT
		,LicenseeName			NVARCHAR(50)
		,StatusName				VARCHAR(30)
		,TypeName				NVARCHAR(50)
		,PlatformName			NVARCHAR(50)
		,IntegrationMethodName	NVARCHAR(400)
	)
							
	INSERT INTO @tblFeature(FeatureId)
	SELECT	p.FeatureId
	FROM	dbo.Feature p WITH(NOLOCK)
	WHERE   @SelectedFeature = 'All' 
			OR p.FeatureId IN (SELECT val FROM dbo.strSplit(@SelectedFeature,','))
						
	INSERT INTO #tblLicenseeFeature(LicenseeId, FeatureId, IsFilled)
	SELECT	lp.LicenseeId, p.FeatureId, 0
	FROM	@tblFeature p				
		RIGHT JOIN dbo.LicenseeFeature lp WITH(NOLOCK) 
			ON	p.FeatureId = lp.FeatureId

	UPDATE t
	SET IsFilled = 1
	FROM #tblLicenseeFeature t	
		INNER JOIN dbo.LicenseeFeature lp WITH(NOLOCK) 
			ON	t.LicenseeId = lp.LicenseeId AND t.FeatureId = lp.FeatureId
	WHERE
		(@LaunchFrom IS NULL
			OR (@LaunchFrom IS NOT NULL AND lp.LaunchDate >= @LaunchFrom))
		AND (@LaunchTo IS NULL
			OR (@LaunchTo IS NOT NULL AND lp.LaunchDate <= @LaunchTo))
		AND (@TerminationFrom IS NULL
			OR (@TerminationFrom IS NOT NULL AND lp.TerminationDate >= @TerminationFrom))
		AND (@TerminationTo IS NULL
			OR (@TerminationTo IS NOT NULL AND lp.TerminationDate <= @TerminationTo))
		AND (@FeatureStatusId = 0
			OR (@FeatureStatusId = 1 AND lp.LaunchDate > @today)
			OR (@FeatureStatusId = 2 AND lp.LaunchDate <= @today)
			OR (@FeatureStatusId = 3 AND lp.LaunchDate <= @today AND lp.TerminationDate IS NOT NULL)
			OR (@FeatureStatusId = 4 AND lp.TerminationDate < @today))

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

	IF @LicenseeStatusIds <> 'All'
	BEGIN
		INSERT INTO @tblStatusId(StatusId)
		SELECT CONVERT(TINYINT, val) FROM dbo.strSplit(@LicenseeStatusIds, ',')
	END

	INSERT INTO #tblResult( 
			RowNumber
			,LicenseeId
			,LicenseeName
			,StatusName
			,TypeName
			,PlatformName
	)	
	SELECT	ROW_NUMBER() OVER(ORDER BY LicenseeName) AS RowNumber
			, l.LicenseeId
			,l.LicenseeName
			,ls.LicenseeStatusName
			,lt.TypeName
			,pf.PlatformName
	FROM	dbo.Licensee l
		INNER JOIN LicenseeTypes lt 
			ON	l.TypeId = lt.TypeId
		INNER JOIN LicenseeStatus ls 
			ON	l.LicenseeStatusId = ls.LicenseeStatusId
		INNER JOIN [dbo].[Platform] pf WITH(NOLOCK)
			ON l.PlatformId = pf.PlatformId
		LEFT JOIN #tblLicenseeFeature lf
			ON l.LicenseeId = lf.LicenseeId
	WHERE	l.TypeId IN (SELECT LicenseeTypeId FROM @tblLicenseeType)
			AND l.LicenseeName LIKE ISNULL(@LicenseeName,'%') + '%'
			AND (@LicenseeStatusIds = 'All' OR l.LicenseeStatusId IN (SELECT StatusId FROM @tblStatusId)) 
			AND l.PlatformId IN (SELECT PlatformId FROM @tblPlatform)
			AND l.LicenseeId IN (SELECT lim.LicenseeId FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK) WHERE lim.IntegrationMethodId IN (SELECT IntegrationMethodId FROM @tblIntegrationMethod))
			AND (@SelectedFeature = 'All' OR lf.IsFilled = 1)
	GROUP BY l.LicenseeId
			,l.LicenseeName
			,ls.LicenseeStatusName
			,lt.TypeName
			,pf.PlatformName
	
	IF @TotalRecords = 0
	BEGIN
		SELECT @TotalRecords = COUNT(1)
		FROM #tblResult
	END
			
	SELECT	@strFeatureName = ISNULL(@strFeatureName, '') + '[' +  Featurename + '],'
	FROM	dbo.Feature WITH(NOLOCK)
	WHERE	FeatureId IN (SELECT val FROM dbo.strSplit(@FeatureShown,','))
	ORDER BY FeatureId
	
	SELECT @strFeatureName = LEFT(@strFeatureName,LEN(@strFeatureName) -1)	
	
	SELECT @DynamicPIVOT = 'SELECT LicenseeId
								,LicenseeName
								,StatusName
								,TypeName
								,PlatformName
								,IntegrationName.value AS IntegrationMethodName
								,' + @strFeatureName +
	'FROM (
			SELECT	 RowNumber, t.LicenseeId, t.LicenseeName, t.StatusName, t.TypeName, p.Featurename, t.PlatformName
			,CONVERT(VARCHAR(1), ISNULL(IsFilled, 0)) + '','' + CONVERT(VARCHAR(10), lp.LaunchDate, 20) + CASE WHEN ISNULL(lp.TerminationDate, '''') <> ''''THEN + '','' + CONVERT(VARCHAR(10), lp.TerminationDate, 20) ELSE '''' END AS [Date]
			FROM	 #tblResult t WITH(NOLOCK)
				LEFT JOIN dbo.LicenseeFeature lp WITH(NOLOCK)
					ON	t.LicenseeId = lp.LicenseeId				
				LEFT JOIN dbo.Feature p WITH(NOLOCK)
					ON	lp.FeatureId = p.FeatureId
				LEFT JOIN #tblLicenseeFeature tlp
					ON t.LicenseeId = tlp.LicenseeId AND lp.FeatureId = tlp.FeatureId
		 )p
	PIVOT (
		MAX(p.[Date]) FOR Featurename IN (' + @strFeatureName + ')
	) Result
	OUTER APPLY (
							SELECT STUFF((SELECT '', '' + im.IntegrationMethodName
										FROM dbo.LicenseeIntegrationMethod lim WITH(NOLOCK)
											INNER JOIN dbo.IntegrationMethod im WITH(NOLOCK) 
												ON lim.IntegrationMethodId = im.IntegrationMethodId
										WHERE lim.LicenseeId = Result.LicenseeId AND im.IntegrationMethodName IS NOT NULL 
										ORDER BY im.IntegrationMethodId asc
										FOR XML PATH('''')), 1, 1, '''')
						) IntegrationName(value)
	WHERE RowNumber BETWEEN ' + CONVERT(VARCHAR(10),@RowStart) + ' AND ' + CONVERT(VARCHAR(10),@RowEnd) + ''
	
	EXEC (@DynamicPIVOT)
END
GO
