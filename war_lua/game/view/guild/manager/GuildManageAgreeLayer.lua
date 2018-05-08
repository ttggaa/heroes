--[[
    Filename:    GuildManageAgreeLayer.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 17:02:59
    Description: File description
--]]

--联盟审核 
local GuildManageAgreeLayer = class("GuildManageAgreeLayer", BasePopView)

function GuildManageAgreeLayer:ctor(param)
    GuildManageAgreeLayer.super.ctor(self)
    self._callback = param.callback
    self._callback1 = param.callback1
    self._allianceData = {}
    self._userModel = self._modelMgr:getModel("UserModel")
    self._maxLevel = tab:Setting("MAX_LV").value
    self._maxLevel = tonumber(self._maxLevel) or 80
end

function GuildManageAgreeLayer:onInit()
    self._title = self:getUI("bg.bg.titleBg.title")
    -- UIUtils:setTitleFormat(self._title, 4)

    local title = self:getUI("bg.leftLayer.xuanyanBg.titleBg.title")
    UIUtils:setTitleFormat(title, 3, 1)
    local title = self:getUI("bg.leftLayer.shenpiBg.titleBg.title")
    UIUtils:setTitleFormat(title, 3, 1)

    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.manager.GuildManageAgreeLayer")
        end
        self._callback1()
        self:close()
    end)

    UIUtils:adjustTitle(self:getUI("bg.leftLayer.Image1"))
    UIUtils:adjustTitle(self:getUI("bg.leftLayer.Image2"))

    -- local label77 = self:getUI("bg.leftLayer.shenpiBg.Label_77")
    -- -- label77:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- local Label_78 = self:getUI("bg.leftLayer.shenpiBg.Label_78")
    -- -- Label_78:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- local value = self:getUI("bg.leftLayer.shenpiBg.levelBg.value")
    -- -- value:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- local value = self:getUI("bg.leftLayer.shenpiBg.needBg.value")
    -- -- value:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)


    self._cell = self:getUI("cell")
    -- local limitBtn = self:getUI("bg.limitBtn")
    -- limitBtn:setTitleFontSize(22)
    -- limitBtn:setTitleColor(cc.c3b(255,255,255))
    -- limitBtn:setTitleFontName(UIUtils.ttfName)
    -- limitBtn:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 255), 2)
    -- self:registerClickEvent(limitBtn, function()
    --     self._viewMgr:showDialog("guild.manager.GuildManageSysDialog", {callback = function(str)
    --         local tishi = self:getUI("bg.tishi")
    --         tishi:setString(str)
    --     end})
    -- end)

    -- local changeDeclare = self:getUI("bg.changeDeclare")
    -- changeDeclare:setTitleFontSize(22)
    -- changeDeclare:setTitleColor(cc.c3b(255,255,255))
    -- changeDeclare:setTitleFontName(UIUtils.ttfName)
    -- changeDeclare:getTitleRenderer():enableOutline(cc.c4b(60, 30, 10, 255), 2)
    -- self:registerClickEvent(changeDeclare, function()
    --     self._viewMgr:showDialog("guild.manager.GuildChangeDeclareDialog")
    -- end)

    -- 清空列表
    local allRejectBtn = self:getUI("bg.allRejectBtn")
    self:registerClickEvent(allRejectBtn, function()
        print("+全部拒绝+++++++++++++++++++++++++")
        if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            self._callback1()
            self:close()
            return
        end
        self:allReject()
    end)

    -- 限制设置
    -- self._limitBtn = self:getUI("bg.leftLayer.shenpiBg.limitBtn")
    -- self._limitBtn:setVisible(false)
    -- self:registerClickEvent(self._limitBtn, function()
    --     if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
    --         self._viewMgr:showTip("你已不是联盟管理成员")
    --         self._callback1()
    --         self:close()
    --         return
    --     end
    --     self:setJoinGuildCondition()
    -- end)

    self._changeDeclare = self:getUI("bg.leftLayer.xuanyanBg.changeDeclare")
    -- self._changeDeclare:setVisible(false)

    self._tishi = self:getUI("bg.nothing.tishi")
    self._tishi:setString("还没有申请哦~")
    self._nothing = self:getUI("bg.nothing")
    self._nothing:setVisible(false)

    self:setLevel()
    self:setNeed()
    -- self:updateNothingTishi()

    -- 设置宣言
    self:updateDeclare()
    self:getApplyUserList()
    self:addTableView()
