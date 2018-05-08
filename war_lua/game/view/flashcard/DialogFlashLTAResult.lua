--[[
    Filename:    DialogFlashLTAResult.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-7 19:14:47
    Description: 限时魂石抽卡界面
--]]

local DialogFlashLTAResult = class("DialogFlashLTAResult",BasePopView)

function DialogFlashLTAResult:ctor(data)
    self.super.ctor(self)
    self._ltAwkModel = self._modelMgr:getModel("LimitAwakenModel")
    self._playerDayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._isUseLuck = self._userModel:drawUseLuckyCoin()
    self.callback = data.callback or nil
    self._showType = data.showType or nil   --父类型
    self._genNum10 = data.costNum or 2700   --十连消耗数量
    self.buyNum = data.buyNum               --一次/十次
    self._costType = data.costType          --金币/钻石
    self._curData = data.curData            --活动结束时间
    self._acId = tonumber(data.acId)        --兵团id
    local uiInfo = {   --新活动修改处
        [1051] = {
            titleAnim = "bimengxianshihunshi_bimenghunshi",
            teamId = 407,
            itemId = 94407,
            },
        [1052] = {
            titleAnim = "najiaxianshihunshi_najiahunshi",
            teamId = 606,
            itemId = 94606,
            },
        [1053] = {
            titleAnim = "datianshihunshi_datianshihunshi",
            teamId = 107,
            itemId = 94107,
            },
        [1054] = {
            titleAnim = "juexinggulong_juexinggulong",
            teamId = 307,
            itemId = 94307,
            },
        [1055] = {
            titleAnim = "jinlongzhaomu_jinlongzhaomu",
            teamId = 207,
            itemId = 94207,
            },
        [1056] = {
            titleAnim = "juexingdaemozhaomu_juexingdaemozhaomu",
            teamId = 507,
            itemId = 94507,
            },
        }

    self._uiInfo = uiInfo[self._acId]
end

function DialogFlashLTAResult:getMaskOpacity()
    return 230
end

function DialogFlashLTAResult:onDestroy()
    
end

function DialogFlashLTAResult:onInit()
    self._bg = self:getUI("bg")
    self._bg1 = self:getUI("bg.bg1")
    self.bgWidth, self.bgHeight = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._okBtn = self:getUI("bg.closeBtn")
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setSwallowTouches(false)

    -- 动画相关
    self._itemNames = {}
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setOpacity(0)

    self._bg1:setOpacity(0)
    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
        
    audioMgr:playSound("ItemGain_1")
    -- item 容器
    self._itemTable = {}
    -- -- 兵团转换的兵团背景光效
    self._isChangeMc = {}

    --backBtn
    self._backBtn = self:getUI("bg.backBtn")
    self._backBtn:setOpacity(0)
    self._backBtn:setCascadeOpacityEnabled(true)
    self._backBtn:setVisible(false)
    self._hadClose = false
    self:registerClickEvent(self._backBtn, function()
        self:closeView()
    end)
    self._backBtn:setTouchEnabled(false)

    --tenAginBtn
    self._tenAginBtn = self:getUI("bg.tenAginBtn")
    self._tenAginBtn:setOpacity(0)
    self._tenAginBtn:setCascadeOpacityEnabled(true)
    self._tenAginBtn:setVisible(false)
    self._tenAginBtn:setTouchEnabled(false)

    self._tenBtn = self:getUI("bg.tenAginBtn.tenAginBtn")
    self:registerClickEvent(self._tenBtn, function()
        --魂石上限提示
        local sysTeamD = tab.team[self._uiInfo["teamId"]]
        local _, hasNum = self._modelMgr:getModel("ItemModel"):getItemsById(sysTeamD["awakingUp"])
        local isTiped = self._ltAwkModel:getIsTiped()

        local function tenRecruitTip()
            local tag = SystemUtils.loadAccountLocalData("LIMIT_AWAKE_NO_WARING")
            if tag and tag == 1 then
                self:buyItemByGem(self._genNum10,10)
            else
                self._viewMgr:showDialog("shop.DirectChargeSureDialog",{
                    localTxt = "LIMIT_AWAKE_NO_WARING",
                    contentTxt = "awake_warning1",
                    callback = function ()
                        self:buyItemByGem(self._genNum10,10)
                    end})
            end
            
        end

        if not isTiped and hasNum >= 520 then  --不是免费 / 魂石上限
            self._ltAwkModel:setIsTiped(true)
            self._viewMgr:showDialog("global.GlobalSelectDialog",
            {   desc = lang("ac1051tips2_awake"),
                button1 = "确定",
                button2 = "取消", 
                callback1 = function ()
                    tenRecruitTip()
                end,
                callback2 = function()
                end})
        else
            tenRecruitTip()
        end
    end)
    self._tenBtn:setTouchEnabled(false)
    
    self:initTenAginBtn()
