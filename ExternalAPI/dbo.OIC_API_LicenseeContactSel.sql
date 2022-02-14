/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_API_LicenseeContactSel]
	 @ContactId		INT
	,@SiteName		NVARCHAR(50)
AS
/*
	Created by: Howard
	Date: 2022-02-14
	Task: Add new licensee contact from external system (LAP) [Redmine:#165286]
	DB: DBOIC.bodb_OIC 
	
	Revisions:
		- 20220214@Howard: Init [Redmine:#165286]

	Param's Explanation:
	*
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LicenseeId INT

	SELECT @LicenseeId = l.LicenseeId 
	FROM dbo.Licensee l WITH(NOLOCK) 
	WHERE l.RegisteredLicenseeName = @SiteName
	
	SELECT	c.ContactID
			,c.ContactType
			,c.ContactName
			,c.ContactPosition AS Position
			,c.ContactDepartment AS Department
			,c.ContactEmail AS Email
			,c.ContactSkype AS Skype
			,c.Remark
	FROM dbo.Contact c WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId
	WHERE c.ContactID = @ContactId AND c.IsLicenseeContact = 1 AND l.RegisteredLicenseeName = @SiteName
	
	SELECT  c.CategoryId
			,c.CategoryName
			,c.CategoryNameCN
			,cc.RecipientType
	FROM	dbo.Category c WITH(NOLOCK)
			INNER JOIN dbo.LicenseeCategoryAssigned l WITH(NOLOCK) 
				ON	l.CategoryId = c.CategoryId AND l.LicenseeId = @LicenseeId
			LEFT JOIN dbo.CategoryContact cc WITH(NOLOCK) 
				ON cc.CategoryId = c.CategoryId AND cc.ContactId = @ContactId
	ORDER BY c.CategoryName ASC
END

GO
