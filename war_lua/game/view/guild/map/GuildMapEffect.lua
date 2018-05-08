--[[
    Filename:    GuildMapEffect.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-07-04 20:06:01
    Description: File description
--]]

local GuildMapLayer = require("game.view.guild.map.GuildMapLayer")



--[[
--! @function showElementHighlightTip
--! @desc 特殊点高亮提示
--! @param sp 目标精灵
--! @param inSysGuildMapThing 目标系统数据
--! @param inTypeName 类型
--! @return 
--]]
function GuildMapLayer:showElementHighlightTip(inElementSp, inSysGuildMapThing, inTypeName)
    if inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.PVE and 
        inSysGuildMapThing.qiangdu == 1 then 
        mcMgr:loadRes("1_guildmapbosseffect", function()
            if self.showElementHighlightTip == nil then 
                return
            end
            local boosAnim = mcMgr:createViewMC("yewaiboss_guildmapbosseffect", true)
            boosAnim:setPosition(inElementSp:getContentSize().width * 0.5, inElementSp:getContentSize().height * 0.5)
            boosAnim:setName("bosseffet")
            inElementSp:addChild(boosAnim, 7)  
        end)
        return
    end


    -- -- 增加提示
    -- if inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.CITY or
    --     inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.PORTAL or
    --     inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.ELAPSED_REWARD or
    --    inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.ELAPSED_BUFFER or 
    --    (inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.PVE and 
    --     inTypeName == GuildConst.ELEMENT_TYPE.GUILD) then
 
    --     local tipSp = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp14.png")
    --     if inSysGuildMapThing.func == GuildConst.ELEMENT_EVENT_TYPE.PVE then
    --         tipSp:setPosition(inElementSp:getContentSize().width/2, 10)
    --     else
    --         tipSp:setPosition(inElementSp:getContentSize().width/2, 20)
    --     end
    --     tipSp:setScale(1 / inElementSp:getScaleX())
    --     inElementSp:addChild(tipSp,7)
    -- end
end

function GuildMapLayer:showElementEffect(sp, eleID, mapItem, inGridKey)
	if mapItem and mapItem["haduse"] ~= nil then   --激活
		self:showActiveEventEffect(sp, eleID, mapItem)
	else
		self:showUnActiveEventEffect(sp, eleID, mapItem, inGridKey)
	end

	if mapItem and mapItem["locktime"] and mapItem["owner"] then
		local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
		local mineId = self._modelMgr:getModel("UserModel"):getData()._id
		if tonumber(mapItem["locktime"]) <= currTime and mapItem["owner"] == mineId then
			self:showActiveEventEffect(sp, eleID, mapItem, "stop_kelingqu")
		end
	end

	self:showFlagEffect(sp, eleID, mapItem)
    self:showTaskTipEffect(sp, eleID, mapItem)
end

