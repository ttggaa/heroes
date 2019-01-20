
--[[
    Filename:    SkillCardTakeView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-09-06 16:56:23
    Description: File description
--]]

local TimeUtils = TimeUtils
local TimeUtils_date = TimeUtils.date
local needItemId   = tab:Setting("SKILLBOOK_DRAW_TOOL").value
local oneGemPrice  = tab:Setting("SKILLBOOK_DRAW_COST1").value
local tenGemPrice  = tab:Setting("SKILLBOOK_DRAW_COST2").value
local MAX_SCREEN_WIDTH = MAX_SCREEN_WIDTH
local MAX_SCREEN_HEIGHT = MAX_SCREEN_HEIGHT
local moveY1 = -100

local function getMonthAndDay(time)
    local m = TimeUtils_date("%m",time)
    local d = TimeUtils_date("%d",time)
    return string.format("%s月%s日",m,d)
end

local SkillCardTakeView = class("SkillCardTakeView", BaseView)

function SkillCardTakeView:ctor()
    SkillCardTakeView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("skillCard.SkillCardTakeView")
        elseif eventType == "enter" then 
        end
    end)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._ItemModel = self._modelMgr:getModel("ItemModel")
    self._playerModel = self._modelMgr:getModel("PlayerTodayModel")
    self._SpellBooksModel  = self._modelMgr:getModel("SpellBooksModel")
    -- self._SpellBooksModel:cacheToolWithBookBase()
    self._selectUseItem = false --是否选择使用材料

end

function SkillCardTakeView:getRegisterNames()
    return{
        {"shopBtn","shopBtn"}, -- 商店按钮
        {"skillBtn","skillBtn"}, -- 法术按钮
        {"list","rightTopPanel.list"},
        {"checkBox","bottomPanel.checkBox"},
        {"oneGet","bottomPanel.oneGet"},
        {"tenGet","bottomPanel.tenGet"},
        {"oneGemCostPanel","bottomPanel.oneGemCostPanel"},
        {"oneItemCostPanel","bottomPanel.oneItemCostPanel"},
        {"tenItemCostPanel","bottomPanel.tenItemCostPanel"},
        {"tenGemCostPanel","bottomPanel.tenGemCostPanel"},
        {"timeDes1","rightTopPanel.timeDes1"},
        {"timeDes2","rightTopPanel.timeDes2"}, 
        {"oneFreePanel","bottomPanel.oneFreePanel"},
        {"animaNode","animaNode"},
        {"peopleImage","bg.peopleImage"},
        {"perpleBg","bg.perpleBg"},
        {"preLook","preLook"},
        {"firstTips","bottomPanel.firstTips"}, 
        {"counDes","bottomPanel.count"},
        {"firstGet","bottomPanel.firstGet"}, 
        {"icon","bottomPanel.icon"},
        {"tips","bottomPanel.tips"},

    }
end

