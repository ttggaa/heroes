--
-- Author: huangguofang
-- Date: 2016-08-25 16:16:54
--
local GlobalTreasureGetDialog = class("GlobalTreasureGetDialog",BasePopView)
function GlobalTreasureGetDialog:ctor(param)
    self.super.ctor(self)
    self._gifts = param.gifts
    self._treasureCoinNum = param.coinCount
    self._callback = param.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function GlobalTreasureGetDialog:onInit()
	self._closePanel = self:getUI("closePanel")
    -- self._closePanel:setSwallowTouches(false)
    self._isCloseClick = false
    self._itemNames = {}
    self._itemSps = {}
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setSwallowTouches(false)
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setVisible(true)
    self._touchLab:setOpacity(0)

    self._desNode = self:getUI("bg.desNode")
    self._desNode:setOpacity(0)
    self._desNode:setCascadeOpacityEnabled(true)
    self._desLabel1 = self._desNode:getChildByFullName("desLabel1")
    self._desLabel1:setFontName(UIUtils.ttfName)
    self._desLabel1:setColor(cc.c3b(254, 235, 177))
    self._desLabel2 = self._desNode:getChildByFullName("desLabel2")
    self._desLabel2:setFontName(UIUtils.ttfName)
    self._desLabel2:setColor(cc.c3b(255, 218, 71))
    self._goodsIcon = self._desNode:getChildByFullName("goodsIcon")
    self._numLabel = self._desNode:getChildByFullName("numLabel")
    self._numLabel:setFontName(UIUtils.ttfName)

    if self._treasureCoinNum then
        self._numLabel:setString(tostring(self._treasureCoinNum))
    else
        self._desNode:setVisible(false)
    end
    -- [[ 加多少次后必得橙色宝物的逻辑
    self._promptBg = self:getUI("bg.promptBg")
    self._promptDes1 = self:getUI("bg.promptBg.des1")
    self._promptDes1:setString("占星")
    self._promptDes1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._promptDes1:setColor(cc.c3b(242, 242, 229))
    -- self._promptDes1:enable2Color(1, cc.c4b(255, 236, 73, 255))

    self._promptDes2 = self:getUI("bg.promptBg.des2")
    self._promptDes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._promptDes2:setColor(cc.c3b(242, 242, 229))
    -- self._promptDes2:enable2Color(1, cc.c4b(255, 236, 73, 255))
    
    self._promptDes3 = self:getUI("bg.promptBg.des3")
    self._promptDes3:setColor(cc.c3b(242, 242, 229))
    self._promptDes3:enable2Color(1, cc.c4b(255, 236, 73, 255))
    self._promptDes3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._nextNum = self:getUI("bg.promptBg.nextNum")
    self._nextNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
    -- self._nextNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- 累计抽取次数 
    local totalCount = self._modelMgr:getModel("PlayerTodayModel"):getDrawAward().tDrawNum or 0

    local toGetNum = 20-totalCount%20
    self._nextNum:setString(toGetNum)
    -- [[ 剩余一次得橙色显示
    if toGetNum == 0 then
        self._promptDes1:setVisible(false)
        self._nextNum:setString("")
        self._promptDes2:setString("下次必得")
    else
        self._promptDes1:setVisible(true)
        self._nextNum:setString(toGetNum)
        self._promptDes2:setString("次必得")
    end
    self._promptDes2:setPositionX(self._nextNum:getPositionX()+self._nextNum:getContentSize().width+1)
    self._promptDes3:setPositionX(self._promptDes2:getPositionX()+self._promptDes2:getContentSize().width+1)
    self._promptBg:setOpacity(0)
    self._promptBg:setCascadeOpacityEnabled(true)
    --]]
end

function GlobalTreasureGetDialog:animBegin(callback)
   	-- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    local bgW,bgH = self._bg1:getContentSize().width,self._bg1:getContentSize().height
 	--撒碎纸片
    -- local caidai = mcMgr:createViewMC("caidai_choubaowu", false,true)
    -- caidai:setPosition(bgW/2,bgH+130)
    -- self._bg1:addChild(caidai,5)
    self:addPopViewTitleAnim(self._bg, "huodebaowu_huodetitleanim", 480, 480)

    ScheduleMgr:delayCall(400, self, function( )
        -- ScheduleMgr:delayCall(200, self, function( )
            if callback and self._bg1 then
                callback()
            end
        -- end)
    end)
   
end

-- 接收自定义消息
function GlobalTreasureGetDialog:reflashUI(data)
   
	self.bgWidth,self.bgHeight = self._bg1:getContentSize().width,self._bg1:getContentSize().height
	local gifts = self._gifts

    local colMax = 5
    local itemHeight,itemWidth = 155,147
    local maxHeight = itemHeight * math.ceil( #gifts / colMax) + 80
    local maxHeight = self._bg1:getContentSize().height

    local x = 0
    local y = 0

    -- print("gifts===",#gifts)
    local offsetX,offsetY = 0,0
    local row = math.ceil( #gifts / colMax)
    local col = #gifts
    if col > colMax then
        col = colMax
    end

    offsetX = (self.bgWidth-(col-1)*itemWidth)*0.5
    --    矫正 - (row - 2) * 15  2行 +15 2行不加
    offsetY = maxHeight/2 + row*itemHeight/2 - itemHeight/2 + 15  --maxHeight/2 - row * itemHeight/2 + (row -1) * itemHeight + itemHeight / 2 --offsetY + (row-1)*itemHeight +self.bgHeight/2 + 60
    
    x = x+offsetX-itemWidth
    y = y+offsetY
  
  	--创建item
    local showItems
    showItems = function( idx )
       -- print("=============idx=====",idx)
       	if idx > #gifts then
       		return
       	end
        x = x + itemWidth
        if idx ~= 1 and (idx-1) % colMax == 0 then 
            x =  offsetX
            y = y - itemHeight
        end
        self:createItem(gifts[idx], x, y, idx,showItems)
    end

    local sizeSchedule
    local step = 0.5
    local stepConst = 50
    local bg1Height = 200
    self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
    self._bg1:setOpacity(0)
    self:animBegin(function( )
        self._bg1:setOpacity(255)
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
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                -- title动画
            end
        end)
        --添加items      
        showItems(1)
    end)

    -- 自适应关闭label
    -- self._touchLab:setPositionY(self._bg1:getPositionY() - self._bg1:getContentSize().height/2 - 30)

end

function GlobalTreasureGetDialog:createItem( data,x,y,index,nextFunc )
    local itemData
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num
    local isNotTreasure = false --  新增了
    if itemType ~= "tool" and itemType ~= "hero" and itemType ~= "team" then
        itemId = IconUtils.iconIdMap[itemType]
        isNotTreasure = true
    end
    if math.floor(itemId/1000) == 41 then
        isNotTreasure = true
    end
    itemData = tab:Tool(itemId)
    if itemData == nil then
        print("==================itemID 不存在=====",itemId)
    end
    local item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = true,treasureCircle=true })  --effect = true 不加特效 --treasureCircle 不加内框
    item:setSwallowTouches(true)
    item:setAnchorPoint(cc.p(0,0))
    item:setPosition(cc.p(x,y))
    item:setScaleAnim(false)
    -- item:setVisible(true)

    local itemIcon = item:getChildByFullName("itemIcon")
    itemIcon:setScale(0.8)

	local color = itemData.color or 2
    if not isNotTreasure then 
        local boxIcon = item:getChildByFullName("boxIcon")
        boxIcon:setSwallowTouches(true)
    	if boxIcon ~= nil and itemData then 
    		boxIcon:loadTexture("treasureShop_color".. color ..".png", 1)
    		boxIcon:setContentSize(cc.size(100, 100))
    	end
    	local iconColor = item:getChildByFullName("iconColor")
    	if iconColor then
    		iconColor:setVisible(false)
    	end
    	local numLab = item:getChildByFullName("numLab") or iconColor:getChildByFullName("numLab")
        numLab:setAnchorPoint(cc.p(0.5,0.5))
    	numLab:setPosition(numLab:getPositionX() + 5, numLab:getPositionY() + 2)
    end

	if 4 == color or 5 == color then

        local sp = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
            sender:gotoAndPlay(0)
        end,RGBA8888) 
        sp:setPosition(item:getContentSize().width/2,item:getContentSize().height/2)      
        sp:setScale(1.15)
        sp:setVisible(false)
        table.insert(self._itemSps,sp)
        item:addChild(sp,-2)
	end

    local itemNormalScale = 1 
    if itemData and itemData.name then
	    local itemName = ccui.Text:create()
        itemName:setTextAreaSize(cc.size(100,50))
        -- itemName:ignoreContentAdaptWithSize(false)
        -- itemName:setContentSize(cc.size(50,100))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
	    itemName:setString(lang(tostring(itemData.name)))
	    itemName:setFontSize(20)
        local color = ItemUtils.findResIconColor(itemId,itemNum)
        itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (color or 1)])
        itemName:setFontName(UIUtils.ttfName)        
        -- itemName:getVirtualRenderer():setLineHeight(100.0)
        -- itemName:enableOutline(cc.c4b(0,0,0,255),2)
        itemName:setAnchorPoint(cc.p(0.5,1))
	    itemName:setPosition(cc.p(item:getContentSize().width/2,-10))
	    item:addChild(itemName)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)
	end
   
    item:setAnchorPoint(cc.p(0.5,0.5))
    self._bg1:addChild(item)

    item:setOpacity(0)
    item:setCascadeOpacityEnabled(true)
    
    --第一个item不需要延迟
    local itemTime = (index -1) > 0 and 100 or 100
    ScheduleMgr:delayCall(itemTime, self, function( )      
        audioMgr:playSound("ItemGain_2")
        -- if bgMc then
        --     bgMc:setVisible(true)
        -- end        
        item:setScale(2.5)
        if index == #self._gifts then
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.15),cc.ScaleTo:create(0.1,itemNormalScale*0.7)),cc.CallFunc:create(function()
            	local baowuguangMc = mcMgr:createViewMC("baowuguang_choubaowu", false, true)
		        baowuguangMc:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
		        baowuguangMc:setPlaySpeed(0.8)
		        baowuguangMc:setScale(0.9)
		        item:addChild(baowuguangMc,10)

            end),
            cc.ScaleTo:create(0.1,itemNormalScale),cc.CallFunc:create(function( )
                --最后一个item播完动画，显示name
                for k,v in pairs(self._itemNames) do
                    v:setVisible(true)          
                end  
                for kk,vv in pairs(self._itemSps) do
                    vv:setVisible(true)          
                end              
                item:setScaleAnim(true)
            end)))
        else        	
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.15),cc.ScaleTo:create(0.1,itemNormalScale*0.8)),cc.CallFunc:create(function()
            	local baowuguangMc = mcMgr:createViewMC("baowuguang_choubaowu", false, true)
		        baowuguangMc:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
		        baowuguangMc:setPlaySpeed(0.8)
		        baowuguangMc:setScale(0.9)
		        item:addChild(baowuguangMc,10)
                
            end),
            cc.ScaleTo:create(0.1,itemNormalScale),
            cc.CallFunc:create(function( )
                item:setScaleAnim(true)
            end)))
        end
          
        if index == #self._gifts then

        	--播完动画 注册关闭点击事件
            ScheduleMgr:delayCall(120*index, self, function( )
                self._touchLab:runAction(cc.FadeIn:create(0.1))       
                self._desNode:runAction(cc.FadeIn:create(0.1))  
                self._promptBg:runAction(cc.FadeIn:create(0.2))
                local hadClose
                self:registerClickEventByName("closePanel", function()
                    if not hadClose then
                        -- print("=====================================================")
                        hadClose = true
                        local callback = self._callback
                        if callback and type(callback) == "function" then
                            callback()
                        end                        
                        if self.close then                       
                            self:close(true)
                        end
                        UIUtils:reloadLuaFile("global.GlobalTreasureGetDialog")
                    end
                end)

            end)
        end     
       	--继续创建  
        local isDis = tab.disTreasure[itemId] and tab.disTreasure[itemId].produce == 2
        -- local isHadItemInTreasure = self._modelMgr:getModel("TreasureModel"):getTreasureById(itemId)
        -- local _,itemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
                    
        local isOTreasure = isDis --and not isHadItemInTreasure and itemCount < 2
        if isOTreasure then
            local nextFunc = nextFunc
            self._viewMgr:showDialog("global.GlobalShowTreasureDialog", {itemId = itemId, notLoadRes = true, callback = function() 
                nextFunc(index+1)
            end})
        else
            nextFunc(index+1)
        end
    end) 

end

function GlobalTreasureGetDialog:getMaskOpacity()
    return 230
end

return GlobalTreasureGetDialog