ALTER PROCEDURE [dbo].[OIC_EmailNotificationRecipientSel] 
	@CategoryId				TINYINT
	,@SelectedLicensee		VARCHAR(MAX)
	,@UserId				INT
	
AS
/*
	Created by: Kathy
	Date: 20150825
	Task: get recipient list [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160226@Percy: Add field AddCC [Redmine: #52857]
	
	Param's Explanation:
	
	*
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @ToList			VARCHAR(MAX) = ''
			,@CcList		VARCHAR(MAX) = ''
			,@AddtoCcList	VARCHAR(MAX) = ''
			,@BccList		VARCHAR(MAX) = ''
			,@RowNumber		INT			 = 0
			,@seq			INT			 = 1
			,@LicenseeId	INT
			,@LicenseeName	NVARCHAR(50)
			
	DECLARE @tblResult TABLE (LicenseeId INT, LicenseeName NVARCHAR(50), ToList VARCHAR(MAX), CcList VARCHAR(MAX), AddtoCcList VARCHAR(MAX), BccList VARCHAR(MAX))
	DECLARE @tblLicensee TABLE (seq INT IDENTITY(1,1), LicenseeId INT, LicenseeName NVARCHAR(50))
	
	INSERT INTO @tblLicensee (LicenseeId, LicenseeName)
	SELECT	f.LicenseeId, f.LicenseeName
	FROM	dbo.f_LicenseeBelongToUser(@userId) f
		INNER JOIN dbo.LicenseeCategoryAssigned lc WITH(NOLOCK)
			ON f.LicenseeId = lc.LicenseeId
	WHERE	lc.CategoryId = @CategoryId
			AND f.LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
	GROUP BY f.LicenseeId, f.LicenseeName
	
	SET @RowNumber = @@rowcount
	
	WHILE @seq <=@RowNumber
	BEGIN
		SELECT	@LicenseeId = LicenseeId
				,@LicenseeName = LicenseeName
		FROM	@tblLicensee
		WHERE	seq = @seq
		
		SELECT	@ToList = CASE WHEN RecipientType = 0 THEN @ToList + ISNULL(Email,'') + ';' ELSE @ToList END
				,@CcList = CASE WHEN RecipientType = 1 THEN @CcList + ISNULL(Email,'') + ';' ELSE @CcList END
				,@AddtoCcList = CASE WHEN RecipientType = 2 THEN @AddtoCcList + ISNULL(Email,'') + ';' ELSE @AddtoCcList END
				,@BccList = CASE WHEN RecipientType = 3 THEN @BccList + ISNULL(Email,'') + ';' ELSE @BccList END
		FROM	dbo.f_RecipientList (CAST(@LicenseeId AS VARCHAR(10)), @CategoryId, @UserId)
		WHERE ISNULL(Email,'') <> ''
	
		INSERT INTO @tblResult (LicenseeId, LicenseeName, ToList, CcList, AddtoCcList, BccList)
		SELECT	@LicenseeId
				,@LicenseeName
				,CASE WHEN ISNULL(@ToList,'') = '' THEN '' ELSE LEFT(@ToList,LEN(@ToList) - 1) END
				,CASE WHEN ISNULL(@CcList,'') = '' THEN '' ELSE LEFT(@CcList,LEN(@CcList) - 1) END
				,CASE WHEN ISNULL(@AddtoCcList,'') = '' THEN '' ELSE LEFT(@AddtoCcList,LEN(@AddtoCcList) - 1) END
				,CASE WHEN ISNULL(@BccList,'') = '' THEN '' ELSE LEFT(@BccList,LEN(@BccList) - 1) END
				
		SELECT	@seq = @seq + 1
				,@ToList =''
				,@CcList =''
				,@AddtoCcList =''
				,@BccList = ''
	END
	
	SELECT	LicenseeId
			,LicenseeName
			,ToList
			,AddtoCcList
			,CcList
			,BccList
	FROM	@tblResult

END




GO

GRANT EXECUTE ON [dbo].[OIC_EmailNotificationRecipientSel] TO [bodbAdminNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[OIC_EmailNotificationRecipientSel] TO [vnteam] AS [dbo]
GO