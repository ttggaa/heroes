--[[
    Filename:    TeamCardInfo.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-30 16:54:00
    Description: File description
--]]

local TeamCardInfo = class("TeamCardInfo", BasePopView)

local teamPlayWay = {
    [1] = "主线副本",
    [2] = "竞技场",
    [3] = "龙之国",
    [4] = "阴森墓穴",
    [5] = "矮人宝屋",
    [6] = "远征",
}

function TeamCardInfo:ctor()
    TeamCardInfo.super.ctor(self)
    self._title = {}
    self._panel = {}
end

function TeamCardInfo:onInit()
    local bg = self:getUI("bg")
    local bgLayer = ccui.Layout:create()
    bgLayer:setBackGroundColorOpacity(180)
    bgLayer:setBackGroundColorType(1)
    bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    -- bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    bg:getParent():addChild(bgLayer, -1)

	self._closeBtn = self:getUI("bg.infoBg.closeBtn")
	self:registerClickEvent(self._closeBtn, function(sender)
        self:close()
    end)
    self._cardBg = self:getUI("bg.card")

    self._pos1x = self._cardBg:getPositionX()
	self._pos1y = self._cardBg:getPositionY()
	self._pos2x = 480
	self._pos2y = 320
	self._scale1 = 1
	local h, w = self._cardBg:getContentSize().width, self._cardBg:getContentSize().height
 	local scale
 	if w / h > MAX_SCREEN_WIDTH / MAX_SCREEN_HEIGHT then
 		self._scale2 = MAX_SCREEN_WIDTH / w
 	else
 		self._scale2 = MAX_SCREEN_HEIGHT / h
 	end
 	self._rotate1 = 0
 	self._rotate2 = -90
	self._curPos = 1
	self._animing = false


-- 右侧面板
    -- self._scrollView = self:getUI("bg.infoBg.ScrollView_193")
    -- self:setScrollView()
end

function TeamCardInfo:onDestroy()
    print(self._card.picName)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(self._card.picName)
end

function TeamCardInfo:setScrollView()
    local maxHeight = 0
    for i=1,4 do
        self._title[i] = self._scrollView:getChildByFullName("titleBg" .. i)
        self._panel[i] = self._scrollView:getChildByFullName("panel" .. i)
        maxHeight = maxHeight + self._title[i]:getContentSize().height
        maxHeight = maxHeight + self._panel[i]:getContentSize().height + 40
    end
    -- print("==============" ,maxHeight)
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))

    local tempHeight = 10
    tempHeight = maxHeight - tempHeight 
    for i=1,4 do
        tempHeight = tempHeight - self._title[i]:getContentSize().height
        self._title[i]:setPositionY(tempHeight)
        -- print("********************", tempHeight)
        tempHeight = tempHeight - self._panel[i]:getContentSize().height
        self._panel[i]:setPositionY(tempHeight)
        tempHeight = tempHeight - 50
        -- tempHeight = tempHeight - self._panel[i]:getContentSize().height
    end

end

