--[[
    Filename:    TeamUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-11-10 17:52:03
    Description: File description
--]]

local TeamUtils = {}

TeamUtils.TEAM_MAX_STAGE = 14
TeamUtils.TEAM_MAX_LEVEL = 100

-- 里属性等级
TeamUtils.hPotentialStar = 40
TeamUtils.teamMaxTalentLevel = 16

TeamUtils.TEAM_STAGE_1 = 1 -- 白色
TeamUtils.TEAM_STAGE_2 = 2 -- 绿色
TeamUtils.TEAM_STAGE_3 = 3 -- 蓝色
-- TeamUtils.TEAM_STAGE_3 = 3 -- 蓝色

TeamUtils.TalentXishu = {1, 4, 0.2} -- 兵团天赋系数

TeamUtils.awakingRaceLineColor = { -- 觉醒界面线颜色
    [1] = {contrast = 0, brightness = 0, saturation = 0, hue = -85},
    [2] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [3] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [4] = {contrast = 0, brightness = 0, saturation = 0, hue = -85},
    [5] = {contrast = 40, brightness = -25, saturation = 20, hue = -145},
    [6] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [7] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [8] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [9] = {contrast = 0, brightness = 0, saturation = 31, hue = 180},
}

TeamUtils.awakingRaceColor = { -- 觉醒界面罩子颜色
    [1] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [2] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [3] = {contrast = 0, brightness = -15, saturation = 4, hue = 53},
    [4] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [5] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [6] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [7] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [8] = {contrast = 0, brightness = 0, saturation = 0, hue = 0},
    [9] = {contrast = 0, brightness = 0, saturation = 0, hue = -26},
}

------------------------------------------------
-------------兵团宝石-----------------------
TeamUtils.qualityMC = {
    -- [1] = "cheng_shenghuitubiao",
    [2] = "lv_shenghuitubiao",
    [3] = "lan_shenghuitubiao",
    [4] = "zi_shenghuitubiao",
    [5] = "cheng_shenghuitubiao",
    [6] = "hong_shenghuitubiao",
}
---------------------------------------------------

-- 争霸赛胜败图
TeamUtils.godWarWinImg = {
    [1] = "godwarImageUI_img62.png",
    [2] = "godwarImageUI_img63.png",
    [3] = "godwarImageUI_img64.png",
    [4] = "godwarImageUI_img70.png",
}


TeamUtils.hStarImg = {
    [1] = "teamImageUI_img49.png",
    [2] = "teamImageUI_img48.png",
    [3] = "teamImageUI_img50.png",
}
TeamUtils.frameStarImg = {
    [1] = "teamImageUI_img42.png",
    [2] = "teamImageUI_img41.png",
    [3] = "teamImageUI_img43.png",
}

TeamUtils.teamRaceType = {
    [101] = 6,
    [102] = 7,
    [103] = 8,
    [104] = 9,
    [105] = 10,
    [106] = 11,
    [108] = 12,
    [109] = 13,
}

local teamRolesMap = {
	[1] = {
		{pos = cc.p(0,0),scale = 1,zOrder = 1}
	},
	[4] = {
		{pos = cc.p(0,0),scale = 1.15,zOrder = 2},
		
		{pos = cc.p(-75,40),scale = 1,zOrder = 1},
		{pos = cc.p(75,40),scale = 1,zOrder = 1},
		
		{pos = cc.p(0,75),scale = 0.8,zOrder = 0},
	},
	[9] = {
		{pos = cc.p(0,0),scale = 1.25,zOrder = 4},
		
		{pos = cc.p(-90,30),scale = 1.15,zOrder = 3},
		{pos = cc.p(90,30),scale = 1.15,zOrder = 3},
		
		{pos = cc.p(-155,90),scale = 1,zOrder = 2},
		{pos = cc.p(-52,90),scale = 1,zOrder = 2},
		{pos = cc.p(52,90),scale = 1,zOrder = 2},
		{pos = cc.p(155,90),scale = 1,zOrder = 2},
		
		{pos = cc.p(-70,135),scale = 0.8,zOrder = 1},
		{pos = cc.p(70,135),scale = 0.8,zOrder = 1},
	},
	[16] = {
		{pos = cc.p(0,0),scale = 1.25,zOrder = 6},
		
		{pos = cc.p(-65,32),scale = 1.15,zOrder = 5},
		{pos = cc.p(65,32),scale = 1.15,zOrder = 5},
		
		{pos = cc.p(-122,85),scale = 1,zOrder = 4},
		{pos = cc.p(-40,85),scale = 1,zOrder = 4},
		{pos = cc.p(40,85),scale = 1,zOrder = 4},
		{pos = cc.p(122,85),scale = 1,zOrder = 4},
		
		{pos = cc.p(-150,125),scale = 0.8,zOrder = 3},
		{pos = cc.p(-90,125),scale = 0.8,zOrder = 3},
		{pos = cc.p(-30,125),scale = 0.8,zOrder = 3},
		{pos = cc.p(30,125),scale = 0.8,zOrder = 3},
		{pos = cc.p(90,125),scale = 0.8,zOrder = 3},
		{pos = cc.p(150,125),scale = 0.8,zOrder = 3},
		
		{pos = cc.p(-70,135),scale = 0.75,zOrder = 2},
		{pos = cc.p(70,135),scale = 0.75,zOrder = 2},
		
		{pos = cc.p(0,145),scale = 0.7,zOrder = 1},
	},

}

