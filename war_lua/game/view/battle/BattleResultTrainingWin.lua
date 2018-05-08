--
-- Author: huangguofang
-- Date: 2016-10-24 15:21:37
--

local BattleResultTrainingWin = class("BattleResultTrainingWin", BasePopView)

function BattleResultTrainingWin:ctor(data)
    BattleResultTrainingWin.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._battleInfo = data.result
    self._trainingData = self._battleInfo.trainingData or {}
    
end


function BattleResultTrainingWin:onInit()

    self._evaluateImg = {
        [1] = "globalImgUI_pingjia4.png",
        [2] = "globalImgUI_pingjia3.png",
        [3] = "globalImgUI_pingjia2.png",
        [4] = "globalImgUI_pingjia1.png",
        [5] = "globalImgUI_pingjia1.png",
    }

    self._titleTxt = {
        [1] = "新兵训练营",
        [2] = "精英训练营",
        [3] = "皇家演练场"

    }
    self._touchPanel = self:getUI("touchPanel")    
    self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
    self._touchPanel:setSwallowTouches(false)
    self._touchPanel:setEnabled(false)
    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
    self._bgPanel = self:getUI("bgPanel")
    self._bgImg = self:getUI("bgPanel.bg_img")
    self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    self._bg = self:getUI("bg")
    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)

    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)

    self._seniorBg = self:getUI("bg.seniorBg")
    self._seniorBg:setOpacity(0)
    self._seniorBg:setCascadeOpacityEnabled(true)
    self._seniorBg:setVisible(false)

    self._juniorBg = self:getUI("bg.juniorBg")
    self._juniorBg:setOpacity(0)
    self._juniorBg:setCascadeOpacityEnabled(true)
    self._juniorBg:setVisible(false)

    -- 当前显示面板 初级精英   高级
    self._currBg = self._juniorBg

    if 3 == tonumber(self._trainingData.type) then
        self._currBg = self._seniorBg
    end

    local passImg = self._currBg:getChildByFullName("passImg")
    self._passImg = passImg:getChildByFullName("passImg")
    self._passImg:setOpacity(0)

    self._tipsTxt = self:getUI("bgPanel.tipsTxt")
    self._tipsTxt:setOpacity(0)

    self:initCurrPanel(self._currBg)

    -- self:registerClickEvent(self._countBtn, specialize(self.onCount, self))


	local mcMgr = MovieClipManager:getInstance()
    self:animBegin()
end
-- 初始化当前面板
function BattleResultTrainingWin:initCurrPanel(currPanel)

    self._currBg:setVisible(true)

    local des = currPanel:getChildByFullName("des")
    des:setFontName(UIUtils.ttfName)
    local txt = "恭喜您在" .. self._titleTxt[tonumber(self._trainingData.type)] .. "通关"
    des:setString(txt)

    local titleDes = currPanel:getChildByFullName("titleDes")
    titleDes:setFontName(UIUtils.ttfName)
    titleDes:setString(lang(self._trainingData.name))
    
    local des1 = currPanel:getChildByFullName("des1")
    des1:setFontName(UIUtils.ttfName)

    if self._trainingData.type ~= 3 then
        self._passImg:loadTexture("trainResult_evaluate_pass.png",1)
    else

        local evaluateData = self._modelMgr:getModel("TrainingModel"):getEvaluateDataByScore(self._battleInfo.score or 0)
        if self._evaluateImg[tonumber(evaluateData.evaluate)] then
            self._passImg:loadTexture(self._evaluateImg[tonumber(evaluateData.evaluate)],1)
        end
        local passDes = currPanel:getChildByFullName("passDes")
        if passDes then
            passDes:setFontName(UIUtils.ttfName)
        end
        local passDes1 = currPanel:getChildByFullName("passDes1")
        if passDes1 then
            passDes1:setFontName(UIUtils.ttfName)
        end
        local passTxt = currPanel:getChildByFullName("passTxt")
        if passTxt then
            passTxt:setFontName(UIUtils.ttfName)
            local lowNum = 0
            local highNum = 0
            local randNum = 0.0
            if evaluateData.percent then
                lowNum = evaluateData.percent[1] or 0 
                highNum = evaluateData.percent[2] or 0
            end
            lowNum = lowNum * 10
            highNum = highNum * 10
            randNum = math.random(lowNum, highNum) / 10 
            -- print("============================randmiun==",randNum)
            passTxt:setString(randNum .. "%")

            passDes1:setPositionX(passTxt:getPositionX()+passTxt:getContentSize().width + 2)

        end
        -- 活动关卡
        local scoreTxt = currPanel:getChildByFullName("scoreTxt")
        local score = currPanel:getChildByFullName("score")
        if 3 == tonumber(self._trainingData.type) and self._trainingData.cType and self._trainingData.cType == 2 then
            scoreTxt:setVisible(true)
            score:setVisible(true)
            scoreTxt:setString("战斗时间:")
            -- print("===========self._battleInfo.score====",self._battleInfo.score)
            -- 通关时间
            local scoreNum = self._battleInfo.time or 0
            score:setString(scoreNum .. "s")
        else
            if scoreTxt then
                scoreTxt:setVisible(false)
            end
            if score then
                score:setVisible(false)
            end
        end
    end

