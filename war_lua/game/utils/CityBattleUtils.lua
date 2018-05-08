--[[
    Filename:    CityBattleUtils.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-12-08 14:42:33
    Description: File description
--]]


local CityBattleUtils = {}
local CC_DRAWNODE = cc.DrawNode

-- local CityleidaBase = {
--     [1] = {-1, -1.73}, 
--     [2] = {1, -1.73}, 
--     [3] = {2, 0}, 
--     [4] = {1, 1.73}, 
--     [5] = {-1, 1.73}, 
--     [6] = {-2, 0}, 
-- }

-- local CityleidaBase = {
--     [1] = {-1, 1.73}, 
--     [2] = {1, 1.73}, 
--     [3] = {2, 0}, 
--     [4] = {1, -1.73}, 
--     [5] = {-1, -1.73}, 
--     [6] = {-2, 0}, 
-- }
local baseNum1 = math.tan(math.rad(60))

local CityleidaBase = {
    [1] = {0, 2}, 
    [2] = {baseNum1, 1}, 
    [3] = {baseNum1, -1}, 
    [4] = {0, -2}, 
    [5] = {-baseNum1, -1}, 
    [6] = {-baseNum1, 1}, 
}

local LeidaMaxValue = {
    [1] = 11, 
    [2] = 11, 
    [3] = 11, 
    [4] = 11, 
    [5] = 11, 
    [6] = 11, 
}

local leidaPointValue = {52,46,46,44,44,44,44,42,42,40}

local DrawColor4F = {
    cc.c4f(0, 0.69, 1, 0.7),
    cc.c4f(1, 0.2, 0.13, 0.7),
    cc.c4f(1, 0.98, 0.73, 0.7),
    cc.c4f(1, 0.51, 0.09, 0.7),
    cc.c4f(0.81, 0.53, 0.26, 0.7),
    cc.c4f(0, 0, 0, 0.8)
}

CityBattleUtils.zhenyingTable = {
        ccColor1 = cc.c4b(0, 177, 255, 255),
        ccColor2 = cc.c4b(255, 51, 33, 255),
        ccColor3 = cc.c4b(255, 251, 186, 255),
        ccColor4 = cc.c4b(255, 130, 22, 255),

        cfColor1 = cc.c4f(0, 0.69, 1, 0.7),
        cfColor2 = cc.c4f(1, 0.2, 0.13, 0.7),
        cfColor3 = cc.c4f(1, 0.98, 0.73, 0.7),
        cfColor4 = cc.c4f(1, 0.51, 0.09, 0.7),
        cfColor5 = cc.c4f(0.81, 0.53, 0.26, 0.7),
    }

CityBattleUtils.areaMaskColor = {cc.c4b(250, 24, 24, 255), cc.c4b(247, 194, 37, 255), cc.c4b(0, 16, 249, 255), cc.c4b(255, 255, 255, 255)}

CityBattleUtils.cityStateColor = {cc.c4b(255, 58, 51, 255), cc.c4b(150, 255, 76, 255), cc.c4b(130, 183, 255, 255), cc.c4b(255, 255, 255, 255)}

CityBattleUtils.leidaMaxValue = {
    [1] = 10, 
    [2] = 10, 
    [3] = 10, 
    [4] = 10, 
    [5] = 10, 
    [6] = 10, 
}

CityBattleUtils.readlyImage = {
    [1] = "tl_emo.png", 
    [2] = "tl_dixiacheng.png", 
    [3] = "tl_shouren.png", 
    [4] = "tl_mofashi.png", 
    [5] = "tl_wangling.png", 
    [6] = "tl_renlei.png", 
}

-- 城市血条
CityBattleUtils.cityhpImg = {
    [1] = "citybattle_view_cityhp1.png",
    [2] = "citybattle_view_cityhp2.png",
    [3] = "citybattle_view_cityhp3.png",
    [4] = "citybattle_view_cityhp4.png"
}

