--[[
    Filename:    CityBattleReadyBuildDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-22 17:22:54
    Description: File description
--]]

local CityBattleReadyBuildDialog = class("CityBattleReadyBuildDialog",BasePopView)

local serverOpenDay
function CityBattleReadyBuildDialog:ctor(param)
    CityBattleReadyBuildDialog.super.ctor(self)
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._curBuffId = param.id
    self._tabData = tab:CityBattlePrepare(self._curBuffId)
    self._callBack = param.callback
    serverOpenDay = math.ceil(self._userModel:getOpenServerTime()/86400) 
    self._sec = tostring(self._cityBattleModel:getMineSec())

end



function CityBattleReadyBuildDialog:onInit()
    -- self:setListenReflashWithParam(true)
    self:listenReflash("CityBattleModel", self.onModelReflash)

    local bg = self:getUI("bg")
    self._bg = bg
    self._iconPanel = bg:getChildByFullName("iconPanel")
    self._levelLabel = bg:getChildByFullName("levelBg.level")
    self._curImage = bg:getChildByFullName("curImage")
    self._nextImage = bg:getChildByFullName("nextImage")
    self._curAdd = bg:getChildByFullName("curAdd")
    self._nextAdd = bg:getChildByFullName("nextAdd")
    self._addFlag = bg:getChildByFullName("up")
    self._processBar = bg:getChildByFullName("bar")
    self._processBar:setPositionX(self._processBar:getPositionX()+4)
    self._processLabel = bg:getChildByFullName("barLabel")
    self._processLabel:setPositionX(self._processLabel:getPositionX()+4)
    self._processLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local barBg = bg:getChildByFullName("barBg")
    barBg:setPositionX(barBg:getPositionX()+4)
    local barFrame = bg:getChildByFullName("barFrame")
    barFrame:setPositionX(barFrame:getPositionX()+4)
    self._processLevelLabel = bg:getChildByFullName("level")
    self._buildOne = bg:getChildByFullName("build_one")
    self._buildTen = bg:getChildByFullName("build_ten")
    self._title = bg:getChildByFullName("titleBg.titleTxt")
    local closeBtn = bg:getChildByFullName("close")

    self:registerClickEvent(closeBtn, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleReadyBuildDialog")
        end
        if self._callBack then
            self._callBack()
        end
        self:close()
    end)

    self:registerClickEvent(self._buildOne, function()
        self:onBuild(1)
    end)

    self:registerClickEvent(self._buildTen, function()
        self._isBuildTen = true
        self:onBuild(10)
    end)
    -- local buffIcon = {"citybattle_icon_junliang","citybattle_icon_chengqiang","citybattle_icon_yongbing","citybattle_icon_bingliang2","citybattle_icon_xingzhou","citybattle_icon_zhenli"}
    self._curImage:loadTexture(self._tabData.attrart .. ".png",1)
    self._nextImage:loadTexture(self._tabData.attrart .. ".png",1)
    self:setListenReflashWithParam(true)
    self:listenReflash("CityBattleModel", self.listenModel)

    

    self._title:setString(lang(self._tabData.name))
    self._maxlLabel = self:getUI("bg.MaxLabel")
    self._maxlLabel:setVisible(false)
    self:refreshUI()
end

function CityBattleReadyBuildDialog:listenModel(inType)
    if not inType then return end

    if inType == "ReadyDataChange" then
        local times = self._cityBattleModel:getLeftBuildTimes()
        timeOne:setString(times.."/1")
        if times >= 1 then
            timeOne:setColor(UIUtils.colorTable.ccUIBaseColor9)
        else
            timeOne:setColor(UIUtils.colorTable.ccUIBaseColor6)
        end

        
        timeTen:setString(times.."/10")
        if times >= 10 then
            timeTen:setColor(UIUtils.colorTable.ccUIBaseColor9)
        else
            timeTen:setColor(UIUtils.colorTable.ccUIBaseColor6)
        end
    end
end

function CityBattleReadyBuildDialog:onModelReflash()
    self:refreshUI()
end

