
--[[
    Filename:    SkillTalentDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-12-11 14:39:47
    Description: File description
--]]

local cc_size = cc.size
local SkillTalentDialog = class("SkillTalentDialog",BasePopView)

function SkillTalentDialog:ctor(param)
	SkillTalentDialog.super.ctor(self)
	self._userModel = self._modelMgr:getModel("UserModel")
    self._skillTalentModel = self._modelMgr:getModel("SkillTalentModel")
    self._spellBooksModel = self._modelMgr:getModel("SpellBooksModel")
    self._callback = param.callBack
    self._curTalentIndex = 1
    self._skillTalentModel:sortData()

    self:listenReflash("SkillTalentModel",self.onDataChange)
    self:listenReflash("SpellBooksModel",self.onDataChange)

    local his = SystemUtils.loadAccountLocalData("SKILL_TALENT_IN")
    if not his then
        SystemUtils.saveAccountLocalData("SKILL_TALENT_IN",1)
    end

    local time = SystemUtils.loadAccountLocalData("SKILL_TALENT_IN_TIME")
    local curTime = self._userModel:getCurServerTime()
    if not time or TimeUtils.checkIsOtherDay(time,curTime) then
        SystemUtils.saveAccountLocalData("SKILL_TALENT_IN_TIME",curTime)
    end
end

function SkillTalentDialog:getRegisterNames()
	return {
		{"topUnit","bg.topUnit"},
		{"bottomLeftUnit","bg.bottomLeftUnit"},
		{"bottomRightUnit","bg.bottomRightUnit"},
		{"itemTop","bg.itemTop"},
		{"skillDesPanel","bg.skillDesPanel"},
		{"closeBtn","bg.mainBg.closeBtn"},
		{"tableViewBg","bg.topUnit.tableViewBg"},
        {"Scorenum","bg.topUnit.num"},
        {"title","bg.mainBg.title"},

        {"scoreDes","bg.bottomLeftUnit.scoreDes"},
        {"score_num","bg.bottomLeftUnit.score_num"},
        {"image_choose","bg.bottomLeftUnit.middle.image_choose"},
        {"frame","bg.bottomLeftUnit.middle.frame"},
        {"level","bg.bottomLeftUnit.middle.level"},
        {"icon","bg.bottomLeftUnit.middle.icon"},
        {"iconBg","bg.bottomLeftUnit.middle.iconBg"},
        {"middle","bg.bottomLeftUnit.middle"},

        {"TalentName","bg.bottomRightUnit.TalentName"},
        {"talentLevel","bg.bottomRightUnit.talentLevel"},
        {"des","bg.bottomRightUnit.des"},
        {"costNum","bg.bottomRightUnit.costNum"},
        {"up","bg.bottomRightUnit.up"},
        {"active","bg.bottomRightUnit.active"},
        {"scrollview","bg.bottomRightUnit.scrollview"},
        {"max","bg.bottomRightUnit.max"},
        {"costImage","bg.bottomRightUnit.costImage"},

        {"touchLayer","touchLayer"},
        {"desTip","touchLayer.desTip"},
        {"notice","bg.bottomRightUnit.notice"},
}
end

--界面刷新
function SkillTalentDialog:onDataChange()
    local contentOff = self._tableView:getContentOffset()
    self._tableView:reloadData()
    self._tableView:setContentOffset(contentOff)

    self:updateBottomLeftUnit()
    self:updateBottomRightUnit()
end

