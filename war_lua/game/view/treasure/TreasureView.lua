--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-22 19:37:25
--

local disTPos = {
    [3] = { [2] = true, [6] = true, [7] = true },
    [4] = { [2] = true, [3] = true, [5] = true, [6] = true },
    [6] = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true }
}

local comMcOffsetY =
{
    [10] = 0,
    [11] = {-6,- 25},
    -- [[ todo 缺资源
    [12] = {-2,18},

    [23] = {-10,10},
    --]]
    [22] = 0,
    [21] = 0,

    [30] = 0,
    [31] = {18,28},
    [32] = 0,

    [40] = 0,
    [41] = {-25,-25},
    [42] = {5,25},
    [43] = {-10,-10},
    [33] = {-5,-20},
}

-- 染色 给特效染品质色 适用于蓝色
local activeHue = {
    [2] = -120,
    [3] = 0,
    [4] = 100,
    [5] = -150,
}
local maxComStage = table.nums(tab.devComTreasure)+1
local maxDisStage = table.nums(tab.devDisTreasure)+1
local openConditions = {
    [1] = "需要:等级{condition}解锁",
    [2] = "需要:通关副本{condition}解锁",
    [3] = "需要:通关精英副本{condition}解锁",
}
require("game.view.treasure.TreasureConst")
local GlobalTipView = require("game.view.global.GlobalTipView")
local TreasureView = class("TreasureView",BaseView)
function TreasureView:ctor(param)
    self.super.ctor(self)
    self.initAnimType = 2
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
    self._tModel = self._modelMgr:getModel("TreasureModel")
    self._skillTabMap = {
        tab.heroMastery,
        tab.playerSkillEffect,
        tab.skillPassive,
        tab.skillCharacter,
        tab.skillAttackEffect,
        tab.skill,
    }
    self._initIdx = param and param.treasureId
end

function TreasureView:getAsyncRes()
    return
    {
        { "asset/ui/treasure.plist", "asset/ui/treasure.png" },
        { "asset/ui/treasure1.plist", "asset/ui/treasure1.png" },
        { "asset/ui/treasure2.plist", "asset/ui/treasure2.png" },
        { "asset/ui/treasure3.plist", "asset/ui/treasure3.png" },
        { "asset/ui/treasure4.plist", "asset/ui/treasure4.png" },
        { "asset/ui/treasureActiveBg1.plist", "asset/ui/treasureActiveBg1.png" },
        { "asset/ui/treasureActiveBg2.plist", "asset/ui/treasureActiveBg2.png" },
        {"asset/ui/treasure-HD.plist", "asset/ui/treasure-HD.png"},
        -- 用背包的标题底板
        -- { "asset/ui/bag.plist", "asset/ui/bag.png" },
    }
end
-- function TreasureView:getBgName()
--     return "bg_treasure.jpg"
-- end

function TreasureView:onBeforeAdd(callback)
    self._serverMgr:sendMsg("TreasureServer", "getTreasure", { }, true, { }, function(result)
        if _error then
            errorCallback()
        else
            callback()
        end
        self:reflashUI()
    end )
end

function TreasureView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", { titleTxt = "宝物", hideInfo = true,hideHead=true },nil,ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureView:onInit()
	-- 背景适配
	self._bgImg = self:getUI("bg.bgImg")
	self._bgImg:loadTexture("treasureBg_2.jpg",1)
	-- 
	self._comTreasures    = {}	-- 组合宝物
	self._disTreasures    = {}	-- 散件宝物
	self._curDisTreasures = {}	-- 当前散件信息
	self._comStatus 	  = {}	-- 记录组合宝物状态
	self._Atts = { }
	
	self._layer = self:getUI("bg.layer")   -- 散件板子
    self._disPanel = self:getUI("bg.layer.disPanel")    -- 散件板子
    self._selFrame = self:getUI("bg.layer.selFrame")	-- 选中框
	self._treasureName = self:getUI("bg.rightInfo.treasureName")		-- 名字
	self._fightDes = self:getUI("bg.rightInfo.fightDes")-- 选中宝物的战斗力
    self._fightLab = self:getUI("bg.rightInfo.fightLab")-- 选中宝物的战斗力

    self._rightInfo = self:getUI("bg.rightInfo")
    -- 属性加成值panel
    self._attrPanel = self:getUI("bg.rightInfo.attrPanel")
    -- 组合宝物展示节点
    self._curComPic = ccui.Widget:create()
    -- cc.ClippingNode:create()
    self._curComPic:setContentSize({width=5, height=5})
    self._curComPic:setPosition(self._disPanel:getContentSize().width / 2+8, self._disPanel:getContentSize().height / 2)
    self._disPanel:addChild(self._curComPic,10)
    
    -- 宝物总战斗力
    self._scoreDes = self:getUI("bg.layer.scoreDesImg")
    -- 叹号 点击出 全部属性tip
    local allAttrBtn = ccui.ImageView:create()
    allAttrBtn:loadTexture("globalImage_info.png",1)
    self:registerClickEvent(allAttrBtn,function() 
        self._viewMgr:showHintView("global.GlobalTipView",{
            tipType   = 20,
            posCenter = true,
        })
    end)
    allAttrBtn:setAnchorPoint(1,0.5)
    allAttrBtn:setPositionY(12)
    self._allAttrBtn = allAttrBtn
    self._scoreDes:addChild(allAttrBtn)
    -- self._scoreDes:setColor(cc.c3b(255, 183, 25))
    -- self._scoreDes:enable2Color(1,cc.c4b(255, 236, 67, 255))
    -- self._scoreDes:setFontName(UIUtils.ttfName_Title)
    local allScore = cc.Label:createWithBMFont(UIUtils.bmfName_zhandouli, "0")
    allScore:setAnchorPoint(cc.p(0,0.5))
    allScore:setPositionY(self._scoreDes:getPositionY()+8)
    allScore:setScale(0.75)
    self._layer:addChild(allScore)
    self._allScore = allScore 

    -- 按钮
    self._upBtn = self:getUI("bg.rightInfo.upBtn")
    -- 技能
    self._skillBg 	= self:getUI("bg.rightInfo.skillBg")
    self._skillImg 	= self:getUI("bg.rightInfo.skillBg.skillImg")
    self._skillName = self:getUI("bg.rightInfo.skillBg.skillName")
    self._skillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._skillBg = self:getUI("bg.rightInfo.skillBg")
    self:registerClickEvent(self._skillBg,function( )
        -- print("skillBg..........inininininnini")
        local skillLv = 1
        if self._curComInfo and self._curComInfo.stage > 0 then
            skillLv = self._curComInfo.stage
        end
        self._viewMgr:showHintView("global.GlobalTipView", { tipType = 2, node = self._skillImg, id = self._curComData.addattr[1][2], skillType = self._curComData.addattr[1][1], skillLevel = skillLv ,notAutoClose = true,treasureInfo = {id=self._curComData.id,stage=skillLv}})
    end)
    -- 侧边滚动栏
	self._scrollView = self:getUI("bg.scrollBg.scrollView")
    self._scrollView:setContentSize(cc.size(320,MAX_SCREEN_HEIGHT))
	self._scrollView:setPositionY((640-MAX_SCREEN_HEIGHT)/2+40)
	self._scrollView:addEventListener(function(sender, eventType)
        if eventType == 4 then
        	-- on scrolling
            self:onComScrolling()
        end
    end)
    self._scrollBg = self:getUI("bg.scrollBg")
    -- 当前宝物名字等级
    self._comName = self:getUI("bg.rightInfo.comName")
    self._comName:setFontName(UIUtils.ttfName_Title)
    self._comName:setFontSize(45)
    -- self._comName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self._comName:setString("")

    -- 
    UIUtils:adjustTitle(self:getUI("bg.rightInfo.skillTitleBg"))
    UIUtils:adjustTitle(self:getUI("bg.rightInfo.attTitleBg"))
    

    -- 初始化散件位置
    self:initDisInfo()
    -- 初始化组合宝物
    self.needStartMove = true
    self:initComInfo()

    -- 初始化宝物装饰动画
    self:initDecMcs()

    self:registerClickEventByName("bg.layer.shopBtn",function() 
        self._viewMgr:showView("treasure.TreasureShopView")
    end)
    local settingBtn = self:getUI("bg.layer.settingBtn")
    if settingBtn then
        -- settingBtn:setVisible(false)
    end
    self:registerClickEventByName("bg.layer.settingBtn",function() 
        -- self._serverMgr:sendMsg("TformationServer", "getFormation", {}, true, { }, function(result)
            UIUtils:reloadLuaFile("treasure.TreasureSelectSkillView")
            self._viewMgr:showDialog("treasure.TreasureSelectSkillView")
        -- end)
    end)
    self:registerClickEventByName("bg.layer.breakBtn",function()
        local isOpen,_,openLevel = SystemUtils["enableTreasureFenjie"]()
        if not isOpen then
            local systemOpenTip = tab.systemOpen["TreasureFenjie"][3]
            if not systemOpenTip then
                self._viewMgr:showTip(tab.systemOpen["TreasureFenjie"][1] .. "级开启")
            else
                self._viewMgr:showTip(lang(systemOpenTip))
            end
            return 
        end 
        self._viewMgr:showDialog("treasure.TreasureBreakView")
    end)
    self._breakBtn = self:getUI("bg.layer.breakBtn")
    local isOpen,_,openLevel = SystemUtils["enableTreasureFenjie"]()
    local isFenjieOpened = self._tModel:isFenjieOpened()
    UIUtils:setGray(self._breakBtn,not isOpen or not isFenjieOpened)
    local breakText = self:getUI("bg.layer.breakBtn.text")
    if breakText then breakText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1) end
    self._infoBtn = self:getUI("bg.rightInfo.infoBtn")
    self:registerClickEventByName("bg.rightInfo.infoBtn",function() 
        self._viewMgr:showHintView("global.GlobalTipView",{
            tipType   = 15,
            id        = self._curComData.id,
            stage     = self._curComInfo and self._curComInfo.stage or 1,
            posCenter = true,
        })
    end)

    -- 点击宝物图标 进阶
    self._comTouch = self:getUI("bg.layer.comTouch")
    self._comTouch:setSwallowTouches(false)
    self:registerClickEventByName("bg.layer.comTouch", function()
        self:onClickUpBtn()
    end )
    
    self:registerClickEventByName("bg.rightInfo.upBtn", function()
        if self._upBtn._tip then
            self._viewMgr:showTip(self._upBtn._tip or "")
            return 
        end
        self:onClickUpBtn()
    end )
    -- 宝物刻印 升星
    self:registerClickEventByName("bg.layer.starBtn", function()
        self:onClickStarBtn()
    end )

    
    -- 加上下箭头
    self._downArrow = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self._downArrow:setPosition(70,600)
    self._downArrow:setRotation(-65)
    self._scrollBg:addChild(self._downArrow, 5)
    -- = self:getUI("bg.layer.upArrow")
    -- self._upArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --     cc.MoveBy:create(0.5,cc.p(10,0)),
    --     cc.MoveBy:create(0.5,cc.p(-10,0))
    -- )))

    self._upArrow = mcMgr:createViewMC("zuojiantou_teamnatureanim", true, false)
    self._upArrow:setPosition(80,100)
    self._upArrow:setRotation(-125)
    self._scrollBg:addChild(self._upArrow, 5)
    -- self:getUI("bg.layer.downArrow")
    -- self._downArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
    --     cc.MoveBy:create(0.5,cc.p(-10,0)),
    --     cc.MoveBy:create(0.5,cc.p(10,0))
    -- )))

    -- 适配
    if MAX_SCREEN_WIDTH == 960 then
        -- self._upArrow:setPositionX(770)
        -- self._downArrow:setPositionX(50)
        -- self._breakBtn:setPositionX(34)
    elseif MAX_SCREEN_WIDTH == 1136 then
        -- self._breakBtn:setPositionX(-45)
    end

    self:listenReflash("TreasureModel", self.reflashUI)
    self:listenReflash("ItemModel", function()
        self._curOffset = self._scrollView:getInnerContainer():getPositionY()

        self._scrollView:removeAllChildren()
        self._comTreasures = { }
        self:initComInfo()
        self:reflashUI()
    end )
