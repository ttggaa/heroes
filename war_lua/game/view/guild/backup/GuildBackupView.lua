--[[
    Filename:    GuildBackupView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-26 16:52:32
    Description: File description
--]]

-- 增援系统
-- 联盟捐献选择
local GuildBackupView = class("GuildBackupView", BaseView, require("game.view.guild.GuildBaseView"))

function GuildBackupView:ctor(data)
    GuildBackupView.super.ctor(self)
    self.initAnimType = 3
    self._duringXuYuan = nil
end


function GuildBackupView:onInit()
    local bg = self:getUI("bg")
    local closeBtn = self:getUI("bg.closeBtn")
    closeBtn:setVisible(false)
    self:registerClickEvent(closeBtn, function()
        self:close()
    end)

    -- local des1 = self:getUI("bg.titleBg.des1")
    -- des1:setColor(cc.c3b(203,133,63))
    -- local des2 = self:getUI("bg.titleBg.des2")
    -- des2:setColor(cc.c3b(203,133,63))
    -- local des3 = self:getUI("bg.titleBg.des3")
    -- des3:setColor(cc.c3b(203,133,63))

    local des1 = self:getUI("bg.titleBg.des1")
    -- des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local des3 = self:getUI("bg.titleBg.des3")
    -- des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local timeLab = self:getUI("bg.titleBg.timeLab")
    -- timeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._timesValue = self:getUI("bg.titleBg.timesValue")
    -- self._timesValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._gemvalue = self:getUI("bg.titleBg.gemvalue")
    -- self._gemvalue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._gemvalue:setVisible(false)
    local gem = self:getUI("bg.titleBg.gem")
    gem:setVisible(false)
    self._allianceValue = self:getUI("bg.titleBg.allianceValue")
    self._allianceValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._timeLab = self:getUI("bg.titleBg.timeLab")
    self._request = self:getUI("bg.titleBg.request")
    self._detailCell = self:getUI("detailCell")

    -- self:reflashUI()
    self:addTableView()

    self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
    self:listenReflash("UserModel", self.reflashQuitAlliance)
    -- self:listenReflash("GuildModel", self.reflashUI)
    self:addAnimBg()

    self._playAnimBg = self:getUI("bg.bg")
    self._playAnimBgOffX = 0
    self._playAnimBgOffY = -17
end

