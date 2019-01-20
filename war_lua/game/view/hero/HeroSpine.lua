--[[
    Filename:    HeroSpine.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-12-30 18:04:17
    Description: File description
--]]

local spineMgr = spineMgr
local mcMgr = mcMgr
local ALR = pc.PCAsyncLoadRes:getInstance()

local HeroSpine = class("HeroSpine", function()
    return cc.Node:create()
end)

HeroSpine.kShowWithAction = true

function HeroSpine:ctor(container, deep, heroId, invisible, onLeftButtonClicked, onRightButtonClicked, extendFunction, specifyHeroData)
    self._container = container
    self._deep = deep and deep or 5
    self._heroData = tab:Hero(heroId)
    self._isInvisible = invisible
    self._onLeftButtonClicked = onLeftButtonClicked
    self._onRightButtonClicked = onRightButtonClicked
    self._extendFunction = extendFunction
    self._specifyHeroData = specifyHeroData
    self:create()
end

function HeroSpine:create()
    --[[
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/hero.plist", "asset/ui/hero.png")
    self:registerScriptHandler(function (state)
        if state == "exit" then
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("asset/ui/hero.plist")
            mcMgr:clear()
        end
    end)
    ]]
    self._size = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
    if ADOPT_IPHONEX then
        self._size = {width = 1136, height = MAX_SCREEN_HEIGHT}
    end

    self._markClear = false
    self._taskReferenceCount = 0
    self._isPad = (self._size.width / self._size.height) <= (3.0 / 2.0)

    self._layer = cc.Layer:create()
    self._layer:setPosition(cc.p(0, 0))
    self._layer:setContentSize(self._size)
    self:addChild(self._layer)

    local picName = self._heroData.heroport

    if self._specifyHeroData and self._specifyHeroData.skin then
        local skinTableData = tab:HeroSkin(tonumber(self._specifyHeroData.skin))
        picName = skinTableData and skinTableData.heroport or picName
    end

    if picName then
        local task = pc.LoadResTask:createImageTask("asset/uiother/hero/" .. picName .. ".jpg", RGBAUTO)
        task:setLuaCallBack(function ()
            ScheduleMgr:delayCall(0, self, function()
                if not self._releaseTaskReferenceCount then return end
                self:_releaseTaskReferenceCount()
                if self._markClear then return self:_tryClear() end
                self._imageBg = cc.Sprite:create("asset/uiother/hero/" .. picName .. ".jpg")
                self._imageBg:setScale(1.11)
                self._imageBg:setPosition(cc.p(self._layer:getContentSize().width / 2, self._layer:getContentSize().height / 2))
                if HeroSpine.kShowWithAction then 
                    self._imageBg:setOpacity(100)
                    self._imageBg:runAction(cc.FadeIn:create(0.5))
                end
                self._layer:addChild(self._imageBg, 0)
            end)
        end)
        ALR:addTask(task) 
        self:_retainTaskReferenceCount()
    end

    if self._heroData.heromp then
        self._imageName = cc.Sprite:createWithSpriteFrameName(self._heroData.heromp .. ".png")
        self._imageName:setAnchorPoint(cc.p(1, 0.5))
        local heroCamp = ccui.Text:create()
        heroCamp:setFontSize(20)
        heroCamp:setFontName(UIUtils.ttfName)
        heroCamp:setColor(cc.c3b(250,255,255))
        -- heroCamp:enable2Color(1, cc.c3b(255, 195, 17))
        heroCamp:setString(lang("masterytype_region" .. (self._heroData.masterytype or 0)))
        heroCamp:enableOutline(cc.c3b(0,0,0),1)
        local heroCampW = heroCamp:getContentSize().width+10
        self._heroCampW = heroCampW
        heroCamp:setPosition(self._imageName:getContentSize().width+heroCampW,0)
        heroCamp:setAnchorPoint(1,0)
        self._heroCamp = heroCamp
        self._imageName:addChild(heroCamp)
        --self._imageName:setPosition(self._layer:getContentSize().width / 2 + self._heroData.mppos[1], self._layer:getContentSize().height / 2 + self._heroData.mppos[2])
        -- if self._isPad then
        --     self._imageName:setPosition(self._layer:getContentSize().width / 2 + self._heroData.ipadmppos[1]-heroCampW, self._heroData.ipadmppos[2])
        -- else
        --     self._imageName:setPosition(self._layer:getContentSize().width / 2 + self._heroData.mppos[1]-heroCampW, self._heroData.mppos[2])
        -- end
        local screen_x_offset = (MAX_SCREEN_REAL_WIDTH - 1136) * 0.5 > 0 and (MAX_SCREEN_REAL_WIDTH - 1136) * 0.5 or 0
        self._imageName:setPosition(MAX_SCREEN_REAL_WIDTH - heroCampW - screen_x_offset*2 - 30, self._heroData.mppos[2])

        self._layer:addChild(self._imageName, 20)

        self._nameBg = ccui.ImageView:create("name_bg_hero.png", 1)
        self._nameBg:setScale9Enabled(true)
        self._nameBg:setCapInsets(cc.rect(120, 62, 1, 1))
        self._nameBg:setContentSize(cc.size(293+heroCampW, 124))
        self._nameBg:setPosition(self._imageName:getPositionX() - 146+heroCampW, self._imageName:getPositionY() - 27)
        self:addChild(self._nameBg, 20)
    end

    if self._heroData.heroanim then
        mcMgr:loadRes(self._heroData.heroanim, function()
            if not self._releaseTaskReferenceCount then return end
            self:_releaseTaskReferenceCount()
            if self._markClear then return self:_tryClear() end
            self._backgroundMC = mcMgr:createViewMC("background_" .. self._heroData.heroanim, true)
            self._backgroundMC:setPlaySpeed(1, true)
            --self._backgroundMC:setPosition(cc.p(self._layer:getContentSize().width / 2, 640))
            self._backgroundMC:setPosition(cc.p(self._layer:getContentSize().width / 2 + self._heroData.bjpos[1], self._heroData.bjpos[2]))
            self._layer:addChild(self._backgroundMC, 0)

            self._foregroundMC = mcMgr:createViewMC("foreground_" .. self._heroData.heroanim, true)
            self._foregroundMC:setPlaySpeed(1, true)
            --self._foregroundMC:setPosition(cc.p(self._layer:getContentSize().width / 2, 320))
            self._foregroundMC:setPosition(cc.p(self._layer:getContentSize().width / 2 + self._heroData.qjpos[1], self._heroData.qjpos[2]))
            self._layer:addChild(self._foregroundMC, 15)
        end)
        self:_retainTaskReferenceCount()
    end

    if self._heroData.herospine then
        spineMgr:createSpine(self._heroData.herospine, function (spine)
            if not self._releaseTaskReferenceCount then return end
            self:_releaseTaskReferenceCount()
            if self._markClear then return self:_tryClear() end
            self._spine = spine
            --spine:setPosition(self._layer:getContentSize().width / 2 + 120, self._layer:getContentSize().height / 2 - 320)
            spine:setPosition(self._layer:getContentSize().width / 2 + self._heroData.mxpos[1], self._heroData.mxpos[2])
            spine:setAnimation(0, "animation", true)
            self._layer:addChild(spine, 10)
        end)
        self:_retainTaskReferenceCount()
    end

    if self._specifyHeroData then
        local posX, posY = self._imageName:getPositionX() - 3, self._imageName:getPositionY() - self._imageName:getContentSize().height / 1.3 - 12
        local star = 0
        if self._specifyHeroData.unlock then
            star = self._specifyHeroData.star
        end
        for i=1, 4 do
            if i <= star then
                local starLight = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star5.png")
                starLight:setAnchorPoint(cc.p(1, 0.5))
                --starLight:setPosition(posX - (4 - i) * (starLight:getContentSize().width + 8), posY)
                starLight:setPosition(posX - (4 - i) * (starLight:getContentSize().width + 3)+(self._heroCampW or 0), posY)
                self._layer:addChild(starLight, 20 - i)
            end
            local starGray = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star6.png")
            starGray:setAnchorPoint(cc.p(1, 0.5))
            --starGray:setPosition(posX - (4 - i) * (starGray:getContentSize().width + 8), posY)
            starGray:setPosition(posX - (4 - i) * (starGray:getContentSize().width + 3)+(self._heroCampW or 0), posY)
            self._layer:addChild(starGray, 15 - i)
        end
    end
    if self._specifyHeroData and self._specifyHeroData.score then
        if self._zhandouliLabel then 
            self._zhandouliLabel:removeFromParent()
        end
        local posX, posY = self._imageName:getPositionX()+(self._heroCampW or 0), self._imageName:getPositionY() - 100

        --[[
        self._zhandouliLabel1 = ccui.Text:create()
        self._zhandouliLabel1:setAnchorPoint(cc.p(1, 0.5))
        self._zhandouliLabel1:setColor(cc.c3b(255, 238, 160))
        self._zhandouliLabel1:setPosition(cc.p(posX,posY))
        self._zhandouliLabel1:setString("战斗力")
        self._zhandouliLabel1:setFontSize(18)
        self._layer:addChild(self._zhandouliLabel1, 20)
        ]]

        self._zhandouliLabel = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
        self._zhandouliLabel:setAnchorPoint(cc.p(1,0.5))
        self._zhandouliLabel:setPosition(cc.p(posX + 5, posY - 15))
        self._zhandouliLabel:setString("a")
        self._zhandouliLabel:setScale(0.5)
        self._layer:addChild(self._zhandouliLabel, 20)

        self._zhandouliLabel = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
        self._zhandouliLabel:setName("zhandouliBmp")
        self._zhandouliLabel:setAnchorPoint(cc.p(1,0.5))
        self._zhandouliLabel:setPosition(cc.p(posX, posY - 48))
        self._zhandouliLabel:setString((self._specifyHeroData.score or 0))
        self._zhandouliLabel:setScale(0.9)
        self._layer:addChild(self._zhandouliLabel, 20)
        --[[
        local zhandouliImg = cc.Sprite:createWithSpriteFrameName("zhandouli_mainView.png")
        zhandouliImg:setAnchorPoint(cc.p(1, 0.5))
        zhandouliImg:setPosition(cc.p(4,self._zhandouliLabel:getContentSize().height/2+5))
        self._zhandouliLabel:addChild(zhandouliImg)
        ]]
        --[[
        local zhandouliBg = cc.Sprite:createWithSpriteFrameName("upgrade_material_bg_hero.png")
        zhandouliBg:setAnchorPoint(cc.p(0, 0.5))
        zhandouliBg:setPosition(cc.p(-10,self._zhandouliLabel:getContentSize().height/2+5))
        zhandouliBg:setScale(self._zhandouliLabel:getContentSize().width/102,self._zhandouliLabel:getContentSize().height/23)
        self._zhandouliLabel:addChild(zhandouliBg,-1)
        ]]
    end

    if self._isInvisible then
        self._layer:setVisible(false)
    end

    if self._extendFunction and type(self._extendFunction) == "function" then
        self._extendFunction(self._layer)
    end

    self._container:addChild(self, self._deep)
