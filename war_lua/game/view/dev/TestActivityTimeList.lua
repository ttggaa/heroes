--
-- Author: zhangtao@playcrab.com
-- Date: 2017-7-17 17:06:34
--
local TestActivityTimeList = class("TestActivityTimeList",BaseView)
function TestActivityTimeList:ctor()
    self.super.ctor(self)
    self._distanceX = 50
	self._distanceY = 20
	self._monthDay = {31,29,31,30,31,30,31,31,30,31,30,31}
end

-- 初始化UI后会调用, 有需要请覆盖
function TestActivityTimeList:onInit()
	self._scrollView = self:getUI("bg.listScrollView")

	self._scrollView:removeAllChildren()
	self._scrollView:setBounceEnabled(true)

	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("dev.TestActivityTimeList")
    end)

	self._scrollH = self._scrollView:getInnerContainerSize().height
	local realHeight = (self.GetActivityNum()+1)*self._distanceY
	self._scrollH = self._scrollH < realHeight and realHeight or self._scrollH

	local beginPos = 0
	-- self._batchNode = cc.SpriteBatchNode:create("image.png", MAX_COUNT_POOL)
	for k , v in pairs(self._monthDay) do 
		for i = 1,v do
			beginPos = k*i == 1 and beginPos or beginPos + self._distanceX
			-- beginPos = beginPos + self._distanceX
			local dayBgImage = ccui.ImageView:create()
		    dayBgImage:loadTexture("image.png", 1)
		    dayBgImage:setName("dayBgImage")
		    dayBgImage:setAnchorPoint(cc.p(0,0.5))
		    dayBgImage:setContentSize(cc.size(self._distanceX,self._distanceY))
		    dayBgImage:setPosition(cc.p(beginPos,self._scrollH - self._distanceY/2))
		    --竖线
		    local lineImage = ccui.Scale9Sprite:createWithSpriteFrameName("globalImageUI_tips_split.png")
		    lineImage:setCapInsets(cc.rect(1, 10, 1, 1))
		    lineImage:setName("lineImage")
		    lineImage:setAnchorPoint(cc.p(0,1))
		    lineImage:setContentSize(cc.size(2,realHeight))
		    lineImage:setPosition(cc.p(beginPos+self._distanceX,self._scrollH))
		    self._scrollView:addChild(lineImage)
			-- 文字原型
		    local textPro = ccui.Text:create()
		    textPro:setString(k.."-"..i)
		    textPro:setAnchorPoint(0.5,0.5)
		    textPro:setPosition(self._distanceX/2,self._distanceY/2)
		    textPro:setFontSize(18)
		    textPro:setTextColor(cc.c4b(0,0,0,255))
		    dayBgImage:addChild(textPro)
		    self._scrollView:addChild(dayBgImage)
		end
	end

	--title横线
    local titleLineImage = ccui.Scale9Sprite:createWithSpriteFrameName("teamImageUI_img31.png")
    titleLineImage:setCapInsets(cc.rect(14, 1, 1, 1))
    titleLineImage:setName("titleLineImage")
    titleLineImage:setAnchorPoint(cc.p(0,0))
    titleLineImage:setContentSize(cc.size(self._distanceX*366,2))
    titleLineImage:setPosition(cc.p(0,self._scrollH - self._distanceY))
    self._scrollView:addChild(titleLineImage)

	-- dump(tab.activityopen)

	self._scrollView:setInnerContainerSize(cc.size(beginPos + self._distanceX, self._scrollH))
	self:InitCellList()
end


