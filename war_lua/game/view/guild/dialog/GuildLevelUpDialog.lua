--[[
    Filename:    GuildLevelUpDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-25 11:12:23
    Description: File description
--]]

local GuildLevelUpDialog = class("GuildLevelUpDialog",BasePopView)
function GuildLevelUpDialog:ctor()
    GuildLevelUpDialog.super.ctor(self)
    self._openNum = 1
end

function GuildLevelUpDialog:getMaskOpacity()
    return 230
end

-- 第一次被加到父节点时候调用
function GuildLevelUpDialog:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function GuildLevelUpDialog:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")

    self._modelMgr:getModel("GuildModel"):saveAllianceOpenAction(1)
    local des = self:getUI("bg.layer.des")
    des:setColor(cc.c4b(255,252,226,255))
    des:enable2Color(1, cc.c4b(255, 232, 125, 255))
    des:enableOutline(cc.c4b(60, 30, 10, 255), 1)

    local closePanel = self:getUI("closePanel")
    local callfunc = cc.CallFunc:create(function()
        -- if self._actionOpen == true then
        --     self:setActionOpen()
        -- end
        if self._callback then
            self._callback()
        end
        UIUtils:reloadLuaFile("guild.dialog.GuildLevelUpDialog")
        self:close()
    end)
    -- local callfunc1 = cc.CallFunc:create(function()
    --     closePanel.useTimeFin = true
    --     closePanel:setTouchEnabled(false)
    -- end)
    -- local seq = cc.Sequence:create(cc.DelayTime:create(2.5),callfunc1,cc.DelayTime:create(0.5), callfunc)
    -- closePanel:runAction(seq)

    self._actionOpen = false
    self._bgImg = self:getUI("bg.bg3")
    self._layer = self:getUI("bg.layer")
    self._touchLab = self:getUI("bg.bg3.touchLab")
    self._jiantou = self:getUI("bg.layer.jiantou")
    self._jiantou:setVisible(false)

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

    -- local userlevel = self._userModel:getData().lvl
    -- if userlevel <= tab:SystemDes(table.nums(tab.systemDes)).level then
    --     self:setPlay()  
    -- end
    self:setPlay()  
end

-- 接收自定义消息
function GuildLevelUpDialog:reflashUI(data)
    -- data = {
    --     oldLevel = 1,
    --     newLevel = 2,
    -- }
    if not data then
        return
    end
    self._callback = data.callback
    local guilddes = self:getUI("bg.layer.des")
    guilddes:setString("恭喜您所在联盟提升至" .. data.newLevel .. "级！")

    -- 左侧宝箱
    local leftIconBg = self:getUI("bg.layer.oldIcon")
    leftIconBg:setVisible(false)
    local itemId = tab:GuildLevel(data.oldLevel).gift 
    local itemData = tab:Tool(itemId)
    local itemIcon = IconUtils:createItemIconById({itemId = itemId, itemData = itemData, effect = false})
    itemIcon:setSwallowTouches(true)
    itemIcon:setAnchorPoint(cc.p(0,0))
    itemIcon:setVisible(true)
    leftIconBg:addChild(itemIcon)
    local itemNormalScale = 100/itemIcon:getContentSize().width
    itemIcon:setScale(itemNormalScale)

    local leftName = self:getUI("bg.layer.oldIcon.name")
    if itemData.name then
        leftName:setString(lang(itemData.name))
        leftName:setPositionY(leftName:getPositionY()-4)
    end
    if itemData.color then
        leftName:setColor(UIUtils.colorTable["ccUIBaseColor" .. itemData.color])
    end

    -- 右侧宝箱
    local rightIconBg = self:getUI("bg.layer.newIcon")
    rightIconBg:setVisible(false)
    local itemId = tab:GuildLevel(data.newLevel).gift 
    local itemData = tab:Tool(itemId)
    local itemIcon = IconUtils:createItemIconById({itemId = itemId, itemData = itemData, effect = false})
    itemIcon:setSwallowTouches(true)
    itemIcon:setAnchorPoint(cc.p(0,0))
    itemIcon:setVisible(true)
    rightIconBg:addChild(itemIcon)
    local itemNormalScale = 100/itemIcon:getContentSize().width
    itemIcon:setScale(itemNormalScale)

    local rightName = self:getUI("bg.layer.newIcon.name")
    rightName:setString(lang(itemData.name))
    if rightName then
        rightName:setPositionY(rightName:getPositionY()-4)
    end
    if itemData.color then
        rightName:setColor(UIUtils.colorTable["ccUIBaseColor" .. itemData.color])
    end

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
                self:nextAnimFunc()   
            end
        end)
    end)
    self._bgImg:setVisible(true)
    -- self._bgImg:setOpacity(255)  
end

