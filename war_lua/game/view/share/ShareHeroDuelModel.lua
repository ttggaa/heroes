--[[
    Filename:    ShareHeroDuelModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-04-21 11:50:52
    Description: 英雄交锋 主界面分享
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[
    英雄交锋胜场分享
    data
        段位 stage
        胜场数 winNum
--]]

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()

    data["winNum"] = data["winNum"] or 0
    self._winNum = data["winNum"]
    local heroDuelModel = self._modelMgr:getModel("HeroDuelModel")
    data["stage"] = heroDuelModel:getAniTypeByWins(data["winNum"])
    
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    local leagueRankD = tab:LeagueRank(data.stage)
    if data.stage and data.stage["name"] then
        local animNode = cc.Node:create()
        animNode:setPosition(centerX, centerY + 140)
        animNode:setScale(data.stage["scale"] or 1)
        shareLayer:addChild(animNode)

        local stage = mcMgr:createViewMC(data.stage["name"], false, false)
        stage:setPosition(0, 0)
        animNode:addChild(stage)
        stage:gotoAndStop(40)

        local countNum = cc.LabelBMFont:create(tostring(data["winNum"]), UIUtils.bmfName_hduel_win)
        countNum:setPosition(0, data.stage["fontY"] - data.stage["mcY"] + 10)
        animNode:addChild(countNum, 9)
    end

    local num1, num2 = math.modf(data["winNum"] * 0.1)
    --个位
    local winNum2 = cc.Sprite:createWithSpriteFrameName("heroDuel_share_winNum".. num2 * 10 ..".png")
    winNum2:setAnchorPoint(cc.p(1, 0.5))
    if num1 ~= 0 then
        winNum2:setPosition(570, 190)
    else
        winNum2:setPosition(540, 190)
    end
    shareLayer:addChild(winNum2)

    --十位
    if num1 ~= 0 then
        local winNum1 = cc.Sprite:createWithSpriteFrameName("heroDuel_share_winNum".. num1 ..".png")
        winNum1:setAnchorPoint(cc.p(1, 0.5))
        winNum1:setPosition(winNum2:getPositionX() - winNum2:getContentSize().width - 5, 190)
        shareLayer:addChild(winNum1)
    end

    local lightImg = cc.Sprite:createWithSpriteFrameName("heroDuel_share_lightImg.png")
    lightImg:setPosition(570, 143)
    shareLayer:addChild(lightImg) 
end

function ShareBaseView:onDestroy()  
    if self._resName ~= nil then
        for i,v in ipairs(self._resName) do
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/"..v..".plist")
            cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/ui/"..v..".png")
        end    
    end
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:getShareBgName(inData)
    if inData ~= nil and inData.isAsyncRes and inData.isAsyncRes == true then
        self._resName = {"heroDuel1"}
        for i,v in ipairs(self._resName) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/"..v..".plist", "asset/ui/"..v..".png")
        end
    end
    return "asset/bg/share/share_heroDuel.jpg"
end

function ShareBaseView:getInfoPosition()
    return 846, 20
end

function ShareBaseView:getShareId()
    return 10
end

function ShareBaseView:getMonitorContent()
    return self._winNum
end