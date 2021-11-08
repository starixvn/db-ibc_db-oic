/*<info serverAlias="DBOIC-bodb_OIC" executers="" viewers="" isFunction="1" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER FUNCTION [dbo].[f_LicenseeTypeBelongToUser] (@UserId INT)
RETURNS @res TABLE (
	TypeId		INT NOT NULL
	,TypeName	VARCHAR(40) NOT NULL
	,PRIMARY KEY CLUSTERED (TypeId ASC)
	) WITH EXECUTE AS CALLER
AS

/*
	Created by: 
	Date: 
	Task: 
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20210908@Hogan: Extend size of column LicenseeTypeName to VARCHAR(40) [RedmineID: #161343]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
	
	Param's Explanation:
 */
 
BEGIN
	;WITH cteUserLicenseeTypes
	AS (
		SELECT	TypeId
		FROM	dbo.UserLicenseeTypes WITH(NOLOCK)
		WHERE	UserId = @UserId
	)
	INSERT INTO @res (TypeId, TypeName)
	SELECT	l.TypeId, l.TypeName
	FROM	cteUserLicenseeTypes c
		INNER JOIN dbo.LicenseeTypes l WITH(NOLOCK)
			ON c.TypeId = l.TypeId
	
	RETURN
END

