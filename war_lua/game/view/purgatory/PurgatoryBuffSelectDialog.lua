--[[
    Filename:    PrivilegesShopDialog.lua
    Author:      <yuxiaojing@playcrab.com>
    Datetime:    2018-03-01 11:08:39
    Description: File description
--]]

local PurgatoryBuffSelectDialog = class("PurgatoryBuffSelectDialog", BasePopView)

function PurgatoryBuffSelectDialog:ctor( params )
	self.super.ctor(self)
	if params and params.buffList then
		self._buffDataList = params.buffList
		self._buffData = self._buffDataList[1]
		table.remove(self._buffDataList, 1)
	else
		self._buffData = params.buff
	end
	if params then
		self._callback = params.callback
	end
	self._buffs = self._buffData.buffs
end

function PurgatoryBuffSelectDialog:onInit(  )
    self._purModel = self._modelMgr:getModel("PurgatoryModel")

    self._lastBuffs = self._purModel:getBuffIds()

	self:initBuffView()

	local root = self:getUI('bg.root')
	root:setVisible(false)
	if self._buffDataList and #self._buffDataList > 0 then
		root:setVisible(true)
		local btn_root = root:getChildByFullName('keyawardbtn')
		self:registerClickEvent(btn_root, function (  )
			self._serverMgr:sendMsg("PurgatoryServer", "quickSwitch", {}, true, {}, function ( result )
				self._buffDataList = {}
				if self.close then
            		self:close()
            	end
				self:showBuffFloatTips()
			end, function ( errorId )
			    
			end)
		end)
	end
end

function PurgatoryBuffSelectDialog:showBuffFloatTips(  )
	local newBuffIds = self._purModel:getBuffIds()
	local showTips = {}
	for k, v in pairs(newBuffIds) do
		local buffId = tonumber(k)
		local oldNum = self._lastBuffs[k] or 0
		local newNum = tonumber(v)
		local num = newNum - oldNum
		if num > 0 then
			for i = 1, num do
				local buffData = tab.purBuff[buffId]
				local desc = lang(buffData.des) 
		        local buffNum = buffData.pro[1][2]
		        local result,count = string.gsub(desc, "$num", buffNum)
		        if count > 0 then 
		            desc = result
		        end
		        table.insert(showTips, desc)
			end
		end
	end
	UIUtils.showFloatTips({tips = showTips})
end

function PurgatoryBuffSelectDialog:tsplit(str, reps)
    local des = string.gsub(str, "%b{}", function( lvStr )
        local str = string.gsub(lvStr, "%$num", reps)
        return loadstring("return " .. string.gsub(str, "[{}]", ""))()
    end)
    return des 
end

function PurgatoryBuffSelectDialog:initBuffView(  )
	local buffBG = self:getUI('bg.buffBG')
	local buffCfg = tab.purBuff
	for i = 1, 3 do
		local buffCell = buffBG:getChildByFullName('buffCell_' .. i)
		local buffID = self._buffs[tostring(i)]
		local buffData = buffCfg[buffID]
		if buffData == nil then
			buffCell:setVisible(false)
		else
			buffCell:setVisible(true)
			--buff des
			local itemNameBg = buffCell:getChildByName("itemNameBg")
		    local str = lang(buffData.des)
		    local buffNum = buffData.pro[1][2]
		    str = self:tsplit(str, buffNum)
		    local result, count = string.gsub(str, "$num", buffNum)
		    if count > 0 then 
		        str = result
		    end
		    
		    local richText = itemNameBg.richText
		    if richText then
		        richText:removeFromParent()
		    end
		    richText = RichTextFactory:create(str, 170, 40)
		    richText:setName("richText")
		    richText:formatText()
		    richText:setPosition(itemNameBg:getContentSize().width/2 + (itemNameBg:getContentSize().width - richText:getRealSize().width)/2+3, itemNameBg:getContentSize().height/2)
		    itemNameBg:addChild(richText)
		    itemNameBg.richText = richText

		    --buff name
		    local buffName = buffCell:getChildByFullName('tname')
		    buffName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
		    buffName:setString(lang(buffData.name))

		    --buff icon
		    local iconBg = buffCell:getChildByFullName("iconBg")
			if iconBg then
			    iconBg:setVisible(true)
			    local buffIcon = iconBg:getChildByName("buffIcon")
			    local param = {image = buffData.icon .. ".png", quality = 5, scale = 0.90, bigpeer = true}
			    if buffIcon then
			        IconUtils:updatePeerageIconByView(buffIcon, param)
			        buffIcon:setSwallowTouches(false)
			    else
			        local buffIcon = IconUtils:createPeerageIconById(param)
			        buffIcon:setPosition(-10, -5)
			        buffIcon:setName("buffIcon")
			        iconBg:addChild(buffIcon)
			        buffIcon:setSwallowTouches(false)
			    end
			end

			--buff effect
	        local title = mcMgr:createViewMC("fuweuqiguang2_kaiqi", true, false)
	        title:setPosition(iconBg:getContentSize().width*0.5, iconBg:getContentSize().height*0.5+10)
	        title:setCascadeOpacityEnabled(true)
	        title:setOpacity(150)
	        iconBg:addChild(title, -1)

			--buff select
			local btn_select = buffCell:getChildByFullName('Button_55')
			self:registerClickEvent(btn_select, function()
				self._serverMgr:sendMsg("PurgatoryServer", "switchBuff", {stageId = self._buffData.stageId, buffIdx = i}, true, {}, function ( result )
					if self.close then
                		self:close()
                	end
					self:showBuffFloatTips()
				end, function ( errorId )
				    
				end)
	    	end) 
		end
	end
end

function PurgatoryBuffSelectDialog:onDestroy()
	local buffList = self._buffDataList
    PurgatoryBuffSelectDialog.super.onDestroy(self)
    if buffList and #buffList > 0 then
    	self._viewMgr:showDialog("purgatory.PurgatoryBuffSelectDialog", {buffList = buffList, callback = self._callback})
    	return
    end
	if self._callback then
		self._callback()
	end
end

function PurgatoryBuffSelectDialog:getAsyncRes()
    return  
        { 
            {"asset/ui/privileges2.plist", "asset/ui/privileges2.png"}
        }
end

return PurgatoryBuffSelectDialog