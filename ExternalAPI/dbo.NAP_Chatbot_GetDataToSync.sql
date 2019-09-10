/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[NAP_Chatbot_GetDataToSync]
AS
/*
	Created: Oliver
	Date: 20190910
	Task: Sync data from OIC [RedmineID #119934]
	DB: DBOIC/bodb_OIC  

	Revisions:
		- 20190910@Oliver: init
*/
BEGIN

	SET NOCOUNT ON

	SELECT l.LicenseeId
		  ,l.LicenseeName
		  ,l.RegisteredLicenseeName
		  ,l.LicenseeStatusId
		  ,l.LicenseeTypeId
	FROM dbo.Licensee l WITH (NOLOCK)
	ORDER BY l.LicenseeId

	SELECT ls.LicenseeStatusId
	      ,ls.LicenseeStatusName 
	FROM dbo.LicenseeStatus ls WITH (NOLOCK)
	ORDER BY ls.LicenseeStatusId

	SELECT lp.LicenseeId
		  ,lp.ProductId
		  ,lp.LaunchDate
		  ,lp.TerminationDate
	FROM dbo.LicenseeProduct lp WITH (NOLOCK)
	ORDER BY lp.LicenseeId, lp.ProductId

	SELECT lt.LicenseeTypeId
		   ,lt.LicenseeTypeName
	FROM dbo.LicenseeType lt WITH (NOLOCK)
	ORDER BY lt.LicenseeTypeId

	SELECT p.ProductId
		  ,p.ProductName
	FROM dbo.Product p WITH (NOLOCK)
	ORDER BY p.ProductId
	
END

GO
GRANT EXECUTE ON [dbo].[NAP_Chatbot_GetDataToSync] TO [bodbAdminNet] AS [dbo]
