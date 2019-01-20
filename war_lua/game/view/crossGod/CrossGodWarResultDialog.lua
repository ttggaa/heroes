local CrossGodWarResultDialog = class("CrossGodWarResultDialog", BasePopView)

function CrossGodWarResultDialog:ctor(param)
	CrossGodWarResultDialog.super.ctor(self)
	self._callback = param.callback
end

function CrossGodWarResultDialog:onInit()
	local closeBtn = self:getUI("closeBtn")
	self:registerClickEvent(closeBtn, function()
		UIUtils:reloadLuaFile("crossGod.CrossGodWarResultDialog")
		if self._callback then
            self._callback()
        end
		self:close()
	end)
	self._cGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
	local layer1 = self:getUI("bg.layer1")
    layer1:setVisible(false)
    local layer2 = self:getUI("bg.layer2")
    layer2:setVisible(false)
    local layer4 = self:getUI("bg.layer4")
    layer4:setVisible(false)
    local layer8 = self:getUI("bg.layer8")
    layer8:setVisible(false)

    self._bg = self:getUI("bg")

end

function CrossGodWarResultDialog:reflashUI(data)
    local powId = data.powId
    local balance = 5
    local bgScale = 2
    if powId == 8 then
    elseif powId == 4 then
        bgScale = 1.6
    elseif powId == 2 then
        bgScale = 1.7
    end
    self["updateLayer" .. powId](self)

    local scale1 = cc.ScaleTo:create(0.1, 5)
    local scale2 = cc.ScaleTo:create(0.1, 0.8)
    local spawn = cc.Spawn:create(cc.FadeIn:create(0.1), scale2)
    local scale3 = cc.ScaleTo:create(0.2, 1)
    local seq = cc.Sequence:create(scale1, spawn, scale3)
    self._titleImg:runAction(seq)

    local scale1 = cc.ScaleTo:create(0.1, 0)
    local scale2 = cc.ScaleTo:create(0.1, 1.9, 1.7)
    local spawn = cc.Spawn:create(cc.FadeIn:create(0.1), scale2)
    local scale3 = cc.ScaleTo:create(0.2, 1.8, 1.6)
    local seq = cc.Sequence:create(scale1, spawn, scale3)
    self._titleBg:runAction(seq)

    self._bgImg:setOpacity(0)
    local fade1 = cc.FadeTo:create(0.01, 1)
    local scale1 = cc.ScaleTo:create(0.01, 2, 1)
    local spawn1 = cc.Spawn:create(fade1, scale1)
    local scale2 = cc.ScaleTo:create(0.1, 2, bgScale+0.1)
    local spawn2 = cc.Spawn:create(cc.FadeIn:create(0.1), scale2)
    local scale3 = cc.ScaleTo:create(0.2, 2, bgScale)
    local seq = cc.Sequence:create(spawn1, cc.DelayTime:create(0.1) , spawn2, scale3)
    self._bgImg:runAction(seq)

    self:animBegin(function( )
        self:nextAnimFunc(powId)
    end)
end

