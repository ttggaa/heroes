--[[
    Filename:    TestHerosView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-12-06 21:01:24
    Description: File description
--]]

local TestHerosView = class("TestHerosView", BaseView)

function TestHerosView:ctor(inData)
    TestHerosView.super.ctor(self)

end


function TestHerosView:onInit()
    local IntanceMcAnimNode = require("game.view.intance.IntanceMcAnimNode")
    local heros = {"yingxiongkenluohage","yingxiongaideleide", "yingxiongkaiselin", "yingxiongluoyide", "yingxiongmengfeila", "yingxiongmulake", "yingxiongweidenina", "yingxionggelu", "yingxiongluodehate"}
    local actions = {"stop", "win", "zuoji", "win", "suck", "run2" , "run", "hit2", "hit1", "dizzy", "die2", "die1", "atk3", "atk2", "atk1"}
    self._actionIndex = 1
    self._heroIndex = 1
    self._nameLab = cc.Label:createWithTTF("", UIUtils.ttfName, 30)
    self._nameLab:setPosition(568, 600)
    self._nameLab:setAnchorPoint(0, 0)
    self._nameLab:setColor(cc.c3b(255, 255, 255))
    self._nameLab:enableOutline(cc.c4b(0,0,0,255), 1)
    self:addChild(self._nameLab)   
    local i = 1
    local j = 420
    local heroMcs = {}
    local n = 1
    for k,v in pairs(heros) do
        local intanceMcAnimNode = IntanceMcAnimNode.new(actions, v,
        function(sender) 
            -- mcMgr:release(v)
            self._nameLab:setString(actions[self._actionIndex])
            sender:runByName(actions[self._actionIndex])
            end
            ,100,100,
            {"stop", "win"},{1, 1})
        -- intanceMcAnimNode:setScale(0.5)
        self:addChild(intanceMcAnimNode, 101)
        intanceMcAnimNode:setPosition(i * 300, j)
        i = i +  1
        if i > 3 then
            n = n + 1
            i = 1
            j = j - 200
        end
        table.insert(heroMcs, intanceMcAnimNode)
    end
    self._bgLayer = ccui.Layout:create()
    self._bgLayer:setBackGroundColorOpacity(0)
    self._bgLayer:setBackGroundColorType(1)
    self._bgLayer:setBackGroundColor(cc.c3b(0, 0, 0))
    self._bgLayer:setTouchEnabled(true)
    self._bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(self._bgLayer, 0)    
    registerClickEvent(self._bgLayer, function()
        self._actionIndex = self._actionIndex + 1
        if self._actionIndex > #actions then 
            self._actionIndex = 1
        end
        self._nameLab:setString(actions[self._actionIndex])
        for k,v in pairs(heroMcs) do
            v:runByName(actions[self._actionIndex])
        end
    end)
    local button = ccui.Button:create("activity_carnival_dayBtn_n.png", "activity_carnival_dayBtn_n.png", "", 1)
    button:setPosition(MAX_SCREEN_WIDTH - 60, 60)
    self:addChild(button)
    registerClickEvent(button, function()
        for k,v in pairs(heroMcs) do
            v:removeFromParent()
        end
        heroMcs = {}
        self._actionIndex = 1
        local intanceMcAnimNode = IntanceMcAnimNode.new(actions, heros[self._heroIndex],
        function(sender) 
            -- mcMgr:release(v)
            self._nameLab:setString(actions[self._actionIndex])
            sender:runByName(actions[self._actionIndex])
            end
            ,100,100,
            {"stop", "win"},{1, 1})
        -- intanceMcAnimNode:setScale(0.5)
        self:addChild(intanceMcAnimNode, 101)
        intanceMcAnimNode:setPosition(MAX_SCREEN_WIDTH/2, MAX_SCREEN_HEIGHT/2 - 100)
        table.insert(heroMcs, intanceMcAnimNode)      
        self._heroIndex = self._heroIndex + 1  
        if self._heroIndex > #heros then 
            self._heroIndex = 1
        end
    end)
end

function TestHerosView:hideNoticeBar()

end

return TestHerosView