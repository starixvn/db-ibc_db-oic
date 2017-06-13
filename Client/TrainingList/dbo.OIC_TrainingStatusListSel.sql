USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_TrainingStatusListSel] 
AS

/*
	Created by Percy
	Date: 2017-05-30
	DB: DBOIC.bodb_OIC
	Task: Select status of training [RedmineID: #74879]

	Revisions:
*/

BEGIN
	SET NOCOUNT ON

	SELECT TrainingStatusId, TrainingStatusName
	FROM dbo.TrainingStatus WITH(NOLOCK)
	ORDER BY TrainingStatusId
END
GO
GRANT EXECUTE ON [dbo].[OIC_TrainingStatusListSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_TrainingStatusListSel] TO [vnteam] AS [dbo]