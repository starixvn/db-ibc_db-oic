ALTER PROCEDURE [dbo].[OIC_LicenseeNameChecking]
	@SiteName	VARCHAR(50)
	,@Language	VARCHAR(10)		= 'E'
	,@ErrCode	INT				= 0			OUTPUT
	,@ErrMsg	VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2015-01-15
	Task: Checking licensee name
	DB: DBOIC/BODB_OIC 
	
	Revisions:
	
	Param's Explanation:
	* @ErrCode:
		= 0: 
		> 0: Specific Error.
  
	* @ErrMsg: Error description.
	
 */
BEGIN
	SET NOCOUNT ON
	
	IF EXISTS(SELECT TOP 1 1 FROM dbo.Licensee WITH(NOLOCK) WHERE LicenseeName = @SiteName)
	BEGIN
		SELECT @ErrCode = 99
			,@ErrMsg = [dbo].[f_Get_MsgNamebyMsgID](4,@Language) -- The site name is already used. Please try another name.
		RETURN
	END
	
END




GO
GRANT EXECUTE ON [dbo].[OIC_LicenseeNameChecking] TO [bodbAdminNet] AS [dbo]