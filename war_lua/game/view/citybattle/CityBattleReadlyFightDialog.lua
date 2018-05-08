--[[
    Filename:    CityBattleReadlyFightDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-11-29 16:35:37
    Description: File description
--]]

-- GVG 备战
local CityBattleReadlyFightDialog = class("CityBattleReadlyFightDialog", BasePopView)
local drawLeida = CityBattleUtils.drawLeidaNew
local updateDrawLeida = CityBattleUtils.updateDrawLeidaNew
local readlyImage = CityBattleUtils.readlyImage

local CLIPNODE = cc.ClippingNode
local Sprite   = cc.Sprite
local panelCX
local panelCY
local PanleW
local PanleH
local _drawPanel
local serverOpenDay --开服时间
local _readyData 
local _readyBuffLevel

function CityBattleReadlyFightDialog:ctor(param)
    CityBattleReadlyFightDialog.super.ctor(self)
    self._userModel = self._modelMgr:getModel("UserModel")
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    serverOpenDay = math.ceil(self._userModel:getOpenServerTime()/86400) 
    self._sec = tostring(self._cityBattleModel:getMineSec())
    self._callBack = param and param.callBack
    self:updateData()
end

function CityBattleReadlyFightDialog:updateData()
    _readyData = self._cityBattleModel:getReadlyData()[self._sec]
    _readyBuffLevel = self._cityBattleModel:getReadlyLevel(self._sec)

    self._richText1 = lang("CITYBATTLE_TIP_02")
    self._richText2 = lang("CITYBATTLE_TIP_03") 
end

function CityBattleReadlyFightDialog:getAsyncRes()
    return 
    {
        "asset/bg/golbalIamgeUI5_hintBg.png",
    }
end

