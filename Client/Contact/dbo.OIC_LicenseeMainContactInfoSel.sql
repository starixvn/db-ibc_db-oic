USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LicenseeMainContactInfoSel]    Script Date: 05/21/2015 09:23:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[OIC_LicenseeMainContactInfoSel] --1
	@MainContactId INT
AS
/*
	Created by: Kathy
	Date: 2015-04-21
	Task: Get info main contact of licensee [Redmine:#29609]
	DB: DBOIC.bodb_OIC
	
	Revisions:
	
	
	
 */
BEGIN

	SET NOCOUNT ON
	
	SELECT	c.ContactName
			,c.ContactPosition
			,c.ContactEmail
			,c.ContactSkype
			,c.ContactPhoneNumber
	FROM	dbo.Contact c WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK) 
			ON	l.LicenseeId = c.LicenseeID 
	WHERE	c.ContactID = @MainContactId
			AND c.IsMain = 1	
	
END

GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeMainContactInfoSel] TO [bodbAdminNet] AS [dbo]