--[[
    Filename:    MagicInView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-10-28 19:40:16
    Description: File description
--]]

local MagicInView = class("MagicInView",BaseView)
function MagicInView:ctor()
    MagicInView.super.ctor(self)
    self.initAnimType = 2
end
function MagicInView:getAsyncRes()
    return 
    {
        {"asset/ui/magic.plist", "asset/ui/magic.png"}
    }
end

function MagicInView:getBgName()
    return "bg_007.jpg"
end

function MagicInView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{title = "magicImg_title.png",titleTxt = "学院"})
    -- self._viewMgr:showNavigation("global.UserInfoView",{hideInfo=true,hideHead=true})
end

-- 初始化UI后会调用, 有需要请覆盖
function MagicInView:onInit()
    -- 通用动态背景
    self:addAnimBg()
    self._scrollView = self:getUI("bg.scrollView")
    -- self._scrollView:setBounceEnabled(true)
    self._hole1 = self:getUI("bg.scrollView.hole1")
    self._hole1.pointIcon = self._hole1:getChildByFullName("pointIcon")
    self._hole1.pointIcon:setVisible(false)
    self._hole1:setScaleAnimMin(0.9)
    local talentEnable = SystemUtils["enableTalent"]()
    -- if talentEnable then
    --     if not self._modelMgr:getModel("ArenaModel"):getArena() then
    --         ScheduleMgr:nextFrameCall(self,function( )
    --             ServerManager:getInstance():sendMsg("ArenaServer", "enterArena", {}, true, {}, function(result)
    --             end,function( )
    --             end)
    --             local arenaShopD = self._modelMgr:getModel("ArenaModel"):getArenaShop().shop1
    --             if not arenaShopD then
    --                 ServerManager:getInstance():sendMsg("ArenaServer", "enterArenaShop", {}, true, {}, function(result)
    --                 end)
    --             end
    --         end)
    --     end
    -- end

    self:registerClickEvent(self._hole1,function() 
        if talentEnable then
            self._viewMgr:showView("talent.TalentView")
        else
            local systemOpenTip = tab.systemOpen["Talent"][3]
            if not systemOpenTip then
                self._viewMgr:showTip(tab.systemOpen["Talent"][1] .. "级开启")
            else
                self._viewMgr:showTip(lang(systemOpenTip))
            end
        end
    end)
    self:isLocked(self._hole1,not talentEnable,lang(tab.systemOpen["Talent"][3]) or tab.systemOpen["Talent"][1] .. "级开启")
    -- UIUtils:setGray(self._hole1,not talentEnable)

    self._hole2 = self:getUI("bg.scrollView.hole2")
    self._hole2:setScaleAnimMin(0.9)
    self._hole2.pointIcon = self._hole2:getChildByFullName("pointIcon")
    self._hole2.pointIcon:setVisible(false)
    -- local hole2Img = self._hole2:getChildByName("img")
    -- UIUtils:setGray(hole2Img,not openLeague)
    -- isOpen,openDes = false,"暂未开启"
    -- isOpen = true
    local boostEnable = SystemUtils["enableTeamBoost"]()
    self:isLocked(self._hole2,not boostEnable, "玩家等级" .. tab.systemOpen["TeamBoost"][1] .. "开启")
    -- self:isLocked(self._hole2,not boostEnable,lang(tab.systemOpen["TeamBoost"][3]) or tab.systemOpen["TeamBoost"][1] .. "级开启")

    self:registerClickEvent(self._hole2,function() 
        -- if true then
        if boostEnable then
            -- self._viewMgr:showView("teamboost.TeamBoostView")
        else
            local systemOpenTip = tab.systemOpen["TeamBoost"][3]
            if not systemOpenTip then
                self._viewMgr:showTip(tab.systemOpen["TeamBoost"][1] .. "级开启")
            else
                self._viewMgr:showTip(lang(systemOpenTip))
            end
        end
    end)

    

    self._hole3 = self:getUI("bg.scrollView.hole3")
    -- UIUtils:setGray(self._hole3,true)
    self._hole3:setCascadeOpacityEnabled(true)
    self._hole3:setOpacity(0)
    -- for i=1,3 do
    --  self["_hole" .. i]:setSwallowTouches(true)
    -- end

    self:reflashUI()
    -- self:listenReflash("TeamModel", self.reflashUI)
    -- self:listenReflash("TalentModel", self.reflashUI)
    -- self:listenReflash("PlayerTodayModel", self.reflashUI)
