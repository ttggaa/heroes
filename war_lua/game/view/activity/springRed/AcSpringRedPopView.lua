--[[
    Filename:    AcSpringRedPopView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-7-8 21:24
    Description: 发红包提示界面
--]]

local AcSpringRedPopView = class("AcSpringRedPopView", BaseView)

function AcSpringRedPopView:ctor(param)
	AcSpringRedPopView.super.ctor(self)
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._sRedModel = self._modelMgr:getModel("SpringRedModel")

    self._redData = param
    self._isRequring = false
    self:refreshUI()

    --定时清除界面红包
    local limitT = tab.setting["G_REDPACKET_OPEN_TIME"].value
    self:registerTimer(limitT[2], 0, 0, function ()
        if self and self._sRedModel then
            self._sRedModel:clearPushData()
            self:removeLayer()
        end
    end)
end

function AcSpringRedPopView:refreshUI() 
    self._redList = self._sRedModel:getPushRed() or {}
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
    for i,v in pairs(self._redList) do
        self._redNode:setContentSize(134.4 +  10 * (math.min(i, 3) - 1), 192) --168/240  134.4/192
        self._redNode:setPosition(MAX_SCREEN_WIDTH * 0.5 - 260, MAX_SCREEN_HEIGHT * 0.5 + 9)
        --创建红包动画
        if i <= 3 then
            self:createRedAnim(v, i)
        end
    end

    --closeBtn
    local closeImg = "globalPanelUI12_CloseBtn5.png"
    local closeBtn = ccui.Button:create(closeImg, closeImg, closeImg, 1)
    closeBtn:setPosition(67, -40)
    self._redNode:addChild(closeBtn)
    registerClickEvent(closeBtn, function()
        self._sRedModel:clearPushData()
        self:removeLayer()
        end)

    registerClickEvent(self._redNode, function()
        --活动开启提示
        local isOpen, openT = self._sRedModel:checkRobRedTime()
        if not isOpen then
            local tipDes
            if openT then
                tipDes = string.gsub(lang("RedPacket_Tips1"), "{$num}", openT) 
            else
                tipDes = lang("OVERDUETIPS_1")
            end
            self._viewMgr:showTip(tipDes)
            return
        end
        
        --可抢次数上限
        local redKey, redType = self._redList[1].id, self._redList[1].type
        local isCanG = self._sRedModel:checkGetDayInfo(2, redType)
        if not isCanG then
            self._viewMgr:showTip(lang("RedPacket_Tips4"))
            self:removeSingleRed(redKey) 
            return
        end

        if self._isRequring == true then
            return
        end
        self._isRequring = true

        self._serverMgr:sendMsg("RedPacketServer", "robRedPacket", {id = redKey}, true, {}, 
            function (result)
                if result["errorCode"] == 8308 then
                    self._viewMgr:showTip(lang("RedPacket_Tips6"))
                    self:removeSingleRed(redKey)
                else
                    self._viewMgr:closeHintView()
                    DialogUtils.showGiftGet({gifts = result["reward"], notPop = true})
                    self:removeSingleRed(redKey, true)
                end
                
                self._isRequring = false
            end, 
            function(errorId)
                self:removeSingleRed(redKey)  --移除红包
                self._isRequring = false
            end)
        end)
end

function AcSpringRedPopView:createRedAnim(inData, num)
    local inId = inData["id"]
    local ttype = inData["type"]

    --红包bg
    local redImg = ccui.ImageView:create("ac_sr_gbox" .. ttype .. ".png", 1)
    redImg:setScale(0.8)

    local redWid, redHei = redImg:getContentSize().width * redImg:getScale(), self._redNode:getContentSize().height
    redImg:setPosition(redWid * 0.5 + 10 * (math.min(num, 3)- 1), redHei * 0.5)
    redImg:setName(inId)
    self._redNode:addChild(redImg, -num)

    --title
    local titleDes = cc.Label:createWithTTF(lang("RedPacketName_" .. ttype), UIUtils.ttfName, 22)
    titleDes:setPosition(85, 193)
    redImg:addChild(titleDes)

    --祝福语
    local words = cc.Label:createWithTTF(lang(inData["wishId"]), UIUtils.ttfName, 16)
    words:setAnchorPoint(cc.p(0, 0.5))
    words:setLineBreakWithoutSpace(true)
    words:setDimensions(130, 0)
    words:setColor(cc.c4b(248, 243, 230, 255))
    words:enable2Color(1, cc.c4b(245, 221, 156, 255))
    words:enableOutline(cc.c4b(66, 66, 66, 255), 1)
    words:setPosition(19, 140)
    redImg:addChild(words)

    --名字
    local name = cc.Label:createWithTTF(inData["name"], UIUtils.ttfName, 20)
    name:setColor(cc.c4b(248, 243, 230, 255))
    name:enable2Color(1, cc.c4b(245, 221, 156, 255))
    name:enableOutline(cc.c4b(66, 66, 66, 255), 1)
    name:setPosition(84, 40)
    redImg:addChild(name)

    if OS_IS_WINDOWS then
        name:setString((inData["name"] or "") .. "--" .. inData["id"])
    else
        name:setString(inData["name"] or "")
    end

    --未读数
    if num == 1 then
        local unread = ccui.ImageView:create("globalImageUI6_tipBg.png", 1)
        unread:setPosition(redImg:getContentSize().width - 11, redImg:getContentSize().height - 11)
        unread:setScale(1.1)
        redImg:addChild(unread)

        local unreadNum = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        unreadNum:setPosition(unread:getContentSize().width * 0.5, unread:getContentSize().height * 0.5)
        unreadNum:setString(#self._redList)
        unread:addChild(unreadNum)
    end

    if ttype == 1 then
        titleDes:setColor(cc.c4b(250, 244, 228, 255))
        titleDes:enable2Color(1, cc.c4b(221, 203, 167, 255))
        titleDes:enableOutline(cc.c4b(66, 66, 66, 255), 1)

    else
        titleDes:setColor(cc.c4b(250, 244, 228, 255))
        titleDes:enable2Color(1, cc.c4b(221, 203, 167, 255))
        titleDes:enableOutline(cc.c4b(66, 66, 66, 255), 1)
    end
    
    --红包
    redImg:runAction(cc.Sequence:create(
        cc.EaseIn:create(cc.FadeIn:create(0.2), 1.5), 
        cc.CallFunc:create(function()
            redImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(0.5, 0.84), 
                cc.ScaleTo:create(0.5, 0.8))))
            end)
        ))
    
end

function AcSpringRedPopView:removeLayer()
    if self:getParent().springRedLayer then
        self:getParent().springRedLayer = nil
    end
    self:removeFromParent(true)
    UIUtils:reloadLuaFile("activity.springRed.AcSpringRedPopView")
end

function AcSpringRedPopView:removeSingleRed(redKey, isRobed)
    self._sRedModel:deleteGlobalRobedRed(redKey, isRobed)
    self:refreshUI()
end

return AcSpringRedPopView













