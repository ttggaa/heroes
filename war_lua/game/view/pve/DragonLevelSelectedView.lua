--[[
    Filename:    DragonLevelSelectedView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-11-11 17:17:28
    Description: File description
--]]


local DragonLevelSelectedView = class("DragonLevelSelectedView", BasePopView)

local MAX_DIFF = 16

function DragonLevelSelectedView:ctor(params)
    DragonLevelSelectedView.super.ctor(self)
    self._container = params.container
    self._data = params.data
    self._dragonId = params.dragonId
    self._userModel = self._modelMgr:getModel("UserModel")
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")

end

function DragonLevelSelectedView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
        element:setFontName(UIUtils.ttfName)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function DragonLevelSelectedView:onInit()
    self:disableTextEffect()
    self._dragonLevelIndex = 1

    self._currLevel = 1
    -- 觉醒任务要挑战的关卡索引
    self._awakingTaskId , self._isOneStage= self._modelMgr:getModel("AwakingModel"):getAwakingTaskDragonCondition()

    local labelTitle = self:getUI("bg.dragon_title_bg.label_title")
    labelTitle:setString("难度选择")
    UIUtils:setTitleFormat(labelTitle, 1)

    local labelTips = self:getUI("bg.label_tips")
    labelTips:setFontName(UIUtils.ttfName)
    labelTips:setString("点击图标选择战斗难度")

    self.levelScrollView = self:getUI("bg.levelView")
    self.levelScrollView:setBounceEnabled(true)

    local dragonLevel = self:getUI("bg.dragon_level")
    dragonLevel:setVisible(false)

    local dragonFinalLevel = self:getUI("bg.dragon_level_final")
    dragonFinalLevel:setVisible(false)
    self:L10N_Text(dragonFinalLevel)

    -- 初始化 难度选择数据
    self._dragonLevelData = self:initDragonLevelData()

    local offsetX = 0
    local offsetY = 3
    -- local nameList = {"容易", "一般", "冒险", "精英", "困难", "专家", "冷酷", "疯狂", "噩梦", "炼狱", "终极挑战"}
    self._dragonPanelW = dragonLevel:getContentSize().width + 10
    self._scrollInnerW = 0 -- scrollView inner 宽度
    local scrollW, scrollH = self.levelScrollView:getContentSize().width, self.levelScrollView:getContentSize().height
    self._scrollW = scrollW -- scrollView 宽度
    self._dragonLevel = {}
    local innerContainerWidth = -offsetX
    for i = 1, MAX_DIFF do
        if i ~= MAX_DIFF then
            self._dragonLevel[i] = dragonLevel:clone()
            self._dragonLevel[i]:loadTexture("level" .. i .. "_globalSelected.png", 1)
        else
            self._dragonLevel[i] = dragonFinalLevel:clone()
        end
        local passName = self._dragonLevel[i]:getChildByName("name")
        passName:setString(lang("LONGZHIGUONANDU_" .. i))   -- nameList[i]) --
        passName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:L10N_Text(self._dragonLevel[i])

        self._dragonLevel[i]:setVisible(true)
        self:registerClickEvent(self._dragonLevel[i], function()
            self:onDragonLevelButtonClicked(i)
        end)
        self._dragonLevel[i]._locked = self._dragonLevel[i]:getChildByFullName("dragon_level_locked")
        self._dragonLevel[i]._locked:setCascadeOpacityEnabled(true)
        self._dragonLevel[i]._lockedValue = self._dragonLevel[i]._locked:getChildByFullName("label_locked")
        self._dragonLevel[i]._lockedValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._dragonLevel[i]._lockedValue:setFontName(UIUtils.ttfName)

        self._dragonLevel[i]._levelLabel = self._dragonLevel[i]._locked:getChildByFullName("label_level")
        self._dragonLevel[i]._levelLabel:setFontName(UIUtils.ttfName)
        if self._dragonLevel[i]._levelLabel ~= nil then
             self._dragonLevel[i]._levelLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end

        self._dragonLevel[i]._btnQuickPass = self._dragonLevel[i]:getChildByFullName("btn_quick_pass")
        self._dragonLevel[i]._btnQuickPass:setScale(0.7)
        self:registerClickEvent(self._dragonLevel[i]._btnQuickPass, function()
            self:onQuickPassButtonClicked(i)
        end)

        if i == MAX_DIFF then
            self._dragonLevel[i]._btnGoOn = self._dragonLevel[i]:getChildByFullName("btn_quick_goOn")
            self._dragonLevel[i]._btnGoOn:setScale(0.7)
            self:registerClickEvent(self._dragonLevel[i]._btnGoOn, function()
                --body 继续挑战
            end)
        end
        
        self._dragonLevel[i]:setAnchorPoint(0,0)
        -- 隐藏 visible == 1 的关卡
        if self._dragonLevelData and self._dragonLevelData[i] and self._dragonLevelData[i].visible == 0 then
            self._dragonLevel[i]:setVisible(true)
            self._dragonLevel[i]:setPosition(innerContainerWidth + offsetX, offsetY)
            self.levelScrollView:addChild(self._dragonLevel[i])
            innerContainerWidth = innerContainerWidth + self._dragonLevel[i]:getContentSize().width + offsetX
        else
            self._dragonLevel[i]:setVisible(false)
            self._dragonLevel[i]:setPosition(0, 640)
            self.levelScrollView:addChild(self._dragonLevel[i])
        end
        self._dragonLevel[i].__index = i

    end
    self.levelScrollView:setInnerContainerSize(cc.size(innerContainerWidth, scrollH))
    self._scrollInnerW = innerContainerWidth
    self:updateUI(true)    

    self:registerClickEventByName("bg.btn_close", function()
        if self._container and self._container.onDragonLevelSelected then
            self._container:onDragonLevelClose()
        end
        self:close()
        UIUtils:reloadLuaFile("pve.DragonLevelSelectedView")
    end)