---------------------------------
--任务相关特效或标志 [先知小屋]/[斯芬克斯答题]
function GuildMapLayer:showTaskTipEffect(sp, eleID, mapItem)
    local guildMapModel = self._modelMgr:getModel("GuildMapModel")
    local sysGuildMapThing = tab.guildMapThing[tonumber(eleID)]
    if sysGuildMapThing == nil then
        return
    end
    
    if sp._fuhao ~= nil then
        sp._fuhao:removeFromParent(true)
        sp._fuhao = nil
    end

    local buildT1 = GuildConst.ELEMENT_EVENT_TYPE.TRIGGER_TASK
    local buildT2 = GuildConst.ELEMENT_EVENT_TYPE.NPC
    local buildT3 = GuildConst.ELEMENT_EVENT_TYPE.XUEZHE_BOX
    local buildT4 = GuildConst.ELEMENT_EVENT_TYPE.SPHINX_AQ
	local buildT5 = GuildConst.ELEMENT_EVENT_TYPE.MATERIAL
	local buildT6 = GuildConst.ELEMENT_EVENT_TYPE.OFFICER

    local taskT1 = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_XUEZHE
    local taskT2 = GuildConst.TASK_TYPE.GUILD_MAP_ST_FIND_BOX

    ----先知小屋 感叹号
    if sysGuildMapThing.func == buildT1 then  
        if guildMapModel:getTaskStateByStatis(taskT1) == 0 then
            local tipAnim = mcMgr:createViewMC("tanhao_lianmengdonghua", true)
            tipAnim:setPosition(sp:getContentSize().width * 0.5 + 7, sp:getContentSize().height + 12)
            sp._fuhao = tipAnim
            sp:addChild(tipAnim, 20)
        end
    end

    --学者npc 问号
    if sysGuildMapThing.func == buildT2  then  
        if guildMapModel:getTaskStateByStatis(taskT1) == 1 then
            local tipAnim = mcMgr:createViewMC("wenhao_lianmengdonghua", true)
            tipAnim:setPosition(sp:getContentSize().width * 0.5, sp:getContentSize().height + 7)
            sp._fuhao = tipAnim
            sp:addChild(tipAnim, 20)
        end
    end
	
	--联盟指挥官
	if sysGuildMapThing.func == buildT6 then
		local officerGid = self._guildMapModel:getOfficerTargetGuildId()
		local commanderData = self._guildMapModel:getCommanderData()
		local showAnim = true
		if mapItem.actime then
			if officerGid and officerGid~=0 then--指挥官已激活，并且有物资官存在，
				showAnim = false
			elseif commanderData and commanderData.actime and commanderData.rtime then
				local maxRewardTime = tab:Setting("OFFICER_REWARD_TOTAL").value*60
				local isDifferentDay = TimeUtils.checkIsOtherDay(tonumber(mapItem.actime), self._modelMgr:getModel("UserModel"):getCurServerTime())
				if tonumber(commanderData.rtime)-tonumber(commanderData.actime)>=maxRewardTime and isDifferentDay then
					showAnim = true
				else
					showAnim = false
				end
			end
		end
		if showAnim then
			local tipAnim = mcMgr:createViewMC("tanhao_lianmengdonghua", true)
			tipAnim:setPosition(sp:getContentSize().width * 0.5, sp:getContentSize().height + 30)
			sp._fuhao = tipAnim
			sp:addChild(tipAnim, 20)
		end
	end
	
	--联盟军需官
	if sysGuildMapThing.func == buildT5 then
		local tipAnim = mcMgr:createViewMC("wenhao_lianmengdonghua", true)
		tipAnim:setPosition(sp:getContentSize().width * 0.5, sp:getContentSize().height + 30)
		sp._fuhao = tipAnim
		sp:addChild(tipAnim, 20)
	end

    --宝箱 感叹号
    if sysGuildMapThing.func == buildT3 then
        if guildMapModel:getTaskStateByStatis(taskT2) == 1 then
            local tipAnim = mcMgr:createViewMC("tanhao_lianmengdonghua", true)
            tipAnim:setPosition(sp:getContentSize().width * 0.5 + 7, sp:getContentSize().height + 25)
            sp._fuhao = tipAnim
            sp:addChild(tipAnim, 20)
        end
    end

    --斯芬克斯答题 问号
    if sysGuildMapThing.func == buildT4 then
        local tipAnim = mcMgr:createViewMC("wenhao_lianmengdonghua", true)
        tipAnim:setPosition(sp:getContentSize().width * 0.5 - 14, sp:getContentSize().height + 18)
        sp._fuhao = tipAnim
        sp:addChild(tipAnim, 20)
    end
end

