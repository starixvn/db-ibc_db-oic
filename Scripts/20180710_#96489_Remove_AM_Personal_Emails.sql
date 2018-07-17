USE [bodb_OIC]
GO

UPDATE dbo.UserLicenseeType
SET Email = 'lmd@enpine.com'
WHERE Email IN ('nick@zelianta.com', 'kai@zelianta.com');