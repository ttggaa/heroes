--[[
    Filename:    GodWarChampionDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-04 20:03:27
    Description: File description
--]]

-- 冠军拍脸图
local GodWarChampionDialog = class("GodWarChampionDialog", BasePopView)

function GodWarChampionDialog:getAsyncRes()
    return {
        {"asset/ui/godwar2.plist", "asset/ui/godwar2.png"},
        {"asset/ui/godwar1.plist", "asset/ui/godwar1.png"},
        {"asset/ui/godwar.plist", "asset/ui/godwar.png"},
    }
end

function GodWarChampionDialog:ctor(param)
    GodWarChampionDialog.super.ctor(self)
    self._callback = param.callback
    self._gtype = param.gtype or 3
end

function GodWarChampionDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarChampionDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)  
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._godWarModel:setShowType(self._gtype)
    local layerBg = self:getUI("bg.Image_61")
    layerBg:loadTexture("asset/bg/bg_godwar_011.jpg", 0)

    local dizuo = self:getUI("bg.guanjunBg.renBg.dizuo")
    dizuo:loadTexture("godwarImageUI_img152.png", 1)

    local heroBg = self:getUI("bg.guanjunBg.renBg")
    heroBg:setScale(0.8)

    local pname = self:getUI("bg.guanjunBg.tname")
    pname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    pname:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    local gotogodwar = self:getUI("bg.gotogodwar")
    self:registerClickEvent(gotogodwar, function()
        self.dontRemoveRes = true
        self:close()
        ViewManager:getInstance():showView("godwar.GodWarView")
    end)

end

function GodWarChampionDialog:reflashUI()
    local data = self._godWarModel:getDispersedData()
    dump(data)
    local firstData = data["r1"]
    if not firstData then
        return
    end
    local winId = firstData["rid"]
    local skin = firstData["skin"]
    local winData = self._godWarModel:getPlayerById(winId)

    dump(winData)
    if not winData then
        -- self:close()
        return
    end

    local heroBg = self:getUI("bg.guanjunBg.renBg")
    if heroBg.heroArt then
        heroBg.heroArt:removeFromParent()
    end
    local heroD = tab:Hero(winData.hId)
    local heroArt = heroD["heroart"]
    if skin and skin ~= 0  then
        local heroSkinD = tab.heroSkin[skin]
        heroArt = heroSkinD["heroart"] or heroD["heroart"]
    end
    heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
    heroBg.heroArt:setPosition(90, 35)
    heroBg.heroArt:setName("heroArt")
    heroBg:addChild(heroBg.heroArt)

    local pname = self:getUI("bg.guanjunBg.tname")
    pname:setString(winData.name)

    local guanjun = self:getUI("bg.guanjunBg.guanjun")
    guanjun:setColor(cc.c3b(255, 253, 253))
    guanjun:enable2Color(1, cc.c4b(253, 229, 175, 255))
    guanjun:setFontSize(24)
    -- if guanjunBg.guanjunFightLab then
    --     guanjunBg.guanjunFightLab:setString(winData.score)
    -- end
end

return GodWarChampionDialog