end

-- 初始化散件位置
function TreasureView:initDisInfo( )
	for i = 1, 7 do
        local disTreasure = self:getUI("bg.layer.disPanel.disTreasure_" .. i)
        table.insert(self._disTreasures, disTreasure)
        self:registerClickEvent(disTreasure, function()
            if disTreasure._notTouch then return end
            if disTreasure._tip then
                self._viewMgr:showTip(disTreasure._tip)
                return
            end
            if disTreasure._disId then
                if disTreasure._fixed then
                    self._viewMgr:showDialog("treasure.TreasureDisUpView", { upType = "dis", id = disTreasure._disId, cid = self._curComData.id, stage = disTreasure._stage or 0 }, true)
                else
                    local _, hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(disTreasure._disId)
                    if hadNum < 1 then
                        self._viewMgr:showDialog("bag.DialogAccessTo", { goodsId = disTreasure._disId }, true)
                        -- self._viewMgr:showTip(lang("TIPS_ARTIFACT_NO"))
                        return
                    end
                    local comInfo = self._tModel:getComTreasureById(tostring(disTreasure._comId))
                    local preFightNum = comInfo and ((comInfo.comScore or 0)+ (comInfo.disScore or 0)) or 0
                    self._serverMgr:sendMsg("TreasureServer", "WearDisTreasure", { comId = disTreasure._comId, disId = disTreasure._disId, positionId = disTreasure._posId }, true, { }, function(result)
                        -- disTreasure:setBrightness(40)
                        disTreasure:runAction(cc.Sequence:create(
                            cc.ScaleTo:create(0.1,1.5),
                            cc.CallFunc:create(function( )
                                disTreasure:setBrightness(40)
                            end),
                            cc.ScaleTo:create(0.1,1),
                            cc.DelayTime:create(0.1),
                            cc.CallFunc:create(function( )
                                disTreasure:setBrightness(0)
                                local mc = mcMgr:createViewMC("jihuosanjian_treasureui", false, true, function()
                                    disTreasure._fixed = true
                                    self:reflashUI()
                                end )
                                mc:setName("anim")
                                mc:setPosition(disTreasure:getPositionX(), disTreasure:getPositionY())
                                self._disPanel:addChild(mc, 999)
                                local comInfo = self._tModel:getComTreasureById(tostring(disTreasure._comId))
                                local afterFightNum = comInfo and ((comInfo.comScore or 0)+(comInfo.disScore or 0)) or 0
                                TeamUtils:setFightAnim(self:getUI("bg.layer"),{x=400,y=480,oldFight = preFightNum,newFight=afterFightNum,})
                            end)
                        ))
                    end )
                end
            end
        end )
    end
end
-- 初始化左侧组合宝物列表
function TreasureView:initComInfo( )
	-- 初始化基本界面数据
    local comTreasureTab = { }
    for k, comTreasure in pairs(clone(tab.comTreasure)) do
        if comTreasure.produce == 0 then
            local isOpen = false
            local openTab = comTreasure.condition
            local openType = openTab[1]
            if openType == 1 then
                isOpen = self._modelMgr:getModel("UserModel"):getData().lvl >= openTab[2]
            elseif openType == 2 or openType == 3 then
                local stageInfo
                if openType == 2 then
                    stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(openTab[2])
                elseif openType == 3 then
                    stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(openTab[2])
                end
                isOpen = stageInfo.isOpen
            end
            local haveDis = false
            for _, v in pairs(comTreasure.form) do
                local _, havenum = self._modelMgr:getModel("ItemModel"):getItemsById(tonumber(v))
                if havenum > 0 then
                    haveDis = true
                end
            end
            -- [[ comTreasure表去掉skill字段 这里做兼容
            comTreasure.skill       = comTreasure.addattr[1][2]
            comTreasure.skillType   = comTreasure.addattr[1][1]
            --]]
            if isOpen or haveDis or self._tModel:getComTreasureById(tostring(comTreasure.id)) then
                table.insert(comTreasureTab, comTreasure)
            end
        end
    end
    table.sort(comTreasureTab, function(a, b)
        return a.rank < b.rank
    end )
    -- dump(comTreasureTab)
    local idx = 1
    local maxPageCount = 1
    local x, y = 0, 0
    local comTSize = 130
    local offsetx, offsety = 25, 25
    local leftOffset, rightOffset = 0, 0
    local scrollW, scrollH = self._scrollView:getContentSize().width, self._scrollView:getContentSize().height
    self._scrollView:setInnerContainerSize({width=scrollW, height=scrollH})
    local comTNum = table.nums(comTreasureTab)
    -- print("scrollW < comTNum * comTSize",scrollW < comTNum * comTSize,scrollW ,comTNum * comTSize)
    local maxHeight = comTNum * comTSize
    if scrollW < maxHeight then
        self._scrollView:setInnerContainerSize({width= scrollW, height= maxHeight})
    else
        offsety = (scrollH - comTNum * comTSize) / 2
        leftOffset = offsetx - comTSize
        rightOffset = -(offsetx - comTSize)
    end
    local initSel = nil
    for k, comTreasure in pairs(comTreasureTab) do
        local icon = self:createTreasureIcon(comTreasure.id, comTreasure, false)
        y = maxHeight - idx* comTSize
        
        if nitSel == nil then
            if self._initIdx then
                if self._initIdx == comTreasure.id then
                    initSel = icon
                end
            else
                local haveNotice = self._modelMgr:getModel("TreasureModel"):isComTreasureCanDo(comTreasure.id)
                if initSel == nil and haveNotice then
                    initSel = icon
                end
            end
        end
        if self._curComData and self._curComData.id == comTreasure.id then
            initSel = icon
        end
        
        -- icon:setScale(0.8)
        icon:setPosition(x + offsetx, y + offsety)
        self._scrollView:addChild(icon)
        -- 从新计算位置
        self:reCalculatePos(icon)

        icon._comIdx = idx
        icon._tId = comTreasure.id
        self._comTreasures[tonumber(comTreasure.id)] = icon
        icon._data = comTreasure
        icon._click = true
        self:registerTouchEvent(icon,
        function()
            -- down
            icon:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
                icon._click = false
                -- self._viewMgr:showHitView({tipType = 10,id = comTreasure.id , treasureData = comTreasure})
            end )))
        end ,
        function()
            -- move
            icon._click = true
        end ,
        function()
            -- up
            if icon._click then
                self:clickTreasure(icon)
            end
            icon._click = true
            icon:stopAllActions()
            self._viewMgr:closeHintView()
        end ,
        function()
            -- out
            icon:stopAllActions()
            self._viewMgr:closeHintView()
            icon._click = true
        end
        )
        idx = idx + 1
    end
    local isInUpStarGuide = self._modelMgr:getModel("TreasureModel"):isUpStarGuide()
    if isInUpStarGuide then
        self.needStartMove = false
    end
    if initSel == nil or isInUpStarGuide then
        initSel = self._scrollView:getChildren()[1]
    end
    if self.needStartMove then
        self.needStartMove = false
        --[[ 调试滚动
        initSel = self._scrollView:getChildren()[9]
        --]]
        if initSel == self._scrollView:getChildren()[1] then -- or initSel == self._scrollView:getChildren()[2] then
            if self._upArrow then
                self._upArrow:setVisible(false)
            end
        else
            if table.nums(self._comTreasures) > 4 then
                local scrollHeight = self._scrollView:getInnerContainerSize().height
                local scrollVisibleHeight = self._scrollView:getContentSize().height
                local container = self._scrollView:getInnerContainer()
                -- if true then return end
                local scrollPercent =(scrollHeight-initSel:getPositionY()-comTSize) /(scrollHeight-scrollVisibleHeight) * 100
                print("scrollPercent=======",scrollPercent,initSel:getPositionY())
                scrollPercent = scrollPercent >= 100 and 100 or scrollPercent
                scrollPercent = scrollPercent <= 0 and 0 or scrollPercent

                -- scrollView的scrollToPercentVertical要延迟调用，否则没效果
                ScheduleMgr:delayCall(5, self, function()
                    if not self._scrollView then return end
                    self._scrollView:scrollToPercentVertical(scrollPercent,0.2,true)
                    self:updateArrows()
                end)
            end
        end
    end
    self:clickTreasure(initSel)
    self._comTNum = table.nums(self._comTreasures)    
