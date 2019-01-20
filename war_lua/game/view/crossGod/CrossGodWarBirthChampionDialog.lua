--[[
    Filename:    CrossGodWarBirthChampionDialog.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-29 21:01:29
    Description: File description
--]]


-- 冠军诞生
local CrossGodWarBirthChampionDialog = class("CrossGodWarBirthChampionDialog", BasePopView)

function CrossGodWarBirthChampionDialog:ctor(param)
    CrossGodWarBirthChampionDialog.super.ctor(self)
    self._callback = param.callback
    self.popAnim = false
end

function CrossGodWarBirthChampionDialog:onInit()
    self:registerClickEventByName("closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("crossGod.CrossGodWarBirthChampionDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)  
    local goldIcon = ccui.ImageView:create()
    goldIcon:setName("goldIcon")
    goldIcon:loadTexture("asset/bg/bg_godwar_005.jpg")
    goldIcon:setContentSize(80, 80)
    goldIcon:ignoreContentAdaptWithSize(false)

    local titleLab = self:getUI("playerBg.titleBg.titleLab")
    titleLab:setColor(cc.c3b(252, 244, 197))

    local guanjun = self:getUI("playerBg.champBg.guanjun")
    guanjun:setColor(cc.c3b(255, 253, 253))
    guanjun:enable2Color(1, cc.c4b(253, 229, 175, 255))
    guanjun:setFontSize(24)

    local bg = self:getUI("bg.bg")
    bg:loadTexture("asset/bg/bg_godwar_005.jpg", 0)
    bg:setVisible(true)

    local teamBg = self:getUI("teamBg")
    teamBg:setVisible(true)

    local angel = self:getUI("teamBg.angel")
    angel:loadTexture("asset/bg/bg_godwar_006.png", 0)
    
    local devil = self:getUI("teamBg.devil")
    devil:loadTexture("asset/bg/bg_godwar_007.png", 0)

    local maxLevel = self:getUI("playerBg.maxLevel")
    maxLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._cGodWarModel = self._modelMgr:getModel("CrossGodWarModel")

    self._bg = self:getUI("bg")
end


function CrossGodWarBirthChampionDialog:reflashUI(data)
    self:updateLayer1()
    -- self._viewMgr:lock(-1)
    local headBg = self:getUI("playerBg.headBg")
    -- headBg:setAnchorPoint(0.5, 0.5)
    headBg:setScale(0)
    local champBg = self:getUI("playerBg.champBg")
    champBg:setVisible(false)

    local scale = cc.ScaleTo:create(0.02, 0.5)
    local callFunc = cc.CallFunc:create(function()
        self:setAnim()
        champBg:setVisible(true)
        local move1 = cc.MoveBy:create(0, cc.p(0, -20))
        local move2 = cc.MoveBy:create(0.2, cc.p(0, 20))
        local seq1 = cc.Sequence:create(move1, move2)
        champBg:runAction(seq1)
    end)
    local scale1 = cc.ScaleTo:create(0.2, 1)
    local callFunc1 = cc.CallFunc:create(function()
        UIUtils:shakeWindow(self)
    end)

    local seq = cc.Sequence:create(scale, callFunc, scale1, callFunc1)
    headBg:runAction(seq)

    self:animBegin(function( )
        self:nextAnimFunc(1)   
    end)

end

