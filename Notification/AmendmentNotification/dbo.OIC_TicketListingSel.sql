/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_TicketListingSel]
	@SessionID	NVARCHAR(300)
AS

/*
	Created by: Kai
	Date: 2025-02-10
	Task: OIC - Move Result Amendment to DBOIC.bodb_OIC db054/db055
	DB: DBOIC-bodb_OIC

	Revisions:
		- 20250210@Kai: Move Result Amendment to DBOIC.bodb_OIC db054/db055 - [RedmineId: #217146]

	Param's Explanation:
	
 */

BEGIN
	SET NOCOUNT ON
	
	SELECT EventDate, MatchId
	FROM LicenseeResultAmendment WITH(NOLOCK)
	WHERE SessionID = @SessionID
	
	SELECT DISTINCT lrad.TransID AS BetId
		,SUBSTRING(c.username2, CHARINDEX('$', c.username2) + 1, LEN(c.username2)) AS UserName
		,c.username AS SystemId
	FROM LicenseeResultAmendment lra WITH(NOLOCK)
		INNER JOIN LicenseeResultAmendmentDetails lrad WITH(NOLOCK)
			ON lra.ResultID = lrad.ResultID
		INNER JOIN bodb02.dbo.Customer c WITH(NOLOCK)
			ON c.custid = lrad.CustID
	WHERE lra.SessionID = @SessionID
END
GO