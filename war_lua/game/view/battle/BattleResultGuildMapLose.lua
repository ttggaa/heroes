--[[
    Filename:    BattleResultGuildMapLose.lua
    Author:      wangyan@playcrab.com
    Datetime:    2016-06-28 15:53:07
    Description: File description
--]]

local BattleResultGuildMapLose = class("BattleResultGuildMapLose", BasePopView)

function BattleResultGuildMapLose:ctor(data)
    BattleResultGuildMapLose.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
    self._battleData = data.data
    self._battleInfo = data.battleInfo
    self._star = self._result.star
    if self._star == nil then
    	self._star = 3
    end
end

function BattleResultGuildMapLose:getBgName()
    return "battleResult_bg.jpg"
end
function BattleResultGuildMapLose:onInit()
	self._touchPanel = self:getUI("touchPanel")
	self._touchPanel:setSwallowTouches(false)
	self._touchPanel:setEnabled(false)
	self:registerClickEvent(self._touchPanel, specialize(self.onQuit, self))
	-- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(true)
    end)
	self._bestOutID = nil
	
	self._bg = self:getUI("bg")
	self._tipLabel = self:getUI("bg.tipLabel")
	self._tipLabel:setVisible(false)
	self._rolePanel = self:getUI("bg.role_panel")
	
	self._roleImg = self:getUI("bg.role_panel.role_img")	
	self._roleImgShadow = self:getUI("bg.role_panel.roleImg_shadow")

	self._bgImg = self:getUI("bg.bg_img")
	self._bgImg:loadTexture("asset/bg/battleResult_flagBg.png")

    local bg_click =  self:getUI("bg_click")
    bg_click:setSwallowTouches(false)
    self._countBtn = self:getUI("bg_click.countBtn")
    self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)
    UIUtils:formatBattleResultBtnTxt(self._countBtn:getChildByFullName("nameTxt"))
    self._bg1 = self:getUI("bg.bg1")
    self._bg2 = self:getUI("bg_click.bg2")
    self._bg2:setSwallowTouches(true)
    self._title = self:getUI("bg.title")
    self._title:setScale(2)

    self:registerClickEvent(self._countBtn, specialize(self.onCount, self))

    self._title:setOpacity(0)
    self._countBtn:setOpacity(0)
    self._countBtn:setCascadeOpacityEnabled(true)

    self._bg1:setVisible(false)
    self._bg2:setVisible(false)
    self:initBloodData()

    if self._result.reward then
    	-- 人物
    	local invH = 110
	    local invW = 90
	    local beginX = invW * 0.5
	    local beginY = 220 - invH * 0.5

	    --最佳输出
		local outputID = self._battleData.leftData[1].D["id"]
	    self._lihuiId = self._battleData.leftData[1].D["id"]
	    local outputValue = self._battleData.leftData[1].damage or 0
	    local outputLihuiV = self._battleData.leftData[1].damage or 0
	    for i = 1,#self._battleData.leftData do
	    	if self._battleData.leftData[i].damage then
		        if tonumber(self._battleData.leftData[i].damage) > tonumber(outputValue) then
		            outputValue = self._battleData.leftData[i].damage
		            outputID = self._battleData.leftData[i].D["id"]
		        end
		        if tonumber(self._battleData.leftData[i].damage) > tonumber(outputLihuiV) and self._battleData.leftData[i].original then
		            outputLihuiV = self._battleData.leftData[i].damage
		            self._lihuiId = self._battleData.leftData[i].D["id"]
		        end
		    end
	    end

	    -- 物品
	    local reward = {}
	    local _reward = self._result.reward
	    for i = 1, #_reward do
	    	if _reward[i].type == "tool" then
	    		reward[#reward + 1] = _reward[i]

	    	elseif _reward[i].type == "crusading" then
	    		reward[#reward + 1] = _reward[i]
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["crusading"]
	    		reward[#reward]["num"] = _reward[i].num

	    	elseif _reward[i].type == "gold" then
	    		reward[#reward + 1] = _reward[i]
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["gold"]
	    		reward[#reward]["num"] = _reward[i].num

	    	elseif _reward[i].type == "gem" then
    			reward[#reward + 1] = _reward[i]
    			reward[#reward]["typeId"] = IconUtils.iconIdMap["gem"]
    			reward[#reward]["num"] = _reward[i].num

    		elseif _reward[i].type == "treasureCoin" then
    			reward[#reward + 1] = _reward[i]
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["treasureCoin"]
	    		reward[#reward]["num"] = _reward[i].num
	    	end
	    end
	    local itemCount = #reward
	    self._items = {}
	    local inv = 90
	    local posX = (self._bg2:getContentSize().width - itemCount*inv)/2 + inv/2
		local beginX = posX
	    for i = 1, itemCount do
	    	local sysItem = tab:Tool(reward[i].typeId)
	        local item = IconUtils:createItemIconById({itemId = reward[i].typeId, num = reward[i].num, itemData = sysItem})
	        item:setScale(2)
	        item:setAnchorPoint(0.5, 0.5)
	        item:setPosition(beginX + (i - 1) * inv, inv/2)
	        self._bg2:addChild(item)
	        item:setVisible(false)
	        self._items[i] = item
	        if sysItem.typeId == ItemUtils.ITEM_TYPE_TREASURE then
                local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)
                item:addChild(mc1, 10)
	        end
	    end
	end
	self._time = self._battleData.time

	local mcMgr = MovieClipManager:getInstance()
    self:animBegin()
end

function BattleResultGuildMapLose:onQuit()
	if self._callback then
		self._callback()
	end
end

function BattleResultGuildMapLose:onCount()
	self._viewMgr:showView("battle.BattleCountView",self._battleData,true)
end

local delaytick = {360, 380, 380}
function BattleResultGuildMapLose:animBegin()
	audioMgr:stopMusic()
	audioMgr:playSoundForce("SurrenderBattle")

	-- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

	-- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._battleData.hero1["id"]
    local isChange = false
    local lihuiId = self._lihuiId
    if curHeroId then 
        local _,newId = TeamUtils.changeArtForHeroMastery(curHeroId,self._lihuiId)
        if newId then
            self._lihuiId = newId
            isChange = true
        end
    end

    local teamData = tab:Team(self._lihuiId) 
    if teamData then
        local imgName = string.sub(teamData["art1"], 4, string.len(teamData["art1"]))
        local artUrl = "asset/uiother/team/t_"..imgName..".png"
        -- 觉醒优先
        local teamModel = self._modelMgr:getModel("TeamModel")
        local tdata,_idx = teamModel:getTeamAndIndexById(lihuiId)
        local isAwaking,_ = TeamUtils:getTeamAwaking(tdata)
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, self._lihuiId)
        -- if isAwaking then 
        --     -- 结算例会单独处理 读配置
        --     imgName = teamData.jxart2
        --     artUrl = "asset/uiother/team/"..imgName..".png"
        -- end
        artUrl = "asset/uiother/team/".. art2 ..".png"
        if  teamData["jisuan"] then
            local teamX ,teamY = teamData["jisuan"][1], teamData["jisuan"][2]
            local scale = teamData["jisuan"][3] 
            self._roleImg:setPosition(teamX ,teamY)     
            self._roleImgShadow:setPosition(teamX+2,teamY-2)
            self._roleImg:setScale(scale)
            self._roleImgShadow:setScale(scale)
        end
        self._roleImg:loadTexture(artUrl)
        self._roleImgShadow:loadTexture(artUrl) 
	end
		
	local moveDis = 450
	local posRoleX,posRoleY = self._rolePanel:getPosition()
	self._rolePanel:setPositionY(-moveDis)
	local moveRole = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	self._rolePanel:runAction(moveRole)
	
 	ScheduleMgr:delayCall(200, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local moveBg = cc.Sequence:create(cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
        self._bgImg:runAction(moveBg)
		self:animNext()
	end)

end

function BattleResultGuildMapLose:animNext()	
	-- ScheduleMgr:delayCall(delaytick[self._star], self, function()
		local animPos = self:getUI("bg.animPos")
		-- mcMgr:loadRes("commonlight", function ()
	       	local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
		        sender:gotoAndPlay(80)
		    end,RGBA8888)
		    mc1:setPosition(animPos:getPosition())
		    self._bg:addChild(mc1, 1)
    	-- end,RGBA8888)		
	-- end)

    local mc2 = mcMgr:createViewMC("shibai_commonlose", false)
    mc2:setPosition(animPos:getPosition())
    self._bg:addChild(mc2, 5)
    self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName,  26)
    self._timeLabel:setColor(cc.c3b(245, 20, 34))
    self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
    self._timeLabel:setPosition(animPos:getPositionX(), animPos:getPositionY()-72)
    self._bg:addChild(self._timeLabel, 5)
    if self._time then
    	self:labelAnimTo(self._timeLabel, 0, self._time, true)
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(2.3), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
    	self._countBtn:setEnabled(true)
    end)))
	self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(2.6), cc.CallFunc:create(function()
    	self._touchPanel:setEnabled(true)
    end)))

	if self._bg1 then
		ScheduleMgr:delayCall(100, self, function()
	    	self._bg1:setVisible(true)
	    end)
	end
    if self._battleInfo.mode==11 then
	    local battleInfo = self._battleInfo
	    local enemyBloodLess = self._result.showHurt.enemy.less
	    if enemyBloodLess<=10 and (tonumber(battleInfo.enemyInfo.lv)-tonumber(battleInfo.playerInfo.lv)>tonumber(tab:Setting("G_GUILDMAP_LESS_LV").value)) then
		    self._tipLabel:setString(lang("GUILD_MAP_LESS_2"))
		    self._tipLabel:setVisible(true)
		    return
	    end
    end

    if self._items and next(self._items) ~= nil then
    	self._title:runAction(cc.Sequence:create(
    		cc.DelayTime:create(1.5), 
    		cc.FadeIn:create(0.01),
    		cc.CallFunc:create(function()
    			local getAnim = mcMgr:createViewMC("huodedaojuguang_commonwin", false)
    			getAnim:setPosition(self._title:getPositionX(),  self._title:getPositionY() + 4)
    			self._title:getParent():addChild(getAnim, 3)
    			end),
    		cc.EaseOut:create(cc.ScaleTo:create(0.3, 1), 1.5)
    		))

	    ScheduleMgr:delayCall(1600, self, function()
	    	-- 显示获得道具
	    	if self._bg2 and self._title then 
		    	self._bg2:setVisible(true)
		    	for i = 1, #self._items do
		    		local item = self._items[i]
		    		item:setScaleAnim(false)
		    		item:runAction(cc.Sequence:create(
		    			cc.DelayTime:create(i * 0.1+0.1), 
		    			cc.CallFunc:create(function() 
		    				item:setVisible(true) 
		    				local rwdAnim = mcMgr:createViewMC("daojuguang_commonwin", false)
			    			rwdAnim:setPosition(item:getPosition())
			    			item:getParent():addChild(rwdAnim, 7)
		    				end), 
		    			cc.Spawn:create(cc.FadeIn:create(0.3), cc.ScaleTo:create(0.3, 0.78)),
		    			cc.CallFunc:create(function() 
		    				item:setScaleAnim(true) 
		    				end)))
		    	end
		    end
	    end)
	end
end

function BattleResultGuildMapLose:initBloodData()
    local mine = self:getUI("bg.bg1.mine")
	local num1 = self:getUI("bg.bg1.num1") 
	num1:setString(self._result.showHurt["self"]["surplus"])
	local dis1 = self:getUI("bg.bg1.dis1")
	dis1:setString("( -" .. self._result.showHurt["self"]["less"] .. " )")
	
	local anemy = self:getUI("bg.bg1..anemy")
    local num2 = self:getUI("bg.bg1..num2")
    num2:setString(self._result.showHurt["enemy"]["surplus"])
    local dis2 = self:getUI("bg.bg1..dis2")
	dis2:setString("( -" .. self._result.showHurt["enemy"]["less"] .. " )")

	local tips = self:getUI("bg.bg1..tips")

	local dis = math.max(num1:getContentSize().width, num2:getContentSize().width)
	dis1:setPosition(num1:getPositionX() + dis + 10, num1:getPositionY())
	dis2:setPosition(num2:getPositionX() + dis + 10, num2:getPositionY())
end

function BattleResultGuildMapLose:labelAnimTo(label, src, dest, isTime)
	audioMgr:playSound("TimeCount")
	if dest == nil then return end
	label.src = src
	label.now = src
	label.dest = dest
	label:setString(src)
	label.isTime = isTime
	label.step = 1
	label.updateId = ScheduleMgr:regSchedule(1, self, function(self, dt)
		if label:isVisible() then
			if label.isTime then
				local value = math.floor((label.dest - label.now) * 0.05)
				if value < 1 then
					value = 1
				end
				label.now = label.now + value
			else
				label.now = label.src + math.floor((label.dest - label.src) * (label.step / 50))
				label.step = label.step + 1
			end
			if math.abs(label.dest - label.now) < 5 then
				label.now = label.dest
				ScheduleMgr:unregSchedule(label.updateId)
			end
			if label.isTime then
				label:setString(formatTime(label.now))
			else
	        	label:setString(label.now)
	        end
	    end
    end)
end

function BattleResultGuildMapLose.dtor()
	BattleResultGuildMapLose = nil
end

return BattleResultGuildMapLose