----------------------------------
--未激活特效
function GuildMapLayer:showUnActiveEventEffect(obj, objID, mapItem, inGridKey)
    local sysGuildMapThing = tab.guildMapThing[objID]
    local effectName = sysGuildMapThing["texiao_1"]
    if effectName then
        local unActiveAnim = mcMgr:createViewMC(effectName, true)
        unActiveAnim:setName(effectName)
        
	    if effectName == "shuiche_lianmengchangtaitexiao" then   --水车

	    	unActiveAnim:setPosition(obj:getContentSize().width/2, obj:getContentSize().height/2)
            self:showShuiCheEffect(obj, unActiveAnim)

	    elseif effectName == "zhihuishi_lianmengchangtaitexiao" then  --智慧石
	        unActiveAnim:setPosition(obj:getContentSize().width/2 - 10, obj:getContentSize().height/2 + 32)
	        obj:addChild(unActiveAnim, 10)

	    elseif effectName == "jiesuozhiqian3_lianmengchangtaitexiao" then  --尖塔
	    	unActiveAnim:setPosition(obj:getContentSize().width/2 -5, obj:getContentSize().height/2 +135)
	        obj:addChild(unActiveAnim, 10)

        elseif effectName == "chuansongmenlan_intanceportal" then  --传送门
            unActiveAnim:setPosition(obj:getContentSize().width/2 + 14, obj:getContentSize().height/2)
            unActiveAnim:setScale(0.7)
            obj:addChild(unActiveAnim, 10)
	    
		elseif effectName == "mijingrukou1_mijingrukou" then--联盟秘境传送门
			unActiveAnim:setPosition(obj:getContentSize().width/2+13, obj:getContentSize().height/2-4)
			obj:addChild(unActiveAnim, 10)
	    else
	        unActiveAnim:setPosition(obj:getContentSize().width/2, obj:getContentSize().height/2)
	        obj:addChild(unActiveAnim, 10)
	    end
    end

    if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.TENT or 
        sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then
        local unActiveSp = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp36.png")
        unActiveSp:setAnchorPoint(1, 1)
        unActiveSp:setPosition(obj:getContentSize().width + 10, obj:getContentSize().height )
        obj:addChild(unActiveSp, 100)
    end

    --地表特效
    obj:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function()
            local actEarth = tab.guildMapThing[objID]["texiao_4"]
            if actEarth ~= nil and string.len(actEarth) > 0 and inGridKey ~= nil then        
                local animEarth = mcMgr:createViewMC(actEarth, true)
                animEarth:setPosition(self._shapes[inGridKey]["pos"].x, self._shapes[inGridKey]["pos"].y - 20 + obj:getContentSize().height * 0.5)
                obj.earthAnim = animEarth
                self._floorLayer:addChild(animEarth, 10)

                animEarth:setCascadeOpacityEnabled(true, true)
                animEarth:setOpacity(0)
                animEarth:runAction(cc.FadeIn:create(0.8))

                if self._gridFogs[inGridKey] ~= nil then
                    animEarth:setVisible(false)                    
                end
            end
            end)
        ))
    
    -- 不能通过标记
    -- if (sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.UNDERGROUND_CITY or 
    --     sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.DOOR) and mapItem["openTime"] ~= nil then
    --     local currTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    --     if tonumber(mapItem["openTime"]) > currTime then
    --         local unActiveSp = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp16.png")
    --         unActiveSp:setAnchorPoint(1, 0.5)
    --         unActiveSp:setScale(0.6)
    --         if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.UNDERGROUND_CITY then
    --             unActiveSp:setPosition(obj:getContentSize().width - 8, obj:getContentSize().height * 0.5 - 10 )
    --         elseif sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.DOOR then
    --             unActiveSp:setPosition(obj:getContentSize().width + 50, obj:getContentSize().height * 0.5 + 30)
    --         end
    --         obj:addChild(unActiveSp, 1000) 
    --         unActiveSp:runAction(cc.Sequence:create(
    --                         cc.DelayTime:create(tonumber(mapItem["openTime"]) - currTime), 
    --                         cc.CallFunc:create(function() 
    --                                 unActiveSp:removeFromParent()
    --                             end
    --                             )
    --                         ))
    --     end
    -- end
end 

