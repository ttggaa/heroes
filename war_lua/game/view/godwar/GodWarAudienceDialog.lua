--[[
    Filename:    GodWarAudienceDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-17 11:23:31
    Description: File description
--]]


-- 入围名单
local GodWarAudienceDialog = class("GodWarAudienceDialog", BasePopView)
local groupImg = {
    [1] = "godwarImageUI_img209.png",
    [2] = "godwarImageUI_img210.png",
    [3] = "godwarImageUI_img211.png",
    [4] = "godwarImageUI_img212.png",
    [5] = "godwarImageUI_img213.png",
    [6] = "godwarImageUI_img214.png",
    [7] = "godwarImageUI_img215.png",
    [8] = "godwarImageUI_img216.png",
}

function GodWarAudienceDialog:getAsyncRes()
    return {
        -- {"asset/ui/godwar1.plist", "asset/ui/godwar1.png"},
        {"asset/ui/godwar2.plist", "asset/ui/godwar2.png"},
    }
end

function GodWarAudienceDialog:ctor(param)
    GodWarAudienceDialog.super.ctor(self)
    self._callback = param.callback
    self._gtype = param.gtype or 2
end

function GodWarAudienceDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarAudienceDialog")
        end
        if self._callback then
            self._callback()
        end
        if self.parentView:getClassName() == "godwar.GodWarView" then
            self.dontRemoveRes = true
        end
        self:close()
    end)  

    self:getPowBattle()

    local tableViewBg = self:getUI("bg.tableViewBg")
    local mc1 = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    mc1:setPosition(tableViewBg:getContentSize().width-10, tableViewBg:getContentSize().height*0.5)
    tableViewBg:addChild(mc1, 20)
    self._up = mc1

    local mc2 = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    mc2:setPosition(10, tableViewBg:getContentSize().height*0.5)
    tableViewBg:addChild(mc2, 20)
    self._down = mc2

    self._powImg = self:getUI("bg.powImg")
    self._qizibg = self:getUI("bg.layerBg.qizibg")

    
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._userId = self._userModel:getData()._id
    local layerBg = self:getUI("bg.layerBg")
    layerBg:loadTexture("asset/bg/bg_godwar_011.jpg", 0)
    self._godWarModel:setShowType(self._gtype)

    self._headCell1 = self:getUI("headCell1")
    self._headCell1:setVisible(false)

    self._headCell = self:getUI("headCell")
    self._headCell:setVisible(false)
    self._person = self._godWarModel:getShowPlayer()

    local flag = false -- self._godWarModel:isMyJoin()
    if flag == true then
        local tableViewBg = self:getUI("bg.playerSelf.tableViewBg")
        tableViewBg:setVisible(true)
        self:addTableView(tableViewBg)
        local player = self:getUI("bg.playerSelf.player")
        player:setVisible(true)
        self:updateCell(player, self._userId, -1)
        local tableViewBg = self:getUI("bg.tableViewBg")
        tableViewBg:setVisible(false)
    else
        local tableViewBg = self:getUI("bg.playerSelf.tableViewBg")
        tableViewBg:setVisible(false)
        local player = self:getUI("bg.playerSelf.player")
        player:setVisible(false)
        local tableViewBg = self:getUI("bg.tableViewBg")
        tableViewBg:setVisible(true)
        self:addTableView(tableViewBg)
    end

end

-- 周二展示数据
function GodWarAudienceDialog:getgroupData()
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
function GodWarAudienceDialog:scrollToNext()
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

function GodWarAudienceDialog:updateEight()
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
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"]}
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
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"]}
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

function GodWarAudienceDialog:updateFour()
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
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"]}
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
                local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"]}
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

function GodWarAudienceDialog:getPowBattle()
    print("result==============")
    self._serverMgr:sendMsg("GodWarServer", "getPowBattle", {}, true, {}, function (result)
        -- dump(result)
        self:reflashUI()
    end)
end


