--[[
    FileName:       GloryArenaView
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-10 10:15:38
    Description:
]]

local GloryArenaView = class("GloryArenaView",BaseView)

function GloryArenaView:ctor()
    GloryArenaView.super.ctor(self)
    self.initAnimType = 1
end

-- 是否多线程载入资源
-- function GloryArenaView:isAsyncRes()
--     return true
-- end

--获取打开UI的时候加载的资源
function GloryArenaView:getAsyncRes()
    return 
         {
            {"asset/ui/arena.plist", "asset/ui/arena.png"},
            {"asset/ui/arena1.plist", "asset/ui/arena1.png"},
         }
end

--创建csb的时候，返回的是背景图片状态
-- return nil, --name string xx.jpg
-- nil, --color cc.c3b
-- nil, --Brightness亮度 -100  100 
-- nil, --Contrast对比度 -100  100
-- nil, --Saturation饱和度 -100  100
-- nil  --Hue色相 -180 180
function GloryArenaView:getBgName()
     return "gloryArenaViewBg.jpg"
end

--{"name","targetName"}
--注册节点使用，注册的对象存放在self["_"..name]
function GloryArenaView:getRegisterNames()
--     return {
--         {"leftBar","bg.leftBar"},
-- }
end

-- local tipBg = {"gloryArenaView_left_bg1.png"}
-- local tipBg1 = {"GloryArenaView_newtype1.png"}

local childName = {
    --按钮
    {name = "rewardBtn", childName = "bg.layer.btnBg_ground.detailBtn", isBtn = true, tileName = "奖励"},
    {name = "shopBtn", childName = "bg.layer.btnBg_ground.shopBtn", isBtn = true, tileName = "商店"},
    {name = "rankBtn", childName = "bg.layer.btnBg_ground.rankBtn", isBtn = true, tileName = "排行"},
    {name = "reportBtn", childName = "bg.layer.btnBg_ground.reportBtn", isBtn = true, tileName = "战报"},
    {name = "formationBtn", childName = "bg.layer.btnBg_ground.formationBtn", isBtn = true, tileName = "防守"},
    {name = "ruleBtn", childName = "bg.layer.btnBg_ground.ruleBtn", isBtn = true, tileName = "规则"},
    {name = "changeBtn", childName = "bg.rightBottom.changeBtn", isBtn = true},
    --排名奖励
    {name = "goldNum", childName = "bg.bottom.goldNum", isText = true},
    {name = "goldImg", childName = "bg.bottom.goldImg"},
    {name = "diamondNum", childName = "bg.bottom.diamondNum", isText = true},
    {name = "diamondImg", childName = "bg.bottom.diamondImg"},
    {name = "currencyNum", childName = "bg.bottom.currencyNum", isText = true},
    {name = "currencyImg", childName = "bg.bottom.currencyImg"},
    {name = "settleLab", childName = "bg.bottom.settleLab", isText = true},

    --挑战次数
    {name = "challengeBg", childName = "bg.rightBottom.challengeBg"},
    {name = "chanceNum", childName = "bg.rightBottom.challengeBg.chanceNum", isText = true},
    {name = "chanceTotal", childName = "bg.rightBottom.challengeBg.chanceTotal"},
    {name = "addChangeBtn", childName = "bg.rightBottom.challengeBg.addChangeBtn", isBtn = true},
    
    --冷却时间
    {name = "cdBg", childName = "bg.rightBottom.cdBg"},
    {name = "cdTime", childName = "bg.rightBottom.cdBg.cdTime", isText = true},
    {name = "cdDiamondImg", childName = "bg.rightBottom.cdBg.diamondImg"},
    {name = "cdDiamondNum", childName = "bg.rightBottom.cdBg.diamondNum", isText = true},

    {name = "itemModel", childName = "bg.layer.itemModel"},
    {name = "sloganBg", childName = "bg.layer.sloganBg"},
    {name = "layer", childName = "bg.layer"},
    {name = "bg", childName = "bg"},
    {name = "scrollViewBg_lay", childName = "bg.scrollViewBg_lay"},
    {name = "scrollView", childName = "bg.scrollViewBg_lay.scrollView"},

    {name = "describeBg_img", childName = "bg.layer.describeBg_img"},
    {name = "startTime_text", childName = "bg.layer.describeBg_img.startTime_text"},
    {name = "type_img", childName = "bg.layer.describeBg_img.type_img"},
}


function GloryArenaView:onRewardCallback(_, _x, _y, sender)
    if sender == nil or not self._bIsBtn then
        return
    end
    if not self:lCheckGoBeyond() then
        return
    end
    if sender:getName() == "detailBtn" then
        --奖励
--        self._gloryArenaModel._errorStatus = 1
        self._viewMgr:showDialog("gloryArena.GloryArenaAwardDialog")
    elseif sender:getName() == "shopBtn" then
        --商店
--        SystemUtils.saveAccountLocalData("GLORY_ARENA_BUY_RED_TIME", 0)
        self._viewMgr:showView("shop.ShopView", {idx = 11})
--        if self._imageTest == nil then
--            self._imageTest = ccui.ImageView:create()
--            self._imageTest:loadTexture("asset/uiother/dhero/d_Gelu.jpg", ccui.TextureResType.localType)
--            self:addChild(self._imageTest, 100)
--            self._imageTest:setPosition(cc.p(MAX_SCREEN_WIDTH / 2, MAX_SCREEN_HEIGHT / 2))
--        end

