--[[
 	@FileName 	BattleArrayEnterView.lua
	@Authors 	yuxiaojing
	@Date    	2018-07-24 15:02:49
	@Email    	<yuxiaojing@playcrab.com>
	@Description   描述
--]]

local BattleArrayEnterView = class("BattleArrayEnterView", BaseView)

function BattleArrayEnterView:ctor(  )
	BattleArrayEnterView.super.ctor(self)
	self._isClick = false
    self._isScroll = false
end

function BattleArrayEnterView:getBgName(  )
	return "battleArrayBg1.jpg"
end

function BattleArrayEnterView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideHead = true, hideInfo = true})
end

function BattleArrayEnterView:getAsyncRes(  )
	return {
		{"asset/ui/battleArrayEnter.plist", "asset/ui/battleArrayEnter.png"}
	}
end

function BattleArrayEnterView:onInit(  )
	self._baModel = self._modelMgr:getModel("BattleArrayModel")
	self._offsetxAnim = false
	self._tempTableOffsetX = -99999999
    self._tempTableOffsetX1 = self._tempTableOffsetX

	self._scrollView = cc.ScrollView:create()
	self._scrollView:setViewSize(cc.size(1136, 640))
	self._scrollView:setDirection(0)
	self._scrollView:setBounceable(true)
	self._scrollView:setDelegate()
	self._scrollView:registerScriptHandler(function (  )
		return self:scrollViewDidScroll()
	end, cc.SCROLLVIEW_SCRIPT_SCROLL)

	local bg = self:getUI("bg")
	if MAX_SCREEN_HEIGHT > 640 then
        self._scrollView:setAnchorPoint(cc.p(0, 0))
    else
        self._scrollView:setAnchorPoint(cc.p(0, 0.5))
    end
    self._scrollView:setPosition(cc.p((1136 - MAX_SCREEN_WIDTH) * 0.5, 0))
    self._scrollView:setScale((MAX_SCREEN_WIDTH / 1136) > 1.15 and 1.15 or (MAX_SCREEN_WIDTH / 1136))
    bg:addChild(self._scrollView, 1)

    self._right = self:getUI("right")
    self._right:setLocalZOrder(2)
    local mc1 = mcMgr:createViewMC("tujianyoujiantou_teamnatureanim", true, false)
    mc1:setPosition(cc.p(self._right:getContentSize().width*0.5, self._right:getContentSize().height*0.5))
    self._right:addChild(mc1) 

    self._left = self:getUI("left")
    self._left:setLocalZOrder(2)
    local mc2 = mcMgr:createViewMC("tujianzuojiantou_teamnatureanim", true, false)
    mc2:setPosition(cc.p(self._left:getContentSize().width*0.5, self._left:getContentSize().height*0.5))
    self._left:addChild(mc2)

    self._raceObj = {}
    self._openRace = tab.setting["BATTLEARRAY_TEAMOPEN"].value
    local maxWidth = #self._openRace * 227
    self._scrollView:setContentSize(cc.size(maxWidth, 640))

    for i = 1, #self._openRace do
    	self._raceObj[i] = self:createRaceEnterObj(self._openRace[i])
    	self._raceObj[i]:setName(self._openRace[i])
    	self._raceObj[i]:setAnchorPoint(cc.p(0.5, 0.5))
    	self._raceObj[i]:setPosition(cc.p(227 * (i - 1) + self._raceObj[i]:getContentSize().width / 2, MAX_SCREEN_HEIGHT * 0.5 + 10))
    	self._scrollView:addChild(self._raceObj[i])
    end

    self:updateRedPrompt()

    self._updateId = ScheduleMgr:regSchedule(1, self, function()
        self:update()
    end)

end

function BattleArrayEnterView:onTop(  )
	self:updateRedPrompt()
end

function BattleArrayEnterView:updateRedPrompt(  )
	local redPrompt = self._baModel:getRedPrompt()
	local childs = self._scrollView:getContainer():getChildren()
    if #childs <= 0 then 
        return
    end
    for k, v in pairs(childs) do
    	local raceType = tonumber(v:getName())
    	local redImg = v:getChildByFullName("redImg")
    	if table.indexof(redPrompt, raceType) then
    		redImg:setVisible(true)
    	else
    		redImg:setVisible(false)
    	end

    	local baData = self._baModel:getDataByRace(raceType)
    	local fightNum = v:getChildByFullName("fightNum")
    	fightNum:setString("a+" .. baData.score)
    end
end

