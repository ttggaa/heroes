--[[
    Filename:    ShareTreasureModule.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-02-02 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[
    宝物合成分享
    data
        宝物ID treasureid
                        11
                        21
                        22
                        30
                        31
                        10
                        32
                        42
                        40
                        41
--]]

function ShareBaseView:updateModuleView(data)
    require("game.view.treasure.TreasureConst")

    -- dump(data, "data")
    -- data.treasureid = 32

    local shareLayer = self:getShareLayer()
    self._treasureid = data.treasureid
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5
    local treasureD = tab:ComTreasure(data.treasureid)

    local treasureData = tab.comTreasure[data.treasureid]

    -- --宝物icon
    -- local icon = cc.Sprite:createWithSpriteFrameName(treasureD["art"]..".png")
    -- icon:setPosition(centerX - 6, centerY + 25)
    -- shareLayer:addChild(icon)

    -- data.treasureid = 42
    --effect
    local fpsNum ={
        [10] = {20, centerX, centerY + 15},
        [11] = {37, centerX - 12, centerY},
        [12] = {37, centerX - 7, centerY + 45},
        [23] = {33, centerX - 20, centerY + 30},
        [22] = {33, centerX, centerY + 20},
        [21] = {22, centerX - 11, centerY + 20},
        [30] = {31, centerX - 9, centerY + 20},
        [31] = {15, centerX + 17, centerY + 45},
        [32] = {35, centerX - 12, centerY + 20},
        [33] = {35, centerX - 12, centerY + 20},
        [40] = {15, centerX - 8, centerY + 15},
        [41] = {1, centerX + 0, centerY + 15},
        [42] = {15, centerX, centerY + 45},
        [43] = {15, centerX - 10, centerY + 5},
        [44] = {15, centerX - 0, centerY + 30},
        [45] = {0, centerX - 10, centerY + 5},
        [46] = {15, centerX - 10, centerY + 5},
    }

    data.effect = TreasureConst.comMcs[data.treasureid]
    if data.effect then
        local mc = mcMgr:createViewMC(data.effect, true, false)
        mc:setPosition(fpsNum[data.treasureid][2], fpsNum[data.treasureid][3])
        shareLayer:addChild(mc)
        local count = #mc:getChildren()
        for i=1,count do
            local hideNode = mc:getChildren()[i]
            local count1 = #hideNode:getChildren()
            for k=1,count1 do
                local hideNode1 = hideNode:getChildren()[k]
                if hideNode1.stop ~= nil then
                    hideNode1:gotoAndStop(fpsNum[data.treasureid][1])
                end
            end
            if hideNode.gotoAndStop then
                hideNode:gotoAndStop(10)
            end
        end
        mc:stop(true)
    end

    --散件
    local typePos = { --左右
        [3] = {{570, 551}, {252, 115}, {880, 115}},
        [4] = {{252, 527}, {252, 115}, {882, 527}, {882, 115}},
        [6] = {{252, 527}, {178, 318}, {252, 116}, {875, 527}, {963, 318}, {875, 116}}
    }
    local treeData = treasureData["form"]
    if #treeData == 3 then
        local iconBg = cc.Sprite:createWithSpriteFrameName("share_IconBg_treasure.png")
        iconBg:setPosition(570, 551)
        shareLayer:addChild(iconBg)
    end

    for i,v in ipairs(treeData) do
        local pos = typePos[#treeData][i]

        local blackBg = cc.Sprite:createWithSpriteFrameName("share_IconBlackBg_treasure.png")
        blackBg:setPosition(pos[1], pos[2])
        shareLayer:addChild(blackBg)

        local icon = IconUtils:createItemIconById( { itemId = v, eventStyle = 0, stage = stage, effect = true, showStar = true })
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        icon:setPosition(blackBg:getContentSize().width * 0.5, blackBg:getContentSize().height * 0.5)
        blackBg:addChild(icon)
    end 

    --nameImg
    local name = cc.Sprite:createWithSpriteFrameName(treasureData["shareImg"] .. ".jpg")
    name:setPosition(550, 125)
    shareLayer:addChild(name) 

    --describle
    local des = "[color=fa921a,outlinecolor=3c1e0a,fontsize=26]空[-]"
    local rtx = RichTextFactory:create(lang(treasureData["shareDes"]) or des, 600, 0)
    rtx:setAnchorPoint(cc.p(0, 0.5))
    rtx:formatText()
    local rtxPosX = centerX - rtx:getContentSize().width * 0.5 - rtx:getRealSize().width * 0.5
    rtx:setPosition(rtxPosX, 33)
    shareLayer:addChild(rtx)

    --文字装饰
    local decoImg1 = cc.Sprite:createWithSpriteFrameName("share_txtDeco_treasure.png")
    local decoX1 = centerX - rtx:getRealSize().width * 0.5 - 30
    decoImg1:setPosition(decoX1, 33)
    shareLayer:addChild(decoImg1) 

    local decoImg2 = cc.Sprite:createWithSpriteFrameName("share_txtDeco_treasure.png")
    local decoX2 = centerX + rtx:getRealSize().width * 0.5 + 30
    decoImg2:setScaleX(-1)
    decoImg2:setPosition(decoX2, 33)
    shareLayer:addChild(decoImg2) 
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
        self._resName = {"treasure", "treasure2","treasure4"}
        for i,v in ipairs(self._resName) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/"..v..".plist", "asset/ui/"..v..".png")
        end
    end
    return "asset/bg/share/share_treasure.jpg"
end

function ShareBaseView:getShareId()
    return 3
end

function ShareBaseView:getMonitorContent()
    return self._treasureid
end