--        local action = CCOrbitCamera:create(0.5, 1, 0, 0, -720, 0, 0)
--        self._imageTest:runAction(action)
    elseif sender:getName() == "rankBtn" then
        --排行
        self._serverMgr:sendMsg("CrossArenaServer", "getRank", {}, true, {}, function(result) 
            self._viewMgr:showDialog("gloryArena.GloryArenaRankDialog")
        end)
    elseif sender:getName() == "reportBtn" then
        --战报
        self._serverMgr:sendMsg("CrossArenaServer","getReportList",{time = 0},true,{},function( result )
--            dump(result)
            self._viewMgr:showDialog("gloryArena.GloryArenaReportDialog")
        end)
    elseif sender:getName() == "formationBtn" then
        --防守
--         防守编组
        local function __callback()
            local hideArray = self._gloryArenaModel:lGetHideArray()
            local formationModel = self._modelMgr:getModel("FormationModel")
            local rewardData = self._gloryArenaModel:lGetRankReward()
            local hideCount = 0
            if rewardData then
                hideCount = rewardData.hideTimeNum or 0
            end
            self._viewMgr:showView("formation.NewFormationView", {
                formationType = formationModel.kFormationTypeGloryArenaDef1,
                extend = {
                    showState = {
                        [formationModel.kFormationTypeGloryArenaDef1] = not (hideArray[formationModel.kFormationTypeGloryArenaDef1] or false),
                        [formationModel.kFormationTypeGloryArenaDef2] = not (hideArray[formationModel.kFormationTypeGloryArenaDef2] or false),
                        [formationModel.kFormationTypeGloryArenaDef3] = not (hideArray[formationModel.kFormationTypeGloryArenaDef3] or false),
                    },
                    gloryArenaLimit = hideCount,
                },
                closeCallback = function ()
                    print("*************close***************")
                end})
        end
        self._gloryArenaModel:lCheckDefenseArray(__callback)
--        self._viewMgr:showDialog("gloryArena.GloryArenaDuelDialog", __testData)
    elseif sender:getName() == "ruleBtn" then
        --规则
        self._viewMgr:showDialog("gloryArena.GloryArenaRuleDialog")
    elseif sender:getName() == "changeBtn" then
        --换一批
        if self._bIsCanRefresh then
            self._bIsCanRefresh = false
            self._serverMgr:sendMsg("CrossArenaServer","reflashArena", {}, true, {}, function(result) 
--                dump(result)
                self:initScrollView()
--                self:setReward()
            end)
        else
            self._viewMgr:showTip(lang("TIPS_ARENA_09") or "刷新太频繁！")
        end
    elseif sender:getName() == "addChangeBtn" then
        --购买次数
        self:sendBuyChallengeNumMsg(nil, 1)
    end

end

--初始化逻辑,这个时候只是把资源，背景，csb等创建好了
function GloryArenaView:onInit()
    self:lInitData()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    if self._childNodeTable == nil then
        return
    end
    self.updateisOpen = true
    --控制按钮的点击
    self._bIsBtn = false
--    self:disableTextEffect()
    self:setAttackCount(false)
    self:setInitAttackCoolingCD(false)
    self._childNodeTable.scrollViewBg_lay:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self._childNodeTable.layer:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self._childNodeTable.layer:setLocalZOrder(4)
    self._childNodeTable.sloganBg:setVisible(false)
    self:onAddListenModel()
    local bisCross = self._gloryArenaModel:bIsCross()
    local strTime = self._gloryArenaModel:lGetShowTiem() or ""
    local Season = self._gloryArenaModel:lGetSeason()
    -- self._childNodeTable.type_text:setString("本期玩法：" .. (bisCross and "跨服战" or "本服战"))
--    self._childNodeTable.type_img:loadTexture(bisCross and "GloryArenaView_type1.png" or "GloryArenaView_type2.png", ccui.TextureResType.plistType)
    self._childNodeTable.describeBg_img:ignoreContentAdaptWithSize(false)
    local resData = tab:HonorArenaResource(tonumber(Season))
	if resData then
        self._childNodeTable.describeBg_img:loadTexture((resData.Resource3 or "gloryArenaView_left_bg1") .. ".png", ccui.TextureResType.plistType)
        self._childNodeTable.type_img:loadTexture((resData.Resource4 or "GloryArenaView_newtype1") .. ".png", ccui.TextureResType.plistType)
    end

    self._childNodeTable.describeBg_img:setTouchEnabled(true)
    self._childNodeTable.describeBg_img:addTouchEventListener(function(sender, _type)
        if _type == ccui.TouchEventType.ended and self._bIsBtn then
            self._viewMgr:showDialog("gloryArena.GloryArenaShowImageDialog")
        end
    end)

    self._childNodeTable.startTime_text:setString(strTime or "")
--    local testImage = ccui.ImageView:create("asset/uiother/dhero/d_Astral_01.jpg", ccui.TextureResType.localType)
--    testImage:setPosition(cc.p(MAX_SCREEN_WIDTH / 2, MAX_SCREEN_HEIGHT / 2))
--    testImage:setSkewX(10)
--    self:addChild(testImage, 100)
end

function GloryArenaView:lInitData()
    self._childNodeTable = {}
    self._bIsCanRefresh = true
end