function CityBattleReadlyFightDialog:onInit()
    local image_bg = self:getUI("bg.image_bg")
    image_bg:loadTexture("asset/bg/golbalIamgeUI5_hintBg.png")

    _drawPanel = self:getUI("bg.leidaPanel")
    PanleW = _drawPanel:getContentSize().width
    PanleH = _drawPanel:getContentSize().height
    panelCX = PanleW/2
    panelCY = PanleH/2

    local tipsPanel = self:getUI("bg.tipsPanel")
    tipsPanel:setVisible(false)
    local tipsFrame = tipsPanel:getChildByFullName("leidaPanel.frame")
    if tipsFrame then
        tipsFrame:setVisible(false)
    end
    self:registerClickEvent(_drawPanel,function()
        if not tipsPanel:isVisible() then
            tipsPanel:setVisible(true)
            self:updateTips(tipsPanel,_readyBuffLevel)
        else
            tipsPanel:setVisible(false)
        end
    end)
    local middleFrame = _drawPanel:getChildByFullName("frame")
    if middleFrame then
        middleFrame:setVisible(false)
    end

    -- local mask = cc.Sprite:createWithSpriteFrameName("battleBtn_clipNode1.png")  --遮罩
    -- mask:setPosition(cc.p(self._btnBattle:getContentSize().width/2, self._btnBattle:getContentSize().height/2))
    -- clipNode:setStencil(mask)  
    -- clipNode:setAlphaThreshold(0.01)
    -- clipNode:addChild(amin)  
    -- clipNode:setAnchorPoint(cc.p(0, 0))
    -- clipNode:setPosition(0, 0)



    -- self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    -- self._readlyData = self._cityBattleModel:getReadlyData()
    self:registerClickEventByName("bg.close", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleReadlyFightDialog")
        end
        if self._callBack then
            self._callBack()
        end
        self:close()
    end)
    -- -- local burst = self:getUI("bg.layer.burst")

    -- local title = self:getUI("bg.mainBg.titleBg.title")
    -- title:setFontName(UIUtils.ttfName)
    -- title:setFontSize(30)

    local title_btn = self:getUI("bg.title_btn")
    self:registerClickEvent(title_btn, function()
        self._viewMgr:showDialog("citybattle.CityBattleReadyRuleDialog",{},false)
    end)


    -- for i=1,6 do
    --     local icon = self:getUI("bg.mainBg.leftPanel.leidaPanel.icon" .. i)
    --     icon:setScale(0.8)
    --     icon:loadTexture(readlyImage[i], 1)
    -- end

    -- self._leftPanel = self:getUI("bg.mainBg.leftPanel")
    -- self._leidaPanel = self:getUI("bg.mainBg.leftPanel.leidaPanel")
    -- self._huoyueValue = self:getUI("bg.mainBg.leftPanel.huoyueValue")

    -- -- self:updateLeftPanel()

    -- self._buildCell = self:getUI("buildCell")
    -- self._buildCell:setVisible(false)

    -- self:addTableView()
    self._reward_panel = self:getUI("bg.reward_panel")
    self._leftCountLabel = self:getUI("bg.leidaPanel.image_layer.leftCount")
    self._leftCountLabel:setPositionX(self._leftCountLabel:getPositionX()+2)
    local leftDesLable = self:getUI("bg.leidaPanel.image_layer.left1")
    leftDesLable:setString("可建造次数:")
    self._haveBuildLable = self:getUI("bg.reward_panel.times")
    self._costTili = self:getUI("bg.leidaPanel.image_layer.costTili")
    for i=1,5 do 
        self["reward_box"..i] = self:getUI("bg.reward_panel.box_" .. i)
        self["box_num"..i] = self:getUI("bg.reward_panel.num"..i)
    end
    self._processBoxBar = self:getUI("bg.reward_panel.ProgressBar_115")

    self:updateLeiDa()

    self:initBuffView()

    self:updateRewardView()

    self._isStopBuild = false
    local leftTime = self:getUI("bg.leidaPanel.image_layer.leftTime")
    local curServerTime = self._userModel:getCurServerTime()
    local s1OverTime,s2OverTime,s3OverTime,s4OverTime,s5OverTime,s6OverTime = self._cityBattleModel:getOverTime()
    -- local weekday = TimeUtils.date("%w", curServerTime)
    -- local currTime = curServerTime + 86400*(6-weekday)
    -- local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(currTime,"%Y-%m-%d 20:45:00"))
    CityBattleUtils:setCountDown(leftTime, s1OverTime-curServerTime, "距离备战结束剩余", function()
        print("over")
        self._cityBattleModel:setReadyBuild(true)
        self._isStopBuild = true
    end)

    self:setListenReflashWithParam(true)
    self:listenReflash("CityBattleModel", self.listenModel)
end

function CityBattleReadlyFightDialog:listenModel(inType)
    if not inType then return end
    if inType == "ReadyDataChange" then
        self._leftBuildTimes = self._cityBattleModel:getLeftBuildTimes() or 0
        self._leftCountLabel:setString(self._leftBuildTimes)
        local haveBuild = self._cityBattleModel:getHaveBuildTimes() or 0
        local r = self._cityBattleModel:getGVGUserData().r or 0
        r = haveBuild*100 +r
        self._costTili:setString("本周已累计消耗体力:"..r)
    end
end

