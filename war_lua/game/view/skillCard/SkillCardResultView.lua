--[[
    Filename:    SkillCardResultView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-09-7 14:39:47
    Description: File description
--]]

local iconIdMap = IconUtils.iconIdMap
local itemEffect = {
    "wupinguang_itemeffectcollection",                -- 转光
    "wupinkuangxingxing_itemeffectcollection",        -- 星星
    "tongyongdibansaoguang_itemeffectcollection",     -- 扫光
    "diguang_itemeffectcollection",                   -- 底光
}

local expBottle = {
    [30201] = true,
    [30202] = true,
    [30203] = true,
}

local costImage = {
    "globalImageUI_diamond.png",
    "skillCard_icon.png",
    "globalImageUI_luckyCoin.png",
}

local SkillCardResultView = class("SkillCardResultView",BasePopView)

function SkillCardResultView:ctor(data)
    SkillCardResultView.super.ctor(self)
    self.callback = data.callback 
    --抽取的次数 
    self.buyNum = data.buyNum 
    --是否优先使用道具抽
    self._isFirstUserItem = data.isFirstUserItem 
    self._isUseLuck = self._modelMgr:getModel("UserModel"):drawUseLuckyCoin()

    self._singleToolCost    = 1
	self._tenToolCost       = 10
	self._singleGemCost     = tab:Setting("SKILLBOOK_DRAW_COST1").value
	self._tenGemCost        = tab:Setting("SKILLBOOK_DRAW_COST2").value
	self._toolCostId        = tab:Setting("SKILLBOOK_DRAW_TOOL").value
    self._SpellBooksModel  = self._modelMgr:getModel("SpellBooksModel")
    self._cachData = self._SpellBooksModel:getCacheTab()

	--默认可以使用的抽卡类型 1道具，2钻石
	self._canUseType = 2 
end

function SkillCardResultView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function SkillCardResultView:onInit()
    self._bg = self:getUI("bg")
    self._bg1 = self:getUI("bg.bg1")
    self.bgWidth,self.bgHeight = self._bg:getContentSize().width,self._bg:getContentSize().height
    self._okBtn = self:getUI("bg.closeBtn")
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setSwallowTouches(false)

    -- 动画相关
    self._itemNames = {}
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setOpacity(0)

    self._bg1:setOpacity(0)
    local children1 = self._bg1:getChildren()
    for k,v in pairs(children1) do
        v:setOpacity(0)
    end
    local mcMgr = MovieClipManager:getInstance()
    -- mcMgr:loadRes("intancenopen", function ()
        
    audioMgr:playSound("ItemGain_1")
    -- end,RGBA8888)
    -- item 容器
    self._itemTable = {}
    -- -- 兵团转换的兵团背景光效
    self._isChangeMc = {}

    -- 再来！！！！
    self._backBtn = self:getUI("bg.backBtn")
    -- 再来十次panel
    self._tenAginBtn = self:getUI("bg.tenAginBtn")
    self._tenBtn = self:getUI("bg.tenAginBtn.tenAginBtn")

    -- self._timeLabel = self:getUI("bg.onceAginBtn.timeLabel")
    --更新倒计时
    -- self:reflashTimeLabel()
    -- self:refreshTime()


    -- self._onceAginBtn:setOpacity(0)
    -- self._onceAginBtn:setCascadeOpacityEnabled(true)
    self._tenAginBtn:setOpacity(0)
    self._tenAginBtn:setCascadeOpacityEnabled(true)
    self._backBtn:setOpacity(0)
    self._backBtn:setCascadeOpacityEnabled(true)

    self._hadClose = false
    self:registerClickEvent(self._backBtn, function()
        if  self._hadClose == false then
            self._hadClose = true
            if self.callback and type(self.callback) == "function" then
                self.callback(self._callbackAwards)
            end
            self:close(true)
            UIUtils:reloadLuaFile("skillCard.SkillCardResultView")
        end
    end)

    self:registerClickEvent(self._tenBtn, function()
        self:buyTenAginFunc()
    end)
    
    self._tenAginBtn:setVisible(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._backBtn:setVisible(false)
    self._backBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)

    --注释再来一次功能  hgf - 16.09.07
    -- self:initOnceAginBtn()
    self:initTenAginBtn()

