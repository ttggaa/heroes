--不存在方法，只存变量
--服务端应该能重写这张表
local globalAddress =
{
	-- 1. 开发服务器
	"http://172.16.148.213/gits/war_global/index.php?mod=global&sdk_type=Dev",
	-- 2. 文化部审核服务器	
	"http://117.121.10.238:8081/index.php?mod=global&channel=direct",	
	-- 3. 育碧体验服
	"http://117.121.26.143:8083/index.php?mod=global&channel=direct",
	-- 4. 性能测试服
	"http://117.121.26.143:8092/index.php?mod=global&channel=direct",

	"http://172.16.42.102:8003/index.php?mod=global&channel=direct",
}
GameStatic = { 
	version             = "1.0.216",
    walleVersion        = "0",
	
	language            = "cn", -- "cn", "en"
	languageKey			= "", 

	httpAddress_global = globalAddress[5],

	-- 公告获取开关
	openNotice			= true,
	httpAddress_notice  = "http://global.wartx.war.playcrab.com/index.php", -- 公告服务器
	
    sharePicUrl  = "http://dlied5.qq.com/yxwd/cdn/yxwd.jpg",


	ipAddress           = "",       -- 通过http协议获取
	sec                 = "",
    serverName          = "",

    -- 自动重连次数
    autoReconnectCount  = 1,

	lua_model 			= 1,    		-- (默认不需要调整，game.conf中版本号存在自动为release版本)
										-- 1 dev, 2release 用于ios或android 走内网

    -- 显示点击动画
    showClickMc         = true,

	showLuaError        = OS_IS_WINDOWS or OS_IS_IPHONE_SIMULATOR,
	showDEBUGInfo		= false,
	showLockDebug 		= false,

	-- 关闭游戏中所有日志
	closeLog			= not (OS_IS_WINDOWS or OS_IS_IPHONE_SIMULATOR),
	openDebugLog  		= true,	--关闭游戏中debug日志  print
	openServerLog 		= true,	--关闭服务端传输日志   
	openDumpLog   		= true,	--关闭所有dump         dump

    normalAnimInterval 	= 1 / 60,	
    battleAnimInterval1  = 1 / 30, 
    battleAnimInterval2  = 1 / 60, 

    -- 上传lua报错开关
    playcrab_Lua_error = true,
    -- 上传打点信息开关
    playcrab_Monitor = true,
    
    -- 上传特殊纹理特征
    upload_max_texture_size_4096 = true,

    openAllSystem       = false,
    -- vip充值开关
    openVipRecharge = true,

    -- 设备引导开关
    deviceGuideOpen     = true,

    -- 设置
    setting_PowerSaving = false,
    setting_ClickEff = true,
    setting_PushPhysic = true,


    -- 是否检查静态配置表
    checkTable          = true,
    kickTable 			= false, 

    -- 战中数据检查, 以及处理措施
    checkZuoBi_1 		= true,
    kickZuoBi_1         = false, 

    -- 检查model数据
    checkZuoBi_3  		= true,
    kickZuoBi_3 		= false,

    -- 检查战斗时间
    checkZuoBi_4  		= true,
    kickZuoBi_4 		= false,

    -- 检查战斗中英雄属性
    checkZuoBi_5        = true,
    kickZuoBi_5         = false,

    -- 检查战斗中兵团单次最大伤害
    checkZuoBi_6_value  = 20000000,
    checkZuoBi_6        = false,
    kickZuoBi_6         = false,

    -- 检查战后英雄技能
    checkZuoBi_7        = true,
    kickZuoBi_7         = false,

    -- 检查英雄技能等级
    checkZuoBi_8_value  = 50,
    checkZuoBi_8        = true,
    kickZuoBi_8         = true,

    -- 竞技场服务器结算名次
    arenaServerRank     = 100,

    -- 战前检查数据表, 失败就退出战斗
    checkZuoBi_battleBegin = true,
    -- 战后检查战中属性, 战中数据表, 战斗时间, 战斗血量, 失败就退出战斗
    checkZuoBi_battleEnd = true,

    -- 显示引导debug
    showGuideDebug      = nil,

    -- 是否开启SDK
    enableSDK = not OS_IS_WINDOWS,

    -- 显示服务器时间和本地时间
    showServerTime = OS_IS_WINDOWS or OS_IS_IPHONE_SIMULATOR,

    -- 超级debug开关, 特定设备+url传入参数才可开启
    superDebug = false, -- "playcrab19870515" 为开启

    -- 控制台
    consoleMaxLine = 3000,
    consoleBgAlpha = 128,
    consoleFontSize = 12,
    consoleWidth = 0, -- 相对于半个屏幕的参数

    -- 设备引导控制key，变更后就可以让所有玩家重新跑设备引导
    deviceGuideKey_Video = "playVideo_v001",
    deviceGuideKey_Enable = "unloginGuideEnable_v001",
    deviceGuideKey_Index = "unloginGuideIndex_v001",

    -- 问卷调查地址
    questionOpen = false,

    questionCount = 1,

    question1Level = 99,
    question1Begin = 0,
    question1End = 96*360000,
    questionAddress1 = "https://ue.qq.com/mur/?a=survey&b=13667&c=2&d=95984469a634f8d5c1f785a51304d26e",

    question2Level = 30,
    question2Begin = 96*3600 + 1,
    question2End = 168*3600, 
    questionAddress2 = "https://ue.qq.com/mur/?a=survey&b=12570&c=2&d=55550c4592c412ee1fced7afc7fbba31",

    question3Level = 40,
    question3Begin = 168*3600 + 1,
    question3End = 192*3600, 
    questionAddress3 = "https://ue.qq.com/mur/?a=survey&b=12571&c=2&d=73ff64d6e513ac92a65f27df2851dc0f",

    -- qq内嵌会员地址
    qqVipAddress = "https://mq.vip.qq.com/m/game/vipembed?",

    -- httpDns
    useHttpDns_Vms = true,
    useHttpDns_Update = false,
    useHttpDns_Global = true,
    useHttpDns_Notice = true,
    useHttpDns_GameServer = true,

    -- 重新获取GS的方式
    -- 1：固定间隔时间
    -- 2：onSombra
    reqGameStaticType = 2,
    -- mainView onTop时候重新获取GameStatic的时间间隔
    reqGameStaticInv = 3600,

    -- vms, global plan B
    use_vmsExPort = false,
    use_globalExPort = false,

    vms_port = 80,
    global_port = 8080,

    -- dump ios fps
    dumpFPS_ios = false,

    -- tss
    useTss = true,

    -- gsdk
    useGsdk = false,
    useGsdk_SetEvent = true,
    useGsdk_Start_End = true,
    useGsdk_Pay = true,

    -- gsdk2.0
    useGsdk2_ios = true,
    useGsdk2_ios_SetEvent = true,
    useGsdk2_ios_Start_End = false,
    useGsdk2_ios_User = false,

    useGsdk2_android = true,
    useGsdk2_android_SetEvent = true,
    useGsdk2_android_Start_End = false,
    useGsdk2_android_User = false,

    -- sr
    SR_HeartInv = 6000,

    -- 安全日志
    useSR = true,

    -- 战斗FPS模式
    BattleFpsMode = 1,

    -- 特殊账号登陆，临时存放
    specialAccount = "",

    userSimpleChannel = "default",

    --在windows上是否能充值
    openVipInWindows = OS_IS_WINDOWS,

    -- 上传状态码
    uploadErrorCode = false,

    -- getIP, 状态码上传的时候, 获取IP
    useGetIP = false,
    useGetIP_url = "http://ip.6655.com/ip.aspx?area=1",
    useGetIP_timeout = 1,

    -- 登录重力感应
    loginAccelerometer = true,

    -- 开发工具
    enableDevelop = OS_IS_WINDOWS,

    -- 游戏圈Url
    wxGroupUrl = "https://game.weixin.qq.com/cgi-bin/h5/static/circle/index.html?jsapi=1&appid=wx33464fb7d79e5bef&auth_type=2&ssid=12",

    -- 部落Url
    qqGroupUrl = "https://buluo.qq.com/cgi-bin/bar/qqgame/handle_ticket?redirect_url=https://buluo.qq.com/mobile/barindex.html?bid=354791&from=share_copylink",

    -- 微信交流url 
    wxDiscussUrl = "https://game.weixin.qq.com/cgi-bin/comm/openlink?noticeid=90074497&appid=wx33464fb7d79e5bef&url=https://game.weixin.qq.com/cgi-bin/h5/static/group/index.html?appid=wx33464fb7d79e5bef&group=1",

    --微信礼包url
    wxGiftUrl = "https://game.weixin.qq.com/cgi-bin/comm/openlink?noticeid=90074497&appid=wx33464fb7d79e5bef&url=https://game.weixin.qq.com/cgi-bin/h5/static/group/index.html?appid=wx33464fb7d79e5bef&group=1#wechat_redirect",

    -- QQ会员特权
    qqPrivilegeUrl = "https://mq.vip.qq.com/m/game/vipembed?",

    -- 心悦特权
    xinyuePrivilegeUrl = "https://xinyue.qq.com/builtin.shtml?code=",

    -- 微社区
    weiSheQuUrl = "https://yxwd.qq.com/ingame/all/index.shtml",

    -- 关注公众
    wxPublicUrl = "https://w.url.cn/s/AHCnEOm",
    wxPublicUrlIOS = "https://w.url.cn/s/AHCnEOm",

    qqGiftsCenterUrl = "https://imgcache.qq.com/gc/gamecenterV2/dist/index/gift/search_gift.html?_wv=1031&_wwv=4&appid=1105405983&apptype=1&ADTAG=game.gift.yingxiongwudi",

    -- 微信推广员
    wxTuiGuangYuanUrl = "https://game.weixin.qq.com/cgi-bin/comm/openlink?noticeid=90090004&appid=wx33464fb7d79e5bef&url=https://game.weixin.qq.com/cgi-bin/h5/static/act_mhzx_promotion/yxwd_main_h1.html&auth_type=2&partition=%s&roleid=%s&rolename=%s",
   
    -- 微信邀请有礼
    wxInviteUrl = "https://game.weixin.qq.com/cgi-bin/comm/openlink?noticeid=90107818&appid=wx33464fb7d79e5bef&url=https%3A%2F%2Fgame.weixin.qq.com%2Fcgi-bin%2Factnew%2Fnewportalact%2F107912%2FKlG_cNBbamBB0z7-6XAXew%2Fmain_page%3Fact_id%3D107912%26k%3DKlG_cNBbamBB0z7-6XAXew%26pid%3Dmain_page%23wechat_redirect#wechat_redirect",
    -- qq邀请有礼
    qqInviteUrl = "https://youxi.vip.qq.com/m/act/2b83426abe_yxwd_229116.html?_wv=1&_wwv=4&ADTAG=adtag.linshi.one",
   
    -- 龙珠直播URL
    longzhuLiveUrl = "http://cf.tga.plu.cn/gourl_04",

    -- 腾讯大王卡URL
    tencentCardUrl = "https://m.10010.com/queen/tencent/heroes-invincible.html?channel=73",

    -- 华夏银行URL
    huaxiaBankUrl = "http://www.ylxqgo.com/Luckdraw/tulong.html",

    -- 腾讯游戏许可及服务协议Url
    contractUrl = "https://game.qq.com/contract.shtml",
    -- 隐私政策Url
    privacyUrl = "https://www.tencent.com/en-us/zc/privacypolicy.shtml",
    -- 服务条款Url
    serviceUrl = "https://www.tencent.com/en-us/zc/termsofservice.shtml",

    -- 是否开启副本弹幕
    showIntanceBullet = true,

    -- 是否开启聊天语音功能
    useGVoice = true,

    -- 大R客服地址
    CustomService_topPay_qq_url = "https://wpa.b.qq.com/cgi/wpa.php?ln=1&key=XzgwMDA3NDAzN180NTkwMDRfODAwMDc0MDM3XzJf",

    -- 登录失败帮助客服地址
    CustomService_login_android_url     = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf3846&platform=14",
    CustomService_login_ios_url         = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf3844&platform=15",

    -- 设置帮助客服地址
    CustomService_setting_android_url   = "https://kf.qq.com/touch/scene_product.html?scene_id=kf3838&platform=14",
    CustomService_setting_ios_url       = "https://kf.qq.com/touch/scene_product.html?scene_id=kf3838&platform=15",

    -- 设置充值失败客服地址
    CustomService_recharge_android_url  = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf3842&platform=14",
    CustomService_recharge_ios_url      = "https://kf.qq.com/touch/scene_faq.html?scene_id=kf3840&platform=15",

    --评论引导ios跳转
    CommentGuide_ios_url                = "https://itunes.apple.com/cn/app/id1187834455",

    --CDK兑换码
    CDK_qq_url                          = "https://yxwd.qq.com/act/agile2_114676/index.html?appid=1105405983&logtype=q",
    CDK_wx_url                          = "https://yxwd.qq.com/act/agile2_114676/index.html?appid=wx33464fb7d79e5bef&logtype=wx",

    --广告 微信游戏好礼
    AD_wxGame_url                       = "https://game.weixin.qq.com/cgi-bin/h5/static/acts/appstore97.html",
    --广告 心悦运营圈
    AD_xinyueClub_url                   = "https://apps.game.qq.com/xyapp/h5/jump/app_download",

    -- 苹果审核
    appleExamine = false,

    -- 腾讯手游助手登录四平台
    TxGameAssistant_login = false, 

    -- cdn下载
    CDN_checkMD5 = false,
    CDN_https = false,
    -- CDN_cdncer = "static/cdn.cer",

    --===========================================================================
    --  功能类开关
    --===========================================================================
    -- 关闭某个view 格式 "bag.BagView:team.TeamListView", 以:分割
    systemClose = nil,
    -- 让某个btn无响应 格式 "main.MainView.root.bg.midBg1.chouka:main.MainView.root.bg.midBg1.market"
    btnClose = nil,

    closeTip = nil,

    -- 检查android作弊
    android_cheat = "io.virtualapp:va-native",

    -- 测试机列表
    test_device = "80783CDC-0ED6-43D5-92D0-0B08D6AABB7C",

    -- 禁用设备
    -- ！！！！！！设备id有些机型是一样的，比如c806a8bf9cdcc814，搞的时候要特别谨慎
    forbid_device = nil,

    -- 上传复盘失败结果
    upload_fupan_failed = true,

    -- 主城版本
    -- mainViewVer = 1, -- 废弃
    -- 主城节日，小旗子
    mainViewJieRi = false,
    -- 中秋节
    mainViewJieRi2 = false,
    -- 圣诞节
    mainViewJieRi3 = false,
    -- 主程特殊版本
    mainViewSpecialVer = 4,

    diantai_show = false,
    diantai_roomName = "T2xCmNhz_1507893899783",
    diantai_Name = "英雄无敌电台",

    -- diantai_url1 = "https://gfm.gcloud.qq.com:10001/apollofm/api/v1/get_fm_play_info?fm_name=英雄无敌电台01&appid=642421921&appkey=c355f27ba12d9443ab5e37853728ab49&ckey=7f7328f8d47b83fd628d1feefbb5cd05",
    -- diantai_url2 = "https://gfm.gcloud.qq.com:10001/apollofm/api/v1/get_anchor_room_info?appid=642421921&appkey=c355f27ba12d9443ab5e37853728ab49&ckey=7f7328f8d47b83fd628d1feefbb5cd05",
    diantai_url3 = "https://gfm.gcloud.qq.com:10001/apollofm/api/v1/get_anchor_info",
    diantai_url3_param1="642421921",
    diantai_url3_param2="c355f27ba12d9443ab5e37853728ab49",
    diantai_url3_param3="9773524128471737528",
    diantai_url3_param4="7f7328f8d47b83fd628d1feefbb5cd05",

    is_show_realName = true,
}
