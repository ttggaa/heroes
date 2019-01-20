--[[
 	@FileName 	TeamExclusiveUpSuccessDialog.lua
	@Authors 	yuxiaojing
	@Date    	2018-08-22 10:52:49
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local TeamExclusiveUpSuccessDialog = class("TeamExclusiveUpSuccessDialog", BasePopView)

function TeamExclusiveUpSuccessDialog:ctor( params )
	self.super.ctor(self)
	params = params or {}
	self._oldFightNum = params.oldFightNum
	self._teamData = params.teamData
    self._callback = params.callback
end

function TeamExclusiveUpSuccessDialog:onInit(  )

	self:registerClickEventByName("Panel", function ()
        ScheduleMgr:nextFrameCall(self, function()
            if self._callback then
                self._callback()
            end
            self:close()
        end)
    end)

	self._panel = self:getUI("Panel")
    self._bg = self:getUI('Panel.bg')
    self._left = self:getUI('leftbg')
    self._right = self:getUI('rightbg')
    self._infoPanel = self:getUI('Panel.Panel1')

    self._panel:setTouchEnabled(false)

    self._bg:setOpacity(0)
    self._left:setVisible(false)
    self._right:setVisible(false)
    self._left:runAction(cc.MoveTo:create(0.1, cc.p(0, 0)))
    self._right:runAction(cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH, 0)))

    self._curStarLevel = (self._teamData.zStar or 0) - 1
	self._exclusiveData = tab.exclusive[self._teamData.teamId]

    self:updateView()

    local animName = "shengxingchenggong_huodetitleanim"
    if self._curStarLevel == 0 then
    	animName = "huanxingchenggong_huanxingchenggong"
    end
    audioMgr:playSound("ItemGain_1")
    self:addPopViewTitleAnim(self._panel, animName, self._panel:getContentSize().width / 2, 460)

    local bgHeight = 350
    local maxHeight = self._bg:getContentSize().height + 12
    ScheduleMgr:delayCall(500, self, function( )
    	self._bg:setContentSize(cc.size(self._bg:getContentSize().width, bgHeight))
    	self._bg:setOpacity(255)
    	local sizeSchedule
    	local step = 0.5
        local stepConst = 30
        sizeSchedule = ScheduleMgr:regSchedule(1, self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bgHeight = bgHeight + stepConst
            if bgHeight < maxHeight then
                self._bg:setContentSize(cc.size(self._bg:getContentSize().width, bgHeight))
            else
                self._bg:setContentSize(cc.size(self._bg:getContentSize().width, maxHeight))
                self._bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 1, 1.05),cc.ScaleTo:create(0.1, 1, 1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
            	self:showView()
            end
        end)
    end)
end

function TeamExclusiveUpSuccessDialog:showView(  )
	self._left:setVisible(true)
    self._right:setVisible(true)
    self._left:runAction(cc.MoveTo:create(0.3, cc.p(self._left:getContentSize().width / 2, self._left:getContentSize().height / 2)))
    self._right:runAction(cc.MoveTo:create(0.3, cc.p(MAX_SCREEN_WIDTH - self._right:getContentSize().width / 2, self._right:getContentSize().height / 2)))

    for i = 1, #self._activeList do
        local panel = self._activeList[i]
        ScheduleMgr:delayCall(i * 200, self, function (  )
            if not panel or tolua.isnull(panel) then return end
            panel:setVisible(true)
            local spawn = cc.Spawn:create(cc.JumpBy:create(0.1,cc.p(0,0),10,1))
            panel:runAction(spawn)
            if i >= 3 and i <= 5 then
                audioMgr:playSound("adTag")
            end
        end)
    end
    if self._curStarLevel >= 1 then
        ScheduleMgr:delayCall(800, self, function (  )
            local parent = self._infoPanel:getChildByFullName("star_bg.star" .. self._curStarLevel)
            local increaseMc = mcMgr:createViewMC("bingtuanzhuanshuxingxing_bingtuanzhuanshuxingxing", false, true, function (  )
                parent:loadTexture("globalImageUI6_star3.png", 1)
            end)
            increaseMc:setPosition(parent:getContentSize().width / 2, parent:getContentSize().height / 2 - 0.5)
            parent:addChild(increaseMc, 99)
        end)
    end

    ScheduleMgr:delayCall(#self._activeList * 200, self, function (  )
        self._panel:setTouchEnabled(true)
    end)
