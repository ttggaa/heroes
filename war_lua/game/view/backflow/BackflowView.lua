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
    self._callback = data.callback
end

function BackflowView:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._backflowModel = self._modelMgr:getModel("BackflowModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._flowBaseData = self._backflowModel:getBaseData()

    local uData = self._userModel:getData()
    local dayPanel = self:getUI("bg.allBg.dayPanel")
    local dayPos = self:getUI("bg.allBg.dayPanel.dayPos")

    local dayNum = cc.Label:createWithBMFont(UIUtils.bmfName_backFlow, "00")
    dayNum:setName("dayNum")
    dayNum:setString((uData.statis and uData.statis.snum6) and uData.statis.snum6 or 0)
    dayNum:setAnchorPoint(cc.p(1,0))  
    dayNum:setPosition(122,65)
    dayNum:setScale(0.8)
    dayPanel:addChild(dayNum, 1)
    self._dayNum = dayNum

    local allBg = self:getUI("bg.allBg.allBg")
    allBg:loadTexture("asset/bg/activity_bg_paper.png")
    local closeBtn = self:getUI("bg.allBg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        UIUtils:reloadLuaFile("backflow.BackflowView")
        if self._callback then
            self._callback()
        end
        self:close()
    end)

    local tabPos = {
        [1] = {66, 300},
        [2] = {66, 238},
        [3] = {66, 176},
        [4] = {66, 114},
        [5] = {66, 52},
    }
    self._panelMap = {
        [1] = 1,
        [2] = 3,
        [3] = 2,
        [4] = 4,
        [5] = 5,
    }

    local titleNames = {
        " 免费放送 ",
        " 回归任务 ",
        " 回归特惠 ",
        " 直购特惠 ",
        " 特权专区 ",
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
    local backTask = self._backflowModel:isTaskOpen()

    local closeDialog = {}
     --     " 免费放送 ",
     --    " 回归任务 ",
     --    " 回归特惠 ",
     --    " 直购特惠 ",
     --    " 特权专区 ",
     --     [1] = 1,
     --    [2] = 3,
     --    [3] = 2,
     --    [4] = 4,
     --    [5] = 5,
    for i=1,5 do
        local tab = self:getUI("bg.allBg.leftPanel.tab" .. i)
        local indexId = self._panelMap[i]
        if indexId == 2 then
            if backSale == false then
                closeDialog[i] = indexId
            end
        elseif indexId == 3 then
            if backTask == false then
                closeDialog[i] = indexId
            end
        elseif indexId == 4 then
            if backRecharge == false then
                closeDialog[i] = indexId
            end
        elseif indexId == 5 then
            if backPrivilege == false then
                closeDialog[i] = indexId
            end
        end
        print("================iiiiii=========",i)
        self:registerClickEvent(tab, function(sender)self:tabButtonClick(sender, i) end)
        table.insert(self._tabEventTarget, tab)
    end
    -- dump(closeDialog,"closeDialog==>",5)
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

    self._loginCell = self:getUI("loginCell")
    self._loginCell:setVisible(false)
    self._soldCell = self:getUI("soldCell")
    self._soldCell:setVisible(false)
    self._taskCell = self:getUI("taskCell")
    self._taskCell:setVisible(false)

    self:addWelfareTableView()
    self:addSaleTableView()
    self:addTaskTableView()

    self:tabButtonClick(self._tabEventTarget[self._index], self._index)
    -- self:tabUpButtonClick(self._uptabEventTarget[self._welfareIndex], self._welfareIndex)
    -- self:listenReflash("CityBattleModel", self.listenModel)
    -- 登陆奖励展示
    local loginData = self._backflowModel:getLoginData()
    self._nextIdx = 1
    self._welfareData = loginData
    self._welfareIndex = 1
    self._welfareTableView:reloadData()
    self:scrollToNext()

    self:reciprocalTime()
    self:updateBackflowTip()
    self:setEnableOutLine()

    self:listenReflash("BackflowModel", self.updateBackFlow)
end

function BackflowView:setEnableOutLine()    
    -- layer4
    for i=1,2 do
        local desLab = self:getUI("bg.allBg.rightPanel4.awardBg.desLab" .. i)
        desLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end

    -- layer5
    for i=1,4 do
        local tname = self:getUI("bg.allBg.rightPanel5.buff" .. i .. ".buffTxt3")
        if tname then 
            tname:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
    end
    local titleTxt = self:getUI("bg.allBg.rightPanel5.priImg1.titleTxt")
    titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local timeLab1 = self:getUI("bg.allBg.timerBg.timeLab")
    timeLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local tipLab1 = self:getUI("bg.allBg.timerBg.tipLab")
    tipLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
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

-- 回归福利 免费放送
function BackflowView:updateACLayer1()
    print("updateACLayer11111=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 1)
    rightPanel:setVisible(true)

    if not self._rightArrow then
        self._rightArrow = ccui.Button:create()
        self._rightArrow:loadTextures("globalImageUI6_meiyoutu.png","globalImageUI6_meiyoutu.png","globalImageUI6_meiyoutu.png",1)
        self._rightArrow:setScale9Enabled(true)
        self._rightArrow:setContentSize(cc.size(54,68))
        self._rightArrow:setCapInsets(cc.rect(0, 0, 1, 1))

        local mc = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)        
        mc:setPosition(27,34)
        mc:setScaleX(-1)
        self._rightArrow:addChild(mc)
        self._rightArrow:setPosition(60,180)
        rightPanel:addChild(self._rightArrow,99)
        registerClickEvent(self._rightArrow, function()
            print("===============_rightArrow============")
            self:scrollBtnClick(-1)
        end)
    end

    if not self._leftArrow then
        self._leftArrow = ccui.Button:create()
        self._leftArrow:loadTextures("globalImageUI6_meiyoutu.png","globalImageUI6_meiyoutu.png","globalImageUI6_meiyoutu.png",1)
        self._leftArrow:setScale9Enabled(true)
        self._leftArrow:setContentSize(cc.size(54,68))
        self._rightArrow:setCapInsets(cc.rect(0, 0, 1, 1))

        local mc = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)     
        mc:setPosition(27,34)
        self._leftArrow:addChild(mc)
        self._leftArrow:setPosition(590,180)
        rightPanel:addChild(self._leftArrow,99)
        registerClickEvent(self._leftArrow, function()
            print("===============_leftArrow============")
            self:scrollBtnClick(1)
        end)
    end

end

-- 回归特卖
function BackflowView:updateACLayer2()
    print("updateACLayer22222=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 2)
    rightPanel:setVisible(true)

    self._saleData = self._backflowModel:getSaleData()
    self._saleDataTableView:reloadData()
end

-- 回归任务
function BackflowView:updateACLayer3()
    print("updateACLayer33333=====")
    local rightPanel = self:getUI("bg.allBg.rightPanel3")
    rightPanel:setVisible(true)

    local taskData,haveTips = self._backflowModel:processTaskData()
    self._taskData = taskData
    self._taskTableView:reloadData()

    local scoreTxt = self:getUI("bg.allBg.rightPanel3.activePanel.scoreTxt")
    scoreTxt:setString(self._backflowModel:getTaskDataScore())
    if not self._boxArr then 
        self:initBoxPanel()
    else
        self:updateBoxPanel()
    end
end

-- 更新数据
function BackflowView:updateACLayer3Data()
    print("=============updateACLayer3Data========")
    local layerId = self._panelMap[(self._index or 1)]
    if layerId ~= 3 then
        return
    end
    local taskData,haveTips = self._backflowModel:processTaskData()
    self._taskData = taskData
    self._taskTableView:reloadData()

end

function BackflowView:initBoxPanel()
    local mcName = {
        [1] = "baoxiang1_baoxiang",
        [2] = "baoxiang2_baoxiang",
        [3] = "baoxiang2_baoxiang",
        [4] = "baoxiang3_baoxiang",
        [5] = "baoxiang3_baoxiang",
    }
    local normalImg = {
        [1] = "box_1_n",
        [2] = "box_2_n",
        [3] = "box_2_n",
        [4] = "box_3_n",
        [5] = "box_3_n",
    }
    local getImg = {
        [1] = "box_1_p",
        [2] = "box_2_p",
        [3] = "box_2_p",
        [4] = "box_3_p",
        [5] = "box_3_p",
    }

    self._boxArr = {}
    local proBg = self:getUI("bg.allBg.rightPanel3.activePanel.proBg")
    local taskRewardData = self._backflowModel:getTaskRewardData()
    local score = self._backflowModel:getTaskDataScore()
    local boxNum = #taskRewardData

    local needCount
    local getMc
    self._maxCount = taskRewardData[boxNum] and taskRewardData[boxNum].accumulatepoints or 100

    -- dump(awardData,'awardData=》',5)      
    local proW = 456 / self._maxCount -- 总长360 100份
    for i=1,boxNum do
        local boxData = taskRewardData[i]
        local awardData = boxData.reward or {}
        local accumulatepoints = boxData.accumulatepoints or 0
        local box = ccui.Button:create()
        box:setPosition(proW*accumulatepoints,10)
        proBg:addChild(box,3)

        -- local img = ccui.ImageView:create()
        -- img:loadTexture("globalImageUI6_star1.png",1)
        -- img:setScale(0.5)
        -- img:setPosition(10,0)
        -- box:addChild(img)

        local numTxt = ccui.Text:create()
        numTxt:setFontSize(16)
        numTxt:setFontName(UIUtils.ttfName)
        numTxt:setString(""..accumulatepoints)
        numTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        numTxt:setAnchorPoint(0,0.5)
        numTxt:setPosition(15, 0)
        box:addChild(numTxt,2)
        
        box._needCount = accumulatepoints 
        if not mcName[i] then
            mcName[i] = "baoxiang3_baoxiang"
        end        
        if not normalImg[i] then
            getImg[i] = "box_3_n"
        end
        if not normalImg[i] then
            getImg[i] = "box_3_p"
        end
        getMc = mcMgr:createViewMC(mcName[i], true,false)
        getMc:setPosition(38,32)
        box:addChild(getMc)

        box._getMc = getMc
        box._normalImg = normalImg[i]
        box._getImg = getImg[i]

        box._rewardArr = awardData or {}

        box._normal = true
        box._isCanGet = false
        if score >= accumulatepoints then
            box._isCanGet = true
            box._normal = false
        end
        if boxData.status == 1 then
            box._normal = false
            box._isCanGet = false
        end
        getMc:setVisible(box._isCanGet)
        
        local imgName = box._normal and box._normalImg .. ".png" or box._getImg .. ".png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity(box._isCanGet and 0 or 255)
        box._id = boxData.id
        self:registerClickEvent(box, function (sender)
            self:taskBoxClicked(sender)
        end)
        self._boxArr[i] = box
    end

    self._progressBar = self:getUI("bg.allBg.rightPanel3.activePanel.proBg.bar")
    local proNum = score/self._maxCount*100
    if proNum > 100 then
        proNum = 100
    end
    self._progressBar:setPercent(score/self._maxCount*100)
end

function BackflowView:updateBoxPanel( )
    local taskRewardData = self._backflowModel:getTaskRewardData()
    local score = self._backflowModel:getTaskDataScore()
    for k,v in pairs(self._boxArr) do
        local box = v
        local boxData = taskRewardData[k]
        box._normal = true
        box._isCanGet = false
        local accumulatepoints = box._needCount
        if score >= accumulatepoints then
            box._isCanGet = true
            box._normal = false
        end
        if boxData.status == 1 then
            box._normal = false
            box._isCanGet = false
        end
        box._getMc:setVisible(box._isCanGet)        
        local imgName = box._normal and box._normalImg .. ".png" or box._getImg .. ".png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity(box._isCanGet and 0 or 255)
        
        self:registerClickEvent(box, function (sender)
            self:taskBoxClicked(sender)
        end)
        local proNum = score/self._maxCount*100
        if proNum > 100 then
            proNum = 100
        end
        self._progressBar:setPercent(score/self._maxCount*100)

    end
    
end

-- 充值特惠
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
    -- dump(rechargeData)
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
-- 回归特权

--[[

"battle" : NumberInt(1), 
"dragonCountry" : NumberInt(1), 
"cloudCity" : NumberInt(1), 
"element" : NumberInt(1), 
"endTime" : NumberInt(1529269200), 
"heroAttr" : NumberInt(100), 
"donateRate" : "{\"type\":1,\"taskType\":1,\"times\":2,\"discount\":0.2}", 
"exploreSupply" : "{\"type\":2,\"taskType\":4,\"value\":100}"
]]
function BackflowView:updateACLayer5()
    local rightPanel = self:getUI("bg.allBg.rightPanel" .. 5)
    rightPanel:setVisible(true)
    -- if true then return end
    local buffIndex = {
        [1] = "dragonCountry",
        [2] = "battle",
        [3] = "cloudCity",
        [4] = "element",
        [5] = "exploreSupply",
        [6] = "donateRate",
        [7] = "heroAttr"
    }


    local privilegeData = self._backflowModel:getReturnPrivilege()
    -- dump(privilegeData,"privilegeData==>",5)
    for i=1,7 do
        local buff = self:getUI("bg.allBg.rightPanel5.buff" .. i)
        buff:setVisible(false)
        local buffData = privilegeData[buffIndex[i]]
        print("=========12312=", buffIndex[i], buffOpen)
        if buffData ~= nil then
            buff:setVisible(true)
            if i == 5 then
                local data =  json.decode(buffData)
                local buffTxt2 = self:getUI("bg.allBg.rightPanel5.buff" .. i .. ".buffTxt2")
                buffTxt2:setString("每日赠送行动力" .. data.value .."点")
            elseif i == 6 then
                local data =  json.decode(buffData)
                local str = ""
                if data.taskType == 1 then
                    -- 钻石
                    str = "每日前" .. data.times .. "次至尊捐献" .. data.discount .. "折"
                elseif data.taskType == 3 then
                    str = "每日前" .. data.times .. "次至尊捐献" .. data.discount .. "折"
                end
                local buffTxt2 = self:getUI("bg.allBg.rightPanel5.buff" .. i .. ".buffTxt2")
                buffTxt2:setString(str)
            elseif i == 7 then
                local buffTxt2 = self:getUI("bg.allBg.rightPanel5.buff" .. i .. ".buffTxt2")
                buffTxt2:setString("英雄全属性+" .. buffData)
            end
        end
    end
    self:setPrivilegseCD()
end

function BackflowView:setPrivilegseCD()
    if self._privilegseCD then 
        return
    end
    local returnPrivilege = self._backflowModel:getReturnPrivilege()
    if not returnPrivilege or not returnPrivilege.endTime then
        return
    end
    self._privilegseCD = true
    local timeLab = self:getUI("bg.allBg.rightPanel5.priTimer.timeLab")
    local curServerTime = self._userModel:getCurServerTime()
    local endTime = returnPrivilege.endTime or 0
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local realTime = endTime - curServerTime
        realTime = math.abs(realTime)
        local tday = math.floor(realTime/86400)
        local tTime = realTime - tday*86400
        local thour = math.floor(tTime/3600)
        tTime = tTime - thour*3600
        local tmin = math.floor(tTime/60)
        tTime = tTime - tmin*60
        local tsec = math.fmod(tTime, 60)
        local timerStr = string.format("%d天%.2d:%.2d:%.2d", tday, thour, tmin, tsec)
        if realTime < 0 then
            timerStr = "0天00:00:00"
        end
        if timeLab then
            timeLab:setString(timerStr)
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    timeLab:runAction(cc.RepeatForever:create(seq))
end

-- layer1
--[[
用tableview实现
--]]
function BackflowView:addWelfareTableView()
    local tableViewBg = self:getUI("bg.allBg.rightPanel1.tableViewBg")

    self._welfareTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._welfareTableView:setDelegate()
    self._welfareTableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self._welfareTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
    self._welfareTableView:setAnchorPoint(0, 0)
    self._welfareTableView:setPosition(5, 0)
    self._welfareTableView:registerScriptHandler(function( view ) return self:scrollViewDidScroll(view) end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._welfareTableView:registerScriptHandler(function(table, idx) return self:cellSizeForWelfareTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._welfareTableView:registerScriptHandler(function(table, idx) return self:tableWelfareCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._welfareTableView:registerScriptHandler(function(table) return self:numberOfWelfareCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._welfareTableView:setBounceable(true)
    -- if self._welfareTableView.setDragSlideable ~= nil then 
    --     self._welfareTableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._welfareTableView)
    self._welfareTableView:setTouchEnabled(false)
end

function BackflowView:scrollViewDidScroll(view)
    if view:isDragging() then
        self._refreshAnim = false
    end
    local container = self._welfareTableView:getContainer()
    if container and self._rightArrow and self._leftArrow then
        local x = container:getPositionX()
        local offMax = self._welfareTableView:maxContainerOffset().x
        local offMin = self._welfareTableView:minContainerOffset().x
        self._leftArrow:setVisible(x > offMin+20)
        self._rightArrow:setVisible(x < offMax-20 )        
    end
end
-- cell的尺寸大小
function BackflowView:cellSizeForWelfareTable(table,idx) 
    return 316, 457
end

-- 创建在某个位置的cell
function BackflowView:tableWelfareCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._welfareData[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local loginCell = self._loginCell:clone() 
        loginCell:setVisible(true)
        loginCell:setAnchorPoint(0, 0)
        loginCell:setPosition(3, 0)
        loginCell:setName("loginCell")
        cell:addChild(loginCell)

        local awardBtn = loginCell:getChildByFullName("awardBtn")
        UIUtils:setButtonFormat(awardBtn, 5)

        -- local lingquAnim = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false, function (_, sender)
        -- end)
        -- lingquAnim:setName("lingquAnim")
        -- lingquAnim:setPosition(awardBtn:getContentSize().width*0.5, awardBtn:getContentSize().height*0.5)
        -- awardBtn:addChild(lingquAnim, 1)
        -- awardBtn.lingquAnim = lingquAnim

        self:updateWelfareCell(loginCell, param, indexId)
    else
        print("wo shi shua xin")
        local loginCell = cell:getChildByName("loginCell")
        if loginCell then
            self:updateWelfareCell(loginCell, param, indexId)
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
    inView:setSwallowTouches(false)
    local cellBg = inView:getChildByFullName("cellBg")
    cellBg:setTouchEnabled(true)
    cellBg:setSwallowTouches(false)
    local titleTxt = inView:getChildByFullName("titleTxt")    local des2 = inView:getChildByFullName("des2")
    titleTxt:setString("登陆第" .. indexId.. "天")
    
    local awardBtn = inView:getChildByFullName("awardBtn")
    awardBtn:setVisible(true)
    -- local lingquAnim = awardBtn.lingquAnim
    local loginDay = self._flowBaseData.loginDay
    local awardItem = data.loginAward
    local receive = data.loginReceived or 0
    if awardBtn then
        if loginDay >= indexId then
            awardBtn:setSaturation(0)
            self:registerClickEvent(awardBtn, function()
                local param = {days = indexId}
                self:receiveLoginWelFare(param)
            end)
        else
            awardBtn:setSaturation(-100)
            self:registerClickEvent(awardBtn, function()
                self._viewMgr:showTip(lang("RECOVER_BACK_1"))
            end)
        end
        awardBtn:setVisible(receive == 0)
    end
    local yilingqu = inView:getChildByFullName("yilingqu")
    if yilingqu then
        yilingqu:setVisible(not (receive == 0))        
    end


    if awardItem then
        local num = table.nums(awardItem)
        print()
        for i=1, num do
            local num = awardItem[i]["num"]
            local itemId = awardItem[i]["typeId"]
            if awardItem[i]["type"] ~= "tool" then
                itemId = IconUtils.iconIdMap[awardItem[i]["type"]]
            end
            local itemIcon = inView:getChildByName("item" .. i)
            itemIcon:setSwallowTouches(false)
            local icon = inView["iconItem" .. i]
            local param = {itemId = itemId, num = num}
            if icon then
                icon = IconUtils:updateItemIconByView(itemIcon, param)
            else
                icon = IconUtils:createItemIconById(param)
                icon:setScale(0.8)
                -- icon:setPosition(130+80*i, 18)
                inView["iconItem" .. i] = icon
                if itemIcon then 
                    itemIcon:addChild(icon)
                end
            end
        end
        for i=num+1,7 do
            local itemIcon = inView:getChildByName("item" .. i)
            itemIcon:setSwallowTouches(false)
            itemIcon:setVisible(false)            
        end
    end
end

-- num = -1 右
-- num = 1  左
function BackflowView:scrollBtnClick(num)
    self:lock(-1)
    self._nextIdx = self._nextIdx + num
    local container = self._welfareTableView:getContainer()
    local x = container:getPositionX()
    local posX = x - num*457 
    if posX <= 0 and posX >= -1*table.nums(self._welfareData)*457 then 
        local sizeSchedule 
        local step = 0.5
        local stepConst = 30
        local subX = 0
        if num < 0 then 
            sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
                stepConst = stepConst-step
                if stepConst < 1 then 
                    stepConst = 1
                end
                subX = subX+stepConst
                if x + subX < posX then
                    self._welfareTableView:setContentOffset(cc.p(x + subX , 0))
                else
                    self._welfareTableView:setContentOffset(cc.p(posX , 0))
                    ScheduleMgr:unregSchedule(sizeSchedule)
                    self:unlock()
                end
            end)
        else
            sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
                stepConst = stepConst-step
                if stepConst < 1 then 
                    stepConst = 1
                end
                subX = subX+stepConst
                if x - subX > posX then
                    self._welfareTableView:setContentOffset(cc.p(x - subX , 0))
                else
                    self._welfareTableView:setContentOffset(cc.p(posX , 0))
                    ScheduleMgr:unregSchedule(sizeSchedule)
                    self:unlock()
                end
            end)
        end

    end
    
end

-- layer2
--[[
用tableview实现
--]]
function BackflowView:addSaleTableView()
    local tableViewBg = self:getUI("bg.allBg.rightPanel2.tableViewBg")

    self._saleDataTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width-5, tableViewBg:getContentSize().height))
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
    return 373, 207
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
        soldCell:setPosition(0, 20) --0
        soldCell:setName("soldCell")
        cell:addChild(soldCell)

        -- local fightPanel = self:getUI("bg.fightPanel")
        -- fightPanel:setVisible(false)
        -- local fightPanel = loginCell:getChildByFullName("fightPanel")
        -- fightPanel:setVisible(false)
        -- nameBg:setOpacity(100)
        local costNum = soldCell:getChildByFullName("gotoView.costNum")
        costNum:setColor(UIUtils.colorTable.ccUICommonBtnColor2)
        costNum:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2)
        -- local bg1 = loginCell:getChildByFullName("bg1")
        -- -- local bg2 = loginCell:getChildByFullName("bg2")
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
    -- dump(data)
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
        itemIcon:setPosition(65, 180)
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

