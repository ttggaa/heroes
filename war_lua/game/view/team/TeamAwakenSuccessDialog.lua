--[[
    Filename:    TeamAwakenSuccessDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-23 21:17:19
    Description: File description
--]]


local TeamAwakenSuccessDialog = class("TeamAwakenSuccessDialog", BasePopView)

function TeamAwakenSuccessDialog:ctor()
    TeamAwakenSuccessDialog.super.ctor(self)
end

function TeamAwakenSuccessDialog:onInit()
    local bg1 = self:getUI("bg.layer.bg1")
    bg1:setContentSize(cc.size(1136,402))

    local bg = self:getUI("bg")
 
    local closeBtn = self:getUI("closeBtn")
    registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("team.TeamAwakenSuccessDialog")
    end)

    self._anim = {}
    for i=1,7 do
        if i == 1 then
            self._anim[i] = self:getUI("bg.layer.oldAnim")
        elseif i == 2 then
            self._anim[i] = self:getUI("bg.layer.jiantou")
        elseif i == 3 then
            self._anim[i] = self:getUI("bg.layer.newAnim")
        elseif i == 4 then
            self._anim[i] = self:getUI("bg.layer.fight")
        else -- if i == 5 then
            self._anim[i] = self:getUI("bg.layer.attrLab" .. (i - 5))
        end
        if self._anim[i] then
            self._anim[i]:setVisible(false)
        end
    end

    -- self._newSkillOpen = 0
    self._tishi = self:getUI("bg.layer.tishi")
    self._bg = self:getUI("bg")
    self._layer = self:getUI("bg.layer")
    self._bgImg = self:getUI("bg.layer.bg1")
   
    self._viewMgr:lock()
end

