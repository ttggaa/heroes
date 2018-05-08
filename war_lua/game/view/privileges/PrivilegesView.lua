--[[
    Filename:    PrivilegesView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-03 10:25:37
    Description: File description
--]]


local PrivilegesView = class("PrivilegesView", BaseView)

function PrivilegesView:ctor()
    PrivilegesView.super.ctor(self)
    -- self._initAnimType = 1
    -- self.initAnimType = 3
    self._privilegeModel = self._modelMgr:getModel("PrivilegesModel")
    self._playerTodayModel = self._modelMgr:getModel("PlayerTodayModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._updateAnim = false
    -- self._privilegeWidth = MAX_SCREEN_WIDTH
end

-- function PrivilegesView:onComplete()
--     self._viewMgr:enableScreenWidthBar()
-- end

-- function PrivilegesView:onPopEnd()
--     self._viewMgr:enableScreenWidthBar()
-- end

-- function PrivilegesView:onDestroy()
--     self._viewMgr:disableScreenWidthBar()
--     PrivilegesView.super.onDestroy(self)
-- end

function PrivilegesView:onInit()
    -- local closeBtn = self:getUI("closeBtn")
    -- registerClickEvent(closeBtn, function()        
    --     self:close()
    -- end)

    -- self:registerScriptHandler(function(eventType)
    --     if eventType == "exit" then 
    --         UIUtils:reloadLuaFile("privileges.PrivilegesView")
    --     elseif eventType == "enter" then 
    --     end
    -- end)
    -- self._widget:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    -- if MAX_SCREEN_WIDTH > 1136 then
    --     self._privilegeWidth = 1136
    --     self._widget:setContentSize(1136, MAX_SCREEN_HEIGHT)
    -- end

    self._shopAnim = false
    self._scrollToNext = false
    self._isTouchMove = 0
    -- 特殊处理特权影响主界面气泡显示
    local fristCard = self._modelMgr:getModel("MainViewModel")
    fristCard:releaseFirstCardHalfTip()

    self._tishi = self:getUI("bg.tableViewBg.tishi")
    self._tishi:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._detailCell = self:getUI("detailCell")
    self._detailCell:setVisible(false)
    self:addTableView()

    self._itemNum = self:getUI("bg.tableViewBg.itemNum")
    -- 
    local des = self:getUI("bg.tableViewBg.des")
    des:setColor(cc.c3b(255, 245, 140))
    des:enable2Color(1, cc.c4b(254, 169, 76, 255))
    des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    self._expValue = self:getUI("bg.tableViewBg.expBg.expValue")
    -- self._expValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    for i=1,3 do
        -- local qipao = self:getUI("bg.titleBg.title" .. i .. ".qipao")
        -- qipao:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 5)), cc.MoveBy:create(0.5, cc.p(0, -5)))))
        local lingqu = self:getUI("bg.titleBg.title" .. i .. ".lingqu")
        local rewardMc = mcMgr:createViewMC("baoxiang3_baoxiang", true, false)
        -- rewardMc:setVisible(false)
        lingqu:addChild(rewardMc, 100)
        rewardMc:setPosition(cc.p(lingqu:getContentSize().width*0.5+20, lingqu:getContentSize().height*0.5-10))
        rewardMc:setName("rewardMc")

        local name = self:getUI("bg.titleBg.title" .. i .. ".name")
        name:setFontName(UIUtils.ttfName)
        name:setColor(cc.c3b(255, 206, 111))
        name:enable2Color(1, cc.c4b(255, 255, 255, 255))
        name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        name:setFontSize(30)

        local upPeerage = self:getUI("bg.titleBg.title" .. i .. ".upPeerage")
        self:registerClickEvent(upPeerage, function()
            if self._isTouchMove == 1 then self._isTouchMove = 0 return end
            self:upPeerage()
        end)
        upPeerage:setSwallowTouches(false)

        local mc1 = mcMgr:createViewMC("jinsheng_privilegesanim", true, false)
        mc1:setPosition(cc.p(upPeerage:getContentSize().width*0.5, upPeerage:getContentSize().height*0.5-40))
        mc1:setName("mc1")

        upPeerage:addChild(mc1)

        if i == 2 then
            local icon = self:getUI("bg.titleBg.title" .. i .. ".icon")
            local mc2 = mcMgr:createViewMC("choukahuodeguang_flashchoukahuode", true, false)
            mc2:setPosition(cc.p(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5))
            mc2:setScale(0.6)
            mc2:setName("mc2")
            icon:addChild(mc2, -1)
        elseif i == 3 then
            local icon = self:getUI("bg.titleBg.title" .. i .. ".icon")
            self._guowangshangdian = mcMgr:createViewMC("guowangshangdian_privilegesshopkaiqi", false, false)
            self._guowangshangdian:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5-10)
            -- mc2:setScale(0.6)
            self._guowangshangdian:setName("mc2")
            icon:addChild(self._guowangshangdian, 1)
        end
    end 

    -- self._rankIcon = self:getUI("bg.rankIcon")
    -- 规则
    local peerage = self:getUI("bg.tableViewBg.peerage")
    self:registerClickEvent(peerage, function()
        self._viewMgr:showDialog("privileges.PrivilegesDescDialog", nil)
    end)

    local privilegeData = self._privilegeModel:getData()
    self._selectPeerage = privilegeData.peerage or 1
    self._nowPeerage = privilegeData.peerage or 1
    local shopOpen = self:getShopOpen()
    if shopOpen == true then
        self._guowangshangdian:gotoAndStop(70)
    else
        self._guowangshangdian:gotoAndStop(1)
    end

    local leftPanel = self:getUI("bg.titleBg.leftPanel")
    local rightPanel = self:getUI("bg.titleBg.rightPanel")
    rightPanel:setLocalZOrder(2)
    local mc1 = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(rightPanel:getContentSize().width*0.5, rightPanel:getContentSize().height*0.5))
    rightPanel:addChild(mc1) 

    leftPanel:setLocalZOrder(2)
    local mc2 = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(leftPanel:getContentSize().width*0.5, leftPanel:getContentSize().height*0.5))
    leftPanel:addChild(mc2)

    local icon = self:getUI("bg.titleBg.title2.icon")
    local mc2 = icon:getChildByName("mc2")

    local title = self:getUI("bg.peerBg.titleBg.title")
    UIUtils:setTitleFormat(title, 3, 1)

    local downY, clickFlag, tempScale
    registerTouchEvent(
        leftPanel,
        function (_, _, y)
            downY = y
            clickFlag = false
            if mc2 then
                mc2:setVisible(false)
            end
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            if clickFlag == false then 
                self._selectPeerage = self._selectPeerage - 1
                self:updatePeerage()
                self:clickPeerage()
            end
            if mc2 then
                mc2:setVisible(true)
            end
        end,
        function ()
            if mc2 then
                mc2:setVisible(true)
            end
        end)

    local downY, clickFlag
    registerTouchEvent(
        rightPanel,
        function (_, _, y)
            downY = y
            clickFlag = false
            if mc2 then
                mc2:setVisible(false)
            end
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            if clickFlag == false then 
                self._selectPeerage = self._selectPeerage + 1
                self:updatePeerage()
                self:clickPeerage()
            end
            if mc2 then
                mc2:setVisible(true)
            end
        end,
        function ()
            if mc2 then
                mc2:setVisible(true)
            end
        end)


    local titleBg = self:getUI("bg.titleBg")
    local downY, downX, endX
    registerTouchEvent(
        titleBg,
        function (_, x, y)
            self._isTouchMove = 0
            downY = y
            downX = x
            endX = x
        end, 
        function (_, x, y)
        end, 
        function (_, x, y)
            if x - downX > 10 then
                self._selectPeerage = self._selectPeerage - 1
                self._isTouchMove = 1
            elseif x - downX < -10 then
                self._selectPeerage = self._selectPeerage + 1
                self._isTouchMove = 1
            end
            if self._selectPeerage < 1 then 
                self._selectPeerage = 1
            end
            if self._selectPeerage > 10 then 
                self._selectPeerage = 10
            end
            if self._isTouchMove == 1 then
                self:updatePeerage()
                self:clickPeerage()  
            end          
        end,
        function (_, x, y)
            if x - downX > 10 then
                print("right=========== -1")
                self._selectPeerage = self._selectPeerage - 1
                self._isTouchMove = 1
            elseif x - downX < -10 then
                self._selectPeerage = self._selectPeerage + 1
                self._isTouchMove = 1
            end
            if self._selectPeerage < 1 then 
                self._selectPeerage = 1
            end
            if self._selectPeerage > 10 then 
                self._selectPeerage = 10
            end
            print("self._isTouchMove===3==================", self._isTouchMove)
            if self._isTouchMove == 1 then            
                self:updatePeerage()
                self:clickPeerage() 
            end               
        end)
    titleBg:setSwallowTouches(true)
    -- self:updatePeerage()
    -- self:clickPeerage()

    self:listenReflash("PrivilegesModel", self.reflashUI)
    self:listenReflash("ItemModel", self.reflashUI)
    -- self:reflashUI()

    -- local num = self._scrollView:getInnerContainerSize().height - self._scrollView:getContentSize().height
    -- local tempNum = math.ceil(num/(self._peerageCell:getContentSize().height + 5))
    -- if self._nowPeerage > tempNum then
    --     self._scrollView:scrollToPercentVertical(num, 0, false)
    -- elseif self._nowPeerage > 1 then
    --     local backPercent = (self._nowPeerage - 1) * (self._peerageCell:getContentSize().height + 5) / num 
    --     self._scrollView:scrollToPercentVertical(backPercent * 100, 0, false)
    -- end

    -- self._updatePrivilege = false

    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    local privilegesTip = self:getUI("bg.tableViewBg.privilegesTip")
    privilegesTip:setContentSize(cc.size(210, (tbuffNum+1)*45))
    privilegesTip:setCapInsets(cc.rect(30, 30, 30, 30))
    privilegesTip:setVisible(false)
    local closePrivilegesTip = self:getUI("bg.tableViewBg.privilegesTip.closePrivilegesTip")
    self:registerClickEvent(closePrivilegesTip, function()
        privilegesTip:setVisible(false)
    end)
