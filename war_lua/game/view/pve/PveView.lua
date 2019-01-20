--[[
    Filename:    PveView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2015-04-29 15:21:37
    Description: File description
--]]

local PveView = class("PveView", BaseView)
local _pve = {
    [1] = {level = 21, lvlSettingId = 902,sBossId = 5,system = "Crypt"             --[[ 对应systemOpen表--]], filename = "pve.ZombieView", show = false, PVEID = "5",   effectName = "yinsenmuxue_pverukou",offsetY=0},
    [2] = {level = 18, lvlSettingId = 901,sBossId = 4,system = "DwarvenTreasury"   --[[ 对应systemOpen表--]], filename = "pve.AiRenMuWuView", show = false, PVEID = "4",effectName = "airenbaowu_pverukou",offsetY=0},
    [3] = {level = 30, lvlSettingId = 101,            system = "Boss"              --[[ 对应systemOpen表--]], filename = "pve.DragonView", show = false, PVEID = "101", effectName = "longzhiguo_pverukoudragon",offsetY=5},
	[4] = {level = 74, lvlSettingId = 101,sBossId = 6,system = "ArmyTest"		   --[[ 对应systemOpen表--]], filename = "pve.ProfessionBattleDialog", show = false, PVEID = "101", effectName = "juntuanshilian_pverukouprofessionbattle", offsetY = 14}
    -- [1] = {icon = "pveIn_001.png", iconX = 134, iconY = 276, name = "pveIn_nation", nameX = 127, nameY = 113, dec = "PVE_DRAGON_UTOPIA", filename = "pve.DragonView", holeCount = 0},
    -- [2] = {icon = "pveIn_003.png", iconX = 113, iconY = 253, name = "pveIn_treasure", nameX = 125, nameY = 113, dec = "PVE_DWARVEN_TREASURY", filename = "pve.AiRenMuWuView", holeCount = 0},
    -- [3] = {icon = "pveIn_004.png", iconX = 145, iconY = 236, name = "pveIn_grave", nameX = 125, nameY = 113, dec = "PVE_CRYPT", filename = "pve.ZombieView", holeCount = 0},

    -- [4] = {icon = "airenIcon.png", iconX = 113, iconY = 253, name = "airen", nameX = 125, nameY = 113, dec = "PVE_DWARVEN_TREASURY", filename = "pve.AiRenMuWuView", holeCount = 0},
    -- [5] = {icon = "muxueIcon.png", iconX = 145, iconY = 236, name = "muxue", nameX = 125, nameY = 113, dec = "PVE_CRYPT", filename = "pve.ZombieView", holeCount = 0},
}

function PveView:ctor()
    PveView.super.ctor(self)
    self.initAnimType = 2
    self._item = {}

    self._bossModel = self._modelMgr:getModel("BossModel")
end

function PveView:getAsyncRes()
    return 
        {
            {"asset/ui/pveIn.plist", "asset/ui/pveIn.png"},
        }
end

function PveView:getBgName()
    return "bg_012.jpg"
end

function PveView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView", {hideInfo = true , title = "globalTitleUI_yijiezhimen.png",titleTxt = "异界之门"})
end

function PveView:onBeforeAdd(callback, errorCallback) 
    self._serverMgr:sendMsg("BossServer", "getBossInfo", {}, true, {}, function(result) 
--        dump(result,"result")
        if result == true then
            self:onModelReflash()
        end
        callback()
    end)  
end

