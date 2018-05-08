--[[
    Filename:    VipWeekGiftLayer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-08-14 20:06:29
    Description: File description
--]]

local modf = math.modf
local cc = cc
local VipWeekGiftLayer = class("VipWeekGiftLayer", 
    require("game.view.activity.common.ActivityCommonLayer"))

function VipWeekGiftLayer:ctor()
    VipWeekGiftLayer.super.ctor(self)
    -- self:notice1()
    self._activityModel = self._modelMgr:getModel("ActivityModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._noticeModel = self._modelMgr:getModel("NoticeModel")
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            for _,sprites in pairs (self._randSp) do
                for _,sprite in pairs (sprites) do 
                    sprite:release()
                end 
            end
            self._noticeModel:setSpecailType(nil)
            UIUtils:reloadLuaFile("activity.common.VipWeekGiftLayer")
        elseif eventType == "enter" then 
        end
    end)
    self._idx = 1
    self._data = self._activityModel:getWeeklyGift()
    self._data.haveIn = true

    self._rewardData = self._data.weeklyGifts
    self._acBeginPos = cc.p(32,-30)
    self._middlePos = cc.p(32,31)
    self._endPos = cc.p(32,94)
    self._noticeModel:setSpecailType("GUANGBO_vipgift")
    self._vipModel = self._modelMgr:getModel("VipModel")
end

-- function VipWeekGiftLayer:notice1()
--     self._setVisible = self.setVisible
--     -- 拦截visible 做相关处理
--     self.setVisible = function(self,isVisible)
--         if self:isVisible() == isVisible then 
--             return 
--         end
--         local bg = self:getUI("richBg.bg")
--         if isVisible == false then
--             if self._textBg ~= nil then 
--                 self._textBg:stopAllActions()
--                 self._cachePosition = self._textBg:getPositionX()
--             end
--             bg:setOpacity(0)
--         else
--             if self._textBg ~= nil then
--                 bg:runAction(cc.FadeTo:create(0.2, 150))
--                 local maxWidth = (self._textBg:getContentSize().width + self._cacheMoveToX)
--                 local parent = math.abs((self._cachePosition + self._cacheMoveToX) / maxWidth)
--                 self._textBg:runAction(cc.Sequence:create(
--                         cc.MoveTo:create(self._cacheMoveTime * parent, cc.p(- self._cacheMoveToX, 0)), 
--                         cc.CallFunc:create(function() 
--                                 self._isShow = false
--                                 self:reflashNotice()
--                                 print("_richText finish") 
--                         end)))              
--             end
--         end
--         self:_setVisible(isVisible)
--     end
-- end

function VipWeekGiftLayer:onTop()
    
end

function VipWeekGiftLayer:onInit()
    local bg_image = self:getUI("bg.bg_image")
    bg_image:loadTexture("asset/bg/vipGiftBg.jpg")
    self._scrollView = self:getUI("bg.list")
    self._scrollView:setClippingEnabled(true)
    local try_btn = self:getUI("bg.try_btn")
    self:registerClickEvent(try_btn,function()
        self:tryLuck()
    end)

    local buy_btn = self:getUI("bg.buy")
    self:registerClickEvent(buy_btn,function()
        self:buyGift()
    end)

    local newPrice = self:getUI("bg.newPrice")
    newPrice:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local overLabel1 = self:getUI("bg.overLabel1")
    local overLabel2 = self:getUI("bg.overLabel2")
    local overLabel3 = self:getUI("bg.overLabel3")
    overLabel1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    overLabel2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    overLabel3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local title1 = self:getUI("bg.title1")
    -- local educeLabel = self:getUI("bg.educeLabel")
    title1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- educeLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local richBg = self:getUI("richBg.bg")
    richBg:setOpacity(0)
    -- 移动所到点
    self._cacheMoveToX = 0
    -- 移动时间
    self._cacheMoveTime = 0
    -- 当前移动点
    self._cachePosition = 0

    self._isShow = false

    self:initButtonView()
    
    -- bg:setPosition(14,15)
    self:refreshUI()
    self:cacheRandSprite()
    -- self:getNoticeData()

    ScheduleMgr:delayCall(100, self, function()
        pcall(function()
            self.parentView:updateTabRed()
        end)
    end)

end

--[[
    请求公告信息
]]
-- function VipWeekGiftLayer:getNoticeData()
--     self._serverMgr:sendMsg("ActivityServer", "getWeeklyGiftNotice", {}, true, {}, function(result)

--     end)
-- end



