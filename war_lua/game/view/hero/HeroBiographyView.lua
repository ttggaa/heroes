--
-- Author: huangguofang
-- Date: 2017-01-17 17:15:28
--

local HeroBiographyView = class("HeroBiographyView", BasePopView)

local AnimAp = require "base.anim.AnimAP"
function HeroBiographyView:ctor(data)
    HeroBiographyView.super.ctor(self)
    -- self.initAnimType = 1
    self._heroModel = self._modelMgr:getModel("HeroModel")
    -- self._userModel = self._modelMgr:getModel("UserModel")
    self._heroId = data.heroId or 60102
    self._callBack = data.callback or nil
end

function HeroBiographyView:getAsyncRes()
    return 
    {
        {"asset/ui/heroBio.plist", "asset/ui/heroBio.png"},
        {"asset/ui/heroBio1.plist", "asset/ui/heroBio1.png"},
    }
end

function HeroBiographyView:onInit()
    -- 通用动态背景
    -- self:addAnimBg()

    self._bioData = {}                      -- 传记数据
    self._isAllMistClear = false            -- 是否迷雾全开
    self._passBioData = {}                  -- 通关传记ID数组
    self._bioIndexData = {}                 -- 传记 关卡 映射（6010201 = 1, 6010202 = 2）
    self._memoirsData = {}                  -- 回忆录数据
    self._buildItem = {}                    -- 所有关卡obj（包含宝箱）
    self._currStageIdx = 0                  -- 当前点击关卡
    self._stageIdx = 1                      -- 当前挑战关

    -- 解锁提示
    self._tipsPanel = self:getUI("tipsPanel")
    self._tipsBg = self:getUI("tipsPanel.tipsBg")
    local title = self._tipsBg:getChildByFullName("title")
    local stageName = self._tipsBg:getChildByFullName("stageName")
    title:setColor(cc.c4b(255,255,255,255))
    title:enable2Color(1, cc.c4b(254,255,128,255))
    title:enableOutline(cc.c4b(134,53,0,255),1)
    stageName:setColor(cc.c4b(250,229,202,255))
    stageName:enableOutline(cc.c4b(134,53,0,255),1)
    self._tipsPanel:setSwallowTouches(false)
    self._tipsPanel:setVisible(false)


    -- 是否播放过riddle动画
    self._riddleAnim = {}
    for i=1,5 do
        self._riddleAnim[tonumber(self._heroId .. "0" .. i)] = SystemUtils.loadAccountLocalData("BIOGRAPHY_Anim_" .. self._heroId .. "0" .. i) or false
    end

    -- 是否播放过解锁动画
    self._unlockAnim = {}
    for i=1,5 do
        self._unlockAnim[tonumber(self._heroId .. "0" .. i)] = SystemUtils.loadAccountLocalData("BIOGRAPHY_UnlockAnim_" .. self._heroId .. "0" .. i) or false
    end

    -- dump(bioServerData,"bioserver",5)
    self._bioData = self:initBioData() --, self._memoirsData
    self._stageIdx = self:searchCurrSatge()
    self._currStageIdx = self._stageIdx

    -- dump(self._bioData,"============>",5)

    local bgData = tab:HeroBio(tonumber(self._heroId .. "01"))
    local bgNameStr = bgData and bgData.bg or "heroBio_bg_" .. self._heroId
    local bgImg = self:getUI("bg.stagePanel.bgImg")
    bgImg:loadTexture("asset/bg/" .. bgNameStr .. ".jpg")

    self:registerClickEventByName("bg.btn_return", function(sender)
        if self._callBack then
            self._callBack()
        end
        self:close()
        UIUtils:reloadLuaFile("hero.HeroBiographyView")
    end)

    -- 规则按钮
    self._ruleBtn = self:getUI("bg.buttomPanel.btn_rule")
    UIUtils:addFuncBtnName(self._ruleBtn, "规则",cc.p(self._ruleBtn:getContentSize().width/2,0),true,18)
    local name = self:getUI("bg.buttomPanel.btn_rule.name")
    local bgImg = self:getUI("bg.buttomPanel.btn_rule.bgImg")
    name:setVisible(false)
    bgImg:setVisible(false)
    -- name:setFontName(UIUtils.ttfName_Title)
    -- name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(self._ruleBtn, function(sender)
        self:ruleButtonClicked()
    end)

    --回忆录按钮
    self._memoirsBtn = self:getUI("bg.buttomPanel.btn_memoirs")
    UIUtils:addFuncBtnName(self._memoirsBtn, "回忆录",cc.p(self._memoirsBtn:getContentSize().width/2,2),true,18)
    self._memoirsRed = self:getUI("bg.buttomPanel.btn_memoirs.redImg")
    -- 通关第二关显示 解锁第二个传记
    self._memoirsBtn:setVisible(self._bioData[1] and self._bioData[1].isPassed)
    self._memoirsRed:setVisible(self:isMemoirsRed())
    local name = self:getUI("bg.buttomPanel.btn_memoirs.name")
    local bgImg = self:getUI("bg.buttomPanel.btn_memoirs.bgImg")
    name:setVisible(false)
    bgImg:setVisible(false)
    -- name:setFontName(UIUtils.ttfName_Title)
    -- name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    self:registerClickEvent(self._memoirsBtn, function(sender)
        self:memoirsButtonClicked()
    end)

    self._stagePanel    = self:getUI("bg.stagePanel")
    self._lockPanel     = self:getUI("bg.buttomPanel.conditionPanel")
    self._conPanel      = self:getUI("bg.buttomPanel.conditionPanel.conPanel")
    
    local desTxt        = self:getUI("bg.buttomPanel.conditionPanel.conDes")
    desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._riddlePanel   = self:getUI("bg.buttomPanel.riddlePanel")
    self._riddleName    = self:getUI("bg.buttomPanel.riddlePanel.desPanel.stageName")
    self._riddleTxt     = self:getUI("bg.buttomPanel.riddlePanel.desPanel.riddleTxt")

    -- 前往
    self._goPanel       = self:getUI("bg.buttomPanel.goPanel")
    self._goBtn         = self:getUI("bg.buttomPanel.goPanel.goBtn")
    self._proTxt        = self:getUI("bg.buttomPanel.goPanel.proTxt")

    -- 战斗按钮
    self._fightBtn      = self:getUI("bg.buttomPanel.fightBtn")
    self._unLockPanel   = self:getUI("bg.buttomPanel.fightPanel")
    local stageDes      = self:getUI("bg.buttomPanel.fightPanel.stageDes")
    self._unLockDesName = self:getUI("bg.buttomPanel.fightPanel.stageName")
    self._stageTxt      = self:getUI("bg.buttomPanel.fightPanel.stageTxt")
    stageDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._stageTxt:setFontName(UIUtils.ttfName )
    self._stageTxt:setFontSize(20)
    self._stageTxt:setTextAreaSize(cc.size(600,65))
    self._stageTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    -- 战斗按钮特效
    self._fightBtnAmin1 = mcMgr:createViewMC("zhandouguangxiao_battlebtn", true)
    self._fightBtnAmin1:setPosition(self._fightBtn:getContentSize().width/2, self._fightBtn:getContentSize().height/2)
    self._fightBtn:addChild(self._fightBtnAmin1)    
    local fightImg = self:getUI("bg.buttomPanel.fightBtn.fightImg")
    self._fightBtnAmin2 = mcMgr:createViewMC("zhengfusaoguang_battlebtn", true)
    self._fightBtnAmin2:setPosition(fightImg:getContentSize().width/2, fightImg:getContentSize().height/2)
    fightImg:addChild(self._fightBtnAmin2)

    --初始化地图
    self:initStageMap()
    -- self:updateButtomPanel(self._bioData[self._stageIdx])
    self:checkStageAnim(self._bioData[self._stageIdx])
    -- self._testOpacity = 0
    --初始化迷雾
    -- self:initStageFog()