function GuildBackupView:reflashUI(data)
    -- self._tableView:reloadData()
    -- dump(self._backupData)
    local nothing = self:getUI("bg.bg.nothing")
    -- local tableViewBg = self:getUI("bg.bg.tableViewBg")
    if table.nums(self._backupData) ~= 0 then
        -- tableViewBg:setVisible(true)
        nothing:setVisible(false)
    else
        nothing:setVisible(true)
        -- tableViewBg:setVisible(false)
    end
    local guildBackup = self._modelMgr:getModel("UserModel"):getData()["guildBackup"]
    -- dump(guildBackup)
    if not guildBackup.donateTimes then
        guildBackup.donateTimes = 0
    end
    if not guildBackup.askCD then
        guildBackup.askCD = 0
    end
    local times = self._modelMgr:getModel("GuildModel"):getHelpTimes()
    local leftTimes = math.max(0,times - guildBackup.donateTimes)
    self._timesValue:setString(leftTimes .. "/" .. times)
    local guildHelpAward = tab:Setting("G_GUILD_HELP_AWARD").value

    -- local gem = self:getUI("bg.titleBg.gem")
    -- local des3 = self:getUI("bg.titleBg.des3")
    -- if guildHelpAward[1] then
    --     self._gemvalue:setString(guildHelpAward[1][3])
    --     self._gemvalue:setVisible(true)
    --     -- gem:setVisible(true)
    -- else
    --     self._gemvalue:setVisible(false)
    --     -- gem:setVisible(false)
    -- end

    -- if guildHelpAward[1] then
    --     self._allianceValue:setString(guildHelpAward[1][3])
    --     self._allianceValue:setVisible(false)
    -- else
    --     self._allianceValue:setVisible(false)
    -- end
    
    -- self._timeLab:setString("12:12:12")
    local des3 = self:getUI("bg.titleBg.des3")
    local temptime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
    if guildBackup.askCD - temptime <= 0 then
        self._request:setSaturation(0)
        -- self._request:setEnabled(true)
        self._timeLab:setVisible(false)
        des3:setVisible(false)
        self:registerClickEvent(self._request, function()
            self._viewMgr:showDialog("guild.backup.GuildBackupPreDialog",{callback = function(teamId)
                print("请求支援 ========", teamId)
                self:needBackup(tab:Team(teamId).goods)
            end})
            print("请求支援")
        end)
    else
        self._timeLab:runAction(cc.RepeatForever:create(
            cc.Sequence:create(cc.CallFunc:create(function()
            if not self._timeLab then
                return
            end

            local curServerTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
            local tempTime = guildBackup.askCD - curServerTime
            local hour = math.floor(tempTime/3600)
            tempTime = tempTime - hour*3600
            local minutes = math.floor(tempTime/60)
            tempTime = tempTime - minutes*60
            str = string.format("%.2d:%.2d:%.2d", hour, minutes, tempTime)
            self._timeLab:setString(str)
            if hour == 0 and minutes == 0 and tempTime == 0 then
                self:reflashUI()
            end
        end), cc.DelayTime:create(1))
        ))
        self._timeLab:setVisible(true)
        -- self._request:setEnabled(false)
        des3:setVisible(true)
        self._request:setSaturation(-100)
        self:registerClickEvent(self._request, function()
            self._viewMgr:showTip("冷却时间未到")
        end)
    end

    -- local gem = self:getUI("bg.titleBg.gem")
    local des3 = self:getUI("bg.titleBg.des3")
    local des2 = self:getUI("bg.titleBg.des2")
    local allianceCoin = self:getUI("bg.titleBg.allianceCoin")
    -- self._gemvalue:setPositionX(gem:getPositionX()+gem:getContentSize().width*gem:getScaleX())
    -- allianceCoin:setPositionX(self._gemvalue:getPositionX()+self._gemvalue:getContentSize().width+5)
    allianceCoin:setPositionX(des2:getPositionX()+des2:getContentSize().width+5)
    self._allianceValue:setPositionX(allianceCoin:getPositionX()+allianceCoin:getContentSize().width*allianceCoin:getScaleX())
end

--[[
用tableview实现
--]]
function GuildBackupView:addTableView()
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
function GuildBackupView:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.GuildScienceDetailDialog", {detailData = nil})
end

-- cell的尺寸大小
function GuildBackupView:cellSizeForTable(table,idx) 
    local width = 844 
    local height = 114
    return height, width
end

-- 创建在某个位置的cell
function GuildBackupView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        
        local detailCell = self:getItem(cell)
        self:updateCell(detailCell, indexId)
    else
        print("wo shi shua xin")
        -- local cell_ = cell:getChildByName("detailCell_")
        cell:removeAllChildren()
        local cell_ = self:getItem(cell)
        self:updateCell(cell_, indexId)
    end

    return cell
end

function GuildBackupView:getItem(cell)
    local detailCell = self._detailCell:clone() 
    detailCell:setAnchorPoint(cc.p(0,0))
    detailCell:setPosition(cc.p(0,0))
    -- detailCell:setName("detailCell" .. i)
    cell:addChild(detailCell)
    detailCell:setName("detailCell_")

    local donateBtn = detailCell:getChildByFullName("donateBtn")
    UIUtils:setButtonFormat(donateBtn, 3)
    -- donateBtn:setTitleFontSize(28)
    -- donateBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 1)  

    local cancelBtn = detailCell:getChildByFullName("cancelBtn")
    UIUtils:setButtonFormat(cancelBtn, 4)
    -- cancelBtn:setTitleFontSize(28)
    -- cancelBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 1)

    local name = detailCell:getChildByFullName("name")
    name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    return detailCell
end

-- 返回cell的数量
function GuildBackupView:numberOfCellsInTableView(table)
    return self:cellLineNum() -- #self._backupData -- #self._technology --table.nums(self._membersData)
end

function GuildBackupView:cellLineNum()
    return table.nums(self._backupData)
end

