--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-12-23 11:21:17
--
-- 弹幕系统
local random = math.random
local floor = math.floor
local gettime = socket.gettime
local gsub = string.gsub

local MAX_SCREEN_WIDTH = MAX_SCREEN_WIDTH
local MAX_SCREEN_HEIGHT = MAX_SCREEN_HEIGHT

local BulletScreensUtils = {}

local viewMgr = ViewManager:getInstance()
local serverMgr = ServerManager:getInstance()
local modelMgr = ModelManager:getInstance()

local _bsUpdate
--[[
	调用说明

	初始化
	BulletScreensUtils.init(data)
	清除
	BulletScreensUtils.clear()
	显示
	BulletScreensUtils.show()
	隐藏
	BulletScreensUtils.hide()

	插入一条弹幕
	local time = BulletScreensUtils.pushBullet(str, pos, color)
	# pos 1: 正  2: 逆  3: 顶部  4: 底部  5: 中央
	# color 为索引 colorTab 1 - 8
	# 返回值为发给服务器用的time


	data 参数
		data: 弹幕数据 格式{{time(秒), 文字, 颜色索引, 位置索引}, ...}
			default: lang表随机
		maxTime: 总体时间轴长度
			default: 20
		loop: 是否循环播放
			default: false

		common_TopSpace: 顶部空间
			default: 0
		common_BottomSpace: 底部空间
			default: 0
		common_FontSize: 普通弹幕字体大小
			default: 22
		common_LineSpace: 普通弹幕行间距
			default: 4
		common_MaxLine: 普通弹幕的最大行数
			default: floor((MAX_SCREEN_HEIGHT - common_TopSpace - common_BottomSpace) / (common_FontSize + common_LineSpace))
		common_showTime: 普通弹幕展示时长(字越长, 滚动越快)
			default: 8

		top_enable: 是否开启顶部弹幕
			default: true
		top_FontSize: 顶部弹幕字体大小
			default: 22
		top_LineSpace: 顶部弹幕行间距
			default: 2
		top_MaxLine: 顶部弹幕的最大行数
			default: floor(MAX_SCREEN_HEIGHT * 0.5 / (top_FontSize + top_LineSpace))
		top_showTime: 顶部弹幕展示时长
			default: 5

		bottom_enable: 是否开启底部弹幕
			default: true
		bottom_FontSize: 底部弹幕字体大小
			default: 22
		bottom_LineSpace: 底部弹幕行间距
			default: 2
		bottom_MaxLine: 底部弹幕的最大行数
			default: floor(MAX_SCREEN_HEIGHT * 0.5 / (bottom_FontSize + bottom_LineSpace))
		bottom_showTime: 底部弹幕展示时长
			default: 5

		center_enable: 是否开启中央弹幕
			default: true
		center_FontSize: 中央弹幕字体大小
			default: 60
		center_showTime: 中央弹幕展示时长
			default: 5

]]--

--[[
	实时弹幕用法

	初始化
	BulletScreensUtils.init()

	发自己的弹幕和收到别人的弹幕
	BulletScreensUtils.showBulletNow(位置, {nil, "文字内容", 颜色索引})

	不需要保存数据，所以不用涉及到model
	自己发的时候sendMsg同时调用showBulletNow
	收到push的时候也调用showBulletNow
]]--

