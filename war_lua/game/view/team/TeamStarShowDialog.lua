--[[
    Filename:    TeamStarShowDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-29 20:56:45
    Description: File description
--]]

-- local AnimAP = require "base.anim.AnimAP"
local TeamStarShowDialog = class("TeamStarShowDialog", BasePopView)
local AnimAp = require "base.anim.AnimAP"
function TeamStarShowDialog:ctor(param)
    TeamStarShowDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._teamId = param.teamId or 104
end

-- function TeamStarShowDialog:onComplete()

--     self._viewMgr:enableScreenWidthBar()
-- end

-- function TeamStarShowDialog:onPopEnd()
--     self._viewMgr:enableScreenWidthBar()
-- end

-- function TeamStarShowDialog:onDestroy()
--     self._viewMgr:disableScreenWidthBar()
--     TeamStarShowDialog.super.onDestroy(self)
-- end


function TeamStarShowDialog:onInit()
    self._closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(self._closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamStarShowDialog")
        end
        self:close()
    end)
    self._closeBtn:setTouchEnabled(false)
    local closeTip = self:getUI("bg.closeTip")
    closeTip:setVisible(false)

    self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    if MAX_SCREEN_WIDTH > 1136 then
        self._widget:setContentSize(1136, MAX_SCREEN_HEIGHT)
    end

    local teamD = tab:Team(self._teamId)
    local race = tab:Race(teamD["race"][1])

    local bg1 = self:getUI("bg1")
    bg1:setOpacity(0)
    bg1:setVisible(true)
    local bgImg = ccui.ImageView:create()
    bgImg:setName("bgImg")
    bgImg:setScale(1.4)
    bgImg:loadTexture("asset/uiother/race/race_bg_" .. race.pic .. ".jpg", 0)
    bgImg:setAnchorPoint(0.5, 0.5)
    bgImg:setPosition(bg1:getContentSize().width*0.5, bg1:getContentSize().height*0.5)
    bg1:addChild(bgImg, -1)

    local raceBg = self:getUI("bg2.Image_218.Image_219")
    raceBg:loadTexture("teamImageUI_race_" .. race.pic .. ".png", 1)

    for i=1,3 do
        local nameLab = self:getUI("bg2.nameLab" .. i)
        local potentialAttrTab = tab:PotentialAttr(i)
        local str = lang(potentialAttrTab.name)
        nameLab:setString(str)
        nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    end

end

