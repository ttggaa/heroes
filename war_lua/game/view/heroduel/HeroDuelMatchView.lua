--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-24 15:36:26
--
local HeroDuelMatchView = class("HeroDuelMatchView", BasePopView)

local sfc = cc.SpriteFrameCache:getInstance()
function HeroDuelMatchView:ctor(data)
    HeroDuelMatchView.super.ctor(self)

    self._roomData = nil
    self._data = data

    self._hModel = self._modelMgr:getModel("HeroDuelModel")

    local offset = 50
    self._aniPosList = {
        [1] =  {maxScale = 1.2, startX = -20, startY = 0,   toX = -70  , toY = 0    },      
        [2] =  {maxScale = 1.2, startX = 20,  startY = 0,   toX = 70   , toY = 0    },      
        [3] =  {maxScale = 0.8, startX = -80, startY = 80,  toX = -130 , toY = 130  },      
        [4] =  {maxScale = 0.8, startX = 80,  startY = 80,  toX = 130  , toY = 130  },      
        [5] =  {maxScale = 0.8, startX = -80, startY = -80, toX = -130 , toY = -130 },      
        [6] =  {maxScale = 0.8, startX = 80,  startY = -80, toX = 130  , toY = -130 },      
        [7] =  {maxScale = 1,   startX = -80, startY = 20,  toX = -130 , toY = 70   },      
        [8] =  {maxScale = 1,   startX = 100, startY = -20, toX = 150  , toY = -70  },      
        [9] =  {maxScale = 1,   startX = -100,startY = -20, toX = -150 , toY = -70  },      
        [10] = {maxScale = 1,   startX = 100, startY = 20,  toX = 150  , toY = 70   },      
        [11] = {maxScale = 1,   startX = 0,   startY = 100, toX = 0    , toY = 150  },      
        [12] = {maxScale = 1,   startX = 0,   startY = -100,toX = 0    , toY = -150 },      
        [13] = {maxScale = 0.8, startX = -80, startY = 80,  toX = -130 , toY = 130  },      
        [14] = {maxScale = 0.8, startX = 80,  startY = 80,  toX = 130  , toY = 130  },      
        [15] = {maxScale = 0.8, startX = -80, startY = -80, toX = -130 , toY = -130 },      
        [16] = {maxScale = 0.8, startX = 80,  startY = -80, toX = 130  , toY = -130 },      
        [17] = {maxScale = 1,   startX = -80, startY = 20,  toX = -130 , toY = 70   },      
        [18] = {maxScale = 1,   startX = 100, startY = -20, toX = 150  , toY = -70  },      
        [19] = {maxScale = 1,   startX = -100,startY = -20, toX = -150 , toY = -70  },      
        [20] = {maxScale = 1,   startX = 100, startY = 20,  toX = 150  , toY = 70   },      
        [21] = {maxScale = 1,   startX = 0,   startY = 90,  toX = 0    , toY = 150  },      
        [22] = {maxScale = 1,   startX = 0,   startY = -90, toX = 0    , toY = -150 }     
    }
end

function HeroDuelMatchView:onInit()
    self:registerClickEventByName("bg.cancleBtn", function()
        self:onCanCelMatch(3)
    end)

--    self:registerClickEventByName("bg.aniNode", function()
--        self:showMactchComplete({})
--    end)

    self._ballBg = self:getUI("bg.bg4")
    self._ballBg:setRotation(0)

    self._aniNode = self:getUI("bg.aniNode")

    self._labelBg = self:getUI("bg.labelBg")
    self._desLabel = self:getUI("bg.labelBg.desLabel")
    self._desLabel:setColor(cc.c3b(254, 255, 221))
    self._desLabel:enable2Color(1, cc.c4b(253, 190, 77, 255))

    local waitTime = 120
    self._desLabel:setString("正在为您挑选对手...（".. waitTime .."S）")
    self._timer = ScheduleMgr:regSchedule(1000,self,function( )
        waitTime = waitTime - 1

        self._desLabel:setString("正在为您挑选对手...（".. waitTime .."S）")

        if waitTime <= 0 then
            if self._timer then
                ScheduleMgr:unregSchedule(self._timer)
                self._timer = nil
            end

            self:onCanCelMatch(4, "匹配失败")
        end
    end)

    local temTab = tab.roleAvatar
    self._avatarTab = {}
    for k, v in pairs(temTab) do
        table.insert(self._avatarTab, v)
    end

    self._headIconList = {}
    local tabLen = #self._avatarTab
    for i = 1, #self._aniPosList do
        local avatarData = nil
        local filename = nil
        while not sfc:getSpriteFrameByName(filename) do
            avatarData = self._avatarTab[math.random(1, tabLen)]
            filename = avatarData.icon .. ".jpg"
        end

        local headIcon = self:createHeadIcon(avatarData.icon .. ".jpg")
        headIcon:setPosition(self._aniPosList[i].startX + 150, self._aniPosList[i].startY + 150)
        table.insert(self._headIconList, headIcon)
    end

    self:setListenReflashWithParam(true)
    self:listenReflash("HeroDuelModel", self.onModelReflash) 
