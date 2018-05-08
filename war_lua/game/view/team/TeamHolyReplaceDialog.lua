--[[
    Filename:    TeamHolyReplaceDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2018-01-02 15:32:45
    Description: File description
--]]

-- 更换
local TeamHolyReplaceDialog = class("TeamHolyReplaceDialog", BaseView)
local qualityMC = TeamUtils.qualityMC

function TeamHolyReplaceDialog:ctor(data)
    TeamHolyReplaceDialog.super.ctor(self)
    if not data then
        data = {}
    end
    self._teamId = data.teamId or 101
    self._selectStone = data.selectStone or 1
end

function TeamHolyReplaceDialog:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._weaponModel = self._modelMgr:getModel("WeaponsModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    local debusBtn = self:getUI("bg.middleBg.debusBtn")
    self:registerClickEvent(debusBtn, function()
        self:takeRune()
        -- self:test()
    end)

    local replaceBtn = self:getUI("bg.middleBg.replaceBtn")
    self:registerClickEvent(replaceBtn, function()
        self:equipRune()
    end)

    self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._teamId)

    self._backBtn = self:getUI("bg.rightPanel.backBtn")
    self:registerClickEvent(self._backBtn, function()
        self:initTabView()
    end)

    -- self._tableData = self._teamModel:getTabSuitData()
    self._itemCell = self:getUI("tabCell")
    self:addTableView()

    self._leftAttr = self:getUI("bg.middleBg.leftAttr")
    self._rightAttr = self:getUI("bg.middleBg.rightAttr")
    

    self._nothing = self:getUI("bg.rightPanel.nothing")
    self._nothing:setVisible(false)

    -- init
    self:updateUI()
    self:updateLeftList()
    self:initTabView()
    self:updateLeftStone()
    self:updateRightStone()
end

function TeamHolyReplaceDialog:test()
    -- dump(self._curSelectTeam)
    -- local teamId = self._curSelectTeam.teamId

    -- local fixdeTtpe = self:getStoneType(teamId, self._selectStone)

    -- local fixdeTtpe = self:getShowSuitData(fixdeTtpe)

    -- dump(fixdeTtpe, "useHoly=====", 2)

    -- local newteamData = self._teamModel:getHolyData()-- 宝石
    -- dump(newteamData, "newteamData=====", 1)
    -- local newteamData = self._teamModel:getTabHolyData()
    -- dump(newteamData, "newteamData=====", 1)

    -- local newteamData = self._teamModel:getSuitData() -- 套装
    -- dump(newteamData, "newteamData=====", 2)
    -- local newteamData = self._teamModel:getTabSuitData()
    -- dump(newteamData, "newteamData=====", 2)
    -- local newteamData = self._teamModel:getAllSuitData()
    -- dump(newteamData, "newteamData=====", 2)

    -- local newteamData = self._teamModel:getTeamUseHolyData()-- 使用的宝石
    -- dump(newteamData, "newteamData=====", 2)

    -- local newteamData = self._teamModel:getAllSuitSortData()
    -- dump(newteamData, "newteamData=====", 2)
    
end 

