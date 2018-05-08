--[[
    Filename:    GuildRedTipLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-7-8 21:24
    Description: 发红包提示界面
--]]

local GuildRedTipLayer = class("GuildRedTipLayer",BaseMvcs, ccui.Widget)

function GuildRedTipLayer:ctor(param)
	GuildRedTipLayer.super.ctor(self)
    self._viewMgr = ViewManager:getInstance()
    self._guildRedModel = ModelManager:getInstance():getModel("GuildRedModel")

    self._redData = param
    self._isRequring = false
    self:refreshUI()
end

------------------------------------------------------------------------------------
--------------------------------------争霸赛相关 qiaohuan------------------------------------
function GuildRedTipLayer:updateGodWarData() 
    -- dump(self._redData, "123")
    if self._redNode ~= nil then
        self._redNode:removeFromParent(true)
    end
    self._redNode = ccui.Layout:create()
    self._redNode:setAnchorPoint(cc.p(0, 0.5))
    self._redNode:setBackGroundColorOpacity(0)
    self._redNode:setBackGroundColorType(1)
    self._redNode:setBackGroundColor(cc.c3b(0, 100, 0))
    self._redNode:setTouchEnabled(true)
    self._redNode:setSwallowTouches(true)
    self:addChild(self._redNode, -1)

    local sum = 0
    self._redIdList = {}
    local redList = {[1] = self._redData}
    for t,v in pairs(redList) do
        table.insert(self._redIdList, self._redData)
        sum = #self._redIdList
        self._redNode:setContentSize(135 +  10 * (sum  - 1), 190)   --135/190
        self._redNode:setPosition(160, MAX_SCREEN_HEIGHT * 0.5)
        self:createGodWarRedAnim(v, sum)   --创建红包动画
    end
    
    registerClickEvent(self._redNode, function()
        if self._isRequring == true then
            return
        end
        self._isRequring = true
        local redKey = self._redIdList[1].redKey
        self._serverMgr:sendMsg("GodWarServer", "robRed", {redId = redKey}, true, {}, 
            function (result)
                self._viewMgr:closeHintView()
                DialogUtils.showGiftGet({
                    gifts = result["reward"],
                    bottomDes = lang("GODWARWATCH_1")
                    })
                self:removeGodWarSingleRed()  --移除红包
                self._isRequring = false
            end, 
            function(errorId)
                if tonumber(errorId) == 2808 then
                    self._viewMgr:showTip(lang("GODWARWATCH_2"))
                elseif tonumber(errorId) == 2802 then
                    self._viewMgr:showTip(lang("GODWARWATCH_2"))
                end
                self:removeGodWarSingleRed()  --移除红包
                self._isRequring = false
            end)
        end)
end

function GuildRedTipLayer:removeGodWarSingleRed()
    self._redData = nil
    self:refreshUI()
end

function GuildRedTipLayer:createGodWarRedAnim(redData, sum)
    --红包bg
    local redImg = ccui.ImageView:create("allicance_redhave.png", 1)
    redImg:setPosition(redImg:getContentSize().width * 0.3 + 10 * (sum- 1), self._redNode:getContentSize().height * 0.5)
    redImg:ignoreContentAdaptWithSize(false)
    redImg:setScale(0.6)
    self._redNode:addChild(redImg, -sum)

    --fans icon
    local sysGodWarRed = tab.godWarRed[tonumber(redData["id"])]
    dump(sysGodWarRed)
    if sysGodWarRed == nil then
        self:removeLayer()
        return
    end
    local imgType = 1
    local iconImg = ccui.ImageView:create()
    iconImg:loadTexture("red_fans.png", 1)
    iconImg:setPosition(redImg:getContentSize().width/2+8, redImg:getContentSize().height/2-75)  --3, -18 
    redImg:addChild(iconImg)

    local showTime = sysGodWarRed.showTime
    local ttime = showTime
    local callFunc1 = cc.CallFunc:create(function()
        ttime = ttime - 1
        if ttime <= 0 then
            self:removeGodWarSingleRed()
        end
    end)
    -- redImg:setVisible(false)
    -- local reddelay = tab:Setting("G_GODWAR_REDDELAY").value
    -- local callFunc2 = cc.CallFunc:create(function()
    --     reddelay = reddelay - 1
    --     if reddelay <= 0 then
    --         if redImg then
    --             redImg:setVisible(true)
    --         end
    --     end
    -- end)
    local seq = cc.Sequence:create(callFunc1, cc.DelayTime:create(1))
    -- local seq1 = cc.Sequence:create(callFunc1, cc.DelayTime:create(1))
    iconImg:runAction(cc.RepeatForever:create(seq))

    --红包
    redImg:runAction(cc.Sequence:create(
        cc.EaseIn:create(cc.FadeIn:create(0.2), 2), 
        cc.CallFunc:create(function()
            redImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.5, 0.64), 
                cc.ScaleTo:create(0.5, 0.6))))
            end)
        ))
