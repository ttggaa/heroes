--[[
    Filename:    CrusadeRewardNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-02 15:40:20
    Description: File description
--]]

local CrusadeRewardNode = class("CrusadeRewardNode", BasePopView)

function CrusadeRewardNode:ctor()
    CrusadeRewardNode.super.ctor(self)
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._requestNum = 0
end

function CrusadeRewardNode:onInit()
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._widget:addChild(bgLayer, -1)

    local tempLab = self:getUI("bg.itemBg.Label_26")
    tempLab:enableOutline(cc.c4b(0,0,0),1)
    
    --_requestNum 已请求次数   _lastTimes已购买次数  _uncostNum免费次数
    self._callbackParent = function()
        if self._requestNum > self._lastTimes and self._requestNum >= (self._priviNum + self._uncostNum) and self._callback ~= nil then 
            self._callback()
        end
        self:close()
        UIUtils:reloadLuaFile("crusade.CrusadeRewardNode")
    end
	self:registerClickEventByName("bg.closeBtn", function ()
        self._callbackParent()
        
    end)

    self:registerClickEventByName("bg.cancelBtn", function ()
        self._callbackParent()
    end)

    self._playAnim = false
end

function CrusadeRewardNode:reflashUI(data)
    -- dump(data, "crusade", 10)
	self._curCrusadeId = data.crusadeId
    self._token = data.netData.token
    self._callback = data.callback
    self._buildId = data.crusadeData["buildId"]
    self._lastTimes = data.crusadeData["buyTimes"] or 0
    self._requestNum = data.crusadeData["buyTimes"] or 0
    
    --免费次数
    self._priviNum = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_15)
    self._uncostNum = 0
    for k,v in pairs(tab.crusadeEvent) do
        if v["cost"] == 0 and tonumber(k) < 20 then   --排除特权次数
            self._uncostNum = self._uncostNum + 1
        end
    end

    local bg = self:getUI("bg")
    --精灵
    self._angleNode = ccui.Layout:create()
    self._angleNode:setPosition(bg:getContentSize().width/2 + 40, bg:getContentSize().height/2 + 15)
    bg:addChild(self._angleNode)
    
    local tmpMc1 = mcMgr:createViewMC("hudie_jinglingbaoxiang", true, false)
    tmpMc1:setPosition(0, 0)
    self._angleNode:addChild(tmpMc1)

    self._fairyMc = mcMgr:createViewMC("jinglingbaoxiang_jinglingbaoxiang", true, false)
    self._fairyMc:setPosition(0, -38)
    self._angleNode:addChild(self._fairyMc)

    self._fairyMc1 = mcMgr:createViewMC("kaibaoxiang_jinglingbaoxiang", false, false)
    self._fairyMc1:setPosition(0, -38)
    self._angleNode:addChild(self._fairyMc1)
    self._fairyMc1:setVisible(false)
    self._fairyMc1:stop(false)
    self._fairyMc1:addCallbackAtFrame(30, function ()
        if self._mcCallback ~= nil then 
            self._mcCallback()
        end
        self._playAnim = false
    end)
    self._fairyMc1:addCallbackAtFrame(80, function ()
        self._fairyMc1:stop(false)
        self._fairyMc1:setVisible(false)
        self._fairyMc:setVisible(true)
        self._fairyMc:gotoAndPlay(1)
    end)

    --reward
    local sysCrusadeEvent = tab:CrusadeEvent(1)
    local v = sysCrusadeEvent.showReward[1]
    local itemId 
    if v[1] == "tool" then
        itemId = v[2]
    else
        itemId = IconUtils.iconIdMap[v[1]]
    end
    local toolD = tab:Tool(tonumber(itemId))
    local icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
    local itemBg = self:getUI("bg.itemBg")
    icon:setAnchorPoint(0.5, 0.5)
    itemBg:setScale(0.8)
    icon:setPosition(itemBg:getContentSize().width/2, itemBg:getContentSize().height/2)
    itemBg:addChild(icon)

    self._tipLab = cc.Label:createWithTTF(v[3] .. "~" .. v[4],UIUtils.ttfName, 22)
    self._tipLab:setColor(cc.c4b(215, 245, 215, 255))
    self._tipLab:enableOutline(cc.c4b(0,0,0),1)
    self._tipLab:setAnchorPoint(cc.p(0.5, 0.5))
    self._tipLab:setPosition(itemBg:getContentSize().width/2, 18)
    itemBg:addChild(self._tipLab)     

    --开启状态
    self:updateInfo()

    --进场动画 17/2/3
    self:runAnim()   
