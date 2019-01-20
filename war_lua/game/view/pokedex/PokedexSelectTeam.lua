--[[
    Filename:    PokedexSelectTeam.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-01-21 14:49:41
    Description: File description
--]]


local PokedexSelectTeam = class("PokedexSelectTeam", BasePopView)

function PokedexSelectTeam:ctor(params)
    PokedexSelectTeam.super.ctor(self)
    self._selectPokedex = params.pokedexType
    self._posId = params.posId
    self._callback = params.callback
    -- self._pokedexDV = params.pokDV
end

function PokedexSelectTeam:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("pokedex.PokedexSelectTeam")
        end
        self:close()
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    title:setString(lang("TUJIANTITLE_" .. tab:Tujian(self._selectPokedex).art))

    -- local tishi = self:getUI("bg.layer.tishi")
    -- tishi:setString("*此图鉴仅可选择" .. lang("TUJIANTITLE_" .. tab:Tujian(self._selectPokedex).art))

    -- local none = self:getUI("bg.noneBg.none")
    -- none:setFontName(UIUtils.ttfName)
    -- none:setFontSize(28)
    -- none:enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
    -- none:setString(lang("TUJIANTITLE_" .. self._selectPokedex))

    self._scrollView = self:getUI("bg.sceollBg.scrollView")
    self._tempTeam = self:getUI("bg.teamBg")
    self._tempTeam:setVisible(false)
    local tempScore = self:getUI("bg.teamBg.teamFen")



    self._none = self:getUI("bg.noneBg")

    -- tempScore:setFontSize(20)

    -- 首次进入需要排序
    local teamModel = self._modelMgr:getModel("TeamModel")
    teamModel:refreshDataOrder()
    teamModel:initGetSysTeams()

    -- self:setTeam(2)
end

function PokedexSelectTeam:reflashUI(data)
    self._selectIndex = data.index or 1

    local teamModel = self._modelMgr:getModel("TeamModel")
    local tempTeamData = teamModel:getClassTeam(tab:Tujian(self._selectPokedex).art)
    -- dump(tempTeamData)

    local param = {pokedexId = self._selectPokedex, posId = tonumber(self._posId)}
    local teamId = self._modelMgr:getModel("PokedexModel"):getTeamShow(param)

    -- print(param["putList"][1][2])
    for k,v in pairs(tempTeamData) do
        local score = self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v)
        v.pokedexScore = score
        if teamId and teamId == v.teamId then
            v.sort = 1
        else
            v.sort = 2
        end
    end
    self:processData(tempTeamData) 
    self:teamTypeTeamList(tempTeamData)
end

function PokedexSelectTeam:processData(tempData)
    if table.nums(tempData) <= 1 then
        return
    end
    
    local sortFunc = function(a, b) 
        local acheck = a.pokedexScore
        local bcheck = b.pokedexScore
        local asort = a.sort
        local bsort = b.sort
        local ateamId = a.teamId
        local bteamId = b.teamId
        if acheck == nil then
            return
        end
        if bcheck == nil then
            return
        end
        if asort ~= bsort then
            return asort < bsort
        elseif acheck ~= bcheck then
            return acheck > bcheck
        elseif ateamId ~= bteamId then
            return ateamId < bteamId
        end
    end

    table.sort(tempData, sortFunc)
    -- return tempData
end

