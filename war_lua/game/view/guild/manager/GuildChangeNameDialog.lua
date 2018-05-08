--[[
    Filename:    GuildChangeNameDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-26 11:16:04
    Description: File description
--]]

-- 修改联盟名称
local GuildChangeNameDialog = class("GuildChangeNameDialog",BasePopView)

function GuildChangeNameDialog:ctor(param)
    self.super.ctor(self)
    self._callback = param.callback
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildChangeNameDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)

    self:registerClickEventByName("bg.btn1", function ()
        if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            self:close()
            return
        end
        
        local name = self._nameLabel:getString()
        -- local gem = self._modelMgr:getModel("UserModel"):getData().gem
        -- if gem < 100 then 
        --      DialogUtils.showNeedCharge()
        --     return 
        -- end
        -- print ("=========", utf8.len(name) , utf8.len(name))
        if  name == nil or name == "" or name == self._userModel:getData().guildName or utf8.len(name) < 2 or utf8.len(name) > 7 then
            self._viewMgr:showTip("请重新设置名称")
        else
            local param = {guildName = name}
            self._serverMgr:sendMsg("GuildServer","changeGuildName", param, true, {}, function(result) 
                self._callback(result["name"])
                self._viewMgr:showTip("设置成功！")
                self:close()
            end, function(errorId)
                if tonumber(errorId) == 2702 then
                    self._viewMgr:showTip("该联盟已存在")
                elseif tonumber(errorId) == 117 or tonumber(errorId) == 107 then
                    self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_02"))
                elseif tonumber(errorId) == 114 then 
                    self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_03"))
                elseif tonumber(errorId) == 125 then
                    self._viewMgr:showTip("只能为中文、英文、数字")
                elseif tonumber(errorId) == 126 then
                    self._viewMgr:showTip("字符串长度不足")
                elseif tonumber(errorId) == 127 then
                    self._viewMgr:showTip("字符串长度超出限制")
                end
            end)
        end
    end)
    self:registerClickEventByName("bg.btn2", function ()
        self:close()
    end)
    -- self._randName = self:getUI("bg.randName")
    -- self._randNum = 0
    -- self:registerClickEventByName("bg.randName", function ()
    --     self._randNum = self._randNum + 1
    --     local num = self._randNum%3 + 1
    --     self._randName:loadTexture("saizi_mainview"..num..".png",1)
    --     local name = ItemUtils.randUserName()
    --     self._nameLabel:setString(name)
    -- end)
    self._nameLabel = self:getUI("bg.nameLabel")

    self._nameLabel:addEventListener(function(sender, eventType)
        print(eventType)
        if eventType == 0 then
            -- event.name = "ATTACH_WITH_IME"
        elseif eventType == 1 then
           --  event.name = "DETACH_WITH_IME"
        elseif eventType == 2 then
            self._nameLabel:setColor(cc.c3b(61,31,0))
            -- event.name = "INSERT_TEXT" 
        elseif eventType == 3 then
            -- event.name = "DELETE_BACKWARD"
            if sender:getString() == nil or sender:getString() == "" then
       --       local curName = self._userModel:getData().name
                -- self._nameLabel:setString(curName)
                self._nameLabel:setColor(cc.c3b(255,255,255))
            else
                self._nameLabel:setColor(cc.c3b(61,31,0))
            end 
        end
    end)

    -- title = self:getUI("bg.title")
    -- self._title:setColor(UIUtils.colorTable.titleColorRGB)
    -- self._title:setFontName(UIUtils.ttfName)
    -- -- self._title:enable2Color(1, cc.c4b(240, 165, 40, 255))
    -- self._title:enableOutline(UIUtils.colorTable.titleOutLineColor, 2)
    -- self._title:setFontSize(28)

    self._nameLabel:setPlaceHolder("请输入名称")
    self._nameLabel:setColor(cc.c3b(61,31,0))
    self._nameLabel:setPlaceHolderColor(cc.c4b(120,120,120,255))
end

-- 接收自定义消息
function GuildChangeNameDialog:reflashUI(data)
    local curName = self._userModel:getData().guildName
    self._nameLabel:setString(curName)
end

-- -- 修改联盟名字
-- function GuildChangeNameDialog:changeGuildName(guildId)
--     print("修改联盟名字====")
--     local param = {guildId = guildId or 1}
--     self._serverMgr:sendMsg("GuildServer", "changeGuildName", param, true, {}, function (result)
--         self:changeGuildNameFinish(result)
--     end)
-- end 

-- function GuildChangeNameDialog:changeGuildNameFinish(result)
--     if result == nil then 
--         return 
--     end
-- end

return GuildChangeNameDialog 