-- 创建雷达图
function CityBattleUtils:getRadarImage()

end

-- 用于显示战报时间
function CityBattleUtils:getDisNowTime(leaveTime)

end

function CityBattleUtils:getRedType(redType)

end

-- 设置倒计时间
function CityBattleUtils:setCountDown(inView, time, strTishi, callback,timeList,callbackList)
    if tolua.isnull(inView) then
        print("CityBattleView:setCountDown ===========null==")
        return
    end

    inView:stopAllActions()

    local tempTime = time
    local seq = cc.Sequence:create(cc.CallFunc:create(function()
        tempTime = tempTime - 1
        local tempValue = tempTime
        local day = math.floor(tempValue/86400)
        tempValue = tempValue - day*86400
        local hour = math.floor(tempValue/3600)
        tempValue = tempValue - hour*3600
        local minute = math.floor(tempValue/60)
        tempValue = tempValue - minute*60
        local second = math.fmod(tempValue, 60)
        local showTime 
        if day > 0 then
            showTime = string.format("%d天%.2d:%.2d:%.2d", day, hour, minute, second)
        else
            showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
        end

        if timeList and table.nums(timeList) > 0 then
            for k,v in pairs (timeList) do 
                if tempTime == v then
                    if callbackList[k] then
                        callbackList[k]()
                    end
                    break
                end
            end
        end
        
        if tempTime < 1 then
            print("倒计时结束")
            showTime = strTishi .. "00:00:00"
            inView:setString(showTime)
            inView:stopAllActions()
            if callback then
                callback()
            end
            return
        end
        if inView then
            showTime = strTishi .. showTime
            inView:setString(showTime)
        end
    end), cc.DelayTime:create(1))
    inView:runAction(cc.RepeatForever:create(seq))
end

-- 绘制雷达图
-- paramBase 最大等级，
-- param 当前等级， 
-- contentX, contentY 位置， 
-- radius 半径，
-- cfType 颜色类型
CityBattleUtils.drawLeida = function(paramBase, param, contentX, contentY, radius, cfType)
    local drawPanel = cc.DrawNode:create()
    CityBattleUtils.updateDrawLeida(drawPanel, paramBase, param, contentX, contentY, radius)
    return drawPanel
end

CityBattleUtils.updateDrawLeida = function(inView, paramBase, param, contentX, contentY, radius, cfType)
    local leidaBase = {
        [1] = {-1, -1.73}, 
        [2] = {1, -1.73}, 
        [3] = {2, 0}, 
        [4] = {1, 1.73}, 
        [5] = {-1, 1.73}, 
        [6] = {-2, 0}, 
    }

    if not contentX then
        contentX = 0
    end

    if not contentY then
        contentY = 0
    end

    if not radius then
        radius = 31
    end
    if not cfType then
        cfType = 5
    end
    inView:clear()
    for i=1,6 do
        local pos1X, pos1Y = 0, 0
        local pos2X, pos2Y = 0, 0
        local index1, index2 = 1, 1
        if i == 6 then
            index1 = 1
            index2 = 6
        else
            index1 = i 
            index2 = i + 1
        end

        local tempW = param[index1] / CityBattleUtils.leidaMaxValue[index1] * 32
        local tempH = param[index1] / CityBattleUtils.leidaMaxValue[index1] * 32
        pos1X = contentX + leidaBase[index1][1] * tempW
        pos1Y = contentY + leidaBase[index1][2] * tempH

        tempW = param[index2] / CityBattleUtils.leidaMaxValue[index2] * 32
        tempH = param[index2] / CityBattleUtils.leidaMaxValue[index2] * 32
        pos2X = contentX + leidaBase[index2][1] * tempW
        pos2Y = contentY + leidaBase[index2][2] * tempH

        inView:drawTriangle(cc.p(pos1X, pos1Y), cc.p(pos2X, pos2Y), cc.p(contentX,contentY), CityBattleUtils.zhenyingTable["cfColor" .. cfType])
    end