end
function DialogFlashLTAResult:animBegin(callback)
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height

    ScheduleMgr:delayCall(0, self, function( )
        self:addPopViewTitleAnim(self._bg, self._uiInfo["titleAnim"], bgW/2, 480)
    end)
    ScheduleMgr:delayCall(700, self, function( )
        if callback and self._bg then
            callback()
            self._bg1:runAction(cc.FadeIn:create(0.2))
            local children1 = self._bg1:getChildren()
            for k,v in pairs(children1) do
                if v:getName() ~= "touchLab" then
                    v:runAction(cc.FadeIn:create(0.2))
                end
            end
            if self.buyNum == 10 then
                local mcWupintexiao = mcMgr:createViewMC("wupintexiao_flashcardanim", true, false, function (_, sender)
                end,RGBA8888)
                self._mcWupintexiao = mcWupintexiao
                mcWupintexiao:setPosition(cc.p(bgW/2,bgH/2+30))
                self._bg1:addChild(mcWupintexiao,99)
            end
        end
    end)
end

local expBottle = {
    [30201] = true,
    [30202] = true,
    [30203] = true,
}
-- 接收自定义消息
function DialogFlashLTAResult:reflashUI(data)
    local gifts = data.awards or data
    -- dump(gifts)
    for k,v in pairs(gifts) do
        if v.type and ( v.type ~= "tool" or expBottle[v.typeId] ) then
            gifts[k] = nil
        end
    end
    self._gifts = gifts
    if gifts and #gifts == 0 then
        gifts = {}
        table.insert(gifts, data.awards or data)
    end

    local blank = 25
    local colNum = 5
    local itemHeight,itemWidth = 110,96
    local maxHeight = (itemHeight+blank) * math.ceil( #gifts / colNum)
    local x = 3
    local y = 0
    local offsetX,offsetY = 0,0

    if #gifts <= colNum then
        offsetX = (self.bgWidth-#gifts*(itemWidth+blank))/2+itemWidth/2-10
        offsetY = self.bgHeight/2-30
    else
        offsetX = (self.bgWidth-colNum*(itemWidth+blank))/2+itemWidth/2
        offsetY = self.bgHeight/2 + maxHeight/2 -  itemHeight + 15
    end

    x = offsetX+20
    y = y+offsetY+3
    
    -- 轮次添加物品特效
    local createItemDeque
    local xFactor = 1
    local createNextItemFunc = function( index,small )
        createItemDeque(index,small)
    end
    createItemDeque = function( index,small )
        local itemData = gifts[index]
        if not itemData then return end
        local itemId = itemData.typeId
        -- 如果是再次购买，不加动画，兵团转碎片不加展示卡片效果
        local callFunc = function()   end
        if not self._isAgain then
            callFunc = function( )                
                if itemData.isChange then
                    local mcSplash = mcMgr:createViewMC("shanguang_flashcardanim", true, false, function (_, sender)
                        sender:gotoAndPlay(80)
                    end)
                    mcSplash:setPosition(cc.p(self.bgWidth/2,self.bgHeight/2+30))
                    self._bg:addChild(mcSplash,2)

                    if itemData.isChange == 0 then
                        local teamId = tonumber(string.sub(tostring(itemId),2))
                        DialogUtils.showTeam({teamId = teamId,callback = function (  )
                            createNextItemFunc(index+1)
                        end})
                        
                    elseif itemData.isChange == 1 then
                        DialogUtils.showCard({itemId = itemId,changeNum = itemData.num,callback = function( )
                            createNextItemFunc(index+1)
                        end})
                    end
                else
                    audioMgr:playSound("ItemGain_2")
                    createNextItemFunc(index+1,0.8)
                end 
            end       
        end
        self:createItem(itemData, x, y, index-1, callFunc, small)
         x = x + xFactor*(itemWidth + blank)
        if index % colNum == 0 then 
            x =  offsetX+20
            y = y - blank - itemHeight - 24 --name高度
        end
        if self._isAgain then
            createNextItemFunc(index+1,0.8)
        end
    end

    local bg1Height = 200
    local maxHeight = self._bg1:getContentSize().height + 12
    if not self._isAgain then
        self._bg1:setOpacity(0)
        self:animBegin(function( )
            self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
            self._bg1:setOpacity(255)
            local sizeSchedule
            local step = 0.5
            local stepConst = 30
            local sizeSchedule
            sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
                stepConst = stepConst-step
                if stepConst < 1 then 
                    stepConst = 1
                end
                bg1Height = bg1Height+stepConst
                if bg1Height < maxHeight then
                    self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
                else
                    self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,maxHeight))
                    self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                    ScheduleMgr:unregSchedule(sizeSchedule)
                    self:addDecorateCorner()
                end
            end)
            createItemDeque(1,0.9)
        end)
    else
        createItemDeque(1,0.9)
    end