function CityBattleReadlyFightDialog:updateTips(tipsPanel,levels)
    local levels = _readyBuffLevel
    local leidaPanel =tipsPanel:getChildByFullName("leidaPanel")
    local panelCX = leidaPanel:getContentSize().width/2
    local panelCY = leidaPanel:getContentSize().height/2
    local points
    if not tipsPanel._drawNode then
        tipsPanel._drawNode,points = drawLeida(levels,panelCX,panelCY,6,6)
    else
        points = updateDrawLeida(tipsPanel._drawNode,levels,panelCX,panelCY,6,6)
    end

    if not tipsPanel._clipNode then
        tipsPanel._clipNode = CLIPNODE:create()   
        tipsPanel._clipNode:setContentSize(panelCX*2,panelCY*2)
        tipsPanel._clipNode:setStencil(tipsPanel._drawNode)
        leidaPanel:addChild(tipsPanel._clipNode)
    end

    if not tipsPanel._drawMask then
        tipsPanel._drawMask = Sprite:createWithSpriteFrameName("citybattle_leida_mask.png")
        tipsPanel._drawMask:setPosition(panelCX,panelCY)
        tipsPanel._drawMask:getTexture():setAntiAliasTexParameters()
        tipsPanel._drawMask:setOpacity(180)
        tipsPanel._clipNode:addChild(tipsPanel._drawMask)
        tipsPanel._clipNode:setInverted(false) 
    end

    if leidaPanel:getChildByName("point_1") then
        for key,point in pairs (points) do 
            local pointImgae = leidaPanel:getChildByName("point_"..key)
            pointImgae:setPosition(point)
        end
    else
        for key,point in pairs (points) do 
            local imagePoint = cc.Sprite:createWithSpriteFrameName("citybattle_point.png")
            imagePoint:setPosition(point)
            leidaPanel:addChild(imagePoint)
            imagePoint:setName("point_"..key)
        end
    end

    local closePanel = tipsPanel:getChildByFullName("closePanel")
    closePanel:setContentSize(MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT)
    local point = tipsPanel:convertToNodeSpace(cc.p(0,0))
    closePanel:setPosition(point)
    -- closePanel:setPosition(-MAX_SCREEN_WIDTH/2,-MAX_SCREEN_HEIGHT/2)
    self:registerClickEvent(closePanel,function()
        tipsPanel:setVisible(false)
    end)

    local testData = _readyData
    local partKey  = self._cityBattleModel:getMinOpenDayKey()
    local attrPanel = tipsPanel:getChildByFullName("attrPanel")
    for i=1,6 do 
        local exp,level = self:getCurLvlAndExp(i,tonumber(testData["e"..i]))
        local buildTab  = tab:CityBattlePrepare(i)
        --buff 描述
        local factors = 0
        for i=1,level do 
            factors = factors + buildTab.factor[i]
        end
        factors = factors * buildTab["part"..partKey]
        local buff_des =  lang(buildTab.des)
        local result,success = string.gsub(buff_des,"{$factor100}",factors*100)
        if success == 0 then
            result = string.gsub(buff_des,"{$factor}",factors)
        end
        local index1 = string.find(result,"+")
        local sub1 = string.sub(result,1,index1-1)
        local sub2 = string.sub(result,index1,string.len(result))
        local attrName = attrPanel:getChildByFullName("attr".. i ..".attrName")
        local attrNum = attrPanel:getChildByFullName("attr".. i .. ".attrNum")
        attrName:setString(sub1)
        attrNum:setString(sub2)
    end
end


function CityBattleReadlyFightDialog:updateLeiDa()
    local levels = _readyBuffLevel
    -- levels = {5,1,10,10,10,10}
    local points
    if not self._drawNode then
        print("CityBattleReadlyFightDialog:updateLeiDa 1")
        self._drawNode,points= drawLeida(levels,panelCX,panelCY,6,6,42)
    else
        print("CityBattleReadlyFightDialog:updateLeiDa 2")
        points = updateDrawLeida(self._drawNode,levels,panelCX,panelCY,6,6,42)
    end
    print("CityBattleReadlyFightDialog:updateLeiDa 3")
    if not self._clipNode then
        print("CityBattleReadlyFightDialog:updateLeiDa 4")
        self._clipNode = CLIPNODE:create()   
        self._clipNode:setContentSize(panelCX*2,panelCY*2)
        self._clipNode:setStencil(self._drawNode)
        _drawPanel:addChild(self._clipNode)
    end

    if _drawPanel:getChildByName("point_1") then
        for key,point in pairs (points) do 
            local pointImgae = _drawPanel:getChildByName("point_"..key)
            pointImgae:setPosition(point)
        end
    else
        for key,point in pairs (points) do 
            local imagePoint = cc.Sprite:createWithSpriteFrameName("citybattle_point.png")
            imagePoint:setPosition(point)
            _drawPanel:addChild(imagePoint)
            imagePoint:setName("point_"..key)
        end
    end
    print("CityBattleReadlyFightDialog:updateLeiDa 5")
    if not self._drawMask then
        print("CityBattleReadlyFightDialog:updateLeiDa 6")
        self._drawMask = Sprite:createWithSpriteFrameName("citybattle_leida_mask.png")
        self._drawMask:setPosition(panelCX,panelCY)
        self._drawMask:getTexture():setAntiAliasTexParameters()
        self._drawMask:setOpacity(180)
        self._clipNode:addChild(self._drawMask)
        self._clipNode:setInverted(false) 
    end
    print("CityBattleReadlyFightDialog:updateLeiDa 7")