end

function GuildManageAgreeLayer:updateNothingTishi()
    local allianceD = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    local levelLab, needApply
    if allianceD.lvlimit == 0 then
        levelLab = "无限制，"
    else
        levelLab = allianceD.lvlimit .. "级，"
    end
    if allianceD.status == 0 then
        needApply = "自由加入"
    else
        needApply = "需审核"
    end
    local str = "申请限制：" .. levelLab .. needApply
    
    self._tishi:setString(str)
end

function GuildManageAgreeLayer:reflashUI()
    -- 设置审批
    local allianceD = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    local value = self:getUI("bg.leftLayer.shenpiBg.levelBg.value")
    local lastBtn = self:getUI("bg.leftLayer.shenpiBg.levelBg.lastBtn")
    local nextBtn = self:getUI("bg.leftLayer.shenpiBg.levelBg.nextBtn")
    self._tempLevel = allianceD.lvlimit
    value:setString(allianceD.lvlimit)
    if allianceD.lvlimit == 0 then
        lastBtn:setSaturation(-100)
    elseif allianceD.lvlimit == self._maxLevel then
        nextBtn:setSaturation(-100)
    end
    local value = self:getUI("bg.leftLayer.shenpiBg.needBg.value")
    if allianceD.status == 1 then
        value:setString("需要")
        self._tempValue = 1
    else
        value:setString("无需")
        self._tempValue = 0
    end

end 

function GuildManageAgreeLayer:setLevel()
    local lastBtn = self:getUI("bg.leftLayer.shenpiBg.levelBg.lastBtn")
    local nextBtn = self:getUI("bg.leftLayer.shenpiBg.levelBg.nextBtn")
    local value = self:getUI("bg.leftLayer.shenpiBg.levelBg.value")
    self:registerClickEvent(lastBtn, function()
        if tonumber(value:getString()) - 5 < 25 then
            value:setString(tonumber(0))
            lastBtn:setSaturation(-100)
        elseif tonumber(value:getString()) - 5 >= 25 then
            value:setString(tonumber(value:getString()) - 5)
            nextBtn:setSaturation(0)
        else
            lastBtn:setSaturation(-100)
        end
        -- self._limitBtn:setVisible(true)
        self._tempLevel = tonumber(value:getString())
    end)
    self:registerClickEvent(nextBtn, function()
        if tonumber(value:getString()) + 5 <= 25 then
            value:setString(25)
            lastBtn:setSaturation(0)
        elseif tonumber(value:getString()) + 5 <= self._maxLevel then
            value:setString(tonumber(value:getString()) + 5)
            lastBtn:setSaturation(0)
            if tonumber(value:getString()) == self._maxLevel then
                nextBtn:setSaturation(-100)
            end
        else
            nextBtn:setSaturation(-100)
        end
        -- self._limitBtn:setVisible(true)
        self._tempLevel = tonumber(value:getString())
    end)
end 

function GuildManageAgreeLayer:setNeed()
    local lastBtn = self:getUI("bg.leftLayer.shenpiBg.needBg.lastBtn")
    local nextBtn = self:getUI("bg.leftLayer.shenpiBg.needBg.nextBtn")
    local value = self:getUI("bg.leftLayer.shenpiBg.needBg.value")
    self:registerClickEvent(lastBtn, function()
        -- print ("================")
        if self._tempValue == 0 then
            value:setString("需要")
            self._tempValue = 1
        else
            value:setString("无需")
            self._tempValue = 0 
        end
        -- self._limitBtn:setVisible(true)
    end)
    self:registerClickEvent(nextBtn, function()
        -- print ("================")
        if self._tempValue == 1 then
            value:setString("无需")
            self._tempValue = 0
        else
            value:setString("需要")
            self._tempValue = 1
        end
        -- self._limitBtn:setVisible(true)
    end)
end 