end

function HeroDuelMatchView:createHeadIcon(fileName)
    local headIcon = cc.Sprite:createWithSpriteFrameName(fileName)
    headIcon:setScale(0.25)
    headIcon:setOpacity(0)
    headIcon:setAnchorPoint(0.5, 0.5)
    headIcon:setCascadeOpacityEnabled(true)

    local headFrame = cc.Sprite:createWithSpriteFrameName("bg_head_mainView.png")
    headFrame:setScale(headIcon:getContentSize().width / 92 * 1.1)
    headFrame:setPosition(headIcon:getContentSize().width*0.5, headIcon:getContentSize().height*0.5)
    headIcon:addChild(headFrame)
    self._aniNode:addChild(headIcon)
    headIcon.frame = headFrame
    return headIcon
end


function HeroDuelMatchView:onModelReflash(eventName)
    if eventName == self._hModel.ROOM_UPDATE then 
        if self._hasComplete then return end

        self._hasComplete = true
        self._roomData = self._hModel:getRoomData()

        if self._timer then
            ScheduleMgr:unregSchedule(self._timer)
            self._timer = nil
        end

        self:lock(-1)
        ScheduleMgr:delayCall(1000, self, function()
            self:showMactchComplete(self._roomData.rival.info)

            ScheduleMgr:delayCall(1000, self, function()
                self._viewMgr:showDialog("heroduel.HeroDuelFightView", {data = self._roomData, callback = self._data.callback})
                self:unlock()
                self:close()
            end)
        end)

    elseif eventName == self._hModel.HD_CLOSE then 
        self:onCanCelMatch(4, lang("HERODUEL16"))

    elseif eventName == self._hModel.LOGIN_SERVER_ERROR then 
        if self._timer then
            ScheduleMgr:unregSchedule(self._timer)
            self._timer = nil
        end

        self._serverMgr:sendMsg("HeroDuelServer", "hDuelCancelMatch", {}, true, {}, function(result)

            ServerManager:getInstance():RS_clear()
            self._viewMgr:showTip("匹配失败")
            self:close()
        end)

    elseif eventName == self._hModel.MATCH_ERROR then 

        self._viewMgr:showTip("匹配失败")
        self:close()
    end
end

function HeroDuelMatchView:onCanCelMatch(closeTp, tipStr)
    if not self._hModel:getIsCorrectState(self._hModel.IN_MATCH) then
       self._viewMgr:showTip("已匹配成功，请耐心等待")
       return 
    end

    if self._timer then
        ScheduleMgr:unregSchedule(self._timer)
        self._timer = nil
    end
    self._serverMgr:sendMsg("HeroDuelServer", "hDuelCancelMatch", {tp = closeTp}, true, {}, function(result)
--        dump(result)
        if result.status == -1 then
            self._viewMgr:showTip("已匹配成功，请耐心等待")
        else
            if tipStr ~= nil then
                self._viewMgr:showTip(tipStr)
            end
            self:close()
            UIUtils:reloadLuaFile("heroduel.HeroDuelMatchView")
        end
    end)
end

function HeroDuelMatchView:onShow()
    ScheduleMgr:nextFrameCall(self, function()
        self._ballBg:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.RotateBy:create(0.2, 360),
                cc.FadeIn:create(0.2)
            ),
            cc.CallFunc:create(function()
                self:playMatchAni()
            end)
        ))
    end)