function BulletScreensUtils.initBullet(bulletD)
	local _data = modelMgr:getModel("BulletModel"):getChannelData(bulletD["id"])
	local data = {maxTime = bulletD["maxtime"], loop = bulletD["loop"] == 1}
	if _data ~= nil then
		data.data = _data
		BulletScreensUtils.init(data)
		BulletScreensUtils.bulletD = bulletD
	else
		print("BulletServer.getBullet")
		if bulletD["live"] == 1 then
			-- 实时弹幕
			serverMgr:sendMsg("BulletServer", "getBullet", {sid = bulletD["id"]}, true, {bulletD = bulletD}, function(__data)
				local ___data = {}
				for _, d in pairs(__data) do
					if not modelMgr:getModel("BulletModel"):checkRepeatBullet(d.w, ___data) then
						if d.cross == 1 then
							___data[#___data + 1] = {math.random(3000) * 0.001, d.w, d.c, d.p + 5}
						else
							___data[#___data + 1] = {math.random(3000) * 0.001, d.w, d.c, d.p}
						end
					end
			    end
			    data.data = ___data
		    	BulletScreensUtils.init(data)
		    	BulletScreensUtils.bulletD = bulletD
		    end)
		else
		    serverMgr:sendMsg("BulletServer", "getBullet", {sid = bulletD["id"]}, true, {bulletD = bulletD}, function()
		    	data.data = modelMgr:getModel("BulletModel"):getChannelData(bulletD["id"])
		    	BulletScreensUtils.init(data)
		    	BulletScreensUtils.bulletD = bulletD
		    end)
		end
	end
end

function BulletScreensUtils.getBulletChannelEnabled(bulletD)
	local enable = SystemUtils.loadGlobalLocalData("bullet_"..bulletD["open"])
	if enable == nil then
		enable = true
	end
	BulletScreensUtils.enable = enable
	return enable
end

function BulletScreensUtils.setBulletChannelEnabled(bulletD, enable)
	BulletScreensUtils.enable = enable
	SystemUtils.saveGlobalLocalData("bullet_"..bulletD["open"], enable)
end

-- 颜色索引
local colorTab = 
{
	{cc.c3b(255, 255, 255), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(255,   0,   0), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(  0, 255,   0), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(  0,   0, 255), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(255, 255,   0), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(255,   0, 255), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(  0, 255, 255), cc.c4b(70, 40, 10, 255)},
	{cc.c3b(  0,   0,   0), cc.c4b(255, 255, 255, 255)},
}
-- local function
local _update
local _showCommonBullet

local _data = {}

local _common_TopSpace
local _common_BottomSpace
local _common_FontSize
local _common_LineSpace
local _common_MaxLine
local _common_showTime

local _top_FontSize
local _top_LineSpace
local _top_MaxLine
local _top_showTime

local _bottom_FontSize
local _bottom_LineSpace
local _bottom_MaxLine
local _bottom_showTime

local _center_FontSize
local _center_showTime

-- 数据结构
local _over = false
local _loop = false
local _maxTime = 0
local _lastTime = 0 -- 上一次时间轴
local _beginTick = 0 -- 时间轴
local _dataCurIdx = 0 -- data游标
local _commonBulletPools = {} -- 普通弹幕池
local _commonUnuseBulletPools = {} -- 缓存池
local _topBulletPools = {} -- 顶部弹幕池
local _bottomBulletPools = {} -- 顶部弹幕池
local _centerBulletPools = nil -- 中心弹幕池
local _crossImagePools = {} --跨服sprite池
local _topImagePools = {} --顶部
local _bottomImagePools = {} -- 底部图片
local _pushBulletData = {}	--推送的弹幕池，用于去重，init的时候会重置

-- 开关
local _top_enable = true
local _bottom_enable = true
local _center_enable = true
-- 显示层
local _commonLayer
local _topLayer
local _bottomLayer
local _centerLayer

-- 初始化
function BulletScreensUtils.init(data)
	BulletScreensUtils.clear()
	BulletScreensUtils.show()
	print("BulletScreensUtils.init")
	BulletScreensUtils.enable = true
	_pushBulletData = {}
	if not data then
		data = {}
	end
	-- 弹幕数据
	if data.data ~= nil then
		_data = data.data
	else
		_data = {}
		-- local count = 200
		-- for k, v in pairs(tab.lang) do
		-- 	count = count - 1
		-- 	if v.cn then
		-- 		_data[#_data + 1] = {random(20000) * 0.001, gsub(v.cn, "\n", ""), random(#colorTab), random(5)}
		-- 	end
		-- 	if count <= 0 then
		-- 		break
		-- 	end
		-- end
	end
	table.sort(_data, function(a, b)
		return a[1] < b[1]
	end)

	if data.loop then
		_loop = data.loop
	else
		_loop = false
	end
	if data.maxTime then
		_maxTime = data.maxTime
	else
		_maxTime = 20
	end
	
	_dataCurIdx = 1
	_beginTick = gettime()
	_over = false
	-- dump(_data)
	-- 滚动弹幕相关 --
	if data.common_TopSpace ~= nil then
		_common_TopSpace = data.common_TopSpace
	else
		_common_TopSpace = 0
	end
	if data.common_BottomSpace ~= nil then
		_common_BottomSpace = data.common_BottomSpace
	else
		_common_BottomSpace = 0
	end
	if data.common_FontSize ~= nil then
		_common_FontSize = data.common_FontSize
	else
		_common_FontSize = 22
	end
	if data.common_LineSpace ~= nil then
		_common_LineSpace = data.common_LineSpace
	else
		_common_LineSpace = 4
	end
	if data.common_MaxLine ~= nil then
		_common_MaxLine = data.common_MaxLine
	else
		_common_MaxLine = floor((MAX_SCREEN_HEIGHT - _common_TopSpace - _common_BottomSpace) / (_common_FontSize + _common_LineSpace))
	end
	if data.common_showTime ~= nil then
		_common_showTime = data.common_showTime
	else
		_common_showTime = 8
	end
	for i = 1, _common_MaxLine do
		_commonBulletPools[i] = {0, 0, 0}
	end
	-- 顶部弹幕相关 --
	if data.top_FontSize ~= nil then
		_top_FontSize = data.top_FontSize
	else
		_top_FontSize = 22
	end
	if data.top_LineSpace ~= nil then
		_top_LineSpace = data.top_LineSpace
	else
		_top_LineSpace = 4
	end
	if data.top_MaxLine ~= nil then
		_top_MaxLine = data.top_MaxLine
	else
		_top_MaxLine = floor(MAX_SCREEN_HEIGHT * 0.5 / (_top_FontSize + _top_LineSpace))
	end
	if data.top_showTime ~= nil then
		_top_showTime = data.top_showTime
	else
		_top_showTime = 5
	end
	for i = 1, _top_MaxLine do
		_topBulletPools[i] = {0, nil}
	end
	for i = 1, _top_MaxLine do 
		_topImagePools[i] = nil
	end
	-- 底部弹幕相关 --
	if data.bottom_FontSize ~= nil then
		_bottom_FontSize = data.bottom_FontSize
	else
		_bottom_FontSize = 22
	end
	if data.bottom_LineSpace ~= nil then
		_bottom_LineSpace = data.bottom_LineSpace
	else
		_bottom_LineSpace = 4
	end
	if data.bottom_MaxLine ~= nil then
		_bottom_MaxLine = data.bottom_MaxLine
	else
		_bottom_MaxLine = floor(MAX_SCREEN_HEIGHT * 0.5 / (_bottom_FontSize + _bottom_LineSpace))
	end
	if data.bottom_showTime ~= nil then
		_bottom_showTime = data.bottom_showTime
	else
		_bottom_showTime = 5
	end
	for i = 1, _bottom_MaxLine do
		_bottomBulletPools[i] = {0, nil}
	end
	for i = 1, _bottom_MaxLine do 
		_bottomImagePools[i] = nil
	end
	-- 中心弹幕相关
	if data.center_FontSize ~= nil then
		_center_FontSize = data.center_FontSize
	else
		_center_FontSize = 60
	end
	if data.center_showTime ~= nil then
		_center_showTime = data.center_showTime
	else
		_center_showTime = 5
	end

	-- 开关
	if data.top_enable ~= nil then
		_top_enable = data.top_enable
	else
		_top_enable = true
	end
	if data.bottom_enable ~= nil then
		_bottom_enable = data.bottom_enable
	else
		_bottom_enable = true
	end
	if data.center_enable ~= nil then
		_center_enable = data.center_enable
	else
		_center_enable = true
	end

	local bsLayer = viewMgr:getBulletScreensLayer()
	_commonLayer = cc.Node:create()
	bsLayer:addChild(_commonLayer, 100)
	_topLayer = cc.Node:create()
	bsLayer:addChild(_topLayer, 200)
	_bottomLayer = cc.Node:create()
	bsLayer:addChild(_bottomLayer, 200)
	_centerLayer = cc.Node:create()
	bsLayer:addChild(_centerLayer, 300)

	_bsUpdate = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
		_update()
	end, 0.1, false)
end

function BulletScreensUtils.clear()
	print("BulletScreensUtils.clear")
	BulletScreensUtils.enable = false
	local bsLayer = viewMgr:getBulletScreensLayer()
	bsLayer:removeAllChildren()
	_commonLayer = nil
	_topLayer = nil
	_bottomLayer = nil
	_centerLayer = nil
	if _bsUpdate then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_bsUpdate) 
		_bsUpdate = nil
	end
	_commonBulletPools = {}
	for k, _ in pairs(_commonUnuseBulletPools) do
		k:release()
	end
	_commonUnuseBulletPools = {}

	for k, _ in pairs (_crossImagePools) do 
		k:release()
	end
	_crossImagePools = {}

	_topBulletPools = {}
	_bottomBulletPools = {}
	_centerBulletPools = nil
	_data = nil
end

function BulletScreensUtils.show()
	print("BulletScreensUtils.show")
	viewMgr:getBulletScreensLayer():setVisible(true)
end

function BulletScreensUtils.hide()
	print("BulletScreensUtils.hide")
	viewMgr:getBulletScreensLayer():setVisible(false)
end

local LABEL = cc.Label
local _createWithTTF = LABEL.createWithTTF

local ccSequence = cc.Sequence
local ccRemoveSelf = cc.RemoveSelf
local ccCallFunc = cc.CallFunc
local ccMoveTo = cc.MoveTo
local ccDelayTime = cc.DelayTime
local ccFadeOut = cc.FadeOut
local ccp = cc.p
local ccSpawn = cc.Spawn

local ttf = UIUtils.ttfName
local ttf_title = UIUtils.ttfName_Title

-- 增加一条普通弹幕
function BulletScreensUtils.showCommonBullet(data)
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end
	
	-- 创建label
	local label = next(_commonUnuseBulletPools)
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf, _common_FontSize)
		label:setOpacity(220)
		_commonLayer:addChild(label)
	else
		label:setString(data[2])
		_commonLayer:addChild(label)
		_commonUnuseBulletPools[label] = nil
		label:release()
	end
	if data[3] then 
		local color = colorTab[data[3]]
		if color == nil then color = colorTab[1] end
		label:setColor(color[1])
		label:enableOutline(color[2], 2)
	end
	label:setAnchorPoint(0, 1)
	
	local width = label:getContentSize().width
	local dstX = -width
	-- 计算文字左边界到达屏幕左端的时间
	local v = (MAX_SCREEN_WIDTH + width) / _common_showTime
	local endTime1 = MAX_SCREEN_WIDTH / v

	local _time1, _time2, _type
	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	for i = 1, #_commonBulletPools do
		_time1, _time2 = _commonBulletPools[i][1], _commonBulletPools[i][2]
		_type = _commonBulletPools[i][3]
		if _type == 1 then
			if time + endTime1 > _time1 and time > _time2 then
				showIdx = i
				break
			end
		else
			if time > _time1 then
				showIdx = i
				break
			end	
		end
		if _time1 < minTime then
			minTimeIdx = i
			minTime = _time1
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end

	local posY = MAX_SCREEN_HEIGHT - _common_TopSpace - ((showIdx - 1) * (_common_FontSize + _common_LineSpace))
	label:setPosition(MAX_SCREEN_WIDTH, posY)
	label:runAction(ccSequence:create(
			ccMoveTo:create(_common_showTime, ccp(dstX, posY)),
			ccCallFunc:create(function ()
				label:retain()
				label:removeFromParent()
				_commonUnuseBulletPools[label] = 1
			end)
		))
	local nowTime = gettime() - _beginTick
	-- 文字完全出屏幕的时间
	_commonBulletPools[showIdx][1] = nowTime + _common_showTime
	-- 文字右端到达屏幕右端的时间
	_commonBulletPools[showIdx][2] = nowTime + width / v
	_commonBulletPools[showIdx][3] = 1