end

function CityBattleReadlyFightDialog:getCurLvlAndExp(id,exp)
    local tabData = tab:CityBattlePrepare(id)
    local tabExp = tabData.exp
    local lvlLimit = tabData.maxlv 
    local lvl = 1
    local n = 1
    local needExp = 0
    local leftExp = exp
    while true do 
        if lvl + 1 > lvlLimit then
            break
        end
        needExp = needExp + tabExp[n]
        print(exp,needExp)
        if exp >= needExp then
            lvl = lvl + 1
            leftExp = leftExp - tabExp[n]
        else
            break
        end
        n = n + 1
    end
    print("leftExp",leftExp,"lvl",lvl)
    return leftExp,lvl
end

function CityBattleReadlyFightDialog:getLevelBg(level)
    local tabData = tab:Setting("G_CITYBATTLE_PREPARE_COLOR").value
    local level = level or 1
    local quality = 1
    if level >= tabData[1] and level < tabData[2] then
        quality = 1
    elseif level >=tabData[2] and level < tabData[3] then
        quality = 2
    elseif level >= tabData[3] and  level < tabData[4] then
        quality = 3
    elseif level >=tabData[4] and  level < tabData[5] then
        quality = 4
    else
        quality = 5
    end
    if quality == 1 then
        return "city_quality.png"
    else  
        return "globalImageUI4_iquality" .. quality .. ".png"
    end
end

function CityBattleReadlyFightDialog:checkIsOpen(data)
    local needWeek = data[1]
    local needHour = data[2]
    local needMin = data[3]

    local curServerTime = self._userModel:getCurServerTime()
    local t = TimeUtils.date("*t", curServerTime)
    local curWeek = t.wday
    if curWeek == 1 then
        curWeek = 8
    end
    local needTime = (needWeek+1-curWeek)*86400+curServerTime
    return needTime <= curServerTime
end

