--[[
    Filename:    CrusadeView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-20 18:03:22
    Description: File description
--]]


local CrusadeView = class("CrusadeView", BaseView)

require "game.view.crusade.CrusadeConst"
function CrusadeView:ctor()
    CrusadeView.super.ctor(self)
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
end

function CrusadeView:getAsyncRes()
    return  {
                {"asset/ui/crusade.plist", "asset/ui/crusade.png"},
                {"asset/ui/crusade1.plist", "asset/ui/crusade1.png"},
                {"asset/ui/crusade3.plist", "asset/ui/crusade3.png"},
            }
end

-- function CrusadeView:getBgName()
--     return "bg_001.jpg"
-- end


function CrusadeView:onBeforeAdd(callback, errorCallback)
    self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    if self._crusadeModel:isEmpty() then
        self._onBeforeAddCallback = function(inType)
            if inType == 1 then 
                callback()
            else
                errorCallback()
            end
        end
        self:getCrusadeInfo()
    else
        self:reflashUI()
        self:showTriggerCrusadeStatus()
        callback()
        self._lastClickTime = self._userModel:getCurServerTime()
        self:setMapResProg(1)   --左下角悬浮窗
        self:runFirstAnim()
    end
end

--topBar
function CrusadeView:setNavigation()
    local crusadeData = self._modelMgr:getModel("CrusadeModel"):getData()
    local hideInfo = false
    if crusadeData.isFirst == 1 then
        hideInfo = true
    end

    self._viewMgr:showNavigation("global.UserInfoView",{types= {"Gold","Gem","Crusading"}, hideInfo = hideInfo,  hideHead = true,},nil,ADOPT_IPHONEX and self.fixMaxWidth or nil)
end

function CrusadeView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end

function CrusadeView:onTop()
    self._viewMgr:enableScreenWidthBar()
    if self._widget:getChildByName("bgLayer") ~= nil then 
        self._widget:getChildByName("bgLayer"):removeFromParent()
        local bufferBg = self:getUI("bufferBg")
        bufferBg:setVisible(false)
        local buffBg = self:getUI("buffBg")
        buffBg:setVisible(false)

    end
    self._modelMgr:getModel("GuildRedModel"):checkRandRed()
end

function CrusadeView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end

function CrusadeView:onInit()
    self._crusadeModel = self._modelMgr:getModel("CrusadeModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    -- 屏幕点击检测layer
    self.clickLayer = ccui.Layout:create()
    self.clickLayer:setAnchorPoint(cc.p(0.5, 0.5))
    self.clickLayer:setBackGroundColorOpacity(0)
    self.clickLayer:setBackGroundColorType(1)
    self.clickLayer:setBackGroundColor(cc.c3b(100, 100, 0))
    self.clickLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self.clickLayer:setPosition(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5)
    self:addChild(self.clickLayer, 1)
    self:registerClickEvent(self.clickLayer, function()
        self._lastClickTime = self._userModel:getCurServerTime()
        end)
    self.clickLayer:setSwallowTouches(false)

    self.clickLayer:runAction(cc.RepeatForever:create( 
        cc.Sequence:create(
            cc.CallFunc:create(function()
                local disTime = self._userModel:getCurServerTime() - (self._lastClickTime or 0)
                if disTime >= 2 then  --10s
                    self:setMapResProg(1)
                    self._lastClickTime = self._userModel:getCurServerTime()
                end
            end), 
            cc.DelayTime:create(1))))

    self:registerClickEventByName("Image_15.reset.restartBtn", function ()   --重新开始btn
        self:resetCrusade()
    end)

    self:registerClickEventByName("Image_15.sweepBtn", function () 
        self:showSweepView(1)
        end)

    self._scrollView = self:getUI("ScrollView")       --滚动区
    -- 当前点动画
    self._curCrusadeMc = mcMgr:createViewMC("jiantou_crusademap", true)   --绿色尖 当前关
    self._scrollView:addChild(self._curCrusadeMc, 3)
    self._curCrusadeMc:setVisible(false)

    self._scrollView:setContentSize(cc.size(ADOPT_IPHONEX and 1136 or MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT))
    self._scrollViewBg = cc.Node:create()
    local x = 0
    for i=1,3 do
        local map = cc.Sprite:create("asset/uiother/crusade/ditu" .. i .. ".jpg")
        map:setAnchorPoint(0,0)
        map:setPosition(x, 0)
        self._scrollViewBg:addChild(map)
        x = x + map:getContentSize().width
    end
    self._scrollMaxWidth = x * BG_SCALE_HEIGHT

    self._scrollView:setInnerContainerSize(cc.size(0, MAX_SCREEN_HEIGHT))
    self._scrollViewBg:setScale(BG_SCALE_HEIGHT)
    self._scrollViewBg:setName("crusade_bg")
    self._scrollView:addChild(self._scrollViewBg)
    self._usingIcon = {}

    self:listenReflash("FormationModel", self.onModelReflash)  --布阵model
    self:listenReflash("CrusadeModel", self.onModelReflash)    --远征model

    self:setMenu()  --左下角菜单
    --buff
    self:createBuffNode()

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("crusade.CrusadeSweepView")

        elseif eventType == "enter" then
            
        end
    end)
end

function CrusadeView:createBuffNode()
    local bufferBg = self:getUI("bufferBg")
    bufferBg:setVisible(false)
    local buffBg = self:getUI("buffBg")
    buffBg:setVisible(false)

    --重置buff图标位置
    for i=1,5 do
        local bufferIcon = self:getUI("bufferBg.smallIcon" .. i)
        bufferIcon:setPosition(bufferIcon:getPositionX()+125, bufferIcon:getPositionY()+125)
    end

    local function showBufferNode()    --左上角buff按钮点击事件  
        local userBuffs = self._crusadeModel:getData().buff
        if (userBuffs == nil or table.nums(userBuffs) <=0) then 
            self._viewMgr:showTip("您当前没有加成")
            return
        end
        local bgLayer = ccui.Layout:create()
        bgLayer:setBackGroundColorOpacity(0)
        bgLayer:setBackGroundColorType(1)
        bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
        bgLayer:setTouchEnabled(true)
        bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
        self._widget:addChild(bgLayer, 100)
        bgLayer:setName("bgLayer")

        registerClickEvent(bgLayer, function()
            local bufferBg = self:getUI("bufferBg")    --buff显示图
            bufferBg:setVisible(false)
            local buffBg = self:getUI("buffBg")   
            buffBg:setVisible(false)
            bgLayer:removeFromParent()
        end)

        --普通buff
        if userBuffs ~= nil and next(userBuffs) ~= nil then
            local bufferBg = self:getUI("bufferBg")
            local sysBuffPic = tab.crusadeBuffPic
            for i=1,5 do
                local bufferIcon = self:getUI("bufferBg.smallIcon" .. i)
                bufferIcon:setVisible(false)

                if bufferBg:getChildByName("richText" .. i) ~= nil then 
                    bufferBg:getChildByName("richText" .. i):removeFromParent()
                end
            end

            local buffOrderKeys = table.keys(userBuffs)
            local sortFunc = function(a, b) return tonumber(b) > tonumber(a) end
            table.sort(buffOrderKeys, sortFunc)
            for k,v in pairs(buffOrderKeys) do
                local buff = userBuffs[v]
                local bufferIcon = self:getUI("bufferBg.smallIcon" .. k) 
                bufferIcon:loadTexture(sysBuffPic[tonumber(v)].pic .. ".png", 1)
                bufferIcon:setVisible(true)
                bufferIcon:setScale(0.3)
                local desc = lang("CRUSADE_BUFFS_" .. v)   --text
                local result,count = string.gsub(desc, "$num", buff)
                if count > 0 then 
                    desc = result
                end
                local richText = RichTextFactory:create(desc, 160 , 0)
                richText:formatText()
                -- richText:setScale(0.9)
                richText:setPosition(80 + richText:getContentSize().width/2, bufferIcon:getPositionY())
                richText:setName("richText" .. k)
                bufferBg:addChild(richText)

                local picFrame = ccui.ImageView:create("globalImageUI4_squality5.png", 1)
                picFrame:setPosition( bufferIcon:getContentSize().width/2, bufferIcon:getContentSize().height/2)
                bufferIcon:addChild(picFrame)
            end
        end
        bufferBg:setVisible(true)
        buffBg:setVisible(true)
    end

    local bufferBtn = self:getUI("bufferBtn")  
    self:registerClickEvent(bufferBtn, function()
        showBufferNode()
    end)
end

--buff按钮上动画
function CrusadeView:updateBufferBtnAmin()
    local flag = false
    local buffData = self._crusadeModel:getData().buff
    if buffData ~= nil and table.nums(buffData) >0 then
        flag = true
    end

    local bufferBtn = self:getUI("bufferBtn")
    if flag == false then 
        local amin1 = bufferBtn:getChildByName("amin1")
        if amin1 ~= nil then
            amin1:clearCallbacks()
            amin1:stop()
            amin1:removeFromParent()
            amin1 = nil
        end

        local amin2 = bufferBtn:getChildByName("amin2")
        if amin2 ~= nil then
            amin2:clearCallbacks()
            amin2:stop()
            amin2:removeFromParent()
            amin2 = nil
        end

        return
    end

    if bufferBtn:getChildByName("amin1") ~= nil then 
        return
    end

    local point2 = bufferBtn:convertToWorldSpace(cc.p(0, 0))
    local amin1 = mcMgr:createViewMC("buffguangxiaoxia_duizhanui", true)
    amin1:setName("amin1")
    amin1:setPosition(bufferBtn:getContentSize().width/2, bufferBtn:getContentSize().height/2)
    bufferBtn:addChild(amin1, -1)

    local amin2 = mcMgr:createViewMC("bufftubiaoshang_crusademap", true)
    amin2:setName("amin2")
    amin2:setPosition(bufferBtn:getContentSize().width/2, bufferBtn:getContentSize().height/2)
    bufferBtn:addChild(amin2, 1)
end

