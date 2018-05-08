--[[
    Filename:    ShareSignModule.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-06-26 14:42:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:transferData(data)
    self._data = data
end

function ShareBaseView:updateModuleView()
    local shareLayer = self:getShareLayer()
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5
    dump(self._data)

    if self._data and self._data.shareType == 1 then
        self:signShare1(shareLayer)
    else
        self:signShare2(shareLayer)
    end
end

-- 累签
function ShareBaseView:signShare1(shareLayer)
    -- 抬头
    local labelpox = 100
    local label = cc.Label:createWithTTF("尊敬的", UIUtils.ttfName_Title, 24)
    label:setPosition(labelpox, 430)
    label:setAnchorPoint(0, 0.5)
    shareLayer:addChild(label)
    labelpox = labelpox + label:getContentSize().width

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userName = userData.name
    local label = cc.Label:createWithTTF(userName, UIUtils.ttfName_Title, 24)
    label:setColor(cc.c3b(255, 247, 123))
    label:setPosition(labelpox, 430)
    label:setAnchorPoint(0, 0.5)
    shareLayer:addChild(label)
    labelpox = labelpox + label:getContentSize().width

    local label = cc.Label:createWithTTF("领主阁下:", UIUtils.ttfName_Title, 24)
    label:setPosition(labelpox, 430)
    label:setAnchorPoint(0, 0.5)
    shareLayer:addChild(label)

    local richTextStr = lang("signshare1")
    local signNum = 1
    if self._data and self._data.signNum then
        signNum = self._data.signNum
    end
    richTextStr = string.gsub(richTextStr, "{$signnum}", signNum)
    local richText = RichTextFactory:create(richTextStr, 400, 0)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(300, 300)
    richText:setName("richText")
    shareLayer:addChild(richText)

    -- 落款
    local label = cc.Label:createWithTTF("凯瑟琳·埃恩法斯特", UIUtils.ttfName_Title, 24)
    label:setPosition(330, 150)
    label:setAnchorPoint(0, 0.5)
    shareLayer:addChild(label)
end

-- 全勤
function ShareBaseView:signShare2(shareLayer)
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5
    -- 抬头
    local labelpox = 0
    local label1 = cc.Label:createWithTTF("尊敬的", UIUtils.ttfName_Title, 24)
    label1:setAnchorPoint(0, 0.5)
    label1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    shareLayer:addChild(label1)
    labelpox = labelpox + label1:getContentSize().width

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local userName = userData.name
    local label2 = cc.Label:createWithTTF(userName, UIUtils.ttfName_Title, 24)
    label2:setColor(cc.c3b(252, 236, 177))
    label2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    label2:setAnchorPoint(0, 0.5)
    labelpox = labelpox + label2:getContentSize().width
    shareLayer:addChild(label2)

    local label3 = cc.Label:createWithTTF("领主阁下:", UIUtils.ttfName_Title, 24)
    label3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    label3:setAnchorPoint(0, 0.5)
    labelpox = labelpox + label3:getContentSize().width
    shareLayer:addChild(label3)

    local pos1 = (shareLayer:getContentSize().width - labelpox)*0.5
    label1:setPosition(pos1, 160)
    pos1 = pos1 + label1:getContentSize().width
    label2:setPosition(pos1, 160)
    pos1 = pos1 + label2:getContentSize().width
    label3:setPosition(pos1, 160)


    local richTextStr = lang("signshare2")
    print("richTextStr=========", richTextStr)
    local terasureName = "100"
    if self._data and self._data.treasureId then
        local treasureId = self._data.treasureId or 40113
        local comId,comImg,comName = self._modelMgr:getModel("TreasureModel"):getComInfoByDisId(treasureId)
        terasureName = comName or ""

        local decoImg1 = cc.Sprite:createWithSpriteFrameName(comImg)
        decoImg1:setPosition(centerX, 330)
        shareLayer:addChild(decoImg1) 
    end

    richTextStr = string.gsub(richTextStr, "{$terasure}", terasureName)
    local richText = RichTextFactory:create(richTextStr, 860, 0)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(centerX+15, 80)
    richText:setName("richText")
    shareLayer:addChild(richText)
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
    if not inData then
        return
    end
    local imgName = "share_signAll"
    if inData and inData.shareType == 1 then
        imgName = "share_signSum"
    end
    if inData and inData.shareType == 2 then
        self._resName = {"treasure", "treasure2"}
        for i,v in ipairs(self._resName) do
            cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/"..v..".plist", "asset/ui/"..v..".png")
        end
    end
    return "asset/bg/share/" .. imgName .. ".jpg"
end

function ShareBaseView:getShareId()
    return 15
end
