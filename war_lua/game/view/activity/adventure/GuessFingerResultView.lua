--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-22 14:25:05
--
local GuessFingerResultView = class("GuessFingerResultView",BasePopView)
function GuessFingerResultView:ctor(data)
    self.super.ctor(self)

end

function GuessFingerResultView:getMaskOpacity()
	return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function GuessFingerResultView:onInit()
	self._reward_panel = self:getUI("bg.reward_panel")

	self:registerClickEventByName("bg.okBtn",function( )
		self:close()
		UIUtils:reloadLuaFile("activity.adventure.GuessFingerResultView")
	end)

	self._titleImg = self:getUI("bg.titleImg")
	self._des = self:getUI("bg.des")
	self._des:setString("奖励预览")
	self._des:setColor(UIUtils.colorTable.ccUIBasePromptColor)

	self._role_img = self:getUI("bg.role_img")
	self._role_img:loadTexture("asset/bg/global_reward_img.png")

	-- 2016.12.14 增加 再来一次逻辑
	self._okBtn = self:getUI("bg.okBtn")
	self._aginPanel = self:getUI("bg.aginPanel")
	self._aginPanel:setVisible(false)
	self._costLab = self:getUI("bg.aginPanel.costLab")
	self._costLab:setString(tab.activity907[13].param)
	self._winBtn = self:getUI("bg.aginPanel.winBtn")
	self:registerClickEvent(self._winBtn,function()
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

		local userModel = self._modelMgr:getModel("UserModel")
		dump(userModel:getData(),"userData...===")
		userModel:updateUserData({freeGem=userModel:getData().gem-cost})
		self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png"})
		self._viewMgr:showNavigation("global.UserInfoView",{types = {"Dice","Gold","Gem",},title = "globalTitleUI_yijitanxian.png",delayReflash = true})
	
		self:close() 
		self._viewMgr:showDialog("activity.adventure.GuessFingerView")
	end)
end

-- 第一次进入调用, 有需要请覆盖
function GuessFingerResultView:onShow()

end

-- 接收自定义消息
function GuessFingerResultView:reflashUI(data)
	local win = data.win
	local resultDes = "Win"
	if win == -1 then
		win = 3
		resultDes = "Lose"
	elseif win == 0 then
		win = 2
		resultDes = "Draw"
	elseif win == 1 then
		win = 1
	end
	-- -- 结果为 负 显示再来一次
	-- if win == 3 then
	-- 	self._aginPanel:setVisible(true)
	-- 	self._okBtn:setPosition(560,178)
	-- else
	-- 	self._aginPanel:setVisible(false)
	-- 	self._okBtn:setPosition(480,178)
	-- end
	self._titleImg:loadTexture("figerTitle".. resultDes .. "_adventure.png",1)
	self._des:setString("")
	local awards = tab:Activity907gift(6).reward[win]
	local offset = -#awards/2*115+self._reward_panel:getContentSize().width/2
	for i,award in ipairs(awards) do
		print(i,v)
		local itemId,itemNum
		if award[1] == "tool" then
			itemId,itemNum = award[2],award[3]
		else
			itemId,itemNum = IconUtils.iconIdMap[award[1]],award[3]
		end
		local icon = IconUtils:createItemIconById({itemId = itemId,num = itemNum})
		-- icon:setScale(0.7)
		icon:setPosition(offset+(i-1)*115,0)
		self._reward_panel:addChild(icon)
	end
end

return GuessFingerResultView