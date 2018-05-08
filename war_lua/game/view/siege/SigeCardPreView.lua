--[[
    Filename:    SigeCardPreView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-09-7 14:39:47
    Description: File description
--]]
local cc = cc
local SigeCardPreView = class("SigeCardPreView",BasePopView)


function SigeCardPreView:ctor()
    SigeCardPreView.super.ctor(self)
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("siege.SigeCardPreView")
        elseif eventType == "enter" then 
        end
    end)
    
end

function SigeCardPreView:getRegisterNames()
	return{
		{"titleLabel","bg.title.titleLabel"},
		{"closeBtn","bg.closeBtn"},
		{"list", "bg.list"},
	}
end

-- 初始化UI后会调用, 有需要请覆盖
function SigeCardPreView:onInit()

	self:registerClickEvent(self._closeBtn,function()
		self:close()
	end)

	UIUtils:setTitleFormat(self._titleLabel,1)
	self._list:setVisible(false)
	
	local colorList1 = {
		cc.c4b(255, 254, 244, 255),
		cc.c4b(253, 235, 255, 255),
		cc.c4b(235, 252, 255, 255),
		cc.c4b(235, 255, 241, 255),
	}
	local colorList2 = {
		cc.c4b(255, 185, 143, 255),
		cc.c4b(231, 164, 255, 255),
		cc.c4b(124, 204, 255, 255),
		cc.c4b(124, 255, 152, 255),
	}

	for i=1, 4 do 
		local image = self._list:getChildByFullName("quality"..i)
		local text = image:getChildByFullName("text")
		text:setColor(colorList1[i])
		text:enable2Color(1, colorList2[i])
		text:enableOutline(cc.c3b(18,18,18), 1)
	end
	self:updateListView()
	
end

local Layout = ccui.Layout
local effectName = {
	"wupinguang_itemeffectcollection",                -- 转光
    "wupinkuangxingxing_itemeffectcollection",        -- 星星
    "tongyongdibansaoguang_itemeffectcollection",     -- 扫光
    "diguang_itemeffectcollection",                   -- 底光
}
function SigeCardPreView:updateListView()
	local tabData = tab.drawSWShow

	--计算list高度
	local height = 168
	local iconH = 90
	local gapW = 13
	local gapH = 10
	local barH = 42
	local ceil = math.ceil
	-- self._list:removeAllChildren()
	for i=1,4 do 
		local data = tabData[i]
		local count = #data.weaponid
		local row = ceil(count/6)
		height = height + row * (gapH + iconH) + gapH
	end
	height = math.max(height,418)

	print("height",height)
	local w = self._list:getContentSize().width
	self._list:setInnerContainerSize(cc.size(w,height))

	for i=1,4 do 
		local image = self._list:getChildByFullName("quality"..i)
		local data = tabData[i].weaponid
		local wCount = #data
		local row = ceil(wCount/6)
		image:setPositionY(height - barH*0.5)
		height = height - barH
		for j=1,row do
			local y = height - gapH - iconH
			height = height - gapH - iconH
			if j == row then
				local num = wCount - (j-1) * 6
				for k=1,num do 
					local panel = Layout:create()
					panel:setContentSize(iconH,iconH)
					-- panel:setColor(cc.c3b(39,247,58))
					-- panel:setBackGroundColorOpacity(255)
				 --    panel:setBackGroundColorType(1)
				 --    panel:setBackGroundColor(cc.c3b(0,0,0))
					self._list:addChild(panel)
					panel:setAnchorPoint(0,0)
					local x = 15 + (k-1)*(gapW+iconH)
					panel:setPosition(x,y)
					local itemData = data[(j-1)*6+k]
					local icon = IconUtils:createWeaponIcon({itemId = itemData[1], effect = true, tagShow = true,showMax = true})
					panel:addChild(icon)
					icon:setScale(0.9)
					icon:setAnchorPoint(0.5,0.5)
					icon:setPosition(45,45)

					local effect = effectName[itemData[2]]
			    	local zOrder = 10
			    	local scale = 0.9
			    	local point = cc.p(-2, -5)
			    	if effect == "diguang_itemeffectcollection" then
			    		zOrder = -2
			    		scale = 0.6
			    		point = cc.p(10,12)
			    	end
			    	local bgMc = IconUtils:addEffectByName({effect})
			        bgMc:setName("bgMc")
			        bgMc:setPosition(point)
			        icon:addChild(bgMc,zOrder)
			        bgMc:setScale(scale)
				end
			else
				for k=1,6 do 
					local panel = Layout:create()
					panel:setContentSize(iconH,iconH)
					-- panel:setColor(cc.c3b(39,247,58))
					-- panel:setBackGroundColorOpacity(255)
				 --    panel:setBackGroundColorType(1)
				 --    panel:setBackGroundColor(cc.c3b(0,0,0))
					self._list:addChild(panel)
					panel:setAnchorPoint(0,0)
					local x = 15 + (k-1)*(gapW+iconH)
					panel:setPosition(x,y)
					local itemData = data[(j-1)*6+k]
					local icon = IconUtils:createWeaponIcon({itemId = itemData[1], effect = true, tagShow = true,showMax=true})
					panel:addChild(icon)
					icon:setScale(0.9)
					icon:setAnchorPoint(0.5,0.5)
					icon:setPosition(45,45)

					local effect = effectName[itemData[2]]
			    	local zOrder = 10
			    	local scale = 0.9
			    	local point = cc.p(-2, -5)
			    	if effect == "diguang_itemeffectcollection" then
			    		zOrder = -2
			    		scale = 0.6
			    		point = cc.p(10,12)
			    	end
			    	local bgMc = IconUtils:addEffectByName({effect})
			        bgMc:setName("bgMc")
			        bgMc:setPosition(point)
			        icon:addChild(bgMc,zOrder)
			        bgMc:setScale(scale)
				end
			end
		end
		height = height - gapH
	end
	self._list:setVisible(true)
end



function SigeCardPreView:onTop()
end

function SigeCardPreView:onDestroy( )
	SigeCardPreView.super.onDestroy(self)
end

function SigeCardPreView:dtor()
	Layout = nil
	cc = nil
	effectName = nil
end

return SigeCardPreView