end

-- 规则按钮点击事件
function HeroBiographyView:ruleButtonClicked()
    self._viewMgr:showDialog("hero.HeroBiographyRuleDialog")

end
-- 回忆录按钮点击事件
function HeroBiographyView:memoirsButtonClicked()
    self._viewMgr:showDialog("hero.HeroBioMemoirDialog",{heroId = self._heroId,callBack = function()
        self._memoirsRed:setVisible(self:isMemoirsRed())
    end})

end

-- 初始化传记关卡地图
function HeroBiographyView:initStageMap()

    for k,v in pairs(self._bioData) do
        local buildObj 
        if self["createBuildItem" .. v.buildType] then
             buildObj = self["createBuildItem" .. v.buildType](self,v)
        end
        local posX = v.staPlace and v.staPlace[1] or 0
        local posY = v.staPlace and v.staPlace[2] or 0
        buildObj:setPosition(posX,posY)        
        self._stagePanel:addChild(buildObj,1)
        self._buildItem[tonumber(k)] = buildObj

        self:registerClickEvent(buildObj, function(sender) 
            -- 1 关卡  2 宝箱
            -- print("==================== self._currStageIdx ==", self._currStageIdx)
            if 1 == v.buildType then
                self:stageBuildClicked(tonumber(k))
            else
                self:boxBuildClicked(tonumber(k))
            end
        end)
    end
 
    if not self._stagePanel._currPoint then
        if not self._bioData or not self._buildItem or not self._stagePanel then return end
        local currPoint = mcMgr:createViewMC("dangqianguan_herozhuanji", true)
        currPoint:setScale(1)
        self._stagePanel._currPoint = currPoint
        self._stagePanel:addChild(currPoint)

        local posX = self._bioData[self._stageIdx].staPlace and self._bioData[self._stageIdx].staPlace[1] or 0
        local posY = self._bioData[self._stageIdx].staPlace and self._bioData[self._stageIdx].staPlace[2] or 0
        local selectCoord = self._bioData[self._stageIdx].selectCoord
        posX = posX + selectCoord[1]
        posY = posY + selectCoord[2]
        local height = 0
        if self._buildItem[self._stageIdx] then
            height = self._buildItem[self._stageIdx]:getContentSize().height
        end
        height = posY - height * 0.5 + 20

        -- print("===========self._stagePanel._currPoint======posX====",posX,posY)
        self._stagePanel._currPoint:setPosition(posX,height) 
    end

end  

-- 战后动画
function HeroBiographyView:bioFightAfterAnim()
    -- if true then return end 
    if not self then return end
    -- 如果不是战后赢不更新
    if not self._isAfterBattle or self._isAfterBattle == 0 then return end
    self._isAfterBattle = nil
    if not self._bioData or not self._currStageIdx then return end    

    local currData = self._bioData[self._currStageIdx]
    -- 已通关不做刷新
    if currData.state == 2 then return end
    local currBuild = self._buildItem[self._currStageIdx]
    if not currData or not currBuild then return end    
    --宝箱
    if 1 ~= currData.buildType then return end

    self._bioData = self:initBioData()
    local currData = self._bioData[self._currStageIdx] 

    -- 更新回忆录显示 及红点显示
    self._memoirsBtn:setVisible(self._bioData[3] and self._bioData[3].isPassed)
    self._memoirsRed:setVisible(self:isMemoirsRed())
    -- self:updateBoxItem(self._currStageIdx + 1)

    -- 重新绘制迷雾
    -- self:initStageFog()

    -- 通关标志
    local passTime = 0
    local passImg = currBuild._passImg 
    if tolua.isnull(passImg) ~= nil and currData.isPassed then
        passTime = 0.15
        passImg:setScale(3)
        passImg:setVisible(true)
        passImg:runAction(cc.ScaleTo:create(passTime, 1))
    end
    -- 路点
    local imgName = currData.isPassed and "heroBio_pointGreen.png" or "heroBio_pointGray.png"
    local stageFog = currData.stafog
    if stageFog then
        for k,v in pairs(stageFog) do
            if currBuild["_pointImg" .. k] then

                local ac1 = cc.DelayTime:create(passTime + 0.15 * k )
                local ac2 = cc.CallFunc:create(function ()
                    currBuild["_pointImg" .. k]:loadTexture(imgName,1)
                end)

                if k == #stageFog then                  
                    local ac3 = cc.DelayTime:create(0.15)
                    local ac4 = cc.CallFunc:create(function()
                        --更新显示
                        self:updateBoxItem(self._currStageIdx + 1)
                        self:updateBuildItem(self._currStageIdx)
                        -- 战后更新地图显示
                        local currStageIdx = self:searchCurrSatge()
                        self:stageBuildClicked(currStageIdx)
                    end)
                    currBuild["_pointImg" .. k]:runAction(cc.Sequence:create(ac1, ac2, ac3,ac4))
                else
                    currBuild["_pointImg" .. k]:runAction(cc.Sequence:create(ac1, ac2))
                end
            end
        end
    else
        --更新显示
        self:updateBoxItem(self._currStageIdx + 1)
        self:updateBuildItem(self._currStageIdx)
        -- 战后更新地图显示
        local currStageIdx = self:searchCurrSatge()
        self:stageBuildClicked(currStageIdx)
    end
    
end

