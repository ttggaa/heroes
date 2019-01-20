--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--[[
    FileName:       BattleResultGloryArena
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-16 11:27:25
    Description:
]]

local BattleResultGloryArena = class("BattleResultGloryArena", BasePopView)

function BattleResultGloryArena:ctor(data)
    self.super.ctor(self)
    self._result = data.result
    self._callback = data.callback
	self._battleType = data.battleType
    self._battleInfo = data.result
    self._star = self._result.star
    self._bIsPlayBack = data._bIsPlayBack
    if self._star == nil then
    	self._star = 3
    end
end


-- 渲染时会调用, 改变元件坐标在这里
function BattleResultGloryArena:onAdd()

end

--获取打开UI的时候加载的资源
function BattleResultGloryArena:getAsyncRes()
    return 
         {
            {"asset/ui/gloryArenaResult.plist", "asset/ui/gloryArenaResult.png"},
--            {"asset/ui/battle4.plist", "asset/ui/battle4.png"},
            {"asset/ui/battle.plist", "asset/ui/battle.png"},
            
         }
end

function BattleResultGloryArena:getBgName()
    return "battleResult_bg.jpg"
end

local childName = {
    {name = "bg", childName = "bg"},
    {name = "role_panel", childName = "touchPanel_lay.role_panel"},
    {name = "roleImg_shadow", childName = "touchPanel_lay.role_panel.roleImg_shadow"},
    {name = "role_img", childName = "touchPanel_lay.role_panel.role_img"},
    {name = "bg_img", childName = "bg.bg_img"},
    {name = "ranktile_lab", childName = "bg.ranktile_lab"},
    {name = "rankPos_lab", childName = "bg.ranktile_lab.rankPos_lab"},
    {name = "animPos", childName = "bg.animPos"},
    {name = "title", childName = "bg.title"},
    {name = "bg2", childName = "bg.bg2"},

--    {name = "des_lab", childName = "bg.des_lab"},
    {name = "countBtn", childName = "touchPanel_lay.countBtn", isBtn = true},
    {name = "result_lay", childName = "bg.result_lay"},
    {name = "result_bg", childName = "bg.result_lay.result_bg", starNum = 1, endNum = 3},
    {name = "playBack_btn", childName = "touchPanel_lay.playBack_btn", isBtn = true},
    {name = "bg_1", childName = "touchPanel_lay.bg_1"},
    {name = "bg_2", childName = "bg.bg_2"},
    {name = "bg_2_des", childName = "bg.bg_2.des"},
    {name = "bg_2_des1", childName = "bg.bg_2.des1"},
    {name = "bg_2_rank", childName = "bg.bg_2.rank"},
    {name = "bg_2_upArrow", childName = "bg.bg_2.upArrow"},
    {name = "touchPanel_lay", childName = "touchPanel_lay"},
    
    {name = "play_btn", childName = "touchPanel_lay.bg_1.play_btn", starNum = 1, endNum = 3},
}

function BattleResultGloryArena:onRewardCallback(_, _x, _y, sender)
    if sender == nil or self._childNodeTable == nil then
        return 
    end

    if sender:getName() == "playBack_btn" then
        --回看
        self._childNodeTable.bg_1:setVisible(not self._childNodeTable.bg_1:isVisible())
    elseif sender:getName() == "countBtn" then
        --统计
        self._viewMgr:showView("battle.BattleCountView",self._battleInfo,true)
    end
end

--战斗回放
function BattleResultGloryArena:playBackBattle(result,data,isMeAtk)
    if result == nil then
        return
    end
    local left 
	local right 
    left  = BattleUtils.jsonData2lua_battleData(result.atk)
    right = BattleUtils.jsonData2lua_battleData(result.def)
    BattleUtils.disableSRData()
    
    BattleUtils.enterBattleView_GloryArena(left, right, result.r1, result.r2, false,
        function(info, callback)
            -- 战斗结束
            callback(info)
        end,
        function (info)
            -- 退出战斗
        end, false, not isMeAtk
    )
end

