/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AutoMailUpd]
	@GroupId			TINYINT
	,@TypeId			TINYINT
	,@LicenseeTypeId	TINYINT
	,@SelectedTo	VARCHAR(500)	= ''
	,@SelectedCc	VARCHAR(500)	= ''
	
	,@UserId		INT
    ,@Language		VARCHAR(10)		= 'E'
	,@IP			VARCHAR(50)		= NULL
	,@ErrCode		INT				= 0			OUTPUT
	,@ErrMsg		VARCHAR(300)	= NULL		OUTPUT
AS

/*
	Created by: Cody
	Date: 2024-09-04
	Task: Manage recipient list of auto mails [RedmineId: #209253]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20240904@Cody: Init [RedmineId: #209253]

*/

BEGIN
	SET NOCOUNT ON;

    -- For write log
	DECLARE 
		@startRun				DATETIME
		,@endRun				DATETIME
		,@duration				INT
		,@logSPData				NVARCHAR(MAX)
		,@logSPOlddata			NVARCHAR(MAX)	
		,@xml					XML
		,@procName				VARCHAR(200)
		,@AutoMailTypeName		NVARCHAR(50)
		,@LicenseeTypeName		NVARCHAR(50)
		,@RecipientGroupName	NVARCHAR(50)
	
	SET @startRun = GETDATE()
	
	SELECT @AutoMailTypeName = TypeName FROM dbo.AutoMailType WITH(NOLOCK) WHERE TypeId = @TypeId
	SELECT @RecipientGroupName = GroupName FROM dbo.AutoMailGroup WITH(NOLOCK) WHERE GroupId = @GroupId
	SELECT @LicenseeTypeName = TypeName FROM dbo.LicenseeTypes WITH(NOLOCK) WHERE TypeId = @LicenseeTypeId
	
	DECLARE @tblToCcList TABLE(EmailId INT, RecipientType TINYINT)
	
	INSERT INTO @tblToCcList (EmailId, RecipientType)
	SELECT CONVERT(INT, val), 0
	FROM dbo.strSplit(@SelectedTo, ',') WHERE @SelectedTo <> ''
	UNION ALL
	SELECT CONVERT(INT, val), 1
	FROM dbo.strSplit(@SelectedCc, ',') WHERE @SelectedCc <> ''
	
	-- In case of updating all emails to Cc
	DECLARE @tblExceptedMail TABLE(Id INT)
	
	INSERT INTO @tblExceptedMail
	SELECT Id FROM dbo.AutoMail WITH(NOLOCK) WHERE RecipientType = 0 AND IsTest = 0 AND GroupId = @GroupId AND TypeId = @TypeId AND LicenseeTypeId = @LicenseeTypeId
	EXCEPT 
	SELECT EmailId FROM @tblToCcList WHERE RecipientType = 1
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM @tblExceptedMail) AND (@SelectedTo = '' OR @SelectedTo IS NULL)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = 'Cannot Delete! TO List must contain at least 1 email!'
		RETURN
	END
	
	-- Get data before update
	SET @xml = (
			SELECT	@AutoMailTypeName			AS '@atn'
					,@LicenseeTypeName			AS '@ltn'
					,@RecipientGroupName		AS '@rgn'
					,(
						SELECT	a.Email			AS '@m'
								,a.RecipientType	AS '@rt'
						FROM dbo.AutoMail a WITH(NOLOCK)
							INNER JOIN @tblToCcList tc
								ON tc.EmailId = a.Id
						ORDER BY a.Id
						FOR XML PATH('row'), TYPE, ROOT('ar')
					)
			FOR XML PATH('r')
	)
	
	SELECT @logSPOldData = CONVERT(NVARCHAR(MAX), @xml)
	
	-- Update data
	BEGIN TRY
		UPDATE dbo.AutoMail WITH(ROWLOCK, UPDLOCK)
		SET RecipientType = tc.RecipientType
		FROM dbo.AutoMail AS a
			INNER JOIN @tblToCcList AS tc
				ON a.Id = tc.EmailId
		WHERE a.RecipientType <> tc.RecipientType
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 101
				,@ErrMsg = 'Failed to update recipient emails. Please try again!'
		
		RETURN
	END CATCH
	
	-- Write log
	SET @xml = (
			SELECT	@AutoMailTypeName			AS '@atn'
					,@LicenseeTypeName			AS '@ltn'
					,@RecipientGroupName		AS '@rgn'
					,(
						SELECT	a.Email			AS '@m'
								,a.RecipientType	AS '@rt'
						FROM dbo.AutoMail a WITH(NOLOCK)
							INNER JOIN @tblToCcList tc
								ON tc.EmailId = a.Id
						ORDER BY a.Id
						FOR XML PATH('row'), TYPE, ROOT('ar')
					)
			FOR XML PATH('r')
	)
	
	SELECT	@logSPData = CONVERT(NVARCHAR(MAX), @xml)
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
		,@Duration		= @duration
END
GO