local teamSpecialPosOff = {
    [107] = cc.p(0,20),
    [307] = cc.p(0,10),
    [907] = cc.p(20,0),
    [402] = cc.p(0,60),
    [403] = cc.p(0,-20),
    [404] = cc.p(0,-10),
    [401] = cc.p(-10,-10),
    [503] = cc.p(0,20),
    [507] = cc.p(0,10),
    [607] = cc.p(0,20),
}
local teamVolume = {25,16,9,4,1}
TeamUtils.showTeamRoles = function( teamId,teamNum )
	local teamBgNode = ccui.Widget:create()
	-- teamBgNode:set
	-- dump(teamRoleMap)
	local teamD = tab:Team(teamId or 101)
	teamNum = teamNum or teamVolume[tonumber(teamD.volume)]
    local sizeLim = {}
    if teamNum > 1 then
        sizeLim.width = 140
        sizeLim.height = 160
    end
	local teamRoleMap = teamRolesMap[teamNum] or {}
	local artZoom = teamD.artzoom/100
	local posScaleX,posScaleY = 0.6*artZoom,0.6*artZoom
	local offsetY = teamRoleMap[#teamRoleMap].pos.y*posScaleY*0.5
	for i,roleInfo in ipairs(teamRoleMap) do
        local teamImg = ccui.ImageView:create()
        local filename = "asset/uiother/steam/" .. teamD.steam .. ".png"
        local fu = cc.FileUtils:getInstance()
        if not fu:isFileExist(filename) then
            filename = "asset/uiother/steam/" .. teamD.steam .. ".jpg"
        end
        teamImg:loadTexture(filename)
        local height = teamImg:getContentSize().height
        local specialOffx = 0
        if teamId == 907 then
            specialOffx = 20
        end
        if not teamSpecialPosOff[teamId] then
            teamSpecialPosOff[teamId] = {}
            teamSpecialPosOff[teamId].x = 0
            teamSpecialPosOff[teamId].y=0
        end
        teamImg:setPosition(roleInfo.pos.x*posScaleX+teamSpecialPosOff[teamId].x,roleInfo.pos.y*posScaleY-offsetY+40+teamSpecialPosOff[teamId].y)
        teamImg:setLocalZOrder(roleInfo.zOrder)
        teamImg:setScale(roleInfo.scale)
        teamBgNode:addChild(teamImg)
	end
	return teamBgNode
end

-- 兵团觉醒方阵
TeamUtils.teamRolesMap = {
    [1] = {
        {pos = cc.p(0,-120),scale = 0.5,zOrder = 1}
    },
    [4] = {
        {pos = cc.p(-55,0),scale = 1,zOrder = 2},
        {pos = cc.p(55,0),scale = 1,zOrder = 2},

        {pos = cc.p(-55,80),scale = 1,zOrder = 1},
        {pos = cc.p(55,80),scale = 1,zOrder = 1},
    },
    [9] = {
        {pos = cc.p(110,0),scale = 1,zOrder = 4},
        {pos = cc.p(0,0),scale = 1,zOrder = 4},
        {pos = cc.p(-110,0),scale = 1,zOrder = 4},
        
        {pos = cc.p(-110,70),scale = 1,zOrder = 2},
        {pos = cc.p(0,70),scale = 1,zOrder = 2},
        {pos = cc.p(110,70),scale = 1,zOrder = 2},
        
        {pos = cc.p(-110,140),scale = 1,zOrder = 1},
        {pos = cc.p(110,140),scale = 1,zOrder = 1},
        {pos = cc.p(0,140),scale = 1,zOrder = 1},
    },
    [16] = {
        {pos = cc.p(-165,0),scale = 1,zOrder = 5},
        {pos = cc.p(-55,0),scale = 1,zOrder = 5},
        {pos = cc.p(55,0),scale = 1,zOrder = 5},
        {pos = cc.p(165,0),scale = 1,zOrder = 5},

        {pos = cc.p(-165,70),scale = 1,zOrder = 4},
        {pos = cc.p(-55,70),scale = 1,zOrder = 4},
        {pos = cc.p(55,70),scale = 1,zOrder = 4},
        {pos = cc.p(165,70),scale = 1,zOrder = 4},

        {pos = cc.p(-165,140),scale = 1,zOrder = 3},
        {pos = cc.p(-55,140),scale = 1,zOrder = 3},
        {pos = cc.p(55,140),scale = 1,zOrder = 3},
        {pos = cc.p(165,140),scale = 1,zOrder = 3},

        {pos = cc.p(-165,210),scale = 1,zOrder = 2},
        {pos = cc.p(-55,210),scale = 1,zOrder = 2},
        {pos = cc.p(55,210),scale = 1,zOrder = 2},
        {pos = cc.p(165,210),scale = 1,zOrder = 2},
    },
}

TeamUtils.teamSpecialPosOff = teamSpecialPosOff
TeamUtils.teamVolume = {
    [1] = 25,
    [2] = 16,
    [3] = 9,
    [4] = 4,
    [5] = 1,
}

-- 兵团三个标签调用弹出相应tips
--[[
    tipType : 
		5：兵种
		6：种族
		7：职业
	id：怪兽id
--]]
TeamUtils.showTeamLabelTip = function(inview, tipType, id)
    local viewMgr = ViewManager:getInstance()
    registerTouchEvent(inview, function ()
           
    end, function( )
            -- inview:stopAllActions()
            -- viewMgr:closeHintView()
    end, 
    function ()
            -- inview:stopAllActions()
            -- viewMgr:closeHintView()
    end,
    function ()
            -- inview:stopAllActions()
            -- viewMgr:closeHintView()
    end,
    -- 长按
    function ()
         viewMgr:showHintView("global.GlobalTipView",{tipType = tipType, node = inview, id = id})
    end)
end

-- 获取同一种族的怪兽
local teamClass = {}
TeamUtils.getSameRaces = function()
	if table.nums(teamClass) == 0 then
		local teamData = tab.team
		local teamClassRace = tab.race
		for k,v in pairs(teamClassRace) do
		    if tonumber(k) > 200 then
		        teamClass[k] = {}
		        for k1,v1 in pairs(teamData) do
		            if tonumber(k) == tonumber(v1.race[2]) then
		                table.insert(teamClass[k], k1)
		            end
		        end
		    end
		end
	end
	return teamClass
end

-- -- 获取战力前10 的怪兽
-- local modelMgr = ModelManager:getInstance()
-- local teamFight = {}
-- TeamUtils.getSameRaces = function()

--     local teamModel = modelMgr:getModel("TeamModel")
--     local teamData = teamModel:getData()
--     for k,v in pairs(teamData) do
--         teamFight[k] = {}
--         teamFight[k] = v.score
--         print(k , v.score)
--     end
--     return teamFight
-- end


-- 数据处理
-- 兵团属性规则
TeamUtils.getNatureNums = function(nums)
    -- print(type(nums))
    if type(tonumber(nums)) ~= "number" then
        return 0
    end
    -- if tonumber(nums) > 99 then
    --     nums = math.ceil(tonumber(nums))
    -- elseif tonumber(nums) >= 1 then
    --     nums = string.format("%.1f", math.ceil(tonumber(nums)*10)/10) --  -- string.format("%.1f", tonumber(nums))
    -- elseif tonumber(nums) < 1 then
    --     nums = string.format("%.2f", math.ceil(tonumber(nums)*100)/100) --  -- string.format("%.2f", tonumber(nums))
    -- end
    nums = tonumber(nums)
    if nums > 99 then
        nums = math.floor(nums+0.9)
    elseif nums >= 1 then
        nums = nums * 10
        nums = math.floor(nums + 0.9)/10 --  -- string.format("%.1f", nums)
    elseif nums < 1 then
        nums = math.floor(nums*100+0.9)/100 --  -- string.format("%.2f", tonumber(nums))
    end
    return nums
end

-- 获取通用战斗力
function TeamUtils:updateFightNum()
    local modelMgr = ModelManager:getInstance()
    local formationModel = modelMgr:getModel("FormationModel")
    -- local data = formationModel:getFormationData()[formationModel.kFormationTypeCommon]

    -- if not data then
    --     return 0
    -- end
    -- local fightCapacity = 0
    -- -- local treasureCapacity = modelMgr:getModel("TreasureModel"):getTreasureScore()
    -- fightCapacity = data.score --fightCapacity + heroData.score+treasureCapacity
    local fightCapacity = formationModel:getCurrentFightScoreByType(formationModel.kFormationTypeCommon)
    -- local scoreF1 = modelMgr:getModel("UserModel"):getData()["scoreF1"]
    -- return scoreF1 or 0
    return fightCapacity or scoreF1 or 0
end

-- 战斗力改变动画
--[[
--！inView userData 父节点 
--！inTable table 相关控制          
--！x int 位置x
--！y int 位置
--！oldFight int 旧战力
--！newFight int 新战力
--]]
function TeamUtils:setFightAnim(inView, inTable)
    if (inTable.newFight - inTable.oldFight) <= 0 then
        return
    end
    
    local bgNode = inView:getChildByName("bgNode")
    if bgNode then
        bgNode:stopAllActions()
        bgNode:removeFromParent()
    end
    bgNode = ccui.Widget:create()
    bgNode:setName("bgNode")
    bgNode:setAnchorPoint(cc.p(0.5,0))


    bgNode:setPosition(cc.p(inTable.x+100, inTable.y+20))
    -- local pos = bgNode:convertToWorldSpace(cc.p(0, 0))
    -- print("============================================================")
    -- dump(pos, "pos =====")
    -- print("============================================================")
    bgNode:setContentSize(cc.size(100, 100))

    bgNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
        AudioManager:getInstance():playSound("PowerCount")
    end)))

    -- local brownBg = cc.Sprite:create()
    -- brownBg:setSpriteFrame("globalImageUI_brownBg_team.png")
    -- brownBg:setAnchorPoint(cc.p(0.5, 0.5))
    -- brownBg:setPosition(cc.p(150,-2))
    -- bgNode:addChild(brownBg)

    local str = "a+0" -- .. (inTable.oldFight or 1)
    -- local fightLabel = ccui.TextBMFont:create(str, UIUtils.bmfName_zhandouli_bianhua)
    local fightLabel = cc.Label:createWithBMFont(UIUtils.bmfName_zhandouli_bianhua, str)
    fightLabel:setAdditionalKerning(-22)
    fightLabel:setName("fightLabel")
    fightLabel:setScale(60)
    fightLabel:setAnchorPoint(cc.p(0.5, 0.5))
    fightLabel:setPosition(cc.p(100, 20))
    fightLabel:setOpacity(0)
    bgNode:addChild(fightLabel, 100)

    -- local addfight = cc.Label:createWithTTF("+" .. (inTable.newFight - inTable.oldFight), UIUtils.bmfName, 42)
    -- addfight:setColor(cc.c3b(0,255,0))
    -- addfight:setAnchorPoint(cc.p(0, 0.5))
    -- -- addfight:setPosition(cc.p((fightLabel:getPositionX() + fightLabel:getContentSize().width + 30), -3))
    -- addfight:setOpacity(0)
    -- bgNode:addChild(addfight, 5)

    -- local fightBg = cc.Sprite:create()
    -- fightBg:setSpriteFrame("globalImageUI_fight_team.png")
    -- fightBg:setAnchorPoint(cc.p(0.5, 0.5))
    -- fightBg:setPosition(cc.p(0,0))
    -- bgNode:addChild(fightBg, 3)

    -- local mc2 = mcMgr:createViewMC("zhandouliguang_teamfight", true, false)
    -- mc2:setPosition(cc.p(0, 0))
    -- bgNode:addChild(mc2,10000)
    
    local tempGunlun, tempFight 
    -- if (inTable.newFight - inTable.oldFight) < 10 then
    --     tempFight = math.floor(inTable.newFight * 0.01) * 100
    --     tempGunlun = inTable.newFight - tempFight
    -- -- elseif (inTable.newFight - inTable.oldFight) < 100 then
    -- --     tempFight = math.floor(inTable.newFight * 0.001) * 1000
    -- --     tempGunlun = inTable.newFight - tempFight
    -- else
    --     tempFight = 0
    --     tempGunlun = inTable.newFight - tempFight
    -- end

    -- -- 滚动轮
    -- tempFight = inTable.oldFight
    -- tempGunlun = inTable.newFight - inTable.oldFight
    tempFight = 0
    tempGunlun = inTable.newFight - inTable.oldFight

    local fightNum = tempGunlun / 20
    local numsch = 1
    local sequence = cc.Sequence:create(
        -- cc.CallFunc:create(function()
        --     local mc2 = mcMgr:createViewMC("zhandouliguang_teamfight", false, true)
        --     mc2:setPosition(cc.p(fightBg:getContentSize().width/2,fightBg:getContentSize().height/2))
        --     fightBg:addChild(mc2,10)
        -- end),
        -- cc.MoveBy:create(0.5, cc.p(100, -200)),
        -- cc.FadeOut:create(0),
        cc.ScaleTo:create(0, 6),
        cc.Spawn:create(cc.ScaleBy:create(0.07, 0.2), cc.FadeTo:create(0.07, 179)),
        cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255)),
        
        -- cc.ScaleTo:create(0.1, 1),
        cc.Repeat:create(cc.Sequence:create(cc.DelayTime:create(0.025),cc.CallFunc:create(function()
            fightLabel:setString("a+" .. (tempFight + math.ceil(fightNum * numsch)))
            numsch = numsch + 1
        end)), 20),
        
        cc.CallFunc:create(function()
            fightLabel:setString("a+" .. tempGunlun)
            -- fightLabel:setString("a" .. inTable.newFight)

            -- local mc2 = mcMgr:createViewMC("zhandouliguang_teamupgrade", false, true)
            -- mc2:setPosition(cc.p(brownBg:getContentSize().width/2,brownBg:getContentSize().height/2))
            -- brownBg:addChild(mc2, 10)
            -- addfight:setPosition(cc.p((fightLabel:getPositionX() + fightLabel:getContentSize().width + 30), -3))
            -- addfight:runAction(cc.Sequence:create(
            --     cc.FadeIn:create(0.2),
            --     cc.FadeOut:create(0.3),
            --     cc.FadeIn:create(0.2),
            --     cc.FadeOut:create(0.3)
            --     )
            -- )
        end)
        -- cc.FadeOut:create(0.2)
        )
    inView:addChild(bgNode,1000)
    local mc2 = mcMgr:createViewMC("tongyongzhandouli_shuaxinguangxiao", false, false)
    mc2:setPosition(cc.p(30, 0))
    bgNode:addChild(mc2,99)
    local mc3 = mcMgr:createViewMC("zhandoulishuaguang_shuaxinguangxiao", false, true)
    mc3:setPosition(cc.p(30, 0))
    bgNode:addChild(mc3,101)

    fightLabel:runAction(sequence)
    bgNode:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
        -- bgNode:removeFromParent()
    -- end)))
    end),cc.RemoveSelf:create(true)))

