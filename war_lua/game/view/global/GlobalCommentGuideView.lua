--[[
    Filename:    GlobalCommentGuideView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-3-23 1:04:00
    Description: 评论引导界面
--]]

local GlobalCommentGuideView = class("GlobalCommentGuideView", BasePopView)

--[[
弹出条件
1、单抽获得XX兵团
2、十连抽得某兵团
3、英雄交锋N胜
4、冠军对决达到XX段位
5、竞技场排名进入前N
6、抽出某宝物
]]

function GlobalCommentGuideView:ctor()
	GlobalCommentGuideView.super.ctor(self)
end

function GlobalCommentGuideView:onInit()
	local bg = self:getUI("bg")
	local spImg = ccui.ImageView:create("asset/bg/comment_roleImg.png")
	spImg:setPosition(328, 352)
	bg:addChild(spImg)

    local tip2 = self:getUI("bg.tip2")
	tip2:setString(lang("COMTERM8"))

	--本地状态
	local function recordLocal()
	    local commentLocal = SystemUtils.loadAccountLocalData("COMMENT_GUIDE") or {} --本地状态
    
	    local lastT = tonumber(commentLocal["lastT"]) or 0
		local versionT = TimeUtils.getIntervalByTimeString(tab.setting["COMMENT_TIME"].value)
		local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
		
		if lastT < versionT and curTime >= versionT then 
			commentLocal = {}
		end

		commentLocal["lastT"] = curTime
		if self._curType == 5 then  --竞技场首次
			commentLocal[5] = curTime
		end
		SystemUtils.saveAccountLocalData("COMMENT_GUIDE", commentLocal)
	end 

	local cancelBtn = self:getUI("bg.cancelBtn")
	self:registerClickEvent(cancelBtn, function()
		recordLocal()
		self:close()
		end)

	local cmtBtn = self:getUI("bg.cmtBtn")
	self:registerClickEvent(cmtBtn, function()
		--跳转ios
		-- self._isClick = true
		cmtBtn:setTouchEnabled(false)
		cancelBtn:setTouchEnabled(false)
		sdkMgr:loadUrl({type = "1", url = GameStatic.CommentGuide_ios_url})
		recordLocal()
		self._serverMgr:sendMsg("UserServer", "getIOSCommentAward", {}, true, {}, function (result)
			-- DialogUtils.showGiftGet({
	  --           gifts = result["reward"], 
	  --           callback = function() 
	  --           	self:close()
	  --       	end
	  --           })
			-- self:setVisible(false)
			self:close()
		end)
		end)

	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
        	UIUtils:reloadLuaFile("global.GlobalCommentGuideView")
        elseif eventType == "enter" then
        end
    end)
end

function GlobalCommentGuideView:reflashUI(inData)
	-- self._curType = inData["curType"]

	-- local curData = tab.comterm[self._curType]
	-- local desc
	-- local desc1 = lang(curData["describe"])
	-- if self._curType == 1 or self._curType == 2 then   	--单抽获得XX兵团 / 十连抽得某兵团
	-- 	local teamId = inData["num"]
	-- 	local name = lang(tab.team[teamId]["name"])
	-- 	desc = string.gsub(desc1, "$name", name)

	-- elseif self._curType == 3 then 						--英雄交锋N胜
	-- 	local num = inData["num"]
	-- 	desc = string.gsub(desc1, "$num", num)

	-- elseif self._curType == 4 then 						--冠军对决达到XX段位
	-- 	local num = inData["num"]
	-- 	local name = lang(tab.leagueRank[num]["name"])
	-- 	desc = string.gsub(desc1, "$name", name)

	-- elseif self._curType == 5 then 						--竞技场排名进入前N
	-- 	local num = inData["num"]
	-- 	desc = string.gsub(desc1, "$num", num)

	-- elseif self._curType == 6 then 						--抽出某宝物
	-- 	local tID = inData["num"]
	-- 	local tName = lang(tab.disTreasure[tID]["name"])
	-- 	desc = string.gsub(desc1, "$num", tName)
	-- end

	-- --des
	-- if desc then
	-- 	local bg = self:getUI("bg")
	--     local desc = RichTextFactory:create(desc, 410 , 0)
	--     desc:setAnchorPoint(cc.p(1, 0.5))
	--     desc:formatText()
	--     desc:setPosition(330 + 225 + desc:getContentSize().width, 470)
	--     bg:addChild(desc)
	-- end
	
    --reward
 --    local rwdBg = self:getUI("bg.rwdBg")
 --    local itemId = tab.comaward["COMAWARD_NAME"]["award1Show"][1][2]
 --    local itemNum = tab.comaward["COMAWARD_NAME"]["award1Show"][1][3]
	-- local itemData = tab:AvatarFrame(itemId)
	-- local rwdIcon = IconUtils:createHeadFrameIconById({itemId = itemId, itemData = itemData})
	-- rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
 --    rwdIcon:setPosition(rwdBg:getContentSize().width * 0.5, rwdBg:getContentSize().height * 0.5 + 15)
 --    rwdBg:addChild(rwdIcon)
end

function GlobalCommentGuideView:applicationWillEnterForeground(second)
	-- if self._isClick and self._isClick == true then
	-- 	self._serverMgr:sendMsg("UserServer", "getIOSCommentAward", {}, true, {}, function (result)
	-- 		DialogUtils.showGiftGet({
	--             gifts = result["reward"], 
	--             callback = function() end
	--             })
	-- 		self:close()
	-- 		end)
	-- end
end

return GlobalCommentGuideView