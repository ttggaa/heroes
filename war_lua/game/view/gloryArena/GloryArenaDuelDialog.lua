--[[
    FileName:       GloryArenaDuelDialog
    Author:         <dongcheng@playcrab.com>
    Datetime:       2018-08-20 16:57:40
    Description:
]]

local GloryArenaDuelDialog = class("GloryArenaDuelDialog", BasePopView)

function GloryArenaDuelDialog:ctor()
    self.super.ctor(self) 
end

function GloryArenaDuelDialog:getBgName()
     return "bg_jump.jpg"
end

--获取打开UI的时候加载的资源
function GloryArenaDuelDialog:getAsyncRes()
    return 
         {
            {"asset/ui/gloryArena.plist", "asset/ui/gloryArena.png"},
            {"asset/ui/newFormation2.plist", "asset/ui/newFormation2.png"},
            {"asset/ui/newFormation1.plist", "asset/ui/newFormation1.png"},  
            {"asset/ui/newFormation.plist", "asset/ui/newFormation.png"},
--            {"asset/ui/newFormation1.plist", "asset/ui/newFormation1.png"},
         }
end

local childName = {
    {name = "bg", childName = "bg"},
    {name = "rightbg_image", childName = "bg.rightbg_image"},
    {name = "leftbg_image", childName = "bg.leftbg_image"},
    {name = "top_lay", childName = "bg.top_lay"},
    {name = "Label_21", childName = "bg.Label_21"},
    {name = "battleBg_lay", childName = "bg.battleBg_lay"},
    {name = "middleCore_img", childName = "bg.middleCore_img"},
    {name = "leftScroe_img", childName = "bg.middleCore_img.leftScroe_img"},
    {name = "rightScore_img", childName = "bg.middleCore_img.rightScore_img"},
}

function GloryArenaDuelDialog:onRewardCallback(_, _x, _y, sender)
    if sender == nil or self._childNodeTable == nil then
        return 
    end
end


-- 初始化UI后会调用, 有需要请覆盖
function GloryArenaDuelDialog:onInit()
    self._childNodeTable = self:lGetChildrens(self._widget, childName)
    if self._childNodeTable == nil then
        return
    end
    self._preBGMName = audioMgr:getMusicFileName()
    audioMgr:playMusic("gloryArena_cry", true)
    self.popAnim = false
    -- self:disableTextEffect()
    self._childNodeTable.bg:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self._childNodeTable.battleBg_lay:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self._childNodeTable.top_lay:setContentSize(cc.size(MAX_SCREEN_WIDTH, self._childNodeTable.top_lay:getContentSize().height))
    self._childNodeTable.bg:addTouchEventListener(function(sender, _type)
        if _type == ccui.TouchEventType.ended then
            if self._timeUpdate then
                ScheduleMgr:unregSchedule(self._timeUpdate)
                self._timeUpdate = nil
            end
            self:showResultView(self._selfResultData, not self._isMeAtk)
            ScheduleMgr:cleanMyselfDelayCall(self)
--            self:close()
--            UIUtils:reloadLuaFile("gloryArena.GloryArenaDuelDialog")
--            package.loaded["script.game.common.NewHeroSoloPlayer"]  = nil
            
        end
    end)
    self:initTopLay()
    self._childNodeTable.battleBg_lay:setTouchEnabled(false)
    self._childNodeTable.middleCore_img:setVisible(false)
    self._childNodeTable.middleCore_img:setPositionX(MAX_SCREEN_WIDTH / 2)
    self._childNodeTable.middleCore_img:setLocalZOrder(2)

    self._touchLay = ccui.Layout:create()
    self._touchLay:setTouchEnabled(true)
    self._touchLay:setContentSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT))
    self._childNodeTable.bg:addChild(self._touchLay, 100)

    -- 防止流程中报错无法关界面
    ScheduleMgr:delayCall(8000, self, function( )
        if tolua.isnull(self._touchLay) then return end
            self._touchLay:setTouchEnabled(false)
    end)

end


