--[[
    @FileName   StarChartsResonanceDialog.lua
    @Authors    zhangtao
    @Date       2018-03-09 18:39:15
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local StarChartsResonanceDialog = class("StarChartsResonanceDialog",BasePopView)
StarChartsResonanceDialog.kItemTag = 1000
StarChartsResonanceDialog.kFragToolId = 3002
function StarChartsResonanceDialog:ctor(params)
    self.super.ctor(self)
    self._parent = params.container
    self._starId = params.starId
    self._heroData = params.heroData
    self.starChartsModel = self._modelMgr:getModel("StarChartsModel")
    self.heroStar = self._heroData.star
end

-- 初始化UI后会调用, 有需要请覆盖
function StarChartsResonanceDialog:onInit()
    self._title = self:getUI("bg.title")
    self._title:setFontName(UIUtils.ttfName_Title)
    self._title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    --关闭按钮
    self:registerClickEventByName("bg.closeBtn", function ()
        UIUtils:reloadLuaFile("starCharts.StarChartsResonanceDialog")
        self:close()
    end)
    --转换按钮
    self.selectType = 1  --1 表示碎片 2 表示万能碎片
    self._okBtn = self:getUI("bg.okBtn")
    self:registerClickEvent(self._okBtn, function ()
        if self.heroStar < 4 then
            self._viewMgr:showTip(lang("TIP_starCharts7"))
            return 
        end
        local needCount = self:getNeedCount()
        if tonumber(needCount) <= 0 then
            self._viewMgr:showTip(lang("TIP_starCharts9"))
            return 
        end
        self:okBtnClicked()
    end)

    self._convertPanel = self:getUI("bg.ConvertPanel")
    self._itemNode1 = self:getUI("bg.ConvertPanel.itemNode1")
    self._useTxtNum1 = self:getUI("bg.ConvertPanel.useNum1")
    self._selectImage1 = self:getUI("bg.ConvertPanel.itemNode1.selectImage1")
    self._itemNode2 = self:getUI("bg.ConvertPanel.itemNode2")
    self._useTxtNum2 = self:getUI("bg.ConvertPanel.useNum2")
    self._selectImage2 = self:getUI("bg.ConvertPanel.itemNode2.selectImage2")
    self._selectImage1:setVisible(false)
    self._selectImage2:setVisible(false)

    self._fragNode = self:getUI("bg.ConvertPanel.fragNode")
    self._itemNum = self:getUI("bg.ConvertPanel.itemNum")
    self._greenPro = self:getUI("bg.detailPanel.centerBg.greenPro")

    self._canGetValue = self:getUI("bg.detailPanel.centerBg.desPanel.canGetValue")
    self._totalValue = self:getUI("bg.detailPanel.centerBg.desPanel.totalValue")

    self:selectBorder()

    self:initData()
    -- self._selectImage1:setVisible(true)
    -- self._selectImage2:setVisible(false)

    self._slider = self:getUI("bg.detailPanel.centerBg.sliderBar")
    self._slider:setCascadeOpacityEnabled(false)
    self._slider:getVirtualRenderer():setOpacity(0)
    self._slider:addEventListener(function(sender, eventType)
        local event = {}
        if eventType == 0 then
            event.name = "ON_PERCENTAGE_CHANGED"            
            self:sliderValueChange()
        end
        event.target = sender
    end)

    self._addBtn = self:getUI("bg.detailPanel.centerBg.addBtn")
    self:registerClickEvent(self._addBtn, function ()
        if self._inputNum < self._maxNeed then
            self._inputNum = self._inputNum + 1
            self:setSliderPercent(self._inputNum/self._maxNeed*100)
        else
            self._viewMgr:showTip("已达使用上限！")
        end
        self:refreshBtnStatus()
    end)

    self._subBtn = self:getUI("bg.detailPanel.centerBg.subBtn")
    self:registerClickEvent(self._subBtn, function ()
        if self._inputNum > 0 then
            self._inputNum = self._inputNum - 1
            self:setSliderPercent(self._inputNum/self._maxNeed*100)
        end
        self:refreshBtnStatus()
    end)

    self._addTenBtn = self:getUI("bg.detailPanel.centerBg.addTenBtn")
    self:registerClickEvent(self._addTenBtn, function ()
        self._inputNum = self._maxNeed
        self:setSliderPercent(self._inputNum/self._maxNeed*100)
        self:refreshBtnStatus()
    end)

    self:updateUI()
    
end

function StarChartsResonanceDialog:setNotOpenStatus()
    local desPanel = self:getUI("bg.detailPanel.centerBg.desPanel")
    local openNotice = self:getUI("bg.detailPanel.centerBg.openNotice")
    local needCount = self:getNeedCount()
    local isOpen = true
    if self.heroStar < 4 or tonumber(needCount) <= 0 then
        isOpen = false
        desPanel:setVisible(isOpen)
        openNotice:setVisible(not isOpen)
    else
        desPanel:setVisible(true)
        openNotice:setVisible(false)
        if tonumber(self._maxNeed) <= 0 then
            isOpen = false
        end
    end
    self._slider:setTouchEnabled(isOpen)
    self._addTenBtn:setTouchEnabled(isOpen)
    self._addBtn:setTouchEnabled(isOpen)
    self._subBtn:setTouchEnabled(isOpen)
    UIUtils:setGray(self._slider,not isOpen)
    UIUtils:setGray(self._okBtn,not isOpen)
    UIUtils:setGray(self._addBtn,not isOpen)
    UIUtils:setGray(self._subBtn,not isOpen)
    UIUtils:setGray(self._addTenBtn,not isOpen)

    if self.heroStar < 4 then
        openNotice:setString("英雄4星后开启星魂共鸣")
    else
        local needCount = self:getNeedCount()
        if tonumber(needCount) <= 0 then
            openNotice:setString("星魂已达最高上限")
        end
    end

end


function StarChartsResonanceDialog:selectBorder()
    self._selectImage = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
    local convertPanel = self:getUI("bg.ConvertPanel")
    convertPanel:addChild(self._selectImage,3)

    local posX,posY = self._itemNode1:getPosition()
    -- self._selectImage:setAnchorPoint(1,1)
    self._selectImage:setPosition(posX+4 ,posY+4)
    self._selectImage:setVisible(true)
end

function StarChartsResonanceDialog:initData()
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(StarChartsResonanceDialog.kFragToolId)
    self._itemCount = itemNum
    self._useTxtNum2:setString(self._itemCount)
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._heroData.soul)
    self._fragCount = itemNum
    self._useTxtNum1:setString(self._fragCount)
    -- if self.selectType == 1 then
    --     self._maxNeed = self._fragCount

    -- elseif self.selectType == 2 then
    --     self._maxNeed = self._itemCount
    -- end
    self._itemNum:setString(self:getHeroSoulNum())
    self:setMaxNeed()
    self._inputNum = 0
end


function StarChartsResonanceDialog:setMaxNeed()
    local needCount = self:getNeedCount()
    if self.selectType == 1 then
        self._maxNeed = self._fragCount
        if self._fragCount > needCount then
            self._maxNeed = needCount
        end
    elseif self.selectType == 2 then
        self._maxNeed = self._itemCount
        if self._itemCount > needCount then
            self._maxNeed = needCount
        end
    end


end

function StarChartsResonanceDialog:updateUI()
    --英雄
    local itemIcon = self._itemNode1:getChildByTag(StarChartsResonanceDialog.kItemTag)
    local _, itemNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._heroData.soul)
    if itemIcon then itemIcon:removeFromParent() end
    itemIcon = IconUtils:createItemIconById({itemId = self._heroData.soul, num = -1, eventStyle = 0})
    self._itemNode1:addChild(itemIcon)
    self:registerClickTouchWithLight(itemIcon,function()
        if self.selectType == 1 then
            return
        end
        self.selectType = 1
        self:resetBorderStatus()
        self:setNotOpenStatus()
    end)
    --万能碎片
    local itemIcon2 = self._itemNode2:getChildByTag(StarChartsResonanceDialog.kItemTag)
    if itemIcon2 then itemIcon:removeFromParent() end
    itemIcon2 = IconUtils:createItemIconById({itemId = StarChartsResonanceDialog.kFragToolId, num = -1, eventStyle = 0})
    self._itemNode2:addChild(itemIcon2)
    self:registerClickTouchWithLight(itemIcon2,function()
        if self.selectType == 2 then
            return
        end
        self.selectType = 2
        self:resetBorderStatus()
        self:setNotOpenStatus()
    end)
    self:setBottomText()
    self:setNotOpenStatus()
    self:refreshBtnStatus()
