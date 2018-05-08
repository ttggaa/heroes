--[[
    Filename:    LordManagerDonateView.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-03-06 14:00
    Description: File description
--]]

local LordManagerDonateView = class("LordManagerDonateView",BasePopView)

LordManagerDonateView.checkBoxNames = {"gold","diamond","zz"}

function LordManagerDonateView:ctor(param)
 	self.super.ctor(self)
    self.callback = param.callback
end 

function LordManagerDonateView:getAsyncRes()
    return 
        {
            {"asset/ui/alliance.plist","asset/ui/alliance.png"},
            {"asset/ui/alliance3.plist","asset/ui/alliance3.png"},
        }
end


function LordManagerDonateView:onInit()
	self._item      = self:getUI("bg.item")
    self._sureBtn   = self:getUI("bg.sureBtn")
    self._closeBtn  = self:getUI("bg.closeBtn")
    self._list      = self:getUI("bg.bg2.tableNode.listView")
    self._lordManagerModel = self._modelMgr:getModel("LordManagerModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._items = {}
    self:registerClickEvent(self._closeBtn, function ( ... )
        self:close()
    end)
    self._curCheckBoxId = 0
    self._curScienceId  = tonumber(self._lordManagerModel:getScienceType()) or 0
    self:registerClickEvent(self._sureBtn, function ( ... )
        --保存&关闭
        self._lordManagerModel:saveDonateType(self._curCheckBoxId)
        self._lordManagerModel:saveScienceType(self._curScienceId)
        if self.callback then
            self.callback()
        end
        self:close()
    end)
    local bottomTips = self:getUI("bg.bottom_panel.label_tips")
    bottomTips:setString(lang("LordManager_Text1"))
    self:createListView()
    self:initCheckBox()
end

function LordManagerDonateView:initCheckBox()
    self._checkBox_gold = self:getUI("bg.bottom_panel.gold_checkBox")
    self._checkBox_diamond = self:getUI("bg.bottom_panel.diamond_checkbox")
    self._checkBox_zz = self:getUI("bg.bottom_panel.zz_checkbox")

    -- 设置默认勾选
    self._curCheckBoxId = tonumber(self._lordManagerModel:getDonateType())
    if self._curCheckBoxId ~= 0 then
        self["_checkBox_"..self.checkBoxNames[self._curCheckBoxId]]:setSelected(true)
    end
    for i,v in ipairs(self.checkBoxNames) do
        self["_checkBox_"..v]:addEventListener(function(sender, eventType)
            if eventType == 0 then
                if self._curCheckBoxId ~= 0 then
                    self["_checkBox_"..self.checkBoxNames[self._curCheckBoxId]]:setSelected(false)
                end
                self._curCheckBoxId = i
            else
                self._curCheckBoxId = 0
            end
        end)
    end
end

function LordManagerDonateView:createListView( ... )
    self._technology = tab.technologyBase
    self._technologyChild = tab.technologyChild
    local array = {}
    for _level,v in ipairs(self._technology) do
        for i,scienceId in ipairs(v.include) do
            local data = {}
            data.scienceId = scienceId
            data.lv = _level
            data.info = self._technologyChild[scienceId]
            table.insert(array,data)
        end
    end
    for i=1,#array,2 do
        local itemWidget = ccui.Widget:create()
        itemWidget:setAnchorPoint(0,1)
        itemWidget:setContentSize(598,87)

        local item1 = self:createItem(array[i],i)
        itemWidget:addChild(item1)
        item1:setPosition(2,0)
        local item2
        if array[i+1] then
            item2 = self:createItem(array[i+1],i+1)
            itemWidget:addChild(item2)
            item2:setPosition(299,0)
        end
        self._list:pushBackCustomItem(itemWidget)
    end
    self._list:setBounceEnabled(false)
    self._list:jumpToTop()
end

function LordManagerDonateView:createItem(data)
    local guildScience = self._guildModel:getGuildScience()
    local item = self._item:clone()
    item:setVisible(true)
    local tname = item:getChildByFullName("tname")
    tname:setVisible(true)
    print("data  name" .. data.info.name)
    tname:setString(lang(data.info.name))
    self._items[data.scienceId] = item

    local img_icon = item:getChildByFullName("img_icon")
    local openLock = item:getChildByFullName("lock")
    local img_lock = item:getChildByFullName("img_lock")
    local tmaxLevel = item:getChildByFullName("max_level")
    local limit_level = item:getChildByFullName("limit_level")
    local expLabel = item:getChildByFullName("des")
    item.checkBox = item:getChildByFullName("checkBox")
    local tlevel = item:getChildByFullName("img_icon.sciencelv")
    --上限
    limit_level:setVisible(false)
    img_icon:loadTexture("allianceScicene_icon" .. data.scienceId .. ".png",1)

    item.checkBox:setSelected(self._curScienceId == data.scienceId)

    local level,exp
    if not guildScience[tostring(data.scienceId)] then
        level = 1
        exp = 0
    else
        level = guildScience[tostring(data.scienceId)].lvl + 1
        exp = guildScience[tostring(data.scienceId)].exp or 0
    end
    
    tlevel:setString(level-1)

    --经验条
    local bar = item:getChildByFullName("donate_progress.bar")
    local barValue = 4
    if level > table.nums(data.info.levelexp) then
        barValue = 100
        -- expLabel:setString(exp.."/"..data.info.levelexp[level])
        --满级经验条显示      TODO
    else
        barValue = 4 + (exp/data.info.levelexp[level])*90
        expLabel:setString(exp.."/"..data.info.levelexp[level])
    end
    

    bar:setPercent(barValue)

    --状态显示   未解锁  or 已到达最大等级
    local guild_level = self._guildModel:getAllianceDetail().level or 1
    local limit_guild_level = data.info.limit[guild_level]
    print("guild_level  "..guild_level)
    print("limit_guild_level  " ..limit_guild_level)
    local isOpen = false
    if guild_level >= self._technology[data.lv].limit then
        isOpen = true
    end
    --解锁
    openLock:setVisible(not isOpen)
    img_lock:setVisible(not isOpen)
    UIUtils:setGray(img_icon,not isOpen)

    openLock:setString("联盟等级"..self._technology[data.lv].limit.."级开启")   --需要X级开启

    if level > limit_guild_level and level <= data.info["levelmax"] then
        tmaxLevel:setVisible(false)
        limit_level:setVisible(true)
        item.checkBox:setVisible(false)
    end

    if level > data.info["levelmax"] then
        item.checkBox:setVisible(false)
        tmaxLevel:setVisible(true)
    else
        tmaxLevel:setVisible(false)
    end

     if not isOpen then
        -- tname:setVisible(false)
        expLabel:setVisible(false)
        item:getChildByFullName("donate_progress"):setVisible(false)
        item.checkBox:setVisible(false)
        limit_level:setVisible(false)
    end

    item.checkBox:addEventListener(function (sender, evtType )
        if evtType == 0 then
            if self._items[self._curScienceId] then
                self._items[self._curScienceId].checkBox:setSelected(false)
            end
            self._curScienceId = data.scienceId
        else
            self._curScienceId = 0
        end
    end)

    return item
end

function LordManagerDonateView:onHide()

end

function LordManagerDonateView:onTop()

end


return LordManagerDonateView