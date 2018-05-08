--[[
    Filename:    GlobalExtendBarNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-08 10:33:29
    Description: File description
--]]

local GlobalExtendBarNode = class("GlobalExtendBarNode", BaseMvcs, BaseEvent, ccui.Widget)

function GlobalExtendBarNode:ctor(inData)
    GlobalExtendBarNode.super.ctor(self)
    self._extendInfo = inData.extendInfo
    -- 初始获取按钮红点提示
    self._redTipCallback = inData.redTipCallback
    -- 伸开或收缩完毕回调
    self._motionCallback = inData.motionCallback
    -- 初始化状态1伸展，0收缩
    self._initState = inData.initState or 0
    print("self._initState===================", self._initState)
    -- 预留宽度
    self._reserveWidth = inData.reserveWidth or 171
    -- 指定按钮宽度
    self._btnWidth = inData.btnWidth or 82
    -- 按钮间间距
    self._spaceWidth = inData.spaceWidth or 26
    -- 横向方向1左侧，2右侧
    self._horizontal = inData.horizontal or 2
    -- 初始化风格，--2按照指定按钮宽度进行分割，1按照实际按钮宽度进行分割
    self._style = inData.style or 1   
    -- 文本内容大小
    self._fontSize = inData.fontSize or 24

    -- 内容偏移量
    self._iconOffset = inData.iconOffset or {0, 0}

    self._nameOffset = inData.nameOffset or {0, 0}


    -- 条默认高度
    self._barHeight = inData.barHeight or 110
    self:onInit()
end

function GlobalExtendBarNode:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("global.GlobalExtendBarNode")
        elseif eventType == "enter" then 
        end
    end)
    self:setName("extendBar")
    self:setContentSize(100, 100)
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    layer:setContentSize(100, 100)
    layer:setPosition(0, 0)
    self:addChild(layer)    

    self._extendBg = ccui.ImageView:create("global_extend_bg.png", 1)
    self._extendBg:setName("bg")

    self._extendBg:setScale9Enabled(true)
    self._extendBg:setCapInsets(cc.rect(46, 47, 1, 1))
    self._extendBg:setContentSize(500, self._barHeight)
    self:addChild(self._extendBg)
    if self._horizontal == 1 then
        self._extendBg:setAnchorPoint(0, 0.5)
        self._extendBg:setPosition(0, 50)
    else
        self._extendBg:setAnchorPoint(1, 0.5)

        self._extendBg:setPosition(100, 50)    
    end
    self._extendBtn = ccui.Button:create()
    self._extendBtn:setName("extend")
    self._extendBtn:loadTextures("global_extend.png", "global_extend.png", "globalBtnUI_chatBtn.png", 1)
    self._extendBtn:setAnchorPoint(cc.p(0.5, 0.5))
    if self._horizontal == 1 then 
        -- 此状态还有其他地方设置Position记得修改
        self._extendBtn:setPosition(cc.p(self._extendBg:getContentSize().width , self._extendBg:getContentSize().height * 0.5 - 8))
    else
        self._extendBtn:setPosition(cc.p(0, self._extendBg:getContentSize().height * 0.5 - 8))
    end
    self._extendBg:addChild(self._extendBtn)
    self._extendBtn:setScaleAnim(true)
    self:initExtendBar()

    if self._initState == 1 then
        self:doExtendBarAnim(false, true)
    else
        self:doExtendBarAnim(false, false)
    end

    registerClickEvent(self._extendBg, function() end)
end


-- 初始化伸缩条
function GlobalExtendBarNode:initExtendBar()
    local count = #self._extendInfo
    self._extendBtns = {}
    self._extendVisibleBtns = {}
    for i = 1, count do
        local info = self._extendInfo[i]
        local btn = ccui.Button:create(info[2], info[2], info[2], 1)
        btn:setCascadeOpacityEnabled(true)
        btn:setName(info[1])

        local label = cc.Label:createWithTTF(info[3], UIUtils.ttfName, self._fontSize)
        label:setColor(UIUtils.colorTable.ccUIBaseColor1)
        label:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
        btn:addChild(label)

        label:setPosition(btn:getContentSize().width * 0.5 + self._nameOffset[1], (btn:getContentSize().height - 79) * 0.5 + 10 + self._nameOffset[2])

        self:registerClickEvent(btn, function ()
            if self._lockStateCallback ~= nil and self._lockStateCallback() == false then return end
            self._viewMgr:lock(-1)
            ScheduleMgr:delayCall(75, self, function()
                if type(info[4]) == "function" then
                    local callFun = info[6] ~= nil and specialize(info[4],info[6],info[1]) or info[4]
                    callFun()
                    self._viewMgr:unlock()
                else
                    -- info[6]  传入界面的参数
                    self._viewMgr:showView(info[4],info[6])
                    self._viewMgr:unlock()
                end
            end)
        end)

        self._extendBg:addChild(btn)
        self._extendBtns[i] = btn
        if i < count then
            if btn._lineImg == nil then
                local lineImg = ccui.ImageView:create()
                lineImg:loadTexture("mainView_btn_line.png", 1)
                self._extendBg:addChild(lineImg, 200)
                btn._lineImg = lineImg
                btn._lineImg:setVisible(false)
                -- if btn._lineImg then
                --     btn._lineImg:setPosition(125 + i * 20 + 4, 55)
                --     -- btn._lineImg:setScale(1.1)
                -- end

            end
        end
    end

    self:registerClickEvent(self._extendBtn, function ()
        if self._lockStateCallback ~= nil and self._lockStateCallback() == false then return end
        self:doExtendBarAnim()
    end)

    self:updateExtendBar()