function TeamHolyReplaceDialog:updateLeftSuit()
    local maxHeight = 0
    local titleBg1 = self:getUI("bg.middleBg.leftAttr.titleBg1")
    maxHeight = maxHeight + titleBg1:getContentSize().height
    local titleBg2 = self:getUI("bg.middleBg.leftAttr.titleBg2")
    maxHeight = maxHeight + titleBg2:getContentSize().height
    local natureBg = self:getUI("bg.middleBg.leftAttr.natureBg")
    maxHeight = maxHeight + natureBg:getContentSize().height
    local richtextBg = self:getUI("bg.middleBg.leftAttr.richTextBg")

    local rune = self._curSelectTeam.rune or {}
    local stoneId = tostring(self._selectStone)
    local effectTab = tab:Setting("GEM_EFFECT_NUM").value
    if rune and rune[stoneId] and rune[stoneId] ~= 0 then
        local stoneKey = rune[stoneId]
        local stoneData = self._teamModel:getHolyDataByKey(stoneKey)
        local stoneId = stoneData.id
        local stoneTab = tab:Rune(stoneId) 

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
            richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5 - rmaxHeight)
            richText:setName("richText" .. i)
            richtextBg:addChild(richText)
            richtextBg["richText" .. i] = richText
            rmaxHeight = rmaxHeight + richText:getInnerSize().height
        end
        maxHeight = maxHeight + rmaxHeight
        richtextBg:setVisible(true)
    else
        richtextBg:setVisible(false)
    end

    local scrollViewWidth = self._leftAttr:getContentSize().width
    local sheight = self._leftAttr:getContentSize().height
    if sheight > maxHeight then
        maxHeight = sheight
    end
    self._leftAttr:setInnerContainerSize(cc.size(scrollViewWidth, maxHeight))

    local posY = maxHeight - titleBg1:getContentSize().height * 0.5
    local addPosY = titleBg1:getContentSize().height
    titleBg1:setPositionY(posY)

    addPosY = addPosY + natureBg:getContentSize().height
    local posY = maxHeight - addPosY
    natureBg:setPositionY(posY)

    addPosY = addPosY + titleBg2:getContentSize().height
    local posY = maxHeight - addPosY + titleBg2:getContentSize().height*0.5 + 3
    titleBg2:setPositionY(posY)

    addPosY = addPosY + richtextBg:getContentSize().height
    local posY = maxHeight - addPosY
    richtextBg:setPositionY(posY)
end 


function TeamHolyReplaceDialog:equipRune()
    -- local oldTeamData = clone(self._curSelectTeam)
    local param = {teamId = self._teamId, sid = self._selectStone, id = self._stoneKey}
    self._serverMgr:sendMsg("TeamServer", "equipRune", param, true, {}, function (result)
        dump(result, "result ===", 10)
        self._stoneKey = nil
        self:updateLeftStone()
        self:updateRightStone()
        self:updateLeftList()
        self:reloadData()

        local newteamData = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
        dump(newteamData)
    end)
end

function TeamHolyReplaceDialog:reloadData()
    if self._selectIndex == 1 then
        local teamId = self._curSelectTeam.teamId
        local fixdeTtpe = self._teamModel:getStoneType(teamId, self._selectStone)
        self._tableData = self._teamModel:getShowSuitData(fixdeTtpe)
        self._tableView:reloadData()
    else
        self._tableData = self._teamModel:getShowHolyData(self._selectSuitId)
        self._tableView:reloadData()
    end
    if table.nums(self._tableData) == 0 then
        self._nothing:setVisible(true)
    else
        self._nothing:setVisible(false)
    end
end 

function TeamHolyReplaceDialog:takeRune()
    local param = {teamId = self._teamId, sids = self._selectStone}
    self._serverMgr:sendMsg("TeamServer", "takeRune", param, true, {}, function (result)
        self:updateLeftList()
        self:updateLeftStone()
        self:reloadData()
        dump(result)
        local newteamData = self._teamModel:getTeamAndIndexById(self._curSelectTeam.teamId)
        dump(newteamData)
    end)
end

function TeamHolyReplaceDialog:updateLeftStone()
    local leftIconBg = self:getUI("bg.middleBg.leftIconBg")
    local rname = self:getUI("bg.middleBg.leftIconBg.rname")
    local notEquip = self:getUI("bg.middleBg.leftIconBg.notEquip")
    local suitIcon = leftIconBg["suitIcon"]
    
    local rune = self._curSelectTeam.rune or {}
    local stoneId = tostring(self._selectStone)
    if rune and rune[stoneId] and rune[stoneId] ~= 0 then
        local stoneKey = rune[stoneId]
        local stoneData = self._teamModel:getHolyDataByKey(stoneKey)

        local stoneId = stoneData.id
        local stoneTab = tab:Rune(stoneId) 
        rname:setString(lang(stoneTab.name))
        local param = {suitData = stoneTab}
        if not suitIcon then
            suitIcon = IconUtils:createHolyIconById(param)
            suitIcon:setScale(0.82)
            suitIcon:setPosition(1, 4)
            leftIconBg:addChild(suitIcon, 20)
            leftIconBg["suitIcon"] = suitIcon
        else
            IconUtils:updateHolyIcon(suitIcon, param)
        end
        suitIcon:setVisible(true)

        local attrData = stoneData.p
        for i=1,6 do
            local attrLab = self:getUI("bg.middleBg.leftAttr.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.middleBg.leftAttr.natureBg.attrBg" .. i .. ".attrValue")
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

        if notEquip then
            notEquip:setVisible(false)
        end
    else
        rname:setString("")
        for i=1,6 do
            local attrLab = self:getUI("bg.middleBg.leftAttr.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.middleBg.leftAttr.natureBg.attrBg" .. i .. ".attrValue")
            attrLab:setVisible(false)
            attrValue:setVisible(false)
        end
        if suitIcon then
            suitIcon:setVisible(false)
        end
        if notEquip then
            notEquip:setVisible(true)
        end
    end

    self:updateLeftSuit()
