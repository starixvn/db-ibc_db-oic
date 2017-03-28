USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LogListSel]
	@UserId			INT,
	@FromDate		DATETIME,
	@ToDate			DATETIME,
	@ActionID		VARCHAR(MAX) = 'All', -- All
	@Target			VARCHAR(50) = '', -- All
	@DoneBy			VARCHAR(50) = '', -- All
		
	@PageSize		INT = 10,
	@PageIndex		INT	= 1,
	@TotalRecords	INT = 0 OUTPUT
AS
/*
	Creator: Percy
	Date: 2016-09-26
	DB: DBOIC.bodb_OIC
	Task: Select Log List [RedmineID: #64713]

	Revisions:

	Param's Explanation:
		- @ActionID: '1,2' -- List of LogActionID
*/
BEGIN
	DECLARE @FDate DATETIME, @TDate DATETIME -- prevent bad parameter sniffing
	SELECT  @FDate = @FromDate, @TDate = @ToDate

	SELECT  @ActionID = ISNULL(@ActionID, ''), @Target = ISNULL(@Target, ''), @DoneBy = ISNULL(@DoneBy, '')
	SELECT  @Target = LTRIM(RTRIM(@Target)), @DoneBy = LTRIM(RTRIM(@DoneBy))
	SELECT  @Target = '%' + @Target + '%', @DoneBy = '%' + @DoneBy + '%'

	CREATE TABLE #LogList (LogID INT, LogDate DATETIME, ActionID INT, OldAction NVARCHAR(MAX), NewAction NVARCHAR(MAX), DoneBy NVARCHAR(100))
	CREATE TABLE #Result (LogID INT, LogDate DATETIME, [Action] VARCHAR(50), [Target] VARCHAR(MAX), DoneBy NVARCHAR(100), IsDetail BIT DEFAULT (1))
	
	DECLARE @ModifyUser TABLE (ID INT PRIMARY KEY, Name NVARCHAR(100)) -- @DoneBy
	INSERT INTO @ModifyUser (ID, Name)
	SELECT UserId AS ID, DisplayName AS Name
	FROM dbo.UserInfo WITH(NOLOCK)
	WHERE DisplayName LIKE @DoneBy

	-- Check user test
	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = @UserId AND DisplayName LIKE 'starix%')
	BEGIN
		DELETE @ModifyUser WHERE Name LIKE 'starix%'
	END

	DECLARE @Action TABLE (ActionID INT)

	IF EXISTS (SELECT TOP 1 1 FROM @ModifyUser)
	BEGIN
		IF ISNULL(@ActionID, '') <> 'All'
		BEGIN
			INSERT INTO @Action (ActionID)
			SELECT DISTINCT CONVERT(INT, val) FROM dbo.strSplit(@ActionID, ',')
		END
		
		INSERT INTO #LogList (LogID, LogDate, ActionID, OldAction, NewAction, DoneBy)
		SELECT DISTINCT ul.Id, ul.LogDate, ul.LogActionId, uld.OldData, uld.Data, m.Name
		FROM dbo.UserLog_RunSP ul WITH(NOLOCK)
			INNER JOIN dbo.UserLog_RunSP_Detail uld WITH(NOLOCK) ON ul.Id = uld.Id
			INNER JOIN @ModifyUser m ON ul.UserId = m.ID
		WHERE
			(@ActionID = 'All' OR ul.LogActionId IN (SELECT ActionID FROM @Action))
			AND ul.LogDate BETWEEN @FDate AND @TDate

		-- Target: Client
		IF EXISTS (SELECT TOP 1 1 FROM dbo.LogAction WITH(NOLOCK) WHERE LogActionTypeId = 1 AND (@ActionID = 'All' OR LogActionId IN (SELECT ActionID FROM @Action)))
		BEGIN
			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], l.LicenseeName, A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionTypeId = 1
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
				INNER JOIN dbo.Licensee l WITH(NOLOCK) ON l.LicenseeId = d.c.value('@lid','INT')
			WHERE l.LicenseeName LIKE @Target

			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], l.LicenseeName, A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r><row /></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionTypeId = 1
			) A
				CROSS APPLY A.[Target].nodes('r/row') d(c)
				INNER JOIN dbo.Licensee l WITH(NOLOCK) ON l.LicenseeId = d.c.value('@lid','INT')
			WHERE l.LicenseeName LIKE @Target
		END

		-- Target: Product Name
		IF (@ActionID = 'All' OR EXISTS (SELECT TOP 1 1 FROM @Action WHERE ActionID IN (3003, 3004, 3005, 200)))
		BEGIN
			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], d.c.value('@pn','VARCHAR(100)'), A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId IN (3003, 3004, 3005)
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
			WHERE d.c.value('@pn','VARCHAR(100)') LIKE @Target

			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], d.c.value('@pn','VARCHAR(100)'), A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r><lp><row /></lp></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId = 200
			) A
				CROSS APPLY A.[Target].nodes('r/lp/row') d(c)
			WHERE d.c.value('@pn','VARCHAR(100)') LIKE @Target
		END
		
		-- Target: Type Of Licensee
		IF (@ActionID = 'All' OR EXISTS (SELECT TOP 1 1 FROM @Action WHERE ActionID IN (3000, 3001, 3002)))
		BEGIN
			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], d.c.value('@ltn','VARCHAR(100)'), A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId IN (3000, 3001, 3002)
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
			WHERE d.c.value('@ltn','VARCHAR(100)') LIKE @Target
		END
		
		-- Target: Feature
		IF (@ActionID = 'All' OR EXISTS (SELECT TOP 1 1 FROM @Action WHERE ActionID IN (3009, 3010, 3011)))
		BEGIN
			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], d.c.value('@fn','VARCHAR(100)'), A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId IN (3009, 3010, 3011)
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
			WHERE d.c.value('@fn','VARCHAR(100)') LIKE @Target
		END
		
		-- Target: Category
		IF (@ActionID = 'All' OR EXISTS (SELECT TOP 1 1 FROM @Action WHERE ActionID IN (3006, 3007, 3008)))
		BEGIN
			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], d.c.value('@cn','VARCHAR(100)'), A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId IN (3006, 3007, 3008)
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
			WHERE d.c.value('@cn','VARCHAR(100)') LIKE @Target
		END
		
		-- Target: User
		IF (@ActionID = 'All' OR EXISTS (SELECT TOP 1 1 FROM @Action WHERE ActionID IN (2000, 2001, 2002, 3012, 3013)))
		BEGIN
			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], d.c.value('@udn','VARCHAR(100)'), A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId IN (2000, 3012)
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
			WHERE d.c.value('@udn','VARCHAR(100)') LIKE @Target

			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], u.DisplayName, A.DoneBy
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId IN (2001, 3013, 3014)
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
				INNER JOIN dbo.UserInfo u WITH(NOLOCK) ON d.c.value('@uid','VARCHAR(100)') = u.UserId
			WHERE u.DisplayName LIKE @Target

			-- get log update user password from NAP Admin --
			INSERT INTO #LogList (LogID, LogDate, ActionID, OldAction, NewAction, DoneBy)
			SELECT n.Id, n.LogDate, 2002, nd.Data, nd.OldData, m.Name
			FROM bodb_NAPLOG.dbo.NAPLog_RUNSP n WITH(NOLOCK)
				INNER JOIN bodb_NAPLOG.dbo.NAPLOG_RUNSP_Detail nd WITH(NOLOCK) ON n.Id = nd.ID
				INNER JOIN @ModifyUser m ON n.UserId = m.ID
			WHERE n.ActionId = 3 AND n.siteID = 24 -- OIC /*89: local, 24: UAT, PRO*/

			INSERT INTO #Result (LogID, LogDate, [Action], [Target], DoneBy, IsDetail)
			SELECT DISTINCT A.LogID, A.LogDate, A.[Action], u.DisplayName, A.DoneBy, 0
			FROM (
				SELECT ll.LogID, ll.LogDate, la.[ActionNameEn] AS [Action], CONVERT(XML, ISNULL(ISNULL(ll.NewAction, ll.OldAction), N'<r></r>')) AS [Target], ll.DoneBy
				FROM #LogList ll
					INNER JOIN dbo.LogAction la WITH(NOLOCK) ON ll.ActionID = la.LogActionId
				WHERE la.LogActionId = 2002
			) A
				CROSS APPLY A.[Target].nodes('r') d(c)
				INNER JOIN dbo.UserInfo u WITH(NOLOCK) ON d.c.value('@ui','VARCHAR(100)') = u.UserId
			WHERE u.DisplayName LIKE @Target
		END
	END

	SELECT @TotalRecords = COUNT(*) FROM #Result

	-- paging
	DECLARE @rowStart INT, @rowEnd INT
	SELECT  @rowStart = 1 + @PageIndex * @PageSize, @rowEnd = (@PageIndex + 1) * @PageSize
	
	;WITH CTE_Result AS (
		SELECT
			ROW_NUMBER() OVER(ORDER BY LogDate DESC, LogID DESC) AS rownum,
			*
		FROM #Result
	)
	SELECT
		*
	FROM CTE_Result
	WHERE rownum BETWEEN @rowStart AND @rowEnd
	ORDER BY rownum

	DROP TABLE #LogList
	DROP TABLE #Result
END
GO
GRANT EXECUTE ON [dbo].[OIC_LogListSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LogListSel] TO [vnteam] AS [dbo]
GO