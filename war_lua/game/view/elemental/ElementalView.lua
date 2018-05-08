--[[
    @FileName   ElementalView
    @Authors    zhangtao
    @Date       2017-08-03 14:04:48
    @Email      <zhangtao@playcrad.com>
    @Description   元素位面View
--]]


local  ElementalView= class("ElementalView",BaseView)
local openDesc = {"火","水","气","土","混乱"}
local weekDay = {"周一","周二","周三","周四","周五","周六","周日"}

function ElementalView:ctor()
    self.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._elementModel = self._modelMgr:getModel("ElementModel")
    -- self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._openSate = self._elementModel:getOpenState()
end

-- 初始化UI后会调用, 有需要请覆盖
function ElementalView:onInit()
    -- dump(self._userModel:getData())
    --关闭按钮
    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("elemental.ElementalView")
    end)
    ----title
    local title = self:getUI("titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    self._openList = self._elementModel:getOpenList()

    self:loadUI()
    --初始化按钮
    self:setMenuClick()
end

function ElementalView:loadUI()
    self._elemItem = {}
    self._weekDay = self._elementModel:getCurWeekDay()
    self:getUI("timesBg.openValue"):setString(self:getOpenDes())
    self._todayFirstEnter =  self:getFitstState()
    --位面元素
    self._yuansu = 
    {
        --1.位面动画 2.位面名字 3.位面y的偏移 4.元素名字
        {"huo_elementalrukou","elemental_huoTitleName.png","30"},
        {"shui_elementalrukou","elemental_shuiTitleName.png","0"},
        {"qi_elementalrukou","elemental_qiTitleName.png","0"},
        {"tu_elementalrukou","elemental_tuTitleName.png","0"},
        {"hundun_elementalrukou","elemental_hundunTitleName.png","0"}
    }

    self._challengeTimes = self._elementModel:getMaxChallengeTimes()

    --设置位面元素开启状态
    -- self:setOpenState()
    if self:hasOpen() and self._todayFirstEnter then self:lock() end
    for i = 1 , 5 do
        self._elemItem[i] = self:getUI("bg.btnLayer.yuansu"..i)
        self._elemItem[i]:removeAllChildren()
        self._elemItem[i].name = self:createName(i,self._elementModel:planOrOpen(i))
        self._elemItem[i].icon = self:createIcon(i,self._elementModel:planOrOpen(i))
        self._elemItem[i].suoAni = self:createSuoAni(i,self._elementModel:planOrOpen(i))
        self._elemItem[i].times = self:createTimeLable(i,self._elementModel:planOrOpen(i))
                
        self:registerTouchEvent(self._elemItem[i],
            function ()
                if self._openSate[i] then
                    self._elemItem[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 50))))
                end
                self._elemItem[i]:setBrightness(40)
                self._elemItem[i].downSp = self._elemItem[i]:getVirtualRenderer()
            end,
            function ()
                if self._elemItem[i].downSp ~= self._elemItem[i]:getVirtualRenderer() then
                    self._elemItem[i]:setBrightness(0)
                end
            end,
            function ()
                self._elemItem[i]:setOpacity(255)
                self._elemItem[i]:setBrightness(0)
                if not next(self._elementModel:getOpenList()[i]) then
                    self._viewMgr:showTip(lang("TIP_GUILD_OPEN_5"))
                    return
                end

                if self._openSate[i] then
                    self._elemItem[i]:stopAllActions()
                    self._viewMgr:showDialog("elemental.ElementalLevelSelectView", {planeId = i,enterType = 1,parent = self}, true)
                else
                    self._viewMgr:showTip(self:openNotice(i))
                end
            end,
            function()
                if self._openSate[i] then
                    self._elemItem[i]:stopAllActions()
                end
                self._elemItem[i]:setBrightness(0)
                self._elemItem[i]:setOpacity(255)
            end)
    end
    -- --设置挑战次数
    -- self:setHasTimes()
end

