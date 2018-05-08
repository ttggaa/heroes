--[[
    Filename:    TeamItemCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-05-29 09:36:07
    Description: File description
--]]

local TeamItemCell = class("TeamItemCell", cc.TableViewCell)

function TeamItemCell:ctor()
    -- TeamItemCell.super.ctor(self)

end


function TeamItemCell:onInit()

end

function TeamItemCell:reflashUI(inTeamData)
	self._teamData = inTeamData
    if not self._teamData then
        return
    end
    -- local teamData = self._teamsData[index+1]
    local sysTeam = tab:Team(self._teamData.teamId)
    local sysLangName = lang(sysTeam.name)

    -- local nameLab = self:getUI("listItem.itemNameLab")
    -- nameLab:setString(sysLangName)
    -- nameLab:setColor(cc.c3b(255,0,0))

    -- local stageLab = self:getUI("listItem.itemStageLab")
    -- stageLab:setString("+" .. self._teamData.stage)
    -- stageLab:setColor(cc.c3b(255,0,0))

    -- for i= 1 , self._teamData.star do
    --     local starImg = self:getUI("listItem.star" .. i)
    --     starImg:setVisible(true)
    -- end
    -- -- 隐藏无用的星星
    -- for i= self._teamData.star+1 , 6 do
    --     local starImg = self:getUI("listItem.star" .. i)
    --     starImg:setVisible(false)
    -- end

    -- local itemIcon = self:getUI("listItem.itemIcon")
    -- itemIcon:loadTexture(sysTeam.art1,1)
    -- local listItem = self:getUI("listItem")
    -- for k,v in pairs(listItem:getChildren()) do
    --     v:setVisible(false)
    -- end


    local modelMgr = ModelManager:getInstance()
    local teamModel = modelMgr:getModel("TeamModel")