--创建/刷新地图关卡
function CrusadeView:reflashUI(type)
    -- 更新重置时间
    -- self._crusadeModel:updateReSetTime()
    self._passNum = 0   --战斗关卡数
    self._buildingFog = {}
    self._linePoint = {}
    local userCrusade = self._crusadeModel:getData().crusadeData
    self._oneKeySweep = self._crusadeModel:getData().oneKeySweep

    local crusadeBg = self._scrollView:getChildByName("crusade_bg")   --地图
    local sysCrusadeMains = tab.crusadeMain
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    
    for i,v in ipairs(sysCrusadeMains) do   --创建地图关卡
        local sysCrusadeMap = tab:CrusadeMap(v.id)
        local buildingIcon = ccui.Widget:create()     
        local buildIconSprite

        --事件
        if v.type == CrusadeConst.CRUSADE_TYPE.EVENT then   
            local sysCrusadeBuild = tab:CrusadeBuild(userCrusade[i].buildId)
            if sysCrusadeBuild.type == CrusadeConst.CRUSADE_BUILDING_TYPE.REWARD then  
                --奖励
                buildIconSprite = mcMgr:createViewMC("jingling_crusadeeventsprite", true)   --精灵
                buildIconSprite:setContentSize(70, 100)
                buildIconSprite:stop()
                buildingIcon.mc = buildIconSprite
                buildingIcon:setContentSize(70, 100)
                buildIconSprite:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
            
            else
                --buff加成/宝图碎片
                buildIconSprite = cc.Sprite:createWithSpriteFrameName(sysCrusadeBuild.res .. ".png")   --魔法学校（尖塔）
                buildingIcon:setContentSize(buildIconSprite:getContentSize().width, buildIconSprite:getContentSize().height)
                buildIconSprite:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
                buildIconSprite:setAnchorPoint(0.5, 0.5)

                if sysCrusadeBuild.id == 6 and lastFinCrusade < i then
                    local towerMc = mcMgr:createViewMC("fangjiantachangtai_fangjianta", true)
                    buildingIcon:addChild(towerMc,10)
                    buildingIcon.mc1 = towerMc
                    -- buildIconSprite.lock = false
                    towerMc:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
                end
            end

            self:registerClickEvent(buildingIcon, function() self:showCrusadeNodeEvent(i, userCrusade[i], "event_"..sysCrusadeBuild.type) end)

        --奖励
        elseif v.type == CrusadeConst.CRUSADE_TYPE.BOX then   
            if v.boxType == 1 then
                --银宝箱  
                if lastFinCrusade >= i then 
                    buildIconSprite = cc.Sprite:createWithSpriteFrameName("crusadeImg_silverBoxDown.png")
                else
                    buildIconSprite = cc.Sprite:createWithSpriteFrameName("globalImageUI6_meiyoutu.png")
                    buildIconSprite:setContentSize(cc.size(140, 91))
                    local silverMc = mcMgr:createViewMC("zhanyibaoxiang1_baoxiang", true)
                    buildingIcon:addChild(silverMc,10)
                    buildingIcon.mc1 = silverMc
                end

            else
                --金宝箱
                if lastFinCrusade >= i then  
                    buildIconSprite = cc.Sprite:createWithSpriteFrameName("crusadeImg_goldBoxDown.png")
                else
                    buildIconSprite = cc.Sprite:createWithSpriteFrameName("globalImageUI6_meiyoutu.png")
                    buildIconSprite:setContentSize(cc.size(140, 91))
                    local goldenMc = mcMgr:createViewMC("zhanyibaoxiang2_baoxiang", true)
                    buildingIcon:addChild(goldenMc,10)
                    buildingIcon.mc1 = goldenMc
                end
             end
            buildIconSprite.lock = false
            buildingIcon:setContentSize(buildIconSprite:getContentSize().width, buildIconSprite:getContentSize().height)
            buildIconSprite:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
            buildIconSprite:setAnchorPoint(0.5, 0.5)
            buildIconSprite:setScale(0.9)   
            if buildingIcon.mc1 ~= nil then 
                buildingIcon.mc1:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
            end 
            self:registerClickEvent(buildingIcon,  function() self:showCrusadeNodeEvent(i, userCrusade[i], "reward") end)

        --战斗
        else 
            --关卡数提示  wangyan 
            self._passNum = self._passNum + 1           
            if buildingIcon.tipInfo == nil then
                local tipInfo = cc.Sprite:createWithSpriteFrameName("crusadeImg_tipBg.png")
                tipInfo:setAnchorPoint(0.5, 0.5)
                tipInfo:setVisible(false)
                buildingIcon:addChild(tipInfo, 20)
                buildingIcon.tipInfo = tipInfo
                local tipLab = cc.Label:createWithTTF("第".. self._passNum .."/15关", UIUtils.ttfName, 20)
                tipLab:setAnchorPoint(0.5, 0.5)
                tipLab:setColor(cc.c4b(255, 255, 255, 255))
                tipLab:setPosition(tipInfo:getContentSize().width * 0.5, tipInfo:getContentSize().height * 0.5 + 5) 
                tipInfo:addChild(tipLab)
            end

            local height = 0
            if v.fightType == CrusadeConst.CRUSADE_FIGHT_TYPE.HERO then 
                --英雄
                local sysHero = tab:Hero(userCrusade[i].formation.heroId)
                local heroSp = IconUtils:createCrusadeHeroIconById({sysHeroData = sysHero, skin = userCrusade[i].skin})
                heroSp:setAnchorPoint(0.5, 0.5)
                heroSp:getChildByName("boxIcon"):setVisible(false)
                heroSp:setScale(0.7)
                buildingIcon:addChild(heroSp)
                buildingIcon.hero = heroSp

                buildIconSprite = ccui.Widget:create()
                buildIconSprite:setContentSize(heroSp:getContentSize())
                buildIconSprite:setAnchorPoint(0.5, 0)
                
                local heroBg = cc.Sprite:createWithSpriteFrameName("crusadeImg_curBg.png")
                heroBg:setAnchorPoint(0.5, 0.5)
                buildingIcon:addChild(heroBg)
                buildingIcon.heroBg = heroBg
                
                height = heroBg:getContentSize().height * heroBg:getScaleX()
                buildingIcon:setContentSize(buildIconSprite:getContentSize().width * buildIconSprite:getScaleX(), height)
                
                heroSp:setPosition(buildingIcon:getContentSize().width/2 +0.02, height - (heroBg:getContentSize().height * heroBg:getScaleX() /2 -2) )
                heroBg:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2 - 5)
                buildIconSprite:setPosition(buildingIcon:getContentSize().width/2+0.02 , buildingIcon:getContentSize().height/2)
                --关卡数
                buildingIcon.tipInfo:setPosition(buildingIcon:getContentSize().width*0.5, buildingIcon:getContentSize().height*0.5+40)   --45

            else
                -- 攻城战
                buildIconSprite = cc.Sprite:createWithSpriteFrameName("crusade_cheng.png")
                buildIconSprite:setAnchorPoint(0.5, 0)

                sysHero = tab:Hero(userCrusade[i].formation.heroId)
                local heroSp = IconUtils:createCrusadeHeroIconById({sysHeroData = sysHero, skin = userCrusade[i].skin})
                heroSp:setAnchorPoint(0.5, 0.5)
                heroSp:getChildByName("boxIcon"):setVisible(false)
                heroSp:setScale(0.7)
                buildingIcon:addChild(heroSp, 10)
                buildingIcon.hero = heroSp

                local heroBg = cc.Sprite:createWithSpriteFrameName("crusadeImg_curBg.png")
                heroBg:setAnchorPoint(0.5, 0.5)
                buildingIcon:addChild(heroBg, 10)
                buildingIcon.heroBg = heroBg
                
                height = buildIconSprite:getContentSize().height * buildIconSprite:getScaleY() + (heroBg:getContentSize().height * heroBg:getScaleX())
                buildingIcon:setContentSize(buildIconSprite:getContentSize().width * buildIconSprite:getScaleX(), height - 47)
                
                heroSp:setPosition(buildingIcon:getContentSize().width/2 -25, height - (heroBg:getContentSize().height * heroBg:getScaleX() /2) - 40)
                heroBg:setPosition(buildingIcon:getContentSize().width/2 -25, height - (heroBg:getContentSize().height * heroBg:getScaleX() /2) - 47)
                buildIconSprite:setPosition(buildingIcon:getContentSize().width/2 -20, -30)  ---20-10

                --关卡数
                buildingIcon.tipInfo:setPosition(buildingIcon:getContentSize().width*0.5 -25, buildingIcon:getContentSize().height*0.5+74)   
            end
            buildingIcon.heroBg.cachePosX = buildingIcon.heroBg:getPositionX()
            buildingIcon.heroBg.cachePosY = buildingIcon.heroBg:getPositionY()

            buildingIcon.hero.cachePosX =  buildingIcon.hero:getPositionX()
            buildingIcon.hero.cachePosY =  buildingIcon.hero:getPositionY()

            self:registerClickEvent(buildingIcon,  function() self:showCrusadeNodeEvent(i, userCrusade[i], "battle") end)
        end
        buildIconSprite:setName("buildIconSprite")
        buildingIcon:addChild(buildIconSprite, 1)
        buildingIcon:setAnchorPoint(sysCrusadeMap.anchorPointX, sysCrusadeMap.anchorPointY)
        buildingIcon:setPosition(sysCrusadeMap.x * BG_SCALE_HEIGHT, sysCrusadeMap.y * BG_SCALE_HEIGHT)

        self._scrollView:addChild(buildingIcon, 2)
        buildingIcon:setName("Crusade_" .. i)

        if activeCrusadeId > i then   --通关
            buildingIcon:setSaturation(0)  --置灰
            -- 已完成关卡
            local finishTip = cc.Sprite:createWithSpriteFrameName("crusadeImg_temp13.png")  --已通过img
            finishTip:setAnchorPoint(0.5, 0)
            buildingIcon:addChild(finishTip, 100)
            finishTip:setPosition(buildingIcon:getContentSize().width/2 ,0)
            if v.fightType == CrusadeConst.CRUSADE_FIGHT_TYPE.SIEGE then
                finishTip:setPosition(buildingIcon:getContentSize().width/2-15 ,-20)
            end
            if buildingIcon.hero ~= nil then 
                buildingIcon.hero:setSaturation(-180)
            end
            if buildingIcon.heroBg ~= nil then 
                buildingIcon.heroBg:setSaturation(0)
            end
            self:updateBuildingLine(i)  --通关显示远征路径（绿点）

        elseif activeCrusadeId == i then   --当前关
            buildingIcon:setSaturation(0)
            if buildingIcon.hero ~= nil then 
                buildIconSprite:setSaturation(0)
            end
            if buildingIcon.heroBg ~= nil then 
                buildingIcon.heroBg:setSaturation(0)
            end
            if buildingIcon.mc ~= nil then  
                buildingIcon.mc:play()
            end

        else
            -- 未完成远征关卡
            if buildIconSprite.lock == nil or buildIconSprite.lock == true then 
                buildingIcon:setSaturation(-180)
            else
                buildingIcon:setSaturation(0)           
            end
        end  

        self:updateBuildingFog(sysCrusadeMap)  --未通关区域  加关卡雾
        self._usingIcon[i] = buildingIcon
    end


    -- 更新监听数据相关信息 【重置次数】
    self:onModelReflash()
    -- 更新藏宝图所在点
    self:updateTreasurePoint()
    -- 更新可视区域
    self:updateScrollMaxWidth()
    -- 滑动scrollview显示当前关
    self:scrollCurActBuilding()
    -- 刷新当前关提示mc
    self:updateCurTipMc(self._crusadeModel:getData().activeCrusadeId)
    -- 刷新buff动画
    self:updateBufferBtnAmin()
    -- 所有通关后 点亮动画
    self:finishCrusade()
    