--显示结算界面

function GloryArenaDuelDialog:showResultView(data, reverse)
    local battleinfo = {
    data = clone(data), result = clone(data), battleType = BattleUtils.BATTLE_TYPE_GloryArena, _bIsPlayBack = true,
    callback = nil,
    }
    battleinfo.data.reverse = reverse
    battleinfo.result.reverse = reverse

    battleinfo.result.reward = self._resultData.rewards or {}
    -- if reverse then
    --     local left = battleinfo.result.leftData
    --     local right = battleinfo.result.rightData
    --     battleinfo.result.leftData = right
    --     battleinfo.result.rightData = left
    -- end
--    if self._preBGMName then
----        print("++++++++++++12", self._preBGMName)
--        audioMgr:playMusic(self._preBGMName, true)
--    end
    self._viewMgr:showDialog("battle.BattleResultGloryArena", battleinfo, true, true, function()
        self:close()
        UIUtils:reloadLuaFile("gloryArena.GloryArenaDuelDialog")
    end, true)
end

-- 接收自定义消息
function GloryArenaDuelDialog:reflashUI(data)
    self._resultData = data
--    dump(data)
    self._selfName = "atk"
    self._enemyName = "def"
    self._win = false
    self._isMeAtk = false
    self._selfResultData = {}
    self:updateUI(data)
end

function GloryArenaDuelDialog:updateUI()
    if self._resultData then
        local userId = self._modelMgr:getModel("UserModel"):getUID()
        local isMeAtk = userId == self._resultData.atkId
        self._isMeAtk = isMeAtk
        local direction = "left"
        if not isMeAtk then
            self._selfName = "def"
            self._enemyName = "atk"
            direction = "right"
        end

        if (self._resultData.win == 1 and isMeAtk) or (self._resultData.win == 2 and not isMeAtk) then
             self._win = true
        end
        
--        self:updateTopLay()
        self:updateMiddle()


        --结算界面拼接数据
        local leftData = {}
        if self._resultData.lastBattle and self._resultData.lastBattle.teamInfo then
            
            for i,v in pairs(self._resultData.lastBattle.teamInfo[direction .. "Team"]) do
                if v and tonumber(i) then
                    local localTeamData = {}
                    localTeamData.D = {}
                    localTeamData.D.id = tonumber(i)
                    localTeamData.damage = v["damage"]
                    localTeamData.original = true
                    leftData[#leftData + 1] = localTeamData
                end
            end

        end

        self._childNodeTable.Label_21:setVisible(false)
        self._childNodeTable.Label_21:setPositionX(MAX_SCREEN_WIDTH * 0.5)
        self._selfResultData._rank = self._resultData[self._selfName .. "Rank"]
        self._selfResultData.win = (self._resultData.win == 1)--self._win
        self._selfResultData.battles = clone(self._resultData.battles)
        self._selfResultData.hero1 = {}
        self._selfResultData.leftData = leftData
        self._selfResultData._enemyRank = self._resultData[self._enemyName .. "Rank"]
        self._selfResultData.dataSec = self._resultData.dataSec
        self._selfResultData.change = self._resultData.change
--        self._selfResultData.result = {}
--        self._selfResultData.result.reward = self._resultData.rewards
    end
end

function GloryArenaDuelDialog:onPopEnd()
    self:lAddBattleUi()
--    self._touchLay:setTouchEnabled(false)
end

function GloryArenaDuelDialog:lGetGroupID(score1, score2)
    local pro = score1 / score2
    local data = tab.honorArenaSoloGroup
    for key, var in ipairs(data) do
        if var and pro >= var.trigger[1] and pro < var.trigger[2] then
            return var.id
        end
    end
    return 1
end

function GloryArenaDuelDialog:lAddBattleUi()
    if self._resultData and self._resultData.battles then

--        local NewHeroSoloPlayer = require "script.game.common.NewHeroSoloPlayer"
        if not self._solo then
            self._solo = NewHeroSoloPlayer.new()
            self._solo:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5 - 160)
            self._childNodeTable.battleBg_lay:addChild(self._solo)
        end

        local heroData1 = {}
        local heroData2 = {}
        local groupID1 = {}
        -- 入场位置
        local initPos = { {- MAX_SCREEN_WIDTH * 0.5 - 600, 160},{- MAX_SCREEN_WIDTH * 0.5 - 400, 40},{- MAX_SCREEN_WIDTH * 0.5 - 600, -100}, { MAX_SCREEN_WIDTH * 0.5 + 300, 160},{ MAX_SCREEN_WIDTH * 0.5 + 400, 40},{ MAX_SCREEN_WIDTH * 0.5 + 300, -100}}
        -- 战斗位置
        local battlePos = {{-200, 160},{-100, 40},{-100, -100}, {100, 160}, {200, 40}, {200, -100}}
        local atkCamp1 = {}
        for key, var in ipairs(self._resultData.battles) do
            if var then
                local leftData = {}
                local rightData = {}
                local isWin = false
                if (self._selfName == "atk" and var.win == 1) or (self._selfName == "def" and var.win == 2) then
                    isWin = true
                end
                leftData.heroID = var[self._selfName .. "HeroId"] or 60102
                leftData.name = "" --"神勇妖皇" .. key
                leftData.HP_begin = 8
                leftData.HP_end = 0
                leftData.HP_color = 1
                leftData.startPos = cc.p(initPos[key][1], initPos[key][2])
                leftData.battlePos = cc.p(battlePos[key][1], battlePos[key][2])