end

------------------------------------------------------------------------------------
--------------------------------------抢红包相关 wangyan----------------------------
function GuildRedTipLayer:refreshUI() 
    if self._redData and self._redData.belong == "godwar" then
        self:updateGodWarData() 
        return
    end

    self._redList = self._guildRedModel:getGlobalRobRedList() or {}
    -- dump(self._redList, "redList", 10)
    if next(self._redList) == nil then
        self:removeLayer()
        return
    end

    --redNode
    if self._redNode ~= nil then
        self._redNode:removeFromParent(true)
    end
    self._redNode = ccui.Layout:create()
    self._redNode:setAnchorPoint(cc.p(0, 0.5))
    self._redNode:setBackGroundColorOpacity(0)
    self._redNode:setBackGroundColorType(1)
    self._redNode:setBackGroundColor(cc.c3b(0, 100, 0))
    self._redNode:setTouchEnabled(true)
    self._redNode:setSwallowTouches(true)
    self:addChild(self._redNode, -1)

    --redAim
    self._redIdList = {}
    for t,v in pairs(self._redList) do
        local temp = {id = t, curType = v.type}
        table.insert(self._redIdList, temp)

        local sum = #self._redIdList
        self._redNode:setContentSize(100 +  10 * (math.min(sum, 3) - 1), 140) --100/140
        self._redNode:setPosition(160, MAX_SCREEN_HEIGHT * 0.5 - 20)
        --创建红包动画
        if sum <= 3 then
            self:createRedAnim(t, v, sum)   
        end
    end

    --closeBtn
    self._closeBtn = ccui.Button:create("globalPanelUI12_CloseBtn5.png", "globalPanelUI12_CloseBtn5.png", "globalPanelUI12_CloseBtn5.png", 1)
    self._closeBtn:setPosition(50, -38)
    self._redNode:addChild(self._closeBtn)

    registerClickEvent(self._closeBtn, function()
        local redKey = self._redIdList[1].id
        self._viewMgr:closeHintView()
        self:removeSingleRed(redKey, true)  --移除红包
        end)

    --unread
    self._unread = ccui.ImageView:create("globalImageUI6_tipBg.png", 1)
    self._unread:setPosition(100, 140)
    self._redNode:addChild(self._unread)

    self._unreadNum = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
    self._unreadNum:setPosition(self._unread:getContentSize().width * 0.5, self._unread:getContentSize().height * 0.5)
    self._unreadNum:setString(#self._redIdList)
    self._unread:addChild(self._unreadNum)

    self._unread:runAction(cc.Sequence:create(
        cc.EaseIn:create(cc.FadeIn:create(0.2), 1.5), 
        cc.CallFunc:create(function()
            self._unread:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.5, 1.1), 
                cc.ScaleTo:create(0.5, 1))))
            end)
        ))

    registerClickEvent(self._redNode, function()
        if self._isRequring == true then
            return
        end
        self._isRequring = true

        local redKey = self._redIdList[1].id
        local curType = self._redIdList[1].curType
        local methodStr = "robGuildUserRed"
        if curType == "random" then
            methodStr = "robRandomRed"
        end
        self._serverMgr:sendMsg("GuildRedServer", methodStr, {redId = redKey}, true, {}, 
            function (result)
                self._viewMgr:closeHintView()
                DialogUtils.showGiftGet({gifts = result["reward"]})
                self:removeSingleRed(redKey)  --移除红包
                self._isRequring = false
            end, 
            function(errorId)
                if tonumber(errorId) == 2808 then
                    self._viewMgr:showTip("大人，您今天没有次数了")
                elseif tonumber(errorId) == 2802 then
                    self._viewMgr:showTip("这个红包已过期")
                elseif tonumber(errorId) == 2801 then
                    self._viewMgr:showTip("5点可参与红包活动")
                end
                self:removeSingleRed(redKey)  --移除红包
                self._isRequring = false
            end)
        end)
