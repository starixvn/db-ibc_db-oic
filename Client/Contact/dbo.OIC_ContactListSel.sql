/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_ContactListSel]
	@SelectedContact	NVARCHAR(1000)    = ''
    
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
    
	DECLARE @ToList		VARCHAR(1000)
			,@CcList	VARCHAR(1000)

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
			,(SELECT ISNULL(@ToList,'') + c.CategoryName + ','  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category c WITH(NOLOCK) 
						ON c.CategoryId = cc.CategoryID
				WHERE cc.ContactID = lc.ContactID 
						AND cc.RecipientType = 0 
				FOR XML PATH('')
			  ) AS ToList
			,(SELECT ISNULL(@CcList,'') + c.CategoryName + ','  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category c WITH(NOLOCK) 
						ON c.CategoryId = cc.CategoryID
				WHERE cc.ContactID = lc.ContactID 
						AND cc.RecipientType = 1
			   FOR XML PATH('')
			  ) AS CcList
			,lc.IsMain
			,lc.IsLicenseeContact
    FROM	dbo.Contact lc WITH(NOLOCK)
    WHERE	lc.ContactID IN (SELECT CONVERT(INT, val) AS ContactID FROM dbo.strSplit(@SelectedContact, ','))
END
