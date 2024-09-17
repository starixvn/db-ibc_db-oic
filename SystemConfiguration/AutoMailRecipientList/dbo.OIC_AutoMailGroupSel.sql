/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AutoMailGroupSel]

AS

/*
	Created by: Cody
	Date: 2024-09-18
	Task: Manage recipient list of auto mails [RedmineId: #209253]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20240918@Cody: Init [RedmineId: #209253]

    Param's Explanation:

*/

BEGIN
	SET NOCOUNT ON;

    SELECT  GroupId AS TeamId
            ,GroupName AS TeamName
    FROM dbo.AutoMailGroup WITH(NOLOCK)

END
GO