end

function HeroSpine:runHeroUnlockAction()
    audioMgr:playSound("NewHero")
    self._layer:setVisible(true)
    local blackLayer1HeightRate = 0.17
    local blackLayer2HeightRate = 0.22
    local blackLayer1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), self._size.width, self._size.height * blackLayer1HeightRate)
    blackLayer1:setVisible(false)
    blackLayer1:setPosition(cc.p(0, self._size.height * (1 - blackLayer1HeightRate)))
    self._layer:addChild(blackLayer1, 1)
    local whiteLayer1 = cc.LayerColor:create(cc.c4b(255, 255, 255, 188), self._size.width, self._size.height * blackLayer1HeightRate)
    whiteLayer1:setPosition(cc.p(0, self._size.height))
    self._layer:addChild(whiteLayer1, 2)
    whiteLayer1:runAction(cc.Sequence:create({
            cc.EaseIn:create(cc.MoveTo:create(0.1, cc.p(0, self._size.height * (1 - blackLayer1HeightRate))), 2),
            cc.CallFunc:create(function()
                    blackLayer1:setVisible(true)
                    whiteLayer1:runAction(cc.Sequence:create({
                        cc.FadeOut:create(0.2),
                        cc.CallFunc:create(function()
                            whiteLayer1:setVisible(false)
                            whiteLayer1:removeFromParentAndCleanup()
                        end)}))
            end)}))
    local blackLayer2 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), self._size.width, self._size.height * blackLayer2HeightRate)
    blackLayer2:setVisible(false)
    blackLayer2:setPosition(cc.p(0, 0))
    self._layer:addChild(blackLayer2, 11)
    local whiteLayer2 = cc.LayerColor:create(cc.c4b(255, 255, 255, 188), self._size.width, self._size.height * blackLayer2HeightRate)
    whiteLayer2:setPosition(cc.p(0, -self._size.height * blackLayer2HeightRate))
    self._layer:addChild(whiteLayer2, 12)
    whiteLayer2:runAction(cc.Sequence:create({
            cc.EaseIn:create(cc.MoveTo:create(0.1, cc.p(0, 0)), 2),
            cc.CallFunc:create(function()
                    blackLayer2:setVisible(true)
                    whiteLayer2:runAction(cc.Sequence:create({
                        cc.FadeOut:create(0.2),
                        cc.CallFunc:create(function()
                            whiteLayer2:setVisible(false)
                            whiteLayer2:removeFromParentAndCleanup()
                        end)}))
            end)}))

    local imageBg = self:getImageBg()
    if imageBg then
        imageBg:setOpacity(0)
        imageBg:runAction(cc.FadeIn:create(0.2))
    end

    local whiteLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), self._size.width, self._size.height * (1 - blackLayer1HeightRate - blackLayer2HeightRate))
    whiteLayer:setPosition(cc.p(0, self._size.height * blackLayer2HeightRate))
    whiteLayer:setVisible(false)
    self._layer:addChild(whiteLayer, 1)
    local backgroundMC = self:getBackGroundMC()
    if backgroundMC then
        backgroundMC:setVisible(false)
        backgroundMC:runAction(cc.Sequence:create({
            cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                whiteLayer:setVisible(true)
                whiteLayer:runAction(cc.Sequence:create({
                    cc.FadeOut:create(0.25),
                    cc.CallFunc:create(function()
                        whiteLayer:setVisible(false)
                        whiteLayer:removeFromParentAndCleanup()
                    end)}))
            end),
            cc.CallFunc:create(function()
                backgroundMC:setVisible(true)
        end)}))
    end

    local foregroundMC = self:getForeGroundMC()
    if foregroundMC then
        foregroundMC:setVisible(false)
    end

    local imageName = self:getImageName()
    imageName:setVisible(true)
    imageName:setScale(2)
    imageName:setOpacity(0)
    imageName:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.Spawn:create({cc.FadeIn:create(0.1), cc.EaseIn:create(cc.ScaleTo:create(0.08, 0.8), 2)}), cc.EaseOut:create(cc.ScaleTo:create(0.1, 1), 2)}))

    local heroSpine = self:getSpine()
    if heroSpine then
        heroSpine:setPosition(0, 0)
        heroSpine:setOpacity(0)
        heroSpine:setColor(cc.c3b(255, 255, 255))
        heroSpine:runAction(cc.Spawn:create({
            cc.CallFunc:create(function()
                local line1 = mcMgr:createViewMC("gain_intancenopen", false, true)
                line1:setPlaySpeed(1, true)
                line1:setPosition(cc.p(0, self._size.height * (1 - blackLayer1HeightRate - 0.01)))
                self._layer:addChild(line1, 3)

                local line2 = mcMgr:createViewMC("gain_intancenopen", false, true)
                line2:setPlaySpeed(1, true)
                line2:setPosition(cc.p(0, self._size.height * (blackLayer2HeightRate + 0.01)))
                self._layer:addChild(line2, 13)
            end),
            cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(self._layer:getContentSize().width / 1.3, 0)), 2), 
            cc.FadeIn:create(0.2)
        }))
    end

    local level = nil

    local btn1Bg = ccui.Button:create("globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", 1)
    btn1Bg:setPosition(cc.p(self._size.width / 3, 100))
    btn1Bg:setScaleX(0.45)
    btn1Bg:setScaleY(1.1)
    btn1Bg:addClickEventListener(function()
        level(function()
            if self._onLeftButtonClicked and type(self._onLeftButtonClicked) == "function" then
                self._onLeftButtonClicked()
            end
        end)
    end)
    self._layer:addChild(btn1Bg, 15)
    btn1Bg:setOpacity(0)
    btn1Bg:runAction(cc.Sequence:create({cc.DelayTime:create(0.5), cc.FadeIn:create(0.2)}))
    local btn1Label = cc.Label:createWithTTF("查看", UIUtils.ttfName, 22)
    btn1Label:setColor(cc.c3b(255, 235, 191))
    btn1Label:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn1Label:setPosition(btn1Bg:getPosition())
    self._layer:addChild(btn1Label, 20)
    btn1Label:setOpacity(0)
    local btn1Label2 = cc.Label:createWithTTF("查看", UIUtils.ttfName, 22)
    btn1Label2:setVisible(false)
    btn1Label2:setColor(cc.c3b(255, 235, 191))
    btn1Label2:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn1Label2:setPosition(btn1Bg:getPosition())
    self._layer:addChild(btn1Label2, 25)
    btn1Label:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeIn:create(0.2), cc.DelayTime:create(0.2), cc.CallFunc:create(function()
        btn1Label2:setVisible(true)
    end)}))
    btn1Label2:runAction(cc.RepeatForever:create(cc.Sequence:create({
        cc.Spawn:create({
            cc.ScaleTo:create(0.5, 1.15),
            cc.FadeOut:create(0.5)
        }),
        cc.CallFunc:create(function()
            btn1Label2:setScale(1)
            btn1Label2:setOpacity(255)
        end),
        cc.DelayTime:create(0.2)
    })))
    local btn2Bg = ccui.Button:create("globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", 1)
    btn2Bg:setPosition(cc.p(self._size.width * 2 / 3, 100))
    btn2Bg:setScaleX(0.45)
    btn2Bg:setScaleY(1.1)
    btn2Bg:addClickEventListener(function()
        level(function()
            if self._onRightButtonClicked and type(self._onRightButtonClicked) == "function" then
                self._onRightButtonClicked()
            end
        end)
    end)
    self._layer:addChild(btn2Bg, 15)
    btn2Bg:setOpacity(0)
    btn2Bg:runAction(cc.Sequence:create({cc.DelayTime:create(0.5), cc.FadeIn:create(0.2)}))
    local btn2Label = cc.Label:createWithTTF("继续", UIUtils.ttfName, 22)
    btn2Label:setColor(cc.c3b(255, 235, 191))
    btn2Label:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn2Label:setPosition(btn2Bg:getPosition())
    self._layer:addChild(btn2Label, 20)
    btn2Label:setOpacity(0)
    local btn2Label2 = cc.Label:createWithTTF("继续", UIUtils.ttfName, 22)
    btn2Label2:setVisible(false)
    btn2Label2:setColor(cc.c3b(255, 235, 191))
    btn2Label2:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn2Label2:setPosition(btn2Bg:getPosition())
    self._layer:addChild(btn2Label2, 25)
    btn2Label:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeIn:create(0.2), cc.DelayTime:create(0.2), cc.CallFunc:create(function()
        btn2Label2:setVisible(true)
    end)}))
    btn2Label2:runAction(cc.RepeatForever:create(cc.Sequence:create({
        cc.Spawn:create({
            cc.ScaleTo:create(0.5, 1.15),
            cc.FadeOut:create(0.5)
        }),
        cc.CallFunc:create(function()
            btn2Label2:setScale(1)
            btn2Label2:setOpacity(255)
        end),
        cc.DelayTime:create(0.2)
    })))
    level = function(callback)
        btn1Bg:removeFromParent()
        btn1Label:removeFromParent()
        btn1Label2:removeFromParent()
        btn2Bg:removeFromParent()
        btn2Label:removeFromParent()
        btn2Label2:removeFromParent()
        local heroSpine = self:getSpine()
        if heroSpine then
            heroSpine:runAction(cc.Spawn:create({cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(self._layer:getContentSize().width / 1.1, 0)), 2), cc.FadeOut:create(0.2)}))
        end

        local imageName = self:getImageName()
        imageName:setVisible(false)

        blackLayer1:runAction(cc.Sequence:create({cc.DelayTime:create(0.3), cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, self._size.height)), 2), cc.CallFunc:create(function()
            blackLayer1:removeFromParent()
        end)}))
        blackLayer2:runAction(cc.Sequence:create({cc.DelayTime:create(0.3), cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, -self._size.height * blackLayer2HeightRate)), 2), cc.CallFunc:create(function()
            blackLayer2:removeFromParent()
        end)}))

        local backgroundMC = self:getBackGroundMC()
        if backgroundMC then
            backgroundMC:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.CallFunc:create(function()
                backgroundMC:setVisible(false)
            end)}))
        end

        local imageBg = self:getImageBg()
        if imageBg then
            imageBg:setOpacity(255)
            imageBg:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
                if callback and type(callback) == "function" then
                    callback()
                end
            end)}))
        else
            ScheduleMgr:delayCall(500, nil, function()
                if callback and type(callback) == "function" then
                    callback()
                end
            end)
        end
    end
