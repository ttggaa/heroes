--[[
    Filename:    ActivityLevelFeedBackView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-22 11:54:45
    Description: File description
--]]

local ActivityLevelFeedBackView = class("ActivityLevelFeedBackView", BasePopView)

function ActivityLevelFeedBackView:ctor(params)
    ActivityLevelFeedBackView.super.ctor(self)
    self.initAnimType = 1
    self._callback = params.callback

end

function ActivityLevelFeedBackView:getAsyncRes()
    return  {
                {"asset/ui/acLevel.plist", "asset/ui/acLevel.png"}
            }
end

function ActivityLevelFeedBackView:onDestroy()
    -- GuideUtils.checkTriggerByType("action", "9")   
    ActivityLevelFeedBackView.super.onDestroy(self)
end

function ActivityLevelFeedBackView:onInit()
	self._levelFeedBackModel = self._modelMgr:getModel("ActivityLevelFeedBackModel")

    self:registerScriptHandler(function(state)
        if state == "exit" then
            if self._timerId then 
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerId)
                self._timerId = nil
            end
            UIUtils:reloadLuaFile("activity.ActivityLevelFeedBackView")
        end 
    end)

    self._cellbgW = 574
    self._cellBgH = 110

end

function ActivityLevelFeedBackView:reflashUI()
    local closeBtn = self:getUI("bg.closeBtn")
    closeBtn:setScale(1)
    self:registerClickEventByName("bg.closeBtn", function ()
        if self._callback then
            self._callback()
        end
        self:close()
        -- UIUtils:reloadLuaFile("activity.ActivityLevelFeedBackView")
    end)

    local bg1 = self:getUI("bg.bg1")
    bg1:loadTexture("asset/bg/activity_bg_paper.png")

    local leftRoleImg = self:getUI("bg.rolePanel.leftRoleImg")
    leftRoleImg:loadTexture("asset/uiother/team/t_touhuoguai.png")
    leftRoleImg:setScale(0.76)

    self:listenReflash("UserModel", self.updateNewLevel)
    
    -- self:update()
    -- self._timerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() self:update() end, 1, false)

    self:updateView()
end

function ActivityLevelFeedBackView:update()
    self._modelMgr:getModel("ActivityLevelFeedBackModel"):getTimeOut()
    local levelFBData = self._modelMgr:getModel("ActivityLevelFeedBackModel"):getData()
    local userModel = self._modelMgr:getModel("UserModel")
    local curTime = userModel:getCurServerTime()
    local labTime = self:getUI("bg.labTime")
    if levelFBData.timeOut - curTime  <= 0 then 
        labTime:setString("活动结束")
        if self._timerId then 
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerId)
            self._timerId = nil
        end
    else
        local remainTime = TimeUtils.date("*t", (levelFBData.timeOut - curTime))
        local formatStr = "%02d天%02d:%02d:%02d"
        if remainTime.day < 10 then 
             formatStr = "%01d天%02d:%02d:%02d"
        end

        labTime:setString(TimeUtils.getTimeStringFont1(levelFBData.timeOut - curTime))
    end
end

function ActivityLevelFeedBackView:updateView()
    local userModel = self._modelMgr:getModel("UserModel")
    -- if self._cacheLevel == userModel:getData().lvl then 
    --     return
    -- end
    self._cacheLevel = userModel:getData().lvl


    self._scrollView = self:getUI("bg.scrollBg.scrollView")
    self._scrollView:removeAllChildren()
    self._scrollView:setBounceEnabled(true)
    -- scrollView:setClippingType(1)

    local height = table.nums(tab.activity903) * self._cellBgH + 5 
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
    -- self._scrollView:setClippingType(1)

    height = height - 5
    local levelFBData = self._levelFeedBackModel:getData()
    local showLevel = 0
    local keys = {}
    for k,v in pairs(tab.activity903) do
        table.insert(keys, k)
    end
    table.sort(keys)
    local n = 0
    for k,i in pairs(keys) do
        n = n + 1
        local v = tab.activity903[i]
        local cellBg = self:createCell(i, v)
        cellBg:setPosition(6, height)
        self._scrollView:addChild(cellBg)
        height = height - self._cellBgH
        if (levelFBData[tostring(v.id)] == nil and 
            showLevel == 0 and 
            self._cacheLevel >= v.id) or 
            (v.id > self._cacheLevel and showLevel == 0 )then 
            showLevel = n
        end
    end
    if showLevel == 0 then 
        showLevel = #keys
    end
    self:updateScrollheight(showLevel)
