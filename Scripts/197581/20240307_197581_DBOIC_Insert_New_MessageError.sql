/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
/*
	Created: 20240307@Kai
	DB: DBOIC.bodb_OIC
	Task: Insert new message error [Redmine:#197581]
*/

INSERT INTO MessageError(MessageErrorId, MessageErrorGroupId, ContentEn)
VALUES (12, 1, 'The LicenseeTypeId does not exist. Please try again.')
	  ,(13, 1, 'The PlatformId does not exist. Please try again.')
	  ,(14, 1, 'The IntegrationMethods includes a non-existent Id. Please try again.');
			
GO