end

function DialogFlashLTAResult:createItem( data,x,y,index,callfunc,scale )
    local itemData
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num
    if itemType ~= "tool" then
        itemId = IconUtils.iconIdMap[itemType]
    end

    local scaleOffset = 0
    if data.isChange == 0 then
        scale = 1
        scaleOffset = 6
    else
        scale = 0.9
    end
    itemData = tab:Tool(itemId)
    if itemData == nil then
        itemData = tab:Team(itemId)
    end

    local item 
    if data.isChange == 0 then
        local teamId  = self._uiInfo["teamId"]
        local teamD = tab:Team(teamId)
        itemData = teamD
        item = IconUtils:createSysTeamIconById({sysTeamData = teamD })
        local iconColor = item:getChildByName("iconColor")
        iconColor:loadTexture("globalImageUI_squality_jin.png",1)
        iconColor:setContentSize(cc.size(107, 107))
    else
        item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,fromChouka=true,effect = false })
    end
    item:setScaleAnim(false)
    item:setSwallowTouches(true)
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:setPosition(cc.p(x,y+50+scaleOffset + 17))
    item:setVisible(true)

    if itemData and itemData.name then
        --itemName
        local itemName = ccui.Text:create()
        itemName:setFontName(UIUtils.ttfName)
        itemName:setTextAreaSize(cc.size(100,65))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
        itemName:setFontSize(20)
        itemName:setString(lang(tostring(itemData.name)))

        if data.isChange == 0 then
            itemName:setColor(cc.c3b(240, 240, 0))
        else
            itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (itemData.color or 1)])
        end
        itemName:enableOutline(cc.c4b(0,0,0,255),1)
        itemName:setAnchorPoint(cc.p(0.5,1))
        itemName:setPosition(cc.p(x,y + 22))
        
        self._bg:addChild(itemName,2)
        itemName:setVisible(false)
        table.insert(self._itemNames, itemName)

        --itemNum
        if tonumber(itemId) == tonumber(self._uiInfo["itemId"]) then
            local nameTemp = lang(itemData.name)
            local disNum = 0
            if utf8.len(nameTemp) <= 4 then   --少于等于4个字
                disNum = 23
            end
            self:showItemsNum(x, y, disNum)
        end
    end

    table.insert(self._itemTable,item)
    self._bg:addChild(item,2)

    item:setOpacity(0)
    local children = item:getChildren()
    for k,v in pairs(children) do
        if v:getName() == "numLab" then
            v:setVisible(false)
        else
            v:setOpacity(0)
        end
        if v.setSwallowTouches then
            v:setSwallowTouches(true)
        end
    end
    local bgMc = item:getChildByName("bgMc")
    if bgMc then
        bgMc:setVisible(false)
    end
    
    ScheduleMgr:delayCall(100, self, function( )
        if not itemData or not data or not item then return end
        -- 加背景光效
        local bgMcName 
        if itemData.color == 5 then
            bgMcName = "chengguangquan_flashcardanim"
        elseif itemData.color == 4 then
            bgMcName = "ziguangquan_flashcardanim"
        end
        if bgMcName then
            local mc = mcMgr:createViewMC(bgMcName, false, true, function (_, sender)
                sender:removeFromParent()
            end)

            mc:setPosition(cc.p(x,y+50))
            mc:setPlaySpeed(0.5)
            self._bg:addChild(mc,9)
        end
        if data.isChange then    
            local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(x,y+50)      
            mc:setScale(1.1)
            self._bg:addChild(mc) 

            table.insert(self._isChangeMc,mc)
            if data.isChange == 0 then 
                local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection",
                                                  "tongyongdibansaoguang_itemeffectcollection",
                                                  "wupinkuangxingxing_itemeffectcollection"})
                item:addChild(mc, 3)
            elseif data.isChange == 1 then -- 转化碎片也加扫光
                -- local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection"})
                -- item:addChild(mc, 20)
            end
                      
        end
        if bgMc then
            bgMc:setVisible(true)
        end
        if not self._isAgain then
            item:setScale(2)
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,(scale or 1)*0.9)),cc.ScaleTo:create(0.3,scale),cc.CallFunc:create(function( )
                item:setScaleAnim(true)
            end)))
        else
            item:setScale(scale)
            item:setScaleAnim(true)
            item:setOpacity(255)
        end
        if callfunc then
            callfunc()
        end

        local children = item:getChildren()
        for k,v in pairs(children) do
            if v:getName() == "numLab" then
                v:setVisible(true)
            end
            if v:getName() ~= "bgMc" then
                v:runAction(cc.FadeIn:create(0.2))
            end
        end

        if index == #self._gifts-1 or #self._gifts == 1 then
            for k,v in pairs(self._itemNames) do
                v:setVisible(true)
            end
            ScheduleMgr:delayCall(800, self, function( )
                if tolua.isnull(self._touchLab) or tolua.isnull(self._tenAginBtn) then return end
                if 10 == self.buyNum then
                    self._tenAginBtn:setVisible(true)
                    self._tenAginBtn:runAction(cc.FadeIn:create(0.1)) 

                    self._backBtn:setVisible(true)
                    self._backBtn:runAction(cc.FadeIn:create(0.1))                     
                else
                    self._touchLab:setVisible(true) 
                    self._touchLab:runAction(cc.FadeIn:create(0.2))
                end                         
            end)
            ScheduleMgr:delayCall(1000, self, function( )
                if tolua.isnull(self._touchLab) or tolua.isnull(self._tenAginBtn) then return end
               
                -- 按钮可点击
                if 10 == self.buyNum then
                    self._tenBtn:setTouchEnabled(true)
                    self._tenAginBtn:setTouchEnabled(true)
                    self._backBtn:setTouchEnabled(true)
                else
                    self:registerClickEventByName("closePanel", function()                       
                        self:closeView()
                    end)

                    self:registerClickEventByName("bg.bg1", function()
                        self:closeView()
                    end)

                    self:registerClickEventByName("bg", function()
                        self:closeView()
                    end)
                end             
            end)
            if not tolua.isnull(self._mcWupintexiao) then
                self._mcWupintexiao:removeFromParent()
            end
        end
    end)
