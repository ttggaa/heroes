--
-- Author: huangguofang
-- Date: 2016-07-11 18:36:47
--
local RankTreasureView = class("RankTreasureView",BasePopView)
function RankTreasureView:ctor(params)
    self.super.ctor(self)
    self._treasureData = params.data
    self._userData = params.userData
    self._comTreasureTable = tab.comTreasure
end

-- 初始化UI后会调用, 有需要请覆盖
function RankTreasureView:onInit()

	self:registerClickEventByName("bg.closeBtn", function(  )
		self:close()
        UIUtils:reloadLuaFile("rank.RankTreasureView")
	end)

	self._comTreasureData = {}--clone(self._comTreasureTable)

	for k,v in pairs(self._comTreasureTable) do
		local tempTable = {}
		tempTable.comId = v.id
		tempTable.stage = 0
		tempTable.score = 0
		tempTable.rank = v.rank    --排序字段
		if 1 == tonumber(v.display) then
			for kk,vv in pairs(self._treasureData) do
				if v.id == vv.comId then
					tempTable.stage = vv.stage
					tempTable.score = vv.score
					tempTable.treasureDev = vv.treasureDev
					break
				end	
			end	
			table.insert(self._comTreasureData,tempTable)
		end
	end
	table.sort(self._comTreasureData,function( a,b )
		return a.rank < b.rank
	end)

	-- dump(self._comTreasureData,"self._comTreasureData===>")

	self._bg = self:getUI("bg")
	self._title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(self._title, 1)

    self._heroHead = self:getUI("bg.heroHead")
    self:updateUserHead(self._heroHead)

    self._nameBg = self:getUI("bg.nameBg")
    self._nameBg:setContentSize(1,1)
	self._name = self:getUI("bg.name")
	UIUtils:setTitleFormat(self._name, 2)
	self._name:setString(self._userData.name or "")

	-- local nameWidth = self._name:getContentSize().width+20 --+self._vipLab:getContentSize().width
 --    self._nameBg:setContentSize(nameWidth < 115 and 192 or nameWidth + 80, self._nameBg:getContentSize().height)

	self._rank = self:getUI("bg.rank")
	-- self._rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	self._rank:setString(self._userData.rank  or 0)
	
	local score = self:getUI("bg.score")
	score:setVisible(false)
	self._score = ccui.TextBMFont:create("00", UIUtils.bmfName_zhandouli_little)
	self._score:setAnchorPoint(cc.p(1,0.5))
	
	self._score:setPosition(score:getPositionX(),score:getPositionY()+14)
	self._score:setString("a" .. self._userData.score)
	self._score:setScale(0.6)
	self._bg:addChild(self._score)

--    self._userData["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[self._userData["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setPosition(658, 419)
	self._bg:addChild(tequanIcon)
    tequanIcon:setScaleAnim(true)

    if tequanImg ~= "globalImageUI6_meiyoutu.png" then
        self:registerClickEvent(tequanIcon,function( sender )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
    end

	self._scrollView = self:getUI("bg.scrollBg.scrollView")
	self._scrollView:setBounceEnabled(true)

	-- dump(self._treasureData,"======>")
	local nums = table.nums(self._comTreasureData)
	local row = 4
	local line =  math.ceil(nums/4)
	local height = 110 * line	
	local y = height + 15   -- 15校正值
	if nums <= row then
		height = self._scrollView:getContentSize().height 
		y = height - 15
	end
	-- print(height,"====================",y)
	local i = 0
	local x = 10  			-- 10 校正值
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,height))
	for k,v in ipairs(self._comTreasureData) do
		local treasureIcon = self:createTreasureIcon(v.comId,v.stage,v)
		treasureIcon:setScale(0.9)
		if i % row == 0  then
			x = 10
			y = y - 115
		else
			x = x + 120
		end
		-- print("===============xxx===yyy====  ",x,y)
		treasureIcon:setPosition(x, y)
		self._scrollView:addChild(treasureIcon)
		i = i + 1
	end