end
showCommonBullet = BulletScreensUtils.showCommonBullet

-- 增加一条逆向弹幕
function BulletScreensUtils.showReverseBullet(data)
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end
	
	-- 创建label
	local label = next(_commonUnuseBulletPools)
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf, _common_FontSize)
		label:setOpacity(220)
		_commonLayer:addChild(label)
	else
		label:setString(data[2])
		_commonLayer:addChild(label)
		_commonUnuseBulletPools[label] = nil
		label:release()
	end
	if data[3] then 
		local color = colorTab[data[3]]
		if color == nil then color = colorTab[1] end
		label:setColor(color[1])
		label:enableOutline(color[2], 2)
	end
	label:setAnchorPoint(0, 1)

	local width = label:getContentSize().width
	local dstX = -width
	-- 计算文字左边界到达屏幕左端的时间
	local v = (MAX_SCREEN_WIDTH + width) / _common_showTime
	local endTime1 = MAX_SCREEN_WIDTH / v

	local _time1, _time2, _type
	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	for i = 1, #_commonBulletPools do
		_time1, _time2 = _commonBulletPools[i][1], _commonBulletPools[i][2]
		_type = _commonBulletPools[i][3]
		if _type == 2 then
			if time + endTime1 > _time1 and time > _time2 then
				showIdx = i
				break
			end
		else
			if time > _time1 then
				showIdx = i
				break
			end	
		end
		if _time1 < minTime then
			minTimeIdx = i
			minTime = _time1
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end

	local posY = MAX_SCREEN_HEIGHT - _common_TopSpace - ((showIdx - 1) * (_common_FontSize + _common_LineSpace))
	label:setPosition(dstX, posY)
	label:runAction(ccSequence:create(
			ccMoveTo:create(_common_showTime, ccp(MAX_SCREEN_WIDTH, posY)),
			ccCallFunc:create(function ()
				label:retain()
				label:removeFromParent()
				_commonUnuseBulletPools[label] = 1
			end)
		))
	local nowTime = gettime() - _beginTick
	-- 文字完全出屏幕的时间
	_commonBulletPools[showIdx][1] = nowTime + _common_showTime
	-- 文字右端到达屏幕右端的时间
	_commonBulletPools[showIdx][2] = nowTime + width / v
	-- 正/逆
	_commonBulletPools[showIdx][3] = 2
