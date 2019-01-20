--
-- Author: <ligen@playcrab.com>
-- Date: 2017-02-07 19:47:45
--
local HeroDuelFightView = class("HeroDuelFightView", BasePopView)
function HeroDuelFightView:ctor(data)
    HeroDuelFightView.super.ctor(self)

    self._roomData = data.data
    self._callback = data.callback

    self._myData = self._roomData["self"]
    self._enemyData = self._roomData["rival"]

    self._hModel = self._modelMgr:getModel("HeroDuelModel")

    self.popAnim = false
end

function HeroDuelFightView:getBgName()
    return "bg_match.jpg"
end

function HeroDuelFightView:onInit()
--    self:registerClickEventByName("bg", function()
--        self:close()
--        UIUtils:reloadLuaFile("heroduel.HeroDuelFightView")
--    end)

    self._myNode = self:getUI("bg.bgLeft")
    self._enemyNode = self:getUI("bg.bgRight")

    local myFlag = self._myNode:getChildByFullName("flag")
    local enemyFlag = self._enemyNode:getChildByFullName("flag")


    -- 旗子底儿动画
	local redBgMc = mcMgr:createViewMC("youbian_duizhanui", true, false)

    -- 旗子底儿动画
	local blueBgMc = mcMgr:createViewMC("zuobian_duizhanui", true, false)

    local isOffensive = self._hModel:isOffensiveOrder()
    if isOffensive then
        self._enemyNode:getChildByFullName("infoNode.firstIcon"):setVisible(false)

        blueBgMc:setPosition(210, 170)
        self._myNode:addChild(blueBgMc)
        redBgMc:setPosition(220, 230)
        self._enemyNode:addChild(redBgMc)
    else
        self._myNode:getChildByFullName("infoNode.firstIcon"):setVisible(false)

        myFlag:loadTexture("imgFlagRed_heroDuel2.png", 1)
        myFlag:setFlippedX(true)
        enemyFlag:loadTexture("imgFlagBlue_heroDuel2.png", 1)
        enemyFlag:setFlippedX(true)


        redBgMc:setPosition(110, 200)
        self._myNode:addChild(redBgMc)
        blueBgMc:setPosition(320, 200)
        self._enemyNode:addChild(blueBgMc)
    end

    self._myName = self._myNode:getChildByFullName("infoNode.name")
    self._myName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._myName:setString(self._myData.info.name)
--    self._myName:setPositionX(self._myName:getPositionX() + (1136-MAX_SCREEN_WIDTH)*0.5)

    self._myServerName = self._myNode:getChildByFullName("infoNode.serverName")
    self._myServerName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._myServerName:setString(self._modelMgr:getModel("LeagueModel"):getServerName(self._myData.info.sec))
--    self._myServerName:setPositionX(self._myServerName:getPositionX() + (1136-MAX_SCREEN_WIDTH)*0.5)

    self._enemyName = self._enemyNode:getChildByFullName("infoNode.name")
    self._enemyName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._enemyName:setString(self._enemyData.info.name)
--    self._enemyName:setPositionX(self._enemyName:getPositionX() - (1136-MAX_SCREEN_WIDTH)*0.5)

    self._enemyServerName = self._enemyNode:getChildByFullName("infoNode.serverName")
    self._enemyServerName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._enemyServerName:setString(self._modelMgr:getModel("LeagueModel"):getServerName(self._enemyData.info.sec))
--    self._enemyServerName:setPositionX(self._enemyServerName:getPositionX() - (1136-MAX_SCREEN_WIDTH)*0.5)


    self._myRoleNode = self._myNode:getChildByFullName("roleNode")
    self._enemyRoleNode = self._enemyNode:getChildByFullName("roleNode")

    local myHeroD = tab:Hero(self._myData.info.heroId or 60001)
    local myRoleImg = cc.Sprite:create("asset/uiother/hero/" .. myHeroD.crusadeRes ..".png")
    myRoleImg:setScale(1.2)
    myRoleImg:setPosition(50, -20)
    self._myRoleNode:addChild(myRoleImg)

    local enemyHeroD = tab:Hero(self._enemyData.info.heroId or 60001)
    local enemyRoleImg = cc.Sprite:create("asset/uiother/hero/" .. enemyHeroD.crusadeRes ..".png")
    enemyRoleImg:setScale(1.2)
    enemyRoleImg:setPosition(100, -20)
    self._enemyRoleNode:addChild(enemyRoleImg)

    self._vsNode = self:getUI("bg.img_vs")
	self._vsMc = mcMgr:createViewMC("vs_duizhanui", true, false)
	self._vsMc:gotoAndStop(0)
	self._vsMc:setVisible(false)
	self._vsMc:setPosition(cc.p(105,133))
	self._vsNode:addChild(self._vsMc,10)

--    self._vsMc:addCallbackAtFrame(50, function (_, sender)
--        self._vsMc:gotoAndPlay(22)
--    end)

    self._mode = self._hModel:getHeroDuelData("mode")
    ScheduleMgr:delayCall(3000, self, function()
        self._viewMgr:showDialog("heroduel.HeroDuelForbiddenView", {callback = self._callback,mode = self._mode})
        self:close()
    end)

    self._myNode:setPositionX(self._myNode:getPositionX() - 50)
    self._enemyNode:setPositionX(self._enemyNode:getPositionX() + 50)

end

function HeroDuelFightView:onShow()
    self._myNode:runAction(cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(60,0)), 3),
            cc.MoveBy:create(0.07, cc.p(-10,0))
            ))

    self._enemyNode:runAction(cc.Sequence:create(
            cc.EaseOut:create(cc.MoveBy:create(0.1, cc.p(-60,0)), 3),
            cc.MoveBy:create(0.07, cc.p(10,0))
            ))
end
return HeroDuelFightView