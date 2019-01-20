
--[[
    Filename:    CityBattleShopView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-07-07 21:04:58
    Description: File description
--]]

local CityBattleRuleDialog = class("CityBattleRuleDialog",BasePopView)
function CityBattleRuleDialog:ctor(param)
    CityBattleRuleDialog.super.ctor(self)
    self._callBack = param and param.callBack
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function CityBattleRuleDialog:onInit()
	self:registerClickEventByName("bg.closeBtn", function ()
        if self._callBack then
            self._callBack()
        end
        self:close()
        UIUtils:reloadLuaFile("citybattle.CityBattleRuleDialog")
    end)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)

    self._title = self:getUI("bg.headBg.title")
    self._title:setFontName(UIUtils.ttfName)
    UIUtils:setTitleFormat(self._title,6)

    self._roleNode = self:getUI("bg.roleNode")
    self._roleNode:setVisible(true)
    
    local dialogLabel = cc.Label:createWithTTF("领主大人，还有什么不明白吗？", UIUtils.ttfName_Title, 20)
    dialogLabel:setMaxLineWidth(145)
    dialogLabel:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    dialogLabel:setLineHeight(30)
    dialogLabel:setPosition(279, 117)
    self._roleNode:addChild(dialogLabel)

    local detailBtn = self._roleNode:getChildByFullName("detailBtn")
    detailBtn:setTitleFontSize(22)
    self:registerClickEvent(detailBtn, function ()
        -- self._viewMgr:showDialog("heroduel.HeroDuelDesView", {}, true)
        self._viewMgr:showDialog("global.CommonNewGuideDialog",{showType = 3},true)
    end)

    self._rankCell = self:getUI("bg.rankCell")

    self._rankCell:setVisible(false)

    local imageBar = self:getUI("bg.roleNode.Image_70")
    local cloneBar = imageBar:clone()
    -- 文字原型
    self._textPro = ccui.Text:create()
    self._textPro:setString("")
    self._textPro:setAnchorPoint(0,1)
    self._textPro:setPosition(0,0)
    self._textPro:setFontSize(22)
    self._textPro:setFontName(UIUtils.ttfName)
    self._textPro:setTextColor(cc.c4b(255,110,59,255))

    local maxHeight = 0

    -- local scrollBgH = self:generateRanks()
    -- maxHeight = maxHeight+scrollBgH

    local scrollW = self._scrollView:getInnerContainerSize().width
    -- 增加抬头
    -- local des1 = self._textPro:clone()
    -- des1:setString("胜场奖励")
    -- des1:setFontSize(22)
    -- des1:setFontName(UIUtils.ttfName)
    -- des1:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- des1:setAnchorPoint(0,0)
    -- des1:setPosition(3, maxHeight + 15)
    -- self._scrollView:addChild(des1)
    -- maxHeight=maxHeight+des1:getContentSize().height+15

    -- 增加富文本
	local rtxStr = lang("RULE_CITYBATTLE")  --lang("RULE_ARENA")
    rtxStr = string.gsub(rtxStr,"ffffff","462800")
	local rtx = RichTextFactory:create(rtxStr,418,0)
    rtx:setPixelNewline(true)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0))
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height
    rtx:setName("rtx")
    rtx:setPosition(-w* 0.5,maxHeight + 30)
    self._scrollView:addChild(rtx)
    maxHeight = maxHeight+h +30

    local des2 = self._textPro:clone()
    des2:setString("基本规则")
    des2:setFontName(UIUtils.ttfName)
    des2:setFontSize(22)
    des2:setAnchorPoint(0,0)
    des2:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des2:setPosition(3, maxHeight + 10)
    self._scrollView:addChild(des2)
    maxHeight=maxHeight+des2:getContentSize().height + 10



    

    --战场分区
    


    self._scrollView:addChild(cloneBar)
    cloneBar:setPositionY(maxHeight + 10)
    maxHeight = maxHeight + cloneBar:getContentSize().height + 5

    local data = self._cityBattleModel:getData().c.co
    local battleName = {
        "赤焰战区:",
        "碧蓝战区:",
        "苍星战区:"
    }
    local ids = {}
    for key,value in pairs (data) do 
        ids[value] = key
    end

    local sdkMgr = SdkManager:getInstance()
    local function getPlatform(sec)
        local platform =""
        local sec = tonumber(sec)
        if sec and sec >= 5001 and sec < 7000 then
            platform = "双线"
        elseif sdkMgr:isQQ() then
            platform = "qq"
        elseif sdkMgr:isWX() then
            platform = "微信"
        else
            platform = "win"
        end
        return platform
    end

    local function getRealNum(sec)
        sec = tonumber(sec)
        local num = 0
        if sec < 5001 then
            num = sec % 1000
        elseif (sec >= 5001 and sec < 5026) or (sec >= 6001 and sec < 6026) then
            num = (sec % 1000)*2 - 1
        elseif (sec >= 5026 and sec < 5501) or (sec >= 6026 and sec < 6501) then   --5025  6025 以后不区分单双号服务器
            local temp = 6025
            if sec < 6000 then
                temp = 5025
            end
            num = sec - temp + 50
        elseif (sec >= 5501 and sec < 6000) or (sec >= 6501 and sec < 7000) then
            num = (sec % 100) * 2
        else
            num = sec % 1000
        end
        return num
    end
    local severList = self._userModel:getServerIDMap()
    local function fiterServers(sec)
        local result = {}
        if not severList[tostring(sec)] then
            result[#result+1] = sec
        else
            for old,new in pairs (severList) do
                if tostring(sec) == new then
                    result[#result+1] = tonumber(old)
                end
            end
            if #result == 0 then
                result[#result+1] = sec
            end
        end
        return result
    end

    

    for i = 3,1,-1 do 
        local battleData = ids[i]
        if battleData then
            print("battleData",battleData,battleName[i])
            local servers = fiterServers(battleData)
            local str = "[color=ffffff,fontsize=20]"
            for index,id in pairs (servers) do 
                local num = getRealNum(id)
                local platform = getPlatform(id)
                platform = platform or ""
                str = str .. platform .. num .. "区"
                if index ~= table.nums(servers) then
                    str = str .. "、"
                end
            end
            str = str .. "[-]"
            local rtxStr = str
            rtxStr = string.gsub(rtxStr,"ffffff","8a5c1d")
            local rtx = RichTextFactory:create(rtxStr,280,0)
            rtx:setPixelNewline(true)
            rtx:formatText()
            rtx:setVerticalSpace(3)
            rtx:setAnchorPoint(cc.p(0,0))
            local w = rtx:getInnerSize().width
            local h = rtx:getVirtualRendererSize().height
            rtx:setName("rtx")
            rtx:setPosition(-w* 0.5+120,maxHeight+10)
            self._scrollView:addChild(rtx)

            local battleName_ = self._textPro:clone()
            battleName_:setString(battleName[i])
            battleName_:setFontName(UIUtils.ttfName)
            battleName_:setFontSize(22)
            battleName_:setAnchorPoint(0,0)
            battleName_:setTextColor(UIUtils.colorTable.ccUIBaseTextColor1)
            battleName_:setPosition(20, maxHeight+h-13)
            self._scrollView:addChild(battleName_)
            maxHeight = maxHeight + h +10

            
            print("maxHeight",maxHeight)
        end
    end

    local des3 = self._textPro:clone()
    des3:setString("战场分区")
    des3:setFontName(UIUtils.ttfName)
    des3:setFontSize(22)
    des3:setAnchorPoint(0,0)
    des3:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
    des3:setPosition(3, maxHeight + 10)
    self._scrollView:addChild(des3)
    maxHeight=maxHeight+des3:getContentSize().height + 10

    self._roleNode:removeFromParent()
    self._roleNode:setPosition(0, maxHeight + 10)
    self._scrollView:addChild(self._roleNode)
    maxHeight = maxHeight + self._roleNode:getContentSize().height + 10

    self._scrollView:setInnerContainerSize(cc.size(scrollW,maxHeight))
    
end

function CityBattleRuleDialog:generateRanks()
    local itemH,itemW = self._rankCell:getContentSize().height,self._rankCell:getContentSize().width
    local hDuelAwardTab = tab.heroDuelAward

    local hDuelAwardTab = {} 
    for k, v in pairs(tab.heroDuelAward) do
        table.insert(hDuelAwardTab, v)
    end
    table.sort(hDuelAwardTab, function(a,b)
        return a.id < b.id
    end)

    local bgHeight = (#hDuelAwardTab)*itemH
    for tabI = 1, #hDuelAwardTab do
        local item = self._rankCell:clone()
        item:setVisible(true)
        item:setPosition(cc.p(-25,itemH*(tabI-1)-3))
        if tabI%2 == 1 then
            item:getVirtualRenderer():setVisible(false)
        end
        ---[[ 用数据初始化item
        local rankRange = item:getChildByFullName("rankRange")
        local rankStr = hDuelAwardTab[tabI].id .. "胜场奖励"
        rankRange:setString(rankStr)

        local infoStartPos = 160
        local rewardSpace = 130
        local rewardData = hDuelAwardTab[tabI]["award"]
        for i = 1, #rewardData do
            local cData = rewardData[i]

            local icon = nil
            local iconWidth = 30
            if cData[1] == "tool" then
                local iconPath = tab:Tool(cData[2]).art
                icon = cc.Sprite:createWithSpriteFrameName(iconPath .. ".png")
            else
                local iconPath = IconUtils.resImgMap[cData[1]]

                if iconPath == nil then
                    local itemId = tonumber(IconUtils.iconIdMap[cData[1]])
                    local toolD = tab:Tool(itemId)
                    iconPath = IconUtils.iconPath .. toolD.art .. ".png"
                    icon = IconUtils:createItemIconById({itemId = itemId,itemData = toolD})
                end
                icon = cc.Sprite:createWithSpriteFrameName(iconPath)
            end
            icon:setScale(iconWidth / icon:getContentSize().width)
            icon:setPosition(infoStartPos + (i - 1)*rewardSpace, 17)
            item:addChild(icon)

            local countTxt = tostring(cData[3])
            local rewardCount = cc.Label:createWithTTF("x" .. countTxt, UIUtils.ttfName, 18) 
            rewardCount:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            rewardCount:setPosition(infoStartPos + (i - 1)*rewardSpace + rewardCount:getContentSize().width*0.5 + 22, 17)
            item:addChild(rewardCount)
        end

        self._scrollView:addChild(item)
    end
    -- 顶部描述
    local rtxStr = lang("HERODUEL_RULE2")
    local topDes = RichTextFactory:create(rtxStr,418, 0)
    topDes:formatText()
    topDes:setVerticalSpace(3)
    topDes:setAnchorPoint(cc.p(0,0))
    local w = topDes:getInnerSize().width
    local h = topDes:getVirtualRendererSize().height
    topDes:setName("topDes")
    topDes:setPosition(cc.p(-w*0.5+5,bgHeight + 10))
    self._scrollView:addChild(topDes)
    bgHeight = bgHeight+h
    self._scrollView:setBackGroundImageCapInsets(cc.rect(217,30,1,1))
    return bgHeight
end

return CityBattleRuleDialog