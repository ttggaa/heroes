--[[
    Filename:    HappyPopResultView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-14 16:17
    Description: 法术特训小游戏 结算界面
--]]

local HappyPopResultView = class("HappyPopResultView", BasePopView)

function HappyPopResultView:ctor(param)
	HappyPopResultView.super.ctor(self)

	self._callback1 = param.callback1  --enter
	self._callback2 = param.callback2  --cancle
end

function HappyPopResultView:onInit()
	local title = self:getUI("bg.bg2.titleBg.titleLab")
	UIUtils:setTitleFormat(title, 1)

	local tipDes = self:getUI("bg.bg2.tipDes")
	local show1 = self:getUI("bg.bg2.show1")
	local show2 = self:getUI("bg.bg2.show2")
	local maxImg1 = self:getUI("bg.bg2.show1.maxImg")
	local maxImg2 = self:getUI("bg.bg2.show2.maxImg")
	local noTip = self:getUI("bg.bg2.show1.Label_85")
	tipDes:setVisible(false)
	show1:setVisible(false)
	show2:setVisible(false)
	maxImg1:setVisible(false)
	maxImg2:setVisible(false)
	noTip:setVisible(false)

	local againBtn = self:getUI("bg.bg2.againBtn")
	self:registerClickEvent(againBtn, function()
		if self._callback1 then
			self._callback1()
		end
		self:close()
		end)

	local quitBtn = self:getUI("bg.bg2.quitBtn")
	self:registerClickEvent(quitBtn, function()
		if self._callback2 then
			self._callback2()
		end
		self:close()
		end)

	self:setListenReflashWithParam(true)
	self:listenReflash("HappyPopModel", self.listenModelHandle)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.happyPop.HappyPopResultView")

        elseif eventType == "enter" then
        	
        end
    end)

end

function HappyPopResultView:listenModelHandle(inData)
	if inData == "close" then
		self:close()
	end
end

function HappyPopResultView:reflashUI(inData)
	if not inData.data or not next(inData.data) then
		return
	end

	dump(inData, "inData")

	local curData = inData.data
	local lastInfo = inData.lastInfo

	local curS = curData["info"]["s"] or 0   				--法术卷轴
	local curN = curData["info"]["n"] or 0 					--英雄碎片
	local curScore = curData["source"] or 0   				--当局分数
	local lastMScore = lastInfo["score"] or 0   			--上一局最高分
	local curMScore = curData["info"]["score"] or 0 		--当前最高分

	local maxS = tab.magicTrainingCfg["LIMIT_SCROLL_NUM"].value
	local maxN = tab.magicTrainingCfg["LIMIT_HERO_NUM"].value
	
	local tipDes = self:getUI("bg.bg2.tipDes")
	local show1 = self:getUI("bg.bg2.show1")
	local show2 = self:getUI("bg.bg2.show2")
	local maxImg1 = self:getUI("bg.bg2.show1.maxImg")
	local maxImg2 = self:getUI("bg.bg2.show2.maxImg")
	local noTip = self:getUI("bg.bg2.show1.Label_85")

	if curS >= maxS and curN >= maxN then   --奖励上限
		if curData["rewards"] and next(curData["rewards"]) then   	--第一次达上限
			show1:setVisible(true)
			tipDes:setVisible(true)

			local scoreNum = self:getUI("bg.bg2.show1.scoreNum")
			scoreNum:setString(curScore)
			self:createRwdItem(curData["rewards"])
			tipDes:setString(lang("MAGICTRAINING_COMPLETE_TIPS2"))

		else   														--达上限后
			show2:setVisible(true)
			tipDes:setVisible(true)

			local scoreNum = self:getUI("bg.bg2.show2.scoreNum")
			scoreNum:setString(curScore)
			local maxNum = self:getUI("bg.bg2.show2.maxNum")
			maxNum:setString(curMScore)
			tipDes:setString(lang("MAGICTRAINING_COMPLETE_TIPS3"))
		end

	else
		if curData["rewards"] and next(curData["rewards"]) then
			show1:setVisible(true)
			tipDes:setVisible(true)

			local scoreNum = self:getUI("bg.bg2.show1.scoreNum")
			scoreNum:setString(curScore)
			self:createRwdItem(curData["rewards"])
			tipDes:setString(lang("MAGICTRAINING_COMPLETE_TIPS1"))
		else
			show1:setVisible(true)
			noTip:setVisible(true)
			show1:setPositionY(150)

			local scoreNum = self:getUI("bg.bg2.show1.scoreNum")
			scoreNum:setString(curScore)
			noTip:setString(lang("MAGICTRAINING_COMPLETE_TIPS4"))
		end
	end

	if curScore > lastMScore then
		maxImg1:setVisible(true)
		maxImg2:setVisible(true)
	end
end

function HappyPopResultView:createRwdItem(inRwd)
    if not inRwd or next(inRwd) == nil then
    	return
    end

    local show1 = self:getUI("bg.bg2.show1")
    for i,v in ipairs(inRwd) do
    	local num = v["num"]
    	local iType = v["type"]
    	local typeId = v["typeId"]
        local itemId
        if IconUtils.iconIdMap[iType] then
            itemId = IconUtils.iconIdMap[iType]
        else
            itemId = typeId
        end

        local itemIcon = IconUtils:createItemIconById({itemId = itemId, num = num})
        itemIcon:setScale(0.7)
        itemIcon:setPosition(120 + (itemIcon:getContentSize().width * itemIcon:getScale() + 8)* (i-1), -15)
        itemIcon:setSwallowTouches(false)
        show1:addChild(itemIcon)
    end
end


return HappyPopResultView