--
-- Author: huangguofang
-- Date: 2018-08-08 11:02:33
--

-- 奖励展示layer
local AcLimitPrayAwardLayer = class("AcLimitPrayAwardLayer",BaseLayer)
function AcLimitPrayAwardLayer:ctor(params)
    self.super.ctor(self)
    -- parent=self,UIInfo = self._info,openId=self._openId
    self._parent = params.parent
    self._UIInfo = params.UIInfo or {}
    self._openId = params.openId
    self._awardTeamPanel = params.awardTeamPanel or self

    self._userModel = self._modelMgr:getModel("UserModel")
    self._limitPrayModel = self._modelMgr:getModel("LimitPrayModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function AcLimitPrayAwardLayer:onInit() 	
    local rankData = clone(tab.prayRank)
    local awardD = rankData[1] and rankData[1].reward
    local teamSkinData = {}
    local heroShadowData = {}
    local teamSkinId = 0
    for k,v in pairs(awardD) do
        if v[1] == "tool" then
            teamSkinId = string.sub(v[2],2,-1)
            if tab:TeamSkin(tonumber(teamSkinId)) then
                teamSkinData = tab:TeamSkin(tonumber(teamSkinId))
            end
        elseif v[1] == "heroShadow" then
            heroShadowData = tab:HeroShadow(tonumber(v[2]))
        end
    end

    -- 兵模
    local teamBgImg  	= self:getUI("bg.teamBgImg")
    -- teamBgImg:setPosition(140,380)
    local skinart = teamSkinData["skinart"]

    self._actionList = {"stop", "run","atk" ,"atk2"}
    if self._teamMc then
        self._teamMc:setVisible(true)
    else
        if skinart then
            HeroAnim.new(self._awardTeamPanel, skinart, self._actionList, function (mc)
                mc:play()
                mc:setScale(0.35)
                mc:setScaleX(-0.35)
                mc:changeMotion("stop")
                mc:setLocalZOrder(20)
                mc:setPosition(100,-25)
                self._teamMc = mc
            end, false, nil, nil, true)
        end
    end
    

    local heroShadow 	= self:getUI("bg.heroShadow")
    local art = heroShadowData["art"]
    if art then
        HeroAnim.new(heroShadow, art, self._actionList, function (mc)
            mc:play()
            mc:setScale(0.2)
            mc:setScaleX(-0.2)
            mc:changeMotion("stop")
            mc:setLocalZOrder(2)
            mc:setPosition(180,0)
        end, false, nil, nil, true)
    end

    self._scheduler = cc.Director:getInstance():getScheduler()
    self._scheduler1 = self._scheduler:scheduleScriptFunc(handler(self, self.actionUpdate), 5, false)
    --场景监听
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            -- if self._teamMc then
            --     self._teamMc:setVisible(false)
            -- end
            if self._scheduler then
                if self._scheduler1 then
                    self._scheduler:unscheduleScriptEntry(self._scheduler1)
                end
                    self._scheduler = nil           
                end
            end
        end)

    -- 兵团例会
    local teamImg 		= self:getUI("bg.teamPanel.teamImg")
    local imgName = teamSkinData.skinart2
    if imgName then
        teamImg:loadTexture("asset/uiother/team/"..imgName..".png")
        teamImg:setPosition(self._UIInfo.teamPos2[1],self._UIInfo.teamPos2[2])
    else
        teamImg:setVisible(false)
    end
    if self._UIInfo.scaleNum then
        teamImg:setScale(self._UIInfo.scaleNum)
    end
    if self._UIInfo.isFlip then
        teamImg:setFlippedX(true)
    end

end

function AcLimitPrayAwardLayer:actionUpdate( )
    local index = math.random(1, 4)
    print("==========1111==index====",index)
    local actionStr = self._actionList[tonumber(index)]
    if self._teamMc then
        self._teamMc:changeMotion(actionStr)
    end
end

-- 接收自定义消息
function AcLimitPrayAwardLayer:reflashUI(data)
    print("===================reflashUI=================")
end

return AcLimitPrayAwardLayer