end
showReverseBullet = BulletScreensUtils.showReverseBullet

-- 增加一条顶部弹幕
function BulletScreensUtils.showTopBullet(data)
	if not _top_enable then showCommonBullet(data) return end
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end

	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	local _time, label
	for i = 1, #_topBulletPools do
		_time = _topBulletPools[i][1]
		if time > _time then
			showIdx = i
			break
		end	
		if _time < minTime then
			minTimeIdx = i
			minTime = _time
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end
	label = _topBulletPools[showIdx][2]
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf_title, _top_FontSize)
		label:setAnchorPoint(0.5, 1)
		_topLayer:addChild(label)
	else
		label:setString(data[2])
	end

	if data[3] then 
		local color = colorTab[data[3]]
		if color == nil then color = colorTab[1] end
		label:setColor(color[1])
		label:enableOutline(color[2], 1)
	end
	label:setOpacity(255)

	local posY = MAX_SCREEN_HEIGHT - ((showIdx - 1) * (_top_FontSize + _top_LineSpace))
	label:setPosition(MAX_SCREEN_WIDTH * 0.5, posY)
	label:stopAllActions()
	label:runAction(ccSequence:create(
			ccDelayTime:create(_top_showTime),
			ccFadeOut:create(0.001)
		))
	
	local nowTime = gettime() - _beginTick
	-- 文字消失时间
	_topBulletPools[showIdx][1] = nowTime + _top_showTime
	_topBulletPools[showIdx][2] = label
end
showTopBullet = BulletScreensUtils.showTopBullet

-- 增加一条底部弹幕
function BulletScreensUtils.showBottomBullet(data)
	if not _bottom_enable then showCommonBullet(data) return end
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end

	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	local _time, label
	for i = 1, #_bottomBulletPools do
		_time = _bottomBulletPools[i][1]
		if time > _time then
			showIdx = i
			break
		end	
		if _time < minTime then
			minTimeIdx = i
			minTime = _time
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end
	label = _bottomBulletPools[showIdx][2]
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf_title, _bottom_FontSize)
		label:setAnchorPoint(0.5, 0)
		_bottomLayer:addChild(label)
	else
		label:setString(data[2])
	end
	if data[3] then 
		local color = colorTab[data[3]]
		if color == nil then color = colorTab[1] end
		label:setColor(color[1])
		label:enableOutline(color[2], 1)
	end
	label:setOpacity(255)

	local posY = ((showIdx - 1) * (_bottom_FontSize + _bottom_LineSpace))
	label:setPosition(MAX_SCREEN_WIDTH * 0.5, posY)
	label:stopAllActions()
	label:runAction(ccSequence:create(
			ccDelayTime:create(_bottom_showTime),
			ccFadeOut:create(0.001)
		))
	local nowTime = gettime() - _beginTick
	-- 文字消失时间
	_bottomBulletPools[showIdx][1] = nowTime + _bottom_showTime
	_bottomBulletPools[showIdx][2] = label
