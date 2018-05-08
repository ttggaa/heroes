--
-- Author: huangguofang
-- Date: 2016-09-02 20:33:32
--
local ACGreenDragonTeamLayer = class("ACGreenDragonTeamLayer",BaseLayer)
function ACGreenDragonTeamLayer:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function ACGreenDragonTeamLayer:onInit()
    self._teamId = 107	-- 大天使107 绿龙207
    self._staticTeamData = tab:Team(self._teamId)
	self._skillPanel = self:getUI("bg.skilPanel")
	-- print("==========================name==========",self._skillPanel:getName())

	local teamPanel = self:getUI("bg.teamPanel")
	teamPanel:setPositionX(teamPanel:getPositionX()-3)
	self._teamTag = self:getUI("bg.teamPanel.tagImg")
	self._teamImg = self:getUI("bg.teamPanel.teamImg")
	self._dizuoImg = self:getUI("bg.teamPanel.dizuo")
	local nameTxt = self:getUI("bg.teamPanel.nameTxt")
	nameTxt:setColor(cc.c4b(255,255,255,255))
	nameTxt:enable2Color(1, cc.c4b(247,255,180,255))
	nameTxt:enableOutline(cc.c4b(48,23,2,255), 2)  
	nameTxt:setFontName(UIUtils.ttfName_Title)
	nameTxt:setString(lang(self._staticTeamData.name))
	self._teamNameTxt = nameTxt

	self:initRightPanel()

	self._tableView = nil
	self._tableData = self._staticTeamData.skill
	-- dump(self._tableData,"sleg._tabelData")

	-- self:addTableView()
	self:initLeftPanel()
end

-- function ACGreenDragonTeamLayer:addTableView()
-- 	local width = self._skillPanel:getContentSize().width
-- 	local height = self._skillPanel:getContentSize().height

-- 	local tableView = cc.TableView:create(cc.size(width, height))
--     tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
--     tableView:setPosition(cc.p(5,2))
--     tableView:setDelegate()
--     tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--     -- tableView:setBounceEnabled(false)
--     -- self._skillPanel:addChild(tableView,999)
--     self._skillPanel:addChild(tableView, 10)