end

-- 点击组合icon事件
function TreasureView:clickTreasure( icon )
    for k, v in pairs(self._comTreasures) do
        v:getChildByFullName("iconBg"):loadTexture("buttonBg_" ..(v._data.quality or 2) .. "_treasure.png", 1)
        local selFrame = v:getChildByFullName("select")
        if selFrame then
            selFrame:setVisible(false)
        end
    end
    if icon == nil then return end
    self._curComData = icon._data
    self._curIcon = icon
    local selFrame = icon:getChildByFullName("select")
    if not selFrame then
        selFrame = mcMgr:createViewMC("bapowuxuanzhong_treasureui", true, false)
        -- self._selFrame:clone()
        selFrame:setVisible(true)
        selFrame:setName("select")
        icon:addChild(selFrame, -11)
        selFrame:setPosition(icon:getContentSize().width/2+2, icon:getContentSize().height/2-2)
        selFrame:setScale(0.92)
    else
        selFrame:setVisible(true)
    end
    -- selFrame:setScale(0.95)
    icon:getChildByFullName("iconBg"):loadTexture("buttonBg_" ..(self._curComData.quality or 2) .. "_treasure.png", 1)
    local poses = disTPos[#self._curComData.form]
    self._curDisTreasures = { }
    local idx = 1
    for i, v in ipairs(self._disTreasures) do
        if poses[i] then
            -- v:setVisible(true)
            table.insert(self._curDisTreasures, v)
            v._data = self._curComData.form[idx]
            idx = idx + 1
            v._notTouch = false
        else
            -- v:setVisible(false)
            v:removeAllChildren()
            v._notTouch = true
        end
        v:setContentSize({width=146,height=146})
        -- 新逻辑 disTreasure 底图是否可见 2017.4.1
        -- if  (i == 1 or i == 4) and #self._curComData.form == 6 then
        --     v:loadTexture("grid_5_treasure.png",1)
        --     v:setOpacity(255)
        -- elseif (i == 3 or i == 5) and (#self._curComData.form == 4) then 
        --     if self._curComData.quality == 4 then
        --         v:setOpacity(255)
        --         v:loadTexture("grid_4_treasure.png",1)
        --         v:setContentSize({width=170,height=153})
        --     else
        --         v:setOpacity(0)
        --     end
        -- else
            v:setOpacity(0)
        -- end

        -- 紫色偏移
        -- if i == 7 then 
        --     if self._curComData.quality == 4 then
        --         v:setPositionX(315)
        --     else
        --         v:setPositionX(325)
        --     end
        -- end
    end
    self:reflashUI()
end

-- 点击进阶
function TreasureView:onClickUpBtn( )
    if self._comStatus._tip then
        return
    end
    if self._comStatus._status == "active" then
        self:lock(-1)
        local comInfo = self._tModel:getComTreasureById(tostring(self._curComData.id))
        local preFightNum = comInfo and ((comInfo.comScore or 0)+(comInfo.disScore or 0)) or 0
        self._serverMgr:sendMsg("TreasureServer", "activationComTreasure", { comId = self._curComData.id }, true, { }, function(result)
            for k, v in pairs(self._activeMcs) do
                if v and not tolua.isnull(v) then
                    v:removeFromParent()
                end
            end
            self._activeMcs = { }
            local compx, compy = self._curComPic:getPositionX(), self._curComPic:getPositionY()
            -- for k, disTreasure in pairs(self._curDisTreasures) do
            --     local x, y = disTreasure:getPositionX(), disTreasure:getPositionY()
                -- local mc = mcMgr:createViewMC("jihuowupinguang_treasureactive", false, true)
                -- mc:setPosition(x, y)
                -- self._disPanel:addChild(mc, 999)

                -- local angle = math.atan2(compy - y, compx - x)
                -- local rotation = - angle * 180 / 3.14 + 180
                -- local mc2 = mcMgr:createViewMC("feixingguang_treasureactive", false, true)
                -- -- mc2:setName("anim")
                -- mc2:setPosition((compx + x) / 2,(compy + y) / 2)
                -- mc2:setRotation(rotation)
                -- self._disPanel:addChild(mc2, 999)
            -- end
            -- 未激活图片偏移
            ScheduleMgr:delayCall(300, self, function()
                local mcOffset= {
                    [12] = {x=-20,y=10,scale = 0.5},
                    [23] = {x=0,y=0,scale = 1},
                    [31] = {x=-30,y=0,scale = 1},
                    [41] = {x=0,y=0,scale = 1},
                    [43] = {x=-0,y=0,scale = 1},
                }

                local activeMcFileName = "baowuguang"
                local mcPreName = "pic_artifact_" .. self._curComData.id
                if self._curComData.id == 43 then
                    activeMcFileName = "treasurehanbingzhijian"
                elseif self._curComData.id == 33 then
                    activeMcFileName = "treasureyingyan"
                elseif self._curComData.id == 41 then
                    activeMcFileName = "treasuretianshilianmeng"
                    mcPreName = "tianshilianmengfaguang"
                end

                local mcName = mcPreName .. "_" .. activeMcFileName
                local mc = mcMgr:createViewMC(mcName, false, true)
                local mcOffx,mcOffy = 0,0
                local scale = 1
                if mcOffset[self._curComData.id] then
                    mcOffx,mcOffy = mcOffset[self._curComData.id].x,mcOffset[self._curComData.id].y
                    scale = mcOffset[self._curComData.id].scale
                end 
                mc:setScale(scale)
                mc:setPosition(0+mcOffx, 0+mcOffy)
                self._curComPic:addChild(mc, 999)
            end )
            ScheduleMgr:delayCall(500, self, function()
                audioMgr:playSound("openArtifact")
                self._viewMgr:showDialog("treasure.TreasureActiveView", { id = self._curComData.id,callback = function( )
                    if self and self:getUI("bg.layer") then
                        local comInfo = self._tModel:getComTreasureById(tostring(self._curComData.id))
                        local afterFightNum = comInfo and ((comInfo.comScore or 0)+(comInfo.disScore or 0)) or 0
                        TeamUtils:setFightAnim(self:getUI("bg.layer"),{x=400,y=480,oldFight = preFightNum,newFight=afterFightNum,})
                    end
                    self._modelMgr:getModel("GuildRedModel"):checkRandRed()
                end }, true)
                self:unlock()
            end )
        end )
    elseif self._comStatus._status == "promote" then
        self._viewMgr:showDialog("treasure.TreasureComUpView", { upType = "com", id = self._curComData.id, stage = self._curComInfo.stage or 0 }, true)
    end
end

-- 点击升星
function TreasureView:onClickStarBtn( )
    print("升星。。。。")
end

-- local stageColors = {
--     [2] = {cc.c3b(169, 252, 144),cc.c4b( 6, 189, 27, 255)},
--     [3] = {cc.c3b(191, 242, 255),cc.c4b(32, 154, 255, 255)},
--     [4] = {cc.c3b(232, 184, 255),cc.c4b(223, 92, 255, 255)},
--     [5] = {cc.c3b(255, 223, 159),cc.c4b(255, 174, 101, 255)},
-- }

-- 接收自定义消息
function TreasureView:reflashUI(data)
    local haveActivedTreasure = next(self._tModel:getData()) and true
    self._allAttrBtn:setVisible(haveActivedTreasure or false)
	if self._curComData == nil then return end
    self._curComInfo = self._tModel:getComTreasureById(tostring(self._curComData.id))
    
    -- 刷新宝物主体
    self:reflashTreasureInfo()

    -- 刷新组合宝物列表
    self:reflashComTList()
    -- 刷新技能图标
    self:reflashSkillIcon()
    -- 检查开启
    self:detectComOpen()
    -- 刷新散件状态
    self:reflashTShow()
    -- 刷新宝物描述
    self:refreshTreasureDes()
    -- 刷新加成总属性
    self:reflashAttrPanel()
    -- 刷新升级按钮状态
    self:reflashUpBtnStatus()
    --刷新分享按钮状态 wangyan
    self:reflashShareBtnStatus()
end

function TreasureView:reflashShareBtnStatus()
    if self._shareNode == nil then
        self._shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareTreasureModule"})
        self._shareNode:setPosition(600, 545)
        if MAX_SCREEN_WIDTH == 1136 then
            self._shareNode:setPosition(650, 545)
        end
        self._shareNode:setCascadeOpacityEnabled(true, true)
        self:getUI("bg.layer"):addChild(self._shareNode, 5)
    end

    self._shareNode:registerClick(function()
        return {moduleName = "ShareTreasureModule", treasureid = self._curComData.id}
        end)

    if self._curComInfo and self._curComInfo.stage > 0 then
        self._shareNode:setVisible(true)
    else
        self._shareNode:setVisible(false)
    end
end

--[[状态需求
1 可激活 可升阶 
----红按钮 特效
2 不可升阶  无特效
-- 材料够   散件等级不足 灰按钮
-- 材料不够 散件等级够   棕色按钮
--]]
function TreasureView:reflashUpBtnStatus()
    self._upBtn:removeAllChildren()
    local rtx = self._rightInfo:getChildByFullName("activeRtx")
    if rtx then
        rtx:removeFromParent()
    end
    if not self._curComInfo or self._curComInfo.stage == 0 then
        self._upBtn:setVisible(true)
        self._upBtn:setTitleText("激活")
        self._upBtn:loadTextures("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "", 1)
        self:L10N_Text(self._upBtn)
        self._upBtn._status = "active"
        local hadFixed = 0
        local disTNum = table.nums(self._curComData.form)
        if self._curComInfo then
            for k, v in pairs(self._curComInfo.treasureDev) do
                if v.s >= 1 then
                    hadFixed = hadFixed + 1
                end
            end
        end
        if hadFixed ~= disTNum or hadFixed == 0 then
            if hadFixed == 0 then
                rtx = RichTextFactory:create("[color = 8a5c1d,fontsize = 20]激活宝物可提升属性[-]",250,40) -- 激活散件宝物（" .. hadFixed .. "/" .. disTNum .. "）
                rtx:formatText()
                rtx:setVerticalSpace(7)
                rtx:setName("activeRtx")
                rtx:setPosition(cc.p(self._rightInfo:getContentSize().width/2,self._upBtn:getContentSize().height + 110))
                self._rightInfo:addChild(rtx)
                UIUtils:alignRichText(rtx)
            end

            self._upBtn._tip = lang("TIPS_ARTIFACT_03")
            -- self._upBtn:loadTextures("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "", 1)
            UIUtils:setGray(self._upBtn, true)
        else
            self._upBtn._tip = nil
            self._upBtn:setBright(true)
            self._upBtn:setSaturation(0)
            self._upBtn:setBrightness(0)
            -- self._upBtn:setEnabled(true)
            local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
            mc1:setName("anim")
            mc1:setScale(1,1.1)
            mc1:setPosition(70, 34)
            self._upBtn:addChild(mc1, 1)
            -- self._upBtn:loadTextures("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "", 1)
            UIUtils:setGray(self._upBtn, false)
        end
    else
        
        self._upBtn:setVisible(true)
        self._upBtn:setTitleText("进阶")
        self._upBtn:loadTextures("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "", 1)
        UIUtils:setGray(self._upBtn, false)
        self:L10N_Text(self._upBtn)

        self._upBtn._status = "promote"
        local hadFixed = 0
        local disTNum = table.nums(self._curComData.form)
        local comStage = self._curComInfo.stage or 0
        for k, v in pairs(self._curComInfo.treasureDev) do
            if v.s >= comStage + 1 then
                hadFixed = hadFixed + 1
            end
        end
        if hadFixed ~= disTNum then
            local rtx = self._upBtn:getChildByFullName("rtx")
            if rtx then
                rtx:removeFromParent()
            end
            local devComT = self._curComInfo.stage < maxComStage and tab:DevComTreasure(self._curComInfo.stage) or nil
            if devComT then
                -- rtx = RichTextFactory:create("[color = 3d1f00,fontSize = 20]需要:所有散件宝物+" .. comStage + 1 .. "[-]", 250, 40)
                -- -- [color = 53ff22,fontSize = 16,outlinecolor = 000000, outlinesize = 2]（" .. hadFixed .. "/" .. disTNum .. "）[-]"
                -- rtx:formatText()
                -- rtx:setVerticalSpace(7)
                -- rtx:setName("rtx")
                -- rtx:setPosition(cc.p(self._rightInfo:getContentSize().width / 2, self._upBtn:getContentSize().height - 70))
                -- self._rightInfo:addChild(rtx)
                -- UIUtils:alignRichText(rtx)
                -- self._upBtn._tip = "请先进阶宝物配件"--
                self._upBtn._tip = nil
            else
                self._upBtn._tip = lang("TIPS_ARTIFACT_04")
                self._upBtn:setVisible(false)
            end
            UIUtils:setGray(self._upBtn, true)
        else
            self._upBtn._tip = nil
            local canUp = true
            local devComT = self._curComInfo.stage < maxComStage and tab:DevComTreasure(self._curComInfo.stage) or nil
            if devComT then
                local materials = devComT["special" .. self._curComData.quality]
                for _, material in pairs(materials) do
                    local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(material[2])
                    if haveNum < self._tModel:getCurrentNum(material[2],material[3]) then
                        canUp = false
                        break
                    end
                end
            else
                canUp = false
            end
            if canUp then
                local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true, false)
                mc1:setName("anim")
                mc1:setScale(1,1.1)
                mc1:setPosition(70, 34)
                self._upBtn:addChild(mc1, 1)
            else
                self._upBtn:loadTextures("globalButtonUI13_3_1.png", "globalButtonUI13_3_1.png", "", 1)
                self:L10N_Text(self._upBtn)
            end
        end
    end
end

-- 未激活图片偏移
local picOffset= {
    [12] = {x=-10,y=0},
    [23] = {x=0,y=-10},
    [43] = {x=-10,y=-3},
    [33] = {x=0,y=10},
    [41] = {x=10,y=0},
}

function TreasureView:reflashTreasureInfo( )
    self._bgImg:loadTexture("asset/bg/treasureBg_".. self._curComData.quality ..".jpg")
    self._skillBg:loadTexture("skillBg_".. self._curComData.quality .."_treasure.png",1)
    self._comName:setString("")
    local stage = self._curComInfo and self._curComInfo.stage or 0
    if stage > 0 then
        UIUtils:createTreasureNameLab(self._curComData.id,stage,nil,self._comName)
    else
        UIUtils:createTreasureNameLab(self._curComData.id,nil,nil,self._comName)
    end
    if self._curComData.id == 33 then
        self._curComPic:setScale(1)
    else
        self._curComPic:setScale(0.8)
    end
    if self._curComPic:getChildByFullName("anim") then
        self._curComPic:getChildByFullName("anim"):removeFromParent()
    end
    local totalScore = self._modelMgr:getModel("TreasureModel"):getTreasureScore() or 0
    self._allScore:setString(totalScore)
    UIUtils:center2Widget(self._scoreDes,self._allScore,380)
    if self._infoBtn then
        self._infoBtn:setVisible(false)
    end
    if self._curComInfo then
        local curComScore = (self._curComInfo.disScore or 0) +(self._curComInfo.comScore or 0)
        self._fightLab:setString(curComScore)
        if self._infoBtn then
            self._infoBtn:setVisible(curComScore ~= 0)
        end
        if self._curComInfo.stage > 0 then
            local mc = mcMgr:createViewMC(TreasureConst.comMcs[self._curComData.id], true, false)
            mc:setName("anim")
            mc:setPlaySpeed(0.25)
            if comMcOffsetY then
                if type(comMcOffsetY[self._curComData.id]) == "number" then
                    mc:setPosition(0, comMcOffsetY[self._curComData.id])
                elseif type(comMcOffsetY[self._curComData.id]) == "table" then
                    mc:setPosition(comMcOffsetY[self._curComData.id][1], comMcOffsetY[self._curComData.id][2])
                end
            end
            self._curComPic:addChild(mc)
            local mc1 = mcMgr:createViewMC("baowufenweiguang_treasureui", true, false)
            mc1:setName("anim")
            mc1:setPosition(-150, -150)
            mc1:setHue(activeHue[self._curComData.quality])
            mc:addChild(mc1, -1)
            -- self:setProgressMc(100)
            if self._actSkillMc then
                self._actSkillMc:setVisible(true)
            end
            if self._skillColMc then
                self._skillColMc:setVisible(true)
            end
            -- self._comActBg:setVisible(true)
            self._upBtn:setVisible(self._curComInfo.stage < maxComStage)
            self:getUI("bg.rightInfo.iconMaxStage"):setVisible(self._curComInfo.stage >= maxComStage)
        else
            local picOffx,picOffy = 0,0 
            if picOffset[self._curComData.id] then
                picOffx,picOffy = picOffset[self._curComData.id].x,picOffset[self._curComData.id].y
            end 
            local pic = ccui.ImageView:create()
            -- pic:setPosition(0, 0)
            pic:setPosition(0+picOffx, 0+picOffy)
            print("artName...",self._curComData.art)
            pic:loadTexture(IconUtils.iconPath .. self._curComData.art .. ".png", 1)
            pic:setSaturation(-80)
            -- pic:setColor(cc.c4b(128, 128, 128, 255))
            if self._curComData.id == 41 then
                pic:setScale(0.95)
            else
                pic:setScale(1)
            end
            pic:setName("anim")
            local color = UIUtils.colorTable["ccUIBaseColor" .. self._curComData.quality]
            pic:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(2, 128, 128, 128), cc.TintTo:create(3, color.r,color.g,color.b))))
            self._curComPic:addChild(pic)
            if self._actSkillMc then
                self._actSkillMc:setVisible(false)
            end
            if self._skillColMc then
                self._skillColMc:setVisible(false)
            end
            -- self._comActBg:setVisible(false)
        end
    else
        local picOffx,picOffy = 0,0 
        if picOffset[self._curComData.id] then
            picOffx,picOffy = picOffset[self._curComData.id].x,picOffset[self._curComData.id].y
        end 
        local pic = ccui.ImageView:create()
        pic:setPosition(0+picOffx, 0+picOffy)
        pic:loadTexture(IconUtils.iconPath .. self._curComData.art .. ".png", 1)
        pic:setSaturation(-80)
        -- pic:setColor(cc.c4b(128, 128, 128, 255))
        pic:setName("anim")
        local color = UIUtils.colorTable["ccUIBaseColor" .. self._curComData.quality]
        pic:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(2, 128, 128, 128), cc.TintTo:create(3, color.r,color.g,color.b))))
        self._curComPic:addChild(pic)
        self._fightLab:setString(0)
        if self._actSkillMc then
            self._actSkillMc:setVisible(false)
        end
        if self._skillColMc then
            self._skillColMc:setVisible(false)
        end
        -- self._comActBg:setVisible(false)
    end
    UIUtils:alignNodesToPos({self._fightDes,self._fightLab,self._infoBtn},155,7)