end


function TeamHolyReplaceDialog:updateLeftSuit()
    local maxHeight = 0
    local titleBg1 = self:getUI("bg.middleBg.leftAttr.titleBg1")
    maxHeight = maxHeight + titleBg1:getContentSize().height
    local titleBg2 = self:getUI("bg.middleBg.leftAttr.titleBg2")
    maxHeight = maxHeight + titleBg2:getContentSize().height
    local natureBg = self:getUI("bg.middleBg.leftAttr.natureBg")
    maxHeight = maxHeight + natureBg:getContentSize().height
    local richtextBg = self:getUI("bg.middleBg.leftAttr.richTextBg")

    local rune = self._curSelectTeam.rune or {}
    local stoneId = tostring(self._selectStone)
    local effectTab = tab:Setting("GEM_EFFECT_NUM").value
    local suitBg = self:getUI("bg.middleBg.leftAttr.suitBg")
    local suitStr = ""
    if rune and rune[stoneId] and rune[stoneId] ~= 0 then
        local stoneKey = rune[stoneId]
        local stoneData = self._teamModel:getHolyDataByKey(stoneKey)
        local stoneId = stoneData.id
        local stoneTab = tab:Rune(stoneId) 

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
            desc = string.gsub(desc, "fontsize=20", "fontsize=18")
            richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5 - rmaxHeight)
            richText:setName("richText" .. i)
            richtextBg:addChild(richText)
            richtextBg["richText" .. i] = richText
            rmaxHeight = rmaxHeight + richText:getInnerSize().height
        end
        maxHeight = maxHeight + rmaxHeight
        richtextBg:setVisible(true)
    else
        richtextBg:setVisible(false)
    end

    local scrollViewWidth = self._leftAttr:getContentSize().width
    local sheight = self._leftAttr:getContentSize().height
    if sheight > maxHeight then
        maxHeight = sheight
    end
    self._leftAttr:setInnerContainerSize(cc.size(scrollViewWidth, maxHeight))

    local posY = maxHeight - titleBg1:getContentSize().height * 0.5
    local addPosY = titleBg1:getContentSize().height
    titleBg1:setPositionY(posY)

    addPosY = addPosY + natureBg:getContentSize().height
    local posY = maxHeight - addPosY
    natureBg:setPositionY(posY)

    addPosY = addPosY + titleBg2:getContentSize().height
    local posY = maxHeight - addPosY + titleBg2:getContentSize().height*0.5 + 3
    titleBg2:setPositionY(posY)

    addPosY = addPosY + richtextBg:getContentSize().height
    local posY = maxHeight - addPosY
    richtextBg:setPositionY(posY)
end 