function CrossGodWarResultDialog:updateLayer8()
    local powId = 8
    local warData = self._cGodWarModel:getEliminateFightData()[powId]
    local layer8 = self:getUI("bg.layer8")

    self._bgImg = self:getUI("bg.layer8.bg1")
    -- self._bgImg:setVisible(false)
    self._tishi = self:getUI("bg.layer8.tishi")
    self._tishi:setVisible(false)

    self._titleImg = self:getUI("bg.layer8.titleImg")
    self._titleImg:setOpacity(0)
    self._titleBg = self:getUI("bg.layer8.titleBg")
    self._titleBg:setOpacity(0)
    self._layer = layer8
    if not warData then
        return
    end
    self._tipBg = self:getUI("bg.layer8.tipBg")
    -- self._tipBg:setOpacity(0)
    self._tipBg:setVisible(false)
    self._maxLevel = self:getUI("bg.layer8.maxLevel")
    self._maxLevel:setString(lang("crossFight_tips_13"))
    self._maxLevel:setVisible(false)

    layer8:setVisible(true)
    for i=1,4 do
        local indexId = i*2-1
        local atkData = warData[i].player1
        local param1 = {avatar = atkData.avatar, tp = 4, avatarFrame = atkData["avatarFrame"]}
        local headBg = self:getUI("bg.layer8.headBg" .. indexId)
        headBg:setAnchorPoint(0.5, 0.5)
        headBg:setVisible(false)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        headBg:setCascadeOpacityEnabled(true)
        local tname = self:getUI("bg.layer8.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(atkData.name)

        local defData = warData[i].player2
        local param1 = {avatar = defData.avatar, tp = 4,avatarFrame = defData["avatarFrame"]}
        indexId = i*2
        local headBg = self:getUI("bg.layer8.headBg" .. indexId)
        headBg:setVisible(false)
        headBg:setAnchorPoint(0.5, 0.5)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        local tname = self:getUI("bg.layer8.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(defData.name)
        headBg:setCascadeOpacityEnabled(true)
    end
end

function CrossGodWarResultDialog:updateLayer4()
    local powId = 4
    local warData = self._cGodWarModel:getEliminateFightData()[powId]

    local layer = self:getUI("bg.layer4")

    self._bgImg = self:getUI("bg.layer4.bg1")
    -- self._bgImg:setVisible(false)
    self._tishi = self:getUI("bg.layer4.tishi")
    self._tishi:setVisible(false)
    self._titleImg = self:getUI("bg.layer4.titleImg")
    self._titleImg:setOpacity(0)
    self._titleBg = self:getUI("bg.layer4.titleBg")
    self._titleBg:setOpacity(0)
    self._layer = layer

    self._tipBg = self:getUI("bg.layer4.tipBg")
    self._tipBg:setVisible(false)
    self._maxLevel = self:getUI("bg.layer4.maxLevel")
    self._maxLevel:setString(lang("crossFight_tips_14"))
    self._maxLevel:setVisible(false)
    if not warData then
        return
    end
    layer:setVisible(true)
    for i=1,2 do
        local indexId = i*2-1
        local atkData = warData[i].player1
        local param1 = {avatar = atkData.avatar, tp = 4, avatarFrame = atkData["avatarFrame"]}
        local headBg = self:getUI("bg.layer4.headBg" .. indexId)
        headBg:setAnchorPoint(0.5, 0.5)
        headBg:setVisible(false)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        headBg:setCascadeOpacityEnabled(true)
        local tname = self:getUI("bg.layer4.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(atkData.name)

        local defData = warData[i].player2
        local param1 = {avatar = defData.avatar, tp = 4,avatarFrame = defData["avatarFrame"]}
        indexId = i*2
        local headBg = self:getUI("bg.layer4.headBg" .. indexId)
        headBg:setVisible(false)
        headBg:setAnchorPoint(0.5, 0.5)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        local tname = self:getUI("bg.layer4.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(defData.name)
        headBg:setCascadeOpacityEnabled(true)
    end
end

function CrossGodWarResultDialog:updateLayer2()
    local powId = 2
    local warData = self._cGodWarModel:getEliminateFightData()[powId]    --冠亚军数据
    local layer = self:getUI("bg.layer2")

    self._bgImg = self:getUI("bg.layer2.bg1")
    -- self._bgImg:setVisible(false)
    self._vsImg = self:getUI("bg.layer2.vsImg")
    self._vsImg:setVisible(false)
    self._tishi = self:getUI("bg.layer2.tishi")
    self._tishi:setVisible(false)
    self._titleImg = self:getUI("bg.layer2.titleImg")
    self._titleImg:setOpacity(0)
    self._layer = layer
    self._titleBg = self:getUI("bg.layer2.titleBg")
    self._titleBg:setOpacity(0)

    self._tipBg = self:getUI("bg.layer2.tipBg")
    self._tipBg:setVisible(false)
    self._maxLevel = self:getUI("bg.layer2.maxLevel")
    self._maxLevel:setString(lang("crossFight_tips_15"))
    self._maxLevel:setVisible(false)

    self._lab1 = self:getUI("bg.layer2.lab1")
    self._lab1:setColor(cc.c4b(255,252,226,255))
    self._lab1:enable2Color(1, cc.c4b(255,232,125, 255))
    self._lab1:setVisible(false)

    self._lab2 = self:getUI("bg.layer2.lab2")
    self._lab2:setColor(cc.c4b(255,223,117,255))
    self._lab2:enable2Color(1, cc.c4b(188,104,34, 255))
    self._lab2:setVisible(false)

    layer:setVisible(true)
    for i=1,1 do
        local indexId = i*2-1
        local atkData = warData[i].player1
        local param1 = {avatar = atkData.avatar, tp = 4, avatarFrame = atkData["avatarFrame"]}
        local headBg = self:getUI("bg.layer2.headBg" .. indexId)
        -- headBg:setAnchorPoint(0.5, 0.5)
        headBg:setVisible(false)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        headBg:setCascadeOpacityEnabled(true)
        local tname = self:getUI("bg.layer2.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(atkData.name)

        local defData = warData[i].player2
        local param1 = {avatar = defData.avatar, tp = 4,avatarFrame = defData["avatarFrame"]}
        indexId = i*2
        local headBg = self:getUI("bg.layer2.headBg" .. indexId)
        headBg:setVisible(false)
        -- headBg:setAnchorPoint(0.5, 0.5)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        local tname = self:getUI("bg.layer2.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(defData.name)
        headBg:setCascadeOpacityEnabled(true)
    end

    self:updateLayer3()

    self._vsImg1 = self:getUI("bg.layer2.vsImg1")
    self._vsImg1:setVisible(false)
end


function CrossGodWarResultDialog:updateLayer3()
    local powId = 3
    local warData = self._cGodWarModel:getEliminateFightData()[powId]
    local layer = self:getUI("bg.layer2")
    for i=1,1 do
        local indexId = i*2-1+2
        local atkData = warData[i].player1
        local param1 = {avatar = atkData.avatar, tp = 4, avatarFrame = atkData["avatarFrame"]}
        local headBg = self:getUI("bg.layer2.headBg" .. indexId)
        -- headBg:setAnchorPoint(0.5, 0.5)
        headBg:setVisible(false)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        headBg:setCascadeOpacityEnabled(true)
        local tname = self:getUI("bg.layer2.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(atkData.name)

        local defData = warData[i].player2
        local param1 = {avatar = defData.avatar, tp = 4,avatarFrame = defData["avatarFrame"]}
        indexId = i*2+2
        local headBg = self:getUI("bg.layer2.headBg" .. indexId)
        headBg:setVisible(false)
        -- headBg:setAnchorPoint(0.5, 0.5)
        local icon = headBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            -- icon:setPosition(40, 40)
            headBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
        local tname = self:getUI("bg.layer2.headBg" .. indexId .. ".name")
        tname:setScale(0.8)
        tname:setString(defData.name)
        headBg:setCascadeOpacityEnabled(true)
    end
end

function CrossGodWarResultDialog:updateLayer1()
    local layer = self:getUI("bg.layer1")

    self._bgImg = self:getUI("bg.layer1.bg1")
    self._tishi = self:getUI("bg.layer1.tishi")
    self._tishi:setVisible(false)
    self._titleImg = self:getUI("bg.layer1.titleImg")
    self._titleImg:setOpacity(0)
    self._layer = layer

    layer:setVisible(true)

    self._maxLevel = self:getUI("bg.layer1.maxLevel")
    self._maxLevel:setString(lang("GODWARPAI_4"))
    self._maxLevel:setVisible(false)

    local powId = 1
    local warData = self._cGodWarModel:getDispersedData()
    local firstData = warData["r1"]
    if not firstData then
        return
    end
    local atkId = firstData["rid"]
    local skin = firstData["skin"]
    if not atkId then
        return 
    end
    local indexId = 1
    local atkData = self._cGodWarModel:getPlayerById(atkId)
    local param1 = {avatar = atkData.avatar, tp = 4, avatarFrame = atkData["avatarFrame"]}
    local headBg = self:getUI("bg.layer1.headBg" .. indexId)
    headBg:setAnchorPoint(0.5, 0.5)
    headBg:setVisible(false)
    local icon = headBg:getChildByName("icon")
    if not icon then
        icon = IconUtils:createHeadIconById(param1)
        icon:setName("icon")
        headBg:addChild(icon)
    else
        IconUtils:updateHeadIconByView(icon, param1)
    end
    headBg:setCascadeOpacityEnabled(true)
    local tname = self:getUI("bg.layer1.headBg" .. indexId .. ".name")
    tname:setScale(0.8)
    tname:setString(atkData.name)
end

function CrossGodWarResultDialog:nextAnimFunc(powId)
    if powId == 2 then
        self:nextAnimFuncLayer2(powId)
        return
    end
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
  
    ScheduleMgr:delayCall(50, self, function()
        if not self._titleImg then return end
    end)
    ScheduleMgr:delayCall(500, self, function()
        if not self._bg then return end
        local caidai = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", false, true)
        caidai:setPosition(self._bg:getContentSize().width*0.5,self._bg:getContentSize().height*0.5+200)
        self._bg:addChild(caidai,5)
    end)
    ScheduleMgr:delayCall(300, self, function()
        if not self.setPopAnim then
            return
        end
        local layer = self:getUI("bg.layer" .. powId)
        self:setPopAnim(layer, powId)
    end)
    ScheduleMgr:delayCall(800, self, function()
        if not self._maxLevel then return end
        self._maxLevel:setVisible(true)
        self._tipBg:setVisible(true)
    end)
    ScheduleMgr:delayCall(1000, self, function()
        if not self._tishi then return end
        self._tishi:setVisible(true)
        local closeBtn = self:getUI("closeBtn")
        closeBtn:setTouchEnabled(true)
        self._viewMgr:unlock()
    end)
end

function CrossGodWarResultDialog:nextAnimFuncLayer2(powId)
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
  
    -- ScheduleMgr:delayCall(50, self, function()
    --     if not self._titleImg then return end
    --     -- local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
    --     --     sender:removeFromParent()
    --     -- end,RGBA8888)
    --     -- mcShua:setPosition(cc.p(self._titleImg:getContentSize().width*0.5-80, 14))
    --     -- audioMgr:playSound("adTag")
    --     -- self._titleImg:addChild(mcShua)
    -- end)

    ScheduleMgr:delayCall(150, self, function()
        if not self.setPopAnim1 then
            return
        end
        self._lab1:setVisible(true)
    end)

    ScheduleMgr:delayCall(200, self, function()
        if not self.setPopAnim1 then
            return
        end
        local layer = self:getUI("bg.layer" .. powId)
        self:setPopAnim1(layer, powId)
    end)
    ScheduleMgr:delayCall(290, self, function()
        if not self._bg then return end
        local caidai = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", false, true)
        caidai:setPosition(self._bg:getContentSize().width*0.5,self._bg:getContentSize().height*0.5+200)
        self._bg:addChild(caidai,5)
    end)
    ScheduleMgr:delayCall(300, self, function()
        if not self._vsImg then
            return
        end
        local scale1 = cc.ScaleTo:create(0.01, 3)
        local scale2 = cc.ScaleTo:create(0.1, 0.3)
        local scale3 = cc.ScaleTo:create(0.2, 0.4)
        local callFunc = cc.CallFunc:create(function()
            self._vsImg:setVisible(true)
        end)
        local seq = cc.Sequence:create(scale1, callFunc, scale2, scale3)
        self._vsImg:runAction(seq)
    end)
    ScheduleMgr:delayCall(550, self, function()
        if not self.setPopAnim1 then
            return
        end
        self._lab2:setVisible(true)
    end)
    ScheduleMgr:delayCall(600, self, function()
        if not self.setPopAnim2 then
            return
        end
        local layer = self:getUI("bg.layer" .. powId)
        self:setPopAnim2(layer, powId)
    end)
    ScheduleMgr:delayCall(600, self, function()
        if not self._maxLevel then return end
        self._maxLevel:setVisible(true)
        self._tipBg:setVisible(true)
    end)
    ScheduleMgr:delayCall(700, self, function()
        if not self._vsImg1 then
            return
        end
        local scale1 = cc.ScaleTo:create(0.01, 3)
        local scale2 = cc.ScaleTo:create(0.1, 0.3)
        local scale3 = cc.ScaleTo:create(0.2, 0.4)
        local callFunc = cc.CallFunc:create(function()
            self._vsImg1:setVisible(true)
        end)
        local seq = cc.Sequence:create(scale1, callFunc, scale2, scale3)
        self._vsImg1:runAction(seq)
    end)
    ScheduleMgr:delayCall(1000, self, function()
        if not self._tishi then return end
        self._tishi:setVisible(true)
        self._tishi:setVisible(true)
        local closeBtn = self:getUI("closeBtn")
        closeBtn:setTouchEnabled(true)
        self._viewMgr:unlock()
    end)
end

function CrossGodWarResultDialog:animBegin(callback)
    self._bg = self:getUI("bg")

    ScheduleMgr:delayCall(450, self, function( )
        if self._bg then

            if callback and self._bg then
                callback()
            end

        end
    end)
end

function CrossGodWarResultDialog:setPopAnim(inView, powId)
    for i=1,powId do
        local headBg = inView:getChildByFullName("headBg" .. i)
        headBg:setVisible(false)
        headBg:setAnchorPoint(0.5, 0.5)

        local tname = inView:getChildByFullName("headBg" .. i .. ".name")
        tname:setVisible(false)

        local scale1 = cc.ScaleTo:create(0.01, 8)
        local callFunc1 = cc.CallFunc:create(function()
            headBg:setSaturation(-100)
            headBg:setBrightness(100)
            headBg:setVisible(true)
            local mc1 = mcMgr:createViewMC("touxiangkuangguang_godwar", false, true, function()
                if headBg.mc1 then
                    headBg.mc1:removeFromParent()
                end
            end)
            mc1:gotoAndStop(1)
            mc1:setPosition(headBg:getContentSize().width*0.5, headBg:getContentSize().height*0.5)
            mc1:setName("mc1")
            headBg:addChild(mc1, 5)
            headBg.mc1 = mc1
        end)

        local callFunc2 = cc.CallFunc:create(function()
            headBg:setSaturation(0)
            headBg:setBrightness(0)
        end)
        local callFunc3 = cc.CallFunc:create(function()
            tname:setVisible(true)
            if headBg.mc1 then
                headBg.mc1:gotoAndPlay(1)
            end
        end)
        
        local scale2 = cc.ScaleTo:create(0.2, 0.9)
        local scale3 = cc.ScaleTo:create(0.2, 1)
        local seq = cc.Sequence:create(scale1, callFunc1, scale2, callFunc2, scale3, callFunc3)
        headBg:runAction(seq)
    end
end

function CrossGodWarResultDialog:setPopAnim1(inView, powId)
    local headBg1 = inView:getChildByFullName("headBg1")
    local move1 = cc.MoveBy:create(0.01, cc.p(-600, 0))
    local move2 = cc.MoveBy:create(0.05, cc.p(700, 0))
    local move3 = cc.MoveBy:create(0.1, cc.p(-100, 0))
    local callFunc = cc.CallFunc:create(function()
        headBg1:setVisible(true)
    end)
    headBg1:runAction(cc.Sequence:create(move1, callFunc, move2, move3))
    
    local headBg2 = inView:getChildByFullName("headBg2")
    local move1 = cc.MoveBy:create(0.01, cc.p(600, 0))
    local move2 = cc.MoveBy:create(0.05, cc.p(-700, 0))
    local move3 = cc.MoveBy:create(0.1, cc.p(100, 0))
    local callFunc = cc.CallFunc:create(function()
        headBg2:setVisible(true)
    end)
    headBg2:runAction(cc.Sequence:create(move1, callFunc, move2, move3)) 
end

function CrossGodWarResultDialog:setPopAnim2(inView, powId)
    local headBg3 = inView:getChildByFullName("headBg3")
    local move1 = cc.MoveBy:create(0.01, cc.p(-600, 0))
    local move2 = cc.MoveBy:create(0.05, cc.p(700, 0))
    local move3 = cc.MoveBy:create(0.1, cc.p(-100, 0))
    local callFunc = cc.CallFunc:create(function()
        headBg3:setVisible(true)
    end)
    headBg3:runAction(cc.Sequence:create(move1, callFunc, move2, move3))
    
    local headBg4 = inView:getChildByFullName("headBg4")
    local move1 = cc.MoveBy:create(0.01, cc.p(600, 0))
    local move2 = cc.MoveBy:create(0.05, cc.p(-700, 0))
    local move3 = cc.MoveBy:create(0.1, cc.p(100, 0))
    local callFunc = cc.CallFunc:create(function()
        headBg4:setVisible(true)
    end)
    headBg4:runAction(cc.Sequence:create(move1, callFunc, move2, move3)) 
end

return CrossGodWarResultDialog