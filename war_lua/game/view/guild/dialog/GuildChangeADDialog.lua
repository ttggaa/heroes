--[[
    Filename:    GuildChangeADDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-07-07 11:03:42
    Description: File description
--]]

-- 修改公告
local GuildChangeADDialog = class("GuildChangeADDialog",BasePopView)

function GuildChangeADDialog:ctor()
    self.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildChangeADDialog:onInit()
    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)

    local bg = self:getUI("bg.conBg.anim")
    self._anim = cc.Sprite:createWithSpriteFrameName("xiugai_gonggao.png")
    self._anim:setName("jimaobi")
    self._anim:setPosition(40, 2)
    bg:addChild(self._anim, 10)
    self._anim:setVisible(false)


    self._conBg = self:getUI("bg.conBg")
    self._conBg:setVisible(false)
    self._conLabel = self:getUI("bg.conLabel")
    self._conLabel:setLineBreakWithoutSpace(true)
    self._conLabel:setPlaceHolderColor(cc.c4b(120,120,120,255))



    -- self._conLabel:setPixelNewline(true)
    self._putongBg = self:getUI("bg.putongBg")
    self._putongBg:setVisible(false)
    self._playLabel = self:getUI("bg.playLabel")
    self._playLabel:setLineBreakWithoutSpace(true)
    -- self._conLabel:setPlaceHolder(lang("GUIDENOTICE_WORD"))
    -- self._conLabel:setPlaceHolderColor(cc.c4b(61,31,0,255))
end

-- 接收自定义消息
function GuildChangeADDialog:reflashUI(data)
    local allianceDetail = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    -- dump(allianceDetail)
    local btn1 = self:getUI("bg.btn1")
    if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3  then
        -- or self._modelMgr:getModel("GuildModel"):getGuildADFristShowLaoda() == true then
        self._conLabel:setVisible(false)
        self._playLabel:setVisible(true)
        self._putongBg:setVisible(true)
        btn1:setTitleText("知道了")
        self:registerClickEventByName("bg.btn1", function ()
            self:close()
        end)
    else
        self._conLabel:setVisible(true)
        self._playLabel:setVisible(false)
        self._conBg:setVisible(true)
        -- 
        self._anim:setVisible(true)
        self._conLabel:setPlaceHolder("请输入联盟公告")
        self._conLabel:setPlaceHolderColor(cc.c4b(120,120,120,255))
        self._conLabel:addEventListener(function(sender, eventType)
                print("==============", eventType)
                if eventType == 0 then
                elseif eventType == 1 then
                elseif eventType == 2 then
                    self._conLabel:setColor(cc.c3b(61,31,0))
                elseif eventType == 3 then
                    if sender:getString() == nil or sender:getString() == "" then
                        self._conLabel:setColor(cc.c3b(255,255,255))
                    else
                        self._conLabel:setColor(cc.c3b(61,31,0))
                    end 
                end
            end)

        btn1:setTitleText("确定修改")
        self:registerClickEventByName("bg.btn1", function ()
            local conLabel = self._conLabel:getString()
            if  conLabel == nil or conLabel == "" or conLabel == self._userModel:getData().guildName or utf8.len(conLabel) < 20 then
                -- conLabel:setString("")
                self._viewMgr:showTip("大人，最少也要输入20个字")
            elseif utf8.len(conLabel) > 70 then
                self._viewMgr:showTip("大人，最多只能输入70个字")
            else
                local param = {content = conLabel}
                self._serverMgr:sendMsg("GuildServer","addGuildNotice", param, true, {}, function(result) 
                    -- self._modelMgr:getModel("GuildModel"):updateNotice(param)
                    -- self._viewMgr:showTip("设置成功！")
                    ModelManager:getInstance():getModel("GuildModel"):updateNotice(param)
                    self._viewMgr:reflashUI("GuildManageView")
                    self._viewMgr:reflashUI("GuildManageNewView")
                    if self.close then
                        self:close()
                    end
                end, function(errorId)
                    if tonumber(errorId) == 125 then
                        self._viewMgr:showTip("只能为中文、英文、数字")
                    elseif tonumber(errorId) == 126 then
                        self._viewMgr:showTip("字符串长度不足")
                    elseif tonumber(errorId) == 127 then
                        self._viewMgr:showTip("字符串长度超出限制")
                    elseif tonumber(errorId) == 117 then
                        self._viewMgr:showTip("输入内容含有非法字符")
                    end
                end)
            end
        end)
    end
    -- self._modelMgr:getModel("GuildModel"):getGuildADFristShow()
    if allianceDetail["notice"] == "" then
        self._conLabel:setString(lang("GUIlDENOTICE_WORD"))
        self._playLabel:setString(lang("GUIlDENOTICE_WORD"))
    else
        self._conLabel:setString(allianceDetail["notice"])
        self._playLabel:setString(allianceDetail["notice"])
    end
end

-- -- 修改联盟名字
-- function GuildChangeADDialog:changeGuildName(guildId)
--     print("修改联盟名字====")
--     local param = {guildId = guildId or 1}
--     self._serverMgr:sendMsg("GuildServer", "changeGuildName", param, true, {}, function (result)
--         self:changeGuildNameFinish(result)
--     end)
-- end 

-- function GuildChangeADDialog:changeGuildNameFinish(result)
--     if result == nil then 
--         return 
--     end
-- end

return GuildChangeADDialog 