end


function GlobalExtendBarNode:initOtherViewBtnTip()
    if self._extendBarIsExtend == true and self._redTipCallback ~= nil then
        for k,v in pairs(self._extendBtns) do
            self._redTipCallback(v:getName(), v)
        end
    end
end

-- 根据等级开放, 重新排列按钮位置
function GlobalExtendBarNode:updateExtendBar()

    local anim_W = 10 -- 动画预留

    self._extendVisibleBtns = {}
    for i = 1, #self._extendInfo do
        local info = self._extendInfo[i]
        self._extendBtns[i]:setVisible(false)
        local systemName = info[5]
        if systemName then
            local open, show = SystemUtils["enable"..systemName]() 
            if open then
                self._extendVisibleBtns[#self._extendVisibleBtns + 1] = self._extendBtns[i]
            end
        else
            self._extendVisibleBtns[#self._extendVisibleBtns + 1] = self._extendBtns[i]
        end
    end

    self._extendBarAniming = false -- 是否在动画中
    
    self._extendBtn:stopAllActions()
    local count = #self._extendVisibleBtns
    local width = self._reserveWidth + anim_W + (self._btnWidth + self._spaceWidth) * count

    if self._style == 1 then 
        width = self._reserveWidth + anim_W --_extendBg宽度offset
        for i = 1, #self._extendVisibleBtns do
            local btn = self._extendVisibleBtns[i]
            width = width + btn:getContentSize().width + self._spaceWidth
        end
    end
    if count == 0 then 
        width = width + 30
    end
    self._extendBg:setContentSize(width , self._extendBg:getContentSize().height)

    if self._horizontal == 1 then
        self._extendBtn:setPosition(cc.p(self._extendBg:getContentSize().width + 10, self._extendBg:getContentSize().height * 0.5 - 8))
        self._extendBg.___extendPosX = -10
        self._extendBg.___extendPosY = self._extendBg:getPositionY() + self._iconOffset[2]
        self._extendBg.___extendPosX2 = -width + 100 + 10  + self._iconOffset[1]
    else
        self._extendBg.___extendPosX = 100 + anim_W + self._iconOffset[1]
        self._extendBg.___extendPosY = self._extendBg:getPositionY() + self._iconOffset[2]
        self._extendBg.___extendPosX2 = self._extendBg.___extendPosX + width - self._reserveWidth
    end

    local posX = 65           --按钮初始位置偏移
    local linePosX = 65
    width = self._reserveWidth --_extendBg宽度offset
    if self._horizontal == 1 then
        posX = self._extendBg:getContentSize().width - 75
        self._extendBtn:setFlippedX(true)
        self._extendBg:setPositionX(-anim_W)
    else
        self._extendBtn:setFlippedX(false)
        self._extendBg:setPositionX(100+anim_W)
    end
    for i = 1, #self._extendVisibleBtns do
        local btn = self._extendVisibleBtns[i]
        btn:setVisible(true)
        btn:setOpacity(255)
        if self._horizontal == 1 then
            if self._style == 1 then 
                btn.___extendPosX = posX
                posX = posX - btn:getContentSize().width - self._spaceWidth
                linePosX = math.ceil(posX + btn:getContentSize().width * 0.5 + self._spaceWidth * 0.5)
            else
                btn.___extendPosX = posX
                posX = posX - self._btnWidth - self._spaceWidth
                linePosX = math.ceil(posX + self._btnWidth * 0.5 + self._spaceWidth * 0.5)
            end 
        else
            if self._style == 1 then 
                btn.___extendPosX = posX
                posX = posX + btn:getContentSize().width + self._spaceWidth
                linePosX = math.ceil(posX - btn:getContentSize().width * 0.5 - self._spaceWidth * 0.5)
            else
                btn.___extendPosX = posX
                posX = posX + self._btnWidth + self._spaceWidth
                linePosX = math.ceil(posX - self._btnWidth * 0.5 - self._spaceWidth * 0.5)
            end
        end
        if btn._lineImg then
            btn._lineImg:setPosition(linePosX, self._extendBg:getContentSize().height * 0.5)
            btn._lineImg:setVisible(true)
        end
        btn.___extendPosY = self._extendBg:getContentSize().height * 0.5 + self._iconOffset[2]
        btn:setPosition(btn.___extendPosX + self._iconOffset[1], btn.___extendPosY)
     
    end   
    self._extendBarIsExtend = true -- 是否处于拓展状态
    if self._motionCallback ~= nil then 
        self._motionCallback(1)
    end
    if #self._extendVisibleBtns == 0 then
        -- self._extendBarIsExtend = false
        self._extendBtn:setSaturation(-100)
        self._extendBtn:setTouchEnabled(false)
    else
        self._extendBtn:setSaturation(0)
        self._extendBtn:setTouchEnabled(true)
    end

    self:initOtherViewBtnTip()
end

-- 伸缩条动画
function GlobalExtendBarNode:doExtendBarAnim(inAnim, initState)
    if self._extendBarAniming then return end
    if initState ~= nil then 
        self._extendBarIsExtend = initState
    else
        self._extendBarIsExtend = not self._extendBarIsExtend
    end
    if self._extendBarIsExtend then
        -- 展开动画
        self._extendBarAniming = true
        -- self._extendBtn:setRotation(0)
        if self._horizontal == 1 then 
            self._extendBtn:setFlippedX(true)
        else
            self._extendBtn:setFlippedX(false)
        end
        self._extendBg:stopAllActions()
        if inAnim ~= false then
            self._extendBg:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.2, cc.p(100, self._extendBg.___extendPosY)),
                    cc.MoveTo:create(0.2, cc.p(self._extendBg.___extendPosX, self._extendBg.___extendPosY)),
                    cc.CallFunc:create(function ()
                        self._extendBarAniming = false
                        self:initOtherViewBtnTip()
                        if self._motionCallback ~= nil then 
                            self._motionCallback(0)
                        end                        
                    end)
                ))
            for i = 1, #self._extendVisibleBtns do
                local btn = self._extendVisibleBtns[i]
                btn:stopAllActions()
                btn:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.1 + 0.05 * i),
                    cc.Spawn:create(cc.FadeIn:create(0.05), cc.MoveTo:create(0.05, cc.p(btn.___extendPosX, btn.___extendPosY)))
                ))
            end
        else
            self._extendBg:setPosition(self._extendBg.___extendPosX, self._extendBg.___extendPosY)
            self._extendBarAniming = false
            self:initOtherViewBtnTip()
            if self._motionCallback ~= nil then 
                self._motionCallback(0)
            end
            for i = 1, #self._extendVisibleBtns do
                local btn = self._extendVisibleBtns[i]
                btn:stopAllActions()
                btn:setOpacity(255)
                btn:setPosition(btn.___extendPosX, btn.___extendPosY)
            end            
        end
    else
        -- 回收动画
        self._extendBarAniming = true
        local btnOffset = 0
        if self._horizontal == 1 then 
            btnOffset = -self._extendBg:getContentSize().width
            self._extendBtn:setFlippedX(false)
        else
            btnOffset = self._extendBg:getContentSize().width
            self._extendBtn:setFlippedX(true)
        end        
        self._extendBg:stopAllActions()
        if inAnim ~= false then
            self._extendBg:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(0.1, cc.p(100, self._extendBg.___extendPosY)),
                    cc.MoveTo:create(0.15, cc.p(self._extendBg.___extendPosX2, self._extendBg.___extendPosY)),
                    cc.CallFunc:create(function ()
                        self._extendBarAniming = false
                        self:initOtherViewBtnTip()
                        if self._motionCallback ~= nil then 
                            self._motionCallback(1)
                        end                       
                    end)
                ))
            for i = 1, #self._extendVisibleBtns do
                local btn = self._extendVisibleBtns[i]
                btn:stopAllActions()
                btn:runAction(cc.Sequence:create(
                    cc.MoveTo:create(0.1, cc.p(btn.___extendPosX + 5, btn.___extendPosY)),
                    cc.Spawn:create(cc.FadeOut:create(0.15), cc.MoveTo:create(0.15, cc.p(btn.___extendPosX + btnOffset, btn.___extendPosY)))
                ))
            end
        else
            self._extendBg:setPosition(self._extendBg.___extendPosX2, self._extendBg.___extendPosY)
            self._extendBarAniming = false
            self:initOtherViewBtnTip()
            if self._motionCallback ~= nil then 
                self._motionCallback(1)
            end 
            for i = 1, #self._extendVisibleBtns do
                local btn = self._extendVisibleBtns[i]
                btn:stopAllActions()
                btn:setOpacity(0)
                btn:setPosition(btn.___extendPosX + btnOffset, btn.___extendPosY)
            end
        end
    end
end

function GlobalExtendBarNode:checkLockStateCallback(inCallback)
    self._lockStateCallback = inCallback
end

return GlobalExtendBarNode