end

function DialogFlashLTAResult:showItemsNum(x, y, disNum)
    local teamModel = self._modelMgr:getModel("TeamModel")
    local itemModel = self._modelMgr:getModel("ItemModel")
    local itemId = self._uiInfo["itemId"]
    local teamId = self._uiInfo["teamId"]
    local sysTeamD = tab.team[teamId]
    local teamData = teamModel:getTeamAndIndexById(teamId)
    
    local need
    local isAwk, awkLv = TeamUtils:getTeamAwaking(teamData)
    local awakeList = sysTeamD["awakingUpNum"]
    local _, hasNum = itemModel:getItemsById(sysTeamD["awakingUp"])

    if isAwk then
        if awkLv > #awakeList then
            return
        end
        need = awakeList[awkLv]
    else
        need = 0
        for i,v in ipairs(awakeList) do
            need = need + v
            if hasNum < need then
                break
            end
        end
    end

    local numStr = ccui.Text:create()
    numStr:setFontName(UIUtils.ttfName)
    numStr:setTextAreaSize(cc.size(100,65))
    numStr:setTextHorizontalAlignment(1)
    numStr:setTextVerticalAlignment(0)
    numStr:setFontSize(20)
    numStr:setAnchorPoint(cc.p(0.5, 1))
    numStr:setPosition(cc.p(x, y - 25 + disNum))
    numStr:setString("(".. hasNum .. "/" .. need .. ")")
    numStr:setVisible(false)
    self._bg:addChild(numStr, 3)

    table.insert(self._itemNames,numStr)
    if hasNum >= need then
        numStr:setColor(UIUtils.colorTable.ccUIBaseColor2)
    else
        numStr:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    end
end