-- layer3
--[[
    用tableview实现
    回归任务
--]]
function BackflowView:addTaskTableView()
    local tableViewBg = self:getUI("bg.allBg.rightPanel3.tableViewBg")

    self._taskTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width-5, tableViewBg:getContentSize().height))
    self._taskTableView:setDelegate()
    self._taskTableView:setDirection(0)
    self._taskTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._taskTableView:setAnchorPoint(0, 0)
    self._taskTableView:setPosition(5, 2)
    self._taskTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTaskTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._taskTableView:registerScriptHandler(function(table, idx) return self:tableTaskCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._taskTableView:registerScriptHandler(function(table) return self:numberOfTaskCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._taskTableView:setBounceable(true)
    -- if self._taskTableView.setDragSlideable ~= nil then 
    --     self._taskTableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._taskTableView)
end

-- cell的尺寸大小
function BackflowView:cellSizeForTaskTable(table,idx) 
    return 291, 207
end

-- 创建在某个位置的cell
function BackflowView:tableTaskCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._taskData[idx+1]
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local taskCell = self._taskCell:clone() 
        taskCell:setVisible(true)
        taskCell:setAnchorPoint(0, 0)
        taskCell:setPosition(0, 20) --0
        taskCell:setName("taskCell")
        cell:addChild(taskCell)

        local condTxt1 = taskCell:getChildByFullName("condTxt1")
        condTxt1:setColor(UIUtils.colorTable.ccUIBaseColor2)
        condTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local condTxt2 = taskCell:getChildByFullName("condTxt2")
        condTxt2:enableOutline(cc.c4b(138,92,29,255), 1)

        self:updateTaskCell(taskCell, param, indexId)
    else
        print("wo shi shua xin")
        local taskCell = cell:getChildByName("taskCell")
        if taskCell then
            self:updateTaskCell(taskCell, param, indexId)
        end
    end

    return cell
end

-- 返回cell的数量
function BackflowView:numberOfTaskCellsInTableView(table)
    return self:cellTaskLineNum()  -- 
end


function BackflowView:cellTaskLineNum()
    return table.nums(self._taskData) 
end

function BackflowView:updateTaskCell(inView, data, indexId)
    -- dump(data)
    local itemName = inView:getChildByFullName("itemName")
    local des1 = inView:getChildByFullName("des1")
    local itemNumLab = inView:getChildByFullName("itemNumBg.itemNumLab")
    local yilingqu = inView:getChildByFullName("yilingqu")
    local goBtn = inView:getChildByFullName("goBtn")
    local getBtn = inView:getChildByFullName("getBtn")
    local condTxt1 = inView:getChildByFullName("condTxt1")
    local condTxt2 = inView:getChildByFullName("condTxt2")

    itemName:setString(lang(data.title))
    des1:setString(lang(data.description))
    condTxt1:setString(data.haveNum .. "/")
    condTxt2:setString(data.condition_num[1])
    if data.haveNum >= data.condition_num[1] then
        condTxt2:setColor(UIUtils.colorTable.ccUIBaseColor2)
        condTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    else
        condTxt2:disableEffect()
        condTxt2:setColor(cc.c4b(138,92,29,255))
    end
    condTxt1:setPositionX(condTxt2:getPositionX()-condTxt2:getContentSize().width-1)
    itemNumLab:setString("可获得"  .. data.accumulatepoints .. "积分")
    if data.status == 0 then
        yilingqu:setVisible(false)
        goBtn:setVisible(false)
        getBtn:setVisible(false)
        if data.haveNum >= data.condition_num[1] then
            getBtn:setVisible(true)
            self:registerClickEvent(getBtn, function()
                -- 领取奖励
                self:getTaskAward(data)
            end)
        else
            goBtn:setVisible(true)
            self:registerClickEvent(goBtn, function()
                if self["goView" .. data.button] then
                    self["goView" .. data.button](self)
                end
            end)
        end
    else
        goBtn:setVisible(false)
        getBtn:setVisible(false)
        yilingqu:setVisible(true)
    end
end

function BackflowView:tabButtonState(sender, isSelected, key)
    local titleNames = self._titleNames
    -- local shortTitleNames = self._shortTitleNames

    local text = sender:getChildByFullName("text")
    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    text:setString(titleNames[key])
    if isSelected then
        text:disableEffect()
        text:setColor(cc.c3b(242, 214, 189))
    else
        -- text:setString(shortTitleNames[key])
        text:setColor(cc.c3b(134, 89, 47))
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
        }
