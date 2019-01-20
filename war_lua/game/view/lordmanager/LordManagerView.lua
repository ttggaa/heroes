--[[
    Filename:    LordManagerView.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-03-06 14:00
    Description: File description
--]]

local LordManagerView = class("LordManagerView",BasePopView)

local Normal_Pos = cc.p(435,73)
local Finish_Pos = cc.p(360,54)

function LordManagerView:ctor()
 	self.super.ctor(self)
 	self._btns = {}
end 

function LordManagerView:getAsyncRes()
    return 
        {
            {"asset/ui/lordManager.plist", "asset/ui/lordManager.png"},
            {"asset/ui/lordManager1.plist", "asset/ui/lordManager1.png"},
            {"asset/ui/lordManager3.plist", "asset/ui/lordManager3.png"},
            {"asset/ui/lordManager2.plist", "asset/ui/lordManager2.png"},
            {"asset/ui/alliance.plist","asset/ui/alliance.png"},
            {"asset/ui/activity.plist","asset/ui/activity.png"}
        }
end

function LordManagerView:onTop()
    print("==================LordManagerView:onTop()===============")
    if self._layerNodeTableView then
        self._layerNodeTableView:reloadData()
    end
end

function LordManagerView:onInit()
    self:listenReflash("LordManagerModel",self.reflashTableView)
    self:setListenReflashWithParam(true)
	self._layerNode = self:getUI("bg.right_panel.layer_item_list")
    self._item      = self:getUI("item")
	self._item1      = self:getUI("item1")
    self._sureBtn   = self:getUI("bg.sureBtn")
    self._ruleTips   = self:getUI("bg.rule_tips")

    local title = self:getUI("bg.mainBg.title.titleName")

    self._lordManagerModel = self._modelMgr:getModel("LordManagerModel")
    --精灵
    local spImg     = self:getUI("bg.spImg")
    spImg:loadTexture("asset/bg/global_reward3_img.png",0)
    spImg:setPositionX(spImg:getPositionX()-60)

    self:registerClickEvent(self._ruleTips, function ( ... )
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("LordManager_Rule")},true)
    end)

    self:registerClickEvent(self:getUI("bg.mainBg.closeBtn"), function ( ... )
        self:close()
    end)

    self:initLeftTab()
end

-- 初始化 页签
function LordManagerView:initLeftTab( ... )
	for i,tabName in ipairs(LordManagerUtils.tabNames) do
		local img = ccui.ImageView:create()
		img:loadTexture(LordManagerUtils.tabNameImg[i],1)
		self._btns[i] = self:getUI(tabName)
        self._btns[i]:addChild(img)
        local size = self._btns[i]:getContentSize()
        img:setPosition(cc.p(size.width/2-10,size.height/2))
		local name = cc.Label:createWithTTF(lang("LordManager_Table"..i), UIUtils.ttfName, 20)
		name:setColor(cc.c3b(255, 255, 255))
		name:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		name:setPosition(cc.p(self._btns[i]:getContentSize().width/2-10,27))
		self._btns[i]:addChild(name)
	end
	
	for i,tabName in ipairs(LordManagerUtils.tabNames) do
		self:registerClickEvent(self._btns[i], function ( sender )
			self:changeTab(sender,i)
		end)
	end

    self:registerClickEvent(self._sureBtn, function ( sender )
        if self:checkSelectState(self._preTabIdx) then
            self._lordManagerModel:checkIsNeedCostMoney(self._preTabIdx)
        else
            local array = self._lordManagerModel:getDataByType(self._preTabIdx)
            for k,v in pairs(array) do
                if v.isOpen and v.hTimes > 0 then
                    if idx == 3 then
                        if v.isPass then
                            self._viewMgr:showTip("请至少选择一项")
                            return
                        end
                    else
                        self._viewMgr:showTip("请至少选择一项")
                        return
                    end
                end
            end
            self._viewMgr:showTip("没有可以领取的奖励")
        end
    end)
    
	self:changeTab(self:getUI("bg.left_panel.tab1"), 1)