-- teamModel:getTeamQualityByStage(self._teamData.stage)
    local backQuality = teamModel:getTeamQualityByStage(self._teamData.stage)
    local icon = self:getChildByName("teamIcon")
    if icon == nil then 
        icon = IconUtils:createTeamIconById({teamData = self._teamData, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
        icon:setName("teamIcon")
        icon:setPosition(cc.p(116/2 - 0,116/2 - 10))
        icon:setAnchorPoint(cc.p(0.5, 0.5))
        -- icon:setRotation(-90)
        icon:setScale(0.90)
        self:addChild(icon)
    else
        IconUtils:updateTeamIconByView(icon, {teamData = self._teamData, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
    end

-- 上阵

    -- globalImageUI_inFormation_s
    local inFormationIcon = icon:getChildByName("InFormation")
    if inTeamData.isInFormation == true then 
        if inFormationIcon == nil then 
            inFormationIcon = cc.Sprite:createWithSpriteFrameName("globalIamgeUI6_addTeam.png")
            inFormationIcon:setAnchorPoint(cc.p(0, 1))
            inFormationIcon:setName("InFormation")
            -- inFormationIcon:setScale(0.8)
            inFormationIcon:setPosition(-10,icon:getContentSize().height - 19)
            icon:addChild(inFormationIcon,5)
        end
        inFormationIcon:setVisible(true)
    else
        if inFormationIcon ~= nil then 
            inFormationIcon:setVisible(false)
        end
    end

    -- if isInFormation == true then 
    --     if inFormationIcon == nil then 
    --         -- print("shangzhen")
    --         inFormationIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI6_connerTag_r.png")
    --         inFormationIcon:setScaleX(-1)
    --         inFormationIcon:setAnchorPoint(cc.p(0.5, 1))
    --         -- inFormationIcon:setPosition(cc.p(-20,28))
    --         inFormationIcon:setScale(0.6)
    --         inFormationIcon:setName("InFormation")
    --         inFormationIcon:setPosition(37 ,icon:getContentSize().height-3)
    --         icon:addChild(inFormationIcon,2)
    --         local isInFormationLabel = cc.Label:createWithTTF("上阵", UIUtils.ttfName, 18)
    --         -- isInFormationLabel:setString("上阵")
    --         -- isInFormationLabel:setFontName(UIUtils.ttfName)
    --         -- isInFormationLabel:setFontSize(18)
    --         isInFormationLabel:setScaleX(-1)
    --         isInFormationLabel:setRotation(45)
    --         isInFormationLabel:setPosition(cc.p(41, 35))
    --         inFormationIcon:addChild(isInFormationLabel)
    --     end
    --     inFormationIcon:setVisible(true)
    -- else
    --     if inFormationIcon ~= nil then 
    --         inFormationIcon:setVisible(false)
    --     end
    -- end

-- 红点提示
    -- local formationModel = modelMgr:getModel("FormationModel")
    -- local isInFormation = formationModel:isTeamLoaded(self._teamData.teamId)
    -- globalImageUI_inFormation_s
    local hintIcon = icon:getChildByName("hintIcon")
    local isHint = self._teamData.onTeam
    if (inTeamData.isInFormation == true and isHint == true) or (inTeamData.onTree == 1) then 
        if hintIcon == nil then 
            hintIcon = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            hintIcon:setAnchorPoint(cc.p(1, 1))
            hintIcon:setName("hintIcon")
            hintIcon:setPosition(icon:getContentSize().width+1,icon:getContentSize().height+1)
            icon:addChild(hintIcon,5)
        end
        hintIcon:setVisible(true)
    else
        if hintIcon ~= nil then 
            hintIcon:setVisible(false)
        end
    end

-- 英雄选择显示
    if icon:getChildByName("itemIconSelected") == nil then 

        -- local iconSelected = ccui.ImageView:create()
        
        -- iconSelected:loadTexture("globalImageUI4_selectFrame.png", 1)
        -- -- iconSelected:setContentSize(cc.size(80, 80))
        -- iconSelected:setName("itemIconSelected")
        -- iconSelected:setPosition(cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2))
        -- iconSelected:ignoreContentAdaptWithSize(false)

        -- -- local iconSelected = cc.Sprite:createWithSpriteFrameName("globalImageUI4_IconSelected1.png")
        
        -- -- iconSelected:setPosition(cc.p(icon:getContentSize().width/2,icon:getContentSize().height/2))
        -- iconSelected:setAnchorPoint(cc.p(0.5, 0.5))
        -- -- iconSelected:setName("itemIconSelected")
        -- icon:addChild(iconSelected,2)


        local itemIconSelected = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
        itemIconSelected:setName("itemIconSelected")
        itemIconSelected:gotoAndStop(1)
        itemIconSelected:setPosition(icon:getContentSize().width*0.5, icon:getContentSize().height*0.5)
        itemIconSelected:setScale(1.1)
        itemIconSelected:setVisible(false)
        icon:addChild(itemIconSelected,2)
    end

    -- local starBg = self:getUI("listItem.itemIconBg")

    -- local star = self:getUI("listItem.itemIconBg.star1")

    -- local x , starY = star:getPosition()
    -- local starWidth = star:getContentSize().width
    -- local starHeight = star:getContentSize().height

    -- local starAllWidth = self._teamData.star * starWidth
    -- local beginX  = starBg:getContentSize().width / 2 - starAllWidth / 2
    -- for i= 1 , 6 do
    --     local tempStar = starBg:getChildByFullName("star" .. i)
    --     if i <= self._teamData.star then 
    --         if tempStar == nil then 
    --             tempStar = star:clone()
    --             starBg:addChild(tempStar)
    --         end
    --         tempStar:setVisible(true)
    --         tempStar:setPosition(beginX + (i - 1) * starWidth, starY)
    --         tempStar:setName("star" .. i)

    --     else
    --         if tempStar ~= nil then
    --             tempStar:setVisible(false)
    --         end
    --     end
    -- end
end


--[[
--! @function switchListItemState
--! @desc 切换list item 选中状态
--! @param sender object 操作list item
--! @param isSelected bool 是否选中
--! @return 
--]]
function TeamItemCell:switchListItemState(isSelected)
    if isSelected then 
        self:getChildByName("teamIcon"):getChildByName("itemIconSelected"):setVisible(true)
        -- self:getUI("listItem.itemIconBg"):setVisible(false)
        -- print("switchListItemState111111111111")
    else
        -- print("switchListItemState")
		-- self:getUI("listItem.itemIconBg"):setVisible(true)
		self:getChildByName("teamIcon"):getChildByName("itemIconSelected"):setVisible(false)
    end
end

return TeamItemCell