end

-- 刷新技能描述
function TreasureView:refreshTreasureDes( )
    if not self._skillDesPanel then self._skillDesPanel = self:getUI("bg.rightInfo.skillDesPanel") end
    local rtx = self._skillDesPanel:getChildByFullName("skillDes")
    if rtx then rtx:removeFromParent() end
    local stage = self._curComInfo and self._curComInfo.stage or 0
    local skillDes = self:generateDes(math.max(stage,1))
    -- print("skillDes,,,,,",skillDes)
    rtx = RichTextFactory:create("[color = 8a5c1d,fontsize=16]" .. skillDes ..  "[-]", 180, 100)
    -- rtx:setVerticalSpace(-2)
    rtx:formatText()
    rtx:setName("skillDes")
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    -- local realW,realH = rtx:getRealSize().width,rtx:getRealSize().height
    -- print("···",h,realH)
    rtx:setPosition(w/2, 50)
    self._skillDesPanel:addChild(rtx, 99)
    if stage == 0 then UIUtils:setGray(rtx,true) end
    UIUtils:alignRichText(rtx, { hAlign = "center"})
end

-- 初始化常态的mc动画
function TreasureView:initDecMcs( )

    if not self._comUpMc then
        local mc = mcMgr:createViewMC("jinjie_treasureui", true, false,function( _,sender )
            -- sender:gotoAndPlay(20)
        end)
        mc:setScale(0.9)
        mc:setPosition(335,170)

        self._disPanel:addChild(mc,99)
        self._comUpMc = mc
    end

