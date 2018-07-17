USE [bodb_OIC]
GO

UPDATE dbo.UserLicenseeType
SET Email = 'lmd@enpine.com'
WHERE Email IN ('david@bopingholdings.com', 'jfoo@enpine.com', 'jack@bopingholdings.com', 'kai.chang@oneworks.com', 'nick.chen@oneworks.com', 'justin.foo@oneworks.com', 'martin.jr@oneworks.com');