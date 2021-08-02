/*<info serverAlias="DBOIC-bodb_OIC" executers="" viewers="" isFunction="1" isNested="1"></info>*/

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
	,LicenseeTypeId	INT NOT NULL
	,LicenseeTypeName VARCHAR(30) NOT NULL
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
    
    Param's Explanation:
		
*/

BEGIN
	INSERT INTO @res (LicenseeId, LicenseeName, LicenseeTypeId, LicenseeTypeName)
	SELECT  l.LicenseeId, l.LicenseeName, l.LicenseeTypeId, f.LicenseeTypeName
	FROM	dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeProduct lp WITH(NOLOCK)
			ON l.LicenseeId = lp.LicenseeId
		INNER JOIN dbo.f_LicenseeTypeBelongToUser(@UserId) f
			ON f.LicenseeTypeId = l.LicenseeTypeId
	WHERE	lp.ProductId = @ProductId
		AND (@ExcludeTerminationProduct = 0 OR (lp.TerminationDate IS NULL OR lp.TerminationDate > CAST(GETDATE() AS DATE)))
	
	RETURN
END
