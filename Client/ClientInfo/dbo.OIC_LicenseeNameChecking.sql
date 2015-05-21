USE [bodb_OIC]
GO
/****** Object:  StoredProcedure [dbo].[OIC_LicenseeNameChecking]    Script Date: 04/16/2015 14:22:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Stored Procedure dbo.OIC_LicenseeNameChecking    Script Date: 16/04/2015 9:22:41 AM ******/
ALTER PROCEDURE [dbo].[OIC_LicenseeNameChecking]
	@SiteName	VARCHAR(50)
	,@Language	VARCHAR(10)		= 'E'
	,@ErrCode	INT				= 0			OUTPUT
	,@ErrMsg	VARCHAR(300)	= NULL		OUTPUT
AS
/*
	Created by: Kathy
	Date: 2015-01-15
	Task: Checking licensee name [Redmine:#27752]
	DB: DBOIC.bodb_OIC
	
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