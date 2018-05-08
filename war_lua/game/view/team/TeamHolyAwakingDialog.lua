--[[
    Filename:    TeamHolyAwakingDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-16 17:45:20
    Description: File description
--]]

-- 觉醒
local TeamHolyAwakingDialog = class("TeamHolyAwakingDialog", BaseView)

function TeamHolyAwakingDialog:ctor(data)
    TeamHolyAwakingDialog.super.ctor(self)
    if not data then
        data = {}
    end
    self._teamId = data.teamId or 101
    self._selectStone = 1
end

function TeamHolyAwakingDialog:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    local debusBtn = self:getUI("bg.debusBtn")
    self:registerClickEvent(debusBtn, function()
        self:resetUI()
    end)

    local awakingBtn = self:getUI("bg.awakingBtn")
    self:registerClickEvent(awakingBtn, function()
        if not self._stoneKey then
            print("没有选择材料")
        end
        local stoneData = self._teamModel:getHolyDataByKey(self._stoneKey)
        local itemData = tab:RuneAwake(stoneData.jackType).awakeCostd
        local itemId = itemData[2]
        local tempItems, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
        local itemNum = (tempItemCount or 0) 
        local costNum = (itemData[3] or 0)
        if itemNum >= costNum then
            local param = {id = self._stoneKey}
            self:awakeRunes(param)
        else
            print("材料不足")
        end
    end)

    local leftPanel = self:getUI("bg.leftPanel")
    self:registerClickEvent(leftPanel, function()
        UIUtils:reloadLuaFile("team.TeamHolySelectDialog")
        local callback = function(stoneKey)
            self._stoneKey = stoneKey
            print("=========", stoneKey)
            self:updateLeftPanel()
            self:updateTargetPanel()
        end
        local selType = 3
        local param = {callback = callback, selType = selType}
        self._viewMgr:showDialog("team.TeamHolySelectDialog", param)
    end)

    self:updateUI()
    self:resetUI()

    -- self:updateLeftPanel()
end

function TeamHolyAwakingDialog:resetUI()
    self._stoneKey = nil
    self:updateLeftPanel()
    self:updateTargetPanel()

    local debusBtn = self:getUI("bg.debusBtn")
    debusBtn:setVisible(false)
    local awakingBtn = self:getUI("bg.awakingBtn")
    awakingBtn:setVisible(true)

    local itemBg = self:getUI("bg.itemBg")
    itemBg:setVisible(false)
end

function TeamHolyAwakingDialog:awakeRunes(param)
    dump(param)
    self._serverMgr:sendMsg("RunesServer", "awakeRunes", param, true, {}, function (result)
        dump(result, "result ===", 10)
        -- self:updateTargetPanel()
        local debusBtn = self:getUI("bg.debusBtn")
        debusBtn:setVisible(true)
        local awakingBtn = self:getUI("bg.awakingBtn")
        awakingBtn:setVisible(false)
    end)
end

function TeamHolyAwakingDialog:updateLeftPanel()
    -- self._stoneKey = 2
    local selPanel = self:getUI("bg.leftPanel.selPanel")
    local addPanel = self:getUI("bg.leftPanel.addPanel")
    local itemBg = self:getUI("bg.itemBg")
    if not self._stoneKey then
        selPanel:setVisible(false)
        addPanel:setVisible(true)
        itemBg:setVisible(false)
        return
    end
    selPanel:setVisible(true)
    addPanel:setVisible(false)
    itemBg:setVisible(true)

    local stoneData = self._teamModel:getHolyDataByKey(self._stoneKey)

    local suitIconBg = self:getUI("bg.leftPanel.selPanel.iconBg")
    local richtextBg = self:getUI("bg.leftPanel.selPanel.richTextBg")
    local suitIcon = suitIconBg["suitIcon"]
    if stoneData then
        local stoneId = stoneData.id
        local stoneTab = tab:Rune(stoneId) 
        local param = {suitData = stoneTab}
        if not suitIcon then
            suitIcon = IconUtils:createHolyIconById(param)
            suitIcon:setScale(0.88)
            suitIcon:setPosition(1, 1)
            suitIconBg:addChild(suitIcon, 20)
            suitIconBg["suitIcon"] = suitIcon
        else
            IconUtils:updateHolyIcon(suitIcon, param)
        end
        suitIcon:setVisible(true)

        local attrData = stoneData.p
        for i=1,6 do
            local attrLab = self:getUI("bg.leftPanel.selPanel.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.leftPanel.selPanel.natureBg.attrBg" .. i .. ".attrValue")
            local _attrData = attrData[i]
            if _attrData then
                local str = lang("ATTR_" .. _attrData[1])
                attrLab:setString(str)
                attrLab:setVisible(true)
                local str = "+" .. _attrData[2] .. "%"
                attrValue:setString(str)
                attrValue:setVisible(true)
            else
                attrLab:setVisible(false)
                attrValue:setVisible(false)
            end
        end

        local effectTab = tab:Setting("GEM_EFFECT_NUM").value
        local rmaxHeight = 0
        for i=1,table.nums(effectTab) do
            local indexId = effectTab[i]
            local desc = lang(stoneTab["des" .. indexId])
            local richText = richtextBg["richText" .. i]
            if richText then
                richText:removeFromParent()
            end
            if string.find(desc, "color=") == nil then
                desc = "[color=462800]"..desc.."[-]"
            end   
            desc = string.gsub(desc, "color=645252", "color=ffeea0")
            richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5 - rmaxHeight)
            richText:setName("richText" .. i)
            richtextBg:addChild(richText)
            richtextBg["richText" .. i] = richText
            rmaxHeight = rmaxHeight + richText:getInnerSize().height + 10
        end
        richtextBg:setVisible(true)

        local itemIcon = itemBg.itemIcon
        local itemData = tab:RuneAwake(stoneData.jackType).awakeCostd
        local itemId = itemData[2]
        local tempItems, tempItemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
        local itemNum = (tempItemCount or 0) .. "/" .. (itemData[3] or 0)
        local param = {itemId = itemId, effect = true, eventStyle = 1, num = itemNum}
        local itemIcon = itemBg:getChildByName("itemIcon")
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setName("itemIcon")
            itemIcon:setScale(0.6)
            itemIcon:setPosition(cc.p(0,0))
            itemBg:addChild(itemIcon)
        end
    else
        for i=1,6 do
            local attrLab = self:getUI("bg.leftPanel.selPanel.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.leftPanel.selPanel.natureBg.attrBg" .. i .. ".attrValue")
            attrLab:setVisible(false)
            attrValue:setVisible(false)
        end
        if suitIcon then
            suitIcon:setVisible(false)
        end
        richtextBg:setVisible(true)
    end
