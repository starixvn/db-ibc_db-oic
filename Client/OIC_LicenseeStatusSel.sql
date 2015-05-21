USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LicenseeStatusSel]    Script Date: 04/16/2015 14:35:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.OIC_LicenseeStatusSel    Script Date: 16/04/2015 9:22:41 AM ******/
ALTER PROCEDURE [dbo].[OIC_LicenseeStatusSel]
	@ShowTest INT = 0
AS

/*
	Created by: Dom
	Date: 2014-12-18
	Task: Get Licensee Status [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		
 */

BEGIN
	SET NOCOUNT ON;
	
	SELECT	LicenseeStatusId
			,LicenseeStatusName AS Statusname
			,Remark 
	FROM dbo.LicenseeStatus WITH(NOLOCK)  
	WHERE	@ShowTest = 1 
			OR IsTest=@ShowTest
END
GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeStatusSel] TO [bodbAdminNet] AS [dbo]