function GloryArenaView:onAddListenModel()
    self._gloryArenaModel = self._modelMgr:getModel("GloryArenaModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    
    self:listenReflash("GloryArenaModel", self.reflashUI)

--    self:registerTimer(19, 49, 0, specialize(self.__test, self))

--    self._gloryArenaModel:setData(testData)
--    self:reflashUI()
end

--function GloryArenaView:__test()
--    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
--end

--滑动停止之后计算位置
function GloryArenaView:calculationPro(sender, nDis)
    local beganPos = sender:getTouchBeganPosition()
    local endPos = sender:getTouchEndPosition()
    local innerContainer = self._childNodeTable.scrollView:getInnerContainer()
    if innerContainer then
        local _position = cc.p(innerContainer:getPosition())
        local rema = 0
        --根据滑动的方向，计算向上和向下取整
        if math.abs(beganPos.x - endPos.x) >= 5 then
            if beganPos.x - endPos.x >= 0 then
                rema = math.floor(_position.x / self._itemSizeWidth)
            else
                rema = math.ceil(_position.x / self._itemSizeWidth)
            end
            if nDis then
                rema = -1 * nDis
            end
            local pro = rema * self._itemSizeWidth / (self._innerSizeWidth - self._scrollSizeWidth) * 100
            if math.abs(pro) < 0 then
                pro = 0
            elseif math.abs(pro) > 100 then
                pro = -100
            end
            self._childNodeTable.scrollView:scrollToPercentHorizontal(math.abs(pro), 0.15, true)
        end
    end
    self:calcArrow()
end

--滑动过程和创建的时候计算大小和位置
function GloryArenaView:calculationScalePos(var)
    if var ~= nil then
        local _position = cc.p(var:convertToWorldSpace(cc.p(0, 0)))
--        _position.x = _position.x + self._offsetX
        if _position.x >= -100 and _position.x <= MAX_SCREEN_WIDTH + 100 then
            local _x = math.floor(math.abs(MAX_SCREEN_WIDTH / 2 - (_position.x + self._itemSizeWidth / 2)) * 0.1) * 0.01
            local scale = 0.7 - math.floor(_x / 3 * 100) * 0.01
            var:setPositionY((1.0 - scale) * 400)
            var:setScale(scale)
            var:setVisible(true)
            return true
        else
            --提高scrollView的效率
            local _x = math.floor(math.abs(MAX_SCREEN_WIDTH / 2 - (_position.x + self._itemSizeWidth / 2)) * 0.1) * 0.01
            local scale = 0.7 - math.floor(_x / 3 * 100) * 0.01
            var:setPositionY((1.0 - scale) * 400)
            var:setScale(scale)
            var:setVisible(true)
            return false
        end
    end
    return false
end

function GloryArenaView:updateItemS()
    
--    self._rankData = self._gloryArenaModel:lGetMainRankData()
    local maxCount = math.max(#self._rankData - 1, #self._imageTable)

    self:updateCellData(self._childNodeTable.itemModel, self._rankData[1], 1, true,true)

    for i = maxCount, 1, -1 do
        local _data = self._rankData[i + 1]
        local _itemNode = self._imageTable[i]
        if _data and _itemNode then
             self:updateCellData(_itemNode, _data, i, true, true)
        elseif _data and not _itemNode then
            _itemNode = self:lGetItem(i)
            self._imageTable[#self._imageTable + 1] = _itemNode
            self:updateCellData(_itemNode, _data, i, true, true)
        elseif not _data and _itemNode then
            self._childNodeTable.scrollView:removeChild(_itemNode)
            table.remove(self._imageTable, i)
        end
    end
end

function GloryArenaView:lGetItem(pos)
    local item = self._childNodeTable.itemModel:clone()
    item:setName("item" .. pos)
    item:setTouchEnabled(false)
    item:setPosition(cc.p((pos - 1) * self._itemSizeWidth + self._itemSizeWidth / 2, 0))
    self._childNodeTable.scrollView:addChild(item)
    return item
end

--计算小箭头的显示
function GloryArenaView:calcArrow()
    local innerContainer = self._childNodeTable.scrollView:getInnerContainer()
    if innerContainer then
        local _position = cc.p(innerContainer:getPosition())
--        print("======================", _position.x, self._innerSizeWidth - self._scrollSizeWidth)
        if math.abs(_position.x) <= 10 then
            self._leftArrow:setVisible(false)
            self._rightArrow:setVisible(true)
        elseif math.abs(_position.x) >= (self._innerSizeWidth - 10 - self._scrollSizeWidth) then
            self._leftArrow:setVisible(true)
            self._rightArrow:setVisible(false)
        else
            self._leftArrow:setVisible(true)
            self._rightArrow:setVisible(true)
        end
        
    end
    
end


function GloryArenaView:setStartPos()
    local InnerContainerLayout = self._childNodeTable.scrollView:getInnerContainer()
    local posIndex = 0
    if InnerContainerLayout then
--    InnerContainerLayout:setPositionX((self._innerSizeWidth - self._scrollSizeWidth) * -1)
        for i = 1, self._itensCount do
            local itemData = self._rankData[i + 1]
            if itemData then
                if itemData.rid == self._userModel:getUID() then
                    posIndex = i
                end
            end
        end
        posIndex = posIndex - 3
        if posIndex < 0 then
            posIndex = 0
        end
        local posIndexX = self._itemSizeWidth * posIndex
        if posIndexX > (self._innerSizeWidth - self._scrollSizeWidth) then
            posIndexX = self._innerSizeWidth - self._scrollSizeWidth
        end
        InnerContainerLayout:setPositionX(posIndexX * -1)
    end
end

function GloryArenaView:initScrollView()
        
    self._rankData = self._gloryArenaModel:lGetMainRankData()
    self._nSelfRank = self._gloryArenaModel:lGetSelfRank() or 0

    self._itensCount = #self._rankData - 1
    self._itemSizeWidth = math.floor(MAX_SCREEN_WIDTH / 6)
    self._scrollSizeWidth = self._itemSizeWidth * 6
    self._innerSizeWidth = self._itemSizeWidth * self._itensCount
    self._offsetX = (MAX_SCREEN_WIDTH - self._scrollSizeWidth) / 2
    local scrollSizeHeight = 300
    

    -- print("===================", self._childNodeTable.scrollView:getPositionX())
    if self._imageTable ~= nil then
        local isPos = false
        if #self._rankData - 1 ~= #self._imageTable then
            isPos = true
            --这个时候由于item的数量改变，随之滚动层的大小和位置都需要改变，这里最后统一写函数控制(临时处理)
            -- self:calculationPro(self._childNodeTable.scrollView, 0)
            self._childNodeTable.scrollView:setContentSize(cc.size(self._scrollSizeWidth, scrollSizeHeight))
            self._childNodeTable.scrollView:setInnerContainerSize(cc.size(self._innerSizeWidth, scrollSizeHeight))
            self:setStartPos()
        end
        self:updateItemS()
        if isPos then
            for i,v in ipairs(self._imageTable) do
                if v then
                    self:calculationScalePos(v)
                end
            end
        end
        return
    end

    

    self._childNodeTable.scrollView:setPositionX(self._offsetX)
    self._childNodeTable.scrollView:setContentSize(cc.size(self._scrollSizeWidth, scrollSizeHeight))
    self._childNodeTable.scrollView:setInnerContainerSize(cc.size(self._innerSizeWidth, scrollSizeHeight))
    
    self._childNodeTable.scrollViewBg_lay:setLocalZOrder(10)
    self._childNodeTable.scrollView:setTouchEnabled(true)
    self._childNodeTable.scrollView:setClippingEnabled(true)
    self._childNodeTable.scrollView:setBounceEnabled(false)
--    self._childNodeTable.scrollView:setInertiaScrollEnabled(true)
    self._childNodeTable.scrollView:removeAllChildren(true)
    self._imageTable = {}
--    self._imageTable[1] = self._childNodeTable.itemModel
    --更具自己的排名设置初始位置
--    self._nSelfRank = 15

    self:setStartPos()

    self:updateCellData(self._childNodeTable.itemModel, self._rankData[1], 1, nil, true)

    local selfPos = 0
    for i = 1, self._itensCount do
        local itemData = self._rankData[i + 1]
        local item  = self:lGetItem(i)
        self._imageTable[#self._imageTable + 1] = item
        local bIsCreateSp = self:calculationScalePos(item)
        self:updateCellData(item, itemData, i, nil, bIsCreateSp)
        if self._nSelfRank == itemData.rank then
            selfPos = i - 3
        end
    end
    self._childNodeTable.itemModel:setLocalZOrder(1)
 
    
    self._childNodeTable.scrollView:setInertiaScrollEnabled(false)
    local worldPos = cc.p(self._childNodeTable.scrollView:convertToWorldSpace(cc.p(0, 0)))
    local scrollrect = cc.rect(worldPos.x, worldPos.y, self._scrollSizeWidth, scrollSizeHeight)

    --创建一个layout监听滑动停止
    local _layout = ccui.Layout:create()
    _layout:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
--    _layout:setBackGroundColorType(1)
--    _layout:setBackGroundColor(cc.c3b(100, 100, 100))
--    _layout:setBackGroundColorOpacity(100)
    _layout:setTouchEnabled(true)
    _layout:setSwallowTouches(false)

    self._rightArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._rightArrow:setPosition(MAX_SCREEN_WIDTH-50,250)
    _layout:addChild(self._rightArrow, 99)

    self._leftArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._leftArrow:setPosition(50,250)
    _layout:addChild(self._leftArrow, 99)

    self._leftArrow:setVisible(false)
    self._rightArrow:setVisible(false)

    self:addChild(_layout, 3)
    local bisTouch = false
    _layout:addTouchEventListener(function(sender, _type)
        if _type == ccui.TouchEventType.ended or _type == ccui.TouchEventType.canceled then
            if bisTouch then
                bisTouch = false
                self:calculationPro(sender)
            end
        elseif _type == ccui.TouchEventType.began then
            local beginPos = sender:getTouchBeganPosition()
            if cc.rectContainsPoint(scrollrect, beginPos) then
                bisTouch = true
            end
        end
    end)

    self._childNodeTable.scrollView:addEventListener(function(sender, EventType)
        for key, var in ipairs(self._imageTable) do
            if var then
                local bIsCreateSp = self:calculationScalePos(var)
                local _data = self._rankData[key + 1]
                self:updateCellData(var, _data, key, true, bIsCreateSp, true)
            end
        end

--        if math.abs(pro) <= 5 then
--            self._leftArrow:setVisible(false)
--            self._rightArrow:setVisible(true)
--        elseif math.abs(pro) >= 95 then
--            self._leftArrow:setVisible(true)
--            self._rightArrow:setVisible(false)
--        else
--            self._leftArrow:setVisible(true)
--            self._rightArrow:setVisible(true)
--        end
    end)
    self:calcArrow()
--    self:calculationPro(self._childNodeTable.scrollView, selfPos or 0)

end

--设置跑马灯的显示逻辑，默认开启
 function GloryArenaView:setNoticeBar()
      self._viewMgr:hideNotice(true)
 end

-- 异步方法, 进入系统之前需要做的事情, 比如请求,这个时候Ui还是没有放置在ViewManager上面,比如动画等其他创建函数还没有执行
function GloryArenaView:onBeforeAdd(callback, errorCallback)
    if callback then
        callback()
    end
    self:reflashUI()
--    self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
--        self:reflashUI(resule)
--    end)
end

-- 第一次进入界面会调用, 有需要请覆盖
 function GloryArenaView:onShow()
    if not self._arenaSchedule then
        self._arenaSchedule = ScheduleMgr:regSchedule(1000,self,function( )
            self:arenaUpdate()
        end)
    end
    self:arenaUpdate()
 end

--设置通用浮框的逻辑
function GloryArenaView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView",{types = {"Currency","Gold","Gem"},hideHead=true,title = "globalTitle_arena.png",titleTxt = "荣耀经济场"})
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"", "", "", ""}, title = "globalTitleUI_pvp.png",titleTxt = "荣耀竞技场"})
end