function TeamHolyReplaceDialog:updateRightStone()
    local rightIconBg = self:getUI("bg.middleBg.rightIconBg")
    local rname = self:getUI("bg.middleBg.rightIconBg.rname")
    local notEquip = self:getUI("bg.middleBg.rightIconBg.notEquip")
    local suitIcon = rightIconBg["suitIcon"]
    if not self._stoneKey then
        if suitIcon then
            suitIcon:setVisible(false)
        end
        notEquip:setVisible(true)
        rname:setString("")
        for i=1,6 do
            local attrLab = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".attrLab")
            local attrValue = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".attrValue")
            local arrow = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".arrow")
            local newLab = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".newLab")
            arrow:setVisible(false)
            newLab:setVisible(false)
            attrLab:setVisible(false)
            attrValue:setVisible(false)
        end
        self:updateRightSuit()
        return
    else
        notEquip:setVisible(false)
    end
    local stoneKey = self._stoneKey
    local stoneData = self._teamModel:getHolyDataByKey(stoneKey)


    local stoneId = stoneData.id
    local stoneTab = tab:Rune(stoneId) 
    rname:setString(lang(stoneTab.name))
    local param = {suitData = stoneTab}
    if not suitIcon then
        suitIcon = IconUtils:createHolyIconById(param)
        suitIcon:setScale(0.82)
        suitIcon:setPosition(3, 4)
        rightIconBg:addChild(suitIcon, 20)
        rightIconBg["suitIcon"] = suitIcon
    else
        IconUtils:updateHolyIcon(suitIcon, param)
    end
    suitIcon:setVisible(true)

    local attrData = stoneData.p
    for i=1,6 do
        local attrLab = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".attrLab")
        local attrValue = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".attrValue")
        local arrow = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".arrow")
        local newLab = self:getUI("bg.middleBg.rightAttr.natureBg.attrBg" .. i .. ".newLab")
        arrow:setVisible(false)
        newLab:setVisible(false)
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

    self:updateRightSuit()
end


function TeamHolyReplaceDialog:updateRightSuit()
    local maxHeight = 0
    local titleBg1 = self:getUI("bg.middleBg.rightAttr.titleBg1")
    maxHeight = maxHeight + titleBg1:getContentSize().height
    local titleBg2 = self:getUI("bg.middleBg.rightAttr.titleBg2")
    maxHeight = maxHeight + titleBg2:getContentSize().height
    local natureBg = self:getUI("bg.middleBg.rightAttr.natureBg")
    maxHeight = maxHeight + natureBg:getContentSize().height
    local richtextBg = self:getUI("bg.middleBg.rightAttr.richTextBg")

    local rune = self._curSelectTeam.rune or {}
    local stoneId = tostring(self._selectStone)
    local effectTab = tab:Setting("GEM_EFFECT_NUM").value
    local suitBg = self:getUI("bg.middleBg.rightAttr.suitBg")
    local suitStr = ""
    if self._stoneKey then
        local stoneKey = self._stoneKey
        local stoneData = self._teamModel:getHolyDataByKey(stoneKey)
        local stoneId = stoneData.id
        local stoneTab = tab:Rune(stoneId) 

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
            desc = string.gsub(desc, "fontsize=20", "fontsize=18")
            richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
            richText:formatText()
            richText:enablePrinter(true)
            richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5 - rmaxHeight)
            richText:setName("richText" .. i)
            richtextBg:addChild(richText)
            richtextBg["richText" .. i] = richText
            rmaxHeight = rmaxHeight + richText:getInnerSize().height
        end
        maxHeight = maxHeight + rmaxHeight
        richtextBg:setVisible(true)
    else
        richtextBg:setVisible(false)
    end

    local scrollViewWidth = self._rightAttr:getContentSize().width
    local sheight = self._rightAttr:getContentSize().height
    if sheight > maxHeight then
        maxHeight = sheight
    end
    self._rightAttr:setInnerContainerSize(cc.size(scrollViewWidth, maxHeight))

    local posY = maxHeight - titleBg1:getContentSize().height * 0.5
    local addPosY = titleBg1:getContentSize().height
    titleBg1:setPositionY(posY)

    addPosY = addPosY + natureBg:getContentSize().height
    local posY = maxHeight - addPosY
    natureBg:setPositionY(posY)

    addPosY = addPosY + titleBg2:getContentSize().height
    local posY = maxHeight - addPosY + titleBg2:getContentSize().height*0.5 + 3
    titleBg2:setPositionY(posY)

    addPosY = addPosY + richtextBg:getContentSize().height
    local posY = maxHeight - addPosY
    richtextBg:setPositionY(posY)
end 