function TestActivityTimeList:InitCellList()
	local heightIndex = 1
	for _,tabValue in pairs(tab.advertise) do
		if tabValue["allow_open"] == 1 and tabValue["start_type"] == 1 then
			local month1 , day1 = self:CutString(tabValue["start_time"])
			local month2 , day2 = self:CutString(tabValue["end_time"])
			local firstIndex = self:GetPosIndex(month1,day1)
			local secondIndex = self:GetPosIndex(month2,day2)
			print("firstIndex" .. firstIndex)
			print("secondIndex" .. secondIndex)
			local dayBgImage = ccui.ImageView:create()
		    dayBgImage:loadTexture("arenareward_progressBar.png",1)
			dayBgImage:setScale9Enabled(true)
		    dayBgImage:setCapInsets(cc.rect(15, 8, 1, 1))
		    dayBgImage:setName("dayBgImage")
		    dayBgImage:setAnchorPoint(cc.p(0,0.5))
		    dayBgImage:setContentSize(cc.size(self._distanceX*(secondIndex-firstIndex+1),self._distanceY-2))
		    dayBgImage:setPosition(cc.p((firstIndex - 1)*self._distanceX,self._scrollH - self._distanceY/2 - heightIndex*self._distanceY))


		    --横线
		    local lineImage = ccui.ImageView:create() 
		    lineImage:setScale9Enabled(true)
		    lineImage:loadTexture("teamImageUI_img31.png",1)
		    lineImage:setCapInsets(cc.rect(14, 1, 1, 1))
		    lineImage:setName("lineImage")
		    lineImage:setAnchorPoint(cc.p(0,0))
		    lineImage:setContentSize(cc.size(self._distanceX*366,2))
		    lineImage:setPosition(cc.p(0,self._scrollH - heightIndex*self._distanceY - self._distanceY))
		    self._scrollView:addChild(lineImage)

			-- 文字原型
		    local textPro = ccui.Text:create()
		    textPro:setString(tabValue["activity_id"])
		    textPro:setAnchorPoint(0.5,0.5)
		    textPro:setPosition(self._distanceX*(secondIndex-firstIndex+1)/2,self._distanceY/2)
		    textPro:setFontSize(16)
		    textPro:setTextColor(cc.c4b(0,0,0,255))

		    dayBgImage:addChild(textPro)
		    self._scrollView:addChild(dayBgImage)


		 	self:registerClickEvent(dayBgImage,function() 
		 		print("registerClickEvent")
		 		local filename = "asset/other/ad/"..tabValue["activity_id"]
				local showImageView = ccui.ImageView:create(filename) 
				showImageView:setAnchorPoint(cc.p(0.5, 0.5))
				showImageView:setPosition(480,320)
				showImageView:setName("showImageView")

				self._scrollView:setTouchEnabled(false)
		 		self:getUI("bg"):addChild(showImageView,200,999)

		 		self:registerClickEvent(showImageView,function()
		 			self._scrollView:setTouchEnabled(true)
		 			self:getUI("bg"):removeChildByTag(999,true)

		 			end)
		 	end)

		    heightIndex = heightIndex + 1
		end
	end
end

function TestActivityTimeList:GetPosIndex(month,day)
	local index = 0
	for k , v in pairs(self._monthDay) do
		if tonumber(k) < tonumber(month) then
			index = index + v
		elseif tonumber(k) == tonumber(month) then
			index = index + tonumber(day)
		end
	end
	return index
end

--切分字符串返回月和天
function TestActivityTimeList:CutString(string)
	local splitList1 = string.split(string, " ")
	local splitList2 = string.split(splitList1[1], "-")
	return splitList2[2],splitList2[3]
end

function TestActivityTimeList:GetActivityNum()
	local listNum = 0
	for _,tabValue in pairs(tab.advertise) do
		if tabValue["allow_open"] == 1 and tabValue["start_type"] == 1 then
			listNum = listNum + 1
		end
	end
	return listNum
end

-- 第一次进入调用, 有需要请覆盖
function TestActivityTimeList:onShow()

end

-- 被其他View盖住会调用, 有需要请覆盖
function TestActivityTimeList:onHide()

end

-- 接收自定义消息
function TestActivityTimeList:reflashUI(data)

end

return TestActivityTimeList