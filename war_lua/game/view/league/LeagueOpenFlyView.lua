--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-02-10 11:55:48
--

-- 展示方法
-- self._viewMgr:showDialog("league.LeagueOpenFlyView", {target = self:getUI("bg.midBg3.pve")}, true) 
local LeagueOpenFlyView = class("LeagueOpenFlyView",BasePopView)
function LeagueOpenFlyView:ctor(param)
    self.super.ctor(self)
    self.popAnim = false
    self._callback = param and param.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueOpenFlyView:onInit()
end

-- 第一次进入调用, 有需要请覆盖
function LeagueOpenFlyView:onShow()

end

function LeagueOpenFlyView:getMaskOpacity()
    return 0
end

-- 接收自定义消息
function LeagueOpenFlyView:reflashUI(data)
	self._bg = self:getUI("bg")
	self._target = data.target or self._bg
    local mcStar = mcMgr:createViewMC( "jifenlansaikaiqi_kaiqianim", false, false, function (_, sender)

    end,RGBA8888)
    mcStar:setPosition(480,380)
    self._bg:addChild(mcStar,99)
    ScheduleMgr:delayCall(2100, self, function(  )
    	if self.showFlyAnim then 
	    	self:showFlyAnim()
	    end
    end)

    -- local mcStar = mcMgr:createViewMC( "kaipaichuxian_flashcardkaipaichuxian", false, false, function (_, sender)
    --     self:close()
    --     UIUtils:reloadLuaFile("league.LeagueOpenFlyView")
    -- end,RGBA8888)
    -- mcStar:setPosition(480,380)
    -- self._bg:addChild(mcStar,99)
end

function LeagueOpenFlyView:showFlyAnim( )
	local icon = ccui.Widget:create() --cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. "ta_jingjichangcishu" .. ".png")
    icon:setPosition(480, 400)
    self._bg:addChild(icon, 2)
    icon:setScale(0)

    local btn = self._target
    local qipao = btn:getChildByFullName("tipbg")

    local scale = btn:getScale()

    local bgNodePos = btn:convertToWorldSpace(cc.p(0, 0)) 
    local iconPos = icon:convertToWorldSpace(cc.p(0, 0))
    local posX = bgNodePos.x - iconPos.x + btn:getContentSize().width*0.5*btn:getScaleX()   -- 165 --systemDes.position[1]
    local posY = bgNodePos.y - iconPos.y + btn:getContentSize().height*0.5*btn:getScaleY()  -- 99 --systemDes.position[2]

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
        cc.ScaleTo:create(0.05, 1.0), 
        cc.CallFunc:create(function()
            local mc2 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true, false) 
            mc2:setName("mc2")
            -- mc2:setScale(100) 
            mc2:setRotation(angle)
            icon:addChild(mc2)

            local sp = mcMgr:createViewMC("lashentiao_lianmengjihuo", false, false)  
            sp:setAnchorPoint(cc.p(0.5, 0))
            sp:setRotation(90)
            sp:setScaleX(0.1)
            mc2:addChild(sp, -1)
            local spSeq = cc.Sequence:create(cc.ScaleTo:create(0.1, .8, 1), cc.ScaleTo:create(0.4, 1.1, 1), cc.ScaleTo:create(0.1, 0, 1))
            sp:runAction(spSeq)
        end),
        cc.CallFunc:create(function()
            -- audioMgr:playSound("Unlock")
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
            mc1:setScale(1)
            icon:addChild(mc1,-1) 
            
            btn:stopAllActions()
            -- btn:setOpacity(255)
            btn:runAction(cc.Sequence:create(
                cc.CallFunc:create(function()
                    btn:setOpacity(100)
                end),
                cc.DelayTime:create(0.3), 
                cc.CallFunc:create(function()
                    btn:setOpacity(0)
                end)
            ))
            -- if not tolua.isnull(qipao) then qipao:removeFromParent() end
			if not qipao and not btn:getChildByFullName("tipbg_guanjun") then
				local tipScale = 1 / btn:getScale()
				local tipbg = cc.Scale9Sprite:createWithSpriteFrameName("qipao_guanjun.png")     
		        tipbg:setName("tipbg_guanjun")
		        tipbg._touchToRemove = true
		        tipbg:setAnchorPoint(0.25, 0)
		        tipbg:setPosition(50, 20)
		        tipbg:setScale(tipScale)
		        local seq = cc.Sequence:create(cc.ScaleTo:create(1, tipScale+tipScale*0.2), cc.ScaleTo:create(1, tipScale))
		        tipbg:runAction(cc.RepeatForever:create(seq))
		        btn:addChild(tipbg, 10000)
			end
            
        end),
        cc.DelayTime:create(1), 
        -- cc.MoveTo:create(speed, cc.p(95, MAX_SCREEN_HEIGHT - 37)), 
        cc.CallFunc:create(function ()
            GuideUtils.checkTriggerByType("open", 101)
            local mc2 = icon:getChildByFullName("mc2")
            if mc2 then
                mc2:setOpacity(0)
            end
            if self._callback then
                self._callback()
            end
            self:close()
			UIUtils:reloadLuaFile("league.LeagueOpenFlyView")
        end), 
        cc.RemoveSelf:create(true)))
end

return LeagueOpenFlyView