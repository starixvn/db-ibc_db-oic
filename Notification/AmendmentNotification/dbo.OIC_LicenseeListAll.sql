/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

CREATE PROCEDURE [dbo].[OIC_LicenseeListAll]
AS
/*
	Created by: Scofield
	Date: 20171129
	Task: get all licensee [Redmine:#84004]
	DB: DBOIC.bodb_OIC
	
	Revisions:
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT lt.LicenseeTypeId, lt.LicenseeTypeName, l.LicenseeId, l.LicenseeName
	FROM dbo.Licensee l
	INNER JOIN dbo.LicenseeType lt ON l.LicenseeTypeId = lt.LicenseeTypeId
END
GO