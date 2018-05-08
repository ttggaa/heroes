--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-05-24 17:21:12
--
local GlobalResApproatchView = class("GlobalResApproatchView",BasePopView)
function GlobalResApproatchView:ctor(data)
    self.super.ctor(self)
    data = data or {}
    self._callback = data.callback
    self._inInstance = data.inInstance
end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalResApproatchView:onInit()
	self:registerClickEventByName("bg.btn_close",function( )
		if self._callback then
			self._callback()
		end
		self:close()
		UIUtils:reloadLuaFile("global.GlobalResApproatchView")
	end)
    self._resAppMap = {}
    local staticD = tab.static 
    for k,v in pairs(staticD) do
    	-- dump(v)
    	-- print("v.approach",v.approach)
    	-- if v.approach then
    		self._resAppMap[v.name] = v.approach
    	-- end
    end

    local staticMap = {
	    {des = "点金手",icon = "xgn_huangjin.png",goto = function( )
	    	DialogUtils.showBuyRes({goalType = "gold"})
	    end, sysOpen = "User_buyGold"},
	    {des = "购买经验",icon = "xgn_jingyan.png",goto = function( )
	    	DialogUtils.showBuyRes({goalType = "texp"})
	    end},
	    {des = "剧情副本",icon = "xgn_fuben.png",goto = "intance.IntanceView"},
	    {des = "剧情副本",icon = "xgn_fuben.png",goto = "intance.IntanceView"}, -- 4 没有配
	    {des = "矮人宝屋",icon = "xgn_airen.png",goto = "pve.AiRenMuWuView",sysOpen = "DwarvenTreasury"},
	    {des = "阴森墓穴",icon = "xgn_muxue.png",goto = "pve.ZombieView",sysOpen = "Crypt"},
	    {des = "攻城战",icon = "xgn_muxue.png",goto = function()
	    	-- self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = 1})  
	    	self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView") 
	    end,sysOpen = "Weapon"},
	    {des = "守城战",icon = "xgn_muxue.png",goto = function()
	    	-- self._viewMgr:showView("siegeDaily.SiegeDailyView",{utype = 2}) 
	    	self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")  
	    end,sysOpen = "Weapon"},
	    {des = "配件分解",icon = "xgn_muxue.png",goto = "weapons.WeaponsBreakView",sysOpen = "Weapon"},
	}
	self._staticMap = staticMap

	self._title = self:getUI("bg.titlt_bg.title")
    UIUtils:setTitleFormat(self._title, 6)
end

-- 接收自定义消息
function GlobalResApproatchView:reflashUI(data)
	data = data or {}
	
	local curApproatchs = self._resAppMap[data.goalType or "gold"]
	local resId = IconUtils.iconIdMap[data.goalType or "gold"]
	self._title:setString( (lang(tab:Tool(resId).name) or "资源") .. "不足")
	for i=1,3 do
		local data = self._staticMap[curApproatchs[i]]
		local approatchLy = self:getUI("bg.approach" .. i)
		local icon = approatchLy:getChildByName("icon")
		icon:loadTexture(data.icon,1)
		local des = approatchLy:getChildByName("des")
		-- des:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
		des:setString(data.des)
		local isOpen = true
		local openLevel
		if data.sysOpen then
			print("enable .. data.sysOpen","enable" .. data.sysOpen)
			isOpen,_,openLevel = SystemUtils["enable" .. data.sysOpen]()
		end
		self:registerClickEvent(approatchLy,function( )
			if not isOpen and openLevel then
				-- [[ -- 未开启提示读 systemOpen表
				if data.sysOpen and tab.systemOpen[data.sysOpen] then
					local systemOpenTip = tab.systemOpen[data.sysOpen][3]
		            if not systemOpenTip then
		                self._viewMgr:showTip(tab.systemOpen[data.sysOpen][1] .. "级开启")
		            else
		                self._viewMgr:showTip(lang(systemOpenTip))
		            end
		        else
					self._viewMgr:showTip(openLevel .. "级开启")
		        end
				--]]
				return 
			end
			if type(data.goto) == "string" then
				self._viewMgr:showView(data.goto)
			elseif type(data.goto) == "function" then 
				data.goto()
			end
			dump(curApproatchs,"curApproatchs....")
			if self._callback then
				self._callback(curApproatchs[i])
			end
			self:close()
		end)
	end
end

return GlobalResApproatchView