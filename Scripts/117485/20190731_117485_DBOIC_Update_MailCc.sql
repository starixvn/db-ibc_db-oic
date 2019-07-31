USE bodb_OIC
GO

/*
	Created: 20190731@Howard
	DB: DBOIC.bodb_OIC
	Task: Update mail of TM to mail cc [RedmineID: #117485]
*/

DECLARE @LicenseeId INT, @LicenseeName VARCHAR(100), @LicenseeTypeName VARCHAR(100)
DECLARE @tblLicensees TABLE (LicenseeId INT, LicenseeName VARCHAR(100), LicenseeTypeName VARCHAR(100))

INSERT INTO @tblLicensees
SELECT l.LicenseeId, l.LicenseeName, lt.LicenseeTypeName 
FROM dbo.Licensee l
	INNER JOIN dbo.LicenseeType lt 
		ON l.LicenseeTypeId = lt.LicenseeTypeId AND lt.LicenseeTypeName = 'ONEWorks API'
				
DECLARE @BusinessCursor AS CURSOR
SET @BusinessCursor = CURSOR FOR
SELECT * FROM @tblLicensees

OPEN @BusinessCursor

FETCH NEXT FROM @BusinessCursor INTO @LicenseeId, @LicenseeName, @LicenseeTypeName

WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE @CategoryId INT = 0
		
		SELECT @CategoryId = c.CategoryId
		FROM dbo.Category c 
		WHERE c.CategoryName = 'API Notification'
		
		IF @LicenseeTypeName = 'ONEWorks API'
			BEGIN
				IF EXISTS(SELECT * FROM dbo.LicenseeCategoryAssigned l
							WHERE l.LicenseeId = @LicenseeId AND l.CategoryId = @CategoryId)
						BEGIN
								DECLARE @ContactId INT = 0
								
								SELECT @ContactId = c.ContactId 
								FROM Contact c
								WHERE c.LicenseeId = @LicenseeId AND c.ContactName = 'LicenseePM'
										AND c.ContactEmail = 'licenseepm@onelab.tw'
										
								IF @ContactId <> 0 -- contact existed
								   BEGIN
										 -- check exist on mailcc
										IF NOT EXISTS (SELECT * FROM dbo.CategoryContact cc 
														WHERE cc.ContactId = @ContactId 
															AND cc.CategoryId = @CategoryId 
															AND cc.RecipientType = 1) -- cc
											BEGIN
												PRINT 'CONTACT EXIST - RecipientType = 1'
												-- update contact to mailcc
												DECLARE @SelectedCc VARCHAR(10) = ''
												SELECT @SelectedCc = CONVERT(VARCHAR(10), @ContactId)
												EXEC dbo.OIC_LicenseeCategoryUpd 
														@LicenseeId = @LicenseeId,
														@CategoryId = @CategoryId,
														@SelectedCc = @SelectedCc,
														@UserId = 0
												
											END
								    END
								 ELSE 
									BEGIN
										PRINT 'INSERT'
										
										-- insert contact to mailcc
										DECLARE @SelectedCategories VARCHAR(100) = '<root><row id="' + CAST(@CategoryId AS VARCHAR(10)) + '"' + ' type="1" /></root>'
										SELECT @SelectedCategories = CONVERT(XML, @SelectedCategories)
										
										EXEC dbo.OIC_LicenseeContactIns 
												@UserId = 0,
												@LicenseeId =  @LicenseeId,
												@ContactType = 1,
												@ContactName = 'LicenseePM',
												@Position = 'N/A',
												@Department = 'N/A',
												@Email = 'licenseepm@onelab.tw',
												@Skype = 'N/A',
												@SelectedCategories = @SelectedCategories	
									END
						END
			END
	    ELSE IF (@LicenseeTypeName = 'Zelianta Athena' OR @LicenseeTypeName = 'Zelianta API')
			BEGIN
				PRINT 'FALSE'
			END
		ELSE IF (@LicenseeTypeName = 'Boping Athena' OR @LicenseeTypeName = 'Boping API')
			BEGIN
				PRINT 'FALSE'
			END 
	    
		FETCH NEXT FROM @BusinessCursor INTO @LicenseeId, @LicenseeName, @LicenseeTypeName
	END
	
	
CLOSE @BusinessCursor;
DEALLOCATE @BusinessCursor;

