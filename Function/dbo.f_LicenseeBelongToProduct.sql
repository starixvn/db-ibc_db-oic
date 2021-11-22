/*<info serverAlias="DBOIC-bodb_OIC" viewers="" isFunction="1" isNested="1"></info>*/

USE [bodb_OIC]
GO

ALTER FUNCTION [dbo].[f_LicenseeBelongToProduct]
(
	@ProductId TINYINT
	,@UserId INT
	,@ExcludeTerminationProduct		BIT		= 0
)

RETURNS @res TABLE (
	LicenseeId INT NOT NULL
	,LicenseeName NVARCHAR(50) NOT NULL
	,TypeId	INT NOT NULL
	,TypeName NVARCHAR(50) NOT NULL
	,PRIMARY KEY CLUSTERED (LicenseeId ASC)
	) WITH EXECUTE AS CALLER
AS

/*
    Created by:
    Date:
    Task:
    DB: DBOIC.bodb_OIC
    
    Revisions:
		- 20210729@Hogan: Enhance Site Name in Send mail notification function [Redmine: #159206]
		- 20210908@Hogan: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
    
    Param's Explanation:
		
*/

BEGIN
	INSERT INTO @res (LicenseeId, LicenseeName, TypeId, TypeName)
	SELECT  l.LicenseeId, l.LicenseeName, l.TypeId, f.TypeName
	FROM	dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeProduct lp WITH(NOLOCK)
			ON l.LicenseeId = lp.LicenseeId
		INNER JOIN dbo.f_LicenseeTypeBelongToUser(@UserId) f
			ON f.TypeId = l.TypeId
	WHERE	lp.ProductId = @ProductId
		AND (@ExcludeTerminationProduct = 0 OR (lp.TerminationDate IS NULL OR lp.TerminationDate > CAST(GETDATE() AS DATE)))
	
	RETURN
END