--判断当天是否是第一次显示
function ElementalView:getFitstState()
    local curServerTime = self._userModel:getCurServerTime()
    local timeDate
    local tempCurDayTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curServerTime,"%Y-%m-%d 05:00:00"))
    if curServerTime > tempCurDayTime then
        timeDate = TimeUtils.getDateString(curServerTime,"%Y%m%d")
    else
        timeDate = TimeUtils.getDateString(curServerTime - 86400,"%Y%m%d")
    end
    local tempdate = SystemUtils.loadAccountLocalData("ELEMENTAL_IS_SHOWED_ITEM")
    if tempdate ~= timeDate then
        SystemUtils.saveAccountLocalData("ELEMENTAL_IS_SHOWED_ITEM", timeDate)
        return true
    end
    return false

end

function ElementalView:setHasTimes()
    for k , v in pairs(self._elemItem) do
        if v.times then
            local hasTimes = self._elementModel:getAllElementTimes()[k]
            local timesNode = v.times:getChildByFullName("timesLab")
            timesNode:setString(hasTimes)
            timesNode:setColor(hasTimes == 0 and cc.c3b(255,0,0) or cc.c3b(0,255,30)) 
        end
    end
end


--判断当天是否有开启的位面
function ElementalView:hasOpen()
    for _ , info in pairs(self._openList) do
        for k , v in pairs(info) do
            if tonumber(v) == tonumber(self._weekDay) then
                return true
            end
        end
    end
    return false
end

--开启提示
function ElementalView:openNotice(itemId)
    local noticeDesc = ""
    for k , v in pairs(self._openList[itemId]) do
        if k ~= #self._openList[itemId] then
            noticeDesc = noticeDesc .. weekDay[tonumber(v)].."、"
        else
            noticeDesc = noticeDesc .. weekDay[tonumber(v)].."开启"
        end        
    end
    return noticeDesc
end

--开启位面
function ElementalView:getOpenDes()
    local desc = ""
    local tempDesc = {}
    for index, info in pairs(self._openList) do
        for k , v in pairs(info) do
            if tonumber(v) == tonumber(self._weekDay) then
                table.insert(tempDesc,openDesc[index])
            end
        end
    end
    for k , v in pairs(tempDesc) do
        if k ~= #tempDesc then
            desc = desc .. v .."、"
        else
            desc = desc .. v
        end
    end
    if desc == "" then desc = "无" end
    return desc
end

--进入动画
function ElementalView:beforePopAnim()
    local titleBg = self:getUI("titleBg")
    if titleBg then
        titleBg:setOpacity(0)
    end
end

function ElementalView:popAnim(callback)
    local titleBg = self:getUI("titleBg")
    if titleBg then
        ScheduleMgr:nextFrameCall(self, function()
            titleBg:stopAllActions()
            titleBg:setOpacity(255)
            local x, y = titleBg:getPositionX(), titleBg:getPositionY()
            titleBg:setPosition(x, y + 80)
            titleBg:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(x, y - 5)), 3),
                cc.MoveTo:create(0.07, cc.p(x, y)),
                cc.CallFunc:create(function ()
                    self.__popAnimOver = true
                    if callback then callback() end
                end)
            ))
        end)
    else
        self.__popAnimOver = true
    end
end

function ElementalView:createIcon(index,isOpen)
    local elemIcon = mcMgr:createViewMC(self._yuansu[index][1], true, false) 
    elemIcon:setAnchorPoint(cc.p(0.5,0.5))
    elemIcon:setPosition(cc.p(self._elemItem[index]:getContentSize().width/2, self._elemItem[index]:getContentSize().height/2 + tonumber(self._yuansu[index][3])))
    elemIcon:setName("elemIcon")
    
    if self._todayFirstEnter then
        elemIcon:stop()
        elemIcon:setSaturation(-180)
    else
        if not isOpen then
            elemIcon:stop()
            elemIcon:setSaturation(-180)
        end
    end
    self._elemItem[index]:addChild(elemIcon, 1)

    return elemIcon
end

function ElementalView:createName(index,isOpen)
    local elemName = ccui.ImageView:create()
    elemName:loadTexture(self._yuansu[index][2], 1)
    elemName:ignoreContentAdaptWithSize(false)
    elemName:setAnchorPoint(cc.p(0.5,0))
    elemName:setPosition(cc.p(self._elemItem[index]:getContentSize().width/2,20))
    elemName:setName("elemName")
    -- elemName:setSaturation(-180)
    if self._todayFirstEnter then
        elemName:setSaturation(-180)
    else
        if not isOpen then
            elemName:setSaturation(-180)
        end
    end
    self._elemItem[index]:addChild(elemName, 2)
    return elemName