-- 创建建筑物
function HeroBiographyView:createBuildItem1(data)
    
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(cc.p(0.5,0.5))
    -- layout:setContentSize(cc.size(60, 60))
    -- layout:setBackGroundColorOpacity(128)
    -- layout:setBackGroundColorType(1)

    if not data then return layout end

    -- print("====================data.id==",data.index,data.staSc)
    -- 关卡点
    if data.stageModel then
        local buildImg = ccui.ImageView:create()
        buildImg:loadTexture("asset/uiother/intance/" .. data.stageModel .. ".png")   --.. ".png"
        buildImg:setAnchorPoint(cc.p(0.5,0.5))
        layout._buildImg = buildImg
        local scaleNum = tonumber(data.staSc)/buildImg:getContentSize().height
        layout:setContentSize(buildImg:getContentSize().width*scaleNum,buildImg:getContentSize().height*scaleNum)
        buildImg:setPosition(layout:getContentSize().width*0.5, layout:getContentSize().height*0.5)        
        buildImg:setScale(scaleNum)
        layout:addChild(buildImg)

        --关卡名称
        local nameCoord = data.nameCoord
        local subX = 0
        local subY = 0
        if nameCoord then
            subX = nameCoord[1] or 0 
            subY = nameCoord[2] or 0
        end
        local nameImg = ccui.ImageView:create()
        nameImg:loadTexture("globalImageUI11_btnTextBg.png",1)
        nameImg:setAnchorPoint(cc.p(1,0.5))
        nameImg:setOpacity(200)
        nameImg:setPosition(layout:getContentSize().width+subX, subY)
        layout._nameImg = nameImg
        layout:addChild(nameImg,5)  
        local nameTxt = ccui.Text:create()
        nameTxt:setFontName(UIUtils.ttfName)
        nameTxt:setFontSize(18)
        nameTxt:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        nameTxt:setAnchorPoint(cc.p(0.5,0.5))
        nameTxt:setString(lang(data.stageName))        
        
        nameTxt:setPosition(nameImg:getContentSize().width*0.5, nameImg:getContentSize().height*0.5)
        layout._nameTxt = nameTxt
        nameImg:addChild(nameTxt,5)  

        -- 未解锁建筑置灰
        layout:setSaturation(data.isUnlock and 0 or -100)
    else
        -- boss关
        local buildImg1 = ccui.Layout:create()
        layout._isBoss = true
        layout:setContentSize(cc.size(100, 100))
        local relColor = false 
        -- 怪物颜色 1 蓝色 2 红色
        if data.camp == 2 then relColor = true end
        if AnimAp["mcList"][data.bossModel] then 
            buildImg = MovieClipAnim.new(buildImg1, data.bossModel, function (sp)
                local w, h = sp:getSize()
                local scale = sp:getScale()
                local scaleNum = tonumber(data.staSc)*scale/h
                sp:setScale(scaleNum)
                sp:setPosition(layout:getContentSize().width/2, 0)
                sp:changeMotion(2)
                sp:play()

                layout.animSp = sp
            end, relColor)

            if data.flipX == 1 then 
                buildImg1:setFlippedX(true)
                buildImg1:setPositionX(layout:getContentSize().width)
            else
                buildImg1:setFlippedX(false)
            end 
            buildImg1:setContentSize(layout:getContentSize().width,layout:getContentSize().height)
        else
            buildImg = SpriteFrameAnim.new(buildImg1,  data.bossModel, function (sp)
                local w, h = sp:getSize()
                local scale = sp:getScale()
                local scaleNum = tonumber(data.staSc)*scale/h
                -- layout:setContentSize(cc.size(w*scaleNum, h*scaleNum))
                sp:setName("anim_sp")
                sp:setPosition(layout:getContentSize().width/2, 0)
                sp:play()
                layout.animSp = sp
                
                if data.flipX == 1 then 
                    sp:setScaleX(-scaleNum)
                else
                    sp:setScaleX(scaleNum)
                end
            end, relColor)
        end
        layout:addChild(buildImg1)
        local dialog 
        if data.isPassed then
            dialog = tab:BranchDialogue(data.lastWords)
        else
            dialog = tab:BranchDialogue(data.words) 
        end
        layout.talkIndex = 0
        -- if data.isUnlock then
            self:showBossTalk(data,layout,dialog,data.wordsPosi)
        -- end
    end

    -- 路点
    local stageFog = data.stafog
    local imgName = data.isPassed and "heroBio_pointGreen.png" or "heroBio_pointGray.png"
    if stageFog then
        for k,v in pairs(stageFog) do
            local pointImg = ccui.ImageView:create()
            pointImg:setAnchorPoint(cc.p(0.5,0.5))
            layout["_pointImg" .. k] = pointImg
            local posX = v[1]
            local posY = v[2]
            if posX and posY then
                pointImg:loadTexture(imgName,1)   --.. ".png"                
                pointImg:setPosition(posX,posY)        
                self._stagePanel:addChild(pointImg) 
            end
        end
    end

    -- 通关标志
    local passImg = ccui.ImageView:create()
    passImg:loadTexture("heroBio_passImg.png",1)
    passImg:setAnchorPoint(cc.p(0.5,0.5))
    passImg:setPosition(layout:getContentSize().width-10, 10)
    layout._passImg = passImg
    passImg:setVisible(data.isPassed)
    layout:addChild(passImg,5)

    return layout
end

-- 创建建筑物
function HeroBiographyView:createBuildItem2(data)
    
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(cc.p(0.5,0.5))
    layout:setContentSize(cc.size(60, 60))
    -- layout:setBackGroundColorOpacity(128)
    -- layout:setBackGroundColorType(1)

    if not data then return layout end

    -- print("====================data.id==",data.index,data.staSc)
    -- 关卡点(包括宝箱)

    if layout._boxMc then
        layout._boxMc:removeFromParent()
        layout._boxMc = nil
    end

    local buildImg = ccui.ImageView:create()
    buildImg:setAnchorPoint(cc.p(0.5,0.5))
    buildImg:setPosition(30, 30)
    buildImg:loadTexture("heroBio_boxImgOpen.png",1)
    buildImg:setScale(tonumber(data.staSc)/buildImg:getContentSize().height)        
    layout._buildImg = buildImg
    layout:addChild(buildImg)

    -- if data.stageModel then        
        -- buildImg:loadTexture("asset/uiother/intance/" .. data.stageModel .. ".png")   --.. ".png"        
    -- end
    local comImg = data.isBossBox and "heroBio_boxImg_boss.png" or "heroBio_boxImg.png"
    local getImg = data.isBossBox and "heroBio_boxImgOpen_boss.png" or "heroBio_boxImgOpen.png"
    --  local comImg = "heroBio_boxImg.png"
    -- local getImg = "heroBio_boxImgOpen.png"
    local buildGet
    if data.isBossBox then
        -- 可领状态
        buildGet = mcMgr:createViewMC("zhuanjibaoxiang_herozhuanji", true,false,nil,RGBA8888)
        buildGet:setPosition(30,30)
        buildGet:setVisible(false)
        buildGet:setScale(tonumber(data.staSc)/buildImg:getContentSize().height)    
        layout._buildGet = buildGet
        layout:addChild(buildGet)  
    else
        -- 可领状态
        buildGet = mcMgr:createViewMC("zhanyibaoxiang2_baoxiang", true,false,nil,RGBA8888)
        buildGet:setPosition(30,30)
        buildGet:setVisible(false)
        buildGet:setScale(tonumber(data.staSc)/buildImg:getContentSize().height)    
        layout._buildGet = buildGet
        layout:addChild(buildGet)    
    end
    -- -- 已领  data.isPassed
    if data.state == 1 then
        buildImg:loadTexture(getImg,1)   --.. ".png"
    elseif self._bioData[data.index-1] and self._bioData[data.index-1].isPassed then
        buildGet:setVisible(true)
        buildImg:setVisible(false)
    else
        buildImg:loadTexture(comImg,1)
    end
    
    -- 通关标志
    local passImg = ccui.ImageView:create()
    passImg:loadTexture("heroBio_passImg.png",1)
    passImg:setAnchorPoint(cc.p(0.5,0.5))
    passImg:setPosition(50, 10)
    layout._passImg = passImg
    passImg:setVisible(data.isPassed)
    -- layout:addChild(passImg)

    -- layout:setSaturation(data.isUnlock and 0 or -100)
    return layout
end


