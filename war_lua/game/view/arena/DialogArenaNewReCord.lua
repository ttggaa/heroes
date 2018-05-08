--[[
    Filename:    DialogArenaNewReCord.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-11-02 16:09:41
    Description: File description
--]]

local DialogArenaNewReCord = class("DialogArenaNewReCord",BasePopView)
function DialogArenaNewReCord:ctor(param)
    self.super.ctor(self)
    param = param or {}
    self._callback = param.callback 
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogArenaNewReCord:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        if self._callback then
            self._callback()
        end
        self:close(true)
        -- self._viewMgr:popView()
        UIUtils:reloadLuaFile("arena.DialogArenaNewReCord")
    end)
    self._bg = self:getUI("bg.desBg")
    local des3 = self:getUI("bg.des3")  
    des3:setCascadeColorEnabled(false) 
    des3:setColor(cc.c3b(250, 224, 188)) 
    local diamondImg = self:getUI("bg.des3.diamondImg")    
    local scaleNum = math.floor((32/diamondImg:getContentSize().width)*100)
    diamondImg:setScale(scaleNum/100)
    self._diamondNum = self:getUI("bg.des3.diamondNum")
    self._title = self:getUI("bg.title")
    -- self._title:loadTexture("title_lishixingao.png",1)
    -- self._rank = self:getUI("bg.desBg.rank")
    self._topRank = self:getUI("bg.topRankBmp")
    self._topRank:setVisible(false)
    self._topRank:setFntFile(UIUtils.bmfName_arena_newrecord)

    self._rank = self:getUI("bg.des2.rankBmp")
    self._rank:setFntFile(UIUtils.bmfName_paiming)
    self._upNum = self:getUI("bg.des2.upNum")
    self._upArrow = self:getUI("bg.des2.upArrow")
    self._upArrow:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(0.5,cc.p(0,5)),
            cc.MoveBy:create(0.5,cc.p(0,-5))
        )
    ))

    self._des4 = self:getUI("bg.des4")
    self._closeBtn = self:getUI("bg.closeBtn")
    self._closeBtn:setTitleText("确定")
    -- self._topRank = self:getUI("bg.desBg.topRank")

end

-- 接收自定义消息
function DialogArenaNewReCord:reflashUI(data)
	local award = data.award
	local arena = self._modelMgr:getModel("ArenaModel"):getArena()
	self._diamondNum:setString(award.gem or 0)

    local rank = data.rank or 0
	local preHRank = data.preHRank or 0
    self._preHRank = preHRank
    self._newHRank = rank
    self._rank:setString(rank)
    self._topRank:setString(preHRank)
    self._upNum:setString(math.abs(rank -preHRank))
    -- self._upArrow:setPositionX(self._rank:getPositionX()+self._rank:getContentSize().width+20)
    -- self._upNum:setPositionX(self._upArrow:getPositionX()+self._upArrow:getContentSize().width+5)
    local des2PosX = self._topRank:getPositionX()+self._topRank:getContentSize().width+10
    -- print("des2PosX",des2PosX)
    self:getUI("bg.des2"):setPositionX(des2PosX)
    self._callback = data.callback

     for i=1,4 do
        local des = self:getUI("bg.des" .. i)
        des:setVisible(false)
    end
    local des1 = self:getUI("bg.des1")
    des1:setColor(cc.c3b(245, 234, 93))
    des1:enable2Color(1,cc.c4b(221, 161, 63, 255))
    local desRank = self:getUI("bg.des2.desRank")
    desRank:setColor(cc.c3b(245, 234, 93))
    desRank:enable2Color(1,cc.c4b(221, 161, 63, 255))
    self._closeBtn:setVisible(true)
    self._closeBtn:setOpacity(0)

    local maxHeight = 230
    local step = 0.5
    local stepConst = 15
    self.bgWidth,self.bgHeight = self._bg:getContentSize().width,self._bg:getContentSize().height/2
    self._bg:setContentSize(cc.size(self.bgWidth,self.bgHeight))
    local sizeSchedule
    self._bg:setOpacity(0)
    self:animBegin(function( )
        self._bg:setOpacity(255)
        sizeSchedule = ScheduleMgr:regSchedule(10,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            self.bgHeight = self.bgHeight+stepConst
            if self.bgHeight < maxHeight then
                self._bg:setContentSize(cc.size(self.bgWidth,self.bgHeight))
            else
                self._bg:setContentSize(cc.size(self.bgWidth,200))
                self._bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
                local mcMgr = MovieClipManager:getInstance()
                -- mcMgr:loadRes("intancenopen", function ()
                    self:addDecorateCorner()
                -- end,RGBAUTO)
            end
        end)
    end)
end

function DialogArenaNewReCord:animBegin(callback)
    audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
    self:addPopViewTitleAnim(self:getUI("bg"), "lishixingao_huodetitleanim", 480, 420)
    ScheduleMgr:delayCall(400, self, function( )
        if callback and self._bg then
            callback()
            for i=1,4 do
                local des = self:getUI("bg.des" .. i)
                ScheduleMgr:delayCall(i*320, self, function( )
                    if des then 
                        if i ~= 2 then
                            des:setVisible(true)
                        end
                        des:runAction(cc.JumpBy:create(0.1,cc.p(0,0),10,1))--cc.Sequence:create(,cc.CallFunc:create(function ( ) 
                    end
                    if i == 1 then
                        self._topRank:setVisible(true)
                        self:runNumAnim()
                    end
                    if self._closeBtn and self._bg then
                        if i == 4 then
                            self._closeBtn:runAction(cc.FadeIn:create(0.2))
                        else
                            -- audioMgr:playSound("adTag")
                            -- local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
                            --     sender:removeFromParent()
                            -- end,RGBA8888)
                            -- mcShua:setPosition(cc.p(bgW/2-80,des:getPositionY()-bgH-25-100))
                            -- -- mcShua:setPlaySpeed(0.2)
                            -- self._bg:addChild(mcShua)
                        end
                    end
                    -- end)))
                end)
            end
        end
    end)
    
    -- local mc1 = mcMgr:createViewMC("shengxingjinjiechenggong_teamsuccess", false, false)
    -- mc1:setName("anim1")
    -- mc1:setPosition(cc.p(self._title:getPositionX(), self._title:getPositionY()-250))
    -- self._bg:addChild(mc1,-1)
    -- self._title:setOpacity(0)
    -- self._title:setScale(4)
    -- self._title:runAction(cc.Spawn:create(cc.FadeIn:create(0.2),cc.ScaleTo:create(0.2,0.9),cc.ScaleTo:create(0.3,1)))                  
end

function DialogArenaNewReCord:runNumAnim( )
    local finalNum = self._newHRank 
    local beginNum = self._preHRank
    local deltNum = beginNum-finalNum
    local scrollNum = beginNum
    local step = 1
    if deltNum > 10 then
        step = math.floor(deltNum/10)
    end
    self._topRank:setVisible(true)
    self._topRank:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(0.05),
        cc.CallFunc:create(function( )
            scrollNum = scrollNum - step 
            if scrollNum <= finalNum then
                self._topRank:stopAllActions()
                self._topRank:setString(finalNum)
                local des2PosX = self._topRank:getPositionX()+self._topRank:getContentSize().width+10
                self:getUI("bg.des2"):setPositionX(des2PosX)
                self:getUI("bg.des2"):setVisible(true)
            else
                self._topRank:setString(scrollNum)
            end
        end)
    )))
end

return DialogArenaNewReCord