end

function HeroSpine:_runHeroUnlockAction()
    self._layer:setVisible(true)
    local blackLayer1HeightRate = 0.17
    local blackLayer2HeightRate = 0.22
    local blackLayer1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), self._size.width, self._size.height * blackLayer1HeightRate)
    blackLayer1:setPosition(cc.p(0, self._size.height))
    self._layer:addChild(blackLayer1, 1)
    local whiteLayer1 = cc.LayerColor:create(cc.c4b(255, 255, 255, 188), self._size.width, self._size.height * blackLayer1HeightRate)
    whiteLayer1:setVisible(false)
    whiteLayer1:setPosition(cc.p(0, self._size.height * (1 - blackLayer1HeightRate)))
    self._layer:addChild(whiteLayer1, 2)
    blackLayer1:runAction(cc.Sequence:create({
            cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, self._size.height * (1 - blackLayer1HeightRate))), 2),
            cc.CallFunc:create(function()
                    whiteLayer1:setVisible(true)
                    whiteLayer1:runAction(cc.Sequence:create({
                        cc.FadeOut:create(0.2),
                        cc.CallFunc:create(function()
                            whiteLayer1:setVisible(false)
                            whiteLayer1:removeFromParentAndCleanup()
                        end)}))
            end)}))
    local blackLayer2 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), self._size.width, self._size.height * blackLayer2HeightRate)
    blackLayer2:setPosition(cc.p(0, -self._size.height * blackLayer2HeightRate))
    self._layer:addChild(blackLayer2, 11)
    local whiteLayer2 = cc.LayerColor:create(cc.c4b(255, 255, 255, 188), self._size.width, self._size.height * blackLayer2HeightRate)
    whiteLayer2:setVisible(false)
    whiteLayer2:setPosition(cc.p(0, 0))
    self._layer:addChild(whiteLayer2, 12)
    blackLayer2:runAction(cc.Sequence:create({
            cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, 0)), 2),
            cc.CallFunc:create(function()
                    whiteLayer2:setVisible(true)
                    whiteLayer2:runAction(cc.Sequence:create({
                        cc.FadeOut:create(0.2),
                        cc.CallFunc:create(function()
                            whiteLayer2:setVisible(false)
                            whiteLayer2:removeFromParentAndCleanup()
                        end)}))
            end)}))

    local imageBg = self:getImageBg()
    imageBg:setOpacity(0)
    imageBg:runAction(cc.FadeIn:create(0.2))

    local whiteLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), self._size.width, self._size.height * (1 - blackLayer1HeightRate - blackLayer2HeightRate))
    whiteLayer:setPosition(cc.p(0, self._size.height * blackLayer2HeightRate))
    whiteLayer:setVisible(false)
    self._layer:addChild(whiteLayer, 1)
    local backgroundMC = self:getBackGroundMC()
    backgroundMC:setVisible(false)
    backgroundMC:runAction(cc.Sequence:create({
        cc.DelayTime:create(0.15),
        cc.CallFunc:create(function()
            whiteLayer:setVisible(true)
            whiteLayer:runAction(cc.Sequence:create({
                cc.FadeOut:create(0.3),
                cc.CallFunc:create(function()
                    whiteLayer:setVisible(false)
                    whiteLayer:removeFromParentAndCleanup()
                end)}))
        end),
        cc.CallFunc:create(function()
            backgroundMC:setVisible(true)
    end)}))

    local foregroundMC = self:getForeGroundMC()
    foregroundMC:setVisible(false)

    local imageName = self:getImageName()
    imageName:setVisible(true)
    imageName:setScale(1.8)
    imageName:setOpacity(0)
    imageName:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.Spawn:create({cc.FadeIn:create(0.1), cc.EaseIn:create(cc.ScaleTo:create(0.1, 0.8), 2)}), cc.EaseOut:create(cc.ScaleTo:create(0.1, 1), 2)}))

    local heroSpine = self:getSpine()
    if heroSpine then
        heroSpine:setPosition(0, 0)
        heroSpine:setOpacity(0)
        heroSpine:runAction(cc.Spawn:create({cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(self._layer:getContentSize().width / 1.3, 0)), 2), cc.FadeIn:create(0.2)}))
    end

    local level = nil

    local btn1Bg = ccui.Button:create("globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", 1)
    btn1Bg:setPosition(cc.p(self._size.width / 3, 100))
    btn1Bg:setScaleX(0.45)
    btn1Bg:setScaleY(1.1)
    btn1Bg:addClickEventListener(function()
        level(function()
            if self._onLeftButtonClicked and type(self._onLeftButtonClicked) == "function" then
                self._onLeftButtonClicked()
            end
        end)
    end)
    self._layer:addChild(btn1Bg, 15)
    btn1Bg:setOpacity(0)
    btn1Bg:runAction(cc.Sequence:create({cc.DelayTime:create(0.5), cc.FadeIn:create(0.2)}))
    local btn1Label = cc.Label:createWithTTF("查看", UIUtils.ttfName, 22)
    btn1Label:setColor(cc.c3b(255, 235, 191))
    btn1Label:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn1Label:setPosition(btn1Bg:getPosition())
    self._layer:addChild(btn1Label, 20)
    btn1Label:setOpacity(0)
    btn1Label:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeIn:create(0.2)}))
    local btn2Bg = ccui.Button:create("globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", 1)
    btn2Bg:setPosition(cc.p(self._size.width * 2 / 3, 100))
    btn2Bg:setScaleX(0.45)
    btn2Bg:setScaleY(1.1)
    btn2Bg:addClickEventListener(function()
        level(function()
            if self._onRightButtonClicked and type(self._onRightButtonClicked) == "function" then
                self._onRightButtonClicked()
            end
        end)
    end)
    self._layer:addChild(btn2Bg, 15)
    btn2Bg:setOpacity(0)
    btn2Bg:runAction(cc.Sequence:create({cc.DelayTime:create(0.5), cc.FadeIn:create(0.2)}))
    local btn2Label = cc.Label:createWithTTF("继续", UIUtils.ttfName, 22)
    btn2Label:setColor(cc.c3b(255, 235, 191))
    btn2Label:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn2Label:setPosition(btn2Bg:getPosition())
    self._layer:addChild(btn2Label, 20)
    btn2Label:setOpacity(0)
    btn2Label:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeIn:create(0.2), }))

    level = function(callback)
        btn1Bg:removeFromParent()
        btn1Label:removeFromParent()
        btn2Bg:removeFromParent()
        btn2Label:removeFromParent()
        local heroSpine = self:getSpine()
        if heroSpine then
            heroSpine:runAction(cc.Spawn:create({cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(self._layer:getContentSize().width / 1.1, 0)), 2), cc.FadeOut:create(0.2)}))
        end

        local imageName = self:getImageName()
        imageName:setVisible(false)

        blackLayer1:runAction(cc.Sequence:create({cc.DelayTime:create(0.3), cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, self._size.height)), 2), cc.CallFunc:create(function()
            blackLayer1:removeFromParent()
        end)}))
        blackLayer2:runAction(cc.Sequence:create({cc.DelayTime:create(0.3), cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, -self._size.height * blackLayer2HeightRate)), 2), cc.CallFunc:create(function()
            blackLayer2:removeFromParent()
        end)}))


        backgroundMC:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.CallFunc:create(function()
            backgroundMC:setVisible(false)
        end)}))

        local imageBg = self:getImageBg()
        imageBg:setOpacity(255)
        imageBg:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
            if callback and type(callback) == "function" then
                callback()
            end
        end)}))
    end
