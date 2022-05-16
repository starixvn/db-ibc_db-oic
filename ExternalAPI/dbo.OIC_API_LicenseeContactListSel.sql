/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_API_LicenseeContactListSel]
	 @SiteName			NVARCHAR(50)
	,@SubsidiaryList	VARCHAR(1000)
	,@ContactName		NVARCHAR(50)	= NULL
	,@Language			VARCHAR(50)		= NULL
	,@ErrCode			INT				= 0 OUTPUT
	,@ErrMsg			VARCHAR(300)	= NULL OUTPUT
AS
/*
	Created by: Howard
	Date: 2022-02-14
	Task: Add new licensee contact from external system (LAP) [Redmine:#165286]
	DB: DBOIC.bodb_OIC 
	
	Revisions:
		- 20220214@Howard: Init [Redmine:#165286]
		- 20220424@Howard: Support Subsidiary business [Redmine:#170641]

	Param's Explanation:
	*
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @LicenseeId INT
			,@ToList	VARCHAR(1000)
			,@CcList	VARCHAR(1000)
			,@ToListId	VARCHAR(1000)
			,@CcListId	VARCHAR(1000)

	SELECT @LicenseeId = l.LicenseeId 
	FROM dbo.Licensee l WITH(NOLOCK)
	WHERE l.RegisteredLicenseeName =  @SiteName

	SELECT	c.ContactID
			,c.ContactType
			,c.ContactName
			,c.ContactPosition AS Position
			,c.ContactDepartment AS Department
			,c.ContactEmail AS Email
			,c.ContactSkype AS Skype
			,c.Remark
			,(SELECT ISNULL(@ToList,'') + 
				CASE 
					WHEN @Language = 'zh-cn' THEN ISNULL(ct.CategoryNameCN, ct.CategoryName)
					ELSE ct.CategoryName
				END
			 + '@'  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category ct WITH(NOLOCK) 
						ON ct.CategoryId = cc.CategoryID
				WHERE cc.ContactID = c.ContactID 
						AND cc.RecipientType = 0
				ORDER BY
					CASE 
						WHEN @Language = 'zh-cn' AND ct.CategoryNameCN IS NOT NULL THEN ct.CategoryNameCN
						ELSE ct.CategoryName 
					END ASC
				FOR XML PATH('')
			  ) AS ToListString
			,(SELECT ISNULL(@CcList,'') +
				CASE 
					WHEN @Language = 'zh-cn' THEN ISNULL(ct.CategoryNameCN, ct.CategoryName)
					ELSE ct.CategoryName
				END
			+ '@'  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category ct WITH(NOLOCK) 
						ON ct.CategoryId = cc.CategoryID
				WHERE cc.ContactID = c.ContactID 
						AND cc.RecipientType = 1
				ORDER BY
					CASE 
						WHEN @Language = 'zh-cn' AND ct.CategoryNameCN IS NOT NULL THEN ct.CategoryNameCN
						ELSE ct.CategoryName 
					END ASC
			   FOR XML PATH('')
			  ) AS CcListString
			  			,(SELECT ISNULL(@ToList,'') + 
				CASE 
					WHEN @Language = 'zh-cn' THEN ISNULL(ct.CategoryNameCN, ct.CategoryName)
					ELSE ct.CategoryName
				END
			 + '@'  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category ct WITH(NOLOCK) 
						ON ct.CategoryId = cc.CategoryID
				WHERE cc.ContactID = c.ContactID 
						AND cc.RecipientType = 0
				ORDER BY
					CASE 
						WHEN @Language = 'zh-cn' AND ct.CategoryNameCN IS NOT NULL THEN ct.CategoryNameCN
						ELSE ct.CategoryName 
					END ASC
				FOR XML PATH('')
			  ) AS ToListString
			  ,(SELECT ISNULL(@ToListId,'') + CONVERT(VARCHAR, ct.CategoryId)
			 + '@'  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category ct WITH(NOLOCK) 
						ON ct.CategoryId = cc.CategoryID
				WHERE cc.ContactID = c.ContactID 
						AND cc.RecipientType = 0
				FOR XML PATH('')
			  ) AS ToListInt
			,(SELECT ISNULL(@CcListId,'') + CONVERT(VARCHAR, ct.CategoryId)
			+ '@'  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category ct WITH(NOLOCK) 
						ON ct.CategoryId = cc.CategoryID
				WHERE cc.ContactID = c.ContactID 
						AND cc.RecipientType = 1
			   FOR XML PATH('')
			  ) AS CcListInt
			,c.IsMain
			,c.Subsidiary
	FROM dbo.Contact c WITH(NOLOCK)
	WHERE c.LicenseeId = @LicenseeId AND c.IsLicenseeContact = 1 
		AND c.ContactName LIKE '%' + LTRIM(RTRIM(ISNULL(@ContactName, ''))) + '%'
		AND ',' + @SubsidiaryList + ',' LIKE '%,' + ISNULl(c.Subsidiary, @SiteName) + ',%'
	ORDER BY c.IsMain DESC, c.ContactName ASC

END

GO