--天赋升级
function SkillTalentDialog:onUpLevel()
    local talentData = self._skillTalentModel:getData()[self._curTalentIndex]
    local talentId = talentData.id
    local level = talentData.level
    local maxLevel = self._skillTalentModel:getTalentMaxLevelById(talentData.id)
    local costTabId = talentData.costsort
    local costTabData = tab:SkillBookTalentExp(level+1)
    local costData = costTabData["cost" .. costTabId]
    local costType,costNum = costData[1][1],costData[1][3]
    print("maxLevel",maxLevel)
    if level >= maxLevel then
        self._viewMgr:showTip(lang("SKILLBOOK_TIPS125"))
        return
    else
        local userHave = self._userModel:getData()[costType]
        if not userHave or userHave < costNum then
            self._viewMgr:showTip(lang("SKILLBOOK_TIPS124"))
            return
        end
    end
    local preScore = self._skillTalentModel:getTotalScore()
    self._serverMgr:sendMsg("SpTalentServer", "upSpTalent", {sid = talentId}, true, {}, function(result)
        print("升级成功")
        self._viewMgr:showDialog("spellbook.SkillTalentUpDialog",{id = talentId,oldLevel = level,callback = function()
            local curScore = self._skillTalentModel:getTotalScore()
            local addScore = curScore - preScore
            if addScore > 0 then
                local bg = self:getUI("bg")
                TeamUtils:setFightAnim(bg,{x=bg:getContentSize().width*0.5-70,y=bg:getContentSize().height*0.5,oldFight = 0,newFight=addScore})
            end
        end},true)
    end)
end

--天赋激活
function SkillTalentDialog:onActive()
    local talentData = self._skillTalentModel:getData()[self._curTalentIndex]
    local talentId = talentData.id
    if self._skillTalentModel:checkActiveCondition(talentId) == 1 then
        self._viewMgr:showTip(lang("SKILLBOOK_TIPS128"))
        return
    end
    local level = talentData.level
    local costTabData = tab:SkillBookTalentExp(level+1)
    local costTabId = talentData.costsort
    local costData = costTabData["cost" .. costTabId]
    local costType,costNum = costData[1][1],costData[1][3]
    local userHave = self._userModel:getData()[costType]
    if not userHave or userHave < costNum then
        self._viewMgr:showTip(lang("SKILLBOOK_TIPS129"))
        return
    end
    local preScore = self._skillTalentModel:getTotalScore()
    self._serverMgr:sendMsg("SpTalentServer", "activeSpTalent", {sid = talentId}, true, {}, function(result)
        print("激活成功")
        self._viewMgr:showDialog("spellbook.SkillTalentUpDialog",{id = talentId,oldLevel = 0,callback = function()
            local curScore = self._skillTalentModel:getTotalScore()
            local addScore = curScore - preScore
            if addScore > 0 then
                local bg = self:getUI("bg")
                TeamUtils:setFightAnim(bg,{x=bg:getContentSize().width*0.5-70,y=bg:getContentSize().height*0.5,oldFight = 0,newFight=addScore})
            end
        end},true)
    end)
end