end

-- 圆圈进度特效
function TreasureView:setProgressMc( percent )
    if true then return end
    if not self._proMc then
        local clipNode = cc.ClippingNode:create()
        clipNode:setPosition(330,320)
        clipNode:setContentSize({width=418, height=418})
        local mask = cc.Sprite:createWithSpriteFrameName("mask_progress_treasure.png")
        mask:getTexture():setAntiAliasTexParameters()
        mask:setAnchorPoint(0.5,0)
        mask:setPositionY(-235)
        mask:setScale(0.93)
        -- mask:setRotation(90)
        clipNode:setStencil(mask)
        clipNode:setAlphaThreshold(0.05)
        self._proMask = mask
        local mc = mcMgr:createViewMC("huanxingliudong_treasureui", true,false)
        clipNode:addChild(mc)
        self._disPanel:addChild(clipNode,-1)
        self._proMc = clipNode
    end

    local sfc = cc.SpriteFrameCache:getInstance()
    local spriteFrame = sfc:getSpriteFrameByName("mask_progress_treasure.png")
    local rect = spriteFrame:getRect()
    local isRotated = spriteFrame:isRotated()
    local widthO,heightO = rect.width,rect.height
    local width,height = rect.width,rect.height
    if isRotated then
        width = width*percent*0.01
    else
        height = height*percent*0.01
    end
    self._proMask:setTextureRect(cc.rect(rect.x,rect.y+heightO-height,width,height))
end

-- 刷新散件
function TreasureView:reflashTShow()
    self._curComInfo = self._tModel:getComTreasureById(tostring(self._curComData.id))
    local allFixed = true
    local fixedNum = 0
    for i, v in ipairs(self._curDisTreasures) do
        v:removeAllChildren()
        v._posId = i
        v._disId = self._curComData.form[i]
        v._comId = self._curComData.id

        v._fixed = false
        local stage = self._curComInfo and self._curComInfo.treasureDev[tostring(v._disId)] and self._curComInfo.treasureDev[tostring(v._disId)].s
        if stage and stage == 0 then
        	stage = nil
        end
        v._icon = IconUtils:createItemIconById( { itemId = v._disId, eventStyle = 0, stage = stage, effect = true, showStar = true })
        v._icon:setScale(0.75)
        v._icon:setPosition(40,40)
        v:addChild(v._icon)
        v._tip = nil
        -- end
        v._icon:setSaturation(-180)
        -- v._icon:setVisible(false)
        if self._curComInfo then
            local dev = self._curComInfo.treasureDev
            v._stage = dev[tostring(v._disId)] and dev[tostring(v._disId)].s
            -- IconUtils:updateItemIconByView(v._icon,{itemId = v._disId,eventStyle = 0,num = "+" .. v._stage})
            if dev[tostring(v._disId)].s >= 1 then
                v._icon:setSaturation(0)
                v._fixed = true
                fixedNum = fixedNum + 1
                v._icon:setVisible(true)
                -- if tab:DisTreasure(v._disId).splight == 1 then
                --     local mc = mcMgr:createViewMC("zujiantexiao_zujian", true, false, function() end )
                --     mc:setName("anim")
                --     mc:setScale(.75)
                --     mc:setPosition(v._icon:getContentSize().width / 2+20, v._icon:getContentSize().height / 2+20)
                --     v:addChild(mc, 99)
                -- end

                local canUp = true
                local devDisT = v._stage < maxDisStage and tab:DevDisTreasure(v._stage) or nil
                if devDisT then
                    local materials = devDisT["mater" .. tab:DisTreasure(v._disId).quality]
                    -- for _,material in pairs(materials) do
                    local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(materials[2])
                    if haveNum < self._tModel:getCurrentNum(materials[2],materials[3]) then
                        canUp = false
                    end
                    -- end
                    local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(v._disId)
                    if haveNum < devDisT.treasureNum then
                        canUp = false
                    end
                else
                    canUp = false
                end 

                if canUp then
                    -- and (self._curComInfo.stage+1) > v._stage

                    local arrowUp = cc.Sprite:createWithSpriteFrameName("globalImageUI5_upArrow.png")
                    arrowUp:setPosition(v._icon:getContentSize().width - 0, 55)
                    arrowUp:stopAllActions()
                    arrowUp:setScale(1)
                    v:addChild(arrowUp, 110)
                    local moveUp = cc.MoveBy:create(0.5, cc.p(0, 3))
                    local moveDown = cc.MoveBy:create(0.5, cc.p(0, -3))
                    local seq = cc.Sequence:create(moveUp, moveDown)
                    local repeateMove = cc.RepeatForever:create(seq)
                    arrowUp:runAction(repeateMove)
                end
            else
                local _, hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(v._disId)
                if hadNum >= 1 then
                    local mc = mcMgr:createViewMC("wupinguang_itemeffectcollection", true, false, function()
                    end )
                    mc:setName("anim")
                    mc:setScale(0.75)
                    mc:setPosition(v._icon:getContentSize().width / 2+29, v._icon:getContentSize().height / 2+29)
                    v:addChild(mc, 99)

                    local pic = ccui.ImageView:create()
                    pic:setPosition(v._icon:getContentSize().width / 2+28, v._icon:getContentSize().height / 2+29)
                    pic:loadTexture("golbalIamgeUI5_add.png", 1)
                    pic:setScale(0.5)
                    pic:setName("addPic")
                    pic:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(2, 150), cc.FadeTo:create(3, 200))))
                    v:addChild(pic, 999)
                end

            end
            -- local iconFrame = v._icon:getChildByFullName("iconColor")
            -- iconFrame:setSaturation(0)
        else
            -- if self._comTreasures[tonumber(v._comId)]._isOpen then
            local _, hadNum = self._modelMgr:getModel("ItemModel"):getItemsById(v._disId)
            if hadNum >= 1 then
                local mc = mcMgr:createViewMC("wupinguang_itemeffectcollection", true, false, function()
                end )
                mc:setName("anim")
                mc:setScale(0.75)
                mc:setPosition(v._icon:getContentSize().width / 2+29, v._icon:getContentSize().height / 2+29)
                v:addChild(mc, 99)

                local pic = ccui.ImageView:create()
                pic:setPosition(v._icon:getContentSize().width / 2+28, v._icon:getContentSize().height / 2+29)
                pic:loadTexture("golbalIamgeUI5_add.png", 1)
                pic:setScale(0.5)
                pic:setName("addPic")
                pic:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(2, 150), cc.FadeTo:create(3, 255))))
                v:addChild(pic, 999)
            end
        end
        -- end
        allFixed = allFixed and v._fixed
    end

    -- jia特效
    if self._activeMcs then 
	    for k, v in pairs(self._activeMcs) do
	        if v and not tolua.isnull(v) then
	            v:removeFromParent()
	        end
	    end
	end
    -- [[
    local allNum  = #self._curDisTreasures
    -- local percent = fixedNum/allNum*100
    -- if allNum == 6 then
    --     if fixedNum == 1 then
    --         percent = 10
    --     elseif fixedNum == 5 then
    --         percent = 95
    --     end
    -- end

    -- self:setProgressMc(percent)
    --]]
    self._activeMcs = { }
    if allFixed and self._curComInfo and self._curComInfo.stage == 0 then
        -- local mc = mcMgr:createViewMC("changtaizhongxinguang_treasureactive", true, false)
        -- -- mc:setName("anim")
        -- mc:setPosition(0, 0)
        -- self._curComPic:addChild(mc, 999)
        -- table.insert(self._activeMcs, mc)
        local animPic = self._curComPic:getChildByFullName("anim")
        if animPic then
            local outlineSp = ccui.ImageView:create()
            outlineSp:setPosition(0, 0)
            outlineSp:loadTexture(IconUtils.iconPath .. "pic_out_".. self._curComData.id .. ".png", 1)
            self._curComPic:addChild(outlineSp,-1)
            local color = UIUtils.colorTable["ccUIBaseColor" .. self._curComData.quality]
            -- outlineSp:setPurityColor(color.r,color.g,color.b)
            outlineSp:setScale(2)
            outlineSp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(2, 0), cc.FadeTo:create(3, 180))))
            table.insert(self._activeMcs, outlineSp)
        end 
        local compx, compy = self._curComPic:getPositionX(), self._curComPic:getPositionY()
        for k, disTreasure in pairs(self._curDisTreasures) do
            local x, y = disTreasure:getPositionX(), disTreasure:getPositionY()
            local angle = math.atan2(compy - y, compx - x)
            local rotation = -angle * 180 / 3.14-90
            local mc = mcMgr:createViewMC("lianxian_treasureui", true, false)
            -- mc:setName("anim")
            -- mc:setPosition((compx + x) / 2,(compy + y) / 2)
            -- mc:setPosition((compx ) / 2,(compy ) / 2)
            mc:setPosition(x ,y )
            mc:setRotation(rotation)
            -- mc:setScale(0.5)
            local color = UIUtils.colorTable["ccUIBaseColor" .. self._curComData.quality]
            mc:setColor(color)
            self._disPanel:addChild(mc, 9)
            table.insert(self._activeMcs, mc)
            mc:setHue(activeHue[self._curComData.quality])
            mc:setBrightness(40)
            
            -- break
        end
        local kejihuoMc = mcMgr:createViewMC("kejihuo_treasureui", true, false)
        kejihuoMc:setPosition(340,180)
        self._disPanel:addChild(kejihuoMc,10)
        table.insert(self._activeMcs, kejihuoMc)
    end