end

function StarChartsResonanceDialog:resetBorderStatus()
    -- self._selectImage1:setVisible(self.selectType == 1 and true or false)
    -- self._selectImage2:setVisible(self.selectType == 2 and true or false)
    local posX,posY = 0,0
    if self.selectType == 1 then
        posX,posY = self._itemNode1:getPosition()
    elseif self.selectType == 2 then
        posX,posY = self._itemNode2:getPosition()
    end
    -- self._selectImage:setAnchorPoint(1,1)
    self._selectImage:setPosition(posX + 4 ,posY + 4)
    self._selectImage:setVisible(true)

    -- self._maxNeed = self.selectType == 1 and self._fragCount or self._itemCount
    self:setMaxNeed()
    self._inputNum = 0
    self._useTxtNum2:setString(self._itemCount)
    self._useTxtNum1:setString(self._fragCount)
    self:setBottomText()
    self:refreshBtnStatus()
end

function StarChartsResonanceDialog:registerClickTouchWithLight(view,clickCallback)
    local touchX, touchY = 0, 0   
    registerTouchEvent(view,
        function ()
            local tempFlashes = 0
            view.flashes = 50
            if not self._btnSchedule then
                -- self._btnSchedule = ScheduleMgr:regSchedule(0.1, self,function( )
                --     if view.flashes >= 100 then 
                --         tempFlashes = -10
                --     end
                --     if view.flashes <= 50 then
                --         tempFlashes = 10
                --     end
                --     view.flashes = view.flashes + tempFlashes
                --     view:setBrightness(view.flashes)
                -- end)
                view:setBrightness(40)
            end
            view.downSp = view:getVirtualRenderer()
        end,
        function ()
            if view.downSp ~= view:getVirtualRenderer() then
                view:setBrightness(0)
            end
        end,
        function ()
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            view:setBrightness(0)
                  
            if clickCallback ~= nil then 
                clickCallback()
            end
        end,
        function()
            if self._btnSchedule then
                ScheduleMgr:unregSchedule(self._btnSchedule)
                self._btnSchedule = nil
            end
            view:setBrightness(0)
        end)
