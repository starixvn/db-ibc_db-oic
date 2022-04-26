/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_ContactListSel]
	@SelectedContact	VARCHAR(2200)    = ''
    
AS
/*
    Created by: Alex
    Date: 2022-02-28
    Task: Enhance function to copy contact list for licensees [Redmine:#161538]
    DB: DBOIC/BODB_OIC 
    
    Revisions:
		- 20220228@Alex: Init SP [RedmindId: #161538]
    
    Param's Explanation:
		*@SelectedContact: '1,2,3,4'
*/
BEGIN
    SET NOCOUNT ON
	
    DECLARE @tblContactList TABLE(ContactId INT)
	DECLARE @ToList		VARCHAR(1000)
			,@CcList	VARCHAR(1000)
			
	INSERT INTO @tblContactList(ContactId)
	SELECT CONVERT(INT, val) AS ContactId 
	FROM dbo.strSplit(@SelectedContact, ',')
	
    SELECT	lc.ContactID		
			,lc.LicenseeId
			,lc.ContactName
			,lc.ContactType 
			,lc.ContactPosition		AS Position
			,lc.ContactDepartment	AS Department
			,lc.ContactPhoneNumber	AS PhoneNumber
			,lc.ContactEmail		AS Email
			,lc.ContactSkype		AS Skype
			,lc.ContactLandline		AS Landline
			,lc.Remark
			,(SELECT STUFF ((SELECT ', ' + c.CategoryName
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category c WITH(NOLOCK) 
						ON c.CategoryId = cc.CategoryID
				WHERE cc.ContactID = lc.ContactID 
						AND cc.RecipientType = 0 
				FOR XML PATH('')),1,2,'')) AS ToList
			,(SELECT STUFF ((SELECT ', ' + c.CategoryName
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category c WITH(NOLOCK) 
						ON c.CategoryId = cc.CategoryID
				WHERE cc.ContactID = lc.ContactID 
						AND cc.RecipientType = 1
			   FOR XML PATH('')),1,2,'')) AS CcList
			,lc.IsMain
			,lc.IsLicenseeContact
    FROM @tblContactList cl
	INNER JOIN dbo.Contact lc WITH(NOLOCK)
    ON	lc.ContactID = cl.ContactId
END