function CityBattleReadlyFightDialog:initBuffView()
    local testData = _readyData
    dump(testData)
    -- local buffIcon = {"citybattle_icon_junliang","citybattle_icon_chengqiang","citybattle_icon_yongbing","citybattle_icon_bingliang2","citybattle_icon_xingzhou","citybattle_icon_zhenli"}
    local partKey  = self._cityBattleModel:getMinOpenDayKey()
    local curWeek  = self:getWeek()
    for i=1,6 do 
        local exp,level = self:getCurLvlAndExp(i,tonumber(testData["e"..i]))
        local buildTab  = tab:CityBattlePrepare(i)
        local buffPanle = self:getUI("bg.buffPanel" .. i)
        local icon      = buffPanle:getChildByFullName("icon")
        local param     = {readlyIcon = "citybattle_prepare_" .. i .. ".jpg",level = level} 
        local levelbg   = buffPanle:getChildByFullName("level_bg")
        local nameDes   = buffPanle:getChildByFullName("level_des")
        local buffDes   = buffPanle:getChildByFullName("buff_des")
        local bar       = buffPanle:getChildByFullName("bar")
        local buildBtn  = buffPanle:getChildByFullName("build")
        local buildTxt  = buildBtn:getChildByFullName("buildTxt")
        buildTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        buildBtn:setVisible(true)

        local buildIcon = icon:getChildByName("buildIcon")
        if not buildIcon then
            buildIcon = IconUtils:createReadlyIconById(param)
            buildIcon:setPosition(icon:getContentSize().width/2,icon:getContentSize().height/2)
            buildIcon:setAnchorPoint(cc.p(0.5, 0.5))
            icon:addChild(buildIcon, 10)
            buildIcon:setName("buildIcon")
        else
            IconUtils:updateReadlyIconByIcon(buildIcon,param)
        end
        local bufIcon   =  buffPanle:getChildByFullName("buffIcon")
        bufIcon:loadTexture(buildTab.attrart .. ".png",1) 
        
        local isOpen = true
        if buildTab.opentime and not self:checkIsOpen(buildTab.opentime) then --未开启
            local notOpen = Sprite:createWithSpriteFrameName("city_close.png")
            levelbg:setVisible(false)
            notOpen:setPosition(50,buffPanle:getContentSize().height/2)
            buffPanle:addChild(notOpen)
            notOpen:setName("city_close")
            self:setNodeColor(buffPanle,cc.c4b(128, 128, 128,255),-30)
            isOpen = false
        else
            local image = self:getLevelBg(level)
            if image then
                levelbg:loadTexture(image,1)
            end
            levelbg:setVisible(true)
            levelbg:getChildByFullName("lvl"):setString("+" .. level)
            levelbg:getChildByFullName("lvl"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            if buffPanle:getChildByName("city_close") then
                buffPanle:removeChildByName("city_close")
            end
            self:setNodeColor(buffPanle,cc.c4b(255,255,255,255),0)
        end

        --名称描述，等级描述
        local tabName = lang(buildTab.name)
        nameDes:setString(tabName .. level .. "级")

        --buff 描述
        local factors = 0
        for i=1,level do 
            factors = factors + buildTab.factor[i]
        end
        -- print("partKey",partKey)
        -- dump(buildTab)
        factors = factors * buildTab["part"..partKey]
        local buff_des =  lang(buildTab.des)
        local result,success = string.gsub(buff_des,"{$factor100}",factors*100)
        if success == 0 then
            result = string.gsub(buff_des,"{$factor}",factors)
        end
        print("result",result)
        buffDes:setString(result)

        --进度条
        local curLevelMaxExp = buildTab.exp[level]
        local percent = exp * 100 / curLevelMaxExp
        print(exp,curLevelMaxExp,percent)
        bar:setPercent(percent)
        local isMax = level >= 10 
        self:registerClickEvent(buildBtn, function()
            local param = {id = i,isMax = isMax,isOpen = isOpen}
            self:onBuild(param)
        end)
        if isMax then
            -- buildBtn:setVisible(false)
            -- local MaxImage = Sprite:createWithSpriteFrameName("city_level_max.png")
            -- MaxImage:setPosition(buildBtn:getPositionX(),buildBtn:getPositionY())
            -- buffPanle:addChild(MaxImage,2)
            -- MaxImage:setName("city_max")
            -- local MaxImagebg = Sprite:createWithSpriteFrameName("city_level_maxbg.png")
            -- MaxImagebg:setPosition(buildBtn:getPositionX(),buildBtn:getPositionY())
            -- buffPanle:addChild(MaxImagebg)
            -- MaxImagebg:setName("city_maxbg")
            bar:setPercent(100)
        else
            
            -- if buffPanle:getChildByName("city_max") then
            --     buffPanle:removeChildByName("city_max")
            -- end
            -- if buffPanle:getChildByName("city_maxbg") then
            --     buffPanle:removeChildByName("city_maxbg")
            -- end
        end
    end
end

function CityBattleReadlyFightDialog:getWeek()
    local serverTime = self._userModel:getCurServerTime()
    local curWeek = os.date("*t",serverTime).wday
    return curWeek
end

function CityBattleReadlyFightDialog:onBuild(param)
    if self._isStopBuild then
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_13"))
        return
    end
    if not param.isOpen then
        self._viewMgr:showTip("暂未开启")
        return
    end
    self._serverMgr:sendMsg("CityBattleServer", "getDonateInfo", {}, true, {}, function (result, error)
        self._viewMgr:showDialog("citybattle.CityBattleReadyBuildDialog",{id = param.id,callback = function()
            print("aaaaaaa")
            _readyBuffLevel = self._cityBattleModel:getReadlyLevel(self._sec)
            self:updateLeiDa()
            self:initBuffView()
            self:updateRewardView()        
        end},true)
    end)
end



-- function CityBattleReadlyFightDialog:getPartKey()
--     if serverOpenDay <= 30 then
--         return 0
--     elseif serverOpenDay > 30 and serverOpenDay <= 45 then 
--         return  1
--     elseif serverOpenDay > 45 and serverOpenDay <= 60 then
--         return 2
--     elseif serverOpenDay > 60 and serverOpenDay <= 75 then
--         return 3
--     else
--         return 4
--     end
-- end

-- self:setNodeColor(v, isBright and cc.c4b(255,255,255,255) or cc.c4b(128, 128, 128,255))
function CityBattleReadlyFightDialog:setNodeColor(node,color,num)  
    if node:getName() == "city_close" then return end
    if node:getName() == "city_maxbg" then return end
    if node:getName() == "city_max" then return end
    if node and not tolua.isnull(node) then 
        if node:getDescription() ~= "Label" then
            node:setColor(color)
        else
            node:setBrightness(num)
        end
    end
    local children = node:getChildren()
    if children == nil or #children == 0 then
        return 
    end
    for k,v in pairs(children) do
        self:setNodeColor(v,color,num)
    end
end


function CityBattleReadlyFightDialog:updateRewardView()
    self._leftBuildTimes = self._cityBattleModel:getLeftBuildTimes() or 0
    self._haveBuildTimes = self._cityBattleModel:getHaveBuildTimes() or 0
    self._rewardsData = self._cityBattleModel:getReadyRewardsData()
    local r = self._cityBattleModel:getGVGUserData().r or 0

    self._leftCountLabel:setString(self._leftBuildTimes)
    self._haveBuildLable:setString(self._haveBuildTimes)
    r = self._haveBuildTimes*100 + r
    self._costTili:setString("本周已累计消耗体力:"..r)
    local max = 50
    self._processBoxBar:setPercent(self._haveBuildTimes * 100 / max)

    local closeImage = {"box_1_n.png","box_1_n.png","box_2_n.png","box_2_n.png","box_3_n.png"}
    local openImage = {"box_1_p.png","box_1_p.png","box_2_p.png","box_2_p.png","box_3_p.png"}
    local mcName = {"baoxiang1_baoxiang","baoxiang1_baoxiang","baoxiang2_baoxiang","baoxiang2_baoxiang","baoxiang3_baoxiang"}

    local function showGiftGet(inBtnTitle,inRewards,canGet,desc)
        
        DialogUtils.showGiftGet( {
        gifts = inRewards,
        viewType = 1,
        canGet = canGet, 
        des = desc,
        title = "",
        btnTitle = inBtnTitle, 
        callback = function()

        end} )
    end

    local barWidth = self._reward_panel:getContentSize().width
    for i=1,5 do 
        local tabData = tab:CityBattlePrepareReward(i)
        local gift = tabData.reward
        local condition = tabData.limit
        local boxImage  = self["reward_box"..i]
        if boxImage:getChildByName("BoxMc") then
            boxImage:removeChildByName("BoxMc")
        end
        local boxNum = self["box_num"..i]
        if boxNum then
            boxNum:setString(condition)
            boxNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            print("sssss",barWidth*condition/50)
            boxNum:setPositionX(barWidth*condition/50)
            boxImage:setPositionX(barWidth*condition/50)
        end
        boxImage:setOpacity(255)

        if not self._cityBattleModel:checkIsGetById(i) then
            -- 未领取
            print("aaa",self._haveBuildTimes,condition)
            if self._haveBuildTimes >= condition then
                self:registerClickEvent(boxImage,function()
                    print("领取")
                    local param = {id = i}
                    self._serverMgr:sendMsg("CityBattleServer", "getDonateAward", param, true, {}, function (result)
                        self._cityBattleModel:updateReadyBoxDataAfterGet(i)
                        DialogUtils.showGiftGet({gifts = result.reward, notPop=true })
                        if boxImage:getChildByName("BoxMc") then
                            boxImage:removeChildByName("BoxMc")
                        end
                        boxImage:setOpacity(255)
                        boxImage:loadTexture(openImage[i],1)
                        self:registerClickEvent(boxImage,function()
                            local result = string.gsub(self._richText2, "$num1", condition)
                            result = string.gsub(result, "$num", self._haveBuildTimes)
                            showGiftGet("已领取",gift,false,result)
                        end)
                    end)
                end)
                local mc = mcMgr:createViewMC(mcName[i], true)
                boxImage:addChild(mc)
                boxImage:setOpacity(0)
                mc:setPosition(boxImage:getContentSize().width/2,boxImage:getContentSize().height/2)
                mc:setName("BoxMc")
            else
                self:registerClickEvent(boxImage,function()
                    local result = string.gsub(self._richText1, "$num1", condition)
                    result = string.gsub(result, "$num", self._haveBuildTimes)
                    showGiftGet(nil,gift,false,result)
                end)
            end
        else
            -- 已领取
            boxImage:loadTexture(openImage[i],1)
            self:registerClickEvent(boxImage,function()
                local result = string.gsub(self._richText2, "$num1", condition)
                result = string.gsub(result, "$num", self._haveBuildTimes)
                showGiftGet("已领取",gift,false,result)
            end)
        end
    end

end


-- -- 更新左侧窗口
-- function CityBattleReadlyFightDialog:updateLeftPanel()
--     local liuTemp2 = self._cityBattleModel:getReadlyLevel()
--     dump(liuTemp2, "liuTemp2===", 10)
--     if not self._drawPanel then
--         self._drawPanel = drawLeida({}, liuTemp2, self._leidaPanel:getContentSize().width*0.5, self._leidaPanel:getContentSize().height*0.5, 31)
--         self._leidaPanel:addChild(self._drawPanel)  
--     else
--         updateDrawLeida(self._drawPanel, {}, liuTemp2, self._leidaPanel:getContentSize().width*0.5, self._leidaPanel:getContentSize().height*0.5, 31)
--     end

--     local gvgUserData = self._cityBattleModel:getGVGUserData()
--     self._huoyueValue:setString(gvgUserData["r"] or 0)
-- end

function CityBattleReadlyFightDialog:reflashUI()
    -- self:updateLeftPanel()
    -- self._tableView:reloadData()
    -- dump(self._readlyData, "self._readlyData======")
end

-- --[[
-- 用tableview实现
-- --]]
-- function CityBattleReadlyFightDialog:addTableView()
--     print("==============+++")
--     local tableViewBg = self:getUI("bg.tableViewBg")
--     self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height-10))
--     self._tableView:setDelegate()
--     self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--     self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     self._tableView:setPosition(cc.p(0, 13))
--     self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
--     self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
--     self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
--     self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
--     self._tableView:setBounceable(false)
--     -- self._tableView:reloadData()
--     -- if self._tableView.setDragSlideable ~= nil then 
--     --     self._tableView:setDragSlideable(true)
--     -- end
--     -- self._tableView:reloadData()
--     tableViewBg:addChild(self._tableView)
-- end

