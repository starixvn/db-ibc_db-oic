/*<info serverAlias="DBOIC-bodb_OIC"></info>*/

USE [bodb_OIC]
GO

/*
	Created: 20241008@Cody
	DB: DBOIC.bodb_OIC
	Task: Manage recipient list of auto mails [RedmineId: #209253]
*/

INSERT INTO [dbo].[AutoMail]
	    (Email, RecipientType, IsTest, GroupId, TypeId, LicenseeTypeId)
	VALUES
        /* IT Onelab+Starixsoft, Launch Licensee Email, Boping */
        ('jfoo@enpine.com', 0, 0, 1, 1, 1),
        ('john.huang@onelab.tw', 1, 0, 1, 1, 1),
        ('singz.hsieh@onelab.tw', 1, 0, 1, 1, 1),
        ('thien.pham@starixsoft.com', 1, 0, 1, 1, 1),
        ('stacy.wu@onelab.tw', 1, 0, 1, 1, 1),
        ('tony.huang@onelab.tw', 1, 0, 1, 1, 1),
        ('tony.yu@onelab.tw', 1, 0, 1, 1, 1),
        ('allen.wu@nextfortune.tw', 1, 0, 1, 1, 1),
        ('hyjay-it@hyjay.com', 1, 0, 1, 1, 1),
        ('licensing@starixsoft.com', 1, 0, 1, 1, 1),
        ('tp@enpine.com', 1, 0, 1, 1, 1),
        ('vh@enpine.com', 1, 0, 1, 1, 1),
        ('licensing@bopingholdings.com', 1, 0, 1, 1, 1),
        ('kei.lee@nextfortune.tw', 1, 0, 1, 1, 1),
        ('jessie.chan@nextfortune.tw', 1, 0, 1, 1, 1),
        ('totti.chen@onelab.tw', 1, 0, 1, 1, 1),
        ('thomas.chou@onelab.tw', 1, 0, 1, 1, 1),
        ('ariel.lin@onelab.tw', 1, 0, 1, 1, 1),
        ('esther.liao@onelab.tw', 1, 0, 1, 1, 1),
        ('aaron.wang@onelab.tw', 1, 0, 1, 1, 1),
        ('tandy.tien@onelab.tw', 1, 0, 1, 1, 1),
        ('adam.huang@onelab.tw', 1, 0, 1, 1, 1),
        ('sunny.chan@nextfortune.tw', 1, 0, 1, 1, 1),
        ('jenny.yang@nextfortune.tw', 1, 0, 1, 1, 1),
        ('howard.ye@nextfortune.tw', 1, 0, 1, 1, 1),
        ('albert.yeah@nextfortune.tw', 1, 0, 1, 1, 1),
        ('kid.shih@onelab.tw', 1, 0, 1, 1, 1),
        ('licenseetm@nextfortune.tw', 1, 0, 1, 1, 1),
        ('martin.lee@nextfortune.tw', 1, 0, 1, 1, 1),
        ('shannon.yang@nextfortune.tw', 1, 0, 1, 1, 1),
        ('chester.fang@nextfortune.tw', 1, 0, 1, 1, 1),
        ('Ron.Lin@nextfortune.tw', 1, 0, 1, 1, 1),
        ('rudy.ke@nextfortune.tw', 1, 0, 1, 1, 1),
        ('david.wen@nextfortune.tw', 1, 0, 1, 1, 1),
        ('stanly.hsu@cardiff-service.com', 1, 0, 1, 1, 1),
        ('ryan.chou@nextfortune.tw', 1, 0, 1, 1, 1),
        ('bert.chang@onelab.tw', 1, 0, 1, 1, 1),
        ('julien.le@starixsoft.com', 1, 0, 1, 1, 1),
        ('erika.tran@starixsoft.com', 1, 0, 1, 1, 1),
        ('candy.le@starixsoft.com', 0, 1, 1, 1, 1),
        ('qa@starixsoft.com', 1, 1, 1, 1, 1),


        /* IT Onelab+Starixsoft, Launch Licensee Email, Zelianta */
        ('jfoo@enpine.com', 0, 0, 1, 1, 3),
        ('john.huang@onelab.tw', 1, 0, 1, 1, 3),
        ('singz.hsieh@onelab.tw', 1, 0, 1, 1, 3),
        ('thien.pham@starixsoft.com', 1, 0, 1, 1, 3),
        ('stacy.wu@onelab.tw', 1, 0, 1, 1, 3),
        ('tony.huang@onelab.tw', 1, 0, 1, 1, 3),
        ('tony.yu@onelab.tw', 1, 0, 1, 1, 3),
        ('allen.wu@nextfortune.tw', 1, 0, 1, 1, 3),
        ('hyjay-it@hyjay.com', 1, 0, 1, 1, 3),
        ('licensing@starixsoft.com', 1, 0, 1, 1, 3),
        ('tp@enpine.com', 1, 0, 1, 1, 3),
        ('vh@enpine.com', 1, 0, 1, 1, 3),
        ('licensing@zelianta.com', 1, 0, 1, 1, 3),
        ('kei.lee@nextfortune.tw', 1, 0, 1, 1, 3),
        ('totti.chen@onelab.tw', 1, 0, 1, 1, 3),
        ('thomas.chou@onelab.tw', 1, 0, 1, 1, 3),
        ('ariel.lin@onelab.tw', 1, 0, 1, 1, 3),
        ('esther.liao@onelab.tw', 1, 0, 1, 1, 3),
        ('aaron.wang@onelab.tw', 1, 0, 1, 1, 3),
        ('tandy.tien@onelab.tw', 1, 0, 1, 1, 3),
        ('jessie.chan@nextfortune.tw', 1, 0, 1, 1, 3),
        ('adam.huang@onelab.tw', 1, 0, 1, 1, 3),
        ('sunny.chan@nextfortune.tw', 1, 0, 1, 1, 3),
        ('jenny.yang@nextfortune.tw', 1, 0, 1, 1, 3),
        ('howard.ye@nextfortune.tw', 1, 0, 1, 1, 3),
        ('albert.yeah@nextfortune.tw', 1, 0, 1, 1, 3),
        ('kid.shih@onelab.tw', 1, 0, 1, 1, 3),
        ('martin.lee@nextfortune.tw', 1, 0, 1, 1, 3),
        ('shannon.yang@nextfortune.tw', 1, 0, 1, 1, 3),
        ('chester.fang@nextfortune.tw', 1, 0, 1, 1, 3),
        ('licenseetm@nextfortune.tw', 1, 0, 1, 1, 3),
        ('Ron.Lin@nextfortune.tw', 1, 0, 1, 1, 3),
        ('rudy.ke@nextfortune.tw', 1, 0, 1, 1, 3),
        ('david.wen@nextfortune.tw', 1, 0, 1, 1, 3),
        ('stanly.hsu@cardiff-service.com', 1, 0, 1, 1, 3),
        ('ryan.chou@nextfortune.tw', 1, 0, 1, 1, 3),
        ('bert.chang@onelab.tw', 1, 0, 1, 1, 3),
        ('julien.le@starixsoft.com', 1, 0, 1, 1, 3),
        ('erika.tran@starixsoft.com', 1, 0, 1, 1, 3),
        ('candy.le@starixsoft.com', 0, 1, 1, 1, 3),
        ('qa@starixsoft.com', 1, 1, 1, 1, 3),


        /* IT Onelab+Starixsoft, Launch Licensee Email, Oneworks */
        ('jfoo@enpine.com', 0, 0, 1, 1, 2),
        ('john.huang@onelab.tw', 1, 0, 1, 1, 2),
        ('singz.hsieh@onelab.tw', 1, 0, 1, 1, 2),
        ('thien.pham@starixsoft.com', 1, 0, 1, 1, 2),
        ('stacy.wu@onelab.tw', 1, 0, 1, 1, 2),
        ('tony.huang@onelab.tw', 1, 0, 1, 1, 2),
        ('tony.yu@onelab.tw', 1, 0, 1, 1, 2),
        ('allen.wu@nextfortune.tw', 1, 0, 1, 1, 2),
        ('hyjay-it@hyjay.com', 1, 0, 1, 1, 2),
        ('licensing@starixsoft.com', 1, 0, 1, 1, 2),
        ('tp@enpine.com', 1, 0, 1, 1, 2),
        ('vh@enpine.com', 1, 0, 1, 1, 2),
        ('licensing@oneworks.com', 1, 0, 1, 1, 2),
        ('licenseetm@nextfortune.tw', 1, 0, 1, 1, 2),
        ('kei.lee@nextfortune.tw', 1, 0, 1, 1, 2),
        ('totti.chen@onelab.tw', 1, 0, 1, 1, 2),
        ('thomas.chou@onelab.tw', 1, 0, 1, 1, 2),
        ('ariel.lin@onelab.tw', 1, 0, 1, 1, 2),
        ('esther.liao@onelab.tw', 1, 0, 1, 1, 2),
        ('aaron.wang@onelab.tw', 1, 0, 1, 1, 2),
        ('tandy.tien@onelab.tw', 1, 0, 1, 1, 2),
        ('jessie.chan@nextfortune.tw', 1, 0, 1, 1, 2),
        ('adam.huang@onelab.tw', 1, 0, 1, 1, 2),
        ('sunny.chan@nextfortune.tw', 1, 0, 1, 1, 2),
        ('jenny.yang@nextfortune.tw', 1, 0, 1, 1, 2),
        ('howard.ye@nextfortune.tw', 1, 0, 1, 1, 2),
        ('albert.yeah@nextfortune.tw', 1, 0, 1, 1, 2),
        ('kid.shih@onelab.tw', 1, 0, 1, 1, 2),
        ('licenseetm@nextfortune.tw', 1, 0, 1, 1, 2),
        ('martin.lee@nextfortune.tw', 1, 0, 1, 1, 2),
        ('shannon.yang@nextfortune.tw', 1, 0, 1, 1, 2),
        ('chester.fang@nextfortune.tw', 1, 0, 1, 1, 2),
        ('Ron.Lin@nextfortune.tw', 1, 0, 1, 1, 2),
        ('rudy.ke@nextfortune.tw', 1, 0, 1, 1, 2),
        ('david.wen@nextfortune.tw', 1, 0, 1, 1, 2),
        ('stanly.hsu@cardiff-service.com', 1, 0, 1, 1, 2),
        ('ryan.chou@nextfortune.tw', 1, 0, 1, 1, 2),
        ('bert.chang@onelab.tw', 1, 0, 1, 1, 2),
        ('julien.le@starixsoft.com', 1, 0, 1, 1, 2),
        ('erika.tran@starixsoft.com', 1, 0, 1, 1, 2),
        ('candy.le@starixsoft.com', 0, 1, 1, 1, 2),
        ('qa@starixsoft.com', 1, 1, 1, 1, 2),


        /* IT Onelab+Starixsoft, Launch Licensee Email, Jollysports */
        ('tm@jollysports.com', 0, 0, 1, 1, 4),
        ('it@jollysports.com', 0, 0, 1, 1, 4),
        ('it2@jollysports.com', 0, 0, 1, 1, 4),
        ('licensing@jollysports.com', 1, 0, 1, 1, 4),
        ('candy.le@starixsoft.com', 0, 1, 1, 1, 4),
        ('qa@starixsoft.com', 1, 1, 1, 1, 4),


        /* OP, Launch Licensee Email, Boping */
        ('seanlau@enpine.com', 0, 0, 2, 1, 1),
        ('jetyee88@enpine.com', 0, 0, 2, 1, 1),
        ('byronchia@enpine.com', 0, 0, 2, 1, 1),
        ('scyy@enpine.com', 0, 0, 2, 1, 1),
        ('jfoo@enpine.com', 0, 0, 2, 1, 1),
        ('Han@enpine.com', 0, 0, 2, 1, 1),
        ('nsd.pm@enpine.com', 0, 0, 2, 1, 1),
        ('AdI@enpine.com', 0, 0, 2, 1, 1),
        ('kenji@enpine.com', 0, 0, 2, 1, 1),
        ('kwongyong@enpine.com', 0, 0, 2, 1, 1),
        ('licensing@bopingholdings.com', 1, 0, 2, 1, 1),
        ('candy.le@starixsoft.com', 0, 1, 2, 1, 1),
        ('qa@starixsoft.com', 1, 1, 2, 1, 1),


        /* OP, Launch Licensee Email, Zelianta */
        ('seanlau@enpine.com', 0, 0, 2, 1, 3),
        ('jetyee88@enpine.com', 0, 0, 2, 1, 3),
        ('byronchia@enpine.com', 0, 0, 2, 1, 3),
        ('scyy@enpine.com', 0, 0, 2, 1, 3),
        ('jfoo@enpine.com', 0, 0, 2, 1, 3),
        ('Han@enpine.com', 0, 0, 2, 1, 3),
        ('nsd.pm@enpine.com', 0, 0, 2, 1, 3),
        ('AdI@enpine.com', 0, 0, 2, 1, 3),
        ('kenji@enpine.com', 0, 0, 2, 1, 3),
        ('kwongyong@enpine.com', 0, 0, 2, 1, 3),
        ('licensing@zelianta.com', 1, 0, 2, 1, 3),
        ('candy.le@starixsoft.com', 0, 1, 2, 1, 3),
        ('qa@starixsoft.com', 1, 1, 2, 1, 3),


        /* OP, Launch Licensee Email, Oneworks */
        ('seanlau@enpine.com', 0, 0, 2, 1, 2),
        ('jetyee88@enpine.com', 0, 0, 2, 1, 2),
        ('byronchia@enpine.com', 0, 0, 2, 1, 2),
        ('scyy@enpine.com', 0, 0, 2, 1, 2),
        ('jfoo@enpine.com', 0, 0, 2, 1, 2),
        ('Han@enpine.com', 0, 0, 2, 1, 2),
        ('nsd.pm@enpine.com', 0, 0, 2, 1, 2),
        ('AdI@enpine.com', 0, 0, 2, 1, 2),
        ('kenji@enpine.com', 0, 0, 2, 1, 2),
        ('kwongyong@enpine.com', 0, 0, 2, 1, 2),
        ('licensing@oneworks.com', 1, 0, 2, 1, 2),
        ('candy.le@starixsoft.com', 0, 1, 2, 1, 2),
        ('qa@starixsoft.com', 1, 1, 2, 1, 2),


        /* OP, Launch Licensee Email, Jollysports */
        ('op@jollysports.com', 0, 0, 2, 1, 4),
        ('licensing@jollysports.com', 1, 0, 2, 1, 4),
        ('candy.le@starixsoft.com', 0, 1, 2, 1, 4),
        ('qa@starixsoft.com', 1, 1, 2, 1, 4),


        /* Legal, Launch Licensee Email, Boping */
        ('info@bopingholdings.com', 0, 0, 3, 1, 1),
        ('licensing@bopingholdings.com', 1, 0, 3, 1, 1),
        ('candy.le@starixsoft.com', 0, 1, 3, 1, 1),
        ('qa@starixsoft.com', 1, 1, 3, 1, 1),


        /* Legal, Launch Licensee Email, Zelianta */
        ('owlegal@lexfingsi.com', 0, 0, 3, 1, 3),
        ('licensing@zelianta.com', 1, 0, 3, 1, 3),
        ('candy.le@starixsoft.com', 0, 1, 3, 1, 3),
        ('qa@starixsoft.com', 1, 1, 3, 1, 3),


        /* Legal, Launch Licensee Email, Oneworks */
        ('owlegal@lexfingsi.com', 0, 0, 3, 1, 2),
        ('licensing@oneworks.com', 1, 0, 3, 1, 2),
        ('candy.le@starixsoft.com', 0, 1, 3, 1, 2),
        ('qa@starixsoft.com', 1, 1, 3, 1, 2),


        /* CSD, Launch Licensee Email, Boping */
        ('cs@oneonone-solutions.com', 0, 0, 4, 1, 1),
        ('erica@enpine.com', 0, 0, 4, 1, 1),
        ('csoneonone@enpine.com', 0, 0, 4, 1, 1),
        ('licensing@bopingholdings.com', 1, 0, 4, 1, 1),
        ('candy.le@starixsoft.com', 0, 1, 4, 1, 1),
        ('qa@starixsoft.com', 1, 1, 4, 1, 1),


        /* CSD, Launch Licensee Email, Zelianta */
        ('cs@oneonone-solutions.com', 0, 0, 4, 1, 3),
        ('erica@enpine.com', 0, 0, 4, 1, 3),
        ('csoneonone@enpine.com', 0, 0, 4, 1, 3),
        ('licensing@zelianta.com', 1, 0, 4, 1, 3),
        ('candy.le@starixsoft.com', 0, 1, 4, 1, 3),
        ('qa@starixsoft.com', 1, 1, 4, 1, 3),


        /* CSD, Launch Licensee Email, Oneworks */
        ('cs@oneonone-solutions.com', 0, 0, 4, 1, 2),
        ('erica@enpine.com', 0, 0, 4, 1, 2),
        ('csoneonone@enpine.com', 0, 0, 4, 1, 2),
        ('licensing@oneworks.com', 1, 0, 4, 1, 2),
        ('candy.le@starixsoft.com', 0, 1, 4, 1, 2),
        ('qa@starixsoft.com', 1, 1, 4, 1, 2),


        /* CSD, Launch Licensee Email, Jollysports */
        ('cs@jollysports.com', 0, 0, 4, 1, 4),
        ('licensing@jollysports.com', 1, 0, 4, 1, 4),
        ('tm@jollysports.com', 1, 0, 4, 1, 4),
        ('candy.le@starixsoft.com', 0, 1, 4, 1, 4),
        ('qa@starixsoft.com', 1, 1, 4, 1, 4),


        /* CSD+TM, Relaunch Licensee Email, Boping */
        ('cs@oneonone-solutions.com', 0, 0, 6, 2, 1),
        ('erica@enpine.com', 0, 0, 6, 2, 1),
        ('csoneonone@enpine.com', 0, 0, 6, 2, 1),
        ('licensing@bopingholdings.com', 1, 0, 6, 2, 1),
        ('julien.le@starixsoft.com', 1, 0, 6, 2, 1),
        ('erika.tran@starixsoft.com', 1, 0, 6, 2, 1),
        ('totti.chen@onelab.tw', 1, 0, 6, 2, 1),
        ('thomas.chou@onelab.tw', 1, 0, 6, 2, 1),
        ('ariel.lin@onelab.tw', 1, 0, 6, 2, 1),
        ('esther.liao@onelab.tw', 1, 0, 6, 2, 1),
        ('aaron.wang@onelab.tw', 1, 0, 6, 2, 1),
        ('tandy.tien@onelab.tw', 1, 0, 6, 2, 1),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 2, 1),
        ('candy.le@starixsoft.com', 0, 1, 6, 2, 1),
        ('qa@starixsoft.com', 1, 1, 6, 2, 1),


        /* CSD+TM, Relaunch Licensee Email, Zelianta */
        ('cs@oneonone-solutions.com', 0, 0, 6, 2, 3),
        ('erica@enpine.com', 0, 0, 6, 2, 3),
        ('csoneonone@enpine.com', 0, 0, 6, 2, 3),
        ('licensing@zelianta.com', 1, 0, 6, 2, 3),
        ('julien.le@starixsoft.com', 1, 0, 6, 2, 3),
        ('erika.tran@starixsoft.com', 1, 0, 6, 2, 3),
        ('totti.chen@onelab.tw', 1, 0, 6, 2, 3),
        ('thomas.chou@onelab.tw', 1, 0, 6, 2, 3),
        ('ariel.lin@onelab.tw', 1, 0, 6, 2, 3),
        ('esther.liao@onelab.tw', 1, 0, 6, 2, 3),
        ('aaron.wang@onelab.tw', 1, 0, 6, 2, 3),
        ('tandy.tien@onelab.tw', 1, 0, 6, 2, 3),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 2, 3),
        ('candy.le@starixsoft.com', 0, 1, 6, 2, 3),
        ('qa@starixsoft.com', 1, 1, 6, 2, 3),


        /* CSD+TM, Relaunch Licensee Email, Oneworks */
        ('cs@oneonone-solutions.com', 0, 0, 6, 2, 2),
        ('erica@enpine.com', 0, 0, 6, 2, 2),
        ('csoneonone@enpine.com', 0, 0, 6, 2, 2),
        ('licensing@oneworks.com', 1, 0, 6, 2, 2),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 2, 2),
        ('julien.le@starixsoft.com', 1, 0, 6, 2, 2),
        ('erika.tran@starixsoft.com', 1, 0, 6, 2, 2),
        ('totti.chen@onelab.tw', 1, 0, 6, 2, 2),
        ('thomas.chou@onelab.tw', 1, 0, 6, 2, 2),
        ('ariel.lin@onelab.tw', 1, 0, 6, 2, 2),
        ('esther.liao@onelab.tw', 1, 0, 6, 2, 2),
        ('aaron.wang@onelab.tw', 1, 0, 6, 2, 2),
        ('tandy.tien@onelab.tw', 1, 0, 6, 2, 2),
        ('candy.le@starixsoft.com', 0, 1, 6, 2, 2),
        ('qa@starixsoft.com', 1, 1, 6, 2, 2),


        /* CSD+TM, Relaunch Licensee Email, Jollysports */
        ('cs@jollysports.com', 0, 0, 6, 2, 4),
        ('licensing@jollysports.com', 1, 0, 6, 2, 4),
        ('it@jollysports.com', 1, 0, 6, 2, 4),
        ('it2@jollysports.com', 1, 0, 6, 2, 4),
        ('candy.le@starixsoft.com', 0, 1, 6, 2, 4),
        ('qa@starixsoft.com', 1, 1, 6, 2, 4),


        /* OP, Relaunch Licensee Email, Boping */
        ('seanlau@enpine.com', 0, 0, 2, 2, 1),
        ('jetyee88@enpine.com', 0, 0, 2, 2, 1),
        ('byronchia@enpine.com', 0, 0, 2, 2, 1),
        ('scyy@enpine.com', 0, 0, 2, 2, 1),
        ('jfoo@enpine.com', 0, 0, 2, 2, 1),
        ('Han@enpine.com', 0, 0, 2, 2, 1),
        ('nsd.pm@enpine.com', 0, 0, 2, 2, 1),
        ('AdI@enpine.com', 0, 0, 2, 2, 1),
        ('kenji@enpine.com', 0, 0, 2, 2, 1),
        ('kwongyong@enpine.com', 0, 0, 2, 2, 1),
        ('licensing@bopingholdings.com', 1, 0, 2, 2, 1),
        ('candy.le@starixsoft.com', 0, 1, 2, 2, 1),
        ('qa@starixsoft.com', 1, 1, 2, 2, 1),


        /* OP, Relaunch Licensee Email, Zelianta */
        ('seanlau@enpine.com', 0, 0, 2, 2, 3),
        ('jetyee88@enpine.com', 0, 0, 2, 2, 3),
        ('byronchia@enpine.com', 0, 0, 2, 2, 3),
        ('scyy@enpine.com', 0, 0, 2, 2, 3),
        ('jfoo@enpine.com', 0, 0, 2, 2, 3),
        ('Han@enpine.com', 0, 0, 2, 2, 3),
        ('nsd.pm@enpine.com', 0, 0, 2, 2, 3),
        ('AdI@enpine.com', 0, 0, 2, 2, 3),
        ('kenji@enpine.com', 0, 0, 2, 2, 3),
        ('kwongyong@enpine.com', 0, 0, 2, 2, 3),
        ('licensing@zelianta.com', 1, 0, 2, 2, 3),
        ('candy.le@starixsoft.com', 0, 1, 2, 2, 3),
        ('qa@starixsoft.com', 1, 1, 2, 2, 3),


        /* OP, Relaunch Licensee Email, Oneworks */
        ('seanlau@enpine.com', 0, 0, 2, 2, 2),
        ('jetyee88@enpine.com', 0, 0, 2, 2, 2),
        ('byronchia@enpine.com', 0, 0, 2, 2, 2),
        ('scyy@enpine.com', 0, 0, 2, 2, 2),
        ('jfoo@enpine.com', 0, 0, 2, 2, 2),
        ('Han@enpine.com', 0, 0, 2, 2, 2),
        ('nsd.pm@enpine.com', 0, 0, 2, 2, 2),
        ('AdI@enpine.com', 0, 0, 2, 2, 2),
        ('kenji@enpine.com', 0, 0, 2, 2, 2),
        ('kwongyong@enpine.com', 0, 0, 2, 2, 2),
        ('licensing@oneworks.com', 1, 0, 2, 2, 2),
        ('candy.le@starixsoft.com', 0, 1, 2, 2, 2),
        ('qa@starixsoft.com', 1, 1, 2, 2, 2),


        /* OP, Relaunch Licensee Email, Jollysports */
        ('op@jollysports.com', 0, 0, 2, 2, 4),
        ('licensing@jollysports.com', 1, 0, 2, 2, 4),
        ('candy.le@starixsoft.com', 0, 1, 2, 2, 4),
        ('qa@starixsoft.com', 1, 1, 2, 2, 4),


        /* Finance, Relaunch Licensee Email, Boping */
        ('finance@bopingholdings.com', 0, 0, 5, 2, 1),
        ('group@bopingholdings.com', 0, 0, 5, 2, 1),
        ('licensing@bopingholdings.com', 1, 0, 5, 2, 1),
        ('Licensing@starixsoft.com', 1, 0, 5, 2, 1),
        ('candy.le@starixsoft.com', 0, 1, 5, 2, 1),
        ('qa@starixsoft.com', 1, 1, 5, 2, 1),


        /* Finance, Relaunch Licensee Email, Zelianta */
        ('finance@zelianta.com', 0, 0, 5, 2, 3),
        ('group@zelianta.com', 0, 0, 5, 2, 3),
        ('licensing@starixsoft.com', 1, 0, 5, 2, 3),
        ('licensing@zelianta.com', 1, 0, 5, 2, 3),
        ('candy.le@starixsoft.com', 0, 1, 5, 2, 3),
        ('qa@starixsoft.com', 1, 1, 5, 2, 3),


        /* Finance, Relaunch Licensee Email, Oneworks */
        ('silverbell166@enpine.com', 0, 0, 5, 2, 2),
        ('meiteng@enpine.com', 0, 0, 5, 2, 2),
        ('schang27@enpine.com', 0, 0, 5, 2, 2),
        ('licensing@starixsoft.com', 0, 0, 5, 2, 2),
        ('malcolm@enpine.com', 0, 0, 5, 2, 2),
        ('shyane.cqx@enpine.com', 0, 0, 5, 2, 2),
        ('finance@oneworks.com', 0, 0, 5, 2, 2),
        ('licensing@oneworks.com', 1, 0, 5, 2, 2),
        ('candy.le@starixsoft.com', 0, 1, 5, 2, 2),
        ('qa@starixsoft.com', 1, 1, 5, 2, 2),


        /* Finance, Relaunch Licensee Email, Jollysports */
        ('group@jollysports.com', 0, 0, 5, 2, 4),
        ('licensing@jollysports.com', 1, 0, 5, 2, 4),
        ('candy.le@starixsoft.com', 0, 1, 5, 2, 4),
        ('qa@starixsoft.com', 1, 1, 5, 2, 4),


        /* CSD+TM, New Product Launch Email, Boping */
        ('cs@oneonone-solutions.com', 0, 0, 6, 3, 1),
        ('csoneonone@enpine.com', 0, 0, 6, 3, 1),
        ('erica@enpine.com', 0, 0, 6, 3, 1),
        ('licensing@bopingholdings.com', 1, 0, 6, 3, 1),
        ('licensing@starixsoft.com', 1, 0, 6, 3, 1),
        ('totti.chen@onelab.tw', 1, 0, 6, 3, 1),
        ('thomas.chou@onelab.tw', 1, 0, 6, 3, 1),
        ('ariel.lin@onelab.tw', 1, 0, 6, 3, 1),
        ('esther.liao@onelab.tw', 1, 0, 6, 3, 1),
        ('aaron.wang@onelab.tw', 1, 0, 6, 3, 1),
        ('tandy.tien@onelab.tw', 1, 0, 6, 3, 1),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 3, 1),
        ('candy.le@starixsoft.com', 0, 1, 6, 3, 1),
        ('qa@starixsoft.com', 1, 1, 6, 3, 1),


        /* CSD+TM, New Product Launch Email, Zelianta */
        ('cs@oneonone-solutions.com', 0, 0, 6, 3, 3),
        ('csoneonone@enpine.com', 0, 0, 6, 3, 3),
        ('erica@enpine.com', 0, 0, 6, 3, 3),
        ('licensing@zelianta.com', 1, 0, 6, 3, 3),
        ('licensing@starixsoft.com', 1, 0, 6, 3, 3),
        ('totti.chen@onelab.tw', 1, 0, 6, 3, 3),
        ('thomas.chou@onelab.tw', 1, 0, 6, 3, 3),
        ('ariel.lin@onelab.tw', 1, 0, 6, 3, 3),
        ('esther.liao@onelab.tw', 1, 0, 6, 3, 3),
        ('aaron.wang@onelab.tw', 1, 0, 6, 3, 3),
        ('tandy.tien@onelab.tw', 1, 0, 6, 3, 3),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 3, 3),
        ('candy.le@starixsoft.com', 0, 1, 6, 3, 3),
        ('qa@starixsoft.com', 1, 1, 6, 3, 3),


        /* CSD+TM, New Product Launch Email, Oneworks */
        ('cs@oneonone-solutions.com', 0, 0, 6, 3, 2),
        ('csoneonone@enpine.com', 0, 0, 6, 3, 2),
        ('erica@enpine.com', 0, 0, 6, 3, 2),
        ('licensing@oneworks.com', 1, 0, 6, 3, 2),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 3, 2),
        ('licensing@starixsoft.com', 1, 0, 6, 3, 2),
        ('totti.chen@onelab.tw', 1, 0, 6, 3, 2),
        ('thomas.chou@onelab.tw', 1, 0, 6, 3, 2),
        ('ariel.lin@onelab.tw', 1, 0, 6, 3, 2),
        ('esther.liao@onelab.tw', 1, 0, 6, 3, 2),
        ('aaron.wang@onelab.tw', 1, 0, 6, 3, 2),
        ('tandy.tien@onelab.tw', 1, 0, 6, 3, 2),
        ('candy.le@starixsoft.com', 0, 1, 6, 3, 2),
        ('qa@starixsoft.com', 1, 1, 6, 3, 2),


        /* CSD+TM, New Product Launch Email, Jollysports */
        ('cs@jollysports.com', 0, 0, 6, 3, 4),
        ('licensing@jollysports.com', 1, 0, 6, 3, 4),
        ('it@jollysports.com', 1, 0, 6, 3, 4),
        ('it2@jollysports.com', 1, 0, 6, 3, 4),
        ('candy.le@starixsoft.com', 0, 1, 6, 3, 4),
        ('qa@starixsoft.com', 1, 1, 6, 3, 4),


        /* Finance, New Product Launch Email, Boping */
        ('finance@bopingholdings.com', 0, 0, 5, 3, 1),
        ('Group@bopingholdings.com', 0, 0, 5, 3, 1),
        ('licensing@bopingholdings.com', 1, 0, 5, 3, 1),
        ('Licensing@starixsoft.com', 1, 0, 5, 3, 1),
        ('candy.le@starixsoft.com', 0, 1, 5, 3, 1),
        ('qa@starixsoft.com', 1, 1, 5, 3, 1),


        /* Finance, New Product Launch Email, Zelianta */
        ('finance@zelianta.com', 0, 0, 5, 3, 3),
        ('group@zelianta.com', 0, 0, 5, 3, 3),
        ('licensing@starixsoft.com', 1, 0, 5, 3, 3),
        ('licensing@zelianta.com', 1, 0, 5, 3, 3),
        ('candy.le@starixsoft.com', 0, 1, 5, 3, 3),
        ('qa@starixsoft.com', 1, 1, 5, 3, 3),


        /* Finance, New Product Launch Email, Oneworks */
        ('silverbell166@enpine.com', 0, 0, 5, 3, 2),
        ('meiteng@enpine.com', 0, 0, 5, 3, 2),
        ('schang27@enpine.com', 0, 0, 5, 3, 2),
        ('licensing@starixsoft.com', 0, 0, 5, 3, 2),
        ('malcolm@enpine.com', 0, 0, 5, 3, 2),
        ('shyane.cqx@enpine.com', 0, 0, 5, 3, 2),
        ('finance@oneworks.com', 0, 0, 5, 3, 2),
        ('licensing@oneworks.com', 1, 0, 5, 3, 2),
        ('candy.le@starixsoft.com', 0, 1, 5, 3, 2),
        ('qa@starixsoft.com', 1, 1, 5, 3, 2),


        /* Finance, New Product Launch Email, Jollysports */
        ('group@jollysports.com', 0, 0, 5, 3, 4),
        ('licensing@jollysports.com', 1, 0, 5, 3, 4),
        ('candy.le@starixsoft.com', 0, 1, 5, 3, 4),
        ('qa@starixsoft.com', 1, 1, 5, 3, 4),


        /* CSD+TM, Suspended/ Terminated Licensee Email, Boping */
        ('cs@oneonone-solutions.com', 0, 0, 6, 4, 1),
        ('csoneonone@enpine.com', 0, 0, 6, 4, 1),
        ('erica@enpine.com', 0, 0, 6, 4, 1),
        ('licensing@bopingholdings.com', 1, 0, 6, 4, 1),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 4, 1),
        ('candy.le@starixsoft.com', 0, 1, 6, 4, 1),
        ('qa@starixsoft.com', 1, 1, 6, 4, 1),


        /* CSD+TM, Suspended/ Terminated Licensee Email, Zelianta */
        ('cs@oneonone-solutions.com', 0, 0, 6, 4, 3),
        ('csoneonone@enpine.com', 0, 0, 6, 4, 3),
        ('erica@enpine.com', 0, 0, 6, 4, 3),
        ('licensing@zelianta.com', 1, 0, 6, 4, 3),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 4, 3),
        ('candy.le@starixsoft.com', 0, 1, 6, 4, 3),
        ('qa@starixsoft.com', 1, 1, 6, 4, 3),


        /* CSD+TM, Suspended/ Terminated Licensee Email, Oneworks */
        ('cs@oneonone-solutions.com', 0, 0, 6, 4, 2),
        ('csoneonone@enpine.com', 0, 0, 6, 4, 2),
        ('erica@enpine.com', 0, 0, 6, 4, 2),
        ('licensing@oneworks.com', 1, 0, 6, 4, 2),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 4, 2),
        ('candy.le@starixsoft.com', 0, 1, 6, 4, 2),
        ('qa@starixsoft.com', 1, 1, 6, 4, 2),


        /* CSD+TM, Suspended/ Terminated Licensee Email, Jollysports */
        ('cs@jollysports.com', 0, 0, 6, 4, 4),
        ('licensing@jollysports.com', 1, 0, 6, 4, 4),
        ('it@jollysports.com', 1, 0, 6, 4, 4),
        ('candy.le@starixsoft.com', 0, 1, 6, 4, 4),
        ('qa@starixsoft.com', 1, 1, 6, 4, 4),


        /* Legal, Suspended/ Terminated Licensee Email, Boping */
        ('info@bopingholdings.com', 0, 0, 3, 4, 1),
        ('licensing@bopingholdings.com', 1, 0, 3, 4, 1),
        ('candy.le@starixsoft.com', 0, 1, 3, 4, 1),
        ('qa@starixsoft.com', 1, 1, 3, 4, 1),


        /* Legal, Suspended/ Terminated Licensee Email, Zelianta */
        ('owlegal@lexfingsi.com', 0, 0, 3, 4, 3),
        ('licensing@zelianta.com', 1, 0, 3, 4, 3),
        ('candy.le@starixsoft.com', 0, 1, 3, 4, 3),
        ('qa@starixsoft.com', 1, 1, 3, 4, 3),


        /* Legal, Suspended/ Terminated Licensee Email, Oneworks */
        ('owlegal@lexfingsi.com', 0, 0, 3, 4, 2),
        ('licensing@oneworks.com', 1, 0, 3, 4, 2),
        ('candy.le@starixsoft.com', 0, 1, 3, 4, 2),
        ('qa@starixsoft.com', 1, 1, 3, 4, 2),


        /* Finance, Suspended/ Terminated Licensee Email, Boping */
        ('finance@bopingholdings.com', 0, 0, 5, 4, 1),
        ('Group@bopingholdings.com', 0, 0, 5, 4, 1),
        ('Licensing@starixsoft.com', 0, 0, 5, 4, 1),
        ('licensing@bopingholdings.com', 1, 0, 5, 4, 1),
        ('candy.le@starixsoft.com', 0, 1, 5, 4, 1),
        ('qa@starixsoft.com', 1, 1, 5, 4, 1),


        /* Finance, Suspended/ Terminated Licensee Email, Zelianta */
        ('finance@zelianta.com', 0, 0, 5, 4, 3),
        ('group@zelianta.com', 0, 0, 5, 4, 3),
        ('licensing@starixsoft.com', 1, 0, 5, 4, 3),
        ('licensing@zelianta.com', 1, 0, 5, 4, 3),
        ('candy.le@starixsoft.com', 0, 1, 5, 4, 3),
        ('qa@starixsoft.com', 1, 1, 5, 4, 3),


        /* Finance, Suspended/ Terminated Licensee Email, Oneworks */
        ('silverbell166@enpine.com', 0, 0, 5, 4, 2),
        ('meiteng@enpine.com', 0, 0, 5, 4, 2),
        ('schang27@enpine.com', 0, 0, 5, 4, 2),
        ('licensing@starixsoft.com', 0, 0, 5, 4, 2),
        ('malcolm@enpine.com', 0, 0, 5, 4, 2),
        ('shyane.cqx@enpine.com', 0, 0, 5, 4, 2),
        ('finance@oneworks.com', 0, 0, 5, 4, 2),
        ('licensing@oneworks.com', 1, 0, 5, 4, 2),
        ('candy.le@starixsoft.com', 0, 1, 5, 4, 2),
        ('qa@starixsoft.com', 1, 1, 5, 4, 2),


        /* Finance, Suspended/ Terminated Licensee Email, Jollysports */
        ('group@jollysports.com', 0, 0, 5, 4, 4),
        ('licensing@jollysports.com', 1, 0, 5, 4, 4),
        ('candy.le@starixsoft.com', 0, 1, 5, 4, 4),
        ('qa@starixsoft.com', 1, 1, 5, 4, 4),


        /* CSD+TM, Terminated Product Email, Boping */
        ('cs@oneonone-solutions.com', 0, 0, 6, 5, 1),
        ('csoneonone@enpine.com', 0, 0, 6, 5, 1),
        ('erica@enpine.com', 0, 0, 6, 5, 1),
        ('licensing@bopingholdings.com', 1, 0, 6, 5, 1),
        ('Licensing@starixsoft.com', 1, 0, 6, 5, 1),
        ('totti.chen@onelab.tw', 1, 0, 6, 5, 1),
        ('thomas.chou@onelab.tw', 1, 0, 6, 5, 1),
        ('ariel.lin@onelab.tw', 1, 0, 6, 5, 1),
        ('esther.liao@onelab.tw', 1, 0, 6, 5, 1),
        ('aaron.wang@onelab.tw', 1, 0, 6, 5, 1),
        ('tandy.tien@onelab.tw', 1, 0, 6, 5, 1),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 5, 1),
        ('candy.le@starixsoft.com', 0, 1, 6, 5, 1),
        ('qa@starixsoft.com', 1, 1, 6, 5, 1),


        /* CSD+TM, Terminated Product Email, Zelianta */
        ('cs@oneonone-solutions.com', 0, 0, 6, 5, 3),
        ('csoneonone@enpine.com', 0, 0, 6, 5, 3),
        ('erica@enpine.com', 0, 0, 6, 5, 3),
        ('licensing@zelianta.com', 1, 0, 6, 5, 3),
        ('Licensing@starixsoft.com', 1, 0, 6, 5, 3),
        ('totti.chen@onelab.tw', 1, 0, 6, 5, 3),
        ('thomas.chou@onelab.tw', 1, 0, 6, 5, 3),
        ('ariel.lin@onelab.tw', 1, 0, 6, 5, 3),
        ('esther.liao@onelab.tw', 1, 0, 6, 5, 3),
        ('aaron.wang@onelab.tw', 1, 0, 6, 5, 3),
        ('tandy.tien@onelab.tw', 1, 0, 6, 5, 3),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 5, 3),
        ('candy.le@starixsoft.com', 0, 1, 6, 5, 3),
        ('qa@starixsoft.com', 1, 1, 6, 5, 3),


        /* CSD+TM, Terminated Product Email, Oneworks */
        ('cs@oneonone-solutions.com', 0, 0, 6, 5, 2),
        ('csoneonone@enpine.com', 0, 0, 6, 5, 2),
        ('erica@enpine.com', 0, 0, 6, 5, 2),
        ('licensing@oneworks.com', 1, 0, 6, 5, 2),
        ('licenseetm@nextfortune.tw', 1, 0, 6, 5, 2),
        ('Licensing@starixsoft.com', 1, 0, 6, 5, 2),
        ('totti.chen@onelab.tw', 1, 0, 6, 5, 2),
        ('thomas.chou@onelab.tw', 1, 0, 6, 5, 2),
        ('ariel.lin@onelab.tw', 1, 0, 6, 5, 2),
        ('esther.liao@onelab.tw', 1, 0, 6, 5, 2),
        ('aaron.wang@onelab.tw', 1, 0, 6, 5, 2),
        ('tandy.tien@onelab.tw', 1, 0, 6, 5, 2),
        ('candy.le@starixsoft.com', 0, 1, 6, 5, 2),
        ('qa@starixsoft.com', 1, 1, 6, 5, 2),


        /* CSD+TM, Terminated Product Email, Jollysports */
        ('cs@jollysports.com', 0, 0, 6, 5, 4),
        ('licensing@jollysports.com', 1, 0, 6, 5, 4),
        ('it@jollysports.com', 1, 0, 6, 5, 4),
        ('it2@jollysports.com', 1, 0, 6, 5, 4),
        ('candy.le@starixsoft.com', 0, 1, 6, 5, 4),
        ('qa@starixsoft.com', 1, 1, 6, 5, 4),


        /* Legal, Terminated Product Email, Boping */
        ('info@bopingholdings.com', 0, 0, 3, 5, 1),
        ('licensing@bopingholdings.com', 1, 0, 3, 5, 1),
        ('candy.le@starixsoft.com', 0, 1, 3, 5, 1),
        ('qa@starixsoft.com', 1, 1, 3, 5, 1),


        /* Legal, Terminated Product Email, Zelianta */
        ('owlegal@lexfingsi.com', 0, 0, 3, 5, 3),
        ('licensing@zelianta.com', 1, 0, 3, 5, 3),
        ('candy.le@starixsoft.com', 0, 1, 3, 5, 3),
        ('qa@starixsoft.com', 1, 1, 3, 5, 3),


        /* Legal, Terminated Product Email, Oneworks */
        ('owlegal@lexfingsi.com', 0, 0, 3, 5, 2),
        ('licensing@oneworks.com', 1, 0, 3, 5, 2),
        ('candy.le@starixsoft.com', 0, 1, 3, 5, 2),
        ('qa@starixsoft.com', 1, 1, 3, 5, 2),


        /* Finance, Terminated Product Email, Boping */
        ('finance@bopingholdings.com', 0, 0, 5, 5, 1),
        ('Group@bopingholdings.com', 0, 0, 5, 5, 1),
        ('Licensing@starixsoft.com', 0, 0, 5, 5, 1),
        ('licensing@bopingholdings.com', 1, 0, 5, 5, 1),
        ('candy.le@starixsoft.com', 0, 1, 5, 5, 1),
        ('qa@starixsoft.com', 1, 1, 5, 5, 1),


        /* Finance, Terminated Product Email, Zelianta */
        ('finance@zelianta.com', 0, 0, 5, 5, 3),
        ('group@zelianta.com', 0, 0, 5, 5, 3),
        ('licensing@starixsoft.com', 0, 0, 5, 5, 3),
        ('licensing@zelianta.com', 1, 0, 5, 5, 3),
        ('candy.le@starixsoft.com', 0, 1, 5, 5, 3),
        ('qa@starixsoft.com', 1, 1, 5, 5, 3),


        /* Finance, Terminated Product Email, Oneworks */
        ('silverbell166@enpine.com', 0, 0, 5, 5, 2),
        ('meiteng@enpine.com', 0, 0, 5, 5, 2),
        ('schang27@enpine.com', 0, 0, 5, 5, 2),
        ('licensing@starixsoft.com', 0, 0, 5, 5, 2),
        ('malcolm@enpine.com', 0, 0, 5, 5, 2),
        ('shyane.cqx@enpine.com', 0, 0, 5, 5, 2),
        ('finance@oneworks.com', 0, 0, 5, 5, 2),
        ('licensing@oneworks.com', 1, 0, 5, 5, 2),
        ('candy.le@starixsoft.com', 0, 1, 5, 5, 2),
        ('qa@starixsoft.com', 1, 1, 5, 5, 2),


        /* Finance, Terminated Product Email, Jollysports */
        ('group@jollysports.com', 0, 0, 5, 5, 4),
        ('licensing@jollysports.com', 1, 0, 5, 5, 4),
        ('candy.le@starixsoft.com', 0, 1, 5, 5, 4),
        ('qa@starixsoft.com', 1, 1, 5, 5, 4),


        /* OP (INR), Launch Licensee Email, Boping */
        ('edscott@enpine.com', 0, 0, 7, 1, 1),
        ('francishou@enpine.com', 0, 0, 7, 1, 1),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 1, 1),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 1, 1),
        ('candy.le@starixsoft.com', 0, 1, 7, 1, 1),
        ('qa@starixsoft.com', 1, 1, 7, 1, 1),


        /* OP (INR), Launch Licensee Email, Oneworks */
        ('edscott@enpine.com', 0, 0, 7, 1, 2),
        ('francishou@enpine.com', 0, 0, 7, 1, 2),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 1, 2),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 1, 2),
        ('candy.le@starixsoft.com', 0, 1, 7, 1, 2),
        ('qa@starixsoft.com', 1, 1, 7, 1, 2),


        /* OP (INR), Launch Licensee Email, Zelianta */
        ('edscott@enpine.com', 0, 0, 7, 1, 3),
        ('francishou@enpine.com', 0, 0, 7, 1, 3),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 1, 3),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 1, 3),
        ('candy.le@starixsoft.com', 0, 1, 7, 1, 3),
        ('qa@starixsoft.com', 1, 1, 7, 1, 3),


        /* OP (INR), Launch Licensee Email, Jollysports */
        ('edscott@enpine.com', 0, 0, 7, 1, 4),
        ('francishou@enpine.com', 0, 0, 7, 1, 4),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 1, 4),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 1, 4),
        ('candy.le@starixsoft.com', 0, 1, 7, 1, 4),
        ('qa@starixsoft.com', 1, 1, 7, 1, 4),


        /* OP (INR), Relaunch Licensee Email, Boping */
        ('edscott@enpine.com', 0, 0, 7, 2, 1),
        ('francishou@enpine.com', 0, 0, 7, 2, 1),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 2, 1),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 2, 1),
        ('candy.le@starixsoft.com', 0, 1, 7, 2, 1),
        ('qa@starixsoft.com', 1, 1, 7, 2, 1),


        /* OP (INR), Relaunch Licensee Email, Oneworks */
        ('edscott@enpine.com', 0, 0, 7, 2, 2),
        ('francishou@enpine.com', 0, 0, 7, 2, 2),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 2, 2),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 2, 2),
        ('candy.le@starixsoft.com', 0, 1, 7, 2, 2),
        ('qa@starixsoft.com', 1, 1, 7, 2, 2),


        /* OP (INR), Relaunch Licensee Email, Zelianta */
        ('edscott@enpine.com', 0, 0, 7, 2, 3),
        ('francishou@enpine.com', 0, 0, 7, 2, 3),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 2, 3),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 2, 3),
        ('candy.le@starixsoft.com', 0, 1, 7, 2, 3),
        ('qa@starixsoft.com', 1, 1, 7, 2, 3),


        /* OP (INR), Relaunch Licensee Email, Jollysports */
        ('edscott@enpine.com', 0, 0, 7, 2, 4),
        ('francishou@enpine.com', 0, 0, 7, 2, 4),
        ('dfeeney@chromelabtech.com', 0, 0, 7, 2, 4),
        ('fook.lcf@chromelabtech.com', 0, 0, 7, 2, 4),
        ('candy.le@starixsoft.com', 0, 1, 7, 2, 4),
        ('qa@starixsoft.com', 1, 1, 7, 2, 4)