function GuildLevelUpDialog:nextAnimFunc()
    -- self._viewMgr:lock(-1)
    local closePanel = self:getUI("closePanel")
    closePanel:setTouchEnabled(false)

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
                -- if self._actionOpen == true then
                --     self:setActionOpen()
                -- end
                if self._callback then
                    self._callback()
                end
                UIUtils:reloadLuaFile("guild.dialog.GuildLevelUpDialog")
                self:close()
                hadClose = true
            end
        end)
        closePanel:setTouchEnabled(false)
        -- if self._openNum <= 0 then
        --     local layer = self:getUI("bg.layer")
        --     layer:setPositionY(-24)
        --     -- local nothingBg = self:getUI("bg.nothingBg")
        --     -- nothingBg:setVisible(true)
        -- end
        local guildLevel = self._userModel:getData().guildLevel
        if guildLevel <= tab:GuildSystemDes(table.nums(tab.guildSystemDes)).level then
            local play1 = self:getUI("bg.layer.playWay1")
            local seq = cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function()
                if self._openNum >= 1 then
                    play1:setVisible(true)
                end
                
                play1:runAction(cc.FadeIn:create(0.2))
                local children1 = play1:getChildren()
                for k,v in pairs(children1) do
                    v:runAction(cc.FadeIn:create(0.2))
                end
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

    ScheduleMgr:delayCall(300, self, function()
        if not self._jiantou then return end
        local oldIcon = self:getUI("bg.layer.oldIcon")
        oldIcon:setVisible(true)
        oldIcon:runAction(cc.Sequence:create(cc.MoveBy:create(0, cc.p(60, 0)),cc.MoveBy:create(0.15, cc.p(-60, 0)))) -- ,cc.JumpBy:create(0.15, cc.p(-60, 0),10,1)))
        local newIcon = self:getUI("bg.layer.newIcon")
        newIcon:setVisible(true)
        newIcon:runAction(cc.Sequence:create(cc.MoveBy:create(0, cc.p(-60, 0)),cc.MoveBy:create(0.15, cc.p(60, 0)))) -- ,cc.JumpBy:create(0.15, cc.p(60, 0),10,1)))
    end)

    ScheduleMgr:delayCall(350, self, function()
        if not self._jiantou then return end
        self._jiantou:setVisible(true)
    end)
end

function GuildLevelUpDialog:animBegin(callback)
    -- 加锁
    self._bg = self:getUI("bg")
    self:addPopViewTitleAnim(self._bg, "lianmengshengji_huodetitleanim", 0, 133)
    ScheduleMgr:delayCall(450, self, function( )
        if self._bg then
            --震屏
            if callback and self._bg then
                callback()
            end
        end
    end)
end

function GuildLevelUpDialog:setPlay()
    local play = self:getUI("bg.layer")
    play:setVisible(true)
    local guildLevel = self._userModel:getData().guildLevel
    print('guildLevel========', guildLevel)
    if not guildLevel or guildLevel == 0 then
        return
    end

    local tempLevel = 0
    local tempSystemDes = {}
    for i=1,table.nums(tab.guildSystemDes) do
        local guildSTab = tab:GuildSystemDes(i)
        if guildLevel <= guildSTab.level then
            table.insert(tempSystemDes, i)
        end
    end

    for i=1,1 do
        play = self:getUI("bg.layer.playWay" .. i)
        local playName = play:getChildByFullName("play")
        local playLevel = play:getChildByFullName("playLevel")
        local playDec = play:getChildByFullName("playDec")
        local playIcon = play:getChildByFullName("playIcon")
        local playWayArt = playIcon:getChildByName("playWayArt")
        local playwayOpen = play:getChildByFullName("playOpen")
        local openIcon = play:getChildByFullName("open")
        if i <= table.nums(tempSystemDes) then
            print("==========",i,tempSystemDes[i])
            tempLevel = tempSystemDes[i]
            local guildSystemDesTab = tab:GuildSystemDes(tempLevel)
            local playway = guildSystemDesTab.art .. ".png"
            playWayArt = cc.Sprite:create()
            playWayArt:setSpriteFrame(playway)
            playWayArt:setAnchorPoint(cc.p(0, 0))
            playWayArt:setPosition(cc.p(playIcon:getContentSize().width*0, playIcon:getContentSize().height*0 + 5))
            playWayArt:setScale(0.7)
            playIcon:addChild(playWayArt)

            playName:setString(lang(guildSystemDesTab.name))
            playLevel:setString("" .. guildSystemDesTab.level .. "级开启")
            local str = string.gsub(lang(guildSystemDesTab.des), "%b[]", "") 
            playDec:setString(str)
            playName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            playLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            playDec:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            if guildLevel >= guildSystemDesTab.level then
                playName:setColor(cc.c3b(255, 255, 255))
                -- playLevel:setVisible(false)
                playLevel:setString("")
                playwayOpen:setVisible(true)
                -- playLevel:setColor(cc.c3b(255,64,64))
                -- playDec:setColor(cc.c3b(211, 169, 109))

                local xuanzhong = play:getChildByFullName("xuanzhong")
                xuanzhong:setVisible(false)
                -- local seq = cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1))
                -- xuanzhong:runAction(cc.RepeatForever:create(seq))

                if self.parentView:getClassName() == "guild.GuildView" then
                    if self._actionOpen == false then
                        self._actionOpen = true
                    end
                end
            else
                playwayOpen:setVisible(false)
                openIcon:loadTexture("globalPanelUI6_playWay1.png", 1)
                openIcon:setCapInsets(cc.rect(86,0,1,1))
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

function GuildLevelUpDialog:setActionOpen()
    print("==================解锁成功")
    -- local mainModel = self._modelMgr:getModel("MainViewModel")
    -- mainModel:setActionOpen()
end


-- 弹出悬浮窗（如：获得物品）title动画
function GuildLevelUpDialog:addPopViewTitleAnim(view,mcName,x,y)
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
function GuildLevelUpDialog:addDecorateCorner( )
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

return GuildLevelUpDialog            