--进入UI播放动画之前的准备工作
-- function GloryArenaView:beforePopAnim()

-- end

-- 渲染时会调用, 改变元件坐标在这里
-- function GloryArenaView:onAdd()

-- end

--UI已经打开了，这个时候动画可能还没有结束
function GloryArenaView:onComplete()

end

--动画播放结束的时候调用的, 发请求最好也在这里
function GloryArenaView:onAnimEnd()
   self._bIsBtn = true
   self._curTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
end

---create View end

-- 成为topView会调用, 有需要请覆盖
 function GloryArenaView:onTop()
    self._bIsBtn = true
    if not self._arenaSchedule then
        self._arenaSchedule = ScheduleMgr:regSchedule(1000,self,function( )
            self:arenaUpdate()
        end)
    end
    self:arenaUpdate()
 end


-- 被其他View盖住会调用, 有需要请覆盖
 function GloryArenaView:onHide()
    if self._arenaSchedule then
        ScheduleMgr:unregSchedule(self._arenaSchedule)
        self._arenaSchedule = nil
    end
 end

-- 获取对话时,需要隐藏的UI列表
-- function GloryArenaView:getHideListInStory()
--     return nil
-- end


-- 主要用于内存优化
-- 进入战斗之前要做的事
-- function GloryArenaView:enterBattle()