end

function StarChartsResonanceDialog:refreshBtnStatus( )
    if self._inputNum == 0 then
        self._subBtn:setEnabled(false)
        self._subBtn:setBright(false) 
        self:setSliderPercent(0)
    else
        self._subBtn:setEnabled(true)
        self._subBtn:setBright(true)
    end

    if self._inputNum >= self._maxNeed then 
        self._addBtn:setEnabled(false)
        self._addBtn:setBright(false)
        self:setSliderPercent(100)
    else
        self._addBtn:setEnabled(true)
        self._addBtn:setBright(true)
    end
    if self.selectType == 1 then
        self._useTxtNum1:setString(self._fragCount - self._inputNum > 0 and self._fragCount - self._inputNum or 0)
    else
        self._useTxtNum2:setString(self._itemCount - self._inputNum > 0 and self._itemCount - self._inputNum or 0)
    end
    self._itemNum:setString(self._inputNum + self:getHeroSoulNum())
    self:setSliderPercent(self._inputNum / self._maxNeed * 100)
    self._greenPro:setScaleX(self._slider:getPercent()/100)
    -- local star = self._heroData.star
    -- local cost = 0
    -- if 0 == star then
    --     cost = self._heroData.unlockcost[3]
    -- elseif 4 == star then
    --     cost = self._heroData.scrollUnlock 
    --             and self._heroData.scrollUnlock[1] 
    --             and self._heroData.scrollUnlock[1][3] or 30
    -- else
    --     cost = self._heroData.starcost[star][1][3]
    -- end
    -- local upgradeNeed = cost - self._fragCount - self._inputNum
    -- if upgradeNeed < 0 then upgradeNeed = 0 end
    -- local color = UIUtils.colorTable.ccColorQuality1
    -- local colorType = tab:Tool(self._heroData.soul).color
    -- if colorType and type(colorType) == "number" then
    --     color = UIUtils.colorTable["ccColorQuality" .. colorType]
    -- end
    -- self._canGetValue:setColor(color)
    -- self._canGetValue:setString(lang(tab:Tool(self._heroData.soul).name) .. "x" .. upgradeNeed)
    -- local restCount = self._itemCount - self._inputNum
    -- if restCount < 0 then restCount = 0 end
    -- color = UIUtils.colorTable.ccColorQuality1
    -- colorType = tab:Tool(HeroFragUseView.kFragToolId).color
    -- if colorType and type(colorType) == "number" then
    --     color = UIUtils.colorTable["ccColorQuality" .. colorType]
    -- end
    -- self._totalValue:setColor(color)
    -- self._totalValue:setString(lang(tab:Tool(HeroFragUseView.kFragToolId).name) .. "x" .. restCount)
end

