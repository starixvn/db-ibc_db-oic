/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_AutoMailTypeSel]
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

	SELECT  TypeId
            ,TypeName
	FROM dbo.AutoMailType WITH(NOLOCK)
END
GO