-- -- 触摸时调用
-- function CityBattleReadlyFightDialog:tableCellTouched(table,cell)
-- end

-- -- cell的尺寸大小
-- function CityBattleReadlyFightDialog:cellSizeForTable(table,idx) 
--     local width = 550 
--     local height = 142
--     return height, width
-- end

-- -- 创建在某个位置的cell
-- function CityBattleReadlyFightDialog:tableCellAtIndex(table, idx)
--     local cell = table:dequeueCell()
--     local indexId = idx+1
--     if nil == cell then
--         cell = cc.TableViewCell:new()
--         for i=1,2 do
--             local buildCell = self._buildCell:clone() 
--             buildCell:setVisible(true)
--             buildCell:setAnchorPoint(cc.p(0,0))
--             buildCell:setPosition(cc.p(287*(i-1)+5, 0))
--             buildCell:setName("buildCell" .. i)
--             cell:addChild(buildCell)

--             local titleBg = buildCell:getChildByFullName("titleBg")
--             titleBg:setOpacity(150)

--             local title = buildCell:getChildByFullName("titleBg.title")
--             title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

--             local jianzaoBtn = buildCell:getChildByFullName("jianzaoBtn")
--             -- jianzaoBtn:setColor(UIUtils.colorTable.ccUICommonBtnColor3)
--             jianzaoBtn:setColor(UIUtils.colorTable.ccUICommonBtnColor3)
--             jianzaoBtn:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 1)
--         end

