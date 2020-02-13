/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LicenseeGroupSel]    Script Date: 2/12/2020 1:36:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OIC_LicenseeGroupSel]
AS

/*
	Created by: Hogan
	Date: 2020-1-10
	Task: Add Group into Client functions [Redmine:#126855]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20200110@Hogan: Create stored procedure OIC_LicenseeGroupSel [RedmineID: #126855]
 */

BEGIN
	SET NOCOUNT ON;
	
	SELECT	Id
			,Name
	FROM dbo.LicenseeGroup WITH(NOLOCK)  
END

GO
