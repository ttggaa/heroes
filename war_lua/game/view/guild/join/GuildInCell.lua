--[[
    Filename:    GuildInCell.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-21 15:35:00
    Description: File description
--]]

-- 联盟加入cell
local GuildInCell = class("GuildInCell", BaseLayer)

function GuildInCell:ctor(param)
    GuildInCell.super.ctor(self)
    self._applyJoinBack = param.applyJoinBack
    self._cancelApplyJoinBack = param.cancelApplyJoinBack
    self._guildModel = self._modelMgr:getModel("GuildModel")
     -- self:setSwallowTouches(false)
end

function GuildInCell:onInit()
    self._name = self:getUI("bg.name")
    -- self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- self._name:setFontName(UIUtils.ttfName)
    self._level = self:getUI("bg.level")
    -- self._level:setFontName(UIUtils.ttfName)
    -- self._level:enableOutline(cc.c4b(61,37,17,255), 2)
    self._personNum = self:getUI("bg.personNum")
    -- self._personNum:enableOutline(cc.c4b(11,48,71,255), 2)
    self._limitLevel = self:getUI("bg.limitLevel")
    -- self._limitLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._limitLab = self:getUI("bg.limitLab")
    -- self._limitLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._apply = self:getUI("bg.apply")
    -- self._apply:setVisible(false)
    self._cancelApply = self:getUI("bg.cancelApply")
    -- self._cancelApply:setVisible(false)

    self._tishi = self:getUI("bg.tishi")
end

function GuildInCell:reflashUI(data)
    -- dump(data)
    local typeId = 4

    if data["allianceD"] == nil then
        return
    end

    self._allianceData = data
    local allianceD = data["allianceD"]
    -- local roldMax = tab:Setting("G_GUILD_MEMBER_NUM").value + allianceD.level or 0
    if allianceD.roleNum == nil then
        return
    end
    if allianceD.roleNum >= (allianceD.roleNumLimit or 20) then
        typeId = 4
    elseif allianceD.status == 1 and allianceD.hadApply == 0 then
        typeId = 1
    elseif allianceD.status == 1 and allianceD.hadApply == 1 then
        typeId = 2
    elseif allianceD.status == 0 and allianceD.hadApply == 0 then
        typeId = 3
    elseif allianceD.status == 0 and allianceD.hadApply == 1 then
        typeId = 2
    end

    -- print ("typeId ================= ",typeId)
    self._name:setString(allianceD.name)
    if self._name:getContentSize().width > 210 then
        local str = self:limitLen(allianceD.name, 9)
        str = str .. "..."
        self._name:setString(str)
    end
    self._level:setString("Lv. " .. allianceD.level)
    self._personNum:setString(allianceD.roleNum .. "/" .. (allianceD.roleNumLimit or 20))
    
    if allianceD.lvlimit == 0 then
        self._limitLevel:setString("无限制")
        -- self._limitLevel:setColor(cc.c3b(255,252,223))
        -- self._limitLab:setColor(cc.c3b(255,252,223))
        -- self._limitLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- self._limitLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        self._limitLevel:setString(allianceD.lvlimit .. "级")
        -- self._limitLevel:setColor(cc.c3b(254,121,41))
        -- self._limitLab:setColor(cc.c3b(254,121,41))
        -- self._limitLevel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- self._limitLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    if allianceD.status == 0 then
        -- print("==========HHHHHHHHHHHHHHHHH=")
        self._limitLab:setString("自由加入")
    else
        self._limitLab:setString("需审批")
    end

    local iconBg = self:getUI("bg.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")
    local param = {flags = allianceD.avatar1 or 101, logo = allianceD.avatar2 or 201}
    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setName("avatarIcon")
        avatarIcon:setScale(0.8)
        avatarIcon:setPosition(0, -3)
        iconBg:addChild(avatarIcon)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end
    if typeId == 1 then
        -- self._personNum:setColor(cc.c3b(118,238,0))
        -- self._personNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._tishi:setVisible(false)
        self._apply:setVisible(true)
        self._cancelApply:setVisible(false)
        -- self._apply:setSaturation(0)
        -- self._apply:setBright(true)
        self._apply:setTitleText("申请")
        self:registerClickEvent(self._apply, function()
            self:applyJoin(allianceD._id, data.id, typeId)
            print("申请" .. allianceD._id)
        end)
    elseif typeId == 2 then
        -- self._personNum:setColor(cc.c3b(118,238,0))
        -- self._personNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._tishi:setVisible(false)
        self._apply:setVisible(false)
        self._cancelApply:setVisible(true)
        self:registerClickEvent(self._cancelApply, function()
            self:cancelApplyJoin(allianceD._id, data.id)
            print("取消申请" .. allianceD._id)
        end)
    elseif typeId == 3 then
        -- self._personNum:setColor(cc.c3b(118,238,0))
        -- self._personNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._tishi:setVisible(false)
        -- self._apply:setSaturation(0)
        -- self._apply:setBright(true)
        self._apply:setVisible(true)
        self._cancelApply:setVisible(false)
        self._apply:setTitleText("加入")
        self:registerClickEvent(self._apply, function()
            
            self:applyJoin(allianceD._id, data.id, typeId)
            -- self:JoinAlliance(allianceD._id)
            print("加入" .. allianceD._id)
        end)
    else
        -- self._personNum:setColor(cc.c3b(237,69,46))
        -- self._personNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._tishi:setVisible(true)
        self._apply:setVisible(false)
        self._cancelApply:setVisible(false)
        -- self._apply:setSaturation(-100)
        -- self._apply:setBright(false)
        self._apply:setTitleText("已满员")
        self:registerClickEvent(self._apply, function()
            -- print("不可加入" .. allianceD._id)
        end)
    end

    local bg = self:getUI("bg.bg")

    local downY, clickFlag
    registerTouchEvent(
        bg,
        function (_, _, y)
            downY = y
            clickFlag = false
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            if clickFlag == false then 
                self._viewMgr:showDialog("guild.dialog.GuildDetailDialog", {allianceD = allianceD}, true)
            end
        end,
        function ()
        end)
    bg:setSwallowTouches(false)