end 
function TeamHolyAwakingDialog:test()

end 

function TeamHolyAwakingDialog:updateTargetPanel()
    -- self._stoneKey = 2
    local selPanel = self:getUI("bg.targetPanel.selPanel")
    local addPanel = self:getUI("bg.targetPanel.addPanel")
    addPanel:setVisible(false)
    -- self._targetKey = self._stoneKey
    if not self._stoneKey then
        selPanel:setVisible(false)
        return
    end
    selPanel:setVisible(true)

    local stoneData = self._teamModel:getHolyDataByKey(self._stoneKey)

    local suitIconBg = self:getUI("bg.targetPanel.selPanel.iconBg")
    local richtextBg = self:getUI("bg.targetPanel.selPanel.richTextBg")
    local suitIcon = suitIconBg["suitIcon"]
    if stoneData then
        local stoneId = stoneData.id
        local oldStoneTab = tab:Rune(stoneId) 
        local nStoneId = oldStoneTab.awakeId
        local stoneTab = tab:Rune(nStoneId) 
        local param = {suitData = stoneTab}
        if not suitIcon then
            suitIcon = IconUtils:createHolyIconById(param)
            suitIcon:setScale(0.88)
            suitIcon:setPosition(1, 1)
            suitIconBg:addChild(suitIcon, 20)
            suitIconBg["suitIcon"] = suitIcon
        else
            IconUtils:updateHolyIcon(suitIcon, param)
        end
        suitIcon:setVisible(true)

        local attrData = stoneData.p
        for i=1,6 do
            local attrLab = self:getUI("bg.targetPanel.selPanel.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.targetPanel.selPanel.natureBg.attrBg" .. i .. ".attrValue")
            local _attrData = attrData[i]
            if _attrData then
                local str = lang("ATTR_" .. _attrData[1])
                attrLab:setString(str)
                attrLab:setVisible(true)
                local str = "+" .. _attrData[2] .. "%"
                attrValue:setString(str)
                attrValue:setVisible(true)
            else
                attrLab:setVisible(false)
                attrValue:setVisible(false)
            end
        end

        local effectTab = tab:Setting("GEM_EFFECT_NUM").value
        local rmaxHeight = 0
        for i=1,table.nums(effectTab) do
            local indexId = effectTab[i]
            local desc = lang(stoneTab["des" .. indexId])
            local richText = richtextBg["richText" .. i]
            if richText then
                richText:removeFromParent()
            end
            if string.find(desc, "color=") == nil then
                desc = "[color=462800]"..desc.."[-]"
            end   
            desc = string.gsub(desc, "color=645252", "color=ffeea0")
            richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5 - rmaxHeight)
            richText:setName("richText" .. i)
            richtextBg:addChild(richText)
            richtextBg["richText" .. i] = richText
            rmaxHeight = rmaxHeight + richText:getInnerSize().height + 10
        end
        richtextBg:setVisible(true)
    else
        for i=1,6 do
            local attrLab = self:getUI("bg.targetPanel.selPanel.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.targetPanel.selPanel.natureBg.attrBg" .. i .. ".attrValue")
            attrLab:setVisible(false)
            attrValue:setVisible(false)
        end
        if suitIcon then
            suitIcon:setVisible(false)
        end
        richtextBg:setVisible(true)
    end
end 

function TeamHolyAwakingDialog:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"RuneCoin","Gold","Gem"},titleTxt = "圣徽"})
end

function TeamHolyAwakingDialog:getBgName()
    return "bg_012.jpg"
end

function TeamHolyAwakingDialog:updateUI()

    local title = self:getUI("bg.leftPanel.title")
    title:setColor(cc.c3b(253, 254, 230))
    title:enable2Color(1, cc.c4b(232, 200, 89, 255))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local title = self:getUI("bg.targetPanel.title")
    title:setColor(cc.c3b(253, 254, 230))
    title:enable2Color(1, cc.c4b(232, 200, 89, 255))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
end 


return TeamHolyAwakingDialog