end

function DragonLevelSelectedView:updateUI(isUpdate)
    if not isUpdate then
        self._dragonLevelData = self:initDragonLevelData()
    end
    ScheduleMgr:delayCall(0, self, function()
        if not self or not self._currLevel or not self.levelScrollView or not self._dragonLevel then return end
        local offsetX = self._currLevel <= 3 and 0 or -1 * (self._currLevel - 3 ) * self._dragonPanelW
        if self._currLevel > #self._dragonLevel - 4 or offsetX < self._scrollW - self._scrollInnerW then
            offsetX = self._scrollW - self._scrollInnerW
        end
        self.levelScrollView:getInnerContainer():setPositionX(offsetX)
    end)

    -- self.levelScrollView
    for i = 1, #self._dragonLevel do
        self._dragonLevel[i]._locked:setVisible(not self._dragonLevelData[i].unlock or self._dragonLevelData[i].firstUnlock)
        self._dragonLevel[i]._lockedValue:setString(self._dragonLevelData[i].unlockLevel .. "级解锁")

        if self._dragonLevel[i]._levelLabel ~= nil then
            self._dragonLevel[i]._levelLabel:setString(self._dragonLevelData[i].levelLabel)
        end
        --[[
        for j = 1, self._data.star[tostring(i)] do
            self._dragonLevel[i]._star[j]:setVisible(true)
        end
        ]]
        
        self._dragonLevel[i]._btnQuickPass:setVisible(self._data.diffList[tostring(i)] and self._data.diffList[tostring(i)] > 0)   --1 == self._privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.LongZhiGuo) and 
        if self._dragonLevelData[i].firstUnlock then
            ScheduleMgr:delayCall(800, self, function()
                local unlockMC = mcMgr:createViewMC("pvejiesuo_pokedex", false, true, function()
                    SystemUtils.saveAccountLocalData("DRAGON_" .. self._dragonId .. "_LEVEL_UNLOCK_" .. i, 1)
                end)
                unlockMC:setPosition(cc.p(self._dragonLevel[i]:getContentSize().width / 2 - 1, self._dragonLevel[i]:getContentSize().height / 2+30))
                self._dragonLevel[i]:addChild(unlockMC, 100)

                unlockMC:addCallbackAtFrame(12, function (_, sender)
                    self._dragonLevel[i]._locked:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(function()
                        self._dragonLevel[i]._locked:setVisible(false)
                    end)))
                end)
            end)
        end

        -- 添加觉醒任务提示气泡
        if self._awakingTaskId then
            local isNeedTip = false
            if self._isOneStage then
                if self._awakingTaskId == self._dragonLevel[i].__index and not self._dragonLevel[i]._awakingTipsImg then
                    isNeedTip = true
                end
            else
                if not self._dragonLevel[i]._awakingTipsImg then
                    if self._awakingTaskId == self._dragonLevel[i].__index then
                        isNeedTip = true
                    elseif self._awakingTaskId < self._dragonLevel[i].__index 
                           and self._dragonLevelData[i].unlock then
                        isNeedTip = true
                    end
                    
                end
            end

            if isNeedTip then
                local img = ccui.ImageView:create()
                img:loadTexture("globalImageUI_awakingTipsImg.png", 1)
                img:setPosition(self._dragonLevel[i]:getContentSize().width*0.5,self._dragonLevel[i]:getContentSize().height - 60)
                self._dragonLevel[i]:addChild(img,100)
                self._dragonLevel[i]._awakingTipsImg = img
            end
        end
    end
