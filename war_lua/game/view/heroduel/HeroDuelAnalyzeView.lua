--[[
    Filename:    HeroDuelAnalyzeView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-02-08 15:02:15
    Description: File description
--]]

local HeroDuelAnalyzeView = class("HeroDuelAnalyzeView", BasePopView)
function HeroDuelAnalyzeView:ctor(inData)
    HeroDuelAnalyzeView.super.ctor(self)
    self:handleData(inData.data)
end


function HeroDuelAnalyzeView:handleData(inData)
    self._handleData = {}
    for k,v in pairs(inData) do
        local dataTb = string.split(k, "#")
        v.id = tonumber(dataTb[1])
        if v.show == 0 then 
            v.damageRate = 0
            v.hurtRate = 0
            v.healRate = 0
        else
            v.damageRate = v.damage / v.show
            v.hurtRate = v.hurt / v.show
            v.healRate = v.heal / v.show
        end
        table.insert(self._handleData, v)
    end
end

function HeroDuelAnalyzeView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("heroduel.HeroDuelAnalyzeView")
        elseif eventType == "enter" then 
        end
    end)
end

function HeroDuelAnalyzeView:reflashUI()
    self._leftTips = { tab_out = lang("HERODUEL_NUM1"), tab_def = lang("HERODUEL_NUM2"), tab_treat = lang("HERODUEL_NUM3")}
    self._rightTips = { tab_out = lang("HERODUEL_NUM4"), tab_def = lang("HERODUEL_NUM5"), tab_treat = lang("HERODUEL_NUM6")}

    self:registerClickEventByName("bg.layer.closeBtn", function()
        self:close()
    end)

    local titleLab = self:getUI("bg.layer.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 1)

    self._tableBg1 = self:getUI("bg.layer.tableBg1")
    self._tableBg1:setVisible(false)

    self._tableBg2 = self:getUI("bg.layer.tableBg2")
    self._tableBg2:setVisible(false)

    local labLeftTip = self:getUI("bg.layer.tableBg1.stateBg.labLeftTip")
    labLeftTip:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local labRightTip = self:getUI("bg.layer.tableBg1.stateBg.labRightTip")
    labRightTip:setColor(UIUtils.colorTable.ccUIBaseTextColor1)


    self:getUI("bg.layer.tableBg2.tagBg.title1"):setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self:getUI("bg.layer.tableBg2.tagBg.title2"):setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self:getUI("bg.layer.tableBg2.tagBg.title3"):setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self:getUI("bg.layer.tableBg2.tagBg.title4"):setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    -- 页签动画换touch 注释
    -- self:registerClickEventByName("bg.layer.tab_out", function(sender)self:tabButtonClick(sender) end)
    -- self:registerClickEventByName("bg.layer.tab_def", function(sender)self:tabButtonClick(sender) end)
    -- self:registerClickEventByName("bg.layer.tab_treat", function(sender)self:tabButtonClick(sender) end)
    -- self:registerClickEventByName("bg.layer.tab_synth", function(sender)self:tabButtonClick(sender) end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_out"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_def"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_treat"))
    table.insert(self._tabEventTarget, self:getUI("bg.layer.tab_synth"))

    self._maxData = {}
    self._sortData = {}
    for k, button in pairs(self._tabEventTarget) do
        button:setTitleFontName(UIUtils.ttfName)
        button:setTitleFontSize(20)
        UIUtils:setTabChangeAnimEnable(button,80,handler(self, self.tabButtonClick))
        if #self._handleData > 0 then
            self:sortData(button:getName())
            self._sortData[button:getName()] = clone(self._handleData)
            local tempShowData = clone(self._handleData[1])
            self:sortData(button:getName(), 1)
            local tempRateData = clone(self._handleData[1])
            if button:getName() == "tab_out" then 
                self._maxData.damage = tempShowData.damage
                self._maxData.damageRate = tempRateData.damageRate
            elseif button:getName() == "tab_def" then 
                self._maxData.hurt = tempShowData.hurt
                self._maxData.hurtRate = tempRateData.hurtRate
            elseif button:getName() == "tab_treat" then 
                self._maxData.heal = tempShowData.heal
                self._maxData.healRate = tempRateData.healRate
            elseif button:getName() == "tab_synth" then 
                self._maxData.mvp = tempShowData.mvp
                self._maxData.show = tempRateData.show
                self:sortData(button:getName(), 2)
                dump(self._handleData, "self._handleData", 10)
                local tempRateData = clone(self._handleData[1])
                self._maxData.ban = tempRateData.ban
            end
        else
            self._sortData[button:getName()] = {}
        end
    end

    self:initTableView()

    self:tabButtonClick(self._tabEventTarget[1],true)

end

function HeroDuelAnalyzeView:initTableView()
    
    self._tableView1 = cc.TableView:create(cc.size(470, 430))
    self._tableView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView1:setAnchorPoint(0, 0)
    self._tableView1:setPosition(0, 5)
    self._tableView1:setDelegate()
    self._tableView1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView1:setBounceable(true)
    self._tableBg1:addChild(self._tableView1,999)
    self._tableView1:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView1:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._tableView1:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView1:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView1:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView1:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    UIUtils:ccScrollViewAddScrollBar(self._tableView1, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)

    
    self._tableView2 = cc.TableView:create(cc.size(470, 428))
    self._tableView2:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView2:setAnchorPoint(0, 0)
    self._tableView2:setPosition(0, 5)
    self._tableView2:setDelegate()
    self._tableView2:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView2:setBounceable(true)
    self._tableBg2:addChild(self._tableView2,999)
    self._tableView2:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView2:registerScriptHandler(function( view ) return self:scrollViewDidZoom(view) end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    self._tableView2:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView2:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView2:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView2:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    UIUtils:ccScrollViewAddScrollBar(self._tableView2, cc.c3b(169, 124, 75), cc.c3b(64, 32, 12), -12, 6)
        
    -- self._tableView = tableView

    self._inScrolling = false
end

--[[
--! @function tabButtonClick
--! @desc 选项卡按钮点击事件处理
--! @param sender table 操作对象
--! @return 
--]]
function HeroDuelAnalyzeView:tabButtonClick(sender,noAudio)
    if sender == nil then 
        return 
    end
    if not noAudio then 
        audioMgr:playSound("Tab")
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUIBaseTextColor2)
            text:disableEffect()
            -- text:setPositionX(65)
            self:tabButtonState(v, false)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender 
    UIUtils:tabChangeAnim(sender,function( )
        local text = sender:getTitleRenderer()
        text:disableEffect()
        -- text:setPositionX(85)
        sender:setTitleColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self:tabButtonState(sender, true)
    end)


    self:touchTabEvent(sender:getName())
end


--[[
--! @function tabButtonState
--! @desc 按钮状态切换
--! @param sender table 操作对象
--! @param isSelected bool 是否选中状态
--! @return 
--]]
function HeroDuelAnalyzeView:tabButtonState(sender, isSelected, isDisabled)
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
end

function HeroDuelAnalyzeView:sortData(inTabName, inSortShowRate)
    if inTabName == "tab_out" then
        table.sort(self._handleData,function (a, b)
            if inSortShowRate ~= nil then 
                if a.damageRate > b.damageRate then 
                    return true
                else
                    if a.damageRate == b.damageRate then
                        if a.damage > b.damage then 
                            return true
                        end
                    end
                end              
            else
                if a.damage > b.damage then 
                    return true
                else
                    if a.damage == b.damage then 
                        if a.damageRate > b.damageRate then 
                            return true
                        end  
                    end
                end               
            end

        end)
    elseif inTabName == "tab_def" then
        table.sort(self._handleData,function (a, b)
            if inSortShowRate ~= nil then 
                if a.hurtRate > b.hurtRate then 
                    return true
                else
                    if a.hurtRate == b.hurtRate then
                        if a.hurt > b.hurt then 
                            return true
                        end
                    end
                end              
            else
                if a.hurt > b.hurt then 
                    return true
                else
                    if a.hurt == b.hurt then 
                        if a.hurtRate > b.hurtRate then 
                            return true
                        end  
                    end
                end               
            end
        end)
    elseif inTabName == "tab_treat" then  
        table.sort(self._handleData,function (a, b)
            if inSortShowRate ~= nil then 
                if a.healRate > b.healRate then 
                    return true
                else
                    if a.healRate == b.healRate then
                        if a.heal > b.heal then 
                            return true
                        end
                    end
                end                
            else
                if a.heal > b.heal then 
                    return true
                else
                    if a.heal == b.heal then 
                        if a.healRate > b.healRate then 
                            return true
                        end  
                    end
                end              
            end
        end)
    elseif inTabName == "tab_synth" then  
        table.sort(self._handleData,function (a, b)
            if inSortShowRate == 1 then 
                if a.show > b.show then 
                    return true
                else
                    if a.show == b.show then 
                        if a.id > b.id then 
                            return true
                        end
                    end
                end
            elseif inSortShowRate == 2 then 
                if a.ban > b.ban then 
                    return true
                else
                    if a.ban == b.ban then 
                        if a.id > b.id then 
                            return true
                        end
                    end
                end
            else
                if a.mvp > b.mvp then 
                    return true
                else
                    if a.mvp == b.mvp then 
                        if a.show > b.show then 
                            return true
                        else
                            if a.show  == b.show then 
                                if a.ban > b.ban then 
                                    return true
                                end   
                            end 
                        end
                    end
                end
            end
        end)
    end
end

function HeroDuelAnalyzeView:touchTabEvent(inTabName)
    self._selectTabType = inTabName
    self._showData = self._sortData[inTabName]
    local nothing
    if inTabName == "tab_synth" then
        self._tableView = self._tableView2
        self._tableBg2:setVisible(true)
        self._tableBg1:setVisible(false)
        nothing = self:getUI("bg.layer.tableBg2.nothing")
    else
        
        local labLeftTip = self:getUI("bg.layer.tableBg1.stateBg.labLeftTip")
        labLeftTip:setString(self._leftTips[inTabName])

        local labRightTip = self:getUI("bg.layer.tableBg1.stateBg.labRightTip")
        labRightTip:setString(self._rightTips[inTabName])
        
        self._tableView = self._tableView1
        self._tableBg1:setVisible(true)
        self._tableBg2:setVisible(false)
        nothing = self:getUI("bg.layer.tableBg1.nothing")
    end
    if #self._showData <= 0 then 
        nothing:setVisible(true)
        self._tableView:setVisible(false)
    else
        nothing:setVisible(false)
        self._tableView:setVisible(true)
        self._tableView:reloadData()
    end
end


function HeroDuelAnalyzeView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    -- if self._inScrolling then
    self._tableOffset = view:getContentOffset()
    -- end
    UIUtils:ccScrollViewUpdateScrollBar(view)
end

function HeroDuelAnalyzeView:scrollViewDidZoom(view)
end

function HeroDuelAnalyzeView:tableCellTouched(table,cell)
end

function HeroDuelAnalyzeView:cellSizeForTable(table,idx) 
    return 70, 470
end

function HeroDuelAnalyzeView:tableCellAtIndex(table, idx)
    -- return cell
    local cell = table:dequeueCell()
    if nil == cell then
        if self._selectTabType ~= "tab_synth" then 
            cell = require("game.view.heroduel.HeroDuelAnalyzeCommonDataCell").new()
        else
            cell = require("game.view.heroduel.HeroDuelAnalyzeSythCell").new()
        end
    end
    cell:setIdx(idx + 1)
    cell:reflashUI(self._showData[idx+1], self._maxData, self._selectTabType)
    return cell
end

function HeroDuelAnalyzeView:numberOfCellsInTableView(table)
    return #self._showData
end

return HeroDuelAnalyzeView