function SkillTalentDialog:onInit()
	self:registerClickEvent(self._closeBtn,function()
        if self._callback then
            self._callback()
        end
		self:close()
		UIUtils:reloadLuaFile("spellbook.SkillTalentDialog")
    end)

    self:registerClickEvent(self._up, function()
        self:onUpLevel()
    end)

    self:registerClickEvent(self._active, function()
        self:onActive()
    end)

    -- tip
    self._desTip:getChildByFullName("tipDes"):setString(lang("SKILLBOOK_TIPS127"))
    self._desTip:setVisible(false)
    self:registerClickEvent(self._touchLayer,function() 
        if self._desTip:isVisible() then
            self._desTip:setVisible(false)
        end
    end)
    self._touchLayer:setSwallowTouches(false)
    self._touchLayer:setVisible(true)

    self:registerClickEvent(self._notice,function()
        if not self._desTip:isVisible() then
            self._desTip:setVisible(true)
        end
    end)

    local bg = self._topUnit
    self.leftMc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self.leftMc:setPosition(cc.p(150, 60))
    bg:addChild(self.leftMc,20)
    self.leftMc:setRotation(-180)
    self.leftMc:setVisible(false)

    self.rightMc = mcMgr:createViewMC("youjiantou_teamnatureanim", true, false)
    self.rightMc:setPosition(cc.p(bg:getContentSize().width-35, 60))
    bg:addChild(self.rightMc,20)
    self.rightMc:setVisible(false)

    UIUtils:setTitleFormat(self._title,1)
    self._costNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._topUnit:getChildByFullName("num_battle"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._bottomLeftUnit:getChildByFullName("scoreDes"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    
    self._zhandouliLab = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
    self._Scorenum:setVisible(false)
    self._zhandouliLab:setScale(0.5)
    self._topUnit:addChild(self._zhandouliLab, 1)
    self._zhandouliLab:setPosition(self._Scorenum:getPositionX(),self._Scorenum:getPositionY()+4)

    self._zhandouliLab1 = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
    self._score_num:setVisible(false)
    self._zhandouliLab1:setScale(0.4)
    self._zhandouliLab1:setAnchorPoint(0,0.5)
    self._bottomLeftUnit:addChild(self._zhandouliLab1, 1)
    self._zhandouliLab1:setPosition(self._score_num:getPositionX(),self._score_num:getPositionY()+4)

    self._itemTopWidth = self._itemTop:getContentSize().width 
    self._itemTopHeight = self._itemTop:getContentSize().height
    if self._tableView == nil then
        local tableBg = self._tableViewBg
        self._tableView = cc.TableView:create(cc.size(tableBg:getContentSize().width, tableBg:getContentSize().height))
        self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self._tableView:setPosition(cc.p(0, 0))
        self._tableView:setDelegate()
        self._tableView:setBounceable(true)
        self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_LEFTRIGHT)
        self._tableView:registerScriptHandler(function(view) 
            return self:scrollViewDidScroll(view) 
        end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
        self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
        self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
        self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self._tableView:registerScriptHandler(function ( table,cell )
            return self:tableCellTouched(table,cell)
        end,cc.TABLECELL_TOUCHED)
        tableBg:addChild(self._tableView)
        self._tableView:reloadData()
    end

    self._itemTop:setVisible(false)
    self._skillDesPanel:setVisible(false)
    self:updateBottomLeftUnit()
    self:updateBottomRightUnit()

    

end

function SkillTalentDialog:tableCellTouched(table , cell)
    local index = cell:getIdx() + 1
    print("cell touched at index: " .. index)
    if self._curTalentIndex ~= index then
        local cellBefore = table:cellAtIndex(self._curTalentIndex - 1)
        local beforeItem = cellBefore and cellBefore.itemNode
        if beforeItem then
            beforeItem:getChildByFullName("image_choose"):setVisible(false)
        end
        self._curTalentIndex = index
        local curItem = cell.itemNode
        if curItem then
            curItem:getChildByFullName("image_choose"):setVisible(true)
        end 

        self:updateBottomLeftUnit()
        self:updateBottomRightUnit()
    end
end

function SkillTalentDialog:onShow()
    self:updateRealVisible(true)
end

function SkillTalentDialog:scrollViewDidScroll(view)
    self._inScrolling = view:isDragging()
    if self._inScrolling then
        self.leftMc:setVisible(false)
        self.rightMc:setVisible(false)
    else
        self._offsetX = view:getContentOffset().x
        if self._offsetX >= 0 then
            self.leftMc:setVisible(false)
            self.rightMc:setVisible(true)
        elseif self._offsetX <= view:minContainerOffset().x then
            self.rightMc:setVisible(false)
            self.leftMc:setVisible(true)
        else
            self.leftMc:setVisible(true)
            self.rightMc:setVisible(true)
        end
    end
end

function SkillTalentDialog:cellSizeForTable(table,idx)
    return self._itemTopHeight,self._itemTopWidth
end

function SkillTalentDialog:tableCellAtIndex(table,idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    end
    local item = cell.itemNode
    if not item then
        item = self._itemTop:clone()
        item:setVisible(true)
        item:setSwallowTouches(false)
        item:setPosition(0,0)
        cell:addChild(item)
        cell.itemNode = item
    end
    local data = self._skillTalentModel:getData()
    self:updateTopCell(item,data[idx+1],idx+1)
    return cell
end

function SkillTalentDialog:updateTopCell(item, cellData, index)
    local image_choose = item:getChildByFullName("image_choose")
    local frame = item:getChildByFullName("frame")
    local level = item:getChildByFullName("level")
    local icon = item:getChildByFullName("icon")

    local redPoint = item:getChildByFullName("redPoint")
    redPoint:setVisible(false)
    local isAct = self._skillTalentModel:checkActiveCondition(cellData.id)
    local isUP = self._skillTalentModel:checkUpCondition(cellData.id)
    if isAct == 3 or isUP then
        redPoint:setVisible(true)
    end

    --clear
    if self._curTalentIndex ~= index then
        image_choose:setVisible(false)
    else
        image_choose:setVisible(true)
    end
    level:setString(cellData.level)
    icon:loadTexture(cellData.image .. ".png", 1)
    if cellData.level <= 0 then --未激活
        UIUtils:setGray(item,true)
        -- item:setBrightness(-60)
    else
        UIUtils:setGray(item,false)
    end

    frame:loadTexture("skillTalent_fram" .. cellData.quality .. ".png",1)
    
end

function SkillTalentDialog:numberOfCellsInTableView(view)
    local data = self._skillTalentModel:getData()
    return #data
end

--[[
    更新左下方技能详情
    无返回
]]
function SkillTalentDialog:updateBottomLeftUnit()


    local talentData = self._skillTalentModel:getData()[self._curTalentIndex]
    -- dump(talentData,"updateBottomLeftUnit",10)

    local curScore = talentData.score
    local tableData = tab:SkillBookTalent(talentData.id)
    local skillBookData = tableData.skillbook
    local skillData = self._spellBooksModel:getData()
    local panelCount = {4,5,6}
    local count = #panelCount
    local curPanel
    for i=1,count do 
        local panel = self._bottomLeftUnit:getChildByFullName("panel_" .. panelCount[i])
        if skillBookData and #skillBookData == panelCount[i] then
            panel:setVisible(true)
            curPanel = panel
        else
            panel:setVisible(false)
        end
    end
    -- self._score_num:setString(curScore)
    if self._zhandouliLab1 then
        self._zhandouliLab1:setString(curScore)
    end


    for i=1,#skillBookData do
        local skillId = skillBookData[i]
        local data = tab.skillBookBase[tonumber(skillId)]
        local icon = curPanel:getChildByFullName("icon"..i)
        icon:loadTexture(data.art .. ".png", 1)
        icon:setScale(0.9)
        local iconFrame = icon:getChildByFullName("iconFrame")
        iconFrame:setScale(1.24)
        local x,y = iconFrame:getPositionX(),iconFrame:getPositionY()
        local w,h = icon:getContentSize().width,icon:getContentSize().height
        iconFrame:setPosition(w*0.5, h*0.5)
        local level = icon:getChildByFullName("level")
        local skillFind = skillData[tostring(skillId)] 
        if skillFind then
            level:setString(skillFind.l)
            UIUtils:setGray(icon,false)
        else
            --此法术书还未激活
            level:setString(0)
            UIUtils:setGray(icon,true)
        end

        local function checkRedPoint(inId, inIcon)
            local isEnough, canAct, canUp = self:detectEnough(inId)
            local redPoint = inIcon:getChildByName("redPoint")
            redPoint:setPosition(72, 70)
            redPoint:setVisible(false)
            if isEnough and (canAct or canUp)then
                redPoint:setVisible(true)
            end
        end

        checkRedPoint(skillId, icon)

        level:setPosition(w*0.5,8)
        self:registerClickEvent(icon, function()
            self._viewMgr:showDialog("spellbook.SpellBookUpDialog",{spellId = skillId, function()
                checkRedPoint(skillId, icon)
                end})
        end)
        -- level:setPosition(level:getPositionX()+w*0.5-x,level:getPositionY()+h*0.5-y-6)

    end
    self._level:setString(talentData.level) 
    self._icon:loadTexture(tableData.image .. ".png" , 1)
    self._frame:loadTexture("skillTalent_fram" .. talentData.quality .. ".png", 1)
    if talentData.level == 0 then
        UIUtils:setGray(self._middle,true)
    else
        UIUtils:setGray(self._middle,false)
    end


    local totalScore = self._skillTalentModel:getTotalScore()
    -- self._Scorenum:setString(totalScore)
    if self._zhandouliLab then
        self._zhandouliLab:setString(totalScore)
    end
end

--[[
    更新右下方天赋说明详情
    无返回
]]
function SkillTalentDialog:updateBottomRightUnit()

    local talentData = self._skillTalentModel:getData()[self._curTalentIndex]
    self._TalentName:setString(lang(talentData.name))

    local maxLevel = self._skillTalentModel:getTalentMaxLevelById(talentData.id)
    if talentData.level > 0 then
        self._talentLevel:setString("Lv." .. talentData.level .. "/" .. maxLevel) 
    else
        self._talentLevel:setString("未激活")
    end
    
    
    --描述
    if self._des.richNode then
        self._des.richNode:removeFromParent()
        self._des.richNode = nil
    end
    local richDes = lang(talentData.dsc1)
    if talentData.level > 0 then
        richDes = "[color=8a5c1d,fontsize=18]" .. richDes .. "[-]"
    else
        richDes = "[color=645252,fontsize=18]" .. richDes .. "[-]"
        richDes = string.gsub(richDes,"1ca216","645252")
    end
    
    local base = talentData.base
    local addNum = math.max(base,base + (talentData.level - 1) * talentData.addition)
    print("base",base,addNum)
    richDes = string.gsub(richDes,"{$int}",addNum)

    local rtx = RichTextFactory:create(richDes,self._des:getContentSize().width,self._des:getContentSize().height)
    rtx:formatText()
    rtx:setVerticalSpace(1)
    self._des:addChild(rtx)
    self._des.richNode = rtx
    rtx:setPosition(self._des:getContentSize().width*0.5,self._des:getContentSize().height*0.5)

    local advanceData = talentData.advancedlv
    local realLevel = talentData.level
    self._scrollview:removeAllChildren()
    if advanceData and #advanceData > 0 then
        local showIndex = 0
        for k,v in pairs(advanceData) do 
            if realLevel >= v then
                showIndex = k
            else
                break
            end
        end
        local function createRich(index)
            local richText = lang(talentData["dscsp"..index])
            local item = self._skillDesPanel:clone()
            item:setVisible(true)
            local richBg = item:getChildByFullName("richBg")
            local image = item:getChildByFullName("flag")
            if showIndex >= index then
                --解锁
                UIUtils:setGray(image,false)
                richText = "[color=8a5c1d,fontsize=18]" .. "Lv." .. advanceData[index] .. " ".. richText .. "[-]"
            else
                --未解锁
                richText = "[color=645252,fontsize=18]" .. "Lv." .. advanceData[index] .. " " .. richText .. "[-]"
                richText = string.gsub(richText,"1ca216","645252")
                UIUtils:setGray(image,true)
            end
            
            
            local rtx = RichTextFactory:create(richText,richBg:getContentSize().width,0)
            rtx:setPixelNewline(true)
            rtx:formatText()
            rtx:setVerticalSpace(1)
            rtx:setAnchorPoint(cc.p(0.5,1))
            local h = rtx:getVirtualRendererSize().height
            item:addChild(rtx)
            rtx:setPosition(richBg:getContentSize().width*0.5+30,richBg:getContentSize().height)
            return item,h
        end
        local totalHeight = 0
        for i= #advanceData,1,-1 do 
            local richNode,h = createRich(i)
            self._scrollview:addChild(richNode)
            richNode:setPosition(0,totalHeight+h-50)
            totalHeight = totalHeight + h
        end
        self._scrollview:setInnerContainerSize(cc_size(self._scrollview:getContentSize().width,totalHeight))
        self._scrollview:jumpToTop()
    end

    local level = talentData.level
    local curMaxLevel,maxLevel = self._skillTalentModel:getTalentMaxLevelById(talentData.id)
    -----消耗------

    local costTabId = talentData.costsort
    local costTabData = tab:SkillBookTalentExp(level+1)
    UIUtils:setGray(self._up,false)
    UIUtils:setGray(self._active,false)
    if costTabData then
        local costData = costTabData["cost" .. costTabId]
        if costData then
            local userHave = self._userModel:getData()[costData[1][1]] or 0
            self._costNum:setString( userHave .. "/" .. costData[1][3])
            local isLight = false
            if userHave >= costData[1][3] then
                self._costNum:setColor(UIUtils.colorTable.ccUIBaseColor1)     --可升级 by wangyan
                isLight = true

            else
                UIUtils:setGray(self._up,true)
                UIUtils:setGray(self._active,true)
                self._costNum:setColor(UIUtils.colorTable.ccUIBaseColor6)
            end
            if level >= curMaxLevel then
                UIUtils:setGray(self._up,true)
            end
            self:setBtnState(self._up, isLight)

        elseif level >= maxLevel then
            print("已满级")
            self._costNum:setVisible(false)
        else
            print("costTabId",costTabId)
            self._costNum:setVisible(false)
        end
    end

    self._up:setVisible(false)
    self._active:setVisible(false)
    self._max:setVisible(false)
    self._costNum:setVisible(true)
    self._costImage:setVisible(true)
    -----激活或者升级-----------
    if level > 0 and level < maxLevel  then
        self._up:setVisible(true)

    elseif level == 0 then --未激活
        self._active:setVisible(true)
        local isLight = self._skillTalentModel:checkActiveCondition(talentData.id)
        self:setBtnState(self._active, isLight == 3)

    else --满级
        self._max:setVisible(true)
        self._costNum:setVisible(false)
        self._costImage:setVisible(false)
    end

end

function SkillTalentDialog:setBtnState(inBtn, isLight)
    if inBtn.effect then
        inBtn.effect:removeFromParent(true)
        inBtn.effect = nil
    end

    local btnRes = ""
    if isLight then 
        btnRes = "globalButtonUI13_1_1.png"         --可激活 / 可升级 
        UIUtils:setGray(inBtn,false)
        local effect = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
        effect:setPosition(66, 33)
        inBtn.effect = effect
        inBtn:addChild(effect)

    else
        btnRes = "globalButtonUI13_3_2.png"
        UIUtils:setGray(inBtn,true)
    end
    inBtn:loadTextures(btnRes, btnRes, btnRes, 1)
end

function SkillTalentDialog:detectEnough(inId)
    local isEnough = false
    local isAct = false
    local canUp = false
    
    local data = tab.skillBookBase[tonumber(inId) or 0]
    
    local spbInfo = self._spellBooksModel:getData()
    local spellInfo = spbInfo[tostring(inId)]

    local level = spellInfo and spellInfo.l or 0
    local canUpLvl = table.nums(data.quality) - 1

    local maxLevel = #data.skillbook_exp
    local needNum = data.skillbook_exp[math.min(maxLevel,level+1)] or 0
    local itemId = data.goodsId 
    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
    if haveNum >= needNum then
        isEnough = true
    end

    if not spellInfo or level < 1 then
        isAct = true
    end

    if level < canUpLvl  then
        canUp = true
    end

    return isEnough, isAct,canUp
end

return SkillTalentDialog