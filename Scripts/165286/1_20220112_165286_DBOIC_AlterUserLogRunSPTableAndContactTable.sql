/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220112@Kai
	DB: DBOIC.bodb_OIC
	Task:  LAP/OIC LAP New Licensee Contact function [Redmine:#165286]
*/


ALTER TABLE [dbo].[Contact]
ADD [IsLicenseeContact] BIT NOT NULL DEFAULT 0;
GO