end

-- 领取登录福利
function BackflowView:receiveLoginWelFare(param)
    if not param then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("BackFlowServer", "receiveLoginWelFare", param, true, {}, function (result)
        -- dump(result, "indexId=====", 10)
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

-- 获取任务奖励
function BackflowView:getTaskAward(data)
    if not data then return end
    local tbData = {}
    table.insert(tbData, data.id)
    self._serverMgr:sendMsg("BackFlowServer", "finishTask", {taskIds=tbData}, true, {}, function (result)
        self:updateACLayer3()
    end, function(errorId)
        
    end)
end
-- 获取积分宝箱奖励
function BackflowView:taskBoxClicked(sender)
    if sender._isCanGet then
        print("================发送领宝箱协议============")
        local tbData = {}
        table.insert(tbData, sender._id)
        self._serverMgr:sendMsg("BackFlowServer", "getScoreReward", {rewardIds=tbData}, true, {}, function(data)
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    -- 更新宝箱状态
                    sender._normal = false
                    sender._isCanGet = false
                    sender._getMc:setVisible(false)                
                    sender:loadTextures(sender._getImg .. ".png",sender._getImg .. ".png","",1)
                    sender:setOpacity(255)
                end,notPop = false})
            end 
        end)       
    elseif sender._normal then
        -- 预览
        local tipStr = "获取" .. sender._needCount .. "积分可得以下奖励"
        DialogUtils.showGiftGet({ gifts = sender._rewardArr, viewType = 2,des=tipStr}) -- des = ""
    else
        self._viewMgr:showTip(lang("TiPS_YILINGQU"))
    end