end

-- 数据动画处理
--[[
--！inView userData 父节点 
--！inTable table 相关控制          
--！oldValue int 旧战力
--！newValue int 新战力
--！add bool 新战力
--]]
function TeamUtils:setDataAnim(inView, inTable)
    if inView == nil then
        return
    else
        inView:stopAllActions()
    end
    local oldColor = inTable.tempColor
    -- local viewMgr = ViewManager:getInstance()
    -- viewMgr:lock(-1)
    local tempGunlun, tempFight 
    if (inTable.newData - inTable.oldData) < 10 then
        tempData = math.floor(inTable.newData * 0.01) * 100
        tempGunlun = inTable.newData - tempData
    elseif (inTable.newData - inTable.oldData) < 100 then
        tempData = math.floor(inTable.newData * 0.001) * 1000
        tempGunlun = inTable.newData - tempData
    else
        tempData = 0
        tempGunlun = inTable.newData - tempData
    end
    local dataNum = tempGunlun / 20
    -- local depleteSchedule
    local numsch = 50

    local seq = cc.Sequence:create(
        cc.CallFunc:create(function()
            inView:setColor(cc.c3b(0,255,30))
            inView:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end),
        cc.ScaleTo:create(0.1,1.2),
        -- cc.CallFunc:create(function()
        --     if inTable.bool == true then
        --         depleteSchedule = ScheduleMgr:regSchedule(25, self, function()
        --             inView:setString("+" .. (tempData + math.ceil(dataNum * numsch / 50)))
        --             numsch = numsch + 50
        --             if numsch > 1000 then
        --                 inView:setString("+" .. inTable.newData)
        --                 ScheduleMgr:unregSchedule(depleteSchedule)
        --                 viewMgr:unlock()
        --             end 
        --         end)
        --     else
        --         depleteSchedule = ScheduleMgr:regSchedule(25, self, function()
        --             inView:setString((tempData + math.ceil(dataNum * numsch / 50)))
        --             numsch = numsch + 50
        --             if numsch > 1000 then
        --                 inView:setString(inTable.newData)
        --                 ScheduleMgr:unregSchedule(depleteSchedule)
        --                 viewMgr:unlock()
        --             end
        --         end)
        --     end
        -- end),
        cc.DelayTime:create(0.5),
        cc.ScaleTo:create(0.2,1),
        cc.CallFunc:create(function()
            inView:disableEffect()
            inView:setColor(oldColor)
        end)
        )

    inView:runAction(seq)
