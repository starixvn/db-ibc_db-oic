/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="vnteam" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_LogRunSpIns]
	@UserId			INT			
	,@SPName		VARCHAR(50)	
	,@Language		VARCHAR(20)		= 'EN'
	,@IP			VARCHAR(50)		= NULL
	,@Data			NVARCHAR(MAX)	= NULL	
	,@OldData		NVARCHAR(MAX)	= NULL
	,@Duration		INT				= NULL
	,@ExtraInfo		NVARCHAR(100)	= NULL
AS
/*
	Created by: Kathy
	Date: 2014-12-18
	Task: Add new log user run sp [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20161019@Percy: Support test version (xtest, xpre, UAT1, UAT2, UAT3, UAT4) [RedmineID: #64712]
		- 20220214@Howard: Support Licensee Contact [Redmine:#165286]

	Param's Explanation:
		* @UserId: UserId perform this action  
		* @ActionId: Log action ID
		* @TrackingValue: XML string format
 */
BEGIN
	SET NOCOUNT ON
	
	DECLARE @logactionid INT

	IF @SPName LIKE '%_xtest'
		SELECT @SPName = LEFT(@SPName, LEN(@SPName) - 6)
	ELSE IF @SPName LIKE '%_xpre' OR @SPName LIKE '%_UAT1' OR @SPName LIKE '%_UAT2' OR @SPName LIKE '%_UAT3' OR @SPName LIKE '%_UAT4'
		SELECT @SPName = LEFT(@SPName, LEN(@SPName) - 5)
	
	SELECT @logactionid = LogActionId
	FROM dbo.LogAction WITH(NOLOCK)
	WHERE SPName = @SPName

	INSERT INTO dbo.UserLog_RunSP (UserId, LogActionId, IP, LogDate, Duration, ExtraInfo)
	VALUES (@UserId, @logactionid, @IP, GETDATE(), @Duration, @ExtraInfo)
	
	IF @@ERROR = 0
		INSERT INTO dbo.UserLog_RunSP_Detail(LogActionId, Data, OldData)
		VALUES (@logactionid, @Data, @OldData)
END

GO