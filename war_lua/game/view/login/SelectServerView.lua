--[[
    Filename:    SelectServerView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2017-04-26 18:48:10
    Description: File description
--]]

local SelectServerView = class("SelectServerView", BaseLayer)


function SelectServerView:ctor(data)
    SelectServerView.super.ctor(self)
    self._data = data


    -- dump(self._recommend)
end

function SelectServerView:onDestroy()

    SelectServerView.super.onDestroy(self)
end

function SelectServerView:reflash(d)
	if d then
		self._data = d
	end
	local data = self._data
    self._callback = data.callback
    local array = data.array

    -- array = clone(data.array)
    -- for i = 6, 246 do
    -- 	array[i] = clone(array[1])
    -- 	array[i].name = i.."服"
    -- 	array[i].id = tostring(i + 9992)
    -- 	array[i].role = nil
    --     array[i].mixed = math.random(3) == 1
    -- end
    -- table.sort(array, function (a, b)
    -- 	return tonumber(a.id) > tonumber(b.id)
    -- end)

    -- 服务器总数量
    self._maxCount = #array

    -- self._hotMap = {}
    self._newMap = {}

    local count = 0
    local newMap = self._newMap
    for i = 1, #array do
    	count = count + 1
    	newMap[array[i].id] = true
    	if count >= 4 then
    		break
    	end
   	end

    local hasMixed = false
    -- 从小到大排序
    self._serverArr = {}
    local serverArr = self._serverArr
    for i = 1, #array do
    	serverArr[self._maxCount - i + 1] = array[i]
        if array[i].mixed and array[i].mixed ~= "" then
            hasMixed = true
        end
    end
    self._hasMixed = hasMixed

    self._wenhao:setVisible(hasMixed)

    -- dump(self._serverArr, "a", 20)

    -- 总页数(推荐和常规)
    local a, b = math.modf(self._maxCount / 10)
    self._pageCount = a + (b > 0 and 1 or 0)

    -- 最近登录 取有号的等级最大的四个服务器
    local roles = {}
    for i = 1, #array do
    	if array[i].role then
    		roles[#roles + 1] = {level = array[i].role.level, index = i}
    		-- 最多4个
    		if #roles >= 4 then
    			break
    		end
    	end
    end
    table.sort(roles, function (a, b)
    	return a.level > b.level
    end)
    self._roles = {}
    local role = self._roles
    for i = 1, #roles do
    	role[i] = array[roles[i].index]
    end

    -- 推荐服务器, 如果没有推荐，取最新的服务器
    self._recommend = {}
    local recommend = self._recommend
    for i = 1, #array do
    	if tonumber(array[i].recommend) == 1 then
    		recommend[#recommend + 1] = array[i]
    		-- self._hotMap[array[i].id] = true
    		if #recommend >= 1 then
    			break
    		end
    	end
    end
    if #recommend == 0 then
        local time
        local _idx
    	for i = 1, #array do
            if time == nil then
                time = array[i].server_start_date
                _idx = i
            else
                if array[i].server_start_date and array[i].server_start_date > time then
                    time = array[i].server_start_date
                    _idx = i
                end
            end	
    	end
        if _idx then
            recommend[#recommend + 1] = array[_idx]
        end
   	end

    -- 如果有混服，重新计算
    self._pageCount2 = 0
    self._maxCount2 = 0
    self._serverArr2 = {}
    if hasMixed then
        for i = #self._serverArr, 1, -1 do
            if self._serverArr[i].mixed and self._serverArr[i].mixed ~= "" then
                table.insert(self._serverArr2, 1, self._serverArr[i])
                table.remove(self._serverArr, i)
            end
        end
        self._maxCount2 = #self._serverArr2
        self._maxCount = self._maxCount - self._maxCount2
        local a, b = math.modf(self._maxCount / 10)
        self._pageCount = a + (b > 0 and 1 or 0)  

        local a, b = math.modf(self._maxCount2 / 10)
        self._pageCount2 = a + (b > 0 and 1 or 0)
    end
    -- dump(self._serverArr)
    -- dump(self._serverArr2)

   	if self._scrollView then
   		self._scrollView:removeFromParent()
   	end
   	local height = (1 + self._pageCount + self._pageCount2) * 47
    self._scrollView = cc.ScrollView:create() 
    self._scrollView:setViewSize(cc.size(188, 446))
    self._scrollView:setPosition(15, 24)
    self._scrollView:setContentSize(cc.size(188, height))
    
    self._scrollView:setDirection(1) --设置滚动方向
    self._scrollView:setBounceable(height > 446)
    self:getUI("bg"):addChild(self._scrollView)
    self._scrollView:setContentOffset(cc.p(0, 446 - height))

    self._pageBtns = {}
    for i = 1, 1 + self._pageCount + self._pageCount2 do
    	local btn = ccui.Button:create("login_sserver_btn1.png", "login_sserver_btn2.png", "login_sserver_btn2.png", 1)
        btn:setScaleAnim(false)
        btn:setPosition(94, height - i * 47 + 24)
        btn:setAnchorPoint(0.5, 0.5)
        btn:setColor(cc.c3b(255, 193, 158))
        btn:setTitleFontSize(20)  
        btn:setTitleFontName(UIUtils.ttfName)
        btn:setSwallowTouches(false)
    	self._scrollView:addChild(btn)
    	self._pageBtns[i] = btn
    	local x, y, down
    	self:registerTouchEvent(btn, 
    	function (_, _x, _y)
    		-- down
    		x, y = _x, _y
    		down = true
    	end, 
    	function (_, _x, _y)
    		-- move
    		if down and (math.abs(x - _x) > 5 or math.abs(y - _y) > 5) then
    			down = false
    		end
    	end,
    	 function (_, _x, _y)
    		-- up
    		if down then
    			self:onPage(i)
    		end
    	end)
    end
    -- 初始化左边页签
    self:initPageBtnTitle()
    -- 初始化推荐服务器页
    self:initRecommendPage()

    self:onPage(1)
end

function SelectServerView:onInit()
	self:setFullScreen()
	self:registerClickEventByName("bg.closeBtn", function()
		self:closeEx()
	end)

	-- 常规
	self._layer1 = self:getUI("bg.layer1")
	-- 最近登录
	self._layer2 = self:getUI("bg.layer2")
	-- 推荐
	self._layer3 = self:getUI("bg.layer3")

	self._btn1s = 
	{
		self:getUI("bg.layer1.btn1"), self:getUI("bg.layer1.btn2"),
		self:getUI("bg.layer1.btn3"), self:getUI("bg.layer1.btn4"),
		self:getUI("bg.layer1.btn5"), self:getUI("bg.layer1.btn6"),
		self:getUI("bg.layer1.btn7"), self:getUI("bg.layer1.btn8"),
		self:getUI("bg.layer1.btn9"), self:getUI("bg.layer1.btn10"),
	}
	self._btn2s = 
	{
		self:getUI("bg.layer2.btn1"), self:getUI("bg.layer2.btn2"),
		self:getUI("bg.layer2.btn3"), self:getUI("bg.layer2.btn4"),
	}
	self._btn3s = 
	{
		self:getUI("bg.layer3.btn1"), self:getUI("bg.layer3.btn2"),
		self:getUI("bg.layer3.btn3"), self:getUI("bg.layer3.btn4"),
	}

	local btn1s = self._btn1s
	for i = 1, #self._btn1s do
		self:registerClickEvent(btn1s[i], function ()
			self:onBtn1(i)
		end)
	end
	local btn2s = self._btn2s
	for i = 1, #self._btn2s do
		self._btn2s[i]:setVisible(false)
		self:registerClickEvent(btn2s[i], function ()
			self:onBtn2(i)
		end)
	end
	local btn3s = self._btn3s
	for i = 1, #self._btn3s do
		self._btn3s[i]:setVisible(false)
		self:registerClickEvent(btn3s[i], function ()
			self:onBtn3(i)
		end)
	end

    self._wenhao = self:getUI("bg.wenhao")
    self._wenhaotip = self:getUI("wenhaotip")
    self._wenhao:setVisible(false)
    self._wenhaotip:setVisible(false)
    self:getUI("wenhaotip.wenhaotip1.Label_104"):setString("　　　　　　《魔法门之英雄无敌：战争纪元》双平台大区说明　　　　　　\n亲爱的领主大人：　　　　　　　　　　　　　　　　　　　　　　　　　　\n　　双平台区支持iOS和安卓玩家同服体验。同一帐号下的角色数据可以在相同\n操作系统设备之间共用（例如iPhone和iPad设备）。　　　　　　　　　　　\n　　注意：角色数据不可在iOS和安卓设备间共用。　　　　　　　　　　　\n　　　　　　　　　　　　　　　　　　　《英雄无敌》运营团队感谢您的配合")

    self:registerClickEvent(self._wenhao, function ()
        self._wenhaotip:setVisible(not self._wenhaotip:isVisible())
    end)

    self:registerClickEvent(self._wenhaotip, function ()
        self._wenhaotip:setVisible(false)
    end)  
end

-- 初始化左边页签
function SelectServerView:initPageBtnTitle()
	self._pageBtns[1]:setTitleText("推荐服务器")
	local count1 = self._pageCount
    local count2 = self._pageCount2
	local min, max

    if count2 > 0 then
        for i = 1, count2 do
            if self._pageBtns[i + 1] then
                min = (count2 + 1 - i)*10 - 9
                max = (((count2 + 1 - i)*10) > self._maxCount2) and self._maxCount2 or ((count2 + 1 - i)*10)
                self._pageBtns[i + 1]:setTitleText("双平台 "..min.."-"..max.."区")
            end
        end
    end

    local ex = ""
    if self._hasMixed then
        if DIFF_PLATFORM then
            if OS_IS_ANDROID then
                ex = "iOS "
            elseif OS_IS_IOS then
                ex = "安卓 "
            else
                ex = "Win "
            end
        else
            if OS_IS_ANDROID then
                ex = "安卓 "
            elseif OS_IS_IOS then
                ex = "iOS "
            else
                ex = "Win "
            end
        end
    end
	for i = 1, count1 do
		if self._pageBtns[i + count2 + 1] then
			min = (count1 + 1 - i)*10 - 9
			max = (((count1 + 1 - i)*10) > self._maxCount) and self._maxCount or ((count1 + 1 - i)*10)
			self._pageBtns[i + count2 + 1]:setTitleText(ex..min.."-"..max.."区")
		end
	end

end

-- 初始化推荐服务器页
function SelectServerView:initRecommendPage()
	-- self._recommend = {}self._roles = {}
	local a, b = math.modf(#self._roles / 2)
	local roleLines = a + b * 2
	local a, b = math.modf(#self._recommend / 2)
	local recommendLines = a + b * 2

	self._layer2:setVisible(roleLines > 0)
	self._layer2.visible = roleLines > 0

	if roleLines == 0 then
		self._layer3:setPositionY(self._layer2:getPositionY())
	elseif roleLines == 1 then
		self._layer3:setPositionY(94)
	end

	for i = 1, #self._roles do
		self:fillServerBtn(self._btn2s[i], self._roles[i])
	end

	for i = 1, #self._recommend do
		self:fillServerBtn(self._btn3s[i], self._recommend[i])
	end
end

function SelectServerView:isZhuanFu(id)
    return tostring(id) == "69" or tostring(id) == "2019"
end

function SelectServerView:fillServerBtn(btn, data)
    if data == nil then return end
	btn:setVisible(true)
	if not btn.name then btn.name = btn:getChildByName("name") end
	if not btn.mark then btn.mark = btn:getChildByName("mark") end
	if not btn.level then btn.level = btn:getChildByName("level") end
	if not btn.state then btn.state = btn:getChildByName("state") end

    local name
    if data.mixed and data.mixed ~= "" then
        name = data.name--"双平台 " .. data.name
    else
        if self._hasMixed then
            if DIFF_PLATFORM then
                if OS_IS_ANDROID then
                    name = "iOS " .. data.name
                elseif OS_IS_IOS then
                    name = "安卓 " .. data.name
                else
                    name = "Win " .. data.name
                end
            else
                if OS_IS_ANDROID then
                    name = "安卓 " .. data.name
                elseif OS_IS_IOS then
                    name = "iOS " .. data.name
                else
                    name = "Win " .. data.name
                end
            end
        else
            name = data.name
        end
    end

    if self._hasMixed then
        btn.name:setAnchorPoint(0, .5)
        btn.name:setPositionX(60)  
    end
	btn.name:setString(name)
    if btn.name:getContentSize().width > 200 then
        btn.name:setScale(200 / btn.name:getContentSize().width)
    else
        btn.name:setScale(1)
    end

    if self:isZhuanFu(data.id) then
        btn.mark:loadTexture("login_sserver_m3.png", 1)
    else
    	if self._newMap[data.id] then
    		btn.mark:loadTexture("login_sserver_m1.png", 1)
    	else
    		btn.mark:loadTexture("login_sserver_m2.png", 1)
    	end
    end

	if data.role then
		btn.level:setVisible(true)
		if data.role.vipLvl and data.role.vipLvl > 0 then
			btn.level:setString("V"..data.role.vipLvl.." lv."..data.role.level)
		else
			btn.level:setString("lv."..data.role.level)
		end
	else
		btn.level:setVisible(false)
	end

	if tonumber(data.maintain) == 1 then
		btn.state:loadTexture("login_sserver_s1.png", 1)
	else
		if self._newMap[data.id] then
			btn.state:loadTexture("login_sserver_s2.png", 1)
		else
			btn.state:loadTexture("login_sserver_s3.png", 1)
		end
	end
    btn.state:setScale(1.25)
	btn.id = data.id
end

function SelectServerView:onPage(index)
	local pageBtns = self._pageBtns
	if self._page then
		local page = self._page
		pageBtns[page]:setTouchEnabled(true)
		pageBtns[page]:setBright(true)
		pageBtns[page]:setSwallowTouches(false)
		pageBtns[page]:setColor(cc.c3b(255, 193, 158))
	end
	self._page = index
	local page = self._page
	pageBtns[page]:setTouchEnabled(false)
	pageBtns[page]:setBright(false)
	pageBtns[page]:setColor(cc.c3b(255, 224, 156))

	-- 第一页是推荐服务器
	if self._page == 1 then
		self._layer1:setVisible(false)
		self._layer2:setVisible(self._layer2.visible)
		self._layer3:setVisible(true)
	else
        if self._page <= self._pageCount2 + 1 then
            -- 互通服
            self._layer1:setVisible(true)
            self._layer2:setVisible(false)
            self._layer3:setVisible(false)

            for i = 1, #self._btn1s do
                self._btn1s[i]:setVisible(false)
            end
            local _index = index - 1
            local count = self._pageCount2
            local min = (count + 1 - _index)*10 - 9
            local max = (((count + 1 - _index)*10) > self._maxCount2) and self._maxCount2 or ((count + 1 - _index)*10)
            -- print(min, max)
            for i = min, max do
                -- print((max - min + 2) - (i - min + 1))
                self:fillServerBtn(self._btn1s[(max - min + 2) - (i - min + 1)], self._serverArr2[i])
            end   
        else
            -- 普通服
            self._layer1:setVisible(true)
            self._layer2:setVisible(false)
            self._layer3:setVisible(false)

            for i = 1, #self._btn1s do
                self._btn1s[i]:setVisible(false)
            end
            local _index = index - self._pageCount2 - 1
            local count = self._pageCount
            local min = (count + 1 - _index)*10 - 9
            local max = (((count + 1 - _index)*10) > self._maxCount) and self._maxCount or ((count + 1 - _index)*10)
            -- print(min, max)
            for i = min, max do
                -- print((max - min + 2) - (i - min + 1))
                self:fillServerBtn(self._btn1s[(max - min + 2) - (i - min + 1)], self._serverArr[i])
            end
        end
	end
end

function SelectServerView:onBtn1(index)
	self._callback(self._btn1s[index].id)
	self:closeEx()
end

function SelectServerView:onBtn2(index)
	self._callback(self._btn2s[index].id)
	self:closeEx()
end

function SelectServerView:onBtn3(index)
	self._callback(self._btn3s[index].id)
	self:closeEx()
end

function SelectServerView:openEx()
    self._viewMgr:lock(-1)
	self:setVisible(true)
	local bg = self:getUI("bg")
    if bg then
    	bg:setOpacity(255)
        bg:setAnchorPoint(0.5, 0.5)
        bg:stopAllActions()
        bg:setScale(0.7)
        self._doPopCallback = callback
        audioMgr:playSound("Popup")
        ScheduleMgr:delayCall(0, self, function()
            bg:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.05), 3), 
                cc.ScaleTo:create(0.07, 1.0),
                cc.CallFunc:create(function ()
                    self._viewMgr:unlock()
            end)))
        end)
    else
        self._viewMgr:unlock()
    end
end

function SelectServerView:closeEx()
    self._wenhaotip:setVisible(false)
    self._viewMgr:lock(-1)
    local bg = self:getUI("bg")
    if bg then
        audioMgr:playSound("Close")
        bg:setAnchorPoint(0.5, 0.5)
        bg:stopAllActions()
        bg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.05, 1.1),
            cc.ScaleTo:create(0.06, 0.6), cc.CallFunc:create(
            function () 
                self:setVisible(false) 
                self._viewMgr:unlock()
            end)
            ))
    else
        self._viewMgr:unlock()
    end
end

return SelectServerView