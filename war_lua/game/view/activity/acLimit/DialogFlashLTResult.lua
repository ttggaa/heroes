--[[
    Filename:    DialogFlashLTResult.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-04-18 22:21:47
    Description: 限时兵团抽卡界面
--]]

local discountTen   = tab:Setting("G_DISCOUNT_TENTIMES_DRAW").value
local toolSingle    = tab:Setting("G_DRAWCOST_TOOL_SINGLE").value[3]
local toolTen       = tab:Setting("G_DRAWCOST_TOOL_TENTIMES").value[3]
local gemSingle     = tab:Setting("G_DRAWCOST_GEM_SINGLE").value[3]
local gemTen        = tab:Setting("G_DRAWCOST_GEM_TENTIMES").value[3]

local DialogFlashLTResult = class("DialogFlashLTResult",BasePopView)

function DialogFlashLTResult:ctor(data)
    self.super.ctor(self)
    self._playerDayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._isUseLuck = self._userModel:drawUseLuckyCoin()
    self.callback = data.callback or nil
    self._showType = data.showType or nil   --父类型
    self._genNum10 = data.costNum or 2700   --十连消耗数量
    self.buyNum = data.buyNum               --一次/十次
    self._costType = data.costType          --金币/钻石
    self._curData = data.curData            --活动结束时间
    self._acId = tonumber(data.acId)        --活动activ_id
    self._id = data.id                      --活动id
    local uiInfo = {   --新活动修改处
        [1001] = {
            titleAnim = "gongxihuodetianshi_huodetitleanim",
            itemId = 3107},
        [1002] = {
            titleAnim = "najiahuode_talou",
            itemId = 3606},
        [1003] = {
            titleAnim = "bimengzhaomu_bimenghuode",
            itemId = 3407},
        [1004] = {
            titleAnim = "gulongzhaomu_gulongzhaomu",
            itemId = 3307},
        [1005] = {
            titleAnim = "xianshidaemo_xianshidaemo",
            itemId = 3507},
        [1006] = {
            titleAnim = "shengqishizhaomu_shengqishizhaomu",
            itemId = 3108},
        [1007] = {
            titleAnim = "heilongzhaomu_heilongzhaomu",
            itemId = 3707},
        [1008] = {
            titleAnim = "taitanzhaomu_taitanzhaomu",
            itemId = 3607},
        [1009] = {
            titleAnim = "lvlongzhaomu_lvlongzhaomu",
            itemId = 3207},
        [1010] = {
            titleAnim = "manniuzhaomu_manniuzhaomu",
            itemId = 3805},
        [1011] = {
            titleAnim = "jiutoushezhaomu_jiutoushezhaomu",
            itemId = 3807},
        [1012] = {
            titleAnim = "kuangzhanshizhaomu_kuangzhanshizhaomu",
            itemId = 3408},
        [1013] = {
            titleAnim = "baozanglierenzhaomu_baozanglierenzhaomu",
            itemId = 39902},
        [1014] = {
            titleAnim = "longguizhaomu_longguizhaomu",
            itemId = 39906},
        [1015] = {
            titleAnim = "honglongzhaomu_honglongzhaomu",
            itemId = 3708},
        }

    self._uiInfo = uiInfo[self._acId]
end

function DialogFlashLTResult:getMaskOpacity()
    return 230
end

function DialogFlashLTResult:onDestroy()
    discountTen = nil
    toolSingle = nil
    toolTen = nil
    gemSingle = nil
    gemTen = nil
end

function DialogFlashLTResult:onInit()
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

    --onceAginBtn
    self._onceAginBtn = self:getUI("bg.onceAginBtn")
    self._onceAginBtn:setVisible(false)
    self._onceAginBtn:setTouchEnabled(false)

    --tenAginBtn
    self._tenAginBtn = self:getUI("bg.tenAginBtn")
    self._tenAginBtn:setOpacity(0)
    self._tenAginBtn:setCascadeOpacityEnabled(true)
    self._tenAginBtn:setVisible(false)
    self._tenAginBtn:setTouchEnabled(false)

    --tenBtn
    self._tenBtn = self:getUI("bg.tenAginBtn.tenAginBtn")
    self:registerClickEvent(self._tenBtn, function()
        self:buyItemByGem(self._genNum10,10)
    end)
    self._tenBtn:setTouchEnabled(false)
    
    self:initTenAginBtn()
end
function DialogFlashLTResult:animBegin(callback)
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
function DialogFlashLTResult:reflashUI(data)
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

function DialogFlashLTResult:createItem( data,x,y,index,callfunc,scale )
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
        local teamId  = TeamUtils:getTeamIdByItemId(itemId)
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
    item:setPosition(cc.p(x,y+50+scaleOffset))
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
        itemName:setPosition(cc.p(x,y))
        self._bg:addChild(itemName,2)
        itemName:setVisible(false)
        table.insert(self._itemNames, itemName)

        --itemNum
        if tonumber(itemId) == tonumber(self._uiInfo["itemId"]) then
            local tempId = TeamUtils:getTeamIdByItemId(self._uiInfo["itemId"])
            local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(tempId)
            if teamData == nil then --未招募
                local haveNum = ccui.Text:create()
                haveNum:setFontName(UIUtils.ttfName)
                haveNum:setTextAreaSize(cc.size(100,65))
                haveNum:setTextHorizontalAlignment(1)
                haveNum:setTextVerticalAlignment(0)
                haveNum:setFontSize(20)

                local _, _haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._uiInfo["itemId"])
                haveNum:setString("(".. _haveNum .. "/80)")
                if _haveNum >= 80 then
                    haveNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
                else
                    haveNum:setColor(UIUtils.colorTable.ccUIBasePromptColor)
                end
                haveNum:setAnchorPoint(cc.p(0.5, 1))
                haveNum:setPosition(cc.p(x, y - 22))
                self._bg:addChild(haveNum, 3)
                haveNum:setVisible(false)
                table.insert(self._itemNames,haveNum)
            end
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

function DialogFlashLTResult:closeView()
    if self._hadClose == false then
        self._hadClose = true
        if self.callback and type(self.callback) == "function" then
            self.callback()
        end
        self:close(true)
        UIUtils:reloadLuaFile("activity.acLimit.DialogFlashLTResult")
    end
end

function DialogFlashLTResult:initTenAginBtn()
    self._costImg = self:getUI("bg.tenAginBtn.costImg")
    self._costValue = self:getUI("bg.tenAginBtn.costValue")
    self._costImg:setScale(0.64)

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
function DialogFlashLTResult:buyItemByGem(cost,num)
    local sysTLConfig = tab.limitTeamConfig

    local costCoin = 0
    if self._isUseLuck then
        costCoin = self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0
    else
        costCoin = self._modelMgr:getModel("UserModel"):getData().gem or 0
    end

    local curTime = self._userModel:getCurServerTime()
    local endTime = self._curData["endTime"] or 0
    if curTime >= endTime then
        self._viewMgr:showTip("限时招募活动已结束")
        return
    end

    self._backBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)

    if costCoin < sysTLConfig["cost10"]["num"] then
        self:setVisible(false)
        DialogUtils.showNeedCharge({
            desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),
            -- button1 = "前往",
            -- title = "幸运币不足",
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
        self._serverMgr:sendMsg("LimitTeamsServer", "limitTeamLottery", {num = 10, acId = self._id}, true, {}, function(result, errorCode)
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

function DialogFlashLTResult:showItemAgin(data)
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

return DialogFlashLTResult