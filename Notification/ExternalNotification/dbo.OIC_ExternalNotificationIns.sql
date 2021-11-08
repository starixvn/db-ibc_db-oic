/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ExternalNotificationIns] 
	@MessageTypeId			TINYINT
	,@SelectedLicensee		VARCHAR(MAX)	= 'All'
	,@SubjectEn				NVARCHAR(300)	= ''
	,@SubjectCh				NVARCHAR(300)	= ''
	,@SubjectCs				NVARCHAR(300)	
	,@ContentEn				NVARCHAR(MAX)  = ''
	,@ContentCh				NVARCHAR(MAX)  = ''	
	,@ContentCs				NVARCHAR(MAX)  
	
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 20150825
	Task: Insert external notification [Redmine:#40305]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20170302@Percy: Expand length of Content [RedmineID: #70322]
		- 20180914@Scofield: Change content display orders of the languages [#100984]
		- 20211122@Kai: Enhancement of Type of Licensee [#163521]
	
	Param's Explanation:
		@MessageTypeId: 40: public
						41: special
						42: personal
						43: match delay - new
						44: match delay - done
						
	
	*
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun		DATETIME
			,@endRun		DATETIME
			,@duration		INT
			,@logSPData		NVARCHAR(MAX)
			,@xml			XML
			,@procName		VARCHAR(200)
			,@MessageId		INT
			,@IsTesting		BIT = 0	
			,@log_Licensee	VARCHAR(MAX) = ''
			
	DECLARE @tblLicensee TABLE (LicenseeId INT)
	
	SET @startRun = GETDATE()
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.UserInfo WITH(NOLOCK) WHERE DisplayName LIKE 'starix%' AND UserId = @UserId)
		SET @IsTesting = 1
	 
	BEGIN TRY
		INSERT INTO dbo.Message 
		(
				ContentEn
				,ContentCh
				,ContentCs
				,MessageTypeId
				,Creator
				,CreateTime
				,SubjectEn
				,SubjectCh
				,SubjectCs
		)
		SELECT	@ContentEn
				,@ContentCh
				,@ContentCs
				,@MessageTypeId
				,@UserId
				,GETDATE()
				,@SubjectEn
				,@SubjectCh
				,@SubjectCs
		
		SET @MessageId = SCOPE_IDENTITY()
		
		IF @MessageTypeId IN (40, 41) -- exlude personal, match delay (42, 43,44)
		BEGIN
			-- send to ALL licensee
			INSERT INTO dbo.LicenseeMessage (LicenseeId, MessageId)
			SELECT	LicenseeId, @MessageId
			FROM	dbo.Licensee WITH(NOLOCK)
			
			-- for log
			SELECT	@log_Licensee = @log_Licensee + CAST(LicenseeId AS VARCHAR(10)) + ','
			FROM	dbo.f_LicenseeBelongToUser(@UserId) 
			
			IF @IsTesting = 0 -- just insert msg into MessageLicenseeType for real user
				INSERT INTO dbo.MessageLicenseeType (MessageId, TypeId, PositionId)
				SELECT	@MessageId, TypeId, 0
				FROM	dbo.Licensee WITH(NOLOCK)
				GROUP BY TypeId
		END
		IF @MessageTypeId IN(42, 43,44) -- Personal,  match delay
		BEGIN
			INSERT INTO dbo.LicenseeMessage (LicenseeId, MessageId)
			SELECT	LicenseeId, @MessageId
			FROM	dbo.f_LicenseeBelongToUser(@UserId)
			WHERE	LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
			
			-- for log
			SELECT @log_Licensee = @SelectedLicensee
			
			IF @IsTesting = 0  -- just insert msg into MessageLicenseeType for real user
				INSERT INTO dbo.MessageLicenseeType (MessageId, TypeId, PositionId)
				SELECT	@MessageId, TypeId, 0
				FROM	dbo.f_LicenseeBelongToUser(@UserId)
				WHERE	LicenseeId IN (SELECT val FROM dbo.strSplit(@SelectedLicensee,','))
				GROUP BY TypeId
		END				
	END TRY
	BEGIN CATCH
			DELETE FROM dbo.MessageLicenseeType WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			DELETE FROM dbo.LicenseeMessage WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			DELETE FROM dbo.Message WITH(ROWLOCK, UPDLOCK)
			WHERE MessageId = @MessageId
			
			SELECT	@Errcode = 100
					,@ErrMsg = dbo.f_Get_MsgNamebyMsgID(40000,@Language)
			
			RETURN
	END CATCH
	
	-- write log
		
	SET @xml = (
		SELECT	@MessageTypeId		AS '@mid'
				,@log_Licensee		AS '@lt'			
		FOR XML PATH('r'), TYPE
		)		
				
	SELECT	@logSPData		= CONVERT(NVARCHAR(MAX),@xml)
			,@endRun		= GETDATE()  
			,@duration		= DATEDIFF(millisecond, @startRun, @endRun)   
			,@procName		= OBJECT_NAME(@@procid)

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