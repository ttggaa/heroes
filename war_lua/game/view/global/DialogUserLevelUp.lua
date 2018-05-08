--[[
    Filename:    DialogUserLevelUp.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-08-21 17:28:18
    Description: File description
--]]

local DialogUserLevelUp = class("DialogUserLevelUp",BasePopView)
function DialogUserLevelUp:ctor(data)
    DialogUserLevelUp.super.ctor(self)
    self._openNum = 0
end

function DialogUserLevelUp:getMaskOpacity()
    return 230
end

-- 第一次被加到父节点时候调用
function DialogUserLevelUp:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function DialogUserLevelUp:onInit()
    -- local closeBtn = self:getUI("closePanel")
    -- registerClickEvent(closeBtn, function()        
    --     print("=======registerClickEvent---------===")
    --     self:close()
    --     UIUtils:reloadLuaFile("global.DialogUserLevelUp")
    -- end)

    -- local des1 = self:getUI("bg.layer.des1")
    -- des1:setColor(cc.c4b(255,252,226,255))
    -- des1:enable2Color(1, cc.c4b(255, 232, 125, 255))
    -- des1:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    -- local des2 = self:getUI("bg.layer.des2")
    -- des2:setColor(cc.c4b(255,252,226,255))
    -- des2:enable2Color(1, cc.c4b(255, 232, 125, 255))
    -- des2:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    -- local des3 = self:getUI("bg.layer.des3")
    -- des3:setColor(cc.c4b(255,252,226,255))
    -- des3:enable2Color(1, cc.c4b(255, 232, 125, 255))
    -- des3:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    for i=1,2 do
        local des = self:getUI("bg.layer.show" .. i .. ".des")
        des:setColor(cc.c4b(255,252,226,255))
        des:enable2Color(1, cc.c4b(255, 232, 125, 255))
        des:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    end

    local closePanel = self:getUI("closePanel")
    local callfunc = cc.CallFunc:create(function()
        if self._actionOpen == true then
            self:setActionOpen()
        end
        UIUtils:reloadLuaFile("global.DialogUserLevelUp")
        self:close()
    end)
    local callfunc1 = cc.CallFunc:create(function()
        closePanel.useTimeFin = true
        closePanel:setTouchEnabled(false)
    end)
    local seq = cc.Sequence:create(cc.DelayTime:create(2.5),callfunc1,cc.DelayTime:create(2.5), callfunc)
    closePanel:runAction(seq)

    self._actionOpen = false
    self._bgImg = self:getUI("bg.bg3")
    self._animBg = self:getUI("bg.bg0")
    self._layer = self:getUI("bg.layer")
    -- self._levelupImg = self:getUI("bg.levelupImg")
    self._preLevel = self:getUI("bg.layer.show1.preLevel")
    self._level = self:getUI("bg.layer.show1.level")
    self._prePhysic = self:getUI("bg.layer.show2.preLevel")
    self._physic = self:getUI("bg.layer.show2.level")
    self._show1 = self:getUI("bg.layer.show1")
    self._show2 = self:getUI("bg.layer.show2")
    -- self._preLevel3 = self:getUI("bg.layer.show1.preLevel3")
    -- self._level3 = self:getUI("bg.layer.show1.level3")

    self._touchLab = self:getUI("bg.bg3.touchLab")

    for i=1,2 do
        local arrow = self:getUI("bg.layer.show" .. i .. ".arrow")
        local seq = cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(-5, 0)), cc.MoveBy:create(0.5, cc.p(5, 0)))
        arrow:runAction(cc.RepeatForever:create(seq))
    end
	
    -- self._levelupImg:setVisible(false)
    self._layer:setOpacity(0)
    local children1 = self._layer:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end

    local play1 = self:getUI("bg.layer.playWay1")
    local children1 = play1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    play1:setVisible(false)
    local play2 = self:getUI("bg.layer.playWay2")
    local children1 = play2:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    play2:setVisible(false)
    local play3 = self:getUI("bg.layer.playWay3")
    local children1 = play3:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    play3:setVisible(false)

    local userlevel = self._modelMgr:getModel("UserModel"):getData().lvl
    if userlevel <= tab:SystemDes(table.nums(tab.systemDes)).level then
        self:setPlay()  
    end
    -- 误删 找VV
    local sysUserLevel = tab:UserLevel(userlevel)
    if sysUserLevel.pa and sysUserLevel.pa == 1 then 
        require "game.view.intance.IntanceConst"
        IntanceConst.PAUSE_ACTIVATE = true
    end