function PokedexSelectTeam:teamTypeTeamList(teamData)
    local pokedexName = {
        "攻击","防御","突击","射手","魔法","城堡","壁垒","据点","墓园","地狱","塔楼","元素","地下城","要塞","港口"
    }
    local teamModel = self._modelMgr:getModel("TeamModel")
    local posX = 11

    if table.nums(teamData) == 0 then
        self._none:setVisible(true)
        return
    else
        self._none:setVisible(false)
    end
    
    local line = math.ceil(table.nums(teamData)*0.5)
    self._scrollView:setInnerContainerSize(cc.size(600, line * 130)) 
    local posY = self._scrollView:getInnerContainerSize().height - 128  -- line * 120 - 20

    self._team = {}
    local flag = false
    local pokedexKey = 0
    for k,v in pairs(teamData) do
        self._team[k] = self._tempTeam:clone()
        self._team[k]:setVisible(true)
        self._team[k].teamScore = self._team[k]:getChildByFullName("teamFen")
        self._team[k].teamScore:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- self._team[k].teamScore:enable2Color(1, cc.c4b(235, 211, 127, 255))
        -- self._team[k].teamScore:enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
        -- self._team[k].teamScore:setFontSize(18)

        local str = "评分:" .. self._modelMgr:getModel("TeamModel"):getTeamAddPingScore(v) or 0 -- tab:Star(v.star).score or 0
        self._team[k].teamScore:setString(str)

        local sysTeam = tab:Team(v.teamId)
        local backQuality = teamModel:getTeamQualityByStage(v.stage)
        self._team[k].iconPlay = self._team[k]:getChildByFullName("team")
        if self._team[k].iconPlay == nil then
            self._team[k].iconPlay = IconUtils:createTeamIconById({teamData = v, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
            self._team[k].iconPlay:setName("team")
            self._team[k].iconPlay:setScale(0.9)
            self._team[k].iconPlay:setPosition(cc.p(3, 12))
            self._team[k]:addChild(self._team[k].iconPlay)
        else
            IconUtils:updateSysTeamIconByView(self._team[k].iconPlay, {teamData = v, sysTeamData = sysTeam,quality = backQuality[1] , quaAddition = backQuality[2],  eventStyle = 0})
        end
        self._team[k].iconPlay:setCascadeOpacityEnabled(true)

        -- for k1,v1 in pairs(pokedexPos["posList"]) do
        --     if v.teamId == v1 then
        --         if self._team[k].shang then
        --             self._team[k].shang:setVisible(true)
        --         end
        --         flag = true
        --     end
        -- end

        self._team[k].shang = self._team[k]:getChildByFullName("shang")
        -- self._team[k].shang:setCascadeOpacityEnabled(true)
        self._team[k].nameLab = self._team[k]:getChildByFullName("nameLab")
        self._team[k].tishiLab = self._team[k]:getChildByFullName("shang.tishiLab")
        self._team[k].shangzhen = self._team[k]:getChildByFullName("shangzhen")
        UIUtils:setButtonFormat(self._team[k].shangzhen, 3)
        -- self._team[k].shangzhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
        self._team[k].xiazhen = self._team[k]:getChildByFullName("xiazhen")
        UIUtils:setButtonFormat(self._team[k].xiazhen, 4)
        -- self._team[k].xiazhen:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2)
        self._team[k].biaoqian = self._team[k]:getChildByFullName("biaoqian")
        local currTxt = self._team[k]:getChildByFullName("biaoqian.txt")
        if currTxt then
            currTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
        end
        self._team[k].raceType = self._team[k]:getChildByFullName("raceType")
    -- local rgb = tab:Tujian(self._selectPokedex).rgb
    -- bg1:setColor(cc.c3b(rgb[1], rgb[2], rgb[3]))


        local pokedexModel = self._modelMgr:getModel("PokedexModel")
        local pokedexPos = pokedexModel:getDataById(self._selectPokedex)

-- 处理兵团上阵
        flag,pokedexKey = pokedexModel:getPokedexShangzhen(v.teamId)
        if flag then
            if self._team[k].shang then
                -- self._team[k].iconPlay:setCascadeOpacityEnabled(true) -- (-80)
                -- self._team[k].iconPlay:setOpacity(150)
                
                self._team[k].shang:setVisible(true)
                self._team[k].raceType:setVisible(true)
                -- self._team[k].shang:setOpacity(255)
                local rgb = tab:Tujian(tonumber(pokedexKey)).rgb
                self._team[k].raceType:setColor(cc.c3b(rgb[1], rgb[2], rgb[3]))
                -- print("======================", pokedexKey, tab:Tujian(tonumber(pokedexKey)).art)
                self._team[k].nameLab:setString((pokedexName[tonumber(tab:Tujian(tonumber(pokedexKey)).art)]) or "" .. "图鉴")
                -- self._team[k].nameLab:setColor(UIUtils.colorTable["ccColorQuality" .. tab:Tujian(tonumber(pokedexKey)).color])
                -- self._team[k].nameLab:enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2) -- (UIUtils.colorTable["ccColorQualityOutLine" .. tab:Tujian(tonumber(pokedexKey)).color], 2)
                -- -- self._team[k].tishiLab:setColor(UIUtils.colorTable["ccColorQuality" .. tab:Tujian(tonumber(pokedexKey)).color])
                -- self._team[k].tishiLab:enableOutline(UIUtils.colorTable.ccUICommonBtnColor4, 2) -- (UIUtils.colorTable["ccColorQualityOutLine" .. tab:Tujian(tonumber(pokedexKey)).color], 2)
                print("self._selectPokedex ======", self._selectPokedex, flag,pokedexKey)
                if self._selectPokedex == tonumber(pokedexKey) then
                    self._team[k].nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 
                    self._team[k].tishiLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                else
                    self._team[k].nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2) 
                    self._team[k].tishiLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
                end
            end 
            self._team[k].shangzhen:setTitleText("换阵")
        else
            self._team[k].shangzhen:setTitleText("上阵")
            self._team[k].nameLab:setString("空闲兵团")
            self._team[k].nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            self._team[k].raceType:setVisible(false)
            self._team[k].shang:setVisible(false)
            self._team[k].shang:setBrightness(0)
            self._team[k]:setBrightness(0)
        end

        local tempTeamId = self._modelMgr:getModel("PokedexModel"):getTeamShow({pokedexId = self._selectPokedex, posId = tonumber(self._posId)})
        if tempTeamId and tempTeamId ~= v.teamId then
            self._team[k].xiazhen:setVisible(false)
            self._team[k].shangzhen:setVisible(true)
            self._team[k].biaoqian:setVisible(false)
        else
            self._team[k].xiazhen:setVisible(true)
            self._team[k].shangzhen:setVisible(false)
            self._team[k].biaoqian:setVisible(true)
        end



        self._scrollView:addChild(self._team[k])
        self._team[k]:setPosition(cc.p(posX, posY))
        IconUtils:setTeamIconLevelVisible(self._team[k].iconPlay, false)
        -- IconUtils:setTeamIconStarVisible(iconPlay, false)
        IconUtils:setTeamIconStageVisible(self._team[k].iconPlay, false)
        posX = posX + 260
        if math.fmod(tonumber(k), 2) == 0 then
            posY = posY - 126
            posX = 11
        end
        -- if flag == true then
        --     self:registerClickEvent(self._team[k].iconPlay, function()
        --         self._viewMgr:showTip("该怪兽已上阵")
        --     end)

        -- else
            self:registerClickEvent(self._team[k].shangzhen, function()
                local param = {pokedexId = self._selectPokedex, putList = {{tonumber(self._posId),v.teamId}}}-- positionId = tonumber(self._posId), teamId = v.teamId}
                local teamFlag = pokedexModel:getTeamShow(param)
                if teamFlag then
                    self:close()
                else
                    self:putTeamOnPokedexPos(param)
                end
                
            end)
        -- end

            self:registerClickEvent(self._team[k].xiazhen, function()
                local posIdsTab = {}
                table.insert(posIdsTab,tonumber(self._posId))
                local param = {pokedexId = self._selectPokedex, posIds = posIdsTab}-- positionId = tonumber(self._posId), teamId = v.teamId}
                -- local teamFlag = pokedexModel:getTeamShow(param)
                -- if teamFlag then
                --     self:close()
                -- else
                    self:putOffTeamOnPokedexPos(param)
                -- end
            end)

        flag = false

    end
end

-- 怪兽上阵
function PokedexSelectTeam:putTeamOnPokedexPos(param)
    ViewManager:getInstance():lock(-1)
    self._serverMgr:sendMsg("PokedexServer", "putTeamOnPokedexPos", param, true, {}, function (result)
        if self._callback then
            self._callback()
        end
        audioMgr:playSound("PlaceDex")
        ViewManager:getInstance():unlock()
        if self.close then
            self:close()
        end
    end)
end

-- 怪兽下阵
function PokedexSelectTeam:putOffTeamOnPokedexPos(param)
    ViewManager:getInstance():lock(-1)
    self._serverMgr:sendMsg("PokedexServer", "putOffTeamOnPokedexPos", param, true, {}, function (result)
        if self._callback then
            self._callback()
        end
        audioMgr:playSound("PlaceDex")
        ViewManager:getInstance():unlock()
        if self.close then
            self:close()
        end
    end)
end

return PokedexSelectTeam