--         print("+++++111")
--         self:updateCell(cell, param, indexId)
--     else
--         print("+++++")
--         self:updateCell(cell, param, indexId)
--         -- local buildCell = cell:getChildByName("buildCell")
--         -- if buildCell then
--         --     self:updateCell(buildCell, param, indexId)
--         --     buildCell:setSwallowTouches(false)
--         -- end
--     end

--     return cell
-- end

-- -- 返回cell的数量
-- function CityBattleReadlyFightDialog:numberOfCellsInTableView(table)
--     return 3
-- end

-- -- 更新tableView数据
-- function CityBattleReadlyFightDialog:updateCell(cell, data, indexLine)
--     for i=1,2 do
--         local buildCell = cell:getChildByFullName("buildCell" .. i)
--         if buildCell then
--             local indexId = (indexLine-1)*2+i
--             self:updateBuildCell(buildCell, self._readlyData[indexId], indexId)
--         end
--     end
-- end

-- function CityBattleReadlyFightDialog:updateBuildCell(inView, nodeData, indexId)    
--     if not nodeData then
--         return
--     end

--     local buildTab = tab:CityBattlePrepare(indexId)
--     inView:setVisible(true)

--     local buildIcon = inView:getChildByName("buildIcon")
--     local param = {readlyIcon = "citybattle_prepare_" .. indexId .. ".png"} 
--     if buildIcon == nil then 
--         buildIcon = IconUtils:createReadlyIconById(param)
--         buildIcon:setName("buildIcon")
--         buildIcon:setPosition(8,32)
--         buildIcon:setAnchorPoint(cc.p(0, 0))
--         inView:addChild(buildIcon, 10)
--     else
--         IconUtils:updateReadlyIconByIcon(buildIcon, param)
--     end