end

-- 接收自定义消息
function DialogUserLevelUp:reflashUI(data)
    -- data = {
    --     preLevel = 5,
    --     level = 6,
    --     prePhysic = 100,
    --     physic = 120,
    -- }
    local minLevel = 0
    local maxLevel = 0
	if data.preLevel then
        minLevel = data.preLevel
        maxLevel = data.level
		self._preLevel:setString(data.preLevel or "")
		self._level:setString(data.level or "")
        if data.level and data.level == 34 then
            self._modelMgr:getModel("LeagueModel"):notShowBatchTipMc()
        end
		self._prePhysic:setString(data.prePhysic or "")
		self._physic:setString(data.physic or "")
	elseif #data == 4 then
        minLevel = data[1]
        maxLevel = data[2]       
		self._preLevel:setString(data[1] or "")
		self._level:setString(data[2] or "")
        if data[2] and data[2] == 34 then
            self._modelMgr:getModel("LeagueModel"):notShowBatchTipMc()
        end
		self._prePhysic:setString(data[3] or "")
		self._physic:setString(data[4] or "")
	end

    -- local num1 = tab:UserLevel(data.preLevel).num
    -- local num2 = tab:UserLevel(data.level).num
    -- if num1 ~= num2 then
    --     self._preLevel3:setString(num1)
    --     self._level3:setString(num2)
    -- else
    --     self._preLevel3:setVisible(false)
    --     self._level3:setVisible(false)
    --     local des = self:getUI("bg.layer.des3")
    --     des:setVisible(false)
    --     local arrow = self:getUI("bg.layer.arrow3")
    --     arrow:setVisible(false)
    -- end

    self._upNum = data.level or 1
    local mcMgr = MovieClipManager:getInstance()

	self.callback = data.callback

    local sminLevel = SystemUtils.loadGlobalLocalData("IWFunOpenMinLevel")
    if sminLevel == nil or sminLevel == 0 or sminLevel < minLevel then 
        SystemUtils.saveAccountLocalData("IWFunOpenMinLevel", minLevel)
    end

    SystemUtils.saveAccountLocalData("IWFunOpenMaxLevel", maxLevel)

    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150
    self.bgWidth = self._bgImg:getContentSize().width    
    local maxHeight = self._bgImg:getContentSize().height
    self._bgImg:setOpacity(0)
    self._layer:setVisible(false)    
    self._bgImg:setPositionX(self._layer:getContentSize().width*0.5)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))  
    self:animBegin(function( )
        self._bgImg:setOpacity(255) 
        self:setAnim() 
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._layer:setVisible(true)
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                -- nextAnimFunc()   
            end
        end)
    end)
    self._bgImg:setVisible(true)
    -- self._bgImg:setOpacity(255)  
end

function DialogUserLevelUp:setAnim()
    for i=1,2 do
        local show = self:getUI("bg.layer.show" .. i)
        local mc2 = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", false, true)
        mc2:setPosition(0, show:getContentSize().height*0.5)
        show:addChild(mc2)

        local seq = cc.Sequence:create(cc.MoveBy:create(0, cc.p(40, 0)), cc.DelayTime:create(0.1*i), cc.EaseOut:create(cc.MoveBy:create(0.2, cc.p(-40, 0)), 2.5))
        show:runAction(seq)
    end
end


