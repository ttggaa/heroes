--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-05-23 15:44:07
--
local DrawTreasureResultDialog = class("DrawTreasureResultDialog",BasePopView)
function DrawTreasureResultDialog:ctor(param)
    self.super.ctor(self)
    param = param or {}
    self._drawNum = param.drawNum or 1
    -- 动画暂停节点
    self._mcStopIndex = {70,73,75,79,85}
end

function DrawTreasureResultDialog:getMaskOpacity()
    return 0
end

-- 初始化UI后会调用, 有需要请覆盖
function DrawTreasureResultDialog:onInit()
	local hadClose
    self:registerClickEventByName("closePanel", function()
        if not hadClose then
            -- print("=====================================================")
            hadClose = true
            local callback = self._callback
            if callback and type(callback) == "function" then
                callback()
            end         
            if self._viewMgr then
	            self._viewMgr:closeHintView()               
	        end
            if self.close then                       
                self:close(true)
            end
            UIUtils:reloadLuaFile("treasure.DrawTreasureResultDialog")
        end
    end)
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setVisible(false)

    self._bg = self:getUI("bg")
    -- 抽卡动画
    local offsetx,offsety = 0,0
    local mcName = "baowuchouka_treasurebaowuchouka2"
    if self._drawNum == 5 then
    	mcName = "wulianchou_treasurebaowuchouka2"
    	offsetx,offsety = -20,-60
 	end -- 
    local mcChouka = mcMgr:createViewMC(mcName, false, false)
    mcChouka:setPosition(cc.p(self._bg:getContentSize().width/2+offsetx,self._bg:getContentSize().height/2-10+offsety))
    -- mcChouka:setPlaySpeed(0.01)
    self._resultMc = mcChouka
    self._bg:addChild(mcChouka,10)
    self._resultMc:setVisible(false)
    self._resultMc:gotoAndStop(0)
 	self:getUI("bg.card1Layer"):setVisible(false)
 	self:getUI("bg.card5Layer"):setVisible(false)
 	self:addBgMc()
 	self._desNode = self:getUI("bg.desNode")
 	self._desNode:setCascadeOpacityEnabled(true,true)
 	self._desNode:setOpacity(0)
 	self._promptBg = self:getUI("bg.promptBg")
 	self._promptBg:setCascadeOpacityEnabled(true,true)
 	self._promptBg:setOpacity(0)
 	self._numLabel = self:getUI("bg.desNode.numLabel")
 	self._nextNum = self:getUI("bg.promptBg.nextNum")
 	self._nextNum:setColor(cc.c3b(255, 210, 138))
    self._nextNum:setFontSize(22)
end

function DrawTreasureResultDialog:addBgMc( )
    local offsetX = (960-MAX_SCREEN_WIDTH)/2
    local offsetY = (-640+MAX_SCREEN_HEIGHT)/2
    local mcBgYun = mcMgr:createViewMC("baowuchoukabeij_treasureshopbaowuchouka", true, false)
    mcBgYun:setAnchorPoint(0.5,0.5)
    mcBgYun:setPosition(offsetX,640+offsetY)
    -- mcBgYun:setScale(scale)
    self._bg:addChild(mcBgYun,-1)
    local xscale = MAX_SCREEN_WIDTH / 960
    local yscale = MAX_SCREEN_HEIGHT / 640
    if xscale > yscale then
        mcBgYun:setScale(xscale)
    else
        mcBgYun:setScale(yscale)
    end
    mcBgYun:setCascadeOpacityEnabled(true,true)
    mcBgYun:setOpacity(0)
    mcBgYun:runAction(cc.FadeIn:create(0.6))
end

-- 接收自定义消息
function DrawTreasureResultDialog:reflashUI(data)
	if not data then return end
	self._resultMc:setVisible(true)
	-- self._resultMc:gotoAndStop(85)
	self._resultMc:gotoAndPlay(0)
	local rewards = data.rewards 
	if not rewards or not next(rewards) then return end
	self._awardLy = self:getUI("bg.card" .. self._drawNum .. "Layer") -- 
	self._awardLy:setVisible(true)
	self["init" .. self._drawNum .. "Award"](self,rewards)
	local leftCount,haveExItem,toGetNum = self._modelMgr:getModel("TreasureModel"):countLeftNum()
	self._nextNum:setString(toGetNum)
	self._numLabel:setString(data.treasureCoinNum or 5)
end

function DrawTreasureResultDialog:init1Award( rewards )
	self._awardLy:setVisible(true)
	local cardBg = self._awardLy:getChildByFullName("cardBg")
	self:updateItem(cardBg,rewards[1],1.8,1,function( )
		cardBg:runAction(cc.Sequence:create(
			cc.FadeIn:create(0.8),
			cc.ScaleTo:create(0.2,1),
			cc.CallFunc:create(function(  )
				self:animEnd()
			end)
		))
	end)
