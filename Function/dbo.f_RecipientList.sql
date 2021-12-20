/*<info serverAlias="DBOIC-bodb_OIC" isFunction="1" isNested="0"></info>*/

ALTER FUNCTION [dbo].[f_RecipientList] (
	@SelectedLicensee	VARCHAR(MAX)
	,@CategoryId		TINYINT
	,@UserId			INT
)
RETURNS @res TABLE (
	LicenseeId			INT NOT NULL
	,Recipient			INT NOT NULL
	,RecipientName		NVARCHAR(50)
	,Email				NVARCHAR(50)
	,IsContact			BIT NOT NULL
	,RecipientType		TINYINT
	) WITH EXECUTE AS CALLER
AS

/*
    Revisions:
		- 20200518@hogan: csoneonone@enpine.com does not receive email when sending to upcomming licensees [RedmineID: #133714]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
    
    Param's Explanation:
		
*/

BEGIN
	DECLARE @tblLicensee TABLE (LicenseeId INT, LicenseeTypeId TINYINT, LicenseeStatusId TINYINT)
	
	DECLARE @UserEmail					NVARCHAR(50)
			,@DisplayName				NVARCHAR(50)

	SELECT @UserEmail = Email
			,@DisplayName = DisplayName
	FROM	dbo.UserInfo WITH(NOLOCK)
	WHERE	UserId = @UserId
	
	INSERT INTO @tblLicensee (LicenseeId, LicenseeTypeId, LicenseeStatusId)
	SELECT	DISTINCT LicenseeId, TypeId, LicenseeStatusId
	FROM	dbo.Licensee WITH(NOLOCK)
	WHERE	LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
	
	INSERT INTO @res(
			LicenseeId
			,Recipient
			,RecipientName
			,Email
			,IsContact
			,RecipientType
		)
	SELECT	c.LicenseeId
			,c.ContactId
			,c.ContactName
			,c.ContactEmail
			,1
			,cc.RecipientType
	FROM	dbo.Contact c WITH(NOLOCK)
		INNER JOIN CategoryContact cc WITH(NOLOCK)
			ON	c.ContactId = cc.ContactId
				AND cc.CategoryId = @CategoryId
	WHERE	c.LicenseeId IN (SELECT LicenseeId FROM @tblLicensee)
	
	INSERT INTO @res (LicenseeId, Recipient, RecipientName, Email, IsContact, RecipientType)
	SELECT	ul.LicenseeId
			,ui.UserId -- AM
			,ui.DisplayName
			,ult.Email
			,0
			,2 -- AddtoCc
	FROM	dbo.UserLicensee ul WITH(NOLOCK)
		INNER JOIN dbo.UserInfo ui WITH(NOLOCK)
			ON ul.UserId = ui.UserId
		INNER JOIN dbo.UserLicenseeTypes ult WITH(NOLOCK)
			ON ui.UserId = ult.UserId
		INNER JOIN @tblLicensee t
			ON t.LicenseeId = ul.LicenseeId AND t.LicenseeTypeId = ult.TypeId
	WHERE	ui.PositionId = 6
	UNION 
	SELECT	t.LicenseeId
			,ui.UserId -- HOD AM
			,ui.DisplayName
			,ult.Email
			,0
			,2 -- AddtoCc
	FROM	dbo.UserInfo ui WITH(NOLOCK)
		INNER JOIN dbo.UserLicenseeTypes ult WITH(NOLOCK)
			ON ui.UserId = ult.UserId
		INNER JOIN @tblLicensee t
			ON t.LicenseeTypeId = ult.TypeId
	WHERE	ui.PositionId = 3 
	UNION
	SELECT	LicenseeId
			,0 -- system
			,'system'
			,CcList
			,0
			,2 -- AddtoCc
	FROM	@tblLicensee
		CROSS APPLY dbo.EmailConfiguration 
	WHERE	LicenseeStatusId = 3
	UNION
	SELECT	LicenseeId
			,0 -- system
			,'system'
			,BccList
			,0
			,3 -- bcc
	FROM	@tblLicensee
		CROSS APPLY dbo.EmailConfiguration
	WHERE	LicenseeStatusId = 3
	
	RETURN
END

GO