function CityBattleReadyBuildDialog:onBuild(num)
    local status = self._cityBattleModel:getReadBuildStatus()
    if status then
        self._viewMgr:showTip(lang("CITYBATTLE_TIP_13"))
        return
    end

    local times = self._cityBattleModel:getLeftBuildTimes()
    if times < num then
        -- self._viewMgr:showTip("剩余建造次数不足")
        self._viewMgr:showDialog("global.GlobalPromptDialog", {indexId = 12})
        return
    end
    local param = {id = self._curBuffId, num = num}
    self._serverMgr:sendMsg("CityBattleServer", "donate", param, true, {}, function (result)
        -- dump(result, "CityBattleReadyBuildDialog.result", 10)
        -- self:refreshUI()
        self:playAnima()
    end)
end

function CityBattleReadyBuildDialog:playAnima()
    if self._bg:getChildByName("chengchijianzhao") then
        self._bg:removeChildByName("chengchijianzhao")
    end
    local mc1 = mcMgr:createViewMC("chengchijianzhao_kaiqi", false, true)
    mc1:setPosition(cc.p(self._iconPanel:getPositionX()+self._iconPanel:getContentSize().width-6,self._iconPanel:getPositionY()+self._iconPanel:getContentSize().height-30))
    mc1:setName("chengchijianzhao")
    self._bg:addChild(mc1,100)
end

function CityBattleReadyBuildDialog:getCurLvlAndExp(id,exp)
    print("getCurLvlAndExp",id,exp)
    local tabData = tab:CityBattlePrepare(id)
    -- dump(tabData,"aaaa",10)
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
    return leftExp,lvl
end

function CityBattleReadyBuildDialog:getLevelBg(level)
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