end
showBottomBullet = BulletScreensUtils.showBottomBullet

-- 增加一条中心弹幕
function BulletScreensUtils.showCenterBullet(data)
	if not _center_enable then showCommonBullet(data) return end
	if _centerBulletPools == nil then
		_centerBulletPools = _createWithTTF(LABEL, data[2], ttf_title, _center_FontSize)
		_centerBulletPools:setAnchorPoint(0.5, 0.5)
		_centerBulletPools:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
		_centerLayer:addChild(_centerBulletPools)
	else
		_centerBulletPools:setString(data[2])
	end
	if data[3] then
		local color = colorTab[data[3]]
		if color == nil then color = colorTab[1] end
		_centerBulletPools:setColor(color[1])
		_centerBulletPools:enableOutline(color[2], 1)
	end
	_centerBulletPools:stopAllActions()
	_centerBulletPools:runAction(ccSequence:create(
			ccDelayTime:create(_center_showTime),
			ccFadeOut:create(0.001)
		))
end
showCenterBullet = BulletScreensUtils.showCenterBullet

-------------------------------------------------------------------


local Sprite = cc.Sprite
local _createSprite = Sprite.createWithSpriteFrameName

local crossColorTable = {
	cc.c4b(60,30,10,255),
	cc.c3b(255, 255, 120),
	cc.c3b(120, 255, 120),
	cc.c3b(120, 255, 255),
	cc.c3b(120, 120, 255),
	cc.c3b(255, 120, 255),
	cc.c3b(255, 120, 120)
}

-- 增加一条跨服普通弹幕
function BulletScreensUtils.showCommonBulletCross(data)
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end
	
	-- 创建label
	local label = next(_commonUnuseBulletPools)
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf, _common_FontSize)
		label:setOpacity(220)
		_commonLayer:addChild(label)
		label:enableOutline(crossColorTable[1], 1)
	else
		label:setString(data[2])
		_commonLayer:addChild(label)
		_commonUnuseBulletPools[label] = nil
		label:release()
	end
	-- if data[3] then 
	-- 	local color = colorTab[data[3]]
	-- 	if color == nil then color = colorTab[1] end
	-- 	label:setColor(color[1])
	-- 	label:enableOutline(color[2], 2)
	-- end
	
	label:setAnchorPoint(0, 1)

	local sprite = next(_crossImagePools)
	if sprite == nil then
		sprite = _createSprite(Sprite,"globalImageUI_gvg_cross.png")
		_commonLayer:addChild(sprite)
	else
		_commonLayer:addChild(sprite)
		_crossImagePools[sprite] = nil
		sprite:release()
	end
	sprite:setAnchorPoint(0, 1)
	

	local lable_size = label:getContentSize()
	local sprite_size = sprite:getContentSize()
	local SpriteW = sprite_size.width
	
	local width = lable_size.width
	local dstX = -width
	-- 计算文字左边界到达屏幕左端的时间
	local v = (MAX_SCREEN_WIDTH + width + SpriteW) / _common_showTime
	local endTime1 = (MAX_SCREEN_WIDTH + SpriteW) / v

	local _time1, _time2, _type
	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	for i = 1, #_commonBulletPools do
		_time1, _time2 = _commonBulletPools[i][1], _commonBulletPools[i][2]
		_type = _commonBulletPools[i][3]
		if _type == 1 then
			if time + endTime1 > _time1 and time > _time2 then
				showIdx = i
				break
			end
		else
			if time > _time1 then
				showIdx = i
				break
			end	
		end
		if _time1 < minTime then
			minTimeIdx = i
			minTime = _time1
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end

	local posY = MAX_SCREEN_HEIGHT - _common_TopSpace - ((showIdx - 1) * (_common_FontSize + _common_LineSpace))
	local beginX = SpriteW and MAX_SCREEN_WIDTH + SpriteW or MAX_SCREEN_WIDTH
	local dy = posY - (sprite_size.height - lable_size.height)*0.5
	label:setPosition(beginX, dy)
	local dtime = _common_showTime * 0.05
	label:runAction(ccSequence:create(
			ccMoveTo:create(_common_showTime, ccp(dstX, dy)),
			ccCallFunc:create(function ()
				label:retain()
				label:removeFromParent()
				_commonUnuseBulletPools[label] = 1
			end)
		))
	label:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.TintTo:create(dtime, crossColorTable[2]),
        cc.TintTo:create(dtime, crossColorTable[3]),
        cc.TintTo:create(dtime, crossColorTable[4]),
        cc.TintTo:create(dtime, crossColorTable[5]),
        cc.TintTo:create(dtime, crossColorTable[6]),
        cc.TintTo:create(dtime, crossColorTable[7])
    )))


	sprite:setPosition(MAX_SCREEN_WIDTH, posY)
	sprite:runAction(ccSequence:create(
		ccMoveTo:create(_common_showTime, ccp(dstX-SpriteW, posY)),
		ccCallFunc:create(function ()
			sprite:retain()
			sprite:removeFromParent()
			_crossImagePools[sprite] = 1
		end)
	))

	local nowTime = gettime() - _beginTick
	-- 文字完全出屏幕的时间
	_commonBulletPools[showIdx][1] = nowTime + _common_showTime
	-- 文字右端到达屏幕右端的时间
	_commonBulletPools[showIdx][2] = nowTime + (width + SpriteW) / v
	_commonBulletPools[showIdx][3] = 1