end


-- 购买特卖商品
function BackflowView:buyReturnSaleGoods(param)
    if not param then
        self._viewMgr:showTip("参数有误")
        return
    end
    self._serverMgr:sendMsg("BackFlowServer", "buyReturnSaleGoods", param, true, {}, function (result)
        -- dump(result, "indexId=====", 10)
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
        -- dump(result, "indexId=====", 10)
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
        -- dump(result, "indexId=====", 10)
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
    local uData = self._userModel:getData()
    self._dayNum:setString((uData.statis and uData.statis.snum6) and uData.statis.snum6 or 0)

    self._flowBaseData = self._backflowModel:getBaseData()
    local layerId = self._panelMap[(self._index or 1)]
    self["updateACLayer" .. layerId](self)
    self:updateBackflowTip()
end

function BackflowView:reciprocalTime()
    local baseData = self._backflowModel:getBaseData()
    -- dump(baseData)

    local timeLab1 = self:getUI("bg.allBg.timerBg.timeLab")
    local curServerTime = self._userModel:getCurServerTime()
    local endTime = baseData.endTime or 0
    local callFunc = cc.CallFunc:create(function()
        local curServerTime = self._userModel:getCurServerTime()
        local realTime = endTime - curServerTime
        if realTime < 0 then
            if self._callback then
                self._callback()
            end
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
        if timeLab1 then
            timeLab1:setString(timerStr)
        end
    end)
    local seq = cc.Sequence:create(callFunc, cc.DelayTime:create(1))
    timeLab1:runAction(cc.RepeatForever:create(seq))
end

function BackflowView:updateBackflowTip()
    local loginTip = self._backflowModel:getBackflowLoginTip()
    local rechargeTip = self._backflowModel:getBackflowRechargeTip()
    -- local blessTip = self._backflowModel:getBackflowBlessTip()
    local taskTip = self._backflowModel:getBackflowTaskTip()

    print("==============loginTiprechargeTiptaskTip======",loginTip,rechargeTip,taskTip)
    local onTip1 = self:getUI("bg.allBg.leftPanel.tab1.onTip")
    if loginTip == true then
        onTip1:setVisible(true)
    else
        onTip1:setVisible(false)
    end
    local onTip3 = self:getUI("bg.allBg.leftPanel.tab2.onTip")
    if taskTip == true then
        onTip3:setVisible(true)
    else
        onTip3:setVisible(false)
    end
    local onTip4 = self:getUI("bg.allBg.leftPanel.tab4.onTip")
    if rechargeTip == true then
        onTip4:setVisible(true)
    else
        onTip4:setVisible(false)
    end


end


function BackflowView:scrollToNext()
    -- dump(self._welfareData)
    local welfareData = self._welfareData
    local scrollIndexId = 0
    for i=1,table.nums(welfareData) do
        local received = welfareData[i].loginReceived      
        if received and received == 0 then
            scrollIndexId = i
            break
        end
    end
    -- print("=============scrollIndexId====",scrollIndexId)
    if scrollIndexId == 0 or scrollIndexId > self._flowBaseData.loginDay then
        scrollIndexId = self._flowBaseData.loginDay
    end

    local selectedIndex = (scrollIndexId-1) or 0
    local allIndex = table.nums(welfareData)
    local beWidth = selectedIndex*457

    local scrollAnim = true
    local tempWidth = self._welfareTableView:getContainer():getContentSize().width
    local tableViewBg = self:getUI("bg.allBg.rightPanel1.tableViewBg")
    local tabwidth = tempWidth - tableViewBg:getContentSize().width
    -- print(tempWidth,"containHeight==========", tabwidth)
    -- print("====================",tempWidth < tableViewBg:getContentSize().width)
    if tempWidth < tableViewBg:getContentSize().width then
        self._welfareTableView:setContentOffset(cc.p(self._welfareTableView:getContentOffset().x,0), scrollAnim)
    else
         -- print((tempWidth - beWidth),"========== ff ==========",tableViewBg:getContentSize().width)
        if (tempWidth - beWidth)+10 > tableViewBg:getContentSize().width then
            self._welfareTableView:setContentOffset(cc.p(-1*beWidth,0), scrollAnim)
        else
            self._welfareTableView:setContentOffset(cc.p(0, 0), scrollAnim)
        end
    end
end

-- 1【前往】世界地图
function BackflowView:goView1()
    self._viewMgr:showView("intance.IntanceView", {})
end
-- 2【前往】前往精英副本-开启的最高等级副本
function BackflowView:goView2()
    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {})