function StarChartsResonanceDialog:okBtnClicked()
    print("=====self._inputNum===="..self._inputNum)
    if self._inputNum == 0 then
        self._viewMgr:showTip(lang("TIP_starCharts6"))
        return
    end

    local clickFunc = function()
        self._serverMgr:sendMsg("StarChartsServer", "convert", {heroId = self._heroData.id, num = self._inputNum,mode = self.selectType}, true, {}, function(result, success) 
            if not success then 
                self._viewMgr:showTip("转换失败，请配表")
                self:close()
                return 
            end
            
            dump(result)
            -- if result["heros"] ~= nil then 
            --      self._modelMgr:getModel("HeroModel"):updateHeroData(result["heros"])
            -- end
            
            -- if result["d"].items then
            --     self._modelMgr:getModel("ItemModel"):updateItems(result["d"].items)
            --     result["d"].items = nil
            -- end
            -- self.starChartsModel:setStarInfoByHeroId(self._heroData.id)  --更新英雄星图信息
            -- self._parent:setSoulNum()
            -- self:close()
            --self._viewMgr:showTip("转换成功")
            if self.selectType == 1 then
                local zhuanhuaAni = mcMgr:createViewMC("zhuanhua1_zhuanhuadonghua", false,true)
                local mcContentSize = self._itemNode1:getContentSize()
                zhuanhuaAni:setPosition(182,mcContentSize.height/2 + 2)
                self._itemNode1:addChild(zhuanhuaAni,100)
            else
                local zhuanhuaAni2 = mcMgr:createViewMC("zhuanhua2_zhuanhuadonghua", false,true)
                local mcContentSize = self._itemNode2:getContentSize()
                zhuanhuaAni2:setPosition(118,mcContentSize.height/2 + 2)
                self._itemNode2:addChild(zhuanhuaAni2,100) 
            end
            self:initData()
            self:updateUI()
            -- --self:initData()
            -- --self:refreshBtnStatus()
            -- local star = self._heroData.star
            -- local gifts = {}
            -- if 0 == star then
            --     gifts = clone(self._heroData.unlockcost)
            --     gifts[3] = self._inputNum
            -- elseif 4 == star then
            --     gifts = {"tool",300000+tonumber(self._heroData.id),self._inputNum}
            -- else
            --     gifts = clone(self._heroData.starcost[star])
            --     gifts[1][3] = self._inputNum
            -- end
            -- if type(gifts) == "table" and type(gifts[1]) ~= "table" then
            --     gifts = {gifts}
            -- end
            -- DialogUtils.showGiftGet({gifts = gifts, callback = function()
            --     self._container:onFragViewClose()
            --     self:close()
            -- end})
        end)
    end
    if self.selectType == 2 then
        DialogUtils.showShowSelect({desc = "万能英雄碎片为稀有物资，是否继续执行此操作？",callback1=function( )
                clickFunc()
        end})
    else
        clickFunc()
    end
end

--
function StarChartsResonanceDialog:setBottomText()
    local heroName = lang(tab.hero[self._heroData.id]["heroname"])
    local needNum = self:getNeedCount()
    if self.selectType == 1 then
        self._canGetValue:setString(heroName .."碎片x"..needNum)
        self._totalValue:setString(heroName .."碎片x"..self._fragCount)
    else
        self._canGetValue:setString(lang("TOOL_3002").."x"..needNum)
        self._totalValue:setString(lang("TOOL_3002").."x"..self._itemCount)
    end
end
--已经转化的星魂数量
function StarChartsResonanceDialog:getHeroSoulNum()
    self.starInfo = self.starChartsModel:getStarInfo()
    if self.starInfo == nil or self.starInfo["ss"] == nil then
        return 0
    else
       return self.starInfo["ss"]
    end
    return 0
end
--激活所有星体还需的星魂数量
function StarChartsResonanceDialog:getNeedCount()
    local totalCount = self.starChartsModel:getAllBodyActivityCost()
    local costCount = self.starChartsModel:getActivitedBodyCost()
    local soulCount = self:getHeroSoulNum()
    local completedCount = tab.starCharts[self._starId]["charts_cost1"]
    local needCount = totalCount - costCount - soulCount + completedCount
    if needCount < 0 then
        needCount = 0
    end
    return needCount
end

function StarChartsResonanceDialog:setSliderPercent(num)
    local num = num * 0.01
    local newnum= 1.5 * num /(1+0.5 * num)
    self._slider:setPercent(newnum * 100)
end

function StarChartsResonanceDialog:sliderValueChange()    
    local num = self._slider:getPercent() * 0.01
    -- self._inputNum = math.floor(self._itemCount * num /100)
    local newnum = (num/(1.5-0.5*num))*100
    self._inputNum = math.ceil((self._maxNeed-0.9) * newnum /100)
    if self._inputNum < 1 then
        self._inputNum = 0
    end
    self:refreshBtnStatus()
end

-- 第一次进入调用, 有需要请覆盖
function StarChartsResonanceDialog:onShow()

end

-- 接收自定义消息
function StarChartsResonanceDialog:reflashUI(data)

end

return StarChartsResonanceDialog