function CityBattleReadyBuildDialog:refreshUI()
    local isMax
    local exp_ = self._cityBattleModel:getReadlyData()[self._sec]["e"..self._curBuffId] or 0
    local curlExp,curLevel = self:getCurLvlAndExp(self._curBuffId,tonumber(exp_))
    local isLevelUp = false
    if not self._curLevel then
        self._curLevel = curLevel
    else
        if self._curLevel ~= curLevel then
            isLevelUp = true
            self._curLevel = curLevel
        end
    end

    if curLevel >= 10 then
        isMax = true
    end
    self._levelLabel:setString("+"..curLevel)
    self._levelLabel:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    local buildTab = self._tabData
    local addResult

    local factors = 0
    for i=1,curLevel do 
        factors = factors + buildTab.factor[i]
    end
    local partKey  = self._cityBattleModel:getMinOpenDayKey()
    factors = factors * buildTab["part"..partKey]
    local buff_des =  lang(buildTab.des)
    local result,success = string.gsub(buff_des,"{$factor100}",factors*100)
    if success == 0 then
        result = string.gsub(buff_des,"{$factor}",factors)
        if isLevelUp then
            addResult = string.gsub(buff_des,"{$factor}",factors-self._oldFactors)
        end
        self._oldFactors = factors
    else
        if isLevelUp then
            addResult = string.gsub(buff_des,"{$factor100}",factors*100-self._oldFactors)
        end
        self._oldFactors = factors*100
    end
    self._curAdd:setString(result)

    --buff 描述
    if not isMax then
        --next buff
        factors = 0
        for i=1,curLevel+1 do 
            factors = factors + buildTab.factor[i]
        end
        factors = factors * buildTab["part"..partKey]
        local result,success = string.gsub(buff_des,"{$factor100}",factors*100)
        if success == 0 then
            result = string.gsub(buff_des,"{$factor}",factors)
        end
        self._nextAdd:setString(result)
    end
    

    --进度条
    local curLevelMaxExp = buildTab.exp[curLevel]
    if isMax then
        curLevelMaxExp = buildTab.exp[curLevel-1]
        -- self._processBar:setPercent(100)
        self:barAnima(false,100)
        -- self._processLabel:setString(curLevelMaxExp .. "/" .. curLevelMaxExp)
        self._processLabel:setString("max")
        self._processLevelLabel:setString("Lv.".. curLevel)
    else
        self._processLevelLabel:setString("Lv.".. curLevel)
        local percent = curlExp * 100 / curLevelMaxExp
        -- self._processBar:setPercent(percent)
        self:barAnima(isLevelUp,percent)
        self._processLabel:setString(curlExp .. "/" .. curLevelMaxExp)
    end
    local timeOne = self:getUI("bg.timeOne")
    local timeTen = self:getUI("bg.timeTen")
    local runIcon = self:getUI("bg.runIcon")
    if isMax then
        -- self._buildOne:setVisible(false)
        -- self._buildTen:setVisible(false)
        -- self._maxlLabel:setVisible(true)
        -- timeOne:setVisible(false)
        -- timeTen:setVisible(false)
        local nextDes = self:getUI("bg.nextDes")
        nextDes:setVisible(false)
        self._nextImage:setVisible(false)
        self._nextAdd:setVisible(false)
        local up = self:getUI("bg.up")
        up:setVisible(false)
        self:addMaxImage(runIcon)
    end

    local times = self._cityBattleModel:getLeftBuildTimes()
    
    timeOne:setString(times.."/1")
    if times >= 1 then
        timeOne:setColor(UIUtils.colorTable.ccUIBaseColor9)
    else
        timeOne:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end

    
    timeTen:setString(times.."/10")
    if times >= 10 then
        timeTen:setColor(UIUtils.colorTable.ccUIBaseColor9)
    else
        timeTen:setColor(UIUtils.colorTable.ccUIBaseColor6)
    end
    
    local levelBg = self:getUI("bg.levelBg")
    local image = self:getLevelBg(curLevel)
    if image then
        levelBg:loadTexture(image,1)
    end

    local param = {readlyIcon = "citybattle_prepare_" .. self._curBuffId .. ".jpg",level = curLevel}

    local buildIcon = self._iconPanel:getChildByName("buildIcon")
    if not buildIcon then
        buildIcon = IconUtils:createReadlyIconById(param)
        buildIcon:setPosition(self._iconPanel:getContentSize().width/2,self._iconPanel:getContentSize().height/2)
        buildIcon:setAnchorPoint(cc.p(0.5, 0.5))
        self._iconPanel:addChild(buildIcon, 10)
        buildIcon:setName("buildIcon")
    else
        IconUtils:updateReadlyIconByIcon(buildIcon,param)
    end
    if addResult then
        self:buildLevelUp(addResult)
    end
    
end

function CityBattleReadyBuildDialog:addMaxImage(node)
    if node:getChildByName("city_max") then
        return
    end
    local MaxImage = cc.Sprite:createWithSpriteFrameName("city_level_max.png")
    MaxImage:setPosition(node:getContentSize().width/2,node:getContentSize().height/2)
    node:addChild(MaxImage,2)
    MaxImage:setName("city_max")

    local label = cc.Label:createWithTTF(lang("CITYBATTLE_TIP_35"), UIUtils.ttfName, 16)
    local bg = self:getUI("bg")
    bg:addChild(label)
    label:setColor(cc.c3b(138,92,29))
    label:setPosition(bg:getContentSize().width/2,bg:getContentSize().height/2+5)
    self._processBar:loadTexture("globalImageUI12_progress2.png",1)
    -- local MaxImagebg = cc.Sprite:createWithSpriteFrameName("city_level_maxbg.png")
    -- -- MaxImagebg:setPosition(buildBtn:getPositionX(),buildBtn:getPositionY())
    -- node:addChild(MaxImagebg)
    -- MaxImagebg:setName("city_maxbg")
end

