--
-- Author: huangguofang
-- Date: 2018-03-21 10:50:44
--


local iconIdMap = IconUtils.iconIdMap

local AcLuckyLotteryGetDialog = class("AcLuckyLotteryGetDialog",BasePopView)
function AcLuckyLotteryGetDialog:ctor(data)
    self.super.ctor(self)
    self._closeCallback = data.closeCallback or nil
    self._againCallBack = data.againCallBack
    self._buyNum = data.buyNum or 1

    self._items = {} -- 物品数组
	self._isFam = data.isFam
    
    self.bgName = "bg.bg1"    
end

function AcLuckyLotteryGetDialog:onDestroy()
    
    self.super.onDestroy(self)
end

function AcLuckyLotteryGetDialog:getMaskOpacity()
    return 230
end

function AcLuckyLotteryGetDialog:onInit()
	-- self._scrollView = self:getUI("bg.scrollView")
    self._bg = self:getUI("bg")
    self._bg1 = self:getUI("bg.bg1")
    -- self._bg1:setVisible(true)
    self._againBtn = self:getUI("bg.againBtn")
    self._againBtn:setTitleText("再来".. self._buyNum .. "次")
	self._closeBtn = self:getUI("bg.closeBtn")
	self._againBtn:setOpacity(0)
    self._againBtn:setCascadeOpacityEnabled(true)
	self._closeBtn:setOpacity(0)

    self._bg1ScrollView = self:getUI("bg.bg1.scrollview")

    local costData = tab:Setting("GEM_LOTTERY_NUM_" .. self._buyNum).value
    local costType = costData[1][1]
    local decorate = self:getUI("bg.againBtn.decorate")
    decorate:setZOrder(-2)
    local costImg = self:getUI("bg.againBtn.costImg")
    costImg:setZOrder(-1)
    costImg:loadTexture(IconUtils.resImgMap[costType], 1)
    local userData = self._modelMgr:getModel("UserModel"):getData()
    local haveCostNum = userData[costType]    
    local costNum = self:getUI("bg.againBtn.costNum")
    costNum:setZOrder(-1)
    costNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    costNum:setString(costData[1][3] or 0)
    costNum:setColor(haveCostNum >= costData[1][3]
                and UIUtils.colorTable.ccUIBaseColor1
                or UIUtils.colorTable.ccUIBaseColor6)
    -- self._scrollView:setClippingType(1)
    self.bgWidth,self.bgHeight = self._bg1:getContentSize().width,self._bg1:getContentSize().height   
    -- 物品名字展示
    self._itemNames = {}
   
end
function AcLuckyLotteryGetDialog:animBegin(callback)    
    audioMgr:playSound("ItemGain_1")
   
    local bgW,bgH = self._bg1:getContentSize().width,self._bg1:getContentSize().height
    self:addPopViewTitleAnim(self._bg, "gongxihuode_huodetitleanim", 480, 480)
    ScheduleMgr:delayCall(400, self, function( )
        if callback and self._bg1 then
            callback()
        end
    end)
end

