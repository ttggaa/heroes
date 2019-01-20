--[[
    Filename:    PokedexCardNode.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-19 17:33:36
    Description: File description
--]]


-- local PokedexCardNode = class("PokedexCardNode", function()
--     return cc.Sprite:create()
-- end)

local PokedexCardNode = class("PokedexCardNode", ccui.Widget)
-- local PokedexCardNode = class("PokedexCardNode", ccui.Widget)

function PokedexCardNode:cror()
    self.super.ctor(self)
end

-- function PokedexCardNode:init()

-- end

function PokedexCardNode:reflashUI(data)
    -- if not data then
    --     return
    -- end
    self:setContentSize(cc.size(210, 512))
    -- self:setAnchorPoint(cc.p(0.5, 0.5))

    self._indexId = data.indexId

    local art = "tj_" .. tab:Tujian(self._indexId).art .. ".png" or "tj_1.png"
    if tab:Tujian(self._indexId).art == 7 then
        art = "tj_4.png"
    elseif tab:Tujian(self._indexId).art == 4 then
        art = "tj_7.png"
    end
    -- print("======",self._indexId, tab:Tujian(self._indexId).art)
    self._sp = cc.Sprite:create()
    self._sp:setSpriteFrame(art)
    self._sp:setAnchorPoint(cc.p(0.5, 0.5))
    self._sp:setPosition(cc.p(self:getContentSize().width*0.5,self:getContentSize().height*0.5))
    self:addChild(self._sp)

    self._fightLabel = cc.LabelBMFont:create("a+1000", UIUtils.bmfName_zhandouli_little)
    self._fightLabel:setAnchorPoint(cc.p(0.5,0.5))
    self._fightLabel:setPosition(cc.p(self:getContentSize().width*0.5, -20))
    self:addChild(self._fightLabel, 1)


    self._off = cc.Label:createWithTTF("80级开启", UIUtils.ttfName, 20)
    self._off:setColor(cc.c3b(255,46,46))
    self._off:setAnchorPoint(cc.p(0.5,0.5))
    self._off:setPosition(cc.p(self:getContentSize().width*0.5, -15))
    self:addChild(self._off, 1)
    -- self._off:setVisible(false)

    local hongdian = "globalImageUI_bag_keyihecheng.png" 
    self._hongdian = cc.Sprite:create()
    self._hongdian:setSpriteFrame(hongdian)
    self._hongdian:setAnchorPoint(cc.p(1, 0))
    self._hongdian:setPosition(cc.p(self._sp:getContentSize().width-5, 5))
    self._sp:addChild(self._hongdian, 5)

    local diban = "pokeImage_bg7.png" 
    self._diban = cc.Scale9Sprite:createWithSpriteFrameName(diban) -- cc.Sprite:create()
    -- self._diban:setSpriteFrame(diban)
    self._diban:setContentSize(cc.size(185, 36))
    self._diban:setCapInsets(cc.rect(80, 0, 1, 1))
    self._diban:setAnchorPoint(cc.p(0.5, 0))
    self._diban:setPosition(cc.p(self._diban:getContentSize().width*0.5+15, 16))
    self._sp:addChild(self._diban)

    self._pokedex = {}
    -- local index = math.fmod(self._indexId, 5)
    -- if index == 0 then
    --     index = 5
    -- elseif index > 5 then
    --     index = 1
    -- end

    local tupian = "pokeImg_posBg0.png" 
    for i=1,6 do
        self._pokedex[i] = cc.Sprite:create()
        self._pokedex[i]:setSpriteFrame(tupian)
        self._pokedex[i]:setAnchorPoint(cc.p(1, 0))
        self._pokedex[i]:setPosition(cc.p(20 + i*28, 20))
        self._sp:addChild(self._pokedex[i])
    end
end

function PokedexCardNode:setTip(flag)
    if flag == true then
        self._hongdian:setVisible(true)
    else
        self._hongdian:setVisible(false)
    end
end 

function PokedexCardNode:updateCell(data)
        -- dump(data)
        -- local userData = self._modelMgr:getModel("UserModel"):getData()
        -- local pokedexData = self._modelMgr:getModel("PokedexModel"):getData()
        -- local level = tab:Tujian(self._indexId).level
        -- if tonumber(userData.lvl) >= level then
        if data.type == 1 then
            self._fightLabel:setString("a+" .. data.fight)
            self._sp:setSaturation(0)
            self._fightLabel:setVisible(true)
            self._off:setVisible(false)
            self._fightLabel:setScale(0.6)
            -- self:registerClickEvent(self, function()
            --     print("进入图鉴")
            --     self._viewMgr:showView("pokedex.PokedexDetailView", {pokedexType = self._indexId})
            -- end)
        else
            self._off:setString(data.level .. "级开启")
            self._sp:setSaturation(-100)
            self._fightLabel:setVisible(false)
            self._off:setVisible(true)
        end
        if data["pokedexData"] then
            for k,v in pairs(data["pokedexData"]["posList"]) do
                if v ~= 0 then
                    self._pokedex[tonumber(k)]:setSpriteFrame("pokeImg_pos" .. tab:Tujian(self._indexId).color .. ".png")
                else
                    self._pokedex[tonumber(k)]:setSpriteFrame("pokeImg_posBg0.png")
                end
            end
        end

    -- local callback = function()
    --     local userData = self._modelMgr:getModel("UserModel"):getData()
    --     local pokedexData = self._modelMgr:getModel("PokedexModel"):getData()
    --     print("进入图鉴")
    --     local level = tab:Tujian(self._indexId).level
    --     if tonumber(userData.lvl) >= level then
    --         self._sp:setSaturation(0)
    --         self._fightLabel:setVisible(true)
    --         self._off:setVisible(false)
    --         self:registerClickEvent(self, function()
    --             print("进入图鉴")
    --             self._viewMgr:showView("pokedex.PokedexDetailView", {pokedexType = index})
    --         end)
    --     else
    --         self._off:setString(level .. "级开启")
    --         self._sp:setSaturation(-100)
    --         self._fightLabel:setVisible(false)
    --         self._off:setVisible(true)
    --         self:registerClickEvent(self, function()
    --         end)
    --     end
    -- end
    -- return callback
end

return PokedexCardNode