/*<info serverAlias="DBNAP-bodb_NAPLOG" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_PasswordUpdateLogSel]
	@SiteId		TINYINT,	
	@FromDate	DATETIME,
	@ToDate		DATETIME
AS

/*
	Created by: Cody
	Date: 20230719
	Task: Migrate bodb_OIC to db054/db055
	DB: DBNAP.bodb_NAPLOG
	
	Revisions:
		- 20230719@Cody: Create sp - [RedmineId: #191392]
	
	Parameters:
 */

BEGIN
	SET NOCOUNT ON;

	SELECT n.Id AS LogId, n.UserId, n.LogDate, 2002 AS ActionId, nd.OldData, nd.Data
	FROM [dbo].[NAPLog_RUNSP] n WITH(NOLOCK)
		INNER JOIN [dbo].[NAPLOG_RUNSP_Detail] nd WITH(NOLOCK) ON n.Id = nd.ID
	WHERE n.LogDate BETWEEN @FromDate AND @ToDate
			AND n.ActionId = 3 AND n.siteID = @SiteId
END