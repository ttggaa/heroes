--
-- Author: huangguofang
-- Date: 2017-02-08 19:21:40
--
local GlobalHeadFrameGetDialog = class("GlobalHeadFrameGetDialog",BasePopView)
function GlobalHeadFrameGetDialog:ctor(data)
    self.super.ctor(self)
    self._gifts = data.gifts or {}
    self._callback = data.callBack or nil

    dump(data,"data_gifts",3)
   
end

function GlobalHeadFrameGetDialog:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalHeadFrameGetDialog:onInit()
	-- self._scrollView = self:getUI("bg.scrollView")
    self._bg = self:getUI("bg")
    self._bgImg = self:getUI("bg.bgImg")
    self._bgImg:setSwallowTouches(false)
    -- self._bg:setVisible(false)

    self.bgWidth,self.bgHeight = self._bgImg:getContentSize().width,self._bgImg:getContentSize().height
  
    self._items = {}
    -- 动画相关
    self._itemNames = {}
    
    -- 不显示点击任意位置关闭界面提示
    -- self._touchLab = self:getUI("bg.touchLab")
    -- self._touchLab:setVisible(false)
    -- self._touchLab:setOpacity(0)
    self._tipsTxt = self:getUI("bg.tipsTxt")
    self._tipsTxt:setVisible(true)
    self._tipsTxt:setOpacity(0)
end
function GlobalHeadFrameGetDialog:animBegin(callback)
    if not self.viewType then
        audioMgr:playSound("ItemGain_1")
    end
    local showXian 
    local bgW,bgH = self._bgImg:getContentSize().width,self._bgImg:getContentSize().height
    self:addPopViewTitleAnim(self._bg, "gongxijiesuo_huodetitleanim", 480, 480)
    ScheduleMgr:delayCall(400, self, function( )
        if callback and self._bgImg then
            callback()
        end
    end)
end

-- 接收自定义消息
function GlobalHeadFrameGetDialog:reflashUI(data)
  
    local gifts = self._gifts
    local itemNum = #gifts
    local itemHeight,itemWidth = 140,127

    local maxHeight = self._bgImg:getContentSize().height

    local offsetX = (self._bgImg:getContentSize().width-(itemNum-1)*itemWidth)*0.5 -- (self.bgWidth-(col-1)*itemWidth)*0.5
    local offsetY = maxHeight/2 + 15

    local x = offsetX-itemWidth
    local y = offsetY-5
    local showItems
    showItems = function( idx )
        x = x + itemWidth
        if idx ~= 1 and (idx-1) % 5 == 0 then 
            x =  offsetX
            y = y - itemHeight
        end
        self:createItem(gifts[idx], x, y, idx,showItems)
    end
    
    local bg1Height = 200
    self._bgImg:setOpacity(0)
    self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))
    self:animBegin(function( )
        self._bgImg:setOpacity(255)
        local sizeSchedule
        local step = 0.5
        local stepConst = 30
        -- self._bgImg:setAnchorPoint(0.5,1)
        -- self._bgImg:setPositionY(self._bgImg:getPositionY()+self._bgImg:)
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bgImg:setContentSize(cc.size(self.bgWidth,bg1Height))
            else
                self._bgImg:setContentSize(cc.size(self.bgWidth,maxHeight))
                self._bgImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                
            end
        end)
        -- ScheduleMgr:delayCall(200, self, function( )
        showItems(1)
        -- end)
    end)

    -- 自适应关闭label
    -- self._touchLab:setPositionY(self._bg:getContentSize().height/2-maxHeight/2-30)
end

