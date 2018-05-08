--
-- Author: huangguofang
-- Date: 2018-03-15 19:23:16
--
local AcLuckyLotteryDialog = class("AcLuckyLotteryDialog",BasePopView)
function AcLuckyLotteryDialog:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 1
    print("================initAnimType===",self.initAnimType)
    self._runeLotteryModel = self._modelMgr:getModel("RuneLotteryModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._closeCallBack = param.closeCallBack
    
end
function AcLuckyLotteryDialog:getAsyncRes()
    return 
    {
        {"asset/ui/acLuckyLottery.plist", "asset/ui/acLuckyLottery.png"},
    }
end

-- function AcLuckyLotteryDialog:getBgName()
--     return "acLuckyLottery_bg_img.jpg"
-- end

function AcLuckyLotteryDialog:onDestroy()
    AcLuckyLotteryDialog.super.onDestroy(self)
    
end

-- 第一次被加到父节点时候调用
function AcLuckyLotteryDialog:onAdd()

end

function AcLuckyLotteryDialog:onInit()
    print("===============幸运夺宝==============")
    self._limitNum = tab:Setting("GEM_BACKPACK_CAPPED").value
    self._bg = self:getUI("bg")
    local bgImg = self:getUI("bg.bgImg")
    bgImg:loadTexture("asset/bg/acLuckyLottery_bg_img.jpg")
    local w = bgImg:getContentSize().width
    local h = bgImg:getContentSize().height
    local scaleW = MAX_SCREEN_WIDTH / w
    local scaleH = MAX_SCREEN_HEIGHT / h
    -- 背景图片适配
    bgImg:setScale(scaleW > scaleH and scaleW or scaleH)

    self._closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(self._closeBtn, function ()
        self:close()
        if self._closeCallBack then
            self._closeCallBack()
        end
        UIUtils:reloadLuaFile("activity.acLuckyLottery.AcLuckyLotteryDialog")
    end)

    self._hotPanel  = self:getUI("bg.leftPanel.btnPanel.hotPanel")
    self._cdTxt     = self:getUI("bg.leftPanel.btnPanel.cdTxt")
    self._ruleBtn   = self:getUI("bg.leftPanel.btnPanel.ruleBtn")
    self:registerClickEvent(self._ruleBtn, function () 
    --  
        print("============打开规则界面======")
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("runeLottery_rule")},true)
    end)
    self._itemArr = {}
    self._lotteryPanel = self:getUI("bg.leftPanel.lotteryPanel")
    for i=1,14 do
        local item = self:getUI("bg.leftPanel.lotteryPanel.item" .. i)
        self._itemArr[i] = item
        self._itemArr[i]._index = i
    end
    self._buyBgImg = self:getUI("bg.leftPanel.lotteryPanel.buyBgImg")
    self._buyPanel = self:getUI("bg.leftPanel.lotteryPanel.buyPanel")


    local costData1 = tab:Setting("GEM_LOTTERY_NUM_1").value
    local costData5 = tab:Setting("GEM_LOTTERY_NUM_5").value
    self._costType = costData1[1][1]

    self._buyBtn1 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn1")
    self._buyBtn1Cost = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn1.costNum")
    self._buyBtnCostNum1 = costData1[1][3]
    self._buyBtn1Cost:setString(costData1[1][3] or 0)
    self._buyBtn1Cost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)    
    local buyBtn1Txt1 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn1.getTxt1")
    buyBtn1Txt1:setString("购买".. (costData1[2][3] or 0) .. "灵魂石")
    local buyBtn1Txt2 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn1.getTxt2")
    buyBtn1Txt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local costType1 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn1.costType")
    costType1:loadTexture(IconUtils.resImgMap[self._costType],1)

    self._buyBtn5 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn5")
    self._buyBtn5Cost = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn5.costNum")
    self._buyBtnCostNum5 = costData5[1][3]
    self._buyBtn5Cost:setString(costData5[1][3] or 0)
    self._buyBtn5Cost:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local buyBtn5Txt1 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn5.getTxt1")
    buyBtn5Txt1:setString("购买".. (costData5[2][3] or 0) .. "灵魂石")
    local buyBtn5Txt2 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn5.getTxt2")
    buyBtn5Txt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local costType5 = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.buyBtn5.costType")
    costType5:loadTexture(IconUtils.resImgMap[self._costType],1)
    -- 字色
    self:updateBuyBtnCost()

    self:registerClickEvent(self._buyBtn1, function ()
        self._buyNum = 1
        self:lotteryBtnClicked()
    end)
    self:registerClickEvent(self._buyBtn5, function ()
        self._buyNum = 5
        self:lotteryBtnClicked()
    end)

    self._exchangeBtn = self:getUI("bg.leftPanel.exchangeBtn")
    UIUtils:addFuncBtnName( self._exchangeBtn,"特惠兑换",nil,true,16)
    self:registerClickEvent(self._exchangeBtn, function ()
        print("============打开兑换界面======")
        if not self._runeLotteryModel:isLotteryOpen() then
            self._viewMgr:showTip("幸运夺宝活动已结束")
            return
        end
        self._viewMgr:showDialog("activity.acLuckyLottery.AcLuckyLotteryShopDialog", {})
    end)
    self._goodsData     = self._runeLotteryModel:getGoodsData() or {}
    self._serverData    = self._runeLotteryModel:getLotteryData() or {}
    self._rewardData    = self._runeLotteryModel:getRewardData() or {}
    self._hotData       = self._rewardData.rewardDisplay or {}
    self:initLeftPanel()
    self:initRightPanel()

    -- local timeTxt = self:getUI("bg.leftPanel.btnPanel.timeTxt")
    -- timeTxt:setString("服务器")

    -- 倒计时
    self:reflashCD()
    self._timer = ScheduleMgr:regSchedule(1000, self, function( )
        self:reflashCD()
    end)

    self:listenReflash("UserModel", self.updateBuyBtnCost)
