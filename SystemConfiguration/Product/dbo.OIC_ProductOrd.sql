USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_ProductOrd]    Script Date: 11/7/2022 4:52:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[OIC_ProductOrd]
	@ProductId				TINYINT
	,@ProductIdForSwap		TINYINT
	,@UserId				INT
	,@IP					VARCHAR(50)		= NULL
	,@Language				VARCHAR(10)		= 'E'
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Cody
	Date: 20221107
	Task: Support to order Client product[RedmineId: #171988]
	DB: DBOIC.bodb_OIC

	Revisions:
		- 20221107@Cody: Init SP [RedmindId: #171988]
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

	SET @startRun = GETDATE()
	
	SET @xml = (
		SELECT	ProductId		AS '@pi'
				,ProductName	AS '@pn'
				,[Order]		AS '@od'
		FROM	dbo.Product WITH(NOLOCK)
		WHERE	ProductId IN (@ProductId, @ProductIdForSwap)
		FOR XML PATH('row'), ROOT('r')
		)
	
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)
	
	-- Change order
	BEGIN TRY
		DECLARE @Order INT, @OrderForSwap INT
		
		SET @Order = (SELECT [Order] FROM dbo.Product WITH(NOLOCK) WHERE ProductId = @ProductId)
		SET @OrderForSwap = (SELECT [Order] FROM dbo.Product WITH(NOLOCK) WHERE ProductId = @ProductIdForSwap)
		
		UPDATE	dbo.Product WITH(ROWLOCK, UPDLOCK)
			SET	[Order] = CASE 
							WHEN ProductId = @ProductId 
							THEN @OrderForSwap 
							ELSE @Order 
						  END
			WHERE ProductId IN (@ProductId, @ProductIdForSwap)
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30030, @Language) -- Fail to change client product order. Please try again.
		RETURN
	END CATCH
	
	SET @xml = (
		SELECT	ProductId		AS '@pi'
				,ProductName	AS '@pn'
				,[Order]		AS '@od'
		FROM	dbo.Product WITH(NOLOCK)
		WHERE	ProductId IN (@ProductId, @ProductIdForSwap)
		FOR XML PATH('row'), ROOT('r')
		)
		
	SELECT @logSPData = CONVERT(NVARCHAR(MAX),@xml)
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