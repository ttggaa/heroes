--[[
    Filename:    TeamHeroNode1.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-03-31 20:29:25
    Description: File description
--]]

-- 兵团关联
local TeamHeroNode = class("TeamHeroNode", BaseLayer)

function TeamHeroNode:ctor()
    TeamHeroNode.super.ctor(self)
    self._heroNode = {}
end

function TeamHeroNode:onInit()
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._pokedexModel = self._modelMgr:getModel("PokedexModel")
    self._userModel = self._modelMgr:getModel("UserModel")

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)

    self._listNode1 = self:getUI("listNode1")
    self._listNode1:setVisible(false)
    self._listNode2 = self:getUI("listNode")
    self._listNode2:setVisible(false)

    local title = self:getUI("bg.scrollView.titleBg1")
    UIUtils:adjustTitle(title, 3, 1)
    local title = self:getUI("bg.scrollView.titleBg2")
    UIUtils:adjustTitle(title, 3, 1)

    -- local title = self:getUI("bg.scrollView.titleBg1.title")
    -- UIUtils:setTitleFormat(title, 3, 1)
    -- local title = self:getUI("bg.scrollView.titleBg2.title")
    -- UIUtils:setTitleFormat(title, 3, 1)

    self._title2 = self:getUI("bg.scrollView.titleBg2")
end

function TeamHeroNode:reflashUI(data)
    self._teamData = data.teamData
    if table.nums(self._heroNode) == 0 then
        self:createHeroNode()
    end
    self:updateHeroNode()
end

