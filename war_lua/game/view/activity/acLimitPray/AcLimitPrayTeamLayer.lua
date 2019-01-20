--
-- Author: huangguofang
-- Date: 2018-08-07 18:30:49
--

local AcLimitPrayTeamLayer = class("AcLimitPrayTeamLayer",BaseLayer)
function AcLimitPrayTeamLayer:ctor(params)
    self.super.ctor(self)
 	self._parent = params.parent
    self._UIInfo = params.UIInfo or {}
    self._openId = params.openId
end

-- 初始化UI后会调用, 有需要请覆盖
function AcLimitPrayTeamLayer:onInit()
    local teamId = self._UIInfo.teamId or 0
    self._staticTeamData = tab:Team(teamId)
	self._skillPanel = self:getUI("bg.skilPanel")
	-- print("==========================name==========",self._skillPanel:getName())

	self._tableView = nil
	self._tableData = clone(self._staticTeamData.skill)
	if tonumber(self._staticTeamData.zizhi)+12 == 16 then
		local num = table.nums(self._tableData)
		table.remove(self._tableData,num - 1)
		table.remove(self._tableData,num - 2)
	else
		local num = table.nums(self._tableData)
		table.remove(self._tableData,num)
		table.remove(self._tableData,num - 1)
	end
	-- self:addTableView()
	self:initSkillPanel()
end

function AcLimitPrayTeamLayer:createItem(data,index)
	if not data then return end

	local layer = ccui.Layout:create()
	layer:setAnchorPoint(cc.p(0,0))
	layer:setContentSize(cc.size(573, 140))
	-- layer:setBackGroundImage("acLimitPray_teamCell_Bg.png",1)
	-- layer:setBackGroundImageScale9Enabled(true)
	-- layer:setBackGroundImageCapInsets(cc.rect(10,1,1,1))

	-- --技能背景
	local bgImg = ccui.ImageView:create()
	bgImg:loadTexture("acLimitPray_teamCell_Bg.png",1)
	-- bgImg:setContentSize(573,103)
	-- bgImg:setScale9Enabled(true)
	-- bgImg:setCapInsets(cc.rect(55,55,1,1))
	bgImg:setAnchorPoint(0,0)
	bgImg:setScaleY(1.3)
	bgImg:setPosition(0, 0)
	layer:addChild(bgImg)

	-- 技能icon
	local icon = IconUtils:createTeamSkillIconById({teamSkill = data, teamData = self._staticTeamData, level = 1, eventStyle = 1})
    icon:setPosition(cc.p(-4, 3))
    icon:setScale(1.1)
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
    nameTxt:setPosition(120, 104)
    nameTxt:setFontName(UIUtils.ttfName)
    nameTxt:setAnchorPoint(cc.p(0,0.5))
    nameTxt:setColor(cc.c4b(255,255,255,255))
    -- nameTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    layer:addChild(nameTxt,2)

	--描述
	local desTxt = ccui.Text:create()
	desTxt:setTextAreaSize(cc.size(446,100))
    desTxt:setString(lang("skillintroduce_" .. data.id))
    desTxt:setFontSize(18)
    desTxt:setPosition(120, 0)
    desTxt:setFontName(UIUtils.ttfName)
    desTxt:setAnchorPoint(0,0)
    desTxt:setColor(cc.c4b(123,199,210,255))
    desTxt:setTextVerticalAlignment(1)
 --    if  then

	-- end
    layer:addChild(desTxt,2)

	return layer 
end

function AcLimitPrayTeamLayer:initSkillPanel()
	self._scrollView = self:getUI("bg.scrollView")
	self._scrollView:setPositionX(self._scrollView:getPositionX() - 3)
	self._scrollView:removeAllChildren()
    self._scrollView:setBounceEnabled(true)
    -- scrollView:setClippingType(1)

    local itemH = 140
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
		item:setPosition(27, height - i * itemH)
        self._scrollView:addChild(item)    
        i = i + 1
	end

end


-- 接收自定义消息
function AcLimitPrayTeamLayer:reflashUI(data)

end

return AcLimitPrayTeamLayer