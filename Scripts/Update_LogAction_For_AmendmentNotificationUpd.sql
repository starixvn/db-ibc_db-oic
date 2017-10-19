
INSERT INTO dbo.LogActionType( ActionTypeNameEn )
VALUES( 'Notification' );

INSERT INTO dbo.LogAction( LogActionId, LogActionTypeId, SPName, ActionNameEn, Enable, "Order" )
VALUES( 5000, 5, 'OIC_AmendmentNotificationUpd', 'Update Result Amendment Notification', 1, 5001 );