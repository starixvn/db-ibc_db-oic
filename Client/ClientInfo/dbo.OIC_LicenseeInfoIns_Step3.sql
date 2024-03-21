/*<info serverAlias="DBOIC-bodb_OIC" executers="wsv_nap" viewers="" isFunction="0" isNested="1"></info>*/

ALTER PROCEDURE [dbo].[OIC_LicenseeInfoIns_Step3]
	@UserId				INT
	,@LicenseeId		INT
	,@AMUserId			INT				
	,@PMUserId			INT				
	,@LicAccount		XML				= NULL
	,@InternalURL		VARCHAR(3000)	= NULL
	
	,@Language			VARCHAR(10)		= 'E'
	,@IP				VARCHAR(50)		= NULL
	,@ErrCode			INT				= 0			OUTPUT
	,@ErrMsg			VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2014-12-22
	Task: Internal Person in Charge - Step3 [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
	Revisions:
		- 20170517@Percy: Add Internal backend URL [RedmineID: #74330]
		- 20170802@Percy: Add Url testing account - add element into @LicAccount [RedmineID: #80712]
		- 20170809@Percy: Extend Url length [RedmineID: #81392]
		- 20240305@Kai: Skip insert data when AMUserId, PMUserId is null [RedmineID: #197581]
	
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
	UPDATE dbo.Licensee WITH(ROWLOCK, UPDLOCK)
	SET InternalURL = @InternalURL
	WHERE LicenseeId = @LicenseeId

	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrCode = 100
		RETURN
	END
	
	-- Insert AM
	IF @AMUserId IS NOT NULL
	BEGIN 
		INSERT INTO dbo.UserLicensee(UserId, LicenseeId) VALUES (@AMUserId, @LicenseeId)
	END
	
	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrCode = 100
		RETURN
	END
	
	-- Insert PM
	IF @PMUserId IS NOT NULL
	BEGIN
		INSERT INTO dbo.UserLicensee(UserId, LicenseeId) VALUES (@PMUserId, @LicenseeId)
	END

	IF @@ERROR <> 0
	BEGIN
		SELECT @ErrCode = 101
		RETURN
	END
	
	-- Insert Account
	IF @LicAccount IS NOT NULL
	BEGIN
		INSERT INTO dbo.LicenseeAccountInfo (
				LicenseeId
				,UserName
				,UserPwd
				,AccountType
				,[Order]
				,Url
		)
		SELECT	@LicenseeId
				,t.c.value('@username','nvarchar(50)')
				,t.c.value('@password','nvarchar(50)')
				,t.c.value('@type','tinyint')
				,t.c.value('@order','tinyint')
				,t.c.value('@url','varchar(3000)')
		FROM @LicAccount.nodes('root/row') t(c) 
		
		IF @@ERROR <> 0
		BEGIN
			SELECT @ErrCode = 102
			RETURN
		END
	END

	SELECT @ErrCode = 0
END
GO