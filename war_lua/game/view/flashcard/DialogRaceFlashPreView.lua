--
-- Author: huangguofang
-- Date: 2018-10-10 21:06:34
--
local choukashowTab = clone(tab.raceDrawShow)
local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local DialogRaceFlashPreView = class("DialogRaceFlashPreView",BasePopView)
function DialogRaceFlashPreView:ctor(param)
    self.super.ctor(self)
    
    self._showData = {}
    self._raceId = param.raceId or 101
    for k,v in ipairs(choukashowTab) do
        if tonumber(v.race) == tonumber(self._raceId) then
            self._showData.soul = v.soul or {}
            self._showData.team = v.team or {}
            self._showData.other = v.other or {}
            break
        end        
    end
    self._idx2RaceMap = {
    }
    -- table.sort(self._showData,function( a,b )
    --  return a.id < b.id
    -- end)
    dump(self._showData,"showData===>")

end

function DialogRaceFlashPreView:getAsyncRes()
    return 
    {
        -- {"asset/ui/arena.plist", "asset/ui/arena.png"},
        -- {"asset/ui/nests.plist", "asset/ui/nests.png"},
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogRaceFlashPreView:onInit()
    
    self.initAnimType = 1
    self._bg = self:getUI("bg")
    self._bg:setSwallowTouches(false)
    self._item = self:getUI("item")
    self._item:setVisible(false)

    local notClose = false
    self:registerClickEventByName("bg.closeBtn",function( )
        if not notClose then
            self:close(true)
            notClose = true
            UIUtils:reloadLuaFile("flashcard.DialogRaceFlashPreView")
        end
    end)
    self:getUI("bg.closeBtn"):setZOrder(100)

    self._tabIdx = {
        [1] = {name="魂石",key="soul"},
        [2] = {name="碎片",key="team"},
        [3] = {name="宝物",key="other"}
    }

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._initKeyNum = 3
    self:initTabs()
    self:touchTab(self._initKeyNum)
end

function DialogRaceFlashPreView:initTabs()
    self._tabBtns = {}
    local btnSize = 86
    local x,y = -36,480
    local offsetX,offsetY = 0,-10
    local tabNums = table.nums(self._showData)
    local maxHeight = math.max(480,tabNums*btnSize)
    local count = 0
    for k,v in ipairs(self._tabIdx) do
        if v.key and self._showData[v.key] and table.nums(self._showData[v.key]) > 0 then 
            if k ~= self._initKeyNum and k < self._initKeyNum then
                self._initKeyNum = k
            end
            print("===========123===================")
            local tabBtn = ccui.Button:create()
            tabBtn:loadTextures("globalBtnUI4_page1_n.png",
                "globalBtnUI4_page1_n.png",
                "globalBtnUI4_page1_p.png",1)           
            tabBtn:setTitleFontName(UIUtils.ttfName)
            tabBtn:setTitleText(v.name)
            tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            tabBtn:setTitleFontSize(22) 
        
            tabBtn:setPosition(x, y)
            y = y - 72
            self._bg:addChild(tabBtn,99)
            self._tabBtns[k] = tabBtn
            UIUtils:setTabChangeAnimEnable(tabBtn,60,handler(self, self.touchTab),k)
        end
    end
end

function DialogRaceFlashPreView:touchTab( idx )
    local btn = self._tabBtns[idx]
    if btn == nil then 
        return 
    end
    if not noAudio then 
        audioMgr:playSound("Tab")
    end
    for k,v in pairs(self._tabBtns) do
        if v ~= btn then 
            local text = v:getTitleRenderer()
            v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            -- text:setPositionX(85)
            v:setScaleAnim(false)
            v:stopAllActions()
            v:setScale(1)
            v:setZOrder(-10)
            self:tabButtonState(v, false)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    
    -- text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- 按钮动画
    self._preBtn = btn
    btn:stopAllActions()
    btn:setZOrder(99)
    UIUtils:tabChangeAnim(btn,function()
        local text = btn:getTitleRenderer()
        text:disableEffect()
        -- text:setPositionX(85)
        btn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        self:tabButtonState(btn, true)
    end)
    self:reflashIcons(idx)
end

function DialogRaceFlashPreView:tabButtonState( tabBtn,isSelect )
    tabBtn:setBright(not isSelect)
    tabBtn:setEnabled(not isSelect)
end

function DialogRaceFlashPreView:reflashIcons( idx )
    local tabD = self._tabIdx[idx] or {}
    local iconData = self._showData[tabD.key or "soul"] or {}
    self._scrollView:removeAllChildren()
    local iconW,iconH = 160,180
    local offsetX,offsetY = -4,10
    local maxHeight = 391
    local count = #iconData
    local row,col = math.ceil(count/4),4
    if iconH * row > maxHeight then
        maxHeight = iconH * row
    end
    self._scrollView:setInnerContainerSize(cc.size(630,maxHeight))
    for i=1,#iconData do
        local teamIcon = self:createItem(iconData[i],idx)
        local x = ((i-1)%col)*iconW+offsetX
        local y = maxHeight - math.ceil(i/col)*iconH +offsetY
        teamIcon:setPosition(x,y)
        self._scrollView:addChild(teamIcon)
    end
end


function DialogRaceFlashPreView:createItem(id,idx)
    local itemId = id
    local item = self._item:clone()
    item:setVisible(true)
    item:setSwallowTouches(false)
    local sysItem = tab:Tool(itemId)
    if sysItem then
        local iconBg = item:getChildByFullName("iconPanel")
        local icon = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem})
        -- icon:setAnchorPoint(cc.p(0, 0.5))
        icon:setPosition(3, 3)
        icon:setScale(0.8)
        iconBg:addChild(icon)

        local name = item:getChildByFullName("name")
        name:setString(lang(sysItem.name))
    end
    return item
end

-- 接收自定义消息
function DialogRaceFlashPreView:reflashUI(data)

end

return DialogRaceFlashPreView