end

function BattleResultTrainingWin:onQuit()
    if self._callback then
        self._callback()
    end
    -- UIUtils:reloadLuaFile("battle.BattleResultTrainingWin")
end

function BattleResultTrainingWin:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
end

function BattleResultTrainingWin:animBegin()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("WinBattle")

    -- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

    local posBgX,posBgY = self._posBgX,self._posBgY
    local mc2
    local moveBg = cc.Sequence:create(
        cc.Spawn:create(cc.FadeIn:create(0.1),
        cc.MoveTo:create(0.1,cc.p(posBgX,posBgY-40))),
        cc.MoveTo:create(0.15,cc.p(posBgX,posBgY)))
    self._bgImg:runAction(moveBg)

    local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false) 
    liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
    self:getUI("bg_click"):addChild(liziAnim, 1000)
    
    -- 动画小精灵
    local animPosLeft = self:getUI("bg.animPos_left") 
    --添加精灵动画
    local spine = spineMgr:createSpine("xinshouyindao", function (spine)
        -- spine:setVisible(false)
        spine.endCallback = function ()
            spine:setAnimation(0, "pingdan", true)
        end 
        local anim = "pingdan"
        spine:setAnimation(0, anim, true)
        spine:setPosition(animPosLeft:getPositionX() - 100,animPosLeft:getPositionY())
        -- spine:setScale(scale)
        animPosLeft:getParent():addChild(spine,2)

        local action = cc.MoveTo:create(0.1,cc.p(animPosLeft:getPositionX() ,animPosLeft:getPositionY()))
        spine:runAction(action)

    end)

    ScheduleMgr:delayCall(300, self, function ()         
        -- 动画恭喜通关
        local animPos = self:getUI("bg.animPos") 
        self._passMc = mcMgr:createViewMC("gongxitongguan_qianjin", false)
        self._passMc:setPosition(animPos:getPosition())
        self._passMc:setScale(0.8)
        animPos:getParent():addChild(self._passMc)
     end)

     local posX = self._currBg:getPositionX()
     local posY = self._currBg:getPositionY()

     self._currBg:setPosition(posX, posY - 100)
     local panelMove = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posX,posY+10)),cc.MoveTo:create(0.05,cc.p(posX,posY)))
     local panelSpawn = cc.Spawn:create(panelMove,cc.FadeIn:create(0.15))
     local panelSeq = cc.Sequence:create(cc.DelayTime:create(0.8), panelSpawn)
     self._currBg:runAction(panelSeq)

     local scaleNum = self._passImg:getScale()
     self._passImg:setScale(scaleNum*4)
     local panelScale = cc.Sequence:create(cc.ScaleTo:create(0.1,scaleNum-0.2),cc.ScaleTo:create(0.05,scaleNum))
     local panelSpawn = cc.Spawn:create(panelScale,cc.FadeIn:create(0.2))
     local seq = cc.Sequence:create(cc.DelayTime:create(1.4), panelSpawn,cc.CallFunc:create(function ()
         self._touchPanel:setEnabled(true)
     end))
     self._passImg:runAction(seq)

     self._tipsTxt:runAction(cc.Sequence:create(cc.DelayTime:create(1.4),cc.FadeIn:create(0.1)))
end

function BattleResultTrainingWin.dtor()
    BattleResultTrainingWin = nil

end

return BattleResultTrainingWin