--初始化逻辑,这个时候只是把资源，背景，csb等创建好了
function BattleResultGloryArena:onInit()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    
    if self._childNodeTable == nil then
        return
    end

--    self:disableTextEffect()
--    dump(self._battleInfo)
    if self._battleInfo.win then
--        self._battleInfo._rank = 1
--        self._battleInfo._enemyRank = 100
        local rank = (self._battleInfo._rank or 0) - (self._battleInfo._enemyRank or 0)
        if rank < 0 then
            
            if self._battleInfo.change and self._battleInfo.change == 0 then
                self._childNodeTable.bg_2_rank:setVisible(false)
                self._childNodeTable.bg_2_upArrow:setVisible(false)
                self._childNodeTable.bg_2_des:setString("您在战斗中已经罕逢对手")
                self._childNodeTable.bg_2_des1:setString("您的竞技排名未发生变化")
                self._childNodeTable.bg_2_des1:setPositionX(self._childNodeTable.bg_2_des:getPositionX())
            else
                self._childNodeTable.bg_2_rank:setVisible(true)
                self._childNodeTable.bg_2_upArrow:setVisible(true)
                self._childNodeTable.bg_2_rank:setString(self._battleInfo._rank .."(   " .. math.abs(rank) .. ")")
                self._childNodeTable.bg_2_upArrow:setAnchorPoint(cc.p(0, 0.5))
                self._childNodeTable.bg_2_upArrow:setPositionX(self._childNodeTable.bg_2_des1:getPositionX() + (string.len(tostring(self._battleInfo._rank))) * 16 + self._childNodeTable.bg_2_des1:getContentSize().width / 2 + 10)
            end
        else
            self._childNodeTable.bg_2_rank:setVisible(false)
            self._childNodeTable.bg_2_upArrow:setVisible(false)
            self._childNodeTable.bg_2_des1:setString("您的竞技排名未发生变化")
            self._childNodeTable.bg_2_des1:setPositionX(self._childNodeTable.bg_2_des:getPositionX())
        end
        
    else
        self._childNodeTable.bg_2_rank:setVisible(false)
        self._childNodeTable.bg_2_upArrow:setVisible(false)
        self._childNodeTable.bg_2_des:setString("您的军队惨遭失败，")
        self._childNodeTable.bg_2_des1:setString("您的竞技排名未发生变化")
        self._childNodeTable.bg_2_des1:setPositionX(self._childNodeTable.bg_2_des:getPositionX())
    end
    self._childNodeTable.touchPanel_lay:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))

    self._childNodeTable.bg:setEnabled(true)
    self._touchPanel = self._childNodeTable.bg
    self:registerClickEvent(self._childNodeTable.touchPanel_lay, specialize(self.onQuit, self))
	-- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchPanel) then return end
        self._touchPanel:setEnabled(false)
    end)

    if self._bIsPlayBack then
        self._childNodeTable.bg_1:setVisible(false)
        self._childNodeTable.countBtn:setVisible(false)
        self._childNodeTable.playBack_btn:setVisible(true)
        self._childNodeTable.ranktile_lab:setVisible(true)
        self._childNodeTable.result_lay:setVisible(true)
        self._childNodeTable.result_lay:setLocalZOrder(20)
        for i = 1, 3 do
            local var1 = self._childNodeTable.play_btn[i]
            local var2 = self._childNodeTable.result_bg[i]
            local countData = self._battleInfo.battles[i]
            local boolWin = false
            if countData then
                if not self._battleInfo.reverse and countData.win == 1 then
                    boolWin = true
                elseif self._battleInfo.reverse and countData.win == 2 then
                    boolWin = true
                end
            end
            local winRes = boolWin and "gloryArenaResult_win.png" or "gloryArenaResult_lose.png"
            local iconRes = boolWin and "globalImage_winlose_1.png" or "globalImage_winlose_2.png"
            if var2 then
                var2:loadTexture(winRes, ccui.TextureResType.plistType)
            end
            if countData and var1 then
                var1:getChildByFullName("icon"):loadTexture(iconRes, ccui.TextureResType.plistType)
                var1:getChildByFullName("title"):setString("第" .. i .. "场")
				self:registerClickEvent(var1, function(_, x, y, sender)
					 local _sec = self._battleInfo.dataSec or ModelManager:getInstance():getModel("UserModel"):getServerId()
                     self._serverMgr:sendMsg("CrossArenaServer","getBattleReport",{reportKey = countData.reportKey, sec = _sec, type = 1},true,{},function( result )
                        self:playBackBattle(result, nil, not self._battleInfo.reverse)
                    end)
                end)
            end
            self._childNodeTable.rankPos_lab:setString(self._battleInfo._rank or "")
        end
        
        
    else
        self._childNodeTable.bg_1:setVisible(false)
        self._childNodeTable.countBtn:setVisible(true)
        self._childNodeTable.playBack_btn:setVisible(false)
        self._childNodeTable.ranktile_lab:setVisible(false)
        self._childNodeTable.result_lay:setVisible(false)
        self._childNodeTable.bg_2:setPositionY(self._childNodeTable.bg_2:getPositionY() + 100)
        local __win = self._battleInfo.win
        if self._battleInfo.reverse then
            __win = not __win
        end
        local strLang = __win and "honorArena_tip_22" or "honorArena_tip_23"
        self._childNodeTable.bg_2_des1:setString(lang(strLang))
        self._childNodeTable.bg_2_des1:setVisible(true)
        self._childNodeTable.bg_2_des1:setPositionX(self._childNodeTable.bg_2_des:getPositionX())
        self._childNodeTable.bg_2_des:setVisible(false)
    end

    self._childNodeTable.bg_img:loadTexture("asset/bg/battleResult_flagBg.png")

    self._bg = self._childNodeTable.bg
	self._title = self._childNodeTable.title
	self._bg2 = self._childNodeTable.bg2
    self._title:setVisible(false)
    self._bg2:setVisible(false)

	self._rolePanel = self._childNodeTable.role_panel

	self._bgImg = self._childNodeTable.bg_img

	self._countBtn = self._childNodeTable.countBtn
	self._countBtn:setSwallowTouches(true)
    self._countBtn:setEnabled(false)

    local mcMgr = MovieClipManager:getInstance()
    

	self._roleImg = self._childNodeTable.role_img
	self._roleImgShadow = self._childNodeTable.roleImg_shadow

    if self._battleInfo.leftData and #self._battleInfo.leftData > 0 then
        -- 人物
	    local team
	    self._teams = {}
	    local invH = 96
	    local invW = 86
	    local count = #self._battleInfo.leftData
	    local colume = 4
	    local rowNum = math.ceil(count/colume)
	    local beginX = invW * 0.5
	    local beginY = 200 - invH * 0.5
	    local teamModel = self._modelMgr:getModel("TeamModel")
	    --最佳输出
	    local outputID = self._battleInfo.leftData[1].D["id"]
	    self._lihuiId = self._battleInfo.leftData[1].D["id"]
	    local outputValue = self._battleInfo.leftData[1].damage or 0
	    local outputLihuiV = self._battleInfo.leftData[1].damage or 0
	    for i = 1,#self._battleInfo.leftData do
            if self._battleInfo.leftData[i].damage then
