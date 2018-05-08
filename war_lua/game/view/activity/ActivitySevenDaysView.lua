--[[
    Filename:    ActivitySevenDaysView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-22 11:46:51
    Description: File description
--]]

local ActivitySevenDaysView = class("ActivitySevenDaysView", BasePopView)

function ActivitySevenDaysView:ctor(data)
    ActivitySevenDaysView.super.ctor(self)
    -- self.initAnimType = 1
    self._callback = data.callback
    
end

function ActivitySevenDaysView:getAsyncRes()
    return  {
                {"asset/ui/acSeven-HD.plist", "asset/ui/acSeven-HD.png"}
            }
end

-- function ActivitySevenDaysView:getBgName()
--     return "bg_001.jpg"
-- end

function ActivitySevenDaysView:onInit()
    self._sevenDaysModel = self._modelMgr:getModel("ActivitySevenDaysModel")

    self._cacheDay = -1
  

    self:listenReflash("UserModel", self.updateNewDay)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.ActivitySevenDaysView")
        elseif eventType == "enter" then 

        end
    end)

end


function ActivitySevenDaysView:reflashUI()
    local closeBtn = self:getUI("bg.closeBtn")
    closeBtn:setScale(1)
    self:registerClickEventByName("bg.closeBtn", function ()
        
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    -- local bg1 = self:getUI("bg1")
    -- bg1:loadTexture("asset/bg/bg_001.jpg")

    local bg1 = self:getUI("bg.bg1")
    bg1:loadTexture("asset/bg/activity_bg_paper.png")


    local leftRoleImg = self:getUI("bg.rolePanel.leftRoleImg")
    leftRoleImg:loadTexture("asset/uiother/team/t_mujingling_2.png")

    -- leftRoleImg:setFlippedX(true)    
    
    local desLabel1 = self:getUI("bg.Label_9")
    desLabel1:setFontSize(24)
    local desLabel2 = self:getUI("bg.Label_11")
    desLabel2:setFontSize(24)   

    self._cellBgH = 110
    self._cellbgW = 574
    self:updateView()
end

function ActivitySevenDaysView:updateView()
    local userModel = self._modelMgr:getModel("UserModel")

    self._cacheDay = userModel:getData().statis.snum6
    -- print("===========self._cacheDay==========",self._cacheDay)
    local labDay = self:getUI("bg.labDay")
    labDay:setFontSize(30)
    labDay:setString(userModel:getData().statis.snum6)

    local sevenDaysData = self._sevenDaysModel:getData()
    if sevenDaysData.loginExt ~= nil then
        self._loginExt = json.decode(sevenDaysData.loginExt)
    end

    local showDay = 0
    self._showKeys = {}

    self._specialDay = 0
    self._specialShow = 0
    for k,v in pairs(tab.activity902) do
        table.insert(self._showKeys, k)
        if v.type == 0 then 
            self._specialDay = k
            self._specialShow = k
        end
    end
    if self._specialDay ~= 0 and sevenDaysData[tostring(self._specialDay)] ~= nil then 
        self._specialDay = 0
    end
    
    table.sort(self._showKeys)
    if self._specialDay ~= 0 then
        for i= #self._showKeys, 1, -1 do
            if self._showKeys[i] > self._specialDay then 
                table.remove(self._showKeys, k)
            end
        end
    end
    local height = #self._showKeys * self._cellBgH + 5
    self._scrollHeight = height
    -- self:getUI("bg.scrollBg.scrollView"):setVisible(false)
    self._scrollView = self:getUI("bg.scrollBg.scrollView")
    -- self._scrollView:setVisible(false)
    self._scrollView:removeAllChildren()
    self._scrollView:setBounceEnabled(true)

    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, height))
    self._scrollView:setClippingEnabled(true)

    height = height - 5

    for k,i in pairs(self._showKeys) do
        local v = tab.activity902[i]
        local cellBg = self:createCell(i, v)
        cellBg:setPosition(6, height)
        self._scrollView:addChild(cellBg)
        height = height - self._cellBgH
    end
    self:updateScrollheight()
end

function ActivitySevenDaysView:updateScrollheight()
    local sevenDaysData = self._sevenDaysModel:getData()
    local showDay = 0
    for k,i in pairs(self._showKeys) do
        local v = tab.activity902[i]
        if (sevenDaysData[tostring(v.id)] == nil and 
            showDay == 0 and 
            self._cacheDay >= v.id) or 
            (v.id > self._cacheDay and showDay == 0 ) then 
            showDay = v.id
        end
    end
    if showDay == 0 then 
        showDay = #self._showKeys
    end
    local height = (showDay - 1) * 100
    local moveToPercent = 0
    local hideArea = self._scrollView:getInnerContainerSize().height - self._scrollView:getContentSize().height
    if height < hideArea then
        moveToPercent = height / hideArea * 100
    else
        moveToPercent = 99.99
    end
    if self._scrollView.moveToPercent ~= moveToPercent then
        self._scrollView:scrollToPercentVertical(moveToPercent, 0, false)
        self._scrollView.moveToPercent = moveToPercent
    end

end

