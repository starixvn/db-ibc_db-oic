USE [bodb_OIC]
GO

INSERT INTO dbo.LogAction( LogActionId, LogActionTypeId, SPName, ActionNameEn, Enable, "Order" )
VALUES ( 4005, 4, 'OIC_AmendmentResultIns', 'Insert Result Amendment Notification', 1, 4006 ),
	( 4006, 4, 'OIC_AmendmentNotificationUpd', 'Update Result Amendment Notification', 1, 4007 ),
	( 4007, 4, 'OIC_AmendmentMessageUserIns', 'Insert Amendment User', 1, 4008 );

INSERT INTO dbo.MessageError(MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (40002, 4, 'Fail to add new amendment result'),
	(40003, 4, 'Fail to update amendment result'),
	(40004, 4, 'Fail to insert amendment user');
	
UPDATE dbo.LogAction
  SET
      Enable = 0
WHERE LogActionId IN(4000, 4001, 4002, 4003, 4004);

ALTER TABLE dbo.UserMessage ADD LicenseeName VARCHAR(300); 
