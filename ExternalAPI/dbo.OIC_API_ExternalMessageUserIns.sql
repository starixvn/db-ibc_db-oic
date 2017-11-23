/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

CREATE PROCEDURE [dbo].[OIC_API_OIC_API_ExternalMessageUserIns]
	@MessageID			INT,
	@MessageType			INT,
	@UserName			VARCHAR(100),
	@LicenseeName		VARCHAR(100),
	@IP				VARCHAR(50)	= NULL,
	@ErrCode			INT			= 0			OUTPUT,
	@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Scofield
	Date: 20171023 [#84004]
	DB: DBOIC.bodb_OIC
	
	Revisions:	
		- 20171030@Scofield: #84004 - Implement Deliver notification to licensee backend

	Param's Explanation:
 */
BEGIN
	SET NOCOUNT ON
	DECLARE @startRun		DATETIME,
			@endRun		DATETIME,
			@duration		INT,
			@logSPData	NVARCHAR(MAX),
			@xml			XML,
			@procName		VARCHAR(200)	

    SET @startRun = GETDATE()	
	
	BEGIN TRY	
		INSERT INTO dbo.ExternalMessageUser (MessageID, MessageType, UserName, LicenseeName, IsRead, UpdatedDate)
		VALUES (@MessageID, @MessageType, @UserName, @LicenseeName, 1, GETDATE())
	END TRY
	BEGIN CATCH	
		SELECT	@Errcode = 100,
				@ErrMsg = dbo.f_Get_MsgNamebyMsgID (40004, 'E')
		RETURN
	END CATCH
	
	-- write log
	SET @xml = (
			 SELECT	@MessageID			AS '@mid',
					@MessageType		AS '@mty',
					   @UserName		AS '@una',
					   @LicenseeName	AS '@lin'
			 FOR XML PATH('r'), TYPE)		
		
	SELECT @logSPData	= CONVERT(NVARCHAR(MAX),@xml)
		,@endRun		= GETDATE()  
		,@duration	= DATEDIFF(millisecond, @startRun, @endRun)   
		,@procName	= OBJECT_NAME(@@procid)

	EXEC dbo.OIC_LogRunSpIns
		@UserId		= @UserId
		,@SPName		= @procName
		,@Language	= 'E'
		,@IP			= @IP
		,@Data		= @logSPData
		,@OldData		= Null
		,@Duration	= @duration
	
END
GO

