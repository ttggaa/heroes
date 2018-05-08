--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-10-24 17:32:23
--
local AdventureStarView = class("AdventureStarView",BasePopView)
function AdventureStarView:ctor(param)
    self.super.ctor(self)
    self._exactStars = param.exactStars
end

-- 初始化UI后会调用, 有需要请覆盖
function AdventureStarView:onInit()
	self:registerClickEventByName("closeBtn",function( )
		DialogUtils.showShowSelect({desc=lang("zhanxing_quit"),callback1=function( )
			self:close(true)
			UIUtils:reloadLuaFile("activity.adventure.AdventureStarView")
		end})
	end)
	self:registerClickEventByName("bg.okBtn",function( )
		if self._modelMgr:getModel("AdventureModel"):inResetTime() then
			self:close(true)
			UIUtils:reloadLuaFile("activity.adventure.AdventureStarView")
			return
		end
		if self._leftNum == 1 then
			local isOk = self:checkSelect()
			if isOk == -1 then
				self._viewMgr:showTip(lang("zhanxing_tip1"))
			elseif isOk == 1 then
				self._serverMgr:sendMsg("AdventureServer", "chooseNum", {win=1}, true, { }, function(result)
			    	dump(result,"select star true")
			    	ViewManager:getInstance():showTip(lang("zhanxing_success"))
			    	ScheduleMgr:delayCall(500, self, function( )
			    		if self and self.close then
					    	self:close(true)
					    	DialogUtils.showGiftGet({gifts=result.rwd})
					    end
			    	end)
			    end)
			else
				self._viewMgr:showTip(lang("zhanxing_fail"))
				self:close(true)
			end
		else
			local isOk = self:checkSelect()
			if isOk == 0 then
		        self._leftNum = self._leftNum - 1
		        self._numLab:setString(self._leftNum)
		        self._viewMgr:showTip(lang("zhanxing_tip2"))
		        self._selectStars = {0,0}
		        self:selectStar()
		        self._selectStars = {}
			elseif isOk == -1 then
				self._viewMgr:showTip(lang("zhanxing_tip1"))
			else 
				self._serverMgr:sendMsg("AdventureServer", "chooseNum", {win=1}, true, { }, function(result)
			    	dump(result,"select star true")
			    	local tempResult = result
			    	ViewManager:getInstance():showTip(lang("zhanxing_success"))
			    	ScheduleMgr:delayCall(500, self, function( )
			    		if self and self.close then
					    	self:close(true)
					    	DialogUtils.showGiftGet({gifts=tempResult and tempResult.rwd})
					    end
			    	end)
			    end)
			end
		end
	end)
	local wallImg = self:getUI("bg.wallImg")
	wallImg:setScale(1.1)
	wallImg:setVisible(true)
	wallImg:loadTexture("asset/bg/bg2_adventure.jpg")
	wallImg:setOpacity(0)
	wallImg:runAction(cc.FadeIn:create(0.5))

	self._numLab = self:getUI("bg.num")
	self._leftNum = 2 -- 尝试次数 选一次少一次
	self._numLab:setString(self._leftNum)
	self._selectStars = {}
	self._stars = {}
	for i=1,12 do
		local star = self:getUI("bg.star_" .. i)
		star:setBackGroundColorOpacity(0)
		self._stars[i] = star
		-- local numLab = ccui.Text:create()
		-- numLab:setFontSize(40)
		-- numLab:setPosition(50,50)
		-- numLab:setString(i)
		-- star:addChild(numLab)
		self:registerClickEvent(star,function() 
			self:selectStar(i)
			dump(self._selectStars)
		end)
	end

	-- 提示
	local promptPanel = self:getUI("bg.promptPanel")
	promptPanel:setVisible(false)
	promptPanel:setSwallowTouches(false)
	self:registerClickEvent(promptPanel,function() 
		promptPanel:stopAllActions()
		promptPanel:setVisible(false)
	end)
	self:registerClickEventByName("bg.infoBtn",function() 
		promptPanel:setVisible(true)
		promptPanel:stopAllActions()
		promptPanel:runAction(cc.Sequence:create(
			cc.DelayTime:create(1),
			cc.CallFunc:create(function( )
				promptPanel:setVisible(false)
			end)
		))
	end)

	local desLab = self:getUI("bg.promptPanel.desLab")
	desLab:setString("")
    local prompt = lang("zhanxing_1.2")
    prompt = string.gsub(prompt,"{$star1}","[color=f5951e00]" .. AdventureConst.STATRS[self._exactStars[1]] .. "[-]")
    prompt = string.gsub(prompt,"{$star2}","[color=f5951e00]" .. AdventureConst.STATRS[self._exactStars[2]] .. "[-]")
    prompt = string.gsub(prompt,"6d98d8","865c30" )

	prompt = "[color=865c30]" .. prompt .."[-]"
    local lenth = string.len(prompt)
    rtx = RichTextFactory:create(prompt,desLab:getContentSize().width,desLab:getContentSize().height)
    -- rtx:enablePrinter(true)
    rtx:formatText()
    -- rtx:setVerticalSpace(5)
    -- rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getInnerSize().height
    rtx:setPosition(cc.p(w/2,desLab:getContentSize().height-h/2))
    UIUtils:alignRichText(rtx,{hAlign = "left"})
    rtx:setName("rtx")
    desLab:addChild(rtx,99)