--                print("____________", self._battleInfo.leftData[i].D["id"])
		        if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputValue) then
		            outputValue = self._battleInfo.leftData[i].damage
		            outputID = self._battleInfo.leftData[i].D["id"]
		        end
		        if tonumber(self._battleInfo.leftData[i].damage) > tonumber(outputLihuiV) and self._battleInfo.leftData[i].original then
		            outputLihuiV = self._battleInfo.leftData[i].damage
		            self._lihuiId = self._battleInfo.leftData[i].D["id"]
		        end
		    end
	    end
	    
--	    local curHeroId = self._battleInfo.hero1["id"]
--	    local initTeamIconFunc = function(id, i)
--	        local mercenaryId = self._result["mercenaryId"] or 0
--	        local isMercenary = false
--	        if tonumber(id) == tonumber(mercenaryId) then isMercenary = true end
--	        local teamD = tab:Team(id)
--	        local teamData = {}
--	        if isMercenary then
--	    	    teamData = self._modelMgr:getModel("GuildModel"):getEnemyDataById(id,self._result["userId"])
--    	    else
--    		    teamData = teamModel:getTeamAndIndexById(id)
--    	    end
--		    if teamData then
--			    local quality = teamModel:getTeamQualityByStage(teamData.stage)
--		        team = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle = 0})
--		        team:setAnchorPoint(0.5, 0.5)
--		        -- team:setScale(0.8)
--		        -- 如果有专精变身替换icon