function TeamHeroNode:updateHeroNode()
    local userlvl = self._userModel:getData().lvl
    local relate = tab:Team(self._teamData.teamId).relate 
    dump(relate, "relate ============")
    local pokedexCount, heroCount = self:getCount()
    local relateNum = table.nums(relate)
    if relateNum == 0 then
        self._title2:setVisible(false)
    else
        self._title2:setVisible(true)
    end
    local nodeCount = 2 + relateNum
    local maxHeight = self._listNode1:getContentSize().height*pokedexCount + self._listNode2:getContentSize().height*relateNum
    maxHeight = maxHeight + 83
    if maxHeight < self._scrollView:getContentSize().height then
        maxHeight = self._scrollView:getContentSize().height
    end
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))

    local heroD, heroMastery 
    local special 
    local herosData = self._modelMgr:getModel("HeroModel"):getData()
    local tempFlag = true
    relateNum = table.nums(relate) + 2
    for i=1,8 do
        if i <= pokedexCount then
            local indexId = i
            local pokedexCell = self._heroNode[i]
            pokedexCell:setVisible(true)
            local pokedexId = self._teamModel:getPokedexIdByTeamId(self._teamData.teamId)
            local pokedexTab = tab:Tujian(pokedexId[i])

            -- dump(pokedexId)
            local pokedexPos = self._pokedexModel:getDataById(pokedexId[i])
            -- dump(pokedexPos, "pokedexPos")
            local pokeNum = self._pokedexModel:getPokedexOnTeamByIdNum(pokedexId[i]) or 0
            for j=1,5 do
                if pokeNum >= j then
                    pokedexCell["tujian" .. j]:loadTexture("pokeImg_pos" .. pokedexTab.color .. ".png", 1)
                else
                    pokedexCell["tujian" .. j]:loadTexture("pokeImg_posBg0.png", 1)
                end
            end

            pokedexCell.pokedexName:setString(lang(pokedexTab["name"]) .. "图鉴")
            pokedexCell.openLevel:setString(pokedexTab["level"] .. "级开启")
            if pokedexPos and userlvl >= pokedexTab["level"] then
                pokedexCell.openLevelPanel:setVisible(false)
                pokedexCell.shuoming:setVisible(true)

                local strValue = TeamUtils.getNatureNums(0.006 * pokedexPos.score) 
                local str = lang(pokedexTab.name) .. "兵团攻击+" .. strValue .. "%，生命+" .. strValue .. "%"
                pokedexCell.shuoming:setString(str)
            else
                pokedexCell.shuoming:setVisible(false)
                pokedexCell.openLevelPanel:setVisible(true)
            end
        elseif i > 2 and i <= relateNum then
            local indexId = i - 2
            tempFlag = false
            self._heroNode[i]:setVisible(true)
            heroD = clone(tab:Hero(relate[indexId][1]))
            -- special = heroD.special
            heroMastery = tab:HeroMastery(heroD.special * 10 + 1)


            self._heroNode[i].heroName:setString(lang(heroD.heroname))
            self._heroNode[i].featName:setString(lang(heroMastery.name))
            -- self._heroNode[i].openLabel:setString(lang("RELATE_" .. relate[indexId][2]))-- relate[i][2] .. "星生效")
            -- self._heroNode[i].openLabel:setString(lang(heroD.heroname) .. lang("RELATE_" .. relate[i][2]))-- relate[i][2] .. "星生效")

            local heroData = herosData[tostring(relate[indexId][1])]
            local heroStar
            if heroData then
                heroStar = heroData.star 
                self._heroNode[i].haveHero:setVisible(false)
            else
                heroStar = 0
                self._heroNode[i].haveHero:setVisible(true)
                -- self._heroNode[i].haveHero:setPositionX(self._heroNode[i].heroName:getPositionX()
                             -- + self._heroNode[i].heroName:getContentSize().width + 10)
            end
            if heroStar < relate[indexId][2][table.nums(relate[indexId][2])] then
                -- self._heroNode[i].permit:setSaturation(-100)
                self._heroNode[i].openLabel:setColor(cc.c3b(255,114,0))
                self._heroNode[i].openLabel:enableOutline(cc.c4b(81,19,0,255), 2)
                -- self._heroNode[i].openLabel:setColor(cc.c3b(255,46,46))
            else
                -- self._heroNode[i].permit:setSaturation(0)
                self._heroNode[i].openLabel:disableEffect()
                self._heroNode[i].openLabel:setColor(cc.c3b(116,62,34))
                self._heroNode[i].openLabel:setString(lang("RELATE_0"))
            end
            for j=1,4 do
                -- if j == heroStar then
                --     self._heroNode[i]["star" .. j]:setVisible(true)
                --     -- self._heroNode[i]["star" .. j]:loadTexture("globalImageUI6_star3.png", 1)
                --     -- self._heroNode[i]["star" .. j]:setVisible(true)
                -- else
                --     -- self._heroNode[i]["star" .. j]:loadTexture("globalImageUI6_star4.png", 1)
                --     self._heroNode[i]["star" .. j]:setVisible(false)
                -- end
                self._heroNode[i]["star" .. j]:setVisible(false)
            end

            -- self._heroNode[i].masteryIcon = self._heroNode[i].iconBg:getChildByName("masteryIcon")
            -- local tempHeroData = clone(heroD)
            -- tempHeroData.star = heroStar
            -- if heroStar == 0 then
            --     heroD.star = 1
            -- end

            self._heroNode[i].heroIcon = self._heroNode[i].heroIconBg:getChildByName("heroIcon")
            -- local param = {image = heroMastery.icon .. ".jpg", eventStyle = 1, heroData = heroD, star = heroStar}
            heroD.star = heroStar
            local param = {sysHeroData = heroD}
            if self._heroNode[i].heroIcon then
                IconUtils:updateHeroIconByView(self._heroNode[i].heroIcon, param)
            else
                self._heroNode[i].heroIcon =IconUtils:createHeroIconById(param)
                self._heroNode[i].heroIcon:setName("heroIcon")
                self._heroNode[i].heroIcon:setAnchorPoint(cc.p(0,0))
                self._heroNode[i].heroIcon:setScale(0.9)
                self._heroNode[i].heroIcon:setPosition(cc.p(0, -3))
                self._heroNode[i].heroIconBg:addChild(self._heroNode[i].heroIcon)
                self._heroNode[i].heroIcon:getChildByName("iconStar"):setPositionY(self._heroNode[i].heroIcon:getChildByName("iconStar"):getPositionY() + 10)
            end
            self._heroNode[i].heroIcon:getChildByName("starBg"):setVisible(false)

            for j=1,4 do
                local icon = self._heroNode[i]["headIcon" .. j] -- self._heroNode[i]:getChildByFullName("headIconBg.icon" .. i)
                local suo = icon:getChildByFullName("suo")
                if suo then
                    suo:setVisible(false)
                end
                local iconLock
                if j <= table.nums(relate[indexId][2]) then
                    if icon then
                        local globalHeroFrame = false
                        -- print("star======", heroD.global, relate[indexId][2][j])
                        if heroD.global == relate[indexId][2][j] then
                            globalHeroFrame = true
                        end
                        icon:setVisible(true)
                        local heroIcon = icon:getChildByName("heroIcon")
                        local heroMastery = tab:HeroMastery(heroD.special * 10 + relate[indexId][2][j])
                        local param = {image = heroMastery.icon .. ".jpg", eventStyle = 1, heroData = heroD, 
                                        star = relate[indexId][2][j], showCurStarOnly = true, heroFrame = relate[indexId][2][j],
                                        globalHeroFrame = globalHeroFrame}
                        if heroIcon then
                            IconUtils:updateTeamPlayIconByView(heroIcon, param)
                        else
                            print("lalalalallalala") 
                            heroIcon = IconUtils:createTeamPlayIconById(param)
                            heroIcon:setName("heroIcon")
                            heroIcon:setScale(0.45)
                            heroIcon:setPosition(cc.p(0, 0))
                            icon:addChild(heroIcon)
                        end
                        iconLock = heroIcon:getChildByFullName("iconColor"):getChildByFullName("iconLock")
                        if iconLock then
                            iconLock:setVisible(true)
                        end
                    end
                    if relate[indexId][2][j] <= heroStar then
                        if iconLock then
                            iconLock:setVisible(false)
                        end
                    end
                else
                    if icon then
                        icon:setVisible(false)
                    end
                end
            end
        else
            self._heroNode[i]:setVisible(false)
        end
    end
    self._title2:setVisible(not tempFlag)
    
    local titleBg1 = self:getUI("bg.scrollView.titleBg1")
    titleBg1:setPositionY(maxHeight-19)
    local titleBg2 = self:getUI("bg.scrollView.titleBg2")
    maxHeight = maxHeight - self._listNode1:getContentSize().height*pokedexCount - 48
    print("pokedexCount==========", pokedexCount)
    if pokedexCount == 1 then
        titleBg2:setPositionY(maxHeight-19)
        maxHeight = maxHeight - 9
        for i=1,3 do
            if i < (pokedexCount + 1) then
                self._heroNode[i]:setPosition(cc.p(96,maxHeight+20))
            else
                self._heroNode[i]:setPosition(cc.p(96,maxHeight + 14))
            end
            maxHeight = maxHeight - (self._heroNode[i]:getContentSize().height)
        end
    else
        titleBg2:setPositionY(maxHeight-19)
        for i=1,nodeCount do
            if i < 3 then
                self._heroNode[i]:setPosition(cc.p(96,maxHeight + 86))
            else
                self._heroNode[i]:setPosition(cc.p(96,maxHeight + 2))
            end
            maxHeight = maxHeight - (-1+self._heroNode[i]:getContentSize().height)
        end
    end

    self._scrollView:jumpToTop()