end

--滑动scrollview显示当前关
function CrusadeView:scrollCurActBuilding(inBuildingIcon)
    inBuildingIcon = inBuildingIcon or self._crusadeModel:getData().activeCrusadeId
    local viewWidth = self._scrollView:getInnerContainer():getContentSize().width
    local buildingIcon = self._scrollView:getChildByName("Crusade_" .. inBuildingIcon)
    if buildingIcon ~= nil then
        if viewWidth - self._scrollView:getContentSize().width > 0 then 
            local temp = viewWidth - self._scrollView:getContentSize().width
            local backPercent = buildingIcon:getPositionX() / temp - MAX_SCREEN_WIDTH /2 /temp
            self._scrollView:scrollToPercentHorizontal(backPercent * 100, 0, false)
        end
    end
end

--通关显示远征路径（绿点）
function CrusadeView:updateBuildingLine(inCrusadeId)
    local sysCrusadeMap = tab:CrusadeMap(inCrusadeId)
    if sysCrusadeMap.linePosi then 
        for k,v in pairs(sysCrusadeMap.linePosi) do
            local linePoint = cc.Sprite:createWithSpriteFrameName("crusadeImg_point.png")
            linePoint:setAnchorPoint(cc.p(0.5, 0.5))
            linePoint:setColor(cc.c3b(80, 240, 99))
            linePoint:setPosition(v[1] * BG_SCALE_HEIGHT, v[2] * BG_SCALE_HEIGHT)
            self._scrollView:addChild(linePoint)
            table.insert(self._linePoint, linePoint)
        end
    end 
    -- if sysCrusadeMap.lineRes ~= nil then 
    --     local buildLine = cc.Sprite:createWithSpriteFrameName(sysCrusadeMap.lineRes .. ".png")
    --     buildLine:setAnchorPoint(cc.p(0.5, 0.5))
    --     buildLine:setColor(cc.c3b(80, 240, 99))
    --     -- buildLine:setTexture("asset/uiother/crusade/" .. sysCrusadeMap.lineRes .. ".png")
    --     buildLine:setPosition(sysCrusadeMap.linePosi[1], sysCrusadeMap.linePosi[2])
    --     self._scrollView:addChild(buildLine)
    --     -- self._curBuildLine:runAction(cc.Sequence:create(cc.FadeOut:create(0.5)))
    --     table.insert(self._lineIcon, buildLine)
    -- end
end

--未通关区域加关卡雾
function CrusadeView:updateBuildingFog(inSysCrusadeMap)
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    if inSysCrusadeMap.fogPosi ~= nil and activeCrusadeId < inSysCrusadeMap.id then 
        for k,v in pairs(inSysCrusadeMap.fogPosi) do
            local fogIcon = cc.Sprite:create("asset/uiother/intance/intanceImageUI4_fog.png")
            fogIcon:setScaleY(1.06)
            self._scrollView:addChild(fogIcon, 10)
            fogIcon:setPosition(v[1] * BG_SCALE_HEIGHT, v[2] * BG_SCALE_HEIGHT)
            if self._buildingFog[inSysCrusadeMap.id] == nil then 
                self._buildingFog[inSysCrusadeMap.id] = {}
            end
            table.insert(self._buildingFog[inSysCrusadeMap.id], fogIcon)
        end
    end
end

--雾消散
function CrusadeView:fadeInFog(inCrusadeId, inCallback)
    -- print("self._buildingFog[inCrusadeId]-====",self._buildingFog[inCrusadeId])
    if self._buildingFog[inCrusadeId] ~= nil then 
        for k,v in pairs(self._buildingFog[inCrusadeId]) do
            v:runAction(cc.Sequence:create(cc.FadeOut:create(0.5)))
        end
    end
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5), 
        cc.CallFunc:create(function() 
            if inCallback ~= nil then 
                inCallback()
            end
        end)))
end

--刷新关卡提示mc跳跃动画
function CrusadeView:updateCurTipMc(inBuildingId)
    local sysCrusadeMain = tab:CrusadeMain(inBuildingId)
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    local buildingIcon = self._scrollView:getChildByName("Crusade_" .. inBuildingId)
    local acWidth = (0.5 - buildingIcon:getAnchorPoint().x) * buildingIcon:getContentSize().width
    local x = buildingIcon:getPositionX() + acWidth 
    local acHeight = (1 - buildingIcon:getAnchorPoint().y) * buildingIcon:getContentSize().height
    local y = buildingIcon:getPositionY() + acHeight 
    if self._curCrusadeSp ~= nil then 
        self._curCrusadeSp:removeFromParent()
        self._curCrusadeSp = nil
    end 
    self._curCrusadeMc:setPosition(x-3, y+10)
    if lastFinCrusade == inBuildingId then 
        self._curCrusadeMc:setVisible(false)
        buildingIcon:setSaturation(0)
        -- 已完成关卡
        local finishTip = cc.Sprite:createWithSpriteFrameName("crusadeImg_temp13.png")  --通过
        finishTip:setAnchorPoint(0.5, 0)
        buildingIcon:addChild(finishTip, 100)
        finishTip:setPosition(buildingIcon:getContentSize().width/2 ,0)

        if buildingIcon.hero ~= nil then 
            buildingIcon.hero:setSaturation(-180)
            buildingIcon.hero:stopAllActions()
            buildingIcon.hero:setPosition(buildingIcon.hero.cachePosX, buildingIcon.hero.cachePosY)
        end
        if buildingIcon.heroBg ~= nil then 
            buildingIcon.heroBg:setSaturation(0)
            buildingIcon.heroBg:stopAllActions()
            buildingIcon.heroBg:setPosition(buildingIcon.heroBg.cachePosX, buildingIcon.heroBg.cachePosY)
        end
        if buildingIcon.tipInfo ~= nil then
            buildingIcon.tipInfo:stopAllActions()
            buildingIcon.tipInfo:setVisible(false)
        end

        if buildingIcon.mc ~= nil then 
            buildingIcon.mc:stop()
        end

        if buildingIcon.mc1 ~= nil then
            buildingIcon.mc1:setVisible(false)
            buildingIcon.mc1:stop()
        end

        if sysCrusadeMain.type == CrusadeConst.CRUSADE_TYPE.BOX then
            local buildSprite = buildingIcon:getChildByName("buildIconSprite")
            if buildSprite then  --globalImageUI6_meiyoutu
                if sysCrusadeMain.boxType == 1 then  --银
                    buildSprite:setSpriteFrame("crusadeImg_silverBoxDown.png")
                else
                    buildSprite:setSpriteFrame("crusadeImg_goldBoxDown.png")
                end
            end
        end
    else
        if buildingIcon.tipInfo then
            buildingIcon.tipInfo:setVisible(true)
        end
        if sysCrusadeMain.type == CrusadeConst.CRUSADE_TYPE.BATTLE and 
            (sysCrusadeMain.fightType == CrusadeConst.CRUSADE_FIGHT_TYPE.HERO  or 
                sysCrusadeMain.fightType == CrusadeConst.CRUSADE_FIGHT_TYPE.SIEGE )then 
            self._curCrusadeMc:setVisible(false)
            if buildingIcon.hero ~= nil then 
                buildingIcon.hero:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create( 
                            cc.MoveBy:create(0.6, cc.p(0, 10)),
                            cc.MoveBy:create(0.6, cc.p(0, -10))
                            )
                        )
                    )
            end
            if buildingIcon.heroBg ~= nil then 
                buildingIcon.heroBg:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create( 
                            cc.MoveBy:create(0.6, cc.p(0, 10)),
                            cc.MoveBy:create(0.6, cc.p(0, -10))
                            )
                        )
                    )
            end

            if buildingIcon.tipInfo ~= nil then 
                buildingIcon.tipInfo:runAction(
                    cc.RepeatForever:create(
                        cc.Sequence:create( 
                            cc.MoveBy:create(0.6, cc.p(0, 10)),
                            cc.MoveBy:create(0.6, cc.p(0, -10))
                            )
                        )
                    )
            end
        else
            self._curCrusadeMc:setVisible(true)
            if buildingIcon.mc ~= nil then 
                buildingIcon.mc:play()
            end
        end
        buildingIcon:setSaturation(0)
    end
end