local ANIM_TIME = 0.3
function TeamCardInfo:reflashUI(data)
    local star = data.teamD.starlevel 
    if data.teamData then
        star = data.teamData.star
    end
    local param = {teamD = data.teamD, level = data.level, star = star}
    local card = CardUtils:createTeamCard(param)
    self._card = card
    card:setPosition(self._cardBg:getContentSize().width * 0.5, self._cardBg:getContentSize().height * 0.5)
    self._cardBg:addChild(card)
    self._cardBg:runAction(cc.EaseIn:create(cc.Spawn:create(
        cc.MoveTo:create(ANIM_TIME, cc.p(self._pos2x, self._pos2y)), 
        cc.RotateTo:create(ANIM_TIME, self._rotate2), 
        cc.ScaleTo:create(ANIM_TIME, self._scale2)), 1.5))
       
    self:registerClickEvent(self._cardBg, function(sender)


        self:runAction(cc.Sequence:create(
            cc.CallFunc:create(function()
                self._cardBg:runAction(cc.EaseIn:create(
                    cc.Spawn:create(
                        cc.MoveTo:create(ANIM_TIME, cc.p(self._pos1x, self._pos1y)),
                        cc.RotateTo:create(ANIM_TIME, self._rotate1),
                        cc.ScaleTo:create(ANIM_TIME, self._scale1)
                        ), 
                    1.5))
                end),
            cc.DelayTime:create(ANIM_TIME - 0.1),
            cc.CallFunc:create(function()
                    self:close()
                end)
            ))
        -- if self._animing then return end
        -- self._animing = true
        -- if self._curPos == 1 then
        --     -- self._cardBg:runAction(cc.EaseIn:create(cc.Spawn:create(
        --     --     cc.MoveTo:create(ANIM_TIME, cc.p(self._pos2x, self._pos2y)), 
        --     --     cc.RotateTo:create(ANIM_TIME, self._rotate2), 
        --     --     cc.ScaleTo:create(ANIM_TIME, self._scale2)), 1.5))
        --     -- self._curPos = 2
        -- else
        --     self:close()
        --     -- self._cardBg:runAction(cc.EaseIn:create(cc.Spawn:create(
        --     --     cc.MoveTo:create(ANIM_TIME, cc.p(self._pos1x, self._pos1y)),
        --     --     cc.RotateTo:create(ANIM_TIME, self._rotate1),
        --     --     cc.ScaleTo:create(ANIM_TIME, self._scale1)), 1.5))
        --     -- self._curPos = 1
        -- end
        -- ScheduleMgr:delayCall(ANIM_TIME * 1000, self, function()
        --     self._animing = false
        -- end)
    end)

end

-- function TeamCardInfo:reflashUI(data)
--     local star = data.teamD.starlevel 
--     if data.teamData then
--         star = data.teamData.star
--     end
--     local param = {teamD = data.teamD, level = data.level, star = star}
--     local card = CardUtils:createTeamCard(param)
--     self._card = card
--     card:setPosition(self._cardBg:getContentSize().width * 0.5, self._cardBg:getContentSize().height * 0.5)
--     self._cardBg:addChild(card)

--     self:registerClickEvent(self._cardBg, function(sender)
--     	if self._animing then return end
--     	self._animing = true
--     	if self._curPos == 1 then
--     		self._cardBg:runAction(cc.EaseIn:create(cc.Spawn:create(
--                 cc.MoveTo:create(ANIM_TIME, cc.p(self._pos2x, self._pos2y)), 
--                 cc.RotateTo:create(ANIM_TIME, self._rotate2), 
--                 cc.ScaleTo:create(ANIM_TIME, self._scale2)), 1.5))
--     		self._curPos = 2
--     	else
--     		self._cardBg:runAction(cc.EaseIn:create(cc.Spawn:create(
--                 cc.MoveTo:create(ANIM_TIME, cc.p(self._pos1x, self._pos1y)),
--                 cc.RotateTo:create(ANIM_TIME, self._rotate1),
--                 cc.ScaleTo:create(ANIM_TIME, self._scale1)), 1.5))
--     		self._curPos = 1
--     	end
--     	ScheduleMgr:delayCall(ANIM_TIME * 1000, self, function()
--     		self._animing = false
--     	end)
--     end)

--     self:checkDingwei(data.teamD)
--     self:setPanel2(data.teamD, data.teamData, data.level)
--     self:setPanel3(data.teamD)
--     self:setPanel4(data.teamD)
-- end

function TeamCardInfo:getMaxPingding(param,tempIndex,tempNum)
    local tempPing = {}
    table.insert(tempPing, {tempIndex,tempNum})
    local tempIndex1,tempNum1 = 0, 0
    for i=1,4 do
        if i ~= tempIndex then
            if param[i] == tempNum then
                tempIndex1 = i
                tempNum1 = param[i] 
                table.insert(tempPing, {tempIndex1,tempNum1})
                tempIndex1,tempNum1 = 0, 0
            end
        end
    end
    return tempPing
end