------------------------------------
--水车
function GuildMapLayer:showShuiCheEffect(obj, anim)
	local clipNode = cc.ClippingNode:create()   
    clipNode:setInverted(false)   
    local mask = cc.Sprite:createWithSpriteFrameName("guildMapShuiChe_clip.png")  
    mask:setPosition(cc.p(obj:getContentSize().width/2 - 2, obj:getContentSize().height/2 - 20))
    mask:setAnchorPoint(0.5, 0.5)
    clipNode:setStencil(mask)  
    clipNode:setAlphaThreshold(0.01)
    clipNode:addChild(anim)  
    clipNode:setAnchorPoint(cc.p(0, 0))
    clipNode:setPosition(0, 0)
    obj:addChild(clipNode,10)
    clipNode:setCascadeOpacityEnabled(true, true)
    clipNode:setOpacity(0)
    clipNode:runAction(cc.FadeIn:create(0.5))
end

------------------------------------
--激活特效
function GuildMapLayer:showActiveEventEffect(obj, objID, mapItem, effectName)
    if effectName == nil or string.len(effectName) <= 0 then 
        local sysGuildMapThing = tab.guildMapThing[objID]
        if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.TENT or 
            sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then
            local activeSp = cc.Sprite:createWithSpriteFrameName("guildMapImg_temp37.png")
            activeSp:setAnchorPoint(1, 1)
            activeSp:setPosition(obj:getContentSize().width + 10, obj:getContentSize().height )
            obj:addChild(activeSp, 100)
        else
           effectName = tab.guildMapThing[objID]["texiao_2"]
        end
	end
    if effectName ~= nil and string.len(effectName)  > 0 then
        local activeAnim = mcMgr:createViewMC(effectName, true)
        
        if effectName == "shuiche_lianmengchangtaitexiao" then
        	activeAnim:setPosition(obj:getContentSize().width/2, obj:getContentSize().height/2)
        	self:showShuiCheEffect(obj, activeAnim)

        elseif effectName == "stop_kelingqu" then
        	activeAnim:setPosition(obj:getContentSize().width/2 - 55, obj:getContentSize().height/2 + 75)
        	obj:addChild(activeAnim, 10)

        elseif effectName == "fangjiantatexiao_guildmapfangjianta" then
            activeAnim:setPosition(obj:getContentSize().width/2 + 3, obj:getContentSize().height/2 + 25)
            obj:addChild(activeAnim, 10)

        else
        	activeAnim:setPosition(obj:getContentSize().width/2, obj:getContentSize().height/2)
        	obj:addChild(activeAnim, 10)
        end
    end
end

