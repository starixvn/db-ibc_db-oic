/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_TicketListingSel]
	@SessionID	NVARCHAR(300)	
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

	SELECT distinct lra.MatchID AS MatchId
		,lra.EventDate
		,m.matchcode AS CodeId
		,m.IsNeutral
		,sbm.ProductID 
		,t1.teamname AS AwayTeam
		,t2.teamname AS HomeTeam
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] lra WITH(NOLOCK)
		INNER JOIN [bodb02].[dbo].[match] m WITH(NOLOCK)
			ON lra.MatchID = m.matchid
		INNER JOIN [bodb02].[dbo].[SportBettypeMatrix] sbm WITH(NOLOCK)
			ON sbm.SportType = m.sporttype
		LEFT JOIN [bodb02].[dbo].[Team] t1 WITH(NOLOCK)
			ON m.awayid = t1.teamid
		LEFT JOIN [bodb02].[dbo].[Team] t2 WITH(NOLOCK)
			ON m.homeid = t2.teamid
	WHERE lra.SessionID = @SessionID
			AND sbm.ProductID IN (1,3)
	
	SELECT DISTINCT lrad.TransID AS BetId
		,c.username2 AS UserName
		,c.username AS SystemId
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] lra WITH(NOLOCK)
		INNER JOIN [bodb_licensee].[dbo].[LicenseeResultAmendmentDetails] lrad WITH(NOLOCK)
			ON lra.ResultID = lrad.ResultID
		INNER JOIN [bodb02].[dbo].[Customer] c WITH(NOLOCK)
			ON c.custid = lrad.CustID
	WHERE lra.SessionID = @SessionID
END
GO