end

function TeamHeroNode:createHeroNode()
    local nodeCount = 8
    local maxHeight = self._listNode1:getContentSize().height*2 + self._listNode2:getContentSize().height*(nodeCount-2)+5*nodeCount
    maxHeight = maxHeight + 100
    self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))
    
    for i=1,nodeCount do
        if i < 3 then
            self._heroNode[i] = self._listNode1:clone()
            self._heroNode[i]:setName("pokedexNodeBg" .. i)

            self._heroNode[i].shuoming = self._heroNode[i]:getChildByFullName("shuoming")
            self._heroNode[i].shuoming:setFontSize(18)
            self._heroNode[i].shuoming:setFontName(UIUtils.ttfName)

            -- self._heroNode[i].zhuanchang = self._heroNode[i]:getChildByFullName("permit.zhuanchangBg.zhuanchang")
            -- self._heroNode[i].zhuanchang:setFontSize(22)
            -- self._heroNode[i].zhuanchang:setFontName(UIUtils.ttfName)
            -- self._heroNode[i].zhuanchang:disableEffect()
            -- self._heroNode[i].zhuanchang:setColor(cc.c3b(255, 255, 255))

            self._heroNode[i].pokedexName = self._heroNode[i]:getChildByFullName("pokedexName")
            self._heroNode[i].pokedexName:setFontSize(24)
            self._heroNode[i].pokedexName:setFontName(UIUtils.ttfName)        

            for j=1,5 do
                self._heroNode[i]["tujian" .. j] = self._heroNode[i]:getChildByFullName("tujian" .. j)
            end
            
            self._heroNode[i].openLevelPanel = self._heroNode[i]:getChildByFullName("openLevel")
            self._heroNode[i].openLevel = self._heroNode[i]:getChildByFullName("openLevel.openLevel")
            self._scrollView:addChild(self._heroNode[i])
        else
            self._heroNode[i] = self._listNode2:clone()
            self._heroNode[i]:setName("heroNodeBg" .. i)

            self._heroNode[i].zhuanchangBg = self._heroNode[i]:getChildByFullName("permit.zhuanchangBg")
            self._heroNode[i].zhuanchangBg:setOpacity(0)

            self._heroNode[i].featName = self._heroNode[i]:getChildByFullName("permit.zhuanchangBg.featName")
            self._heroNode[i].featName:setFontSize(18)
            self._heroNode[i].featName:setColor(cc.c3b(138, 92, 29))

            self._heroNode[i].zhuanchang = self._heroNode[i]:getChildByFullName("permit.zhuanchangBg.zhuanchang")
            self._heroNode[i].zhuanchang:setFontSize(18)
            self._heroNode[i].zhuanchang:setColor(cc.c3b(138, 92, 29))

            self._heroNode[i].heroName = self._heroNode[i]:getChildByFullName("permit.heroName")
            self._heroNode[i].heroName:disableEffect()
            self._heroNode[i].heroName:setFontSize(20)
            self._heroNode[i].heroName:setPositionY(self._heroNode[i].heroName:getPositionY())
            self._heroNode[i].heroName:setColor(cc.c3b(60,42,30))
            -- self._heroNode[i].heroName:enable2Color(2, cc.c4b(246, 147, 42, 255))
            -- self._heroNode[i].heroName:enableOutline(cc.c4b(27, 12, 4, 255), 1)

            for j=1,4 do
                self._heroNode[i]["star" .. j] = self._heroNode[i]:getChildByFullName("heroIconBg.star_" .. j)
                self._heroNode[i]["headIcon" .. j] = self._heroNode[i]:getChildByFullName("permit.headIconBg.icon" .. j)
            end
            
            self._heroNode[i].heroIconBg = self._heroNode[i]:getChildByFullName("heroIconBg")

            self._heroNode[i].openLabel = self._heroNode[i]:getChildByFullName("openLabel")
            self._heroNode[i].openLabel:setFontSize(18)
            self._heroNode[i].haveHero = self._heroNode[i]:getChildByFullName("haveHero")
            self._heroNode[i].haveHero:setVisible(false)
            self._heroNode[i].permit = self._heroNode[i]:getChildByFullName("permit")
            self._scrollView:addChild(self._heroNode[i])
        end
    end
end

function TeamHeroNode:getCount()
    local pokedexCount = 2
    -- if self._teamData.teamId == 907 then
    --     pokedexCount = 1
    -- end
    local heroCount = 3
    return pokedexCount, heroCount
end

return TeamHeroNode