function TeamCardInfo:createPingding(count,check,max)
    local panel1 = self._scrollView:getChildByFullName("panel1")
    local pingBar
    local beginX = -3
    local barBg = panel1:getChildByFullName("check" .. count .. ".progressBg") 
    for i=1,check do
        -- pingBar = cc.Sprite:createWithSpriteFrameName("globalImageUI_teamImg1.png")
        -- pingBar:setName("bar" .. i)
        -- posX = beginX + 10 * i
        -- pingBar:setPosition(posX,16)
        -- barBg:addChild(pingBar)
        pingBar = barBg:getChildByName("bar" .. i)
        if pingBar then
            pingBar:setVisible(true)
            if max == true then
                pingBar:setSpriteFrame("globalImageUI6_teamImg3.png")
            else
                pingBar:setSpriteFrame("globalImageUI_teamImg1.png")
            end
        else
            pingBar = cc.Sprite:createWithSpriteFrameName("globalImageUI_teamImg1.png")
            pingBar:setName("bar" .. i)
            posX = beginX + 8 * i
            pingBar:setPosition(posX,7)
            barBg:addChild(pingBar)
        end
    end
end

-- 定位
function TeamCardInfo:checkDingwei(data)
    local teamData = data --tab:Team(self._curSelectTeam.teamId)
    local barBg, temp
    local panel1 = self._scrollView:getChildByFullName("panel1") 
    -- for i=1,4 do
    --     barBg = panel1:getChildByFullName("check" .. i) 
    --     for k=1,10 do
    --         local tempCheck = barBg:getChildByFullName("progressBg.bar" .. k) 
    --         tempCheck:setVisible(false)
    --     end
    -- end
    local tempIndex, tempNum = 0, 0
    local pingdingNum = {} 
    for i=1,4 do
        barBg = panel1:getChildByFullName("check" .. i) 
        if i == 1 then
            -- str1 = "atkshow"
            temp = teamData.atkshow
        elseif i == 2 then
            -- str1 = "hpshow"
            temp = teamData.hpshow 
        elseif i == 3 then
            -- str1 = "atkspeedshow"
            temp = teamData.atkspeedshow + 0
        elseif i == 4 then
            -- str1 = "defshow"
            temp = teamData.defshow + 0
        end
        if temp > 10 then
            temp = 0
        end
        if temp > tempNum then
            tempIndex = i
            tempNum = temp 
        end
        pingdingNum[i] = temp
        self:createPingding(i,temp)
        -- for k=1,temp do
        --     local tempCheck = barBg:getChildByFullName("progressBg.bar" .. k) 
        --     tempCheck:setVisible(true)
        -- end
    end
    local maxPingding = self:getMaxPingding(pingdingNum,tempIndex,tempNum)
    for tempIndex,v in ipairs(maxPingding) do
        self:createPingding(v[1],v[2], true)
    end

    local des = panel1:getChildByFullName("desLab") 
    local str = "兵团特征：" .. lang("CARDDES_" .. data.id) or 1
    des:setString(str) 
    des:setColor(cc.c3b(181,143,110))
end



-- 技能
function TeamCardInfo:setPanel2(data,teamData,level)
    local temp
    local panel2 = self._scrollView:getChildByFullName("panel2") 
    local iconCell
    local isGray = false
    local sysTeam = data
    local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
    for i,v in pairs(sysTeam.skill) do
        local skillType = v[1]
        local skillId = v[2]        
        local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
        local icon = panel2:getChildByFullName("icon" .. i)
        iconCell = icon:getChildByName("iconCell") 
        if iconCell ~= nil then 
            IconUtils:updateTeamSkillIconByView(iconCell,{teamSkill = sysSkill ,isGray = isGray ,eventStyle = 1})
        else
            iconCell = IconUtils:createTeamSkillIconById({teamSkill = sysSkill ,isGray = isGray ,eventStyle = 1, nil, level = 1})
            iconCell:setName("iconCell")
            iconCell:setScale(0.9)
            iconCell:setPosition(cc.p(-10, -10))
            icon:addChild(iconCell)
        end
        local name = panel2:getChildByFullName("name" .. i)
        name:setString(lang(sysSkill.name))
    end
end

