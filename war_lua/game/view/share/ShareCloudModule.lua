--[[
    Filename:    ShareCloudModule.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-02-02 14:42:52
    Description: File description
--]]



local ShareBaseView = require("game.view.share.ShareBaseView")

--[[ 
	云中城通关分享
	data
		排名 rank
		战斗力 score
		层 floor
		关 stage
--]]
		
function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()

    self._data = data
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    local desPath = nil
    local zhanliStr = nil
    local score = nil
    local rankOffsetX = 0
    if data.rType == self._modelMgr:getModel("RankModel").kRankTypeCloudCity then
        zhanliStr = "通关时间"
        score = string.sub(data.score, 3)
        desPath = "txt_shareDes1_cloudCity.png"
    elseif data.rType == self._modelMgr:getModel("RankModel").kRankTypeCloudCity_MIN_fight then
        zhanliStr = "战力"
        score = data.score
        desPath = "txt_shareDes2_cloudCity.png"
        rankOffsetX = 78
    end

    local rank1 = cc.Label:createWithTTF(data.rank, UIUtils.ttfName_Title, 80)
    rank1:setColor(cc.c3b(118, 0, 0))
    rank1:setPosition(414 + rankOffsetX, 335)
    shareLayer:addChild(rank1)

    local rank2 = cc.Label:createWithTTF(data.rank, UIUtils.ttfName_Title, 80)
    rank2:setColor(cc.c3b(255, 230, 156))
    rank2:enable2Color(1, cc.c4b(254, 118, 44, 255))
    rank2:setPosition(411 + rankOffsetX, 338)
    shareLayer:addChild(rank2)

    local desTxt = cc.Sprite:createWithSpriteFrameName(desPath)
    desTxt:setAnchorPoint(0, 0.5)
    desTxt:setPosition(20, 290)
    shareLayer:addChild(desTxt)

    local txtEffect = cc.Sprite:createWithSpriteFrameName("txt_shareEffect_cloudCity.png")
    txtEffect:setPosition(280, 297)
--    shareLayer:addChild(txtEffect)

    local zhandouliLabel = cc.Label:createWithTTF(zhanliStr..score, UIUtils.ttfName_Title, 34)
    zhandouliLabel:setPosition(574, 28)
    zhandouliLabel:enableOutline(cc.c3b(211,68,24), 2)
    zhandouliLabel:enable2Color(1, cc.c4b(255,255,90,255))
    shareLayer:addChild(zhandouliLabel)

    local floor = cc.Label:createWithTTF("第"..data.floor.."层 第"..data.stage.."关", UIUtils.ttfName_Title, 26)
    floor:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
--    floor:setColor(cc.c3b(255, 218, 85))
    floor:setPosition(573, 585)
    shareLayer:addChild(floor)
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_cloud.jpg"
end


function ShareBaseView:getShareId()
    if self._data.rType == self._modelMgr:getModel("RankModel").kRankTypeCloudCity then
        return 7
    elseif self._data.rType == self._modelMgr:getModel("RankModel").kRankTypeCloudCity_MIN_fight then
        return 8
    end
    return 0
end