-- end

-- 退出战斗要做的事
-- function GloryArenaView:exitBattle()

-- end

-- 接收自定义消息
function GloryArenaView:reflashUI(data)
    if self._gloryArenaModel:lIsCurTimeOpen() then
        self:initScrollView()
        self:setAttackCount(true)
        self:setReward()
        self:reflashTip()
--        print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%")
    end
end

--刷新小红点
function GloryArenaView:reflashTip()
    self:lSetRedSpot(self._childNodeTable.rewardBtn, self._gloryArenaModel:bIsCanBuyRed() or self._gloryArenaModel:bIsCanReward())
end

--添加小红点
function GloryArenaView:lSetRedSpot(sender, bIsShow)
    if sender then
        if sender._redSport_img == nil then
            sender._redSport_img = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrameByName("globalImageUI_bag_keyihecheng.png"))
            sender._redSport_img:setPosition(cc.p(sender:getContentSize().width - 11, sender:getContentSize().height - 15))
            sender._redSport_img:setScale(0.8)
            sender:addChild(sender._redSport_img, 1)
        end
        sender._redSport_img:setVisible(bIsShow)
    end
end

--function GloryArenaView:onTop( )
----	self:updatePvpIn()
----	self:reflashUI()
--end

function GloryArenaView:sendMessageCrossArena(callback)
    self._serverMgr:sendMsg("CrossArenaServer", "enterCrossArena", {},true ,{}, function(resule)
    --        self:reflashUI(resule)
        if callback then
            callback(resule)
        end
    end)
end

function GloryArenaView:lCheckGoBeyond()
    if self.updateisOpen and self._bIsBtn and not self._gloryArenaModel:lIsCurTimeOpen() then
        self.updateisOpen = false
--        self._viewMgr:popView()
         self._viewMgr:showDialog("gloryArena.GloryArenaResTipDialog",{callback = function()
                self._viewMgr:popView()
         end})
         return false
    end
    return true
end

function GloryArenaView:arenaUpdate()
--    print("++++++++++++++++++++++")
    self._bIsCanRefresh = true
    -- 十点结算倒计时
    local settleLab = self:getUI("bg.bottom.settleLab")
    settleLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    settleLab:setFontSize(20)
    settleLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local settleStartTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 20:00:00"))
    local settleEndTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 21:00:00"))
    if nowTime > settleStartTime and nowTime < settleEndTime then
        settleLab:setVisible(true)
        local leftTime = settleEndTime-nowTime
        settleLab:setString(string.format("%02d:%02d后结算",math.floor(leftTime/60),leftTime%60))
    else
        settleLab:setVisible(false)
    end
--     if _G.test == nil then
--         _G.test = 0
--     end
--     _G.test = _G.test + 1
--     if _G.test == 5 then
--         self._viewMgr:showDialog("gloryArena.GloryArenaResTipDialog",{callback = function()
--                self._viewMgr:popView()
--                _G.test = 0
--         end
--         })
--     end
--     print("+++++++++++++++", _G.test)
--    if self.updateisOpen and self._bIsBtn and not self._gloryArenaModel:lIsCurTimeOpen() then
--        self.updateisOpen = false
----        self._viewMgr:popView()
--         self._viewMgr:showDialog("gloryArena.GloryArenaResTipDialog",{callback = function()
--                self._viewMgr:popView()
--         end})
--    end
    self:lCheckGoBeyond()
    --过5点判断
    if self._curTime then
        local curTime = ModelManager:getInstance():getModel("UserModel"):getCurServerTime()
        local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
--        print("OOOOOOOOOOOOOOO", curTime > sec_time, self._curTime <= sec_time, curTime, sec_time, self._curTime)
        if curTime > sec_time and self._curTime <= sec_time then
--            print("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW")
            self._curTime = curTime + 1
            self:sendMessageCrossArena()
        end
    end
end


function GloryArenaView:setReward()
    if self._childNodeTable == nil then
        return
    end

    local selfRank = self._gloryArenaModel:lGetSelfRank()

    local rewardData = self._gloryArenaModel:lGetRankReward()

    
--    self._childNodeTable.diamondNum:setVisible(false)
    self._childNodeTable.diamondImg:setVisible(false)
    local itemId = rewardData.diamond[2] or 301303
    local itemCount = rewardData.diamond[3] or 301303
    if rewardData.diamond[1] ~= "tool" then
        print("找策划，奖励配置错了")
        itemId = 301303
        itemCount = 0
    end
    local sysItem = tab:Tool(itemId)
    if self._sysItem == nil then
        self._sysItem = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem})
        self._sysItem:setAnchorPoint(cc.p(0.5, 0.5))
        self._sysItem:setPosition(cc.p(self._childNodeTable.diamondNum:getPosition()))
