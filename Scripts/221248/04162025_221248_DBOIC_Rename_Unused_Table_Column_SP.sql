/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
    Created: 20250416@Kai
    DB: DBOIC.bodb_OIC
    Task: Rename unused Table, Column & Stored Procedures #221248
*/

-- Rename unused Table
EXEC sp_rename 'dbo.LicenseeType', 'DEL_LicenseeType';
EXEC sp_rename 'dbo.UserLicenseeType', 'DEL_UserLicenseeType';
EXEC sp_rename 'dbo.MessageTarget', 'DEL_MessageTarget';

-- Rename unused Column
EXEC sp_rename 'dbo.Licensee.LicenseeTypeId', 'DEL_LicenseeTypeId', 'COLUMN';

-- Rename unused Stored Procedures
EXEC sp_rename 'dbo.OIC_DBA_UserLicenseeIns', 'DEL_OIC_DBA_UserLicenseeIns';
EXEC sp_rename 'dbo.OIC_LicenseeListAll', 'DEL_OIC_LicenseeListAll';
EXEC sp_rename 'dbo.OIC_Msg_SystemMsgIns', 'DEL_OIC_Msg_SystemMsgIns';
