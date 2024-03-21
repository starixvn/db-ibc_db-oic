/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeInfoUpd_Step3]
	@LicenseeId		INT
	,@AMUserId		INT
	,@PMUserId		INT
	,@oldAMUserId	INT
	,@oldPMUserId	INT
	,@AMDisplayName	VARCHAR(50)
	,@PMDisplayName	VARCHAR(50)
	,@LicAccount	XML				= NULL
	,@InternalURL	VARCHAR(3000)	= NULL
	
	,@UserId		INT
	,@Language		VARCHAR(10)		= 'E'
	,@IP			VARCHAR(50)		= NULL
	,@ErrCode		INT				= 0			OUTPUT
	,@ErrMsg		VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 20150505
	Task: Update internal person in charge - Step3 [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20170517@Percy: Add Internal backend URL [RedmineID: #74330]
		- 20170802@Percy: Add Url testing account - add element into @LicAccount [RedmineID: #80712]
		- 20170809@Percy: Extend Url length [RedmineID: #81392]
		- 20240227@Kai: Update data when old data is null [RedmineID: #197581]
	
	Param's Explanation:
	* @LicAccount:
				<root>
					<row order="1" type="1" username="webaccount" password="abc" url="https://" />
					<row order="1" type="2" username="csd" password="1234" url="https://" />
					<row order="1" type="3" username="training" password="12abc" url="https://" />
				</root>
	* @ErrCode:
		= 0: 
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
 */
BEGIN
	SET NOCOUNT ON

	-- Internal Backend URL
	BEGIN TRY
		UPDATE dbo.Licensee WITH(ROWLOCK, UPDLOCK)
		SET InternalURL = @InternalURL
		WHERE LicenseeId = @LicenseeId
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 100
		RETURN
	END CATCH

	DECLARE @tblLicAccount TABLE (UserName NVARCHAR(50), UserPwd NVARCHAR(50), AccountType TINYINT, [Order] TINYINT, Url VARCHAR(3000))
	
	-- Update AM
	IF @oldAMUserId <> @AMUserId OR @oldAMUserId IS NULL
	BEGIN TRY
		DELETE 
		FROM	dbo.UserLicensee WITH(ROWLOCK, UPDLOCK) 
		WHERE	LicenseeId = @LicenseeId 
				AND UserId = @oldAMUserId
		
		INSERT INTO dbo.UserLicensee( UserId, LicenseeId ) VALUES (@AMUserId, @LicenseeId)
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 100
		RETURN
	END CATCH
	
	-- Update PM
	IF @oldPMUserId <> @PMUserId OR @oldPMUserId IS NULL
	BEGIN TRY		
		DELETE 
		FROM	dbo.UserLicensee WITH(ROWLOCK, UPDLOCK) 
		WHERE	LicenseeId = @LicenseeId 
				AND UserId = @oldPMUserId
		
		INSERT INTO dbo.UserLicensee( UserId, LicenseeId ) VALUES (@PMUserId, @LicenseeId)
	END TRY
	BEGIN CATCH
		SELECT @ErrCode = 101
		RETURN
	END CATCH
	
	-- Update Account
	IF @LicAccount IS NOT NULL
	BEGIN TRY
		INSERT INTO @tblLicAccount(
				UserName
				,UserPwd
				,AccountType
				,[Order]
				,Url
		)
		SELECT	t.c.value('@username','nvarchar(50)')
				,t.c.value('@password','nvarchar(50)')
				,t.c.value('@type','tinyint')
				,t.c.value('@order','tinyint')
				,t.c.value('@url','varchar(3000)')
		FROM @LicAccount.nodes('root/row') t(c) 
				
		MERGE	dbo.LicenseeAccountInfo l
		USING	(SELECT * FROM @tblLicAccount) t
			ON	l.[Order] = t.[Order]
				AND l.LicenseeId = @LicenseeId
				AND l.AccountType = t.AccountType
		WHEN MATCHED AND (l.UserName <> t.UserName OR l.UserPwd <> t.UserPwd OR l.Url <> t.Url)
			THEN UPDATE SET l.UserName = t.UserName, l.UserPwd = t.UserPwd, l.Url = t.Url
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (LicenseeId, UserName, UserPwd, AccountType, [Order], Url) VALUES (@LicenseeId, t.UserName, t.UserPwd, t.AccountType, t.[Order], t.Url)
		WHEN NOT MATCHED BY SOURCE AND l.LicenseeId = @LicenseeId THEN DELETE;
	END TRY
	BEGIN CATCH
			SELECT @ErrCode = 102
			RETURN
	END CATCH

	SELECT @ErrCode = 0
END
GO