-- --[[
--     刷新公告
-- ]]
-- function VipWeekGiftLayer:reflashNotice(inData)
--     print("##############################1123")
--     if inData ~= nil and inData.clearState == true then 
--         if self._textBg ~= nil then 
--             self._textBg:stopAllActions()
--             self._textBg:removeFromParent()
--             self._textBg = nil
--         end
--         self._isShow = false
--         return
--     end
--     print("##############################11234")
--     if self._isShow == true then
--         return 
--     end
--     print("##############################1125")
--     local bg = self:getUI("richBg.bg")

--     if self._textBg ~= nil then 
--         self._textBg:stopAllActions()
--         self._textBg = nil
--     end
--     print("##############################1126")
--     local noticeData = self._noticeModel:getNoticeData("GUANGBO_vipgift")
--     dump(noticeData,"noticeData",10)
--     if noticeData == nil then 
--         self._isShow = false
--         bg:runAction(cc.FadeTo:create(0.2, 0))
--         return
--     end
--     print("##############################1127")
--     self._isShow = true
--     bg:removeAllChildren()
--     bg:runAction(cc.FadeTo:create(0.2, 150))

--     self._textBg =  cc.Layer:create()
--     self._textBg:setAnchorPoint(0, 0)

--     --富文本
--     local context = self:getRichText(noticeData)
--     if context == nil then 
--         self._isShow = false
--         self._textBg = nil
--         bg:setOpacity(0)
--         return 
--     end
--     pcall(function()
--         local richText = RichTextFactory:create(context, 3000, 0)
--         richText:formatText()

--         self._textBg:setContentSize(richText:getRealSize().width, bg:getContentSize().height)
--         richText:setPosition(richText:getContentSize().width/2, self._textBg:getContentSize().height/2)
--         self._textBg:addChild(richText)
--     end)


--     self._textBg:setPosition(bg:getContentSize().width, 0)

--     bg:addChild(self._textBg)

--     self._cacheMoveToX = self._textBg:getContentSize().width 
--     self._cacheMoveTime = 4 * (1 + self._cacheMoveToX / self._textBg:getContentSize().width)
--     self._textBg:runAction(cc.Sequence:create(
--             cc.MoveTo:create(self._cacheMoveTime, cc.p(-self._cacheMoveToX, 0)), 
--             cc.CallFunc:create(function() 
--                 self._isShow = false
--                 self:reflashNotice()
--             end)))
-- end

-- function VipWeekGiftLayer:getRichText(inData)
--     local context = "[color=fa921a,outlinecolor=3c1e0a,fontsize=16]空{$name}{$num}[-]"
--     --限时神将
--     if inData.bdType and inData.bdType == "limitTeam" then 
--         if inData["type"] == 1 then   --整卡
--             context = lang("GUANGBO_ac1001_2")
--             context = string.gsub(context, "{$name}", inData["name"])
--         elseif inData["type"] == 3 then  --招募
--             context = lang("GUANGBO_ac1001_1")
--             context = string.gsub(context, "{$name}", inData["name"])
--         end

--     else
--         context = lang(inData.id)
--         if context == nil then
--             return nil
--         end

--         for i,v in pairs(inData.replace) do
--             local releaceData = string.split(v, "::")
--             if #releaceData == 2 then
--                 local name = releaceData[2]
--                 if string.find(releaceData[1], '$teamId') ~= nil then
--                     local sysTeam = tab:Team(tonumber(releaceData[2]))
--                     name = lang(sysTeam.name)

--                 elseif string.find(releaceData[1], '$gift') ~= nil then
--                     local chatModel = self._modelMgr:getModel("ChatModel")
--                     local giftId = chatModel:getGiftId(releaceData[2])
--                     local sysTool = tab:Tool(tonumber(giftId))
--                     name = lang(sysTool.name)
--                 end
--                 local uresult,count1 = string.gsub(context, releaceData[1], name)
--                 if count1 > 0 then 
--                     context = uresult
--                 end
--             end
--         end
--     end

--     return context
-- end

function VipWeekGiftLayer:cacheRandSprite()
    self._randSp = {{},{},{},{}}
    for k=1,4 do 
        for i=1,10 do 
            local sprite = cc.Sprite:createWithSpriteFrameName("weekGiftRandNum".. (i-1) .. ".png")
            sprite:retain()
            self._randSp[k][i] = sprite
        end
    end
end

