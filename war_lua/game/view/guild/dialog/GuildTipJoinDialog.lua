--[[
    Filename:    GuildTipJoinDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-25 10:33:40
    Description: File description
--]]


local GuildTipJoinDialog = class("GuildTipJoinDialog", BasePopView)

function GuildTipJoinDialog:ctor(param)
    GuildTipJoinDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._callback = param.callback
    self._richQQ = "[color=3d1f00,fontsize=20]尊贵的领主大人：[-][][-][color=3d1f00,fontsize=20]您的联盟长再次邀请您加入联盟[-][fontsize=20,color=00FF1E,outlinecolor=3c1e0aff]QQ群[-][color=3d1f00,fontsize=20]，赶快放下矜持加入大家庭吧！[-][][-][color=5d4522,fontsize=20]（首次加入还可以获得[-][pic=globalImageUI_littleDiamond.png][-][color=5d4522,fontsize=20]100[-][color=5d4522,fontsize=20]）[-]"
    self._richWX = "[color=3d1f00,fontsize=20]尊贵的领主大人：[-][][-][color=3d1f00,fontsize=20]您的联盟长再次邀请您加入联盟[-][fontsize=20,color=00FF1E,outlinecolor=3c1e0aff]微信群[-][color=3d1f00,fontsize=20]，赶快放下矜持加入大家庭吧！[-][][-][color=5d4522,fontsize=20]（首次加入还可以获得[-][pic=globalImageUI_littleDiamond.png][-][color=5d4522,fontsize=20]100[-][color=5d4522,fontsize=20]）[-]"
end

function GuildTipJoinDialog:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.dialog.GuildTipJoinDialog")
        end
        self:close()
    end)

    local title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    local bindBtn = self:getUI("bg.bindingwx")
    UIUtils:setButtonFormat(bindBtn, 3)
    bindBtn:setVisible(false)
    local bindBtn = self:getUI("bg.bindingqq")
    UIUtils:setButtonFormat(bindBtn, 3)
    bindBtn:setVisible(false)
    local sdkMgr = SdkManager:getInstance()
    if sdkMgr:isQQ() then
        bindBtn = self:getUI("bg.bindingqq")
        bindBtn:setVisible(true)
    elseif sdkMgr:isWX() then
        bindBtn = self:getUI("bg.bindingwx")
        bindBtn:setVisible(true)
    end
    
    self:registerClickEvent(bindBtn, function()
        if self._callback then
            self._callback()
            self:close()
        end
    end)
end

function GuildTipJoinDialog:reflashUI()
    local richtextBg = self:getUI("bg.richtextBg")
    local str
    if sdkMgr:isQQ() then
        str = self._richQQ
    elseif sdkMgr:isWX() then
        str = self._richWX
    end

    local guildList = self._modelMgr:getModel("GuildModel"):getAllianceList()
    local guildNum = table.nums(guildList)
    guildNum = guildNum - GRandom(7)
    if guildNum < 1 then
        guildNum = 1
    end
    str = string.gsub(str, "${num}", guildNum)
    local richText = RichTextFactory:create(str, richtextBg:getContentSize().width, 0)
    richText:formatText()
    local height  = richtextBg:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    -- richtextBg:setInnerContainerSize(cc.size(richtextBg:getContentSize().width, height))
    -- richText:setPosition(richtextBg:getContentSize().width/2, richtextBg:getInnerContainerSize().height - richText:getRealSize().height/2)
    richText:setPosition(richtextBg:getContentSize().width/2, richtextBg:getContentSize().height - richText:getRealSize().height/2)
    richtextBg:addChild(richText)
end
return GuildTipJoinDialog