end

function AcLuckyLotteryDialog:reflashCD()

    local currentTime = self._userModel:getCurServerTime()
    local endTime = self._serverData.endTime or 1521320400

    local remainTime = endTime - currentTime

    local tempValue = remainTime    
    local day = math.floor(tempValue/86400) 
    tempValue = tempValue - day*86400
    
    local hour = math.floor(tempValue/3600)
    tempValue = tempValue - hour*3600

    local minute = math.floor(tempValue/60)
    tempValue = tempValue - minute*60
   
    local second = math.fmod(tempValue, 60)
    local showTime = string.format("%.2d天%.2d:%.2d:%.2d", day, hour, minute, second)
    if day == 0 then
        showTime = string.format("00天%.2d:%.2d:%.2d", hour, minute, second)
    end
    if remainTime <= 0 then
        if self._timer then
            ScheduleMgr:unregSchedule(self._timer)
            self._timer = nil
        end
        showTime = "00天00:00:00"
    end
    self._cdTxt:setString(showTime)

end

function AcLuckyLotteryDialog:initLeftPanel()
    -- dump(self._goodsData,"self._goodsData==>",5)
    -- dump(self._serverData,"self._serverData==>",5)
    -- dump(self._hotData,"self._hotData==>",5)
    -- 热点显示
    local height = self._hotPanel:getContentSize().height
    local width  = self._hotPanel:getContentSize().width
    local iconH = 90
    local posX = (width - iconH)*0.5
    local posY = height - iconH
    local rewardNum = #self._hotData
    for k,v in ipairs(self._hotData) do        
        local icon        
        local itemId 
        local reward = v
        local itemId = reward[2]
        local rType = reward[1]
        
        if type(reward[2]) == "string" then
            local dataTemp = itemType[tonumber(acOpenId)]
            itemId = dataTemp[reward[2]][2]
            rType = dataTemp[reward[2]][1]
            -- print("===========reward[2]===",reward[2])
        end

        if rType == "siegeProp" then
            local propsTab = tab:SiegeEquip(itemId)
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            icon = IconUtils:createWeaponsBagItemIcon(param)
            local iconColor = icon:getChildByName("iconColor")
            if iconColor and iconColor.lvlLabel then
                iconColor.lvlLabel:setVisible(false)
            end
            icon:setName("icon" .. k)
            icon:setScale(0.9)
        else
            if rType == "tool"then
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3]})
                icon:setScale(0.9)
            elseif rType == "rune" then
                -- print("==================itemId====",itemId)
                local itemData = tab:Rune(itemId)
                icon =IconUtils:createHolyIconById({suitData = itemData})
                icon:setScale(0.9)

            else
                itemId = IconUtils.iconIdMap[rType]
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3]})
                icon:setScale(0.9)
            end
        end
        icon:setPosition(posX,posY)
        icon:setAnchorPoint(0,0)
        self._hotPanel:addChild(icon)

        local boxIcon = icon.boxIcon
        local iconColor = icon.iconColor
        if boxIcon then
            boxIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setVisible(false)
        end
        if k ~= rewardNum then
            -- print("================11111====",posY)
            local imgLine = ccui.ImageView:create()
            imgLine:loadTexture("acLuckyLottery_line_img.png", 1)
            imgLine:setPosition(width*0.5,posY - 15)
            posY = posY - 20
            self._hotPanel:addChild(imgLine)
        end  
        posY = posY - iconH

    end

    -- 初始化item
    local acOpenId = self._runeLotteryModel:getAcOpenID()
    -- print("===========acOpenId====",acOpenId)
    local itemType = tab.itemType
    for k,v in ipairs(self._goodsData) do
        -- print("===================kkkk=",k)
        local index = v.grid and v.grid[1] or 1
        local item = self._itemArr[index]
        local reward = v.itemId
        local rType = reward[1]
        local icon
        local itemId = reward[2]
        local nameStr = ""
        local qualityNum = 1
        if type(reward[2]) == "string" then
            local dataTemp = itemType[tonumber(acOpenId)]
            itemId = dataTemp[reward[2]][2]
            rType = dataTemp[reward[2]][1]
            -- print("===========reward[2]===",reward[2])
        end
        if rType == "siegeProp" then
            local propsTab = tab:SiegeEquip(itemId)
            nameStr = lang(propsTab.name)
            qualityNum = propsTab.quality
            local param = {itemId = itemId, level = 1, itemData = propsTab, quality = propsTab.quality, iconImg = propsTab.art, eventStyle = 1}
            icon = IconUtils:createWeaponsBagItemIcon(param)
            local iconColor = icon:getChildByName("iconColor")
            if iconColor and iconColor.lvlLabel then
                iconColor.lvlLabel:setVisible(false)
            end
            icon:setName("icon" .. k)
            icon:setScale(0.9)
        else
            if rType == "tool"then
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3]})
                icon:setScale(0.9)
                nameStr = lang(toolD.name)
                qualityNum = ItemUtils.findResIconColor(itemId,1)
            elseif rType == "rune" then                
                -- print("==================itemId====",itemId)
                local itemData = tab:Rune(itemId)
                icon =IconUtils:createHolyIconById({suitData = itemData})
                icon:setScale(0.9)
                nameStr = lang(itemData.name)
                qualityNum = itemData.quality
            else
                itemId = IconUtils.iconIdMap[rType]
                local toolD = tab:Tool(tonumber(itemId))
                icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = reward[3]})
                icon:setScale(0.9)
                nameStr = lang(toolD.name)
                qualityNum = ItemUtils.findResIconColor(itemId,1)
            end
            
        end
        local boxIcon = icon.boxIcon
        local iconColor = icon.iconColor
        if boxIcon then
            boxIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setVisible(false)
        end
        icon:setAnchorPoint(0.5,0.5)
        icon:setScaleAnim(true)
        icon:setPosition(item:getContentSize().width*0.5, item:getContentSize().height*0.5)
        item.__icon = icon 
        item:addChild(icon,5) 

        local selectAnim = mcMgr:createViewMC("xuanzhuanguang_xingyunduobao", false,false)
        selectAnim:setPosition(69, 50)
        selectAnim:setVisible(false)
        item:addChild(selectAnim,1)
        item._selectAnim = selectAnim

        local nameTxt = ccui.Text:create()
        nameTxt:setFontSize(14)
        nameTxt:setFontName(UIUtils.ttfName)
        nameTxt:setString(nameStr)
        print("==qualityNum====",qualityNum)
        nameTxt:setColor(UIUtils.colorTable["ccColorQuality" .. qualityNum])
        nameTxt:setPosition(item:getContentSize().width*0.5,15)
        nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        item:addChild(nameTxt,5)
        item._nameTxt = nameTxt

    end

    -- 设置幸运值
    local numTxt = self:getUI("bg.leftPanel.lotteryPanel.buyPanel.numTxt")
    numTxt:setVisible(false)
    local num = self._serverData.luckyScore or 0
    local luckyTxt = cc.LabelBMFont:create(num, UIUtils.bmfName_Lottery)
    luckyTxt:setScale(0.45)
    luckyTxt:setAnchorPoint(cc.p(0,0.5))
    luckyTxt:setPosition(numTxt:getPositionX()-5,numTxt:getPositionY()+6)
    self._buyPanel:addChild(luckyTxt, 1)
    self._numTxt = luckyTxt