function SkillCardTakeView:onInit()
    UIUtils:addFuncBtnName(self._shopBtn,"法术商店",nil,true )
    UIUtils:addFuncBtnName(self._skillBtn,"法术书柜",nil,true )
    self._peopleImage:loadTexture("asset/bg/skillCardTake_peple.png")
    self._perpleBg:loadTexture("asset/bg/skillCardTake_bottomBg.png")
    self._perpleBg:setOpacity(0)
    self._peopleImage:setOpacity(0)

    local panel = self:getUI("rightTopPanel")
    local logoImg = ccui.ImageView:create()
    logoImg:loadTexture("skillCard_bg.png",1)
    -- logoImg:setScaleY(0.5)
    panel:addChild(logoImg,-1)
    logoImg:setPosition(82,10)
    logoImg:setFlippedX(true)

    
    

    --描边
    self._oneItemCostPanel:getChildByFullName("count"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._oneGemCostPanel:getChildByFullName("count"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._tenItemCostPanel:getChildByFullName("count"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._tenGemCostPanel:getChildByFullName("count"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._oneFreePanel:getChildByFullName("count"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._timeDes1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._timeDes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._firstTips:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._tips:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._tips:setString(lang("SKILLBOOK_TIPS120"))

    local icon1 = self._oneItemCostPanel:getChildByFullName("icon")
    icon1:setScale(0.9)
    icon1:loadTexture("globalImageUI_keyin2.png",1)
    local icon2 = self._tenItemCostPanel:getChildByFullName("icon")
    icon2:setScale(0.9)
    icon2:loadTexture("globalImageUI_keyin2.png",1)

    local _,haveNum = self._ItemModel:getItemsById(needItemId)
    self._checkBox:setSelected(haveNum > 0)
    self._selectUseItem = haveNum > 0
    if haveNum == 0 then
        self._checkBox:setVisible(false)
    end

    self._checkBox:addEventListener(function (_, state)--state 0 选中，1取消
        print("touch check box...",state)
        self._selectUseItem = state == 0
        self:updateMiddleBottomView()
    end)

    self:registerClickEvent(self._oneGet,function()
        self:onOneGet()
    end)
    self:registerClickEvent(self._tenGet,function()
        self:tenGet()
    end)
    self:registerClickEvent(self._shopBtn,function()
        self:onShop()
    end)
    self:registerClickEvent(self._skillBtn,function()
        self:onSkillView()
    end)
    self:registerClickEvent(self._preLook,function()
        self:onPreLook()
    end)
    self:updateHotView()
    self:updateMiddleBottomView()
    ScheduleMgr:delayCall(0, self, function( ... )
        self._peopleImage:setPositionY(self._peopleImage:getPositionY()+moveY1)
        self._perpleBg:setPositionY(self._perpleBg:getPositionY()-moveY1)
        self:showAnimation(1)
    end)
    -- 

    self:listenReflash("VipModel",self.updateMiddleBottomView)
    self:listenReflash("UserModel",self.updateMiddleBottomView)  --add by wangyan

    self:registerTimer(5,0,5,function()
        self:updateHotView()
        self:updateMiddleBottomView()
    end)

    local discountTag = ccui.ImageView:create()
    discountTag:loadTexture("globalImageUI6_connerTag_r.png",1)
    -- discountTag:setName("discountTag")
    discountTag:setAnchorPoint(cc.p(1,1))
    discountTag:setScale(0.9)
    discountTag:setPosition(self._tenGet:getContentSize().width-10,self._tenGet:getContentSize().height)
    -- discountTag:setCascadeOpacityEnabled(true)
    -- discountTag:setOpacity(0)

    local discountName = ccui.Text:create()
    discountName:setString("超值")
    discountName:setFontSize(22)
    discountName:setFontName(UIUtils.ttfName)
    discountName:setColor(cc.c3b(255, 255, 255))
    discountName:enableOutline(cc.c4b(146,19,5,255),3)
    discountName:setRotation(41)
    discountName:setPosition(44,36)
    discountTag:addChild(discountName)
    discountTag:setScale(0.9)
    self._tenGet:addChild(discountTag,9)

    local haveDrawCount = self._SpellBooksModel:getDrawData().spbookNum
    self._firstGet:setVisible(false)
    if not haveDrawCount or haveDrawCount == 0 then
        self._firstGet:setVisible(true)
        local scale = 1
        local seq = cc.Sequence:create(cc.ScaleTo:create(2, scale+scale*0.1), cc.ScaleTo:create(2, scale))
        self._firstGet:runAction(cc.RepeatForever:create(seq))
    end
    self._icon:loadTexture("globalImageUI_keyin2.png",1)
    self:setEnterFlag()
end

function SkillCardTakeView:updateRedPoint()
    local red = self._SpellBooksModel:checkBookCaseRed()
    UIUtils.addRedPoint(self._skillBtn,red)
end

local effectName = {
    "wupinguang_itemeffectcollection",                -- 转光
    "wupinkuangxingxing_itemeffectcollection",        -- 星星
    "tongyongdibansaoguang_itemeffectcollection",     -- 扫光
    "diguang_itemeffectcollection",                   -- 底光
}

--[[
    刷新热点面板
]]
function SkillCardTakeView:updateHotView()
    local curServerTime = self._userModel:getCurServerTime()
    local serverWeek = self._userModel:getData().week
    local beginTime,endTime = TimeUtils.getWeekBeginAndEnd(curServerTime)
    local hour = tonumber(TimeUtils_date("%H",curServerTime))
    if hour < 5 then
        curServerTime = curServerTime - 86400
    end
    local year = TimeUtils_date("%Y",curServerTime)
    local dmonth = TimeUtils_date("%W",curServerTime)
    local id = serverWeek or tonumber(string.format("%02d%02d",tonumber(year),tonumber(dmonth)))
    local hotData1 = tab:ScrollHotSpot(tonumber(id))
    local scrollShow1 = hotData1.scrollShow

    --[[
    local hotDataBefore = tab:ScrollHotSpot(id-1)
    local scrollShow2 = hotDataBefore and hotDataBefore.scrollShow or -10
    

    if scrollShow1 == scrollShow2 then --当前周跟上一周，是同一热点周
        beginTime = beginTime - 604800
        hotDataBefore = tab:ScrollHotSpot(id+1)
        local id = hotDataBefore and hotDataBefore.scrollTemplate or 1
        self._nextActiveID = id
    else
        endTime = endTime + 604800
        hotDataBefore = tab:ScrollHotSpot(id+2)
        local id = hotDataBefore and hotDataBefore.scrollTemplate or 1
        self._nextActiveID = id
    end
    ]]

    local hotDataBefore = tab:ScrollHotSpot(id+1)
    local id = hotDataBefore and hotDataBefore.scrollTemplate or 1
    self._nextActiveID = id


    local giftId = hotData1 and hotData1.scrollTemplate or 1
    local conditionDay = 3
    self._isHideTab = true
    if curServerTime + conditionDay * 86400 >= endTime then
        self._isHideTab = false
    end


    self._preParam = {
        ["id"] = giftId,
        ["nextId"] = self._nextActiveID,
        ["hide"] = self._isHideTab
    }
    local giftData = tab:ScrollTemplate(giftId).art
    dump(giftData,"giftData",10)
    local giftNum = table.nums(giftData)
    local widthCell = 65
    self._list:removeAllChildren()
    self._list:setClippingEnabled(true)
    self._list:setInnerContainerSize(cc.size(widthCell*giftNum,self._list:getContentSize().height))

    local tabData = tab.tool
    for i=1,giftNum do
        local data = giftData[i]
        local icon = IconUtils:createItemIconById({itemId = data[2], itemData = tabData[data[2]],eventStyle = 1, showSpecailSkillBookTip = true})
        local effect = effectName[tonumber(data[3])] or effectName[1]
        local zOrder = 10
        local scale = 0.9
        local point = cc.p(-2, -5)
        if effect == "diguang_itemeffectcollection" then
            zOrder = -2
            scale = 0.6
            point = cc.p(10,12)
        end
        local bgMc = IconUtils:addEffectByName({effect})
        bgMc:setName("bgMc")
        bgMc:setPosition(point)
        icon:addChild(bgMc,zOrder)
        icon:setScale(0.6)
        bgMc:setScale(scale)
        self._list:addChild(icon)
        icon:setPosition((i-1)*widthCell+widthCell*0.1,2)
    end

    self._timeDes1:setString("持续时间:")
    --持续时间
    local des = ""
    des = getMonthAndDay(beginTime) .. "05:00~"
    des = des .. getMonthAndDay(endTime) .. "05:00"
    print("des",des)
    self._timeDes2:setString(des)

    self:preRedPoint()
end

function SkillCardTakeView:preRedPoint()
    local red = false
    local diffNextID = self._SpellBooksModel:isNewGift(self._nextActiveID)
    if not self._isHideTab and diffNextID then
        red = true
    end
    UIUtils.addRedPoint(self._preLook,red,cc.p(54,54))
end

-- 当前是否有免费次数
function SkillCardTakeView:isFreeTime()
    local getTimes = self._playerModel:getData().day68 or 0
    return getTimes <= 0 
end


function SkillCardTakeView:onAdd()
    
end

--[[
    中间底部面板
]]
function SkillCardTakeView:updateMiddleBottomView()
    local _,haveNum = self._ItemModel:getItemsById(needItemId)
    local isUserLuck = self._userModel:drawUseLuckyCoin()
    local userGemCount = self._userModel:getData().gem
    if isUserLuck then
        userGemCount = self._userModel:getData().luckyCoin
    end

    -- 单次是否免费
    local isFree = self:isFreeTime()
    --单次抽是否使用道具
    local isItemShow = not isFree and haveNum > 0 and self._selectUseItem
    --十次抽是否使用道具    
    local isTenItemShow = haveNum >= 10 and self._selectUseItem

    

    self._oneFreePanel:setVisible(isFree)
    self._oneItemCostPanel:setVisible(isItemShow and not isFree)
    self._oneGemCostPanel:setVisible(not isItemShow and not isFree)
    self._tenItemCostPanel:setVisible(isTenItemShow)
    self._tenGemCostPanel:setVisible(not isTenItemShow)

    if isFree then
        local freeDes = self._oneFreePanel:getChildByFullName("count")
        freeDes:setString("本次免费")
    end

    if isItemShow then
        local oneItemCostLabel = self._oneItemCostPanel:getChildByFullName("count")
        local costDes = haveNum .. "/" .. 1
        oneItemCostLabel:setString(costDes)
    else
        local oneCostLabel = self._oneGemCostPanel:getChildByFullName("count")
        oneCostLabel:setString(oneGemPrice)
        if userGemCount >= oneGemPrice then
            oneCostLabel:setColor(cc.c4b(255,255,255,255))
        else
            oneCostLabel:setColor(cc.c4b(205,32,30,255))
        end
        local icon = self._oneGemCostPanel:getChildByFullName("icon")
        if isUserLuck then
            icon:loadTexture(IconUtils.resImgMap.luckyCoin,1)
        else
            icon:loadTexture(IconUtils.resImgMap.gem,1)
        end
    end

    if isTenItemShow then
        local costDes = haveNum .. "/" .. 10
        local tenItemCostLable = self._tenItemCostPanel:getChildByFullName("count")
        tenItemCostLable:setString(costDes)
    else
        local tenCostLabel = self._tenGemCostPanel:getChildByFullName("count")
        tenCostLabel:setString(tenGemPrice)
        if userGemCount >= tenGemPrice then
            tenCostLabel:setColor(cc.c4b(255,255,255,255))
        else
            tenCostLabel:setColor(cc.c4b(205,32,30,255))
        end
        local icon = self._tenGemCostPanel:getChildByFullName("icon")
        if isUserLuck then
            icon:loadTexture(IconUtils.resImgMap.luckyCoin,1)
        else
            icon:loadTexture(IconUtils.resImgMap.gem,1)
        end
    end

    --如果道具个数为0，需隐藏
    if haveNum == 0 then
        self._checkBox:setVisible(false)
        self._icon:setVisible(false)
        self._firstTips:setVisible(false)
    else
        self._checkBox:setVisible(true)
        self._icon:setVisible(true)
        self._firstTips:setVisible(true)
    end

    --祈愿次数 counDes
    local haveDrawCount = self._SpellBooksModel:getDrawData().spbookNum or 0
    if haveDrawCount > 0 then
        self._firstGet:setVisible(false)
    end
    haveDrawCount = haveDrawCount % 10
    print("haveDrawCount",haveDrawCount)
    self._counDes:setString(10-haveDrawCount)

    self._isTenItemShow = isTenItemShow
    self._isItemShow = isItemShow
    self._oneGemPrice = oneGemPrice
    self._tenGemPrice = tenGemPrice
    self._isFree = isFree

    self:updateRedPoint()
end

--单次抽
--hero.drawSpeelBook type 0免费抽取1道具抽取2钻石抽取
function SkillCardTakeView:onOneGet()
    if not self._isItemShow and not self._isFree then
        local isUserLuck = self._userModel:drawUseLuckyCoin()
        if isUserLuck then
            local userGemCount = self._userModel:getData().luckyCoin
            if userGemCount < self._oneGemPrice then
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
                    DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needNum,callback = function()
                        self:updateMiddleBottomView()
                    end })
                end})
                return
            end
        else
            local userGemCount = self._userModel:getData().gem
            if userGemCount < self._oneGemPrice then
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function()
                    if not self._viewMgr then 
                        self._viewMgr = ViewManager:getInstance()
                    end
                    self._viewMgr:showView("vip.VipView", {viewType = 0})
                end})
                return
            end
        end
    end

    self._buyNum = 1
    local isUserItem = self._isFree and 0 or self._isItemShow and 1 or 2
    local param = {num =1, type = isUserItem}
    self._serverMgr:sendMsg("HeroServer", "drawSpeelBook", param, true, {}, function(result)
        if not result then
            self._playerModel:updateDayInfo({day68 = 1})
            self:updateMiddleBottomView()
            return 
        end
        audioMgr:playSound("drawScroll")
        self:showAnimation(2,function()
            self:showResult(result)
            self:updateMiddleBottomView()
        end)
    end,function(errorId)
        print("errorId",errorId)
    end)

    -- self._buyNum = 1
 --    self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 2, num = 1}, true, {}, function(result)
 --     if result then
 --         self:lock(-1)
    --         ScheduleMgr:delayCall(2000, self, function( )
    --             if self.unlock then 
    --                 self:unlock()
    --             end     
    --             self:showResult(result)
    --         end)
 --     end
 --    end,
 --    function( )
 --        if self.unlock then 
 --            self:unlock()
 --        end
 --    end)
