/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20240102@Cody
	DB: DBOIC.bodb_OIC
	Task: Update platform JollySports for licensees #198195
*/

UPDATE [dbo].[Platform]
SET [PlatformName] = 'JollySports'
WHERE [PlatformId] = 3

GO