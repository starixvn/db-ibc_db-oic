/*<info serverAlias="DBOIC-bodb_OIC"></info>*/
USE bodb_OIC
GO

/*
	Created: 20210601@Hogan
	DB: DBOIC.bodb_OIC
	Task: Update the launched date of Vgaming and Sports Lottery product [RedmineID: #156232]
*/

UPDATE dbo.LicenseeProduct WITH (ROWLOCK, UPDLOCK)
	SET LaunchDate = '2021-06-08'
FROM dbo.Product p WITH(NOLOCK)
	INNER JOIN dbo.LicenseeProduct lp ON p.ProductId = lp.ProductId
	INNER JOIN dbo.Licensee l WITH(NOLOCK) ON l.LicenseeId = lp.LicenseeId
Where p.ProductName LIKE 'Vgaming'
	AND lp.LaunchDate = '2021-06-01'
	AND l.RegisteredLicenseeName IN ('11bet','12Bet','18Luck','24AVIA','365online','368Cash','396Club','3star88','7kplatform','818Bet',
									'88Macao','9Club','ab6688','Abcasino','Ae88','AEUG','AG','allwincity','ALPHA88','Alphalota',
									'ANGbet','AnvoFH','AOGcasino','B24VN','BBIN3','bdtt','BETSUN','BigGaming','Bobbet','BOG22',
									'Boying','Bsdbet','BWGaming','Callmeboss','CGame','CGame4','Champion','Comebet','Datang001','Dawoo',
									'Debet','DEWA','DF88','dj888','e8casino','ECBet88','ECLBET','erhaozhan','Fabet','FB88',
									'Five88','GAMEBee','GamingSoft','Gampag','Gaobet','GGBOOK','GMASTER','GPIGAME','HC6YAYOU','Heaven',
									'Hecbet','Happy1668','Hejiyongle','HL8','HonorW','HOT99','HuangMa','iBET','ID88','IGPTech',
									'IONclub','ISC888','JIBET','IBO','Kzing2','Leng4D','Liga','liv66','KeenOcean','Lode88',
									'Lucky88','M8Credit','MANBETX','ManCity','mansion88','MAX88','Mayayule','Mybet88','Nbbet','Nbet',
									'One88','Onegaming','OPEBET','OXbet','Pinbo','PKbet','Saba789','Senibet','Sin88','Sky88',
									'Soon88','Sunwin','TangChao','TaoCai','TCbet','TGO','Tianbo','Tripleone','TT128','TYCgame',
									'US8YAYOU','Uwoniwin','VCBA','VN88','W88','WABET','WBS','win365','Winbox','WINCLUB88',
									'wmcasino','XTDGT','Xtu168','YTX','Yunji','Zbet','NewFuture','ZhiFeng009','ZhiFeng012','ZhiFeng021',
									'ZhiFeng032','ZhiFeng035','ZhiFeng036','ZhiFeng040','zt828')

UPDATE dbo.LicenseeProduct WITH (ROWLOCK, UPDLOCK)
	SET LaunchDate = '2021-05-27'
FROM dbo.Product p WITH(NOLOCK)
	INNER JOIN dbo.LicenseeProduct lp ON p.ProductId = lp.ProductId
	INNER JOIN dbo.Licensee l WITH(NOLOCK) ON l.LicenseeId = lp.LicenseeId
Where p.ProductName LIKE 'Sports Lottery'
	AND l.LicenseeName IN ('11bet','12BET','18Luck','24AVIA','365online','368CASH','396Club','3ge888','3STAR88','568Win',
							'633esports','7kplatform','818Bet','88MACAO','9BET','9CLUB','A1game','ab6688','ABCASINO','AE88',
							'AEUG','AG','allwincity','Alpha88','Alphalota','ANGbet','AnvoFH','AOGcasino','AONCASH','AWC',
							'awc2','B24VN','Baji','BBIN','BBIN2','BBIN3','bdtt','BE7','BETSUN','BigGaming',
							'Bobo88','BOG22','Bolanation','BOMA365','Bonanza88','Boying','BPLE','Bsdbet','BWGaming','Callmeboss',
							'CGame','CGame4','Champion','Comebet','Datang001','Dawoo','DBP','Debet','DEWA','DF88',
							'Diamond','DingTai','dj888','e8casino','ECBet88','ECLBET','erhaozhan','Fabet','FB88','Five88',
							'FUN88','GAMEBee','GAMINGSOFT','Gampag','Gaobet','gbkj','GESAB','GMaster','GPIgame','HC6YAYOU',
							'Heaven','HECBET','HEJI (HAPPY168)','Hejiyongle','hjccasino','HL8','HONORW','HOT99','HuangMa','iBET',
							'ID88','IGPTech','INSERTGAME','IONClub','ISC888','ITCBET','JIBET','JZFortune','Kzing','Kzing2',
							'Leng4D','LIGA','liv66','LIVV88 (KEENOCEAN)','Lode88','Lucky88','M8BOLA','M8Credit','MACAUBET','ManCity',
							'MARS','MAX88','Mayayule','MICL','Monaco','Mopgaming','MTech','mtegames','Mybet88','MYGAME',
							'N88','N8B','N8BK','N8G','Nbbet','Nbet','OCMS','Okada','OLE777','One88',
							'Onegaming','Opal88','OPEbet','OXbet','OYO','Pinbo','PKbet','pmwint','Q8BOLA','Raisetech',
							'Red88','ROYAL','Saba789','SDY','SENIBET','shengboyun','Sin88','Sky88','Soon88','spondemo',
							'Sunriseb2b','Sunwin','SV88','TangChao','TaoCai','TCbet','TGO','TLC','TopGame','Tripleone',
							'TSEnter','TT128','txwl002','TYCgame','UNOBET','US8YAYOU','Uwoniwin','VCBA','VN88','W88',
							'WABET','Wanbo','WBS','weicai','win365','Winbox','WINCLUB88','WKCUR','WKPHIL','wmcasino',
							'Xinbo','XTDGT','Xtu168','Yibo','YongBao','YTX','Yunji','Zbet','ZFRT081','ZFRT082',
							'ZFRT125','ZFRT132','ZFRT133','ZFRT142','ZFRT150','ZFRTW','ZhiFeng009','ZhiFeng012','ZhiFeng027','ZhiFeng032',
							'ZhiFeng035','ZhiFeng036','ZhiFeng040','Zowin','zt828')