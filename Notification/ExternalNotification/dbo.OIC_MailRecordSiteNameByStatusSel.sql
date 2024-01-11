/*<info serverAlias="DBOIC-bodb_OIC" executers="bodbAdminNet" viewers="" isFunction="0" isNested="0"></info>*/

ALTER PROCEDURE [dbo].[OIC_MailRecordSiteNameByStatusSel]
	@Status			TINYINT
AS
/*  
	Created by: Hogan  
	Date: 2019-10-24  
	Task: Upgrade mail client [Redmine:#120949]  
	DB: DBOIC.bodb_OIC  
   
	Revisions:  
		- 20191024@Hogan: Create stored procedure OIC_MailRecordSiteNameByStatusSel [RedmineID: #120949]
		- 20230310@Kai: Get data UpdatedTime column [RedmineID: #184690]
		- 20231227@Cody: Get LicenseeTypeId [RedmineID: #198195]
 */ 
BEGIN
	SET NOCOUNT ON
	
	SELECT	msn.Id				AS MailSiteNameId
			,msn.[To]			AS MailTo
			,msn.Cc				AS MailCc
			,msn.Bcc			AS MailBcc
			,msn.[Subject]		AS MailSubject
			,msn.MailRecordId
			,msn.MSiteMailId	AS MSiteMailId
			,msn.[Status]
			,msn.CountSend
			,msn.CreateTime
			,msn.UpdatedTime
			,l.TypeId			AS LicenseeTypeId
	FROM dbo.MailRecordSiteName msn WITH(NOLOCK)
		LEFT JOIN dbo.Licensee l WITH(NOLOCK)
			ON msn.[Type] = 0 AND msn.ToRecipientId = l.LicenseeId
	WHERE msn.[Status] = @Status
	ORDER BY msn.ID DESC
END
GO
