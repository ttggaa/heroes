--[[
    Filename:    LordSweepSetView.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-03-06 14:00
    Description: File description
--]]

local LordSweepSetView = class("LordSweepSetView",BasePopView)
local titleNames = {"攻击天赋扫荡","防御天赋扫荡","突击天赋扫荡","射手天赋扫荡","魔法天赋扫荡","均衡扫荡"}
local rewardItems =    {{"i_3044.png"},
                        {"i_3045.png"},
                        {"i_3046.png"},
                        {"i_3047.png"},
                        {"i_3048.png"},
                        {"i_3044.png","i_3045.png","i_3046.png","i_3047.png","i_3048.png",},
                        }
local MAX_NUM = 6
local rewardNum   = 20

function LordSweepSetView:ctor(param)
 	self.super.ctor(self)
    --默认推荐
    self._recommend = 0
    --默认勾选
    self._curSelectId = 0
    self.callback = param.callback
end 

function LordSweepSetView:onInit()
	self:registerClickEvent(self:getUI("bg.closeBtn"), function ( ... )
		self:close()
	end)
    self._items = {}
	self._item      = self:getUI("bg.item")
    self._sureBtn   = self:getUI("bg.sureBtn")
    self._list      = self:getUI("bg.bg2.tableNode.listView")
    self._lordManagerModel = self._modelMgr:getModel("LordManagerModel")
    self._itemModel = self._modelMgr:getModel("ItemModel")
    self._curSelectId = tonumber(self._lordManagerModel:getTowerType())
    self:registerClickEvent(self._sureBtn, function ( ... )
        --保存选择方式
        self._lordManagerModel:saveTowerType(self._curSelectId)
        if self.callback then
            self.callback()
        end
        self:close()
    end)
    self._recommend = self:getRecommendState()
    self:createListView()
    ScheduleMgr:delayCall(0, self, function()
        self:jumpToSelectedItem()
    end)
end
--[[
    获取对应类型的奖励数量
]]
function LordSweepSetView:getNumByStageAndId(stage,idx,pos)
    local num = 0
    for i=stage,1,-1 do
        --类型12345  6为均衡
        if tab.towerStage[i].rewardType == idx then
            num = tab.towerStage[i].reward[1][3]
            break
        elseif tab.towerStage[i].rewardType == pos then
            num = tab.towerStage[i].reward[1][3]
            break
        end
    end
    return num
end

function LordSweepSetView:createListView( ... )
    for i=1,MAX_NUM do
        local item = self._item:clone()
        item:setVisible(true)
        table.insert(self._items,item)
        local name = item:getChildByFullName("tname")
        item.des  = item:getChildByFullName("des")
        item.lockDes = item:getChildByFullName("lock")
        item.img_tag = item:getChildByFullName("img_tag_bg")
        item.itemPanel = item:getChildByFullName("itemPanel")
        item.checkBox = item:getChildByFullName("checkBox")
        item.checkBox:setSelected(self._curSelectId==i )
        name:setString(titleNames[i])

        --推荐
        item.img_tag:setVisible(self._recommend == i)
        local stage = self._modelMgr:getModel("CloudCityModel"):getPassMaxStageId()
        local maxTimes = self._lordManagerModel:getDataByIdx(308).hTimes or 0
        if maxTimes == 0 then
            maxTimes = self._modelMgr:getModel("CloudCityModel"):getMaxChallengeTimes()
        end
        for idx= 1, 5 do
            local img = item.itemPanel:getChildByFullName("icon"..idx)
            local num = item.itemPanel:getChildByFullName("num"..idx)
            if rewardItems[i][idx] and idx <= maxTimes then
                local image = i < 6 and rewardItems[i][idx] or rewardItems[i][6-idx]
                img:loadTexture(image, 1)
                local n = i < 6 and maxTimes or 1 
                local itemNum = i < 6 and self:getNumByStageAndId(stage, i,idx) or self:getNumByStageAndId(stage,6 - idx,idx)
                n = n * itemNum
                num:setString(n)
            else
                img:setVisible(false)
                num:setVisible(false)
            end 
        end
        item.checkBox:addEventListener(function ( sender,eventType)
            if eventType == 0 then
                if self._curSelectId ~= 0 then
                    self._items[self._curSelectId].checkBox:setSelected(false)
                end
                self._curSelectId = i
            else
                self._curSelectId = 0 
            end
        end)
        self._list:setBounceEnabled(false)
        self:setState(item,i)
        self._list:pushBackCustomItem(item)
        --设置扫荡状态
    end
end

function LordSweepSetView:setState(view,idx)
    local stage = self._modelMgr:getModel("CloudCityModel"):getPassMaxStageId()
    if stage == 0 then
        UIUtils:setGray(view,true)
        view.checkBox:setVisible(false)
        return
    end
    local isLock = true
    if idx == 6 then
        if stage >= 5 then
            isLock = false
        end
    else
        for i = stage,1,-1 do
            if tab.towerStage[i].rewardType == idx then
                isLock = false
                break
            end
        end         
    end
    UIUtils:setGray(view,isLock)
    view.checkBox:setVisible(not isLock)
    view.des:setVisible(not isLock)
    view.lockDes:setVisible(isLock)
    view.itemPanel:setVisible(not isLock)

    local str = idx ~= 6 and lang("LordManager_Text4") or lang("LordManager_Text3")

    view.lockDes:setString(str)
end

function LordSweepSetView:onHide()

end

function LordSweepSetView:onTop()

end

--[[
    获取推荐状态，只在已解锁类型中搜索
]]
function LordSweepSetView:getRecommendState( ... )
    local itemIds = {3044,3045,3048,3046,3047}
    local state = 0
    local oldNum = nil
    local array = {}
    local stage = self._modelMgr:getModel("CloudCityModel"):getPassMaxStageId() or 0
    stage = stage >= 5 and 5 or stage
    if stage == 0 then return 0 end
    for i=1,stage do
        local _,has = self._itemModel:getItemsById(itemIds[i])
        table.insert(array,{id = i,num =has})
    end
    if #array > 1 then
        table.sort(array,function (a,b)
            return a.num < b.num
        end)
    end
    state = array[1].id
    return state
end

function LordSweepSetView:jumpToSelectedItem()
    -- body
    local itemIndex = self._curSelectId ~= 0 and self._curSelectId or self._recommend
    local percent = itemIndex / 6
    percent = percent > 1 and 1 or percent 
    if itemIndex == 1 then percent = 0 end
    print(" percent "  .. percent)
    self._list:jumpToPercentVertical(math.ceil(percent*100))
    -- self._list:jumpToPercentVertical(100)
end

function LordSweepSetView.dtor( ... )
    titleNames  = nil
    rewardItems = nil
    MAX_NUM     = nil
    rewardNum   = nil
end



return LordSweepSetView