end
-- 3【前往】矮人宝屋
function BackflowView:goView3()
    if not SystemUtils:enableDwarvenTreasury() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.AiRenMuWuView") 
end
-- 4【前往】阴森墓穴
function BackflowView:goView4()
    if not SystemUtils:enableCrypt() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.ZombieView") 
end
-- 【前往】龙之国
function BackflowView:goView5()    
    if not SystemUtils:enableBoss() then
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK"))
        return 
    end
    self._viewMgr:showView("pve.DragonView")
end
-- 6【前往】元素位面
function BackflowView:goView6()
    if not SystemUtils:enableElement() then
        self._viewMgr:showTip(lang("TIP_elementalPlane"))
        return 
    end

    self._viewMgr:showView("elemental.ElementalView")
end
-- 7【前往】云中城
function BackflowView:goView7()
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    self._viewMgr:showView("cloudcity.CloudCityView")
end
-- 8【前往】战役
function BackflowView:goView8()
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView")
end
-- 9【前往】船坞
function BackflowView:goView9()
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end
-- 10【前往】圣徽
function BackflowView:goView10()
    if not SystemUtils:enableHoly() then
        self._viewMgr:showTip(lang("TIP_Runes"))
        return 
    end
    self._viewMgr:showView("team.TeamHolyView", {})