end
function AcLuckyLotteryDialog:initRightPanel()
    -- self._serverData

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

    local boxData = self._serverData["box"] or {}
    local allBox = self._rewardData.frequency or {}
    local awardData = self._rewardData.reward or {}
    local drawCount = self._serverData["drawCount"] or 0
    self._boxArr = {}
    local coutNum
    local needCount
    local getMc
    self._maxCount = 0
    -- dump(awardData,'awardData=》',5)

    for i=1,#allBox do
        local box = self:getUI("bg.rightPanel.box" .. i)
        coutNum = self:getUI("bg.rightPanel.box" .. i .. ".coutNum")
        coutNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        needCount = allBox[i]
        coutNum:setString(needCount)    
        if needCount > self._maxCount then
            self._maxCount = needCount
        end
        box._coutNumTxt = countNum
        box._needCount = needCount 
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
        local rewardD = awardData[i] or {}
        box._rewardArr = {}
        table.insert(box._rewardArr, rewardD)
        -- dump(awardData[i],"awardData[i]==>",4)

        box._normal = true
        box._isCanGet = false
        if drawCount >= needCount then
            box._isCanGet = true
            box._normal = false
        end
        if boxData[tostring(needCount)] then
            box._normal = false
            box._isCanGet = false
        end

        getMc:setVisible(box._isCanGet)
        
        local imgName = box._normal and box._normalImg .. ".png" or box._getImg .. ".png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity(box._isCanGet and 0 or 255)

        self:registerClickEvent(box, function (sender)
            self:luckyBoxClicked(sender)
        end)
        self._boxArr[i] = box
    end

    self._progressBar = self:getUI("bg.rightPanel.progressBar")
    self._progressBar:setPercent((self._maxCount == 0) and 0 or drawCount/self._maxCount*100)