function TeamHolyReplaceDialog:updateLeftList()
    -- local leftPanel = self:getUI("bg.leftPanel")
    local rune = self._curSelectTeam.rune or {}
    local holyData = self._teamModel:getHolyData()
    for i=1,6 do
        local stoneBg = self:getUI("bg.leftPanel.stoneImg" .. i)
        local stoneIcon = self:getUI("bg.leftPanel.stoneImg" .. i .. ".notEquip")
        print("stoneBg==============", stoneBg)
        -- local nStone = stoneBg.notEquip
        local qualityAnim = stoneBg.qualityAnim
        local indexId = tostring(i)
        if rune and rune[indexId] and rune[indexId] ~= 0 then
            local key = rune[indexId]
            local holyId = holyData[key].id
            local holyId = holyData[key].id
            print("holyId===============" .. i .. key, holyId)
            -- local suitTab = tab.rune[holyId]
            local make = holyData[key].make
            local quality = holyData[key].quality
            local suitTab = tab.runeClient[make]
            -- local param = {suitData = suitTab}
            -- local stoneIcon = stoneBg.stoneIcon
            -- if not stoneIcon then
            --     stoneIcon = IconUtils:createHolyIconById(param)
            --     stoneIcon:setScale(0.82)
            --     stoneIcon:setPosition(-2, -2)
            --     stoneBg:addChild(stoneIcon, 20)
            --     stoneBg.stoneIcon = stoneIcon
            -- else
            --     IconUtils:updateHolyIcon(stoneIcon, param)
            -- end
            -- stoneIcon:setVisible(true)
            if stoneIcon then
                stoneIcon:loadTexture(suitTab.icon .. ".png", 1)
                stoneIcon:setScale(0.8)
            end

            if not tolua.isnull(qualityAnim) then
                qualityAnim:removeFromParent()
                qualityAnim = nil
            end
            local quslityStr = qualityMC[quality]
            if quslityStr then
                qualityAnim = mcMgr:createViewMC(quslityStr, true, false)
                qualityAnim:setName("qualityAnim")
                qualityAnim:setScale(0.8)
                qualityAnim:setPosition(48, 45)
                stoneBg:addChild(qualityAnim)
                stoneBg.qualityAnim = qualityAnim
            end

            -- if nStone then
            --     nStone:setVisible(false)
            -- end
        else
            if stoneIcon then
                stoneIcon:loadTexture("TeamHolyUI_img17.png", 1)
            end

            if not tolua.isnull(qualityAnim) then
                qualityAnim:removeFromParent()
                qualityAnim = nil
            end
            -- if nStone then
            --     nStone:setVisible(true)
            -- end
        end

        local xuanzhong = stoneBg.xuanzhong
        if not xuanzhong then
            xuanzhong = mcMgr:createViewMC("xuanzhong_teamqianneng", true, false)
            xuanzhong:setName("xuanzhong")
            -- xuanzhong:setScale(0.8)
            -- xuanzhong:gotoAndStop(1)
            xuanzhong:setPosition(48, 48)
            stoneBg:addChild(xuanzhong,50)
            stoneBg.xuanzhong = xuanzhong
        end
        if self._selectStone == i then
            xuanzhong:setVisible(true)
        else
            xuanzhong:setVisible(false)
        end

        self:registerClickEvent(stoneBg, function()
            print("holyId==========", holyId)
            local oldStoneId = self._selectStone
            local oldStoneBg = self:getUI("bg.leftPanel.stoneImg" .. oldStoneId)
            local oldSel = oldStoneBg.xuanzhong
            if oldSel then
                oldSel:setVisible(false)
            end
            xuanzhong:setVisible(true)
            self._selectStone = i
            self:updateLeftStone()
            if oldStoneId >= 3 and i <= 2 then
                self._stoneKey = nil 
                self:updateRightStone()
                self:initTabView()
            else
                self:reloadData()
            end
        end)
    end
