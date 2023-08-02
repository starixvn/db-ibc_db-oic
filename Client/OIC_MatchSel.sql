/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_MatchSel]
	@MatchId		INT,
	@EventDate		DATETIME,
	@MoveBetsDay	SMALLDATETIME,
	@BalanceUpDay	SMALLDATETIME
AS

/*
	Created by: 20230802@Kos
	Task: Migrate bodb_OIC to DB054/DB055
	DB: DBACC.bodb02

	Revisions:
		- 20230802@Kos: Migrate bodb_OIC to DB054/DB055 [RedmineId: #191392]
*/

BEGIN
	SET NOCOUNT ON;

	DECLARE @tblMatch TABLE (
		MatchId		INT,
		IsNeutral	BIT,
		MatchCode	NVARCHAR(50),
		SportType	SMALLINT,
		AwayId		INT,
		HomeId		INT)

	IF @EventDate > @MoveBetsDay
	BEGIN
		INSERT INTO @tblMatch
		SELECT
			matchid,
			IsNeutral,
			matchcode,
			sporttype,
			awayid,
			homeid
		FROM dbo.match WITH (NOLOCK)
		WHERE matchid = @MatchId
	END
	ELSE IF @EventDate >= @BalanceUpDay
	BEGIN
		INSERT INTO @tblMatch
		SELECT
			matchid,
			IsNeutral,
			matchcode,
			sporttype,
			awayid,
			homeid
		FROM dbo.match14 WITH (NOLOCK)
		WHERE matchid = @MatchId
	END
	ELSE
	BEGIN
		INSERT INTO @tblMatch
		SELECT
			matchid,
			IsNeutral,
			matchcode,
			sporttype,
			awayid,
			homeid
		FROM bodb_Archive.dbo.match_bk WITH (NOLOCK)
		WHERE matchid = @MatchId
	END

	SELECT DISTINCT
		m.MatchId,
		m.MatchCode AS CodeId,
		m.IsNeutral,
		sbm.ProductID,
		s.SportName,
		t1.teamname AS AwayTeam,
		t2.teamname AS HomeTeam
	FROM @tblMatch AS m
		INNER JOIN dbo.SportBettypeMatrix AS sbm WITH (NOLOCK) ON sbm.SportType = m.sporttype
		INNER JOIN dbo.Sports AS s WITH (NOLOCK) ON s.SportType = sbm.SportType
		LEFT JOIN dbo.Team AS t1 WITH (NOLOCK) ON t1.teamid = m.awayid
		LEFT JOIN dbo.Team AS t2 WITH(NOLOCK) ON t2.teamid = m.homeid
	WHERE sbm.ProductID IN (1, 3)
END