--[[
    Filename:    PrivilegesPeerageDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-11 16:39:17
    Description: File description
--]]

-- 金币领取
local PrivilegesPeerageDialog = class("PrivilegesPeerageDialog", BasePopView)

function PrivilegesPeerageDialog:ctor(param)
    PrivilegesPeerageDialog.super.ctor(self)
    self._callback = param.callback 
    self._selectPeerage = param.selectPeerage 
    self._peerage = {}
end

function PrivilegesPeerageDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._itemBg = self:getUI("bg.itemBg")
    self._awardLab = self:getUI("bg.awardLab")
    self._layer = self:getUI("bg.layer")
    self._maxLayer = self:getUI("bg.maxLayer")



    local peerage = self:getUI("bg.closeBtn")
    self:registerClickEvent(peerage, function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("privileges.PrivilegesPeerageDialog")
        end
        self:close()
    end)

    local lingqu = self:getUI("bg.lingqu")
    self:registerClickEvent(lingqu, function()
        self._callback()
        self:close()
    end)
    -- self:reflashUI()
end

function PrivilegesPeerageDialog:reflashUI(data)
    -- local goldNum = self:getUI("bg.goldNum")
    -- local gold = tab:Peerage(self._selectPeerage).wages[1][3]
    -- goldNum:setString(gold)

    print("===============", self._selectPeerage)
    if self._selectPeerage < 10 then
        self._layer:setVisible(true)
        self._maxLayer:setVisible(false)
        local des1 = self:getUI("bg.layer.des1")
        local des2 = self:getUI("bg.layer.des2")
        local des3 = self:getUI("bg.layer.des3")
        local des4 = self:getUI("bg.layer.des4")
        des4:setString(10000)
        local des5 = self:getUI("bg.layer.des5")

        local name = self:getUI("bg.layer.name")
        name:setFontName(UIUtils.ttfName)
        name:setColor(cc.c3b(250, 242, 192))
        name:enable2Color(1, cc.c4b(255, 195, 20, 255))
        name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        name:setFontSize(30)
        name:setString(lang(tab:Peerage(self._selectPeerage).name))

        local juewei = self:getUI("bg.layer.des1")
        -- juewei:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        juewei:setColor(cc.c3b(70, 40, 0))
        juewei:setString("成为" .. lang(tab:Peerage(self._selectPeerage+1).name) .. "您可以:")

        local privilegeIcon = self:getUI("bg.layer.privilegeIcon")
        privilegeIcon:loadTexture(tab:Peerage(self._selectPeerage).res .. ".png", 1)
        local miaoshu = self:getUI("bg.layer.miaoshu")
        miaoshu:setColor(cc.c3b(255, 241, 180))
        miaoshu:enable2Color(1, cc.c4b(235, 192, 19, 255))
        miaoshu:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local str= string.gsub(lang(tab:Peerage(self._selectPeerage+1)["des"]), "%b[]", "")
        miaoshu:setString(str)
    else
        self._layer:setVisible(false)
        self._maxLayer:setVisible(true)

        local name = self:getUI("bg.maxLayer.name")
        name:setFontName(UIUtils.ttfName)
        name:setColor(cc.c3b(250, 242, 192))
        name:enable2Color(1, cc.c4b(255, 195, 20, 255))
        name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        name:setFontSize(30)
        name:setString(lang(tab:Peerage(self._selectPeerage).name))

        local privilegeIcon = self:getUI("bg.maxLayer.privilegeIcon")
        privilegeIcon:loadTexture(tab:Peerage(self._selectPeerage).res .. ".png", 1)
    end

    local awardLab = self:getUI("bg.awardLab")
    awardLab:setString(lang(tab:Peerage(self._selectPeerage).name) .. "每日奖励:")

    local itemBg = self:getUI("bg.itemBg")
    local wages = tab:Peerage(self._selectPeerage).wages
    local param = {itemId = 39993, effect = true, eventStyle = 1, num = wages[1][3]}
    local itemIcon = itemBg:getChildByName("itemIcon")
    if itemIcon then
        IconUtils:updateItemIconByView(itemIcon, param)
    else
        itemIcon = IconUtils:createItemIconById(param)
        itemIcon:setName("itemIcon")
        itemIcon:setScale(0.7)
        itemIcon:setPosition(cc.p(0,0))
        itemBg:addChild(itemIcon)
    end
end

return PrivilegesPeerageDialog


-- -- 金币领取
-- local PrivilegesPeerageDialog = class("PrivilegesPeerageDialog", BasePopView)

-- function PrivilegesPeerageDialog:ctor(param)
--     PrivilegesPeerageDialog.super.ctor(self)
--     self._callback = param.callback 
--     self._selectPeerage = param.selectPeerage 
--     self._peerage = {}
-- end

-- function PrivilegesPeerageDialog:onInit()
--     local title = self:getUI("bg.titleBg.title")
--     UIUtils:setTitleFormat(title, 1)

--     local peerage = self:getUI("bg.closeBtn")
--     self:registerClickEvent(peerage, function()
--         self:close()
--     end)

--     local lingqu = self:getUI("bg.lingqu")
--     self:registerClickEvent(lingqu, function()
--         self._callback()
--         self:close()
--     end)
--     -- self:reflashUI()
-- end

-- function PrivilegesPeerageDialog:reflashUI(data)
--     local goldNum = self:getUI("bg.goldNum")
--     local gold = tab:Peerage(self._selectPeerage).wages[1][3]
--     goldNum:setString(gold)
-- end

-- return PrivilegesPeerageDialog


-- 特权总览
-- local PrivilegesPeerageDialog = class("PrivilegesPeerageDialog", BasePopView)

