/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AutoMailByRecipientSel]
	@GroupId			TINYINT = 0
	,@TypeId			TINYINT = 0
	,@LicenseeTypeId	TINYINT = 0
AS

/*
	Created by: Cody
	Date: 2024-08-27
	Task: Manage recipient list of auto mails [RedmineId: #209253]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20240827@Cody: Init [RedmineId: #209253]

*/

BEGIN
	SET NOCOUNT ON;

	SELECT	a.Id
			,ag.GroupId
			,ag.GroupName
			,lt.TypeId		AS LicenseeTypeId
			,lt.TypeName	AS LicenseeTypeName
			,a.Email
			,a.RecipientType
	FROM dbo.AutoMail a WITH(NOLOCK)
		INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK)
			ON a.LicenseeTypeId = lt.TypeId
		INNER JOIN dbo.AutoMailGroup ag WITH(NOLOCK)
			ON a.GroupId = ag.GroupId
	WHERE (@GroupId = 0 OR a.GroupId = @GroupId)
			AND (@TypeId = 0 OR a.TypeId = @TypeId)
			AND (@LicenseeTypeId = 0 OR a.LicenseeTypeId = @LicenseeTypeId)
			AND IsTest = 0
	ORDER BY lt.TypeId
END
GO