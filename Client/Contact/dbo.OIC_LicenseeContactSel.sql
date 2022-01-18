/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_LicenseeContactSel]
	@ContactId		INT
AS
/*
	Created by: Kathy
	Date: 2015-02-09
	Task: Licensee contact info [Redmine:#30037]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20210913@Hogan: return IsMain column [RedmineID: #160430]
		- 20211109@Alex: Change Type Of Licensee [RedmindId: #163521]
		- 20220117@Kai: New Licensee Contact function [Redmine:#165286]

	Param's Explanation:
	*
*/
BEGIN
	SET NOCOUNT ON
	
	SELECT	c.ContactID
			,l.LicenseeId
			,l.TypeId
			,l.PlatformId
			,c.ContactType
			,c.IsLicenseeContact
			,c.ContactName
			,c.ContactPosition AS Position
			,c.ContactDepartment AS Department
			,c.ContactEmail AS Email
			,c.ContactSkype AS Skype
			,c.ContactPhoneNumber AS PhoneNumber
			,c.ContactLandline AS Landline
			,c.Remark
			,c.IsMain
	FROM dbo.Contact c WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId
	WHERE	c.ContactID = @ContactId
	
	SELECT	CategoryID
			,RecipientType as Type
	FROM dbo.CategoryContact WITH(NOLOCK)
	WHERE ContactID = @ContactId
	
	SELECT	im.IntegrationMethodId, im.IntegrationMethodName
	FROM dbo.Contact c WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId
		INNER JOIN dbo.LicenseeIntegrationMethod lim WITH(NOLOCK)
			ON  c.LicenseeID = lim.LicenseeId
		INNER JOIN dbo.IntegrationMethod im WITH(NOLOCK)
			ON 	lim.IntegrationMethodId = im.IntegrationMethodId
	WHERE	c.ContactID = @ContactId
END
GO