function GlobalHeadFrameGetDialog:createItem( data,x,y,index,nextFunc )
    -- print("==========================index==",index,#self._gifts)
    local itemData
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num
    -- dump(data,"data i n createitem")
    
    if itemType ~= "tool" and itemType ~= "avatarFrame" and itemType ~= "avatar" then
        itemId = IconUtils.iconIdMap[itemType]
    end
    
    itemData = tab.tool[itemId]
    local item
    if itemType == "avatarFrame" then
        itemData = tab:AvatarFrame(tonumber(itemId))
        if not itemData then
            print("=====AvatarFrame have no id==",itemId)
            itemData = tab.tool[itemId]
        end
        param = {itemId = itemId,num = itemNum,itemData = itemData}
        item = IconUtils:createHeadFrameIconById(param)
        self._haveFrame = true
    elseif itemType == "avatar" then
        itemData = tab:RoleAvatar(tonumber(itemId))
        if not itemData then
            print("=====RoleAvatar have no id==",itemId)
            itemData = tab.tool[itemId]
        end
        param = {itemId = itemId,num = itemNum,itemData = itemData,eventStyle=1}
        item = IconUtils:createAvatarIconById(param)
        --todo
        self._haveAvatar = true
    else
        item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = false })
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
    -- item:setScale()
    table.insert(self._items,item)
    -- item:setSwallowTouches(false)
    item:setScale(0.85)
    item:setScaleAnim(false)
    item:setAnchorPoint(0,0)
    item:setPosition(x,y)
    item:setVisible(true)
    local itemNormalScale = .9 --80/item:getContentSize().width
    if itemData and itemData.name then
	    local itemName = ccui.Text:create()
        itemName:setFontName(UIUtils.ttfName)
        itemName:setTextAreaSize(cc.size(100,65))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
	    itemName:setString(lang(tostring(itemData.name or itemData.heroname)))
	    itemName:setFontSize(20)
        itemName:getVirtualRenderer():setLineHeight(20)
        -- local color = ItemUtils.findResIconColor(itemId,itemNum)
        -- itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (color or 1)])
        itemName:setColor(UIUtils.colorTable.ccUIBaseColor5)
        itemName:setFontName(UIUtils.ttfName)        
        itemName:setAnchorPoint(0.5,1)
	    itemName:setPosition(item:getContentSize().width/2,-2)
        itemName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
	    item:addChild(itemName)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)
	end

    item:setAnchorPoint(0.5,0.5)
    self._bgImg:addChild(item,5)
 
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
        if not self.viewType then
            audioMgr:playSound("ItemGain_2")
        end
        -- if bgMc then
        --     bgMc:setVisible(true)
        -- end
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
                                local diguangMc = item:getChildByFullName("boxIcon"):getChildByFullName("diguangMc")
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
            if v:getName() == "numLab" then
                v:setVisible(true)
            end
            if v:getName() ~= "bgMc" then
                v:runAction(cc.FadeIn:create(0.1))--cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,1)))
            end
        end
        if index == #self._gifts then
            local str = ""
            if self._haveFrame and self._haveAvatar then
                str = "头像框和头像"
            else
                if self._haveFrame then
                    str = "头像框"
                elseif self._haveAvatar then
                    str = "头像"
                end
            end
            self._tipsTxt:setVisible(str ~= "")
            self._tipsTxt:setString("已解锁全新".. str .."，可在个人信息中更换")

            ScheduleMgr:delayCall(300, self, function( )
                -- self._touchLab:runAction(cc.FadeIn:create(0.1))   
                self._tipsTxt:runAction(cc.FadeIn:create(0.1))               
                -- self._confirmBtn:runAction(cc.FadeIn:create(0.1))   
                local hadClose

                self:registerClickEventByName("closePanel", function()
                    if not hadClose then
                        hadClose = true
                        self:closeFunc()
                    end
                end)

                self:produceItemsAfterAction() 
            end)
        else
            nextFunc(index+1)
        end
       
    end)
end

function GlobalHeadFrameGetDialog:produceItemsAfterAction( )
    for k,v in pairs(self._items) do
        v:setScaleAnim(true)
    end
end

function GlobalHeadFrameGetDialog:closeFunc( )
    
    if self._callback then
        self._callback()
    end
    if self.close then                       
        self:close(true)
    end
    UIUtils:reloadLuaFile("global.GlobalHeadFrameGetDialog")
end

return GlobalHeadFrameGetDialog