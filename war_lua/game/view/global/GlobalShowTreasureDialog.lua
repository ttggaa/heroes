--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-24 17:52:13
--

local GlobalShowTreasureDialog = class("GlobalShowTreasureDialog",BasePopView)
function GlobalShowTreasureDialog:ctor(param)
    self.super.ctor(self)
    param = param or {}
    self._notLoadRes = param.notLoadRes -- 这里用于判断是否需要载 宝物资源
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil 
end

function GlobalShowTreasureDialog:getAsyncRes()
    return not self._notLoadRes and 
    {
        { "asset/ui/treasure.plist", "asset/ui/treasure.png" },
        { "asset/ui/treasureshop1.plist", "asset/ui/treasureshop1.png" },
        { "asset/ui/treasureshop2.plist", "asset/ui/treasureshop2.png" },
    }
    or {}
end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalShowTreasureDialog:onInit()
	self._viewMgr:enableScreenWidthBar()
	self._card = self:getUI("bg.card")
	self._card:setVisible(false)
	self._bg = self:getUI("bg")
	self._title = self:getUI("title")
	self._title:setCascadeOpacityEnabled(true)
	self._title:setOpacity(0)
	self._closePanel = self:getUI("closePanel")
	local isClose = false
	
	self._name = self:getUI("bg.name")
	self._name:setLocalZOrder(999)
	self._name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	self._name:setPositionY(self._name:getPositionY()-15)
	self._name:setOpacity(0)
	self._nameBg = self:getUI("bg.nameBg")
	-- 额外资源
    self._treasureBg = self:getUI("treasureBg")
    self._treasureBg:loadTexture("asset/bg/bg_treasureget.jpg",0)
    -- self._kapaiBg:setVisible(false)
    -- self._kapaiBg:setPosition(cc.p(0,0))
    -- local xscale = MAX_SCREEN_WIDTH / self._kapaiBg:getContentSize().width
    -- local yscale = MAX_SCREEN_HEIGHT / self._kapaiBg:getContentSize().height
    -- if xscale > yscale then
    --     self._kapaiBg:setScale(xscale)
    -- else
    --     self._kapaiBg:setScale(yscale)
    -- end
    -- self._kapaiBg:setAnchorPoint(cc.p(0,0))
    -- self:addChild(self._kapaiBg,-10)
    -- self._kapaiBg:setPosition(-MAX_SCREEN_WIDTH/2+self._bg:getContentSize().width/2,-MAX_SCREEN_HEIGHT/2+self._bg:getContentSize().height/2)
    -- self._bg:addChild(self._kapaiBg,-10)

    local leftPanel = self:getUI("bg.leftPanel")
	leftPanel:setCascadeOpacityEnabled(true)
	leftPanel:setOpacity(0)
	local rightTopPanel = self:getUI("bg.rightTopPanel")
	rightTopPanel:setCascadeOpacityEnabled(true)
	rightTopPanel:setOpacity(0)
	local desPanel = self:getUI("bg.desPanel")
	desPanel:setCascadeOpacityEnabled(true)
	desPanel:setOpacity(0)
	local bottomPanel = self:getUI("bg.bottomPanel")
	bottomPanel:setCascadeOpacityEnabled(true)
	bottomPanel:setOpacity(0)

end

-- 接收自定义消息
function GlobalShowTreasureDialog:reflashUI(data)
	audioMgr:playSound("NewCreature")
	-- 加转化描述 16.7.4 by guojun
	self._itemId = tonumber(data.itemId)
	local toolD = tab.tool[self._itemId]
	local filename = IconUtils.iconPath .. toolD.art .. ".png"
	local sfc = cc.SpriteFrameCache:getInstance()
	if not sfc:getSpriteFrameByName(filename) then
		filename = IconUtils.iconPath .. toolD.art .. ".jpg"
	end
	self._card:loadTexture(filename,1)
	-- local teamD = tab:Team(data.itemId-3000)
	local name = lang(toolD.name) or "不知名卡片"
	self._name:setString(name)
	self._name:setFontName(UIUtils.ttfName)
	self._name:setColor(cc.c3b(255, 243, 174))
    self._name:enable2Color(1, cc.c4b(240, 165, 40, 255))
	self._callback = data.callback
	local mcMgr = MovieClipManager:getInstance()
    self._itemId = data.itemId
    
    mcMgr:loadRes("herounlockanim", function ()
    	if self._title then
    		self._title:setScale(1.5)
    		self._title:loadTexture("treasureName_" .. self._itemId .. "_treasureShop.png",1)
    		self._title:setOpacity(100)
    		-- self._title:setBrightness(40)
    		self._title:runAction(cc.Sequence:create(
    			cc.Spawn:create(
	    			cc.ScaleTo:create(0.1,3),
	    			cc.FadeTo:create(0.1,150)
    			),
    			cc.CallFunc:create(function( )
			    	if self.animBegin then
			        	self:animBegin()
			        end
    			end),
    			cc.Spawn:create(
	    			cc.ScaleTo:create(0.1,1),
	    			cc.FadeTo:create(0.1,255)
    			)
    		))
    	end
    end, RGBAUTO)

	-- self:showBgAnim(true)
