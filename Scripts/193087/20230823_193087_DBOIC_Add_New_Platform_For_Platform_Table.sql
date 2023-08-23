/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20230823@Kai
	DB: DBOIC.bodb_OIC
	Task: Add new platform Jollysports for licensees #192986
*/

INSERT INTO [dbo].[Platform] ([PlatformId], [PlatformName])
VALUES (3, 'Jollysports') ;

GO