end

function AcLuckyLotteryDialog:updateDataAndPanel()
    print("============updateDataAndPanel=======")
    self._serverData    = self._runeLotteryModel:getLotteryData() or {}
    self._numTxt:setString(self._serverData.luckyScore or 0)

    local drawCount = self._serverData["drawCount"] or 0
    local boxData = self._serverData["box"] or {}
    --更新宝箱
    for k,v in pairs(self._boxArr) do
        local box = v
        local needCount = box._needCount
        local getMc = box._getMc
        local normalImg = box._normalImg
        local getImg = box._getImg

        if drawCount >= needCount then
            box._isCanGet = true
            box._normal = false
        end
        if boxData[tostring(needCount)] then
            box._normal = false
            box._isCanGet = false
        end

        getMc:setVisible(box._isCanGet)
        
        local imgName = box._normal and box._normalImg .. ".png" or box._getImg .. ".png"
        box:loadTextures(imgName,imgName,"",1)
        box:setOpacity(box._isCanGet and 0 or 255)
    end

    self._progressBar:setPercent((self._maxCount == 0) and 0 or drawCount/self._maxCount*100)
    self:updateBuyBtnCost()
end

function AcLuckyLotteryDialog:updateBuyBtnCost()
    
    local userData = self._userModel:getData()
    local haveCostNum = userData[self._costType]
    self._buyBtn1Cost:setColor(haveCostNum >= self._buyBtnCostNum1 
                and UIUtils.colorTable.ccUIBaseColor1
                or UIUtils.colorTable.ccUIBaseColor6)
    self._buyBtn5Cost:setColor(haveCostNum >= self._buyBtnCostNum5 
                and UIUtils.colorTable.ccUIBaseColor1
                or UIUtils.colorTable.ccUIBaseColor6)
end

