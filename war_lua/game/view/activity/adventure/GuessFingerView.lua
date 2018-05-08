--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-22 14:24:28
--
local GuessFingerView = class("GuessFingerView",BasePopView)
function GuessFingerView:ctor(data)
	data = data or {}
    self.super.ctor(self)
    self._callback = data.callback
end

function GuessFingerView:getMaskOpacity()
	return 230
end


-- 初始化UI后会调用, 有需要请覆盖
function GuessFingerView:onInit()
	-- 设置必胜花费
	-- local costLab = self:getUI("bg.costLab")
	-- costLab:setString(tab.activity907[13].param)
	self._rewardBg = self:getUI("bg.rewardBg")
	self._guessBg = self:getUI("bg_0.guessBg")
	self._guessBg:setPosition(480,353)
	self._titleImg = self:getUI("bg.titleImg")
	-- 2016.12.15 增加 再来一次逻辑
	self._aginPanel = self:getUI("bg.aginPanel")
	self._aginPanel:setVisible(false)
	self._costLab = self:getUI("bg.aginPanel.costLab")
	self._costLab:setString(tab.activity907[13].param)
	self._aginBtn = self:getUI("bg.aginPanel.aginBtn")
	self:registerClickEvent(self._aginBtn,function()
		-- 判断钱够不够
		local hadNum = self._modelMgr:getModel("UserModel"):getData().gem
		local cost = tab.activity907[13].param
		if hadNum < cost then
			DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
                local viewMgr = ViewManager:getInstance()
                viewMgr:showView("vip.VipView", {viewType = 0})
            end})
			return
		end
		self:sendGuessMsg(self._selGestureId)
	end)
	self._quitBtn = self:getUI("bg.aginPanel.quitBtn")
	
	self:registerClickEventByName("bg.aginPanel.quitBtn",function( )
		self:close()
		UIUtils:reloadLuaFile("activity.adventure.GuessFingerView")
	end)
	
	self._confirmBtn = self:getUI("bg.confirmBtn")
	self:registerClickEventByName("bg.confirmBtn",function( )
		self:sendGuessMsg(self._selGestureId)
		UIUtils:reloadLuaFile("activity.adventure.GuessFingerView")
	end)

	self._awardTitle = self:getUI("bg.awardTitle")
	self._awardTitle:setString("胜利奖励预览")
	self._awardTitle:setColor(UIUtils.colorTable.ccUIBasePromptColor)
	

	self._guessTitle = self:getUI("bg_0.guessTitle")
	self._guessTitle:setPosition(480,545)

	self._selGestureId = nil
	self._gestures = {}
	for i=1,3 do
		local finger = self:getUI("bg.finger_".. i )
		finger:setZOrder(2)
		finger.bg  = self:getUI("bg.fingerbg_".. (i-1) )
		self._gestures[i] = finger 
		self:registerClickEvent(finger.bg,function( )
			self:clickGensture(i)
		end)
	end
	self:clickGensture(1)
	self:refreshAward()

	self._bg = self:getUI("bg")
	self._bgGuessAnim = self:getUI("bg_0")
	self._bgGuessAnim:setVisible(false)
end

-- 第一次进入调用, 有需要请覆盖
function GuessFingerView:onShow()

end

-- 接收自定义消息
function GuessFingerView:reflashUI(data)
	-- 2016.12.15 如果是猜拳失败 不弹新 板子
	if data and data.lose then
		self._confirmBtn:setVisible(false)
		self._aginPanel:setVisible(true)
		self._titleImg:loadTexture("figerTitleLose_adventure.png",1)
		self._bg:setVisible(true)
		self._bgGuessAnim:setVisible(false)
	else
		self._confirmBtn:setVisible(true)
		self._aginPanel:setVisible(false)
		self._titleImg:loadTexture("figerGuessTitle_adventure.png",1)
		-- self._bg:setVisible(false)
		-- self._bgGuessAnim:setVisible(false)
	end
end

-- 初始化猜拳格子
function GuessFingerView:clickGensture( idx )
	-- body
	-- if self._selGestureId then return end
	self._selGestureId = idx
	for i=1,3 do
		self:setSelect(i,idx == i)
	end
	audioMgr:playSound("Treasure_caiquanchoose")
	-- 选中手势之后就 向后端发协议 移除 恢复原逻辑
	-- self:sendGuessMsg(self._selGestureId)
	-- UIUtils:reloadLuaFile("activity.adventure.GuessFingerView")
end

function GuessFingerView:setSelect( idx,isSelected )
	local finger = self._gestures[idx]
	if not finger then return end
	if isSelected then
		finger:setScale(1)
		finger.bg:setColor(cc.c3b(255, 255, 255))
		finger.bg:setZOrder(1)
	else
		finger:setScale(0.8)
		finger.bg:setColor(cc.c3b(66, 66, 66))
		finger.bg:setZOrder(0)
	end
end