end

function TeamExclusiveUpSuccessDialog:updateView(  )
    self._activeList = {}

    local iconBg = self._infoPanel:getChildByFullName("iconBg")
    local mc1bg = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
        sender:gotoAndPlay(0)
    end,RGBA8888)
    mc1bg:setPosition(iconBg:getContentSize().width*0.5, iconBg:getContentSize().height*0.5)
    mc1bg:setPlaySpeed(1)
    iconBg:addChild(mc1bg)

    local artName = self._exclusiveData.art1 or "pic_artifact_30"
    if self._curStarLevel >= 0 then
        artName = self._exclusiveData.art2 or "pic_artifact_31"
    end

    local artImg = iconBg:getChildByFullName("artImg")
    if artImg then
        artImg:removeFromParent()
    end
    if self._curStarLevel < 0 then
        local artName = self._exclusiveData.art1 or "pic_artifact_30"
        artImg = ccui.ImageView:create()
        artImg:setName("artImg")
        artImg:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        artImg:loadTexture(artName .. ".png", 1)
        iconBg:addChild(artImg)
    else
        artImg = mcMgr:createViewMC(self._exclusiveData.art2, true, false)
        artImg:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height / 2)
        artImg:setName("artImg")
        iconBg:addChild(artImg)
    end

    -- iconBg:setOpacity(0)
    -- iconBg:setCascadeOpacityEnabled(true)
    iconBg:setVisible(false)
    table.insert(self._activeList, iconBg)

	local qualityType = self._exclusiveData.type or 1
	local nameLab = self._infoPanel:getChildByFullName("name")
	nameLab:setString(lang(self._exclusiveData.name))
	nameLab:setColor(TeamUtils.exclusiveNameColorTab[qualityType].color)
	nameLab:enable2Color(1, TeamUtils.exclusiveNameColorTab[qualityType].color2)

    nameLab:setVisible(false)
    table.insert(self._activeList, nameLab)

	local starBg = self._infoPanel:getChildByFullName("star_bg")
    local starLevel = self._curStarLevel
    if starLevel >= 1 then
        starLevel = starLevel - 1
    end
	for i = 1, 6 do
		starBg:getChildByFullName("star" .. i):loadTexture(i <= starLevel and "globalImageUI6_star3.png" or "globalImageUI6_star4.png", 1)
	end

    starBg:setVisible(false)
    table.insert(self._activeList, starBg)

	local fightInfo = self._infoPanel:getChildByFullName("fightInfo")
	local fightLab = ccui.TextBMFont:create('a' .. self._oldFightNum, UIUtils.bmfName_zhandouli_little)
    fightLab:setAnchorPoint(cc.p(0.5, 0))
    fightLab:setScale(0.47)
    fightLab:setName("fightLab")
    fightLab:setPosition(120, 10)
    fightInfo:addChild(fightLab)

    local fightLab1 = ccui.TextBMFont:create('a' .. self._teamData.score, UIUtils.bmfName_zhandouli_little)
    fightLab1:setAnchorPoint(cc.p(0.5, 0))
    fightLab1:setScale(0.47)
    fightLab1:setName("fightLab1")
    fightLab1:setPosition(350, 10)
    fightInfo:addChild(fightLab1)

    fightInfo:setVisible(false)
    table.insert(self._activeList, fightInfo)

    local desPanel = self._infoPanel:getChildByFullName("desPanel")
    local scrollView = self._infoPanel:getChildByFullName("desPanel.ScrollView")
    local minHeight = scrollView:getContentSize().height
    local tLabel = {text = lang(self._exclusiveData.effectdes[self._curStarLevel + 1]), fontsize = 21, color = cc.c4b(250, 229, 200, 255), width = scrollView:getContentSize().width - 10, anchorPoint = ccp(0, 0)}
    local text = UIUtils:createMultiLineLabel(tLabel)
    local innerH = text:getContentSize().height
    text:setPosition(0, 0)
    if innerH < minHeight then
        text:setPosition(0, minHeight - innerH)
        innerH = minHeight
    end
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, innerH))
    scrollView:addChild(text)

    desPanel:setVisible(false)
    table.insert(self._activeList, desPanel)

    local touchLab = self._infoPanel:getChildByFullName("touchLab")
    touchLab:setVisible(false)
    table.insert(self._activeList, touchLab)
end

return TeamExclusiveUpSuccessDialog