end

--检查对应页签是否可以领奖
function LordManagerView:checkSelectState(idx)
    local state = false
    local array = self._lordManagerModel:getDataByType(idx)
    for k,v in pairs(array) do
        if self._lordManagerModel:isSave(v.idx) and v.isOpen and v.hTimes > 0 then
            if idx == 3 then
                if v.isPass then
                    state = true 
                    break
                end
            else
                state = true
                break
            end
        end
    end
    return state
end

function LordManagerView:changeTab(sender,idx)
	print("tab btn idx "..idx)
	if self._preBtn and self._preBtn == sender then return end
    if idx == 4 and self._modelMgr:getModel("GloryArenaModel"):lIsOpen() and next(self._modelMgr:getModel("GloryArenaModel"):lGetSelfAttackCount()) == nil then
        self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
            local tempData = self._modelMgr:getModel("LordManagerModel"):getDataByType(idx)
            if table.nums(tempData) <= 0 then
                self._viewMgr:showTip(lang("LordManager_Text7"))
                return
            end
            self._btns[idx]:setEnabled(false)
            self._btns[idx]:setBright(false)
            if self._preBtn then
                self._preBtn:setEnabled(true)
                self._preBtn:setBright(true)
            end
            self._preBtn = self._btns[idx]
            self._preTabIdx = idx
            self._itemData = self._modelMgr:getModel("LordManagerModel"):getDataByType(idx)
            self:reflahRightPanel(idx) 
            return
        end
        )
    end
    local tempData = self._modelMgr:getModel("LordManagerModel"):getDataByType(idx)
    if table.nums(tempData) <= 0 then
        self._viewMgr:showTip(lang("LordManager_Text7"))
        return
    end
    self._btns[idx]:setEnabled(false)
    self._btns[idx]:setBright(false)
    if self._preBtn then
        self._preBtn:setEnabled(true)
        self._preBtn:setBright(true)
    end
    self._preBtn = self._btns[idx]
    self._preTabIdx = idx
    self._itemData = self._modelMgr:getModel("LordManagerModel"):getDataByType(idx)
    self:reflahRightPanel(idx) 
end

function LordManagerView:reflashTableView(eventName)
    print("eventname"..tostring(eventName))
    if eventName == "reflashView" then
        self._itemData = self._modelMgr:getModel("LordManagerModel"):getDataByType(self._preTabIdx)
        self:reflahRightPanel(self._preTabIdx)
    end
end

function LordManagerView:createTableView()
    local tips = self:getUI("bg.tips")
    tips:setVisible(#self._itemData <= 0)
    if self._layerNodeTableView then
        self._layerNodeTableView:reloadData()
        return 
    end
    local tableView = cc.TableView:create(cc.size(537,360))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setAnchorPoint(0,0)
    tableView:setPosition(0 ,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._layerNode:addChild(tableView,999)
    tableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function ( table,cell ) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index ) return self:cellSizeForTable(table,index) end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index ) return self:tableCellAtIndex(table,index) end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table ) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._layerNodeTableView = tableView
end

function LordManagerView:scrollViewDidScroll(view)

end

function LordManagerView:tableCellTouched(table,cell)
end

function LordManagerView:cellSizeForTable(table,idx) 
    return 111,529
end

function LordManagerView:tableCellAtIndex(table,idx)
    local index = idx + 1
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
        local itemView = self._item:clone()
        if self._preTabIdx == 4 then
            itemView = self._item1:clone()
        end
        itemView:setVisible(true)
        itemView:setAnchorPoint(0,0)
        itemView:setTouchEnabled(false)
        itemView:setPosition(5, 0)
        itemView:setTag(9999)
        cell:addChild(itemView)
    else
        local itemView = cell:getChildByTag(9999)
        if itemView then
            itemView:removeFromParent()
        end
        itemView = self._item:clone()
        if self._preTabIdx == 4 then
            itemView = self._item1:clone()
        end
        itemView:setVisible(true)
        itemView:setAnchorPoint(0,0)
        itemView:setTouchEnabled(false)
        itemView:setPosition(5, 0)
        itemView:setTag(9999)
        cell:addChild(itemView)
    end
    local itemView = cell:getChildByTag(9999)
    if not itemView then return end
    if self._preTabIdx ~= 4 then
        self:updateItem(itemView,index)
    else
        self:updateItem1(itemView,index)
    end

    return cell