function AcLuckyLotteryDialog:lotteryBtnClicked()
    if not self._runeLotteryModel:isLotteryOpen() then
        self._viewMgr:showTip("幸运夺宝活动已结束")
        return
    end
    local buyNum = self._buyNum or 1
    -- print("================buyNum====",buyNum)
    -- self:debugFunc()   --动画调试
    -- if true then return end
    local holyData = self._teamModel:getHolyData()
    -- print(type(holyData),"============table.nums(HolyData)===",table.nums(holyData),self._limitNum)
    if self._limitNum < table.nums(holyData) then
        self._viewMgr:showTip("圣徽背包已满，请前往分解")
        return
    end
    local userData = self._userModel:getData()
    local haveCostNum = userData[self._costType]
    local costNum = self["_buyBtnCostNum" .. buyNum]
    -- print("===========costNum===",costNum,haveCostNum)
    if haveCostNum >= costNum then
        self._serverMgr:sendMsg("RuneLotteryServer", "drawRunes", {type=buyNum}, true, {}, function(result)
            -- 播放动画
            self:playAnim(result["reward"],function()
                self:updateDataAndPanel()
            end)
            
        end)
    else
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = costNum - haveCostNum})
        end})
        -- DialogUtils.showNeedCharge({button1 = "前往",title = "钻石不足",callback1 = function ( ... )
        --     self._viewMgr:showView("vip.VipView", {viewType = 0})
        -- end})
    end
end

-- 宝箱点击
function AcLuckyLotteryDialog:luckyBoxClicked(sender)
    if not self._runeLotteryModel:isLotteryOpen() then
        self._viewMgr:showTip("幸运夺宝活动已结束")
        return
    end
    if sender._isCanGet then
        print("================发送领宝箱协议============")
        self._serverMgr:sendMsg("RuneLotteryServer", "getRuneBox", {id=sender._needCount}, true, {}, function(data)
            if data["reward"] then 
                DialogUtils.showGiftGet({ gifts = data["reward"], hide = self, callback = function()                    
                    -- 更新宝箱状态
                    sender._normal = false
                    sender._isCanGet = false
                    sender._getMc:setVisible(false)
                
                    sender:loadTextures(sender._getImg .. ".png",sender._getImg .. ".png","",1)
                    sender:setOpacity(255)
                    self._serverData    = self._runeLotteryModel:getLotteryData() or {}
                end,notPop = false})
            end 
        end)       
    elseif sender._normal then
        -- 预览
        dump(sender._rewardArr,"sender._rewardArr",3)
        DialogUtils.showGiftGet({ gifts = sender._rewardArr, viewType = 2,des=""}) -- des = ""
    else
        self._viewMgr:showTip(lang("TiPS_YILINGQU"))
    end

end
function AcLuckyLotteryDialog:reflashUI(data)
    print("=========================reflashUI()=====")
end