end

function GlobalShowTreasureDialog:animBegin( show )
	-- local mc =  mcMgr:createViewMC("shang_getteamanim", true, false, function (_, sender)
 --        -- sender:gotoAndPlay(80)
 --        sender:removeFromParent()
 --    end)
 --    mc:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
 --    -- self._mcs[name] = mc
 --    self:addChild(mc,2)

 --    local mc1 =  mcMgr:createViewMC("beijing_herounlockanim", true, false, function (_, sender)
 --        sender:gotoAndPlay(80)
 --        -- sender:removeFromParent()
 --    end)
 --    local xscale = MAX_SCREEN_WIDTH / 960
 --    local yscale = MAX_SCREEN_HEIGHT / 640
 --    if xscale > yscale then
 --        mc1:setScale(xscale)
 --    else
 --        mc1:setScale(yscale)
 --    end
 --    mc1:setAnchorPoint(cc.p(0,0))
	-- mc1:setName("xia")
 --    mc1:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
 --    self:addChild(mc1,-1)

 --    local mc2 = mcMgr:createViewMC("baowuchuxianguang_herounlockanim", false, true
 --    )
 --    mc2:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2)
 --    self:addChild(mc2,-1)
	
	-- local mc3 = mcMgr:createViewMC("fazhenguang_getteamanim", true, false
 --    )
 --    mc3:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2-60)
 --    self:addChild(mc3)

    self._card:setVisible(true)
    self._card:setScale(0.5)
    self._card:setOpacity(0)
	ScheduleMgr:delayCall(500, self, function ( )
		if tolua.isnull(self._card) then return end
        -- local mc2 = mcMgr:createViewMC("fazhenhuang_getteamanim", true, false
        -- )
        -- -- mc2:setHue(80)
        -- -- mc2:setSaturation(-30)
        -- mc2:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2-100)
        -- self:addChild(mc2,-1)

        -- local mc3 = mcMgr:createViewMC("fazhen_herounlockanim", true, false
        -- )
        -- -- mc3:setHue(80)
        -- -- mc3:setSaturation(-30)
        -- mc3:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2-100)
        -- self:addChild(mc3,-1)
	end)
    ScheduleMgr:delayCall(100, self, function( )
    	if tolua.isnull(self._card) then return end
    	self:reflashPanels()
    	self._card:setBrightness(40)
    	self._card:setScale(0.1)
    	self._name:setScale(0.5)
    	self._name:runAction(cc.Sequence:create(
    		cc.MoveBy:create(0,cc.p(0,-40)),
    		cc.Spawn:create(
    			cc.FadeIn:create(0.3),
    			cc.MoveBy:create(0.3,cc.p(0,30)),
    			cc.ScaleTo:create(0.3,1)
    		)
    	))
    	self._card:runAction(
    		cc.Spawn:create(
	    		cc.FadeIn:create(0.5),
	    		cc.Sequence:create(
	    			cc.ScaleTo:create(0.2,1.6),cc.ScaleTo:create(0.3,1.2)
	    			,
	    			cc.CallFunc:create(function( )
						self._card:setBrightness(0)
						self._card:setCascadeOpacityEnabled(true,true)
						-- self._card:runAction(cc.Spawn:create(cc.FadeOut:create(0.5),cc.Sequence:create(cc.ScaleTo:create(0.15,1.2),cc.ScaleTo:create(0.35,0.6))))
						self._card:runAction(cc.RepeatForever:create(
							cc.Sequence:create(
								cc.MoveBy:create(1,cc.p(0,10)),
								cc.MoveBy:create(1,cc.p(0,-10))
							)
						))
						audioMgr:playSound("Turn")
						ScheduleMgr:delayCall(900, self, function ( )
							self._bg:setOpacity(0)	
		    				self._bg:setVisible(true)
		    				self._bg:runAction(cc.FadeIn:create(0.5))	
							self._name = self:getUI("bg.name")
		    				local des1 = self:getUI("bg.des1")							
							-- treasureIcon:setScale(0.5)
							self._closePanel:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.3)),cc.CallFunc:create(function()
								self._closePanel:setTouchEnabled(false)
								local isClose = false
								self:registerClickEvent(self._closePanel, function( )
									local callback = self._callback 
									if callback then
										callback()
									end
									self.dontRemoveRes = true
									if isClose == false then
										isClose = true
										self:close(true)
										UIUtils:reloadLuaFile("global.GlobalShowTreasureDialog")
									end
								end)
								
							end)))
						end)
	    			end)
    			)
	    	)
    	)
	end)