end

function LordManagerView:numberOfCellsInTableView(table)
    return #self._itemData
end

function LordManagerView:reflahRightPanel(idx)
    self._sureBtn:setVisible(idx ~= 4)
    self:createTableView()
end

--未解锁功能  不显示
--解锁功能 未达到扫荡要求 --给提示
--未开启活动  不显示
--已领取 --
--settingBtn 只有203 308
function LordManagerView:updateItem(item,idx)
    local id = self._itemData[idx].idx.."01"
    item.bgImg = item:getChildByFullName("bgImg")
    
    item.countTxt = item:getChildByFullName("countTxt")
    item.countTxt:setString(LordManagerUtils.lordDesStr[tab.lordManager[tonumber(id)].des1])
    item.bgImg:loadTexture(tab.lordManager[tonumber(id)].bg..".png", 1)
    item.img_finish = item:getChildByFullName("img_finish")
    item.countLabel = item:getChildByFullName("countLabel")
    item.checkBox = item:getChildByFullName("checkBox")
    item.achieveTxt = item:getChildByFullName("achieveTxt")

    local settingBtn = item:getChildByFullName("settingBtn")

    local maxTimes = self._itemData[idx].maxTimes
    local hTimes   = self._itemData[idx].hTimes
    item.countLabel:setString(hTimes.."/"..maxTimes)

    --达到等级未开启扫荡 特殊处理
    if self._itemData[idx].idx > 300 and self._itemData[idx].idx < 314 then
        if self._itemData[idx].isOpen == true and self._itemData[idx].isPass == false then
            item.achieveTxt:setString("尚未开启扫荡")
            item.achieveTxt:setVisible(true)
            item.achieveTxt:setPositionY(73)
            item.img_finish:setVisible(false)
            item.checkBox:setVisible(false)
            item.countLabel:setVisible(true)
            item.countTxt:setVisible(true)
            settingBtn:setVisible(false)
            return
        end
    end

    settingBtn:setVisible(false)
    if self._itemData[idx].idx == 203 or self._itemData[idx].idx == 308 then
        settingBtn:setVisible(true)
    end
    self:registerClickEvent(settingBtn, function ( ... )
        if self._itemData[idx].idx == 203 then
            --捐献设置界面
            self._viewMgr:showDialog("lordmanager.LordManagerDonateView",{callback = function ( ... )
                self:reflahRightPanel()
            end})
        elseif self._itemData[idx].idx == 308 then
            self._viewMgr:showDialog("lordmanager.LordSweepSetView",{callback = function ( ... )
                self:reflahRightPanel()
            end})
        end
    end)
    -- item.countLabel:setFontName(UIUtils.ttfName_Number)
    
    item.checkBox:setVisible(hTimes > 0)
    local isSave = self._modelMgr:getModel("LordManagerModel"):isSave(self._itemData[idx].idx)
    item.checkBox:setSelected(isSave)

    --完成状态设置  --通用状态设置
    item.achieveTxt:setVisible(false)
    item.img_finish:setVisible(hTimes <= 0)
    item.countTxt:setVisible(hTimes > 0)
    item.countLabel:setVisible(hTimes > 0)

    --203 308 完成移动设置位置
    local pos = hTimes > 0 and Normal_Pos or Finish_Pos
    settingBtn:setPosition(pos)

    ----------------单独处理
    if self._itemData[idx].idx == 202 then
        
        local redNum = 0
        local sysRedData = self._modelMgr:getModel("GuildRedModel"):getSysData()
        for i=1,table.nums(sysRedData) do
            if sysRedData[i] and sysRedData[i].robRed == 0 then
                redNum = redNum + 1
            end
        end
        item.checkBox:setVisible(redNum > 0)     -- 没有可领取的红包
        item.achieveTxt:setVisible(hTimes > 0 and redNum <= 0)
        item.achieveTxt:setString("没有可领取的红包")
    elseif self._itemData[idx].idx == 314 then 
        item.img_finish:setVisible(false)
        item.checkBox:setVisible(hTimes > 0)
        item.achieveTxt:setVisible(hTimes <= 0 )
        item.achieveTxt:setString("无可派驻位置")
        item.achieveTxt:setPositionY(Finish_Pos.y)
    elseif self._itemData[idx].idx == 315 then
        item.img_finish:setVisible(false)
        item.checkBox:setVisible(hTimes > 0)     
        item.achieveTxt:setVisible(hTimes <= 0 )
        item.achieveTxt:setString("无可领取岛屿")
        item.achieveTxt:setPositionY(Finish_Pos.y)
    elseif self._itemData[idx].idx == 203 then
        local tid = tonumber(self._lordManagerModel:getScienceType())
        local did = tonumber(self._lordManagerModel:getDonateType())
        --没有勾选有效的选项
        if tid == 0 or did == 0 then
            item.checkBox:setVisible(false)
            item.achieveTxt:setString("请选择捐献目标")
            item.achieveTxt:setVisible(true)
            settingBtn:setPosition(Finish_Pos)
            item.achieveTxt:setPositionY(Normal_Pos.y)
            return
        end
        local isMax,needExp = self._modelMgr:getModel("GuildModel"):isMaxLevel(tid)
        local times  = hTimes < (math.floor(needExp/LordManagerUtils.expArray[did])) and hTimes or (math.floor(needExp/LordManagerUtils.expArray[did]))
        local has = 0
        if did == 1 then
            has = self._modelMgr:getModel("UserModel"):getData().gold or 0 
        else
            has = self._modelMgr:getModel("UserModel"):getData().gem or 0
        end
        local cost = LordManagerUtils.costArray[did]
        if cost > has then
            local str = did == 1 and "黄金不足" or "钻石不足"
            item.achieveTxt:setString(str)
        end
        if isMax then
            item.achieveTxt:setString("建设等级已满")
        end
        local isVisible = false 
        if hTimes > 0 then
            if (not isMax) and has > cost then 
                isVisible = true
            end
            item.checkBox:setVisible(isVisible)
            item.achieveTxt:setVisible(not isVisible)
        else
            item.checkBox:setVisible(false)
            item.achieveTxt:setVisible(false)
        end 
        if item.achieveTxt:isVisible() then
            settingBtn:setPosition(Finish_Pos)
        end
    elseif self._itemData[idx].idx == 308 then
        local state = tonumber(self._lordManagerModel:getTowerType())
        if hTimes > 0 then
            item.checkBox:setVisible(state ~= 0)
            item.achieveTxt:setVisible(state == 0)
            item.achieveTxt:setString("请选择扫荡方式")
            item.achieveTxt:setPositionY(Normal_Pos.y)
            local pos = item.achieveTxt:isVisible() and Finish_Pos or Normal_Pos
            settingBtn:setPosition(pos)
        else
            settingBtn:setPosition(Finish_Pos)
        end
    elseif self._itemData[idx].idx == 204 then
        item.achieveTxt:setVisible(hTimes <= 0)
        item.achieveTxt:setString("无可领黄金")
        item.achieveTxt:setPositionY(54)
        item.img_finish:setVisible(false)
    elseif self._itemData[idx].idx == 316 then
        item.achieveTxt:setVisible(hTimes <= 0)
        item.achieveTxt:setString("无可领取道具")
        item.img_finish:setVisible(false)
    end

    --宝物占星 法术祈愿优化 增加本期热点
    if item:getChildByName("hotBtn") then
        item:getChildByName("hotBtn"):removeFromParent()
    end
    if item:getChildByName("hotItem") then
        item:getChildByName("hotItem"):removeFromParent()
        item:getChildByName("iconTitle"):removeFromParent()
    end

    if self._itemData[idx].idx == 104 then
        --占星
        local hotSpotBtn = ccui.Button:create()  
        hotSpotBtn:loadTextures("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", 1)
        hotSpotBtn:setPosition(340,55)
        hotSpotBtn:setTitleFontName(UIUtils.ttfName)
        -- self:L10N_Text(hotSpotBtn)
        hotSpotBtn:setTitleText("本期热点")
        hotSpotBtn:setTitleFontSize(22)  
        hotSpotBtn:setScale(0.8)
        item:addChild(hotSpotBtn)
        hotSpotBtn:setName("hotBtn")
        registerClickEvent(hotSpotBtn, function ( ... )
            self._viewMgr:showDialog("treasure.TreasureShopPreView", {imgs = self._lordManagerModel:getHotSpotTreasure()
        })
        end)
    elseif self._itemData[idx].idx == 105 then
        --祈愿
        local data = self._lordManagerModel:getHotSpotSkillCard()
        local tabData = tab.tool
        local icon = IconUtils:createItemIconById({itemId = data[2], itemData = tabData[data[2]],eventStyle = 1, showSpecailSkillBookTip = true})
        icon:setScale(0.6)
        item:addChild(icon)
        icon:setPosition(310,15)
        icon:setName("hotItem")

        local title = cc.Label:createWithTTF("本期橙色法术", UIUtils.ttfName, 16)
        title:setColor(cc.c4b(255, 255, 255, 255))
        title:enable2Color(1, cc.c4b(255, 221, 63, 255))
        title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        title:setPosition(337,85)
        title:setName("iconTitle")
        item:addChild(title)
    end

    --保存选中状态
    item.checkBox:addEventListener(function(sender, eventType)
        if eventType == 0 then
            self._modelMgr:getModel("LordManagerModel"):saveSelectedState(self._itemData[idx].idx,1)
        else
            self._modelMgr:getModel("LordManagerModel"):saveSelectedState(self._itemData[idx].idx,0)
        end
    end)
