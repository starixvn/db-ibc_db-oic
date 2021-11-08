USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LicenseeListByType]    Script Date: 09/07/2015 10:18:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OIC_LicenseeListByType]
	@UserId INT
AS
/*
	Created by: Kathy
	Date: 20150825
	Task: get all licensee belong to user [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
	
	Param's Explanation:
	
	*
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT	TypeId
			,TypeName
			,LicenseeId
			,LicenseeName
	FROM	dbo.f_LicenseeBelongToLicenseeType (@UserId)
	WHERE	LicenseeId IS NOT NULL
	ORDER BY TypeId
END















GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeListByType] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_LicenseeListByType] TO [vnteam] AS [dbo]