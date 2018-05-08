--[[
    Filename:    CrossUtils.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-08 15:07:20
    Description: File description
--]]

local CrossUtils = {}

CrossUtils.mapImg = {
    [1] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross1.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {504, 567}, btnpos = {435, 565, 0.8}},
    [2] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross2.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {667, 1070}, btnpos = {607, 1010, 0.8}},
    [3] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross3.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {684, 824}, btnpos = {604, 724, 0.8}},
    [4] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross4.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {410, 384}, btnpos = {350, 304, 0.8}},
    [5] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross5.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {808, 511}, btnpos = {768, 431, 0.8}},
    [6] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross6.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {505, 270}, btnpos = {455, 170, 0.8}},
    [7] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross7.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {1149, 453}, btnpos = {989, 333, 0.8}},
    [8] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross8.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {261, 652}, btnpos = {221, 572, 0.8}},
    [9] = {hue = 0, saturation = 0, brightness = 0, contrast = 0, img = "mapBorder_cross9.png", rColor = cc.c4b(255, 53, 30, 255), bColor = cc.c4b(20, 203, 255, 255), pos = {1166, 1083}, btnpos = {1080, 1000, 0.8}},
}
function CrossUtils:getVertices(radius)
    local vertices = {}
    local radius = radius
    local segments = 360
    local coef = math.pi/180
    for i=0, segments do
        local rads = i * coef
        local x    = radius * math.sin(rads)
        local y    = radius * math.cos(rads)
        table.insert(vertices, cc.p(x, y))
    end
    return vertices
end

function CrossUtils:drawSector(drawNode, radius, beginPos, endPos, fillColor, color)
    local vertices = self:getVertices(radius)

    local pPolygonPtArr = {}
    table.insert(pPolygonPtArr, cc.p(0, 0))
    for i=beginPos, endPos do
        local x = vertices[i+1].x
        local y = vertices[i+1].y
        table.insert(pPolygonPtArr, cc.p(x, y))
    end

    local borderWidth = 0.5
    drawNode:drawPolygon(pPolygonPtArr, table.nums(pPolygonPtArr), fillColor, borderWidth, color)
end

function CrossUtils:drawCircle() 
    local towerNode = self:getUI("bg")
    local drawNode = cc.DrawNode:create()
    drawNode:setPosition(200, 200)
    towerNode:addChild(drawNode)

    local radius = 150
    local beginPos = 0
    local endPos = 80
    local color = cc.c4f(0.0, 0.0, 0.0, 1.0)
    local fillColor = cc.c4f(1.0, 0.0, 0.0, 1.0)
    CrossUtils:drawSector(drawNode, radius, beginPos, endPos, fillColor, color)

    local beginPos = endPos
    local endPos = endPos + 80
    local fillColor = cc.c4f(1.0, 0.0, 1.0, 1.0)
    CrossUtils:drawSector(drawNode, radius, beginPos, endPos, fillColor, color)
   
    local beginPos = endPos
    local endPos = endPos + 80
    local fillColor = cc.c4f(1.0, 0.0, 0.0, 1.0)
    CrossUtils:drawSector(drawNode, radius, beginPos, endPos, fillColor, color)

    local beginPos = endPos
    local endPos = endPos + 80
    local fillColor = cc.c4f(1.0, 1.0, 0.0, 1.0)
    CrossUtils:drawSector(drawNode, radius, beginPos, endPos, fillColor, color)

    local beginPos = endPos
    local endPos = endPos + 40
    local fillColor = cc.c4f(0.0, 1.0, 0.0, 1.0)
    CrossUtils:drawSector(drawNode, radius, beginPos, endPos, fillColor, color)

    local beginPos = 0
    local endPos = 360
    local fillColor = cc.c4f(1, 1, 1, 1.0)
    CrossUtils:drawSector(drawNode, 30, beginPos, endPos, fillColor, color)
end

return CrossUtils