--[[
    Filename:    HappyPopConst.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-11-8 21:00
    Description: 法术小游戏 消消乐常量
--]]


HappyPopConst = {}

HappyPopConst.cardType = {
	skill = 1,   	--小技能
	master = 2,		--大招
	hero = 3, 		--英雄
	clock = 4,		--时钟
}

HappyPopConst.isShow = false   	--是否显示牌id
HappyPopConst.isSkip = false   	--是否快速点击
HappyPopConst.isSkipHero = true --是否跳过英雄关联牌
HappyPopConst.revertTime = 0.4  --快速点击翻牌间隔时间