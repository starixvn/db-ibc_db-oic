/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_API_LicenseeInfoBySiteNameSel] 
	 @SiteName			NVARCHAR(50)
	,@Language			VARCHAR(10)	= 'E'
	,@ErrCode			INT			= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)= NULL		OUTPUT
AS
/*
	Created by: Howard
	Date: 2022-02-14
	Task: Add new licensee contact from external system (LAP) [Redmine:#165286]
	DB: DBOIC.bodb_OIC 
	
	Revisions:
		- 20220214@Howard: Init [Redmine:#165286]
*/
BEGIN
	SET NOCOUNT ON

	SELECT l.LicenseeId, l.LicenseeName
	FROM dbo.Licensee l WITH(NOLOCK)
	WHERE l.RegisteredLicenseeName = @SiteName
	
END

GO