end


function ActivityLevelFeedBackView:updateScrollheight(showLevel)
    local height = (showLevel - 1) * (self._cellBgH - 10)
    local movePercent = 0
    local hideArea = self._scrollView:getInnerContainerSize().height - self._scrollView:getContentSize().height
    if height < hideArea then
        moveToPercent = height / hideArea * self._cellBgH
    else
        moveToPercent = 99.99
    end
    self._scrollView:scrollToPercentVertical(moveToPercent, 0, false)
end

function ActivityLevelFeedBackView:createCell(index, inData)
    local cellBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI_activity_cellBg.png")
    cellBg:setContentSize(self._cellbgW,self._cellBgH)
    cellBg:setCapInsets(cc.rect(40,40,1,1))
    cellBg:setName("cellBg" .. index)
    local x = 146
    local saoguang = false
    for k,v in pairs(inData.reward) do
        local itemType = v[1]
        local itemId = v[2]
        local itemNum = v[3]
        local itemIcon
        if itemType == "hero" then
            local sysHeroData = tab:Hero(itemId)
            itemIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData})
            itemIcon:setName("itemIcon")
            -- itemIcon:setAnchorPoint(cc.p(0,0))
            itemIcon:setScale(0.68)
            itemIcon:getChildByName("starBg"):setVisible(false)
            for i=1,6 do
                if itemIcon:getChildByName("star" .. i) then
                    itemIcon:getChildByName("star" .. i):setPositionY(itemIcon:getChildByName("star" .. i):getPositionY() + 5)
                end
            end

            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)
            
            -- local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
            -- mc1:setPosition(itemIcon:getContentSize().width/2 ,itemIcon:getContentSize().height/2)

            -- local clipNode = cc.ClippingNode:create()
            -- clipNode:setInverted(false)

            -- local mask = cc.Sprite:createWithSpriteFrameName("golbalIamgeUI5_tmp1.png")
            -- mask:setScale(1.25)
            -- mc1:setPosition(35,35)
            -- mask:setAnchorPoint(0, 0)
            -- clipNode:setStencil(mask)
            -- clipNode:setAlphaThreshold(0.05)
            -- clipNode:addChild(mc1)
            -- clipNode:setPosition(cc.p(6, 6))
            -- itemIcon:addChild(clipNode, 3)
            itemIcon:setSwallowTouches(false)

            saoguang = true
        elseif itemType == "team" then
            local sysTeam = tab:Team(itemId)
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam, isJin = true})
            itemIcon:setAnchorPoint(cc.p(0.5,0.5))
            itemIcon:setScale(0.65)
            itemIcon:setSwallowTouches(false)
            saoguang = true
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local itemData = tab:Tool(itemId)
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum, itemData = itemData})       
            itemIcon:setScale(0.72)
            saoguang = false
        end
        itemIcon:setPosition(x, 55)
        itemIcon:setAnchorPoint(0.5, 0.5)
        cellBg:addChild(itemIcon)

        local itemEffect = itemIcon:getChildByName("itemEffect")
        local spLight = itemIcon:getChildByName("spLight")
        if saoguang == true then
            if spLight then
                spLight:setVisible(true)
            else
                spLight = mcMgr:createViewMC("diguang_itemeffectcollection", true, false, nil, RGBA8888)
                spLight:setName("spLight")
                -- spLight:setScale(1.2)
                spLight:setPosition(cc.p(itemIcon:getContentSize().width/2, itemIcon:getContentSize().height/2))
                itemIcon:addChild(spLight, -1)
                spLight:setVisible(true)
            end

            if itemEffect then
                itemEffect:setVisible(true)
            else
                itemEffect = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})      
                itemEffect:setName("itemEffect")
                -- itemEffect:setScale(1.2)
                -- itemEffect:setPosition(cc.p(itemIcon:getContentSize().width/2, itemIcon:getContentSize().height/2))
                itemEffect:setVisible(true)
                itemIcon:addChild(itemEffect)
            end
        else
            if itemEffect then
                itemEffect:setVisible(false)
            end
            if spLight then
                spLight:setVisible(false)
            end
        end
        if inData.rewardType == 0 then
            itemIcon:setPositionX(x-6)
            x = x + 70
            itemIcon:setScale(0.6)
            if k ~= #inData.reward then
                local temp1 = cc.Label:createWithTTF("或",UIUtils.ttfName, 20)
                temp1:setColor(cc.c4b(122,82,55,255))
                temp1:setAnchorPoint(cc.p(0, 0.5))
                temp1:setPosition(itemIcon:getPositionX() + (itemIcon:getContentSize().width * itemIcon:getScale() * 0.5) + 5, 55)
                cellBg:addChild(temp1)
                x = x + temp1:getContentSize().width 
            end
        else
            x = x + 78
        end
            -- local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
            --     mc1:setPosition(itemIcon:getContentSize().width/2 ,itemIcon:getContentSize().height/2)

            --     local clipNode = cc.ClippingNode:create()
            --     clipNode:setInverted(false)

            --     local mask = cc.Sprite:createWithSpriteFrameName("golbalIamgeUI5_tmp1.png")
            --     mask:setScale(1.25)
            --     mc1:setPosition(35,35)
            --     mask:setAnchorPoint(0, 0)
            --     clipNode:setStencil(mask)
            --     clipNode:setAlphaThreshold(0.05)
            --     clipNode:addChild(mc1)
            --     clipNode:setPosition(cc.p(5, 5))
            --     itemIcon:addChild(clipNode, 10)

        
    end
    cellBg:setAnchorPoint(0, 1)
    

    local dayBgImg = ccui.ImageView:create()
    dayBgImg:loadTexture("acLevel_cellDayBg.png",1)
    dayBgImg:setAnchorPoint(0.5,1)
    dayBgImg:setPosition(50, self._cellBgH)
    dayBgImg:setName("dayBgImg")   
    cellBg:addChild(dayBgImg)
    -- 标题
    local title_txt = ccui.Text:create()
    title_txt:setFontSize(22)
    title_txt:setName("title_txt")
    title_txt:setFontName(UIUtils.ttfName)
    title_txt:setString("Lv." .. index)
    title_txt:setColor(cc.c4b(255,243,164,255))
    title_txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    title_txt:setAnchorPoint(0.5,0.5)
    title_txt:setPosition(50, 70)
    cellBg:addChild(title_txt,2)
    --[[
    local tips1 = {}
    tips1[1] = cc.Sprite:createWithSpriteFrameName("activity_num_Level.png")

    for i=1, string.len(index) do
        local num = string.sub(index, i, i)
        tips1[i + 1] = cc.Sprite:createWithSpriteFrameName("activity_num" .. num .. ".png")
        tips1[i + 1]:setScale(0.6)
    end

    local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
    nodeTip1:setAnchorPoint(cc.p(0, 0.5))
    nodeTip1:setPosition(5, 48)
    cellBg:addChild(nodeTip1)  
    ]] 
    
    -- local tips1 = {}
    -- tips1[1] = cc.Label:createWithTTF("LV",UIUtils.ttfName, 22)
    -- tips1[1]:setColor(cc.c4b(250, 225, 13, 255))
    -- tips1[1]:enableOutline(cc.c4b(100, 75, 7, 255), 2)

    -- tips1[2] = cc.Label:createWithTTF(index,UIUtils.ttfName, 36)
    -- tips1[2]:setColor(cc.c4b(250, 225, 13, 255))
    -- tips1[2]:enableOutline(cc.c4b(100, 75, 7, 255), 2)

    -- local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
    -- tips1[2]:setPosition(tips1[2]:getPositionX(), tips1[2]:getPositionY()+3)
    -- nodeTip1:setAnchorPoint(cc.p(0, 0))
    -- nodeTip1:setPosition(10, 20)
    -- cellBg:addChild(nodeTip1)

    -- self._levelFeedBackModel:getData()
    local button = ccui.Button:create("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "", 1)
    local itemIconLayout = ccui.LayoutComponent:bindLayoutComponent(button)
    itemIconLayout:setHorizontalEdge(ccui.LayoutComponent.HorizontalEdge.Left)
    itemIconLayout:setVerticalEdge(ccui.LayoutComponent.VerticalEdge.Top)
    itemIconLayout:setStretchWidthEnabled(false)
    itemIconLayout:setStretchHeightEnabled(false)
    itemIconLayout:setSize(button:getContentSize())
    itemIconLayout:setLeftMargin(0)
    itemIconLayout:setTopMargin(0)


    button:setAnchorPoint(cc.p(0.5, 0.5))
    button:setName("button")
    button:setScale(0.8)
    button:setPosition(cc.p(502, cellBg:getContentSize().height/2))
    button:ignoreContentAdaptWithSize(false)
    button:setTitleText("领取")
    -- button:setSwallowTouches(false)
    button:setName("getbtn")
    -- self:L10N_Text(button)
    button:setTitleFontName(UIUtils.ttfName)
    button:setColor(cc.c4b(255, 255, 255, 255))
    button:getTitleRenderer():enableOutline(cc.c4b(153, 93, 0, 255), 2) --(cc.c4b(101, 33, 0, 255), 2)
    button:setTitleFontSize(28)
    local sevenDaysData = self._levelFeedBackModel:getData()
    if self._cacheLevel >= index then 
        if sevenDaysData[tostring(index)] == nil then 
            registerClickEvent(button,function() 
                self:receiveLevelReward(index, inData.rewardType)
            end)
            cellBg:addChild(button)
        else
            local getitSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
            getitSp:setPosition(cc.p(502, cellBg:getContentSize().height/2))
            cellBg:addChild(getitSp)
            -- button:setTouchEnabled(false)
            -- button:setSaturation(-180)
        end
    else
        button:setTouchEnabled(false)
        button:setSaturation(-180)
        cellBg:addChild(button)
    end
    return cellBg
end


function ActivityLevelFeedBackView:receiveLevelReward(inSelectedData)
    print(
        "inSelectedData=====================", inSelectedData)
    local sysData = tab.activity903[inSelectedData]
    if sysData.rewardType == 0 then 
        self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = sysData.reward or {}, callback = function(selectedIndex)
            self:receiveLevelReward1(inSelectedData, selectedIndex)
        end})
    else
        self:receiveLevelReward1(inSelectedData)
    end