--        self._sysItem:setContentSize(cc.size(42, 42))
        self._sysItem:setScale(0.5)
        self._childNodeTable.diamondNum:getParent():addChild(self._sysItem)
    else
        IconUtils:updateItemIconByView(self._sysItem, {itemId = itemId, itemData = sysItem})
    end
    
    self._childNodeTable.diamondNum:setString(itemCount)
    self._childNodeTable.diamondNum:setPositionX(self._sysItem:getPositionX() + self._sysItem:getContentSize().width * 0.5 / 2 + 10)
    

    self._childNodeTable.goldNum:setString(rewardData.texp or 0)
    self._childNodeTable.goldImg:ignoreContentAdaptWithSize(false)
    self._childNodeTable.goldImg:loadTexture("globalImageUI_texp.png", ccui.TextureResType.plistType)
--    self._childNodeTable.goldImg:setPositionX(self._sysItem:getPositionX() + self._sysItem:getContentSize().width * 0.5 + 10)
    self._childNodeTable.goldImg:setPositionX(self._childNodeTable.diamondNum:getPositionX() + self._childNodeTable.diamondNum:getContentSize().width + 30)
    self._childNodeTable.goldNum:setPositionX(self._childNodeTable.goldImg:getPositionX() + 30)

    self._childNodeTable.currencyImg:ignoreContentAdaptWithSize(false)
    self._childNodeTable.currencyImg:loadTexture("globalImageUI_gloryArenaIcon_min.png", ccui.TextureResType.plistType)
    self._childNodeTable.currencyNum:setString(rewardData.honorCertificate or 0)
    self._childNodeTable.currencyImg:setPositionX(self._childNodeTable.goldNum:getPositionX() + self._childNodeTable.goldNum:getContentSize().width + 30)
    self._childNodeTable.currencyNum:setPositionX(self._childNodeTable.currencyImg:getPositionX() + 30)
    
    
--    self._childNodeTable.settleLab:setPositionX(MAX_SCREEN_WIDTH / 2)
--    self._childNodeTable.settleLab:setString("------------")
end

function GloryArenaView:setAttackCount(bIsVisible)
    if self._childNodeTable == nil then
        return
    end
    if bIsVisible then
        local selfAttackCount = self._gloryArenaModel:lGetSelfAttackCount()
        self._childNodeTable.challengeBg:setVisible(true)
        self._childNodeTable.chanceNum:setColor((selfAttackCount.num > 0 and cc.c3b(0, 255, 0) or cc.c3b(255, 0, 0)))
        self._childNodeTable.chanceNum:setString(selfAttackCount.num)
        self._childNodeTable.chanceTotal:setString("/5")
        if selfAttackCount.num <= 0 then
            self._childNodeTable.addChangeBtn:setTouchEnabled(true)
            self._childNodeTable.addChangeBtn:setVisible(true)
        else
            self._childNodeTable.addChangeBtn:setTouchEnabled(false)
            self._childNodeTable.addChangeBtn:setVisible(false)
        end
        
    else
        self._childNodeTable.challengeBg:setVisible(false)
    end
end

function GloryArenaView:setInitAttackCoolingCD(bIsVisible)
    if self._childNodeTable == nil then
        return
    end
    if bIsVisible then
        self._childNodeTable.cdBg:setVisible(true)
        self._childNodeTable.cdTime:setString("--:--")
        self._childNodeTable.cdDiamondImg:loadTexture("globalImageUI_diamond.png", ccui.TextureResType.plistType)
        self._childNodeTable.cdDiamondNum:setString(0)
        self._childNodeTable.cdDiamondNum:setPositionX(cdDiamondImg:getPositionX() + 30)
    else
        self._childNodeTable.cdBg:setVisible(false)
    end
end


local cellConfig = {
    {name = "name", childName = "name", isText = true},
    {name = "image_bg", childName = "image_bg"},
    {name = "infoBg", childName = "infoBg"},
    {name = "rank", childName = "rank", isText = true},
    {name = "des1", childName = "des1", isText = true},
    {name = "HeroNode", childName = "HeroNode"},
    {name = "challengeBtn", childName = "challengeBtn"},
    {name = "selfImg", childName = "selfImg"},
    {name = "moppingUp_btn", childName = "moppingUp_btn"},
    {name = "challenge_btn", childName = "challenge_btn"},
}


function GloryArenaView:startBattle(data)
    if  data == nil or not self._bIsBtn then
        return
    end
    if not self:lCheckGoBeyond() then
        return
    end
    if self._gloryArenaModel:lGetSelfAttackCount().num > 0 then
        local formationModel = self._modelMgr:getModel("FormationModel")
        --防止进攻编组是nul
--        formationModel:private_CheckGloryArenaAttackFormationData()
            local function inAttackArray()
                self._viewMgr:showView("formation.NewFormationView", {
                        formationType = formationModel.kFormationTypeGloryArenaAtk1,
                        extend = {
                        },
                        closeCallback = function ()
                            print("*************close***************")
                        end,
                        callback = function ()
                            --挑战别人
                            if self._gloryArenaModel:lIsCurTimeOpen() then 
                                self._serverMgr:sendMsg("CrossArenaServer", "challenge", {id = data.id, rank = data.rank},true ,{}, function(resule)
                                    -- 关闭布阵
                                    self._viewMgr:popView()
                                    self._viewMgr:showDialog("gloryArena.GloryArenaDuelDialog", resule)
                                    if resule then
                                        local userId = self._modelMgr:getModel("UserModel"):getUID()
                                        local isMeAtk = userId == resule.atkId
                                        if (isMeAtk and resule.win == 1) or (not isMeAtk and  resule.win == 2) then
                                            self:sendMessageCrossArena()
                                        end
                                    end
                                end)
                            else
                                self._viewMgr:showTip(lang("honorArena_tip_2"))
                            end
                        end
                    })
            end
            self._gloryArenaModel:lCheckAttackArray(inAttackArray)
    else
        self:sendBuyChallengeNumMsg(data, 2)
    end