function GuildManageAgreeLayer:setJoinGuildCondition()
    -- print ("==GuildManageAgreeLayer=======",self._tempValue, self._tempLevel, type(self._tempLevel))
    local param = {status = self._tempValue, levelLimit = self._tempLevel}
    local levelLab, needApply
    if self._tempLevel == 0 then
        levelLab = ""
    else
        levelLab = self._tempLevel .. "级"
    end
    if self._tempValue == 0 then
        needApply = "自由加入"
    else
        needApply = "需审核"
    end
    local str = levelLab .. needApply
    self._serverMgr:sendMsg("GuildServer", "setJoinGuildCondition", param, true, {}, function(result)
        local guildData = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
        if result["lvlimit"] then
            guildData["lvlimit"] = result["lvlimit"]
        end
        if result["status"] then
            guildData["status"] = result["status"]
        end
        self._callback(str)
        -- self._limitBtn:setVisible(false)
        -- self._tishi:setString(str)
        -- self:setJoinGuildConditionFinish(result)
    end)
end 

function GuildManageAgreeLayer:updateDeclare()
    local allianceD = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    dump(allianceD)
    local declareDes = self:getUI("bg.leftLayer.xuanyanBg.declareDes")
    declareDes:setPlaceHolderColor(cc.c4b(120,120,120,255))
    self._sloganLabel = declareDes
    if allianceD.declare == nil or allianceD.declare == "" then
        self._sloganLabel:setString(lang("GUIDEDECLA_WORD"))
    else
        self._sloganLabel:setString(allianceD.declare or "")
    end

    self._sloganLabel:setPlaceHolder("请输入宣言！")
    self._sloganLabel:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self._sloganLabel:addEventListener(function(sender, eventType)
            -- print("===================", eventType)
            if eventType == 0 then
                -- event.name = "ATTACH_WITH_IME"
                self._changeDeclare:setVisible(true)
                -- self._sloganLabel:setPlaceHolder("")
            elseif eventType == 1 then
               --  event.name = "DETACH_WITH_IME"
               -- self._sloganLabel:setPlaceHolder("请输入宣言！")
            elseif eventType == 2 then
                -- event.name = "INSERT_TEXT"
                -- self._sloganLabel:setPlaceHolder("请输入宣言！")
                self._sloganLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            elseif eventType == 3 then
                -- event.name = "DELETE_BACKWARD"
                self._sloganLabel:setColor(cc.c3b(70, 40, 0))
                if sender:getString() == nil or sender:getString() == "" then
                    self._sloganLabel:setColor(cc.c3b(255, 255, 255))
                    self._sloganLabel:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
                    self._sloganLabel:setPlaceHolder("请输入联盟宣言")                    
                end 
            end
        end)


    -- 确定按钮
    self:registerClickEvent(self._changeDeclare, function()
        if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            self._callback1()
            self:close()
            return
        end
        local slogan = self._sloganLabel:getString()
        if slogan == "" then
            self._viewMgr:showTip("请输入宣言！")
        elseif utf8.len(slogan) < 2 or utf8.len(slogan) > 40 then
            self._viewMgr:showTip("宣言长度需2~40个字！")
        else
            self:sendSvaeDeclarationMsg(slogan)
            self:setJoinGuildCondition()
        end
    end)
end

function GuildManageAgreeLayer:sendSvaeDeclarationMsg(slogan)
    local msg = slogan--string.urlencode(slogan)
    local param = {content = msg}
    self._serverMgr:sendMsg("GuildServer", "addGuildDeclare", param, true, {}, function(result)
        self._modelMgr:getModel("GuildModel"):updateDeclare(param)
        self._viewMgr:showTip("设置成功！")
        -- self._changeDeclare:setVisible(false)
        -- self._modelMgr:getModel("ArenaModel"):setSlogan(self._sloganLabel:getString())
        -- self:close()
    end, function(errorId)
        if tonumber(errorId) == 125 then
            self._viewMgr:showTip("只能为中文、英文、数字")
        elseif tonumber(errorId) == 126 then
            self._viewMgr:showTip("字符串长度不足")
        elseif tonumber(errorId) == 127 then
            self._viewMgr:showTip("字符串长度超出限制")
        elseif tonumber(errorId) == 117 or tonumber(errorId) == 107 then
            self._viewMgr:showTip("输入内容含有非法字符")
        end
    end)