end

-- 绘制雷达图 新
-- param 当前等级， 
-- contentX, contentY 位置， 
-- cfInerType 填充颜色类型
-- cfBorderType 围边颜色类型
-- r 边长
-- 定点点的边长,table

CityBattleUtils.drawLeidaNew = function(param, contentX, contentY, cfInerType,cfBorderType,r,pointR)
    local drawNode = CC_DRAWNODE:create()
    drawNode:setAnchorPoint(0.5,0.5)
   local points =  CityBattleUtils.updateDrawLeidaNew(drawNode, param, contentX, contentY, cfInerType, cfBorderType,r,pointR)
    return drawNode,points
end

CityBattleUtils.mathF = function(x)
    return 20*x/(x+10)
end

CityBattleUtils.updateDrawLeidaNew = function(drawNode, param, contentX, contentY, cfType, cfBorderType, r, pointR)
    if not contentX then
        contentX = 0
    end

    if not contentY then
        contentY = 0
    end
    if not cfType then
        cfType = 5
    end
    if not cfBorderType then cfBorderType = 5 end
    local d = r or 42
    local d1 = pointR or leidaPointValue
    drawNode:clear()
    local points = {}
    -- local points1 = {}
    local smallIndex = 1
    local startValue = param[1]
    for i=1,6 do
        local pos1X, pos1Y = 0, 0
        -- local pos2X, pos2Y = 0, 0
        local index1 = i
        local level = param[index1]
        local realLevel = CityBattleUtils.mathF(level)
        local baseNum =  CityleidaBase[index1]
        local tempW = realLevel / LeidaMaxValue[index1] * d
        local tempH = realLevel / LeidaMaxValue[index1] * d
        pos1X = contentX + baseNum[1] * tempW
        pos1Y = contentY + baseNum[2] * tempH
        -- pos2X = contentX + baseNum[1] * tempW/d*d1[level]
        -- pos2Y = contentY + baseNum[2] * tempH/d*d1[level]
        -- table.insert(points,{level = level,point = cc.p(pos1X, pos1Y)})
        points[i] = cc.p(pos1X, pos1Y)
        -- points1[i] = cc.p(pos2X, pos2Y)
        if level < startValue then
            startValue = level
            smallIndex = i
        end
    end
    local resultPoints = {}
    for i = smallIndex,6 do 
        table.insert(resultPoints,points[i])
    end
    if smallIndex > 1 then
        for i=1,smallIndex-1 do 
            table.insert(resultPoints,points[i])
        end
    end
    local color = DrawColor4F[cfType]
    local colorBorder = DrawColor4F[cfBorderType]
    --实体多边形
    drawNode:drawPolygon(resultPoints,table.nums(resultPoints),color,1,colorBorder)
    return resultPoints
end