function CityBattleReadyBuildDialog:barAnima(isLevelUp,percent)
    self:barEffect()
    if not self._isBuildTen then
        self._processBar:setPercent(percent)
        return
    end
    local curentPer = self._processBar:getPercent()
    if isLevelUp then
        self._processBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            if curentPer + 1 <= 100 then
                curentPer = curentPer +1
                self._processBar:setPercent(curentPer)
            else
                self._processBar:stopAllActions()
                curentPer = 0
                self._processBar:setPercent(0)
                self._processBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
                    if curentPer + 1 <= percent then
                        curentPer = curentPer +1
                        self._processBar:setPercent(curentPer)
                    else
                        self._processBar:stopAllActions()
                    end
                end), cc.DelayTime:create(0))))
            end
        end), cc.DelayTime:create(0))))
    else
        self._processBar:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function()
            if curentPer + 1 <= percent then
                curentPer = curentPer +1
                self._processBar:setPercent(curentPer)
            else
                self._processBar:stopAllActions()
            end
            
        end), cc.DelayTime:create(0))))
    end
    self._isBuildTen = false

end

function CityBattleReadyBuildDialog:barEffect()
    -- local mc1 = mcMgr:createViewMC("tiaomanzhuangtai_herospellstudyanim", false, true)
    -- mc1:setPosition(cc.p(self._processBar:getContentSize().width/2-5,self._processBar:getContentSize().height))
    -- mc1:setScaleX(0.34)
    -- self._processBar:addChild(mc1,100)
end

-- function CityBattleReadyBuildDialog:getPartKey()
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


function CityBattleReadyBuildDialog:buildLevelUp(addStr)
    local runeIcon = self:getUI("bg.runIcon")

    self:teamPiaoNature(0.5, runeIcon, 1)
    self:teamPiaoNature1(addStr)
end

--[[
--! @function teamPiaoNature
--! @desc 点击道具飘字
--! @param param 飘字列表
--! @param count 飘字 
--! @return 
--]]
function CityBattleReadyBuildDialog:teamPiaoNature(time, runeIcon, str)
    -- if str == 1 then
    --     str = "teamImageUI_img24"
    -- else
    --     str = "teamImageUI_img25"
    -- end
    str = "citybattle_jinjie"

    local natureLab = runeIcon:getChildByName("natureLab")
    if natureLab then
        natureLab:stopAllActions()
        natureLab:removeFromParent()
    end
    natureLab = cc.Sprite:create() 
    natureLab:setSpriteFrame(str .. ".png")
    natureLab:setName("natureLab")
    natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5))
    natureLab:setOpacity(0)
    runeIcon:addChild(natureLab,100)

    local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2), 
        cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
        cc.MoveBy:create(0.38, cc.p(0,17)),
        cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
        cc.RemoveSelf:create(true))
    natureLab:runAction(seqnature)
end

function CityBattleReadyBuildDialog:teamPiaoNature1(addStr)
    local runeIcon = self:getUI("bg.runIcon")
    local param = {}
    param[1] = addStr
    for i=1,1 do
        local natureLab = runeIcon:getChildByName("natureLab" .. i)
        if natureLab then
            natureLab:stopAllActions()
            natureLab:removeFromParent()
        end
        natureLab = cc.Label:createWithTTF(param[i], UIUtils.ttfName, 24)
        natureLab:setName("natureLab" .. i)
        natureLab:setColor(UIUtils.colorTable.ccColorQuality2)
        natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        natureLab:setPosition(cc.p(runeIcon:getContentSize().width*0.5, runeIcon:getContentSize().height*0.5-35*i - 10))
        natureLab:setOpacity(0)
        runeIcon:addChild(natureLab,100)

        local seqnature = cc.Sequence:create(cc.ScaleTo:create(0, 0.2), cc.DelayTime:create(0.2+0.1*i), 
            cc.Spawn:create(cc.ScaleTo:create(0.2, 1),cc.FadeIn:create(0.2),cc.MoveBy:create(0.2, cc.p(0,38))), 
            cc.MoveBy:create(0.38, cc.p(0,17)),
            cc.Spawn:create(cc.MoveBy:create(0.4, cc.p(0,10)),cc.FadeOut:create(0.7)),
            cc.RemoveSelf:create(true))
        natureLab:runAction(seqnature)
    end
end

function CityBattleReadyBuildDialog:dtor()
    serverOpenDay = nil
end

return CityBattleReadyBuildDialog