end


function GloryArenaView:sweepEnemy(data)
    if  data == nil or not self._bIsBtn then
        return
    end
    if not self:lCheckGoBeyond() then
        return
    end
    if self._gloryArenaModel:lGetSelfAttackCount().num > 0 then
        self._serverMgr:sendMsg("CrossArenaServer", "sweepEnemy", {id = data.id, rank = data.rank},true ,{}, function(resule)
            DialogUtils.showGiftGet( {gifts = resule.rewards})
        end)
    else
        self:sendBuyChallengeNumMsg(data, 3)
    end
end

function GloryArenaView:showPlayerInfo(data)
    if  data == nil or not self._bIsBtn then
        return
    end
    if not self:lCheckGoBeyond() then
        return
    end
    self._serverMgr:sendMsg("CrossArenaServer", "getDetailInfo", {id = data.id},true ,{}, function(resule)
        self._viewMgr:showDialog("gloryArena.GloryArenaUserInfoDialog", resule.info)
    end)
end

function GloryArenaView:updateCellData(sender, data, nIndex, bNotDelay, bIsCreateSp, bIsOneCreateSp)
    if sender and data then
        local childNodeTable = sender._childNodeTable
        if childNodeTable == nil then
            childNodeTable = self:lGetChildrens(sender, cellConfig)
        end
        if childNodeTable then 
            sender._childNodeTable = childNodeTable
            if not bIsOneCreateSp then
                sender:setOpacity(0)
                local bgRes = "ga_reportDialog_rank4.png"
                if data.rank <= 3 then
                    bgRes = "ga_reportDialog_rank" .. data.rank .. ".png"
                elseif data.rank > 10 then
                    bgRes = "ga_reportDialog_rank5.png"
                end

                if data.rank == 1 and sender.animation == nil then
                    sender.animation = mcMgr:createViewMC("rongyaobaozuo_jingjichangbaozuo", true, false)
                    sender.animation:setPosition(cc.p(childNodeTable.image_bg:getContentSize().width / 2, childNodeTable.image_bg:getContentSize().height / 2 + 10))
                    sender.animation:setScale(1.2)
                    childNodeTable.image_bg:addChild(sender.animation)
                end
                childNodeTable.image_bg:ignoreContentAdaptWithSize(false)
                childNodeTable.image_bg:loadTexture(bgRes, ccui.TextureResType.plistType)
                childNodeTable.name:setString(data.name or "-")
                childNodeTable.rank:setString(data.rank or "-")
    --            childNodeTable.
                local bIsSel = false
                if data.rid == self._userModel:getUID() then
                    bIsSel = true
                end

                self:lSetBtnTitle(childNodeTable.challengeBtn)
                self:lSetBtnTitle(childNodeTable.moppingUp_btn)
                self:lSetBtnTitle(childNodeTable.challenge_btn)

                if bIsSel then
                    childNodeTable.selfImg:setVisible(true)
                    childNodeTable.challengeBtn:setVisible(false)
                    childNodeTable.moppingUp_btn:setVisible(false)
                    childNodeTable.challenge_btn:setVisible(false)
                    childNodeTable.selfImg:setScale(1.5)
                    childNodeTable.HeroNode:setTouchEnabled(false)
                else
                    childNodeTable.HeroNode:setTouchEnabled(true)
                    self:registerClickEvent(childNodeTable.HeroNode, function( _,x,y,sender)
                        --查看玩家信息
                        self:showPlayerInfo(data)
                    end)
                    if data.rank <= self._nSelfRank then
                        childNodeTable.selfImg:setVisible(false)
                        childNodeTable.challengeBtn:setVisible(true)
                        childNodeTable.moppingUp_btn:setVisible(false)
                        childNodeTable.challenge_btn:setVisible(false)
                        childNodeTable.challengeBtn:setSwallowTouches(true)
                        local isAttack = true
                        if self._nSelfRank > 20 and data.rank <= 10 then
                            isAttack = false
                        end
                        if isAttack then
                            childNodeTable.challengeBtn:loadTextures("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", ccui.TextureResType.plistType)
                            childNodeTable.challengeBtn:setTitleText("挑  战")
                            childNodeTable.challengeBtn:setTitleFontSize(26)

                        else
                            childNodeTable.challengeBtn:loadTextures("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", ccui.TextureResType.plistType)
                            childNodeTable.challengeBtn:setTitleText("查  看")
                            childNodeTable.challengeBtn:setTitleFontSize(26)

                        end
                        self:registerClickEvent(childNodeTable.challengeBtn, function( _,x,y,sender)
                            if isAttack then
                                --挑战别人
                                self:startBattle(data)
                            else
                                --查看别人
                                self:showPlayerInfo(data)
                            end
                        end)
                    else
                        --扫荡
                        childNodeTable.selfImg:setVisible(false)
                        childNodeTable.challengeBtn:setVisible(false)
                        childNodeTable.moppingUp_btn:setVisible(true)
                        childNodeTable.challenge_btn:setVisible(true)
                        childNodeTable.challenge_btn:setSwallowTouches(true)
                        childNodeTable.moppingUp_btn:setSwallowTouches(true)
                        self:registerClickEvent(childNodeTable.challenge_btn, function( _,x,y,sender)
                            --挑战别人
                            self:startBattle(data)
                        end)

                        self:registerClickEvent(childNodeTable.moppingUp_btn, function( _,x,y,sender)
                            --扫荡
                            self:sweepEnemy(data)
                        end)
                    end

                    
                end
            end
            if bIsCreateSp then
                local enemyId = data.heroId or 60001
                local heroD = tab:Hero(enemyId or 60001)
                if not heroD then
                    print("没有英雄数据！！")
                    heroD = tab:Hero(60001)
                end 
                local heroArt = heroD["heroart"]
                if data.heroSkin and data.heroSkin ~= 0  then
                    local heroSkinD = tab.heroSkin[data.heroSkin]
                    heroArt = heroSkinD["heroart"] or heroD["heroart"]
                end
                local sp = childNodeTable.HeroNode:getChildByName("stop_sp")
                local isCreateSp = true
                if sp then
                    if sp._heroArt == heroArt then
                        isCreateSp = false
                    else
                        childNodeTable.HeroNode:removeChild(sp, true)
                    end
                end
                if isCreateSp and sender._isCreateSp then
                    isCreateSp = false
                end
