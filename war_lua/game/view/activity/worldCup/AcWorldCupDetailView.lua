--[[
    Filename:    AcWorldCupDetailView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-05-10 18:42
    Description: 竞猜投注详情界面
--]]

local AcWorldCupDetailView = class("AcWorldCupDetailView", BasePopView)

local sysGuessTeam = tab.guessTeam
local sysGuessBet = tab.guessBet

function AcWorldCupDetailView:ctor(param)
	AcWorldCupDetailView.super.ctor(self)
	self._worldCupModel = self._modelMgr:getModel("WorldCupModel")

	self._data = param.data
end

function AcWorldCupDetailView:onInit()
	self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("activity.worldCup.AcWorldCupDetailView")
        end
    end)

	local closeBtn = self:getUI("bg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		self:close()
		end)
end

function AcWorldCupDetailView:reflashUI()
	local cellData = self._data
	local betList = self._worldCupModel:getBetList()
    local betData = betList[tostring(cellData["id"])]

    --比赛双方flag
	for i=1, 2 do
        local flagId = cellData["team_" .. i]
        local flag = self:getUI("bg.infoBg.flag" .. i)
        local resImg = sysGuessTeam[flagId]["art"] or "globalImageUI6_meiyoutu"
        flag:loadTexture(resImg .. ".png", 1)
        local flagName = self:getUI("bg.infoBg.flag" .. i .. ".name")
        flagName:setString(lang(sysGuessTeam[flagId]["teamID"]))
        flagName:setFontSize(30)
        local score = self:getUI("bg.infoBg.score" .. i)
        score:setString(cellData["gamescore"][i])
        local nameWid = flagName:getContentSize().width * flag:getScale()
        if i == 1 then
        	flag:setPositionX(score:getPositionX() - nameWid - 30)
        else
        	flag:setPositionX(score:getPositionX() + 30)
        end
        
    end

    --比赛名
    local num1 = self:getUI("bg.num1")
    num1:setString(lang(cellData["game_id"]))
    
    --押注是否对
    ------------------------
    local team1 = cellData["team_1"]
    local team2 = cellData["team_2"]
    local disTeam = math.abs(cellData["gamescore"][1] - cellData["gamescore"][2])
    local tempOdds = nil
    if cellData["gamesesult"] == team1 then
        if disTeam >= 3 then
            tempOdds = 1
        else
            tempOdds = 2
        end
    elseif cellData["gamesesult"] == team2 then
        if disTeam >= 3 then
            tempOdds = 5
        else
            tempOdds = 4
        end
    else
        tempOdds = 3
    end

    local isMatch = false   
    if betData[3] == tempOdds then
        isMatch = true
    else
        if betData[3] == 2 and tempOdds == 1 then   --押胜结果是大胜也算
            isMatch = true
        elseif betData[3] == 4 and tempOdds == 5 then  --押胜结果是大胜也算
            isMatch = true
        end
    end
    -------------------------

    local num3 = self:getUI("bg.num3")
    if betData[2] == cellData["gamesesult"] and isMatch then
    	num3:setString("竞猜成功")
    else
    	num3:setString("竞猜失败")
    end
    
    --赔率
    local num4 = self:getUI("bg.num4")
    num4:setString(cellData["odds"][betData[3]])

    --国旗
    local flag = self:getUI("bg.flag")
    local num2 = self:getUI("bg.num2")
    if cellData["gamesesult"] == 0 then   --平局
    	num2:setString("平局")
        num2:setPositionX(232)
        flag:setVisible(false)
    else
    	num2:setString("胜利")
    	local winId = cellData["gamesesult"]
    	local resImg = sysGuessTeam[winId]["art"] or "globalImageUI6_meiyoutu"
    	flag:loadTexture(resImg .. ".png", 1)

    	local flagName = flag:getChildByName("name")
        flagName:setString(lang(sysGuessTeam[winId]["teamID"]))

        num2:setPositionX(237 + flag:getContentSize().width * flag:getScale() + flagName:getContentSize().width * flag:getScale() + 5)
    end
    
    if betData[2] ~= cellData["gamesesult"] or not isMatch then  --失败
        for i=1, 2 do
            self:getUI("bg.num" .. (i + 4)):setVisible(false)
            self:getUI("bg.des" .. (i + 4)):setVisible(false)
        end
    else
        for i=1, 2 do
            --奖励icon
            local sysBetData = sysGuessBet[betData[1]]
            local oddsNum = cellData["odds"][betData[3]]
            local costType = sysBetData["cost"][1]
            local costNum = sysBetData["cost"][3]
            local costId = IconUtils.iconIdMap[costType] or sysBetData["cost"][2]
            local toolD = tab:Tool(tonumber(costId))
            local rwdIcon = IconUtils:createItemIconById({itemId = costId,itemData = toolD})
            rwdIcon:setScale(0.25)
            rwdIcon:setPosition(109, 31)
            self:getUI("bg"):addChild(rwdIcon)

            --数量
            local countNum = 0
            if i == 1 then
                countNum = ItemUtils.formatItemCount(costNum)
                rwdIcon:setPosition(230, 55)
            else
                countNum = ItemUtils.formatItemCount(costNum * oddsNum)
                rwdIcon:setPosition(230, 32)
            end

            local rwdNum = self:getUI("bg.num" .. (i + 4))
            rwdNum:setString(countNum .. "个")
            rwdNum:setPositionX(258)
        end
    end
end

return AcWorldCupDetailView