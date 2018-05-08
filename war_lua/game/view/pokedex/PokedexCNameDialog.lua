--[[
    Filename:    PokedexCNameDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-12-21 16:32:30
    Description: File description
--]]

local PokedexCNameDialog = class("PokedexCNameDialog",BasePopView)
function PokedexCNameDialog:ctor(param)
    self.super.ctor(self)
    self._callback = param and param.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function PokedexCNameDialog:onInit()
    self._title = "修改名称"

    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._nameLabel = self:getUI("bg.nameLabel")
    local pFormation = self._pokedexModel:getPFormation()
    local userData = self._userModel:getData()
    local pfId = userData.pfId or 1
    local curName = pFormation[tostring(pfId)] 
    if not curName or curName == "" then
        curName = ("图鉴编组" .. pfId)
    end
    self._nameLabel:setString(curName)
    self._nameLabel:addEventListener(function(sender, eventType)
        self._nameLabel:setColor(cc.c3b(70, 40, 0))
        if self._nameLabel:getString() == "" then
            self._nameLabel:setColor(cc.c3b(255, 255, 255))
            self._nameLabel:setPlaceHolderColor(cc.c4b(135,128,128,255))
            self._nameLabel:setPlaceHolder("请输入图鉴编组名称")
        end
    end)
    self:registerClickEventByName("bg.btn1",function() 
        -- self:close()
        -- UIUtils:reloadLuaFile("pokedex.PokedexCNameDialog")
        local name = self:getUI("bg.nameLabel"):getString()
        -- if self._callback and name and name ~= "" then
        --     self._callback(name)
        -- end
        local param = {name = name}
        self:changePFormationName(param)
    end)

    self:registerClickEventByName("bg.btn2",function() 
        self:close()
        UIUtils:reloadLuaFile("pokedex.PokedexCNameDialog")
    end)

    if self._title then
        local title = self:getUI("bg.title")
        UIUtils:setTitleFormat(title,3)
        title:setString(self._title)
    end
end

function PokedexCNameDialog:changePFormationName(param)
    -- local param = {id = self._selectPokedex}
    self._serverMgr:sendMsg("PokedexServer", "changePFormationName", param, true, {}, function (result)
        if self._callback then
            self._callback()
        end
        self:close()
    end)
end

-- 接收自定义消息
function PokedexCNameDialog:reflashUI(data)

end

return PokedexCNameDialog