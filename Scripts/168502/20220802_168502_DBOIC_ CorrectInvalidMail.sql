/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE [bodb_OIC]
GO
s
/*
	Created: 20220802@Howard
	DB: DBOIC.bodb_OIC
	Task:  OIC - Correct data of invalid mail [Redmine:#168502]
*/


  UPDATE [dbo].[MailRecordSiteName] WITH(ROWLOCK)
  SET   [Status] = 0,
	[Subject] = '[ABEMT] New Licensee Launch (Boping/Single Wallet) (Send time: 08/02/2022 18:57:01 GMT+8)',
	[To] = 'jfoo@enpine.com; jyhuang@enpine.com',
	[Cc] = 'morris.chen@onelab.tw; john.huang@onelab.tw; johnny.yang@onelab.tw; morris.hsieh@onelab.tw; sayhau@enpine.com; singz.hsieh@onelab.tw; stacy.wu@onelab.tw; thomas.chou@onelab.tw; thund.cheng@onelab.tw; tony.huang@onelab.tw; tony.yu@onelab.tw; troy.chen@onelab.tw; vincent.cheng@onelab.tw; maggie.tseng@nextfortune.tw; allen.wu@nextfortune.tw; it@cardiff-service.com; licensing@starixvn.com; tp@enpine.com; vh@enpine.com; licensing@bopingholdings.com; licensingpm@bopingholdings.com; kei.lee@nextfortune.tw; jessie.chan@nextfortune.tw; totti.chen@onelab.tw',
	MSiteMailId = NULL,
	CountSend = 0,
	LatestSendTime = NULL
  WHERE Id = 118466

GO