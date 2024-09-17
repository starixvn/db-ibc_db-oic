/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AutoMailIns]
    @GroupId			TINYINT
	,@TypeId			TINYINT
	,@LicenseeTypeId	TINYINT
    ,@ToList			NVARCHAR(MAX)	= ''
	,@CcList			NVARCHAR(MAX)	= ''

	,@UserId			INT
	,@Language			VARCHAR(10)		= 'E'
	,@IP				VARCHAR(50)		= NULL
    ,@ErrCode      	 	INT				= 0	        OUTPUT
    ,@ErrMsg			NVARCHAR(MAX)	= NULL		OUTPUT
	,@ExistingToList	NVARCHAR(MAX)	= NULL		OUTPUT
	,@ExistingCcList	NVARCHAR(MAX)	= NULL		OUTPUT
AS

/*
	Created by: Cody
	Date: 2024-08-27
	Task: Manage recipient list of auto mails [RedmineId: #209253]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20240827@Cody: Init [RedmineId: #209253]

*/

BEGIN
	SET NOCOUNT ON;
	
	-- For write log
	DECLARE 
		@startRun		DATETIME
		,@endRun		DATETIME
		,@duration		INT
		,@logSPData		NVARCHAR(MAX)
		,@xml			XML
		,@procName		VARCHAR(200)

	SET @startRun = GETDATE()

    DECLARE @tblMailList TABLE (Email NVARCHAR(50), RecipientType TINYINT)

	INSERT INTO @tblMailList(Email, RecipientType)
	SELECT  CONVERT(NVARCHAR(50), val), 0
	FROM dbo.strSplit(@ToList, ',') WHERE @ToList <> ''
	UNION ALL
	SELECT	CONVERT(NVARCHAR(50), val), 1
	FROM dbo.strSplit(@CcList, ',') WHERE @CcList <> ''

	-- In case both To List and CC List text are empty 
	IF @ToList = '' AND @CcList = ''
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = 'TO List or CC List is required'
		
		RETURN
	END

    -- In case the email already exists in the database	
	DECLARE @tblExistingMails TABLE(RecipientType TINYINT, Email NVARCHAR(50))

	INSERT INTO @tblExistingMails (RecipientType, Email)
	SELECT DISTINCT ml.RecipientType, ml.Email
	FROM dbo.AutoMail a WITH(NOLOCK)
		INNER JOIN @tblMailList ml
			ON a.Email = ml.Email
				AND a.IsTest = 0
				AND a.GroupId = @GroupId 
				AND a.TypeId = @TypeId
				AND a.LicenseeTypeId = @LicenseeTypeId

	IF EXISTS (SELECT TOP(1) 1 FROM @tblExistingMails)
	BEGIN
		SET @ExistingToList = STUFF
									(
										(SELECT ', ' + Email
											FROM @tblExistingMails
											WHERE RecipientType = 0
											FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1, 2, ''
									)
		SET @ExistingCcList = STUFF
									(
										(SELECT ', ' + Email
											FROM @tblExistingMails
											WHERE RecipientType = 1
											FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1, 2, ''
									)

		SELECT  @ErrCode = 101
				,@ExistingToList = ISNULL(@ExistingToList, '')
				,@ExistingCcList = ISNULL(@ExistingCcList, '')
		
		RETURN
	END
	
	-- Insert data
	BEGIN TRY
		INSERT INTO dbo.AutoMail (Email, RecipientType, IsTest, GroupId, TypeId, LicenseeTypeId)
		SELECT Email, RecipientType, 0, @GroupId, @TypeId, @LicenseeTypeId
		FROM @tblMailList
	END TRY
	BEGIN CATCH
		SELECT	@ErrCode = 102
				,@ErrMsg = 'Failed to add new emails. Please try again!'
		
		RETURN
	END CATCH
	
	-- Write log
	DECLARE @AutoMailTypeName		NVARCHAR(50)
			,@LicenseeTypeName		NVARCHAR(50)
			,@RecipientGroupName	NVARCHAR(50)
	
	SELECT @AutoMailTypeName = TypeName FROM dbo.AutoMailType WITH(NOLOCK) WHERE TypeId = @TypeId
	SELECT @RecipientGroupName = GroupName FROM dbo.AutoMailGroup WITH(NOLOCK) WHERE GroupId = @GroupId
	SELECT @LicenseeTypeName = TypeName FROM dbo.LicenseeTypes WITH(NOLOCK) WHERE TypeId = @LicenseeTypeId
	
	SET @xml = (
			SELECT	@AutoMailTypeName			AS '@atn'
					,@LicenseeTypeName			AS '@ltn'
					,@RecipientGroupName		AS '@rgn'
					,(
						SELECT	Email			AS '@m'
								,RecipientType	AS '@rt'
						FROM @tblMailList ml
						ORDER BY RecipientType
						FOR XML PATH('row'), TYPE, ROOT('ar')
					)
			FOR XML PATH('r')
	)
	
	SELECT	@logSPData	= CONVERT(NVARCHAR(MAX), @xml)
			,@endRun	= GETDATE()
			,@duration 	= DATEDIFF(MILLISECOND, @startRun, @endRun)
			,@procName 	= OBJECT_NAME(@@PROCID)
			
	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @UserId
		,@SPName		= @procName
		,@Language		= @Language
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration
END
GO