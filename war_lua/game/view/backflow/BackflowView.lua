--[[
    Filename:    BackflowView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-06-22 10:51:05
    Description: File description
--]]

local BackflowView = class("BackflowView", BasePopView)

function BackflowView:ctor(data)
    BackflowView.super.ctor(self)
    if not data then
        data = {}
    end
    self._index = data.tabId or 1
    self._welfareIndex = data.welfareIndex or 1
    self._callback = callback
end

function BackflowView:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._backflowModel = self._modelMgr:getModel("BackflowModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._flowBaseData = self._backflowModel:getBaseData()

    local closeBtn = self:getUI("bg.allBg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        UIUtils:reloadLuaFile("backflow.BackflowView")
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    local tabPos = {
        [1] = {66, 310},
        [2] = {66, 242},
        [3] = {66, 173},
        [4] = {66, 106},
        [5] = {66, 37},
    }
    self._panelMap = {
        [1] = 1,
        [2] = 5,
        [3] = 2,
        [4] = 3,
        [5] = 4,
    }
    local tabMap = {
        [1] = 1,
        [2] = 3,
        [3] = 4,
        [4] = 5,
        [5] = 2,
    }
    local titleNames = {
        " 回归福利 ",
        " 回归特权 ",
        " 回归特卖 ",
        " 回归祝福 ",
        " 充值特惠 ",
    }
    -- self._shortTitleNames = {
    --     " 回归福利 ",
    --     " 回归特卖 ",
    --     " 回归祝福 ",
    --     " 充值特惠 ",
    --     " 回归特权 ",
    -- }

    self._titleNames = titleNames
    self._shortTitleNames = titleNames

    self._tabEventTarget = {}
    local backPrivilege = self._backflowModel:isPrivilegeOpen()
    local backSale = self._backflowModel:isSaleOpen()
    local backRecharge = self._backflowModel:isRechargeOpen()
    local backBless = self._backflowModel:isBlessOpen()

    local closeDialog = {}
    for i=1,5 do
        local tab = self:getUI("bg.allBg.leftPanel.tab" .. i)
        local indexId = i -- tabMap[i]
        if i == 2 then
            if backPrivilege == false then
                closeDialog[indexId] = i
            end
        elseif i == 3 then
            if backSale == false then
                closeDialog[indexId] = i
            end
        elseif i == 4 then
            if backBless == false then
                closeDialog[indexId] = i
            end
        elseif i == 5 then
            if backRecharge == false then
                closeDialog[indexId] = i
            end
        end
        self:registerClickEvent(tab, function(sender)self:tabButtonClick(sender, i) end)
        table.insert(self._tabEventTarget, tab)
    end

    local tabNum = 1
    for i=1,5 do
        local tab = self._tabEventTarget[i]
        if closeDialog[i] then
            tab:setVisible(false)
        else
            local tPos = tabPos[tabNum]
            tab:setPosition(tPos[1], tPos[2])
            tabNum = tabNum + 1
        end
    end
    print("tabNum========", tabNum)


    local uptabPos = {
        [1] = {582, 415},
        [2] = {461, 415},
        [3] = {341, 415},
    }
    local backActives = self._backflowModel:isActivesOpen()
    local backNests = self._backflowModel:isBackNestsOpen()
    self._uptabEventTarget = {}
    local closeUptabDialog = {}
    for i=1,3 do
        local tab = self:getUI("bg.allBg.rightPanel1.uptab" .. i)
        if i == 3 and backActives == false then
            tab:setVisible(false)
            closeUptabDialog[i] = i
        elseif i == 2 and backNests == false then
            tab:setVisible(false)
            closeUptabDialog[i] = i
        end
        self:registerClickEvent(tab, function(sender)self:tabUpButtonClick(sender, i) end)
        table.insert(self._uptabEventTarget, tab)
    end

    local uptabNum = 1
    for i=1,3 do
        local tab = self._uptabEventTarget[i]
        if closeUptabDialog[i] then
            tab:setVisible(false)
        else
            local tPos = uptabPos[uptabNum]
            tab:setPosition(tPos[1], tPos[2])
            uptabNum = uptabNum + 1
        end
    end

    self._receiveCell = self:getUI("receiveCell")
    self._receiveCell:setVisible(false)
    self._soldCell = self:getUI("soldCell")
    self._soldCell:setVisible(false)

    -- local backNests = self._backflowModel:getBaseData()
    -- dump(backNests)
    -- -- local backNests = self._backflowModel:getLoginData()
    -- -- dump(backNests)
    -- -- local backNests = self._backflowModel:getBarrackData()
    -- -- dump(backNests)
    -- local backNests = self._backflowModel:getSaleData()
    -- dump(backNests)
    -- local backNests = self._backflowModel:isBackNestsOpen()
    -- dump(backNests)
    -- local backNests = self._backflowModel:getReturnPrivilege()
    -- dump(backNests)


    self:addWelfareTableView()
    self:addSaleTableView()

    self:tabButtonClick(self._tabEventTarget[self._index], self._index)
    self:tabUpButtonClick(self._uptabEventTarget[self._welfareIndex], self._welfareIndex)
    -- self:listenReflash("CityBattleModel", self.listenModel)
    self:reciprocalTime()
    self:updateBackflowTip()
    self:setEnableOutLine()

    self:listenReflash("BackflowModel", self.updateBackFlow)
end

function BackflowView:setEnableOutLine()
    -- layer1
    -- layer2
    -- layer3
    for i=1,3 do
        local pname = self:getUI("bg.allBg.rightPanel3.acbuff" .. i .. ".pname")
        pname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local actionName = self:getUI("bg.allBg.rightPanel3.acbuff" .. i .. ".actionName")
        actionName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    
    -- layer4
    for i=1,2 do
        local desLab = self:getUI("bg.allBg.rightPanel4.awardBg.desLab" .. i)
        desLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    -- layer5
    for i=1,4 do
        local tname = self:getUI("bg.allBg.rightPanel5.scrollView.acBg" .. i .. ".nameBg.tname")
        tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local tipLab = self:getUI("bg.allBg.rightPanel5.scrollView.acBg" .. i .. ".nameBg.tipLab")
        tipLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local valueLab = self:getUI("bg.allBg.rightPanel5.scrollView.acBg" .. i .. ".nameBg.valueLab")
        valueLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    local timeLab1 = self:getUI("bg.allBg.rightPanel1.timerBg.timeLab")
    local timeLab2 = self:getUI("bg.allBg.rightPanel2.titleBg.timerBg.timeLab")
    local timeLab3 = self:getUI("bg.allBg.rightPanel3.des4")
    local timeLab4 = self:getUI("bg.allBg.rightPanel4.timerBg.timeLab")
    local timeLab5 = self:getUI("bg.allBg.rightPanel5.titleBg.timerBg.timeLab")
    timeLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    timeLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    timeLab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    timeLab4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    timeLab5:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local tipLab1 = self:getUI("bg.allBg.rightPanel1.timerBg.tipLab")
    local tipLab2 = self:getUI("bg.allBg.rightPanel2.titleBg.timerBg.tipLab")
    local tipLab3 = self:getUI("bg.allBg.rightPanel3.des4")
    local tipLab4 = self:getUI("bg.allBg.rightPanel4.timerBg.tipLab")
    local tipLab5 = self:getUI("bg.allBg.rightPanel5.titleBg.timerBg.tipLab")
    tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tipLab2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tipLab3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tipLab4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    tipLab5:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local des1 = self:getUI("bg.allBg.rightPanel3.des1")
    local des2 = self:getUI("bg.allBg.rightPanel3.des2")
    local des3 = self:getUI("bg.allBg.rightPanel3.des3")
    des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    des3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
end

function BackflowView:test()
    -- local flowData = self._backflowModel:getBlessData()
    -- -- local flowData = self._backflowModel:getRechargeData()
    -- dump(flowData)
    self:updateBackflowTip()
end

function BackflowView:refreshTabData(name)
    for i=1,5 do
        local rightPanel = self:getUI("bg.allBg.rightPanel" .. i)
        rightPanel:setVisible(false)
    end
    if name == "tab1" then

        self._index = 1
    elseif name == "tab2" then

        self._index = 2
    elseif name == "tab3" then
        self:test()
        self._index = 3
    elseif name == "tab4" then

        self._index = 4
    elseif name == "tab5" then

        self._index = 5
    end
    local layerId = self._panelMap[(self._index or 1)]
    print("self._index=============", self._index, layerId)
    self["updateACLayer" .. layerId](self)
    self._tabName = name
end

--[[
--! @function refreshUpTabData
--! @desc 更新tab界面
--! @param name 字符串 tab名称
--! @return 
--]]
function BackflowView:refreshUpTabData(name)
    -- self._tableView:removeAllChildren()
    print("name=====", name)
    local data = {}
    if name == "uptab1" then
        local loginData = self._backflowModel:getLoginData()
        self._welfareData = loginData
        self._welfareIndex = 1
    elseif name == "uptab2" then
        local barrackData = self._backflowModel:getBarrackData()
        self._welfareData = barrackData
        self._welfareIndex = 2
    elseif name == "uptab3" then
        self._welfareData = {}
        local barrackData = self._backflowModel:getActiveData()
        self._welfareData = barrackData
        self._welfareIndex = 3
    end
    self._uptabName = name
    self._welfareTableView:reloadData()
    self:scrollToNext()
end

function BackflowView:updateACLayer1()
    print("updateACLayer1=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 1)
    rightPanel:setVisible(true)
end

function BackflowView:updateACLayer2()
    print("updateACLayer1=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 2)
    rightPanel:setVisible(true)

    self._saleData = self._backflowModel:getSaleData()
    self._saleDataTableView:reloadData()
end

function BackflowView:updateACLayer3()
    print("updateACLayer1=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 3)
    rightPanel:setVisible(true)
    local blessTab = {
        [1] = "heroAttr",
        [2] = "donateRate",
        [3] = "exploreSupply",
    }
    local taskTab = {
        [1] = lang("RECOVER_BACK__VALUE1"),
        [2] = "首次捐献y折",
        [3] = lang("RECOVER_BACK__VALUE3"),
        [4] = lang("RECOVER_BACK__VALUE4"),
        [5] = "行动力回复速度",
        [6] = lang("RECOVER_BACK__VALUE6"),
    }

    local flowData = self._backflowModel:getBlessData()
    for i=1,3 do
        local acbuff = self:getUI("bg.allBg.rightPanel3.acbuff" .. i)
        local tipLab = self:getUI("bg.allBg.rightPanel3.acbuff" .. i .. ".tipLab")
        local tData = flowData[blessTab[i]]
        -- dump(tData)
        local str = "???"
        if flowData.blessed == 1 then
            if i == 1 then
                local taskType = 6
                local tstr = taskTab[taskType]
                str = string.gsub(tstr, "$value", tData)
            elseif i == 2 then
                local taskType = tData.taskType
                if taskType == 1 or taskType == 3 then
                    local tstr = taskTab[taskType]
                    str = string.gsub(tstr, "$times", tData.times)
                    str = string.gsub(str, "$discount", tData.discount)
                end
            elseif i == 3 then
                local taskType = tData.taskType
                if taskType == 4 then
                    local tstr = taskTab[taskType]
                    str = string.gsub(tstr, "$value", tData.value)
                end
            end
        else
            if i == 1 then
                local taskType = 6
                local tstr = taskTab[taskType]
                str = string.gsub(tstr, "$value", "???")
            elseif i == 2 then
                local taskType = 3
                local tstr = taskTab[taskType]
                str = string.gsub(tstr, "$times", "?")
                str = string.gsub(str, "至尊捐献", "?")
                str = string.gsub(str, "$discount", "?")
            elseif i == 3 then
                local tstr = taskTab[4]
                str = string.gsub(tstr, "$value", "???")
            end
        end
        local richText = tipLab:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        richText = RichTextFactory:create(str, 180, 40)
        richText:formatText()
        richText:setName("richText" .. i)
        richText:setPosition(tipLab:getContentSize().width*0.5, tipLab:getContentSize().height*0.5)
        tipLab:addChild(richText)
    end

    if flowData.blessed == 1 then
        local wishBtn = self:getUI("bg.allBg.rightPanel3.wishBtn")
        wishBtn:setSaturation(-100)
        if wishBtn.lingquAnim then
            wishBtn.lingquAnim:setVisible(false)
        end
        self:registerClickEvent(wishBtn, function()
            self._viewMgr:showTip(lang("RECOVER_BACK_4"))
        end)
    else
        local wishBtn = self:getUI("bg.allBg.rightPanel3.wishBtn")
        wishBtn:setSaturation(0)
        local isOpen, toBeOpen = SystemUtils["enableGuild"]()
        if isOpen == true then
            if not wishBtn.lingquAnim then
                local lingquAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
                end)
                lingquAnim:setName("lingquAnim")
                lingquAnim:setPosition(wishBtn:getContentSize().width*0.5, wishBtn:getContentSize().height*0.5)
                wishBtn:addChild(lingquAnim, 1)
                wishBtn.lingquAnim = lingquAnim
            else
                wishBtn.lingquAnim:setVisible(true)
            end
        end
        self:registerClickEvent(wishBtn, function()
            local flag = self._userModel:getIdGuildOpen()
            if flag == true then
                self:blessWishing()
            else
                if isOpen == true then
                    DialogUtils.showShowSelect({desc = "加入联盟后才能许愿，是否要加入联盟？",callback1=function( )
                        self._viewMgr:showView("guild.join.GuildInView", {})
                    end})
                else
                    self._viewMgr:showTip(lang("TIP_Guild"))
                end
            end
        end)
    end
end

function BackflowView:updateACLayer4()
    print("updateACLayer1=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 4)
    rightPanel:setVisible(true)

    local costValue = self:getUI("bg.allBg.rightPanel4.costValue")
    local awardBg = self:getUI("bg.allBg.rightPanel4.awardBg")
    local awardBtn = self:getUI("bg.allBg.rightPanel4.awardBg.awardBtn")
    local desLab1 = self:getUI("bg.allBg.rightPanel4.awardBg.desLab1")
    local desLab2 = self:getUI("bg.allBg.rightPanel4.awardBg.desLab2")
    local rechargeData = self._backflowModel:getRechargeData()
    dump(rechargeData)
    local rechargeLimit = rechargeData.rechargeLimit
    local rechargeNum = rechargeData.rechargeNum
    local rechargeTab = {
        [6] = "backflowImageUI_img3.png",
        [18] = "backflowImageUI_img4.png",
        [30] = "backflowImageUI_img5.png",
        [98] = "backflowImageUI_img6.png",
        [198] = "backflowImageUI_img101.png",
    }
    if costValue then
        costValue:loadTexture(rechargeTab[rechargeLimit], 1)
    end
    local awardItem = rechargeData.goodDataInfo
    local tawardData = {}
    if awardItem then
        for i=1,table.nums(awardItem) do
            local indexId = tostring(i)
            local num = awardItem[indexId]["num"]
            local itemId = awardItem[indexId]["typeId"]
            tawardData[i] = {}
            tawardData[i][1] = awardItem[indexId]["type"]
            tawardData[i][2] = itemId
            tawardData[i][3] = num
            if awardItem[indexId]["type"] ~= "tool" then
                itemId = IconUtils.iconIdMap[awardItem[indexId]["type"]]
            end
            local itemIcon = awardBg:getChildByName("itemIcon" .. i)
            local param = {itemId = itemId, num = num}

            if itemIcon then
                IconUtils:updateItemIconByView(itemIcon, param)
            else
                itemIcon = IconUtils:createItemIconById(param)
                itemIcon:setScale(0.8)
                itemIcon:setPosition(-95+125*i, 102)
                itemIcon:setName("itemIcon" .. i)
                awardBg:addChild(itemIcon)
            end
        end
    end
    local hasReceived = rechargeData.hasReceived
    if awardBtn then
        if hasReceived == 0 then
            awardBtn:setSaturation(0)
            if rechargeNum >= rechargeLimit then
                if not awardBtn.lingquAnim then
                    local lingquAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
                    end)
                    lingquAnim:setName("lingquAnim")
                    lingquAnim:setPosition(awardBtn:getContentSize().width*0.5, awardBtn:getContentSize().height*0.5)
                    awardBtn:addChild(lingquAnim, 1)
                    awardBtn.lingquAnim = lingquAnim
                else
                    awardBtn.lingquAnim:setVisible(true)
                end

                self:registerClickEvent(awardBtn, function()
                    local callback = function(selectItem)
                        local params = {id = selectItem}
                        if self.receiveRechargeWelfare then
                            self:receiveRechargeWelfare(params)
                        else
                            ViewManager:getInstance():showTip(lang("OVERDUETIPS_1"))
                        end
                    end
                    local param = {gift = tawardData, callback = callback}
                    self._viewMgr:showDialog("global.GlobalSelectAwardDialog", param)
                end)
            else
                if awardBtn.lingquAnim then
                    awardBtn.lingquAnim:setVisible(false)
                end
                self:registerClickEvent(awardBtn, function()
                    DialogUtils.showNeedCharge({desc = "充值额度不足，请前往充值", callback1=function( )
                        local viewMgr = ViewManager:getInstance()
                        local callback = function()
                            self:getBackFlowInfo()
                        end
                        viewMgr:showView("vip.VipView", {viewType = 0, callback = callback})
                    end})
                end)
            end
        else
            if awardBtn.lingquAnim then
                awardBtn.lingquAnim:setVisible(false)
            end
            awardBtn:setSaturation(-100)
            self:registerClickEvent(awardBtn, function()
                self._viewMgr:showTip("您已领取了奖励")
            end)
        end
    end
end

function BackflowView:updateACLayer5()
    print("updateACLayer1=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 5)
    rightPanel:setVisible(true)
    local buff = {
        [1] = "dragonCountry",
        [2] = "cloudCity",
        [3] = "battle",
        [4] = "element",
    }

    local privilegeData = self._backflowModel:getReturnPrivilege()
    for i=1,4 do
        local acBg = self:getUI("bg.allBg.rightPanel5.scrollView.acBg" .. i)
        local gotoView = self:getUI("bg.allBg.rightPanel5.scrollView.acBg" .. i .. ".gotoView")
        local buffOpen = privilegeData[buff[i]]
        print("==========", buff[i], buffOpen)
        if buffOpen == 1 then
            acBg:setVisible(true)
            if i == 1 then
                self:registerClickEvent(gotoView, function()
                    self._viewMgr:showView("pve.DragonView") 
                end)
            elseif i == 2 then
                self:registerClickEvent(gotoView, function()
                    self._viewMgr:showView("cloudcity.CloudCityView")
                end)
            elseif i == 3 then
                self:registerClickEvent(gotoView, function()
                    self._viewMgr:showView("crusade.CrusadeView")
                end)
            elseif i == 4 then
                self:registerClickEvent(gotoView, function()
                    self._viewMgr:showView("elemental.ElementalView")
                end)
            end
        else
            acBg:setVisible(false)
            self:registerClickEvent(gotoView, function()
                self._viewMgr:showTip("未到开启等级")
            end)
        end
    end

end


-- layer1
    --[[
    用tableview实现
    --]]
    function BackflowView:addWelfareTableView()
        local tableViewBg = self:getUI("bg.allBg.rightPanel1.tableViewBg")

        self._welfareTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
        self._welfareTableView:setDelegate()
        self._welfareTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self._welfareTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._welfareTableView:setAnchorPoint(0, 0)
        self._welfareTableView:setPosition(5, 0)
        self._welfareTableView:registerScriptHandler(function(table, idx) return self:cellSizeForWelfareTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
        self._welfareTableView:registerScriptHandler(function(table, idx) return self:tableWelfareCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
        self._welfareTableView:registerScriptHandler(function(table) return self:numberOfWelfareCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._welfareTableView:setBounceable(true)
        -- if self._welfareTableView.setDragSlideable ~= nil then 
        --     self._welfareTableView:setDragSlideable(true)
        -- end
        tableViewBg:addChild(self._welfareTableView)
    end

    -- cell的尺寸大小
    function BackflowView:cellSizeForWelfareTable(table,idx) 
        local width = 625
        local height = 110
        return height, width
    end

    -- 创建在某个位置的cell
    function BackflowView:tableWelfareCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local param = self._welfareData[idx+1]
        local indexId = idx + 1
        if nil == cell then
            cell = cc.TableViewCell:new()
            local receiveCell = self._receiveCell:clone() 
            receiveCell:setVisible(true)
            receiveCell:setAnchorPoint(0, 0)
            receiveCell:setPosition(0, 0) --0
            receiveCell:setName("receiveCell")
            cell:addChild(receiveCell)

            -- local fightPanel = self:getUI("bg.fightPanel")
            -- fightPanel:setVisible(false)
            -- local fightPanel = receiveCell:getChildByFullName("fightPanel")
            -- fightPanel:setVisible(false)
            -- nameBg:setOpacity(100)
            -- local name = receiveCell:getChildByFullName("name")

            -- local bg1 = receiveCell:getChildByFullName("bg1")
            -- -- local bg2 = receiveCell:getChildByFullName("bg2")
            -- titleCell:setCapInsets(cc.rect(25, 25, 1, 1))
            -- bg1:setCapInsets(cc.rect(25, 25, 1, 1))
            local awardBtn = receiveCell:getChildByFullName("awardBtn")
            UIUtils:setButtonFormat(awardBtn, 5)

            local lingquAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
            end)
            lingquAnim:setName("lingquAnim")
            lingquAnim:setPosition(awardBtn:getContentSize().width*0.5, awardBtn:getContentSize().height*0.5)
            awardBtn:addChild(lingquAnim, 1)
            awardBtn.lingquAnim = lingquAnim

            local awardBtn = receiveCell:getChildByFullName("btnType3.awardBtn")
            local lingquAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
            end)
            lingquAnim:setName("lingquAnim")
            lingquAnim:setPosition(awardBtn:getContentSize().width*0.5, awardBtn:getContentSize().height*0.5)
            awardBtn:addChild(lingquAnim, 1)
            awardBtn.lingquAnim = lingquAnim
            self:updateWelfareCell(receiveCell, param, indexId)
        else
            print("wo shi shua xin")
            local receiveCell = cell:getChildByName("receiveCell")
            if receiveCell then
                self:updateWelfareCell(receiveCell, param, indexId)
            end
        end

        return cell
    end

    -- 返回cell的数量
    function BackflowView:numberOfWelfareCellsInTableView(table)
        return self:cellWelfareLineNum() -- 
    end

    function BackflowView:cellWelfareLineNum()
        return table.nums(self._welfareData) 
    end

    function BackflowView:updateWelfareCell(inView, data, indexId)
        -- dump(data)
        local tableType = data.tableType

        local cellBg = inView:getChildByFullName("cellBg")
        local des1 = inView:getChildByFullName("des1")
        local dayNum = inView:getChildByFullName("dayNum")
        local des2 = inView:getChildByFullName("des2")
        des1:setString("活动期间登录")
        dayNum:setString(indexId)
        des2:setString("天")
        local dayNumPosX = 15

        local btnType3 = inView:getChildByFullName("btnType3")
        local awardBtn = inView:getChildByFullName("awardBtn")
        awardBtn:setVisible(true)
        btnType3:setVisible(false)
        local lingquAnim = awardBtn.lingquAnim
        local loginDay = self._flowBaseData.loginDay
        local awardItem = {}
        if tableType == 2 then
            local receive = data.loginReceived
            if awardBtn then
                if loginDay >= indexId then
                    awardBtn:setSaturation(0)
                    if lingquAnim then
                        lingquAnim:setVisible(true)
                    end
                    self:registerClickEvent(awardBtn, function()
                        local param = {type = 1, days = indexId}
                        self:receiveLoginWelFare(param)
                    end)
                else
                    if lingquAnim then
                        lingquAnim:setVisible(false)
                    end
                    awardBtn:setSaturation(-100)
                    self:registerClickEvent(awardBtn, function()
                        self._viewMgr:showTip(lang("RECOVER_BACK_1"))
                    end)
                end
            end
            local yilingqu = inView:getChildByFullName("yilingqu")
            if yilingqu then
                if receive == 0 then
                    yilingqu:setVisible(false)
                    awardBtn:setVisible(true)
                    cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
                else
                    yilingqu:setVisible(true)
                    awardBtn:setVisible(false)
                    cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
                end
            end
            awardItem = data.loginAward
        elseif tableType == 1 then
            local receive = data.barrackReceived
            if awardBtn then
                if loginDay >= indexId then
                    awardBtn:setSaturation(0)
                    if lingquAnim then
                        lingquAnim:setVisible(true)
                    end
                    self:registerClickEvent(awardBtn, function()
                        local param = {type = 2, days = indexId}
                        self:receiveLoginWelFare(param)
                    end)
                else
                    if lingquAnim then
                        lingquAnim:setVisible(false)
                    end
                    awardBtn:setSaturation(-100)
                    self:registerClickEvent(awardBtn, function()
                        self._viewMgr:showTip(lang("RECOVER_BACK_1"))
                        dump(data)
                    end)
                end
            end
            local yilingqu = inView:getChildByFullName("yilingqu")
            local lingquAnim = awardBtn.lingquAnim
            if yilingqu then
                if receive == 0 then
                    awardBtn:setVisible(true)
                    yilingqu:setVisible(false)
                    cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
                else
                    awardBtn:setVisible(false)
                    yilingqu:setVisible(true)
                    cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
                end
            end
            awardItem = data.award
        elseif tableType == 3 then
            awardBtn:setVisible(false)
            btnType3:setVisible(true)
            local awardBtn = inView:getChildByFullName("btnType3.awardBtn")
            local labNum = inView:getChildByFullName("btnType3.labNum")
            local lingquAnim = awardBtn.lingquAnim
            local receive = data.st
            local activeNum = self._flowBaseData.activeNum
            local limit = data.limit
            des1:setString("累计活跃达到")
            dayNum:setString(limit)
            des2:setString("")
            labNum:setString(activeNum .. "/" .. limit)
            labNum:setVisible(true)
            dayNumPosX = 30
            if awardBtn then
                if activeNum >= limit then
                    awardBtn:setSaturation(0)
                    if lingquAnim then
                        lingquAnim:setVisible(true)
                    end
                    self:registerClickEvent(awardBtn, function()
                        local param = {id = indexId}
                        self:getActiveReward(param)
                    end)
                else
                    if lingquAnim then
                        lingquAnim:setVisible(false)
                    end
                    awardBtn:setSaturation(-100)
                    self:registerClickEvent(awardBtn, function()
                        self._viewMgr:showTip(lang("RECOVER_BACK_1"))
                        dump(self._flowBaseData)
                        dump(data)
                    end)
                end
            end
            local yilingqu = inView:getChildByFullName("yilingqu")
            local lingquAnim = awardBtn.lingquAnim
            if yilingqu then
                if receive == 0 then
                    awardBtn:setVisible(true)
                    yilingqu:setVisible(false)
                    cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
                else
                    awardBtn:setVisible(false)
                    labNum:setVisible(false)
                    yilingqu:setVisible(true)
                    cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
                end
            end
            awardItem = data.award
        end

        dayNum:setPositionX(des1:getPositionX()+des1:getContentSize().width+dayNumPosX)


        if awardItem then
            for i=1,table.nums(awardItem) do
                local num = awardItem[i]["num"]
                local itemId = awardItem[i]["typeId"]
                if awardItem[i]["type"] ~= "tool" then
                    itemId = IconUtils.iconIdMap[awardItem[i]["type"]]
                end
                local itemIcon = inView:getChildByName("itemIcon" .. i)
                local param = {itemId = itemId, num = num}
                if itemIcon then
                    IconUtils:updateItemIconByView(itemIcon, param)
                else
                    itemIcon = IconUtils:createItemIconById(param)
                    itemIcon:setScale(0.7)
                    itemIcon:setPosition(130+80*i, 18)
                    itemIcon:setName("itemIcon" .. i)
                    inView:addChild(itemIcon)
                end
            end
        end
    end

-- layer2
    --[[
    用tableview实现
    --]]
    function BackflowView:addSaleTableView()
        local tableViewBg = self:getUI("bg.allBg.rightPanel2.tableViewBg")

        self._saleDataTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
        self._saleDataTableView:setDelegate()
        self._saleDataTableView:setDirection(0)
        self._saleDataTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self._saleDataTableView:setAnchorPoint(0, 0)
        self._saleDataTableView:setPosition(5, 2)
        self._saleDataTableView:registerScriptHandler(function(table, idx) return self:cellSizeForSaleTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
        self._saleDataTableView:registerScriptHandler(function(table, idx) return self:tableSaleCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
        self._saleDataTableView:registerScriptHandler(function(table) return self:numberOfSaleCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._saleDataTableView:setBounceable(true)
        -- if self._saleDataTableView.setDragSlideable ~= nil then 
        --     self._saleDataTableView:setDragSlideable(true)
        -- end
        tableViewBg:addChild(self._saleDataTableView)
    end

    -- cell的尺寸大小
    function BackflowView:cellSizeForSaleTable(table,idx) 
        local width = 210
        local height = 335
        return height, width
    end

    -- 创建在某个位置的cell
    function BackflowView:tableSaleCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local param = self._saleData[idx+1]
        local indexId = idx + 1
        if nil == cell then
            cell = cc.TableViewCell:new()
            local soldCell = self._soldCell:clone() 
            soldCell:setVisible(true)
            soldCell:setAnchorPoint(0, 0)
            soldCell:setPosition(0, 0) --0
            soldCell:setName("soldCell")
            cell:addChild(soldCell)

            -- local fightPanel = self:getUI("bg.fightPanel")
            -- fightPanel:setVisible(false)
            -- local fightPanel = receiveCell:getChildByFullName("fightPanel")
            -- fightPanel:setVisible(false)
            -- nameBg:setOpacity(100)
            local costNum = soldCell:getChildByFullName("gotoView.costNum")
            costNum:setColor(UIUtils.colorTable.ccUICommonBtnColor2)
            costNum:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2)
            -- local bg1 = receiveCell:getChildByFullName("bg1")
            -- -- local bg2 = receiveCell:getChildByFullName("bg2")
            -- titleCell:setCapInsets(cc.rect(25, 25, 1, 1))
            -- bg1:setCapInsets(cc.rect(25, 25, 1, 1))

            self:updateSaleCell(soldCell, param, indexId)
        else
            print("wo shi shua xin")
            local soldCell = cell:getChildByName("soldCell")
            if soldCell then
                self:updateSaleCell(soldCell, param, indexId)
            end
        end

        return cell
    end

    -- 返回cell的数量
    function BackflowView:numberOfSaleCellsInTableView(table)
        return self:cellSaleLineNum() -- 
    end

    function BackflowView:cellSaleLineNum()
        return table.nums(self._saleData) 
    end

    function BackflowView:updateSaleCell(inView, data, indexId)
        dump(data)
        local itemId = data["typeId"]
        if data["ttype"] ~= "tool" then
            itemId = IconUtils.iconIdMap[data["ttype"]]
        end
        print("itemId==========", itemId)
        local toolTab = tab:Tool(itemId)

        local itemName = inView:getChildByFullName("itemName")
        local itemNumLab = inView:getChildByFullName("itemNumBg.itemNumLab")
        local soldout = inView:getChildByFullName("soldout")
        local gotoView = inView:getChildByFullName("gotoView")
        local costImg = inView:getChildByFullName("gotoView.costImg")
        local costNum = inView:getChildByFullName("gotoView.costNum")

        local priceInfo = data.priceInfo
        local price = {}
        local maxCount = 1
        for i=1,table.nums(priceInfo) do
            local priceTab = priceInfo["price" .. i]
            if priceTab["buyTimes"] < priceTab["totalTimes"] then
                maxCount = i
                price = priceTab
                break
            end
        end
        if not price["totalTimes"] then
            price = priceInfo["price" .. maxCount]
        end
        itemName:setString(lang(toolTab.name))
        local costPrice = (price["totalTimes"] or 0)-(price["buyTimes"] or 0)
        itemNumLab:setString("剩余" .. costPrice .. "次")
        costNum:setString((price["price"] or 10000))
        local posX = (gotoView:getContentSize().width - costImg:getContentSize().width - costNum:getContentSize().width-10)*0.5
        costImg:setPositionX(posX)
        posX = posX + costImg:getContentSize().width+5
        costNum:setPositionX(posX)

        local num = (price["num"] or 0)
        local itemIcon = inView:getChildByName("itemIcon")
        local param = {itemId = itemId, num = num}
        if itemIcon then
            IconUtils:updateItemIconByView(itemIcon, param)
        else
            itemIcon = IconUtils:createItemIconById(param)
            itemIcon:setScale(0.9)
            itemIcon:setPosition(58, 160)
            itemIcon:setName("itemIcon")
            inView:addChild(itemIcon)
        end

        if gotoView then
            if costPrice == 0 then
                gotoView:setVisible(false)
                if soldout then
                    soldout:setVisible(true)
                end
            else
                if soldout then
                    soldout:setVisible(false)
                end
                gotoView:setVisible(true)
                local gem = self._userModel:getData().gem
                if gem >= price["price"] then
                    self:registerClickEvent(gotoView, function()
                        local param = {id = indexId}
                        self:buyReturnSaleGoods(param)
                    end)
                else
                    self:registerClickEvent(gotoView, function()
                        DialogUtils.showNeedCharge({desc = lang("RECOVER_BACK_2"), callback1=function( )
                            local viewMgr = ViewManager:getInstance()
                            local callback = function()
                                self:getBackFlowInfo()
                            end
                            viewMgr:showView("vip.VipView", {viewType = 0, callback = callback})
                        end})
                    end)
                end
            end
        end
    end

function BackflowView:buySaleData(saleData)
     
end


function BackflowView:tabButtonState(sender, isSelected, key)
    local titleNames = self._titleNames
    local shortTitleNames = self._shortTitleNames


    local text = sender:getChildByFullName("text")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    -- sender:getTitleRenderer():disableEffect()
    -- sender:setTitleFontSize(24)
    -- sender:setTitleFontName(UIUtils.ttfName)
    if isSelected then
        text:disableEffect()
        text:setString(titleNames[key])
        text:setColor(cc.c3b(255, 255, 255))
        text:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
    else
        text:disableEffect()
        text:setString(shortTitleNames[key])
        text:setColor(cc.c3b(60, 42, 30))
        -- sender:setTitleText(shortTitleNames[key])
        -- sender:setTitleColor(cc.c3b(130, 100, 70))
    end
end

function BackflowView:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        self:tabButtonState(v, false, k)
    end
    self:tabButtonState(sender, true, key)
    self:refreshTabData(sender:getName())
    self._tabName = sender:getName()
    audioMgr:playSound("Tab")
end


    function BackflowView:uptabButtonState(sender, isSelected, key)
        -- local titleNames = {
        --     " 登录福利 ",
        --     " 兵营资源 ",
        --     " 未开放 ",
        -- }
        -- local shortTitleNames = {
        --     " 登录福利 ",
        --     " 兵营资源 ",
        --     " 未开放 ",
        -- }

        -- local text = sender:getChildByFullName("text")

        sender:setBright(not isSelected)
        sender:setEnabled(not isSelected)
        -- sender:getTitleRenderer():disableEffect()
        -- sender:setTitleFontSize(24)
        -- sender:setTitleFontName(UIUtils.ttfName)
        -- if isSelected then
        --     text:disableEffect()
        --     text:setString(titleNames[key])
        --     -- text:setColor(cc.c3b(255, 255, 255))
        --     -- text:enableOutline(UIUtils.colorTable.titleOutLineColor, 1)
        -- else
        --     text:disableEffect()
        --     text:setString(shortTitleNames[key])
        --     -- text:setColor(cc.c3b(60, 42, 30))
        --     -- sender:setTitleText(shortTitleNames[key])
        --     -- sender:setTitleColor(cc.c3b(130, 100, 70))
        -- end
    end

    function BackflowView:tabUpButtonClick(sender, key)
        if sender == nil then 
            return 
        end
        if self._uptabName == sender:getName() then 
            return 
        end
        for k,v in pairs(self._uptabEventTarget) do
            self:uptabButtonState(v, false, k)
        end
        self:uptabButtonState(sender, true, key)
        self:refreshUpTabData(sender:getName())
        self._uptabName = sender:getName()
        audioMgr:playSound("Tab")
    end

-- function BackflowView:listenModel(inType)
--     print("inType==============================================", inType)
--     if inType == nil then
--         return
--     end

--     if self["reflash" .. inType] then
--         self["reflash" .. inType](self)
--     else
--         -- if self._worldLayer ~= nil then 
--         --     if self._worldLayer["listenModel" .. inType] == nil then
--         --         print("BackflowView: Not found listenModel" .. inType)
--         --         return
--         --     end
--         --     self._worldLayer["listenModel" .. inType](self._mapLayer)
--         --     -- print("inType--------------------------------------------------", inType)
--         --     -- dump(self._guildMapModel:getEvents())
--         -- end
--     end
-- end


function BackflowView:getAsyncRes()
    return 
        {
            {"asset/ui/backflow.plist", "asset/ui/backflow.png"},
            {"asset/ui/backflow1.plist", "asset/ui/backflow1.png"},
        }
end

-- 领取登录福利
function BackflowView:receiveLoginWelFare(param)
    if not param then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("BackFlowServer", "receiveLoginWelFare", param, true, {}, function (result)
        dump(result, "indexId=====", 10)
        DialogUtils.showGiftGet( {
            gifts = result.reward,
            callback = function()
        end})
        self._welfareTableView:reloadData()
        self:updateBackflowTip()
        self:scrollToNext()
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 7420 then
            self._viewMgr:showTip(lang("OVERDUETIPS_1"))
        end
    end)
end

function BackflowView:getActiveReward(param)
    if not param then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("BackFlowServer", "getActiveReward", param, true, {}, function (result)
        dump(result, "indexId=====", 10)
        DialogUtils.showGiftGet( {
            gifts = result.reward,
            callback = function()
        end})
        self._welfareTableView:reloadData()
        self:updateBackflowTip()
        self:scrollToNext()
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 7420 then
            self._viewMgr:showTip(lang("OVERDUETIPS_1"))
        end
    end)
end

-- 购买特卖商品
function BackflowView:buyReturnSaleGoods(param)
    if not param then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("BackFlowServer", "buyReturnSaleGoods", param, true, {}, function (result)
        dump(result, "indexId=====", 10)
        DialogUtils.showGiftGet( {
            gifts = result.reward,
            callback = function()
        end})
        local offset = self._saleDataTableView:getContentOffset()
        self._saleDataTableView:reloadData()
        self._saleDataTableView:setContentOffset(cc.p(offset.x, offset.y), false)

        self:updateBackflowTip()
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 7420 then
            self._viewMgr:showTip(lang("OVERDUETIPS_1"))
        end
    end)
end

-- 领取充值特惠奖励
function BackflowView:receiveRechargeWelfare(param)
    if not param then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("BackFlowServer", "receiveRechargeWelfare", param, true, {}, function (result)
        dump(result, "indexId=====", 10)
        DialogUtils.showGiftGet( {
            gifts = result.reward,
            callback = function()
        end})
        self:updateBackFlow()
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 7420 then
            self._viewMgr:showTip(lang("OVERDUETIPS_1"))
        end
    end)
end


-- 回归祝福许愿
function BackflowView:blessWishing()
    self._serverMgr:sendMsg("BackFlowServer", "blessWishing", {}, true, {}, function (result)
        dump(result, "indexId=====", 10)
        self:blessWishingFinish(result)
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 7420 then
            self._viewMgr:showTip(lang("OVERDUETIPS_1"))
        end
    end)
end

function BackflowView:blessWishingFinish(result)
    for i=1,3 do
        local acbuff = self:getUI("bg.allBg.rightPanel3.acbuff" .. i)
        local mc1 = mcMgr:createViewMC("xuyuan_huiliuxuyuan", false, true, function (_, sender)
        end)
        mc1:setName("anim1")
        mc1:setPosition(acbuff:getContentSize().width*0.5+2, acbuff:getContentSize().height*0.5+30)
        acbuff:addChild(mc1, 1)
    end
    self:updateBackFlow()
end

function BackflowView:getBackFlowInfo()
    self._serverMgr:sendMsg("BackFlowServer", "getBackFlowInfo", {}, true, {}, function (result)
        self:updateBackFlow()
    end, function(errorId)
        local errorId = tonumber(errorId)
        if errorId == 7420 then
            self._viewMgr:showTip(lang("OVERDUETIPS_1"))
        end
    end)
end

function BackflowView:updateBackFlow()
    self._flowBaseData = self._backflowModel:getBaseData()
    local layerId = self._panelMap[(self._index or 1)]
    self["updateACLayer" .. layerId](self)
    self:updateBackflowTip()
end

function BackflowView:reciprocalTime()
    local baseData = self._backflowModel:getBaseData()
    dump(baseData)

    local timeLab1 = self:getUI("bg.allBg.rightPanel1.timerBg.timeLab")
    local timeLab2 = self:getUI("bg.allBg.rightPanel2.titleBg.timerBg.timeLab")
    local timeLab3 = self:getUI("bg.allBg.rightPanel3.des4")
    local timeLab4 = self:getUI("bg.allBg.rightPanel4.timerBg.timeLab")
    local timeLab5 = self:getUI("bg.allBg.rightPanel5.titleBg.timerBg.timeLab")

    local curServerTime = self._userModel:getCurServerTime()
    local endTime = baseData.endTime or 0
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local realTime = endTime - curServerTime
        if realTime < 0 then
            if self.close then
                self:close()
            end
            return
        end
        realTime = math.abs(realTime)
        local tday = math.floor(realTime/86400)
        local tTime = realTime - tday*86400
        local thour = math.floor(tTime/3600)
        tTime = tTime - thour*3600
        local tmin = math.floor(tTime/60)
        tTime = tTime - tmin*60
        local tsec = math.fmod(tTime, 60)
        local timerStr = string.format("%d天%.2d:%.2d:%.2d", tday, thour, tmin, tsec)
        if tday == 0 then
            timerStr = string.format("%.2d:%.2d:%.2d", thour, tmin, tsec)
        end
        if timeLab1 then
            timeLab1:setString(timerStr)
        end
        if timeLab2 then
            timeLab2:setString(timerStr)
        end
        if timeLab3 then
            timeLab3:setString(timerStr)
        end
        if timeLab4 then
            timeLab4:setString(timerStr)
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    timeLab1:runAction(cc.RepeatForever:create(seq))

    local curServerTime = self._userModel:getCurServerTime()
    local privilegeData = self._backflowModel:getReturnPrivilege()
    local endTime = privilegeData.endTime or baseData.endTime or 0
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local realTime = endTime - curServerTime
        if realTime < 0 then
            timeLab5:stopAllActions()
            return
        end
        realTime = math.abs(realTime)
        local tday = math.floor(realTime/86400)
        local tTime = realTime - tday*86400
        local thour = math.floor(tTime/3600)
        tTime = tTime - thour*3600
        local tmin = math.floor(tTime/60)
        tTime = tTime - tmin*60
        local tsec = math.fmod(tTime, 60)
        local timerStr = string.format("%d天%.2d:%.2d:%.2d", tday, thour, tmin, tsec)
        if tday == 0 then
            timerStr = string.format("%.2d:%.2d:%.2d", thour, tmin, tsec)
        end
        if timeLab5 then
            timeLab5:setString(timerStr)
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    timeLab5:runAction(cc.RepeatForever:create(seq))
end

function BackflowView:updateBackflowTip()
    local loginTip = self._backflowModel:getBackflowLoginTip()
    local barrackTip = self._backflowModel:getBackflowBarrackTip()
    local activeTip = self._backflowModel:getBackflowActiveTip()
    local rechargeTip = self._backflowModel:getBackflowRechargeTip()
    local blessTip = self._backflowModel:getBackflowBlessTip()

    local onUpTip1 = self:getUI("bg.allBg.rightPanel1.uptab1.onTip")
    if loginTip == true then
        onUpTip1:setVisible(true)
    else
        onUpTip1:setVisible(false)
    end

    local onUpTip2 = self:getUI("bg.allBg.rightPanel1.uptab2.onTip")
    if barrackTip == true then
        onUpTip2:setVisible(true)
    else
        onUpTip2:setVisible(false)
    end

    local onUpTip3 = self:getUI("bg.allBg.rightPanel1.uptab3.onTip")
    if activeTip == true then
        onUpTip3:setVisible(true)
    else
        onUpTip3:setVisible(false)
    end


    local onTip1 = self:getUI("bg.allBg.leftPanel.tab1.onTip")
    if loginTip == true or barrackTip == true or activeTip == true then
        onTip1:setVisible(true)
    else
        onTip1:setVisible(false)
    end
    local onTip3 = self:getUI("bg.allBg.leftPanel.tab" .. self._panelMap[5] .. ".onTip")
    if blessTip == true then
        onTip3:setVisible(true)
    else
        onTip3:setVisible(false)
    end
    local onTip4 = self:getUI("bg.allBg.leftPanel.tab" .. self._panelMap[2] .. ".onTip")
    if rechargeTip == true then
        onTip4:setVisible(true)
    else
        onTip4:setVisible(false)
    end
end


function BackflowView:scrollToNext()
    -- dump(self._welfareData)
    local welfareData = self._welfareData
    local scrollIndexId = 1
    for i=1,table.nums(welfareData) do
        local received = 1
        local tableType = welfareData[i].tableType
        if tableType == 2 then
            received = welfareData[i].loginReceived
        elseif tableType == 1 then
            received = welfareData[i].barrackReceived
        elseif tableType == 3 then
            received = welfareData[i].st
        end
        if received == 0 then
            scrollIndexId = i
            break
        end
    end
    print("scrollIndexId====", scrollIndexId)
    local selectedIndex = (scrollIndexId-1) or 0
    local allIndex = table.nums(welfareData)
    local begHeight = selectedIndex*110

    local scrollAnim = true
    local tempheight = self._welfareTableView:getContainer():getContentSize().height
    local tableViewBg = self:getUI("bg.allBg.rightPanel1.tableViewBg")
    local tabHeight = tempheight - tableViewBg:getContentSize().height
    print("containHeight==========", tabHeight)
    if tempheight < tableViewBg:getContentSize().height then
        self._welfareTableView:setContentOffset(cc.p(0, self._welfareTableView:getContentOffset().y), scrollAnim)
    else
        if (tempheight - begHeight) > tableViewBg:getContentSize().height then
            self._welfareTableView:setContentOffset(cc.p(0, -1*(tabHeight-begHeight)), scrollAnim)
        else
            self._welfareTableView:setContentOffset(cc.p(0, 0), scrollAnim)
        end
    end
end


return BackflowView