function TeamAwakenSuccessDialog:nextAnimFunc()
    -- audioMgr:playSound("adTitle")
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._bgW,self._bgH = bgW,bgH
  
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl 

    local animTimes = 7
    -- if userlvl < 40 then
    --     animTimes = 9
    -- end
    for i=1,animTimes do
        local des = self._anim[i]
        -- print("========", des:getName())
        ScheduleMgr:delayCall(i*120, self, function( )
            des:setVisible(true)
            des:runAction(cc.JumpBy:create(0.1,cc.p(0,0),10,1))--cc.Sequence:create(,cc.CallFunc:create(function ( )
                if i < 4 then
                    audioMgr:playSound("adIcon")
                end
                if i >= 4 and i <= 9 then
                    local mcShua = mcMgr:createViewMC("shuxingshuguang_itemeffectcollection", true, false, function (_, sender)
                        sender:removeFromParent()
                    end,RGBA8888)
                    mcShua:setPosition(cc.p(des:getContentSize().width*0.5-80, 12))
                    mcShua:setScaleY(0.8)
                    audioMgr:playSound("adTag")
                    -- mcShua:setPlaySpeed(0.2)
                    des:addChild(mcShua)
                end
                if i == animTimes then
                    self._tishi:setVisible(true)
                    self._viewMgr:unlock()
                end
        end)
    end
end


function TeamAwakenSuccessDialog:updateSmallTeam(inView, flag)
    local teamBg = inView:getChildByName("teamBg") 
    local aminBg = inView:getChildByName("aminBg")
    local sysTeam = tab:Team(self._teamId)
    local race = sysTeam["race"][1]
    if teamBg then
        if race == 107 or race == 108 then
            teamBg:loadTexture("asset/uiother/dizuo/teamBgDizuo101.png", 0)
        else
            teamBg:loadTexture("asset/uiother/dizuo/teamBgDizuo" .. race .. ".png", 0)
        end
    end

    local pos = sysTeam.xiaoren
    local teamName, art1, art2, steam = TeamUtils:getTeamAwakingTab(sysTeam, self._teamId, flag)
    local backBgNode = aminBg:getChildByName("backBgNode")
    if backBgNode then
        backBgNode:setTexture("asset/uiother/steam/"..steam..".png")
    else
        backBgNode = cc.Sprite:create("asset/uiother/steam/"..steam..".png")
        backBgNode:setAnchorPoint(cc.p(0.5, 0))
        backBgNode:setScale(0.6)
        backBgNode:setName("backBgNode")
        aminBg:addChild(backBgNode)
    end
    backBgNode:setPosition(cc.p(aminBg:getContentSize().width/2+pos[1], pos[2]-10))

    local tZZ = {
        [1] = 13,
        [2] = 14,
        [3] = 15,
    }
    local zizhi = inView:getChildByName("zizhi")
    local str = tZZ[sysTeam.zizhi]
    zizhi:setString(str)

    -- local tName = inView:getChildByName("name")
    -- tName:setString(lang(teamName))
end


function TeamAwakenSuccessDialog:reflashUI(inData)
    local oldTeamData = inData.old
    local newTeamData = inData.new

    self._teamId = newTeamData.teamId 

    -- dump(inData)
    local teamModel = self._modelMgr:getModel("TeamModel")

    -- 名称显示处理
    self._curSelectSysTeam = tab:Team(newTeamData.teamId)
    local teamName, art1, art2, art3, art4 = TeamUtils:getTeamAwakingTab(oldTeamData, oldTeamData.teamId, false)
    local sysLangName = lang(teamName)

    -- 隐藏无用的星星
    local oldSysTeam = tab:Team(oldTeamData.teamId)
    local leftBackQuality = teamModel:getTeamQualityByStage(oldTeamData.stage)

    local oldFight = self:getUI("bg.layer.fight.oldFight")
    oldFight:setString("a" .. oldTeamData.score)
    oldFight:setFntFile(UIUtils.bmfName_zhandouli)
    oldFight:setScale(0.5)

    local oldAnim = self:getUI("bg.layer.oldAnim")
    self:updateSmallTeam(oldAnim, false)
    local teamModel = self._modelMgr:getModel("TeamModel")

    if leftBackQuality[2] ~= 0 then 
        sysLangName = sysLangName .. "+" .. leftBackQuality[2]
    end
    local leftPanelName = self:getUI("bg.layer.oldAnim.name")
    leftPanelName:setColor(cc.c3b(17,132,239))
    leftPanelName:setFontSize(20)
    leftPanelName:setString(sysLangName)
    leftPanelName:setColor(UIUtils.colorTable["ccColorQuality" .. leftBackQuality[1]])


    local leftAttrTipLab0 = self:getUI("bg.layer.attrLab0.leftAttrTipLab")
    leftAttrTipLab0:setString(lang("ATTR_999").. "：")

    local leftAttrTipLab1 = self:getUI("bg.layer.attrLab1.leftAttrTipLab")
    leftAttrTipLab1:setString(lang("ATTR_93").. "：")

    local leftAttrTipLab2 = self:getUI("bg.layer.attrLab2.leftAttrTipLab")
    leftAttrTipLab2:setString(lang("ATTR_94").. "：") 
   
    local leftAttrLab0 = self:getUI("bg.layer.attrLab0.leftAttrLab")
    local posStr = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(oldTeamData)
    leftAttrLab0:setString(posStr) 

    local aLvl = oldTeamData.aLvl
    if aLvl <= 0 then
        aLvl = 1
    end
    if aLvl >= 6 then
        aLvl = 6
    end
    local attr = oldSysTeam.atkadd[oldTeamData.star]
    local leftAttrLab1 = self:getUI("bg.layer.attrLab1.leftAttrLab")
    leftAttrLab1:setString(TeamUtils.getNatureNums(attr)) 

    local hpattr = oldSysTeam.hpadd[oldTeamData.star]
    local leftAttrLab2 = self:getUI("bg.layer.attrLab2.leftAttrLab")
    leftAttrLab2:setString(TeamUtils.getNatureNums(hpattr))


    local teamName, art1, art2, art3, art4 = TeamUtils:getTeamAwakingTab(newTeamData, newTeamData.teamId, false)
    local sysLangName = lang(teamName)
    local newAnim = self:getUI("bg.layer.newAnim")
    self:updateSmallTeam(newAnim, true)

    local rightBackQuality = teamModel:getTeamQualityByStage(newTeamData.stage)
    if rightBackQuality[2] ~= 0 then 
        sysLangName = sysLangName .. "+" .. rightBackQuality[2]
    end

    local newFight = self:getUI("bg.layer.fight.newFight")
    newFight:setString("a" .. newTeamData.score)
    newFight:setFntFile(UIUtils.bmfName_zhandouli)
    newFight:setScale(0.5)
    
    local rightPanelName = self:getUI("bg.layer.newAnim.name")
    rightPanelName:setColor(UIUtils.colorTable["ccColorQuality" .. rightBackQuality[1]])
    rightPanelName:setString(sysLangName)

    local newSysTeam = tab:Team(newTeamData.teamId)
    local aLvl = newTeamData.aLvl
    if aLvl <= 0 then
        aLvl = 1
    end
    if aLvl >= 6 then
        aLvl = 6
    end
    local rightAttrLab0 = self:getUI("bg.layer.attrLab0.rightAttrLab")
    local posStr = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(newTeamData)
    rightAttrLab0:setString(posStr)

    local attr = newSysTeam.atkadd[newTeamData.star] + newSysTeam.atktalent[aLvl]
    local rightAttrLab1 = self:getUI("bg.layer.attrLab1.rightAttrLab")
    rightAttrLab1:setString(TeamUtils.getNatureNums(attr))

    local hpattr = newSysTeam.hpadd[newTeamData.star] + newSysTeam.hptalent[aLvl]
    local rightAttrLab2 = self:getUI("bg.layer.attrLab2.rightAttrLab")
    rightAttrLab2:setString(TeamUtils.getNatureNums(hpattr)) 

    local sizeSchedule
    local step = 0.5
    local stepConst = 30
    local bg1Height = 150 
    self.bgWidth = 1136   
    
    local maxHeight = 390 --self._bgImg:getContentSize().height
    print(self._bgImg:getContentSize().height,"=======self._bgImg:getContentSize().height=========maxHeight========",maxHeight)
    self._bgImg:setOpacity(0)
    self._layer:setVisible(false)
    self._bgImg:setPositionX(self._layer:getContentSize().width*0.5)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))  
    self:animBegin(function( )
        self._bgImg:setOpacity(255)
        self._layer:setVisible(true) 
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))                   
            else
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner() 
                self:nextAnimFunc()            
            end
        end)
    end)