end
-- function TeamHolyReplaceDialog:updateLeftList()
--     -- local leftPanel = self:getUI("bg.leftPanel")
--     local rune = self._curSelectTeam.rune or {}
--     local holyData = self._teamModel:getHolyData()
--     for i=1,6 do
--         local stoneBg = self:getUI("bg.leftPanel.stoneBg" .. i)
--         local notEquip = self:getUI("bg.leftPanel.stoneBg" .. i .. ".notEquip")
--         local nStone = stoneBg.notEquip
--         local stoneIcon = stoneBg.stoneIcon
--         local indexId = tostring(i)
--         if rune and rune[indexId] and rune[indexId] ~= 0 then
--             local key = rune[indexId]
--             local holyId = holyData[key].id
--             print("holyId===============" .. i .. key, holyId)
--             local suitTab = tab.rune[holyId]
--             local param = {suitData = suitTab}
--             local stoneIcon = stoneBg.stoneIcon
--             if not stoneIcon then
--                 stoneIcon = IconUtils:createHolyIconById(param)
--                 stoneIcon:setScale(0.82)
--                 stoneIcon:setPosition(-2, -2)
--                 stoneBg:addChild(stoneIcon, 20)
--                 stoneBg.stoneIcon = stoneIcon
--             else
--                 IconUtils:updateHolyIcon(stoneIcon, param)
--             end
--             stoneIcon:setVisible(true)
--             if nStone then
--                 nStone:setVisible(false)
--             end
--         else
--             if stoneIcon then
--                 stoneIcon:setVisible(false)
--             end
--             if nStone then
--                 nStone:setVisible(true)
--             end
--         end

--         local xuanzhong = stoneBg.xuanzhong
--         if not xuanzhong then
--             xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
--             xuanzhong:setName("xuanzhong")
--             xuanzhong:setScale(0.8)
--             xuanzhong:gotoAndStop(1)
--             xuanzhong:setPosition(39, 39)
--             stoneBg:addChild(xuanzhong,50)
--             stoneBg.xuanzhong = xuanzhong
--         end
--         if self._selectStone == i then
--             xuanzhong:setVisible(true)
--         else
--             xuanzhong:setVisible(false)
--         end

--         self:registerClickEvent(stoneBg, function()
--             print("holyId==========", holyId)
--             local oldStoneId = self._selectStone
--             local oldStoneBg = self:getUI("bg.leftPanel.stoneBg" .. oldStoneId)
--             local oldSel = oldStoneBg.xuanzhong
--             if oldSel then
--                 oldSel:setVisible(false)
--             end
--             xuanzhong:setVisible(true)
--             self._selectStone = i
--             self:updateLeftStone()
--             if oldStoneId >= 3 and i <= 2 then
--                 self._stoneKey = nil 
--                 self:updateRightStone()
--                 self:initTabView()
--             else
--                 self:reloadData()
--             end
--         end)
--     end
-- end

function TeamHolyReplaceDialog:reflashUI()
    local x = 1
end

function TeamHolyReplaceDialog:updateUI()
    local title = self:getUI("bg.middleBg.leftAttr.titleBg1")
    UIUtils:adjustTitle(title, 10)
    local title = self:getUI("bg.middleBg.leftAttr.titleBg2")
    UIUtils:adjustTitle(title, 10)

    local title = self:getUI("bg.middleBg.rightAttr.titleBg1")
    UIUtils:adjustTitle(title, 10)
    local title = self:getUI("bg.middleBg.rightAttr.titleBg2")
    UIUtils:adjustTitle(title, 10)
end


--[[
用tableview实现
--]]
function TeamHolyReplaceDialog:addTableView()
    local tableViewBg = self:getUI("bg.rightPanel.tableViewBg")
    local theight = tableViewBg:getContentSize().height
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(1)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, 0)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    if self._tableView.setDragSlideable ~= nil then 
        self._tableView:setDragSlideable(true)
    end
    tableViewBg:addChild(self._tableView)
end

-- 返回cell的数量
function TeamHolyReplaceDialog:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function TeamHolyReplaceDialog:getTableNum()
    local tabNum = 0
    if self._selectIndex == 1 then
        tabNum = table.nums(self._tableData)
    else
        tabNum = math.ceil(table.nums(self._tableData)/4)
    end
    return tabNum
end

-- cell的尺寸大小
function TeamHolyReplaceDialog:cellSizeForTable(table,idx) 
    local width = 95 
    local height = 82
    if self._selectIndex == 1 then
        height = 72
    end
    return height, width