--     local title = inView:getChildByFullName("titleBg.title")
--     if title then
--         title:setString(lang(buildTab["name"]))
--     end
--     local titleIcon = inView:getChildByFullName("titleBg.titleIcon")
--     if titleIcon then
--         titleIcon:loadTexture(readlyImage[indexId], 1)
--         titleIcon:setScale(0.6)
--     end

--     local shuxingLab = inView:getChildByFullName("shuxingLab")
--     if shuxingLab then
--         shuxingLab:setString(lang(buildTab["des"]) .. "+" .. nodeData["l"] .. "级")
--     end

--     local jianzaoBtn = inView:getChildByFullName("jianzaoBtn")
--     if jianzaoBtn then
--         self:registerClickEvent(jianzaoBtn, function()
--             print("建造 ===", indexId)
--             self:donate(indexId)
--         end)
--     end

--     local progress = inView:getChildByFullName("progressBg.progress")
--     if progress then
--         local str = 0
--         if buildTab["exp"][nodeData["l"]] then
--             str = nodeData["e"] / buildTab["exp"][nodeData["l"]] * 100
--         else
--             str = nodeData["e"] / buildTab["exp"][10] * 100
--         end
--         progress:setPercent(str)
--     end
-- end

-- function CityBattleReadlyFightDialog:donate(indexId)
--     local param = {id = indexId, num = 10}
--     self._serverMgr:sendMsg("CityBattleServer", "donate", param, true, {}, function (result)
--         dump(result, "result===", 10)
--         -- if self.donateFinish then
--         --     self:donateFinish(result)
--         -- end
        
--         self:reflashUI()
--     end)
-- end

-- function CityBattleReadlyFightDialog:donateFinish(result)
--     if result == nil then
--         return 
--     end
--     self:reflashUI()
-- end

function CityBattleReadlyFightDialog:dtor( ... )
    drawLeida = nil
    updateDrawLeida = nil
    readlyImage = nil
    CLIPNODE = nil
    Sprite = nil
    panelCX = nil
    panelCY = nil
    PanleW = nil
    PanleH = nil
    _drawPanel = nil
    serverOpenDay = nil
    _readyData = nil
    _readyBuffLevel = nil
end

return CityBattleReadlyFightDialog