end
showCommonBulletCross = BulletScreensUtils.showCommonBulletCross

-- 增加一条逆向弹幕
function BulletScreensUtils.showReverseBulletCross(data)
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end
	
	-- 创建label
	local label = next(_commonUnuseBulletPools)
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf, _common_FontSize)
		label:setOpacity(220)
		_commonLayer:addChild(label)
		label:enableOutline(crossColorTable[1], 1)
	else
		label:setString(data[2])
		_commonLayer:addChild(label)
		_commonUnuseBulletPools[label] = nil
		label:release()
	end
	-- if data[3] then 
	-- 	local color = colorTab[data[3]]
	-- 	if color == nil then color = colorTab[1] end
	-- 	label:setColor(color[1])
	-- 	label:enableOutline(color[2], 2)
	-- end
	label:setAnchorPoint(0, 1)
	local sprite = next(_crossImagePools)
	if sprite == nil then
		sprite = _createSprite(Sprite,"globalImageUI_gvg_cross.png")
		_commonLayer:addChild(sprite)
	else
		_commonLayer:addChild(sprite)
		_crossImagePools[sprite] = nil
		sprite:release()
	end
	sprite:setAnchorPoint(0, 1)
	
	local lable_size = label:getContentSize()
	local sprite_size = sprite:getContentSize()
	local SpriteW = sprite_size.width

	local width = lable_size.width
	local dstX = -width
	-- 计算文字左边界到达屏幕左端的时间
	local v = (MAX_SCREEN_WIDTH + width + SpriteW) / _common_showTime
	local endTime1 = (MAX_SCREEN_WIDTH + SpriteW) / v

	local _time1, _time2, _type
	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	for i = 1, #_commonBulletPools do
		_time1, _time2 = _commonBulletPools[i][1], _commonBulletPools[i][2]
		_type = _commonBulletPools[i][3]
		if _type == 2 then
			if time + endTime1 > _time1 and time > _time2 then
				showIdx = i
				break
			end
		else
			if time > _time1 then
				showIdx = i
				break
			end	
		end
		if _time1 < minTime then
			minTimeIdx = i
			minTime = _time1
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end

	local posY = MAX_SCREEN_HEIGHT - _common_TopSpace - ((showIdx - 1) * (_common_FontSize + _common_LineSpace))
	local dy = posY - (sprite_size.height - lable_size.height)*0.5
	label:setPosition(dstX-SpriteW, dy)
	local dtime = _common_showTime * 0.05
	label:runAction(ccSequence:create(
			ccMoveTo:create(_common_showTime, ccp(MAX_SCREEN_WIDTH, dy)),
			ccCallFunc:create(function ()
				label:retain()
				label:removeFromParent()
				_commonUnuseBulletPools[label] = 1
			end)
		))
	label:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.TintTo:create(dtime, crossColorTable[2]),
        cc.TintTo:create(dtime, crossColorTable[3]),
        cc.TintTo:create(dtime, crossColorTable[4]),
        cc.TintTo:create(dtime, crossColorTable[5]),
        cc.TintTo:create(dtime, crossColorTable[6]),
        cc.TintTo:create(dtime, crossColorTable[7])
    )))

	sprite:setPosition(-SpriteW, posY)
	sprite:runAction(ccSequence:create(
		ccMoveTo:create(_common_showTime, ccp(MAX_SCREEN_WIDTH+width, posY)),
		ccCallFunc:create(function ()
			sprite:retain()
			sprite:removeFromParent()
			_crossImagePools[sprite] = 1
		end)
	))

	local nowTime = gettime() - _beginTick
	-- 文字完全出屏幕的时间
	_commonBulletPools[showIdx][1] = nowTime + _common_showTime
	-- 文字右端到达屏幕右端的时间
	_commonBulletPools[showIdx][2] = nowTime + (width + SpriteW) / v
	-- 正/逆
	_commonBulletPools[showIdx][3] = 2
end
showReverseBulletCross = BulletScreensUtils.showReverseBulletCross