end

function TeamAwakenSuccessDialog:animBegin(callback)
    -- -- 播放获得音效
    -- audioMgr:playSound("ItemGain_1")
    --升星成功
    self:addPopViewTitleAnim(self._bg, "juexingchenggong_juexingchenggong", 560, 465)
    -- self:addPopViewTitleAnim(self._bg, "shengxingchenggong_huodetitleanim", 568, 480)

    ScheduleMgr:delayCall(400, self, function( )
        if self._bg then                    
            --震屏
            -- UIUtils:shakeWindow(self._bg)
            -- ScheduleMgr:delayCall(200, self, function( )
            if callback and self._bg then
                callback()
            end
            -- end)
        end
    end)
   
end


-- 弹出悬浮窗（如：获得物品）title动画
function TeamAwakenSuccessDialog:addPopViewTitleAnim(view,mcName,x,y)
    local mcStar = mcMgr:createViewMC( mcName, false, false, function (_, sender)

    end,RGBA8888)

    local children = mcStar:getChildren()
    for k,v in pairs(children) do
        if k == 2 then
            local _children = v:getChildren()
            for kk,vv in pairs(_children) do
                -- vv:setSpriteFrame("TeamAwakenImageUI_img25.png")
            end
        end
    end
    mcStar:addCallbackAtFrame(84, function()
        mcStar:gotoAndPlay(35)
    end)
    mcStar:setPosition(x,y+35)
    view:addChild(mcStar,99)

    mcStar:addCallbackAtFrame(6,function( )
        local mc = mcMgr:createViewMC("caidai_huodetitleanim", false, false, function (_, sender)
        --sender:gotoAndPlay(80)
        end,RGBA8888)
        -- mc:setPlaySpeed(1)
        mc:setPosition(cc.p(x,y))
        view:addChild(mc,100)
                 
        local mc1bg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888)
        mc1bg:setPlaySpeed(1)
        mc1bg:setScale(1.5)

        local clipNode2 = cc.ClippingNode:create()
        clipNode2:setPosition(x,y+45)
        local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
        mask:setScale(2.5)
        mask:setPosition(0,147)
        clipNode2:setStencil(mask)
        clipNode2:setAlphaThreshold(0.5)
        mc1bg:setPositionY(-10)
        clipNode2:addChild(mc1bg)
        view:addChild(clipNode2,-1)
        UIUtils:shakeWindow(view)
    end) 
end

function TeamAwakenSuccessDialog:getMaskOpacity()
    return 230
end

return TeamAwakenSuccessDialog