end

function ActivityLevelFeedBackView:receiveLevelReward1(inSelectedData, inSelectedIndex)
    local levelFBData = self._modelMgr:getModel("ActivityLevelFeedBackModel"):getData()
    local userModel = self._modelMgr:getModel("UserModel")
    -- local curTime = userModel:getCurServerTime()
    -- if levelFBData.timeOut - curTime  <= 0 then 
    --     self._viewMgr:showTip("活动已结束")
    -- end
    local param = {level = inSelectedData, cId = inSelectedIndex}
    self._serverMgr:sendMsg("AwardServer", "receiveLevelReward", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            return
        end
        local sevenDaysData = self._levelFeedBackModel:getData()
        if sevenDaysData[tostring(inSelectedData)] == nil then 
            return
        end

        local cellBg = self._scrollView:getChildByName("cellBg" .. inSelectedData)
        if cellBg == nil then 
            return
        end
        local getbtn = cellBg:getChildByName("getbtn")
        getbtn:setVisible(false)

        local getitSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
        getitSp:setPosition(cc.p(502, cellBg:getContentSize().height/2))
        cellBg:addChild(getitSp)
        self:updateNewLevel()

        DialogUtils.showGiftGet( {
            hide = self,
            gifts = result.rewards,
            title = lang("FINISHSTAGETITLE"),
            callback = function()
        end})
    end)
end


function ActivityLevelFeedBackView:updateNewLevel()
    local userModel = self._modelMgr:getModel("UserModel")
    if self._cacheLevel == userModel:getData().lvl then 
        return
    end
    self._cacheLevel = userModel:getData().lvl

    local cellBg = self._scrollView:getChildByName("cellBg" .. self._cacheLevel)
    if cellBg == nil then 
        return
    end

    local getbtn = cellBg:getChildByName("getbtn")
    getbtn:setTouchEnabled(true)
    getbtn:setSaturation(0)
    registerClickEvent(getbtn,function() 
        self:receiveLevelReward(self._cacheLevel)
    end)
end


return ActivityLevelFeedBackView