function VipWeekGiftLayer:tryLuck()

    --vip 等级
    local level = self._vipModel:getLevel()
    if level < self._curIndex - 1 then
        DialogUtils.showNeedCharge({desc = "VIP等级不足，是否前去充值", callback1=function()
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end})
        return
    end

    self._serverMgr:sendMsg("ActivityServer", "weeklyGiftRandomCut", {giftId = self._curIndex}, true, {}, function(result)
        dump(result,"aaa",10)
        if not result then return end
        if result.d and result.d.vipWeeklyGift and result.d.vipWeeklyGift.weeklyGifts then
            local data = result.d.vipWeeklyGift.weeklyGifts
            local key = table.keys(data)[1]
            self._activityModel:updateWeeklyGiftAfterLuck(self._curIndex,data[key])
            self:resultAnima(data[key]["cut"])
        end
    end)
end

function VipWeekGiftLayer:buyGift()
    local tabData = tab:WeeklyGift(self._curIndex)
    local curData = self:getSingleDataByIndex(self._curIndex)
    local realPrice = tonumber(tabData.price) - curData.cut
    local user_gem = self._userModel:getData().gem

    if user_gem < realPrice then
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
            self._viewMgr:showView("vip.VipView", {viewType = 0})
        end})
        return
    end

    self._serverMgr:sendMsg("ActivityServer", "buyWeeklyGift", {giftId = self._curIndex}, true, {}, function(result)
        dump(result,"sssss",10)
        if not result then return end
        self._activityModel:updateWeeklyGiftDataAfterGet(self._curIndex)
        self:showMiddleView(self._curIndex)
        if result.reward then
            DialogUtils.showGiftGet({gifts = result.reward})
        end
    end)
end

--[[
    动画
]]
function VipWeekGiftLayer:playAni(status)
    if status then
        if not self._mc then
            local bg = self:getUI("bg")
            self._mc = mcMgr:createViewMC("fenxianghaolideng_fenxianghaoli", true, false)
            self._mc:setPosition(cc.p(317, 187))
            bg:addChild(self._mc)
        else
            self._mc:setVisible(status)
        end
    else
        if self._mc then
            self._mc:setVisible(false)
        end
    end
    
end

function VipWeekGiftLayer:resultAnima(cutNum)
    if not cutNum or tonumber(cutNum) < 0 then return end
    local list = self:getRandNums(cutNum)
    local count = 4
    -- local function nextAni(index)
    --     -- print("count",count,index)
    --     if count <= 0 or index <= 0 then
    --         ScheduleMgr:delayCall(0, self, function()
    --             self:showMiddleView(self._curIndex)
    --         end)
    --         self._viewMgr:unlock()
    --         self:playAni(false)
    --         return
    --     end
    --     local num = list[index]
    --     local panel = self:getUI("bg.randPanel"..index)
    --     count = count - 1
    --     self:randNumberAnimation(panel,1,num,function()
    --         nextAni(index-1)
    --     end)
    -- end

    self._viewMgr:lock(-1)
    local cir = {4,3,2,1}
    for i=4,1,-1 do 
        local panel = self:getUI("bg.randPanel"..i)
        local num = list[i]
        self:randNumberAnimation(panel,cir[i],num,i,function()
            if i == 1 then
                ScheduleMgr:delayCall(0, self, function()
                    self:showMiddleView(self._curIndex)
                end)
                self._viewMgr:unlock()
                self:playAni(false)
            end
        end)
    end
    -- self:randNumberAnimation(panel,1,num,function()
    --     nextAni(index-1)
    -- end)
    -- nextAni(4)
    self:playAni(true)
end

--[[
    VIP 按钮
]]
function VipWeekGiftLayer:initButtonView()
    local vipCount = 16
    local width = 56
    for i=1,vipCount do 
        local buttonImage = ccui.ImageView:create()
        buttonImage:loadTexture("weekGift_btn2.png",1)
        self._scrollView:addChild(buttonImage)
        buttonImage:setAnchorPoint(0,0)
        buttonImage:setPosition((i-1)*width,2)

        local buttonLable = cc.Label:createWithTTF("v".. (i-1), UIUtils.ttfName, 20)
        buttonImage:addChild(buttonLable)
        buttonLable:setPosition(28,18)
        buttonLable:setName("btnLabel")
        buttonLable:setColor(cc.c3b(132,119,110))
        buttonLable:enableOutline(cc.c4b(110,44,0,255), 2)

        self:registerClickEvent(buttonImage,function()
            self:clickIndex(buttonImage,i)
        end)
        if self._idx == i then
            self:clickIndex(buttonImage,i)
        end
    end
    self._scrollView:setInnerContainerSize(cc.size(vipCount*width,40))

