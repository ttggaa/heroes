--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-17 11:55:42
--
local ArenaTurnCardView = class("ArenaTurnCardView",BasePopView)
function ArenaTurnCardView:ctor(param)
    self.super.ctor(self)
    dump(param)
    param = param or {}
    local awards = param.awards or {}
    self._awards =  {}
    if awards["1"] then
    	for k,v in pairs(awards) do -- 处理成正常数组
			self._awards[tonumber(k)] = v
		end
    else
    	self._awards = awards
    end
    	
    self._titleType = param.titleType  or 1
end

function ArenaTurnCardView:getMaskOpacity()
    return 230
end
-- 初始化UI后会调用, 有需要请覆盖
function ArenaTurnCardView:onInit()
	self._closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEventByName("bg.closeBtn",function() 
		self:close()
		UIUtils:reloadLuaFile("arena.ArenaTurnCardView")
	end)
	self._closeBtn:setVisible(false)
	self._closePanel = self:getUI("closePanel")
	self:registerClickEventByName("closePanel",function() 
		self:close()
		UIUtils:reloadLuaFile("arena.ArenaTurnCardView")
	end)
	self._closePanel:setVisible(false)
	-- 倒计时
	self._countNode = self:getUI("bg.countNode")
	local timeLab 	= ccui.TextBMFont:create("0", UIUtils.bmfName_timecount)
    timeLab:setAnchorPoint(cc.p(0,0))
    timeLab:setPosition(20,20)
    timeLab:setScale(.8)
    self._countNode:addChild(timeLab)
    self._timeLab 	= timeLab
    self._selectNum = 0 
    self._noTouch 	= true
	self._cards = {}
	for i=1,3 do
		local card 	   = self:getUI("bg.card" .. i)
		-- card:setVisible(false)
		self._cards[i] = card
		local num 	= card:getChildByName("num")
		num:setColor(cc.c3b(255, 252, 226))
	    num:enable2Color(1, cc.c4b(255, 232, 125, 255))
	    num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
		num:setString("")
		local nameBg 	= card:getChildByName("nameBg")
		nameBg:setVisible(false)
		-- 点击效果
		card:setScaleAnim(false)
		self:registerTouchEvent(card,function(_,x,y) 
			-- down
			if self._noTouch then return end
			card:stopAllActions()
			card:setScale(1)
			card:runAction(cc.ScaleTo:create(0.1,1.05))
			card:setBrightness(40)
		end,function(_,x,y) 
			-- move
		end,function(_,x,y) 
			-- up
			if self._noTouch then return end
			self._timeLab:stopAllActions()
			self._timeLab:setVisible(false)
			card:runAction(cc.ScaleTo:create(0.1,1))
			card:setBrightness(0)
			self:runTurnAnim(i,true)
		end,function(_,x,y) 
			-- out
			if self._noTouch then return end
			card:runAction(cc.ScaleTo:create(0.1,1))
			card:setBrightness(0)
		end)
	end
	self._bg1 	   = self:getUI("bg.bg1")
	self._title    = self:getUI("bg.title")
	if self._titleType == 2 then
		self._title:loadTexture("arenaDraw_title_award.png",1)
	else
		self._title:loadTexture("arenaDraw_title_sweep.png",1)
	end
	self._subTitle = self:getUI("bg.subTitle")
	self._subTitle:setColor(cc.c3b(255, 252, 226))
    self._subTitle:enable2Color(1, cc.c4b(255, 232, 125, 255))
    self._subTitle:setString(lang("SWEEP_ARENA_01") or "")

	self._des = self:getUI("bg.des")
	self._awardName = self:getUI("bg.awardName")
	self._des:setVisible(false)
	self._awardName:setVisible(false)
	self:animBegin()
end

function ArenaTurnCardView:animBegin( )
	-- 抬头动画
	self._title:setOpacity(0)
	self._title:setScale(4)
	self._title:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(.2,0.8),
			cc.FadeIn:create(.2)
		),
		cc.ScaleTo:create(.1,1),
		cc.CallFunc:create(function( )
			local selMc = mcMgr:createViewMC("zhandoujiangliguang_arenafanpaizi", true,true)
			selMc:setPosition(self._title:getContentSize().width/2+50,self._title:getContentSize().height/2+10)
        	self._title:addChild(selMc)
		end)
	))
	-- 背景图动画
	self._bg1:setOpacity(0)	
	self._bg1:runAction(cc.Sequence:create(
		cc.DelayTime:create(.3),
		cc.Spawn:create(
			cc.FadeIn:create(.2),
			cc.ScaleTo:create(0.2,1,1.05)
		),
		cc.ScaleTo:create(0.2,1)
	))	
	-- 卡牌拍击动画
	for i,card in ipairs(self._cards) do
		card:setCascadeOpacityEnabled(true)
		card:setOpacity(0)
		local cardClone = card:clone()
		cardClone:setPurityColor(255, 255, 255)
		cardClone:setVisible(false)
		cardClone:setPosition(cardClone:getContentSize().width/2,cardClone:getContentSize().height/2)
		card:addChild(cardClone)
		cardClone:setOpacity(200)
		cardClone:runAction(cc.Sequence:create(
			cc.DelayTime:create(.5+(i-1)*0.1),
			cc.CallFunc:create(function( )
				cardClone:setVisible(true)
			end),
			cc.ScaleTo:create(0.1,1.1),
			cc.Spawn:create(
				cc.FadeOut:create(.05),
				cc.ScaleTo:create(0.1,1.12)
			),
			cc.CallFunc:create(function( )
				cardClone:setOpacity(255)
				cardClone:removeFromParent()
			end)
		))
		card:runAction(cc.Sequence:create(
			cc.DelayTime:create(.5+(i-1)*0.1),
			cc.FadeIn:create(0.1)
		))
	end
	-- 倒计时开始
	local MaxCount = 15
	self._timeLab:setString(MaxCount)
	self._timeLab:setVisible(false)
	self._timeLab:runAction(cc.Sequence:create(
		cc.DelayTime:create(1),
		cc.CallFunc:create(function( )
			self._noTouch = false
			self._timeLab:stopAllActions()
			self._timeLab:setVisible(true)
			self._timeLab:runAction(cc.RepeatForever:create(
				cc.Sequence:create(
					cc.CallFunc:create(function( )
						self._timeLab:setString(MaxCount)
						MaxCount = MaxCount - 1
						if MaxCount < 0 then
							self._noTouch = true
							self._timeLab:stopAllActions()
							self._timeLab:setVisible(false)
							self:randOneCard()
						end
					end),
					cc.DelayTime:create(1)
				)
			))
		end)
	))