--		        local teampData = clone(teamData)
--		        teampData.teamId = id

--			    local art = nil
--			    local changeId = nil
--		        if curHeroId then 
--			        art,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
--			    end
--			    local _,art = TeamUtils:getTeamAwakingTab(teamData,changeId,false)
--                local teamIcon = team:getChildByFullName("teamIcon")
--			    teamIcon:loadTexture(art .. ".jpg",1)

--		        -- if curHeroId then 
--		        -- 	local isAwaking, _ = TeamUtils:getTeamAwaking(teamData)
--			    -- 	local art,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
--			    -- 	if changeId and art then
--			    -- 		-- 觉醒优先
--			    -- 		if isAwaking then
--			    -- 			local tData = tab:Team(changeId)
--			    -- 			art = tData.jxart1
--			    -- 		end
--			    -- 		local teamIcon = team:getChildByFullName("teamIcon")
--			    -- 		teamIcon:loadTexture(art .. ".jpg",1)
--			    -- 	end
--			    -- end
--		        if i % 4 == 0 then		  
--		    	    team:setPosition(beginX, beginY)		    		  		
--		    	    beginX = invW * 0.5
--		    	    beginY = beginY - invH
--		        else		    		
--		    	    team:setPosition(beginX, beginY)
--		    	    beginX = beginX + invW
--		        end
--		        self._bg1:addChild(team)
--		        if self._battleInfo.isTimeUp or self._battleInfo.leftData[i].die ~= -1 then
--		    	    local dieIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI4_dead.png")
--		    	    dieIcon:setPosition(team:getContentSize().width/2,team:getContentSize().height/2)
--		    	    -- team:setSaturation(-100)
--		    	    dieIcon:setName("dieImg")
--		    	    local child = team:getChildren()
--		    	    for i=1,#child do
--		    		    if child[i]:getName() ~= "dieImg" then
--		    			    child[i]:setSaturation(-100)
--		    		    end
--		    	    end
--		    	    team:addChild(dieIcon,100)
--		        end
--		        self._teams[i] = team

--		        if outputID == id then
--		    	    team.isBestOutput = true
--		    	    self._bestOutID = outputID
--		    	    local _,changeId = TeamUtils.changeArtForHeroMastery(curHeroId,id)
--		    	    self._bestOutID = changeId or outputID
--		        end

--			    --佣兵标志
--			    if isMercenary then
--			        local hireIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_hireIcon.png") 
--			        hireIcon:setScale(1.4)
--			        hireIcon:setPosition(team:getContentSize().width * 0.5 - 45, 100)
--		    	    team:addChild(hireIcon,100)	
--		        end	

--		    end
--	    end
    end