function GuildBackupView:updateCell(cell, indexLine)    

    local detailCell = cell
    local indexId = indexLine
    local userId = self._modelMgr:getModel("UserModel"):getData()._id
    local name = detailCell:getChildByFullName("name")

    local cellData = self._backupData[indexId]
    if userId == cellData["rid"] then
        name:setString("您")
        name:setColor(UIUtils.colorTable.ccUIBaseColor7)
    elseif cellData["rid"] == "" then
        name:setString("联盟")
        name:setColor(UIUtils.colorTable.ccUIBaseColor3)
    else
        name:setString(cellData["name"])
        name:setColor(UIUtils.colorTable.ccUIBaseColor2)
    end

    local awardNum = detailCell:getChildByFullName("awardNum")
    if not tab:Zengyuan(cellData.pieceId) then
        self._viewMgr:showTip("zengyuan表没有配" .. cellData.pieceId)
    else
        awardNum:setString(tab:Zengyuan(cellData.pieceId)["award"][1][3])
    end
    
    local lab1 = detailCell:getChildByFullName("lab1")
    lab1:setPositionX(name:getPositionX()+name:getContentSize().width-2)
    local endtime = detailCell:getChildByFullName("endtime")
    local str
    endtime:runAction(cc.RepeatForever:create(
        cc.Sequence:create(cc.CallFunc:create(function()
        if not endtime then
            return
        end
        local curServerTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
        local tempTime = cellData["expiredTime"] - curServerTime
        local hour = math.floor(tempTime/3600)
        tempTime = tempTime - hour*3600
        local minutes = math.floor(tempTime/60)
        tempTime = tempTime - minutes*60
        str = string.format("%.2d:%.2d:%.2d", hour, minutes, tempTime)
        endtime:setString(str)
        if hour == 0 and minutes == 0 and tempTime == 0 then
            self:delDonateData(indexId)
        end
    end), cc.DelayTime:create(1)) 
    ))

    local roleBg = detailCell:getChildByFullName("roleBg")
    local itemIcon = roleBg:getChildByName("itemIcon")
    local param = {itemId = cellData["pieceId"], eventStyle = 1}
    if itemIcon then
        IconUtils:updateItemIconByView(itemIcon, param)
    else
        itemIcon = IconUtils:createItemIconById(param)
        itemIcon:setName("itemIcon")
        itemIcon:setScale(0.9)
        roleBg:addChild(itemIcon)
    end
    local itemModel = self._modelMgr:getModel("ItemModel")
    local sameSouls, sameSoulCount = itemModel:getItemsById(cellData["pieceId"])
    local teamNum = detailCell:getChildByFullName("teamNum")
    teamNum:setString(sameSoulCount)
    local lab3 = detailCell:getChildByFullName("lab3")
    lab3:setPositionX(teamNum:getPositionX()+teamNum:getContentSize().width)

    local cancelBtn = detailCell:getChildByFullName("cancelBtn")
    local donateBtn = detailCell:getChildByFullName("donateBtn")
    if userId == cellData["rid"] then 
        donateBtn:setVisible(false)
        cancelBtn:setVisible(true)
        -- donateBtn:setSaturation(0)
        cancelBtn:setTitleText("撤销")
        self:registerClickEvent(cancelBtn, function()
            -- self._viewMgr:showTip("您不能对自己进行捐献")
            self:cancleNeedbackup(indexId, cellData["askId"])
            print("撤销增援", cellData["askId"])
        end)
    elseif sameSoulCount == 0 then
        donateBtn:setVisible(true)
        cancelBtn:setVisible(false)
        donateBtn:setSaturation(-100)
        donateBtn:setTitleText("捐赠")
        self:registerClickEvent(donateBtn, function()
            self._viewMgr:showTip("碎片数量不足")
        end)
    else
        donateBtn:setVisible(true)
        cancelBtn:setVisible(false)
        donateBtn:setSaturation(0)
        donateBtn:setTitleText("捐赠")
        self:registerClickEvent(donateBtn, function()
            -- dump(cellData)
            self:donate(indexId, cellData["askId"])
            -- print("进行捐献")
        end)
    end
    local guildBackup = self._modelMgr:getModel("UserModel"):getData()["guildBackup"]
    local times = self._modelMgr:getModel("GuildModel"):getHelpTimes()
    -- dump(guildBackup)
    if userId ~= cellData["rid"] then
        if guildBackup.donateTimes and (times - guildBackup.donateTimes) <= 0 then
            self:registerClickEvent(donateBtn, function()
                self._viewMgr:showTip("捐赠次数不足")
            end)
        end
    end

    if cellData["rid"] == "" then
        local guildBackup = self._modelMgr:getModel("UserModel"):getData()["guildBackup"]
        -- dump(guildBackup,"guildBackup", 20)
        print("=============",  guildBackup[tostring(cellData["askId"])] , cellData["askId"])
        if guildBackup["guildDonate"] and guildBackup["guildDonate"][tostring(cellData["askId"])] == 1 then
            donateBtn:setSaturation(-100)
            donateBtn:setTitleText("已捐赠")
            self:registerClickEvent(donateBtn, function()
                self._viewMgr:showTip("已捐赠")
            end)
        end
    end 
    detailCell:setVisible(true)

    local name 
    local isSys
    if cellData.rid and cellData.rid ~= "" then
        name = cellData.name
    else
        name = "联盟"
        isSys = true
    end

    local avatar = cellData.avatar or 3502
    local avatarFrame = cellData.avatarFrame or 1006
    local lv = cellData.lvl or 10

    local playerName = detailCell:getChildByFullName("senderName")
    playerName:setString(name)

    local playerIcon = detailCell:getChildByFullName("playerIcon")
    -- playerIcon:setScale(1)

    local avatorIcon = playerIcon:getChildByName("avatorIcon")
    local flag = playerIcon:getChildByName("FlagIcon")
    if isSys then
        if avatorIcon then
            -- avatorIcon:removeFromParent()
            avatorIcon:setVisible(false)
        end
        local guildData = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
        local param = {flags = guildData.avatar1, logo = guildData.avatar2}
        if not flag then
            flag = IconUtils:createGuildLogoIconById(param)
            flag:setPosition(0,4)
            flag:setName("FlagIcon")
            flag:setScale(0.60)
            playerIcon:addChild(flag)
        else
            flag:setVisible(true)
            IconUtils:updateGuildLogoIconByView(flag, param)
        end
    else
        if not avatorIcon then
            avatorIcon = IconUtils:createHeadIconById({avatar = avatar,level = lv or "0" ,tp = 4,avatarFrame=avatarFrame}) 
            avatorIcon:setPosition(cc.p(-1,-1))
            playerIcon:addChild(avatorIcon)
            avatorIcon:setName("avatorIcon")
            playerIcon:setScale(0.8)
            -- playerIcon:setPosition(0,4)
        else
            avatorIcon:setVisible(true)
            IconUtils:updateHeadIconByView(avatorIcon,{avatar = avatar,level = lv or "0" ,tp = 4,avatarFrame=avatarFrame})
        end
        if flag then
            -- flag:removeFromParent()
            flag:setVisible(false)
        end
    end
    

    -- for i=1,3 do
    --     local detailCell = cell:getChildByFullName("detailCell" .. i)
    --     if detailCell then
    --         local indexId = (indexLine-1)*3+i
    --         print("indexId===========", indexId)
    --         if self._backupData[indexId] then
                
    --         else
    --             detailCell:setVisible(false)
    --         end
    --     end
    -- end