function CityBattleUtils.createLeiDaTip(parentNode,level,readyData, secNameData,partKey)
    local tipMask = parentNode:getChildByName("tipMask")
    if tipMask then
        tipMask:setVisible(true)
        CityBattleUtils.updateGlobalTips(tipMask:getChildByName("bottomImage"),level,readyData, secNameData,partKey)
        return
    end

    local mask = ccui.Layout:create()
    mask:setBackGroundColorOpacity(0)
    mask:setBackGroundColorType(1)
    mask:setBackGroundColor(cc.c3b(0,0,0))
    mask:setContentSize(MAX_SCREEN_WIDTH,MAX_SCREEN_HEIGHT)
    mask:setName("tipMask")
    parentNode:addChild(mask, 1000)
    mask:setTouchEnabled(true)
    parentNode:registerClickEvent(mask,function()
        mask:setVisible(false)
    end)

    local bottomImage = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI5_tipBg.png")
    bottomImage:setCapInsets(cc.rect(35,35,1,1))
    bottomImage:setContentSize(480,330)
    bottomImage:setAnchorPoint(0.5,0.5)
    mask:addChild(bottomImage)
    if secNameData.side == "left" then
        bottomImage:setPosition(235 ,290)
    elseif secNameData.side == "right" then
        bottomImage:setPosition(MAX_SCREEN_WIDTH - 235 ,290)
    else
        bottomImage:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    end

    local leidaPanle = ccui.Layout:create()
    leidaPanle:setContentSize(178,212)
    leidaPanle:setPosition(40,30)
    leidaPanle:setName("leidaPanle")
    bottomImage:addChild(leidaPanle,50)
    local leidaBg = cc.Sprite:createWithSpriteFrameName("citybattle_leida_bg.png")
    leidaPanle:addChild(leidaBg)
    leidaBg:setPosition(91,106)

    local param = {
        {icon = "citybattle_attribute_1.png",pos = cc.p(90,213)},
        {icon = "citybattle_attribute_2.png",pos = cc.p(180,161)},
        {icon = "citybattle_attribute_3.png",pos = cc.p(180,55)},
        {icon = "citybattle_attribute_4.png",pos = cc.p(90,-1)},
        {icon = "citybattle_attribute_5.png",pos = cc.p(-2,55)},
        {icon = "citybattle_attribute_6.png",pos = cc.p(-2,161)},
    }
    for _,data in pairs(param) do 
        local image = cc.Sprite:createWithSpriteFrameName(data.icon)
        image:setPosition(data.pos)
        leidaPanle:addChild(image)
    end
    local x1,x2,x3 = 270,300,400
    local y = 240
    for i=1,6 do 
        local icon = cc.Sprite:createWithSpriteFrameName("citybattle_attribute_"..i..".png")
        bottomImage:addChild(icon)
        icon:setPosition(x1,y-(i-1)*40)

        local labelAttr = cc.Label:createWithTTF("兵团恢复", UIUtils.ttfName, 20)
        labelAttr:setAnchorPoint(0,0.5)
        labelAttr:setPosition(x2,y-(i-1)*40)
        bottomImage:addChild(labelAttr)
        labelAttr:setName("attrName"..i)
        labelAttr:setColor(cc.c3b(252,244,197))

        local labelAttrNum = cc.Label:createWithTTF("+18", UIUtils.ttfName, 20)
        labelAttrNum:setAnchorPoint(0,0.5)
        labelAttrNum:setPosition(x3,y-(i-1)*40)
        bottomImage:addChild(labelAttrNum)
        labelAttrNum:setName("attrNum"..i)
        labelAttrNum:setColor(cc.c3b(0,255,30))

    end

    local nameLab = cc.Label:createWithTTF(secNameData.secName, UIUtils.ttfName, 24)
    nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    nameLab:setPosition(30, 295)
    nameLab:setAnchorPoint(0, 0.5)
    nameLab:setColor(cc.c3b(252,244,197))
    bottomImage:addChild(nameLab,50)
    bottomImage.nameLab = nameLab

    local desLab = cc.Label:createWithTTF(secNameData.secDes, UIUtils.ttfName, 16)
    desLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    desLab:setPosition(30, 270)
    desLab:setAnchorPoint(0, 0.5)
    desLab:setColor(cc.c3b(252,244,197))
    bottomImage:addChild(desLab,50)
    bottomImage.desLab = desLab

    bottomImage:setName("bottomImage")
    CityBattleUtils.updateGlobalTips(bottomImage,level,readyData, secNameData,partKey)
    return bottomImage
end