-- 增加一条顶部弹幕
function BulletScreensUtils.showTopBulletCross(data)
	if not _top_enable then showCommonBulletCross(data) return end
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end

	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	local _time, label
	for i = 1, #_topBulletPools do
		_time = _topBulletPools[i][1]
		if time > _time then
			showIdx = i
			break
		end	
		if _time < minTime then
			minTimeIdx = i
			minTime = _time
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end
	label = _topBulletPools[showIdx][2]
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf_title, _top_FontSize)
		label:setAnchorPoint(0.5, 1)
		_topLayer:addChild(label)
		label:enableOutline(crossColorTable[1], 1)
	else
		label:setString(data[2])
	end

	-- if data[3] then 
	-- 	local color = colorTab[data[3]]
	-- 	if color == nil then color = colorTab[1] end
	-- 	label:setColor(color[1])
	-- 	label:enableOutline(color[2], 1)
	-- end
	label:setOpacity(255)

	local sprite = _topImagePools[showIdx]
	if sprite == nil then
		sprite = _createSprite(Sprite,"globalImageUI_gvg_cross.png")
		_topLayer:addChild(sprite)
		sprite:setAnchorPoint(1, 1)
	end
	sprite:setOpacity(255)

	local lable_size = label:getContentSize()
	local sprite_size = sprite:getContentSize()
	local SpriteW = sprite_size.width


	local posY = MAX_SCREEN_HEIGHT - ((showIdx - 1) * (_top_FontSize + _top_LineSpace))
	local dy = posY - (sprite_size.height - lable_size.height) * 0.5
	local labelX = MAX_SCREEN_WIDTH * 0.5 + SpriteW * 0.5
	local spriteX = labelX - lable_size.width * 0.5

	local dtime = _top_showTime * 0.2
	label:setPosition(labelX , dy)
	label:stopAllActions()
	label:runAction(ccSequence:create(
			ccDelayTime:create(_top_showTime),
			ccFadeOut:create(0.001),
			ccCallFunc:create(function()
				label:stopAllActions()
			end)
		))

	label:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.TintTo:create(dtime, crossColorTable[2]),
        cc.TintTo:create(dtime, crossColorTable[3]),
        cc.TintTo:create(dtime, crossColorTable[4]),
        cc.TintTo:create(dtime, crossColorTable[5]),
        cc.TintTo:create(dtime, crossColorTable[6]),
        cc.TintTo:create(dtime, crossColorTable[7])
    )))

	sprite:setPosition(spriteX , posY)
	sprite:stopAllActions()
	sprite:runAction(ccSequence:create(
			ccDelayTime:create(_top_showTime),
			ccFadeOut:create(0.001)
		))
	
	local nowTime = gettime() - _beginTick
	-- 文字消失时间
	_topBulletPools[showIdx][1] = nowTime + _top_showTime
	_topBulletPools[showIdx][2] = label
	_topImagePools[showIdx] = sprite
end
showTopBulletCross = BulletScreensUtils.showTopBulletCross

-- 增加一条底部弹幕
function BulletScreensUtils.showBottomBulletCross(data)
	if not _bottom_enable then showCommonBulletCross(data) return end
	local time = data[1]
	if type(time) ~= "number" then
		time = 0
	end

	local minTimeIdx = 0
	local minTime = 99999
	local showIdx = 0
	local _time, label
	for i = 1, #_bottomBulletPools do
		_time = _bottomBulletPools[i][1]
		if time > _time then
			showIdx = i
			break
		end	
		if _time < minTime then
			minTimeIdx = i
			minTime = _time
		end
	end
	if showIdx == 0 then
		showIdx = minTimeIdx
	end
	label = _bottomBulletPools[showIdx][2]
	if label == nil then
		label = _createWithTTF(LABEL, data[2], ttf_title, _bottom_FontSize)
		label:setAnchorPoint(0.5, 0)
		_bottomLayer:addChild(label)
		label:enableOutline(crossColorTable[1], 1)
	else
		label:setString(data[2])
	end
	-- if data[3] then 
	-- 	local color = colorTab[data[3]]
	-- 	if color == nil then color = colorTab[1] end
	-- 	label:setColor(color[1])
	-- 	label:enableOutline(color[2], 1)
	-- end
	label:setOpacity(255)

	local sprite = _bottomImagePools[showIdx]
	if sprite == nil then
		sprite = _createSprite(Sprite,"globalImageUI_gvg_cross.png")
		_bottomLayer:addChild(sprite)
		sprite:setAnchorPoint(1, 0)
	end
	sprite:setOpacity(255)

	local lable_size = label:getContentSize()
	local sprite_size = sprite:getContentSize()
	local SpriteW = sprite_size.width

	local posY = ((showIdx - 1) * (_bottom_FontSize + _bottom_LineSpace))
	local dy = posY + (sprite_size.height - lable_size.height) * 0.5
	local labelX = MAX_SCREEN_WIDTH * 0.5 + SpriteW * 0.5
	local spriteX = labelX - lable_size.width * 0.5
	local dtime = _bottom_showTime * 0.2
	label:setPosition(labelX, dy)
	label:stopAllActions()
	label:runAction(ccSequence:create(
			ccDelayTime:create(_bottom_showTime),
			ccFadeOut:create(0.001),
			ccCallFunc:create(function()
				label:stopAllActions()
			end)
		))

	label:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.TintTo:create(dtime, crossColorTable[2]),
        cc.TintTo:create(dtime, crossColorTable[3]),
        cc.TintTo:create(dtime, crossColorTable[4]),
        cc.TintTo:create(dtime, crossColorTable[5]),
        cc.TintTo:create(dtime, crossColorTable[6]),
        cc.TintTo:create(dtime, crossColorTable[7])
    )))

	sprite:setPosition(spriteX, posY)
	sprite:stopAllActions()
	sprite:runAction(ccSequence:create(
			ccDelayTime:create(_bottom_showTime),
			ccFadeOut:create(0.001)
		))

	local nowTime = gettime() - _beginTick
	-- 文字消失时间
	_bottomBulletPools[showIdx][1] = nowTime + _bottom_showTime
	_bottomBulletPools[showIdx][2] = label
	_bottomImagePools[showIdx] = sprite
end
showBottomBulletCross = BulletScreensUtils.showBottomBulletCross

-- 增加一条中心弹幕
function BulletScreensUtils.showCenterBullet(data)
	if not _center_enable then showCommonBullet(data) return end
	if _centerBulletPools == nil then
		_centerBulletPools = _createWithTTF(LABEL, data[2], ttf_title, _center_FontSize)
		_centerBulletPools:setAnchorPoint(0.5, 0.5)
		_centerBulletPools:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
		_centerLayer:addChild(_centerBulletPools)
	else
		_centerBulletPools:setString(data[2])
	end
	if data[3] then
		local color = colorTab[data[3]]
		if color == nil then color = colorTab[1] end
		_centerBulletPools:setColor(color[1])
		_centerBulletPools:enableOutline(color[2], 1)
	end
	_centerBulletPools:stopAllActions()
	_centerBulletPools:runAction(ccSequence:create(
			ccDelayTime:create(_center_showTime),
			ccFadeOut:create(0.001)
		))
