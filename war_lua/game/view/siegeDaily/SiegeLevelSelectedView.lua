--[[
    Filename:    SiegeLevelSelectedView.lua
    Author:      <hexinping@playcrab.com>
    Datetime:    2017-09-12 
    Description: 攻城日常难度选择UI
--]]


local SiegeLevelSelectedView = class("SiegeLevelSelectedView", BasePopView)

function SiegeLevelSelectedView:ctor(params)
    SiegeLevelSelectedView.super.ctor(self)
    self._container = params.container
    self._theme = params.theme
    self._currLevel = params.level
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
    self._maxLevel , self._totalLevel= self._dailySiegeModel:getMaxLevelCfg(self._theme)
end

function SiegeLevelSelectedView:onInit()
    self._dragonLevelIndex = 1
    -- self._currLevel = 1

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

    -- 初始化 难度选择数据
    self._dragonLevelData = self:initDragonLevelData()

    local offsetX = 0
    local offsetY = 3
    self._dragonPanelW = dragonLevel:getContentSize().width + 10
    self._scrollInnerW = 0 -- scrollView inner 宽度
    local scrollW, scrollH = self.levelScrollView:getContentSize().width, self.levelScrollView:getContentSize().height
    self._scrollW = scrollW -- scrollView 宽度
    self._dragonLevel = {}
    local innerContainerWidth = -offsetX
    for i = 1, self._maxLevel do

        local levelData = self._dragonLevelData[i]
        self._dragonLevel[i] = dragonLevel:clone()
        self._dragonLevel[i]:loadTexture(levelData.unlockPng, 1)
        local passName = self._dragonLevel[i]:getChildByName("name")
        passName:setString(levelData.name)   -- nameList[i]) --
        passName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self:L10N_Text(self._dragonLevel[i])

        local power = self._dragonLevel[i]:getChildByName("power")
        power:setString(levelData.power)   -- nameList[i]) --
        power:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)


        self._dragonLevel[i]:setVisible(true)
        self:registerClickEvent(self._dragonLevel[i], function()
            -- 解锁动画之前点击无效
            -- if self._dragonLevel[i]._locked:isVisible() then
            --     return 
            -- end 
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

        self._dragonLevel[i]:setAnchorPoint(0,0)

        self._dragonLevel[i]:setPosition(innerContainerWidth + offsetX, offsetY)
        self.levelScrollView:addChild(self._dragonLevel[i])
        innerContainerWidth = innerContainerWidth + self._dragonLevel[i]:getContentSize().width
        self._dragonLevel[i].__index = i

    end
    local viewSize = self.levelScrollView:getSize()
    local offset = self._totalLevel == self._maxLevel and 100 or 0
    innerContainerWidth = math.max(viewSize.width, innerContainerWidth) + offset
    self.levelScrollView:setInnerContainerSize(cc.size(innerContainerWidth, scrollH))
    self._scrollInnerW = innerContainerWidth
    self:updateUI(true)    

    self:registerClickEventByName("bg.btn_close", function()
        if self._container and self._container.onSiegeLevelClose then
            self._container:onSiegeLevelClose()
        end
        self:close()
        UIUtils:reloadLuaFile("siegeDaily.SiegeLevelSelectedView")
    end)
end

function SiegeLevelSelectedView:updateUI(isUpdate)
    if not isUpdate then
        self._dragonLevelData = self:initDragonLevelData()
    end
    ScheduleMgr:delayCall(0, self, function()
        if not self or not self._currLevel or not self.levelScrollView or not self._dragonLevel then return end
        local offsetX = self._currLevel <= 4 and 0 or -1 * (self._currLevel - 4 ) * self._dragonPanelW
        if (self._currLevel > 4 and self._currLevel > #self._dragonLevel - 4) or offsetX < self._scrollW - self._scrollInnerW then
            offsetX = self._scrollW - self._scrollInnerW
        end
        self.levelScrollView:getInnerContainer():setPositionX(offsetX)
    end)

    -- self.levelScrollView
    for i = 1, #self._dragonLevel do
        self._dragonLevel[i]._locked:setVisible(not self._dragonLevelData[i].unlock or self._dragonLevelData[i].firstUnlock)
        self._dragonLevel[i]._lockedValue:setString(self._dragonLevelData[i].unlockDes)

        if self._dragonLevel[i]._levelLabel ~= nil then
            self._dragonLevel[i]._levelLabel:setString(self._dragonLevelData[i].name)
        end
  
        self._dragonLevel[i]._btnQuickPass:setVisible(self._dragonLevelData[i].quickPass) 

        if self._dragonLevelData[i].firstUnlock then
            ScheduleMgr:delayCall(800, self, function()
                local unlockMC = mcMgr:createViewMC("pvejiesuo_pokedex", false, true, function()
                    SystemUtils.saveAccountLocalData("SIEGEATTACK_" .. self._theme .. "_LEVEL_UNLOCK_" .. i, 1)
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
    end
end

function SiegeLevelSelectedView:initDragonLevelData()
    local result = {}
    local levelMax = self._maxLevel

    -- 已经打通的关卡最大等级
    local reachLevelMax = self._dailySiegeModel:getChallengeLevelMax()
    local serverData = self._dailySiegeModel:getData()
    local playerCurLevel =  self._modelMgr:getModel("UserModel"):getPlayerLevel() or 1

    for i = 1, levelMax do
        result[i] = {}
        local cfgData = self._dailySiegeModel:getConfigDataByTypeAndDiff(serverData._type1,i) or {}
        -- 解锁等级
        local unlockLevel = 0
        local unlockDes   = ""
        if i > 1 then
            unlockLevel = i - 1
            -- unlockDes = "通过"..lang("LONGZHIGUONANDU_" .. unlockLevel).."难度解锁"
            -- 限制等级
            unlockDes = cfgData.level .. "级解锁"
        end
        local playerLimitLevel = cfgData.level

        local diff  = i 
        local name = lang("LONGZHIGUONANDU_" .. diff)
        local unlockPng = "level"..i.."_globalSelected.png"

        
        local tips = "diff:"..i.."没有配"
        local power  = cfgData.power or tips
        
        if cfgData.power then
            power = "推荐战力:"..string.format("%d", math.floor(power/10000)) .. "万"
        end
        
        -- 是否可以扫荡
        local quickPass = reachLevelMax >= diff

        -- 是否第一次解锁
        local firstUnlock = false
        if i > 1 and reachLevelMax >= unlockLevel and playerCurLevel >= playerLimitLevel and
            1 ~= SystemUtils.loadAccountLocalData("SIEGEATTACK_" .. self._theme .. "_LEVEL_UNLOCK_" .. i) then
            firstUnlock = true
        end 

        result[i].unlock = reachLevelMax >= unlockLevel and playerCurLevel >= playerLimitLevel
        result[i].firstUnlock = firstUnlock
        result[i].unlockLevel = unlockLevel
        result[i].playerLimitLevel = playerLimitLevel
        result[i].unlockDes = unlockDes
        result[i].unlockPng = unlockPng
        result[i].name = name
        result[i].diff = diff
        result[i].power = ""
        result[i].quickPass = quickPass
    end
    return result
end

function SiegeLevelSelectedView:onDragonLevelButtonClicked(index)
    print("onDragonLevelButtonClicked", index)
    if not self._dragonLevelData[index].unlock then

        local varibleNameToValue = {
            ["$level"] = self._dragonLevelData[index].playerLimitLevel
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
    if self._container and self._container.onSiegeLevelSelected then
        self._container:onSiegeLevelSelected(self._dragonLevelIndex)
    end
end

function SiegeLevelSelectedView:onQuickPassButtonClicked(index)
    print("onQuickPassButtonClicked")
    self._dragonLevelIndex = index
    if self._container and self._container.onQuickPass then
        self._container:onQuickPass(self._dragonLevelIndex)
    end
end
function SiegeLevelSelectedView.dtor()
    nameList = nil
end

function SiegeLevelSelectedView:getAsyncRes()
    return  {{"asset/ui/gLevelSelected.plist", "asset/ui/gLevelSelected.png"}}
end

return SiegeLevelSelectedView