end

function TeamUtils.changeArtForHeroMastery(heroId,teamId)
    local art
    local changeId 
    local heroD = tab:Hero(tonumber(heroId))
    local heroData = ModelManager:getInstance():getModel("HeroModel"):getData()[tostring(heroId)]
    if not heroData or not heroD then return end
    local special = heroD.special 
    if not heroData.star then 
        print("=====英雄星级为空================star==",star,type(star))
        return 
    end
    local star = heroData.star    
    if special then
        for i=1,tonumber(star) do
            -- print("=---TeamUtils.changeArtForHeroMastery=========" .. (special .. i))
            local heroMasteryD = tab:HeroMastery(tonumber(special .. (i or 1)))
            if heroMasteryD and heroMasteryD.creplace then
                for k,v in pairs(heroMasteryD.creplace) do
                    if v[1] == tonumber(teamId) then
                        changeId = tonumber(v[2])
                        break
                    end
                end
                if changeId and tab:Team(changeId) then
                    return tab:Team(changeId).art1,changeId
                end
            end
            print(i)
        end
    end
    return art,changeId
end
-- 不需要获得英雄或者兵团就可以修改头像
function TeamUtils.changeArtForHeroMasteryByData(heroData,heroId,teamId)
    local art
    local changeId  
    local heroD = tab:Hero(tonumber(heroId))
    if not heroData and not heroD then return end
    local special = heroD.special
    if not heroData.star then 
        print("=====英雄星级为空================star==",star,type(star))
        return 
    end
    local star = heroData.star or 1
    if special then
        for i=1,tonumber(star) do
            -- print("=---TeamUtils.changeArtForHeroMastery=========" .. (special .. i))
            local heroMasteryD = tab:HeroMastery(tonumber(special .. (i or 1)))
            if heroMasteryD and heroMasteryD.creplace then
                for k,v in pairs(heroMasteryD.creplace) do
                    if v[1] == tonumber(teamId) then
                        changeId = tonumber(v[2])
                        break
                    end
                end
                if changeId and tab:Team(changeId) then
                    return tab:Team(changeId).art1,changeId
                end
            end
        end
    end
    return art,changeId