end

function CrusadeRewardNode:updateInfo()
    local sysCrusadeBuild = tab:CrusadeBuild(self._buildId)
    local sysCrusadeEvent
    if self._priviNum > self._requestNum then
        sysCrusadeEvent = tab:CrusadeEvent(1)
    else
        sysCrusadeEvent = tab:CrusadeEvent(self._requestNum - self._priviNum + 1)
    end

    local maxTimesTip = self:getUI("bg.maxTimesTip")
    local freeBg = self:getUI("bg.Panel_25")  --特权
    local gemBg = self:getUI("bg.Panel_24")   --钻石
    local discountTag = self:getUI("bg.enterBtn.discount") 
    local cost2 = self:getUI("bg.cost2")
    local discountTag2 = self:getUI("bg.cost2.enterBtn.discount")
    self._rwdTip = maxTimesTip
    maxTimesTip:setVisible(false)
    freeBg:setVisible(false)
    gemBg:setVisible(false)
    discountTag:setVisible(false)
    cost2:setVisible(false)
    discountTag2:setVisible(false)
    
    --最大次数
    if sysCrusadeEvent == nil then 
        maxTimesTip:setString("已达最大次数")
        maxTimesTip:setColor(UIUtils.colorTable.ccUIBaseColor1)
        maxTimesTip:setVisible(true)
        self._rwdTip = maxTimesTip
        return 
    end

    -- rwd
    local reward = sysCrusadeEvent.showReward[1]
    self._tipLab:setString(reward[3] .. "~" .. reward[4])

    -- 特权影响特殊处理
    if self._priviNum > self._requestNum then    --特权免费
        freeBg:setVisible(true)
        self._rwdTip = freeBg
        local labNum = self:getUI("bg.Panel_25.Label_27_0")
        self:getUI("bg.Panel_25.labNum1"):setVisible(false)
        self:getUI("bg.Panel_25.labNum"):setVisible(false)
        labNum:setString("免费")
        discountTag:setVisible(false)
    else
        if sysCrusadeEvent.cost > 0 then
            gemBg:setVisible(true)
            self._rwdTip = gemBg
            local gemIcon = self:getUI("bg.Panel_24.Image_32")
            local scaleNum1 = math.floor((36/gemIcon:getContentSize().width)*100)
            gemIcon:setScale(scaleNum1/100)

        else 
            maxTimesTip:setVisible(true)
            self._rwdTip = maxTimesTip
            maxTimesTip:setString("免费")
            maxTimesTip:setColor(UIUtils.colorTable.ccUIBaseColor2)
        end

        local image_32 = self:getUI("bg.Panel_24.Image_32")
        local labNum = self:getUI("bg.Panel_24.labNum")    
        local discountNum = self:getUI("bg.enterBtn.discount.num") 

        local discountNum2 = self:getUI("bg.cost2.enterBtn.discount.num") 
        local labNum2 = self:getUI("bg.cost2.Panel_24.labNum")
        local enterBtn2 = self:getUI("bg.cost2.enterBtn") 

        -- 单次购买 活动折扣
        local activityModel = self._modelMgr:getModel("ActivityModel") 
        local discount = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_13) or 0
        self._singleCostNum = sysCrusadeEvent.cost
        if discount ~= 0 and sysCrusadeEvent.cost > 0 then 
            self._singleCostNum = math.ceil(self._singleCostNum * (1 + discount))
            discountTag:setVisible(true)
            discountTag2:setVisible(true)

            local discNum = (1 + discount) * 10
            local words = {"一","二","三","四","五","六","七","八","九","十",}

            discountNum:setString(words[discNum] .. "折") 
            labNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
            labNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

            discountNum2:setString(words[discNum] .. "折") 
            labNum2:setColor(UIUtils.colorTable.ccUIBaseColor2)
            labNum2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        else
            labNum:setColor(UIUtils.colorTable.ccUIBaseColor1)
            labNum2:setColor(UIUtils.colorTable.ccUIBaseColor1)
        end
        labNum:setPositionY(image_32:getPositionY() - 2)
        labNum:setString(self._singleCostNum)

        --可连购
        self._canBuyNum = 0   --可刷次数
        self._fCostNum = 0  --需要的花费
        local fMaxNum = self._requestNum - self._priviNum + 1  --当前购买次数
        if sysCrusadeEvent.cost > 0 then
            local sysCru = tab.crusadeEvent
            for i= fMaxNum, 100, 1 do
                if not sysCru[i] or self._canBuyNum >= 5 then
                    break
                end

                if sysCru[i]["cost"] ~= 0 and i >= fMaxNum then   --可连刷次数
                    self._canBuyNum = self._canBuyNum + 1
                    self._fCostNum = self._fCostNum + sysCru[i]["cost"]
                end
            end
        end

        self._fCostNum = math.ceil(self._fCostNum * (1 + discount))
        
        if self._canBuyNum > 1 then
            cost2:setVisible(true)
            enterBtn2:setTitleText("开启" .. self._canBuyNum .. "次")
            labNum2:setString(self._fCostNum)
        end
        
        if self._singleCostNum > 99  and labNum.move == nil then 
            image_32:setPositionX(image_32:getPositionX() - 8)
            labNum:setPositionX(labNum:getPositionX() - 3)
            labNum.move =  1
        end
    end

    self:registerClickEventByName("bg.enterBtn", function ()
        if self._playAnim == true then 
            return
        end
    
        if self._requestNum < (self._priviNum + self._uncostNum) then  
            self:getCrusadeEventReward()
        else
            self:buyCrusadeEventReward(1)
        end
    end)

    self:registerClickEventByName("bg.cost2.enterBtn", function ()
        if self._playAnim == true then 
            return
        end
    
        self:buyCrusadeEventReward(self._canBuyNum)
    end)
