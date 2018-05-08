--[[
    Filename:    LordSweepResultDialog.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-03-06 14:00
    Description: File description
--]]

local LordSweepResultDialog = class("LordSweepResultDialog",BasePopView)

function LordSweepResultDialog:ctor(param)
 	self.super.ctor(self)
 	self._awards = param.awards
    self.callback = param.callback
end

function LordSweepResultDialog:onInit()
	
	self._item      = self:getUI("bg.item")
	self._item:setVisible(false)
    self._sureBtn   = self:getUI("bg.sureBtn")
    self._closeBtn   = self:getUI("bg.closeBtn")
    self._sureBtn:setVisible(false)
    self._lordManagerModel = self._modelMgr:getModel("LordManagerModel")
    self:registerClickEvent(self._closeBtn, function ( ... )
        if self.callback then
            self.callback()
        end
        self:close()  
    end)

    self:registerClickEvent(self._sureBtn, function ( ... )
        if self.callback then
            self.callback()
        end
        self:close()
    end)
    
    self._list = self:getUI("bg.bg2.tableNode.listView")
    self:createListView()
    self._sureBtn:setVisible(false)
    self._closeBtn:setVisible(false)
end

function LordSweepResultDialog:createListView(...)
    local array = {}
    local createItemDeque 
    local createNextItemFunc = function( index )
        ScheduleMgr:delayCall(500, self, function()
            createItemDeque(index)
        end)
    end

    createItemDeque = function ( index )
        local rewardData = self._awards[index]
        if not rewardData then
            self._sureBtn:setVisible(true)
            self._closeBtn:setVisible(true)
            return 
        end
        local item = self._item:clone()
        local name = item:getChildByFullName("tname")
        local des = item:getChildByFullName("des")
        local pos = rewardData.idx.."01"
        local title 
        if rewardData.idx ~= 210 and rewardData.idx ~= 319 and rewardData.idx ~= 320 then
            title = lang(tab.lordManager[tonumber(pos)].title)
        else
            if rewardData.idx == 210 then
                title = "联盟经验奖励"
            elseif rewardData.idx == 319 then
                title = "矮人宝屋累积奖励"
            elseif rewardData.idx == 320 then
                title = "阴森墓穴累积奖励"
            end
        end
        name:setString(title)
        local fSize = name:getFontSize()
        local num = name:getStringLength()
        des:setPositionX(name:getPositionX() + (fSize*num) + 10)
        
        item:setVisible(true)
        item:setAnchorPoint(0,0)
        item:setTouchEnabled(false)
        self:createItem(item,index)
        self._list:pushBackCustomItem(item)
        ScheduleMgr:delayCall(0, self, function()
            self._list:jumpToPercentVertical(100)
        end)
        local changeArray = {}
        for k,v in pairs(rewardData.awards) do
            if v.isChange then
                table.insert(changeArray,v)
            end
        end
        local showNextCard
        showNextCard = function (cardIdx)
            if changeArray[cardIdx] then
                local data = changeArray[cardIdx]
                if data.isChange == 0 then
                    local teamId = tonumber(string.sub(tostring(data.typeId),2))
                    ScheduleMgr:delayCall(500, self, function()
                        DialogUtils.showTeam({teamId = teamId,callback = function ()
                            showNextCard(cardIdx+1)
                        end})
                    end)
                end

                if data.isChange == 1 then
                    ScheduleMgr:delayCall(500, self, function()
                        DialogUtils.showCard({itemId = data.typeId,changeNum = data.num,callback = function( )
                            showNextCard(cardIdx+1)
                        end})
                    end)
                end
            else
                createNextItemFunc(index+1)
            end
        end
        if #changeArray > 0 then
            showNextCard(1)
        else
            createNextItemFunc(index + 1)
        end
    end
    createNextItemFunc(1)
end

function LordSweepResultDialog:createItem(item,idx)
    item.list = item:getChildByFullName("itemList")
    for k,itemData in pairs(self._awards[idx].awards) do
    	local itemCell
        if itemData.type ~= "tool" 
            and itemData.type ~= "hero" 
            and itemData.type ~= "team" 
            and itemData.type ~= "avatarFrame" 
            and itemData.type ~= "avatar" 
            and itemData.type ~= "hSkin" 
            and itemData.type ~= "siegeProp"
        then
            itemData.typeId = IconUtils.iconIdMap[itemData.type]
        end

        --抽到兵团整卡
        if itemData.isChange and itemData.isChange == 0 then
            local teamId  = itemData.typeId-3000
            local teamD = tab:Team(teamId)
            itemData = teamD
            itemCell = IconUtils:createSysTeamIconById({sysTeamData = teamD })
            local iconColor = itemCell:getChildByName("iconColor")
            iconColor:loadTexture("globalImageUI_squality_jin.png",1)
            itemCell:setScale(0.74)
        else
            itemCell = IconUtils:createItemIconById({itemId = itemData.typeId, num = itemData.num})
            itemCell:setScale(0.85)
        end
    	itemCell:setAnchorPoint(0.5,1)
    	item.list:pushBackCustomItem(itemCell)
    end
end

return LordSweepResultDialog