end
function SkillCardResultView:animBegin(callback)
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height

    self._bgW,self._bgH = bgW,bgH
    self:addPopViewTitleAnim(self._bg, "gongxihuode_huodetitleanim", self._bg:getContentSize().width/2, 480)
    ScheduleMgr:delayCall(700, self, function( )
        if callback and self._bg then
            callback()
            self._bg1:runAction(cc.FadeIn:create(0.2))
            local children1 = self._bg1:getChildren()
            for k,v in pairs(children1) do
                if v:getName() ~= "touchLab" then
                    v:runAction(cc.FadeIn:create(0.2))
                end
            end
            if self.buyNum == 10 then
                local mcWupintexiao = mcMgr:createViewMC("wupintexiao_flashcardanim", true, false, function (_, sender)
                    -- sender:removeFromParent()
                end,RGBA8888)
                self._mcWupintexiao = mcWupintexiao
                -- mcWupintexiao:setPlaySpeed(0.8)
                mcWupintexiao:setPosition(cc.p(bgW/2,bgH/2+30))
                self._bg1:addChild(mcWupintexiao,99)
            end
        end
    end)
end

-- 接收自定义消息
function SkillCardResultView:reflashUI(data)
    local gifts = data.awards
    self._callbackAwards = gifts or self._callbackAwards
    -- dump(gifts)
    -- for k,v in pairs(gifts) do
    --     if v.type and ( v.type ~= "tool" or expBottle[v.typeId] ) then
    --         gifts[k] = nil
    --     end
    -- end
    self._gifts = gifts
    if gifts and #gifts == 0 then
        gifts = {}
        table.insert(gifts,data)
    end
    local blank = 25
    local colNum = 5
    local itemHeight,itemWidth = 110,96
    
    local maxHeight = (itemHeight+blank) * math.ceil( #gifts / colNum)
    local x = 3
    local y = 0--maxHeight - itemHeight

    local offsetX,offsetY = 0,0
    if #gifts <= colNum then
        offsetX = (self.bgWidth-#gifts*(itemWidth+blank))/2+itemWidth/2-10
        offsetY = self.bgHeight/2-30 -- itemHeight/2+30
        -- offsetY = self.bgHeight/2 - maxHeight/2 + itemHeight/2
    else
        offsetX = (self.bgWidth-colNum*(itemWidth+blank))/2+itemWidth/2
        -- offsetY = self.bgHeight/2-itemHeight+30
        offsetY = self.bgHeight/2 + maxHeight/2 -  itemHeight + 15
    end
    x = offsetX+20
    y = y+offsetY+3--itemHeight/2
    -- 轮次添加物品特效
    local createItemDeque
    local xFactor = 1
    local createNextItemFunc = function( index,small )
        createItemDeque(index,small)
    end
    createItemDeque = function( index,small )
        local itemData = gifts[index]
        if not itemData then return end
        local itemId = itemData.typeId
        -- 如果是再次购买，不加动画，兵团转碎片不加展示卡片效果
        local callFunc = function()   end
        if not self._isAgain then
            callFunc = function( )                
                if itemData.isChange then
                    local mcSplash = mcMgr:createViewMC("shanguang_flashcardanim", true, false, function (_, sender)
                        sender:gotoAndPlay(80)
                    end)
                    mcSplash:setPosition(cc.p(self.bgWidth/2,self.bgHeight/2+30))
                    self._bg:addChild(mcSplash,2)

                    if itemData.isChange == 0 then
                        local teamId = tonumber(string.sub(tostring(itemId),2))
                        DialogUtils.showTeam({teamId = teamId,callback = function (  )
                            createNextItemFunc(index+1)
                        end})
                        
                    elseif itemData.isChange == 1 then
                        DialogUtils.showCard({itemId = itemId,changeNum = itemData.num,callback = function( )
                            createNextItemFunc(index+1)
                        end})
                    end
                else
                    audioMgr:playSound("ItemGain_2")
                    createNextItemFunc(index+1,0.8)
                end 
            end       
        end
        self:createItem(itemData, x, y, index-1,callFunc,small)
         x = x + xFactor*(itemWidth + blank)
        if index % colNum == 0 then 
            x =  offsetX+20
            -- x = x - xFactor*(itemWidth + blank)
            -- xFactor = -1
            y = y - blank - itemHeight - 24 --name高度
        end
        if self._isAgain then
            createNextItemFunc(index+1,0.8)
        end

    end

    local bg1Height = 200
    local maxHeight = self._bg1:getContentSize().height + 12
    if not self._isAgain then
        self._bg1:setOpacity(0)
        self:animBegin(function( )
            self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
            -- self._bg1:setAnchorPoint(0.5,1)
            -- self._bg1:setPositionY(MAX_SCREEN_HEIGHT-160)
            self._bg1:setOpacity(255)
            local sizeSchedule
            local step = 0.5
            local stepConst = 30
            -- self._bg:setPositionY(self._bg:getPositionY()+self._bg:)
            local sizeSchedule
            sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
                stepConst = stepConst-step
                if stepConst < 1 then 
                    stepConst = 1
                end
                bg1Height = bg1Height+stepConst
                if bg1Height < maxHeight then
                    self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,bg1Height))
                else
                    self._bg1:setContentSize(cc.size(self._bg1:getContentSize().width,maxHeight))
                    self._bg1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                    ScheduleMgr:unregSchedule(sizeSchedule)
                    self:addDecorateCorner()
                    
                end
            end)
            -- ScheduleMgr:delayCall(200, self, function( )
                -- showItems(1)
                createItemDeque(1,0.9)
            -- end)
        end)
    else
        createItemDeque(1,0.9)
    end