end
-- 11【前往】联盟
function BackflowView:goView11()
    if not SystemUtils:enableGuild() then
        self._viewMgr:showTip(lang("TIP_Guild"))
        return 
    end
    local userData = self._userModel:getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showView("guild.join.GuildInView")
    else
        self._viewMgr:showView("guild.GuildView")
    end
end
-- 12【前往】攻城器械
function BackflowView:goView12()
    local state = self._modelMgr:getModel("WeaponsModel"):getWeaponState()
    if state == 1 then
        self._viewMgr:showTip(lang("TIP_Weapon"))
    elseif state == 2 then
        self._viewMgr:showTip(lang("TIP_Weapon2"))
    elseif state == 3 then
        self._viewMgr:showTip(lang("TIP_Weapon3"))
    elseif state == 4 then
        local tdata = self._modelMgr:getModel("WeaponsModel"):getWeaponsDataByType(1)
        if tdata then
            self._viewMgr:showView("weapons.WeaponsView", {})
        else
            self._serverMgr:sendMsg("WeaponServer", "getWeaponInfo", {}, true, {}, function(result)
                self._viewMgr:showView("weapons.WeaponsView", {})
            end)
        end
    end
end
-- 13【前往】祭坛
function BackflowView:goView13()
    self._viewMgr:showView("flashcard.FlashCardView")
end
-- 14【前往】抽宝占星  积分  等级可见性
function BackflowView:goView14()
    if not SystemUtils:enableTreasure() then
        self._viewMgr:showTip(lang("TIP_Treasure"))
        return 
    end

    self._viewMgr:showView("treasure.TreasureShopView")
end









return BackflowView