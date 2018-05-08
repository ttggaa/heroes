--[[
    Filename:    IntanceGuideCurtainLayer.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-31 10:19:33
    Description: File description
--]]

local IntanceGuideCurtainLayer = class("IntanceGuideCurtainLayer",BaseMvcs, cc.Layer)

--[[
 @desc  创建
 @return 
--]]
function IntanceGuideCurtainLayer:ctor()
    IntanceGuideCurtainLayer.super.ctor(self)

	local curtain1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))   --下
	curtain1:setContentSize(cc.size(MAX_SCREEN_WIDTH, 150))  --160
	curtain1:setPosition(0, -150)
	curtain1:setName("curtain1")
	self:addChild(curtain1,3)

	local curtain2 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))   --上
	curtain2:setContentSize(cc.size(MAX_SCREEN_WIDTH, 150))   --160
	curtain2:setPosition(0, MAX_SCREEN_HEIGHT )
	curtain2:setAnchorPoint(0,0)
	curtain2:setName("curtain2")
	self:addChild(curtain2,3)

end


function IntanceGuideCurtainLayer:play()
	local curtain1 = self:getChildByName("curtain1")
	local x ,y = curtain1:getPosition()
	y = y + 115
	local action1 = cc.MoveTo:create(0.55, cc.p(x, y))
	curtain1:runAction(cc.EaseIn:create(action1,0.52))

	local curtain2 = self:getChildByName("curtain2")
	x ,y = curtain2:getPosition()
	y = y - 115
	action1 = cc.MoveTo:create(0.55, cc.p(x, y))
	curtain2:runAction(cc.EaseIn:create(action1,0.52))
end

function IntanceGuideCurtainLayer:doPlay()
	local curtain1 = self:getChildByName("curtain1")
	local x ,y = curtain1:getPosition()
	y = y + 115
	curtain1:setPosition(x, y)

	local curtain2 = self:getChildByName("curtain2")
	x ,y = curtain2:getPosition()
	y = y - 115
	curtain2:setPosition(x, y)
end

function IntanceGuideCurtainLayer:reversePlay(callback)
	local curtain1 = self:getChildByName("curtain1")
	local x ,y = curtain1:getPosition()
	y = y - 100
	local action1 = cc.MoveTo:create(0.55, cc.p(x, y))
	curtain1:runAction(cc.EaseIn:create(action1,0.52))

	local curtain2 = self:getChildByName("curtain2")
	x ,y = curtain2:getPosition()
	y = y + 100
	action1 = cc.MoveTo:create(0.55, cc.p(x, y))
	curtain2:runAction(cc.Sequence:create(cc.EaseIn:create(action1,0.52), cc.CallFunc:create(function ()
		if callback then callback() end
	end)))
end


return IntanceGuideCurtainLayer