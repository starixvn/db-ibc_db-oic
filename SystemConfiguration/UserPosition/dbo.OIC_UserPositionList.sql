/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_UserPositionList]
AS

/*
	Created by: Kathy
	Date: 20151002
	Task: list user position [Redmine:#44258]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20180925@Helen: DB052.bodb_NAP Migration to DBCust - [Redmine:100493]
		- 20230719@Cody: Migrate bodb_OIC to db054/db055 - [RedmineId: #191392]
	
	Parameters:
 */
 
BEGIN
	SET NOCOUNT ON;

	SELECT	ui.UserId
			,ui.DisplayName
			,ui.PositionId
			,p.PositionName
	FROM dbo.UserInfo ui WITH(NOLOCK)
		LEFT JOIN dbo.Position p WITH(NOLOCK)
			ON ui.PositionId = p.PositionId

END