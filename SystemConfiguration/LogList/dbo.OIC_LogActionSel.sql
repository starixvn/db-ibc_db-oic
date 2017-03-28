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
*/
BEGIN
	SELECT
		lt.LogActionTypeId, lt.ActionTypeNameEn AS ActionTypeName, l.LogActionId, l.ActionNameEn AS ActionName
	FROM dbo.LogActionType lt WITH(NOLOCK)
		INNER JOIN dbo.LogAction l WITH(NOLOCK) ON lt.LogActionTypeId = l.LogActionTypeId
	WHERE lt.LogActionTypeId <> 4 -- Don't support Notification Center
		AND [Enable] = 1
	ORDER BY [Order]
END
GO
GRANT EXECUTE ON [dbo].[OIC_LogActionSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LogActionSel] TO [vnteam] AS [dbo]
GO