end

function VipWeekGiftLayer:clickIndex(sender,index)
    print(">>>>>>>>>>>>>>>>>",index)
    if self._preItem == sender then return end
    if not tolua.isnull(self._preItem) then
        self._preItem:loadTexture("weekGift_btn2.png",1)
        local lable = self._preItem:getChildByName("btnLabel")
        lable:setColor(cc.c3b(132,119,110))
    end

    self._preItem = sender
    self._curIndex = index
    sender:loadTexture("weekGift_btn1.png",1)
    local lable = sender:getChildByName("btnLabel")
    lable:setColor(cc.c3b(255,238,160))

    self:showMiddleView(index)
end

function VipWeekGiftLayer:getSingleDataByIndex(index)
    return self._rewardData[tostring(index)] or {}
end

function VipWeekGiftLayer:showMiddleView(index)
    local overLabel1 = self:getUI("bg.overLabel1")
    local overLabel2 = self:getUI("bg.overLabel2")
    local overLabel3 = self:getUI("bg.overLabel3")
    overLabel1:setVisible(false)
    overLabel2:setVisible(false)
    overLabel3:setVisible(false)

    local originPrice = self:getUI("bg.originPrice")
    local newPrice = self:getUI("bg.newPrice")
    local line = self:getUI("bg.line")
    local originPrice1 = self:getUI("bg.originPrice1")
    originPrice:setVisible(false)
    newPrice:setVisible(false)
    line:setVisible(false)
    originPrice1:setVisible(false)

    local try_btn = self:getUI("bg.try_btn")
    local haveBuy = self:getUI("bg.haveBuy")
    local buy = self:getUI("bg.buy")
    try_btn:setVisible(false)
    haveBuy:setVisible(false)
    buy:setVisible(false)

    local randPanel1 = self:getUI("bg.randPanel1")
    local randPanel2 = self:getUI("bg.randPanel2")
    local randPanel3 = self:getUI("bg.randPanel3")
    local randPanel4 = self:getUI("bg.randPanel4")


    -- icon
    local iconBg = self:getUI("bg.icon")
    local tabData = tab:WeeklyGift(index)
    local gift = tabData.gift
    local toolData
    local toolIcon = iconBg:getChildByFullName("toolIcon")
    local heroIcon = iconBg:getChildByFullName("heroIcon")
    local teamIcon = iconBg:getChildByFullName("teamIcon")
    local weaponIcon = iconBg:getChildByFullName("weaponIcon")

    if not tolua.isnull(heroIcon) then
        heroIcon:setVisible(false)
    end
    if not tolua.isnull(toolIcon) then
        toolIcon:setVisible(false)
    end
    if not tolua.isnull(teamIcon) then
        teamIcon:setVisible(false)
    end
    if not tolua.isnull(weaponIcon) then
        weaponIcon:setVisible(false)
    end

    local itemType = gift[1]
    local itemID = gift[2]
    if itemType == "tool" then
        toolData = tab:Tool(itemID)
    elseif itemType == "team" then
        toolData = tab:Team(itemID)
    elseif itemType == "hero" then
        toolData = tab:Hero(itemID)
    elseif itemType == "siegeProp" then
        toolData = tab:SiegeEquip(itemID)
    else
        itemID = IconUtils.iconIdMap[itemType]
        toolData = tab:Tool(itemID)
    end
    print("itemID",itemID)
    if itemType == "tool" then
        if toolIcon then
            IconUtils:updateItemIconByView(toolIcon,{itemId = itemID,itemData = toolData,num = gift[3],effect = false})
            toolIcon:setVisible(true)
        else
            local icon
            icon = IconUtils:createItemIconById({itemId =  itemID,itemData = toolData,num = gift[3],effect = false})
            icon:setAnchorPoint(0.5,0.5)
            icon:setScale(0.88)
            icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+2)
            iconBg:addChild(icon)
            icon:setName("toolIcon")
        end
        iconBg:setTouchEnabled(false)
    elseif itemType == "team" then
        if teamIcon then
            IconUtils:updateSysTeamIconByView(teamIcon, {sysTeamData = toolData,isGray = false,isJin = true})
            teamIcon:setVisible(true)
        else
            teamIcon = IconUtils:createSysTeamIconById({sysTeamData = toolData,isGray = false,isJin = true})
            teamIcon:setName("teamIcon")
            teamIcon:setAnchorPoint(0.5,0.5)
            teamIcon:setScale(0.76)
            teamIcon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+2)
            iconBg:addChild(teamIcon)
        end
        iconBg:setTouchEnabled(false)
    elseif itemType == "hero" then
        local param = {sysHeroData = toolData, effect = false}
        if heroIcon then
            heroIcon:setVisible(true)
            IconUtils:updateHeroIconByView(heroIcon, param)
        else
            heroIcon = IconUtils:createHeroIconById(param)
            heroIcon:setName("heroIcon")
            heroIcon:setAnchorPoint(0.5,0.5)
            heroIcon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+2)
            heroIcon:setScale(0.8)
            iconBg:addChild(heroIcon)
        end
        registerClickEvent(iconBg, function()
            local NewFormationIconView = require "game.view.formation.NewFormationIconView"
            self._viewMgr:showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalHero, iconId = itemID}, true)
        end)

    elseif itemType == "siegeProp" then
        local param = {itemId = itemID, level = 1, itemData = toolData, quality = toolData.quality, iconImg = toolData.art, eventStyle = 1}
        if weaponIcon then
            weaponIcon:setVisible(true)
            IconUtils:updateWeaponsBagItemIcon(weaponIcon, param)
        else
            weaponIcon = IconUtils:createWeaponsBagItemIcon(param)
            weaponIcon:setName("weaponIcon")
            weaponIcon:setAnchorPoint(0.5,0.5)
            weaponIcon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+2)
            weaponIcon:setScale(0.8)
            iconBg:addChild(weaponIcon)
        end

    else
        if toolIcon then
            IconUtils:updateItemIconByView(toolIcon,{itemId = itemID,itemData = toolData,num = gift[3],effect = false})
            toolIcon:setVisible(true)
        else
            local icon
            icon = IconUtils:createItemIconById({itemId =  itemID,itemData = toolData,num = gift[3],effect = false})
            icon:setAnchorPoint(0.5,0.5)
            icon:setScale(0.88)
            icon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2+2)
            iconBg:addChild(icon)
            icon:setName("toolIcon")
        end
        iconBg:setTouchEnabled(false)
    end
    

    --立减范围
    -- local educeLabel = self:getUI("bg.educeLabel")
    -- educeLabel:setVisible(true)
    -- local showoff = tabData.showoff
    -- local str = showoff[1] .. "-" .. showoff[2]
    -- educeLabel:setString(str)


    local curData = self:getSingleDataByIndex(index)
    -- curData.cut = 101
    if curData.cut and curData.cut > 0 then --已经试玩手气，else 没有试手气
        originPrice:setVisible(true)
        newPrice:setVisible(true)
        line:setVisible(true)
        originPrice:setString("原价:"..tabData.price)
        newPrice:setString("现价:" .. tonumber(tabData.price) - curData.cut)
        local result = self:getRandNums(curData.cut)
        for i=1,4 do 
            local panel = self:getUI("bg.randPanel" .. i)
            self:setNumType(panel,result[i])
        end
        if curData.hasBuy and curData.hasBuy > 0 then --已购买 else 未购买
            haveBuy:setVisible(true)
        else
            buy:setVisible(true)
            overLabel1:setVisible(true)
            overLabel2:setVisible(true)
            overLabel3:setVisible(true)
            if curData.defeat then
                overLabel2:setString(curData.defeat .. "%")
            end
        end
    else
        originPrice1:setVisible(true)
        originPrice1:setString("原价:"..tabData.price)
        try_btn:setVisible(true)
        for i=1,4 do 
            local panel = self:getUI("bg.randPanel" .. i)
            self:setNumType(panel,10)
        end
    end

