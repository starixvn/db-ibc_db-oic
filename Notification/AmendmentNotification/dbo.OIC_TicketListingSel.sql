/*<info serverAlias="DBEXT-bodb02" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_TicketListingSel]
	@SessionID					NVARCHAR(300)
	,@MoveBetsDay				DATETIME
	,@BalanceUpDay				DATETIME
	
AS
/*
	Created by: Alex
	Date: 2021-12-20
	Task: OIC - Enhance Result Amendment/ Recalculation [Redmine:#164892]
	DB: DBOIC/BODB_OIC 

	Revisions:
		- 20211220@Alex: Create SP [Redmine:#164892]

	Param's Explanation:
	
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @tblMatch	TABLE (matchid INT, IsNeutral BIT, matchcode NVARCHAR(50), sporttype SMALLINT, awayid INT, homeid INT)
	DECLARE @EventDate DATETIME;
	DECLARE @MatchId INT;
	
	SELECT @EventDate = EventDate, @MatchId = MatchID
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] WITH(NOLOCK)
	WHERE SessionID = @SessionID
	
	IF @EventDate >= @MoveBetsDay + 1
	BEGIN
		INSERT INTO @tblMatch (matchid, IsNeutral, matchcode, sporttype, awayid, homeid)
		SELECT	matchid, IsNeutral, matchcode, sporttype, awayid, homeid
		FROM	[bodb02].[dbo].[match] WITH(NOLOCK)
		WHERE matchid = @MatchId
	END
	ELSE IF @EventDate >= @BalanceUpDay	
	BEGIN
		INSERT INTO @tblMatch (matchid, IsNeutral, matchcode, sporttype, awayid, homeid)
		SELECT	matchid, IsNeutral, matchcode, sporttype, awayid, homeid
		FROM	[bodb02].[dbo].[match14] WITH(NOLOCK)
		WHERE matchid = @MatchId
	END
	ELSE
	BEGIN
		INSERT INTO @tblMatch (matchid, IsNeutral, matchcode, sporttype, awayid, homeid)
		SELECT	matchid, IsNeutral, matchcode, sporttype, awayid, homeid
		FROM	[DBARC].[bodb_Archive].[dbo].[match_bk] WITH(NOLOCK)
		WHERE matchid = @MatchId
	END
	
	SELECT DISTINCT lra.MatchID 
		,lra.EventDate
		,m.matchcode AS CodeId
		,m.IsNeutral
		,sbm.ProductID 
		,s.SportName
		,t1.teamname AS AwayTeam
		,t2.teamname AS HomeTeam
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] lra WITH(NOLOCK)
		INNER JOIN @tblMatch m 
			ON lra.MatchID = m.matchid
		INNER JOIN [bodb02].[dbo].[SportBettypeMatrix] sbm WITH(NOLOCK)
			ON sbm.SportType = m.sporttype
		INNER JOIN [bodb02].[dbo].[Sports] s WITH(NOLOCK)
			ON sbm.SportType = s. SportType
		LEFT JOIN [bodb02].[dbo].[Team] t1 WITH(NOLOCK)
			ON m.awayid = t1.teamid
		LEFT JOIN [bodb02].[dbo].[Team] t2 WITH(NOLOCK)
			ON m.homeid = t2.teamid
	WHERE lra.SessionID = @SessionID
			AND sbm.ProductID IN (1,3)
	
	SELECT DISTINCT lrad.TransID AS BetId
		,SUBSTRING(c.username2,CHARINDEX('$',c.username2)+1,LEN(c.username2)) AS UserName
		,c.username AS SystemId
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] lra WITH(NOLOCK)
		INNER JOIN [bodb_licensee].[dbo].[LicenseeResultAmendmentDetails] lrad WITH(NOLOCK)
			ON lra.ResultID = lrad.ResultID
		INNER JOIN [bodb02].[dbo].[Customer] c WITH(NOLOCK)
			ON c.custid = lrad.CustID
	WHERE lra.SessionID = @SessionID
END
GO