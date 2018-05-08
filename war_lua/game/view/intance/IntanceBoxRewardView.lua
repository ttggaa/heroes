--[[
    Filename:    IntanceBoxRewardView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-14 21:05:31
    Description: File description
--]]


local IntanceBoxRewardView = class("IntanceBoxRewardView", BasePopView)


function IntanceBoxRewardView:ctor()
    IntanceBoxRewardView.super.ctor(self)

end

function IntanceBoxRewardView:reflashUI(inData)
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
    end)
	local bg = self:getUI("bg.itemBg")

	local itemsNode = {}
	for i,data in pairs(inData) do
		local itemType = data[1] or data.type
	    local itemId = data[2] or data.typeId 
	    local itemNum = data[3] or data.num
	    if itemType ~= "tool" then
	        itemId = IconUtils.iconIdMap[itemType]
	    end
		-- if data.isItem then
		local sysItem = tab:Tool(itemId)

        local dropIcon = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = sysItem})
        -- bg:addChild(dropIcon)
        -- dropIcon:setAnchorPoint(cc.p(0,0.5))
        -- dropIcon:setName("dropIcon" .. i)
        -- print("bg:getContentSize().width/2---", bg:getContentSize().width/2)
        -- -- dropIcon:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2)
        -- dropIcon:setPosition((i - 1) * dropIcon:getContentSize().width * dropIcon:getScale() + 20,  bg:getContentSize().height/2)
        itemsNode[i] = dropIcon
	end
	local nodeTip1 = UIUtils:createHorizontalNode(itemsNode)
	nodeTip1:setAnchorPoint(0.5, 0.5)
	nodeTip1:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2)
	bg:addChild(nodeTip1)
end

return IntanceBoxRewardView