end


function GuildManageAgreeLayer:updateCell(inView, data, indexId)
    if data == nil then
        return
    end
    -- dump(data,"data ====================")
    local iconBg = inView:getChildByFullName("iconBg")
    if iconBg then
        local param1 = {avatar = data.avatar, tp = 4,avatarFrame = data["avatarFrame"]}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setScale(0.8)
            icon:setName("icon")
            -- icon:setPosition(cc.p(-5,-5))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(data.name)
    end

    
    
    local vipImg = inView:getChildByFullName("vipImg")
    if vipImg and data.vipLvl then
        if data.vipLvl == 0 then
            vipImg:setVisible(false)
        else
            vipImg:setVisible(true)
        end
        -- vipImg:setString("V" .. data.vipLvl)  
        vipImg:loadTexture("chatPri_vipLv" .. math.max(1, data.vipLvl) .. ".png", 1)
        -- vipLab:setPositionX(level:getPositionX() + level:getContentSize().width + 5)
    end

    -- local vipLab = inView:getChildByFullName("vipLab")
    -- if vipLab then
    --     vipLab:setString("V" .. data.vipLvl)
    --     -- vipLab:setPositionX(name:getPositionX() + name:getContentSize().width + 5)
    --     if data.vipLvl == 0 then
    --         vipLab:setVisible(false)
    --     else
    --         vipLab:setVisible(true)
    --     end
    -- end

    local level = inView:getChildByFullName("level")
    if level then
        level:setString("Lv. " .. data.lvl)
    end

    local applyTime = inView:getChildByFullName("applyTime")
    if applyTime then
        applyTime:setString(GuildUtils:getDisTodayTime(data.applyTime))
    end

    local reject = inView:getChildByFullName("reject")
    if reject then
        self:registerClickEvent(reject, function()
            local param = {defId = data.memberId, type = 0}
            self:approval(param, indexId)
            print("+++拒绝+++++++++++++++++++++++")
        end)
    end

    local apply = inView:getChildByFullName("apply")
    if apply then
        self:registerClickEvent(apply, function()
            local param = {defId = data.memberId, type = 1}
            self._modelMgr:getModel("GuildModel"):setGuildTempData(true)
            self:approval(param, indexId)
            print("+同意+++++++++++++++++++++++++")
        end)
    end
end

-- 审批玩家
function GuildManageAgreeLayer:approval(param, indexId)
    -- print("载入=============数据====")
    if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] == 3 then
        self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
        self._callback1()
        self:close()
        return
    end
    -- dump(param)
    -- local param = {guildId = guildId}
    self._serverMgr:sendMsg("GuildServer", "approval", param, true, {}, function (result)
        self._allianceData[indexId] = nil
        self:proData()
        -- self:approvalFinish(result)
    end, function(errorId)
        if tonumber(errorId) == 2701 then
            self._viewMgr:showTip("该玩家已加入其他联盟")
            self._allianceData[indexId] = nil
            self:proData()
        elseif tonumber(errorId) == 2711 then
            self._viewMgr:showTip("联盟人数已满")
        elseif tonumber(errorId) == 2713 then
            self._allianceData[indexId] = nil
            self:proData()
            self._viewMgr:showTip("申请列表无此人")
        elseif tonumber(errorId) == 2741 then
            self._allianceData[indexId] = nil
            self:proData()
            self._viewMgr:showTip(lang("GUILD_EXIT_TIPS_3"))
        end
    end)
end 

-- function GuildManageAgreeLayer:approvalFinish(result)
--     if result == nil then 
--         return 
--     end
-- end

function GuildManageAgreeLayer:proData()
    local tempAlliance = {}
    for i,v in pairs(self._allianceData) do
        table.insert(tempAlliance, v)
    end
    self._allianceData = tempAlliance
    if table.nums(self._allianceData) == 0 then
        self._modelMgr:getModel("UserModel"):getData()["guildApply"] = 0
        self._nothing:setVisible(true)
    else
        self._nothing:setVisible(false)
    end
    self._tableView:reloadData()