--     tableView:registerScriptHandler(function( view )
--         return self:scrollViewDidScroll(view)
--     end ,cc.SCROLLVIEW_SCRIPT_SCROLL)
--     tableView:registerScriptHandler(function( view )
--         return self:scrollViewDidZoom(view)
--     end ,cc.SCROLLVIEW_SCRIPT_ZOOM)
--     tableView:registerScriptHandler(function ( table,cell )
--         return self:tableCellTouched(table,cell)
--     end,cc.TABLECELL_TOUCHED)
--     tableView:registerScriptHandler(function( table,index )    	
--         return self:cellSizeForTable(table,index)
--     end,cc.TABLECELL_SIZE_FOR_INDEX)
--     tableView:registerScriptHandler(function ( table,index )
--         return self:tableCellAtIndex(table,index)
--     end,cc.TABLECELL_SIZE_AT_INDEX)
--     tableView:registerScriptHandler(function ( table )
--         return self:numberOfCellsInTableView(table)
--     end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

--     self._tableView = tableView
--     -- print("================self._tableView=====",type(self._tableView),type(tableView))
-- end
-- function ACGreenDragonTeamLayer:scrollViewDidScroll(view)
-- 	self._inScrolling = view:isDragging()	
-- end

-- function ACGreenDragonTeamLayer:scrollViewDidZoom(view)
--     -- print("scrollViewDidZoom")
-- end

-- function ACGreenDragonTeamLayer:tableCellTouched(table,cell)
--     print("cell touched at index: " .. cell:getIdx())
-- end

-- function ACGreenDragonTeamLayer:cellSizeForTable(table,idx) 

--     return 110,340
-- end

-- function ACGreenDragonTeamLayer:tableCellAtIndex(table, idx)
-- 	print("=====================tableCellAtIndex===================")
--     -- local strValue = string.format("%d",idx)
--     local cell = table:dequeueCell()

--     if nil == cell then
--         cell = cc.TableViewCell:new()
--     else
--     	cell:removeAllChildren()
--     end
--  --    local data = self._tableData[idx+1]

--  --    local skillType = data[1]   --技能技能类型
--  --    local skillId = data[2]		--技能id
-- 	-- local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
-- 	-- self._skillNode[k].nameLab:setString(lang(sysSkill.name))
-- 	-- local item = self:createItem(sysSkill,idx)
--     --三种不同的item
--  --    local item = ccui.ImageView:create()
-- 	-- -- -- --任务名称背景

-- 	-- item:loadTexture("greenDragon_skillDesBg.png",1)
-- 	-- item:setContentSize(340,108)
-- 	-- item:setScale9Enabled(true)
-- 	-- item:setCapInsets(cc.rect(10,1,1,1))
-- 	-- item:setAnchorPoint(cc.p(0,0))
-- 	-- item:setPosition(0, 0)	
-- 	-- --layer:addChild(item,1)

   
--     -- cell:addChild(item)

--     return cell
-- end

-- function ACGreenDragonTeamLayer:numberOfCellsInTableView(table)
-- 	print("#self._tableData=======",#self._tableData)
-- 	return 4
	
-- end

function ACGreenDragonTeamLayer:createItem(data,index)
	if not data then return end

	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0,0))
	layer:setContentSize(cc.size(340, 108))
	-- layer:setBackGroundImage("greenDragon_skillDesBg.png",1)
	-- layer:setBackGroundImageScale9Enabled(true)
	-- layer:setBackGroundImageCapInsets(cc.rect(10,1,1,1))

	-- --技能背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("globalPanelUI_activity_cellBg.png",1)
	bgImg:setContentSize(340,108)
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(cc.rect(55,55,1,1))
	bgImg:setAnchorPoint(cc.p(0,0))
	bgImg:setPosition(0, 0)
	layer:addChild(bgImg)

	-- 技能icon
	local icon = IconUtils:createTeamSkillIconById({teamSkill = data, teamData = self._staticTeamData, level = 1, eventStyle = 1})
    icon:setPosition(cc.p(-4, -5))
    layer:addChild(icon,2)
    if data.dazhao and 1 == data.dazhao then 
	    local bigLable = ccui.ImageView:create()	    
		bigLable:loadTexture("label_big_skill_hero.png",1)	
		bigLable:setAnchorPoint(cc.p(0,0.5))
		bigLable:setRotation(-30)
		bigLable:setPosition(5, 75)
		icon:addChild(bigLable,15)        
	end
    
    --名称
	local nameTxt = ccui.Text:create()
    nameTxt:setString(lang(data.name))
    nameTxt:setFontSize(22)
    nameTxt:setPosition(102, 78)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setAnchorPoint(cc.p(0,0.5))
    nameTxt:setColor(cc.c4b(78,50,13,255))
    -- nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    layer:addChild(nameTxt,2)

	--技能label背景
	local label = data.label 
	local imageName = ""
	if not label then
		label = 3
	end
	if 1 == label or 6 == label then
		imageName = "greenDragon_skillTag2.png" -- 触发
	elseif 4 == label then
		imageName = "greenDragon_skillTag3.png"	-- 光环
	else
		imageName = "greenDragon_skillTag1.png"	-- 被动
	end
	local skillImg = ccui.ImageView:create()
	skillImg:loadTexture(imageName,1)	
	skillImg:setAnchorPoint(cc.p(1,1))
	skillImg:setPosition(330, 88)
	layer:addChild(skillImg)

	-- print("==============================",data.id)
	-- dump(data,"data")
	--描述
	local desTxt = ccui.Text:create()
	desTxt:setTextAreaSize(cc.size(230,80))
    desTxt:setString(lang("rankgreendragonskill" .. data.id))
    desTxt:setFontSize(18)
    desTxt:setPosition(102, -2)
    desTxt:setFontName(UIUtils.ttfName)
    desTxt:setAnchorPoint(cc.p(0,0))
    desTxt:setColor(cc.c4b(122,82,55,255))
    desTxt:setTextVerticalAlignment(1)
    layer:addChild(desTxt,2)

	-- local teamData = clone(self._staticTeamData)
	-- teamData.level = 1
	-- teamData.teamId = self._teamId
	-- teamData.star = 1
	-- if not teamData.equipLevel1 then
	-- 	for i=1,4 do
	--         teamData["el" .. i] = 1
	--         teamData["es" .. i] = 1
	--         teamData["sl".. i] = 1
	--     end
	--     teamData.skill = nil
	-- end
 --   	local str = SkillUtils:handleSkillDesc1(lang(data.des), teamData, 1,1)
 -- --  	print("========================",str)
 -- 	--处理富文本字符串
	-- str = string.gsub(str,"%b[]",function( catchStr )
	-- 	local _,pos1 = string.find(catchStr,"color=")

	-- 	if pos1 then
	-- 		return string.sub(catchStr,1,pos1) .. "112511" .. string.sub(catchStr,pos1+7,string.len(catchStr))
	-- 	else
	-- 		return catchStr 
	-- 	end
	-- end) 
	-- str = string.gsub(str,"%b[]",function( catchStr )
	-- 	local _,pos1 = string.find(catchStr,"fontsize=")
	-- 	if pos1 then
	-- 		return string.sub(catchStr,1,pos1) .. "18" .. string.sub(catchStr,pos1+3,string.len(catchStr))
	-- 	else
	-- 		return catchStr 
	-- 	end
	-- end) 
	-- -- print("============",str)
	-- str = string.gsub(str,"%b[]",function( catchStr )
	-- 	local _,pos1 = string.find(catchStr,"outlinecolor=")
	-- 	if pos1 then
	-- 		return string.sub(catchStr,1,pos1-14) .. "" .. string.sub(catchStr,pos1+9,string.len(catchStr))
	-- 	else
	-- 		return catchStr 
	-- 	end
	-- end) 
 --   	local rtx = RichTextFactory:create(str,240,60)
	-- rtx:formatText()
 --    rtx:setPosition(220,45)

 --    layer:addChild(rtx)

	return layer 