function PveView:onInit()
    -- 通用动态背景
    self:addAnimBg()
    self._scrollView = self:getUI("bg.scrollView")

    for i=1,table.nums(_pve) do
        local level = _pve[i].level
		if i~=4 then
			level = tab:PveSetting(tonumber( _pve[i].lvlSettingId)).level
		else
			level = tab:ProfessionBattle(tonumber(_pve[i].lvlSettingId)).level
		end
		
        _pve[i].level = level
    end
    local userData = self._modelMgr:getModel("UserModel"):getData()
    for i=1,#_pve do
        self._item[i] = self._scrollView:getChildByFullName("holeNode" .. i)
        self._item[i].hole = self._item[i]:getChildByFullName("hole" .. i)
        self._item[i].hole:setTouchEnabled(false)
        -- 特效
        local mc = mcMgr:createViewMC(_pve[i].effectName, true,false)
		if i==4 then
			mc:setScale(0.95)
			mc:setPosition(self._item[i].hole:getContentSize().width*0.5-3,self._item[i].hole:getContentSize().height*0.5+_pve[i].offsetY)
		else
			mc:setPosition(self._item[i].hole:getContentSize().width*0.5,self._item[i].hole:getContentSize().height*0.5+_pve[i].offsetY)
		end
        
        self._item[i].hole:addChild(mc)
        self._item[i]._effectMc = mc
        --[[if userData.lvl < _pve[i].level then
            self._item[i]._effectMc:stop()
        end--]]
        self._item[i].tishi = self._item[i]:getChildByFullName("tishi")
        self._item[i].holeCount = self._item[i].hole:getChildByFullName("holeCount")
        self._item[i].holeCount:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        self._item[i].suo = self._item[i]:getChildByFullName("suo")
        self._item[i].treasureSurplus = self._item[i].hole:getChildByFullName("treasureSurplus")
        self._item[i].gold = self._item[i].hole:getChildByFullName("gold")

        self._item[i].titleTxt = self._item[i].hole:getChildByFullName("titleTxt")
        self._item[i].titleTxt:setColor(UIUtils.colorTable.ccUITxtColor1)
        self._item[i].titleTxt:enable2Color(1, UIUtils.colorTable.ccUITxtColor2)
        self._item[i].titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

        self._item[i].pointIcon = self._item[i].hole:getChildByFullName("pointIcon")
        self._item[i]:setScaleAnimMin(0.9)
		local isOpen = userData.lvl >= _pve[i].level
		if i==4 then
			local week = self._modelMgr:getModel("ProfessionBattleModel"):getCurWeekDay()
			local _, isNotWeekend = self._modelMgr:getModel("ProfessionBattleModel"):getOpenState()
			isOpen = isOpen and isNotWeekend
			local weekItemData = tab:Setting("ArmyTestDaliyIcon").value[week]
			if weekItemData and weekItemData[2] then
				local toolD = tab.tool[weekItemData[2]]
				local iconName = IconUtils.iconPath .. toolD.art .. ".png"
				local sfc = cc.SpriteFrameCache:getInstance()
				if not sfc:getSpriteFrameByName(iconName) then
					iconName = IconUtils.iconPath .. toolD.art .. ".jpg"
				end
				self._item[i].gold:loadTexture(iconName, 1)
			end
		end
        if isOpen then
            _pve[i].show = true
            -- self._item[i]:setSaturation(0)
            self._item[i].suo:setVisible(false)
            self._item[i].tishi:setVisible(false)
            self._item[i].gold:setVisible(true)
            self._item[i].treasureSurplus:setVisible(true)
            self._item[i].holeCount:setVisible(true)
            self:registerTouchEvent(self._item[i],function(x,y) end,function(x,y) end,
                function(x,y)
					UIUtils.reloadLuaFile(_pve[i].filename)
					if i~=4 then
						self._viewMgr:showView(_pve[i].filename)
					else
						self._serverMgr:sendMsg("ProfessionBattleServer", "getInfo", {}, true, {}, function(result)
							self._viewMgr:showDialog(_pve[i].filename)
						end)
					end
                end,
                function(x,y) end)
        else
            self._item[i].hole:setSaturation(-100)
            self._item[i]._effectMc:stop()
            self._item[i].suo:setVisible(true)
            self._item[i].tishi:setVisible(true)
            self._item[i].treasureSurplus:setVisible(false)
            self._item[i].holeCount:setVisible(false)

            local str = lang("TIPS_PVE_02")
            local des = string.gsub(str,"%b{}",function( lvStr )
                local str = string.gsub(lvStr,"%$level",_pve[i].level)
                return string.gsub(str, "[{}]", "")
            end)

            -- [[ 未开启提示走 systemopen 表 by guojun 2016.12.12
            local systemOpenTip = tab.systemOpen[_pve[i].system][3]
            if systemOpenTip then
                des = lang(systemOpenTip) or des
            end
            --]]
			local noticeText = _pve[i].level .. "级解锁"
			if i==4 then
				local _, isNotWeekend = self._modelMgr:getModel("ProfessionBattleModel"):getOpenState()
				if not isNotWeekend then
					noticeText = "本日不开放"
					des = lang("TIP_ArmyTest_Lock")
				end
				self._item[i].gold:setVisible(false)
			end
            self._item[i].tishi:setString(noticeText)
            self._item[i].tishi:setColor(cc.c3b(120,120,120))

            self:registerTouchEvent(self._item[i],function(x,y) end,function(x,y) end,
                function(x,y)
                    self._viewMgr:showTip(des)
                    _pve[i].show = false
                end,
                function(x,y) end)
        end

    end
	
	
	--箭头指引
	local leftPanel = self:getUI("leftPanel")
    local rightPanel = self:getUI("rightPanel")
    local mc1 = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(rightPanel:getContentSize().width*0.5, rightPanel:getContentSize().height*0.5))
    rightPanel:addChild(mc1)

    local mc2 = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(leftPanel:getContentSize().width*0.5, leftPanel:getContentSize().height*0.5))
    leftPanel:addChild(mc2)
	leftPanel:setVisible(false)
	
	local innerContainer = self._scrollView:getInnerContainer()
	local innerSize = self._scrollView:getInnerContainerSize()
	local contentSize = self._scrollView:getContentSize()
	local vagueWidth = 50
	self._scrollView:addEventListener(function(sender, eventType)
		local posx, posy = innerContainer:getPosition()
		if posx<=-vagueWidth then
			if not leftPanel:isVisible() then
				leftPanel:setVisible(true)
			end
		else
			if leftPanel:isVisible() then
				leftPanel:setVisible(false)
			end
		end
		
		if posx>=contentSize.width-innerSize.width+vagueWidth then
			if not rightPanel:isVisible() then
				rightPanel:setVisible(true)
			end
		else
			if rightPanel:isVisible() then
				rightPanel:setVisible(false)
			end
		end
--		leftPanel:setVisible(posx<=-vagueWidth)
--		rightPanel:setVisible(posx>=contentSize.width-innerSize.width+vagueWidth)
	end)

    self:listenReflash("BossModel", self.onModelReflash)
	self:registerTimer(5,0,1,function(  )
		self:reflashCrossDayNodeState()
	end)