end

-- 刷新组合宝物
function TreasureView:reflashComTList()
    for k, v in pairs(self._comTreasures) do
        local comInfo = self._tModel:getComTreasureById(tostring(v._data.id)) or {}
        local isOpen = false
        local openTab = v._data.condition
        local openType = openTab[1]
        if openType == 1 then
            isOpen = self._modelMgr:getModel("UserModel"):getData().lvl >= openTab[2]
        elseif openType == 2 or openType == 3 then
            local stageInfo
            if openType == 2 then
                stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(openTab[2])
            elseif openType == 3 then
                stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(openTab[2])
            end
            isOpen = stageInfo.isOpen
            -- dump(stageInfo)
        end
        -- end
        local isGray =(not comInfo.stage or comInfo.stage == 0)
        self:updateTreasureIconByView(v, { id = v._data.id, treasureData = v._data, stage = comInfo.stage or -1, isGray = isGray })
        self:reCalculatePos(v)
        -- print("isOpen",isOpen,"isGray",isGray)
        -- v._isOpen = nil
        -- end
    end
    if self._curOffset then
        self._scrollView:getInnerContainer():setPositionY(self._curOffset)
        self._curOffset = nil
    end
    self._comTNum = table.nums(self._comTreasures)
    self:updateArrows()
end

-- 
function TreasureView:updateArrows( )
    local comTNum = self._comTNum or table.nums(self._comTreasures)
    if comTNum > 4 then
        local offsety = self._scrollView:getInnerContainer():getPositionY()
        local scrollH = self._scrollView:getInnerContainerSize().height
        local scrollVisibleH = self._scrollView:getContentSize().height

       -- print("offsetx  ============" , offsety)
        if self._downArrow then  --_upArrow
            if  offsety > -(scrollH - scrollVisibleH) then
                self._downArrow:setVisible(true)
            else
                self._downArrow:setVisible(false)
            end
        end
        if self._upArrow then
            if offsety < 0  then
                self._upArrow:setVisible(true)
            else
                self._upArrow:setVisible(false)
            end
        end
    else
        if self._upArrow then
            self._upArrow:setVisible(false)
        end
        if self._downArrow then
            self._downArrow:setVisible(false)
        end
    end
end

-- 创建组合宝物icon
function TreasureView:createTreasureIcon(id, data, isGray)
    local widget = ccui.Widget:create()
    -- local icon = ccui.ImageView:create()
    -- icon:loadTexture("globalImageUI4_squality" ..(data.quality or 2) .. ".png", 1)
    -- icon:setName("icon")
    -- icon:setAnchorPoint(0, 0)
    -- local iconW, iconH = icon:getContentSize().width, icon:getContentSize().height
    -- widget:addChild(icon)
    local iconBg = ccui.ImageView:create()
    iconBg:setAnchorPoint(0, 0)
    iconBg:setName("iconBg")
    iconBg:loadTexture("buttonBg_" .. data.quality .. "_treasure.png", 1)
    local iconW, iconH = iconBg:getContentSize().width, iconBg:getContentSize().height
    iconBg:ignoreContentAdaptWithSize(false)
    iconBg:setContentSize({width=iconW, height=iconH})
    widget:addChild(iconBg, -1)
    iconBg:setPosition((iconW - iconBg:getContentSize().width) / 2,(iconH - iconBg:getContentSize().height) / 2)
    widget:setContentSize({width=iconW, height=iconH})
    widget:setAnchorPoint(0, 0)
    local lock = ccui.ImageView:create()
    lock:setAnchorPoint(.5, .5)
    lock:setName("lock")
    lock:loadTexture("globalImageUI5_treasureLock.png", 1)
    lock:ignoreContentAdaptWithSize(false)
    lock:setContentSize({width=49, height=57})
    widget:addChild(lock, 10)
    lock:setPosition((iconW ) / 2,(iconH ) / 2)
    lock:setScale(0.7)
    local iconImage = ccui.ImageView:create()
    local filename = data.icon .. ".png"
    -- print("fileName...",filename)
    -- "asset/icon/" ..
    iconImage:loadTexture(filename, 1)
    iconImage:setAnchorPoint(0, 0)
    iconImage:setName("image")
    iconBg:addChild(iconImage)
    local scale = .7
    iconImage:setScale(scale)
    iconImage:setPosition((iconW - iconImage:getContentSize().width * scale) / 2,(iconH - iconImage:getContentSize().height * scale) / 2)

    local runeLab =  ccui.Text:create()
    runeLab:setString("")
    runeLab:setName("runeLab")
    runeLab:setFontSize(22)
    runeLab:setColor(UIUtils.colorTable.ccUIBaseColor1)
    -- runeLab:disableEffect()
    runeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    runeLab:setAnchorPoint(.5, 1)
    runeLab:setPosition(18, widget:getContentSize().height - 4)
    runeLab:setFontName(UIUtils.ttfName)
    widget:addChild(runeLab,9)

    local runeBg = ccui.ImageView:create()
    runeBg:loadTexture("globalImageUI4_iquality" .. (data.quality or 2) .. ".png", 1)
    -- runeBg:loadTexture("globalImageUI_fuwennumbg.png",1)
    runeBg:setAnchorPoint(0, 1)
    runeBg:setPosition(3, widget:getContentSize().height - 3)
    runeBg:setName("runeBg")
    runeBg:setVisible(false)
    widget:addChild(runeBg,8)

    -- iconColor:setVisible(false)
    -- local treasureCorner = ccui.ImageView:create()
    -- treasureCorner:loadTexture("globalImageUI_treasureIcon" .. (data.quality or 2) ..".png",1)
    -- treasureCorner:setName("treasureCorner")
    -- treasureCorner:setPosition(widget:getContentSize().width/2+0.5, widget:getContentSize().height/2)
    -- treasureCorner:setScale(0.9)
    -- widget:addChild(treasureCorner,7)

    local isGray = isGray
    if isGray then
        -- iconImage:setSaturation(-180)
        iconBg:setColor(cc.c4b(128, 128, 128, 255))
        iconBg:setBrightness(-50)
        -- treasureCorner:setColor(cc.c4b(128, 128, 128, 255))
        -- treasureCorner:setBrightness(-50)
        lock:setVisible(true)
    else
        -- iconImage:setSaturation(0)
        iconBg:setColor(cc.c4b(255, 255, 255, 255))
        iconBg:setBrightness(0)
        -- treasureCorner:setColor(cc.c4b(255, 255, 255, 255))
        -- treasureCorner:setBrightness(0)
        lock:setVisible(false)
    end

    return widget
end

-- 更新宝物ICON
function TreasureView:updateTreasureIconByView(node, data)
    local icon = node:getChildByFullName("iconBg")
    local isGray = data.isGray
    local iconImage = icon:getChildByFullName("image")
    local lock = node:getChildByFullName("lock")
    -- local treasureCorner = node:getChildByFullName("treasureCorner")
    if isGray then
        -- iconImage:setSaturation(-180)
        icon:setColor(cc.c4b(128, 128, 128, 255))
        icon:setBrightness(-50)
        -- treasureCorner:setColor(cc.c4b(128, 128, 128, 255))
        -- treasureCorner:setBrightness(-50)
        lock:setVisible(true)
    else
        -- iconImage:setSaturation(0)
        icon:setColor(cc.c4b(255, 255, 255, 255))
        icon:setBrightness(0)
        -- treasureCorner:setColor(cc.c4b(255, 255, 255, 255))
        -- treasureCorner:setBrightness(0)
        lock:setVisible(false)
    end

    local runeLab = node:getChildByFullName("runeLab")
    local runeBg = node:getChildByFullName("runeBg")
    runeLab:setVisible(data.stage > 0)
    runeBg:setVisible(data.stage > 0)        
    runeLab:setString("+" .. (data.stage or ""))
    runeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local dot = node:getChildByFullName("noticeTip")
    local haveNotice = self._modelMgr:getModel("TreasureModel"):isComTreasureCanDo(data.id)
    if haveNotice then
        if not dot or tolua.isnull(dot) then
            dot = ccui.ImageView:create()
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setPosition(icon:getContentSize().width - dot:getContentSize().width / 2, icon:getContentSize().height - dot:getContentSize().width / 2)
            dot:setName("noticeTip")
            node:addChild(dot,15)
        else
            dot:setVisible(true)
        end
    else
        if dot and not tolua.isnull(dot) then
            dot:setVisible(false)
        end
    end