end

function VipWeekGiftLayer:getRandNums(num)
    local num = num
    local result = {10,10,10,10}
    if not num or tonumber(num) <= 0 then
        return result
    end
    local num_ = modf(num/1000)
    result[1] = num_
    num = num - 1000*num_
    num_ = modf(num/100)
    result[2] = num_
    num = num - 100*num_
    num_ = modf(num/10)
    result[3] = num_
    num = num - 10*num_
    result[4] = num
    dump(result)
    return result
end


function VipWeekGiftLayer:setNumType(node,num)
    local numSp = node:getChildByName("randNum")
    if not numSp then
        numSp = cc.Sprite:createWithSpriteFrameName("weekGiftRandNum".. num .. ".png")
        numSp:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
        print("node:getContentSize().height/2",node:getContentSize().height/2)
        numSp:setName("randNum")
        node:addChild(numSp)
    else
        numSp:setSpriteFrame("weekGiftRandNum".. num .. ".png")
    end
    numSp:setVisible(true)
end

--[[
    数字随机动画
    randNode panel
    circleNum 转几圈再出结果
    finalNum 最终值
    callBack 结束回调
]]
function VipWeekGiftLayer:randNumberAnimation(randNode,circleNum,finalNum,randIndex,callBack)
    -- print("randNumberAnimation",circleNum,finalNum)

    -- if self._duringRanding then return end
    self._duringRanding = true
    self:freeSprites(randIndex)
    local numSp = randNode:getChildByName("randNum")
    if numSp then
        numSp:setVisible(false)
    end
    circleNum = circleNum or 1
    finalNum = finalNum or 0
    finalNum = finalNum + 1
    self._duringRanding = true
    local sprits = self._randSp[randIndex]
    
    for _,sprite in pairs (sprits) do 
        sprite:setPosition(self._acBeginPos)
        sprite:setVisible(true)
        randNode:addChild(sprite)
    end
    local timeUnit = 0.1
    local _randIndex = 0
    local _randTimes = 0 --已经循环的次数

    local function ani()
        _randIndex = _randIndex + 1
        -- print("ani",_randTimes,circleNum,_randIndex,finalNum)
        if _randTimes >= circleNum and _randIndex > finalNum then
            return
        end
        local sprite = sprits[_randIndex]
        sprite:setPosition(self._acBeginPos)
        sprite:setOpacity(0)
        sprite:stopAllActions()
        sprite:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(timeUnit,self._middlePos),
                cc.FadeIn:create(timeUnit)
            ),
            cc.CallFunc:create(function()
                if _randIndex >= 10 then
                    _randTimes = _randTimes + 1
                    _randIndex = 0
                    ani()
                else
                    ani()
                end
                if _randTimes >= circleNum and _randIndex >= finalNum then --动画完毕
                    -- sprite:stopAllActions()
                    -- sprite:setVisible(false)
                    self:freeSprites(randIndex)
                    self:setNumType(randNode,finalNum-1)
                    self._duringRanding = false
                    if callBack then
                        callBack()
                    end
                end
            end),
            cc.Spawn:create(
                cc.MoveTo:create(timeUnit,self._endPos),
                cc.FadeOut:create(timeUnit)
            ),
            cc.CallFunc:create(function()
            end)
        ))
    end
    ani()