end

function TeamUtils.getNpcTableValueByTeam(npcD, key)
    if npcD["match"] then
        local teamD = tab.team[npcD["match"]]
        return npcD[key] or teamD[key]
    else
        return npcD[key]
    end
end

TeamUtils.teamboostStage = {
    [1] = {1, 0},
    [2] = {2, 0},
    [3] = {2, 1},
    [4] = {2, 2},
    [5] = {3, 0},
    [6] = {3, 1},
    [7] = {3, 2},
    [8] = {4, 0},
    [9] = {4, 1},
    [10] = {4, 2},
}
-- 获取通用战斗力
function TeamUtils:getTeamBoostName(level)
    if level < 1 or level > 10 then
        level = 1
    end
    return TeamUtils.teamboostStage[level]
end

-- 获取兵团觉醒情况
-- 返回是否觉醒 和 觉醒等级
function TeamUtils:getTeamAwaking(inTeamData)
    if not inTeamData then
        return false, 0
    end
    local ast = inTeamData.ast
    local aLvl = inTeamData.aLvl
    local isAwaking = false
    if ast and ast == 3 then
        isAwaking = true
    end
    if isAwaking == false then
        aLvl = 0
    end
    return isAwaking, aLvl
end

-- 返回兵团 名字、头像、立汇、小人、动画小人
-- 对应 teamName, art1, art2, art3
function TeamUtils:getTeamAwakingTab(inTeamData, teamId, flag)
    if not inTeamData then
        return "", "alpha", "alpha", "alpha"
    end
    local ast = inTeamData.ast
    local teamId = teamId or inTeamData.teamId 
    local isAwaking = false
    local sysTeam = tab.team[teamId]
    if not sysTeam then
        return
    end
    local lihui = string.sub(sysTeam["art1"], 4, string.len(sysTeam["art1"]))
    local art1 = sysTeam.art1
    local art2 = "t_" .. lihui
    local art3 = sysTeam.steam
    local art4 = sysTeam.art
    local teamName = sysTeam.name
    if (ast and ast == 3) or (flag == true) then
        art1 = sysTeam.jxart1
        art2 = "ta_" .. lihui
        art3 = sysTeam.jxsteam
        art4 = sysTeam.jxart
        teamName = sysTeam.awakingName
    end

    return teamName, art1, art2, art3, art4
