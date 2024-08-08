/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/

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
		- 20240708@Cody: Change the solution to get LicenseeTypeId [RedmineId: #207804]
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
			,msn.LicenseeTypeMail
	FROM dbo.MailRecordSiteName msn WITH(NOLOCK)
	WHERE msn.[Status] = @Status
	ORDER BY msn.ID DESC
END
GO