end

-- 刷新主特权
function PrivilegesView:updatePeerage()
    -- local leftPanel = self:getUI("bg.titleBg.leftPanel")
    -- local rightPanel = self:getUI("bg.titleBg.rightPanel")
    for i=1,3 do
        local title = self:getUI("bg.titleBg.title" .. i)
        if title then
            local selectPeer
            local flag = false
            if i == 1 then
                selectPeer = self._selectPeerage - 1
                title:setBrightness(-40)
            elseif i == 2 then
                selectPeer = self._selectPeerage
                self:nowPeerageExp(selectPeer)
                self:updateBigEffect(self._selectPeerage)
                title:setBrightness(0)
            elseif i == 3 then
                selectPeer = self._selectPeerage + 1
                title:setBrightness(-40)
            end


            -- print("i= ", i, "selectPeer=",selectPeer, "self._nowPeerage", self._nowPeerage, self._selectPeerage)
            if selectPeer < 1 then
                title:setVisible(false)
            elseif selectPeer > 10 then
                if selectPeer == 11 then
                    title:setVisible(true)
                    self._guowangshangdian:setVisible(true)
                    local icon = title:getChildByFullName("icon")
                    if icon then
                        icon:loadTexture("peerageRes_12.png", 1)
                        icon:setOpacity(0)
                    end
                    local nowPeerage = title:getChildByFullName("nowPeerage")
                    if nowPeerage then
                        nowPeerage:loadTexture("privilegeImageUI_img15.png", 1)
                    end

                    local name = title:getChildByFullName("name")
                    if name then
                        name:setString("战争军备")
                    end

                    local templevelNum, tempMaxLevel = self:isUpPeerage(1)
                    print("flag============", templevelNum, tempMaxLevel)
                    if templevelNum == tempMaxLevel and self._nowPeerage == 10 then
                        title:setBrightness(0)
                        local clickFlag = false
                        local downY
                        local posX, posY
                        registerTouchEvent(
                            icon,
                            function (_, _, y)
                                downY = y
                                clickFlag = false
                                icon:setBrightness(40)
                                self._clickShop = true
                            end, 
                            function (_, _, y)
                                if downY and math.abs(downY - y) > 5 then
                                    clickFlag = true
                                end
                            end, 
                            function ()
                                icon:setBrightness(0)
                                if clickFlag == false then 
                                    -- print("666666666666666666")
                                    self:getShopInfo()
                                end
                            end,
                            function ()
                                icon:setBrightness(0)
                            end)
                        icon:setEnabled(true)
                        local buffSum = {}
                        local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
                        for i=1,tbuffNum do
                            local flag, buffId = self._privilegeModel:getKingBuff(i)
                            local buffNum = tonumber(buffId)
                            local buffTab = tab:PeerShop(buffNum)
                            local buffIcon = title:getChildByName("buffIcon" .. i)
                            if flag == true then
                                table.insert(buffSum, i)
                                local param = {image = buffTab.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
                                if buffIcon then
                                    IconUtils:updatePeerageIconByView(buffIcon, param)
                                else
                                    buffIcon = IconUtils:createPeerageIconById(param)
                                    buffIcon:setAnchorPoint(0.5, 0.5)
                                    buffIcon:setPosition(0+i*35,-20)
                                    buffIcon:setScale(0.3)
                                    buffIcon:setName("buffIcon" .. i)
                                    title:addChild(buffIcon)
                                end
                                buffIcon:setVisible(true)
                            else
                                if buffIcon then
                                    buffIcon:setVisible(false)
                                end
                            end
                        end
                        print("desStr=====", desStr)
                        -- local des = "[color=562600]不！这一战我即便战退！[-][][-][color=562600]不！这一战我即便战退！[-][][-][color=562600]不！这一战我即便战退！[-]"
                        local des = desStr -- "[-][color=1ca216]不！这一战[-][][pic=vip_newImg.png][-][-][color=1ca216]不！这一战退！[-][][-][pic=vip_newImg.png][-][color=1ca216]不！便战退！[-]"
                        local posX = 0 -- (180 - 35*table.nums(buffSum))*0.5-15
                        for i=1,table.nums(buffSum) do
                            local indexId = buffSum[i]
                            local flag, buffId = self._privilegeModel:getKingBuff(indexId)
                            local buffNum = tonumber(buffId)
                            local buffTab = tab:PeerShop(buffNum)
                            local buffIcon = title:getChildByName("buffIcon" .. indexId)
                            if buffIcon then
                                buffIcon:setPosition(posX+30*i,-20)
                                buffIcon:setScaleAnim(true)
                                self:registerClickEvent(buffIcon, function()
                                    print("调用tips")
                                    local privilegesTip = self:getUI("bg.tableViewBg.privilegesTip")
                                    self:showPrivilegesBuffTip(privilegesTip)
                                end)
                            end
                        end
                    else
                        if icon then
                            icon:setEnabled(false)
                        end
                    end
                end
            else
                title:setVisible(true)
                self._guowangshangdian:setVisible(false)

                local icon = title:getChildByFullName("icon")
                if icon then
                    icon:setOpacity(255)
                    icon:setEnabled(false)
                    icon:loadTexture(tab:Peerage(selectPeer).res .. ".png", 1)
                end
                local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
                for i=1,tbuffNum do
                    local buffIcon = title:getChildByName("buffIcon" .. i)
                    if buffIcon then
                        buffIcon:setVisible(false)
                    end
                end
                local nowPeerage = title:getChildByFullName("nowPeerage")
                if nowPeerage then
                    nowPeerage:loadTexture("privilegeImageUI_img6.png", 1)
                end
                -- local nowPeerage = title:getChildByFullName("nowPeerage")
                -- if nowPeerage then
                --     if selectPeer == self._nowPeerage then
                --         nowPeerage:setVisible(true)
                --     else
                --         nowPeerage:setVisible(false)
                --     end
                -- end
                local name = title:getChildByFullName("name")
                if name then
                    name:setString(lang(tab:Peerage(selectPeer).name))
                end

                local upPeerage = title:getChildByFullName("upPeerage")
                if upPeerage then
                    local flag = false
                    if selectPeer == self._nowPeerage then
                        flag = self:isUpPeerage()
                    end
                    if flag == true then
                        upPeerage:setVisible(true)
                        title:setEnabled(true)
                    else
                        upPeerage:setVisible(false)
                    end
                end
            end

            local lingqu = title:getChildByFullName("lingqu")
            if lingqu then
                if selectPeer == self._nowPeerage and i == 2 then
                    lingqu:setVisible(true)
                else
                    lingqu:setVisible(false)
                end
            end

            if lingqu then
                -- local qipao = title:getChildByFullName("qipao")
                local upPeerage = title:getChildByFullName("upPeerage")
                -- if qipao then
                --     qipao:setVisible(false)
                -- end

                local icon = title:getChildByFullName("icon")
                local changtai = icon:getChildByName("changtai")
                if not changtai then
                    changtai = mcMgr:createViewMC("tequanchangtaitexiao_privilegesanim", true, false)
                    changtai:setPosition(cc.p(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5))
                    changtai:setName("changtai")
                    changtai:setVisible(false)
                    icon:addChild(changtai)
                else
                    changtai:setVisible(false)
                end

                print("select=======", selectPeer , self._nowPeerage)
                if selectPeer == self._nowPeerage then
                    if changtai then
                        changtai:setVisible(true)
                    end
                    local todayTimes = self._playerTodayModel:getData()
                    if todayTimes["day25"] ~= 1 then
                        -- if qipao then
                        --     if upPeerage:isVisible() == false then
                        --         qipao:setVisible(true)
                        --     end
                        -- end
                    else
                        -- if qipao then
                        --     qipao:setVisible(false)
                        -- end
                            lingqu:setVisible(false)
                        if selectPeer == self._nowPeerage and i == 2 then
                        end
                    end

                    self:registerClickEvent(lingqu, function()
                        local todayTimes = self._playerTodayModel:getData()
                        if todayTimes["day25"] ~= 1 then
                            local param = {selectPeerage = self._nowPeerage, callback = function()
                                self:getWages()
                                print("领取每日奖励 =========")
                            end}
                            self._viewMgr:showDialog("privileges.PrivilegesPeerageDialog", param)
                        else
                            self._viewMgr:showTip("你已领取今日俸禄！")
                        end
                    end)
                else
                    if changtai then
                        changtai:setVisible(false)
                    end
                    self:registerClickEvent(lingqu, function()
                        if self._selectPeerage == selectPeer then
                            if selectPeer > self._nowPeerage then
                                self._viewMgr:showTip(lang("TIPS_UI_DES_8"))
                            elseif selectPeer < self._nowPeerage then
                                self._viewMgr:showTip(lang("TIPS_UI_DES_9"))
                            end
                        elseif self._selectPeerage > selectPeer then
                            self._viewMgr:showTip(lang("TIPS_UI_DES_7"))
                        elseif self._selectPeerage < selectPeer then
                            self._viewMgr:showTip(lang("TIPS_UI_DES_7"))
                        end
                    end)
                end
            end
                -- local mc2 = icon:getChildByName("mc2")
                -- if mc2 then
                --     if i == 2 then
                --         mc2:setVisible(true)
                --     else
                --         mc2:setVisible(false)
                --     end
                -- end
        end
    end
end

function PrivilegesView:nowPeerageExp(selectPeer)
    -- local left = self:getUI("bg.titleBg.leftPanel")
    -- local right = self:getUI("bg.titleBg.rightPanel")
    -- if selectPeer <= 2 then
    --     left:setVisible(false)
    --     right:setVisible(true)
    -- elseif selectPeer >= 9 then
    --     right:setVisible(false)
    --     left:setVisible(true)
    -- else
    --     left:setVisible(true)
    --     right:setVisible(true)
    -- end

    local expBg = self:getUI("bg.tableViewBg.expBg")
    if self._selectPeerage < self._nowPeerage then
        expBg:setVisible(false)
        self._tishi:setVisible(false)
    elseif self._selectPeerage == self._nowPeerage then
        expBg:setVisible(true)
        self._tishi:setVisible(false)
        print("self_tableViewself._tableView")
    elseif self._selectPeerage > self._nowPeerage then
        expBg:setVisible(false)
        self._tishi:setVisible(true)
    end

    if expBg:isVisible() then
        local templevelNum, tempMaxLevel = self:isUpPeerage(1)
        local expBar = self:getUI("bg.tableViewBg.expBg.expBar")
        local haveExp = templevelNum*10
        local maxExp = tempMaxLevel*10
        local percentNum = (haveExp/maxExp)*100
        expBar:setPercent(percentNum)

        self._expValue:setString(haveExp .. "/" .. maxExp)
    end
end

function PrivilegesView:isUpPeerage(inType)
    local privilegeData = self._privilegeModel:getData()
    local templevelNum, tempMaxLevel = 0, 0
    local flag = false
    for i=1,5 do
        local peerageTab = tab:Peerage(self._nowPeerage)
        if i <= table.nums(peerageTab.effectId) then
            local maxLevel = peerageTab["lvLimit"][i] - peerageTab["lvCondition"][i]
            local tempLvl = privilegeData["abilityList"][tostring(peerageTab["effectId"][i])] or 0
            if peerageTab["lvCondition"][i] ~= 0 then
                tempLvl = tempLvl - peerageTab["lvCondition"][i]
            end
            if tempLvl >= maxLevel then
                tempLvl = maxLevel
            elseif tempLvl < 0 then
                tempLvl = 0
            end

            templevelNum = templevelNum + tempLvl 
            tempMaxLevel = tempMaxLevel + maxLevel
        end
    end
    
    if templevelNum == tempMaxLevel and self._nowPeerage < 10 then
        flag = true
    end

    if inType == 1 then
        return templevelNum, tempMaxLevel
    else
        return flag
    end
end

-- 刷新主特权效果
function PrivilegesView:updateBigEffect(index)
    local des = self:getUI("bg.tableViewBg.des")
    -- des:setString(lang(tab:Peerage(index).des))
    local peerageTab = tab:Peerage(index)
    local str = string.gsub(lang(peerageTab.des), "%b[]", "")
    des:setString(str)

    -- local title = self:getUI("bg.peerBg.titleBg.title")
    -- title:setString(lang(peerageTab.name))

    -- local iconBg = self:getUI("bg.peerBg.iconBg")
    -- if iconBg then
    --     local peerageEffectIcon = iconBg:getChildByName("peerageEffectIcon")
    --     local param = {image = peerageTab["res"] .. ".png", quality = peerageTab.iconColor, scale = 0.70, bigpeer = true}
    --     if peerageEffectIcon then
    --         IconUtils:updatePeerageIconByView(peerageEffectIcon, param)
    --     else
    --         local peerageEffectIcon = IconUtils:createPeerageIconById(param)
    --         peerageEffectIcon:setPosition(cc.p(-3,0))
    --         peerageEffectIcon:setName("peerageEffectIcon")
    --         iconBg:addChild(peerageEffectIcon)
    --     end
    -- end

    local leftPanel = self:getUI("bg.titleBg.leftPanel")
    local rightPanel = self:getUI("bg.titleBg.rightPanel")
    if self._selectPeerage <= 1 then
        leftPanel:setVisible(false)
        rightPanel:setVisible(true)
    elseif self._selectPeerage >= 10 then
        leftPanel:setVisible(true)
        rightPanel:setVisible(false)
    else
        leftPanel:setVisible(true)
        rightPanel:setVisible(true)
    end

    if self._initAnimType ~= 1 then
        -- local peerBg = self:getUI("bg.peerBg")
        -- local mc1 = mcMgr:createViewMC("qihuanguang_privilegesjihuo", false, true)
        -- mc1:setPosition(cc.p(peerBg:getContentSize().width*0.5, peerBg:getContentSize().height*0.5))
        -- peerBg:addChild(mc1, 2)

        local icon = self:getUI("bg.titleBg.title2.icon")
        local seq = cc.Sequence:create(cc.ScaleTo:create(0.08, 1.6),cc.DelayTime:create(0.2),cc.ScaleTo:create(0.1, 1.5))
        if self._clickShop ~= true then
            icon:runAction(seq)
        end
    end
    self._initAnimType = 2
end

function PrivilegesView:clickPeerage()
    local privilegeData = self._privilegeModel:getData()
    -- dump(privilegeData)
    self._peerageData = {}

    local peerageTab = tab:Peerage(self._selectPeerage)
    -- dump(peerageTab.condition)
    local abilityId = peerageTab.condition
    for i=1,table.nums(peerageTab.condition) do
        self._peerageData[i] = tab:Ability(abilityId[i])
    end
    -- dump(self._peerageData, "self._peerageData =============", 10)

    local offset = self._tableView:getContentOffset()
    self._tableView:reloadData()
    -- if table.nums(self._peerageData) < 5 then
    if self._scrollToNext == true then
    --     self._tableView:setContentOffset(cc.p(0, 0), false)
    -- else
        self._tableView:setContentOffset(cc.p(offset.x, 0), false)
    end
    
    
end

-- function PrivilegesView:addAnim()
--     local leftXiushi = self:getUI("bg.leftXiushi")
--     local beijing = mcMgr:createViewMC("qizi_privilegesanim", true, false)
--     beijing:setAnchorPoint(cc.p(0,0))
--     beijing:setPosition(cc.p(0,0))
--     leftXiushi:addChild(beijing)

--     local reightXiushi = self:getUI("bg.reightXiushi")
--     local beijing = mcMgr:createViewMC("qizi1_privilegesanim", true, false)
--     beijing:setAnchorPoint(cc.p(0,0))
--     beijing:setPosition(cc.p(0,0))
--     reightXiushi:addChild(beijing)

--     -- local rankIcon = self:getUI("bg.rankIcon")
--     -- local beijing = mcMgr:createViewMC("tequanchangtaitexiao_privilegesanim", true, false)
--     -- beijing:setAnchorPoint(cc.p(0.5,0.5))
--     -- beijing:setPosition(cc.p(rankIcon:getContentSize().width*0.5,rankIcon:getContentSize().height*0.5))
--     -- rankIcon:addChild(beijing)
-- end

function PrivilegesView:reflashUI()
    local privilegeData = self._privilegeModel:getData()
    self._selectPeerage = privilegeData.peerage or 1
    self._nowPeerage = privilegeData.peerage or 1

    local tempItems, tempItemCount = self._itemModel:getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
    self._itemNum:setString(tempItemCount)

    local needItemIcon = self:getUI("bg.tableViewBg.img")
    needItemIcon:setScale(0.3)
    needItemIcon:loadTexture(tab:Tool(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value).art .. ".png", 1)
    -- local des1 = self:getUI("bg.tableViewBg.des1")
    -- des1:setString("剩余点数:")
    -- local des2 = self:getUI("bg.tableViewBg.des2")
    -- des2:setString(lang("TIPS_UI_DES_2"))

    -- needItemIcon:setPositionX(des1:getPositionX() + des1:getContentSize().width + 3)
    -- des1:setPositionX(needItemIcon:getPositionX() + needItemIcon:getContentSize().width*needItemIcon:getScaleX() + 3)
    self._itemNum:setPositionX(needItemIcon:getPositionX() + needItemIcon:getContentSize().width*needItemIcon:getScaleX() + 3)
    -- des2:setPositionX(self._itemNum:getPositionX() + self._itemNum:getContentSize().width + 3)

    self:updatePeerage()
    self:clickPeerage()

    -- if self._tabOffsety then
    --     self._tableView:setContentOffset(cc.p(0, self._tabOffsety), false)
    -- end
end

function PrivilegesView:onAnimEnd()
    local showGuide = self._privilegeModel:isShowGuide()
    if showGuide == true then
        self._viewMgr:showDialog("privileges.PrivilegesUpgradeDialog", {old = 0, new = 1, callback = function()
            if self._updateAnim ~= nil then
                self._updateAnim = true
                self._tableView:reloadData()
            end
        end})
    else
        local todayTimes = self._playerTodayModel:getData()
        if todayTimes["day25"] ~= 1 then
            self:showFirstAD()
        end
    end
end

function PrivilegesView:showFirstAD()
    local flag = self._privilegeModel:getPrivilegesFristShow()
    if flag == true then
        local param = {selectPeerage = self._nowPeerage, callback = function()
            self:getWages()
            print("领取每日奖励 =========")
        end}
        self._viewMgr:showDialog("privileges.PrivilegesPeerageDialog", param)
    end
end

-- 第一次进入界面会调用, 有需要请覆盖
-- function BaseView:onShow()
--     self._viewMgr:showDialog("privileges.PrivilegesUpgradeDialog", {old = 0, new = 1})
-- end

--[[
用tableview实现
--]]
function PrivilegesView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-10))
    self._tableView:setDelegate()
    self._tableView:setDirection(0)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(8, 20))
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    -- self._tableView:registerScriptHandler(function(view) return self:scrollViewDidScroll(view) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)

    -- UIUtils:ccScrollViewAddScrollBar(self._tableView, cc.c3b(169, 124, 75), cc.c3b(32, 16, 6), -21, 6)