end

-- 获取兵团技能觉醒情况
-- 返回{是否觉醒技能， 技能类型}
-- {0 or 1, 0 or 1 or 2}
function TeamUtils:getTeamAwakingSkill(inTeamData)
    local skillTab = {}
    for i=1,4 do
        local _skillTab = {0, 0}
        skillTab[i] = _skillTab
    end
    if not inTeamData then
        return skillTab
    end
    local ast = inTeamData.ast
    local aLvl = inTeamData.aLvl
    local tree = inTeamData.tree
    local teamId = inTeamData.teamId
    local teamTab = tab:Team(teamId) or tab:Npc(teamId)

    local isAwaking = false
    local isSkillAwaking = false
    if ast and ast == 3 then
        isAwaking = true
        if tree then
            for i=1,3 do
                local batch = tree["b" .. i]
                if batch and batch ~= 0 then
                    local talentTree = teamTab["talentTree" .. i]
                    skillTab[talentTree[1]][1] = 1
                    skillTab[talentTree[1]][2] = batch
                end
            end
        end
    end
    return skillTab
end

--获取圣徽兵团技能加成
function TeamUtils:getRuneIdAndLv( str )
    local type = tonumber(string.sub(str,1,3))
    local lv = tonumber(string.sub(str,5))
    print("fdewfwefw ",type,lv)
    local level = 0
    if type == 104 then
        if lv == 4 then
            level = level + 1
        else
            level = level + 2
        end
    end
    if type == 403 then
        if lv == 4 then
            level = level + 2
        else
            level = level + 4
        end 
    end
    return type,level
end

function TeamUtils.dtor()
    teamClass = nil
    teamRolesMap = nil
    teamSpecialPosOff = nil
    TeamUtils = nil
    teamVolume = nil
end

return TeamUtils