--	    for i = 1, count do
--	    	if self._battleInfo.leftData[i] and not self._battleInfo.leftData[i].copy then 
--		    	local id = self._battleInfo.leftData[i].D["id"]
--		    	initTeamIconFunc(id,i)
--		    end	    	
--	    end
    if self._result.reward then
	    -- 物品
        self._title:setVisible(true)
        self._bg2:setVisible(true)
	    self._goldValue = 0
	    local reward = {}
	    local _reward = self._result.reward
	    for k,v in pairs(_reward) do
	    	if v.type == "tool" then
	    		reward[#reward + 1] = v

	    	elseif v.type == "crusading" then
	    		reward[#reward + 1] = v
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["crusading"]
	    		reward[#reward]["num"] = v.num

	    	elseif v.type == "gold" then
	    		self._goldValue = v.num

	    	elseif v.type == "gem" then
    			reward[#reward + 1] = v
    			reward[#reward]["typeId"] = IconUtils.iconIdMap["gem"]

    		elseif v.type == "treasureCoin" then
    			reward[#reward + 1] = v
	    		reward[#reward]["typeId"] = IconUtils.iconIdMap["treasureCoin"]
	    		reward[#reward]["num"] = v.num
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
	        item:setScale(0.8)
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
	self._time = self._battleInfo.time
    self._childNodeTable.bg_2:setVisible(true)
    self._childNodeTable.bg_2:setOpacity(0)
    self._childNodeTable.bg_2:setCascadeOpacityEnabled(true)
    self:animBegin()
end


function BattleResultGloryArena:onQuit()
	if self._callback then
		self._callback()
		UIUtils:reloadLuaFile("battle.BattleResultGloryArena")
    else
        self:close(true)
        audioMgr:playMusic("mainmenu", true)
        UIUtils:reloadLuaFile("battle.BattleResultGloryArena")
	end
end


local delaytick = {360, 380, 380}
function BattleResultGloryArena:animBegin()
	audioMgr:stopMusic()
	audioMgr:playSoundForce("WinBattle")

    self._childNodeTable.bg_2:runAction(cc.FadeIn:create(1.0))

	local liziAnim = mcMgr:createViewMC("liziguang_commonwin", true, false)	
	liziAnim:setPosition(MAX_SCREEN_WIDTH * 0.5, 135)
	self:getUI("bg"):addChild(liziAnim, 1000)

	-- 如果兵团有变身技能，这里改变立汇
    local curHeroId = self._battleInfo.hero1["id"]
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
    	local mercenaryId = self._result["mercenaryId"] or 0
    	local isMercenary = false
    	if tonumber(lihuiId) == tonumber(mercenaryId) then isMercenary = true end
    	local tdata = {}
    	-- 雇佣兵
    	if isMercenary then
    		tdata = self._modelMgr:getModel("GuildModel"):getEnemyDataById(lihuiId,self._result["userId"])
		else
			tdata,_ = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(lihuiId)
		end

        local isAwaking,_ = TeamUtils:getTeamAwaking(tdata)
        local teamName, art1, art2, art3 = TeamUtils:getTeamAwakingTab(tdata, self._lihuiId)
        -- if isAwaking then 
        --     -- 结算例会单独处理 读配置
        --     imgName = teamData.jxart2
        --     artUrl = "asset/uiother/team/"..imgName..".png"
        -- end
        artUrl = "asset/uiother/team/".. art2 ..".png"
--        print(")))))))))))))))))))))", artUrl, self._lihuiId)
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
	local posBgX,posBgY = self._bgImg:getPosition()


	self._rolePanel:setPositionY(-moveDis)
	-- 右侧旗子
    self._posBgX = self._bgImg:getPositionX()
    self._posBgY = self._bgImg:getPositionY()
    self._bgImg:setPositionY(self._posBgY+615)

	local moveRole = cc.Sequence:create(cc.MoveTo:create(0.05,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	self._rolePanel:runAction(moveRole)
	-- local moveRoleLow = cc.Sequence:create(cc.DelayTime:create(0.06), cc.MoveTo:create(0.1,cc.p(posRoleX+20,posRoleY)),cc.MoveTo:create(0.01,cc.p(posRoleX,posRoleY)))
	-- self._rolePanelLow:runAction(moveRoleLow)
	
	local moveBg = cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(posBgX,posBgY+20)),cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)))
	self._bgImg:runAction(moveBg)

	local animPos = self:getUI("bg.animPos")
	ScheduleMgr:delayCall(100, self, function(sender)
        local posBgX,posBgY = self._posBgX,self._posBgY
        local mc2
        local moveBg = cc.Sequence:create(
        	cc.MoveTo:create(0.15,cc.p(posBgX,posBgY-20)),
        	cc.MoveTo:create(0.01,cc.p(posBgX,posBgY)),
            cc.CallFunc:create(function()
                local win = self._battleInfo.win
                if self._battleInfo.reverse then
                    win = not win
                end
                if win then
                    --胜利动画
			        mc2 = mcMgr:createViewMC("shengli_commonwin", false)
                else
                    --失败动画
                    mc2 = mcMgr:createViewMC("shibai_commonlose", false)
                end
			    mc2:setPlaySpeed(1.5)
			    mc2:setPosition(animPos:getPositionX(), animPos:getPositionY())
			    self._bg:addChild(mc2, 5)
			end),
			cc.DelayTime:create(0.15),
			cc.CallFunc:create(function()
				-- 底光动画
			   	local mc1 = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false, function (_, sender)
			    	sender:gotoAndPlay(80)	       
			    end,RGBA8888)
			    mc1:setPosition(animPos:getPosition())

			    local clipNode2 = cc.ClippingNode:create()
			    clipNode2:setInverted(false)

		        local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskHalfCircle.png")
		        mask:setScale(2.5)
		        mask:setPosition(animPos:getPositionX(), animPos:getPositionY() + 140)
		        clipNode2:setStencil(mask)
		        clipNode2:setAlphaThreshold(0.01)
		        clipNode2:addChild(mc1)
		        clipNode2:setAnchorPoint(cc.p(0, 0))
            	clipNode2:setPosition(0, 0)
		        self._bg:addChild(clipNode2,4)
			end),
			cc.DelayTime:create(0.3),
			cc.CallFunc:create(function()
				--震屏
    			UIUtils:shakeWindowRightAndLeft2(self._bg)
				end),
			cc.DelayTime:create(0.15),
			cc.CallFunc:create(function()
				self:animNext(mc2)
				end)
        	)
        self._bgImg:runAction(moveBg)
	end)
end

function BattleResultGloryArena:animNext(mc2)	
	-- 动画
    local animPos = self:getUI("bg.animPos")
--    self._bg:setVisible(false)
    local mc3 = mcMgr:createViewMC("shenglixing_commonwin", true)
    mc3:setPosition(animPos:getPositionX(),animPos:getPositionY() - 70)
    self._bg:addChild(mc3, 4)
    if not self._bIsPlayBack then
        self._timeLabel = cc.Label:createWithTTF("00:00", UIUtils.ttfName,  26)
        self._timeLabel:setColor(cc.c3b(245, 20, 34))
        self._timeLabel:enableOutline(cc.c4b(0,0,0,255),2)
        self._timeLabel:setPosition(213, -28)
        mc2:getChildren()[1]:getChildren()[1]:addChild(self._timeLabel)
        if self._time then
    	    self:labelAnimTo(self._timeLabel, 0, self._time, true)
        end
    end

    --获得道具title
    local delayT = self._delayT or 0
    if self._items and #self._items > 0 then
    	self._title:runAction(cc.Sequence:create(
    		cc.DelayTime:create(0.5), 
    		cc.FadeIn:create(0.01),
    		-- cc.ScaleTo:create(0.1, 2),
    		cc.CallFunc:create(function()
    			local getAnim = mcMgr:createViewMC("huodedaojuguang_commonwin", false)
    			getAnim:setPosition(self._title:getPositionX(),  self._title:getPositionY() + 4)
    			self._title:getParent():addChild(getAnim, 3)
    			end),
--            cc.ScaleTo:create(0.3, 0.1)
    		cc.EaseOut:create(cc.ScaleTo:create(0.3, 1.0), 1.5)
    		))
    end

    self._countBtn:runAction(cc.Sequence:create(cc.DelayTime:create(1.3), cc.FadeIn:create(0.3),cc.CallFunc:create(function ()
    	self._countBtn:setEnabled(true)
    end)))
	self._touchPanel:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
    	self._touchPanel:setEnabled(false)
    end)))


    if self._items then
	    ScheduleMgr:delayCall(700, self, function()
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
			    			end)
		    			))
		    	end
		    end
	    end)
	end
end

function BattleResultGloryArena:labelAnimTo(label, src, dest, isTime)
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

-- 接收自定义消息
function BattleResultGloryArena:reflashUI(data)
	
end




function BattleResultGloryArena:dtor()
    childName = nil
end

return BattleResultGloryArena

--endregion