function DialogUserLevelUp:animBegin(callback)
    audioMgr:playSoundForce("LevelUp")
    -- 加锁
    -- self._viewMgr:lock(-1)
    local closePanel = self:getUI("closePanel")
    closePanel:setTouchEnabled(false)

    -- local showXian 
    -- local bgW,bgH = self._animBg:getContentSize().width,self._animBg:getContentSize().height
    -- local mc1 = mcMgr:createViewMC("shengji_levelupanim", true, false, function (_, sender)
    --     sender:gotoAndPlay(80)
    -- end)
    -- mc1:setPosition(cc.p(bgW/2, 20))
    -- self._animBg:addChild(mc1)

    -- local levelNum = cc.Label:createWithBMFont(UIUtils.bmfName_levelup,"a" .. (self._upNum or 1))
    -- levelNum:setAdditionalKerning(-30)
    -- levelNum:setPosition(cc.p(bgW/2,bgH/2-25))
    -- self._animBg:addChild(levelNum,99)
    -- levelNum:setOpacity(0)
    -- ScheduleMgr:delayCall(500, self, function( )
    --     levelNum:runAction(cc.Spawn:create(cc.FadeIn:create(0.5),cc.Sequence:create(cc.ScaleTo:create(0,8),cc.ScaleTo:create(0.2,0.8),cc.ScaleTo:create(0.2,1)))) --,cc.JumpBy:create(0.1,cc.p(0,0),10,1))))
    -- end)
    -- ScheduleMgr:delayCall(1000, self, function( )
        -- self._levelupImg:setVisible(true)
        -- self._levelupImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0,4),cc.ScaleTo:create(0.2,0.8),cc.ScaleTo:create(0.2,1))) -- ,cc.JumpBy:create(0.1,cc.p(0,0),10,1)))
    -- end)

    -- 解锁
    ScheduleMgr:delayCall(200, self, function( )
        self._layer:runAction(cc.FadeIn:create(0.2))
        local children1 = self._layer:getChildren()
        for k,v in pairs(children1) do
            v:runAction(cc.FadeIn:create(0.2))
        end
        local closePanel = self:getUI("closePanel")
        local hadClose
        self:registerClickEvent(closePanel,function( )
            if closePanel.useTimeFin == true then return end
            closePanel:stopAllActions()
            if not hadClose then
                -- print('==========================11111111111')
                if self._actionOpen == true then
                    self:setActionOpen()
                end
                UIUtils:reloadLuaFile("global.DialogUserLevelUp")
                self:close()
                hadClose = true
            end
        end)
        closePanel:setTouchEnabled(false)

        local userlevel = self._modelMgr:getModel("UserModel"):getData().lvl
        if userlevel <= tab:SystemDes(table.nums(tab.systemDes)).level then
            local play1 = self:getUI("bg.layer.playWay1")
            local play2 = self:getUI("bg.layer.playWay2")
            local play3 = self:getUI("bg.layer.playWay3")
            local seq = cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                if self._openNum >= 1 then
                    play1:setVisible(true)
                end
                
                play1:runAction(cc.FadeIn:create(0.2))
                local children1 = play1:getChildren()
                for k,v in pairs(children1) do
                    v:runAction(cc.FadeIn:create(0.2))
                end
                -- play1:runAction(cc.JumpBy:create(0.2,cc.p(0,0),20,1))
                -- play1:setVisible(true)
            end),cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                if self._openNum >= 2 then
                    play2:setVisible(true)
                end
                play2:runAction(cc.FadeIn:create(0.2))
                local children1 = play2:getChildren()
                for k,v in pairs(children1) do
                    v:runAction(cc.FadeIn:create(0.2))
                end
                -- play2:runAction(cc.JumpBy:create(0.2,cc.p(0,0),40,1))
                -- play2:setVisible(true)
            end),cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                if self._openNum >= 3 then
                    play3:setVisible(true)
                end
                play3:runAction(cc.FadeIn:create(0.2))
                local children1 = play3:getChildren()
                for k,v in pairs(children1) do
                    v:runAction(cc.FadeIn:create(0.2))
                end
                -- play3:runAction(cc.JumpBy:create(0.2,cc.p(0,0),40,1))
                -- play3:setVisible(true)
            end),cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                closePanel:setTouchEnabled(true)
                self._touchLab:setVisible(true)
            end))
            self:runAction(seq)
        else
            closePanel:setTouchEnabled(true)
            self._touchLab:setVisible(true)
        end

    end)

    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "shengji_levelupanim", 0, 105)

    ScheduleMgr:delayCall(450, self, function( )
        if self._openNum <= 0 then
            local layer = self:getUI("bg.layer")
            layer:setPositionY(-24)
        end
        if self._bg then
            --震屏
            if callback and self._bg then
                callback()
            end
        end
    end)
end

