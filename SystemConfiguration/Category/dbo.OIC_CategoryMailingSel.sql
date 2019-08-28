USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_CategoryMailingSel]
	@LicenseeId	INT = 0 
	,@SelectedLicensee VARCHAR(1000) = ''
AS
/*
	Created by: Kathy
	Date: 2015-02-04
	Task: Category mailing List [Redmine:#29607]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160818@Percy: Return new column: CategoryNameCN -- Chinese [RedmineID: #62642]
		- 20190822@Howard: Mark important email [RedmineId: #117684]
	Param's Explanation:
	* @SelectedLicensee: '' - All Licensee
*/
BEGIN
	SET NOCOUNT ON
	
	IF @LicenseeId = 0 AND @SelectedLicensee = ''
	BEGIN
		SELECT	@LicenseeId AS LicenseeId
				,c.CategoryId
				,c.CategoryName
				,c.CategoryNameCN
				,c.IsImportant
		FROM	dbo.Category c WITH(NOLOCK)
		
		RETURN
	
	END
	IF @LicenseeId <> 0
	BEGIN
		SELECT	@LicenseeId AS LicenseeId
				,c.CategoryId
				,c.CategoryName
				,c.CategoryNameCN
				,c.IsImportant
		FROM	dbo.Category c WITH(NOLOCK)
			INNER JOIN dbo.LicenseeCategoryAssigned l 
				ON	l.CategoryId = c.CategoryId
					AND l.LicenseeId = @LicenseeId
		RETURN
	END
	IF @SelectedLicensee <> ''
	BEGIN
		SELECT	l.LicenseeId
				,c.CategoryId
				,c.CategoryName
				,c.CategoryNameCN
				,c.IsImportant
		FROM	dbo.Category c WITH(NOLOCK)
			INNER JOIN dbo.LicenseeCategoryAssigned l 
				ON	l.CategoryId = c.CategoryId
		WHERE l.LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
		
		RETURN
	END
END
GO
GRANT EXECUTE ON [dbo].[OIC_CategoryMailingSel] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_CategoryMailingSel] TO [vnteam] AS [dbo]