end


function PrivilegesView:scrollViewDidScroll(view)
    UIUtils:ccScrollViewUpdateScrollBar(view)
end


-- 触摸时调用
function PrivilegesView:tableCellTouched(table,cell)
end

-- cell的尺寸大小
function PrivilegesView:cellSizeForTable(table,idx) 
    local width = 230 
    local height = 240
    return height, width
end

-- 创建在某个位置的cell
function PrivilegesView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._peerageData[idx+1]
    local indexId = idx+1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local detailCell = self._detailCell:clone() 
        detailCell:setVisible(true)
        detailCell:setAnchorPoint(cc.p(0,0))
        detailCell:setPosition(cc.p(1,2))
        detailCell:setName("detailCell")
        cell:addChild(detailCell)

        -- local upgrade = detailCell:getChildByFullName("upgrade")
        -- upgrade:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
        local upgrade = detailCell:getChildByFullName("upgrade")
        UIUtils:setButtonFormat(upgrade, 3, 0)

        local titleBg = detailCell:getChildByFullName("titleBg")
        -- titleBg:setOpacity(150)
        local title = detailCell:getChildByFullName("titleBg.title")
        UIUtils:setTitleFormat(title, 2, 0, 1)
        -- title:enableOutline(cc.c4b(70, 40, 0, 255), 1)

        print("woshixind ===============")
        self:updateCell(detailCell, param, indexId)
        -- mailNode:setSwallowTouches(false)
    else
        local detailCell = cell:getChildByName("detailCell")
        if detailCell then
            self:updateCell(detailCell, param, indexId)
            detailCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function PrivilegesView:numberOfCellsInTableView(table)
    return #self._peerageData --  #self._model -- #self._model --table.nums(self._membersData)