function DialogUserLevelUp:setPlay()
    local play = self:getUI("bg.layer")
    -- play:setVisible(true)
    local userlevel = self._modelMgr:getModel("UserModel"):getData().lvl
    local tempLevel = 0
    local tempSystemDes = {}
    for i=1,table.nums(tab.systemDes) do
        -- tempLevel = 8
        local systemDesTab = tab:SystemDes(i)
        if userlevel <= systemDesTab.level and (userlevel + 16) >= systemDesTab.level then
            local extra = systemDesTab.extra
            if extra and self["getExtra" .. extra] then
                local _extra = self["getExtra" .. extra](self)
                if _extra == true then
                    table.insert(tempSystemDes, i)
                end
            else
                table.insert(tempSystemDes, i)
            end
            if table.nums(tempSystemDes) >= 8 then
                break
            end
        end
    end
    
    for i=1,3 do
        local play = self:getUI("bg.layer.playWay" .. i)
        local playName = play:getChildByFullName("play")
        local playLevel = play:getChildByFullName("playLevel")
        local playDec = play:getChildByFullName("playDec")
        local playIcon = play:getChildByFullName("playIcon")
        local playWayArt = playIcon:getChildByName("playWayArt")
        local playwayOpen = play:getChildByFullName("playOpen")
        local openIcon = play:getChildByFullName("open")
        if i <= table.nums(tempSystemDes) then
            -- print("==========",i,tempSystemDes[i])
            tempLevel = tempSystemDes[i]
            local playway = tab:SystemDes(tempLevel).art .. ".png"
            playWayArt = cc.Sprite:create()
            playWayArt:setSpriteFrame(playway)
            playWayArt:setAnchorPoint(cc.p(0, 0))
            playWayArt:setPosition(cc.p(playIcon:getContentSize().width*0, playIcon:getContentSize().height*0 + 5))
            playWayArt:setScale(0.7)
            playIcon:addChild(playWayArt)

            -- if playWayArt then
            --     playWayArt = IconUtils:updateTeamPlayIconByView({image = playway})
            -- else
            --     playWayArt = IconUtils:createTeamPlayIconById({image = playway})
            --     playWayArt:setName("playWayArt")
            --     playWayArt:setScale(0.7)
            --     playIcon:addChild(playWayArt)
            -- end
            openIcon:loadTexture("globalPanelUI6_playWay1.png", 1)
            openIcon:setCapInsets(cc.rect(86,0,1,1))
            -- print("===============",userlevel, tempLevel, tab:SystemDes(tempLevel).name)
            playName:setString(lang(tab:SystemDes(tempLevel).name))
            playLevel:setString("" .. tab:SystemDes(tempLevel).level .. "级开启")
            local str = string.gsub(lang(tab:SystemDes(tempLevel).des), "%b[]", "") 
            playDec:setString(str)
            playName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            playLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            playDec:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            if userlevel >= tab:SystemDes(tempLevel).level then
                -- playName:setColor(cc.c3b(255, 255, 255))
                -- playLevel:setVisible(false)
                playLevel:setString("")
                playwayOpen:setVisible(false)
                -- playLevel:setColor(cc.c3b(255,64,64))
                -- playDec:setColor(cc.c3b(211, 169, 109))

                local xuanzhong = play:getChildByFullName("xuanzhong")
                xuanzhong:setVisible(false)
                xuanzhong:setOpacity(0)
                local seq = cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1))
                xuanzhong:runAction(cc.RepeatForever:create(seq))

                local callFunc1 = cc.CallFunc:create(function()
                    if openIcon and play then
                        local mc1 = mcMgr:createViewMC("saoguang_levelupanim", false, true)
                        mc1:setPosition(cc.p(0,0))
                        mc1:setPlaySpeed(2)
                        local clipNode = cc.ClippingNode:create()
                        local mask = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI6_playWay2.png") -- cc.Sprite:createWithSpriteFrameName("globalPanelUI6_playWay2.png")
                        mask:setCapInsets(cc.rect(86, 0, 1, 1))
                        mask:setContentSize(557, 65)
                        mask:setAnchorPoint(cc.p(0.5,0.5))
                        mask:setPosition(175, -5)
                        clipNode:setStencil(mask)
                        clipNode:setAlphaThreshold(0.1)
                        clipNode:addChild(mc1)
                        clipNode:setName("anim1")
                        clipNode:setAnchorPoint(cc.p(0,0.5))
                        clipNode:setPosition(cc.p(26,40))
                        play:addChild(clipNode, 20)
                    end
                    openIcon:loadTexture("globalPanelUI6_playWay2.png", 1)
                    openIcon:setCapInsets(cc.rect(86,0,1,1))
                end)
                local callFunc2 = cc.CallFunc:create(function()
                    xuanzhong:setVisible(true)
                    playwayOpen:setVisible(true)
                end)
                local scale1 = cc.ScaleTo:create(0.15, 1)
                local scale2 = cc.ScaleTo:create(0, 3)
                local seq = cc.Sequence:create(cc.DelayTime:create(1), 
                    callFunc1, 
                    cc.DelayTime:create(0.3), 
                    callFunc2,
                    cc.FadeIn:create(0), 
                    scale2, 
                    scale1
                    )
                playwayOpen:runAction(seq)
 
                if self.parentView:getClassName() == "main.MainView" then
                    if self._actionOpen == false then
                        self._actionOpen = true
                    end
                end
            else
                playwayOpen:setVisible(false)
                openIcon:loadTexture("globalPanelUI6_playWay1.png", 1)
                openIcon:setCapInsets(cc.rect(86,0,1,1))
                -- playName:setColor(cc.c3b(134, 134, 134))
                -- playLevel:setColor(cc.c3b(253, 1, 0))
                -- playDec:setColor(cc.c3b(134, 134, 134))
            end
            -- playLevel:setPositionX(playName:getPositionX() + playName:getContentSize().width + 10)
            self._openNum = i 
        else
            playName:setVisible(false)
            playLevel:setVisible(false)
            playwayOpen:setVisible(false)
            playDec:setVisible(false)
            playIcon:setVisible(false)
            if playWayArt then
                playWayArt:setVisible(false)
            end
        end
        
    end
