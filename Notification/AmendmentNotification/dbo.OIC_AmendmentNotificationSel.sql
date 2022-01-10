/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_AmendmentNotificationSel]
	@MessageId	INT
AS
/*
	Created by: Scofield
	Date: 20171017 [#84004]
	DB: DBOIC.bodb_OIC
	
	Revisions:	
		- 20171030@Scofield: #84004 - Implement Deliver notification to licensee backend
		- 20180202@Scofield: #90464 - Add PublishedDate
		- 20211222@Kai: #164892 - EnhanceResultAmendment
 */
BEGIN
	SET NOCOUNT ON
		
	SELECT MessageId, SubjectEn, SubjectCh, SubjectCs, ContentEn, ContentCh, ContentCs, Status, EventDate, PublishedDate
	FROM dbo.AmendmentMessage WITH(NOLOCK)
	WHERE MessageID = @MessageId
			
	SELECT TicketId, MessageId, LicenseeName AS SiteName, DataFilePath, SessionID
	FROM dbo.AmendmentTicket WITH(NOLOCK)
	WHERE MessageID = @MessageId
END
GO