end


--[[
    动画播放 1 初始进入，2抽卡过程 3 关闭抽卡
]]
function SkillCardTakeView:showAnimation(type_,callBack)
    
    local mcCallback
    local fixY = (MAX_SCREEN_HEIGHT-640)*0.5
    if type_ == 1 then
        self:lock(-1)
        self._perpleBg:runAction(
            cc.Spawn:create(
                cc.EaseOut:create(cc.MoveBy:create(0.4,cc.p(0,moveY1-fixY)),3),
                cc.FadeIn:create(0.4)
            )
        )
        self._peopleImage:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.EaseOut:create(cc.MoveBy:create(0.4,cc.p(0,-moveY1-fixY)),3),
                cc.FadeIn:create(0.4)
            ),
            cc.CallFunc:create(function()
                if not self._mc1 then
                    self._mc1 = mcMgr:createViewMC("fashujitan_fashujitan", false, false)
                    self._mc1:retain()
                    self._mc1:setPosition(0,50)
                    self._animaNode:addChild(self._mc1,1)
                    local seq = cc.Sequence:create(cc.MoveTo:create(1, cc.p(0,54)), cc.MoveTo:create(1, cc.p(0,50)))
                    self._mc1:runAction(cc.RepeatForever:create(seq))
                end
                mcCallback = self._mc1:addCallbackAtFrame(25, function()
                    self._mc1:removeCallback(mcCallback)
                    self._mc1:stop()
                    if callBack then callBack() end
                    self:unlock()
                end)
            end)
        ))
    elseif type_ == 2 then
        self._mc1:stopAllActions()
        mcCallback = self._mc1:addCallbackAtFrame(85, function()
            self._mc1:removeCallback(mcCallback)
            -- self._mc1:stop()
            self._mc1:gotoAndStop(95)
            if callBack then callBack() end
            self:unlock()
        end)
        self._mc1:play()
        self:lock(-1)
    elseif type_ == 3 then
        mcCallback = self._mc1:addCallbackAtFrame(105, function()
            self._mc1:removeCallback(mcCallback)
            self._mc1:gotoAndStop(25)
            if callBack then callBack() end
            self:unlock()
            local seq = cc.Sequence:create(cc.MoveTo:create(1, cc.p(0,54)), cc.MoveTo:create(1, cc.p(0,50)))
            self._mc1:runAction(cc.RepeatForever:create(seq))
        end)
        self._mc1:play()
        self:lock(-1)
    end