end

function GlobalShowTreasureDialog:reflashPanels( )
	-- 初始化属性
	-- self:initAttrs()
	-- 初始化散件列表
	self:initAllTreasures()
	local toolD = tab:Tool(self._itemId)
	local panels = {}
	local leftPanel = self:getUI("bg.leftPanel")
	table.insert(panels,leftPanel)
	local rightTopPanel = self:getUI("bg.rightTopPanel")
	table.insert(panels,rightTopPanel)
	local desPanel = self:getUI("bg.desPanel")
	table.insert(panels,desPanel)
	local bottomPanel = self:getUI("bg.bottomPanel")
	table.insert(panels,bottomPanel)
	local desStrs = {lang(toolD.des)}
	-- 相对于原位置的偏移值，弹性值
	local offsets = {
		[1]={-50, 0 , 20, 0  , 0.3},
		[2]={ 50, 0 ,-20, 0  , 0.3},
		[3]={ 0 , 10,  0, -5 , 0  },
		[4]={ 0 , 20,  0, -5 , 0.3},
	}
	
	local titleBgs = {}
	for i,panel in ipairs(panels) do
		local titleBg = panel:getChildByFullName("titleBg")
		if titleBg then
			titleBg:setOpacity(100)
			titleBg:setColor(cc.c3b(0, 0, 0))
			table.insert(titleBgs,titleBg)
		end
		local title = panel:getChildByFullName("title")
		if title then
			title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
			title:setFontName(UIUtils.ttfName)
		end
		local des = panel:getChildByFullName("des")
		if des then
			des:setFontName(UIUtils.ttfName)
			des:enableOutline(cc.c4b(65,65,65,255),1)
			if desStrs[i] then
				des:setString(desStrs[i])
			end
		end
		-- local desPanel =  panel:getChildByFullName("desPanel")
		-- if desPanel then
		-- 	for i=1,3 do
		-- 		local des = desPanel:getChildByFullName("des" .. i)
		-- 		if des then
		-- 			des:setFontName(UIUtils.ttfName)
		-- 			des:enableOutline(cc.c4b(65,65,65,255),1)
		-- 		else
		-- 			break 
		-- 		end
		-- 	end
		-- 	desPanel:setCascadeOpacityEnabled(true)
		-- 	desPanel:setOpacity(0)
		-- 	desPanel:runAction(cc.Sequence:create(
		-- 		cc.DelayTime:create(0.6),
		-- 		cc.CallFunc:create(function( )
		-- 			desPanel:setOpacity(100)
		-- 			desPanel:setVisible(true)
		-- 			desPanel:setScale(0.6)
		-- 		end),
		-- 		cc.Spawn:create(
		-- 			cc.ScaleTo:create(0.15,1.1),
		-- 			cc.FadeIn:create(0.1)
		-- 		),
		-- 		cc.ScaleTo:create(0.1,1)
		-- 	))
		-- end
		-- panel动画
		local initPosX,initPosY = panel:getPositionX(),panel:getPositionY()
		panel:setPosition(initPosX+offsets[i][1],initPosY+offsets[i][2])
		panel:runAction(cc.Sequence:create(
			cc.DelayTime:create(offsets[i][5]),
			cc.Spawn:create(
				cc.MoveTo:create(0.3,cc.p(initPosX+offsets[i][3],initPosY+offsets[i][4])),
				cc.FadeIn:create(0.3)
			),
			cc.MoveTo:create(0.2,cc.p(initPosX,initPosY))
		))
	end
	
	local maxWidth = 240
    local step = 1
    local stepConst = 20
   	local titleWidth,titleHeight = titleBgs[1]:getContentSize().width,titleBgs[1]:getContentSize().height
    local sizeSchedule
    sizeSchedule = ScheduleMgr:regSchedule(10,self,function( )
        stepConst = stepConst+step
        if stepConst >= 30 then 
            stepConst = -15
        end
        titleWidth = titleWidth+stepConst
        if titleWidth < maxWidth then
            self._bg:setContentSize(cc.size(titleWidth,titleHeight))
            for k,v in pairs(titleBgs) do
            	v:setContentSize(cc.size(titleWidth,titleHeight))
            end
        else
            for k,v in pairs(titleBgs) do
            	v:setContentSize(cc.size(maxWidth-5,titleHeight))
            end
            ScheduleMgr:unregSchedule(sizeSchedule)
        end
    end)
    self._titleSchedule = sizeSchedule
end