end
--添加宝物icon信息
function RankTreasureView:createTreasureIcon(comId,stage,treasureData)
	local widget = ccui.Widget:create()
	local iconW,iconH = 107,107
	widget:setContentSize(cc.size(iconW,iconH))
	widget:setAnchorPoint(cc.p(0,0))
	local icon = ccui.ImageView:create()
	local data = tab:ComTreasure(tonumber(comId))
	icon:loadTexture("globalImageUI4_squality".. (data.quality or 2) ..".png",1)
	icon:setName("icon")
	icon:ignoreContentAdaptWithSize(false)
    icon:setContentSize(cc.size(iconW,iconH))
	icon:setAnchorPoint(cc.p(0,0))
	widget:addChild(icon)
	
	local lock = ccui.ImageView:create()
    lock:setAnchorPoint(cc.p(0, 0))
    lock:setName("lock")
    lock:loadTexture("globalImageUI5_treasureLock.png",1)
    lock:ignoreContentAdaptWithSize(false)
    lock:setContentSize(cc.size(49,57))
    widget:addChild(lock,10)
    lock:setPosition(cc.p((iconW-lock:getContentSize().width)/2, (iconH-lock:getContentSize().height)/2))
 	
 	local iconBg = ccui.ImageView:create()
    iconBg:setAnchorPoint(cc.p(0, 0))
    iconBg:setName("iconBg")
    iconBg:loadTexture("globalImageUI6_itembg_" .. data.quality ..".png",1)
    iconBg:ignoreContentAdaptWithSize(false)
    iconBg:setContentSize(cc.size(iconW-5,iconH-5))
    icon:addChild(iconBg,-1)
    iconBg:setPosition(cc.p((iconW-iconBg:getContentSize().width)/2, (iconH-iconBg:getContentSize().height)/2))
   
    local iconImage = ccui.ImageView:create()
	local filename = data.icon .. ".png" -- "asset/icon/" .. 
	iconImage:loadTexture(filename,1)
	iconImage:setAnchorPoint(cc.p(0,0))
	iconImage:setName("image")
	icon:addChild(iconImage)
	iconImage:setPosition(cc.p((iconW-iconImage:getContentSize().width)/2, (iconH-iconImage:getContentSize().height)/2))


	local isGray = (not stage or tonumber(stage) == 0)
	if isGray then
		icon:setColor(cc.c4b(128, 128, 128, 255))
		icon:setBrightness(-50)
		lock:setVisible(true)
	else
		icon:setColor(cc.c4b(255, 255, 255, 255))
		icon:setBrightness(0)
		lock:setVisible(false)

		local iconStage = ccui.ImageView:create()
	    iconStage:setAnchorPoint(cc.p(0, 0))
	    iconStage:setName("iconStage")
	    iconStage:loadTexture("globalImageUI4_iquality" .. (data.quality or 2) ..".png",1)
	    -- iconStage:ignoreContentAdaptWithSize(false)
	    -- iconStage:setContentSize(cc.size(iconW-5,iconH-5))
	    iconStage:setAnchorPoint(cc.p(0,1))
	    iconStage:setPosition(0, iconH+2)
	    icon:addChild(iconStage,5)

	    local stageTxt = ccui.Text:create()
	    stageTxt:setString("+" .. stage)
	    stageTxt:setFontName(UIUtils.ttfName)
	    if tonumber(stage) < 10 then
	    	stageTxt:setFontSize(20)
	    else
	    	stageTxt:setFontSize(18)
	    end
	    stageTxt:setColor(UIUtils.colorTable.ccUIBaseColor1)
	    stageTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	    stageTxt:setAnchorPoint(cc.p(0.5,0.5))
	    stageTxt:setPosition(iconStage:getContentSize().width/2, iconStage:getContentSize().height/2+2)
	    iconStage:addChild(stageTxt,1)
	end

	self:registerClickEvent(icon,function() 
		self._viewMgr:showDialog("treasure.TreasureDetailDialog",{id=comId,stage = stage,comInfo = treasureData})
	end)

	return widget
	
end
--添加玩家头偶像
function RankTreasureView:updateUserHead(heroHead)
	local avtar = self._userData.avatar
	if not avtar or avtar == 0 then
		avtar = 1203
	end 
    if not self._avatar then
        local tencetTp = self._userData["qqVip"]
        local headP = {avatar = avtar,level = tonumber(self._userData.level or self._userData.lvl or 0),tp = 4 ,
        				avatarFrame = self._userData["avatarFrame"], tencetTp = tencetTp, plvl = self._userData["plvl"]}
        self._avatar = IconUtils:createHeadIconById(headP)
        self._avatar:setPosition(cc.p(-1,-1))
        self._heroHead:addChild(self._avatar)
    end
end
-- 接收自定义消息
function RankTreasureView:reflashUI(data)

end

return RankTreasureView