end
showCenterBullet = BulletScreensUtils.showCenterBullet
--------------------

local showBulletFunction = {showCommonBullet, showReverseBullet, showTopBullet, showBottomBullet, showCenterBullet,
	showCommonBulletCross, showReverseBulletCross, showTopBulletCross, showBottomBulletCross, showCenterBulletCross
}

function BulletScreensUtils.showBulletNow(_type, data)
	local allData = {}
	table.merge(allData, _data)
	for k, v in pairs(_pushBulletData) do
		allData[#allData + 1] = clone(v)
	end
	if modelMgr:getModel("BulletModel"):checkRepeatBullet(data[2], allData) then return end
	_pushBulletData[#_pushBulletData + 1] = data
	if showBulletFunction[_type] then
		local nowTime = gettime() - _beginTick
		data[1] = nowTime
		showBulletFunction[_type](data)
	end
end

function BulletScreensUtils.update()
	local tick = gettime()
	local time = tick - _beginTick
	if _lastTime ~= nil and time > _lastTime + 5 then
		time = _lastTime + 0.03
		_beginTick = tick - time
	end
	_lastTime = time
	local _time
	local pos
	if #_data > 0 then
		if _dataCurIdx <= #_data then
			local data = _data[_dataCurIdx]
			local _time = data[1]
			if type(_time) ~= "number" then 
				_time = 0
			end
			while not _over and data[1] < time do
				pos = data[4]
				if type(pos) == "number" then
					if pos < 1 or pos > 10 then
						pos = 1
					end
				else
					pos = 1
				end
				showBulletFunction[pos](data)
				_dataCurIdx = _dataCurIdx + 1
				if _dataCurIdx > #_data then
					if _loop then

					else
						_over = true
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_bsUpdate) 
						_bsUpdate = nil
					end
					break
				end
				data = _data[_dataCurIdx]
			end
		end
	end
	if time > _maxTime then
		_dataCurIdx = 1
		local dTick = _beginTick
		_beginTick = gettime()
		dTick = _beginTick - dTick
		local cb
		for i = 1, #_commonBulletPools do
			cb = _commonBulletPools[i]
			cb[1] = cb[1] - dTick
			cb[2] = cb[2] - dTick
		end
		for i = 1, #_topBulletPools do
			_topBulletPools[i][1] = _topBulletPools[i][1] - dTick
		end
		for i = 1, #_bottomBulletPools do
			_bottomBulletPools[i][1] = _bottomBulletPools[i][1] - dTick
		end
	end
end
_update = BulletScreensUtils.update

-- 插入一条弹幕, 返回值为弹幕插入时间
function BulletScreensUtils.pushBullet(str, pos, color)
	if _data == nil then return end
	if modelMgr:getModel("BulletModel"):checkRepeatBullet(str, _data) then return end
	local time = gettime() - _beginTick + 0.2
	if time > _maxTime then
		time = time - _maxTime
	end
	_data[#_data + 1] = {time, str, color, pos}
	table.sort(_data, function(a, b)
		return a[1] < b[1]
	end)
end

function BulletScreensUtils.getPushTime()
	local time = gettime() - _beginTick + 0.3
	if time > _maxTime then
		time = time - _maxTime
	end
	return time
end



function BulletScreensUtils.dtor()
	_beginTick = nil
	_bottom_enable = nil
	_bottomBulletPools = nil
	_bottomLayer = nil
	_bsUpdate = nil
	_center_enable = nil
	_centerBulletPools = nil
	_centerLayer = nil
	_common_FontSize = nil
	_common_LineSpace = nil
	_common_MaxLine = nil
	_common_showTime = nil
	_commonBulletPools = nil
	_commonLayer = nil
	_createWithTTF = nil
	_data = nil
	_dataCurIdx = nil
	_loop = nil
	_over = nil
	_showCommonBullet = nil
	_top_enable = nil
	_topBulletPools = nil
	_topLayer = nil
	_update = nil
	ccDelayTime = nil
	ccFadeOut = nil
	ccMoveTo = nil
	ccCallFunc = nil
	ccp = nil
	ccRemoveSelf = nil
	ccSequence = nil
	colorTab = nil
	floor = nil
	gettime = nil
	gsub = nil
	LABEL = nil
	MAX_SCREEN_HEIGHT = nil
	MAX_SCREEN_WIDTH = nil
	random = nil
	showBulletFunction = nil
	ttf = nil
	ttf_title = nil
	viewMgr = nil
	_top_FontSize = nil
	_top_LineSpace = nil
	_top_MaxLine = nil
	_top_showTime = nil
	_bottom_FontSize = nil
	_bottom_LineSpace = nil
	_bottom_MaxLine = nil
	_bottom_showTime = nil
	_center_FontSize = nil
	_center_showTime = nil
	_common_TopSpace = nil
	_common_BottomSpace = nil
	serverMgr = nil
	modelMgr = nil
	_pushBulletData = {}
end

return BulletScreensUtils