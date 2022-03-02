/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_LicenseeContactListSel]
    @UserId        INT
    ,@LicenseeName NVARCHAR(50)
    ,@ContactName  NVARCHAR(50)    = ''
    
    ,@PageSize			INT = 10
	,@PageIndex			INT	= 0 
	,@TotalRecords		INT = 0 OUTPUT
AS
/*
    Created by: Kathy
    Date: 2015-02-04
    Task: Licensee contact list [Redmine:#29610]
    DB: DBOIC/BODB_OIC 
    
    Revisions:
		- 20160920@Percy: Add new return field: Change History [RedmineID: #]
		- 20211109@Alex: Change Type Of Licensee [RedmindId: #163521]
		- 20220117@Kai/Howard: New Licensee Contact function [Redmine:#165286]
							   - Kai: Add Licensee Contact field
							   - Howard: Support DoneBy from LAP 

    Param's Explanation:
*/
BEGIN
    SET NOCOUNT ON
    
    DECLARE @tblContactList TABLE(ContactId INT)
    DECLARE @ToList		VARCHAR(1000)
			,@CcList	VARCHAR(1000)
			,@RowCount	INT	
			,@RowStart	INT
			,@RowEnd	INT
    
    INSERT INTO @tblContactList(ContactId)
    SELECT	c.ContactID    
    FROM	dbo.Contact c WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK) 
			ON	c.LicenseeID = l.LicenseeId
    WHERE	l.TypeId IN (SELECT		u.TypeId 
									FROM	dbo.UserLicenseeTypes u WITH(NOLOCK) 
									WHERE	u.UserId = @UserId)
			AND l.LicenseeName = @LicenseeName
			AND c.ContactName LIKE @ContactName + '%'    
    
    -- General info
    SELECT ROW_NUMBER() OVER (ORDER BY lc.IsMain DESC, lc.ContactName) AS RowNumber
			,lc.ContactID
			,lc.ContactName
			,lc.IsLicenseeContact
			,lc.ContactType 
			,lc.ContactPosition		AS Position
			,lc.ContactDepartment	AS Department
			,lc.ContactPhoneNumber	AS PhoneNumber
			,lc.ContactEmail		AS Email
			,lc.ContactSkype		AS Skype
			,lc.ContactLandline		AS Landline
			,lc.Remark
			,(SELECT ISNULL(@ToList,'') + c.CategoryName + ','  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category c WITH(NOLOCK) 
						ON c.CategoryId = cc.CategoryID
				WHERE cc.ContactID = lc.ContactID 
						AND cc.RecipientType = 0 
				FOR XML PATH('')
			  ) AS ToList
			,(SELECT ISNULL(@CcList,'') + c.CategoryName + ','  
				FROM dbo.CategoryContact cc WITH(NOLOCK)
					INNER JOIN dbo.Category c WITH(NOLOCK) 
						ON c.CategoryId = cc.CategoryID
				WHERE cc.ContactID = lc.ContactID 
						AND cc.RecipientType = 1
			   FOR XML PATH('')
			  ) AS CcList
			 ,lc.IsMain
    INTO	#tblResult
    FROM	dbo.Contact lc WITH(NOLOCK)
    WHERE	lc.ContactID IN (SELECT ContactID FROM @tblContactList)
    
	SELECT @PageIndex	= @PageIndex ,
		@RowStart		= @PageSize * @PageIndex + 1
		,@RowEnd		= @RowStart + @PageSize - 1
	
	IF @TotalRecords = 0
	BEGIN
		SELECT	@TotalRecords	= COUNT(1)
		FROM	#tblResult
	END

	-- Get log latest update contact --
	DECLARE @LogActionId_Ins INT, @LogActionId_Upd INT

	SELECT  @LogActionId_Ins = LogActionId FROM dbo.LogAction WITH(NOLOCK) WHERE SPName = 'OIC_LicenseeContactIns'
	SELECT  @LogActionId_Upd = LogActionId FROM dbo.LogAction WITH(NOLOCK) WHERE SPName = 'OIC_LicenseeContactUpd'

	CREATE TABLE #LogContact (Id BIGINT PRIMARY KEY, LogActionId INT, UserId INT, ExtraInfo NVARCHAR(100), LogDate DATETIME, ContactId INT)
	INSERT INTO  #LogContact (Id, LogActionId, UserId, ExtraInfo, LogDate, ContactId)
	SELECT
		A.Id, A.LogActionId, A.UserId, A.ExtraInfo, CONVERT(DATE, A.LogDate) AS LogDate,
		d.c.value('@lcid','INT') AS ContactId -- ContactId
	FROM (
		SELECT u.Id, u.LogActionId, u.UserId, u.ExtraInfo, u.LogDate, CONVERT(XML, ud.Data) AS Data
		FROM dbo.UserLog_RunSP u WITH(NOLOCK)
			INNER JOIN dbo.UserLog_RunSP_Detail ud WITH(NOLOCK) ON u.Id = ud.Id
		WHERE u.LogActionId IN (@LogActionId_Ins, @LogActionId_Upd)
	) AS A
	CROSS APPLY A.Data.nodes('r') d(c)
	-- End get log --

	CREATE NONCLUSTERED INDEX IX_ContactId ON #LogContact (ContactId, LogActionId)

	;WITH CTE_Update AS (
		SELECT  
		A.LogDate, A.ContactId,
		CASE
			WHEN A.UserId = -1 THEN A.ExtraInfo
			ELSE u1.DisplayName
		END AS DisplayName
		FROM (
			SELECT ROW_NUMBER() OVER(PARTITION BY ContactId ORDER BY Id DESC) AS RowNumber
					, UserId, ExtraInfo, LogDate, ContactId
			FROM #LogContact
			WHERE LogActionId = @LogActionId_Upd
		) A
		LEFT JOIN dbo.UserInfo u1 WITH(NOLOCK) ON A.UserId = u1.UserId
		WHERE A.RowNumber = 1
	), CTE_Create AS (
		SELECT B.LogDate, B.ContactId,
		CASE
			WHEN B.UserId = -1 THEN B.ExtraInfo
			ELSE u2.DisplayName
		END AS DisplayName
		FROM (
			SELECT ROW_NUMBER() OVER(PARTITION BY ContactId ORDER BY Id DESC) AS RowNumber
					, UserId, ExtraInfo, LogDate, ContactId
			FROM #LogContact
			WHERE LogActionId = @LogActionId_Ins
		) B
		LEFT JOIN dbo.UserInfo u2 WITH(NOLOCK) ON B.UserId = u2.UserId
		WHERE B.RowNumber = 1
	)
	
	SELECT	r.ContactID
			,ContactName
			,r.IsLicenseeContact
			,ContactType
			,Position
			,Department
			,PhoneNumber
			,Email
			,Skype
			,Landline
			,Remark
			,ToList
			,CcList
			,IsMain
			,CONVERT(VARCHAR(10), c.LogDate, 101) AS CreatedDate
			,CONVERT(VARCHAR(10), u.LogDate, 101) AS UpdatedDate
			,ISNULL(u.DisplayName, c.DisplayName) AS [By]
	FROM	#tblResult r
		LEFT JOIN CTE_Update u ON r.ContactID = u.ContactId
		LEFT JOIN CTE_Create c ON r.ContactID = c.ContactId
	WHERE	RowNumber BETWEEN @RowStart AND @RowEnd
    
	DROP TABLE #tblResult
	DROP TABLE #LogContact
END
GO