end

function HeroSpine:_runHeroUnlockAction()
    self._layer:setVisible(true)
    local blackLayer1HeightRate = 0.17
    local blackLayer2HeightRate = 0.22
    local blackLayer1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), self._size.width, self._size.height * blackLayer1HeightRate)
    blackLayer1:setPosition(cc.p(0, self._size.height))
    blackLayer1:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, self._size.height * (1 - blackLayer1HeightRate))), 2),
            cc.Sequence:create({
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    blackLayer1:setColor(cc.c3b(255, 255, 255))
                end),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    blackLayer1:setColor(cc.c3b(0, 0, 0))
                end)
        })})}))
    self._layer:addChild(blackLayer1, 1)
    local blackLayer2 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), self._size.width, self._size.height * blackLayer2HeightRate)
    blackLayer2:setPosition(cc.p(0, -self._size.height * blackLayer2HeightRate))
    self._layer:addChild(blackLayer2, 11)
    blackLayer2:runAction(cc.Sequence:create({
        cc.Spawn:create({
            cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, 0)), 2),
            cc.Sequence:create({
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    blackLayer2:setColor(cc.c3b(255, 255, 255))
                end),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    blackLayer2:setColor(cc.c3b(0, 0, 0))
                end)
        })})}))

    local imageBg = self:getImageBg()
    imageBg:setOpacity(0)
    imageBg:runAction(cc.FadeIn:create(0.2))

    local whiteLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), self._size.width, self._size.height * (1 - blackLayer1HeightRate - blackLayer2HeightRate))
    whiteLayer:setPosition(cc.p(0, self._size.height * blackLayer2HeightRate))
    whiteLayer:setVisible(false)
    self._layer:addChild(whiteLayer, 15)
    local backgroundMC = self:getBackGroundMC()
    backgroundMC:setVisible(false)
    backgroundMC:setColor(cc.c3b(255, 255, 255))
    backgroundMC:runAction(cc.Sequence:create({
        cc.DelayTime:create(0.05),
        cc.CallFunc:create(function()
            whiteLayer:setVisible(true)
        end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            whiteLayer:setVisible(false)
            whiteLayer:removeFromParentAndCleanup()
        end),
        --cc.DelayTime:create(0.05),
        cc.CallFunc:create(function()
            backgroundMC:setVisible(true)
    end)}))

    local foregroundMC = self:getForeGroundMC()
    foregroundMC:setVisible(false)

    local imageName = self:getImageName()
    imageName:setVisible(true)
    imageName:setScale(1.8)
    imageName:setOpacity(0)
    imageName:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.Spawn:create({cc.FadeIn:create(0.1), cc.EaseIn:create(cc.ScaleTo:create(0.1, 0.8), 2)}), cc.EaseOut:create(cc.ScaleTo:create(0.1, 1), 2)}))

    local heroSpine = self:getSpine()
    if heroSpine then
        heroSpine:setPosition(0, 0)
        heroSpine:setOpacity(0)
        heroSpine:runAction(cc.Spawn:create({cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(self._layer:getContentSize().width / 1.3, 0)), 2), cc.FadeIn:create(0.2)}))
    end

    local level = nil

    local btn1Bg = ccui.Button:create("globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", 1)
    btn1Bg:setPosition(cc.p(self._size.width / 3, 100))
    btn1Bg:setScaleX(0.45)
    btn1Bg:setScaleY(1.1)
    btn1Bg:addClickEventListener(function()
        level(function()
            if self._onLeftButtonClicked and type(self._onLeftButtonClicked) == "function" then
                self._onLeftButtonClicked()
            end
        end)
    end)
    self._layer:addChild(btn1Bg, 15)
    btn1Bg:setOpacity(0)
    btn1Bg:runAction(cc.Sequence:create({cc.DelayTime:create(0.5), cc.FadeIn:create(0.2)}))
    local btn1Label = cc.Label:createWithTTF("查看", UIUtils.ttfName, 22)
    btn1Label:setColor(cc.c3b(255, 235, 191))
    btn1Label:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn1Label:setPosition(btn1Bg:getPosition())
    self._layer:addChild(btn1Label, 20)
    btn1Label:setOpacity(0)
    btn1Label:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeIn:create(0.2)}))
    local btn2Bg = ccui.Button:create("globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", "globalImageUI4_team_textBg.png", 1)
    btn2Bg:setPosition(cc.p(self._size.width * 2 / 3, 100))
    btn2Bg:setScaleX(0.45)
    btn2Bg:setScaleY(1.1)
    btn2Bg:addClickEventListener(function()
        level(function()
            if self._onRightButtonClicked and type(self._onRightButtonClicked) == "function" then
                self._onRightButtonClicked()
            end
        end)
    end)
    self._layer:addChild(btn2Bg, 15)
    btn2Bg:setOpacity(0)
    btn2Bg:runAction(cc.Sequence:create({cc.DelayTime:create(0.5), cc.FadeIn:create(0.2)}))
    local btn2Label = cc.Label:createWithTTF("继续", UIUtils.ttfName, 22)
    btn2Label:setColor(cc.c3b(255, 235, 191))
    btn2Label:enableOutline(cc.c4b(93, 93, 93, 255), 1)
    btn2Label:setPosition(btn2Bg:getPosition())
    self._layer:addChild(btn2Label, 20)
    btn2Label:setOpacity(0)
    btn2Label:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeIn:create(0.2), }))

    level = function(callback)
        btn1Bg:removeFromParent()
        btn1Label:removeFromParent()
        btn2Bg:removeFromParent()
        btn2Label:removeFromParent()
        local heroSpine = self:getSpine()
        if heroSpine then
            heroSpine:runAction(cc.Spawn:create({cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(self._layer:getContentSize().width / 1.1, 0)), 2), cc.FadeOut:create(0.2)}))
        end

        local imageName = self:getImageName()
        imageName:setVisible(false)

        blackLayer1:runAction(cc.Sequence:create({cc.DelayTime:create(0.3), cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, self._size.height)), 2), cc.CallFunc:create(function()
            blackLayer1:removeFromParent()
        end)}))
        blackLayer2:runAction(cc.Sequence:create({cc.DelayTime:create(0.3), cc.EaseIn:create(cc.MoveTo:create(0.15, cc.p(0, -self._size.height * blackLayer2HeightRate)), 2), cc.CallFunc:create(function()
            blackLayer2:removeFromParent()
        end)}))

        backgroundMC:runAction(cc.Sequence:create({cc.DelayTime:create(0.2), cc.CallFunc:create(function()
            backgroundMC:setVisible(false)
        end)}))

        local imageBg = self:getImageBg()
        imageBg:setOpacity(255)
        imageBg:runAction(cc.Sequence:create({cc.DelayTime:create(0.4), cc.FadeOut:create(0.2), cc.CallFunc:create(function()
            if callback and type(callback) == "function" then
                callback()
            end
        end)}))
    end