end

function DrawTreasureResultDialog:init5Award( rewards )
	self._awardLy:setVisible(true)
	for i=1,5 do
		local cardBg = self._awardLy:getChildByFullName("cardBg_" .. i)
		cardBg:setOpacity(0)
		cardBg:setCascadeOpacityEnabled(true,true)
	end
	
	local showTreasure
	showTreasure = function( idx )
		if not rewards[idx] then 
			self:animEnd() 
			return 
		end
		local firstDelay = idx == 1 and 2 or 0
		local cardBg = self._awardLy:getChildByFullName("cardBg_" .. idx)
		self:updateItem(cardBg,rewards[idx],0.15+firstDelay,idx,function()
			print("idx.....",idx)
			cardBg:runAction(cc.Sequence:create(
		    	cc.DelayTime:create(0 or 1),
		    	cc.FadeIn:create(1)
	    	))
			showTreasure(idx+1)
		end)
	end
	showTreasure(1)
end

function DrawTreasureResultDialog:updateItem( item,data,delayTime,idx,callback )
	if not item then return end
	dump(data)
	local itemType = data.type or data[1]
	local itemId = data.typeId or data[2]
	local num = data.num or data[3]

	local notTreasure = false
	if itemType ~= "tool" then
		itemId = IconUtils.iconIdMap[itemType]
	end
	if not tab.disTreasure[itemId] then
		notTreasure = true
	end
	if notTreasure and num > 0 then
		-- 数量 非宝物显示
		local itemNum = ccui.Text:create()
	    itemNum:setFontSize(22)
	    itemNum:setFontName(UIUtils.ttfName)
	    itemNum:setString(num)
	    itemNum:setPosition(130,105)
	    item:addChild(itemNum,1)
	end

	local color = ItemUtils.findResIconColor(itemId,num)
	local bgNamePrefix = notTreasure and "awardBg" or "cardBg"
	local bgName = bgNamePrefix .. (color or 2) .. "_treasureShop.png"
	print(bgName)
	item:loadTexture(bgName,1)

	local toolD = tab.tool[itemId]
	local icon = IconUtils:createItemIconById({itemId = itemId,num = num,itemData = toolD})  --effect = true 不加特效 --treasureCircle 不加内框
    icon:setSwallowTouches(true)
    icon:setAnchorPoint(0,0)
    icon:setPosition(48,95)
    icon:setVisible(false)
    item:addChild(icon)
    local iconColor = icon:getChildByFullName("iconColor")
    iconColor:setVisible(false)
    local boxIcon = icon:getChildByFullName("boxIcon")
    boxIcon:setVisible(false)

    local itemName = ccui.Text:create()
    itemName:setFontSize(22)
    itemName:setFontName(UIUtils.ttfName)
    itemName:setString(lang(toolD.name))
    itemName:setPosition(94,25)
    item:addChild(itemName)
    item:setCascadeOpacityEnabled(true,true)
    item:setOpacity(0)
	local isDis = tab.disTreasure[itemId] and tab.disTreasure[itemId].produce == 2	                    
    local isOTreasure = isDis
	local curIdx = idx
    if isOTreasure then
    	if not self._drawNum == 1 then
			self._resultMc:gotoAndStop(self._mcStopIndex[curIdx])
		end
		-- self._resultMc:stop()
        local nextFunc = callback
        item:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(delayTime or 1),
	    	cc.CallFunc:create(function( )
		        self._viewMgr:showDialog("global.GlobalShowTreasureDialog", {itemId = itemId, notLoadRes = true, callback = function() 
		            if not self._drawNum == 1 then
		            	self._resultMc:gotoAndPlay(self._mcStopIndex[curIdx])
		            end
		            -- self._resultMc:play()
		            icon:setVisible(true)
			        nextFunc()
		        end})
	    	end)
	    ))
    else
    	-- self._resultMc:play()
	    item:runAction(cc.Sequence:create(
	    	cc.DelayTime:create(delayTime or 1),
	    	cc.CallFunc:create(function( )
	    		-- self._resultMc:gotoAndPlay(self._mcStopIndex[curIdx])
		        icon:setVisible(true)
		        callback()
	    	end)
	    ))
    end
end

function DrawTreasureResultDialog:animEnd( )
	self._desNode:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.FadeIn:create(0.2)
	))
	self._promptBg:runAction(cc.Sequence:create(
		cc.DelayTime:create(0.1),
		cc.FadeIn:create(0.2),
		cc.DelayTime:create(0.8),
		cc.CallFunc:create(function( )
			self._closePanel:setVisible(true)
			--[[ 调试代码
			self._viewMgr:showDialog("global.GlobalShowTreasureDialog", {itemId = 40422, notLoadRes = true, callback = function() 
		    end})
			--]]
		end)
	))

end

return DrawTreasureResultDialog