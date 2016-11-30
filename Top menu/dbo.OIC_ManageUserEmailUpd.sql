USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ManageUserEmailUpd]
	@UserID					INT
	,@LicenseeTypeId_Email	XML
	,@Language				VARCHAR(10)	= 'E'
	,@IP					VARCHAR(50)	= NULL
	,@ErrCode				INT	= 0	OUTPUT
	,@ErrMsg				VARCHAR(300) = NULL OUTPUT
AS

/*
	Creator: Percy
	Date: 2016-08-04
	DB: DBOIC.bodb_OIC
	Task: Manage User Mail - Update

	Revisions:

	Param's Explanation:
		* @LicenseeTypeId_Email:
			<root>
				<row lti="1" em="percy.nguyen@starixsoft.com" />
				<row lti="2" em="muller.nguyen@starixsoft.com" />
				<row lti="3" em="anna.nguyen@starixsoft.com" />
			</root>
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

		,@log_email		XML

	DECLARE @tblLicenseeTypeEmail TABLE (LicenseeTypeId TINYINT, LicenseeTypeName VARCHAR(30), Email VARCHAR(50))

	SET @startRun = GETDATE()

	SET @log_email = (
		SELECT
			ult.LicenseeTypeId AS '@lti'
			,lt.LicenseeTypeName AS '@ltn'
			,ult.Email AS '@em'
		FROM
			dbo.UserLicenseeType ult WITH(NOLOCK)
			INNER JOIN dbo.LicenseeType lt WITH(NOLOCK) ON ult.LicenseeTypeId = lt.LicenseeTypeId
		WHERE ult.UserId = @UserID
		FOR XML PATH('row'), ROOT('ltm')
	)

	SET @xml = (SELECT @UserID AS '@uid', @log_email FOR XML PATH('r'), TYPE)		
		
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)

	IF @log_email IS NOT NULL
	BEGIN TRY
		INSERT INTO @tblLicenseeTypeEmail (LicenseeTypeId, Email)
		SELECT
			t.c.value('@lti', 'tinyint')
			,t.c.value('@em', 'varchar(50)')
		FROM @LicenseeTypeId_Email.nodes('root/row') t(c)

		MERGE dbo.UserLicenseeType u
		USING (SELECT * FROM @tblLicenseeTypeEmail) t
			ON u.LicenseeTypeId = t.LicenseeTypeId AND u.UserID = @UserID
		WHEN MATCHED AND u.Email <> t.Email THEN UPDATE SET u.Email = t.Email
		WHEN NOT MATCHED BY TARGET THEN INSERT (UserId, LicenseeTypeId, Email) VALUES (@UserId, t.LicenseeTypeId, t.Email)
		WHEN NOT MATCHED BY SOURCE AND u.UserId = @UserId THEN DELETE;

		IF @@ROWCOUNT = 0
		BEGIN
			SELECT
				@ErrCode = 100
				,@ErrMsg = dbo.f_Get_MsgNamebyMsgID(30026, @Language)
			RETURN
		END
	END TRY
	BEGIN CATCH
		SELECT
			@ErrCode = 101
			,@ErrMsg = dbo.f_Get_MsgNamebyMsgID(30027, @Language)
		RETURN
	END CATCH

	SET @log_email = (
		SELECT
			ult.LicenseeTypeId AS '@lti'
			,lt.LicenseeTypeName AS '@ltn'
			,ult.Email AS '@em'
		FROM
			dbo.UserLicenseeType ult WITH(NOLOCK)
			INNER JOIN dbo.LicenseeType lt WITH(NOLOCK) ON ult.LicenseeTypeId = lt.LicenseeTypeId
		WHERE ult.UserId = @UserID
		FOR XML PATH('row'), ROOT('ltm')
	)

	SET @xml = (SELECT @UserID AS '@uid', @log_email FOR XML PATH('r'), TYPE)		
		
	SELECT
		@logSPData	= CONVERT(NVARCHAR(MAX), @xml)
		,@endRun	= GETDATE()  
		,@duration	= DATEDIFF(MILLISECOND, @startRun, @endRun)   
		,@procName	= OBJECT_NAME(@@PROCID)
	
	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= @logSPOldData
		,@Duration		= @Duration
END
GO
GRANT EXECUTE ON [dbo].[OIC_ManageUserEmailUpd] TO [bodbAdminNet] AS [dbo]
GO
GRANT VIEW DEFINITION ON [dbo].[OIC_ManageUserEmailUpd] TO [vnteam] AS [dbo]
GO