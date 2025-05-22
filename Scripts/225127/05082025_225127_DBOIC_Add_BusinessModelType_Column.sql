/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
    Created: 20250508@Kai
    DB: DBOIC.bodb_OIC
    Task: Add Business Model Type Info [Redmine:#225127]
*/

-- Add Business Model Type Column
ALTER TABLE dbo.Licensee
ADD BusinessModelType TINYINT
GO

-- Rename unused Column
-- EXEC sp_rename 'dbo.Licensee.IsReseller', 'DEL_IsReseller', 'COLUMN';