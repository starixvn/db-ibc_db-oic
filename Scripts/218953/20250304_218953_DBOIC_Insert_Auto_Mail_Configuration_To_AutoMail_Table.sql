/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20250304@Kai
	DB: DBOIC.bodb_OIC
	Task: Setup Auto Mail configuration for Double S #218953
*/

-- Clone auto mail configuration from Bopping to Double S
DECLARE @DoubleSTypeId TINYINT
SELECT @DoubleSTypeId = lt.TypeId
FROM dbo.LicenseeTypes lt WITH (NOLOCK)
WHERE lt.TypeName = 'Double S'

IF ISNULL(@DoubleSTypeId, 0) <> 0
BEGIN
	INSERT dbo.AutoMail (Email, RecipientType, IsTest, GroupId, TypeId, LicenseeTypeId)
	SELECT am.Email
		  ,am.RecipientType
		  ,am.IsTest
		  ,am.GroupId
		  ,am.TypeId
		  ,@DoubleSTypeId AS LicenseeTypeId
	FROM dbo.AutoMail am WITH(NOLOCK)
	INNER JOIN dbo.LicenseeTypes lt WITH (NOLOCK)
	ON am.LicenseeTypeId = lt.TypeId 
	WHERE lt.TypeName = 'Boping'
END
GO

-- Remove unused Table
EXEC sp_rename 'dbo.LicenseeType', 'DEL_LicenseeType'

GO