end

-- 创建在某个位置的cell
function TeamHolyReplaceDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local listCell = self._itemCell:clone()
        listCell:setName("listCell")
        listCell:setVisible(true)
        listCell:setAnchorPoint(0, 0)
        listCell:setPosition(0, 0)
        cell:addChild(listCell)
    end

    local listCell = cell:getChildByName("listCell")
    self:updateCell(listCell, indexId)

    return cell
end

function TeamHolyReplaceDialog:updateCell(inView, indexLine)
    local suitBg1 = inView:getChildByFullName("suitBg1")
    local suitBg2 = inView:getChildByFullName("suitBg2")
    if self._selectIndex == 1 then
        suitBg1:setVisible(true)
        suitBg2:setVisible(false)
        self:updateSuitCell(suitBg1, indexLine)
    else
        suitBg1:setVisible(false)
        suitBg2:setVisible(true)
        for i=1,4 do
            local indexId = (indexLine-1)*4+i
            self:updateStoneCell(suitBg2, indexId, i)
        end
    end
end

function TeamHolyReplaceDialog:updateStoneCell(inView, indexId, verticalId)
    local stoneKey = self._tableData[indexId]
    local suitIcon = inView["suitIcon" .. verticalId]
    if stoneKey then
        local stoneData = self._teamModel:getHolyDataByKey(stoneKey)
        local stoneId = stoneData.id
        local stoneTab = tab:Rune(stoneId) 
        local param = {suitData = stoneTab}
        if not suitIcon then
            suitIcon = IconUtils:createHolyIconById(param)
            suitIcon:setScale(0.76)
            suitIcon:setPosition(78*(verticalId - 1), 5)
            inView:addChild(suitIcon, 20)
            inView["suitIcon" .. verticalId] = suitIcon
        else
            IconUtils:updateHolyIcon(suitIcon, param)
        end
        suitIcon:setVisible(true)

        local xuanzhong = suitIcon.xuanzhong
        if not xuanzhong then
            xuanzhong = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
            xuanzhong:setName("xuanzhong")
            xuanzhong:setScale(0.9)
            xuanzhong:gotoAndStop(1)
            xuanzhong:setPosition(50, 50)
            suitIcon:addChild(xuanzhong,50)
            suitIcon.xuanzhong = xuanzhong
        end

        if self._stoneKey == stoneData.key then
            xuanzhong:setVisible(true)
            xuanzhong.stoneData = stoneData
            self._xuanzhong = xuanzhong
        else
            xuanzhong:setVisible(false)
        end

        local clickFlag = false
        local downX, downY
        local posX, posY
        registerTouchEvent(
            suitIcon,
            function(_, x, y)
                downY = y
                clickFlag = false
                -- suitIcon:setBrightness(40)
            end, 
            function(_, x, y)
                if downY and math.abs(downY - y) > 5 then
                    clickFlag = true
                end
            end, 
            function(_, x, y)
                -- suitIcon:setBrightness(0)
                if clickFlag == false then 
                    print("stoneData=======" .. stoneData.key, stoneData.id)
                    local tsec = self._xuanzhong
                    if tsec then
                        tsec:setVisible(false)
                        tsec.stoneData = nil 
                    end
                    if xuanzhong then
                        xuanzhong:setVisible(true)
                        xuanzhong.stoneData = stoneData
                        self._xuanzhong = xuanzhong
                        self._stoneKey = stoneData.key
                        self:updateRightStone()
                        -- self:updateLeftPanel(stoneData)  
                        -- if self._stoneKey then
                        --     self._replaceBtn:setSaturation(0) 
                        -- end
                    end
                end
            end,
            function(_, x, y)
                -- suitIcon:setBrightness(0)
            end)
        suitIcon:setSwallowTouches(false)
    else
        if suitIcon then
            suitIcon:setVisible(false)
        end
    end
end

function TeamHolyReplaceDialog:selectStone(inView)
    local suitIcon = inView["suitIcon" .. verticalId]

end

