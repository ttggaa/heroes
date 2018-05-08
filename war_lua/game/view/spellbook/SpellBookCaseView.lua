--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-09-08 17:32:33
--
local SpellBookCaseView = class("SpellBookCaseView",BaseView)
function SpellBookCaseView:ctor(param)
    self.super.ctor(self)
    self._spbModel = self._modelMgr:getModel("SpellBooksModel")
    self._spbInfo = self._spbModel:getData()
    self._tp = param and param.tp 
    self._na = param and param.na
    self.fixMaxWidth = ADOPT_IPHONEX and 1136 or nil
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
end
function SpellBookCaseView:getAsyncRes( )
	return 
	{
		{"asset/ui/spellBook1.plist", "asset/ui/spellBook1.png"},
        {"asset/ui/spellBook.plist", "asset/ui/spellBook.png"}
	}
end

function SpellBookCaseView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo = true,titleTxt = "法术书柜"},nil,ADOPT_IPHONEX and self.fixMaxWidth or nil)
end
-- -- 第一次被加到父节点时候调用
-- function SpellBookCaseView:onBeforeAdd()

-- end
-- 初始化UI后会调用, 有需要请覆盖
function SpellBookCaseView:onInit()
	self._realBg = self:getUI("realBg")
	self._realBg:loadTexture("asset/bg/spellBook_bg.jpg")
	self._bg = self:getUI("bg")
	-- titleTxt,pos,hasTextBg,fontSize
	UIUtils:addFuncBtnName(self:getUI("bg.shopBtn"),"商店",nil,true)
	UIUtils:addFuncBtnName(self:getUI("bg.breakBtn"),"分解",nil,true)
    UIUtils:addFuncBtnName(self:getUI("bg.drawBtn"),"规则",nil,true)
    UIUtils:addFuncBtnName(self:getUI("bg.ruleBtn"),"魔法天赋",nil,true)
    self._ruleBtn = self:getUI("bg.ruleBtn")
    self._bookItem = self:getUI("bg.bookItem")
	self._bookItem:setSwallowTouches(false)
	local children = self._bookItem:getChildren()
	for k,v in pairs(children) do
		if v.setSwallowTouches then
			v:setSwallowTouches(false)
		end
	end

	self._orignData = clone(tab.skillBookBase) or {}
	self._tableData = self:filterData()
	self:addTableView()
	
	self:listenReflash("ItemModel", function( )
		self:reflashUI()
    end)
    self:listenReflash("SpellBooksModel", function( )
    	self:reflashUI()
    end)

    self:registerClickEventByName("bg.breakBtn",function() 
        self._viewMgr:showDialog("spellbook.SpellBookBreakView")
    end)
    
    self:registerClickEventByName("bg.drawBtn",function() 
        self._viewMgr:showDialog("spellbook.SpellBookRuleView",{title = "法术书规则",des = des or lang("SHOPSKILLBOOK_RULE2")})
        -- self._viewMgr:showView("skillCard.SkillCardTakeView")
    end)
    
    self:registerClickEventByName("bg.ruleBtn",function() 
        self._viewMgr:showDialog("spellbook.SkillTalentDialog",{callBack = function()
            self:updateTabRedPoint()
        end},true)
    end)

    self:registerClickEventByName("bg.shopBtn",function() 
        self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type = "skillbook"}, true, {}, function(result)
            self._viewMgr:showDialog("skillCard.SkillCardShopView",{},true)
        end)
    end)

    -- 选页签
    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, self:getUI("bg.btn_fire"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_water"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_air"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_solid"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_allV"))
        
    table.insert(self._tabEventTarget, self:getUI("bg.btn_sj"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_zj"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_big"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_bd"))
    -- table.insert(self._tabEventTarget, self:getUI("bg.btn_red"))
    table.insert(self._tabEventTarget, self:getUI("bg.btn_allH"))
    self:getUI("bg.btn_red"):setVisible(false)
    local names = {
        "SKILLBOOK_TIPS103",
        "SKILLBOOK_TIPS101",
        "SKILLBOOK_TIPS102",
        "SKILLBOOK_TIPS104",
        "SKILLBOOK_TIPS115",
        "SKILLBOOK_TIPS110",
        "SKILLBOOK_TIPS111",
        "SKILLBOOK_TIPS112",
        "SKILLBOOK_TIPS113",
        -- "SKILLBOOK_TIPS114",
        "SKILLBOOK_TIPS115",
    }
    for i,v in ipairs(self._tabEventTarget) do
        v:setTitleText(lang(names[i]))
        v:setScaleAnim(true)
    	self:registerClickEvent(v,function() 
    		self:tabButtonClick(i)
    	end)
    end
    -- 居中横向按钮
    local alignNodes = {}
    table.insert(alignNodes, self:getUI("bg.btn_allH"))
    table.insert(alignNodes, self:getUI("bg.btn_sj"))
    table.insert(alignNodes, self:getUI("bg.btn_zj"))
    table.insert(alignNodes, self:getUI("bg.btn_big"))
    table.insert(alignNodes, self:getUI("bg.btn_bd"))
    -- table.insert(alignNodes, self:getUI("bg.btn_red"))
    UIUtils:alignNodesToPos(alignNodes,390,5)
    self:tabButtonClick(self._tp or 10,true)
    self:tabButtonClick(self._na or 5,true)
    self:filterData()

    local fightLab = ccui.TextBMFont:create("0", UIUtils.bmfName_zhandouli_little)
    fightLab:setAnchorPoint(cc.p(1,0))
    fightLab:setPosition(0,12)
    fightLab:setScale(.5)
    self:getUI("bg.scorePanel"):addChild(fightLab,99)
    self._fightLab = fightLab

    local fightText = ccui.Text:create()
    fightText:setString("书柜战斗力")
    fightText:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    -- fightText:enableOutline(cc.c4b(0,0,0,255),1)
    fightText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    fightText:setFontName(UIUtils.ttfName)
    fightText:setFontSize(16)
    fightText:setAnchorPoint(0,0.5)
    fightText:setPosition(0, 6)
    self._fightText = fightText
    self:getUI("bg.scorePanel"):addChild(fightText, 1)
    --3.5版本 刻印战斗力展示
    local digFight = ccui.Text:create()
    digFight:setString("(刻印战斗力)")
    digFight:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    -- digFight:enableOutline(cc.c4b(0,0,0,255),1)
    digFight:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    digFight:setFontName(UIUtils.ttfName)
    digFight:setFontSize(16)
    digFight:setAnchorPoint(1,0.5)
    digFight:setPosition(355, 10)
    self._digFight = digFight
    self:getUI("bg.scorePanel"):addChild(digFight, 1)
    self:getUI("bg.scorePanel"):setOpacity(0)

    self._top_attribute_bg = self:getUI("top_attribute_bg")
    self._topInfo = {}
    self._topInfo._atkValue = self:getUI("top_attribute_bg.label_atk_value")
    self._topInfo._atkValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._topInfo._defValue = self:getUI("top_attribute_bg.label_def_value")
    self._topInfo._defValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._topInfo._intValue = self:getUI("top_attribute_bg.label_int_value")
    self._topInfo._intValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self._topInfo._ackValue = self:getUI("top_attribute_bg.label_ack_value")
    self._topInfo._ackValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    self:updateAttrInfo()

    self:checkNotice()

    -- 点击出英雄战斗力弹板
    -- 叹号 点击出 全部属性tip
    local heroScoreBtn = ccui.ImageView:create()
    heroScoreBtn:loadTexture("globalImage_info.png",1)
    heroScoreBtn:setScaleAnim(true)
    self:registerClickEvent(heroScoreBtn,function() 
        self._viewMgr:showDialog("spellbook.SpellCaseSlotView",{})
    end)
    heroScoreBtn:setAnchorPoint(0.5,0.5)
    heroScoreBtn:setPosition(760,533)
    heroScoreBtn:setScale(0.8)
    self._heroScoreBtn = heroScoreBtn
    self:getUI("bg"):addChild(heroScoreBtn,99)
    self:reflashScore()

    self:updateTabRedPoint()
end

function SpellBookCaseView:checkNotice( )
    self._modelMgr:getModel("SpellBooksModel"):checkNotice()
    for i=1,5 do
        local tabBtn = self._tabEventTarget[i]
        local haveNotice = self._spbModel:isTabHaveNotice(i)
        self:addDot(tabBtn,not haveNotice)
    end
end

function SpellBookCaseView:updateTabRedPoint()
    local red = self._skillTalentModel:checkIsCanActOrUp()
    UIUtils.addRedPoint(self._ruleBtn,red,cc.p(65,65))
end

function SpellBookCaseView:addDot( node,isRemove )
    local dot = node._noticeTip
    if not isRemove then
       if not dot then
            dot = ccui.ImageView:create()
            dot:loadTexture("globalImageUI_bag_keyihecheng.png", 1)
            dot:setPosition(0,node:getContentSize().height)
            node:addChild(dot,99)
            node._noticeTip = dot
        end
        dot:setVisible(true)
    else
        if dot then
            dot:setVisible(false)
        end
    end
    return dot
end

function SpellBookCaseView:isCanUp( bookId )
    local bookD = tab.skillBookBase[tonumber(bookId) or 0]
    if not bookD then return false end
    local spellInfo = self._spbInfo[tostring(bookId)]
    local level = spellInfo and spellInfo.l or 0
    local isMaxLvl = level >= table.nums(bookD.quality)-1
    local maxLevel = #bookD.skillbook_exp
    local needNum = bookD.skillbook_exp[math.min(maxLevel,level+1)] or 0
    local itemId = bookD.goodsId 
    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
    if not isMaxLvl and haveNum >= needNum then
        if level > 0 then
            return 1
        else
            return 0
        end
    end 
    return -1
end

function SpellBookCaseView:filterData( )
	local tp,na = self._hIdx,self._vIdx
	
	local tableData = {}
	for k,v in pairs(self._orignData) do
		if (v.skillQuality == tp or tp == 5) and (v.nature == na or na == 5) and v.show == 1 then
			table.insert(tableData,v)
		end
	end
    table.sort(tableData,function( a,b )

        local aCanUp = self:isCanUp(a.id) 
        local bCanUp = self:isCanUp(b.id)
        if aCanUp ~= bCanUp then
            return aCanUp > bCanUp
        else
            local alvl = self._spbInfo[tostring(a.id)] ~= nil
            local blvl = self._spbInfo[tostring(b.id)] ~= nil
            if alvl ~= blvl then
                return alvl 
            else
                local aq = a.skillQuality 
                local bq = b.skillQuality
                if aq ~= bq then
                    return aq>bq
                else
                    local aOrder = a.order 
                    local bOrder = b.order 
                    if aOrder ~= bOrder then
                        return aOrder < bOrder 
                    else
                        return a.id < b.id 
                    end
                end
            end  
        end

    end)
	self._tableData = tableData 
	if self._tableView then
		self._tableView:reloadData()
	end
	return tableData
end

-- 第一次进入调用, 有需要请覆盖
function SpellBookCaseView:onShow()
    SpellBookCaseView.super.onShow(self)
    self:filterData()
    self:reflashUI()
    self:updateRealVisible(true)
    if not tolua.isnull(self._upDialog) then
        self._upDialog:onShow()
        self._upDialog:reflashUI()
    end
end

function SpellBookCaseView:onHide( )
    self._viewMgr:disableScreenWidthBar()
end
function SpellBookCaseView:onTop()
    self._viewMgr:enableScreenWidthBar()
end
function SpellBookCaseView:onComplete()
    self._viewMgr:enableScreenWidthBar()
end
function SpellBookCaseView:onDestroy( )
    self._viewMgr:disableScreenWidthBar()
    SpellBookCaseView.super.onDestroy(self)
end

-- 接收自定义消息
function SpellBookCaseView:reflashUI(data)
    self._spbInfo = self._spbModel:getData()
    self._tableView:reloadData()
    if self._tableOffset then
        local minOffset = 440 - self._tableView:getContainer():getContentSize().height
        self._tableOffset.y = math.max(self._tableOffset.y, minOffset)
        self._tableOffset.y = math.min(self._tableOffset.y, 0)
        self._tableView:setContentOffset(self._tableOffset)
    end
    self:reflashScore()
    self:updateAttrInfo()
    self:checkNotice()
end

function SpellBookCaseView:tabButtonClick(idx,noAudio)
	sender = self._tabEventTarget[idx]
    if sender == nil then 
        return 
    end
    self._tableOffset = nil
    print("sender:getName()",sender:getName())
    local name = sender:getName()
    if not noAudio then 
        audioMgr:playSound("Tab")
        -- self._spbModel:cancelNotice(idx)
        -- self:addDot(sender,true)
    end
    local beginIdx = 1
    local endIdx = 5
    if idx > 5 then
    	beginIdx = 6
		endIdx = 10
	    self._hIdx = idx-5
	else
		self._vIdx = idx
    end
    for i=beginIdx,endIdx do
    	local btn = self._tabEventTarget[i]
    	if i ~= idx then
    		local text = btn:getTitleRenderer()
            btn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
            text:disableEffect()
            -- btn:setScaleAnim(false)
            self:setTabStatus(btn, false,i)
    	end
    end
    local text = sender:getTitleRenderer()
    text:disableEffect()
    -- text:setPositionX(85)
    sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    self:setTabStatus(sender, true,idx)
    if not noAudio then
        self:filterData()
    end
end

function SpellBookCaseView:setTabStatus( tabBtn,isSelect,idx )
	tabBtn:setBright(not isSelect)
	tabBtn:setEnabled(not isSelect)
	local colorTab = {
		[1] = {cc.c3b(255, 250, 224),ccc3(201, 177, 151)},
		[2] = {cc.c3b(255, 250, 224),ccc3(142, 142, 142)},
	}
	local colorCur = colorTab[math.ceil(idx/5)]
    if isSelect then
        -- tabBtn:loadTextureNormal(isV and "globalBtnUI4_page1_p.png" or "globalBtnUI4_page1_p.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(colorCur[1])
        text:disableEffect()
    else
        -- tabBtn:loadTextureNormal(isV and "globalBtnUI4_page1_n.png" or "globalBtnUI4_page1_n.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(colorCur[2])
        text:disableEffect()
    end
    -- tabBtn:setEnabled(not isSelect)
end

function SpellBookCaseView:addTableView( )
    local tableView = cc.TableView:create(cc.size(800, 440))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(5,0)
    tableView:setDelegate()
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setBounceable(true)
    self._bg:addChild(tableView,7)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidScroll(view)
    end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(function( view )
        return self:scrollViewDidZoom(view)
    end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(function ( table,cell )
        return self:tableCellTouched(table,cell)
    end,cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(function( table,index )
        return self:cellSizeForTable(table,index)
    end,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(function ( table,index )
        return self:tableCellAtIndex(table,index)
    end,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(function ( table )
        return self:numberOfCellsInTableView(table)
    end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:reloadData()
    self._tableView = tableView
end

function SpellBookCaseView:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()

    if self._inScrolling then
        self._tableOffset = view:getContentOffset()
    end
end

function SpellBookCaseView:scrollViewDidZoom(view)
    -- print("scrollViewDidZoom")
end

function SpellBookCaseView:tableCellTouched(table,cell)
    print("cell touched at index: " .. cell:getIdx())
end

function SpellBookCaseView:cellSizeForTable(table,idx) 
    return 164,800
end

function SpellBookCaseView:tableCellAtIndex(table, idx)
    local strValue = string.format("%d",idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local split = cell:getChildByName("split")
    if not split then
    	split = ccui.ImageView:create()
    	split:loadTexture("spellBook_splite.png",1)
    	split:setName("split")
    	split:setAnchorPoint(1,.5)
    	split:setPosition(780,0)

    	local splitL = ccui.ImageView:create()
    	splitL:loadTexture("spellBook_splite.png",1)
    	splitL:setAnchorPoint(0,0)
    	splitL:setScale(-1,1)
    	splitL:setPosition(1,0)

    	split:addChild(splitL)

    	cell:addChild(split)
    end
    self:updateCell(cell,idx)
    return cell
end

function SpellBookCaseView:numberOfCellsInTableView(tableView)
	local tableNum = table.nums(self._tableData)
	local cellNum = math.ceil(tableNum/4)
    return cellNum
end

function SpellBookCaseView:updateCell( cell,idx )
	-- 数据
	local datas = {}
	local dataBegin = math.min(idx*4+1,table.nums(self._tableData))
	local dataEnd = math.min(idx*4+4,table.nums(self._tableData))
	for i=1,4 do
		local item = cell:getChildByName("item" .. i)
		if (idx*4+i) <= dataEnd then
			if not item then
				item = self._bookItem:clone()
				item:setName("item" .. i)
				item:setPosition((i-1)*186+25,6)
				cell:addChild(item)
			end
			item:setVisible(true)
			self:updateItem(item,self._tableData[dataBegin-1+i])
		else
			if item then 
				item:setVisible(false)
			end
		end
	end
end

function SpellBookCaseView:updateItem( oldItem,data )
	if not data then return end
	local item = oldItem or self._bookItem:clone()

	-- 法术书名字
	local itemBg = item:getChildByName("itemBg")
    itemBg:loadTexture("spellBook_itemBg" .. data.skillQuality .. ".png",1)
    local name = item:getChildByName("name")
    local tailStr = ""
    local headStr = ""
	-- if OS_IS_WINDOWS then
 --        --headStr = "\n"
	-- 	tailStr = "\n[" .. data.goodsId .. "/" .. data.id .. "]"
	-- end
	name:setString(headStr .. lang(data.name) .. tailStr)

	-- 法术书图片
	local skillBookImg = item:getChildByName("skillBookImg")
	local art = data.art 
	local sfc = cc.SpriteFrameCache:getInstance()
	if sfc:getSpriteFrameByName(art ..".jpg") then
		skillBookImg:loadTexture("" .. art ..".jpg", 1)
	else
		skillBookImg:loadTexture("" .. art ..".png", 1) 
	end
	skillBookImg:setScale(62/skillBookImg:getContentSize().height)

	-- 进度条和数量
	local num = item:getChildByName("num")
	local proBar = item:getChildByName("proBar")
    local lvl = item:getChildByName("lvl")

    local spellInfo = self._spbInfo[tostring(data.id)]
    local level = spellInfo and spellInfo.l or 0
    local isMaxLvl = level >= table.nums(data.quality)-1
    local maxLevel = #data.skillbook_exp
    local needNum = data.skillbook_exp[math.min(maxLevel,level+1)] or 0
    local itemId = data.goodsId 
    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)

    lvl:setString(level)
    proBar:setScaleX(isMaxLvl and 1 or math.min(1,haveNum/needNum))
    num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    num:setString(isMaxLvl and "MAX" or (haveNum .. "/" .. needNum))
    num:setColor(isMaxLvl and UIUtils.colorTable.ccUIBaseColor2 or UIUtils.colorTable.ccUIBaseColor1)
    local upImg = item:getChildByName("upImg")
    upImg:setVisible(false)
    local activeMc = item:getChildByName("actMc")
    if activeMc then
        activeMc:setVisible(false)
    end
    -- 锁状态
    local lock = item:getChildByName("lock")
    lock:setVisible(level == 0)
    if level == 0 then
        skillBookImg:setBrightness(-80)
    else
        skillBookImg:setBrightness(-0)
    end
	if haveNum >= needNum and not isMaxLvl then
        if level < 1 then
            upImg:loadTexture("skillBook_canActive.png",1)
        else
            upImg:loadTexture("skillBook_canUp.png",1)
        end
        if not activeMc then
            activeMc = mcMgr:createViewMC("kejinjie_skillbookfashushu-HD", true, false, function (_, sender)  end)
            activeMc:setName("actMc")
            activeMc:setPosition(85, 14)
            item:addChild(activeMc,10)
        end
        activeMc:setVisible(true)
        activeMc:gotoAndPlay(0)
        upImg:setVisible(true)
        local action = upImg:getActionByTag(101)
        if not action then
            action = cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.ScaleTo:create(0.5,0.9),
                    cc.ScaleTo:create(0.5,1)
                    -- cc.MoveTo:create(0.5,cc.p(82,28)),
                    -- cc.MoveTo:create(0.5,cc.p(82,30))
                )
            )
            action:setTag(101)
            upImg:runAction(action)
        end
    else
        if activeMc then
            activeMc:setVisible(false)
        end
	end
	self:registerTouchEvent(item,nil,nil,function() 
		-- dump(self._spbModel:getData())
        if not self._inScrolling then
    		self._upDialog = self._viewMgr:showDialog("spellbook.SpellBookUpDialog",{spellId = data.id})
        else
            self._inScrolling = false
        end
	end,nil)
	item:setSwallowTouches(false)

    -- 角标
    local tagBg = item:getChildByName("tagBg")
    local tagLab = item:getChildByName("tagLab")
    local tpDesMap = {"神剑","中级","大招","被动","万能"}
    local hueMap = {0,65,180 ,-50,-100}
    tagBg:setHue(hueMap[data.type] or 0)
    tagLab:setString(tpDesMap[data.type] or "")
    tagLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- 是否装备到英雄身上
    local hero = spellInfo and tonumber(spellInfo.b)
    local heroIcon = item._heroIcon
    if hero and hero ~= 0 then
        local heroData = clone(tab.hero[hero])
        if not heroIcon then
            heroIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
            --heroIcon:setAnchorPoint(cc.p(0, 0))
            heroIcon:setPosition(30,40)
            heroIcon:setScale(0.3)
            item:addChild(heroIcon,20)
            item._heroIcon = heroIcon
        end
        heroIcon:setVisible(true)
        IconUtils:updateHeroIconByView(heroIcon,{sysHeroData = heroData})
        heroIcon:getChildByName("starBg"):setVisible(false)
    else
        if heroIcon then 
            heroIcon:setVisible(false)
        end
    end
	return item
end

function SpellBookCaseView:reflashScore( )
    local allScore = self._spbModel:caculateFightNum() or 0
    self._fightLab:setString("" .. allScore)
    UIUtils:center2Widget(self._fightText,self._fightLab,0,5)
    local heroSlotScore = self._spbModel:sumHeroSlotScore()
    self._digFight:setString("(刻印:英雄战斗力+".. heroSlotScore ..")")
    self._digFight:setVisible(heroSlotScore ~= 0)
    self._heroScoreBtn:setVisible(heroSlotScore ~= 0)
end

function SpellBookCaseView:sendActiveMsg( spellId )
	self._serverMgr:sendMsg("HeroServer","combineSpellBook",{sid = spellId}, true, {}, function(result, success)
    end)
end

function SpellBookCaseView:updateAttrInfo( )
    local spellAttrs = self._modelMgr:getModel("SpellBooksModel"):getSpellBookAttrs() or {}
    dump(spellAttrs,"spellAttrs.........")
    self._topInfo._atkValue:setString(string.format("%.1f", spellAttrs.atk or 0 ))
    self._topInfo._defValue:setString(string.format("%.1f", spellAttrs.def or 0 ))
    self._topInfo._intValue:setString(string.format("%.1f", spellAttrs.int or 0 ))
    self._topInfo._ackValue:setString(string.format("%.1f", spellAttrs.ack or 0 ))
end

-- function SpellBookCaseView:sendUpMsg( spellId )
-- 	self._serverMgr:sendMsg("HeroServer","upLevelSpellBook",{sid = spellId}, true, {}, function(result, success)
--     end)
-- end

return SpellBookCaseView