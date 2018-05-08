--[[
    Filename:    GuildTipBindDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-03-25 10:34:01
    Description: File description
--]]


local GuildTipBindDialog = class("GuildTipBindDialog", BasePopView)

function GuildTipBindDialog:ctor(param)
    GuildTipBindDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._callback = param.callback

    self._richQQ = "[color=3d1f00,fontsize=20]尊贵的领主大人：[-][][-][color=3d1f00,fontsize=20]您的联盟成员第[-][fontsize=20,color=00FF1E,outlinecolor=3c1e0aff]${num}[-][color=3d1f00,fontsize=20]次表示：没有组织的时间一分一秒都忍不了了，快建立属于我们自己的[-][fontsize=20,color=00FF1E,outlinecolor=3c1e0aff]QQ群[-][color=3d1f00,fontsize=20]吧！[-][][-][color=5d4522,fontsize=20]（首次建群还可以获得[-][pic=globalImageUI_littleDiamond.png][-][color=5d4522,fontsize=20]100[-][color=5d4522,fontsize=20]）[-]"
    self._richWX = "[color=3d1f00,fontsize=20]尊贵的领主大人：[-][][-][color=3d1f00,fontsize=20]您的联盟成员第[-][fontsize=20,color=00FF1E,outlinecolor=3c1e0aff]${num}[-][color=3d1f00,fontsize=20]次表示：没有组织的时间一分一秒都忍不了了，快建立属于我们自己的[-][fontsize=20,color=00FF1E,outlinecolor=3c1e0aff]微信群[-][color=3d1f00,fontsize=20]吧！[-][][-][color=5d4522,fontsize=20]（首次建群还可以获得[-][pic=globalImageUI_littleDiamond.png][-][color=5d4522,fontsize=20]100[-][color=5d4522,fontsize=20]）[-]"
end

function GuildTipBindDialog:onInit()
    self._userModel = self._modelMgr:getModel("UserModel")

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.dialog.GuildTipBindDialog")
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

function GuildTipBindDialog:reflashUI()
    local richtextBg = self:getUI("bg.richtextBg")
    local str
    if sdkMgr:isQQ() then
        str = self._richQQ
    elseif sdkMgr:isWX() then
        str = self._richWX
    end


    -- local totalNum = table.nums(self._modelMgr:getModel("GuildModel"):getAllianceList())
    -- local random = math.random(1,7)
    -- local finalCount = math.max(1,totalNum - random)

    local guildList = self._modelMgr:getModel("GuildModel"):getAllianceList()
    local guildNum = table.nums(guildList)
    guildNum = guildNum - GRandom(7)
    if guildNum < 1 then
        guildNum = 1
    end

    str = string.gsub(str, "${num}", tostring(guildNum))
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

return GuildTipBindDialog