end

function ElementalView:createSuoAni(index,isOpen)
    local suoAni = mcMgr:createViewMC("jiesuo_elementalrukou", false, true, function()
        if isOpen then
            self._elemItem[index].icon:play()
            self._elemItem[index].icon:setSaturation(0)
            self._elemItem[index].name:setSaturation(0)
            self:unlock()
        end
    end)
    if self._todayFirstEnter then
        if not isOpen then
            suoAni:stop()
        end
    else
        suoAni:stop()
        if not isOpen then
            suoAni:setVisible(true)
        else
            suoAni:setVisible(false)
        end
    end
    suoAni:setAnchorPoint(cc.p(0.5,0.5))
    suoAni:setPosition(cc.p(self._elemItem[index]:getContentSize().width/2, self._elemItem[index]:getContentSize().height/2))
    self._elemItem[index]:addChild(suoAni, 3)
    return suoAni
end
--次数
function ElementalView:createTimeLable(index,isOpen)
    if not isOpen then return nil end
    local bgNode = ccui.Widget:create()
    bgNode:setAnchorPoint(0,0)
    bgNode:setContentSize(116, 116)
    local timesTitle = cc.Label:createWithTTF("剩余次数:", UIUtils.ttfName, 20)
    timesTitle:setColor(cc.c3b(191,191,163))
    timesTitle:setPosition(cc.p(90,8))
    bgNode:addChild(timesTitle)

    local hasTimes = self._elementModel:getAllElementTimes()[index]
    local timesLab = cc.Label:createWithTTF(hasTimes, UIUtils.ttfName, 20)
    timesLab:setColor(hasTimes == 0 and cc.c3b(255,0,0) or cc.c3b(0,255,30))  
    timesLab:setName("timesLab")
    timesLab:setAnchorPoint(cc.p(0,0.5))
    timesLab:setPosition(cc.p(140,8))  
    bgNode:addChild(timesLab)
    self._elemItem[index]:addChild(bgNode, 3)
    return bgNode
end

function ElementalView:setMenuClick()
    local orderBtn = self:getUI("menu.menuList.btnBg01")
    orderBtn:setScaleAnim(true)
    self:registerClickEvent(orderBtn, function()
        local rankModel = self._modelMgr:getModel("RankModel")
        rankModel:setRankTypeAndStartNum(rankModel.kRankTypeElemProgress, 1) 
        self._serverMgr:sendMsg("RankServer", "getRankList", {type = rankModel.kRankTypeElemProgress, startRank = 1, id = 1}, true, {}, function(result)
            self._viewMgr:showDialog("elemental.ElementalLayerRankView",{selectIndex = 1},true)
        end)
    end)

    local ruleBtn = self:getUI("menu.menuList.btnBg02")
    ruleBtn:setScaleAnim(true)
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("global.GlobalRuleDescView",{desc = lang("planeRule")},true)
    end)

    local shopBtn = self:getUI("menu.menuList.btnBg03")
    shopBtn:setScaleAnim(true)
    self:registerClickEvent(shopBtn, function()
        print("deliveryBtn click")
        self._viewMgr:showView("shop.ShopView", {idx = 7})
        -- self._viewMgr:showView("elemental.ElementShopView", {}, true)
    end)
end

-- 第一次进入调用, 有需要请覆盖
function ElementalView:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function ElementalView:onHide()

end

function ElementalView:onTop()
    self:loadUI()
end

function ElementalView:getBgName()
    return "elementalBg/elemental_main.jpg"
end

function ElementalView:getAsyncRes()
    return 
    {
        {"asset/ui/mf.plist", "asset/ui/mf.png"},
        {"asset/ui/elemental.plist", "asset/ui/elemental.png"},
        { "asset/ui/cloudCity.plist", "asset/ui/cloudCity.png" },

    }
end

-- 接收自定义消息
function ElementalView:reflashUI(data)

end

return ElementalView