function AcLuckyLotteryDialog:playAnim(reward,callBack)
    self:lock(-1)
    if not reward or type(reward) ~= "table" then
        return
    end
    local createItemFunc = function(rewardD,posX,posY)
        local icon        
        local itemId 
        if rewardD[1] == "tool"then
            itemId = rewardD[2]
            local toolD = tab:Tool(tonumber(itemId))
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = rewardD[3]})
        elseif rewardD[1] == "rune" then
            if type(rewardD[2]) == "string" then
                local dataTemp = itemType[tonumber(acOpenId)]
                itemId = dataTemp[rewardD[2]][2]
                -- print("===========rewardD[2]===",rewardD[2])
            else
                itemId = rewardD[2]
            end
            -- print("==================itemId====",itemId)
            local itemData = tab:Rune(itemId)
            icon =IconUtils:createHolyIconById({suitData = itemData})

        else
            itemId = IconUtils.iconIdMap[rewardD[1]]
            local toolD = tab:Tool(tonumber(itemId))
            icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD,num = rewardD[3]})
            
        end
        icon:setScale(0.8)
        icon:setPosition(posX,posY)
        icon:setAnchorPoint(0.5,0.5)
        self._buyBgImg:addChild(icon)
        
        local boxIcon = icon.boxIcon
        local iconColor = icon.iconColor
        if boxIcon then
            boxIcon:setVisible(false)
        end
        if iconColor then
            iconColor:setVisible(false)
        end
        return icon
    end

    local rewardGifts = {}
    local i = 0
    local randNum = math.random(1, 2)
    local time = 0
    local totalTime = 0
    -- print("=========randNum============",randNum)
    for i=1,randNum do
        for k,v in pairs(self._itemArr) do
            local item = v
            local selectAnim = item._selectAnim
            -- print("==============time===",time)
            local action = cc.Sequence:create(cc.DelayTime:create(time),
                cc.CallFunc:create(function()
                    selectAnim:setVisible(true)
                end),
                cc.DelayTime:create(0.05),
                cc.CallFunc:create(function()
                    selectAnim:setVisible(false)
                end)
                )
            item:runAction(action)
            time = time + 0.05
        end
    end
    
    self._buyPanel:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )
        self._buyPanel:setVisible(false)
    end)))
    local rewardCount = #reward
    local rewardIndex = 1
    -- print("===========rewardCount===",rewardCount)
    local buyItemPosX = 42
    local buyItemPosY = 98

    for i=1,5 do
        if rewardIndex > rewardCount then
            break
        end
        for k,v in pairs(self._itemArr) do
            if rewardIndex > rewardCount then
                break
            end
            local item = v
            local selectAnim = item._selectAnim
            -- print("=========111111111111111====",rewardIndex,reward[rewardIndex]["grid"])
            if reward[rewardIndex] and item._index == reward[rewardIndex]["grid"] then
                -- dump(reward[rewardIndex],"reward[rewardIndex]==>",5)
                -- print("==============time===",time)
                if not item._selectReward then 
                    item._selectReward = {}
                end
                local icon = createItemFunc(reward[rewardIndex]["itemId"],buyItemPosX,buyItemPosY)
                buyItemPosX = buyItemPosX + 78
                table.insert(rewardGifts, reward[rewardIndex]["itemId"])
                rewardIndex = rewardIndex + 1
                icon:setVisible(false)
                table.insert(item._selectReward, icon)

                local action = cc.Sequence:create(cc.DelayTime:create(time),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.08),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end),
                    cc.CallFunc:create(function()
                        if item._selectReward and item._selectReward[1] then
                            item._selectReward[1]:setVisible(true)
                            table.remove(item._selectReward,1)
                        end
                    end)
                    )
                item:runAction(action)
                -- print("============rewardIndex==",rewardIndex)
                time = time + 0.8
            else                
                -- print("==============time===",time)
                local action = cc.Sequence:create(cc.DelayTime:create(time),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(true)
                    end),
                    cc.DelayTime:create(0.05),
                    cc.CallFunc:create(function()
                        selectAnim:setVisible(false)
                    end)
                    )
                item:runAction(action)
                time = time + 0.05
            end
        end
    end

    self._bg:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function( ... )
        -- dump(rewardGifts,"rewardGifts==>",5)
        self:unlock()
        local closeFunc = function()
            for k,v in pairs(self._itemArr) do 
                if v._selectReward then
                    v._selectReward = nil
                end
            end                 
            self._buyBgImg:removeAllChildren()
            if callBack then
                callBack()
            end
            self._buyPanel:setVisible(true)
        end
        self._viewMgr:showDialog("activity.acLuckyLottery.AcLuckyLotteryGetDialog", { 
            buyNum = self._buyNum,
            gifts = rewardGifts, 
            hide = self, 
            againCallBack = function()
                closeFunc() 
                ScheduleMgr:delayCall(1, self, function()
                      self:lotteryBtnClicked()
                 end)
            end,
            closeCallback = function()  
                closeFunc()
            end,
            notPop = false}, true,false,nil,true)
    end)))
end

--[[
-- do动画调试
function AcLuckyLotteryDialog:debugFunc( ... )
        print("==================self_buyNum==",self._buyNum)
        local reward = {
            [1] = {
                grid   = 2,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [2] = {
                grid   = 7,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [3] = {
                grid   = 9,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [4] = {
                grid   = 14,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            },
            [5] = {
                grid   = 9,
                itemId = {
                    [1] = "rune",
                    [2] = 20404,
                    [3] = 1,
                }
            }

        }
        self:playAnim(reward,function( ... )
            self:updateDataAndPanel()
        end)
end
--]]

return AcLuckyLotteryDialog