end

function CrusadeRewardNode:buyCrusadeEventReward(inNum)
    local vipInfo = self._modelMgr:getModel("VipModel"):getData()
    local sysVip = tab:Vip(vipInfo.level)

    local limitVipLevel, limitVipTimes = self._modelMgr:getModel("VipModel"):getSysVipMaxLimitByField("sectionReset")
    local sysCrusadeEvent
    if self._priviNum > self._requestNum then
        sysCrusadeEvent = tab:CrusadeEvent(1)
    else
        sysCrusadeEvent = tab:CrusadeEvent(self._requestNum - self._priviNum + 1)
    end

    local buyTime = math.max(self._requestNum - self._priviNum, 0)
    if buyTime >= sysVip.crusadeBoxTimes then
        if limitVipLevel >= vipInfo.level then
            self._viewMgr:showTip(lang("TIPS_CRUSADE_OPENBOX"))
        else
            self._viewMgr:showTip(lang("TIPS_CRUSADE_OPENBOX_MAX"))
        end
        return
    end
    if sysCrusadeEvent == nil then 
        self._viewMgr:showTip(lang("CRUSADE_TIPS_12"))
        return
    end
    local player = self._modelMgr:getModel("UserModel"):getData()
    local fCost = inNum > 1 and self._fCostNum or self._singleCostNum
    if player.gem < fCost then
        -- self._viewMgr:showTip(lang("CRUSADE_TIPS_13"))
        DialogUtils.showNeedCharge({
            desc = lang("TIP_GLOBAL_LACK_GEM"),
            callback1 = function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
        return
    end

    self._serverMgr:sendMsg("CrusadeServer", "buyCrusadeEventReward", {id = self._curCrusadeId, num = inNum}, true, {}, function (result)
        self:getCrusadeEventRewardFinish(result, inNum)
    end)
end

function CrusadeRewardNode:getCrusadeEventReward()
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadeEventReward", {id = self._curCrusadeId, token = self._token}, true, {}, function (result)
        self:getCrusadeEventRewardFinish(result, 1)
    end)
end

function CrusadeRewardNode:getCrusadeEventRewardFinish(result, inNum)
    self._viewMgr:lock(-1)
    if result["d"] == nil then 
        return 
    end

    audioMgr:playSound("pickup")
    self._fairyMc:setVisible(false)
    self._fairyMc:stop(false)
    self._fairyMc1:setVisible(true)
    self._fairyMc1:gotoAndPlay(1)
    self._mcCallback = function()
        self._viewMgr:unlock()
        if result["reward"] ~= nil then
            DialogUtils.showGiftGet( {
                gifts = result["reward"], 
                callback = nil,
                notPop = true
                })
        end
        -- 特权影响特殊处理
        self._requestNum = self._requestNum + inNum
        self:updateInfo()
        self._mcCallback = nil
    end
    self._playAnim = true
end

function CrusadeRewardNode:runAnim()
    self._viewMgr:lock(-1)
    --翅膀  0.4
    local swing1 = self:getUI("bg.swing1")
    local swing2 = self:getUI("bg.swing2")
    swing1:setVisible(false)
    swing1:setVisible(false)
    swing1:setAnchorPoint(cc.p(0, 0))
    swing1:setPosition(248.5, 0)
    local swingAc = cc.CallFunc:create(function()
        swing1:setVisible(true)
        swing1:setVisible(true)
        swing1:runAction(cc.Sequence:create(
            cc.RotateTo:create(0.1, 20), 
            cc.RotateTo:create(0.1, -10), 
            cc.RotateTo:create(0.2, 0)
            ))
        swing2:runAction(cc.Sequence:create(
            cc.RotateTo:create(0.1, -20), 
            cc.RotateTo:create(0.1, 10), 
            cc.RotateTo:create(0.2, 0)
            ))
        end)

    --标题 0.2
    local title = self:getUI("bg.Image_45")
    title:setVisible(false)
    local titleAc = cc.CallFunc:create(function()
        title:setVisible(true)
        title:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.01, 2.5),
            cc.ScaleTo:create(0.1, 0.9),
            cc.ScaleTo:create(0.1, 1)
            ))
        end)


    local function anim1(object, posX, posY)
        object:setVisible(true)
        object:runAction(cc.Spawn:create(
            cc.FadeIn:create(0.1),
            cc.MoveTo:create(0.1, cc.p(posX, posY))
            ))
    end

    --精灵 0.1
    local mcPosX, mcPosY = self._angleNode:getPositionX(), self._angleNode:getPositionY()
    self._angleNode:setPosition(mcPosX + 130, mcPosY)
    self._angleNode:setVisible(false)
    local mcAc = cc.CallFunc:create(function()
        anim1(self._angleNode, mcPosX, mcPosY)
        end)

    -- tip
    local tipImg = self:getUI("bg.Image_27")
    local tipPosX, tipPosY = tipImg:getPositionX(), tipImg:getPositionY()
    tipImg:setPosition(tipPosX - 130, tipPosY)
    tipImg:setVisible(false)
    local tipImgAc = cc.CallFunc:create(function()
        anim1(tipImg, tipPosX, tipPosY)
        end)

    --reward
    local itemBg = self:getUI("bg.itemBg")
    local rwdPosX, rwdPosY = itemBg:getPositionX(), itemBg:getPositionY()
    itemBg:setPosition(rwdPosX - 130, rwdPosY)
    itemBg:setVisible(false)
    local itemAc = cc.CallFunc:create(function()
        anim1(itemBg, rwdPosX, rwdPosY)
        end)

    local function anim2(object)
        object:setVisible(true)
        object:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.01, 0.9),
            cc.ScaleTo:create(0.1, 1.2),
            cc.ScaleTo:create(0.2, 1)
            ))
    end

    --按钮 0.3
    local cancelBtn = self:getUI("bg.cancelBtn")
    local enterBtn = self:getUI("bg.enterBtn")
    cancelBtn:setVisible(false)
    enterBtn:setVisible(false)
    local btnAc = cc.CallFunc:create(function()
        anim2(cancelBtn)
        anim2(enterBtn)
        end)

    --rewardNum
    self._rwdTip:setVisible(false)
    local rwdNumAc = cc.CallFunc:create(function()
        anim2(self._rwdTip)
        end) 

    self:runAction(cc.Sequence:create(
        swingAc, cc.DelayTime:create(0.3),
        titleAc, tipImgAc, itemAc, mcAc, cc.DelayTime:create(0.5),
        btnAc,rwdNumAc, cc.DelayTime:create(0.3),
        cc.CallFunc:create(function()
            self._viewMgr:unlock()
            end)))
end

return CrusadeRewardNode