--boss喊话
function HeroBiographyView:showBossTalk(data, objParent, dialogue, pos)
    if not data or not objParent or not dialogue then return end
    -- print("===================showBossTalk========================")
    objParent.talkIndex = objParent.talkIndex + 1
    if objParent.talkIndex > #dialogue.words then 
        objParent.talkIndex = 1
    end
    local talkContent = dialogue.words[objParent.talkIndex]
    local labTalk = nil 
    local talkBg = nil
    if objParent.talk == nil then 
        talkBg = cc.Sprite:createWithSpriteFrameName("globalImageUI5_sayBg.png")
        talkBg:setPosition(pos[1],pos[2] )
        talkBg:setAnchorPoint(0, 0)
        labTalk = cc.Label:createWithTTF(lang(talkContent), UIUtils.ttfName, 16, cc.size(100, 0))
        labTalk:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        labTalk:setPosition(68, 45)
        labTalk:setAnchorPoint(0.5, 0.5)
        labTalk:setDimensions(100, 0)
        labTalk:setVerticalAlignment(1)
        -- labTalk:setHorizontalAlignment(1)
        labTalk:setName("labTalk")
        talkBg:addChild(labTalk)
        self._stagePanel:addChild(talkBg, 1000)
        objParent.talk = talkBg
    else
        talkBg = objParent.talk
        labTalk = talkBg:getChildByName("labTalk")
    end
    talkBg:stopAllActions()
    talkBg:setVisible(objParent:isVisible())

    labTalk:setString(lang(talkContent))
    labTalk:setScale(0.8)
    if (labTalk:getContentSize().height * labTalk:getScaleX())> (30* labTalk:getScaleX()) then
        labTalk:setScale(0.8)
    else
        labTalk:setScale(1)
    end
    labTalk:setPosition(talkBg:getContentSize().width/2, talkBg:getContentSize().height/2+ 10)
    talkBg:setScale(1)

    if data.flipX == 1 then 
        talkBg:setFlipX(true)
    end
    -- talkBg:setCascadeOpacityEnabled(true, true)
    talkBg:runAction(cc.Sequence:create(
        -- cc.ScaleTo:create(0.15, 1.2), 
        -- cc.ScaleTo:create(0.05, 1),
        cc.DelayTime:create(3), 
        cc.CallFunc:create(function() talkBg:setScale(0) end), 
        cc.DelayTime:create(3),
        cc.CallFunc:create(function() 
            self:showBossTalk(data, objParent, dialogue, pos) 
            end)
        ))
end

