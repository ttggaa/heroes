--[[
    Filename:    GuildDetailDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-18 21:34:09
    Description: File description
--]]

-- 联盟详细信息
local GuildDetailDialog = class("GuildDetailDialog",BasePopView)
function GuildDetailDialog:ctor()
    self.super.ctor(self)
    -- self._itemModel = self._modelMgr:getModel("ItemModel")
end

-- 初始化UI后会调用, 有需要请覆盖5
function GuildDetailDialog:onInit()
    -- local Label_33 = self:getUI("bg.Label_33")
    -- Label_33:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- local Label_37 = self:getUI("bg.Label_37")
    -- Label_37:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- local Label_34 = self:getUI("bg.Label_34")
    -- Label_34:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- local Label_38 = self:getUI("bg.Label_38")
    -- Label_38:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 1)

    local name = self:getUI("bg.name")
    UIUtils:setTitleFormat(name, 2)

    local allianceScore = self:getUI("bg.allianceScore")
    allianceScore:setFntFile(UIUtils.bmfName_zhandouli_little)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function( )
        self:close()
        UIUtils:reloadLuaFile("guild.dialog.GuildDetailDialog")
    end)
end

function GuildDetailDialog:reflashUI(data)
    if data == nil then
        return
    end
    
    local allianceD = data.allianceD

    local iconBg = self:getUI("bg.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")
    local param = {flags = allianceD.avatar1 or 101, logo = allianceD.avatar2 or 201}
    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setScale(0.85)
        avatarIcon:setPosition(10,10)
        iconBg:addChild(avatarIcon)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end


    local name = self:getUI("bg.name")
    name:setString(allianceD.name)

    local nameBg = self:getUI("bg.Image_131")
    local nameWidth = name:getContentSize().width+20
    nameBg:setContentSize(nameWidth < 115 and 192 or nameWidth + 80, nameBg:getContentSize().height)

    local level = self:getUI("bg.level")
    -- level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    level:setString("联盟等级：" .. allianceD.level)
    local playName = self:getUI("bg.playName")
    playName:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    playName:setString(allianceD.mName)
    local allianceId = self:getUI("bg.allianceId")
    allianceId:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    allianceId:setString(allianceD._id)
    local rank = self:getUI("bg.rank")
    rank:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    rank:setString(allianceD.rank)
    local personNum = self:getUI("bg.personNum")
    personNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    personNum:setString(allianceD.roleNum .. "/" .. allianceD.roleNumLimit)
    local gonggao = self:getUI("bg.adBg.gonggao")
    -- gonggao:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    if not allianceD["declare"] or allianceD["declare"] == "" then
        gonggao:setString("联盟宣言: " .. lang("GUIlDEDECLA_WORD"))
    else
        gonggao:setString("联盟宣言: " .. allianceD["declare"])
    end

    local allianceScore = self:getUI("bg.allianceScore")
    if allianceD["score"] then
        allianceScore:setString("a" .. (allianceD["score"] or 0))
    else
        allianceScore:setVisible(false)
    end
    allianceScore:setScale(0.6)

	self:onInitQuitEvaluateData(allianceD)
end

function GuildDetailDialog:onInitQuitEvaluateData(allianceData)
	local quitCountLab = self:getUI("bg.quitCountLab")
	local totalCount = allianceData.quitNum or 0
	quitCountLab:setString(string.format("%s人", totalCount))
	
	local quitData = allianceData.quitJudge or {}
	for i=1, 4 do
		local reasonRoot = self:getUI("bg.quitReason"..i)
		local countLab = reasonRoot:getChildByName("countLab")
		local count = quitData[tostring(i)] or 0
		countLab:setString(string.format("%s人", count))
	end
end

return GuildDetailDialog