end

function SkillCardResultView:createItem( data,x,y,index,callfunc,scale )
    -- dump(data)
    local itemData
    local itemType = data[1] or data.type 
    local itemId = data[2] or data.typeId
    local itemNum = data[3] or data.num
    if itemType ~= "tool" then
        itemId = iconIdMap[itemType]
    end

    local scaleOffset = 0
    if data.isChange == 0 then
        scale = 1
        scaleOffset = 6
    else
        scale = 0.9
    end
    itemData = tab:Tool(itemId)
    if not itemData then
        print("itemId",itemId,"道具id不存在")
        
    end
    -- if itemData == nil then
    --     itemData = tab:Team(itemId)
    -- end

    local bookID = self._cachData[itemId]
    
    local bookData = tab:SkillBookBase(bookID)
    if not bookData then
        print("itemId",itemId,"此道具对应的法术id不存在")
        -- bookData = tab:SkillBookBase(202)
    end

    local item 

    if data.isChange == 0 then
        local teamId  = itemId-3000
        local teamD = tab:Team(teamId)
        itemData = teamD
        item = IconUtils:createSysTeamIconById({sysTeamData = teamD })
        local iconColor = item:getChildByName("iconColor")
        iconColor:loadTexture("globalImageUI_squality_jin.png",1)
    else
        item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,itemData = itemData,effect = false, showSpecailSkillBookTip =true})
    	if bookData.skillBook_art == 4 then
    		local iconColor = item:getChildByName("iconColor")
        	iconColor:loadTexture("globalImageUI_squality_jin.png",1)
    	end
    end

    item:setScaleAnim(false)
    item:setSwallowTouches(true)
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:setPosition(cc.p(x,y+50+scaleOffset))
    item:setVisible(true)
    if itemData and itemData.name then
        local itemName = ccui.Text:create()
        itemName:setFontName(UIUtils.ttfName)
        itemName:setTextAreaSize(cc.size(120,65))
        itemName:setTextHorizontalAlignment(1)
        itemName:setTextVerticalAlignment(0)
        itemName:setFontSize(20)
        itemName:setString(lang(tostring(itemData.name)))

        --字体颜色
        if data.isChange == 0 then
            itemName:setColor(cc.c3b(240, 240, 0))
        else
            itemName:setColor(UIUtils.colorTable["ccColorQuality" .. (itemData.color or 1)])
        end
        itemName:enableOutline(cc.c4b(0,0,0,255),1)
        itemName:setAnchorPoint(cc.p(0.5,1))
        itemName:setPosition(cc.p(x,y)) --cc.pAdd(cc.p(x,y),cc.p(item:getContentSize().width/2,-4)))
        self._bg:addChild(itemName,2)
        itemName:setVisible(false)
        table.insert(self._itemNames,itemName)

        --名字下面数量显示
        local des,isEnough = self._SpellBooksModel:getSkillBookInfoById(itemId)
        if des then
            local haveNum = ccui.Text:create()
            haveNum:setFontName(UIUtils.ttfName)
            haveNum:setTextAreaSize(cc.size(100,65))
            haveNum:setTextHorizontalAlignment(1)
            haveNum:setTextVerticalAlignment(0)
            haveNum:setFontSize(20)

            haveNum:setString(des)
            if isEnough then
                haveNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
            else
                haveNum:setColor(UIUtils.colorTable.ccUIBasePromptColor)
            end
            haveNum:setAnchorPoint(cc.p(0.5, 1))
            haveNum:setPosition(cc.p(x, y - 22))
            self._bg:addChild(haveNum, 3)
            haveNum:setVisible(false)
            table.insert(self._itemNames,haveNum)
        end
    end

    table.insert(self._itemTable,item)
    self._bg:addChild(item,2)

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
    local bgMc = item:getChildByName("bgMc")
    if bgMc then
        bgMc:setVisible(false)
    end
    
    ScheduleMgr:delayCall(100, self, function( )
        if not itemData or not data or not item then return end
        -- 加背景光效
        -- local bgMcName 
        -- if itemData.color == 5 then
        --     bgMcName = "chengguangquan_flashcardanim"
        -- elseif itemData.color == 4 then
        --     bgMcName = "ziguangquan_flashcardanim"
        -- end
        -- local bgMcName = itemEffect[bookData.skillBook_art]
        -- if bgMcName then
        --     local mc = mcMgr:createViewMC(bgMcName, false, true, function (_, sender)
        --         sender:removeFromParent()
        --         -- sender:gotoAndPlay(0)
        --     end)

        --     mc:setPosition(cc.p(x,y+50))
        --     mc:setPlaySpeed(0.5)
        --     self._bg:addChild(mc,9)
        -- end

        local effectName = itemEffect[bookData.skillBook_art]
        if effectName == "huodewupindiguang_itemeffectcollection" then
            local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
                sender:gotoAndPlay(0)
            end,RGBA8888) 
            mc:setPosition(x,y+50)      
            mc:setScale(1.1)
            self._bg:addChild(mc) 
            table.insert(self._isChangeMc,mc)
        else
            local mc = IconUtils:addEffectByName({effectName},item)
            mc:setPosition(0 , 0)
            -- mc:setScale(1.16, 1.15)
            item:addChild(mc, 20)
        end


        -- if data.isChange then    
        --     local mc = mcMgr:createViewMC("huodewupindiguang_itemeffectcollection", true, false, function (_, sender)
        --         sender:gotoAndPlay(0)
        --     end,RGBA8888) 
        --     mc:setPosition(x,y+50)      
        --     mc:setScale(1.1)
        --     self._bg:addChild(mc) 
            

        --     table.insert(self._isChangeMc,mc)
        --     if data.isChange == 0 then 
        --         local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection",
        --                                           "tongyongdibansaoguang_itemeffectcollection",
        --                                           "wupinkuangxingxing_itemeffectcollection"},iconColor)
        --         -- mc:setPosition(-5 ,  - 6) -- effectParent
        --         -- mc:setScale(1.1, 1.1)
        --         item:addChild(mc, 3)
        --     elseif data.isChange == 1 then -- 转化碎片也加扫光
        --         local mc = IconUtils:addEffectByName({"wupinguang_itemeffectcollection"},item)
        --         -- mc:setPosition(item:getContentSize().width * 0.5 , item:getContentSize().height * 0.5 - 2)
        --         -- mc:setScale(1.16, 1.15)
        --         item:addChild(mc, 20)
        --     end
                      
        -- end
        if bgMc then
            bgMc:setVisible(true)
        end
        if not self._isAgain then
            item:setScale(2)
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.1),cc.ScaleTo:create(0.1,(scale or 1)*0.9)),cc.ScaleTo:create(0.3,scale),cc.CallFunc:create(function( )
                item:setScaleAnim(true)
            end)))
        else
            item:setScale(scale)
            item:setScaleAnim(true)
            item:setOpacity(255)
        end
        -- ScheduleMgr:delayCall(400, self, function( )
        if callfunc then
            callfunc()
        end
        -- end)
        local children = item:getChildren()
        for k,v in pairs(children) do
                -- print("v:getName",v:getName() ~= "bgMc",v:getName())
            if v:getName() == "numLab" then
                v:setVisible(true)
            end
            if v:getName() ~= "bgMc" then
                v:runAction(cc.FadeIn:create(0.2))
            end
        end
        if index == #self._gifts-1 or #self._gifts == 1 then
            for k,v in pairs(self._itemNames) do
                v:setVisible(true)
            end
            ScheduleMgr:delayCall(800, self, function( )
                if tolua.isnull(self._touchLab) or tolua.isnull(self._tenAginBtn) then return end

                if 10 == self.buyNum then
                    self._tenAginBtn:setVisible(true)
                    self._tenAginBtn:runAction(cc.FadeIn:create(0.1)) 

                    self._backBtn:setVisible(true)
                    self._backBtn:runAction(cc.FadeIn:create(0.1))                     
                else
                    self._touchLab:setVisible(true) 
                    self._touchLab:runAction(cc.FadeIn:create(0.2))                   
                end                         
            end)
            ScheduleMgr:delayCall(1000, self, function( )
                if tolua.isnull(self._touchLab) or tolua.isnull(self._tenAginBtn) then return end
               
                -- 按钮可点击
                if 10 == self.buyNum then
                    self._tenBtn:setTouchEnabled(true)
                    self._tenAginBtn:setTouchEnabled(true)
                    self._backBtn:setTouchEnabled(true)
                else
                    self:registerClickEventByName("closePanel", function()                       
                        if  self._hadClose == false then
                            self._hadClose = true
                            if self.callback and type(self.callback) == "function" then
                                self.callback()
                            end
                            self:close(true)
                            UIUtils:reloadLuaFile("skillCard.SkillCardResultView")
                        end
                    end)

                    self:registerClickEventByName("bg.bg1", function()
                        if self._hadClose == false then
                            self._hadClose = true
                            if self.callback and type(self.callback) == "function" then
                                self.callback()
                            end
                            self:close(true)
                            UIUtils:reloadLuaFile("skillCard.SkillCardResultView")
                        end
                    end)

                    self:registerClickEventByName("bg", function()
                        if self._hadClose == false then
                            self._hadClose = true
                            if self.callback and type(self.callback) == "function" then
                                self.callback()
                            end
                            self:close(true)
                            UIUtils:reloadLuaFile("skillCard.SkillCardResultView")
                        end
                    end)
                end             
            end)
            if not tolua.isnull(self._mcWupintexiao) then
                self._mcWupintexiao:removeFromParent()
            end
        end
    end)

