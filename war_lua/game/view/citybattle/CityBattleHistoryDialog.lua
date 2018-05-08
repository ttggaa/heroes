
--[[
    Filename:    CityBattleHistoryDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2018-01-16 21:04:58
    Description: File description
--]]

local CityBattleHistoryDialog = class("CityBattleHistoryDialog",BasePopView)

function CityBattleHistoryDialog:ctor(param)
    CityBattleHistoryDialog.super.ctor(self)
    self._callBack = param and param.callBack
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function CityBattleHistoryDialog:getRegisterNames()
    return{
        {"close","bg.close"},
        {"notice","bg.notice"},
        {"tableViewBg", "bg.tableViewBg"},

        {"tableViewBg", "bg.tableViewBg"},
        {"itemPanel", "bg.itemPanel"},
        {"title", "bg.headBg.title"},
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function CityBattleHistoryDialog:onInit()
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,1)
	self:registerClickEvent(self._close, function ()
        if self._callBack then
            self._callBack()
        end
        self:close()
        UIUtils:reloadLuaFile("citybattle.CityBattleHistoryDialog")
    end)
    self._itemPanel:setVisible(false)

    self:registerClickEvent(self._notice, function()  
        self._viewMgr:showDialog("citybattle.CityBattleHisRuleDialog",{},true)
    end)
    self._recordData = self._cityBattleModel:getRecordData()
    dump(self._recordData,"==============",10)
    self:addTableView()
    
end

function CityBattleHistoryDialog:addTableView()
    if self._tableView then  
        self._tableView:removeFromParent()
        self._tableView = nil
    end
    local scrollPanel = self._tableViewBg
    local tableView = cc.TableView:create(cc.size(scrollPanel:getContentSize().width, scrollPanel:getContentSize().height-5))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(0,4)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    scrollPanel:addChild(tableView,1)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView = tableView
    tableView:reloadData()
end

function CityBattleHistoryDialog:scrollViewDidScroll(view)

end

function CityBattleHistoryDialog:scrollViewDidZoom(view)

end

function CityBattleHistoryDialog:tableCellTouched(view)

end

function CityBattleHistoryDialog:cellSizeForTable(table,index)
    return 115,646
end

function CityBattleHistoryDialog:tableCellAtIndex(table,idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end

    local cellData = self._recordData[idx + 1]
    if cell.item == nil then
        local item = self._itemPanel:clone()
        item:setVisible(true)
        self:updateCell(item, cellData, idx)
        item:setPosition(cc.p(8,0))
        item:setAnchorPoint(cc.p(0,0))
        cell.item = item
        cell:addChild(item)
    else
        self:updateCell(cell.item, cellData, idx)
    end

    return cell
end

function CityBattleHistoryDialog:numberOfCellsInTableView(table,index)
    return #self._recordData
end

local serverSmallImage = {"citybattle_view_temp6","citybattle_view_temp8","citybattle_view_temp7"}
function CityBattleHistoryDialog:updateCell(item, data, idx)
    local serverIma = item:getChildByFullName("serverIma")
    local serverLa = item:getChildByFullName("serverLa")
    local list = item:getChildByFullName("list")
    local level = item:getChildByFullName("level")
    local none = item:getChildByFullName("none")

    for i=1,4 do
        local his = item:getChildByFullName("his" .. i)
        his:setVisible(false)
        local integral = item:getChildByFullName("integral"..i)
        integral:setVisible(false)
    end
    serverIma:loadTexture(serverSmallImage[data.color]..".png",1)
    local name = self._cityBattleModel:getServerName(data.sec)
    serverLa:setString(name)
    local levelNum = data.bl or 0
    level:setString(levelNum)

    local sdkMgr = SdkManager:getInstance()
    local function getPlatform(sec)
        local platform =""
        local sec = tonumber(sec)
        if sec and sec >= 5001 and sec < 7000 then
            platform = "双线"
        elseif sdkMgr:isQQ() then
            platform = "qq"
        elseif sdkMgr:isWX() then
            platform = "微信"
        else
            platform = "win"
        end
        return platform
    end

    local function getRealNum(sec)
        sec = tonumber(sec)
        local num = 0
        if sec < 5001 then
            num = sec % 1000
        elseif (sec >= 5001 and sec < 5501) or (sec >= 6001 and sec < 6501) then
            num = (sec % 1000)*2 - 1
        elseif (sec >= 5501 and sec < 6000) or (sec >= 6501 and sec < 7000) then
            num = (sec % 100) * 2
        else
            num = sec % 1000
        end
        return num
    end
    local severList = self._userModel:getServerIDMap()
    local function fiterServers(sec)
        local result = {}
        if not severList[tostring(sec)] then
            result[#result+1] = sec
        else
            for old,new in pairs (severList) do
                if tostring(sec) == new then
                    result[#result+1] = tonumber(old)
                end
            end
            if #result == 0 then
                result[#result+1] = sec
            end
        end
        return result
    end
    local severList = fiterServers(data.sec)
    local str = ""
    for index,sec in pairs (severList) do 
        local num = getRealNum(sec)
        local platform = getPlatform(sec)
        platform = platform or ""
        str = str .. platform .. num .. "区"
        if index ~= table.nums(severList) then
            str = str .. " "
        end
    end
    local fontsize = table.nums(severList) > 4 and 14 or 16
    list:setFontSize(fontsize)
    list:setString(str)
    local r = data.r or {}
    local s = data.s or {0,0,0,0}
    for i=1,4 do 
        local his = item:getChildByFullName("his" .. i)
        if r[i] then
            his:setVisible(true)
            local cityNum = his:getChildByFullName("cityNum")
            cityNum:setString(r[i])
        end
        local integral = item:getChildByFullName("integral"..i)
        if r[i] then
            integral:setVisible(true)
            local numLab = integral:getChildByFullName("cityNum")
            local score = s[i] or 0
            numLab:setString(score)
        end
    end

    --上期标签
    local posItem = item:getChildByFullName("his" .. #r)
    if posItem then
        local lastImg = ccui.ImageView:create()
        lastImg:loadTexture("citybattle_lastLabel.png",1)
        item:addChild(lastImg)
        lastImg:setPosition(cc.p(posItem:getPositionX()+15,88))
    end

    if #r == 0 then
        none:setVisible(true)
    else
        none:setVisible(false)
    end

end

return CityBattleHistoryDialog