--[[
--! @function onModelReflash
--! @desc 更新vip 布阵相关信息，其他信息特殊处理(右下角显示内容 重置次数)
--! @return 
--]]
function CrusadeView:onModelReflash()
    local cModelData = self._crusadeModel:getData()
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    local vipInfo = self._modelMgr:getModel("VipModel"):getData()
    local sysVip = tab:Vip(vipInfo.level)

    local lastReSetNum = self._crusadeModel:getLastReSetNum()
    local restartBtn = self:getUI("Image_15.reset.restartBtn")
    restartBtn:setTitleText("重置(".. lastReSetNum ..")")

    --地图收集进度
    local mapTip = self:getUI("menu.mapTip")
    local progLab = self:getUI("menu.mapTip.progLab")
    progLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local usePcs = self._crusadeModel:getData().usePcs
    local needPcs = self._crusadeModel:getData().needPcs
    progLab:setString(usePcs.."/7")

    --重置可扫荡数提示 / 一键扫荡
    local sweepTips1 = self:getUI("Image_15.reset.tips1")
    local sweepTips2 = self:getUI("Image_15.reset.tips2")
    self:getUI("Image_15.reset.tips1.lab1"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self:getUI("Image_15.reset.tips1.lab2"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self:getUI("Image_15.reset.tips1.lab3"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self:getUI("Image_15.reset.tips1.lab4"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self:getUI("Image_15.reset.tips1.lab5"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self:getUI("Image_15.reset.tips2"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    sweepTips1:setVisible(false)
    sweepTips2:setVisible(false)
    local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    local isPrivOpen1 = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.MuXueHuLan)  --特权子爵开启判断
    local isPrivOpen2 = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.YuanZhengSaodang)  --特权公爵开启判断

    local sweepBtn = self:getUI("Image_15.sweepBtn")
    local reset = self:getUI("Image_15.reset")
    sweepBtn:setVisible(false)
    reset:setPositionX(80)
    if cModelData["sweepId"] and cModelData["sweepId"] > 0 and lastFinCrusade < cModelData["sweepId"] * 2 
        and isPrivOpen2 ~= 0 and (not cModelData["oneKeySweep"] or cModelData["oneKeySweep"] == 0) then
        sweepBtn:setVisible(true)
        reset:setPositionX(-63)
    end
    
    local lab2 = self:getUI("Image_15.reset.tips1.lab2")
    local lab5 = self:getUI("Image_15.reset.tips1.lab5")
    local labBg = self:getUI("Image_15.reset.Image_47")
    if isPrivOpen2 ~= 0 then
        sweepTips1:setVisible(true)
        local passMax = math.max(math.ceil(lastFinCrusade*0.5) - tab.setting["G_CRUSADE_PEERAGE_2"].value, 0)
        lab2:setString(passMax)
        lab5:setString(math.ceil(lastFinCrusade*0.5))
        labBg:setContentSize(cc.size(390, 46))
        
    elseif isPrivOpen1 ~= 0 then
        sweepTips1:setVisible(true)
        local passMax = math.max(math.ceil(lastFinCrusade*0.5) - tab.setting["G_CRUSADE_PEERAGE_1"].value, 0)
        lab2:setString(passMax)
        lab5:setString(math.ceil(lastFinCrusade*0.5))
        labBg:setContentSize(cc.size(390, 46))
        labBg:setPositionX(-95)

    else
        sweepTips2:setVisible(true)
        sweepTips2:setString("特权达到子爵可扫荡")
        labBg:setContentSize(cc.size(250, 46))
        labBg:setPositionX(-20)
    end
end

--[[
--! @function updateLastCrusade
--! @desc 更新远征最新关卡
--! @return 
--]]
function CrusadeView:updateLastCrusade()
    self._viewMgr:lock(999999)
    -- local sysCrusadeMains = tab.crusadeMain
    -- for i,v in pairs(sysCrusadeMains) do
    --     local buildingIcon = self._scrollView:getChildByName("Crusade_" .. i)

    -- end
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if activeCrusadeId == lastFinCrusade then
        self._viewMgr:unlock(0)
        self:activeCrusade() 
        self:finishCrusadeAnim()
        return 
    end

    local sysCrusadeMains = tab.crusadeMain

    local maxCrusade = sysCrusadeMains[#sysCrusadeMains]  --最后一关
    -- if self._cacheCrusadeId ~= activeCrusadeId then 
    --     self._cacheCrusadeId = activeCrusadeId
    local viewWidth = self._scrollView:getInnerContainer():getContentSize().width
    local cachePercent = viewWidth / (viewWidth - self._scrollView:getContentSize().width) - MAX_SCREEN_WIDTH / 2 / (viewWidth - self._scrollView:getContentSize().width)
    local backState = self:updateScrollMaxWidth()
    if not backState then
        self._viewMgr:unlock(0)
        self:activeCrusade() 
    else
        self:fadeInFog(activeCrusadeId, function()
            local viewWidth1 = self._scrollView:getInnerContainer():getContentSize().width
            local percent = viewWidth / (viewWidth1 - self._scrollView:getContentSize().width) - MAX_SCREEN_WIDTH / 2 / (viewWidth1 - self._scrollView:getContentSize().width)
            self._scrollView:scrollToPercentHorizontal(100, 0.5, true)
            self:runAction(cc.Sequence:create(
                            cc.DelayTime:create(0.6),
                            cc.CallFunc:create(function() 
                                self._viewMgr:unlock(0)
                                self:activeCrusade()
                            end)
                            ))
        end)
    end
end

--所有通关后 点亮动画
function CrusadeView:finishCrusade()
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if activeCrusadeId ~= lastFinCrusade then
        return 
    end
    local sysCrusadeMains = tab.crusadeMain
    for i=1, #sysCrusadeMains do
        local v = sysCrusadeMains[i]
        local buildingIcon = self._scrollView:getChildByName("Crusade_" .. v.id)
        local lightMc = mcMgr:createViewMC("dianliang_crusademap", false, false)
        if v.fightType == CrusadeConst.CRUSADE_FIGHT_TYPE.SIEGE then  --攻城战
            lightMc:setPosition(buildingIcon:getContentSize().width/2 - 25, buildingIcon:getContentSize().height + 15)
        else
            lightMc:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height + 10)
        end
        buildingIcon:addChild(lightMc, 10)
        lightMc:gotoAndStop(16)
    end

    self:setMapResProg(2)
end  

--
function CrusadeView:finishCrusadeAnim()
    local sysCrusadeMains = tab.crusadeMain
    self._viewMgr:lock(-1)
    -- self._scrollView:scrollToPercentHorizontal(0, 0.5, true)
    -- local cacheNum = 0
    -- self:runAction(
    -- cc.Sequence:create(
    --     cc.DelayTime:create(0.6), 
    --     cc.CallFunc:create(function() 
    --         local isScroll = false
    --         local sysCrusadeMains = tab.crusadeMain
    --         for i=1, #sysCrusadeMains do
    --             local v = sysCrusadeMains[i]
                
    --             local buildingIcon = self._scrollView:getChildByName("Crusade_" .. v.id)

    --             local lightMc = mcMgr:createViewMC("dianliang_crusademap", false, false)
    --             lightMc:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height + 10)
    --             if v.fightType == CrusadeConst.CRUSADE_FIGHT_TYPE.SIEGE then  --攻城战
    --                 lightMc:setPosition(buildingIcon:getContentSize().width/2 - 25, buildingIcon:getContentSize().height + 15)
    --             end
    --             buildingIcon:addChild(lightMc, 10)

    --             lightMc:stop()
    --             lightMc:setVisible(false)
    --             if isScroll == false and sysCrusadeMains[i + 1] ~= nil then 
    --                 local nextBuildingIcon = self._scrollView:getChildByName("Crusade_" .. sysCrusadeMains[i + 1].id)
    --                 local nextPoint = nextBuildingIcon:convertToWorldSpace(cc.p(0, 0))
    --                 if nextPoint.x + nextBuildingIcon:getContentSize().width > MAX_SCREEN_WIDTH then 
    --                     buildingIcon.needScroll = true
    --                     isScroll = true
    --                     cacheNum = i
    --                 end 
    --             end
    --             local tiem = i * 0.2 
    --             if isScroll == true then 
    --                 tiem = i * 0.2 - (i - cacheNum) * 0.1
    --             end
    --             buildingIcon:runAction(
    --                 cc.Sequence:create(
    --                     cc.DelayTime:create(tiem), 
    --                     cc.CallFunc:create(function() 
    --                         lightMc:setVisible(true) 
    --                         lightMc:play()
    --                             if buildingIcon.needScroll == true then 
    --                                 self._scrollView:scrollToPercentHorizontal(100, 2, true)
    --                             end
    --                         end)
    --                 ))
    --         end
    --     end)
    -- ))
    local bgLayer = ccui.Layout:create() 
    local finishMc = mcMgr:createViewMC("gongxitongguan_nextsection", false, false, function()
        self._viewMgr:unlock(0)
        bgLayer:setTouchEnabled(true)
    end, nil, false)
    -- finishMc:stop()
    -- finishMc:setVisible(false)
    finishMc:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
    self:addChild(finishMc, 887)
    bgLayer:setBackGroundColorOpacity(0)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(bgLayer, 888)
    -- bgLayer:runAction(cc.Sequence:create(
    --                     cc.DelayTime:create(#sysCrusadeMains * 0.1 + 2), 
    --                     cc.CallFunc:create(function() 
    --                         finishMc:setVisible(true) 
    --                         finishMc:play()
    --                         end)
    --                 ))
    registerClickEvent(bgLayer, function()
        finishMc:removeFromParent()
        bgLayer:removeFromParent()
    end)

end

--激活关卡  路径动画
function CrusadeView:activeCrusade()
    self._viewMgr:lock(-1)
    self._curCrusadeMc:setVisible(false)

    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade

    -- print("%%%%%%%%")
    local lastCrusade = tab.crusadeMain[lastFinCrusade]
    if lastCrusade == nil then self._viewMgr:unlock(0) return end
    if lastCrusade.type ~= CrusadeConst.CRUSADE_TYPE.BATTLE then 
        self:triggerSpecialCrusade()
    end

    -- local sysCrusadeMap = tab:CrusadeMap(activeCrusadeId)
    self:updateCurTipMc(lastFinCrusade)
    if activeCrusadeId ~= lastFinCrusade then 
        local sysCrusadeMap = tab:CrusadeMap(lastFinCrusade)
        if sysCrusadeMap.linePosi and #sysCrusadeMap.linePosi > 0 then 
            for k,v in pairs(sysCrusadeMap.linePosi) do
                local linePoint = cc.Sprite:createWithSpriteFrameName("crusadeImg_point.png")
                linePoint:setAnchorPoint(cc.p(0.5, 0.5))
                linePoint:setColor(cc.c3b(80, 240, 99))
                -- buildLine:setTexture("asset/uiother/crusade/" .. sysCrusadeMap.lineRes .. ".png")
                linePoint:setPosition(v[1] * BG_SCALE_HEIGHT, v[2] * BG_SCALE_HEIGHT)
                self._scrollView:addChild(linePoint)
                linePoint:setOpacity(0)
                local ac1 = cc.DelayTime:create(0.1 * k )
                local ac2 = cc.FadeIn:create(0.1)
                if #sysCrusadeMap.linePosi == k then
                    local ac4 = cc.CallFunc:create(function()
                        self:updateCurTipMc(activeCrusadeId)
                        self._viewMgr:unlock(0)
                    end)
                    linePoint:runAction(cc.Sequence:create(ac1, ac2, ac4))
                else
                    linePoint:runAction(cc.Sequence:create(ac1, ac2))
                end
                table.insert(self._linePoint, linePoint)
            end
            return
        end
    end
    self._viewMgr:unlock(0)
end

-- 限制可滚动区域 -1 无限制，0 当前屏幕区域
-- local  SCROLL_PIXEL_LIMIT = {{23, -1}, {16, 2560}, {11, 2048}, {6, 1536} }

--[[
--! @function updateScrollMaxWidth
--! @desc 更新远征可视区域
--! @return 
--]]
function CrusadeView:updateScrollMaxWidth(crusadeId)
    crusadeId = crusadeId or self._crusadeModel:getData().activeCrusadeId
    -- 限制可滚动区域
    local maxWidth = 0
    local flag = false
    for k,v in pairs(tab:Setting("SCROLL_PIXEL_LIMIT").value) do
        local flag1 = false
        if v[1] <= crusadeId then 
            if v[2] == -1 then 
                maxWidth = self._scrollMaxWidth
                flag1 = true
            elseif v[2] > 0 then 
                maxWidth = v[2] * BG_SCALE_HEIGHT  
                flag1 = true
            end
            if flag1 and v[1] == crusadeId then 
                flag = true
            end
            break
        end
    end
    self._scrollView:setInnerContainerSize(cc.size(maxWidth, MAX_SCREEN_HEIGHT))
    return flag
end

--[[
--! @function updateTreasurePoint
--! @desc 更新藏宝图点
--! @return 
--]]
function CrusadeView:updateTreasurePoint()
    -- print("***********************************************updateTreasurePoint")
    local buildingIcon = self._scrollView:getChildByName("CRUSADE_TREASURE")
    if self._crusadeModel:getData().usePcs == self._crusadeModel:getData().needPcs then

        local pcsPosition = self._crusadeModel:getData().pcsPosition

        local positionId = math.ceil(((pcsPosition[1] + pcsPosition[2] - 1) / 2))

        local sysCrusadeTreaPosi = tab:CrusadeTreaPosi(positionId)
        if buildingIcon == nil then 
            buildingIcon = ccui.Widget:create()
            local buildIconSprite = cc.Sprite:createWithSpriteFrameName("crusadeImg_treasure1.png")   --红色叉
            buildingIcon:setContentSize(buildIconSprite:getContentSize().width, buildIconSprite:getContentSize().height)
            buildIconSprite:setPosition(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2)
            buildIconSprite:setAnchorPoint(0.5, 0.5)
            buildingIcon:addChild(buildIconSprite)
            buildingIcon:setAnchorPoint(0.5, 0)
            buildingIcon:setName("CRUSADE_TREASURE")
            self._scrollView:addChild(buildingIcon, 11)
            local mc = mcMgr:createViewMC("xiaochanzi_crusadeopen", true, false)
            mc:setPosition(cc.p(buildingIcon:getContentSize().width/2, buildingIcon:getContentSize().height/2))
            buildingIcon:addChild(mc,6)          
        end
        buildingIcon:setPosition(sysCrusadeTreaPosi.posi1[1], sysCrusadeTreaPosi.posi1[2])
        self:registerClickEvent(buildingIcon, function()
            self:getCrusadePcsReward()
        end)
    end
end

--[[
--! @function showCrusadeEventNode
--! @desc 展示事件关相关内容
--! @param inCrusadeId int 远征id
--! @param inCrusadeData object 远征信息  
--! @return 
--]]
function CrusadeView:showCrusadeEventNode(inCrusadeId, inCrusadeData, buildType)
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if lastFinCrusade >= inCrusadeId then
        self._viewMgr:showTip(lang("CRUSADE_TIPS_5"))
        return 
    end
    if activeCrusadeId < inCrusadeId then   
        if buildType == CrusadeConst.CRUSADE_BUILDING_TYPE.TREASURE then
            self._viewMgr:showTip(lang("CRUSADE_TIPS_16"))
        elseif buildType == CrusadeConst.CRUSADE_BUILDING_TYPE.BUFFER then
            self._viewMgr:showTip(lang("CRUSADE_TIPS_17"))
        elseif buildType == CrusadeConst.CRUSADE_BUILDING_TYPE.REWARD then
            self._viewMgr:showTip(lang("CRUSADE_TIPS_18"))
        end
        -- self._viewMgr:showTip(lang("CRUSADE_TIPS_4"))
        return 
    end
    local music = {"faerie", "getprotection", "genie", "luck", "chest", "obelisk"}
    audioMgr:playSound(music[inCrusadeData.buildId])
    if activeCrusadeId == inCrusadeId and lastFinCrusade ~= inCrusadeId then
        local sysCrusadeBuild = tab:CrusadeBuild(inCrusadeData.buildId)
        self._serverMgr:sendMsg("CrusadeServer", "enterCrusadeEvent", {id = inCrusadeId}, true, {}, function (result)
            if result["token"] == nil then
                return
            end
            if sysCrusadeBuild.type == CrusadeConst.CRUSADE_BUILDING_TYPE.BUFFER then 
                self._viewMgr:showDialog("crusade.CrusadeBufferBuildNode",{
                    crusadeId = inCrusadeId, 
                    crusadeData = inCrusadeData, 
                    netData = result,
                    parentView = self,
                    callback = function()
                        self:updateLastCrusade()
                        self:updateBufferBtnAmin()
                        self:checkRandRed()
                    end
                    }) 
            elseif sysCrusadeBuild.type == CrusadeConst.CRUSADE_BUILDING_TYPE.REWARD then
                self._viewMgr:showDialog("crusade.CrusadeRewardNode",{
                    crusadeId = inCrusadeId, 
                    crusadeData = inCrusadeData, 
                    netData = result,
                    callback = function()
                        self:updateLastCrusade()
                        self:checkRandRed()
                    end
                    }) 
            elseif sysCrusadeBuild.type == CrusadeConst.CRUSADE_BUILDING_TYPE.TREASURE then
                self._viewMgr:showDialog("crusade.CrusadeTreasureNode",{
                    crusadeId = inCrusadeId, 
                    crusadeData = inCrusadeData, 
                    netData = result,
                    callback = function(inNeedScroll)
                        self:checkRandRed()
                        self:activeCrusade()
                        self:setMapResProg(1)
                        if inNeedScroll == true then
                            self._viewMgr:lock(-1)
                            self:updateTreasurePoint()
                            self:scrollTreasurePoint()
                        end
                    end})
            end
        end)
    end
end

function CrusadeView:checkRandRed()
    self._modelMgr:getModel("GuildRedModel"):checkRandRed()
end

--[[
--! @function scrollTreasurePoint
--! @desc 滚动到藏宝图标位置
--! @param 
--! @return 
--]]
function CrusadeView:scrollTreasurePoint()
    -- print("***********************************************updateTreasurePoint")
    local pcsPosition = self._crusadeModel:getData().pcsPosition
    local positionId = math.ceil(((pcsPosition[1] + pcsPosition[2] - 1) / 2))
    local sysCrusadeTreaPosi = tab:CrusadeTreaPosi(positionId)
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade

    local backPercent1 = math.abs(self._scrollView:getInnerContainer():getPositionX()) / (self._scrollView:getInnerContainer():getContentSize().width - self._scrollView:getContentSize().width)

    self._scrollView:setTouchEnabled(false)
    self._scrollView:setInnerContainerSize(cc.size(self._scrollMaxWidth, MAX_SCREEN_HEIGHT))

    local backPercent = math.abs(self._scrollView:getInnerContainer():getPositionX()) / (self._scrollMaxWidth - self._scrollView:getContentSize().width)
    local percent = sysCrusadeTreaPosi.posi1[1] /  (self._scrollMaxWidth - self._scrollView:getContentSize().width) - MAX_SCREEN_WIDTH / 2 / (self._scrollMaxWidth - self._scrollView:getContentSize().width )
    local time = percent * 1
    self._scrollView:scrollToPercentHorizontal(percent * 100, time, true)
    self:runAction(cc.Sequence:create(
                    cc.DelayTime:create(time + 1),
                    cc.CallFunc:create(function() 
                        self._scrollView:scrollToPercentHorizontal(backPercent * 100, time, true)
                    end),
                    cc.DelayTime:create(time),
                    cc.CallFunc:create(function() 
                        self:updateScrollMaxWidth()
                        if tostring(backPercent1) ~= "nan" then 
                            self._scrollView:jumpToPercentHorizontal(backPercent1 * 100)
                        else
                            self._scrollView:jumpToPercentHorizontal(0)
                        end
                        self._scrollView:setTouchEnabled(true)
                        self._viewMgr:unlock()
                    end)))
end  



--[[
--! @function showCrusadeBattleNode`
--! @desc 展示战斗界面
--! @param 
--! @return   
--]]
function CrusadeView:showCrusadeBattleNode(inCrusadeId, inCrusadeData)
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if lastFinCrusade >= inCrusadeId then
        self._viewMgr:showTip(lang("CRUSADE_TIPS_5"))
        return 
    end
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    if activeCrusadeId < inCrusadeId then 
        self._viewMgr:showTip(lang("CRUSADE_TIPS_15"))
        return 
    end

    -- if inCrusadeId ~= activeCrusadeId then
    --     return 
    -- end
    self:beforeAttackCrusade(inCrusadeId, inCrusadeData)
end

--[[
--! @function upgradeStar
--! @desc 向服务端请求升星，如果成功则调取成功界面
--! @param 
--! @return 
--]]
function CrusadeView:beforeAttackCrusade(inCrusadeId, inCrusadeData)
    self._serverMgr:sendMsg("CrusadeServer", "getRivalInfo", {id = inCrusadeId}, true, {}, function (result)
        return self:beforeAttackCrusadeFinish(inCrusadeId, inCrusadeData, result)
    end)
end

function CrusadeView:beforeAttackCrusadeFinish(inCrusadeId, inCrusadeData, enemyD)
    if enemyD == nil then 
        self._viewMgr:showTip("此条信息不应出现，如出现请联系小羊！")
        return
    end

    self._viewMgr:showDialog("crusade.CrusadeBattleNode",{
        crusadeId = inCrusadeId, 
        crusadeData = inCrusadeData,
        enemyD = enemyD,
        callback = function()
            self:updateLastCrusade()
        end,
        callback2 = function() 
            self:triggerSpecialCrusade()
        end})
end


--[[
--! @function getCrusadePcsReward
--! @desc 活动藏宝图奖励
--! @param 
--! @return 
--]]
function CrusadeView:getCrusadePcsReward()
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadePcsReward", {}, true, {}, function (result)
        if result == nil or result["d"] == nil then 
            return 
        end
        if result["reward"] ~= nil then
            self._viewMgr:lock(99999)
            local reward = result["reward"]
            audioMgr:playSound("Dig")
            local wabaoMc = mcMgr:createViewMC("wabao_crusadeopenbox", false, true, function()
                self._viewMgr:unlock()
                DialogUtils.showGiftGet( {
                    gifts = reward,
                    callback = function()
                        local crusadeModel = self._modelMgr:getModel("CrusadeModel")
                        local usePcs = crusadeModel:getData().usePcs
                        local needPcs = crusadeModel:getData().needPcs
                        if usePcs == needPcs then 
                            crusadeModel:getData().playEffect = 1
                            self:showDialog("global.GlobalMessageDialog", {desc = "你仍持完整藏宝图，请点击确定查看", button = "确定", callback = function ()
                                   self._viewMgr:showDialog("crusade.CrusadeTreasureMapNode", {
                                    callback = function(inNeedScroll)
                                        self:setMapResProg(1)
                                        if inNeedScroll == true then
                                            self:updateTreasurePoint()
                                            self:scrollTreasurePoint()
                                        end
                                    end})      
                            end})  
                        end                 
                    end} )
            end)
            local buildingIcon = self._scrollView:getChildByName("CRUSADE_TREASURE")

            wabaoMc:setPosition(buildingIcon:getPositionX(), buildingIcon:getPositionY())
            self._scrollView:addChild(wabaoMc, 100)

            if buildingIcon ~= nil then 
                buildingIcon:removeFromParent()
            end
        end

    end)
end


--[[
--! @function getCrusadeInfo
--! @desc 获取远征信息
--! @param 
--! @return 
--]]
function CrusadeView:getCrusadeInfo()   
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadeInfo", {}, true, {}, function (result)
        -- dump(result,"", 20)
        return self:getCrusadeInfoFinish(result)
    end)
end

--[[
--! @function getCrusadeInfoFinish
--! @desc 获取远征信息服务器返回处理
--! @param result object 返回结果
--! @return 
--]]
function CrusadeView:getCrusadeInfoFinish(result)
    -- self:updateSoulProgState()
    if result == nil or result["crusade"] == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    -- local crusadeModel = self._modelMgr:getModel("CrusadeModel")
    -- local testData = {}
    -- testData.pcsPosition = {0, 1, 2, 3, 4, 5, 6}
    -- crusadeModel:updateCrusadeData(testData)

    self._onBeforeAddCallback(1)
    self:reflashUI() 
    self:showTriggerCrusadeStatus()
    self:runFirstAnim()
end

--奖励未领取
function CrusadeView:showCrusadeBoxReward(inCrusadeId, inCrusadeData)
    local activityModel = self._modelMgr:getModel("ActivityModel")
    local discount = activityModel:getAbilityEffect(activityModel.PrivilegIDs.PrivilegID_12)
    local vipAdd = tab:Vip(self._modelMgr:getModel("VipModel"):getLevel()).crusadeAdd
    local desTip = lang("CRUSADE_BOX_TIPS")
    if discount ~= 0 then
        desTip = lang("CRUSADE_BOX_TIPS2")
    end

    DialogUtils.showGiftGet( {
    gifts = inCrusadeData,
    viewType = 1,
    canGet = false, 
    des = desTip,
    addition = {img = "golbalIamgeUI5_yuanzhengbi.png", add = {acAdd = discount * 100, vipAdd = vipAdd}},
    callback = function()  

    end} )
end

--[[
--! @function getCrusadeBoxReward
--! @desc 获取远征宝箱奖励类型3
--! @param result object 返回结果
--! @return   
--]]
function CrusadeView:getCrusadeBoxReward(inCrusadeId, inCrusadeData)
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if lastFinCrusade >= inCrusadeId then
        self._viewMgr:showTip(lang("CRUSADE_TIPS_5"))
        return 
    end

    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    if activeCrusadeId < inCrusadeId then 
        self:showCrusadeBoxReward(inCrusadeId, inCrusadeData)
        return
    end
    local param = {}
    param.id= inCrusadeId
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadeBoxReward", param, true, {}, function (result)
        return self:getCrusadeBoxRewardFinish(result)
    end)
end


--[[
--! @function getCrusadeBoxRewardFinish
--! @desc 获取远征宝箱奖励返回信息
--! @param result object 返回结果
--! @return 
--]]
function CrusadeView:getCrusadeBoxRewardFinish(result)
    if result == nil then
        return 
    end
    DialogUtils.showGiftGet( {
    gifts = result.reward,
    canGet = true, 
    des = lang("FINISHSTAGEAWARD_2"),
    callback = function()
        self:updateLastCrusade()
    end} )
end

--[[
--! @function runFirstAnim
--! @desc 第一次进入远征动画
--! @param 
--! @return 
--]]
function CrusadeView:runFirstAnim()
    local crusadeData = self._modelMgr:getModel("CrusadeModel"):getData()
    local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    local isPrivOpen1 = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.MuXueHuLan)
    local isShowed = SystemUtils.loadAccountLocalData("CRUSADE_TEQUE_ANIM_IS_SHOWED")
    
    if crusadeData.isFirst ~= 1 then 
        if isPrivOpen1 ~= 0 and isShowed ~= 1 then  --特权开启动画
            self._viewMgr:lock(-1)
            local blackBg = ccui.Layout:create()
            blackBg:setBackGroundColorOpacity(120)
            blackBg:setBackGroundColorType(1)
            blackBg:setBackGroundColor(cc.c3b(0, 0, 0))
            blackBg:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
            self:addChild(blackBg)

            local fogLayer = ccui.Layout:create()
            self:addChild(fogLayer)

            fogLayer:runAction(cc.Sequence:create(
                cc.CallFunc:create(function() 
                    fogLayer:removeFromParent() 
                    self:runEnterAnim(2, blackBg)
                    end), 
                cc.DelayTime:create(0.3), 
                cc.CallFunc:create(function() 
                    self._viewMgr:unlock() 
                    end)))
        else
            self:showSweepView()
        end
        return 
    end 

    self._viewMgr:lock(-1)   --wangyan
    crusadeData.isFirst = 0   

    local count = #self._widget:getChildren()
    for i = 1, count do
        local subView = self._widget:getChildren()[i]
        if subView:getName() ~= self._scrollView:getName() then 
            subView:setVisible(false)
        end
    end
    local fogLayer = cc.Layer:create()
    fogLayer:setAnchorPoint(0, 0)
    fogLayer:setPosition(0, 0)
    fogLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)

    local tempFog = cc.Sprite:create("asset/uiother/intance/intanceImageUI4_fog.png")
    tempFog:setScaleY(1.06)
    local x, y = 0, 0
    local width = tempFog:getContentSize().width
    local height = tempFog:getContentSize().height
    randomNumH = GRandom(20, height /2 - 10)

    y = -randomNumH
    local randomNum
    while true do
        tempFog = cc.Sprite:create("asset/uiother/intance/intanceImageUI4_fog.png")
        tempFog:setScaleY(1.06)
        tempFog:setAnchorPoint(0, 0)
        tempFog:setPosition(x, y)
        fogLayer:addChild(tempFog, 100)
        randomNumH = GRandom(height / 2, height - 10)
        y = y + height - randomNumH
        if y  > (MAX_SCREEN_HEIGHT - randomNumH) then
            randomNumH = GRandom(20, height /2 - 10)
            y = -randomNumH
            randomNumW = GRandom(width / 2, width - 10)
            x = x + width - randomNumW
            if x > MAX_SCREEN_WIDTH then 
                break
            end
        end
    end
    fogLayer:setCascadeOpacityEnabled(true, true)
    fogLayer:setOpacity(255)
    fogLayer:runAction(cc.Sequence:create(cc.Spawn:create(
        cc.MoveTo:create(2, cc.p(MAX_SCREEN_WIDTH, fogLayer:getPositionY())),
        cc.FadeOut:create(1.5)),
        cc.CallFunc:create(function() 
            fogLayer:removeFromParent() 
            self:runEnterAnim(1)
        end), cc.DelayTime:create(1), cc.CallFunc:create(function() self._viewMgr:unlock() end)))
    self:addChild(fogLayer)
end

function CrusadeView:runEnterAnim(inType, inObj)
    --开始动画背景光
    local animBg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true)
    animBg:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
    self._startAimBg = animBg
    self:addChild(animBg)
    animBg:setVisible(false)

    local animName, fps1, fps2 
    if inType == 2 then   --开启扫荡动画
        animName = "zhanyisaodang_zhanyisaodang"
        fps1, fps2 = 4, 23
    else
        animName = "kaishiyuanzheng_intancenopen"
        fps1, fps2 = 7, 35
    end

    --开始动画
    local anim = mcMgr:createViewMC(animName, false, true, function()
        self._viewMgr:unlock()
        local count = #self._widget:getChildren()
        for i = 1, count do
            local subView = self._widget:getChildren()[i]
            if subView:getName() ~= self._scrollView:getName()
                and subView:getName() ~= "bufferBg" then 
                subView:setVisible(true)
            end
        end
        self:getUI("buffBg"):setVisible(false)
        self:setNavigation()
        self:showSweepView()
    end)
    anim:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
    self:addChild(anim)

    anim:addCallbackAtFrame(fps1, function()
        if self._startAimBg then
            self._startAimBg:setVisible(true)
        end
        end)
    anim:addCallbackAtFrame(fps2, function()
        if self._startAimBg then
            self._startAimBg:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                    if inObj then
                        inObj:runAction(cc.FadeOut:create(0.1))
                    end
                    end),
                cc.FadeOut:create(0.1),
                cc.CallFunc:create(function()
                    if inObj then
                        inObj:removeFromParent(true)
                        inObj = nil
                    end
                    self._startAimBg:removeFromParent(true)
                    self._startAimBg = nil
                    end)))
            --开启扫荡动画
            if animName == "zhanyisaodang_zhanyisaodang" then
                SystemUtils.saveAccountLocalData("CRUSADE_TEQUE_ANIM_IS_SHOWED", 1) 
            end
        end
        end)
end

--[[
--! @function resetCrusade
--! @desc 重置远征
--! @param 
--! @return 
--]]
function CrusadeView:resetCrusade()
    local userCrusade = self._crusadeModel:getData()
    local triggerData = self._crusadeModel:getResetData()
    local lastReSetNum = self._crusadeModel:getLastReSetNum()
    if lastReSetNum <= 0 then 
        self._viewMgr:showTip(lang("CRUSADE_TIPS_3"))
        return 
    end

    local function localResetCrusade()
        self._serverMgr:sendMsg("CrusadeServer", "resetCrusade", {}, true, {}, function (result)
            return self:resetCrusadeFinish()
        end)
    end

    -- 确认弹窗
    local checkList = {}
    local usePcs = userCrusade.usePcs
    local needPcs = userCrusade.needPcs
    local unusePcs = userCrusade.unusePcs
    if usePcs == needPcs then  --宝藏未领
        table.insert(checkList, lang("CRUSADE_TIPS_2"))
    end

    if next(triggerData) ~= nil and triggerData["triggerStatus"] <= 0 then  --触发关未通关
        table.insert(checkList, lang("CRUSADE_TIPS_TRIG_7"))
    end

    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId or 1
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if activeCrusadeId >= lastFinCrusade then  
        local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
        local isPrivOpen1 = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.MuXueHuLan)  --特权子爵开启判断
        local isPrivOpen2 = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.YuanZhengSaodang)  --特权公爵开启判断
        local boxTres = self._crusadeModel:getData().boxTres
        local tipDes = ""

        if isPrivOpen2 ~= 0 then        --公爵特权开启
            if boxTres and boxTres["extraBoxId"] ~= nil and boxTres["extraBoxId"] > lastFinCrusade then  --有紫色宝物且没领
                tipDes = lang("CRUSADE_TIPS_TRIG_9")
            elseif lastFinCrusade < 15 then   --通关数小于15
                tipDes = lang("CRUSADE_TIPS_TRIG_10")
            else                              --可扫荡关数提示
                tipDes = lang("CRUSADE_TIPS_TRIG_8")
            end

            tipDes = string.gsub(tipDes, "${stage1}", math.floor(lastFinCrusade*0.5))
            tipDes = string.gsub(tipDes, "${stage2}", math.max(math.ceil(lastFinCrusade*0.5) - tab.setting["G_CRUSADE_PEERAGE_2"].value, 0))
            tipDes = string.gsub(tipDes, "${num}", tab.setting["G_CRUSADE_PEERAGE_2"].value)
            table.insert(checkList, tipDes)

        else
            if isPrivOpen1 ~= 0 then    --子爵特权开启
                if boxTres and boxTres["extraBoxId"] ~= nil and boxTres["extraBoxId"] > lastFinCrusade then  --有紫色宝物且没领
                    tipDes = lang("CRUSADE_TIPS_TRIG_9")
                elseif lastFinCrusade < 15 then   --通关数小于15
                    tipDes = lang("CRUSADE_TIPS_TRIG_10")
                else                              --可扫荡关数提示
                    tipDes = lang("CRUSADE_TIPS_TRIG_8")
                end

                tipDes = string.gsub(tipDes, "${stage1}", math.floor(lastFinCrusade*0.5))
                tipDes = string.gsub(tipDes, "${stage2}", math.max(math.ceil(lastFinCrusade*0.5) - tab.setting["G_CRUSADE_PEERAGE_1"].value, 0))
                tipDes = string.gsub(tipDes, "${num}", tab.setting["G_CRUSADE_PEERAGE_1"].value)
                table.insert(checkList, tipDes)
            else
                if boxTres and boxTres["extraBoxId"] ~= nil and boxTres["extraBoxId"] > lastFinCrusade then  --有紫色宝物且没领
                    tipDes = lang("CRUSADE_TIPS_TRIG_12")
                elseif lastFinCrusade < 15 then   --通关数小于15
                    tipDes = lang("CRUSADE_TIPS_TRIG_13")
                else                              --可扫荡关数提示
                    tipDes = lang("CRUSADE_TIPS_TRIG_11")
                end
                tipDes = string.gsub(tipDes, "${num}", tab.setting["G_CRUSADE_PEERAGE_1"].value)
                table.insert(checkList, tipDes)
            end
        end
    end
    
    local function checkFun(desc)
        self._checkIndex = self._checkIndex and self._checkIndex+1 or 1
        self._viewMgr:showDialog("global.GlobalSelectDialog",
        {   desc = checkList[self._checkIndex],
            button1 = "确定",
            button2 = "取消", 
            callback1 = function ()
                if self._checkIndex == #checkList then
                    localResetCrusade()
                    self._checkIndex = 0
                    checkList = {}
                else
                    return checkFun()
                end
            end,
            callback2 = function()
                self._checkIndex = 0
                checkList = {}
            end})
    end

    if #checkList == 0 then
        localResetCrusade()
    else
        checkFun()
    end
end

--[[
--! @function resetCrusadeFinish
--! @desc 重置服务器返回处理
--! @param result object 返回结果
--! @return 
--]]
function CrusadeView:resetCrusadeFinish(inType)
    local buildingIcon = self._scrollView:getChildByName("CRUSADE_TREASURE")
    if buildingIcon ~= nil then 
        buildingIcon:removeFromParent()
    end
    for k,v in pairs(self._usingIcon) do   
        v:removeFromParent()
    end

    for k,v in pairs(self._buildingFog) do   
        for f,g in pairs(v) do
            g:removeFromParent()
        end
    end

    for k,v in pairs(self._linePoint) do   
        v:removeFromParent()
    end

    if self._swordWidget then
        self._swordWidget:removeFromParent(true)
        self._swordWidget = nil
    end
    
    self._linePoint = {}
    self._usingIcon = {}
    self._buildingFog = {}
    self:reflashUI()

    if inType ~= "sweep" then
        local resetCrusadeData = self._crusadeModel:getResetData()
        if next(resetCrusadeData) ~= nil and resetCrusadeData["triggerId"] ~= CrusadeConst.CRUSADE_RESET_TYPE.NONE then
            self:showAngelSwordAim()   --天使动画
        end
        self._viewMgr:showTip("重置成功")
    end
end

--远征重置触发动画
function CrusadeView:showAngelSwordAim()
    self._viewMgr:lock(-1)
    local resetCrusadeData = self._crusadeModel:getResetData()
    -- dump(resetCrusadeData, "", 10)

    local triggerData = tab.triggerEvent[resetCrusadeData["triggerId"]]
    local insertCrusade = tab.crusadeMain[resetCrusadeData["nearByCrusade"]]

    local angleSwordLayer = cc.Layer:create()   
    angleSwordLayer:setAnchorPoint(0, 0)
    angleSwordLayer:setPosition(0, 0)
    angleSwordLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(angleSwordLayer)

    --播放天使剑动画
    local action1 = cc.CallFunc:create(function()
        self:updateScrollMaxWidth(resetCrusadeData["nearByCrusade"])  -- 更新可视区域
        self:scrollCurActBuilding(resetCrusadeData["nearByCrusade"])  -- 滑动scrollview显示天使剑
    end)

    local action2 = cc.CallFunc:create(function()
        local luojianAnim = mcMgr:createViewMC("luojian_yincang", false, true)
        luojianAnim:addCallbackAtFrame(4, function() 
            self:showTriggerCrusadeStatus()
            end)
        luojianAnim:setPosition(insertCrusade["posi"][1], insertCrusade["posi"][2])
        self._scrollView:addChild(luojianAnim, 11)
    end)

    local action3 = cc.CallFunc:create(function()   --剧情对话
        self._viewMgr:unlock()
        ViewManager:getInstance():enableTalking(triggerData["words1"], {}, function()
            self._viewMgr:lock(-1)
            self:runAction(cc.Sequence:create(
                    cc.CallFunc:create(function()
                        self._scrollView:scrollToPercentHorizontal(0, 2, true)
                    end),
                    cc.DelayTime:create(2),
                    cc.CallFunc:create(function()
                        self._scrollView:setInnerContainerSize(cc.size(BG_SCALE_WIDTH, MAX_SCREEN_HEIGHT))
                        self._viewMgr:unlock()
                    end)
                )
            )  
        end)
    end)

    angleSwordLayer:runAction(cc.Sequence:create(action1, action2, cc.DelayTime:create(1), action3))
end

--天使剑常态动画
function CrusadeView:showTriggerCrusadeStatus()
    -- print("showTriggerCrusadeStatus======wy")
    if self._swordWidget then
        self._swordWidget:removeFromParent(true)
        self._swordWidget = nil
    end
    
    local triggerData = self._crusadeModel:getResetData()
    if next(triggerData) == nil or triggerData["triggerStatus"] > 0 then 
        return 
    end
    local sysTriggerEvent = tab.triggerEvent
    local insertCrusade = tab.crusadeMain[triggerData["nearByCrusade"]]

    self._swordWidget = ccui.Widget:create()
    self._swordWidget:setContentSize(60, 150)
    self._swordWidget:setAnchorPoint(cc.p(0.5,0.5))
    self._swordWidget:setPosition(insertCrusade["posi"][1], insertCrusade["posi"][2])
    self._scrollView:addChild(self._swordWidget, 10)

    local angleSword = mcMgr:createViewMC("changtai_yincang", true, false)
    angleSword:setPosition(30, 75)
    self._swordWidget:addChild(angleSword)

    self:registerClickEvent(self._swordWidget, function() 
        if self._crusadeModel:getData().lastCrusade < triggerData["nearByCrusade"] then 
            self._viewMgr:showTip(lang("CRUSADE_TIPS_TRIG_5"))
        else
            --battle 触发关
            -- if SystemUtils.loadAccountLocalData("crusadeTriggerSelect") == true then
            --     self._serverMgr:sendMsg("CrusadeServer", "enterTriggerCrusade", {type = 0}, true, {}, function (result)
            --         self._viewMgr:showDialog("crusade.CrusadeTriggerBattleNode",{
            --             cruData = result,
            --             cruType = 0,
            --             callback = function()
            --                 self:setSwordState("duanjian")
            --             end
            --             }, true)
            --     end)
            -- else
                self:triggerSpecialCrusade()
            -- end
            
        end 
    end)
end

--远征关卡点击事件
function CrusadeView:showCrusadeNodeEvent(inCrusadeId, inCrusadeData, ctype)
    self:setMapResProg(2)
    local function doCrusade(cruType)
        local cruType = string.split(cruType, "_")
        if cruType[1] == "battle" then
            self:showCrusadeBattleNode(inCrusadeId, inCrusadeData)
        elseif cruType[1] == "reward" then
            self:getCrusadeBoxReward(inCrusadeId, inCrusadeData)
        elseif cruType[1] == "event" then
            self:showCrusadeEventNode(inCrusadeId, inCrusadeData, tonumber(cruType[2]))
        end
    end 

    --判断是否有trigger特殊关
    local isTrigger = false
    local resetTrigger = self._crusadeModel:getResetData()
    if resetTrigger == nil or next(resetTrigger) == nil then  
        doCrusade(ctype)
        return
    end

    --触发关 二次确认
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if lastFinCrusade >= resetTrigger["nearByCrusade"] and resetTrigger["triggerStatus"] == 0 and inCrusadeId - lastFinCrusade == 1 then  
        isTrigger = true
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = lang("CRUSADE_TIPS_TRIG_6"),
            button1 = "确定" ,
            button2 = "取消", 
            callback1 = function()
                isTrigger = false
                self._serverMgr:sendMsg("CrusadeServer", "abandonTriggerCrusade", {}, true, {}, function(result)
                    self._swordWidget:removeFromParent(true)
                    self._swordWidget = nil
                    doCrusade(ctype)
                    end)
            end,
            callback2 = function()
                isTrigger = true
            end}, true)
    end
    if not isTrigger then       
        doCrusade(ctype)
    end
end

--触发特殊关卡
function CrusadeView:triggerSpecialCrusade()
    -- print("CrusadeView:triggerSpecialCrusade======wy")
    local resetTrigger = self._crusadeModel:getResetData()
    if resetTrigger == nil or next(resetTrigger) == nil then  
        return
    end
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if lastFinCrusade >= resetTrigger["nearByCrusade"] and resetTrigger["triggerStatus"] == 0  then
        local triggerData = tab.triggerEvent[resetTrigger["triggerId"]]
        self._storyView = ViewManager:getInstance():enableTalking(triggerData["words2"], "", function()
            local function callback(result, choTye)
                ViewManager:getInstance():disableTalking(function()
                        self:triggerEventHandle(result, resetTrigger["triggerId"], choTye)
                    end)
            end

            local data = {callBack = callback, triType = resetTrigger["triggerId"]}
            self._viewMgr:showDialog("crusade.CrusadeTriggerBtnNode", data, true)

            -- local chooseLayer = require("game.view.crusade.CrusadeTriggerBtnNode").new(data)
            -- ViewManager:getInstance()._navigationLayer:addChild(chooseLayer, 100) 
        end, false)
    end
end

--触发关处理
function CrusadeView:triggerEventHandle(serverData, cruTye, choTye)
    -- print("cruTye, choTye========", cruTye, choTye)
    if cruTye == CrusadeConst.CRUSADE_RESET_TYPE.REWARD then   --1 reward
        if choTye == true then
            self._serverMgr:sendMsg("CrusadeServer", "getCrusadeTriggerReward", {type = 1, token = serverData["token"]}, true, {}, function (result)
                DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    callback = function()
                        self:setSwordState("shangtian")
                        self._viewMgr:showTip(lang("CRUSADE_TIPS_TRIG_1"))
                    end
                })
            end)
            
        elseif choTye == false then
            self._serverMgr:sendMsg("CrusadeServer", "getCrusadeTriggerReward", {type = 0, token = serverData["token"]}, true, {}, function (result)
                DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    callback = function()
                        self:setSwordState("duanjian")
                        self._viewMgr:showTip(lang("CRUSADE_TIPS_TRIG_2"))
                    end
                })
            end)
        end

    elseif cruTye == CrusadeConst.CRUSADE_RESET_TYPE.BATTLE then  --2 battle
        if choTye == true then
            self._serverMgr:sendMsg("CrusadeServer", "getCrusadeTriggerReward", {type = 1, token = serverData["token"]}, true, {}, function (result)
                dump(result, "456", 10)
                DialogUtils.showGiftGet( {
                    gifts = result["reward"], 
                    callback = function()
                        self:setSwordState("shangtian")
                        self._viewMgr:showTip(lang("CRUSADE_TIPS_TRIG_3"))
                    end
                })
            end) 
            
        elseif choTye == false then
            local ani = cc.CallFunc:create(function()
                    self._viewMgr:showTip(lang("CRUSADE_TIPS_TRIG_4"))
                end)
            local battle = cc.CallFunc:create(function()
                    self._viewMgr:showDialog("crusade.CrusadeTriggerBattleNode",{
                        cruData = serverData,
                        cruType = 0,
                        callback = function()
                            self:setSwordState("duanjian")
                        end
                        }, true)
                end)
            self:runAction(cc.Sequence:create(ani, cc.DelayTime:create(1), battle))
        end
    end
end

function CrusadeView:setSwordState(type)
    self._swordWidget:setTouchEnabled(false)
    self._swordWidget:removeAllChildren()

    if type == "shangtian" then
        local shangtian = mcMgr:createViewMC("shangtian_yincang", false, false, function()
            self._swordWidget:removeFromParent(true)
            self._swordWidget = nil
            end)
        shangtian:setPosition(self._swordWidget:getContentSize().width/2, self._swordWidget:getContentSize().height/2)
        self._swordWidget:addChild(shangtian)

    elseif type == "duanjian" then
        local duanjian = mcMgr:createViewMC("duanjian_yincang", false, false, function()
            self._swordWidget:removeFromParent(true)
            self._swordWidget = nil
            end)
        duanjian:setPosition(self._swordWidget:getContentSize().width/2, self._swordWidget:getContentSize().height/2)
        self._swordWidget:addChild(duanjian)
    end
end

-- 左下角菜单
function CrusadeView:setMenu()
    local mapTip = self:getUI("menu.mapTip")
    mapTip:setScaleAnim(true)
    mapTip:setVisible(false)

    local lab1 = self:getUI("menu.treasure.lab")
    lab1:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    lab1:setFontName(UIUtils.ttfName)
    local lab2 = self:getUI("menu.shop.lab")
    lab2:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    lab2:setFontName(UIUtils.ttfName)
    local lab3 = self:getUI("menu.rule.lab")
    lab3:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    lab3:setFontName(UIUtils.ttfName)

    local treasure = self:getUI("menu.treasure")
    treasure:setScaleAnim(true)
    local shop = self:getUI("menu.shop")
    shop:setScaleAnim(true)
    local rule = self:getUI("menu.rule")
    rule:setScaleAnim(true)

    --藏宝图btn
    self:registerClickEvent(treasure, function()            
        self._viewMgr:showDialog("crusade.CrusadeTreasureMapNode", {
            callback = function(inNeedScroll)
                if inNeedScroll == true then
                    self:updateTreasurePoint()
                    self:scrollTreasurePoint()
                end
            end})
    end)

    --商店btn
    self:registerClickEvent(shop, function()                
        self._viewMgr:showView("shop.ShopView",{idx=3})
    end)

    --规则btn
    self:registerClickEvent(rule, function()                
        self._viewMgr:showDialog("crusade.CrusadePopDescNode",{test = 1},true) 
    end)

    --藏宝图进度pop
    self:registerClickEvent(mapTip, function()  
        local usePcs = self._crusadeModel:getData().usePcs
        local needPcs = self._crusadeModel:getData().needPcs             
        if usePcs ~= needPcs or (mapTip.lastCheckTime and os.time() - mapTip.lastCheckTime <= 3) then  --3s内不能重复查看
            return
        end
        mapTip.lastCheckTime = os.time()
        self:updateTreasurePoint()
        self:scrollTreasurePoint()
    end)
end

function CrusadeView:setMapResProg(inType)
    local mapTip = self:getUI("menu.mapTip")

    --hide
    local activeCrusadeId = self._crusadeModel:getData().activeCrusadeId
    local lastFinCrusade = self._crusadeModel:getData().lastCrusade
    if inType == 2 or (activeCrusadeId and lastFinCrusade and activeCrusadeId == lastFinCrusade) then   
        mapTip:setVisible(false)
        mapTip:stopAllActions()
        return
    end

    if not mapTip:isVisible() then
        mapTip:stopAllActions()
        mapTip:setPosition(296, 95)
        mapTip:setVisible(true)
        mapTip:setScale(0)

        mapTip:runAction(cc.Sequence:create(
            cc.FadeIn:create(0.2),
            cc.ScaleTo:create(0.3, 1.05),
            cc.CallFunc:create(function()
                mapTip:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(
                        cc.ScaleTo:create(0.7, 0.92),
                        cc.ScaleTo:create(0.7, 1.05)
                        )))
                end)))
    end
end

function CrusadeView:showSweepView(inType)
    local function openView(inData)
        local result = inData or {}
        self._viewMgr:showDialog("crusade.CrusadeSweepView", {
            reward = result["reward"],
            oneKeySweep = self._oneKeySweep,
            parentView = self, 
            callback1 = function()
                self:resetCrusadeFinish("sweep")   --刷新关卡
                self:showTriggerCrusadeStatus()
            end,
            callBack2 = function(inNeedScroll)     --挖宝藏动画
                if inNeedScroll == true then
                    self._viewMgr:lock(-1)
                    self:updateTreasurePoint()
                    self:scrollTreasurePoint()
                end
            end}, true)
    end

    if inType == 1 then
        self._serverMgr:sendMsg("CrusadeServer", "oneKeySweepCrusade", {}, true, {}, function (result)
            openView(result)
        end)
    else

        local crusadeData = self._crusadeModel:getData()
        --是否是未扫荡完成
        if crusadeData["oneKeySweep"] ~= 1 then
            return
        end

        local isSp, isBuff, isTreasure = self._crusadeModel:checkSencondSweepState()
        if next(isSp) or next(isBuff) then  --是否有小精灵/buff
            openView()

        else
            self._serverMgr:sendMsg("CrusadeServer", "finishOneKeySweepCrusade", {}, true, {}, function()
                if next(isTreasure) then  --地图宝藏
                    audioMgr:playSound("MapFrag")
                    self._viewMgr:showDialog("crusade.CrusadeTreasureMapNode", {
                        amin = true,
                        callback = function(inNeedScroll)
                            if inNeedScroll == true then
                                self._viewMgr:lock(-1)
                                self:updateTreasurePoint()
                                self:scrollTreasurePoint()
                            end
                        end
                        }, true) 
                end
            end)
        end
    end
end

function CrusadeView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    CrusadeView.super.onDestroy(self)
end

return CrusadeView