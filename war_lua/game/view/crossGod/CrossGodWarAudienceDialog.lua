--[[
    Filename:    CrossGodWarAudienceDialog.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-29 11:23:31
    Description: File description
--]]


-- 入围名单
local CrossGodWarAudienceDialog = class("CrossGodWarAudienceDialog", BasePopView)

function CrossGodWarAudienceDialog:getAsyncRes()
    return {
        {"asset/ui/crossGodWar.plist", "asset/ui/crossGodWar.png"},
    }
end

function CrossGodWarAudienceDialog:ctor(param)
    CrossGodWarAudienceDialog.super.ctor(self)
    self._btns = {}
    self._tabIndex = 0
    self._person = {}
    self._callback = param.callback
    self.dontRemoveRes = true
end

function CrossGodWarAudienceDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("crossGod.CrossGodWarAudienceDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)  

    self:getPowBattle()

    local tableViewBg = self:getUI("bg.tableViewBg")

    self._powImg = self:getUI("bg.powImg")
    self._qizibg = self:getUI("bg.layerBg.qizibg")

    
    self._crossGodWarModel = self._modelMgr:getModel("CrossGodWarModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._userId = self._userModel:getData()._id
    local layerBg = self:getUI("bg.layerBg")
    layerBg:loadTexture("asset/bg/bg_godwar_011.jpg", 0)

    self._headCell = self:getUI("headCell")
    self._headCell:setVisible(false)

    local tableViewBg = self:getUI("bg.tableViewBg")
    tableViewBg:setVisible(true)
    self:addTableView(tableViewBg)
    self:initTabBtn()
    self:changeBtn(1)
end

function CrossGodWarAudienceDialog:initTabBtn()
    for i=1,8 do
        self._btns[i] = self:getUI("bg.btnPanel.tab"..i)
        self:registerClickEvent(self._btns[i], function ()
            self:changeBtn(i)
        end)
    end
end

function CrossGodWarAudienceDialog:changeBtn( idx )
    if self._tabIndex == idx then
        return
    end
    for i,btn in ipairs(self._btns) do
        if i == idx then
            btn:setEnabled(false)
            btn:setBrightness(0)
        else
            btn:setEnabled(true)
            btn:setBrightness(-40)
        end
    end
    self._tabIndex = idx
    self._person = self._crossGodWarModel:getPlayersByGroup(self._tabIndex)
    self._tableView:reloadData()
end

-- 周二展示数据
function CrossGodWarAudienceDialog:getgroupData()
    local player = self._modelMgr:getModel("GodWarModel"):getPlayer()
    -- dump(player)
    -- player = tempDat
    local tplayer = {}
    local count = 1
    for k,v in pairs(player) do
        v.key = k 
        table.insert(tplayer, v)
    end
    local flag = false
    local sortFunc = function(a, b)
        local asortId = a.gp
        local bsortId = b.gp
        local aScore = a.score
        local bScore = b.score
        if asortId ~= bsortId then
            return asortId < bsortId
        elseif aScore ~= bScore then
            return aScore > bScore
        end
    end
    table.sort(tplayer, sortFunc)

    local tperson = {}
    for i,v in ipairs(tplayer) do
        if v.key == self._userId then
            self._count = i
        end
        table.insert(tperson, v.key)
    end
    dump(tperson)
    return tperson
end

-- 滑动偏移处理
function CrossGodWarAudienceDialog:scrollToNext()
    local selectedIndex = (self._count or 1) - 1
    local tempWidth = 110*(#self._person) 
    local maxWidth = MAX_SCREEN_WIDTH - 70
    if tempWidth < maxWidth then
        self._tableView:setContentOffset(cc.p(0, 0))
    elseif selectedIndex < 0 then
        self._tableView:setContentOffset(cc.p(-(selectedIndex+1)*110, 0))
    else
        if (tempWidth - (selectedIndex)*110) > maxWidth then
            self._tableView:setContentOffset(cc.p(-(selectedIndex)*110, 0))
        else
            self._tableView:setContentOffset(cc.p(-(tempWidth-maxWidth), 0))
        end
    end
end

function CrossGodWarAudienceDialog:updateEight()
    local powData = self._modelMgr:getModel("GodWarModel"):getWarDataById(8)
    -- dump(powData)
    if not powData then
        return
    end
    local tableViewBg1 = self:getUI("bg.tableViewBg1")
    tableViewBg1:setVisible(true)
    for i=1,4 do
        local headCell = self._headCell1:clone() 
        headCell:setVisible(true)
        headCell:setAnchorPoint(0, 0)
        headCell:setScale(0.9)
        headCell:setPosition(210*(i-1) - 25, 3)
        headCell:setName("headCell")
        tableViewBg1:addChild(headCell)

        local indexId = tostring(i)
        local _powData = powData[indexId]
        if _powData then
            local atkId = _powData["atk"]
            local playData = self._godWarModel:getPlayerById(atkId)
            if playData then
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"],plvl = playData["plvl"]}
                local icon = headCell:getChildByName("icon1")
                if not icon then
                    icon = IconUtils:createHeadIconById(param)
                    icon:setName("icon1")
                    icon:setScale(0.8)
                    icon:setPosition(13,26)
                    headCell:addChild(icon)
                else
                    IconUtils:updateHeadIconByView(icon, param)
                end
                
                local playerName = headCell:getChildByFullName("atkname")
                local playSelf = headCell:getChildByName("playSelf1")
                if playerName then
                    playerName:setString(playData.name)
                    print("self._userId == atkId======", self._userId, atkId)
                    if self._userId == atkId then
                        playerName:setColor(cc.c3b(255, 208, 65))
                        if not playSelf then
                            playSelf = cc.Sprite:createWithSpriteFrameName("globalImageUI_selfRedTag.png")
                            playSelf:setName("playSelf1")
                            playSelf:setScale(0.8)
                            playSelf:setPosition(33,75)
                            headCell:addChild(playSelf, 100)
                        else
                            playSelf:setVisible(true)
                        end
                    else
                        playerName:setColor(cc.c3b(252, 244, 197))
                        if playSelf then
                            playSelf:setVisible(false)
                        end
                    end
                end
            end

            local defId = _powData["def"]
            local playData = self._godWarModel:getPlayerById(defId)
            if playData then
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"],plvl = playData["plvl"]}
                local icon = headCell:getChildByName("icon2")
                if not icon then
                    icon = IconUtils:createHeadIconById(param)
                    icon:setName("icon2")
                    icon:setScale(0.8)
                    icon:setPosition(130,26)
                    headCell:addChild(icon)
                else
                    IconUtils:updateHeadIconByView(icon, param)
                end
                
                local playerName = headCell:getChildByFullName("defname")
                local playSelf = headCell:getChildByName("playSelf2")
                if playerName then
                    playerName:setString(playData.name)
                    if self._userId == defId then
                        playerName:setColor(cc.c3b(255, 208, 65))
                        if not playSelf then
                            playSelf = cc.Sprite:createWithSpriteFrameName("globalImageUI_selfRedTag.png")
                            playSelf:setName("playSelf2")
                            playSelf:setScale(0.8)
                            playSelf:setPosition(153,75)
                            headCell:addChild(playSelf, 10)
                        else
                            playSelf:setVisible(true)
                        end
                    else
                        playerName:setColor(cc.c3b(252, 244, 197))
                        if playSelf then
                            playSelf:setVisible(false)
                        end
                    end
                end
            end
        end
    end
end

function CrossGodWarAudienceDialog:updateFour()
    local powData = self._modelMgr:getModel("GodWarModel"):getWarDataById(4)
    if not powData then
        return
    end

    local tableViewBg1 = self:getUI("bg.tableViewBg1")
    tableViewBg1:setVisible(true)
    for i=1,2 do
        local headCell = self._headCell1:clone() 
        headCell:setVisible(true)
        headCell:setAnchorPoint(0, 0)
        headCell:setPosition(600*(i-1) - 10, 3)
        headCell:setName("headCell")
        tableViewBg1:addChild(headCell)

        local indexId = tostring(i)
        local _powData = powData[indexId]
        if _powData then
            local atkId = _powData["atk"]
            local playData = self._godWarModel:getPlayerById(atkId)
            if playData then
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"],plvl = playData["plvl"]}
                local icon = headCell:getChildByName("icon1")
                if not icon then
                    icon = IconUtils:createHeadIconById(param)
                    icon:setName("icon1")
                    icon:setScale(0.8)
                    icon:setPosition(13,26)
                    headCell:addChild(icon)
                else
                    IconUtils:updateHeadIconByView(icon, param)
                end
                
                local playerName = headCell:getChildByFullName("atkname")
                local playSelf = headCell:getChildByName("playSelf1")
                if playerName then
                    playerName:setString(playData.name)
                    if self._userId == atkId then
                        playerName:setColor(cc.c3b(255, 208, 65))
                        if not playSelf then
                            playSelf = cc.Sprite:createWithSpriteFrameName("globalImageUI_selfRedTag.png")
                            playSelf:setName("playSelf1")
                            playSelf:setScale(0.8)
                            playSelf:setPosition(33,75)
                            headCell:addChild(playSelf, 10)
                        else
                            playSelf:setVisible(true)
                        end
                    else
                        playerName:setColor(cc.c3b(252, 244, 197))
                        if playSelf then
                            playSelf:setVisible(false)
                        end
                    end
                end
            end

            local defId = _powData["def"]
            local playData = self._godWarModel:getPlayerById(defId)
            if playData then
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"],plvl = playData["plvl"]}
                local icon = headCell:getChildByName("icon2")
                if not icon then
                    icon = IconUtils:createHeadIconById(param)
                    icon:setName("icon2")
                    icon:setScale(0.8)
                    icon:setPosition(130,26)
                    headCell:addChild(icon)
                else
                    IconUtils:updateHeadIconByView(icon, param)
                end
                
                local playerName = headCell:getChildByFullName("defname")
                local playSelf = headCell:getChildByName("playSelf2")
                if playerName then
                    playerName:setString(playData.name)
                    if self._userId == defId then
                        playerName:setColor(cc.c3b(255, 208, 65))
                        if not playSelf then
                            playSelf = cc.Sprite:createWithSpriteFrameName("globalImageUI_selfRedTag.png")
                            playSelf:setName("playSelf2")
                            playSelf:setScale(0.8)
                            playSelf:setPosition(33,75)
                            headCell:addChild(playSelf, 10)
                        else
                            playSelf:setVisible(true)
                        end
                    else
                        playerName:setColor(cc.c3b(252, 244, 197))
                        if playSelf then
                            playSelf:setVisible(false)
                        end
                    end
                end
            end
        end
    end
end

function CrossGodWarAudienceDialog:getPowBattle()
    print("result==============")
    self._serverMgr:sendMsg("GodWarServer", "getPowBattle", {}, true, {}, function (result)
        -- dump(result)
        self:reflashUI()
    end)
end


function CrossGodWarAudienceDialog:reflashUI()
    self._person = {}
    desc = lang("crossFight_tips_17")
    local richtextBg = self:getUI("bg.richtextBg")
    if not string.find(desc, "color=") then
        desc = "[color=f7fedd,fontsize=22]" .. desc .. "[-]" 
    end
    local richText = richtextBg:getChildByName("richText")
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)
end

-- 左侧列表
--[[
用tableview实现
--]]
    function CrossGodWarAudienceDialog:addTableView(tableViewBg)
        self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
        -- self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self._tableView:setDelegate()
        self._tableView:setAnchorPoint(cc.p(0, 0))
        self._tableView:setPosition(0, 0)
        self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
        self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
        self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
        self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._tableView:setBounceable(false)
        if self._tableView.setDragSlideable ~= nil then 
            self._tableView:setDragSlideable(true)
        end
        tableViewBg:addChild(self._tableView)
    end

    -- 判断是否滑动到结束
    function CrossGodWarAudienceDialog:scrollViewDidScroll(view)
        self._inScrolling = view:isDragging()
        local tempPos = view:getContentSize().width + view:getContainer():getPositionX()
    end


    -- cell的尺寸大小
    function CrossGodWarAudienceDialog:cellSizeForTable(table,idx) 
        local width = 100 
        local height = 100
        return height, width
    end

    -- 创建在某个位置的cell
    function CrossGodWarAudienceDialog:tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local indexId = idx + 1 -- self:TableNum() - idx
        local param = self._person[indexId]
        if nil == cell then
            cell = cc.TableViewCell:new()
            local headCell = self._headCell:clone() 
            headCell:setVisible(true)
            headCell:setAnchorPoint(0, 0)
            headCell:setPosition(10, 3)
            headCell:setName("headCell")
            cell:addChild(headCell)

            -- local donateBtn = headCell:getChildByFullName("donateBtn")
            -- donateBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 1)  
        end
        local headCell = cell:getChildByName("headCell")
        if headCell then
            self:updateCell(headCell, param, indexId)
            headCell:setSwallowTouches(false)
        end
        return cell
    end

    -- 返回cell的数量
    function CrossGodWarAudienceDialog:numberOfCellsInTableView(table)
        return self:getTableNum() 
    end

    function CrossGodWarAudienceDialog:getTableNum()
        return table.nums(self._person) 
    end

    function CrossGodWarAudienceDialog:updateCell(inView, playData, indexId)
        if not playData then
            return
        end

        local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"],plvl = playData["plvl"]}
        local icon = inView:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param)
            icon:setName("icon")
            icon:setScale(0.8)
            icon:setPosition(13,20)
            inView:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param)
        end
        local playerName = inView:getChildByFullName("name")
        local playSelf = inView:getChildByName("playSelf")
        if playerName then
            playerName:setString(playData.name)
            if self._userId == playData.playerId then
                playerName:setColor(cc.c3b(255, 208, 65))
                if not playSelf then
                    playSelf = cc.Sprite:createWithSpriteFrameName("globalImageUI_selfRedTag.png")
                    playSelf:setName("playSelf")
                    playSelf:setScale(0.8)
                    playSelf:setPosition(33,75)
                    inView:addChild(playSelf, 10)
                else
                    playSelf:setVisible(true)
                end
            else
                playerName:setColor(cc.c3b(252, 244, 197))
                if playSelf then
                    playSelf:setVisible(false)
                end
            end
        end
        icon:setSwallowTouches(false)
    end

function CrossGodWarAudienceDialog:getTargetUserBattleInfo(param)
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
        self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
    end)
end

return CrossGodWarAudienceDialog