end

--preTabIdx == 4
function LordManagerView:updateItem1(item,idx)
    local id = self._itemData[idx].idx.."01"
    item.bgImg = item:getChildByFullName("bgImg")
    
    item.countTxt = item:getChildByFullName("countTxt")
    item.countTxt:setString(LordManagerUtils.lordDesStr[tab.lordManager[tonumber(id)].des1])
    item.bgImg:loadTexture(tab.lordManager[tonumber(id)].bg..".png", 1)
    item.countLabel = item:getChildByFullName("countLabel")

    local settingBtn = item:getChildByFullName("settingBtn")

    local maxTimes = self._itemData[idx].maxTimes
    local hTimes   = self._itemData[idx].hTimes
    item.countLabel:setString(hTimes.."/"..maxTimes)

    item.rank = item:getChildByFullName("rank")
    item.rankPanel = item:getChildByFullName("rankPanel")
    item.stateLab = item:getChildByFullName("stateLab")
    item.stateLab:setVisible(false)

    if self._itemData[idx].idx == 401 then
        --jjc
        item.rank:setVisible(true)
        item.rankPanel:setVisible(false)
        local rankNum = item.rank:getChildByFullName("rankNum")
        rankNum:setString(self._modelMgr:getModel("ArenaModel"):getData().rank or 0)
    elseif self._itemData[idx].idx == 402 then
        --wgls
        item.rank:setVisible(false)
        item.rankPanel:setVisible(true)
        local cModel = self._modelMgr:getModel("CrossModel")
        local state = cModel:getOpenState()

        item.stateLab:setVisible( state~=2 )
        item.countTxt:setVisible(state == 2)
        item.countLabel:setVisible(state == 2)

        local str = state == 1 and lang("LordManager_Text8") or lang("LordManager_Text9")
        item.stateLab:setString(str)
        for i=1,3 do
            local myData = cModel:getMyInfo()
            local playRankStr = myData["rank" .. i] ~= 0 and myData["rank" .. i] or "暂无"
            local tData = cModel:getData()["regiontype"..i] or i
            local ctName = item.rankPanel:getChildByFullName("cityName"..i)
            ctName:setFontSize(17)
            local rkNum = item.rankPanel:getChildByFullName("rankNum"..i)
            rkNum:setFontSize(17)
            ctName:setString(lang("cp_npcRegion" .. tData))
            rkNum:setString("排名:"..playRankStr)
        end
    elseif self._itemData[idx].idx == 403 then
        item.rank:setVisible(false)
        item.rankPanel:setVisible(true)

        local isOpen = self._modelMgr:getModel("GloryArenaModel"):lIsOpen()
        item.stateLab:setVisible(isOpen==false )
        item.countTxt:setVisible(isOpen ~= false)
        item.countLabel:setVisible(isOpen ~= false)

        local Season = self._modelMgr:getModel("GloryArenaModel"):lGetSeason()
        Season = tonumber(Season) ~= 0 and Season or 1
        local resData = tab:HonorArenaResource(tonumber(Season))

        local hot1 = item.rankPanel:getChildByFullName("cityName1")
        local hot2 = item.rankPanel:getChildByFullName("rankNum1")
        hot1:setFontSize(16)
        hot2:setFontSize(16)
        hot1:setString("本期热点:")
        hot2:setString(lang(resData.Name) or "涅槃")

        local time1 = item.rankPanel:getChildByFullName("cityName2")
        local time2 = item.rankPanel:getChildByFullName("rankNum2")
        local t1 , t2 = self._modelMgr:getModel("GloryArenaModel"):lGetLordShowTimes()
        time1:setFontSize(14)
        time2:setFontSize(14)
        time1:setString(t1)
        time2:setString("~ "..t2)

        local rank1 = item.rankPanel:getChildByFullName("cityName3")
        local rank2 = item.rankPanel:getChildByFullName("rankNum3")
        rank1:setFontSize(16)
        rank2:setFontSize(16)
        rank1:setString("当前排名:")
        local rank = self._modelMgr:getModel("GloryArenaModel"):lGetSelfRank()
        rank = rank ~= 0 and rank or "暂无"
        rank2:setString(rank)

    end
    --btn
    item.gotoBtn = item:getChildByFullName("gotoBtn")
    item.sweepBtn = item:getChildByFullName("sweepBtn")

    registerClickEvent(item.gotoBtn, function ( ... )
        self:goView(self._itemData[idx].idx)
    end)

    registerClickEvent(item.sweepBtn, function ()
        self._lordManagerModel:getOtherReward(self._itemData[idx].idx,hTimes)
    end)
end

function LordManagerView:goView(idx)
    if idx == 401 then
        if not SystemUtils:enableArena() then
            self._viewMgr:showTip(lang("TIP_Arena"))
            return 
        end
        self._viewMgr:showView("arena.ArenaView") 
    elseif idx == 402 then
        if not self._modelMgr:getModel("CrossModel"):getOpenActionState() then
            self._viewMgr:showTip(lang("TIPS_SIEGE_LORDBOOK_OPEN_3"))
            return 
        end
        self._viewMgr:showView("cross.CrossMainView")
    elseif idx == 403 then
        self._modelMgr:getModel("GloryArenaModel"):lOpenGloryArena()
    else
    end
end

function LordManagerView:onHide()
    
end

function LordManagerView:onTop()                       
    
end

function LordManagerView.dtor()
    Normal_Pos = nil
    Finish_Pos = nil
end

return LordManagerView