function HeroBiographyView:updateBuildItem(idx)
    if not idx then return end
    if not self._bioData or not self._bioData[idx] then return end

    local data = self._bioData[idx]
    local buildItem = self._buildItem[idx]
    local buildItem1 = self._buildItem[idx+2]
    local data1 = self._bioData[idx+2]
    if buildItem1 and data1 and not buildItem1._isBoss then
        buildItem1:setSaturation(data1.isUnlock and 0 or -100)
    end

    -- 通关一关 解锁两关的情况
    local buildItem2 = self._buildItem[idx+4]
    local data2 = self._bioData[idx+4]

    if buildItem2 and data2 and not buildItem2._isBoss then
        buildItem2:setSaturation(data2.isUnlock and 0 or -100)
    end

    if not buildItem then return end 
    --  
    if not buildItem._isBoss then
        buildItem:setSaturation(data.isUnlock and 0 or -100)
    end
    --[[
    -- 更新boss关是否显示对话
    local lastData = self._bioData[#self._bioData - 1]
    local lastBuild = self._buildItem[#self._buildItem - 1]
    if lastData and lastBuild and lastData.lastWords and lastData.isUnlock then
        local dialog
        if lastData.isPassed then
            dialog = tab:BranchDialogue(lastData.lastWords)
        else
            dialog = tab:BranchDialogue(lastData.words) 
        end
        lastBuild.talkIndex = 0
        self:showBossTalk(lastData,lastBuild,dialog,lastData.wordsPosi)
    end
    ]]

end

function HeroBiographyView:updateBoxItem(idx)
    if not idx then return end
    if not self._bioData or not self._bioData[idx] then return end

    local data = self._bioData[idx]
    local buildItem = self._buildItem[idx]
    -- dump(self._buildItem,"13221321",5)
    if not buildItem then 
        return 
    end 
    -- buildItem:setSaturation(data.isUnlock and 0 or -100)
    -- 开启状态下的宝箱
    local comImg = data.isBossBox and "heroBio_boxImg_boss.png" or "heroBio_boxImg.png"
    local getImg = data.isBossBox and "heroBio_boxImgOpen_boss.png" or "heroBio_boxImgOpen.png"
    -- local comImg = "heroBio_boxImg.png"
    -- local getImg = "heroBio_boxImgOpen.png"
    local buildImg = buildItem._buildImg
    local buildGet = buildItem._buildGet
    if tolua.isnull(buildGet) == nil then return end
    buildImg:setVisible(true)
    buildGet:setVisible(false)
    -- 已领
    if data.state == 1 then
        buildImg:loadTexture(getImg,1)   --.. ".png"        
    elseif self._bioData[data.index-1] and self._bioData[data.index-1].isPassed then
        buildGet:setVisible(true)
        buildImg:setVisible(false)
    else        
        buildImg:loadTexture(comImg,1)
    end

    -- 通关标志
    -- local passImg = buildItem._passImg 
    -- if passImg and data.isPassed then
    --     passImg:setVisible(true)
    -- end
    
end

-- 关卡点击事件
function HeroBiographyView:stageBuildClicked(idx)
    local data = self._bioData[idx]
    -- dump(data,"data==>",5)
    if not data then return end

    if not data.isUnlock then
        self._viewMgr:showTip(lang("BIOTIPS_6"))
        return
    end

    if self._stagePanel._currPoint then
        local posX = data.staPlace and data.staPlace[1] or 0
        local posY = data.staPlace and data.staPlace[2] or 0
        local selectCoord = data.selectCoord
        posX = posX + selectCoord[1]
        posY = posY + selectCoord[2]
        local height = 0
        if self._buildItem[data.index] then
            height = self._buildItem[data.index]:getContentSize().height
        end
        height = posY - height * 0.5 + 20
        self._stagePanel._currPoint:setPosition(posX,height)  
    end
    if self._currStageIdx == data.index then return end
    self._currStageIdx = idx    

    -- local isClicked = SystemUtils.loadAccountLocalData("BIOGRAPHY_Anim_" .. self._heroId .. "0" .. idx)
    -- -- 播放关卡解锁动画 state == 1  可挑战
    -- if data.state == 1 and not isClicked then
    --     SystemUtils.saveAccountLocalData("BIOGRAPHY_Anim_" .. self._heroId .. "0" .. idx,true)
    --     -- 播放解锁动画
    --     self:updateButtomPanel(data)
    -- else
    --     self:updateButtomPanel(data)
    -- end

    -- 检查是否需要播放动画
    self:checkStageAnim(data)
      
end

-- 宝箱点击事件
function HeroBiographyView:boxBuildClicked(idx)

    local data = self._bioData[idx]
    if not data then return end

    if not self._bioData[idx-1].isPassed then
        -- self._viewMgr:showTip("宝箱不能领取")
        if self._bioData[idx-1] then
            DialogUtils.showGiftGet( { gifts = self._bioData[idx-1].award, viewType = 2, des = lang("heroBio_1")})
        end
        return 
    end
    if 1 == data.state then
        self._viewMgr:showTip(lang("heroBio_2"))
        return 
    end

    -- if self._currStageIdx == data.index then return end
    -- self._currStageIdx = idx

    -- if true then return end 
    --领取宝箱
    self._serverMgr:sendMsg("HeroBioServer", "getHeroBioBox", {heroId=self._heroId,id=data.id}, true, {}, function(result,succ)
        -- print("===================获取奖励-=============",succ)
        if succ then
            local reward = result.reward
            if reward then
                DialogUtils.showGiftGet({ gifts = reward,callback = function()
                    -- 更新宝箱状态
                    self:updateBioDataAndUI(idx)                   
                                       
                end})
            end
        end          
    end)

end

-- 检查是否需要播放解谜动画
-- 更新关卡显示
function HeroBiographyView:checkStageAnim(biodata)
    local data = biodata
    if not data then
        -- 跳转回来需要更新数据
        self._bioData = self:initBioData()
        data = self._bioData[self._currStageIdx]
    end
    -- dump(biodata,"biodata==>",5)
    -- print("============self._currStageIdx====",self._currStageIdx)
    -- 检查是否需要播放解锁动画
    self:showUnlockTips(self._bioData[self._currStageIdx])

    self._unLockPanel:setVisible(false)
    self._riddlePanel:setVisible(false)
    self._lockPanel:setVisible(false)
    self._goPanel:setVisible(false)
    self._fightBtn:setVisible(false)
    -- print("=============table.nums(sConTb)=====",table.nums(data.conds))

    if data.state and data.state ~= 2 then
        local condTb = data.heroCond or {}
        local sConTb = data.conds or {}
        -- 触发过条件
        local isRiddle = table.nums(sConTb) >= 2  or data.state == 1
        local isClicked = self._riddleAnim[tonumber(data.id)]
        
        -- 解谜模式 & 触发过条件 & 没被点击过
        if data.riddle and isRiddle and not isClicked then
            self._riddlePanel:setVisible(true)
            self._riddlePanel:setOpacity(255)
            self._riddlePanel:setCascadeOpacityEnabled(true)
            self._riddleAnim[tonumber(data.id)] = true
            SystemUtils.saveAccountLocalData("BIOGRAPHY_Anim_" .. data.id,true)
            -- runAction
            -- callfunction  更新显示
            self._fightBtnAmin1:setVisible(data.state and data.state ~= 0)
            self._fightBtnAmin2:setVisible(data.state and data.state ~= 0)
            -- self._fightBtn:setSaturation((data.state and data.state ~= 0) and 0 or -100)
            self:lock(-1)
            self._riddleName:setString(lang(data.stageName))
            self._riddleTxt:setString(lang(data.riddle))
            -- 解谜模式解锁动画
            local spriteImg = self._riddlePanel:getChildByFullName("spriteImg")
            local desPanel = self._riddlePanel:getChildByFullName("desPanel")            
            desPanel:setOpacity(255)
            desPanel:setCascadeOpacityEnabled(true)
            desPanel:setScale(1)
            local action = cc.Sequence:create(cc.DelayTime:create(0.7), 
                cc.Spawn:create(cc.FadeOut:create(0.2),cc.ScaleTo:create(0.2, 0.3)))
            desPanel:runAction(action)

            spriteImg:setPositionX(3)
            spriteImg:setOpacity(255)
            local spAction = cc.Sequence:create(cc.DelayTime:create(0.9), cc.Spawn:create(cc.FadeOut:create(0.2),cc.MoveBy:create(0.2,cc.p(-30,0))), cc.CallFunc:create(function( )
                self:updateButtomPanel(data,true)                
                self:unlock()
            end))
            spriteImg:runAction(spAction)
        else
            self:updateButtomPanel(data)
        end
    else
        self:updateButtomPanel(data)
    end

end

--  跳转回来更新数据及UI显示
function HeroBiographyView:goBackAndUpdate()
    -- 跳转回来需要更新数据
    self._bioData = self:initBioData()
    local data = self._bioData[self._currStageIdx]
    local sConTb = data.conds or {}
    local isRiddle = table.nums(sConTb) >= 2 or data.state == 1
    if data.riddle and not isRiddle then
        -- 没有触发解谜模式
        return
    end

    self._fightBtnAmin1:setVisible(data.state and data.state ~= 0)
    self._fightBtnAmin2:setVisible(data.state and data.state ~= 0)
    -- self._fightBtn:setSaturation((data.state and data.state ~= 0) and 0 or -100)    

    local comStr = self:getStringByNum(data.comNum)
    local sumStr = self:getStringByNum(data.sumNum)
    self._proTxt:setString(comStr .. "/" .. sumStr)

    self._unLockPanel:setVisible(data.state == 2)
    self._riddlePanel:setVisible(false)
    self._lockPanel:setVisible(data.state ~= 2)
    -- 前往
    if data.bioButton then
        self._goPanel:setVisible(data.state == 0) -- 条件未完成 & 可以跳转
    end
    self._fightBtn:setVisible(data.state ~= 0)   
    if data.state ~= 0 then
        self:registerClickEvent(self._fightBtn, function()
            if data.state and data.state == 0 then
                self._viewMgr:showTip(lang("BIOTIPS_5"))
                return
            end
            -- print("============进入布阵==================",data.id)
            local fightData = tab:HeroStage(tonumber(data.stageId))
            self:goToFormation(data.stageId, fightData,true)

        end)
    end
    --更新条件的显示
    if data.state and data.state ~= 2 then        
        local i = 1
        local condTb = data.heroCond or {}
        local sConTb = data.conds or {}
        for k,v in pairs(condTb) do
            if i ~= 1 and self._conPanel["condItem" .. i] then
                -- 关卡点(包括宝箱)
                local pointImg = self._conPanel["condItem" .. i]:getChildByFullName("pointImg")                
                local desTxt = self._conPanel["condItem" .. i]:getChildByFullName("desTxt")
                if data.state == 1 or (sConTb[tostring(i)] and sConTb[tostring(i)].finish and sConTb[tostring(i)].finish == 1) then
                    pointImg:loadTexture("heroBio_conImg2.png" ,1)   --.. ".png"
                    desTxt:setColor(UIUtils.colorTable.ccUIBaseColor2)
                else
                    pointImg:loadTexture("heroBio_conImg1.png" ,1)   --.. ".png"
                    desTxt:setColor(UIUtils.colorTable.ccUIBaseColor1)
                end
            end
            i = i + 1
        end
    end
    
    -- 检查是否需要播放解锁动画
    self:showUnlockTips(data)
    
end
--  isNeedAnim conditionpanel需要播放动画
function HeroBiographyView:updateButtomPanel(param,isNeedAnim)
    if not param then return end 

    local data = param
    -- 如果进界面的时候宝箱未领 处理
    if data.buildType == 2 then
        data = self._bioData[param.index - 1]
    end

    self._fightBtnAmin1:setVisible(data.state and data.state ~= 0)
    self._fightBtnAmin2:setVisible(data.state and data.state ~= 0)
    -- self._fightBtn:setSaturation((data.state and data.state ~= 0) and 0 or -100)    

    local comStr = self:getStringByNum(data.comNum)
    local sumStr = self:getStringByNum(data.sumNum)
    self._proTxt:setString(comStr .. "/" .. sumStr)

    self:registerClickEvent(self._fightBtn, function()
        if data.state and data.state == 0 then
            self._viewMgr:showTip(lang("BIOTIPS_5"))
            return
        end
        -- print("============进入布阵==================",data.id)
        local fightData = tab:HeroStage(tonumber(data.stageId))
        self:goToFormation(data.stageId, fightData,true)

    end)

    if data.bioButton then
        self:registerClickEvent(self._goBtn, function()            
            if self["goView" .. data.bioButton] then
                self["goView" .. data.bioButton](self)
            end
        end)
    end

    self._unLockPanel:setVisible(false)
    self._riddlePanel:setVisible(false)
    self._lockPanel:setVisible(false)
    self._goPanel:setVisible(false)
    self._fightBtn:setVisible(false)
    if data.state and data.state ~= 2 then
        local condTb = data.heroCond or {}
        local sConTb = data.conds or {}
        local isRiddle = table.nums(sConTb) >= 2 or data.state == 1
        -- dump(sConTb,"sConTb",5)
        -- 解谜模式并且没有触发条件
        if data.riddle and not isRiddle then
            self._riddlePanel:setVisible(true)
            local spriteImg = self._riddlePanel:getChildByFullName("spriteImg")
            local desPanel = self._riddlePanel:getChildByFullName("desPanel") 
            desPanel:setOpacity(255)
            desPanel:setScale(1)
            spriteImg:setPositionX(3)
            spriteImg:setOpacity(255)

            self._riddleName:setString(lang(data.stageName))
            self._riddleTxt:setString(lang(data.riddle))            
        else
            self._lockPanel:setVisible(true)  
            -- 前往
            if data.bioButton then
                self._goPanel:setVisible(data.state ~= 1) -- 条件未完成 & 可以跳转
            end
            self._fightBtn:setVisible(data.state == 1)
            -- --[[
            local i = 1            
            self._conPanel:removeAllChildren()
            local posX = 62
            local posY = self._conPanel:getContentSize().height - 15
            local conW = 30
            -- dump(condTb,"condTb",5)
            -- dump(sConTb,"sConTb",5)
            for k,v in pairs(condTb) do
                if i ~= 1 then
                    local layout = ccui.Layout:create()
                    layout:setAnchorPoint(cc.p(0.5,0.5))
                    layout:setContentSize(cc.size(100, 30))
                    -- layout:setBackGroundColorOpacity(128)
                    -- layout:setBackGroundColorType(1)

                    -- 关卡点(包括宝箱)
                    local pointImg = ccui.ImageView:create()           
                    pointImg:setAnchorPoint(cc.p(0.5,0.5))
                    pointImg:setPosition(0, 15)
                    pointImg:setName("pointImg")
                    layout:addChild(pointImg)

                    -- 条件描述
                    local desTxt = ccui.Text:create()
                    desTxt:setFontSize(20)
                    desTxt:setFontName(UIUtils.ttfName)
                    desTxt:setString(lang(v))
                    desTxt:setTextAreaSize(cc.size(590,100))
                    desTxt:setTextHorizontalAlignment(0)
                    desTxt:setTextVerticalAlignment(0)
                    desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                    desTxt:setAnchorPoint(cc.p(0,1))
                    desTxt:setPosition(pointImg:getContentSize().width+15, 26)
                    desTxt:setName("desTxt")
                    layout:addChild(desTxt)

                    if data.state == 1 or (sConTb[tostring(i)] and sConTb[tostring(i)].finish and sConTb[tostring(i)].finish == 1) then
                        pointImg:loadTexture("heroBio_conImg2.png" ,1)   --.. ".png"
                        desTxt:setColor(UIUtils.colorTable.ccUIBaseColor2)
                    else
                        pointImg:loadTexture("heroBio_conImg1.png" ,1)   --.. ".png"
                        desTxt:setColor(UIUtils.colorTable.ccUIBaseColor1)
                    end

                    layout:setPosition(posX, posY)
                    posY = posY - conW
                    self._conPanel["condItem" .. i] = layout
                    self._conPanel:addChild(layout)
                end
                i = i + 1
            end
            -- ]]
        end
        
    else
        self._unLockPanel:setVisible(true)
        self._fightBtn:setVisible(true)
        -- self._unLockDesName:setString("王位之战")--lang(data.stageName))
    end
    -- 关卡描述
    self._stageTxt:setString(lang(data.stageDes))

    if isNeedAnim then
        self._lockPanel:setVisible(true)
        self._lockPanel:setOpacity(0)
        self._lockPanel:setCascadeOpacityEnabled(true,true)
        self._lockPanel:runAction(cc.FadeIn:create(0.1))
    end

end

--前往布阵
function HeroBiographyView:goToFormation(stageId,data,isWin) --
    
    -- dump(data)
    local formationData , enemyFormationData ,extendData,wallData = self:formatFormationData(data)
    extendData.trainigData = data
    extendData.isFirstTrain = data.state == 1
    extendData.hideBullet = true
    
    local formationModel = self._modelMgr:getModel("FormationModel")
    if isWin then
        formationModel:updateFormationDataByType(formationModel.kFormationTypeTraining,formationData)
    end
    self._viewMgr:showView("formation.NewFormationView", {
        formationType = formationModel.kFormationTypeTraining, 

        enemyFormationData = { [formationModel.kFormationTypeTraining] = enemyFormationData },
        extend = extendData,
        wall = wallData,
        
        callback = function(playerInfo, teamCount, filterCount, formationType)
            self._serverMgr:sendMsg("HeroBioServer", "beforeAttkHeroBio", {id = stageId,heroId=self._heroId, serverInfoEx = BattleUtils.getBeforeSIE()}, true, {}, function(result,succ)
                self._viewMgr:popView()
                if not succ then return end
                self._token = result.token
                BattleUtils.enterBattleView_Biography(playerInfo, stageId, 
                    function (info, callback)
                        -- 战斗结束
                        self._currBattleResult = info.win or false
                        self:afterBioBattle(playerInfo, info,callback,stageId,data,fightToken)
                        
                    end,
                    function (info)
                        -- 退出战斗
                        -- print("==========退出战斗=======self._currBattleResult==",self._currBattleResult)
                        if not self._currBattleResult then
                            self:goToFormation(stageId,data,self._currBattleResult)
                        end
                    end,false)
            end)
        end
        
    })

end

-- 格式化传入布阵的参数
function HeroBiographyView:formatFormationData(data)
    if not data then
        return {} ,{} ,{},{}
    end

    local formationData = {} 

    -- 上阵兵团
    local npc1 = data.npc1
    for i=1,8 do
        local npcData = npc1[i]
        if npcData then
            formationData["team" .. i] = tonumber(npcData[1])
            formationData["g" .. i] = tonumber(npcData[2])
        else
            formationData["team" .. i] = 0
            formationData["g" .. i] = 0
        end
    end

    -- 过滤不显示的兵团id
    formationData.filter = {}

    --上阵英雄
    local hero1 = data.hero1
    formationData.heroId = tonumber(hero1)


    -- 敌方上阵兵团
    local enemyFormationData = {}
    local enemynpc = data.enemynpc or {}
    local fightScore = 0

    for i=1,8 do
        local npcData = enemynpc[i]
        if npcData then
            enemyFormationData["team" .. i] = tonumber(npcData[1])
            enemyFormationData["g" .. i] = tonumber(npcData[2])
            local enemyData = tab:Npc(tonumber(npcData[1]))
            if enemyData.score then
                fightScore = fightScore + tonumber(enemyData.score) 
            end
        else
            enemyFormationData["team" .. i] = 0
            enemyFormationData["g" .. i] = 0
        end
    end

    -- 过滤不显示的兵团id
    enemyFormationData.filter = ""    

    --上阵英雄
    enemyFormationData.heroId = tonumber(data.enemyhero)
    local heroData = tab:NpcHero(tonumber(data.enemyhero))
    if heroData and heroData.score then
        fightScore = fightScore + tonumber(heroData.score) 
    end

    -- 战斗力
    enemyFormationData.score = fightScore

    -- 可以上场的兵团和英雄 包括已经上阵的
    local extend = {}
    extend.teams = data.npc2 or {}
    extend.heroes = data.hero2 or {}
    extend.count = {[self._modelMgr:getModel("FormationModel").kFormationTypeTraining] = data.limitNum}

    local formationModel = self._modelMgr:getModel("FormationModel")
    local wallData = {}
    if data.posi then
        wallData[formationModel.kFormationTypeTraining] = data.posi
    end
    return formationData ,enemyFormationData ,extend,wallData
end

--战后数据处理
function HeroBiographyView:afterBioBattle(playerInfo, info,callback,stageId,data,fightToken)
 
    local currToken = fightToken and fightToken or self._token
    -- print("========================currToken===",currToken)
    local win = info.win or 0
    local hp = info.hp or {} 
    local time = info.time or 0

    --上阵英雄id
    -- local formationHeroID
    -- if playerInfo and playerInfo.hero then
    --     formationHeroID = playerInfo.hero.id
    -- end

    local param = {id = stageId,heroId = self._heroId,token = currToken,
    args = json.encode({win = win,time = time})}  --,skillList = info.skillList,serverInfoEx = info.serverInfoEx,playerInfo=json.encode(playerInfo)
    info.bioData = self._bioData[self._currStageIdx]
    self._serverMgr:sendMsg("HeroBioServer", "afterAttkHeroBio", param, true, {}, function(result,succ) 
        -- if result["extract"] then
        --     dump(result["extract"]["hp"], "a", 10)
        -- end
        self._isAfterBattle = win        
        --结算
        callback(info)
        --更新当前关卡的数据
        self:updateBioDataAndUI(nil,win)
    end)
    
end

-- 战后 领取宝箱之后更新数据和UI
function HeroBiographyView:updateBioDataAndUI(idx,stageWin)
    if not self._bioData then return end
    if not idx then return end 
    local data = self._bioData[idx] 
    if not data then return end 
    -- print("=========self._currStageIdx,",self._currStageIdx)
    if 1 ~= data.buildType then                
        data.state = 1
        data.isPassed = true
        self:updateBoxItem(idx)
    end

end

-- 跳转
-- 1 副本
function HeroBiographyView:goView1() 
    self._viewMgr:showView("intance.IntanceView", {superiorType = 2}) 
end
-- 2 船坞
function HeroBiographyView:goView2()
    if not SystemUtils:enableMF() then
        self._viewMgr:showTip(lang("TIP_MF"))
        return 
    end

    self._viewMgr:showView("MF.MFView")
end
-- 3 英雄
function HeroBiographyView:goView3()
    self:close(true)
end

-- 4 战役
function HeroBiographyView:goView4() 
    if not SystemUtils:enableCrusade() then
        self._viewMgr:showTip(lang("TIP_Crusade"))
        return 
    end
    self._viewMgr:showView("crusade.CrusadeView") 
end

-- 5 云中城
function HeroBiographyView:goView5()
    if not SystemUtils:enableCloudCity() then
        self._viewMgr:showTip(lang("TIP_TOWER"))
        return 
    end

    self._viewMgr:showView("cloudcity.CloudCityView")
end

-- 6 战神像
function HeroBiographyView:goView6() 
    if not SystemUtils:enablePvp() then
        self._viewMgr:showTip(lang("TIP_Pvp"))
        return 
    end
    self._viewMgr:showView("pvp.PvpInView")
end

-- 7  地下城
function HeroBiographyView:goView7() 

    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    self._viewMgr:showView("intance.IntanceEliteView", {superiorType = 2}) 
end

-- 8 训练场
function HeroBiographyView:goView8() 
    if not SystemUtils:enableTraining() then
        self._viewMgr:showTip(lang("TIP_Training"))
        return 
    end

    self._viewMgr:showView("training.TrainingView")
end

-- 9 联盟探索
function HeroBiographyView:goView9() 
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    if guildId == nil or guildId == 0 then 
        local param = {indexId = 9}
        self._viewMgr:showDialog("global.GlobalPromptDialog", param)
        return
    end
    self._viewMgr:showView("guild.map.GuildMapView")
end

-- 10  地下城第七章
function HeroBiographyView:goView10() 

    if not SystemUtils:enableElite() then
        self._viewMgr:showTip(lang("TIP_JINGYING_1"))
        return 
    end
    -- 7200701
    local stageInfo = self._modelMgr:getModel("IntanceEliteModel"):getStageInfo(7200701)
    if not stageInfo.isOpen then 
        self._viewMgr:showTip("地下城章节未开启")
        return
    end

    self._viewMgr:showView("intance.IntanceEliteView", {sectionId = 72007}) --,quickStageId = 7200701
end

-- 初始化传记数据
function HeroBiographyView:initBioData()
    -- 根据英雄ID获取传记数据
    local serverData = self._heroModel:getBiographyDataByHeroId(self._heroId) or {}

    local bioTableData = {}
    -- dump(serverData,"serverData==>",4)
    local index = 1
    for i=1,5 do
        local bioId = tonumber(self._heroId .. "0" .. i)
        --表数据
        local tableData = clone(tab:HeroBio(bioId))
        tableData.buildType = 1     --关卡
        tableData.index = index
        self._bioIndexData[bioId] = index
        tableData.isClearMist = false
        index = index + 1
        local sData = serverData[tostring(bioId)]
        if sData then
            for k,v in pairs(sData) do
                tableData[k] = v 
            end
        end
        tableData.isUnlock = false
        if sData and sData.conds and sData.conds["1"] 
            and sData.conds["1"].finish and sData.conds["1"].finish == 1 then
            tableData.isUnlock = true
            tableData.isClearMist = true
        end
        local condition = 0
        local tCount = tableData.bioCount or {}        
        tableData.comNum = 0                -- 完成条件数 
        tableData.sumNum = tCount[2] or 0   -- 完成总数
        
        -- 0 条件未达到 1 条件达到可以挑战关卡 2 通关
        tableData.state = 0
        if sData and sData.pTime then
            tableData.isUnlock = true
            tableData.isClearMist = true
            if sData.pTime > 1 then
                tableData.state = 2
                self._passBioData[bioId] = 1
            else
                tableData.state = sData.pTime
                local isClicked = SystemUtils.loadAccountLocalData("BIOGRAPHY_RED_" .. self._heroId .. "0" .. i)
                -- 可以挑战 & 第一次达到可挑战条件
                if sData.pTime == 1 and not isClicked then
                    SystemUtils.saveAccountLocalData("BIOGRAPHY_RED_" .. self._heroId .. "0" .. i,true)
                end
            end
            tableData.comNum = tableData.sumNum 
        else
            -- 未完成条件
            if tableData and tableData.cType then
                local cond = tableData.cType[1]
                condition = "1"
                if tonumber(cond) == 100 then
                    condition = "2"
                end
                if sData and sData.conds and sData.conds[condition] then
                    if sData.conds[condition].finish and sData.conds[condition].finish == 1 then
                        tableData.comNum = tableData.sumNum
                    else
                        local valueStr = sData.conds[condition].value or ""
                        if tCount[1] == 1 then
                            tableData.comNum = tonumber(valueStr) or 0
                        else
                            local numArr = string.split(valueStr, ",")
                            tableData.comNum = table.nums(numArr)
                        end
                    end
                end
            end
        end
        -- tableData.isClearMist = true -- test
        -- tableData.state = 2  -- test
        tableData.isPassed = false 
        if 2 == tableData.state then
            tableData.isPassed = true
        end

        if i == 5 and tableData.isUnlock then
            self._isAllMistClear = true
        end
        table.insert(bioTableData,tableData)
        table.insert(self._memoirsData,tableData)

        --宝箱数据
        local boxData = {}
        boxData.id = bioId
        boxData.buildType = 2       --宝箱
        -- boxData.stageModel = tableData.treasure
        boxData.staSc = tableData.treSc
        boxData.staPlace = tableData.trePlace or {0,0}
        boxData.isPassed = false
        boxData.state = 0
        boxData.isClearMist = true
        boxData.index = index
        index = index + 1
        boxData.isUnlock = false
        boxData.isBossBox = (i == 5) and true or false
        if tableData.state == 2 then
            boxData.isUnlock = true
        end
        if sData and sData.box then
            boxData.state = sData.box or 0
        end
        if boxData.state == 1 then
            boxData.isPassed = true
            boxData.isUnlock = true
        end
        table.insert(bioTableData,boxData)
    end

    -- dump(bioTableData,"bioTableData==>")
    return bioTableData--,memoirsData
end

function HeroBiographyView:searchCurrSatge()

    local currStageIdx 
    local tempIdx
    for i=1,5 do
        local bioId = tonumber(self._heroId .. "0" .. i)
        local stageIdx = self._bioIndexData[bioId]
        local bioData = self._bioData[stageIdx]
        if not self._passBioData[bioId] then
            -- 找到第一个没通关的关卡
            if not tempIdx then
                tempIdx = stageIdx
            end
        end
        -- 第一个可以通关的关卡
        if bioData.state == 1 and bioData.buildType == 1 then
            currStageIdx = stageIdx
            break
        end
    end
    -- 1.已解锁未通关  可战斗
    -- 2.未解锁        不可战斗
    -- 3.已解锁已通关  通关
    if not currStageIdx then
        currStageIdx = tempIdx
    end
    if not currStageIdx then
        currStageIdx = self._bioIndexData[tonumber(self._heroId .. "05")]
    end

    return currStageIdx
end

function HeroBiographyView:isMemoirsRed()
    local isRed = false 
    for i=2,5 do
        local data = self._memoirsData[i] or {}
        if isRed then break end
        if data and data.state == 2 then
            isRed = not SystemUtils.loadAccountLocalData("HEROMEMOIR_RED_" .. data.id)
        end
    end
    return isRed
end

-- 过万显示
function HeroBiographyView:getStringByNum( num)
    if not num then return "" end
    local numStr = ""
    if num > 9999 then
        local num1 = math.floor(num/1000)
        numStr = num1/10 .. "万"        
    else
        numStr = num
    end
    return numStr
end

-- 传记解锁提示
function HeroBiographyView:showUnlockTips(data)

    -- print("==================showUnlockTips==================",data.id,data.state)
    if not data then return end
    if data.state ~= 1 then return end
    if self._unlockAnim[tonumber(data.id)] then return end
    -- print("==================self._unlockAnim[tonumber(data.id)]===",data.id,self._unlockAnim[tonumber(data.id)])
    self._tipsPanel:setVisible(true)
    self._tipsBg:setOpacity(0)
    self._tipsBg:setScale(0)
    self._unlockAnim[tonumber(data.id)] = true
    SystemUtils.saveAccountLocalData("BIOGRAPHY_UnlockAnim_" .. data.id,true)
    
    local title = self._tipsBg:getChildByFullName("title")
    local stageName = self._tipsBg:getChildByFullName("stageName")
    local titleStr = lang(data.heroDes)
    -- 截取字符串
    titleStr = "解锁" .. string.sub(titleStr,1,9)
    title:setString(titleStr)

    stageName:setString(lang(data.stageName))
    self._tipsBg:stopAllActions()
    self._tipsBg:runAction(
        cc.Sequence:create(cc.DelayTime:create(0.3),cc.Spawn:create(
            cc.FadeIn:create(0.1),
            cc.Sequence:create(
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.2), 3), 
                cc.ScaleTo:create(0.1, 1.0),
                cc.DelayTime:create(0.8),
                cc.Spawn:create(cc.FadeOut:create(0.1),cc.ScaleTo:create(0.1,0)),
                cc.CallFunc:create(function ()
                    self._tipsPanel:setVisible(false)
                end))))
    )
