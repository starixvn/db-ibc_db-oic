/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20240910@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

INSERT INTO [dbo].[AutoMail]
	        (Email, RecipientType, IsTest, GroupId, TypeId, LicenseeTypeId)
	VALUES
        ('qa@starixsoft.com', 0, 0, 1, 1, 1), -- IT Onelab+Starixsoft, Launch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 1, 1, 3), -- IT Onelab+Starixsoft, Launch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 1, 1, 2), -- IT Onelab+Starixsoft, Launch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 1, 1, 4), -- IT Onelab+Starixsoft, Launch Licensee Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 2, 1, 1), -- OP, Launch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 2, 1, 3), -- OP, Launch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 2, 1, 2), -- OP, Launch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 2, 1, 4), -- OP, Launch Licensee Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 3, 1, 1), -- Legal, Launch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 3, 1, 3), -- Legal, Launch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 3, 1, 2), -- Legal, Launch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 4, 1, 1), -- CSD, Launch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 4, 1, 3), -- CSD, Launch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 4, 1, 2), -- CSD, Launch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 4, 1, 4), -- CSD, Launch Licensee Email, Jollysports

        ('qa@starixsoft.com', 0, 0, 6, 2, 1), -- CSD+TM, Relaunch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 6, 2, 3), -- CSD+TM, Relaunch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 6, 2, 2), -- CSD+TM, Relaunch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 6, 2, 4), -- CSD+TM, Relaunch Licensee Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 2, 2, 1), -- OP, Relaunch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 2, 2, 3), -- OP, Relaunch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 2, 2, 2), -- OP, Relaunch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 2, 2, 4), -- OP, Relaunch Licensee Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 5, 2, 1), -- Finance, Relaunch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 5, 2, 3), -- Finance, Relaunch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 5, 2, 2), -- Finance, Relaunch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 5, 2, 4), -- Finance, Relaunch Licensee Email, Jollysports

        ('qa@starixsoft.com', 0, 0, 6, 3, 1), -- CSD+TM, New Product Launch Email, Boping
        ('qa@starixsoft.com', 0, 0, 6, 3, 3), -- CSD+TM, New Product Launch Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 6, 3, 2), -- CSD+TM, New Product Launch Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 6, 3, 4), -- CSD+TM, New Product Launch Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 5, 3, 1), -- Finance, New Product Launch Email, Boping
        ('qa@starixsoft.com', 0, 0, 5, 3, 3), -- Finance, New Product Launch Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 5, 3, 2), -- Finance, New Product Launch Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 5, 3, 4), -- Finance, New Product Launch Email, Jollysports

        ('qa@starixsoft.com', 0, 0, 6, 4, 1), -- CSD+TM, Suspended/ Terminated Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 6, 4, 3), -- CSD+TM, Suspended/ Terminated Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 6, 4, 2), -- CSD+TM, Suspended/ Terminated Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 6, 4, 4), -- CSD+TM, Suspended/ Terminated Licensee Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 3, 4, 1), -- Legal, Suspended/ Terminated Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 3, 4, 3), -- Legal, Suspended/ Terminated Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 3, 4, 2), -- Legal, Suspended/ Terminated Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 5, 4, 1), -- Finance, Suspended/ Terminated Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 5, 4, 3), -- Finance, Suspended/ Terminated Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 5, 4, 2), -- Finance, Suspended/ Terminated Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 5, 4, 4), -- Finance, Suspended/ Terminated Licensee Email, Jollysports
        
        ('qa@starixsoft.com', 0, 0, 6, 5, 1), -- CSD+TM, Terminated Product Email, Boping
        ('qa@starixsoft.com', 0, 0, 6, 5, 3), -- CSD+TM, Terminated Product Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 6, 5, 2), -- CSD+TM, Terminated Product Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 6, 5, 4), -- CSD+TM, Terminated Product Email, Jollysports
        ('qa@starixsoft.com', 0, 0, 3, 5, 1), -- Legal, Terminated Product Email, Boping
        ('qa@starixsoft.com', 0, 0, 3, 5, 3), -- Legal, Terminated Product Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 3, 5, 2), -- Legal, Terminated Product Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 5, 5, 1), -- Finance, Terminated Product Email, Boping
        ('qa@starixsoft.com', 0, 0, 5, 5, 3), -- Finance, Terminated Product Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 5, 5, 2), -- Finance, Terminated Product Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 5, 5, 4), -- Finance, Terminated Product Email, Jollysports

        ('qa@starixsoft.com', 0, 0, 7, 1, 1), -- OP (INR), Launch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 7, 1, 2), -- OP (INR), Launch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 7, 1, 3), -- OP (INR), Launch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 7, 1, 4), -- OP (INR), Launch Licensee Email, Jollysports

        ('qa@starixsoft.com', 0, 0, 7, 2, 1), -- OP (INR), Relaunch Licensee Email, Boping
        ('qa@starixsoft.com', 0, 0, 7, 2, 2), -- OP (INR), Relaunch Licensee Email, Oneworks
        ('qa@starixsoft.com', 0, 0, 7, 2, 3), -- OP (INR), Relaunch Licensee Email, Zelianta
        ('qa@starixsoft.com', 0, 0, 7, 2, 4) -- OP (INR), Relaunch Licensee Email, Jollysports