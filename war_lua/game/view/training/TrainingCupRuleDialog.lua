--
-- Author: huangguofang
-- Date: 2016-11-09 15:48:57
--




local TrainingCupRuleDialog = class("TrainingCupRuleDialog",BasePopView)
function TrainingCupRuleDialog:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function TrainingCupRuleDialog:onInit()

	self._cupData = tab.trainingCup
	table.sort(self._cupData,function (a,b)
		return a.num > b.num
	end)

	dump(self._cupData,"self._cupData==>")
	self._cupImg = {
    	[1] = "trainingView_inViewCopper.png",
    	[2] = "trainingView_inViewSliver.png",
    	[3] = "trainingView_inViewGolden.png",
    	[4] = "trainingView_inViewWG.png",
	}

	local title = self:getUI("bg.title")
	UIUtils:setTitleFormat(title, 6)

    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("training.TrainingCupRuleDialog")
    end)
    self._item = self:getUI("bg.item")
    self._item:setVisible(false)

    local scrollview = self:getUI("bg.ScrollView")
    scrollview:setBounceEnabled(true)
    local itemW = 80 
    local maxHeight = itemW * (#self._cupData)
    maxHeight = maxHeight > 320 and maxHeight or 320
    scrollview:setInnerContainerSize(cc.size(scrollview:getContentSize().width,maxHeight))
    
    local posY = maxHeight - itemW*0.5
    for i=1,#self._cupData do
		local data = self._cupData[i]
		-- if data.num <= 9 then
    	local item = self._item:clone()
    	item:setVisible(true)
    	item:setOpacity( i%2==0 and 0 or 255)    	

    	local cupImg = item:getChildByFullName("cupImg")
    	if data.art and data.art ~= "" then
    		cupImg:loadTexture(data.art ,1)
    	else
    		cupImg:loadTexture(self._cupImg[data.id],1)
    	end

    	local cupName = item:getChildByFullName("cupName")
    	if data.name then
    		cupName:setString(lang(data.name))
    	else
    		cupName:setString("传奇")
    	end

    	local desTxt = item:getChildByFullName("desTxt")
    	if data.num then
    		desTxt:setString("评分获得" .. data.num .. "个")
    	else
    		desTxt:setString("评分获得X个")
    	end

    	item:setPosition(222, posY)
    	posY = posY - 80
    	scrollview:addChild(item)
	    -- end
    end

end


-- 接收自定义消息
function TrainingCupRuleDialog:reflashUI(data)

end

return TrainingCupRuleDialog