end

function HeroSpine:getContainer()
    return self._layer
end

function HeroSpine:getImageBg()
    return self._imageBg
end

function HeroSpine:getImageName()
    return self._imageName
end

function HeroSpine:getSpine()
    return self._spine
end

function HeroSpine:getBackGroundMC()
    return self._backgroundMC
end

function HeroSpine:getForeGroundMC()
    return self._foregroundMC
end

function HeroSpine:_retainTaskReferenceCount()
    if self._taskReferenceCount < 0 then return end
    self._taskReferenceCount = self._taskReferenceCount + 1
end

function HeroSpine:_releaseTaskReferenceCount()
    if self._taskReferenceCount <= 0 then return end
    self._taskReferenceCount = self._taskReferenceCount - 1
end

function HeroSpine:_tryClear()
    if not self._markClear or self._taskReferenceCount > 0 then return end
    spineMgr:clear()
    mcMgr:clear()
    cc.TextureCache:getInstance():removeTextureForKey("asset/uiother/hero/" .. self._heroData.heroport .. ".jpg")
    self:removeFromParentAndCleanup()
end

function HeroSpine:clear()
    self:setVisible(false)
    self._markClear = true
    self:_tryClear()
    --[[
    if HeroSpine.kShowWithAction then 
        local __clear = function()
            self._markClear = true
            self:_tryClear()
        end
        if self._imageBg then
            self:runAction(cc.Sequence:create(cc.FadeOut:create(0.8), cc.CallFunc:create(function()
                __clear()
            end)))
        else
            __clear()
        end
    else
        self:setVisible(false)
        self._markClear = true
        self:_tryClear()
    end
    ]]
end

function HeroSpine.dtor()
    ALR = nil
end

return HeroSpine