-- function PrivilegesPeerageDialog:ctor(param)
--     PrivilegesPeerageDialog.super.ctor(self)
--     self._selectIndex = param.selectIndex 
--     self._peerage = {}
-- end

-- function PrivilegesPeerageDialog:onInit()

--     self._scrollView = self:getUI("bg.scrollView")
--     self._scrollView:setBounceEnabled(true)
--     local title = self:getUI("bg.titleBg.title")
--     title:setFontName(UIUtils.ttfName)
--     title:setColor(cc.c3b(250, 242, 192))
--     title:enable2Color(1, cc.c4b(255, 195, 20, 255))
--     title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     title:setFontSize(30)

--     self._peerageCell = self:getUI("bg.peerageCell")
--     self._peerageCell:setVisible(false)

--     local peerage = self:getUI("bg.closeBtn")
--     self:registerClickEvent(peerage, function()
--         self:close()
--     end)
--     self:setScrollView()
--     -- self:reflashUI()
-- end

-- function PrivilegesPeerageDialog:reflashUI()
--     local peerageData = self._modelMgr:getModel("PrivilegesModel"):getData()

--     for i=1,table.nums(tab.peerage) do
--         self._peerage[i].peerageName = self._peerage[i]:getChildByFullName("peerageName")

--         self._peerage[i].peerageName:setString(lang(tab:Peerage(i)["name"]))

--         self._peerage[i].peerageEffect = self._peerage[i]:getChildByFullName("peerageEffect")
--         self._peerage[i].wagegold = self._peerage[i]:getChildByFullName("wagegold")

--         local des = string.gsub(lang(tab:Peerage(i)["des"]), "%b[]", "")
--         self._peerage[i].peerageEffect:setString(des)
--         if i <= peerageData.peerage then
--             self._peerage[i].peerageEffect:setColor(cc.c3b(61, 31, 0))
--             self._peerage[i].cellBg:loadTexture("globalPanelUI7_cellBg3.png",1)
--             self._peerage[i].suo:setVisible(false)
--             if i == peerageData.peerage then
--                 self._peerage[i].tipBg:setVisible(true)
--             end
--         end
        
--         self._peerage[i].wagegold:setString("X" .. tab:Peerage(i)["wages"][1][3])
--         -- print("i == self._selectIndex =======", i , self._selectIndex)
--         if i == self._selectIndex then
--             self._peerage[i].select = mcMgr:createViewMC("xuanzhongkuang_privilegesxuanzhong", true, false)
--             self._peerage[i].select:setPosition(self._peerage[i]:getContentSize().width*self._peerage[i]:getScaleX()/2,self._peerage[i]:getContentSize().height*self._peerage[i]:getScaleX()/2)
--             self._peerage[i]:addChild(self._peerage[i].select)
--         end
--     end

--     local num = self._scrollView:getInnerContainerSize().height - self._scrollView:getContentSize().height
--     local tempNum = math.ceil(num/(self._peerageCell:getContentSize().height + 6))
    
--     if self._selectIndex > tempNum then
--         self._scrollView:scrollToPercentVertical(num, 0, false)
--     elseif self._selectIndex > 1 then
--         local backPercent = (self._selectIndex - 1) * (self._peerageCell:getContentSize().height + 6) / num 
--         self._scrollView:scrollToPercentVertical(backPercent * 100, 0, false)
--     end
-- end

-- function PrivilegesPeerageDialog:setScrollView()
--     local maxHeight = (self._peerageCell:getContentSize().height + 6) * 10 + 8
--     self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,maxHeight))
--     for i=1,table.nums(tab.peerage) do
--         self._peerage[i] = {}
--         self._peerage[i] = self._peerageCell:clone()
--         self._peerage[i]:setName("peerageCell" .. i)
--         self._peerage[i]:setPosition(cc.p(10,maxHeight - ((self._peerageCell:getContentSize().height + 6)*i) + 3))
--         self._peerage[i]:setVisible(true)
--         self._scrollView:addChild(self._peerage[i])
--         self._peerage[i].cellBg = self._peerage[i]:getChildByFullName("cellBg")
--         self._peerage[i].suo = self._peerage[i]:getChildByFullName("zhezhao")

--         self._peerage[i].tipBg = self._peerage[i]:getChildByFullName("tipBg")
--         self._peerage[i].tipBg:setVisible(false)
--         self._peerage[i].tip = self._peerage[i]:getChildByFullName("tipBg.tip")
--         self._peerage[i].tip:setColor(cc.c3b(255,255,255))
--         self._peerage[i].tip:setFontName(UIUtils.ttfName)
--         self._peerage[i].tip:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

--         self._peerage[i].peerageIcon = self._peerage[i]:getChildByFullName("peerageIcon")
--         self._peerage[i].peerageIcon:loadTexture("" .. tab:Peerage(i).res .. ".png", 1)

--         self._peerage[i].peerageName = self._peerage[i]:getChildByFullName("peerageName")
--         self._peerage[i].peerageName:setFontName(UIUtils.ttfName)
--         self._peerage[i].peerageName:setColor(cc.c3b(255, 249, 181))
--         self._peerage[i].peerageName:enable2Color(1, cc.c4b(233, 160, 0, 255))
--         self._peerage[i].peerageName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 3)
--         self._peerage[i].peerageName:setFontSize(30)

--         self._peerage[i].peerageEffect = self._peerage[i]:getChildByFullName("peerageEffect")
--         self._peerage[i].peerageEffect:setColor(cc.c3b(61, 31, 0))

--         -- self._peerage[i].wagegold = self._peerage[i]:getChildByFullName("wagegold")
--     end
-- end

-- return PrivilegesPeerageDialog