function TeamStarShowDialog:reflashUI()
    local bg1 = self:getUI("bg1")
    bg1:setAnchorPoint(0.5, 0)
    local mc1 = mcMgr:createViewMC("qiannengjihuo_teamqianneng", false, true)
    mc1:setPosition(bg1:getContentSize().width*0.5, 150)
    bg1:addChild(mc1, 20)

    local teamId = self._teamId
    local teamD = tab:Team(teamId)
    local teamArt = teamD.art 

    -- dump(AnimAp, "AnimAp==========")
    local teamScale = {906}
    if AnimAp["mcList"][teamD.art] then
        MovieClipAnim.new(bg1, teamD.art, function (_sp) 
            _sp:setPosition(bg1:getContentSize().width*0.5, 130)
            _sp:changeMotion(1)
            if table.indexof(teamScale, teamId) ~= false then
                _sp:setScale(0.5)
            else
                _sp:setScale(0.3)
            end
            _sp:play()
            self._teamRole = _sp
        end, false, nil, nil, false)
    else
        SpriteFrameAnim.new(bg1, teamD.art, function (_sp)
            _sp:setPosition(bg1:getContentSize().width*0.5, 130)
            _sp:changeMotion(1)
            _sp:play()
            self._teamRole = _sp
        end)
    end
    local mc2 = mcMgr:createViewMC("qiannengguangxiao_teamqianneng", true, false)
    mc2:setScale(teamD.artzoom*0.01)
    mc2:setPosition(bg1:getContentSize().width*0.5, 170)
    bg1:addChild(mc2, 20)

    local scale = cc.ScaleTo:create(2, 1.3)
    local move1 = cc.MoveBy:create(0.5, cc.p(-200, 0))
    local callFunc1 = cc.CallFunc:create(function()
        local mc1 = mcMgr:createViewMC("yahei_teamqianneng", false, false)
        mc1:setName("anim")
        mc1:setPosition(bg1:getContentSize().width*0.5, 150)
        mc1:setScale(0.8)
        bg1:addChild(mc1, 1)
    end)
    local seq = cc.Sequence:create(scale, cc.DelayTime:create(1), move1, callFunc1)
    bg1:runAction(seq)


    -- 遮罩动画
    local callFunc1 = cc.CallFunc:create(function()
        if self._teamRole then
            self._teamRole:changeMotion(3, nil, function()
                self._teamRole:changeMotion(1)
            end)
        end
    end)
    local callFunc2 = cc.CallFunc:create(function()
    end)
    local bmask = self:getUI("bg1.bmask")
    -- bmask:setVisible(true)
    bmask:setOpacity(0)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.2), 
        cc.FadeTo:create(1.2, 150),
        callFunc1,
        cc.FadeOut:create(0.5), 
        cc.DelayTime:create(1), 
        callFunc2)
    bmask:runAction(seq)


    -- 旗帜动画
    local callFunc1 = cc.CallFunc:create(function()
        local wenzi = self:getUI("bg2.wenzi")
        wenzi:setVisible(true)
        local seq = cc.Sequence:create(cc.ScaleTo:create(0, 2), cc.ScaleTo:create(0.1, 0.8), cc.ScaleTo:create(0.2, 1))
        wenzi:runAction(seq)
    end)
    local callFunc2 = cc.CallFunc:create(function()
        local hstar1 = self:getUI("bg2.hstar1")
        hstar1:setVisible(true)
        local mc1 = mcMgr:createViewMC("jihuoguangxiao_teamqianneng", false, true)
        mc1:setPosition(hstar1:getContentSize().width*0.5, hstar1:getContentSize().height*0.5)
        hstar1:addChild(mc1, 1)
        local mc1 = mcMgr:createViewMC("qiangzhuang_teamqianneng", true, false)
        mc1:setPosition(hstar1:getContentSize().width*0.5, hstar1:getContentSize().height*0.5-1)
        hstar1:addChild(mc1, -1)
    end)
    local callFunc3 = cc.CallFunc:create(function()
        local hstar2 = self:getUI("bg2.hstar2")
        hstar2:setVisible(true)
        local mc1 = mcMgr:createViewMC("jihuoguangxiao_teamqianneng", false, true)
        mc1:setPosition(hstar2:getContentSize().width*0.5, hstar2:getContentSize().height*0.5)
        hstar2:addChild(mc1, 1)
        local mc1 = mcMgr:createViewMC("lingqiao_teamqianneng", true, false)
        mc1:setPosition(hstar2:getContentSize().width*0.5, hstar2:getContentSize().height*0.5-1)
        hstar2:addChild(mc1, -1)
    end)
    local callFunc4 = cc.CallFunc:create(function()
        local hstar3 = self:getUI("bg2.hstar3")
        hstar3:setVisible(true)
        local mc1 = mcMgr:createViewMC("jihuoguangxiao_teamqianneng", false, true)
        mc1:setPosition(hstar3:getContentSize().width*0.5, hstar3:getContentSize().height*0.5)
        hstar3:addChild(mc1, 1)
        local mc1 = mcMgr:createViewMC("xinzhi_teamqianneng", true, false)
        mc1:setPosition(hstar3:getContentSize().width*0.5, hstar3:getContentSize().height*0.5-1)
        hstar3:addChild(mc1, -1)
    end)
    local callFunc5 = cc.CallFunc:create(function()
        self._closeBtn:setTouchEnabled(true)
        local closeTip = self:getUI("bg.closeTip")
        closeTip:setVisible(true)
    end)
    local callFunc = cc.CallFunc:create(function()
        local bg2 = self:getUI("bg2")
        bg2:setVisible(true)
    end)
    local bg2 = self:getUI("bg2")
    bg2:setVisible(false)
    local wenzi = self:getUI("bg2.wenzi")
    wenzi:setVisible(false)
    local hstar1 = self:getUI("bg2.hstar1")
    hstar1:setVisible(false)
    local hstar2 = self:getUI("bg2.hstar2")
    hstar2:setVisible(false)
    local hstar3 = self:getUI("bg2.hstar3")
    hstar3:setVisible(false)
    bg2:setCascadeOpacityEnabled(true)
    local move1 = cc.MoveBy:create(0, cc.p(0, 720))
    local move2 = cc.MoveBy:create(0.2, cc.p(0, -720))
    local seq = cc.Sequence:create(move1,
        cc.DelayTime:create(4), 
        callFunc,
        move2,
        cc.DelayTime:create(0.1), 
        callFunc1, 
        cc.DelayTime:create(0.2), 
        callFunc2, 
        cc.DelayTime:create(0.2), 
        callFunc3, 
        cc.DelayTime:create(0.2), 
        callFunc4, 
        cc.DelayTime:create(0.2), 
        callFunc5)
    bg2:runAction(seq)
end

return TeamStarShowDialog