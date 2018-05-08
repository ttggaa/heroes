--
-- Author: huangguofang
-- Date: 2017-07-03 17:18:15
--
local AcCollectFriendsSendDialog = class("AcCollectFriendsSendDialog", BasePopView)

function AcCollectFriendsSendDialog:ctor(param)
    AcCollectFriendsSendDialog.super.ctor(self)
    self._textArr = param.selectData or {}
    self._friendData = param.friendData or {}
    self._callback = param.succCallBack
    self._celebrationModel = self._modelMgr:getModel("CelebrationModel")
end

function AcCollectFriendsSendDialog:onInit()
    self._okBtn = self:getUI("bg.okBtn")
    self._title = self:getUI("bg.title")    
    UIUtils:setTitleFormat(self._title, 6)
    self._icons = {}
    self._toolId = {
    	[31038] = "英",
		[31039] = "雄",
		[31040] = "无",
		[31041] = "敌",
		[31042] = "经",
		[31043] = "典",
		[31044] = "归",
		[31045] = "来",
	}

    self:registerClickEvent(self._okBtn, function ()
    	-- 
    	local isOpen = self._celebrationModel:isCelebrationEnd()
		if not isOpen then
			self._viewMgr:showTip("活动已结束")
			return 
		end
    	local fUsid = self._friendData and self._friendData.usid or ""
    	local argsStr = ""
    	if table.nums(self._textArr) > 0 then
    		argsStr = json.encode(self._textArr)
    	end
    	self._serverMgr:sendMsg("ActivityServer", "giveTextToFriend", {usid=fUsid,args=argsStr}, true, {},  
    		function(result,succ)		    
		    	if self._callback then
		    		self._callback()
		    	end
		    	self._viewMgr:showTip("赠送成功！")
		        self:close(false, self._callback)
		        UIUtils:reloadLuaFile("activity.celebration.AcCollectFriendsSendDialog")
			end)
    end)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close(false)
        UIUtils:reloadLuaFile("activity.celebration.AcCollectFriendsSendDialog")
    end)

    self:addToolScrollView()

end
function AcCollectFriendsSendDialog:addToolScrollView()
	if not self._textArr then return end
	local itemScrollView = self:getUI("bg.itemScrollView")
	local sVisibleH = itemScrollView:getContentSize().height
	local scrollH = 40
	local itemNum = table.nums(self._textArr)
	local itemH = 76

	scrollH = scrollH + math.ceil(itemNum/4)*itemH + 10
	scrollH = scrollH > sVisibleH and scrollH or sVisibleH
	itemScrollView:setInnerContainerSize(cc.size(itemScrollView:getContentSize().width, scrollH))

	local str = " "
	local posx = 15 
	local posy = scrollH - itemH - 40
	local i = 0
	-- local tempArr = {}
	-- for k,v in pairs(self._textArr) do
	-- 	tempArr[]
	-- end
	for k,v in pairs(self._textArr) do
		i = i + 1
		local itemId = k
		local toolD = tab:Tool(tonumber(itemId))
		icon = IconUtils:createItemIconById({itemId = tonumber(itemId),itemData = toolD,num=1})
		icon:setName("icon" .. k)
		icon:setScale(0.66)
		table.insert(self._icons, icon)
		itemScrollView:addChild(icon,5)
		str = str .. self._toolId[tonumber(k)] 
		if i < itemNum then
			str = str .. ","
		end
	end

	i = 0
	for k,v in pairs(self._icons) do
		i = i + 1
		v:setPosition(posx,posy)
		print("posx===,",posx,i)
		if i == 4 then
			posx = 15
			posy = posy - itemH
		else
			posx = posx + itemH
		end
	end

	local name = self._friendData and self._friendData.name or ""
	local titleStr = "[color=462800]是否确定将下列道具赠送给  " .. "[color=1ca216]" .. name .."[-] " .. "？[-]"   -- [color=cd201e]  " .. str .."[-] " .. itemNum .. "个字

	local titleRtx = RichTextFactory:create(titleStr,320,60)
    titleRtx:formatText()
    titleRtx:setVerticalSpace(3)
    titleRtx:setPosition(170,scrollH-25)  
    titleRtx:setName("titleRtx")
    itemScrollView:addChild(titleRtx,5)

end

function AcCollectFriendsSendDialog:reflashUI(data)
    
end


return AcCollectFriendsSendDialog