--                isCreateSp = false
                if isCreateSp then
                    if not bNotDelay then
                        if self._showSp == nil then
                            self._showSp = 0
                        end
                        self._showSp = self._showSp + 1
                        sender._isCreateSp = true
                        childNodeTable.HeroNode:runAction(cc.Sequence:create(
                            cc.DelayTime:create(0.06 * self._showSp),
                            cc.CallFunc:create(function()
                                    sender._isCreateSp = false
                                    local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
                                    sp._heroArt = heroArt
                                    sp:setName("stop_sp")
                                    sp:setScale(-1.2, 1.2)
                                    sp:setPositionX(childNodeTable.HeroNode:getContentSize().width / 2)
                                    childNodeTable.HeroNode:addChild(sp)            
                            end)
                        ))
                    else
                        sender._isCreateSp = false
                        local sp = mcMgr:createViewMC("stop_" .. heroArt, true)
                        sp._heroArt = heroArt
                        sp:setName("stop_sp")
                        sp:setScale(-1.2, 1.2)
                        sp:setPositionX(childNodeTable.HeroNode:getContentSize().width / 2)
                        childNodeTable.HeroNode:addChild(sp)      
                    end
                end
            end
        end
    end
end

function GloryArenaView:sendBuyChallengeNumMsg(data, nType)
    local buyNum = self._gloryArenaModel:lGetSelfAttackCount().buyNum
    local vip = self._modelMgr:getModel("VipModel"):getData().level

    local canBuyNum = tonumber(tab:Vip(vip).refreshHonorArena) 
    if buyNum >= canBuyNum then
        -- self._viewMgr:showTip("已达购买上限！")
        self._viewMgr:showDialog("global.GlobalResTipDialog",{},true)
        return 
    end
    -- local buySetting = 
    local costIdx = math.min(self._gloryArenaModel:lGetSelfAttackCount().buyNum+1, #tab.reflashCost)-- tab:Setting("G_ARENA_BUY_GEM").value
--    local nextCost = math.ceil(tab:ReflashCost(costIdx).costArena*self:getActivityDiscount())
    local nextCost = tab:ReflashCost(costIdx).refreshHonorArena
    local gem = self._modelMgr:getModel("UserModel"):getData()["gem"]
    if nextCost < gem then
        local canBuyNum = self._gloryArenaModel:canBuyChanllengeNum()
        local canBuyDes = lang("TIPS_ARENA_12")
        canBuyDes = string.gsub(canBuyDes,"{$resetlim}",canBuyNum)
        DialogUtils.showBuyDialog({costNum = nextCost,goods = "购买一次挑战次数(" .. canBuyDes .. ")",callback1 = function( )
            local param = {}
            self._serverMgr:sendMsg("CrossArenaServer", "buyChallengeNum", param, true, {}, function(result) 
                if nType == 2 then
                    self:startBattle(data)
                elseif nType == 3 then
                    self:sweepEnemy(data)
                end
            end)    
        end})
    else
        DialogUtils.showNeedCharge({callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end

--获取打折的数据
function GloryArenaView:getActivityDiscount( )
    local actModel = self._modelMgr:getModel("ActivityModel")
    local actCostLess = actModel:getAbilityEffect(actModel.PrivilegIDs.PrivilegID_15)
    return (1+actCostLess)
end

function GloryArenaView:enterBattleAttack()
    self._viewMgr:lock(-1)
    ScheduleMgr:delayCall(0, self, 
        function()
            self._viewMgr:unlock()
            local file1=io.open("C:\\Users\\playcrab\\AppData\\Local\\war\\test01.txt", "r+") 
            local jsondata=file1:read()
            file1:close()
            local data = cjson.decode(jsondata)
            local leftInfo = BattleUtils.jsonData2lua_battleData(data["atk"])
            local rightInfo = BattleUtils.jsonData2lua_battleData(data["def"])

            local data = BattleUtils.enterBattleView_GloryArena(leftInfo, rightInfo, nil, nil, false,
                function(info, callback)
                    -- 战斗结束
                    callback(info)
                end,
                function (info)
                    -- 退出战斗
                end, true
            )

--            dump(data)
        end
    )
    
end

function GloryArenaView:onDestroy()
    if self._arenaSchedule then
        ScheduleMgr:unregSchedule(self._arenaSchedule)
        self._arenaSchedule = nil
    end
--    ScheduleMgr:cleanMyselfDelayCall(self)

end

--里面用于释放当前文件的local, 因为反require的时候 这些local不会释放,现在还不清楚实现的原理
function GloryArenaView:dtor()
    childBtnName = nil
    cellConfig = nil
    -- tipBg = nil
end

return GloryArenaView