function CrossGodWarBirthChampionDialog:setAnim()
    local angel = self:getUI("teamBg.angel")
    local devil = self:getUI("teamBg.devil")
    local move1 = cc.MoveBy:create(0.3, cc.p(20, 0))
    local move2 = cc.MoveBy:create(0.3, cc.p(-20, 0))
    local seq1 = cc.Sequence:create(cc.MoveBy:create(0, cc.p(300, 0)),cc.MoveBy:create(0.15, cc.p(-320, 0)), move1)
    local seq2 = cc.Sequence:create(cc.MoveBy:create(0, cc.p(-300, 0)),cc.MoveBy:create(0.15, cc.p(320, 0)), move2)
    angel:runAction(seq2) 
    devil:runAction(seq1) 

    local playerBg = self:getUI("playerBg")
    local caidai = mcMgr:createViewMC("zhongjianguang_guanjundansheng", false, false)
    caidai:setPosition(playerBg:getContentSize().width*0.5,playerBg:getContentSize().height*0.5)
    caidai:setScale(1.3)
    playerBg:addChild(caidai,-1)

    local animBg = self:getUI("animBg")
    local dingguang = mcMgr:createViewMC("dingguang_guanjundansheng", false, true)
    dingguang:setPosition(animBg:getContentSize().width*0.5,MAX_SCREEN_HEIGHT)
    animBg:addChild(dingguang,1)

    local dingguang = mcMgr:createViewMC("guanjundansheng_guanjundansheng", false, false)
    dingguang:setPosition(animBg:getContentSize().width*0.5,animBg:getContentSize().height-80)
    animBg:addChild(dingguang)

    local titleBg = self:getUI("playerBg.titleBg")
    local titleLab = self:getUI("playerBg.titleBg.titleLab")
    local leftAdorn = self:getUI("playerBg.titleBg.leftAdorn")
    local rightAdorn = self:getUI("playerBg.titleBg.rightAdorn")
    titleLab:setVisible(false)
    leftAdorn:setVisible(false)
    rightAdorn:setVisible(false)
    titleBg:setOpacity(0)
    local callFunc = cc.CallFunc:create(function()
        local dianfengduijue = mcMgr:createViewMC("dianfengduijue_guanjundansheng", false, true)
        dianfengduijue:setPosition(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5)
        titleBg:addChild(dianfengduijue,1)
    end)
    local callFunc1 = cc.CallFunc:create(function()
        titleLab:setVisible(true)
        leftAdorn:setVisible(true)
        rightAdorn:setVisible(true)
    end)
    -- local scale = cc.ScaleTo:create(0.02, 1, 1)
    local fade = cc.FadeIn:create(0.2)
    local spawn = cc.Spawn:create(fade)
    local seq = cc.Sequence:create(cc.DelayTime:create(0.4), callFunc, cc.DelayTime:create(0.15), callFunc1, spawn)
    titleBg:runAction(seq)


    local caidai = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
    caidai:setPosition(animBg:getContentSize().width*0.5,animBg:getContentSize().height*0.5+200)
    animBg:addChild(caidai,5)
end


function CrossGodWarBirthChampionDialog:nextAnimFunc()

    ScheduleMgr:delayCall(200, self, function()
        if not self._bg then return end
        local maxLevel = self:getUI("playerBg.maxLevel")
        maxLevel:setVisible(true)
        maxLevel:setOpacity(0)
        maxLevel:runAction(cc.FadeIn:create(0.3))
    end)

    ScheduleMgr:delayCall(300, self, function()
        if not self._bg then return end
        self._tishi:setVisible(true)
        self._tishi:setOpacity(0)
        self._tishi:runAction(cc.FadeIn:create(0.3))
        local closeBtn = self:getUI("closeBtn")
        closeBtn:setTouchEnabled(true)
        self._viewMgr:unlock()
    end)
end

function CrossGodWarBirthChampionDialog:animBegin(callback)
    self._bg = self:getUI("bg")

    -- self:addPopViewTitleAnim(self._bg, "jinshengchenggong_huodetitleanim", 568, 480)

    ScheduleMgr:delayCall(450, self, function( )
        if self._bg then
            if callback and self._bg then
                callback()
            end
        end
    end)
end

function CrossGodWarBirthChampionDialog:getMaskOpacity()
    return 230
end


function CrossGodWarBirthChampionDialog:updateLayer1()
    local layer = self:getUI("playerBg")

    self._bgImg = self:getUI("playerBg.bg1")
    self._tishi = self:getUI("playerBg.tishi")
    self._tishi:setVisible(false)
    -- self._titleImg = self:getUI("playerBg.titleImg")
    -- self._titleImg:setOpacity(0)
    self._layer = layer

    layer:setVisible(true)

    self._maxLevel = self:getUI("playerBg.maxLevel")
    self._maxLevel:setString(lang("crossFight_tips_16"))
    self._maxLevel:setVisible(false)

    local powId = 1
    local rankListData = self._cGodWarModel:getPlayerRankData()
    local indexId = 1
    local atkData = rankListData[1]
    local param1 = {avatar = atkData.avatar, tp = 4, avatarFrame = atkData["avatarFrame"]}
    local headBg = self:getUI("playerBg.headBg")
    local icon = headBg:getChildByName("icon")
    if not icon then
        icon = IconUtils:createHeadIconById(param1)
        icon:setName("icon")
        icon:setScale(1.4)
        headBg:addChild(icon)
    else
        IconUtils:updateHeadIconByView(icon, param1)
    end
    headBg:setCascadeOpacityEnabled(true)
    local tname = self:getUI("playerBg.headBg.name")
    tname:setString(atkData.name)
    tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

end

return CrossGodWarBirthChampionDialog