end

-- 拒绝所有玩家
function GuildManageAgreeLayer:allReject()
    local param = {defId = 0, type = 2}
    self._serverMgr:sendMsg("GuildServer", "approval", param, true, {}, function (result)
        self._modelMgr:getModel("UserModel"):getData()["guildApply"] = 0
        self._allianceData = {}
        if table.nums(self._allianceData) == 0 then
            self._nothing:setVisible(true)
        else
            self._nothing:setVisible(false)
        end
        self._tableView:reloadData()
    end)
end 

-- 申请列表
function GuildManageAgreeLayer:getApplyUserList()
    print("申请列表====")
    -- local param = {guildId = guildId}
    self._serverMgr:sendMsg("GuildServer", "getApplyUserList", {}, true, {}, function (result)
        -- dump(result, "result ==================")
        self._allianceData = result
        if table.nums(self._allianceData) == 0 then
            self._nothing:setVisible(true)
            local userData = self._userModel:getData()
            userData.guildApply = 0
        else
            self._nothing:setVisible(false)
        end
        self._tableView:reloadData()
    end)
end 

--[[
用tableview实现
--]]
function GuildManageAgreeLayer:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function GuildManageAgreeLayer:tableCellTouched(table,cell)
    

    local detailData = self._allianceData[cell:getIdx()+1]
    -- dump(detailData,"detailData==",10)
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = detailData.memberId, fid= 1}, true, {}, function(result) 
        local data = result
        data.score = detailData.score or data.score
        data.lvl = detailData.lvl
        data.memberId = detailData.memberId
        data.hero.heroId = data.formation.heroId
        -- dump(data, "data===",10)
        -- self._viewMgr:showDialog("arena.GuildPlayerDialog",data,true)
        self._viewMgr:showDialog("guild.dialog.GuildPlayerDialog", {detailData = data, callback = function(param, indexId)
            if param.type == 1 then
                self._modelMgr:getModel("GuildModel"):setGuildTempData(true)
            end
            print("indexId =============", indexId)
            self:approval(param, indexId)
        end,proId = cell:getIdx()+1, dataType = 2}, true)
    end) 
end

-- cell的尺寸大小
function GuildManageAgreeLayer:cellSizeForTable(table,idx) 
    local width = 522 
    local height = 110
    return height, width
end

-- 创建在某个位置的cell
function GuildManageAgreeLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._allianceData[idx + 1] -- {typeId = 3, id = 1}
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local agreeCell = self._cell:clone() -- self._viewMgr:createLayer("guild.GuildInCell")
        agreeCell:setAnchorPoint(cc.p(0,0))
        agreeCell:setPosition(cc.p(0,0))
        agreeCell:setName("agreeCell")
        cell:addChild(agreeCell)

        local name = agreeCell:getChildByFullName("name")
        -- UIUtils:setTitleFormat(name, 2, 1)

        local nameBg = agreeCell:getChildByFullName("nameBg")
        -- nameBg:setOpacity(100)

        local level = agreeCell:getChildByFullName("level")
        level:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- level:setFontName(UIUtils.ttfName)
        -- level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local applyTime = agreeCell:getChildByFullName("applyTime")
        applyTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        -- local vipLab = agreeCell:getChildByFullName("vipLab")
        -- vipLab:setFntFile(UIUtils.bmfName_vip)

        local reject = agreeCell:getChildByFullName("reject")
        UIUtils:setButtonFormat(reject, 4)
        local apply = agreeCell:getChildByFullName("apply")
        UIUtils:setButtonFormat(apply, 3)


        self:updateCell(agreeCell, param, indexId)
        agreeCell:setSwallowTouches(false)
    else
        local agreeCell = cell:getChildByName("agreeCell")
        if agreeCell then
            self:updateCell(agreeCell, param, indexId)
            agreeCell:setSwallowTouches(false)
        end
    end
    return cell
end

-- 返回cell的数量
function GuildManageAgreeLayer:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function GuildManageAgreeLayer:tableNum()
    return table.nums(self._allianceData)
end


return GuildManageAgreeLayer