end

function GuildRedTipLayer:createRedAnim(inId, inRwd, sum)
    local sysUserRed = tab.guildUserRed[tonumber(inRwd["id"])]
    if sysUserRed == nil then
        self:removeLayer()
        return
    end

    --红包bg
    local redImg = ccui.ImageView:create("allicance_redhave1.png", 1)
    local redWid, redHei = redImg:getContentSize().width, self._redNode:getContentSize().height
    redImg:setPosition(redWid * 0.5 + 10 * (math.min(sum, 3)- 1), redHei * 0.5)
    redImg:ignoreContentAdaptWithSize(false)
    redImg:setName(inId)
    self._redNode:addChild(redImg, -sum)

    --icon / name
    local redType = {
        gold = {name = "red_huangjin", icon = "globalImageUI_gold1"},
        gem = {name = "red_zuanshi", icon = "allicance_redziyuan2"},
        treasureCoin = {name = "red_baowu", icon = "allicance_redziyuan3"},
    }

    local curType = redType[sysUserRed["type"]]
    if curType then
        local redName = ccui.ImageView:create(curType["name"] .. ".png", 1)
        redName:setScale(0.6)
        redName:setPosition(redWid * 0.5 - 1, redHei * 0.5 - 30)
        redImg.name = redName
        redImg:addChild(redName)

        local redIcon = ccui.ImageView:create(curType["icon"] .. ".png", 1)
        redIcon:setScale(0.8)
        redIcon:setPosition(redWid * 0.5 - 1, redHei * 0.5 + 15)
        redImg.icon = redIcon
        redImg:addChild(redIcon)
    end
    
    --红包
    redImg:runAction(cc.Sequence:create(
        cc.EaseIn:create(cc.FadeIn:create(0.2), 1.5), 
        cc.CallFunc:create(function()
            redImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.5, 1.04), 
                cc.ScaleTo:create(0.5, 1))))
            end)
        ))
end

function GuildRedTipLayer:removeLayer()
    if self:getParent().robLayer then
        self:getParent().robLayer = nil
    end
    self:removeFromParent(true)
    UIUtils:reloadLuaFile("guild.redgift.GuildRedTipLayer")
end

function GuildRedTipLayer:removeSingleRed(redKey, isCancel)
    local function removeRed()
        self._guildRedModel:removeGlobalRed(redKey)
        self:refreshUI()
    end

    if isCancel and isCancel == true then
        if self._redNode then
            local redImg = self._redNode:getChildByName(redKey)
            local posX, posY
            if redImg then
                self._unread:setVisible(false)
                redImg:stopAllActions()
                posX, posY = redImg:getPositionX(), redImg:getPositionY()
                redImg:runAction(cc.Sequence:create(
                    cc.Spawn:create(
                        cc.FadeOut:create(0.1), 
                        cc.MoveTo:create(0.1, cc.p(posX, posY + 70))),
                    cc.CallFunc:create(function()
                        removeRed()
                        end)
                    ))
            end

            if redImg.name then
                redImg.name:runAction(cc.Spawn:create(
                    cc.FadeOut:create(0.1), 
                    cc.MoveTo:create(0.1, cc.p(posX, posY + 70))
                    ))
            end

            if redImg.icon then
                redImg.icon:runAction(cc.Spawn:create(
                    cc.FadeOut:create(0.1), 
                    cc.MoveTo:create(0.1, cc.p(posX, posY + 70))
                    ))
            end
        end
    else
        removeRed()
    end
end

return GuildRedTipLayer