end

-- 请求改变数据
function GuildInCell:getGuildById(param)
    -- print("======数据=变化===")
    self._serverMgr:sendMsg("GuildServer", "getGameGuildBaseInfo", param, true, {}, function (result)
        self._allianceData["allianceD"]["lvlimit"] = result["lvlimit"]
        self._allianceData["allianceD"]["status"] = result["status"]
        self:reflashUI(self._allianceData)
    end)
end 

-- 加入联盟
function GuildInCell:applyJoin(guildId, id, typeId)
    local userModelData = self._modelMgr:getModel("UserModel"):getData()
    if userModelData.guildId and userModelData.guildId ~= 0 then
        self._viewMgr:showTip("你已加入联盟")
        self._viewMgr:showView("guild.GuildView")
        self._viewMgr:popView()
        return
    end
    --加联盟24小时限制
    if not self._guildModel:canJoin() then
        local str = self._guildModel:getJoinLeftTime()
        self._viewMgr:showTip(lang("GUILD_EXIT_TIPS_2")..str)
        return
    end
    -- print("载入=============数据====")
    local param = {guildId = guildId}
    self._serverMgr:sendMsg("GuildServer", "applyJoin", param, true, {}, function (result)
        if not result["d"] then
            -- print ("====需审批=========", typeId)
            self._allianceData["allianceD"]["status"] = 1
            self._allianceData["allianceD"]["hadApply"] = 1
            self:reflashUI(self._allianceData)
            -- self._applyJoinBack(id, 1)
        else 
            self._viewMgr:showView("guild.GuildView")
            self._viewMgr:popView()
        end
        -- self:applyJoinFinish(result)
    end,function(errorId)
        if tonumber(errorId) == 2701 then
            self._viewMgr:showTip(string.gsub(lang("GUILD_RECRUIT_3"), "{$guildname}", userModelData.guildName))
        elseif tonumber(errorId) == 2711 then
            self._viewMgr:showTip(lang("GUILD_RECRUIT_10"))
        elseif tonumber(errorId) == 2712 then
            self._viewMgr:showTip(lang("GUILD_RECRUIT_8"))
        elseif tonumber(errorId) == 119 then
            self._viewMgr:showTip(lang("GUILD_RECRUIT_4"))
            self:getGuildById(param)
        end
    end)
end 

function GuildInCell:applyJoinFinish(result)
    if result == nil then 
        return 
    end
end

-- 取消申请
function GuildInCell:cancelApplyJoin(guildId, id)
    print("载入=============数据====")
    local param = {guildId = guildId}
    self._serverMgr:sendMsg("GuildServer", "cancelApplyJoin", param, true, {}, function (result)
        self._allianceData["allianceD"]["hadApply"] = 0
        self:reflashUI(self._allianceData)
        -- self._applyJoinBack(id, 0)
        -- self:cancelApplyJoinFinish(result)
    end)
end

function GuildInCell:limitLen(str, maxNum)
    local lenInByte = #str
    local lenNum = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
        elseif curByte>=192 and curByte<=247 then
            lenNum = lenNum + 3
            maxNum = maxNum + 1
        end
        if lenNum >= maxNum then
            break
        end
    end
    str = string.sub(str, 1, lenNum)
    return str
end 

function GuildInCell:cancelApplyJoinFinish(result)
    if result == nil then 
        return 
    end
end

return GuildInCell