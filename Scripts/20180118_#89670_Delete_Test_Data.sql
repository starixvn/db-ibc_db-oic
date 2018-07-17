USE [bodb_OIC]
GO

DELETE FROM dbo.AmendmentTicket
WHERE MessageID IN (
    SELECT MessageID FROM AmendmentMessage
    WHERE Status = 2);

DELETE FROM AmendmentMessage
WHERE Status = 2;