end

function PveView:onModelReflash()
    self._model = self._bossModel:getData() 
    self._hole = {}
    for i=1,4 do
        self._hole[i] = 0
    end

    for k,v in pairs(self._model) do
--        print("===== ",k)
--        dump(v,"========hta=========")
        if tonumber(k) == 1 then
            self._hole[3] = self._hole[3] + tab:Setting("G_PVE_" .. k).value - v.times
        elseif tonumber(k) == 2 then
            self._hole[3] = self._hole[3] + tab:Setting("G_PVE_" .. k).value - v.times
        elseif tonumber(k) == 3 then
            self._hole[3] = self._hole[3] + tab:Setting("G_PVE_" .. k).value - v.times
        elseif tonumber(k) == tonumber(_pve[2].sBossId) then
            -- 矮人
            self._hole[2] = tab:Setting("G_PVE_" .. k).value - v.times
        elseif tonumber(k) == tonumber(_pve[1].sBossId) then
            -- 墓穴
            self._hole[1] = tab:Setting("G_PVE_" .. k).value - v.times
		elseif tonumber(k) == tonumber(_pve[4].sBossId) then
			self._hole[4] = tab:Setting("ArmyTestNumberOfDaily").value - v.times
        end
    end

    for i=1,#_pve do
        self._item[i].holeCount:setString(self._hole[i])
        if self._hole[i] ~= 0 then
            self._item[i].holeCount:setColor(cc.c3b(118,238,0))
        else
            self._item[i].holeCount:setColor(cc.c3b(255,46,46))
        end

        if self._bossModel:getHasReward(_pve[i].PVEID) then
            self._item[i].pointIcon:setVisible(true)
        else
            self._item[i].pointIcon:setVisible(false)
        end
        -- if _pve[i].show == false then
        --     self._hole[i]:setSaturation(-100)
        -- end
    end
end

