--[[
    Filename:    GuildMapPvpView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-06-27 15:08:36
    Description: File description
--]]


local GuildMapPvpView = class("GuildMapPvpView", BasePopView, require("game.view.guild.map.GuildMapCommonBattle"))

function GuildMapPvpView:ctor(data)
    GuildMapPvpView.super.ctor(self)

    self._userId = self._modelMgr:getModel("UserModel"):getData()._id
    self._guildMapModel = self._modelMgr:getModel("GuildMapModel")
    self._callback = data.callback
    self._targetId = data.targetId
    self._userIds = data.userIds
    self._isFriends = data.isFriends

end



function GuildMapPvpView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapPvpView")
            
            UIUtils:reloadLuaFile("guild.map.GuildMapPvpUserCell")
        elseif eventType == "enter" then 
        end
    end)      
    self:registerClickEventByName("bg1.closeBtn", function ()
        self:close()
    end)

    self:registerClickEventByName("bg2.closeBtn", function ()
        self:close()
    end)


    local titleLab = self:getUI("bg1.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)
    -- titleLab:setFontName(UIUtils.ttfName)
    -- titleLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- titleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    titleLab:setString("攻击敌人")

    local titleLab = self:getUI("bg2.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)
    -- titleLab:setFontName(UIUtils.ttfName)
    -- titleLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- titleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    titleLab:setString("攻击敌人")


    local mapList = self._guildMapModel:getData().mapList

    local bg1 = self:getUI("bg1")
    bg1:setVisible(false)

    local bg2 = self:getUI("bg2")
    bg2:setVisible(false)

    if mapList[self._targetId] == nil then 
        self:close()
        return
    end

    if self._isFriends ==  true then 
        if #self._userIds <=  1  then 
            self:setVisible(false)
            self:getTargetUserBattleInfo(self._userIds[1], true)
        else
            self:onInit3()
        end
    else
        if #self._userIds <= 1  then 
            self:setVisible(false)
            self:getTargetUserBattleInfo(self._userIds[1], false)
            -- self:onInit1()
        else
            self:onInit2()
        end
    end
end



function GuildMapPvpView:onInit1()
    local bg1 = self:getUI("bg1")
    bg1:setVisible(true)

    local descBg = self:getUI("bg1.descBg")
    if descBg ~= nil then 
        local str = lang("GUILDMAPTIPS_8")
        if string.find(str, "color=") == nil then
            str = "[color=000000]".. str .."[-]"
        end          
        local rtx = RichTextFactory:create(str,descBg:getContentSize().width - 30,descBg:getContentSize().height)
        rtx:formatText()
        rtx:setVerticalSpace(3)
        rtx:setAnchorPoint(cc.p(0,0.5))
        rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
        descBg:addChild(rtx)
    end

    local mapList = self._guildMapModel:getData().mapList
    local userList = self._guildMapModel:getData().userList
    local userId = self._userIds[1]

    local holdUserInfo = userList[userId]


  -- 移除头像上内容
    local avatarBg = self:getUI("bg1.infoBg.avatarBg")
    avatarBg:removeAllChildren()

    -- 头像
    local avatar = IconUtils:createHeadIconById({avatar = holdUserInfo.avatar,level = holdUserInfo.lvl , tp = 4,avatarFrame = holdUserInfo["avatarFrame"]})   --,tp = 2
    avatarBg:addChild(avatar)


    local nameLab = self:getUI("bg1.infoBg.nameLab")
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    nameLab:setString(holdUserInfo.name)

    -- 战力
    local labScore = self:getUI("bg1.infoBg.labScore")
    labScore:setString("a" ..holdUserInfo.score)
    labScore:setFntFile(UIUtils.bmfName_zhandouli)
    labScore:setScale(0.85)

    local mapHurtLab = self:getUI("bg1.infoBg.mapHurtLab")
    if holdUserInfo.mapHurt == nil then 
        mapHurtLab:setString("耐力 0/100")
    else
        mapHurtLab:setString("耐力 " .. holdUserInfo.mapHurt .. "/100")
    end
    mapHurtLab:setFontName(UIUtils.ttfName)
    mapHurtLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)    

    self:registerClickEventByName("bg1.cancelBtn", function ()
        self:close()
    end)

    self:registerClickEventByName("bg1.enterBtn", function ()
        self:getAimInfo(userId)
    end)    

end

function GuildMapPvpView:onInit2()
    local bg2 = self:getUI("bg2")
    bg2:setVisible(true)

    
    local tmpTipLab = self:getUI("bg2.userListBg.Label_28")
    tmpTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    self:onInitTable()
 
end

function GuildMapPvpView:onInitTable()
    local tableViewBg = self:getUI("bg2.userListBg")

    self._tableView = cc.TableView:create(cc.size(430, tableViewBg:getContentSize().height - 20))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(10, 10))
    self._tableView:setDelegate()
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)

    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)

    self._tableView:reloadData()
end

function GuildMapPvpView:onInit3()

    local bg2 = self:getUI("bg2")
    bg2:setVisible(true)


    local titleLab = self:getUI("bg2.titleBg.titleLab")
    titleLab:setString("查看玩家")

    self:onInitTable()
    
    local tmpTipLab = self:getUI("bg2.userListBg.Label_28")
    tmpTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    tmpTipLab:setString("请选择要查看的玩家")
end



-- 触摸时调用
function GuildMapPvpView:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function GuildMapPvpView:cellSizeForTable(table,idx) 
    return 110, 430
end

-- 创建在某个位置的cell
function GuildMapPvpView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = require("game.view.guild.map.GuildMapPvpUserCell").new()
    end
    cell:setCallback(function(inUserId, isLook)
        if isLook == true then
            self:getTargetUserBattleInfo(inUserId)
        else
            self:getAimInfo(inUserId)
        end
    end)
    cell:reflashUI(self._userIds[idx+1], self._isFriends)
    return cell
end

-- 返回cell的数量
function GuildMapPvpView:numberOfCellsInTableView(table)
    return #self._userIds
end


function GuildMapPvpView:getTargetUserBattleInfo(inUserId, inIsFriend)
    local formationModel = self._modelMgr:getModel("FormationModel")
    local param = {}
    param.tagId = inUserId
    param.fid = formationModel.kFormationTypeGuildDef
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", param, true, {}, function(result)
        local userList = self._guildMapModel:getData().userList
        local holdUserInfo = userList[inUserId]
        local guildList = self._guildMapModel:getData().guildList
        result.guildMapName = guildList[tostring(holdUserInfo.guildId)].name
        result.mapHurt = holdUserInfo.mapHurt
        result.showType = 1
        if inIsFriend == false then 
            result.isOtherFun = true
            result.titleTxtLeft = "攻击"
            result.titleTxtRight = "路过"
            result.callBackLeft = function()
                self:setVisible(true)
                if self._userInfo ~= nil then 
                    self._userInfo:close()
                end
                self:getAimInfo(inUserId)
            end
            result.callBackRight = function()
                if self._userInfo ~= nil then 
                    self._userInfo:close()
                end
            end
        end
        self._userInfo = self._viewMgr:showDialog("arena.DialogArenaUserInfo", result, true)
    end)
end

function GuildMapPvpView:onDestroy()
    self:onDestroy1()
    GuildMapPvpView.super.onDestroy(self)
end

return GuildMapPvpView