function DialogFlashLTAResult:closeView()
    if self._hadClose == false then
        self._hadClose = true
        if self.callback and type(self.callback) == "function" then
            self.callback()
        end
        self:close(true)
        UIUtils:reloadLuaFile("flashcard.DialogFlashLTAResult")
    end
end

function DialogFlashLTAResult:initTenAginBtn()
    self._costImg = self:getUI("bg.tenAginBtn.costImg")
    self._costImg:setScale(0.64)
    self._costValue = self:getUI("bg.tenAginBtn.costValue")

    local num = self._genNum10 or -1
    self._costValue:setString(num)

    local costCoin = 0
    if self._isUseLuck then
        self._costImg:loadTexture("globalImageUI_luckyCoin.png",1)
        costCoin = self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0
    else
        self._costImg:loadTexture("globalImageUI_diamond.png",1)
        costCoin = self._modelMgr:getModel("UserModel"):getData().gem or 0
    end

    if costCoin < num then
        self._costValue:setColor(cc.c4b(255, 23, 23, 255))
    else
        self._costValue:setColor(cc.c4b(0, 255, 0, 255))
    end
end

--限时兵团十连抽
function DialogFlashLTAResult:buyItemByGem(cost,num)
    local sysTLConfig = tab.limitItemsConfig

    local costCoin = 0
    if self._isUseLuck then
        costCoin = self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0
    else
        costCoin = self._modelMgr:getModel("UserModel"):getData().gem or 0
    end

    local curTime = self._userModel:getCurServerTime()
    local endTime = self._curData["endTime"] or 0
    if curTime >= endTime then
        self._viewMgr:showTip("限时魂石活动已结束")
        return
    end

    self._backBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)

    if costCoin < sysTLConfig["cost10"]["num"] then
        self:setVisible(false)
        DialogUtils.showNeedCharge({
            desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),
            callback1 = function( )
                local viewMgr = ViewManager:getInstance()
                -- viewMgr:showView("vip.VipView", {viewType = 0, callback = function()
                DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = sysTLConfig["cost10"]["num"] - costCoin ,callback = function()
                    if self.initTenAginBtn then
                        self:initTenAginBtn()
                    end
                end})
            end,
            callback3 = function( )
                self._backBtn:setTouchEnabled(true)
                self._tenAginBtn:setTouchEnabled(true)
                self._tenBtn:setTouchEnabled(true)
                self:initTenAginBtn()
                self:setVisible(true)
            end,
            callback4 = function()
                self._backBtn:setTouchEnabled(true)
                self._tenAginBtn:setTouchEnabled(true)
                self._tenBtn:setTouchEnabled(true)
                self:initTenAginBtn()
                self:setVisible(true)
            end})
    else
        self._backBtn:runAction(cc.FadeOut:create(0.1))
        self._tenAginBtn:runAction(cc.FadeOut:create(0.1))
        self._serverMgr:sendMsg("LimitItemsServer", "limitItemsLottery", {num = 10}, true, {}, function(result, errorCode)
            audioMgr:playSound("Draw")
        
            for k,v in pairs(self._itemTable) do
                v:removeFromParent()
            end
            for k,v in pairs(self._itemNames) do
                v:removeFromParent()
            end
            for k,v in pairs(self._isChangeMc) do
                v:removeFromParent()
            end
            self._itemTable = {}
            self._itemNames = {}
            self._isChangeMc = {}

            ScheduleMgr:delayCall(800, self, function( )
                self._isAgain = true
                self:reflashUI(result.reward)
                self:initTenAginBtn()
            end)
        end)
    end
end

function DialogFlashLTAResult:showItemAgin(data)
    --更新用户钻石
    if data.d and data.d.drawAward then
        self._playerDayModel:updateDrawAward(data.d.drawAward)
    end
   
    if data.d and data.d.dayInfo then
        self._playerDayModel:updateDayInfo(data.d.dayInfo)
    end

    if data.d and data.d.items then
        local itemModel = self._modelMgr:getModel("ItemModel")
        itemModel:updateItems(data.d.items)
        data.d.items = nil
    end

    if data.d and data.d.teams then
        local teamModel = self._modelMgr:getModel("TeamModel")
        teamModel:updateTeamData(data.d.items)
        data.d.teams = nil
    end
    if data.d then
        local userModel = self._modelMgr:getModel("UserModel")
        userModel:updateUserData(data.d)
    end

    self._isAgain = true
    self:reflashUI(data)
end

return DialogFlashLTAResult