end

--十连抽
function SkillCardTakeView:tenGet()
    if not self._isTenItemShow then
        print("aaaa")
        local isUserLuck = self._userModel:drawUseLuckyCoin()
        if isUserLuck then
            local userGemCount = self._userModel:getData().luckyCoin
            if userGemCount < self._tenGemPrice then
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
                    DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = self._tenGemPrice - userGemCount,callback = function()
                        self:updateMiddleBottomView()
                    end })
                end})
                return
            end
        else
            local userGemCount = self._userModel:getData().gem
            if userGemCount < self._tenGemPrice then
                print("aaaacc")
                DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function()
                    if not self._viewMgr then 
                        self._viewMgr = ViewManager:getInstance()
                    end
                    self._viewMgr:showView("vip.VipView", {viewType = 0})
                end})
                return
            end
        end
    end
    print("aaaabb")
    self._buyNum = 10
    local isUserItem = self._isTenItemShow and 1 or 2
    local param = {num =10, type = isUserItem}
    self._serverMgr:sendMsg("HeroServer", "drawSpeelBook", param, true, {}, function(result)
        if not result then
            self._playerModel:updateDayInfo({day68 = 1})
            self:updateMiddleBottomView()
            return 
        end
        audioMgr:playSound("drawScroll")
        self:showAnimation(2,function()
            self:showResult(result)
            self:updateMiddleBottomView()
        end)
    end,function(errorId)
        print("errorId",errorId)
    end)
    
