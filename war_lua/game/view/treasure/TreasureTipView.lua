--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-02-03 20:45:21
--
local TreasureTipView = class("TreasureTipView", BaseLayer)
function TreasureTipView:ctor(params)
    TreasureTipView.super.ctor(self)
    self._Atts = {}
    self._allAttMap = {}
end

function TreasureTipView:onInit()
    self._bg = self:getUI("bg")
    self._attrPanel    = self:getUI("bg.attrPanel")
    self._promptPanel  = self:getUI("bg.promptPanel")
    self._basePanel    = self:getUI("bg.basePanel")
    self._treasureImg  = self:getUI("bg.basePanel.treasureImg")
    self._nameLab      = self:getUI("bg.basePanel.nameLab")
    self._zhandouliLabel = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    self._zhandouliLabel:setScale(0.7)
    self._zhandouliLabel:setAnchorPoint(cc.p(0,0.5))
    self._zhandouliLabel:setPosition(cc.p(110, 40))
    self._basePanel:addChild(self._zhandouliLabel, 1)
    self._bgW = 400
end

function TreasureTipView:setAttrs( id,stage,isAllAtt )
    if isAllAtt then 
        self._basePanel:setVisible(false)
        self:showAllTreasureAttrs()
        return 
    end
	self._curComInfo = self._modelMgr:getModel("TreasureModel"):getTreasureById(id)
	-- dump(self._curComInfo)
	self._curComData = tab.comTreasure[id]
    if stage and stage > 0 then
    	self._nameLab:setString(lang(self._curComData.name) .. "+" .. stage)
    else
        self._nameLab:setString(lang(self._curComData.name))
    end
	self._nameLab:setColor(UIUtils.colorTable["ccColorQuality" .. self._curComData.quality])
	local score = 0 
	if self._curComInfo then
		score = self._curComInfo.comScore + self._curComInfo.disScore
	end
	self._zhandouliLabel:setString("a" .. (score or 0))
	self:reflashAttrPanel( id )
	self:generateExAtts(id, stage, nil, 0, 0)
	self._treasureImg:loadTexture(IconUtils.iconPath .. self._curComData.icon .. ".png", 1)
    self:autoResize()
end

