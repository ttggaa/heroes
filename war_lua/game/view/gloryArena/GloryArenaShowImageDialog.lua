--[[
    FileName:       GloryArenaReportDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-09-13 14:14:52
    Description:    荣耀竞技场展示
]]

local GloryArenaShowImageDialog = class("GloryArenaShowImageDialog", BasePopView)
function GloryArenaShowImageDialog:ctor(data)
    GloryArenaShowImageDialog.super.ctor(self)
end

function GloryArenaShowImageDialog:onInit()
    self:getUI("bg"):setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self:registerClickEventByName("bg", function()
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaShowImageDialog")
    end)

    local Season = self._modelMgr:getModel("GloryArenaModel"):lGetSeason()
    local resData = tab:HonorArenaResource(tonumber(Season))
    if resData then
        local featureImg = cc.Sprite:create("asset/bg/GloryArena/" .. (resData.Resource6 or "GloryArenaImage1") .. ".png")
        featureImg:setPosition(MAX_SCREEN_WIDTH / 2, MAX_SCREEN_HEIGHT / 2)
        self:getUI("bg"):addChild(featureImg)
    end
    
end

return GloryArenaShowImageDialog

--endregion
