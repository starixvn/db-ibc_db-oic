/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_ProductStatusUpd]
	@ProductId				TINYINT
	,@UserId				INT
	,@Language				VARCHAR(10)		= 'E'
	,@IP					VARCHAR(50)		= NULL
	,@ErrCode				INT				= 0			OUTPUT
	,@ErrMsg				VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Alex
	Date: 20211005
	Task: Support Product Type on Client Product [RedmineID: #161508]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20211004@Alex: Init store procedure [RedmineID: #161508]
		
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
		SELECT	CASE WHEN p.Active = 1 THEN 'Active' ELSE 'De-active' END AS '@s'
				,p.ProductName AS '@pn'
		FROM	dbo.Product p WITH(NOLOCK)
		WHERE	ProductId = @ProductId

		FOR XML PATH('r'), TYPE
		)		
		
	SELECT @logSPOlddata = CONVERT(NVARCHAR(MAX), @xml)
	
	BEGIN TRY
		UPDATE	dbo.Product WITH(ROWLOCK, UPDLOCK)
			SET	Active = ~Active
		WHERE	ProductId = @ProductId	
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 101
				,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](30029, @Language) -- Fail to edit status client product. Please try again.
		RETURN
	END CATCH
	
	SET @xml = (
		SELECT	CASE WHEN Active = 1 THEN 'Active' ELSE 'De-active' END AS '@s'
				,ProductName AS '@pn'
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