function TreasureTipView:reflashAttrPanel( id, allAtts)
	local atts    = allAtts or self:generateAtts(id)
    self._attrPanel:setContentSize(cc.size(370,#atts/2*40))
    local height  = self._attrPanel:getContentSize().height
    local lineHeight = 30
    local x, y = 0, 0
    local offsetx, offsety = 0, -20
    local lineCol = 0
    local lineNum = 0
    for i, att in ipairs(atts) do
        local desName = ccui.Text:create()
        desName:setAnchorPoint(cc.p(0, 0.5))
        desName:setFontSize(20)
        desName:setFontName(UIUtils.ttfName)
        desName:setColor(UIUtils.colorTable.ccUIBasePromptColor)
        local attName = lang("ARTIFACTDES_PRO_" .. att.attId)
        if not attName then
            attName = lang("ATTR_" .. att.attId)
        end
        if attName then
            attName = string.gsub(attName, "　", "")
            attName = string.gsub(attName, " ", "") .. "+"
        end
        desName:setString(attName)
        x = ((i-1)%2) * 200 + offsetx
        y = height - math.floor((i-1)/2) * lineHeight + offsety
        lineCol = lineCol + 1

        desName:setPosition(cc.p(x, y))
        local attNum = ccui.Text:create()
        attNum:setFontSize(22)
        attNum:setFontName(UIUtils.ttfName)
        attNum:setAnchorPoint(cc.p(0, 0.5))
        local tail = ""
        if att.attId == 2 or att.attId == 5 or att.attId == 131 then
            tail = "%"
        end
        if self._curComInfo and tonumber(att.attNum) then
            attNum:setColor(UIUtils.colorTable.ccUIBaseColor9)
            local value =(att.attNum or 0)
            if value < 1 then
                value = tonumber(string.format("%.2f", value))
            elseif value < 100 then
                value = tonumber(string.format("%.1f", value))
            else
                -- value = math.ceil(value)
                value = tonumber(string.format("%.1f", value))
            end
            attNum:setString(value .. tail)
        else
            attNum:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            attNum:disableEffect()
            attNum:setString("--")
        end
        attNum:setPosition(cc.p(x + desName:getContentSize().width + 10, y))
        self._attrPanel:addChild(attNum)
        self._attrPanel:addChild(desName)
    end
    self._attrPanel:setVisible(true)
end

function TreasureTipView:generateAtts(id)
    -- if not self._Atts[id] then
    local Atts = { }
    local stage = 0
    -- if (self._curComInfo and self._curComInfo.stage > 0) or self._propertyNone then
    --     stage = self._curComInfo and self._curComInfo.stage or 1
    --     for k, property in pairs(self._curComData["property"]) do
    --         if not Atts[property[1]] then
    --             Atts[property[1]] = { }
    --         end
    --         Atts[property[1]].attId = property[1]
    --         Atts[property[1]].attNum =(self._curComInfo and self._curComInfo.stage > 0) and(property[2] + math.max(stage - 1, 0) * property[3]) or "--"
    --     end
    -- end
    local form = self._curComData.form
    local disStages = { }
    -- if self._curComInfo then
    disStages = self._curComInfo and self._curComInfo.treasureDev or { }
    for k, v in pairs(form) do
        local disTreasure = tab:DisTreasure(v)
        for k, property in pairs(disTreasure["property"]) do
            if (disStages[tostring(v)] and disStages[tostring(v)].s > 0) or self._propertyNone then
                local attId = property[1]
                if not Atts[attId] then
                    Atts[attId] = { }
                end
                local disStage = disStages[tostring(v)].s or 0
                Atts[attId].attId = attId
                local preAttNum = tonumber(Atts[attId].attNum) or 0
                local curAttNum = 0
                if self._curComInfo and self._curComInfo.treasureDev
                    and self._curComInfo.treasureDev[tostring(v)].s > 0 then
                    curAttNum = property[2] + math.max(disStage - 1, 0) * property[3]
                    -- 加升星加成
                    local starBuff = 1 + self._modelMgr:getModel("TreasureModel"):caculateStarAttr(v)
                    curAttNum = curAttNum * starBuff
                end
                Atts[attId].attNum = preAttNum + curAttNum
                -- (tonumber(Atts[attId].attNum) or (self._curComInfo and self._curComInfo.treasureDev and tonumber(self._curComInfo.treasureDev[tostring(v)]) > 0))
                -- and ((tonumber(Atts[attId].attNum) or 0)+property[2]+math.max(disStage-1,0)*property[3]) or "--"
            end
        end
    end
    -- end
    self._Atts[id] = { }
    for k, v in pairs(Atts) do
        if v.attNum == 0 then
            v.attNum = "--"
        end
        table.insert(self._Atts[id], v)
    end
    if #self._Atts[id] > 1 then
        table.sort(self._Atts[id], function(a, b)
            return a.attId > b.attId
        end )
    end
    -- end
    return self._Atts[id]
end

local volumeChange = {25,16,9,4,1}
-- 2017.1.7 新逻辑
-- 不同阶数下 额外加成
function TreasureTipView:generateExAtts( id, stage, node, offsetx, offsety,buffs )
	node = node or self._promptPanel
   --  local disData = tab.comTreasure[tonumber(id)]
   --  local unlockData = disData.unlockaddattr
   --  local addAttrsData = disData.addattr
   --  local nextBuffId 
   --  local limitCount = 1
   --  for i,v in ipairs(unlockData) do
   --      if unlockData[i] > stage and not nextBuffId then
   --          nextBuffId = unlockData[i]
			-- limitCount = i
   --      end 
   --  end
    if not self._addAttrItems then
        self._addAttrItems = {}
    end
    local buffs = buffs or self._modelMgr:getModel("TreasureModel"):getVolumeBuffMap(id)
    dump(buffs)
    -- 创建额外加成显示
    local idx = 1
    local valueHeight = table.nums(buffs)*35
    node:setContentSize(cc.size(370,valueHeight))
    for volume,buff in pairs(buffs) do
        local item = self._addAttrItems[idx]
        if not item then
            item = ccui.Layout:create()
            item:setBackGroundColorOpacity(0)
            item:setBackGroundColorType(1)
            item:setBackGroundColor(cc.c4b(216, 194, 156, 128))
            item:setOpacity(255*(idx%2))
            item:setContentSize(350, 32)
            item:setAnchorPoint(0,0)
            item:setPosition(offsetx,valueHeight+offsety-idx*32)
            node:addChild(item)
            self._addAttrItems[idx] = item

            -- local flag = ccui.ImageView:create()
            -- flag:loadTexture("flag3_treasure.png",1)
            -- flag:setPosition(0,3)
            -- flag:setAnchorPoint(0,0)
            -- item:addChild(flag)

            -- local stageLab = ccui.Text:create()
            -- stageLab:setFontSize(16)
            -- stageLab:setFontName(UIUtils.ttfName)
            -- stageLab:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
            -- stageLab:setPosition(0,10)
            -- stageLab:setAnchorPoint(0,0)
            -- stageLab:setString("+" .. unlockData[idx])
            -- item:addChild(stageLab)
        end 
        idx =idx+1

        local stageUpImg = item:getChildByName("upStage")
        if not stageUpImg then
            stageUpImg = ccui.ImageView:create()
            stageUpImg:loadTexture("teamicon_treasure.png",1)
            -- stageUpImg:setScale(0.8)
            stageUpImg:setAnchorPoint(0,0)
            stageUpImg:setPosition(-2,5)
            stageUpImg:setName("upStage")
            item:addChild(stageUpImg)
        end
        node:reorderChild(item,12)

        -- local addAttrData = addAttrsData[idx]
        -- local volume = addAttrData[1]
        -- volume = volumeChange[volume]
        local attr3 = buff[3]
        local attr6 = buff[6]
        local attrDes = ""
        if attr3 then
        	attrDes = attrDes .. "[color=fae6c8]" ..  lang("ATTR_3") .. "增加[color=1ca216]" .. attr3 .. "[-][-]"
        end
        if attr6 then
        	attrDes = attrDes .. "[color=fae6c8]" ..  lang("ATTR_6") .. "增加[color=1ca216]" .. attr6 .. "[-][-]"
        end

        local des = "[color=fa921a]" .. volumeChange[volume] .. "单位兵团" .. attrDes .. "[-]"

        if item:getChildByName("rtx") then
            item:getChildByName("rtx"):removeFromParent()
        end

        local rtx = RichTextFactory:create(des or "",400,item:getContentSize().height)
        rtx:formatText()
        -- rtx:setVerticalSpace(5)
        -- rtx:setAnchorPoint(cc.p(0,0))
        local w = rtx:getInnerSize().width
        local h = rtx:getInnerSize().height
        local realW = rtx:getRealSize().width
        -- if realW > 350 then
            if realW+80 > self._bgW then
                self._bgW = realW+80 
            end
        -- end
        rtx:setPosition(cc.p(w/2+30,item:getContentSize().height/2))
        UIUtils:alignRichText(rtx,{vAlign = "center",hAlign = "left"})
        rtx:setName("rtx")
        item:addChild(rtx) 
    end
end

function TreasureTipView:autoResize( notShowBase )
    local promptChildren = self._promptPanel:getChildren()
    local promptH = #promptChildren * 35
    local attChildren = self._attrPanel:getChildren()
    local attH = math.ceil(#attChildren/4)*40
    local baseH = notShowBase and 0 or 120 
    local bgH = promptH+attH+baseH+40
    self._bg:setContentSize(cc.size(self._bgW,bgH))
    print(self._bgW, bgH,promptH,attH,baseH)
    local posY = 20
    self._promptPanel:setPositionY(posY)
    posY = posY + promptH+10
    print("posY",posY)
    self._attrPanel:setPositionY(posY)
    posY = posY +attH
    print("posY",posY)
    self._basePanel:setPositionY(posY)

    self._bg:setPositionY(-bgH/2)

end

function TreasureTipView:showAllTreasureAttrs( )
    self._allAttMap   = {}
    local allExAttMap = {}
    local comInfos    = self._modelMgr:getModel("TreasureModel"):getData()
    for id,v in pairs(comInfos) do
        self._curComInfo = self._modelMgr:getModel("TreasureModel"):getTreasureById(id)
        -- dump(self._curComInfo)
        self._curComData = tab.comTreasure[tonumber(id)]
        
        local atts  = self:generateAtts(id)
        allExAttMap[id] =  self._modelMgr:getModel("TreasureModel"):getVolumeBuffMap(tonumber(id))
    end
    -- dump(self._Atts,"atts...")
    for k,v in pairs(self._Atts) do
        for k1,v1 in pairs(v) do
            if not self._allAttMap[v1.attId] then
                self._allAttMap[v1.attId] = 0
            end
            self._allAttMap[v1.attId] = self._allAttMap[v1.attId] + v1.attNum
        end
    end
    local allAtts = {}
    for k,v in pairs(self._allAttMap) do
        table.insert(allAtts,{attId = k,attNum = v})
    end
    table.sort(allAtts, function(a, b)
        return a.attId > b.attId
    end )
    dump(self._allAttMap,"self._allAttMap")
    self:reflashAttrPanel(0,allAtts)

    -- 额外加成
    local volumeAttMap = {}
    for k,v in pairs(allExAttMap) do
        -- dump(v,"v....in allEx...")
        for k1,v1 in pairs(v) do
            if not volumeAttMap[k1] then
                volumeAttMap[k1] = {}
            end
            for k2,v2 in pairs(v1) do
                if not volumeAttMap[k1][k2] then
                    volumeAttMap[k1][k2] = 0
                end
                volumeAttMap[k1][k2] = volumeAttMap[k1][k2] + v2
            end
        end
    end
    dump(volumeAttMap,"volumeAttMap........",4)
    self:generateExAtts(20, 1, nil, 0, 0,volumeAttMap)  
    self:autoResize(true)
end

return TreasureTipView