end

-- 更新技能
function TreasureView:reflashSkillIcon( )
	local skillId = self._curComData.skill
    local skillD = { }
    for k, v in pairs(self._skillTabMap) do
        if v[skillId] and(v[skillId].art or v[skillId].icon) then
            skillD = clone(v[skillId])
            break
        end
    end

    self._skillName:setString(lang(skillD.name))
    local fu = cc.FileUtils:getInstance()
    local art = skillD.art or skillD.icon
    -- print("art.......", skillId, art)
    if art == nil then
        dump(skillD,skillId)
    end
    if fu:isFileExist(IconUtils.iconPath .. art .. ".jpg") then
        self._skillImg:loadTexture(IconUtils.iconPath .. art .. ".jpg", 1)
    else
        self._skillImg:loadTexture(IconUtils.iconPath .. art .. ".png", 1)
    end
    self._skillImg:setScale(70 / self._skillImg:getContentSize().width)
end

-- 判断是组合宝物状态
function TreasureView:detectComOpen()
	local id       = self._curComData.id
	local isOpen   = false
    local openTab  = self._curComData.condition
    local openType = openTab[1]
    local openStr  = openConditions[openType]
    if openType == 1 then
        openStr = string.gsub(openStr, "%b{}", function(catchStr)
            return openTab[2]
        end )
        isOpen = self._modelMgr:getModel("UserModel"):getData().lvl >= openTab[2]
    elseif openType == 2 or openType == 3 then
        openStr = string.gsub(openStr, "%b{}", function(catchStr)
            return lang(tab:MainStage(openTab[2]).title)
        end )
        openStr = string.gsub(openStr, " ", "")
        local stageInfo
        if openType == 2 then
            stageInfo = self._modelMgr:getModel("IntanceModel"):getStageInfo(openTab[2])
        elseif openType == 3 then
            stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(openTab[2])
        end
        isOpen = stageInfo.isOpen
    end
    self._comTreasures[tonumber(id)]._isOpen = isOpen
    if self._comUpMc then
        self._comUpMc:setVisible(false)
    end
    if not self._curComInfo or self._curComInfo.stage == 0 then
        self._comStatus._status = "active"
        local hadFixed = 0
        local disTNum = table.nums(self._curComData.form)
        if self._curComInfo then
            for k, v in pairs(self._curComInfo.treasureDev) do
                if v.s >= 1 then
                    hadFixed = hadFixed + 1
                end
            end
        end
        if hadFixed ~= disTNum or hadFixed == 0 then
            self._comStatus._tip = lang("TIPS_ARTIFACT_03")
        else
            self._comStatus._tip = nil
        end

        self._skillImg:setSaturation(-180)
        if self._comUpMc then
            self._comUpMc:setVisible(false)
        end
    else
        self._skillImg:setSaturation(0)

        self._comStatus._status = "promote"

        local hadFixed = 0
        local disTNum = table.nums(self._curComData.form)
        local comName = self._curComInfo.stage or 0
        for k, v in pairs(self._curComInfo.treasureDev) do
            if v.s >= comName + 1 then
                hadFixed = hadFixed + 1
            end
        end
        if hadFixed ~= disTNum then
            local devComT = self._curComInfo.stage <= maxComStage and tab:DevComTreasure(self._curComInfo.stage) or nil
            if devComT then
               self._comStatus._tip = nil
            else
                -- self._comStatus._tip = lang("TIPS_ARTIFACT_04") -- 最高阶不拦截弹窗
                self._comStatus._tip = nil
            end
        else
            self._comStatus._tip = nil

            local canUp = true
            local devComT = self._curComInfo.stage < maxComStage and tab:DevComTreasure(self._curComInfo.stage) or nil
            if devComT then
                local materials = devComT["special" .. self._curComData.quality]
                for _, material in pairs(materials) do
                    local _, haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(material[2])
                    if haveNum < self._tModel:getCurrentNum(material[2],material[3]) then
                        canUp = false
                        break
                    end
                end
            else
                canUp = false
            end
            if self._comUpMc then
                self._comUpMc:setVisible(canUp)
            end
        end
    end

   
end

-- 从新计算位置
function TreasureView:reCalculatePos( comIcon )
    -- if true then return end
	local x,y = comIcon:getPositionX(),comIcon:getPositionY()
	local pos = comIcon:getParent():convertToWorldSpace(cc.p(x,y))
    local radius = 600
    local offsetX = -25
    -- if MAX_SCREEN_WIDTH == 960 then
    --     radius = 600
    --     offsetX = -25
    --     -- self._scrollBg:setPositionX(130)
    -- elseif MAX_SCREEN_WIDTH == 1136 then
    --     radius = 600
    --     offsetX = -10
    --     -- self._scrollBg:setPositionX(110)
    -- end
	local x = self:getPosX(radius, pos.y, {x=radius+offsetX,y=280})
	if x ~= "nan" then
		comIcon:setPositionX(math.min(x,150))
	end
end

-- 组合宝物滚动事件回调
function TreasureView:onComScrolling( )
	for k,comIcon in pairs(self._comTreasures) do
		self:reCalculatePos( comIcon )
	end
    self:updateArrows()
end

-- 圆形轨道坐标X
-- @param r:圆形半径
-- @param posY:对应最表Y
-- @param posC:圆心坐标
function TreasureView:getPosX(r, posY, posC)
    local y = posY
    local cX = posC.x
    local cY = posC.y
    return r * 2 - (math.sqrt(math.pow(r,2) - math.pow((y - cY), 2)) + cX)
end

-- 技能描述
function TreasureView:generateDes( stage )
    local skillDes
    local skillId = self._curComData.addattr[1][2]
    local skillD = { }
    for k, v in pairs(self._skillTabMap) do
        if v[skillId] and(v[skillId].art or v[skillId].icon) then
            skillD = clone(v[skillId])
            break
        end
    end
    stage = stage or 1
    -- if self._curComInfo then stage = self._curComInfo.stage end
    local maxComStage = table.nums(tab.devComTreasure) + 1
    local tipDataD = GlobalTipView["getDataDForTipType2"](GlobalTipView,
    { tipType = 2, node = desBg, id = skillD.id,comId = self._curComData.id, skillType = self._curComData.addattr[1][1], skillLevel = math.min(stage, maxComStage) })
    skillDes = GlobalTipView._des
    skillDes = string.gsub(skillDes, "fontsize=16", "fontsize=16") -- 
    skillDes = string.gsub(skillDes, "fontsize=17", "fontsize=16") -- 
    skillDes = string.gsub(skillDes, "fontsize=18", "fontsize=16") -- 
    skillDes = string.gsub(skillDes, "fontsize=20", "fontsize=16") -- 
    skillDes = string.gsub(skillDes, "fontsize=24", "fontsize=16") -- 
    skillDes = string.gsub(skillDes, "color=3d1f00", "color=fae0bc")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0a00", "")
    skillDes = string.gsub(skillDes, "outlinecolor=3c1e0aff", "")
    skillDes = string.gsub(skillDes, "outlinesize=1", "")
    skillDes = string.gsub(skillDes, "outlinesize=2", "")

    GlobalTipView._des = nil
    return skillDes
end

