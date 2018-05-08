--[[
    Filename:    CrossDeclareDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-18 13:01:04
    Description: File description
--]]


-- 冠军拍脸图
local CrossDeclareDialog = class("CrossDeclareDialog", BasePopView)

function CrossDeclareDialog:getAsyncRes()
    return {
        {"asset/ui/cross1.plist", "asset/ui/cross1.png"},
    }
end

function CrossDeclareDialog:ctor(param)
    CrossDeclareDialog.super.ctor(self)
    -- self._callback = param.callback
end

function CrossDeclareDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossDeclareDialog")
        end
        -- if self._callback then
        --     self._callback()
        -- end
        self:close()
    end)  
    self._crossModel = self._modelMgr:getModel("CrossModel")

    self._crossModel:setCrossMainDialog()

    local layerBg = self:getUI("bg.Image_61")
    layerBg:loadTexture("asset/bg/bg_godwar_011.jpg", 0)


    local arena2 = self:getUI("bg")
    self:registerClickEvent(arena2, function()
        for i=1,3 do
            self:updateArena(i)
        end
    end)

end

function CrossDeclareDialog:updateArena(arenaType)
    -- local arenaType = arenaData[indexId]
    local arenaData = self._crossModel:getData()
    local playData = self._crossModel:getSoloArenaData(arenaType)

    if playData == false then
        return
    end

    local dizuo = self:getUI("bg.arena" .. arenaType .. ".heroBg.dizuo")
    dizuo:loadTexture("arenaMain_heroBg1.png", 1)
    dizuo:setScale(0.8)

    local tname = self:getUI("bg.arena" .. arenaType .. ".tname")
    tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tname:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)

    local heroBg = self:getUI("bg.arena" .. arenaType .. ".heroBg")
    if heroBg.heroArt then
        heroBg.heroArt:removeFromParent()
    end
    local heroId = playData.heroId or 60303
    local heroD = tab:Hero(heroId)
    local heroArt = heroD["heroart"]
    local skin = playData.heroSkin
    if skin and skin ~= 0  then
        local heroSkinD = tab.heroSkin[skin]
        heroArt = heroSkinD["heroart"] or heroD["heroart"]
    end
    heroBg.heroArt = mcMgr:createViewMC("stop_" .. heroArt, true, false)
    heroBg.heroArt:setPosition(90, 15)
    heroBg.heroArt:setScale(0.65)
    heroBg.heroArt:setName("heroArt")
    heroBg:addChild(heroBg.heroArt)

    local regiontype = arenaData["regiontype" .. arenaType]
  
    local anameStr = lang("cp_nameRegion" .. regiontype)
    local aname = self:getUI("bg.arena" .. arenaType .. ".aname")
    aname:setString(anameStr)

    local pnameStr = playData.name
    local secStr = playData.sec 
    if secStr == "npcsec" then
        pnameStr = lang("cp_npcName" .. regiontype)
        secStr = lang("cp_nameRegion" .. regiontype)
    else
        secStr = self._crossModel:getServerName(secStr)
    end
    if pname then
        pname:setString(pnameStr)
    end
    tname:setString(pnameStr)

    local sname = self:getUI("bg.arena" .. arenaType .. ".sname")
    sname:setString(secStr)


    local soloBtn = self:getUI("bg.arena" .. arenaType .. ".soloBtn")
    self:registerClickEvent(soloBtn, function()
        local param = {region = arenaType, defReport = 2}
        self._serverMgr:sendMsg("CrossPKServer", "enterCrossPK", param, true, {}, function (result)
            dump(result, "result==========", 10)
            UIUtils:reloadLuaFile("cross.CrossPKView")
            self._viewMgr:showView("cross.CrossPKView", {arenaId = regiontype, tabSelect = 2})
            self:close()
        end)
    end)

end 

function CrossDeclareDialog:reflashUI()
    for i=1,3 do
        self:updateArena(i)
    end
end

return CrossDeclareDialog
