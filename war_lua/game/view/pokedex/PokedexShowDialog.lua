--[[
    Filename:    PokedexShowDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-28 11:02:07
    Description: File description
--]]


local PokedexShowDialog = class("PokedexShowDialog", BasePopView)

function PokedexShowDialog:ctor()
    PokedexShowDialog.super.ctor(self)
end

function PokedexShowDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("pokedex.PokedexShowDialog")
        end
        self:close()
    end)
    -- local burst = self:getUI("bg.layer.burst")

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)
    
    local showImg = self:getUI("bg.showImg")
    showImg:loadTexture("asset/bg/pokedex_showguide.jpg", 0)
end

function PokedexShowDialog:refreshUI()

end

return PokedexShowDialog