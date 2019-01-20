--[[
    @FileName   ShareGrowthWayModule.lua
    @Authors    cuiyake
    @Date       2018-06-01 14:15:28
    @Email      <cuiyake@playcrad.com>
    @Description   成长之路分享
--]]
local ShareBaseView = require("game.view.share.ShareBaseView")

function ShareBaseView:transferData(data)
    self._data = data --这个data为nil,数据通过Model传
    self._userModel = self._modelMgr:getModel("UserModel")
    self._growthModel = self._modelMgr:getModel("GrowthWayModel")
end

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()
    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    -- local rtxStr = self._growthModel:getShareData()
    -- local desTxt = RichTextFactory:create(rtxStr,300,100)
    -- desTxt:formatText()
    -- desTxt:setVerticalSpace(3)
    -- desTxt:setName("desTxt")
    -- desTxt:setAnchorPoint(cc.p(0.5,0.5))
    -- desTxt:setPosition(525,400)
    -- shareLayer:addChild(desTxt,3)

end

function ShareBaseView:onDestroy()
    ShareBaseView.super.onDestroy(self)
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_growthway.jpg"
end

function ShareBaseView:getInfoPosition()
    return nil, nil
end

function ShareBaseView:getShareId()
    return 18
end