function AcLuckyLotteryGetDialog:reflashUI(data)
    -- dump(data,"...data...in AcLuckyLotteryGetDialog:reflashUI")
    local gifts = data.gifts or data
    if gifts and #gifts == 0 then
        gifts = {}
        table.insert(gifts,data.gifts or data)
    end
    self._gifts = gifts
    -- dump(gifts,"gifts==>",5)
  
    -- 如果有可批量使用的礼包进入背包，通知主界面
    for k,v in pairs(gifts) do
        local id = v.typeId or v[2]
        if id == 0 then
            id = IconUtils.iconIdMap[id]
        end 
        local giftData = tab.toolGift[id] or tab.equipmentBox[id]
        if giftData then
            self._modelMgr:getModel("MainViewModel"):reflashMainView()
            break
        end       
    end
    local maxHeight = self._bg1:getContentSize().height   
    local colMax = 5
    local itemHeight,itemWidth = 140,127
    local maxScrollHeight = itemHeight * math.ceil( #gifts / colMax)+5
    self._bg1ScrollView:setInnerContainerSize(cc.size(1136,maxScrollHeight))

    local x = 0
    local y = 0

    -- print("gifts===",#gifts)
    local offsetX,offsetY = 0,0
    local row = math.ceil( #gifts / colMax)
    local col = #gifts
    if col > colMax then
        col = colMax
    end

    offsetX = (self._bg1ScrollView:getContentSize().width-(col-1)*itemWidth)*0.5 -- (self.bgWidth-(col-1)*itemWidth)*0.5
    --    矫正 - (row - 2) * 15  2行 +15 2行不加
    offsetY = maxScrollHeight/2 + row*itemHeight/2 - itemHeight/2 + 30
    if row == 1 then
        offsetY = maxScrollHeight/2 + row*itemHeight/2 + 30
    end
    x = x+offsetX-itemWidth
    y = y+offsetY-5
    
    local showItems
    showItems = function( idx )
        if not gifts[idx] then
            return 
        end
        x = x + itemWidth
        if idx ~= 1 and (idx-1) % colMax == 0 then 
            x =  offsetX
            y = y - itemHeight
        end
        if idx > 10 and idx%5 == 1 then -- 多一行滚屏
            local offsetY = -(maxScrollHeight - 5 - 2*itemHeight)+(math.ceil((idx-10)/5))*itemHeight
            local container = self._bg1ScrollView:getInnerContainer()
            container:runAction(cc.Sequence:create(
                cc.EaseOut:create(cc.MoveTo:create(0.2,cc.p(0,offsetY)),0.7),
                cc.CallFunc:create(function( )
                    self:createItem(gifts[idx], x, y, idx,showItems)
                end)
            ))
        else
            self:createItem(gifts[idx], x, y, idx,showItems)
        end
    end
    local bg1Height = 200
    self._bg1:setOpacity(0)
    self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
    self:animBegin(function( )
        self._bg1:setOpacity(255)
        local sizeSchedule
        local step = 0.5
        local stepConst = 30

        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
            else
                self._bg1:setContentSize(cc.size(self.bgWidth,maxHeight))
                self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
            end
        end)        
        showItems(1)
        
    end)

end

function AcLuckyLotteryGetDialog:createItem( data,x,y,index,nextFunc )
    local itemData
    print("========index===",index)
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num
    local isChange = data[4] or data.isChange
    
    -- dump(data,"data i n createitem")
    if itemType ~= "tool" 
		and itemType ~= "rune"
    then
        itemId = iconIdMap[itemType]
    end
    
    itemData = tab.tool[itemId]
    
    local item
    if itemType == "rune" then
		itemData = tab:Rune(itemId)
		item =IconUtils:createHolyIconById({suitData = itemData})
	else
        item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = false })
        local isHadItemInTreasure = self._modelMgr:getModel("TreasureModel"):getTreasureById(itemId)
        local _,itemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
       
        --获得界钻石icon加底光特效
        --gem = 39992, payGem = 39978,
        if itemId == IconUtils.iconIdMap.gem or itemId == IconUtils.iconIdMap.payGem then
             local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(item:getContentSize().width*0.5,item:getContentSize().height*0.5)      
            mc:setScale(1.1)
            mc:setName("itemMc")
            mc:setVisible(false)
            item:addChild(mc,-5) 
        end
        
    end

    table.insert(self._items,item)
    item:setSwallowTouches(true)
    item:setScale(0.85)
    item:setScaleAnim(false)
    item:setAnchorPoint(0,0)
	item:setPosition(x,y)
    item:setVisible(true)
    local itemNormalScale = .9 --80/item:getContentSize().width
    if itemData and (itemData.name or itemData.heroname) then
	    local itemName = ccui.Text:create()
        itemName:setFontName(UIUtils.ttfName)
        itemName:setTextAreaSize(cc.size(100,65))
        -- itemName:ignoreContentAdaptWithSize(false)
        -- itemName:setContentSize(cc.size(50,100))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
	    itemName:setString(lang(tostring(itemData.name or itemData.heroname)))
	    itemName:setFontSize(20)
        itemName:getVirtualRenderer():setLineHeight(20)
		local color = ItemUtils.findResIconColor(itemId,itemNum)
		if itemType=="rune" then
			color = itemData.quality
		end
        itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (color or 1)])
        itemName:setFontName(UIUtils.ttfName)        
        -- itemName:getVirtualRenderer():setLineHeight(100.0)
        -- itemName:enableOutline(cc.c4b(0,0,0,255),2)
        itemName:setAnchorPoint(0.5,1)
	    itemName:setPosition(item:getContentSize().width/2,0)
        itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	    item:addChild(itemName)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)
	end
    
    item:setAnchorPoint(0.5,0.5)
    -- self._bg1:addChild(item)
    self._bg1ScrollView:addChild(item)
    
    item:setOpacity(0)
    local children = item:getChildren()
    for k,v in pairs(children) do
        if v:getName() == "numLab" then
            v:setVisible(false)
        else
            v:setOpacity(0)
        end
        if v.setSwallowTouches then
            v:setSwallowTouches(true)
        end
    end
    local iconColor = item:getChildByFullName("iconColor")
    local bgMc
    if iconColor then
        bgMc= iconColor:getChildByName("bgMc")
    end
    if bgMc then
        bgMc:setVisible(false)
    end
    local boxIcon = item:getChildByFullName("boxIcon")
    local diguangMc
    if boxIcon then
        diguangMc = boxIcon:getChildByFullName("diguangMc")
    end
    if diguangMc then
        diguangMc:setVisible(false)
    end
                               
    ScheduleMgr:delayCall(120, self, function( )--index*        
        audioMgr:playSound("ItemGain_2")        
        item:setScale(2)
        if index == #self._gifts then
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,itemNormalScale*0.6)),cc.ScaleTo:create(0.1,itemNormalScale),cc.CallFunc:create(function( )
                local mc = item:getChildByFullName("itemMc")
                if mc then
                    mc:setVisible(true)
                end
                for k,v in pairs(self._itemNames) do
                    v:setVisible(true)
                end
                local boxIcon = item:getChildByFullName("boxIcon")
                local diguangMc
                if boxIcon then
                    diguangMc = boxIcon:getChildByFullName("diguangMc")
                end
                if diguangMc then
                    diguangMc:setVisible(true)
                end
                local iconColor = item:getChildByFullName("iconColor")
                local bgMc
                if iconColor then
                    bgMc= iconColor:getChildByName("bgMc")
                end
                if bgMc then
                    bgMc:setVisible(true)
                end
                
            end)))
        else
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,itemNormalScale*0.6)),
                            cc.ScaleTo:create(0.1,itemNormalScale),
                            cc.CallFunc:create(function()
                                local mc = item:getChildByFullName("itemMc")
                                if mc then
                                    mc:setVisible(true)
                                end
                                local boxIcon = item:getChildByFullName("boxIcon")
                                local diguangMc = boxIcon and boxIcon:getChildByFullName("diguangMc")
                                if diguangMc then
                                    diguangMc:setVisible(true)
                                end
                                local iconColor = item:getChildByFullName("iconColor")
                                local bgMc
                                if iconColor then
                                    bgMc= iconColor:getChildByName("bgMc")
                                end
                                if bgMc then
                                    bgMc:setVisible(true)
                                end

                            end)))
        end
            
        local children = item:getChildren()
        for k,v in pairs(children) do
                -- print("v:getName",v:getName() ~= "bgMc",v:getName())
            if v:getName() == "numLab" then
                v:setVisible(true)
            end
            if v:getName() ~= "bgMc" then
                v:runAction(cc.FadeIn:create(0.1))--cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,1)))
            end
        end
        if index == #self._gifts then
            local setCanCloseFunc = function ()
                    self._againBtn:runAction(cc.FadeIn:create(0.1)) 
                    self._closeBtn:runAction(cc.FadeIn:create(0.1))   
                    local hadClose
                    self:registerClickEvent(self._againBtn, function()
                        if self._againCallBack then
                            print("================================")
                            self._againCallBack()
                        end
                        if not hadClose then
                            hadClose = true
                            self:closeFunc()
                        end
                    end)
                    
                    self:registerClickEvent(self._closeBtn, function()
                        if self._againCallBack then
                            print("================================")
                            self._closeCallback()
                        end
                        if not hadClose then
                            hadClose = true
                            self:closeFunc()
                        end
                    end)
                    -- ???? scaleAnim
                    self:processItemsAfterAction()
            end
            ScheduleMgr:delayCall(300, self, function( )
                setCanCloseFunc()
            end)
        end
        nextFunc(index+1)
    end)
end

-- 关闭
function AcLuckyLotteryGetDialog:closeFunc( )
    
    if self.close then                       
        self:close(true)
    end
    UIUtils:reloadLuaFile("activity.acLuckyLottery.AcLuckyLotteryGetDialog")
end

-- 设置 scaleAnim
function AcLuckyLotteryGetDialog:processItemsAfterAction( )
    for k,v in pairs(self._items) do
        v:setScaleAnim(true)
    end
end

return AcLuckyLotteryGetDialog