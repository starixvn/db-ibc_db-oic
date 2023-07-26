/*<info serverAlias="DBEXT-bodb02" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_TicketListingSel]
	@SessionID					NVARCHAR(300)
	
AS

/*
	Created by: Alex
	Date: 2021-12-20
	Task: OIC - Enhance Result Amendment/ Recalculation [Redmine:#164892]
	DB: DBEXT.bodb02

	Revisions:
		- 20211220@Alex: Create SP [Redmine:#164892]
		- 20230803@Cody: Migrate bodb_OIC to db054/db055 - [RedmineId: #191392]

	Param's Explanation:
	
 */
 
BEGIN
	SET NOCOUNT ON
	
	SELECT EventDate, MatchId
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] WITH(NOLOCK)
	WHERE SessionID = @SessionID
	
	SELECT DISTINCT lrad.TransID AS BetId
		,SUBSTRING(c.username2,CHARINDEX('$',c.username2)+1,LEN(c.username2)) AS UserName
		,c.username AS SystemId
	FROM [bodb_licensee].[dbo].[LicenseeResultAmendment] lra WITH(NOLOCK)
		INNER JOIN [bodb_licensee].[dbo].[LicenseeResultAmendmentDetails] lrad WITH(NOLOCK)
			ON lra.ResultID = lrad.ResultID
		INNER JOIN [dbo].[Customer] c WITH(NOLOCK)
			ON c.custid = lrad.CustID
	WHERE lra.SessionID = @SessionID
END
GO