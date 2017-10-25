USE [bodb_OIC]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OIC_APIAmendmentMessageUserIns]
	@TicketID			INT,
	@UserId			INT,
	@LicenseeName		VARCHAR(300),
	@IP				VARCHAR(50)	= NULL,
	@ErrCode			INT			= 0			OUTPUT,
	@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Scofield
	Date: 20171023 [#84004]
	DB: DBOIC.bodb_OIC

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
		INSERT INTO dbo.AmendmentMessageUser (TicketID, UserID, LicenseeName, IsRead, UpdatedDate)
		VALUES (@TicketID, @UserId, @LicenseeName, 1, GETDATE())
	END TRY
	BEGIN CATCH	
		SELECT	@Errcode = 100,
				@ErrMsg = dbo.f_Get_MsgNamebyMsgID (40004, 'E')
		RETURN
	END CATCH
	
	-- write log
	SET @xml = (
			 SELECT	@TicketID			AS '@tid',
					   @UserId		AS '@uid',
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

GRANT EXECUTE ON [dbo].[OIC_APIAmendmentMessageUserIns] TO [bodbAdminNet] AS [dbo]
GO

GRANT VIEW DEFINITION ON [dbo].[OIC_APIAmendmentMessageUserIns] TO [vnteam] AS [dbo]
GO