/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO

/*
	Created: 20220425@Howard
	DB: DBOIC.bodb_OIC
	Task:  LAP/OIC Support Subsidiary business for Licensee Contacts function [Redmine:#170641]
*/


ALTER TABLE [dbo].[Contact]
ADD [Subsidiary] VARCHAR(50) NULL;
GO