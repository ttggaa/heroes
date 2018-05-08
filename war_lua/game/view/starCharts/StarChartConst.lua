--[[
 	@FileName 	StarChartConst.lua
	@Authors 	zhangtao
	@Date    	2018-03-13 20:13:31
	@Email    	<zhangtao@playcrad.com>
	@Description   描述
--]]
StarChartConst = {}
StarChartConst.CommonType = 0
StarChartConst.NormalType = 1
StarChartConst.AwardType = 2
StarChartConst.UnKnownType = 3
StarChartConst.CenterType = 4


--全局属性列表间距
StarChartConst.Distance = 35
StarChartConst.AbilityHeroSort = 1   --1：英雄上场生效
StarChartConst.AbilityAllSort = 2    --2：全局生效

--星体加成类型
-- 1：英雄
-- 2：兵团
-- 3：系统
-- 4：特殊
StarChartConst.HeroAdd = 1
StarChartConst.TeamAdd = 2
StarChartConst.SysteamAdd = 3
StarChartConst.SpecialAdd = 4


StarChartConst.typeByValue = {
[110] = 1,
[113] = 2,
[116] = 3,
[119] = 4
}


StarChartConst.qualityType = {
[110] = "[全局]英雄攻击:",
[113] = "[全局]英雄防御:",
[116] = "[全局]英雄智力:",
[119] = "[全局]英雄知识:"
}
StarChartConst.showsort = {
[1] = "starCharts_common.png",  --铜
[2] = "starCharts_xiyou.png",	--银
[3] = "starCharts_ji.png",		--奖励
[4] = "starCharts_reward.png"	--金
}
StarChartConst.QualityType110 = 110
StarChartConst.QualityType113 = 113
StarChartConst.QualityType116 = 116
StarChartConst.QualityType119 = 119

StarChartConst.QualityTypeTab = {
    [1] = lang("SHOW_ATTR_110"),
    [2] = lang("SHOW_ATTR_113"),
    [3] = lang("SHOW_ATTR_116"),
    [4] = lang("SHOW_ATTR_119")
}

StarChartConst.SatrChainType = 0 	-- 星链激活
StarChartConst.SatrCompletedType = 1-- 构成成功

StarChartConst.DetailsType1 = 0 	-- 星图成长率
StarChartConst.DetailsType2 = 1 	-- 育成成长率
StarChartConst.DetailsType3 = 2 	-- 星图魂力说明

StarChartConst.NOTOPEN = true 		--构成是否开启