end

local allTime = 0.7
function HeroDuelMatchView:playMatchAni()

    for i = 1, #self._aniPosList do
        local lifeCycle = math.random(2, 5)*0.1
        local maxScale = math.random(1, self._aniPosList[i].maxScale)
        local headCell = self._headIconList[i]
        headCell:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.DelayTime:create(i * 0.1),
                    cc.Spawn:create(
                        cc.EaseOut:create(cc.MoveTo:create(allTime, cc.p(self._aniPosList[i].toX + 150, self._aniPosList[i].toY + 150)),2),
                        cc.EaseOut:create(cc.ScaleTo:create(allTime, maxScale),2),
                        cc.Sequence:create(
                            cc.FadeIn:create(lifeCycle*0.001),
                            cc.DelayTime:create(lifeCycle * 0.6),
                            cc.FadeOut:create(lifeCycle*0.4)
                        )
                    ),
                    cc.CallFunc:create(function()
                        headCell:setScale(0.25)
                        headCell:setOpacity(0)
                        headCell:setPosition(self._aniPosList[i].startX + 150, self._aniPosList[i].startY + 150)

                        local avatarData = nil
                        local filename = nil
                        local tabLen = #self._avatarTab
                        while not sfc:getSpriteFrameByName(filename) do
                            avatarData = self._avatarTab[math.random(1, tabLen)]
                            filename = avatarData.icon .. ".jpg"
                        end
                        headCell:setSpriteFrame(filename)
                        headCell.frame:setScale(headCell:getContentSize().width / 92 * 1.1)
                        headCell.frame:setPosition(headCell:getContentSize().width*0.5, headCell:getContentSize().height*0.5)
                    end)
                )
            )
        )
    end
end

function HeroDuelMatchView:showMactchComplete(rivalData)
    local randomPos = {posX = math.random(20, 280), posY = math.random(20, 280)}

    for i = 1, #self._headIconList do
        self._headIconList[i]:stopAllActions()
        self._headIconList[i]:removeFromParent(true)
    end
    self._headIconList = nil
    
--    local enemy = self:createHeadIcon(tab:RoleAvatar(rivalData.id).icon .. ".jpg")
    local enemy = IconUtils:createHeadIconById({avatar = rivalData.avatar,level = 0,tp = 1,avatarFrame = rivalData["avatarFrame"], plvl = rivalData.plvl})
    enemy:setPosition(randomPos.posX, randomPos.posY)
    enemy:setScale(0.25)
    enemy:setOpacity(0)
    self._aniNode:addChild(enemy)


    local framEffectIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_quality0.png")
    framEffectIcon:setPurityColor(255, 255, 255)
    framEffectIcon:setPosition(150, 140)
    framEffectIcon:setScale(2)
    framEffectIcon:setVisible(false)
    self._aniNode:addChild(framEffectIcon)

    enemy:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.EaseOut:create(cc.MoveTo:create(0.1, cc.p(105, 100)),2),
            cc.Sequence:create(
                cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.8),2),
                cc.CallFunc:create(function()
                    framEffectIcon:setVisible(true)
                    framEffectIcon:runAction(
                        cc.Spawn:create(
                            cc.ScaleTo:create(0.2, 3),
                            cc.FadeOut:create(0.2)
                        )
                    )
                end)),
            cc.FadeIn:create(0.2)

        ),
        cc.ScaleTo:create(0.1, 1)
    ))

    local lightMc = mcMgr:createViewMC("pipeisaoguang_gezhongdun", false, true)
	lightMc:setPosition(cc.p(100,34))
	self._labelBg:addChild(lightMc)

    self._desLabel:setString("发现与您实力相仿的对手！")
end

function HeroDuelMatchView:onDestroy()
    if self._timer then
        ScheduleMgr:unregSchedule(self._timer)
        self._timer = nil
    end

    HeroDuelMatchView.super.onDestroy(self)
end

function HeroDuelMatchView:dtor()
    sfc = nil
    allTime = nil
    HeroDuelMatchView = nil
end
return HeroDuelMatchView