end

function SkillCardTakeView:showResult(result)
    self._viewMgr:showDialog("skillCard.SkillCardResultView",{awards = (result.rewards or {}),
    isFirstUserItem = self._selectUseItem,buyNum = self._buyNum,
    callback = function()
        self:showAnimation(3,function ()
            self:updateMiddleBottomView()
        end)
    end},true)
end

--商店
function SkillCardTakeView:onShop()
    print("商店")
    self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "skillbook"}, true, {}, function(result)
        dump(result,"SkillCardTakeView",10)
        self._viewMgr:showDialog("skillCard.SkillCardShopView",{},true)
    end)
end

--法术书柜 onSkillView
function SkillCardTakeView:onSkillView()
    print("书柜")
    self._viewMgr:showView("spellbook.SpellBookCaseView",{},true)
end

function SkillCardTakeView:onShow()
    print("SkillCardTakeView:onShow")
    self:updateRedPoint()
    self:updateRealVisible(true)
end

--预览
function SkillCardTakeView:onPreLook()
    print("预览")
    self._preParam.callback = function()
        self:preRedPoint()
    end
    self._viewMgr:showDialog("skillCard.SkillCardPreView",self._preParam,true)
end

function SkillCardTakeView:getAsyncRes()
    return {
    {"asset/ui/skillCard.plist","asset/ui/skillCard.png"}
}
end
function SkillCardTakeView:setNavigation()
    local isUserLuck = self._userModel:drawUseLuckyCoin()
    if isUserLuck then
        self._viewMgr:showNavigation("global.UserInfoView",{types = {"Gem", "LuckyCoin", needItemId},titleTxt = "法术祈愿"})
    else
        self._viewMgr:showNavigation("global.UserInfoView",{types = {"Gold", "Gem", needItemId},titleTxt = "法术祈愿"})
    end
end


-- 每次打开UI标记
function SkillCardTakeView:setEnterFlag()
    local curServerTime = self._userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("SKILLCARDTAKE_IS_SHOWED_ITEM")
    if tempdate ~= timeDate then
        SystemUtils.saveAccountLocalData("SKILLCARDTAKE_IS_SHOWED_ITEM", timeDate)
    end
end

function SkillCardTakeView:getBgName()
    return "skillCardTake.jpg"
end

function SkillCardTakeView:onDestroy()
    SkillCardTakeView.super.onDestroy(self)
    if self._mc1 then
        self._mc1:release()
    end
end

function SkillCardTakeView:onTop()
    self:updateRedPoint()
end

function SkillCardTakeView:dtor()
    TimeUtils = nil
    TimeUtils_date = nil
    needItemId = nil
    oneGemPrice = nil
    tenGemPrice = nil
    MAX_SCREEN_WIDTH = nil
    MAX_SCREEN_HEIGHT = nil
    moveY1 = nil
end


return SkillCardTakeView