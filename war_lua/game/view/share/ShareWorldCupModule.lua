--[[
    Filename:    ShareWorldCupModule.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-11 13:12:52
    Description: 世界杯分享
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:updateModuleView(data)
	self._data = data["sData"]
    local gInfo = self._data["gInfo"]   --奖励
    local rInfo = self._data["rInfo"]   --数据

    local shareLayer = self:getShareLayer()
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5
    local userData = self._modelMgr:getModel("UserModel"):getData()

    local des1 = cc.Label:createWithTTF("累计竞猜成功", UIUtils.ttfName, 24)
    des1:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des1:setAnchorPoint(cc.p(0, 0))
    des1:setPosition(640, 571)
    shareLayer:addChild(des1)

    local des2 = cc.Label:createWithTTF(rInfo["successNum"] or 0, UIUtils.ttfName, 24)
    des2:setColor(cc.c4b(4,253,25,255))
    -- des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des2:setAnchorPoint(cc.p(0, 0))
    des2:setPosition(des1:getPositionX() + des1:getContentSize().width + 5, 571)
    shareLayer:addChild(des2)

    local des3 = cc.Label:createWithTTF("场，超越", UIUtils.ttfName, 24)
    des3:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des3:setAnchorPoint(cc.p(0, 0))
    des3:setPosition(des2:getPositionX() + des2:getContentSize().width + 5, 571)
    shareLayer:addChild(des3)

    local scoreNum = math.max(0, math.min(100, (rInfo["beyond"] or 0))) .. "%"
    local des4 = cc.Label:createWithTTF(scoreNum, UIUtils.ttfName, 24)
    des4:setColor(cc.c4b(4,253,25,255))
    -- des4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des4:setAnchorPoint(cc.p(0, 0))
    des4:setPosition(des3:getPositionX() + des3:getContentSize().width + 5, 571)
    shareLayer:addChild(des4)

    local des5 = cc.Label:createWithTTF("玩家", UIUtils.ttfName, 24)
    des5:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- des5:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des5:setAnchorPoint(cc.p(0, 0))
    des5:setPosition(des4:getPositionX() + des4:getContentSize().width + 5, 571)
    shareLayer:addChild(des5)

    local des5 = cc.Label:createWithTTF("活动期间您已通过世界杯竞猜累计获得:", UIUtils.ttfName, 24)
    des5:setColor(UIUtils.colorTable.ccUIBaseColor1)
    des5:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des5:setAnchorPoint(cc.p(0, 0))
    des5:setPosition(680, 110)
    shareLayer:addChild(des5)

    local level = tab.setting["GUESS_SHARE_SHOW"].value
    local score = rInfo["comment"] or 7
    local commet = cc.Label:createWithTTF(level[score + 1] or "", UIUtils.ttfName, 72)
    commet:setColor(cc.c4b(255,246,180,255))
    commet:enable2Color(1, cc.c4b(230,186,66,255))
    commet:setAnchorPoint(cc.p(0, 0))
    commet:setPosition(166, 40)
    shareLayer:addChild(commet)
    if score == 0 then
        commet:setVisible(false)
    end

    local sysGuessBet = tab.guessBet
    if not gInfo or next(gInfo) == nil then
        local des6 = cc.Label:createWithTTF("暂无", UIUtils.ttfName, 30)
        des6:setColor(UIUtils.colorTable.ccUIBaseColor1)
        des6:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        des6:setAnchorPoint(cc.p(0, 0))
        des6:setPosition(860, 50)
        shareLayer:addChild(des6)
    else
        local tempNum = 1
        local max = #table.keys(gInfo)
        for i,v in pairs(gInfo) do
            local sysBetData = sysGuessBet[tonumber(i)]
            local costType = sysBetData["cost"][1]
            local costNum = v or 0
            local costId = IconUtils.iconIdMap[costType] or sysBetData["cost"][2]
            local toolD = tab:Tool(tonumber(costId))
            local rwdIcon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
            shareLayer:addChild(rwdIcon)

            if max > 9 then
                rwdIcon:setScale(0.55)
                if tempNum > 9 then
                    rwdIcon:setPosition(1035 - (rwdIcon:getContentSize().width + 10) * rwdIcon:getScale() * (tempNum - 10), 4)
                else
                    rwdIcon:setPosition(1035 - (rwdIcon:getContentSize().width + 10) * rwdIcon:getScale() * (tempNum - 1), 59)
                end
            else
                rwdIcon:setScale(0.9)
                rwdIcon:setPosition(999 - (rwdIcon:getContentSize().width + 10) * rwdIcon:getScale() * (tempNum - 1), 20)
            end

            tempNum = tempNum + 1
        end
    end
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_acWorldCup.jpg"
end

function ShareBaseView:getShareId()
    return 17
end