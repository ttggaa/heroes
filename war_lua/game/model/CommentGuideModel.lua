--[[
    Filename:    CommentGuideModel.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-3-23 17:26:00
    Description: 评论引导
--]]

local CommentGuideModel = class("CommentGuideModel", BaseModel)

--[[
弹出条件
1、单抽获得XX兵团
2、十连抽得某兵团
3、英雄交锋N胜
4、冠军对决达到XX段位
5、竞技场排名进入前N
6、抽出某宝物
]]

function CommentGuideModel:ctor()
	CommentGuideModel.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")

	self:registerTimer(5, 0, GRandom(0, 10), function ()
        self:setAcShowRed(2)
    end)
end

--外部调用接口
function CommentGuideModel:checkCommentGuide(inData)
	self._curType = inData.inType
	if self["checkGuide" .. inData.inType] then
		return self["checkGuide" .. inData.inType](self, inData)
	end

	return false
end

--是否可以弹评论引导
function CommentGuideModel:isCanCommentGuide()
	--1开 0关
	local isSysOpen = tab.setting["COMMENT_PRIV"].value
	if isSysOpen == 0 then  	
		return false
	end

	--ios
	if not OS_IS_IOS then  		
		return false
	end

	local userData = self._userModel:getData()
    local commentLocal = SystemUtils.loadAccountLocalData("COMMENT_GUIDE") or {} --本地状态
    
    --版本重置
    local lastT = tonumber(commentLocal["lastT"]) or 0
	local versionT = TimeUtils.getIntervalByTimeString(tab.setting["COMMENT_TIME"].value)
	local curTime = self._userModel:getCurServerTime()
	if lastT < versionT and curTime >= versionT then 
		commentLocal = {}
		userData.commentAward = 0
		return true
	end

	--已跳转过  --1已领取 玩家字段
	if userData.commentAward == 1 then  	
		return false
	end

    --竞技场首次判断
    if self._curType == 5 and commentLocal[5] ~= nil then
    	return false
    end

    --当天第一次
	local curT = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(curTime,"%Y-%m-%d 05:00:00"))
	if curTime < curT then
		curT = curT - 86400
	end
	if lastT < curT then
		return true
	end

    return false
end

--1单抽获得XX兵团
function CommentGuideModel:checkGuide1(inData)
	local isCanPop = self:isCanCommentGuide()
	if isCanPop == true then
		local data = tab.comterm[1] or {}
		local num  = data.num 
		if num and type(num) == "table" then
			for i,v in ipairs(num) do
				if v == inData.teamId then
					return true,{curType = 1, num = v}
				end
			end
		end
	end
	
	return false
end

--2十连抽得某兵团
function CommentGuideModel:checkGuide2(inData)
	local isCanPop = self:isCanCommentGuide()
	if isCanPop == true then
		local data = tab.comterm[1] or {}
		local num  = data.num 
		if num and type(num) == "table" then
			for i,v in ipairs(num) do
				if v == inData.teamId then
					return true,{curType = 2, num = v}
				end
			end
		end
	end
	return false
end

--3英雄交锋N胜
function CommentGuideModel:checkGuide3(inData)
	local num = inData.num
	local data = tab.comterm[inData.inType]
	if data["num"] == num then
		local isCanPop = self:isCanCommentGuide()
		if isCanPop == true then
			local param = {curType = 3, num = num}
			return true, param
		end
	end
	return false
end

--4冠军对决达到XX段位 
function CommentGuideModel:checkGuide4(inData)
	local num = inData.num
	local data = tab.comterm[inData.inType]
	if data["num"] == num then
		local isCanPop = self:isCanCommentGuide()
		if isCanPop == true then
			local param = {curType = 4, num = num}
			return true, param
		end
	end

	return false
end

--5竞技场排名进入前N
function CommentGuideModel:checkGuide5(inData)
	local isCanPop = self:isCanCommentGuide()
	if isCanPop == true then
		local data = tab.comterm[5]
		local num = inData.num
		if data.num >= num then
			return true,{curType = 5, num = data.num}
		end
	end
	return false
end

--6抽出某宝物
function CommentGuideModel:checkGuide6(inData)
	local isCanPop = self:isCanCommentGuide()
	if isCanPop == true then
		local data = tab.comterm[6]
		local num  = data.num 
		if num and type(num) == "table" then
			for i,v in ipairs(num) do
				if v == inData.treasureId then
					return true,{curType = 6, num = v}
				end
			end
		end
	end
	return false
end

-- 活动界面是否显示
function CommentGuideModel:isAcCommentShow()
	if true then
		return false
	end

	if OS_IS_IOS then
		local commentAward = self._userModel:getData().commentAward  --1已领取 玩家字段
		if commentAward == 1 then
			return false
		else
			return true
		end
	end

	return false
end

function CommentGuideModel:isAcShowRed()
	if self:isAcCommentShow() == false then
		return false
	end

	local isAcShow = SystemUtils.loadAccountLocalData("AC_COMMENT_SHOW")
	if not isAcShow or isAcShow == 2 then
		return true
	end
	return false
end

function CommentGuideModel:setAcShowRed(isShow)   --1已显示过  2未显示过
	if isShow ~= nil then
		SystemUtils.saveAccountLocalData("AC_COMMENT_SHOW", isShow)
	end	
end

return CommentGuideModel

--[[
local param = {inType = 3, num = }
local isPop, popData = self._modelMgr:getModel("CommentGuideModel"):checkCommentGuide(param)
if isPop == true then
	self._viewMgr:showView("global.GlobalCommentGuideView", popData)
end
]]