function ActivitySevenDaysView:createCell(index, inData)
    local cellBg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI_activity_cellBg.png")
    cellBg:setContentSize(self._cellbgW,self._cellBgH)
    cellBg:setCapInsets(cc.rect(40,40,1,1))
    cellBg:setName("cellBg" .. index)

    -- local txt = ccui.Text:create()
    -- txt:setFontName(UIUtils.ttfName)
    -- txt:setFontSize(18)
    -- txt:setColor(cc.c4b(122,82,55,255))
    -- txt:setString("获得以下奖励")
    -- txt:setPosition(178,90)
    -- cellBg:addChild(txt,1)

    local x = 146
    local saoguang = false
    local rewards = clone(inData.reward)
    local v = tab.activity902[index]
    if self._loginExt ~= nil and v.extra_num ~= nil then 
        self._loginExt[3] = v.extra_num
        table.insert(rewards, 1, self._loginExt)
    end

    for k,v in pairs(rewards) do
        local itemType = v[1]
        local itemId = v[2]
        local itemNum = v[3]
        local itemIcon

        if index == 8 then
            itemType = "team"
            itemId = itemId - 3000
        end
        saoguang = false
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
            itemIcon:setSwallowTouches(false)
            
            registerClickEvent(itemIcon, function()
                local NewFormationIconView = require "game.view.formation.NewFormationIconView"
                self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemId}, true)
            end)

            saoguang = true
        elseif itemType == "team" then
            local sysTeam = tab:Team(itemId)
            if index == 8 then
                sysTeam = clone(sysTeam)
                sysTeam.starlevel = 3
            end
            
            itemIcon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam, isJin = true})
            itemIcon:setAnchorPoint(cc.p(0,0))
            itemIcon:setScale(0.65)
            saoguang = true
            itemIcon:setSwallowTouches(false)
            -- itemIcon:setSwallowTouches(false)
        else
            if itemType ~= "tool" then
                itemId = IconUtils.iconIdMap[itemType]
            end
            local itemData = tab:Tool(itemId)
            itemIcon = IconUtils:createItemIconById({itemId = itemId, num = itemNum, itemData = itemData})       
            itemIcon:setScale(0.72)
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
                -- spLight:setScale(1.1)
                spLight:setPosition(cc.p(itemIcon:getContentSize().width/2, itemIcon:getContentSize().height/2))
                itemIcon:addChild(spLight, -1)
                spLight:setVisible(true)
            end

            if itemEffect then
                itemEffect:setVisible(true)
            else
                itemEffect = IconUtils:addEffectByName({"tongyongdibansaoguang_itemeffectcollection","wupinkuangxingxing_itemeffectcollection"})      
                itemEffect:setName("itemEffect")
                -- itemEffect:setScale(1.22)
                -- itemEffect:setPosition(cc.p(-13, -13)) -- itemIcon:getContentSize().width/2,itemIcon:getContentSize().height/2
                itemEffect:setVisible(true)
                itemIcon:addChild(itemEffect,60)
            end
        else
            if itemEffect then
                itemEffect:setVisible(false)
            end
            if spLight then
                spLight:setVisible(false)
            end
        end
        if self._specialShow == index and k ~= #rewards then
            local temp1 = cc.Label:createWithTTF("或",UIUtils.ttfName, 20)
            temp1:setColor(cc.c4b(122,82,55,255))
            temp1:setAnchorPoint(cc.p(0, 0.5))
            temp1:setPosition(itemIcon:getPositionX() + (itemIcon:getContentSize().width * itemIcon:getScale() * 0.5) + 5, 55)
            cellBg:addChild(temp1)
            x = x + temp1:getContentSize().width + 5
        end

        x = x + 78  --itemIcon:getContentSize().width * itemIcon:getScale()
    end
    cellBg:setAnchorPoint(0, 1)
 
    --[[
    local tips1 = {}
    tips1[1] = cc.Sprite:createWithSpriteFrameName("activity_num_wordDi.png")

    for i=1, string.len(index) do        
        local num = string.sub(index, i, i)
        tips1[i + 1] = cc.Sprite:createWithSpriteFrameName("activity_num" .. num .. ".png")
    end

    tips1[#tips1 + 1] = cc.Sprite:createWithSpriteFrameName("activity_num_wordDay.png")

    local nodeTip1 = UIUtils:createHorizontalNode(tips1, cc.p(0, 0.5))
    nodeTip1:setAnchorPoint(cc.p(0, 0.5))
    nodeTip1:setPosition(5, 48)
    cellBg:addChild(nodeTip1)   
    if index < 10 then 
        nodeTip1:setScale(0.75)
    else
        nodeTip1:setScale(0.6)
    end
    ]]

    local dayBgImg = ccui.ImageView:create()
    dayBgImg:loadTexture("acSeven_cellDayBg.png",1)
    dayBgImg:setAnchorPoint(0.5,1)
    dayBgImg:setPosition(50, self._cellBgH)
    dayBgImg:setName("dayBgImg")   
    cellBg:addChild(dayBgImg)
    -- 标题
    local title_txt = ccui.Text:create()
    title_txt:setFontSize(22)
    title_txt:setName("title_txt")
    title_txt:setFontName(UIUtils.ttfName)
    title_txt:setString("第" .. index .."天")
    title_txt:setColor(cc.c4b(255,243,164,255))
    title_txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    title_txt:setAnchorPoint(0.5,0.5)
    title_txt:setPosition(50, 70)
    cellBg:addChild(title_txt,2)

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
    local sevenDaysData = self._sevenDaysModel:getData()
    if self._cacheDay >= index then 
        if sevenDaysData[tostring(index)] == nil then 
            registerClickEvent(button,function() 
                self:receiveLoginReward(index)
            end)
            cellBg:addChild(button)
        else
            local getitSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")   --已领取
            getitSp:setPosition(cc.p(502, cellBg:getContentSize().height/2))
            cellBg:addChild(getitSp)
            -- button:setTouchEnabled(false)
            -- button:setSaturation(-180)
        end
    else
        -- button:setTouchEnabled(false)   
        registerClickEvent(button,function() 
             self._viewMgr:showTip("登录天数不足，请明天再来哦~")
        end)            
        button:setSaturation(-180)
        cellBg:addChild(button)        
    end

    return cellBg
end


function ActivitySevenDaysView:receiveLoginReward(inSelectedDay)
    local data = tab.activity902[inSelectedDay]
    if data.type == 0 then 
        local rewards = data.reward
        -- 针对第八天特殊处理奖励显示内容
        if inSelectedDay == 8 then
            rewards = {}
            for k,v in pairs(data.reward) do
                local itemType = v[1]
                local itemId = v[2]
                local itemNum = v[3]
                local tmpReward = {}
                tmpReward[1] = "team"
                tmpReward[2] = itemId - 3000
                tmpReward[3] = 0
                tmpReward[4] = 3
                table.insert(rewards, tmpReward)
            end 
        end
        self._viewMgr:showDialog("global.GlobalSelectAwardDialog", {gift = rewards or {},callback = function(selectedIndex)
            self:receiveLoginReward1(inSelectedDay, selectedIndex)
        end, hide = self})
    else
        self:receiveLoginReward1(inSelectedDay)
    end
end

function ActivitySevenDaysView:receiveLoginReward1(inSelectedDay, inSelectedIndex)
    local param = {day = inSelectedDay, cId = inSelectedIndex}
    self._serverMgr:sendMsg("AwardServer", "receiveLoginReward", param, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            return
        end
        local sevenDaysData = self._sevenDaysModel:getData()
        if sevenDaysData[tostring(inSelectedDay)] == nil then 
            return
        end

        local cellBg = self._scrollView:getChildByName("cellBg" .. inSelectedDay)
        -- dump(cellBg:getContentSize(), "***", 10)
        if cellBg == nil then 
            return
        end


        local cellW, cellH = cellBg:getContentSize().width, cellBg:getContentSize().height
        -- --滚动
        -- if inSelectedDay  <= 3 and self._scrollView:getChildByName("cellBg" .. inSelectedDay+1) then
        --     local tempinSelectedDay = inSelectedDay
        --     if inSelectedDay == 3 then 
        --         tempinSelectedDay = inSelectedDay + 2
        --     end
        --     local num = self._scrollView:getInnerContainerSize().height - self._scrollView:getContentSize().height
        --     local backPercent = tempinSelectedDay  * (100 ) / num
        --     self._scrollView:scrollToPercentVertical(backPercent*100, 0, false)
        -- end

        local getbtn = cellBg:getChildByName("getbtn")
        getbtn:setVisible(false)

        local getitSp = cc.Sprite:createWithSpriteFrameName("globalImageUI_activity_getItBlue.png")
        getitSp:setPosition(cc.p(502, cellBg:getContentSize().height/2))
        cellBg:addChild(getitSp)
        self:updateNewDay()

        DialogUtils.showGiftGet( {
            gifts = result.rewards,
            title = lang("FINISHSTAGETITLE"),
            hide = self,
            callback = function()
            if inSelectedDay <= 3 and self._cacheDay == inSelectedDay then
                self._viewMgr:showDialog("activity.ACPublicityView", {panelType=inSelectedDay}, true)
            end
        end})
        if inSelectedDay == self._specialDay then 
            self:updateView()
        else
            self:updateScrollheight()
        end        
    end)
end


function ActivitySevenDaysView:updateNewDay()
    local userModel = self._modelMgr:getModel("UserModel")
    if self._cacheDay == userModel:getData().statis.snum6 then 
        return
    end
    self._cacheDay = userModel:getData().statis.snum6
    local labDay = self:getUI("bg.labDay")
    labDay:setString(self._cacheDay)

    local cellBg = self._scrollView:getChildByName("cellBg" .. self._cacheDay)
    if cellBg == nil then 
        return
    end

    local getbtn = cellBg:getChildByName("getbtn")
    getbtn:setTouchEnabled(true)
    getbtn:setSaturation(0)
    registerClickEvent(getbtn,function() 
        self:receiveLoginReward(self._cacheDay)
    end)
end


return ActivitySevenDaysView