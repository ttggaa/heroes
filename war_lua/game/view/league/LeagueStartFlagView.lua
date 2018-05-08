--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-18 11:43:08
--
local LeagueStartFlagView = class("LeagueStartFlagView",BasePopView)
function LeagueStartFlagView:ctor()
    self.super.ctor(self)
end

function LeagueStartFlagView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueStartFlagView:onInit()
	self:registerClickEvent(self:getUI("bg"),function() 
		self:close(true)
		UIUtils:reloadLuaFile("league.LeagueStartFlagView")
	end)

	self._flag = self:getUI("bg.flag")

	local batchId = self._modelMgr:getModel("LeagueModel"):getData().batchId
	local leagueActD = tab.leagueAct[tonumber(batchId)]
	if not leagueActD then
		leagueActD = tab.leagueAct[2016101]
	end
	-- 副标题
	self._subTitle = self:getUI("bg.flag.subTitle")
	self._subTitle:setFontName(UIUtils.ttfName_Title)
	local seasonNum = self._modelMgr:getModel("LeagueModel"):getData().season or 1
	self._subTitle:setString("第".. (seasonNum or leagueActD.num or "1") .. "届")
	-- 助战英雄
	local heroId = leagueActD.freehero[1]
	local sysHeroData = tab:Hero(tonumber(heroId))
	local heroName = lang(sysHeroData.heroname)
	self._name = self:getUI("bg.flag.name")
	self._name:setFontName(UIUtils.ttfName_Title)
	self._name:setColor(cc.c3b(255,211,44))
	self._name:enable2Color(2, cc.c4b(246, 147, 42, 255))
	self._name:enableOutline(cc.c4b(27, 12, 4, 255), 1)
	self._name:setString(heroName or "")

	self._desLab = self:getUI("bg.flag.desLab")
	self._desLab:getVirtualRenderer():setMaxLineWidth(250)
	self._desLab:setString("英雄".. (heroName or "") .."前来助战，请领主大人入场参战！")
	local icon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
	icon:setPosition(self._flag:getContentSize().width/2,self._flag:getContentSize().height/2)
	if icon:getChildByFullName("starBg") then
		icon:getChildByFullName("starBg"):removeFromParent()
	end
	if icon:getChildByFullName("iconStar") then
		icon:getChildByFullName("iconStar"):removeFromParent()
	end
	-- icon:setVisible(false)
	icon:setName("icon")
	self._flag:addChild(icon)
end

-- 第一次进入调用, 有需要请覆盖
function LeagueStartFlagView:onShow()

end

-- 接收自定义消息
function LeagueStartFlagView:reflashUI(data)
	self._flag:setOpacity(0)
	self._flag:setCascadeOpacityEnabled(true)
	-- 适配
	self._flag:setPositionY(MAX_SCREEN_HEIGHT+200)
	self._flag:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.MoveTo:create(0.1,cc.p(480,MAX_SCREEN_HEIGHT)),
			cc.FadeIn:create(0.1)
		)
	))
end

return LeagueStartFlagView