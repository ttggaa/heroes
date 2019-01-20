--[[
    Filename:    CrossGodWarSelectFormationView.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-10 19:16
    Description: File description
--]]

local CrossGodWarSelectFormationView = class("CrossGodWarSelectFormationView",BasePopView)

function CrossGodWarSelectFormationView:ctor(param)
 	self.super.ctor(self)
    self.callback = param.callback
	self._state = param.state
    self._useInfo = param.useInfo
    self._items = {}
end

function CrossGodWarSelectFormationView:onInit()
	self._item      = self:getUI("bg.item")
	self._item:setVisible(false)
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._heroModel      = self._modelMgr:getModel("HeroModel")
    self._teamModel      = self._modelMgr:getModel("TeamModel")
    self._cGodWarModel   = self._modelMgr:getModel("CrossGodWarModel")
    self._closeBtn   = self:getUI("bg.mainBg.closeBtn")
    self._scrollView = self:getUI("bg.mainBg.scrollView")
    self:registerClickEvent(self._closeBtn, function ( ... )
        self:close()  
    end)
    self:createScrollView()
end
local itemHeight = 186
function CrossGodWarSelectFormationView:createScrollView()
    self._scrollView:removeAllChildren()
    local width = self._scrollView:getInnerContainerSize().width
    local height = itemHeight * 3 
    self._scrollView:setInnerContainerSize(cc.size(width,height))
    local nameStr = {"第一阵容","第二阵容","第三阵容"}
    for i=1,3 do
        local item = self._item:clone()
        item.powerNode = item:getChildByFullName("powerNode")
        item.heroNode = item:getChildByFullName("heroNode")
        item:setVisible(true)
        item.titleName = item:getChildByFullName("titleName")
        item.titleName:setString(nameStr[i])
        local data = self._formationModel:getFormationData()[self._formationModel["kFormationTypeCrossGodWar"..i]] or {}
        if data and next(data) ~= nil then
            local heroData = self._heroModel:getHeroData(data.heroId) or {}
            --heroHead
            local sysHeroData = clone(tab:Hero(tonumber(data.heroId)))
            if not sysHeroData then
                sysHeroData = clone(tab:Hero(60001))
            end
            sysHeroData.star = heroData.star or 1
            sysHeroData.skin = heroData.skin
            local itemIcon = IconUtils:createHeroIconById({sysHeroData = sysHeroData,tp = 4})
            itemIcon:setAnchorPoint(cc.p(0,0))
            item.heroNode:addChild(itemIcon)

            local fightCapacity = 0
            fightCapacity = self._formationModel:getCurrentFightScoreByType(self._formationModel["kFormationTypeCrossGodWar"..i]) 
            print("战斗力。。。",data.score,fightCapacity)
            local zhandouliLabel = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli_little)
            zhandouliLabel:setScale(0.5)
            zhandouliLabel:setAnchorPoint(cc.p(0,0.5))
            item.powerNode:addChild(zhandouliLabel, 1)
            zhandouliLabel:setString(fightCapacity)
            self._scrollView:addChild(item)
            item:setPosition(5,height - (itemHeight*i))
            self:createListView(item,data,heroData)
            self._items[i] =  item
            item.selectBtn = item:getChildByFullName("selectBtn")

            item.timesLab = item:getChildByFullName("timesLab")
            local idx = i + 36
            local allTimes = 6 
            if self._state >= 6 and self._state < 12 then
                allTimes = 1
            end
            local times = allTimes - (self._useInfo[tostring(idx)] or 0)
            item.timesLab:setString(times.."/"..allTimes)
            item.times = times

            if times > 0 then
                item.timesLab:setColor(cc.c3b(28,162,22))
            else
                item.timesLab:setColor(cc.c3b(205,32,30))
            end

            local fId = self._cGodWarModel:getUseFormationId()
            if fId then
                fId = fId - 36
                item.selectBtn:setEnabled(fId~=i)
                item.selectBtn:setBright(fId~=i)
                local str = "使用"
                if fId == i then
                    str = "使用中"
                end
                item.selectBtn:setTitleText(str)
                if fId == i and times <= 0 then
                    item.selectBtn:setBrightness(-50)
                end
            end

            self:registerClickEvent(item.selectBtn,function ( sender )
                local idx = i + 36
                if self._useInfo[tostring(idx)] == 6 then
                    self._viewMgr:showTip("阵容到达使用次数上限")
                    return
                end
                self._serverMgr:sendMsg("CrossGodWarServer","selectFormation",{fId = idx},true,{},function ( result,isSuccess )
                    if isSuccess then
                        self._cGodWarModel:setUseFormationId(idx)
                        self:updateBtnState(i)
                        if self.callback then
                            self.callback(self._state)
                        end
                    end
                end)
            end)
        end
    end
    local nothing = self:getUI("bg.mainBg.nothing")
    nothing:setVisible(self._scrollView:getChildrenCount() == 0)