end

function AdventureStarView:checkSelect( )
	local result = 0
	if #self._selectStars < 2 then 
		self._viewMgr:showTip(lang("zhanxing_tip1"))
		return -1
	end
	if (self._selectStars[1]+self._selectStars[2] == self._exactStars[1] + self._exactStars[2]) and
		(self._selectStars[1]==self._exactStars[1] or self._selectStars[1]==self._exactStars[2] ) then
		result = 1
	end

	return result 
end

-- 选中
function AdventureStarView:selectStar( idx )
	-- self._stars[idx]:setColor(color)
	if idx then
		local isNew = true
		local removeId
		for i,v in ipairs(self._selectStars) do
			if v == idx then
				isNew = false
				removeId = i
			end
		end
		if isNew or not next(self._selectStars) then
			table.insert(self._selectStars,1,idx)
			audioMgr:playSound("Treasure_mishi")
		elseif removeId then
			table.remove(self._selectStars,removeId)
			self:removeStarMc(idx)
		end
		if #self._selectStars > 2 then
			self._selectStars[#self._selectStars] = nil
		end
	end
	for i,star in ipairs(self._stars) do
		for _,starId in ipairs(self._selectStars) do
			if i == starId then
				star:setColor(cc.c3b(255, 0, 0))
				self:addStarMc(i)
				break
			else
				star:setColor(cc.c3b(255, 255, 255))
				self:removeStarMc(i)
			end
		end
	end
end

function AdventureStarView:addStarMc( idx )
	local star = self:getUI("bg.star_" .. idx)
	local starMc = star:getChildByName("starMc")
	if not starMc then
		local mcName = AdventureConst.STATR_MCS[idx][1]
		print("mc idx name",mcName)
		starMc = mcMgr:createViewMC(mcName, true, false, function (_, sender)
	    end,RGBA8888)
		starMc:setName("starMc")
		local offsetx,offsety = AdventureConst.STATR_MCS[idx][2].x,AdventureConst.STATR_MCS[idx][2].y 
	    starMc:setPosition(star:getContentSize().width/2+offsetx,star:getContentSize().height/2+offsety)
	    star:addChild(starMc,999)
	    local scale = AdventureConst.STATR_MCS[idx][3]
	    if scale then
	    	if type(scale) == "table" then
	    		starMc:setScale(scale[1],scale[2])
	    	else
		    	starMc:setScale(scale)
		    end
	    end
	else
		starMc:setVisible(true)
	end
end

function AdventureStarView:removeStarMc( idx )
	local star = self:getUI("bg.star_" .. idx)
	local starMc = star:getChildByName("starMc")
	if starMc then
		starMc:setVisible(false)
	end
end

-- 接收自定义消息
function AdventureStarView:reflashUI(data)

end

return AdventureStarView