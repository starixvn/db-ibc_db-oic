/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240910@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

INSERT INTO [dbo].[AutoMailGroup]
		(GroupId, GroupName, SpecialGroupId)
	VALUES
        (1, 'IT Onelab+Starixsoft', 0),
        (2, 'OP', 0),
        (3, 'Legal', 0),
        (4, 'CSD', 0),
        (5, 'Finance', 0),
        (6, 'CSD+TM', 0),
        (7, 'OP (INR)', 1) -- Licensee has enabled INR currency