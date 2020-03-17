/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LicenseeGroupSel]
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