end

function GuildBackupView:refreshNotReload()
    if self._tableView then
        if not self._firstIn then
            self._firstIn = true
            self._tableView:reloadData()
            print("self._tableView:getContentOffset().y"..self._tableView:getContentOffset().y)
        else
            local currentOff = self._tableView:getContentOffset().y
            self._tableView:reloadData()
            if self._duringXuYuan == true then 
                self._duringXuYuan = nil
                return 
            end
            
            local maxOff = self._tableView:maxContainerOffset().y
            local minOff = self._tableView:minContainerOffset().y

            printf(" minOff == %f , currentOff == %f ,max == %f " ,minOff,currentOff,maxOff)
            local adjustOff 
            if currentOff >=  0 then
                adjustOff = math.max(maxOff,currentOff)
            else
                adjustOff = math.max(minOff,currentOff)
            end
            
            self._tableView:setContentOffset(cc.p(0,adjustOff))
        end
    end
end


function GuildBackupView:delDonateData(indexId)
    -- print("时间为0进行处理")
    table.remove(self._backupData, indexId)
    -- self._tableView:reloadData()
    self:refreshNotReload()
end

function GuildBackupView:addBackup(data)
    print("添加处理")
    table.insert(self._backupData, 1, data)
    self._duringXuYuan = true
    -- self._tableView:reloadData()
    self:refreshNotReload()
end