-------------------------------
--旗帜
function GuildMapLayer:showFlagEffect(obj, objID, mapItem)
	-- dump(mapItem,"123")
	if obj:getChildByName("flagAnim2_1") ~= nil then
		obj:getChildByName("flagAnim2_1"):removeFromParent(true)
	end

	if obj:getChildByName("flagAnim2_2") ~= nil then
		obj:getChildByName("flagAnim2_2"):removeFromParent(true)
	end

	if obj:getChildByName("flagAnim1") ~= nil then
		obj:getChildByName("flagAnim1"):removeFromParent(true)
	end
    local sysGuildMapThing = tab.guildMapThing[objID]
    if sysGuildMapThing == nil  then 
        return
    end

    local showEffectState = function (animName, lightAnim, inOffset1, inOffset2)
        if inOffset1 == nil then 
            inOffset1 = {30, 30}
        end
        if inOffset2 == nil then 
            inOffset2 = {0, 30}
        end
        if animName ~= "" then
            local flagAnim = mcMgr:createViewMC(animName, true)
            flagAnim:setPosition(obj:getContentSize().width/2 - inOffset1[1], obj:getContentSize().height/2 - inOffset1[2])
            flagAnim:setName("flagAnim2_1")
            obj:addChild(flagAnim, 11)
        end
        
        if lightAnim ~= "" then
            local lightAnim = mcMgr:createViewMC(lightAnim, true)
            lightAnim:setPosition(obj:getContentSize().width/2 - inOffset2[1], obj:getContentSize().height/2- inOffset2[2])
            lightAnim:setName("flagAnim2_2")
            obj:addChild(lightAnim, -1)
        end
    end

	if mapItem and mapItem["haduse"] ~= nil then   --激活
		-- if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then
  --           if objID == 74 then   
  --               return
  --           end    
	 --    	local animName, lightAnim
	 --    	local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
	 --    	local curGuildId = self._modelMgr:getModel("GuildMapModel"):getData().currentGuildId
  --           if tostring(guildId) == tostring(curGuildId) then
  --           	animName = "wofangzhanlingqizi_guildmapzhanling"
  --           	lightAnim = "wofangzhanling_guildmapzhanling"
  --           else
  --           	animName = "difangzhanlingqizi_guildmapzhanling"
  --           	lightAnim = "difangzhanling_guildmapzhanling"
  --           end 
  --           if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.CITY then 
  --               lightAnim = ""
  --           end
  --           lightAnim = ""
  --           showEffectState(animName, lightAnim, nil, {-10, 10})
	 --    end
    elseif mapItem and mapItem["nowguildId"] ~= nil and tostring(mapItem["nowguildId"]) ~= "0" then
        local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
        if tostring(guildId) == tostring(mapItem["nowguildId"]) then
            animName = "wofangzhanlingqizi1_guildmapzhanling"
            lightAnim = "wofangzhanling1_guildmapzhanling"
        else
            animName = "difangzhanlingqizi1_guildmapzhanling"
            lightAnim = "difangzhanling1_guildmapzhanling"
        end
        if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.CITY then 
            lightAnim = ""
        end 
        if objID == 74 then 
            local flagAnim = mcMgr:createViewMC("longzhiguojianzhu_guildmaplongzhiguo", true)
            flagAnim:setPosition(obj:getContentSize().width/2 - 10, obj:getContentSize().height/2 - 40)
            flagAnim:setName("flagAnim2_1")
            obj:addChild(flagAnim, 10)
            flagAnim:setScale(0.8)
            return
        end
        showEffectState(animName, lightAnim, {30, 10})
	else
        if objID == 74 then   
            return
        end
		if sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.OUTPUT_GOLD then   --旗帜                                                                       
	    	-- local flagAnim = mcMgr:createViewMC("weizhanlingqizi_guildmapzhanling", true)
	     --    flagAnim:setPosition(obj:getContentSize().width/2 - 30, obj:getContentSize().height/2 - 30)
	     --    flagAnim:setName("flagAnim1")
	     --    obj:addChild(flagAnim, 3)
        elseif  sysGuildMapThing["func"] == GuildConst.ELEMENT_EVENT_TYPE.CITY then
            local flagAnim = mcMgr:createViewMC("weizhanlingqizi1_guildmapzhanling", true)
            flagAnim:setPosition(obj:getContentSize().width/2 - 30, obj:getContentSize().height/2 - 10)
            flagAnim:setName("flagAnim1")
            obj:addChild(flagAnim, 11)            
	    end
	end                        
end

