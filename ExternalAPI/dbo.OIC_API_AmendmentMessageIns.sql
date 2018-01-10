/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

CREATE PROCEDURE [dbo].[OIC_API_AmendmentMessageIns]
	 @Title			NVARCHAR(300)
	,@ReceivedDate	DATETIME
	,@Tickets		XML
	,@SiteId		SMALLINT
	,@IsTest		BIT				= 0
	,@IP			VARCHAR(50)		= NULL
	,@ErrCode		INT				= 0			OUTPUT
	,@ErrMsg		VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: bruce.bui
	Date: 20171010
	Task: Insert amendment result [Redmine:#81860]
	DB: DBOIC.bodb_OIC
	
	Revisions:	
		- 20171030@Scofield: #84004 - Implement Deliver notification to licensee backend

	Param's Explanation:
		@SiteId: 0 - Special delete
				 -1 - LRF
		@Tickets: xml format
			<root>
				<ticket name="licensee name1" path="file path1"/>
				<ticket name="licensee name2" path="file path2"/>
			</root>
	     status column = 0 -- for new result.
*/
BEGIN
	SET NOCOUNT ON
	
	DECLARE @startRun DATETIME = GETDATE()
	SELECT @Errcode = 0, @ErrMsg = ''
	
	BEGIN TRY		
		INSERT INTO dbo.AmendmentMessage(SubjectEn, [Status], ReceivedDate, IsTest)
		SELECT	@Title, 0, @ReceivedDate, @IsTest
		
		DECLARE @MessageId INT = SCOPE_IDENTITY()
		
		INSERT INTO dbo.AmendmentTicket(LicenseeName, DataFilePath, MessageID)
		SELECT t.c.value('@name','nvarchar(300)'), t.c.value('@path','nvarchar(300)'), @MessageId
		FROM @Tickets.nodes('root/ticket') t(c)
				
	END TRY
	BEGIN CATCH	
		SELECT	@Errcode = 100,
				@ErrMsg = dbo.f_Get_MsgNamebyMsgID (40002, 'E')
		RETURN
	END CATCH

	-- write log
	DECLARE @xml XML = (
		SELECT	CONVERT(NVARCHAR(MAX),@Tickets) AS '@t'
			,@ReceivedDate			AS '@rcd'
			,0				AS '@st'
			,@Title					AS '@tt'
			
		FOR XML PATH('r'), TYPE
	)		
		
	DECLARE @logSPData	NVARCHAR(MAX)	= CONVERT(NVARCHAR(MAX),@xml)
			,@duration	INT				= DATEDIFF(millisecond, @startRun, GETDATE())
			,@procName	VARCHAR(200)	= OBJECT_NAME(@@procid)

	EXEC dbo.OIC_LogRunSpIns
		@UserId			= @SiteId
		,@SPName		= @procName
		,@Language		= 'E'
		,@IP			= @IP
		,@Data			= @logSPData
		,@OldData		= NULL
		,@Duration		= @Duration	
END
GO