function GodWarAudienceDialog:reflashUI()
    self._person = {}
    local desc = lang("zhushenzhizhan_1")
    print("gtype=====6666666666666666======", self._gtype)
    if self._gtype == 2 then -- 周一
        self._powImg:loadTexture("godwarImageUI_img205.png", 1)
        self._qizibg:loadTexture("godwarImageUI_img219.png", 1)
        self._person = self._modelMgr:getModel("GodWarModel"):getShowPlayer()
        self._tableView:reloadData()
    elseif self._gtype == 4 then -- 周二
        self._powImg:loadTexture("godwarImageUI_img208.png", 1)
        self._qizibg:loadTexture("godwarImageUI_img219.png", 1)
        self._person = self:getgroupData()
        self._tableView:reloadData()
        self:scrollToNext()
        desc = lang("zhushenzhizhan_2")
    elseif self._gtype == 5 then -- 周三
        self._powImg:loadTexture("godwarImageUI_img204.png", 1)
        self._qizibg:loadTexture("godwarImageUI_img218.png", 1)
        local tableViewBg = self:getUI("bg.tableViewBg")
        tableViewBg:setVisible(false)
        desc = lang("zhushenzhizhan_3")
        self:updateEight()
    elseif self._gtype == 6 then -- 周四
        self._powImg:loadTexture("godwarImageUI_img207.png", 1)
        self._qizibg:loadTexture("godwarImageUI_img217.png", 1)
        local tableViewBg = self:getUI("bg.tableViewBg")
        tableViewBg:setVisible(false)
        desc = lang("zhushenzhizhan_4")
        self:updateFour()
    end

    local richtextBg = self:getUI("bg.richtextBg")
    if not string.find(desc, "color=") then
        desc = "[color=645252,fontsize=22]" .. desc .. "[-]" 
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
    function GodWarAudienceDialog:addTableView(tableViewBg)
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
        self._tableView:setBounceable(true)
        if self._tableView.setDragSlideable ~= nil then 
            self._tableView:setDragSlideable(true)
        end
        tableViewBg:addChild(self._tableView)
    end

    -- 判断是否滑动到结束
    function GodWarAudienceDialog:scrollViewDidScroll(view)
        self._inScrolling = view:isDragging()
        local tempPos = view:getContentSize().width + view:getContainer():getPositionX()
        -- print("==============",tempPos, view:getContainer():getPositionX(), view:getContentSize().width)
        -- down left
        -- up   right
        if view:getContainer():getPositionX() == 0 then
            if view:getContentSize().width < 960 then
                self._up:setVisible(false)
                self._down:setVisible(false)
            else
                self._up:setVisible(true)
                self._down:setVisible(false)
            end
        elseif tempPos <= 800 then
            if view:getContentSize().width < 960 then
                self._up:setVisible(false)
                self._down:setVisible(false)
            else
                self._up:setVisible(false)
                self._down:setVisible(true)
            end
        elseif tempPos == 1036 then
            if view:getContentSize().width < 960 then
                self._up:setVisible(false)
                self._down:setVisible(false)
            else
                self._up:setVisible(false)
                self._down:setVisible(true)
            end
        elseif view:getContentSize().width > 960 then
            self._up:setVisible(true)
            self._down:setVisible(true)
        end
    end


    -- cell的尺寸大小
    function GodWarAudienceDialog:cellSizeForTable(table,idx) 
        local width = 110 
        local height = 102
        return height, width
    end

    -- 创建在某个位置的cell
    function GodWarAudienceDialog:tableCellAtIndex(table, idx)
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
    function GodWarAudienceDialog:numberOfCellsInTableView(table)
        return self:getTableNum() -- 20 -- #self._technology --table.nums(self._membersData)
    end

    function GodWarAudienceDialog:getTableNum()
        return table.nums(self._person) 
    end

    function GodWarAudienceDialog:updateCell(inView, data, indexId)
        local playData = self._godWarModel:getPlayerById(data)
        if not playData then
            return
        end
        -- dump(playData)
        -- print("==play==",indexId, playData.rid,"\t", playData.s)

        local param = {avatar = playData.avatar, level = playData.lvl, tp = 4, avatarFrame = playData["avatarFrame"]}
        local icon = inView:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param)
            icon:setName("icon")
            icon:setScale(0.8)
            icon:setPosition(13,30)
            inView:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param)
        end
        -- if indexId == -1 then
        --     icon:setScale(0.9)
        --     icon:setPosition(cc.p(25,30))
        -- end
        local groupId = inView:getChildByFullName("groupId")
        if groupId then
            groupId:loadTexture(groupImg[playData.gp], 1)
            if self._gtype == 4 then
                groupId:setVisible(true)
            else
                groupId:setVisible(false)
            end
        end
        local playerName = inView:getChildByFullName("name")
        local playSelf = inView:getChildByName("playSelf")
        if playerName then
            playerName:setString(playData.name)
            if self._userId == playData.rid then
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

        -- local clickFlag = false
        -- local downX
        -- local posX, posY
        -- registerTouchEvent(
        --     icon,
        --     function (_, x, y)
        --         downX = y
        --         clickFlag = false
        --     end, 
        --     function (_, x, y)
        --         if downX and math.abs(downX - x) > 5 then
        --             clickFlag = true
        --         end
        --     end, 
        --     function ()
        --         if clickFlag == false then 
        --             local data = {tagId = data, fid = 101}
        --             self:getTargetUserBattleInfo(data)
        --         end
        --     end,
        --     function ()
        --     end)
        icon:setSwallowTouches(false)
    end

function GodWarAudienceDialog:getTargetUserBattleInfo(param)
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result) 
        self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
    end)
end

return GodWarAudienceDialog