-- 展示奖励
function GuessFingerView:refreshAward( )
	self._rewardBg:removeAllChildren()
	local awards = tab:Activity907gift(6).reward[1]
	local offset = -#awards/2*90+self._rewardBg:getContentSize().width/2
	for i,award in ipairs(awards) do
		local itemId,itemNum
		if award[1] == "tool" then
			itemId,itemNum = award[2],award[3]
		else
			itemId,itemNum = IconUtils.iconIdMap[award[1]],award[3]
		end
		local icon = IconUtils:createItemIconById({itemId = itemId,num = itemNum})
		icon:setScale(0.7)
		icon:setPosition(offset+(i-1)*90,10)
		self._rewardBg:addChild(icon)
	end
end

function GuessFingerView:sendGuessMsg( fingerId )
	-- 休息时弹提示 关闭界面
	if self._modelMgr:getModel("AdventureModel"):inResetTime() then
		self:close()
		ViewManager:getInstance():showTip("小骷髅正在准备开启新的冒险，还请耐心等待一会哦~")
		return 
	end
	self._serverMgr:sendMsg("AdventureServer", "guessFinger", {fg = (fingerId or 1)}, true, { }, function(result)
		dump(result)
		if fingerId == 4 then 
			local winFinger = GRandom(1,3)
			local comFinger = winFinger-1
			if comFinger == 0 then comFinger = 3 end
			self:showGuessAnim({win=result.win,rewards=result.rwd,fingerId = winFinger,com=comFinger})
			-- if self.close then
			-- 	self:close()
			-- end
			-- ViewManager:getInstance():showDialog("activity.adventure.GuessFingerResultView",{win=result.win,rewards=result.rwd,com=result.com})
		else
			-- local result = {
			-- 	win = 1,
			-- 	com = 2,
			-- }
			self:showGuessAnim({win=result.win,rewards=result.rwd,fingerId = fingerId,com=result.com})
		end
		self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png"})
		self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png",delayReflash = true})
	
	end)
end
-- bu quan jiandao
-- 
-- 猜拳动画
-- 
local fingerMap = {
	[1] = 1,
	[2] = 2,
	[3] = 3
}
function GuessFingerView:showGuessAnim(param)
	dump(param)
	self._bg:setVisible(false)
	self._bgGuessAnim:setVisible(true)
	local finger1 = self._bgGuessAnim:getChildByName("finger_1")
	local finger2 = self._bgGuessAnim:getChildByName("finger_2")
	finger1:setOpacity(0)
	finger2:setOpacity(0)
	finger2:setFlippedX(false)

	-- 拳头动画1
	local mcFinger1 = finger1:getChildByName("mc1")
	if not mcFinger1 then
		mcFinger1 = mcMgr:createViewMC("zuoquan_adventurechufa", false, false, function (_, sender)
	    end,RGBA8888)

	    mcFinger1:setPosition(50,80)
	    finger1:addChild(mcFinger1,999)
	end	
    self:updateFingerMc(mcFinger1,fingerMap[param.fingerId])

    local mcFinger1 = finger1:getChildByName("mc1")
	if not mcFinger1 then
	    mcFinger2 = mcMgr:createViewMC("youquan_adventurechufa", false, false, function (_, sender)
	    end,RGBA8888)

	    mcFinger2:setPosition(70,80)
	    finger2:addChild(mcFinger2,999)
	end
    self:updateFingerMc(mcFinger2,fingerMap[param.com],function( )
    	if self.close then
			if self._callback then
				self._callback()
			end
			if param.win == -1 then
				self:reflashUI({lose=true})
				audioMgr:playSound("Treasure_caiquanfail")
			else
				audioMgr:playSound("Treasure_caiquanwin")
				self:close()
			end
			ViewManager:getInstance():showDialog("activity.adventure.GuessFingerResultView",{win=param.win,rewards=param.rwd,com=param.com})
		end
    end)
end
local fingerFrames = {
	[1] = {31,37},
	[2] = {26,30},
	[3] = {20,25},

}
-- 更新掷骰子动画
function GuessFingerView:updateFingerMc( fingerMc,fingerNum,callback )
    if not fingerMc then return end
    fingerMc:setVisible(true)
    fingerMc:gotoAndPlay(0)
    local mcCallback1
    mcCallback1 = fingerMc:addCallbackAtFrame(19,function( )
        local beginFrame = fingerFrames[fingerNum][1] --20+(fingerNum-1)*5
        local endFrame = fingerFrames[fingerNum][2] --math.min(20+(fingerNum-1)*5+5,37)
        -- if fingerNum == 3 then
        --     beginFrame = 31
        --     endFrame = 37
        -- end
        fingerMc:removeCallback(mcCallback1)
        fingerMc:gotoAndPlay(beginFrame)
        local mcCallback2
        mcCallback2 = fingerMc:addCallbackAtFrame(endFrame,function( )
            fingerMc:stop()
            fingerMc:runAction(cc.Sequence:create(
	            cc.DelayTime:create(0.5),
	            cc.CallFunc:create(function( )
		            fingerMc:removeCallback(mcCallback2)
		            fingerMc:setVisible(false)
		            if callback then
		                callback()
		            end
				end)
			))

        end)
    end)
end

return GuessFingerView