-- 请求增援
function GuildBackupView:needBackup(teamId)
    self._serverMgr:sendMsg("GuildBackupServer", "needBackup", {pieceId = teamId}, true, {}, function (result)
        dump(result, "result ===")
        self:addBackup(result["addBackup"])
        self:reflashUI()
        self._viewMgr:showTip("许愿成功")
    end)
end

-- 撤销增援
function GuildBackupView:cancleNeedbackup(indexId, askId)
    self._serverMgr:sendMsg("GuildBackupServer", "cancleNeedbackup", {askId = askId}, true, {}, function (result)
        -- dump(result, "result ===")
        self:delDonateData(indexId)
        self:reflashUI()
        self._viewMgr:showTip("撤销许愿成功")
    end, function(errorId)
        if tonumber(errorId) == 2904 then
            self._viewMgr:showTip("该请求不存在")
            self:delDonateData(indexId)
            self:reflashUI()
        end
    end)
end

-- 捐赠
function GuildBackupView:donate(indexId, askId)
    self._serverMgr:sendMsg("GuildBackupServer", "donate", {askId = askId}, true, {}, function (result)
        local guildBackup = self._modelMgr:getModel("UserModel"):getData()["guildBackup"]
        -- dump(guildBackup,"guildBackup", 20)
        -- dump(result, "result ===", 20)
        -- print("tabletabletable =======",indexId, table.nums(self._backupData), (table.nums(self._backupData)-3))
        if indexId <= (table.nums(self._backupData)-3) then
            self:delDonateData(indexId)
        else
            -- self._tableView:reloadData()
            self:refreshNotReload()
        end
        self:reflashUI()
        self._viewMgr:showTip("捐赠成功")
    end, function(errorId)
        if tonumber(errorId) == 2904 then
            self._viewMgr:showTip("该请求不存在")
            self:delDonateData(indexId)
            self:reflashUI()
        elseif tonumber(errorId) == 2909 then
            self._viewMgr:showTip("已捐赠过")
        end
    end)
end

function GuildBackupView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
        end
    end
    self:getNeedBackupList()
end

function GuildBackupView:getNeedBackupList()
    self._serverMgr:sendMsg("GuildBackupServer", "getNeedBackupList", {}, true, {}, function (result)
        self:getNeedBackupListFinish(result)
    end)
end

function GuildBackupView:getNeedBackupListFinish(result)
    -- dump(result,"result ===================")
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self._backupData = self:progressData(result)
    -- self._tableView:reloadData()
    self:refreshNotReload()
    self:reflashUI()
end

function GuildBackupView:progressData(result)
    local userId = self._modelMgr:getModel("UserModel"):getData()._id

    local tempData = {}
    for k,v in pairs(result) do
        -- print("v.rid ===", v.rid , userId)
        -- if v.rid == userId then 
        --     v.typeId = true
        -- else
        --     v.typeId = false
        -- end
        if v.rid == userId then 
            v.typeId = 1
        elseif v.rid == "" then
            v.typeId = 3
        else
            v.typeId = 2
        end
        table.insert(tempData, v)
    end
    local sortFunc = function(a, b)
        local aTime = a.askTime
        local bTime = b.askTime
        print("a.=====", a.rid, b.rid)
        print("typeId.=====", a.typeId , b.typeId)
        -- if a.typeId ~= b.typeId then
        --     return a.typeId
        -- else
        --     if aTime < bTime then
        --         return true
        --     end
        -- end
        if a.typeId < b.typeId then
            return true
        elseif a.typeId == b.typeId then
            if aTime < bTime then
                return true
            elseif aTime == bTime then
                if a.askId < b.askId then
                    return true
                end
            end
        end
        return false
    end
    table.sort(tempData, sortFunc)
    -- dump(tempData)
    return tempData
end

function GuildBackupView:getAsyncRes()
    return{
        {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"}
    } 
end

function GuildBackupView:getBgName()
    return "bg_001.jpg"
end

function GuildBackupView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

-- function GuildBackupView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView",{hideBtn = true, types = {"Gold","Gem","GuildCoin"}})
-- end

function GuildBackupView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"GuildCoin","Gold","Gem"},title = "allianceScicene_img1.png",titleTxt = "联盟许愿"})
end


-- function GuildBackupView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true})
-- end

return GuildBackupView