end

function MagicInView:isLocked( node,lock,lockDes )
    local lockbg = node:getChildByFullName("lockbg")
    if not lockbg then return end
    local des = lockbg:getChildByFullName("des")
    des:enableOutline(cc.c4b(0, 0, 0, 128),2)
    des:setString(lockDes or "")

    UIUtils:setGray(node,lock)
    -- -- img:setColor(color)
    -- -- node:setBrightness(-10)
 --    img:setContrast(lock and -10 or 0)
    -- img:setHue(lock and 20 or 0)
    -- img:setSaturation(lock and -90 or 0)
    node:setBrightness(lock and -10 or 0)
    lockbg:setVisible(lock)
    lockbg:setHue(-10)
    lockbg:setSaturation(80)
end
-- 第一次进入调用, 有需要请覆盖
function MagicInView:onShow()


end

function MagicInView:onTop()
    self:reflashUI()
end

-- 接收自定义消息
function MagicInView:reflashUI()
    -- local arenaModel = self._modelMgr:getModel("ArenaModel")
    -- local newReport = self._modelMgr:getModel("PlayerTodayModel").newArenaReport
    -- local formationModel = self._modelMgr:getModel("FormationModel")
    -- local isFormationFull = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeArenaDef)
    if self._modelMgr:getModel("TalentModel"):checkTalentPopTip() == true then
        self._hole1.pointIcon:setVisible(true)
    else
        self._hole1.pointIcon:setVisible(false)
    end

    print("=========++++++++")
    local teamModel = self._modelMgr:getModel("TeamModel")
    if teamModel:isTeamBoostTip() == true then
       self._hole2.pointIcon:setVisible(true)
    else
       self._hole2.pointIcon:setVisible(false)
    end
end

function MagicInView:beforePopAnim()
    MagicInView.super.beforePopAnim(self)
    -- for i=1,2 do
    --     self["_hole" .. i]:setCascadeOpacityEnabled(true, true)
    --     self["_hole" .. i]:setOpacity(0)
    --     self["_hole" .. i]:setScaleAnim(true)
    --     local lockbg = self["_hole" .. i]:getChildByName("lockbg")
    --     if lockbg then
    --         -- lockbg:setCascadeOpacityEnabled(true)
    --         lockbg:setOpacity(0)
    --     end
    -- end
end
-- 重载出现动画
function MagicInView:popAnim(callback)
    -- 执行父节点动画
    MagicInView.super.popAnim(self,callback)
    -- 定义自己动画
    local delayTime = 0.1
    local moveTime = 0.1
    local springTime = 0.2
    local fadeInTime = 0.1
    local moveDis = 200
    local springDis = 10
    for i=1,2 do
        local hole = self["_hole" .. i]
        local holeInitPos = cc.p(hole:getPositionX(),hole:getPositionY())
        local holeSpringPos = cc.p(hole:getPositionX()-springDis,hole:getPositionY())
        local holebeginPos = cc.p(hole:getPositionX()+moveDis,hole:getPositionY())
        hole:setPosition(holebeginPos)
        local holeDelayTime = delayTime*(i-1)
        local delayAct = cc.DelayTime:create(holeDelayTime)
        local spawn = cc.Spawn:create(cc.MoveTo:create(moveTime,holeSpringPos),cc.FadeIn:create(fadeInTime))
        local seq = cc.Sequence:create(delayAct,spawn,cc.MoveTo:create(springTime,holeInitPos))
        self["_hole" .. i]:runAction(seq)
        local lockbg = self["_hole" .. i]:getChildByName("lockbg")
        -- if lockbg then
        --     lockbg:runAction(cc.FadeIn:create(fadeInTime))
        -- end
    end
end

function MagicInView:onDestroy( )
    if self._leagueOpenSch then
        ScheduleMgr:unregSchedule(self._leagueOpenSch)
        self._leagueOpenSch = nil 
    end
    if self._daySche then
        ScheduleMgr:unregSchedule(self._daySche)
        self._daySche = nil 
    end
    MagicInView.super.onDestroy(self)
end
return MagicInView