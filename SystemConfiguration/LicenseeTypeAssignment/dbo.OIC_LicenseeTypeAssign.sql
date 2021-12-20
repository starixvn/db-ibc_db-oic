/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[OIC_LicenseeTypeAssign]
	@updUserId				INT
	,@SelectedLicenseeType	VARCHAR(500)
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS

/*
	Created by: Kathy
	Date: 20151006
	Task: assign licensee type to user  [Redmine:#44257]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160805@Percy: Add column Email of LicenseeType [RedmineID: #61904]
		- 20211810@Hogan: Extend length of LicenseeType [RedmineID: #163376]
		- 20211116@Alex: Change Type Of Licensee [RedmineID: #163521]
*/

BEGIN
	SET NOCOUNT ON
			
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@logSPOlddata	NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)
		,@isNewUser		BIT = 0
		,@username		NVARCHAR(50)
		,@newDisplayName NVARCHAR(50)
		,@errLicenseeType NVARCHAR(300) = ''

	DECLARE @tblLicenseeType TABLE (TypeId TINYINT)
	
	SET @startRun = GETDATE()
	
	INSERT INTO @tblLicenseeType (TypeId)
	SELECT val FROM dbo.strSplit (@SelectedLicenseeType,',')
	
	SELECT @errLicenseeType = ISNULL (@errLicenseeType, '' ) + lt.TypeName + ','
	FROM	dbo.UserLicensee ul WITH(NOLOCK)
		INNER JOIN dbo.Licensee l WITH(NOLOCK)
			ON l.LicenseeId = ul.LicenseeId
		INNER JOIN dbo.LicenseeTypes lt WITH(NOLOCK)
			ON lt.TypeId = l.TypeId
	WHERE	ul.UserId = @updUserId
			AND l.TypeId NOT IN (SELECT TypeId FROM @tblLicenseeType)
	GROUP BY l.TypeId, lt.TypeName
	
	-- If the user is AM or PM, check if there is any client assigned to him.
	IF @errLicenseeType <> ''
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30024, @Language) + SUBSTRING(@errLicenseeType, 0, LEN(@errLicenseeType))  -- Fail to edit user's Type of Licensee. The user is currently the AM/PM of one or many client(s) of:
		RETURN
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = @updUserId)
	BEGIN
		SELECT	@newDisplayName = username
		FROM	bodb02.dbo.custInfo WITH(NOLOCK) 
		WHERE	custid = @updUserId 
				AND roleid >= 5
		
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT	@ErrCode = 101
					,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30021, @Language) -- User does not exist
			RETURN
		END
		
		SET @isNewUser = 1
		
		IF EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName = @newDisplayName)
		BEGIN
			DECLARE @seq INT = 1
			WHILE(1 = 1)
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName = @newDisplayName +' (' + CAST(@seq AS VARCHAR(10)) +')') 
				BEGIN
					SET @newDisplayName = @newDisplayName +' (' + CAST(@seq AS VARCHAR(10)) +')' 
					
					BREAK
				END
				
				SET @seq = @seq + 1
			END
		END
	END
	
	SET @xml = (SELECT @updUserId AS '@uid',
						(SELECT lt.TypeId		AS '@lti'
								,lt.TypeName	AS '@ltn'
						FROM	UserLicenseeTypes ult WITH(NOLOCK)
							INNER JOIN dbo.LicenseeTypes lt WITH (NOLOCK) ON ult.TypeId = lt.TypeId
						WHERE	UserId = @updUserId
						FOR XML PATH('row'), ROOT('lt'), TYPE
						)
				FOR XML PATH('r'), TYPE
				)
	
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)
	
	BEGIN TRY
		IF @isNewUser = 1
		BEGIN
			INSERT INTO dbo.UserInfo (UserId, DisplayName) VALUES (@updUserId, @newDisplayName)
		END

		DECLARE @Email VARCHAR(50)
		SELECT  @Email = Email FROM dbo.UserInfo WITH(NOLOCK) WHERE UserId = @updUserId
		
		MERGE dbo.UserLicenseeTypes AS ult
		USING (SELECT TypeId FROM @tblLicenseeType) AS t
		ON (ult.TypeId = t.TypeId)
			AND ult.UserId = @updUserId
		WHEN NOT MATCHED BY TARGET THEN INSERT (UserId, TypeId, Email) VALUES (@updUserId, t.TypeId, @Email)
		WHEN NOT MATCHED BY SOURCE AND ult.UserId = @updUserId THEN DELETE;		
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30025,@Language) + ERROR_MESSAGE() -- Fail to edit user's Type of Licensee. Please try again.
		
		RETURN
	END CATCH
	
	SET @xml = (SELECT @updUserId AS '@uid',
						(SELECT lt.TypeId		AS '@lti'
								,lt.TypeName	AS '@ltn'
						FROM	UserLicenseeTypes ult WITH(NOLOCK)
							INNER JOIN dbo.LicenseeTypes lt WITH (NOLOCK) ON ult.TypeId = lt.TypeId
						WHERE	UserId = @updUserId
						FOR XML PATH('row'), ROOT('lt'), TYPE
						)
				FOR XML PATH('r'), TYPE
				)
	
	SELECT @logSPData = CONVERT(NVARCHAR(MAX), @xml)
		,@endRun	= GETDATE()  
		,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
		,@procName	= OBJECT_NAME(@@PROCID)

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= @logSPOlddata
		,@Duration		= @Duration	
END
GO