-- 推荐搭配
function TeamCardInfo:setPanel3(data)
    -- local data = data --tab:Team(self._curSelectTeam.teamId)
    local barBg 
    local temp
    local panel3 = self._scrollView:getChildByFullName("panel3")
    local teamModel = self._modelMgr:getModel("TeamModel")
    -- local icon,param

    -- for i=1,4 do
    --     param = {}
    --     icon = panel3:getChildByFullName("icon" .. i)
    --     iconShow = panel3:getChildByFullName("iconShow" .. i)
    --     if iconShow == nil then
    --         iconShow = IconUtils:createSysTeamIconById(param)
    --         iconShow:setName("iconShow" .. i)
    --         icon:addChild(iconShow)
    --     else
    --         iconShow = IconUtils:updateSysTeamIconByView(param)
    --     end
    -- end
    local iconPlay,iconName,tempName,tempIcon,backQuality,flag
    for i=1,4 do
        icon = panel3:getChildByFullName("icon" .. i)
        iconName = panel3:getChildByFullName("name" .. i)
        if i <= table.nums(data.recommend) then
            iconPlay = icon:getChildByFullName("play")
            local sysTeam = tab:Team(data.recommend[i])
            local sysLangName = lang(sysTeam.name)
            local teamData,_ = teamModel:getTeamAndIndexById(data.recommend[i])

            if teamData then
                -- backQuality = teamModel:getTeamQualityByStage(teamData.stage)
                -- if iconPlay == nil then
                --     iconPlay = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = sysTeam,quality = 1 , quaAddition = 0,  eventStyle = 0})
                --     iconPlay:setName("play")
                --     iconPlay:setScale(0.8)
                --     iconPlay:setPosition(cc.p(0,0))
                --     icon:addChild(iconPlay)
                -- else
                --     iconPlay = IconUtils:updateSysTeamIconByView({teamData = teamData, sysTeamData = sysTeam,quality = 1 , quaAddition = 0,  eventStyle = 0})
                -- end
                -- IconUtils:setTeamIconLevelVisible(iconPlay, false)
                -- IconUtils:setTeamIconStarVisible(iconPlay, false)
                -- IconUtils:setTeamIconStageVisible(iconPlay, false)
                flag = false
            else
                flag = true
            end
            if iconPlay == nil then
                iconPlay = IconUtils:createSysTeamIconById({sysTeamData = sysTeam,isGray = flag ,eventStyle = 0})
                iconPlay:setName("play")
                iconPlay:setScale(0.83)
                iconPlay:setPosition(cc.p(0,0))
                icon:addChild(iconPlay)
            else
                iconPlay = IconUtils:updateSysTeamIconByView({sysTeamData = sysTeam,isGray = flag ,eventStyle = 0})
            end
            iconName:setString(sysLangName)
            iconName:setFontSize(18)
        else
            icon:setVisible(false)
            iconName:setVisible(false)
        end
    end

    local des = panel3:getChildByFullName("desLab") 
    local str = lang(data.recommend2) or "烽火"
    des:setString(str) 
    des:setColor(cc.c3b(181,143,110))
end

-- 推荐玩法
function TeamCardInfo:setPanel4(data)
    local barBg 
    local temp
    local panel4 = self._scrollView:getChildByFullName("panel4")
    local teamModel = self._modelMgr:getModel("TeamModel")

    local iconPlay,iconName,tempName,tempIcon,backQuality
    for i=1,4 do
        icon = panel4:getChildByFullName("icon" .. i)
        iconName = panel4:getChildByFullName("name" .. i)
        if i <= table.nums(data.recommend1) then
            iconPlay = icon:getChildByFullName("play")
            local playway = data.recommend1[i]
            -- print("=============", data.recommend1[i], playway)
            local sysLangName = teamPlayWay[i] --lang(sysTeam.name)
            -- local teamData,_ = teamModel:getTeamAndIndexById(data.recommend[i])

            if iconPlay == nil then
                iconPlay = IconUtils:createTeamPlayIconById({playWay = playway})
                iconPlay:setName("play")
                iconPlay:setScale(0.8)
                iconPlay:setPosition(cc.p(0,0))
                icon:addChild(iconPlay)
            else
                iconPlay = IconUtils:updateTeamPlayIconByView({playWay = playway})
            end
            iconName:setString(sysLangName)
            iconName:setFontSize(18)
        else
            icon:setVisible(false)
            iconName:setVisible(false)
        end

    end
end


return TeamCardInfo