end



function SkillCardResultView:initTenAginBtn()
    self._costImg = self:getUI("bg.tenAginBtn.costImg")
    self._costValue = self:getUI("bg.tenAginBtn.costValue")
    
    local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._toolCostId)
    if toolHaveNum < 10 or not self._isFirstUserItem then
    	self._canUseType = 2
        local costNum = 0
        if self._isUseLuck then
            costNum = self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0
            self._costImg:loadTexture(costImage[3],1)
        else
            costNum = self._modelMgr:getModel("UserModel"):getData().gem or 0
            self._costImg:loadTexture(costImage[1],1)
        end

        if costNum < self._tenGemCost then
            self._costValue:setColor(cc.c4b(255, 23, 23, 255))
        else
            self._costValue:setColor(cc.c4b(0, 255, 0, 255))
        end
        self._costValue:setString(self._tenGemCost)
        self._costImg:setScale(0.64)
    else
    	self._canUseType = 1
        self._costImg:loadTexture(costImage[2],1)
        self._costValue:setString(toolHaveNum .. "/10")
        self._costImg:setScale(0.34)
    end
end

function SkillCardResultView:buyTenAginFunc()
	local cost = self._tenGemCost
    self:buyItemByGem(cost,10)
end

function SkillCardResultView:buyItemByTool(cost,num)
    -- body
    local ToolSingle = tab:Setting("G_DRAWCOST_TOOL_SINGLE")
    local toolId = tonumber(ToolSingle["value"][2])
    local item = self._modelMgr:getModel("ItemModel")
    local idata,icount = item:getItemsById(toolId)

    self._backBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)

    if icount >= cost or (cost == 1 and self._isToolFree) then
        -- print("======================展示再次购买的icon=========")

        self._backBtn:runAction(cc.FadeOut:create(0.1))
        self._tenAginBtn:runAction(cc.FadeOut:create(0.1))

        self._serverMgr:sendMsg("TeamServer", "drawAward", {typeId = 1, num = num}, true, {}, function(result) 
            audioMgr:playSound("Draw")
            -- self:lock()

            --清楚之前的item显示
            for k,v in pairs(self._itemTable) do
                v:removeFromParent()
                -- v = nil
            end
            for k,v in pairs(self._itemNames) do
                v:removeFromParent()
                -- v = nil
            end
            -- local bgMc = self._bg:getChildByFullName("bgMc")
            -- bgMc:setVisible(false)
            -- bgMc:removeFromParent()
            for k,v in pairs(self._isChangeMc) do
                -- print("====================self._isChangeMc======")
                v:removeFromParent()
                -- v = nil
            end
            self._itemTable = {}
            self._itemNames = {}
            self._isChangeMc = {}

            ScheduleMgr:delayCall(800, self, function( )
                -- self:unlock()
                -- 展示再次购买的icon
                -- function
                -- print("======================展示再次购买的icon=========")
                self:showItemAgin(result)
                -- self:initOnceAginBtn()
                self:initTenAginBtn()
            end)
        end)
    else
        self._viewMgr:showTip("道具不足!")
        self._backBtn:setTouchEnabled(true)
        self._tenAginBtn:setTouchEnabled(true)
        self._tenBtn:setTouchEnabled(true)
    end