function GlobalShowTreasureDialog:initAllTreasures( )
	local comTreasureId = math.floor(self._itemId%1000/10)
	local comTreasureD = tab.comTreasure[comTreasureId]
	
	local isHaveAll = true
	local form  = comTreasureD.form
	self._items = {}
	local tsBg  = self:getUI("bg.bottomPanel.treasuresBg")
	local tBg   = self:getUI("bg.bottomPanel.treasureBg")
	tsBg:setCascadeOpacityEnabled(true)
	if form then
		local itemSize = 120
		local num = #form
		local width = itemSize*num
		tsBg:setContentSize(cc.size(width,59))
		
		local x,y = -58,30
		for i,itemId in ipairs(form) do
			x = x+itemSize
			local toolD = tab.tool[itemId]
			local filename = IconUtils.iconPath .. toolD.art .. ".png"
			local sfc = cc.SpriteFrameCache:getInstance()
			if not sfc:getSpriteFrameByName(filename) then
				filename = IconUtils.iconPath .. toolD.art .. ".jpg"
			end
			local icon = ccui.ImageView:create()
			icon:loadTexture(filename,1)
			icon:setPosition(x,y)
			icon:setScale(40/icon:getContentSize().width)
			-- icon:setPurityColor(255, 255, 255)
			-- icon:setBrightness(40)
			tsBg:addChild(icon,10)

			local iconBg = tBg:clone()
			iconBg:setAnchorPoint(0.5,0.5)
			iconBg:setPosition(x,y)
			tsBg:addChild(iconBg)

			-- 闪烁
			if itemId == self._itemId then
				icon:runAction(cc.RepeatForever:create(
					cc.Sequence:create(
						cc.FadeTo:create(0.5,150),
						cc.FadeTo:create(0.5,255)
					)
				))
			else 
				local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
				local disInfo = self._modelMgr:getModel("TreasureModel"):getTreasureById(itemId)
				print(itemId,"count",count,"disInfo",disInfo)
				if not disInfo and count < 1 then
					icon:setBrightness(-60)
					icon:setSaturation(-100)
					-- icon:setColor(cc.c3b(168, 168, 168))
					-- icon:setPurityColor(100, 100, 100)
					iconBg:loadTexture("treasureShop_o_itemBg_dark.png",1)
				end
			end
			local _,count = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
			if count and count == 0 then
				isHaveAll = false
			end
		end
		tBg:setVisible(false)
		print("comTreasureId",comTreasureId)
		local desPanel1 =  self:getUI("bg.desPanel")
		if desPanel1 then
			local des1 = desPanel1:getChildByFullName("des1")
			local des2 = desPanel1:getChildByFullName("des2")
			des1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
			des2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
			des2:setString(lang(comTreasureD.name))
			if isHaveAll then
				des1:setString("可激活宝物")
			else
				des1:setString("集齐一套可激活宝物")
			end
			-- des1:setPositionX(150-des2:getContentSize().width/2)
			-- des2:setPositionX(150+des1:getContentSize().width/2)
			UIUtils:center2Widget(des1,des2,150,1)
		end
	end
end

function GlobalShowTreasureDialog:initAttrs( )
	local panel = self:getUI("bg.rightTopPanel")
	local stage = 1
	local preAtts = self._modelMgr:getModel("TreasureModel"):getTreasureAtts(self._itemId, 1)
    local panelW, panelH = panel:getContentSize().width/2, 25 -- panel:getContentSize().height
    local x, y = 35 , panel:getContentSize().height - panelH - 5
    local offsetx, offsety = offsetx or 0, offsety or 0
    local idx = 1
    self._panels = { }
    -- 不反复创建删除节点，做缓存
    
    for k, v in pairs(preAtts) do
    	y = y - panelH
        local attRight = ccui.Text:create()
        attRight:setFontSize(20)
        attRight:setFontName(UIUtils.ttfName)
        -- attRight:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        attRight:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        attRight:setAnchorPoint(0,0.5)
        attRight:setPosition(x,y)
        panel:addChild(attRight)
        local name = lang("ARTIFACTDES_PRO_" .. v.attId)
        if not name then
            name = lang("ATTR_" .. v.attId)
        end
        if name then
            name = string.gsub(name, "　", "")
            name = string.gsub(name, " ", "")
        end
        local tail = " "
        if tonumber(v.attId) == 2 or tonumber(v.attId) == 5 or tonumber(v.attId) == 131 then
            tail = "% "
        end
        
        local leftAttStr = v.attNum == math.floor(v.attNum) and tostring(v.attNum) or string.format("%.1f", v.attNum)
        attRight:setString(name .. "：+" .. leftAttStr .. tail)
        idx = idx + 1
    end
end

function GlobalShowTreasureDialog:onDestroy( )
	if self._titleSchedule then
		ScheduleMgr:unregSchedule(self._titleSchedule)
		self._titleSchedule = nil
	end
	self._viewMgr:disableScreenWidthBar()
	self.super.onDestroy(self)
end

return GlobalShowTreasureDialog