-------------------------------------
--常态特效pingyuan
function GuildMapLayer:showCommonEffectpingyuan()  
    local delay = cc.DelayTime:create(1)
    local call1 = cc.CallFunc:create(function()
        mcMgr:loadRes("1_lianmengchangtaitexiao", function()
            if self.showCommonEffectpingyuan == nil then 
                return
            end
            --蜻蜓
            local qingTing = mcMgr:createViewMC("qingting_lianmengchangtaitexiao", true, false)
            qingTing:setPosition(GuildConst.GUILD_MAP_MINI_MAX_WIDTH/2 - 523, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT/2 - 505)
            self._floorLayer:addChild(qingTing, 3)
            qingTing:setCascadeOpacityEnabled(true, true)
            qingTing:setOpacity(0)
            qingTing:runAction(cc.FadeIn:create(0.5))
        end)

        mcMgr:loadRes("1_changjingdonghua1", function()
            if self.showCommonEffectpingyuan == nil then 
                return
            end
            local cloudAnim = mcMgr:createViewMC("yun_changjingdonghua1", true) 
            cloudAnim:setPosition(GuildConst.GUILD_MAP_MINI_MAX_WIDTH/2, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT/2)
            self._fogLayer:addChild(cloudAnim, 20)
            cloudAnim:setCascadeOpacityEnabled(true, true)
            cloudAnim:setOpacity(0)
            cloudAnim:runAction(cc.FadeTo:create(0.5, 220))
        end)

        mcMgr:loadRes("1_changjingdonghua2", function()
            if self.showCommonEffectpingyuan == nil then 
                return
            end
            local penAnim = mcMgr:createViewMC("penquan_changjingdonghua2", true) 
            penAnim:setPosition(GuildConst.GUILD_MAP_MINI_MAX_WIDTH/2, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT/2)
            self._floorLayer:addChild(penAnim, 5)
            penAnim:setCascadeOpacityEnabled(true, true)
            penAnim:setOpacity(0)
            penAnim:setScale(1.3515625)
            penAnim:runAction(cc.FadeIn:create(0.5))
        end)

        mcMgr:loadRes("1_anquanqu", function()
            if self.showCommonEffectpingyuan == nil then 
                return
        end
            local anquanqu = mcMgr:createViewMC("anquanqu_anquanqu", true) 
            anquanqu:setPosition(596, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT - 437)
            self._fogLayer:addChild(anquanqu, 19)
            anquanqu:setCascadeOpacityEnabled(true, true)
            anquanqu:setOpacity(0)
            anquanqu:setScale(1)
            anquanqu:runAction(cc.FadeIn:create(0.5))
        end)
    end)
    self._floorLayer:runAction(cc.Sequence:create(delay, call1))
end

-------------------------------------
--常态特效dilao
function GuildMapLayer:showCommonEffectdilao()  
    local delay = cc.DelayTime:create(1)
    local call1 = cc.CallFunc:create(function()
        mcMgr:loadRes("1_anquanqu", function()
            if self.showCommonEffectpingyuan == nil then 
                return
        end
            local anquanqu = mcMgr:createViewMC("dixiachenganquanqu_anquanqu", true) 
            anquanqu:setPosition(1505, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT - 834)
            self._fogLayer:addChild(anquanqu, 19)
            anquanqu:setCascadeOpacityEnabled(true, true)
            anquanqu:setOpacity(0)
            anquanqu:setScale(1.3515625)
            anquanqu:runAction(cc.FadeIn:create(0.5))
        end)
    end)
    self._floorLayer:runAction(cc.Sequence:create(delay, call1))
end

-------------------------------------
--常态特效xuedi
function GuildMapLayer:showCommonEffectxuedi()  
    local delay = cc.DelayTime:create(1)
    local call1 = cc.CallFunc:create(function()
        mcMgr:loadRes("1_xuedianquanqu", function()
            if self.showCommonEffectpingyuan == nil then 
                return
        end
            local anquanqu = mcMgr:createViewMC("xuedianquanqu_xuedianquanqu", true) 
            anquanqu:setPosition(947, GuildConst.GUILD_MAP_MINI_MAX_HEIGHT - 1013)
            self._fogLayer:addChild(anquanqu, 19)
            anquanqu:setCascadeOpacityEnabled(true, true)
            anquanqu:setOpacity(0)
            anquanqu:setScale(1.3515625)
            anquanqu:runAction(cc.FadeIn:create(0.5))
        end)
    end)
    self._floorLayer:runAction(cc.Sequence:create(delay, call1))
end

--常态特效
function GuildMapLayer:showCommonEffect()
    if self._settingData.name == nil or 
        self["showCommonEffect" .. self._settingData.name] == nil or 
        self._settingData.isCenter then 
        return
    end
    self["showCommonEffect" .. self._settingData.name](self)
end