function PveView:reflashCrossDayNodeState()--跨天刷新入口状态
	local userData = self._modelMgr:getModel("UserModel"):getData()
	for i=1,#_pve do
		local isOpen = userData.lvl >= _pve[i].level
		if i==4 then
			local week = self._modelMgr:getModel("ProfessionBattleModel"):getCurWeekDay()
			local _, isNotWeekend = self._modelMgr:getModel("ProfessionBattleModel"):getOpenState()
			isOpen = isOpen and isNotWeekend
			local weekItemData = tab:Setting("ArmyTestDaliyIcon").value[week]
			if weekItemData and weekItemData[2] then
				local toolD = tab.tool[weekItemData[2]]
				local iconName = IconUtils.iconPath .. toolD.art .. ".png"
				local sfc = cc.SpriteFrameCache:getInstance()
				if not sfc:getSpriteFrameByName(iconName) then
					iconName = IconUtils.iconPath .. toolD.art .. ".jpg"
				end
				self._item[i].gold:loadTexture(iconName, 1)
			end
		end
		if isOpen then
			_pve[i].show = true
			self._item[i].hole:setSaturation(0)
			self._item[i].suo:setVisible(false)
			self._item[i].tishi:setVisible(false)
			self._item[i]._effectMc:play()
			self._item[i].gold:setVisible(true)
			self._item[i].treasureSurplus:setVisible(true)
			self._item[i].holeCount:setVisible(true)
			self:registerTouchEvent(self._item[i],function(x,y) end,function(x,y) end,
				function(x,y)
					UIUtils.reloadLuaFile(_pve[i].filename)
					if i~=4 then
						self._viewMgr:showView(_pve[i].filename)
					else
						self._serverMgr:sendMsg("ProfessionBattleServer", "getInfo", {}, true, {}, function(result)
							self._viewMgr:showDialog(_pve[i].filename)
						end)
					end
				end,
				function(x,y) end)
		else
			self._item[i].hole:setSaturation(-100)
			self._item[i]._effectMc:stop()
			self._item[i].suo:setVisible(true)
			self._item[i].tishi:setVisible(true)
			self._item[i].treasureSurplus:setVisible(false)
			self._item[i].holeCount:setVisible(false)

			local str = lang("TIPS_PVE_02")
			local des = string.gsub(str,"%b{}",function( lvStr )
				local str = string.gsub(lvStr,"%$level",_pve[i].level)
				return string.gsub(str, "[{}]", "")
			end)

			local systemOpenTip = tab.systemOpen[_pve[i].system][3]
			if systemOpenTip then
				des = lang(systemOpenTip) or des
			end
			local noticeText = _pve[i].level .. "级解锁"
			if i==4 then
				local _, isNotWeekend = self._modelMgr:getModel("ProfessionBattleModel"):getOpenState()
				if not isNotWeekend then
					noticeText = "本日不开放"
					des = lang("TIP_ArmyTest_Lock")
				end
				self._item[i].gold:setVisible(false)
			end
			self._item[i].tishi:setString(noticeText)
			self._item[i].tishi:setColor(cc.c3b(120,120,120))

			self:registerTouchEvent(self._item[i],function(x,y) end,function(x,y) end,
				function(x,y)
					self._viewMgr:showTip(des)
					_pve[i].show = false
				end,
				function(x,y) end)
		end

	end
end

function PveView:onTop()
    -- print("界面在最上")
end



function PveView:beforePopAnim()
	PveView.super.beforePopAnim(self)
	for i=1,4 do
		self._item[i]:setCascadeOpacityEnabled(true, true)
		self._item[i]:setOpacity(0)
	end
end
-- 重载出现动画
function PveView:popAnim(callback)
	-- 执行父节点动画
	PveView.super.popAnim(self, nil)

    self:lock(-1)
	-- 定义自己动画
	local delayTime = 0.15
	local moveTime = 0.25
	-- local springTime = 0.2
	local fadeInTime = 0.25
	local moveDis = -200
	-- local springDis = 10
	for i=1,4 do
		local hole = self._item[i]
		local holeInitPos = cc.p(hole:getPositionX(),hole:getPositionY())
		-- local holeSpringPos = cc.p(hole:getPositionX() -springDis,hole:getPositionY())
		local holebeginPos = cc.p(hole:getPositionX(),hole:getPositionY()+moveDis)
		hole:setPosition(holebeginPos)
		local holeDelayTime = delayTime*(i-1)
		local delayAct = cc.DelayTime:create(holeDelayTime)
		local spawn = cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(moveTime,holeInitPos),0.5),cc.FadeIn:create(fadeInTime))
		local seq
        if i == 3 then 
            seq = cc.Sequence:create(delayAct,spawn, cc.CallFunc:create(function ()
                if callback then
                    callback()
                end
            end)) 
        else
            seq = cc.Sequence:create(delayAct,spawn) 
        end
		self._item[i]:runAction(seq)
	end

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), cc.CallFunc:create(function()
        self:unlock()
    end)))
end

function PveView.dtor()
    -- body
    _pve = nil
end
return PveView