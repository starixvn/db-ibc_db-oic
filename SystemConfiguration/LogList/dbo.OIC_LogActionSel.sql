/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LogActionSel]
	@ActionTypeID	TINYINT = 0, -- All
	@ActionID		INT = 0 -- All
AS
/*
	Creator: Percy
	Date: 2016-09-26
	DB: DBOIC.bodb_OIC
	Task: Select Log Action List [RedmineID: #64713]
	
	Revisions:	
		- 20171124@Scofield: #84004 - Update to show Notification LogActionType
*/
BEGIN
	SELECT
		lt.LogActionTypeId, lt.ActionTypeNameEn AS ActionTypeName, l.LogActionId, l.ActionNameEn AS ActionName
	FROM dbo.LogActionType lt WITH(NOLOCK)
		INNER JOIN dbo.LogAction l WITH(NOLOCK) ON lt.LogActionTypeId = l.LogActionTypeId
	WHERE [Enable] = 1
	ORDER BY [Order]
END
GO