end

function ACGreenDragonTeamLayer:initLeftPanel()
	self._scrollView = self:getUI("bg.skilPanel.scrollview")
	self._scrollView:setPositionX(self._scrollView:getPositionX() - 3)
	self._scrollView:removeAllChildren()
    self._scrollView:setBounceEnabled(true)
    -- scrollView:setClippingType(1)

    local itemH = 110
    local height = table.nums(self._tableData) * itemH
	self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width , height))
  	
  	local i = 1

	for k,v in pairs(self._tableData) do
        local skillType = v[1]
        local skillId = v[2]
        if skillType == nil or skillId == nil then
        	print("============is null ===================")
            skillType = 1
            skillId = 59055
        end
        local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
         -- self._skillNode[k].classSkill:setString(lang("TEAMSKILL_LABEL" .. (sysSkill.label or 3)))
        local item = self:createItem(sysSkill,i)
		item:setPosition(0, height - i * 110)
        self._scrollView:addChild(item)    
        i = i + 1
	end

end

function ACGreenDragonTeamLayer:initRightPanel()
	-- body
	self._teamTag:loadTexture(IconUtils.iconPath .. self._staticTeamData.classlabel .. ".png" ,1)
	self._teamTag:setScale(0.7)
	self._teamTag:setPositionX(self._teamNameTxt:getPositionX() - self._teamNameTxt:getContentSize().width*0.5 - 20)
	self._teamImg:loadTexture("asset/uiother/steam/" .. self._staticTeamData.steam .. ".png")
	self._dizuoImg:loadTexture("asset/uiother/dizuo/teamBgDizuo101.png")
	-- self._dizuoImg:setVisible(false)

end

-- 接收自定义消息
function ACGreenDragonTeamLayer:reflashUI(data)

end

return ACGreenDragonTeamLayer