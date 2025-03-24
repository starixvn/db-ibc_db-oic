/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20250320@Kai
	DB: DBOIC.bodb_OIC
	Task: Setup Auto Mail configuration for Product Relaunch Email #220858
*/

-- Insert new Auto Mail Type
INSERT dbo.AutoMailType (TypeId, TypeName)
VALUES (6, 'Product Relaunch Email')
GO

-- Clone Auto Mail from Terminated Product Email to Product Relaunch Email
DECLARE @AutoRelaunchProductTypeId TINYINT
SELECT @AutoRelaunchProductTypeId = amt.TypeId
FROM dbo.AutoMailType amt WITH (NOLOCK)
WHERE amt.TypeName = 'Product Relaunch Email'

IF ISNULL(@AutoRelaunchProductTypeId, 0) <> 0
BEGIN
	INSERT dbo.AutoMail (Email, RecipientType, IsTest, GroupId, TypeId, LicenseeTypeId)
	SELECT am.Email
		  ,am.RecipientType
		  ,am.IsTest
		  ,am.GroupId
		  ,@AutoRelaunchProductTypeId AS TypeId
		  ,am.LicenseeTypeId
	FROM dbo.AutoMail am WITH(NOLOCK)
	INNER JOIN dbo.AutoMailType amt WITH (NOLOCK)
	ON am.TypeId = amt.TypeId
	WHERE amt.TypeName = 'Terminated Product Email'
END
GO