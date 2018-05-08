--
-- Author: huangguofang
-- Date: 2016-11-05 17:34:20
--
local TrainingCupUpView = class("TrainingCupUpView",BasePopView)
function TrainingCupUpView:ctor(data)
    self.super.ctor(self)
    self._data = data

end

-- 初始化UI后会调用, 有需要请覆盖
function TrainingCupUpView:onInit()
	-- self._titleImg = self:getUI("bg.titleImg")
	-- self._stageName = self:getUI("bg.stageName")
    self._cupImg = {
        [1] = "trainingView_senior_stageUpCopper.png",
        [2] = "trainingView_senior_stageUpSliver.png",
        [3] = "trainingView_senior_stageUpGolden.png",
        [4] = "trainingView_senior_stageUpWG.png",
    }
    
	self._stageImg = self:getUI("bg.stageImg")
	self._stageImg:loadTexture(self._cupImg[self._data.id] or "trainingView_senior_cupEmpty.png",1)

	self._bg = self:getUI("bg")

	self:registerClickEventByName("closePanel",function( )
    	self:close()
        UIUtils:reloadLuaFile("training.TrainingCupUpView")
	end)

    self._closeTip = self:getUI("bg.closeTip")    
    self._closeTip:setOpacity(0)

    -- 新动画界面
    self._stageBg = self:getUI("bg.stageBg")
    self._stageBg:setCascadeOpacityEnabled(true)
    self._stageBg:setOpacity(0)

    self._zoneImg = self:getUI("bg.stageBg.zoneImg")
    
    local des1 = self:getUI("bg.stageBg.des1")  
    des1:setFontName(UIUtils.ttfName)

    local des2 = self:getUI("bg.stageBg.des2")  
    des2:setFontName(UIUtils.ttfName)
    des2:setString("累计获得" .. self._data.num .. "个")

    local des3 = self:getUI("bg.stageBg.des3")  
    des3:setFontName(UIUtils.ttfName)

    self:stageImgAnim()
end

-- 接收自定义消息
function TrainingCupUpView:reflashUI(data)
   
	-- self:animBegin()
    self:stageImgAnim(function( )
        self:nextAnim()
    end)
end

function TrainingCupUpView:stageImgAnim( callback )
    local stageImg = self._stageImg
    local posX = stageImg:getPositionX()
    local posY = stageImg:getPositionY() 
    stageImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(0.1,cc.p(-1,0)),
        cc.MoveBy:create(0.1,cc.p(1,0))
        )))
    local changeMc = mcMgr:createViewMC("qiehuanguangxiao_leaguejinjiechenggong", false, true,function( _,sender )
        -- stageImg:loadTexture(self._data.art or "trainingView_senior_cupEmpty.png",1)
        stageImg:stopAllActions()

        local stageAnimImg = stageImg:clone()
        stageAnimImg:setName("stageAnimImg")
        stageAnimImg:setBrightness(40)
        stageAnimImg:setPurityColor(255, 255, 255)
        stageAnimImg:setAnchorPoint(cc.p(0.5,0.5))
        stageAnimImg:setPosition(posX,posY)
        stageImg:getParent():addChild(stageAnimImg)

        stageAnimImg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.15,1.3),
            -- cc.DelayTime:create(0.1),
            cc.Spawn:create(cc.FadeOut:create(0.1),cc.ScaleTo:create(0.05,1)),
            cc.CallFunc:create(function( )
                stageAnimImg:removeFromParent()
                local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
                local bgMc = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false,function( _,sender )
                    sender:gotoAndPlay(10)
                end,RGBA8888)
                bgMc:setPosition(stageImg:getContentSize().width*0.5,stageImg:getContentSize().height*0.5)
                stageImg:addChild(bgMc,-1)
                stageImg:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.1),
                    cc.EaseOut:create(cc.MoveTo:create(0.15,cc.p(posX - 100,posY)),0.7),
                    cc.CallFunc:create(function( )
                        if callback then
                            callback() 
                        end
                    end))
                )
            end)
            )
        )
    end,RGBA8888)
    changeMc:setPlaySpeed(0.8)
    changeMc:setPosition(stageImg:getContentSize().width*0.5,stageImg:getContentSize().height*0.5)
    stageImg:addChild(changeMc)
end

function TrainingCupUpView:nextAnim( callack )
    -- local stagePosY = 80
    local stageBg = self._stageBg
    stageBg:setPositionX(205)
    stageBg:runAction(cc.Sequence:create(cc.Spawn:create(
        cc.MoveTo:create(0.1,cc.p(265,stageBg:getPositionY())),
        cc.FadeIn:create(0.2)
    )))

    self._closeTip:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.FadeIn:create(0.1)))

    mcMgr:loadRes("leaguejinjiechenggong",function( )
        local mc = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
        mc:setPosition(400,400)
        self._bg:addChild(mc,99)
    end)
end

return TrainingCupUpView