end

function CrossGodWarSelectFormationView:updateBtnState(curId)
    for i,item in ipairs(self._items) do
        if i == curId then
            item.selectBtn:setEnabled(false)
            item.selectBtn:setBright(false)
            item.selectBtn:setTitleText("使用中")
        else
            item.selectBtn:setEnabled(true)
            item.selectBtn:setBright(true)
            item.selectBtn:setTitleText("使用")
        end
            
    end
end

--[[
@desc 创建军团列表
@param inView parant节点 formationData 阵容信息 heroData 阵容英雄信息
]]
function CrossGodWarSelectFormationView:createListView( inView,formationData,heroData)
    local list = inView:getChildByFullName("teamList")
    list:removeAllChildren()
    for i=1,8 do
        local teamId = formationData["team"..i]
        -- print("teamId",teamId)
        if teamId and tonumber(teamId) ~= 0 then
            local teamData = self._teamModel:getTeamDataById(teamId)
            local teamIcon = self:createTeam(teamId,teamData,formationData,heroData)
            teamIcon:setAnchorPoint(cc.p(0,0))
            teamIcon:setScale(0.5)
            teamIcon:setContentSize(cc.size(teamIcon:getContentSize().width/2,teamIcon:getContentSize().height/2))
            list:pushBackCustomItem(teamIcon)
        end
    end

end

--[[
@desc 创建军团
@param teamId:id teamData:兵团信息 formationData 阵容信息 heroData 阵容英雄信息
]]
function CrossGodWarSelectFormationView:createTeam(teamId,teamData,formationData,heroData)
    -- dump(teamData)
    local teamD = tab:Team(teamId)
    -- -- print("===========self._palyerData.formation.heroId,teamId=>",self._palyerData.formation.heroId,teamId)
    local _,changeId = TeamUtils.changeArtForHeroMasteryByData(heroData,formationData.heroId,teamId)
    -- -- print("===========cahngeId=========",changeId)
    if changeId then
        teamD = tab:Team(changeId)
    end
    local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    dump(quality)
    local teamIcon = IconUtils:createTeamIconById({teamData = teamData,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2],eventStyle=3,clickCallback = function( )        
        local detailData = {}
        detailData.team = teamData
        detailData.team.teamId = teamId
        if changeId then
            detailData.team.teamId = changeId
        end    
        detailData.pokedex = heroData.pokedex or {}
        detailData.treasures = heroData.treasures or {}
        detailData.runes = heroData.runes or {}
        detailData.battleArray = heroData.battleArray
        detailData.pTalents = heroData.pTalents
        detailData.runes = self._teamModel:getHolyData()
        ViewManager:getInstance():showDialog("rank.RankTeamDetailView", {data=detailData}, true)
        -- ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeArenaTeam, iconId = teamId}, true)
    end})
    return teamIcon
end

return CrossGodWarSelectFormationView