function BattleArrayEnterView:createRaceEnterObj( raceType )
	local node = ccui.Widget:create()
    node:setContentSize(227, 512)
    node:setTouchEnabled(false)

    local board = ccui.ImageView:create()
    board:loadTexture("battleArrayEnter_" .. raceType .. ".png", 1)
    board:setAnchorPoint(cc.p(0, 0))
    board:setPosition(8.5, 0)
    node:addChild(board)

    local fightNum = cc.LabelBMFont:create("a+0", UIUtils.bmfName_zhandouli_little)
	fightNum:setAnchorPoint(0.5, 0.5)
	fightNum:setPosition(node:getContentSize().width / 2, -20)
	fightNum:setScale(0.6)
	fightNum:setName("fightNum")
	node:addChild(fightNum)

	-- local testLab = ccui.Text:create()
	-- testLab:setString(raceType)
	-- testLab:setFontSize(30)
	-- testLab:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
	-- node:addChild(testLab)

	local redName = "globalImageUI_bag_keyihecheng.png" 
    local redImg = cc.Sprite:create()
    redImg:setSpriteFrame(redName)
    redImg:setName("redImg")
    redImg:setAnchorPoint(cc.p(1, 0))
    redImg:setPosition(cc.p(node:getContentSize().width - 5, 5))
    redImg:setVisible(false)
    node:addChild(redImg, 5)

    registerTouchEvent(node, 
    	function ( _, x, y )
    		self._isClick = false
    	end, 
    	function ( _, x, y )
    		self._isScroll = true
    	end, 
    	function ( _, x, y )
    		if self._isClick == false then
    			self._modelMgr:getModel("BattleArrayModel"):showBattleArrayView(raceType)
    			self._isClick = false
    		end
    		self._isScroll = false
    	end,
    	function (  )
    		self._isClick = false
    		self._isScroll = false
    	end)
    node:setSwallowTouches(false)
    return node
end

function BattleArrayEnterView:update()
	local offset = self._scrollView:getContentOffset()
	if self._tempTableOffsetX == offset.x then 
        if self._isScroll == false and not self._scrollView:isDragging() then
            self:scrollViewScroll()
        end
        return 
    end
    local childs = self._scrollView:getContainer():getChildren()
    if #childs <= 0 then 
        return
    end

    self._tempTableOffsetX = offset.x
    for k,v in pairs(childs) do
        local x,y = v:getPosition()
        local worldX = v:convertToWorldSpaceAR(cc.p(0,0)).x 
        if tonumber(k) == 1 then
            self._offsetX = worldX
        end
        local sca = 1 / (1 + 0.0000008 * (math.sqrt(math.pow((worldX - MAX_SCREEN_WIDTH * 0.5), 4))))
        v:setScale(sca)
    end
end

function BattleArrayEnterView:scrollViewScroll()
	if self._tempTableOffsetX == self._tempTableOffsetX1 then 
        return 
    end
    self._tempTableOffsetX1 = self._tempTableOffsetX
    local childs = self._scrollView:getContainer():getChildren()
    if #childs <= 0 then 
        return
    end
    self._scrollView:stopScroll()
    local posValue = 3000
    local posIndex, posOffset

    for k,v in pairs(childs) do
        local worldX = v:convertToWorldSpaceAR(cc.p(0,0)).x 
        if posValue >= math.abs(worldX - MAX_SCREEN_WIDTH*0.5) then
            posValue = math.abs(worldX - MAX_SCREEN_WIDTH*0.5)
            posOffset = worldX - MAX_SCREEN_WIDTH*0.5
            posIndex = tonumber(k)
        end
    end

    if posIndex > #self._openRace - 2 then
        posOffset = -80
    elseif posIndex < 3  then
        posOffset = 80
    end
    if posOffset > 0 and posOffset < 1 then
        posOffset = 0
    end
    if self._offsetxAnim == false then
        self._scrollView:setContentOffset(cc.p(self._scrollView:getContentOffset().x - posOffset,0), false)
        self._offsetxAnim = true
        return
    end
    local scrollInner = self._scrollView:getContainer()
    local toffsetX = self._scrollView:getContentOffset().x - posOffset
    local move = cc.MoveTo:create(0.01, cc.p(toffsetX, 0))
    scrollInner:stopAllActions()
    scrollInner:runAction(move)
end

function BattleArrayEnterView:scrollViewDidScroll()
    self._isClick = true

    local view = self._scrollView
    local tempPos = view:getContentSize().width + view:getContainer():getPositionX()
    if math.floor(self._offsetX + 0.5) >= 113 then
        self._right:setVisible(true)
        self._left:setVisible(false)
    elseif math.floor(self._offsetX + 0.5) <= -(85 * #self._openRace) then
        self._right:setVisible(false)
        self._left:setVisible(true)
    else
        self._right:setVisible(true)
        self._left:setVisible(true)
    end
end

function BattleArrayEnterView:onExit()
    if self._updateId then
        ScheduleMgr:unregSchedule(self._updateId)
        self._updateId = nil
    end
end

return BattleArrayEnterView