end

-- 更新tableView数据
function PrivilegesView:updateCell(inView, data, indexId)
    -- dump(data, "data", 10)
    local privilegeData = self._privilegeModel:getData()

    local title = inView:getChildByFullName("title")
    if title then
        -- print("+++==========", lang(data["name"]))
        title:setString(lang(data["name"]))
    end
    local iconBg = inView:getChildByFullName("iconBg")
    -- local abilityTab = tab:Ability(tab:Peerage(self._peerageId[1])["condition"][self._peerageId[2]])
    if self._updateAnim == true then
        local mc = mcMgr:createViewMC("shangdianshuaxin_shoprefreshanim", false, true,function( )
            self._updateAnim = false
            print ("++++=============+++++++++++++++")
        end)
        mc:setScale(1.15)
        mc:setPosition(inView:getContentSize().width*0.5, inView:getContentSize().height*0.5)
        inView:addChild(mc)
    end

    if iconBg then
        local effectIcon = iconBg:getChildByName("effectIcon")
        local param = {image = data["res"] .. ".png", quality = data.iconColor}
        if not effectIcon then
            effectIcon = IconUtils:createPeerageIconById(param)
            effectIcon:setPosition(cc.p(0,10))
            effectIcon:setScale(0.7)
            effectIcon:setName("effectIcon")
            effectIcon:setAnchorPoint(0.5,0.5)
            effectIcon:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2)
            iconBg:addChild(effectIcon)
        else
            IconUtils:updatePeerageIconByView(effectIcon, param)
        end
    end
    
    local peerageTab = tab:Peerage(self._selectPeerage)
    local maxLevel = peerageTab["lvLimit"][indexId] - peerageTab["lvCondition"][indexId]
    local tempLvl = privilegeData["abilityList"][tostring(peerageTab["effectId"][indexId])] or 0
    if peerageTab["lvCondition"][indexId] ~= 0 then
        tempLvl = tempLvl - peerageTab["lvCondition"][indexId]
    end
    if tempLvl >= maxLevel then
        tempLvl = maxLevel
    elseif tempLvl < 0 then
        tempLvl = 0
    end

    local level = inView:getChildByName("level")
    if level then
        if self._selectPeerage <= self._nowPeerage then
            level:setVisible(true)
        else
            level:setVisible(false)
        end
        level:setString("Lv." .. tempLvl .. "/Lv." .. maxLevel)
    end
    local des = inView:getChildByName("des")
    if des then
        local str
        if tempLvl == 0 then
            str = self:split(lang(data["effectDes"]),1)
        else
            str = self:split(lang(data["effectDes"]),tempLvl)
        end
        des:setString(str)
    end

    local upgrade = inView:getChildByName("upgrade")
    local noOpen = inView:getChildByName("noOpen")
    local maxLevelImg = inView:getChildByName("maxLevel")
    local zhezhao = inView:getChildByName("zhezhao")
    local hongdian = inView:getChildByName("hongdian")
    if self._selectPeerage < self._nowPeerage then
        if maxLevelImg then
            maxLevelImg:setVisible(true)
        end
        if upgrade then
            upgrade:setVisible(false)
        end
        if hongdian then
            hongdian:setVisible(false)
        end
        if noOpen then
            noOpen:setVisible(false)
        end
        if zhezhao then
            zhezhao:setVisible(false)
        end
    elseif self._selectPeerage == self._nowPeerage then
        if noOpen then
            noOpen:setVisible(false)
        end
        if zhezhao then
            zhezhao:setVisible(false)
        end
        if hongdian then
            hongdian:setVisible(false)
        end
        if tempLvl < maxLevel then
            if maxLevelImg then
                maxLevelImg:setVisible(false)
            end

            if hongdian then
                local tempItems, tempItemCount = self._itemModel:getItemsById(tab:Setting("G_PRIVILEGES_LVUP_ITEMID").value)
                if tempItemCount >= 10 then
                -- if tempItemCount >= tab:AbilityEffect(self._abilityId)["cost"][self._abilityNextLvl] then
                    hongdian:setVisible(true)
                else
                    hongdian:setVisible(false)
                end
                
            end
            if upgrade then
                upgrade:setVisible(true)
                self:registerClickEvent(upgrade, function()
                    print("hhhhhhhhhhhh", indexId)
                    local param = {abilityId = tab:Peerage(self._nowPeerage)["effectId"][indexId], peerageId = {self._nowPeerage,indexId}, callback = function()
                        -- self:updateCell(inView, data, indexId)
                        -- self:reflashUI()
                        -- if inView then
                        --     local mc1 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", false, true)
                        --     mc1:setPosition(cc.p(inView:getContentSize().width*0.5, inView:getContentSize().height*0.5))
                        --     inView:addChild(mc1)
                        -- end
                        local flag = self:getShopOpen()
                        if flag == true then
                            self._guowangshangdian:gotoAndPlay(1)
                            local title = self:getUI("bg.titleBg.title3.nowPeerage")
                            
                            local mc2 = mcMgr:createViewMC("zisaoguang_privilegesshopkaiqi", false, false)
                            mc2:setPosition(cc.p(40, title:getContentSize().height*0.5+5))
                            mc2:setScale(0.6)
                            mc2:setName("mc2")
                            title:addChild(mc2, -1)
                        end
                        self._scrollToNext = false
                        self._tabOffsety = nil 
                    end}
                    self._tabOffsety = self._tableView:getContentOffset().y
                    -- dump(self._tabOffsety)
                    -- print("===========", self._tabOffsety)
                    self._scrollToNext = true
                    self._viewMgr:showDialog("privileges.PrivilegesAbilityDialog", param)
                end)
            end
        elseif tempLvl == maxLevel then
            if maxLevelImg then
                maxLevelImg:setVisible(true)
            end
            if upgrade then
                upgrade:setVisible(false)
            end
        end
    elseif self._selectPeerage > self._nowPeerage then
        if maxLevelImg then
            maxLevelImg:setVisible(false)
        end
        if upgrade then
            upgrade:setVisible(false)
        end
        if hongdian then
            hongdian:setVisible(false)
        end
        if noOpen then
            noOpen:setVisible(true)
        end
        if zhezhao then
            zhezhao:setVisible(true)
            -- zhezhao:setContentSize(iconSize)
            -- zhezhao:setScale(0.7)
            local width,height = iconBg:getContentSize().width,iconBg:getContentSize().height
            zhezhao:setPosition(iconBg:getPositionX()+width/2,iconBg:getPositionY()+height/2)
        end
    end
