--[[
    Filename:    GuildAppointDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 20:48:39
    Description: File description
--]]

-- 任命弹窗
local GuildAppointDialog = class("GuildAppointDialog",BasePopView)
function GuildAppointDialog:ctor()
    self.super.ctor(self)
    -- self._itemModel = self._modelMgr:getModel("ItemModel")
end

-- 初始化UI后会调用, 有需要请覆盖5
function GuildAppointDialog:onInit()

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    local name1 = self:getUI("bg.name1")
    local name2 = self:getUI("bg.name2")
    local name3 = self:getUI("bg.name3")
    name1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    name2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    name3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.manager.GuildAppointDialog")
        end
        self:close()
    end)
end

function GuildAppointDialog:reflashUI(data)
    if data == nil then
        return
    end
    dump(data)
    -- local allianceD = data.allianceD
    -- local name = self:getUI("bg.name")
    -- name:setString(allianceD.name)
    -- local level = self:getUI("bg.level")
    -- level:setString("Lv" .. allianceD.level)
    -- local playName = self:getUI("bg.playName")
    -- playName:setString(allianceD.mName)
    -- local allianceId = self:getUI("bg.allianceId")
    -- allianceId:setString(allianceD._id)
    -- local rank = self:getUI("bg.rank")
    -- rank:setString(allianceD.rank)
    -- local personNum = self:getUI("bg.personNum")
    -- personNum:setString(allianceD.roleNum .. "/" .. allianceD.roleNumLimit)

-- getVirtualRenderer
-- getDescription
-- getVirtualRendererSize
-- CheckBox


    local detailData = data.detailData

    local headIcon = self:getUI("bg.headBg.headIcon")
    local param1 = {avatar = detailData.avatar, tp = 4,avatarFrame = detailData["avatarFrame"]}
    local heroIcon = headIcon:getChildByName("heroIcon")
    if not heroIcon then
        heroIcon = IconUtils:createHeadIconById(param1)
        heroIcon:setName("heroIcon")
        heroIcon:setPosition(cc.p(0,0))
        headIcon:addChild(heroIcon)
    else
        IconUtils:updateHeadIconByView(heroIcon, param1)
    end

    local name = self:getUI("bg.headBg.nameBg.name")
    -- name:setFontName(UIUtils.ttfName)
    name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    name:setString(detailData.name)

    local lvl = self:getUI("bg.headBg.headIcon.lvl")
    lvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lvl:setString(detailData.lvl)

    local vipLvl = self:getUI("bg.headBg.nameBg.vipLvl")
    vipLvl:setFntFile(UIUtils.bmfName_vip)
    vipLvl:setString("v" .. detailData.vipLvl)
    vipLvl:setPosition(cc.p(name:getPositionX()+name:getContentSize().width+5, name:getPositionY()-2))

    local labNum1 = self:getUI("bg.headBg.labNum1")
    -- labNum1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    labNum1:setString(detailData.dNum)

    local labNum2 = self:getUI("bg.headBg.labNum2")
    -- labNum2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    labNum2:setString(GuildUtils:getDisTodayTime(detailData.leaveTime))

    self:getUI("bg.check" .. detailData.pos):setSelected(true)

    local check1 = self:getUI("bg.check1")
    local check2 = self:getUI("bg.check2")
    local check3 = self:getUI("bg.check3")
    check1:addEventListener(function()
        check1:setSelected(true)
        check2:setSelected(false)
        check3:setSelected(false)
    end)

    check2:addEventListener(function()
        check1:setSelected(false)
        check2:setSelected(true)
        check3:setSelected(false)
    end)

    check3:addEventListener(function()
        check1:setSelected(false)
        check2:setSelected(false)
        check3:setSelected(true)
    end)

    local savebtn = self:getUI("bg.savebtn")

    self:registerClickEvent(savebtn, function()
        local param
        if check1:isSelected() then
            param = {memberId = detailData.memberId, posId = 1}
        elseif check2:isSelected() then
            param = {memberId = detailData.memberId, posId = 2}
        elseif check3:isSelected() then
            param = {memberId = detailData.memberId, posId = 3}
        end
        if detailData.pos == param.posId then
            -- self.viewMgr:showTip("任命成功")
            self:close()
            return
        end
        self:positionAppoint(param)
    end)
end 

function GuildAppointDialog:positionAppoint(param)
    self._serverMgr:sendMsg("GuildServer", "positionAppoint", param, true, {}, function (result)
        self._modelMgr:getModel("GuildModel"):updateMemberPos(param)
        self._modelMgr:getModel("GuildModel"):setGuildTempData(true)
        self:positionAppointFinish(result)
    end,function(errorId)
        if tonumber(errorId) == 2708 then
           self._viewMgr:showTip("该职位已达上限")
        end
    end)
end

function GuildAppointDialog:positionAppointFinish(result)
    dump(result)
    if result == nil then
        return
    end
    self:close()
end
return GuildAppointDialog