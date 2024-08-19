/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="0"></info>*/
USE [bodb_OIC]
GO

CREATE PROCEDURE [dbo].[OIC_MailRecordSiteNameByMailRecordIdSel]
	@MailRecordId		INT
AS
/*  
	Created by: Hogan  
	Date: 2019-11-11  
	Task: Upgrade mail client [Redmine:#120949]  
	DB: DBOIC.bodb_OIC  
   
	Revisions:  
		- 20191111@Hogan: Create stored procedure OIC_MailRecordSiteNameByMailRecordIdSel [RedmineID: #120949]
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
			,msn.LicenseeTypeMail
	FROM dbo.MailRecordSiteName msn WITH(NOLOCK) 
	WHERE msn.MailRecordId = @MailRecordId
END
GO
