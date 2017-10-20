
INSERT INTO dbo.LogActionType( ActionTypeNameEn )
VALUES( 'Amendment Result' );

INSERT INTO dbo.LogAction( LogActionId, LogActionTypeId, SPName, ActionNameEn, Enable, "Order" )
VALUES( 5000, 5, 'OIC_AmendmentNotificationUpd', 'Update Result Amendment Notification', 1, 5001 );


INSERT INTO dbo.MessageErrorGroup( GroupName )
VALUES( 'Amendment Result' );

INSERT INTO MessageError(MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (50000, 5, 'Fail to add new amendment result'),
	(50001, 5, 'Fail to update new amendment result')