end

function VipWeekGiftLayer:freeSprites(index)
    local sprites = self._randSp[index]
    for _,sprite in pairs (sprites) do 
        if sprite:getParent() then
            sprite:removeFromParent(true)
        end
    end
end

function VipWeekGiftLayer:layerDestroy()
    for _,sprites in pairs (self._randSp) do 
        for _,sprite in pairs (sprites) do 
            sprite:release()
        end
    end
    self._randSp = {}
    self._noticeModel:setSpecailType(nil)
end


function VipWeekGiftLayer:refreshUI()
    
    local bg = self:getUI("bg")
    if not self._overLable1 then
        self._overLable1 = cc.Label:createWithTTF("活动结束:", UIUtils.ttfName, 18)
        bg:addChild(self._overLable1)
        self._overLable1:setPosition(480,435)
        self._overLable1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end
    if not self._overLable2 then
        self._overLable2 = cc.Label:createWithTTF("", UIUtils.ttfName, 18)
        self._overLable2:setAnchorPoint(0,0.5)
        bg:addChild(self._overLable2)
        self._overLable2:setPosition(520,435)
        self._overLable2:setColor(cc.c3b(0,255,30))
        self._overLable2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    end


    local endTime = self._data.endTime or self._userModel:getCurServerTime() 
    local tempTime = self._data.endTime - self._userModel:getCurServerTime() 

    local day, hour, minute, second, tempValue    
    self:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
            tempTime = tempTime - 1
            tempValue = tempTime
            day = math.floor(tempValue/86400) 
            tempValue = tempValue - day*86400
            hour = math.floor(tempValue/3600)
            tempValue = tempValue - hour*3600
            minute = math.floor(tempValue/60)
            tempValue = tempValue - minute*60
            second = math.fmod(tempValue, 60)
            local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
            if day == 0 then
                showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
            end
            if tempTime <= 0 then
                showTime = "00天00:00:00"
            end
            self._overLable2:setString(showTime)
            
        end), cc.DelayTime:create(1))
    ))
end


function VipWeekGiftLayer:dtor()
    modf = nil
    cc = nil
end

return VipWeekGiftLayer