end

function DragonLevelSelectedView:initDragonLevelData()
    local result = {}
    local userLevel = self._userModel:getData().lvl
    local pveSetting = tab.pveSetting
    local levelMax = MAX_DIFF

    for i = 1, levelMax do
        result[i] = {}
        result[i].unlockLevel = pveSetting[self._dragonId * 100 + i] and pveSetting[self._dragonId * 100 + i].level or 0
        local diffNum = pveSetting[self._dragonId * 100 + i] and pveSetting[self._dragonId * 100 + i].diff or i
        result[i].levelLabel = lang("LONGZHIGUONANDU_" .. diffNum)
        result[i].unlock = userLevel >= result[i].unlockLevel
        if i >= 2 then
            result[i].unlock = result[i].unlock and (self._data.diffList[tostring(i-1)] and self._data.diffList[tostring(i-1)] > 0)
        end
        result[i].firstUnlock = result[i].unlock and 1 ~= SystemUtils.loadAccountLocalData("DRAGON_" .. self._dragonId .. "_LEVEL_UNLOCK_" .. i)
        if result[i].unlock and self._currLevel < i then
            self._currLevel = i
        end
        result[i].visible = pveSetting[self._dragonId * 100 + i] and pveSetting[self._dragonId * 100 + i].visible or 1
        result[i].id = pveSetting[self._dragonId * 100 + i].id
    end
    return result
end

function DragonLevelSelectedView:onDragonLevelButtonClicked(index)
    print("onDragonLevelButtonClicked", index)
    if not self._dragonLevelData[index].unlock then
        local varibleNameToValue = {
            ["$level"] = self._dragonLevelData[index].unlockLevel
        }
        local description = lang("TIPS_PVE_BOSS_03")
        description = string.gsub(description, "%b{}", function(substring)
            return math.round(loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
                return tostring(varibleNameToValue[variableName])
            end), "[{}]", ""))())
        end)
        self._viewMgr:showTip(description)
        return
    end
    self._dragonLevelIndex = index
    if self._container and self._container.onDragonLevelSelected then
        self._container:onDragonLevelSelected(self._dragonLevelIndex)
    end
end

function DragonLevelSelectedView:onQuickPassButtonClicked(index)
    print("onQuickPassButtonClicked")
    self._dragonLevelIndex = index
    if self._container and self._container.onQuickPass then

        local isNeedTip = false
         if self._awakingTaskId then
            if self._isOneStage then
                if self._awakingTaskId == self._dragonLevel[self._dragonLevelIndex].__index then
                    isNeedTip = true
                end
            else
                if self._awakingTaskId <= self._dragonLevel[self._dragonLevelIndex].__index then
                    isNeedTip = true
                end
            end
        end

        if isNeedTip then 
            DialogUtils.showShowSelect({desc = lang("AWAKING_TIPS_4"), callback1=function( )
                self._container:onQuickPass(self._dragonLevelIndex)
            end})
        else
            self._container:onQuickPass(self._dragonLevelIndex)
        end

    end
end

return DragonLevelSelectedView