--                leftData.isWin = isWin
                atkCamp1[key] = isWin and 1 or 2

                heroData1[#heroData1 + 1] = leftData

                rightData.heroID = var[self._enemyName .. "HeroId"] or 60102
                rightData.name = "" --"神勇妖皇" .. key
                rightData.HP_begin = 8
                rightData.HP_end = 0
                rightData.HP_color = 2
                rightData.startPos = cc.p(initPos[key + 3][1], initPos[key + 3][2])
                rightData.battlePos = cc.p(battlePos[key + 3][1], battlePos[key + 3][2])
--                rightData.isWin = not isWin

                heroData2[#heroData2 + 1] = rightData

                local atkScore = var[self._selfName .. "Score"] or 0
                local defScore = var[self._enemyName .. "Score"] or 1
                if not isWin then
                    atkScore = var[self._enemyName .. "Score"] or 0
                    defScore = var[self._selfName .. "Score"] or 1
                end

                groupID1[key] = self:lGetGroupID(atkScore, defScore)
            end
        end
        

        local param = {
            info1 = heroData1,
            info2 = heroData2,
            scale = 0.4,
            groupID = groupID1,
            --由于表里面攻击方都是胜利，所以这需要和上面的胜利做处理
            atkCamp = atkCamp1,
        }
    
        self._solo:init(param, function()
            if self._timeUpdate then
                ScheduleMgr:unregSchedule(self._timeUpdate)
                self._timeUpdate = nil
            end
            self._timeUpdate = ScheduleMgr:regSchedule(1500,self,function()
                self._solo:walkLeave(nil, function()
                    self._solo:clear()
                    self._childNodeTable.battleBg_lay:setVisible(false)
                    self:readyAnimation()
--                    if self.__viewBg then
--                        self.__viewBg:setVisible(false)
--                    end
                    if self._timeUpdate then
                        ScheduleMgr:unregSchedule(self._timeUpdate)
                        self._timeUpdate = nil
                    end
                end)
            end)
        end)
    end
    

end

local childTopName = {
    {name = "left_img", childName = "left_img"},
    {name = "right_img", childName = "right_img"},
    {name = "middle_img", childName = "middle_img"},
    {name = "hero_lay", childName = "hero_lay", starNum = 1, endNum = 6},
    {name = "middle_lay", childName = "middle_lay"},
}

function GloryArenaDuelDialog:initTopLay()
    self._childNodeTable.top_lay:setVisible(false)
    self._childNodeTable.top_lay:setTouchEnabled(false)
--    self._topCard = {{}, {}}
--    local childNodeTable = self:lGetChildrens(self._childNodeTable.top_lay, childTopName)
--    if childNodeTable then
--        local topBg = ccui.ImageView:create()
--        topBg:loadTexture("asset/bg/gloryArena_topBg.png", ccui.TextureResType.localType)
--        topBg:setScale9Enabled(true)
--        topBg:setContentSize(cc.size(MAX_SCREEN_WIDTH, 149))
--        topBg:setAnchorPoint(cc.p(0.5, 0.5))
--        topBg:setPosition(cc.p(MAX_SCREEN_WIDTH / 2, self._childNodeTable.top_lay:getContentSize().height / 2))
--        self._childNodeTable.top_lay:addChild(topBg, -1)

--        childNodeTable.left_img:setPositionX(0)
--        childNodeTable.right_img:setPositionX(MAX_SCREEN_WIDTH)
--        childNodeTable.middle_img:setContentSize(cc.size(MAX_SCREEN_WIDTH - 40, 16))
--        childNodeTable.middle_img:setPositionX(MAX_SCREEN_WIDTH / 2)
--        childNodeTable.middle_lay:setPositionX(MAX_SCREEN_WIDTH / 2 - childNodeTable.middle_lay:getContentSize().width / 2)
--        for key, var in ipairs(childNodeTable.hero_lay) do
--            if var then
--                local offsetX = 0
--                local skew = 6
--                local index = 0
--                local isLeft = 1
--                if key <= 3 then
--                    index = 4- key
--                    offsetX = (key - 4) * 112 - 94
--                else
--                    isLeft = 2
--                    index = key - 3
--                    skew = -1 * skew
--                    offsetX = (key - 3) * 112
--                end
--                var:setPositionX(MAX_SCREEN_WIDTH / 2 + offsetX)

--                local card = CardUtils:createHeroDuelHeroCard({heroD = clone(tab.hero[60001])})
--                card:setAnchorPoint(cc.p(0.5, 0.5))
--                card:setPositionType(POSITION_PERCENT)
--                card:setPositionPercent(cc.p(0.5, 0.5))
--                card:setScale(0.35, 0.29)
--                card:setSkewX(skew)
--                card:setName("card")
--                var:getChildByName("hero_img"):addChild(card, 10)
--                var:getChildByName("heroBg_img"):setVisible(false)
--                local heroOrderBg_img = var:getChildByName("heroOrderBg_img")
--                local number = cc.LabelBMFont:create(index, UIUtils.bmfName_Lottery)
--                number:setName("number")
--                number:setScale(0.2)
--                number:setAnchorPoint(cc.p(0.5, 0.5))
--                number:setPosition(cc.p(heroOrderBg_img:getContentSize().width / 2, heroOrderBg_img:getContentSize().height / 2 + 5))
----                number:setPosition(cc.p(heroOrderBg_img))
--                heroOrderBg_img:addChild(number)
--                self._topCard[isLeft][index] = var:getChildByName("hero_img")
--            end

--        end

--    end
end

function GloryArenaDuelDialog:updateTopLay()
    local childNodeTable = self:lGetChildrens(self._childNodeTable.top_lay, childTopName)
    if childNodeTable then
         for key, var in ipairs(childNodeTable.hero_lay) do
            if var then
                local card = var:getChildByFullName("hero_img.card")
                local strName = key <= 3 and self._selfName or self._enemyName
                local count = key <= 3 and (4 - key) or (key - 3)
                if self._resultData.battles[count] then
                    local heroId = self._resultData.battles[count][strName .. "HeroId"]
                    if card and heroId then
                        CardUtils:updateHeroDuelHeroCard(card, {heroD = clone(tab.hero[heroId])})
                    end
                end
            end
        end
    end
end

local childMiddleName = {
    {name = "desBg_lay", childName = "desBg_lay"},
    {name = "heroBg_lay", childName = "heroBg_lay"},
    {name = "rank_lab", childName = "desBg_lay.rank_lab"},
    {name = "name_lab", childName = "desBg_lay.name_lab"},
--    {name = "score_lab", childName = "score_lab"},
    {name = "animation_lay", childName = "heroBg_lay.animation_lay", starNum = 1, endNum = 3},
    {name = "heroIcon_lay", childName = "heroBg_lay.heroIcon_lay"},
    {name = "changeScore_img", childName = "desBg_lay.changeScore_img"},
}

function GloryArenaDuelDialog:updateMiddle()

    self._animationTable = {{}, {}}
    local rightChildNodeTable = self:lGetChildrens(self._childNodeTable.rightbg_image, childMiddleName)
    local leftChildNodeTable = self:lGetChildrens(self._childNodeTable.leftbg_image, childMiddleName)

    local rightWith = self._childNodeTable.rightbg_image:getContentSize()
    local leftWith = self._childNodeTable.leftbg_image:getContentSize()

    local middle_img = ccui.ImageView:create()
    middle_img:loadTexture("asset/bg/gloryArena_DuelBg.png", ccui.TextureResType.localType)
    middle_img:setScale9Enabled(true)
    middle_img:setAnchorPoint(cc.p(0.5, 0))
    middle_img:setContentSize(cc.size(MAX_SCREEN_WIDTH, self._childNodeTable.leftbg_image:getContentSize().height))
    middle_img:setPosition(cc.p(MAX_SCREEN_WIDTH / 2, self._childNodeTable.leftbg_image:getPositionY()))

    self._middle_img = middle_img

    self._childNodeTable.bg:addChild(middle_img, -2)

    local animationBg = mcMgr:createViewMC("rongyaojiesuanlianxian_rongyaojingjichangjiesuan", false, true)
    animationBg:setPosition(cc.p(MAX_SCREEN_WIDTH / 2, middle_img:getPositionY() + leftWith.height / 2))
    animationBg:setVisible(false)
--    animationBg:gotoAndStop(5)
    self._childNodeTable.bg:addChild(animationBg, -1)
    animationBg:stop()
    self._animationBg = animationBg
    
    

    self._animationMiddle = mcMgr:createViewMC("baozhaguangxiao_rongyaobaozhaguangxiao", false, true)
    self._animationMiddle:setPosition(cc.p(MAX_SCREEN_WIDTH / 2, self._childNodeTable.middleCore_img:getPositionY()))
    self._childNodeTable.bg:addChild(self._animationMiddle, 1)
    self._animationMiddle:stop()
    self._animationMiddle:setVisible(false)

--    self._heroImage = {}
--    self._resultImage = {}
    if rightChildNodeTable == nil or leftChildNodeTable == nil then
        return
    end

    local changeRank = 0
    self._win = false
    if self._selfName == "atk" and self._resultData.win == 1 then
        changeRank = self._resultData[self._enemyName .. "Rank"] - self._resultData[self._selfName .. "Rank"]
        self._win = true
    elseif self._selfName == "def" and self._resultData.win == 2 then
        changeRank = self._resultData[self._enemyName .. "Rank"] - self._resultData[self._selfName .. "Rank"]
        self._win = true
    end
    local isUp = 2
    if self._win and changeRank > 0 then
        isUp = 1
    elseif changeRank == 0 then
        isUp = 3
    end
    local function initLayout(tableNode, strName, isMeAtk, bIsLeft)
        
        self._animationTable[(bIsLeft and 1 or 2)].heroIcon_lay = tableNode.heroBg_lay
        self._animationTable[(bIsLeft and 1 or 2)].desBg_lay = tableNode.desBg_lay
        tableNode.rank_lab:setString(self._resultData[strName .. "Rank"])
        tableNode.name_lab:setString(self._resultData[strName .. "Name"])
        local result = self._resultData.battles
        local isWinCount = 0
        if result then
            tableNode.changeScore_img:ignoreContentAdaptWithSize(true)
            if isUp == 3 then
                tableNode.changeScore_img:setVisible(false)
            elseif isUp == 2 then
                if bIsLeft then
                    tableNode.changeScore_img:loadTexture("globalImageUI4_downArrow2.png", ccui.TextureResType.plistType)
                else
                    tableNode.changeScore_img:loadTexture("globalImageUI4_upArrow2.png", ccui.TextureResType.plistType)
                end
            elseif isUp == 1 then
                if not bIsLeft then
                    tableNode.changeScore_img:loadTexture("globalImageUI4_downArrow2.png", ccui.TextureResType.plistType)
                else
                    tableNode.changeScore_img:loadTexture("globalImageUI4_upArrow2.png", ccui.TextureResType.plistType)
                end
            end
            tableNode.changeScore_img:setPositionX(tableNode.rank_lab:getPositionX() + tableNode.rank_lab:getContentSize().width + 18)
            if self._resultData.change and self._resultData.change == 0 then
                tableNode.changeScore_img:setVisible(false)
            end
            for key, var in pairs(tableNode.animation_lay) do
                local data = result[key]
                if var then
                    local isWin = false
                    if (strName == "atk" and data.win == 1) or (strName == "def" and data.win == 2) then
                        isWin = true
                        isWinCount = isWinCount + 1
                    end
                    local heroId = data[strName .. "HeroId"]
                    local skinId = data[strName .. "SkinId"]
                    local heroData = clone(tab.hero[heroId])
                    if heroData then
                        heroData.star = 0
--                        heroData.skin = skinId
                        local icon = IconUtils:createHeroIconById({sysHeroData = heroData})
                        icon:setScale(0.6)
                        icon:setCascadeOpacityEnabled(true)
                        icon:setPosition(cc.p(30, 30))
                        var:setCascadeOpacityEnabled(true)
                        var:addChild(icon)
                        self._animationTable[(bIsLeft and 1 or 2)]["icon" .. key] = icon
                        self._animationTable[(bIsLeft and 1 or 2)]["isWin" .. key] = isWin
--                        if not isWin then
--                            icon:setSaturation(-100)
--                        end
                        if key == 1 then    
                            local heroImage = cc.Sprite:create("asset/uiother/hero/" .. heroData.crusadeRes .. ".png")--ccui.ImageView:create()
--                            heroImage:loadTexture( "asset/uiother/hero/" .. heroData.crusadeRes .. ".png", ccui.TextureResType.localType)
                            heroImage:setPosition(heroData.crusadePosi[1], heroData.crusadePosi[2])
                            heroImage:setScale(bIsLeft and 0.9 or -0.9, 0.9)
                            heroImage:setAnchorPoint(0.5,0)
                            tableNode.heroIcon_lay:setClippingEnabled(false)
                            tableNode.heroIcon_lay:addChild(heroImage)
                            
                            tableNode.heroIcon_lay:setPositionX(bIsLeft and 80 or (tableNode.heroBg_lay:getContentSize().width - tableNode.heroIcon_lay:getContentSize().width - 200))
                        end
                    end
                    if isWin then
                        local win = ccui.ImageView:create("gloryArena_Dule_win.png", ccui.TextureResType.plistType)
                        win:setAnchorPoint(cc.p(0.5, 0.5))
                        win:setPosition(cc.p(10, 50))
                        win:setVisible(false)
                        var:addChild(win)
                        self._animationTable[(bIsLeft and 1 or 2)]["win" .. key] = win
                    end 
                end
            end
        end
        if bIsLeft then
            self._childNodeTable.leftScroe_img:loadTexture("gloryArena_number_" .. isWinCount ..".png", ccui.TextureResType.plistType)
        else
            self._childNodeTable.rightScore_img:loadTexture("gloryArena_number_" .. isWinCount ..".png", ccui.TextureResType.plistType)
        end
--        tableNode.score_lab:loadTexture("gloryArena_number_" .. isWinCount ..".png", ccui.TextureResType.plistType)
    end

    
    initLayout(rightChildNodeTable, self._enemyName, self._isMeAtk, false)
    initLayout(leftChildNodeTable, self._selfName, self._isMeAtk, true)
--    self._childNodeTable.rightbg_image:setVisible(true)
--    self._childNodeTable.leftbg_image:setVisible(true)

    

    self._childNodeTable.leftbg_image:setPositionX(0)--(-1 * rightWith.width)
    self._childNodeTable.rightbg_image:setPositionX(MAX_SCREEN_WIDTH - rightWith.width)--(MAX_SCREEN_WIDTH + rightWith.width)
    self:startAction(1)
--    self:readyAnimation()
end

function GloryArenaDuelDialog:readyAnimation()
    audioMgr:stopMusic()
	audioMgr:playSoundForce("gloryArena_win")
    self._childNodeTable.leftbg_image:setVisible(true)
    self._childNodeTable.rightbg_image:setVisible(true)
    self._middle_img:setVisible(true)
    self._middle_img:setScale(0.5)
    self._childNodeTable.middleCore_img:setVisible(false)
    self._childNodeTable.middleCore_img:setCascadeOpacityEnabled(true)
    self._childNodeTable.middleCore_img:setOpacity(0)
    self._childNodeTable.middleCore_img:setScale(2.0)
    self._childNodeTable.middleCore_img:setOpacity(50)
    for key, var in ipairs(self._animationTable) do
        if var then
            var.heroIcon_lay:setCascadeOpacityEnabled(true)
            var.heroIcon_lay:setOpacity(0)
            local offsetX = 300
            if key == 2 then
                offsetX = -300
            end
            var.heroIcon_lay:setPositionX(var.heroIcon_lay:getPositionX() - offsetX)
            var.desBg_lay:setCascadeOpacityEnabled(true)
            var.desBg_lay:setOpacity(0)
            var.desBg_lay:setScale(0.7)
        end
    end
    self:startAction(2)
end

function GloryArenaDuelDialog:bIsNodeNull(sender)
    if sender and not tolua.isnull(sender) then
        return true
    end
    return false
end

function GloryArenaDuelDialog:startAction(nIndex)
--    print(nIndex)
--    print(debug.traceback())
    if nIndex == 1 then
        self._childNodeTable.Label_21:setVisible(false)
        self._childNodeTable.leftbg_image:setVisible(false)
        self._childNodeTable.rightbg_image:setVisible(false)
        self._middle_img:setVisible(false)
    elseif nIndex == 3 then
        self._childNodeTable.Label_21:setVisible(true)
        self._touchLay:setTouchEnabled(false)
    elseif nIndex == 2 then
        self._middle_img:runAction(cc.Sequence:create(cc.EaseOut:create(cc.ScaleTo:create(0.1, 1.0), 3), 
    --        cc.ScaleTo:create(0.07, 1.0),
            cc.CallFunc:create(function ()
                local function run(sender, isLeft)
                    if self._animationBg and not tolua.isnull(self._animationBg) then
                        self._animationBg:setVisible(true)
                        self._animationBg:play()
                    end
                
                    if sender.heroIcon_lay and not tolua.isnull(sender.heroIcon_lay ) then
                        sender.heroIcon_lay:runAction(cc.Sequence:create(
                            cc.Spawn:create(
                                cc.FadeIn:create(0.2),
                                cc.MoveBy:create(0.18, cc.p(isLeft and 300 or -300, 0))
                            ),
                            cc.DelayTime:create(0.18),
                            cc.CallFunc:create(function()
                                    for i = 1, 3  do
                                        if self:bIsNodeNull(sender["icon" .. i]) and not sender["isWin" .. i] then
                                            sender["icon" .. i]:setSaturation(-100)
                                        end

                                        if self:bIsNodeNull(sender["win" .. i]) then
                                            sender["win" .. i]:setScale(1.5)
                                            sender["win" .. i]:setVisible(true)
                                            sender["win" .. i]:setOpacity(0)
                                            sender["win" .. i]:runAction(
                                                cc.Spawn:create(
                                                    cc.EaseOut:create(cc.ScaleTo:create(0.06, 1.0), 1),
                                                    cc.FadeIn:create(0.06)
                                                )
                                            )
                                        end
                                    end
                                end)
                            ))
                    end
                    if sender.desBg_lay and not tolua.isnull(sender.heroIcon_lay ) then
                        sender.desBg_lay:runAction(
                            cc.FadeIn:create(0.18)
                        )
                    end
                    if not isLeft and self:bIsNodeNull(self._childNodeTable.middleCore_img) then
    --                    self._childNodeTable.middleCore_img:setVisible(true)
                        self._childNodeTable.middleCore_img:runAction(cc.Sequence:create(
                                cc.DelayTime:create(0.23),
                                cc.CallFunc:create(function() 
                                    self._childNodeTable.middleCore_img:setVisible(true) 
                                    if self:bIsNodeNull(self._animationMiddle) then
                                        self._animationMiddle:setVisible(true)
                                        self._animationMiddle:play()
                                    end
                                    self:startAction(3)
                                end),
                                cc.Spawn:create(
                                    cc.EaseIn:create(cc.ScaleTo:create(0.04, 1.0), 3),
                                    cc.FadeIn:create(0.04)
                                )
                            ))
                    end
                end
                run(self._animationTable[1], true)
                run(self._animationTable[2], false)
        end)))
    end

    
--    if nIndex == 2 then
--        local function runAction(sender, heroImage, bIsLeft)
--            local sSize = sender:getContentSize()
--            local dis = bIsLeft and sSize.width * 1.5 or (sSize.width * -1.5)
--    --        local posY = sender:getPositioY()
--            sender:runAction(cc.Sequence:create(
--                cc.MoveBy:create(0.2, cc.p(dis , 0)),
--                cc.CallFunc:create(function()
--                    for key, var in ipairs(heroImage) do
--                        if var then
--                            var:runAction(cc.Sequence:create(
--                                cc.DelayTime:create((key - 1) * 0.08),
--                                cc.MoveBy:create(0.08, cc.p(bIsLeft and 300 or -300, 0))
--                            ))
--                        end
--                    end

--                    for key, var in ipairs(self._resultImage) do
--                        if var then
--                            var:setVisible(true)
--                            var:setScale(2.0)
--                            var:runAction(cc.Sequence:create(
--                                cc.DelayTime:create(0.08),
--                                cc.ScaleTo:create(0.06, 1.0)                
--                            ))
--                        end
--                    end

--                    self._childNodeTable.middleCore_img:setVisible(true)
--                    self._childNodeTable.middleCore_img:setScale(1.5)
--                    self._childNodeTable.middleCore_img:runAction(cc.Sequence:create(
--                        cc.DelayTime:create(0.2),
--                        cc.ScaleTo:create(0.08, 1.0)                
--                    ))

--                end)
--            ))

--        end
--        runAction(self._childNodeTable.leftbg_image, self._heroImage[1], true)
--        runAction(self._childNodeTable.rightbg_image, self._heroImage[2], false)
--    elseif nIndex == 1 then
--        local function runAction(cardTable, bIsLeft)
--            for key, var in ipairs(cardTable) do
--                if var then
--                    var:runAction(cc.Sequence:create(
--                        cc.DelayTime:create(0.05 * (key - 1)),
--                        CCOrbitCamera:create(0.5, 1, 0, 90 * (key - 1) * (bIsLeft and 1 or -1), (-1080 + (360) * key - 90 * (key - 1)) * (bIsLeft and 1 or -1), 0, 0)
--                    ))
--                end            
--            end
--        end
--        runAction(self._topCard[1] or {}, true)
--        runAction(self._topCard[2] or {}, false)
--    end
end

---- 销毁
--function GloryArenaDuelDialog:onDestroy()
--    if self._preBGMName then
--        audioMgr:playMusic(self._preBGMName, true)
--    end

--end

function GloryArenaDuelDialog:dtor(args)
    childName = nil
    childTopName = nil
end



return GloryArenaDuelDialog