end

-- 处理字符串
function PrivilegesView:split(str,reps)
    local des = string.gsub(str,"%b{}",function( lvStr )
        local str = string.gsub(lvStr,"%$level",reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    -- local des = string.gsub(str,"{$level}",reps) --  string.gsub(str,"%b{}",function( lvStr )
    des = string.gsub(des, "%b[]", "") 
    return des 
end

function PrivilegesView:upPeerage()
    self._oldPrivileges = self._nowPeerage
    self._serverMgr:sendMsg("PrivilegesServer", "upPeerage", {}, true, {}, function (result)
        self:upPeerageFinish(result)
    end)
end

function PrivilegesView:upPeerageFinish(result)
    local privilegeData = self._privilegeModel:getData()
    self._nowPeerage = privilegeData.peerage or 1
    audioMgr:playSound("privilegeUpgrade")  --特权升级  

    self._viewMgr:showDialog("privileges.PrivilegesUpgradeDialog", {old = self._oldPrivileges, new = self._nowPeerage, callback = function()
        local icon = self:getUI("bg.titleBg.title2.icon")
        local mc1 = mcMgr:createViewMC("jinshengtexiao_privilegesjihuo", false, true)
        mc1:setPosition(cc.p(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5))
        icon:addChild(mc1)
        print("关闭界面")
        self._modelMgr:getModel("GuildRedModel"):checkRandRed()
        ScheduleMgr:delayCall(200, self, function( )
            if self._updateAnim ~= nil then
                self._updateAnim = true
                self._tableView:reloadData()
            end
        end)

    end})
end

function PrivilegesView:getWages()
    local flag = false
    if flag == true then
        self._viewMgr:showTip(lang("TIPS_UI_DES_10"))
    else
        self._serverMgr:sendMsg("PrivilegesServer", "getWages", {}, true, {}, function(result)
            dump(result)
            self:getWagesFinish(result)
        end)
    end
end

function PrivilegesView:getWagesFinish(result)
    self:reflashUI()
    
    if result.reward then
        DialogUtils.showGiftGet( {
            gifts = result.reward,
            title = lang("FINISHSTAGETITLE"),
            callback = function()
        end})
    end
end

function PrivilegesView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

function PrivilegesView:onBeforeAdd(callback, errorCallback)
    local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    if privilegesModel:isEmpty() then
        self._onBeforeAddCallback = function(inType)
            if inType == 1 then 
                callback()
            else
                errorCallback()
            end
        end
        self:getPrivilegeInfo()
    else
        self:reflashUI()
        callback()
    end
end

function PrivilegesView:getPrivilegeInfo()
    self._serverMgr:sendMsg("PrivilegesServer", "getPrivilegeInfo", {}, true, {}, function (result)
        self:getPrivilegesInfoFinish(result)
    end)
end

function PrivilegesView:getPrivilegesInfoFinish(result)
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
end

function PrivilegesView:getAsyncRes()
    return  
        { 
            {"asset/ui/privileges.plist", "asset/ui/privileges.png"},
            {"asset/ui/privileges1.plist", "asset/ui/privileges1.png"},
            {"asset/ui/privileges2.plist", "asset/ui/privileges2.png"},
        }
end

function PrivilegesView:getBgName()
    return "bg_002.jpg"
end

function PrivilegesView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true},nil, ADOPT_IPHONEX and self.fixMaxWidth or self._privilegeWidth)
end

function PrivilegesView:getShopOpen()
    local templevelNum, tempMaxLevel = self:isUpPeerage(1)
    -- print("flag============", templevelNum, tempMaxLevel)
    if templevelNum == tempMaxLevel and self._nowPeerage == 10 then
        print("open============")
        return true
    end
    return false
end

function PrivilegesView:getShopInfo()
    self._serverMgr:sendMsg("PrivilegesServer", "getShopInfo", {}, true, {}, function (result)
        local callback = function()
            self._clickShop = false
        end
        self._viewMgr:showDialog("privileges.PrivilegesShopDialog", {callback = callback})
    end)
end

function PrivilegesView:showPrivilegesBuffTip(inView)
    -- local inView = self:getUI("bg.tableViewBg.privilegesTip")
    inView:setVisible(true)
    -- local shopData = self._privilegeModel:getShopData()
    -- dump(shopData)
    local buffSum = {}
    local tbuffNum = tab:Setting("G_PRIVILEGES_SHOP_BUFF_NUM").value
    for i=1,tbuffNum do
        local buffIcon = inView:getChildByName("buffIcon" .. i)
        if buffIcon then
            buffIcon:setVisible(false)
        end
        local richText = inView:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        local flag, buffId = self._privilegeModel:getKingBuff(i)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        if flag == true then
            table.insert(buffSum, i)
        end
    end

    local posY = table.nums(buffSum)*38 + 20
    inView:setContentSize(cc.size(220, posY))
    posY = posY - 10
    for i=1,table.nums(buffSum) do
        local indexId = buffSum[i]
        local flag, buffId = self._privilegeModel:getKingBuff(indexId)
        local buffNum = tonumber(buffId)
        local buffTab = tab:PeerShop(buffNum)
        local param = {image = buffTab.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
        local buffIcon = inView:getChildByName("buffIcon" .. i)
        if buffIcon then
            IconUtils:updatePeerageIconByView(buffIcon, param)
        else
            buffIcon = IconUtils:createPeerageIconById(param)
            buffIcon:setAnchorPoint(0.5, 0.5)
            buffIcon:setScale(0.3)
            buffIcon:setName("buffIcon" .. i)
            inView:addChild(buffIcon)
        end
        buffIcon:setPosition(35,posY - i*38 + 18)
        buffIcon:setVisible(true)

        local sysBuf = buffTab.buff
        local str = lang(buffTab.des)
        str = self:tsplit(str, sysBuf[2])
        local result, count = string.gsub(str, "$num", sysBuf[2])
        if count > 0 then 
            str = result
        end
        local richText = inView:getChildByName("richText" .. i)
        if richText then
            richText:removeFromParent()
        end
        richText = RichTextFactory:create(str, 180, 40)
        richText:formatText()
        richText:setPosition(140, posY - i*38 + 18)
        richText:setName("richText" .. i)
        inView:addChild(richText)
    end
end

function PrivilegesView:tsplit(str,reps)
    local des = string.gsub(str,"%b{}",function( lvStr )
        local str = string.gsub(lvStr,"%$num",reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    return des 
end

return PrivilegesView