end

function ArenaTurnCardView:randOneCard( )
	self:runTurnAnim(1,true)
end

function ArenaTurnCardView:runTurnAnim( cardIdx, bySelf )
	-- body
	local card = self._cards[cardIdx]
	print(cardIdx)
	if not card or card._inTurnning then return end
	card._inTurnning = true
	self._noTouch = true
    local orbit = cc.ScaleTo:create(.25,0,1)
    local orbit1 = cc.ScaleTo:create(.25,1,1)
    card:runAction(cc.Sequence:create(
        orbit:clone(),
        cc.Spawn:create(
	        orbit1:clone(),
	        cc.CallFunc:create(function( )
	        	if not self._closePanel:isVisible() then
	        		self._closePanel:setEnabled(false)
		        	self._closePanel:setVisible(true)
		        	self._closePanel:runAction(cc.Sequence:create(
		        		cc.DelayTime:create(1),
		        		cc.CallFunc:create(function(  )
		        			self._closePanel:setEnabled(true)
		        		end)
		        	))
		        end
	            card:loadTexture("arenaDraw_card_c.png",1)
	            local awardIdx = cardIdx
	            if bySelf then
	            	awardIdx = 1
	            end
	            -- 加上动画
				local awards 	= self._awards[1] or self._awards[tostring(1)]
				table.remove(self._awards,1)
				if not awards or not next(awards) then return end
				local itemType 	= awards[1] or awards["type"]
				local itemId 	= awards[2] or awards["typeId"]
				local itemNum 	= awards[3] or awards["num"]
				if itemType ~= "tool" then
					itemId  = IconUtils.iconIdMap[itemType]
				end
				local toolD = tab.tool[itemId]
				local num 	= card:getChildByName("num")
				num:setString(lang(toolD.name) or "") 
				local nameBg 	= card:getChildByName("nameBg")
				nameBg:setVisible(true)
				local art = toolD.art or toolD.icon
				local icon  = IconUtils:createItemIconById({itemId = itemId,num=itemNum})
				-- ccui.ImageView:create()
				-- local filename = IconUtils.iconPath .. toolD.art .. ".png"
				-- local sfc = cc.SpriteFrameCache:getInstance()
				-- if not sfc:getSpriteFrameByName(filename) then
				-- 	filename = IconUtils.iconPath .. toolD.art .. ".jpg"
				-- end
				-- icon:loadTexture(filename,1)
				icon:setAnchorPoint(0.5,0.5)
				icon:setScale(0.7)
				icon:setPosition(card:getContentSize().width/2,card:getContentSize().height/2+20)
				card:addChild(icon,10)
				if bySelf then

					local color = ItemUtils.findResIconColor(itemId,itemNum)
					self._awardName:setColor(UIUtils.colorTable["ccUIBaseColor" .. color])
					self._awardName:setString(lang(toolD.name) or "")
					self._awardName:setVisible(true)
					self._des:setVisible(true)
					local desW 	= self._des:getContentSize().width
					local nameW = self._awardName:getContentSize().width
					local allW = desW + nameW
					self._des:setPositionX(480-nameW/2)
					self._awardName:setPositionX(480+desW/2)

					self._timeLab:setVisible(false)
					local selMc = mcMgr:createViewMC("fanpaidiguang_arenafanpaizi", true,false)
					selMc:setPosition(card:getContentSize().width/2,card:getContentSize().height/2)
                	card:addChild(selMc,-1)
                	-- 判断是不是有加强光效
					if self._modelMgr:getModel("ArenaModel"):isShowTurnAnim(itemId,itemNum) then
						-- icon 背后加光效 修改 2017.4.20 只有最好的加icon背后光效 爆光
						local bgMc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true,false)
						bgMc:setPosition(card:getContentSize().width/2,card:getContentSize().height/2+20)
		            	-- bgMc:setScale(2)
		            	card:addChild(bgMc,9)
						local strongMc = mcMgr:createViewMC("fanpaiziguangxiao_arenafanpaizi2", false,true)
						strongMc:setPosition(card:getContentSize().width/2,card:getContentSize().height/2)
	                	strongMc:setScale(2)
	                	card:addChild(strongMc,999)
					end

                	card:runAction(cc.Sequence:create(
                		cc.DelayTime:create(1),
                		cc.CallFunc:create(function( )
		                	for i=1,3 do
		                		self:runTurnAnim(i)
		                	end
                		end)
                	))
				end
	        end)
        )
    ))
end

-- 接收自定义消息
function ArenaTurnCardView:reflashUI(data)

end

return ArenaTurnCardView