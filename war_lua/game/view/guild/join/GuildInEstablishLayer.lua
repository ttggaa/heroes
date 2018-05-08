--[[
    Filename:    GuildInEstablishLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-20 20:10:14
    Description: File description
--]]

-- 联盟创建
local GuildInEstablishLayer = class("GuildInEstablishLayer", BasePopView)

function GuildInEstablishLayer:ctor()
    GuildInEstablishLayer.super.ctor(self)
end

function GuildInEstablishLayer:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    -- bg:loadTexture("asset/bg/allianceBtn_createAllianceDiban.png")

    local xiaoren = self:getUI("bg.xiaoren")
    xiaoren:loadTexture("asset/bg/global_reward_img.png")


    local needLab1 = self:getUI("bg.panel.needLab1")
    -- needLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    needLab1:setString("玩家达到")
    local needLab2 = self:getUI("bg.panel.needLab2")
    needLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local needLab3 = self:getUI("bg.panel.needLab3")
    needLab3:setVisible(false)
    needLab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local needLab4 = self:getUI("bg.panel.needLab4")
    needLab4:setVisible(false)
    needLab4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    needLab2:setString(tab:Setting("G_GUILD_CREATE_LV_LIMIT").value .. "级")
    needLab4:setString("VIP" .. tab:Setting("G_GUILD_CREATE_VIPLV_LIMIT").value)
    needLab2:setPositionX(needLab1:getPositionX() + needLab1:getContentSize().width + 10)
    -- needLab3:setPositionX(needLab2:getPositionX() + needLab2:getContentSize().width)
    -- needLab4:setPositionX(needLab3:getPositionX() + needLab3:getContentSize().width)
    -- needLab4:setPositionX(needLab1:getPositionX() + needLab1:getContentSize().width + 10)

    local nameText = self:getUI("bg.panel.nameTextBg.nameText")
    nameText:setPlaceHolder("请输入名称")
    nameText:setColor(cc.c3b(255, 255, 255))
    nameText:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    
    nameText:addEventListener(function(sender, eventType)
        nameText:setColor(cc.c3b(70, 40, 0))
        if nameText:getString() == "" then
            nameText:setColor(cc.c3b(255, 255, 255))
            nameText:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
            nameText:setPlaceHolder("请输入名称")
        end
    end)

    -- local establish = self:getUI("bg.establish")
    -- self:registerClickEvent(establish, function()
    --     self:createGuild()
    -- end)
    local price = self:getUI("bg.panel.price")
    price:setString(tab:Setting("G_GUILD_CREATE_COST")["value"][1][3])
    price:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._acatar = {avatar1 = 101, avatar2 = 201}

    local clickFlagFun = function ( ... )
        -- self._viewMgr:showTip("现在不能选")
        self._viewMgr:showDialog("guild.dialog.GuildSelectFlagsDialog", {acatar = self._acatar, create = true, callback = function(param)
            self._acatar = param
            self:createAvatar()
        end}, true)
    end
    local iconBg = self:getUI("bg.panel.iconBg")
    self:registerClickEvent(iconBg, function()
        clickFlagFun()
    end)
    local iconImg = self:getUI("bg.panel.iconBg.icon")
    iconImg:setScaleAnim(true)
    self:registerClickEvent(iconImg, function()
        clickFlagFun()
    end)
    self:createAvatar()
    self:updateGold()
    self:listenReflash("UserModel", self.updateGold)
end

function GuildInEstablishLayer:updateGold()
    local establish = self:getUI("bg.establish")
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local price = self:getUI("bg.panel.price")
   

    if userData.gem < tab:Setting("G_GUILD_CREATE_COST")["value"][1][3] then
        price:setColor(cc.c3b(255,23,23))
        self:registerClickEvent(establish, function()
            DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        end)
    else
        price:setColor(cc.c3b(255,255,255))
        self:registerClickEvent(establish, function()
            self:createGuild()
        end)
    end
end

function GuildInEstablishLayer:createAvatar()
    local iconBg = self:getUI("bg.panel.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")
    -- local avatar1 = self._acatar.avatar1
    -- local avatar2 = self._acatar.avatar2
    -- local flags = tab:GuildFlag(self._acatar.avatar1).pic .. ".png"
    -- local logo = tab:GuildFlag(self._acatar.avatar2).pic .. ".png"
    -- local param = {flags = flags, logo = logo}
    local param = {flags = self._acatar.avatar1, logo = self._acatar.avatar2}
    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setScale(0.7)
        iconBg:addChild(avatarIcon)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end
end

function GuildInEstablishLayer:reflashUI(data)
    -- local needLab1 = self:getUI("bg.panel.needLab1")
    -- local needLab2 = self:getUI("bg.panel.needLab2")
    -- local needLab3 = self:getUI("bg.panel.needLab3")
    -- local needLab4 = self:getUI("bg.panel.needLab4")
end

-- 创建联盟
function GuildInEstablishLayer:createGuild()
    
    local viplevel = self._modelMgr:getModel("VipModel"):getData().level
    local userData = self._modelMgr:getModel("UserModel"):getData()
    print("载入=============数据====", userlevel)
    -- if userData.lvl < 28 then
    --     self._viewMgr:showTip("玩家等级不足")
    --     return
    -- else
    if viplevel < 0 then
        self._viewMgr:showTip("VIP等级不足")
        return
    elseif userData.gem < 200 then
        self._viewMgr:showTip("钻石数量不足")
        return
    end

    local nameText = self:getUI("bg.panel.nameTextBg.nameText")
    -- if utf8.len(nameText:getString()) < 2 then
    --     self._viewMgr:showTip("联盟名称不符合规则，请重新命名")
    local name = nameText:getString()
    if  name == nil or name == "" or utf8.len(name) < 2 or utf8.len(name) > 7 then
        self._viewMgr:showTip("请重新设置名称")
        return
    end
    -- local avatar1 = self._acatar.avatar1
    -- local avatar2 = self._acatar.avatar2
    -- print("载入=============数据====",name, avatar1, avatar2)
    local param = {guildName = name, avatar1 = self._acatar.avatar1 or 101, avatar2 = self._acatar.avatar2 or 201}
    self._serverMgr:sendMsg("GuildServer", "createGuild", param, true, {}, function (result)
        -- dump(result, "result ==================")
        self._viewMgr:showView("guild.GuildView")
        self._viewMgr:popView()
    end, function(errorId)
        if tonumber(errorId) == 2702 then
            self._viewMgr:showTip("该联盟已存在")
        elseif tonumber(errorId) == 117 or tonumber(errorId) == 107 then
            self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_02"))
        elseif tonumber(errorId) == 114 then 
            self._viewMgr:showTip(lang("INFORMATION_NAME_ERROR_03"))
        elseif tonumber(errorId) == 125 then 
            self._viewMgr:showTip("输入内容含有非法字符")
        end
    end)
end 

return GuildInEstablishLayer