end

--[[
--! @function initStageFog
--! @desc 初始化关卡迷雾
--! @param inStageId 关卡id
--! @return 
--]]
--[[
function HeroBiographyView:initStageFog()
    -- if self._testOpacity == 255 then return end
  
    -- if true then return end
    if self._fogMask then
        self._fogMask:removeFromParent()
        self._fogMask = nil
    end
    -- 如果迷雾全开，不再绘制
    if self._isAllMistClear then return end

    local maskW = self._stagePanel:getContentSize().width
    local maskH = self._stagePanel:getContentSize().height

    self._fogMask = cc.RenderTexture:create(maskW, maskH, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    self._fogMask:getSprite():getTexture():setAntiAliasTexParameters()
    self._stagePanel:addChild(self._fogMask, 105)
    self._fogMask:beginWithClear(0, 0, 0, 0)

    -- 地图
    local fogLayer = cc.Sprite:create("asset/bg/" .. "heroBio_bg_" .. self._heroId .. ".jpg")
    fogLayer:setPosition(maskW*0.5,maskH*0.5)
    fogLayer:setAnchorPoint(0.5, 0.5)
    fogLayer:setCMex(0.44, 0.52, 0.04, 0.08, 
                     0.4, 0.6, -0.04,  0.04, 
                     0.32, 0.36, 0.08, -0.04, 
                     -0.2, 0, 0.24, 1, 
                     -5.1, -10.2, 0, 255)
    -- fogLayer:setSaturation(-80)
    -- fogLayer:setBrightness(-30.6)
    -- fogLayer:setContrast(-52)
    fogLayer:setColor(cc.c3b(209,188,175))
    fogLayer:setOpacity(255)

    fogLayer:visit()


    -- 边界遮罩
    local fogIcon = cc.Sprite:create("asset/bg/heroBio_bg_zhezao.png")
    fogIcon:setAnchorPoint(0.5,0)
    fogIcon:setPosition(maskW*0.5, 0)
    fogIcon:setBlendFunc({src = gl.ZERO, dst = gl.ONE_MINUS_SRC_ALPHA})
    fogIcon:visit()
    
    for key,value in pairs(self._bioData) do
        local buildItem = self._buildItem[tonumber(key)]
        -- 迷雾
        local mapMist = value.mapMist
        if mapMist and value.isClearMist then
            buildItem._mapMist = {}
            for k,v in pairs(mapMist) do
                local mapMist = cc.Sprite:create("asset/uiother/intance/intanceImageUI4_fog.png")     
                mapMist:setAnchorPoint(cc.p(0.5,0.5)) 
                local posX = v[1]
                local posY = v[2]
                if posX and posY then
                    mapMist:setPosition( posX,posY)   
                    mapMist:setBlendFunc({src = gl.ZERO, dst = gl.ONE_MINUS_SRC_ALPHA})        
                    mapMist:visit()
                    -- mapMist:setOpacity(self._testOpacity)
                    -- self._testOpacity = self._testOpacity + 1
                end
            end
        end
    end    

    self._fogMask:endToLua()
    self._fogMask:setPosition(maskW*0.5, maskH*0.5)
end
]]

return HeroBiographyView