function TeamHolyReplaceDialog:updateSuitCell(inView, indexId)
    local suitData = self._tableData[indexId]
    local suitId = suitData.key

    local suitIcon = inView["suitIcon"]
    local suitTab = tab.runeClient[suitId]

    local tname = inView:getChildByFullName("tname")
    if tname then
        local str = lang(suitTab.name)
        tname:setString(str)
    end
    local tnum = inView:getChildByFullName("tnum")
    local suitNum = self._teamModel:getShowHolyData(suitId)
    if tnum then
        local str = "拥有: " .. table.nums(suitNum)
        tnum:setString(str)
    end

    local param = {suitData = suitTab}
    if not suitIcon then
        suitIcon = IconUtils:createHolyIconById(param)
        suitIcon:setScale(0.6)
        suitIcon:setPosition(75, 7)
        inView:addChild(suitIcon, 20)
        inView["suitIcon"] = suitIcon
    else
        IconUtils:updateHolyIcon(suitIcon, param)
    end

    if table.nums(suitNum) ~= 0 then
        inView:setSaturation(0)
        local clickFlag = false
        local downX, downY
        local posX, posY
        registerTouchEvent(
            inView,
            function(_, x, y)
                downY = y
                clickFlag = false
                -- suitIcon:setBrightness(40)
            end, 
            function(_, x, y)
                if downY and math.abs(downY - y) > 5 then
                    clickFlag = true
                end
            end, 
            function(_, x, y)
                -- suitIcon:setBrightness(0)
                if clickFlag == false then 
                    print("self._holyId===========", self._selectIndex)
                    self._selectSuitId = suitId
                    self._selectIndex = 2
                    self._backBtn:setVisible(true)
                    -- self._tableData = suitNum
                    -- self._tableView:reloadData()
                    self:reloadData()
                end
            end,
            function(_, x, y)
                -- suitIcon:setBrightness(0)
            end)
        inView:setSwallowTouches(false)
    else
        inView:setSaturation(-100)
        local clickFlag = false
        local downX, downY
        local posX, posY
        registerTouchEvent(
            inView,
            function(_, x, y)
                downY = y
                clickFlag = false
                -- suitIcon:setBrightness(40)
            end, 
            function(_, x, y)
                if downY and math.abs(downY - y) > 5 then
                    clickFlag = true
                end
            end, 
            function(_, x, y)
                -- suitIcon:setBrightness(0)
                if clickFlag == false then 
                    self._viewMgr:showTip("没有该装备")
                end
            end,
            function(_, x, y)
                -- suitIcon:setBrightness(0)
            end)
        inView:setSwallowTouches(false)
    end

    -- self:registerClickEvent(inView, function()
    --     self._selectIndex = 2
    --     self._backBtn:setVisible(true)
    --     self._tableData = suitNum
    --     self._tableView:reloadData()
    -- end)

    -- local clickFlag = false
    -- local downX, downY
    -- local posX, posY
    -- registerTouchEvent(
    --     inView,
    --     function(_, x, y)
    --         downY = y
    --         clickFlag = false
    --         -- suitIcon:setBrightness(40)
    --     end, 
    --     function(_, x, y)
    --         if downY and math.abs(downY - y) > 5 then
    --             clickFlag = true
    --         end
    --     end, 
    --     function(_, x, y)
    --         -- suitIcon:setBrightness(0)
    --         if clickFlag == false then 
    --             print("self._holyId===========", self._selectIndex)
    --             self._selectIndex = 2
    --             self._backBtn:setVisible(true)
    --             self._tableData = suitNum
    --             self._tableView:reloadData()
    --         end
    --     end,
    --     function(_, x, y)
    --         -- suitIcon:setBrightness(0)
    --     end)
    -- inView:setSwallowTouches(false)
    -- suitIcon:setSwallowTouches(false)
end

function TeamHolyReplaceDialog:initTabView()
    self._selectIndex = 1
    self._backBtn:setVisible(false)
    self:reloadData()
end

function TeamHolyReplaceDialog:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"RuneCoin","Gold","Gem"},titleTxt = "圣徽"})
end

function TeamHolyReplaceDialog:getBgName()
    return "bg_012.jpg"
end


return TeamHolyReplaceDialog