end

function DialogUserLevelUp:setActionOpen()
    print("==================解锁成功")
    local mainModel = self._modelMgr:getModel("MainViewModel")
    mainModel:setActionOpen()
end


-- 弹出悬浮窗（如：获得物品）title动画
function DialogUserLevelUp:addPopViewTitleAnim(view,mcName,x,y)
    local mcStar = mcMgr:createViewMC( mcName or "gongxihuode_huodetitleanim", false, false, function (_, sender)
        
    end,RGBA8888)
    mcStar:addCallbackAtFrame(84, function()
        mcStar:gotoAndPlay(35)
    end)
    mcStar:setPosition(x,y+35)
    view:addChild(mcStar,99)

    mcStar:addCallbackAtFrame(6,function( )
        local mc = mcMgr:createViewMC("caidai_huodetitleanim", false, false, function (_, sender)
        --sender:gotoAndPlay(80)
        end,RGBA8888)
        -- mc:setPlaySpeed(1)
        mc:setPosition(cc.p(x,y))
        view:addChild(mc,100)
                 
        local mc1bg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888)
        mc1bg:setPlaySpeed(1)
        mc1bg:setScale(1.5)

        local clipNode2 = cc.ClippingNode:create()
        clipNode2:setPosition(x,y+45)
        local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
        mask:setScale(2.5)
        mask:setPosition(0,147)
        clipNode2:setStencil(mask)
        clipNode2:setAlphaThreshold(0.5)
        mc1bg:setPositionY(-10)
        clipNode2:addChild(mc1bg)
        view:addChild(clipNode2,-1)
        UIUtils:shakeWindow(view)
    end) 
end

-- 添加装饰的边角 用于悬浮窗界面
function DialogUserLevelUp:addDecorateCorner( )
    local bg = self:getUI("closePanel")
    local bgW,bgH = bg:getContentSize().width, bg:getContentSize().height
    local offsetX = math.abs(bgW-MAX_SCREEN_WIDTH)/2
    local offsetY = math.abs(bgH-MAX_SCREEN_HEIGHT)/2

    local moveOffset = {25,25}

    local leftBottomPos = {x = -offsetX, y = -offsetY}
    local leftCornerImg = ccui.ImageView:create()
    leftCornerImg:loadTexture("globalImageUI_commonGetConner.png",1)
    leftCornerImg:setAnchorPoint(0,0)
    leftCornerImg:setPosition(leftBottomPos.x-moveOffset[1], leftBottomPos.y-moveOffset[2])
    bg:addChild(leftCornerImg)
    leftCornerImg:runAction(cc.MoveTo:create(0.1,cc.p(leftBottomPos.x, leftBottomPos.y)))

    local rightBottomPos = {x = bgW+offsetX-354, y = -offsetY}
    local rightCornerImg = ccui.ImageView:create()
    rightCornerImg:loadTexture("globalImageUI_commonGetConner.png",1)
    rightCornerImg:setFlippedX(true)
    rightCornerImg:setAnchorPoint(1,0)
    rightCornerImg:setPosition(rightBottomPos.x+moveOffset[1], rightBottomPos.y-moveOffset[2])
    bg:addChild(rightCornerImg)
    rightCornerImg:runAction(cc.MoveTo:create(0.1,cc.p(rightBottomPos.x, rightBottomPos.y)))
end

-- 是否满足特殊条件
function DialogUserLevelUp:getExtra801()
    local flag = false
    local seigeStatus = self._modelMgr:getModel("SiegeModel"):getData().status
    if seigeStatus == 7 then
        flag = true
    end
    return flag
end


return DialogUserLevelUp			