-- 加的属性
function TreasureView:reflashAttrPanel( id, stage)
    id = self._curComData.id 
    stage = 1
    if self._curComInfo and self._curComInfo.stage then
        stage = self._curComInfo.stage
    end
    -- print("id,stage",id,stage)
    local atts    = self:generateAtts(id)
    self._attrPanel:removeAllChildren()
    -- self._attrPanel:setContentSize(cc.size(285,#atts/2*40))
    local height  = self._attrPanel:getContentSize().height
    local lineHeight = 30
    local x, y = 0, 1
    local offsetx, offsety = 0, -30
    local lineCol = 0
    local lineNum = 0
    local linesInfo = {}
    for i, att in ipairs(atts) do
        local desName = ccui.Text:create()
        desName:setAnchorPoint(cc.p(0, 0.5))
        desName:setFontSize(20)
        desName:setFontName(UIUtils.ttfName)
        desName:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
        local attName = lang("ARTIFACTDES_PRO_" .. att.attId)
        if not attName then
            attName = lang("ATTR_" .. att.attId)
        end
        if attName then
            attName = string.gsub(attName, "　", "")
            attName = string.gsub(attName, " ", "")
        end
        desName:setString(attName)
        x = ((i-1)%2) * 140 + offsetx
        y = height - math.floor((i-1)/2) * lineHeight + offsety
        lineCol = lineCol + 1

        desName:setPosition(cc.p(x, y))
        local attNum = ccui.Text:create()
        attNum:setFontSize(20)
        attNum:setFontName(UIUtils.ttfName)
        attNum:setAnchorPoint(cc.p(0, 0.5))
        local tail = ""
        if att.attId == 2 or att.attId == 5 or att.attId == 131 then
            tail = "%"
        end
        if self._curComInfo and tonumber(att.attNum) then
            attNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
            local value =(att.attNum or 0)
            if value < 1 then
                value = tonumber(string.format("%.2f", value))
            elseif value < 100 then
                value = tonumber(string.format("%.1f", value))
            else
                value = math.ceil(value)
            end
            attNum:setString(value .. tail)
        else
            attNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            attNum:disableEffect()
            attNum:setString("--")
        end
        attNum:setPosition(cc.p(x + desName:getContentSize().width + 2, y))
        self._attrPanel:addChild(attNum)
        self._attrPanel:addChild(desName)

        -- 计算偏移
        local lineNum = math.floor((i-1)/2)+1
        if not linesInfo[lineNum] then
            linesInfo[lineNum] = {}
            linesInfo[lineNum].beginX = desName:getPositionX()
            linesInfo[lineNum].endX = attNum:getPositionX()+attNum:getContentSize().width
            linesInfo[lineNum].width = linesInfo[lineNum].endX - linesInfo[lineNum].beginX
        else
            linesInfo[lineNum].endX = attNum:getPositionX()+attNum:getContentSize().width
            linesInfo[lineNum].width = linesInfo[lineNum].endX - linesInfo[lineNum].beginX
        end
    end
    local lineWidthMax = 0
    for k,v in pairs(linesInfo) do
        if v.width > lineWidthMax then
            lineWidthMax = v.width
        end
    end
    local offsetx = (self._attrPanel:getContentSize().width-lineWidthMax)/2
    local children = self._attrPanel:getChildren()
    for k,v in pairs(children) do
        v:setPosition(v:getPositionX()+offsetx,v:getPositionY())
    end
    self._attrPanel:setVisible(true)
end

function TreasureView:generateAtts(id)
    -- if not self._Atts[id] then
    local Atts = { }
    local stage = 0
    local form = self._curComData.form
    local disStages = { }
    -- if self._curComInfo then
    disStages = self._curComInfo and self._curComInfo.treasureDev or { }
    for k, v in pairs(form) do
        local disTreasure = tab:DisTreasure(v)
        for k, property in pairs(disTreasure["property"]) do
            if (disStages[tostring(v)] and disStages[tostring(v)].s > 0) or self._propertyNone then
                local attId = property[1]
                if not Atts[attId] then
                    Atts[attId] = { }
                end
                local disStage = disStages[tostring(v)] and disStages[tostring(v)].s or 0
                Atts[attId].attId = attId
                local preAttNum = tonumber(Atts[attId].attNum) or 0
                local curAttNum = 0
                if self._curComInfo and self._curComInfo.treasureDev
                    and self._curComInfo.treasureDev[tostring(v)].s > 0 then
                    curAttNum = property[2] + math.max(disStage - 1, 0) * property[3]
                    -- 加升星加成
                    local starBuff = 1 + self._modelMgr:getModel("TreasureModel"):caculateStarAttr(v)
                    curAttNum = curAttNum * starBuff
                end
                Atts[attId].attNum = preAttNum + curAttNum
                -- (tonumber(Atts[attId].attNum) or (self._curComInfo and self._curComInfo.treasureDev and tonumber(self._curComInfo.treasureDev[tostring(v)]) > 0))
                -- and ((tonumber(Atts[attId].attNum) or 0)+property[2]+math.max(disStage-1,0)*property[3]) or "--"
            end
        end
    end
    -- end
    self._Atts[id] = { }
    for k, v in pairs(Atts) do
        if v.attNum == 0 then
            v.attNum = "--"
        end
        table.insert(self._Atts[id], v)
    end
    if #self._Atts[id] > 1 then
        table.sort(self._Atts[id], function(a, b)
            return a.attId > b.attId
        end )
    end
    -- end
    return self._Atts[id]
end

function TreasureView:onShow( )
    -- 只判断分解按钮开没开
    local isOpen,_,openLevel = SystemUtils["enableTreasureFenjie"]()
    local isFenjieOpened = self._tModel:isFenjieOpened()
    if isOpen and not isFenjieOpened then
        self._breakBtn:setEnabled(false)
        SystemUtils.saveAccountLocalData("fenjieBtnIsOpen", 1)
        self:showBreakBtnEnableAnim()
    end 
end

function TreasureView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function TreasureView:onTop()
    self._viewMgr:enableScreenWidthBar()
end
function TreasureView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function TreasureView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    TreasureView.super.onDestroy(self)
end

-- 新增逻辑 分解按钮解锁动画
function TreasureView:showBreakBtnEnableAnim( )
    local bgNode = self:getLayerNode()
    local bgLayer 
    -- if breakBg then
        bgLayer = ccui.Layout:create()
        bgLayer:setName("bgLayer")
        bgLayer:setBackGroundColorOpacity(180)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        bgNode:addChild(bgLayer, 1)
    -- else
        -- bgLayer = ccui.Layout:create()
        -- bgLayer:setName("bgLayer")
        -- bgLayer:setBackGroundColorOpacity(0)
        -- bgLayer:setBackGroundColorType(1)
        -- bgLayer:setTouchEnabled(true)
        -- bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        -- bgNode:addChild(bgLayer, 3)
        -- local bgLayer = bgNode
    -- end
    local mc = mcMgr:createViewMC("diguang_lianmengjihuo", false, true, function (_, sender)

    end, RGBA8888)  
    mc:setScale(2)       
    mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(mc, 2)
    local mc1 = mcMgr:createViewMC("jihuoshuxingguang_lianmengjihuo", false, true, function (_, sender) 

    end, RGBA8888)  
    mc1:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(mc1,5)

    local label = cc.Label:createWithTTF(lang("OPEN_SYSTEM_NEW"), UIUtils.ttfName_Title, 40)
    label:setColor(cc.c3b(255, 254, 216))
    label:enable2Color(1, cc.c4b(255, 253, 123, 255))
    label:enableOutline(cc.c4b(60, 30, 10, 255), 2)
    label:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 + 100)
    bgNode:addChild(label, 2)
    label:setScale(2.0)
    label:runAction(cc.Sequence:create(cc.ScaleTo:create(0.25, 0.9), cc.CallFunc:create(function()
        -- label:setPurityColor(255, 255, 255)
    end), cc.ScaleTo:create(0.05, 1.0), cc.DelayTime:create(1.4), cc.FadeOut:create(0.1), cc.CallFunc:create(function()
        label:removeFromParent()
    end)))

    local icon = cc.Sprite:createWithSpriteFrameName("btnFenJie_treasure.png")
    icon:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    bgNode:addChild(icon, 2)
    icon:setScale(0)
    
    print("·systemopen====··", systemopen)
    local btn = self._breakBtn
    local scale = btn:getScale()

    local bgNodePos = btn:convertToWorldSpace(cc.p(0, 0)) 
    local iconPos = icon:convertToWorldSpace(cc.p(0, 0))
    -- local disicon = cc.pGetDistance(cc.p(bgNodePos.x, bgNodePos.y),cc.p(iconPos.x,iconPos.y))
    local offsetX = (MAX_SCREEN_WIDTH-960)/2
    local offsetY = (MAX_SCREEN_HEIGHT-640)/2
    local posX = bgNodePos.x - iconPos.x + btn:getContentSize().width*0.5*btn:getScaleX() + offsetX--+  165 --systemDes.position[1]
    local posY = bgNodePos.y - iconPos.y + btn:getContentSize().height*0.5*btn:getScaleY() + offsetY --+  99 --systemDes.position[2]
    local disicon = math.sqrt(posX*posX+posY*posY)
    local speed = disicon/1000

    local angle = math.deg(math.atan(posX/posY)) -- + 180
    if 0 <= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 <= posY then
        angle = angle + 180
    elseif  0 >= posX and 0 >= posY then
        angle = angle 
    elseif  0 <= posX and 0 >= posY then
        angle = angle 
    end

    icon:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0, 1.0), 
        cc.DelayTime:create(1.2), 
        -- cc.FadeOut:create(0.3),
        cc.ScaleBy:create(0.3, 0.01),
        cc.CallFunc:create(function()
            bgLayer:setBackGroundColorOpacity(0)
            local mc2 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false) 
            mc2:setName("mc2")
            mc2:setScale(100) 
            mc2:setRotation(angle)
            icon:addChild(mc2)

            local sp = mcMgr:createViewMC("lashentiao_lianmengjihuo", false, false)  
            sp:setAnchorPoint(cc.p(0.5, 0))
            sp:setRotation(90)
            sp:setScaleX(0)
            mc2:addChild(sp, -1)

            local scay = 1
            if disicon < 150 then
                scay = 0.5
            elseif disicon > 400 then
                scay = 2
            end
            local spSeq = cc.Sequence:create(cc.ScaleTo:create(0.2, 0, 1), cc.ScaleTo:create(speed+0.1, scay, 1), cc.ScaleTo:create(0, 0, 1), cc.FadeOut:create(0.1))
            sp:runAction(spSeq)
        end),
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(function()
            audioMgr:playSound("Unlock")
        end),        
        cc.Spawn:create(
            -- cc.ScaleBy:create(speed, 0.2), 
            cc.MoveBy:create(speed+0.1, cc.p(posX, posY)),
            cc.FadeOut:create(speed+0.1)),
        cc.CallFunc:create(function()
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:setCascadeOpacityEnabled(true)
                mc2:setOpacity(0)
            end
            local mc1 = mcMgr:createViewMC("fankui_lianmengjihuo", false, true, nil, RGBA8888)  
            mc1:setScale(100)
            icon:addChild(mc1,-1) 
            
            btn:stopAllActions()
            btn:setOpacity(255)
            btn:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                    btn:setScale(scale+0.1)
                    btn:setOpacity(255)
                    btn:setBrightness(40)
                end),
                cc.DelayTime:create(0.3), 
                cc.CallFunc:create(function()
                    btn:setBrightness(0)
                    btn:setScale(scale)
                end)
            ))
            UIUtils:setGray(self._breakBtn,false)
            self._breakBtn:setEnabled(true)
        end),
        cc.DelayTime:create(1), 
        -- cc.MoveTo:create(speed, cc.p(95, MAX_SCREEN_HEIGHT - 37)), 
        cc.CallFunc:create(function ()
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:setOpacity(0)
            end
            bgLayer:removeFromParent()
        end), 
        cc.RemoveSelf:create(true)))
end

return TreasureView