end

function SkillCardResultView:buyItemByGem(cost,num)
    local playerData = self._modelMgr:getModel("UserModel"):getData()
    local gem = playerData.gem

    local costNum, des = 0, ""
    if self._isUseLuck then
        costNum = self._modelMgr:getModel("UserModel"):getData().luckyCoin or 0
        des = "幸运币不足！"
    else
        costNum = self._modelMgr:getModel("UserModel"):getData().gem or 0
        des = "钻石不足！"
    end

    local _,toolHaveNum = self._modelMgr:getModel("ItemModel"):getItemsById(self._toolCostId)

    self._backBtn:setTouchEnabled(false)
    self._tenAginBtn:setTouchEnabled(false)
    self._tenBtn:setTouchEnabled(false)
    local param = {num = 10, type = self._canUseType}

    if toolHaveNum >= 10 and self._isFirstUserItem or costNum >= cost then       
        self._backBtn:runAction(cc.FadeOut:create(0.1))
        self._tenAginBtn:runAction(cc.FadeOut:create(0.1))
        self._serverMgr:sendMsg("HeroServer", "drawSpeelBook", param, true, {}, function(result) 
            audioMgr:playSound("Draw")
            for k,v in pairs(self._itemTable) do
                v:removeFromParent()
            end
            for k,v in pairs(self._itemNames) do
                v:removeFromParent()
            end
            for k,v in pairs(self._isChangeMc) do
                v:removeFromParent()
            end
            self._itemTable = {}
            self._itemNames = {}
            self._isChangeMc = {}
            ScheduleMgr:delayCall(800, self, function( )
                self:showItemAgin({awards = result.rewards})
                self:initTenAginBtn()
            end)
        end)
    else
        self._viewMgr:showTip(des)
        self._backBtn:setTouchEnabled(true)
        self._tenAginBtn:setTouchEnabled(true)
        self._tenBtn:setTouchEnabled(true)
    end
end

function SkillCardResultView:showItemAgin(data)
    -- --更新用户钻石
    -- if data.d and data.d.drawAward then
    --     self._playerDayModel:updateDrawAward(data.d.drawAward)
    -- end
   
    -- if data.d and data.d.dayInfo then
    --     self._playerDayModel:updateDayInfo(data.d.dayInfo)
    -- end

    -- if data.d and data.d.items then
    --     local itemModel = self._modelMgr:getModel("ItemModel")
    --     itemModel:updateItems(data.d.items)
    --     data.d.items = nil
    -- end

    -- if data.d and data.d.teams then
    --     local teamModel = self._modelMgr:getModel("TeamModel")
    --     teamModel:updateTeamData(data.d.items)
    --     data.d.teams = nil
    -- end
    -- if data.d then
    --     local userModel = self._modelMgr:getModel("UserModel")
    --     userModel:updateUserData(data.d)
    -- end

    -- self:reflashTimeLabel()

    self._isAgain = true
    self:reflashUI(data)

end

function SkillCardResultView:dtor()
    iconIdMap = nil
    itemEffect = nil
    costImage = nil
    expBottle = nil
end

return SkillCardResultView