function CityBattleUtils.updateGlobalTips(tipsPanel,levels,readyData, secNameData,partKey)
    local leidaPanel = tipsPanel:getChildByName("leidaPanle")
    local panelCX,panelCY = leidaPanel:getContentSize().width/2,leidaPanel:getContentSize().height/2
    local points
    if not tipsPanel._drawNode then
        tipsPanel._drawNode,points = CityBattleUtils.drawLeidaNew(levels,panelCX,panelCY,6,6)
    else
        points = CityBattleUtils.updateDrawLeidaNew(tipsPanel._drawNode,levels,panelCX,panelCY,6,6)
    end

    if tipsPanel.nameLab ~= nil then
        tipsPanel.nameLab:setString(secNameData.secName)
    end

    if tipsPanel.desLab ~= nil then
        tipsPanel.desLab:setString(secNameData.secDes)
    end

    if secNameData.side == "left" then
        tipsPanel:setPosition(235 ,290)
    elseif secNameData.side == "right" then
        tipsPanel:setPosition(MAX_SCREEN_WIDTH - 235 ,290)
    else
        tipsPanel:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
    end

    if not tipsPanel._clipNode then
        tipsPanel._clipNode = cc.ClippingNode:create()   
        tipsPanel._clipNode:setContentSize(panelCX*2,panelCY*2)
        tipsPanel._clipNode:setStencil(tipsPanel._drawNode)
        leidaPanel:addChild(tipsPanel._clipNode,100)
    end

    if not tipsPanel._drawMask then
        tipsPanel._drawMask = cc.Sprite:createWithSpriteFrameName("citybattle_leida_mask.png")
        tipsPanel._drawMask:setPosition(panelCX,panelCY)
        tipsPanel._drawMask:getTexture():setAntiAliasTexParameters()
        tipsPanel._drawMask:setOpacity(180)
        tipsPanel._clipNode:addChild(tipsPanel._drawMask)
        tipsPanel._clipNode:setInverted(false) 
    end

    if leidaPanel:getChildByName("point_1") then
        for key,point in pairs (points) do 
            local pointImgae = leidaPanel:getChildByName("point_"..key)
            pointImgae:setPosition(point)
        end
    else
        for key,point in pairs (points) do 
            local imagePoint = cc.Sprite:createWithSpriteFrameName("citybattle_point.png")
            imagePoint:setPosition(point)
            leidaPanel:addChild(imagePoint)
            imagePoint:setName("point_"..key)
        end
    end
    local testData = readyData
    local partKey  = partKey
    for i=1,6 do 
        local exp,level = CityBattleUtils.getCurLvlAndExp(i,tonumber(testData["e"..i]))
        local buildTab  = tab:CityBattlePrepare(i)
        --buff 描述
        local factors = 0
        for i=1,level do 
            factors = factors + buildTab.factor[i]
        end
        factors = factors * buildTab["part"..partKey]
        local buff_des =  lang(buildTab.des)
        local result,success = string.gsub(buff_des,"{$factor100}",factors*100)
        if success == 0 then
            result = string.gsub(buff_des,"{$factor}",factors)
        end
        local index1 = string.find(result,"+")
        local sub1 = string.sub(result,1,index1-1)
        local sub2 = string.sub(result,index1,string.len(result))
        local attrName = tipsPanel:getChildByName("attrName"..i)
        local attrNum = tipsPanel:getChildByName("attrNum"..i)
        attrName:setString(sub1)
        attrNum:setString(sub2)
    end

end

function CityBattleUtils.getCurLvlAndExp(id,exp)
    local tabData = tab:CityBattlePrepare(id)
    local tabExp = tabData.exp
    local lvlLimit = tabData.maxlv 
    local lvl = 1
    local n = 1
    local needExp = 0
    local leftExp = exp
    while true do 
        if lvl + 1 > lvlLimit then
            break
        end
        needExp = needExp + tabExp[n]
        if exp >= needExp then
            lvl = lvl + 1
            leftExp = leftExp - tabExp[n]
        else
            break
        end
        n = n + 1
    end
    return leftExp,lvl
end

function CityBattleUtils.dtor()
    CC_DRAWNODE = nil
    CityleidaBase = nil
    LeidaMaxValue = nil
    DrawColor4F = nil
    CityBattleUtils = nil
end

return CityBattleUtils