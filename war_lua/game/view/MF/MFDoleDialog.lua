--[[
    Filename:    MFDoleDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-10-07 20:08:19
    Description: File description
--]]

-- 感谢和领奖
local iconIdMap = IconUtils.iconIdMap

local MFDoleDialog = class("MFDoleDialog",BasePopView)
function MFDoleDialog:ctor(param)
    self.super.ctor(self)
    self._doleType = param.doleType
    self._thankList = param.thankList or {}
    self._helper = param.helper or {}
    self._callBack = param.callBack
end

-- 初始化UI后会调用, 有需要请覆盖
function MFDoleDialog:onInit()
    self._roleImg = self:getUI("bg.bg0.role_img")
    self._roleImg:loadTexture("asset/bg/global_reward_img.png")
    
    self._title = self:getUI("bg.titleBg.title")


    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFDoleDialog")
        end
        if self._callBack then
            self._callBack()
        end
        self:close()
    end)
end

function MFDoleDialog:reflashUI(data)
    -- dump(data)
    -- dump(self._helper, "self._helper ===")
    if self._doleType == 1 then
        self._closeBtn:setTitleText("不客气") 

        local thankList = string.split(self._thankList, ",")

        local str = string.gsub(lang("MF_THX"), "{$num}", table.nums(thankList))
        self._title:setString(str)

        local gifts = tab:Setting("G_MF_THANK").value
        for i=1,2 do
            local itemBg = self:getUI("bg.bg0.rewardPanel.itemBg" .. i)
            if i <= table.nums(gifts) then
                local itemIcon = itemBg:getChildByName("itemIcon")
                local itemId = gifts[i][2]
                if gifts[i][1] == "gold" then
                    itemId = IconUtils.iconIdMap.gold
                end
                local param = {itemId = itemId, effect = true, eventStyle = 1, num = gifts[i][3]*(table.nums(thankList))}
                if itemIcon then
                    IconUtils:updateItemIconByView(itemIcon, param)
                else
                    itemIcon = IconUtils:createItemIconById(param)
                    itemIcon:setName("itemIcon")
                    itemIcon:setScale(0.9)
                    itemIcon:setPosition(cc.p(-2,-8))
                    itemBg:addChild(itemIcon)
                end

                local lvl = itemBg:getChildByFullName("lvl")
                lvl:setVisible(false)

                local name = itemBg:getChildByFullName("name")
                name:setString(lang(tab:Tool(itemId).name))

                itemBg:setVisible(true)
            else
                itemBg:setVisible(false)
            end
        end
        if table.nums(gifts) == 1 then
            local itemBg = self:getUI("bg.bg0.rewardPanel.itemBg1")
            itemBg:setPositionX(149)
        end
    elseif self._doleType == 0 then
        self._closeBtn:setTitleText("谢谢") 

        local str = string.gsub(lang("MF_HELP"), "{$num}", table.nums(self._helper))
        self._title:setString(str)

        for i=1,2 do
            local itemBg = self:getUI("bg.bg0.rewardPanel.itemBg" .. i)
            if i <= table.nums(self._helper) then
                local name = self:getUI("bg.bg0.rewardPanel.itemBg" .. i ..".name")
                name:setString(self._helper[i].name)

                local lvl = self:getUI("bg.bg0.rewardPanel.itemBg" .. i ..".lvl")
                lvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
                lvl:setString(self._helper[i].lvl)

                if itemBg then
                    local param1 = {avatar = self._helper[i].avatar, tp = 4,avatarFrame = self._helper[i]["avatarFrame"]}
                    local icon = itemBg:getChildByName("icon")
                    if not icon then
                        icon = IconUtils:createHeadIconById(param1)
                        icon:setName("icon")
                        icon:setPosition(cc.p(-5,-5))
                        itemBg:addChild(icon)
                    else
                        IconUtils:updateHeadIconByView(icon, param1)
                    end
                end
            else
                itemBg:setVisible(false)
            end
        end

        if table.nums(self._helper) == 1 then
            local itemBg = self:getUI("bg.bg0.rewardPanel.itemBg1")
            itemBg:setPositionX(149)
        end
    end
end

-- function MFDoleDialog:reflashUI(data)
--     if self._doleType == 1 then
--         self._closeBtn:setTitleText("不客气") 
--     else
--         self._closeBtn:setTitleText("谢谢") 
--     end
-- end

return MFDoleDialog