/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ProductUpd]
	@ProductTypeId			TINYINT
	,@MainProductId			TINYINT			= NULL
	,@ProductId				TINYINT
	,@ProductName			VARCHAR(50)
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 201501001
	Task: update product [Redmine:#44255]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20160513@Percy: Add field Order into Product table [RedmineID: #56935]
		- 20211004@Alex: Support Product Type on Client Product [RedmineID: #161508]
		- 20221104@Cody: Support to order Client product [RedmineID: #171988]
		
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
	
	IF EXISTS (SELECT TOP 1 1 FROM dbo.Product WITH(NOLOCK) WHERE ProductName = @ProductName AND ProductTypeId = @ProductTypeId AND MainProductId = @MainProductId)
	BEGIN
		SELECT	@ErrCode = 100
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30006, @Language) -- The product name is already used. Please try another name.
		RETURN
	END		
	
	SET @xml = (
		SELECT	ProductId		AS '@pi'
				,ProductName	AS '@pn'
				,[Order]		AS '@od'
		FROM	dbo.Product WITH(NOLOCK)
		WHERE	ProductId = @ProductId
		FOR XML PATH('r'), TYPE
		)		
		
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)
	
	DECLARE @Order	INT
	
	BEGIN TRY
		SELECT @Order = MAX([Order]) FROM dbo.Product WITH (NOLOCK)
		UPDATE	dbo.Product WITH(ROWLOCK, UPDLOCK)
			SET	ProductName = @ProductName
				,[Order] = CASE 
								WHEN [Order] = @Order 
								THEN [Order] 
								ELSE @Order + 10 
						   END
				,MainProductId = @MainProductId
				,ProductTypeId = @ProductTypeId
		WHERE	ProductId = @ProductId	
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30008, @Language) -- Fail to edit client product. Please try again.
		RETURN
	END CATCH
	
	SET @xml = (
		SELECT	ProductId		AS '@pi'
				,ProductName	AS '@pn'
				,[Order]		AS '@od'
		FROM	dbo.Product WITH(NOLOCK)
		WHERE	ProductId = @ProductId
		FOR XML PATH('r'), TYPE
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
GO
