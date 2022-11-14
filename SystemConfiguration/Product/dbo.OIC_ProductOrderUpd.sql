/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_ProductOrderUpd]
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
		- 20221107@Cody: Init SP [RedmineId: #171988]
		
	Param's Explanation:
	* @ProductId: Original ProductId
	* @ProductIdForSwap: ProductId selected to swap the order with the original product
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
		DECLARE @Order 					SMALLINT
				,@OrderForSwap 			SMALLINT
				,@ProductTypeId 		TINYINT
				,@ProductTypeIdForSwap 	TINYINT
		
		SELECT @Order = [Order], @ProductTypeId = ProductTypeId FROM dbo.Product WITH(NOLOCK) WHERE ProductId = @ProductId
		SELECT @OrderForSwap = [Order], @ProductTypeIdForSwap = ProductTypeId FROM dbo.Product WITH(NOLOCK) WHERE ProductId = @ProductIdForSwap
		
		IF @Order IS NULL OR @OrderForSwap IS NULL OR (@ProductTypeId <> @ProductTypeIdForSwap)
			BEGIN
				SELECT @ErrCode = 101
						,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30030, @Language) -- Fail to change client product order. Please try again.
				RETURN
			END
		
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