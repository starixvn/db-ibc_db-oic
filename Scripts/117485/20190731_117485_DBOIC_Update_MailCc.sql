USE bodb_OIC
GO

/*
	Created: 20190731@Howard
	DB: DBOIC.bodb_OIC
	Task: Update mail of TM to mail cc [RedmineID: #117485]
*/
	
DECLARE @CategoryId INT = 0

SELECT @CategoryId = c.CategoryId
FROM dbo.Category c WITH(NOLOCK)
WHERE c.CategoryName = 'API Notification'

IF @CategoryId <> 0
BEGIN 
	DECLARE @LicenseeId INT, @LicenseeName VARCHAR(100), @LicenseeTypeName VARCHAR(100)
	DECLARE @ContactName NVARCHAR(50), @ContactEmail NVARCHAR(50)
	DECLARE @tblLicensees TABLE (LicenseeId INT, LicenseeName VARCHAR(100), LicenseeTypeName VARCHAR(100))

	INSERT INTO @tblLicensees
	SELECT l.LicenseeId, l.LicenseeName, lt.LicenseeTypeName 
	FROM dbo.Licensee l WITH(NOLOCK)
		INNER JOIN dbo.LicenseeType lt  WITH(NOLOCK)
			ON l.LicenseeTypeId = lt.LicenseeTypeId
		INNER JOIN dbo.LicenseeStatus ls WITH(NOLOCK)
			ON l.LicenseeStatusId = ls.LicenseeStatusId
	WHERE lt.LicenseeTypeName IN ('ONEWorks API',
								  'Zelianta Athena',
								  'Zelianta API',
								  'Boping Athena',
								  'Boping API')
			AND ls.LicenseeStatusName IN ('Upcoming',
										'Soft Launch',
										'Active',
										'Cancelled',
										'Suspended')
								  
	DECLARE @BusinessCursor AS CURSOR
	SET @BusinessCursor = CURSOR FOR
	SELECT * FROM @tblLicensees

	OPEN @BusinessCursor

	FETCH NEXT FROM @BusinessCursor INTO @LicenseeId, @LicenseeName, @LicenseeTypeName

	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF EXISTS(SELECT * FROM dbo.LicenseeCategoryAssigned l
								WHERE l.LicenseeId = @LicenseeId AND l.CategoryId = @CategoryId)
				BEGIN
									IF @LicenseeTypeName = 'ONEWorks API'
										BEGIN
											SET @ContactName = 'LicenseePM'
											SET @ContactEmail = 'licenseepm@onelab.tw'
										END 
									ELSE IF (@LicenseeTypeName = 'Zelianta Athena' OR @LicenseeTypeName = 'Zelianta API')
										BEGIN
											SET @ContactName = 'LicenseePM'
											SET @ContactEmail = 'it@zelianta.com'
										END
									ELSE IF (@LicenseeTypeName = 'Boping Athena' OR @LicenseeTypeName = 'Boping API')
										BEGIN
											SET @ContactName = 'LicenseePM'
											SET @ContactEmail = 'licensingpm@bopingholdings.com'
										END 
										
									DECLARE @ContactId INT = 0
									
									SELECT @ContactId = c.ContactId 
									FROM Contact c
									WHERE c.LicenseeId = @LicenseeId AND c.ContactEmail = @ContactEmail
											
									IF @ContactId <> 0 -- contact existed
									   BEGIN
											-- check exist on mailcc
											IF NOT EXISTS (SELECT * FROM dbo.CategoryContact cc WITH(NOLOCK)
															WHERE cc.ContactId = @ContactId 
																AND cc.CategoryId = @CategoryId 
																AND cc.RecipientType = 1) -- cc
												BEGIN
													PRINT 'UPDATE'
													-- update old contact to mailcc
													
													DECLARE @SelectedTo VARCHAR(500) = ''
													DECLARE @SelectedCc VARCHAR(500) = ''
													
													SELECT @SelectedTo = ISNULL(STUFF((SELECT ',' + CAST(cc.ContactId AS VARCHAR(10))
																						FROM dbo.CategoryContact cc WITH(NOLOCK)
																						WHERE cc.ContactId <> @ContactId AND cc.ContactId 
																										IN (SELECT c.ContactId
																											FROM Contact c WITH(NOLOCK)
																											WHERE c.LicenseeId = @LicenseeId)
																							 AND cc.CategoryId = @CategoryId AND  cc.RecipientType = 0
																						FOR XML PATH('')), 1, 1, ''), '')
																						
													SELECT @SelectedCc = STUFF((SELECT ',' + CAST(cc.ContactId AS VARCHAR(10))
																				FROM dbo.CategoryContact cc WITH(NOLOCK)
																				WHERE cc.ContactId IN (SELECT c.ContactId
																										FROM Contact c WITH(NOLOCK)
																										WHERE c.LicenseeId = @LicenseeId)
																						AND cc.CategoryId = @CategoryId AND  cc.RecipientType = 1
																				FOR XML PATH('')), 1, 1, '')
																				
													SET @SelectedCc = ISNULl(@SelectedCc + ',', '') + CAST(@ContactId AS VARCHAR(10))
													
													EXEC dbo.OIC_LicenseeCategoryUpd 
															@LicenseeId = @LicenseeId,
															@CategoryId = @CategoryId,
															@SelectedTo = @SelectedTo,
															@SelectedCc = @SelectedCc,
															@UserId = -1
												END
										END
									 ELSE 
										BEGIN
											PRINT 'INSERT'
											
											-- insert new contact to mailcc
											DECLARE @SelectedCategories VARCHAR(100) = '<root><row id="' + CAST(@CategoryId AS VARCHAR(10)) + '"' + ' type="1" /></root>'
											
											EXEC dbo.OIC_LicenseeContactIns 
													@UserId = -1,
													@LicenseeId =  @LicenseeId,
													@ContactType = 1,
													@ContactName = @ContactName,
													@Position = 'N/A',
													@Department = 'N/A',
													@Email = @ContactEmail,
													@Skype = 'N/A',
													@SelectedCategories = @SelectedCategories	
										END
				END
		    
			FETCH NEXT FROM @BusinessCursor INTO @LicenseeId, @LicenseeName, @LicenseeTypeName
		END
		
		
		CLOSE @BusinessCursor
		DEALLOCATE @BusinessCursor
 END
 ELSE
	BEGIN
		PRINT 'Category doesn not exist'
	END
					
