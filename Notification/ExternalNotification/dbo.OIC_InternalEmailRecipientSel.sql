/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

USE [bodb_OIC]
GO

ALTER PROCEDURE [dbo].[OIC_InternalEmailRecipientSel]
	@MailTypeId         TINYINT
    ,@LicenseeTypeId    TINYINT
    ,@SpecialGroupIds	VARCHAR(50) = ''
AS

/*
	Created by: Cody
	Date: 2024-09-18
	Task: Manage recipient list of auto mails [RedmineId: #209253]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		20240918@Cody: Init [RedmineId: #209253]

    Param's Explanation:
		* @SpecialGroupIds ('0,1,2,3'):	'': all
										0: normal
										1: special group 1
										2: special group 2
										...

*/

BEGIN
	SET NOCOUNT ON;
	SELECT @SpecialGroupIds = LTRIM(RTRIM(ISNULL(@SpecialGroupIds, '')))

	SELECT a.Id
			,a.GroupId
			,a.LicenseeTypeId
			,a.Email
			,a.RecipientType
			,a.IsTest
	FROM dbo.AutoMail a WITH(NOLOCK)
		INNER JOIN dbo.AutoMailGroup ag WITH(NOLOCK)
			ON ag.GroupId = a.GroupId
	WHERE  a.TypeId = @MailTypeId
			AND a.LicenseeTypeId = @LicenseeTypeId
			AND (@SpecialGroupIds = '' OR ag.SpecialGroupId IN (SELECT CONVERT(TINYINT, value) value FROM STRING_SPLIT(@SpecialGroupIds, ',')))

END
GO