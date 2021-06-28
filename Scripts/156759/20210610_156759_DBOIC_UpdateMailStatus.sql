/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20210610@Howard
	DB: DBOIC.bodb_OIC
	Task: Update Status MailRecordSiteName to 1  [RedmineID: #156759]
*/

UPDATE [dbo].[MailRecordSiteName] WITH(ROWLOCK)
 SET Status = 1
 WHERE Id IN(
		65130,
        65131,
		65132,
		65133,
		65134,
		65135,
		65136,
		65137,
		65138,
		65139,
		65140,
		65141,
		65142,
		65143,
		65144,
		65184,
		65185,
		65186)