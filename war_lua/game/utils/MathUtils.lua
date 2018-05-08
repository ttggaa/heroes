--[[
    Filename:    MathUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-01-23 19:40:27
    Description: File description
--]]

local MathUtils = {}

--[[
--! @function angleAtan2
--! @desc 两点之间角度
--! @param inBeginPoint cc.p 起始点
--! @param inEndPoint cc.p 起始点
--! @return
--]]
function MathUtils.angleAtan2(inBeginPoint, inEndPoint)
	local angle = 180 - math.atan2((inEndPoint.x - inBeginPoint.x), (inEndPoint.y - inBeginPoint.y)) * 180 / math.pi 
	return angle
end

--[[
--! @function midpoint
--! @desc 两点之间中心点
--! @param inBeginPoint cc.p 起始点
--! @param inEndPoint cc.p 起始点
--! @return
--]]
function MathUtils.midpoint(inBeginPoint, inEndPoint)
	return cc.p((inBeginPoint.x + inEndPoint.x) / 2.0, (inBeginPoint.y + inEndPoint.y) / 2.0)
end


function MathUtils.pointDistance(inBeginPoint, inEndPoint)
    return math.sqrt(math.pow((inEndPoint.y - inBeginPoint.y),2) + math.pow((inEndPoint.x- inBeginPoint.x),2))
end

return MathUtils